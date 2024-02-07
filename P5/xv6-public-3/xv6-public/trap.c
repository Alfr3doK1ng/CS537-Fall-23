#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "x86.h"
#include "traps.h"
#include "spinlock.h"
#include "mmap.h"

// Interrupt descriptor table (shared by all CPUs).
struct gatedesc idt[256];
extern uint vectors[];  // in vectors.S: array of 256 entry pointers
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);

  initlock(&tickslock, "time");
}

void
idtinit(void)
{
  lidt(idt, sizeof(idt));
}

void handle_shared_mapping(struct proc *current_process, uint page_fault_addr, char *new_physical_addr, int i)
{
  uint start = current_process -> list_map[i].addr; 
  uint end = start + current_process -> list_map[i].length; 

  if(page_fault_addr < start && page_fault_addr >= end){
    pte_t *pte = walkpgdir(current_process->parent->pgdir, (void *)page_fault_addr, 0);
    mappages(current_process->pgdir, (void*)page_fault_addr, PGSIZE, PTE_ADDR(*pte), PTE_U | PTE_W);
  } else {
    mappages(current_process->pgdir, (void *)page_fault_addr, PGSIZE, V2P(new_physical_addr), PTE_U | PTE_W);
  }
}

void handle_private_mapping(struct proc *current_process, uint page_fault_addr, char *new_physical_addr)
{
  pte_t *pte = walkpgdir(current_process->parent->pgdir, (void *)page_fault_addr, 0);
  char *parent = (char *)P2V(PTE_ADDR(*pte));
  memmove(new_physical_addr, parent, PGSIZE);
  mappages(current_process->pgdir, (void *)page_fault_addr, PGSIZE, V2P(new_physical_addr), PTE_U | PTE_W);
}

void*
page_fault_handler() 
{
  struct proc *current_process = myproc();
  uint page_fault_addr = rcr2();
  int is_guard = 1; 
  
  for(int i = 0; i < MAP_MAXN; i++) {

    if(current_process->list_map[i].is_mapped) {
      uint rounded_max_addr = PGROUNDUP(((uint)current_process->list_map[i].addr) + current_process->list_map[i].length); 
      // Check for virtual address being out of bounds
      if (!(page_fault_addr >= current_process->list_map[i].addr && page_fault_addr < rounded_max_addr)) {
        // Directly handle the case where the MAP_GROWSUP flag is not set
        if ((current_process->list_map[i].flags & MAP_GROWSUP) == 0) {
          cprintf("Segmentation Fault\n");
          current_process->killed = 1;
          return (void*)-1;
        }

        for (int index = 0; index < MAP_MAXN; index++) {
          struct mapping_info *guard_mapping = &current_process->list_map[index];
          if (guard_mapping->is_mapped || &current_process->list_map[i] == guard_mapping) {
            uint guard_start = guard_mapping->addr;
            uint guard_end = guard_start + guard_mapping->length;
            if (page_fault_addr + PGSIZE > guard_start && page_fault_addr < guard_end) {
              is_guard = 0;
            }
          } 
        }

        // At this point, MAP_GROWSUP must be set, so check the guard page
        if (is_guard == 0) {
          cprintf("Segmentation Fault\n");
          current_process->killed = 1;
          return (void*)-1;
        }
      } 

      char *new_physical_addr = kalloc();
      // If MAP_SHARED bit is present
      if(current_process -> list_map[i].flags & MAP_SHARED){
        handle_shared_mapping(current_process, page_fault_addr, new_physical_addr, i);
      } else {
      // If MAP_PRIVATE bit is present
        handle_private_mapping(current_process, page_fault_addr, new_physical_addr);
      }

      // If memory is backed by a file
      if(!(current_process->list_map[i].flags & MAP_ANON)) { 
        fileread(current_process->list_map[i].f, (char*)(page_fault_addr), PGSIZE);
      }     
    }
      
  }

  return (void*)0;
}

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
  if(tf->trapno == T_SYSCALL){
    if(myproc()->killed)
      exit();
    myproc()->tf = tf;
    syscall();
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE:
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_COM1:
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
    break;
  case T_PGFLT:
    page_fault_handler();
    break;

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();
}
