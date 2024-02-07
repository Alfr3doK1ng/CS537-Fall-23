#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
  return fork();
}

int
sys_exit(void)
{
  exit();
  return 0;  // not reached
}

int
sys_wait(void)
{
  return wait();
}

int
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

int
sys_getpid(void)
{
  return myproc()->pid;
}

int
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

int
sys_sleep(void)
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

int sys_mmap(void) {
  int args[6]; // For addr, length, prot, flags, fd, offset

  // Extract each argument and store it in the args array
  for (int i = 0; i < 6; i++) {
    if (argint(i, &args[i]) < 0) {
      return -1; // Return -1 on failure to extract an argument
    }
  }

  // Cast the first argument to a pointer since it's supposed to be a void*
  void *addr = (void*)args[0];

  // Call mmap with the arguments extracted
  void *ret = mmap(addr, args[1], args[2], args[3], args[4], args[5]);

  // If mmap failed, return -1
  if (ret == (void*)-1) {
    return -1;
  }

  // Otherwise, cast the return value to an integer and return it
  return (int)ret;
}

int sys_munmap(void) {
  int args[2]; // For addr and length

  // Extract each argument and store it in the args array
  for (int i = 0; i < 2; i++) {
    if (argint(i, &args[i]) < 0) {
      return -1; // Return -1 on failure to extract an argument
    }
  }

  // Cast the first argument to a pointer since it's supposed to be a void*
  void *addr = (void*)args[0];
  int length = args[1];
  // Call munmap with the arguments extracted
  return munmap(addr, length);
}