
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc e0 68 11 80       	mov    $0x801168e0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 5b 38 10 80       	mov    $0x8010385b,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 c8 86 10 80       	push   $0x801086c8
80100042:	68 80 b5 10 80       	push   $0x8010b580
80100047:	e8 27 52 00 00       	call   80105273 <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 cc fc 10 80 7c 	movl   $0x8010fc7c,0x8010fccc
80100056:	fc 10 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 d0 fc 10 80 7c 	movl   $0x8010fc7c,0x8010fcd0
80100060:	fc 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 b4 b5 10 80 	movl   $0x8010b5b4,-0xc(%ebp)
8010006a:	eb 47                	jmp    801000b3 <binit+0x7f>
    b->next = bcache.head.next;
8010006c:	8b 15 d0 fc 10 80    	mov    0x8010fcd0,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 50 7c fc 10 80 	movl   $0x8010fc7c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	83 c0 0c             	add    $0xc,%eax
80100088:	83 ec 08             	sub    $0x8,%esp
8010008b:	68 cf 86 10 80       	push   $0x801086cf
80100090:	50                   	push   %eax
80100091:	e8 5a 50 00 00       	call   801050f0 <initsleeplock>
80100096:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
80100099:	a1 d0 fc 10 80       	mov    0x8010fcd0,%eax
8010009e:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000a1:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	a3 d0 fc 10 80       	mov    %eax,0x8010fcd0
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000ac:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000b3:	b8 7c fc 10 80       	mov    $0x8010fc7c,%eax
801000b8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000bb:	72 af                	jb     8010006c <binit+0x38>
  }
}
801000bd:	90                   	nop
801000be:	90                   	nop
801000bf:	c9                   	leave  
801000c0:	c3                   	ret    

801000c1 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000c1:	55                   	push   %ebp
801000c2:	89 e5                	mov    %esp,%ebp
801000c4:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000c7:	83 ec 0c             	sub    $0xc,%esp
801000ca:	68 80 b5 10 80       	push   $0x8010b580
801000cf:	e8 c1 51 00 00       	call   80105295 <acquire>
801000d4:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000d7:	a1 d0 fc 10 80       	mov    0x8010fcd0,%eax
801000dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000df:	eb 58                	jmp    80100139 <bget+0x78>
    if(b->dev == dev && b->blockno == blockno){
801000e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e4:	8b 40 04             	mov    0x4(%eax),%eax
801000e7:	39 45 08             	cmp    %eax,0x8(%ebp)
801000ea:	75 44                	jne    80100130 <bget+0x6f>
801000ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ef:	8b 40 08             	mov    0x8(%eax),%eax
801000f2:	39 45 0c             	cmp    %eax,0xc(%ebp)
801000f5:	75 39                	jne    80100130 <bget+0x6f>
      b->refcnt++;
801000f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fa:	8b 40 4c             	mov    0x4c(%eax),%eax
801000fd:	8d 50 01             	lea    0x1(%eax),%edx
80100100:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100103:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
80100106:	83 ec 0c             	sub    $0xc,%esp
80100109:	68 80 b5 10 80       	push   $0x8010b580
8010010e:	e8 f0 51 00 00       	call   80105303 <release>
80100113:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100116:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100119:	83 c0 0c             	add    $0xc,%eax
8010011c:	83 ec 0c             	sub    $0xc,%esp
8010011f:	50                   	push   %eax
80100120:	e8 07 50 00 00       	call   8010512c <acquiresleep>
80100125:	83 c4 10             	add    $0x10,%esp
      return b;
80100128:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010012b:	e9 9d 00 00 00       	jmp    801001cd <bget+0x10c>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100130:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100133:	8b 40 54             	mov    0x54(%eax),%eax
80100136:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100139:	81 7d f4 7c fc 10 80 	cmpl   $0x8010fc7c,-0xc(%ebp)
80100140:	75 9f                	jne    801000e1 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100142:	a1 cc fc 10 80       	mov    0x8010fccc,%eax
80100147:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014a:	eb 6b                	jmp    801001b7 <bget+0xf6>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010014c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014f:	8b 40 4c             	mov    0x4c(%eax),%eax
80100152:	85 c0                	test   %eax,%eax
80100154:	75 58                	jne    801001ae <bget+0xed>
80100156:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100159:	8b 00                	mov    (%eax),%eax
8010015b:	83 e0 04             	and    $0x4,%eax
8010015e:	85 c0                	test   %eax,%eax
80100160:	75 4c                	jne    801001ae <bget+0xed>
      b->dev = dev;
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	8b 55 08             	mov    0x8(%ebp),%edx
80100168:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010016b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016e:	8b 55 0c             	mov    0xc(%ebp),%edx
80100171:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
80100174:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100177:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
8010017d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100180:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
80100187:	83 ec 0c             	sub    $0xc,%esp
8010018a:	68 80 b5 10 80       	push   $0x8010b580
8010018f:	e8 6f 51 00 00       	call   80105303 <release>
80100194:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100197:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010019a:	83 c0 0c             	add    $0xc,%eax
8010019d:	83 ec 0c             	sub    $0xc,%esp
801001a0:	50                   	push   %eax
801001a1:	e8 86 4f 00 00       	call   8010512c <acquiresleep>
801001a6:	83 c4 10             	add    $0x10,%esp
      return b;
801001a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001ac:	eb 1f                	jmp    801001cd <bget+0x10c>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b1:	8b 40 50             	mov    0x50(%eax),%eax
801001b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001b7:	81 7d f4 7c fc 10 80 	cmpl   $0x8010fc7c,-0xc(%ebp)
801001be:	75 8c                	jne    8010014c <bget+0x8b>
    }
  }
  panic("bget: no buffers");
801001c0:	83 ec 0c             	sub    $0xc,%esp
801001c3:	68 d6 86 10 80       	push   $0x801086d6
801001c8:	e8 e8 03 00 00       	call   801005b5 <panic>
}
801001cd:	c9                   	leave  
801001ce:	c3                   	ret    

801001cf <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001cf:	55                   	push   %ebp
801001d0:	89 e5                	mov    %esp,%ebp
801001d2:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001d5:	83 ec 08             	sub    $0x8,%esp
801001d8:	ff 75 0c             	push   0xc(%ebp)
801001db:	ff 75 08             	push   0x8(%ebp)
801001de:	e8 de fe ff ff       	call   801000c1 <bget>
801001e3:	83 c4 10             	add    $0x10,%esp
801001e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
801001e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001ec:	8b 00                	mov    (%eax),%eax
801001ee:	83 e0 02             	and    $0x2,%eax
801001f1:	85 c0                	test   %eax,%eax
801001f3:	75 0e                	jne    80100203 <bread+0x34>
    iderw(b);
801001f5:	83 ec 0c             	sub    $0xc,%esp
801001f8:	ff 75 f4             	push   -0xc(%ebp)
801001fb:	e8 5b 27 00 00       	call   8010295b <iderw>
80100200:	83 c4 10             	add    $0x10,%esp
  }
  return b;
80100203:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100206:	c9                   	leave  
80100207:	c3                   	ret    

80100208 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
80100208:	55                   	push   %ebp
80100209:	89 e5                	mov    %esp,%ebp
8010020b:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
8010020e:	8b 45 08             	mov    0x8(%ebp),%eax
80100211:	83 c0 0c             	add    $0xc,%eax
80100214:	83 ec 0c             	sub    $0xc,%esp
80100217:	50                   	push   %eax
80100218:	e8 c1 4f 00 00       	call   801051de <holdingsleep>
8010021d:	83 c4 10             	add    $0x10,%esp
80100220:	85 c0                	test   %eax,%eax
80100222:	75 0d                	jne    80100231 <bwrite+0x29>
    panic("bwrite");
80100224:	83 ec 0c             	sub    $0xc,%esp
80100227:	68 e7 86 10 80       	push   $0x801086e7
8010022c:	e8 84 03 00 00       	call   801005b5 <panic>
  b->flags |= B_DIRTY;
80100231:	8b 45 08             	mov    0x8(%ebp),%eax
80100234:	8b 00                	mov    (%eax),%eax
80100236:	83 c8 04             	or     $0x4,%eax
80100239:	89 c2                	mov    %eax,%edx
8010023b:	8b 45 08             	mov    0x8(%ebp),%eax
8010023e:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100240:	83 ec 0c             	sub    $0xc,%esp
80100243:	ff 75 08             	push   0x8(%ebp)
80100246:	e8 10 27 00 00       	call   8010295b <iderw>
8010024b:	83 c4 10             	add    $0x10,%esp
}
8010024e:	90                   	nop
8010024f:	c9                   	leave  
80100250:	c3                   	ret    

80100251 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100251:	55                   	push   %ebp
80100252:	89 e5                	mov    %esp,%ebp
80100254:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100257:	8b 45 08             	mov    0x8(%ebp),%eax
8010025a:	83 c0 0c             	add    $0xc,%eax
8010025d:	83 ec 0c             	sub    $0xc,%esp
80100260:	50                   	push   %eax
80100261:	e8 78 4f 00 00       	call   801051de <holdingsleep>
80100266:	83 c4 10             	add    $0x10,%esp
80100269:	85 c0                	test   %eax,%eax
8010026b:	75 0d                	jne    8010027a <brelse+0x29>
    panic("brelse");
8010026d:	83 ec 0c             	sub    $0xc,%esp
80100270:	68 ee 86 10 80       	push   $0x801086ee
80100275:	e8 3b 03 00 00       	call   801005b5 <panic>

  releasesleep(&b->lock);
8010027a:	8b 45 08             	mov    0x8(%ebp),%eax
8010027d:	83 c0 0c             	add    $0xc,%eax
80100280:	83 ec 0c             	sub    $0xc,%esp
80100283:	50                   	push   %eax
80100284:	e8 07 4f 00 00       	call   80105190 <releasesleep>
80100289:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
8010028c:	83 ec 0c             	sub    $0xc,%esp
8010028f:	68 80 b5 10 80       	push   $0x8010b580
80100294:	e8 fc 4f 00 00       	call   80105295 <acquire>
80100299:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	8b 40 4c             	mov    0x4c(%eax),%eax
801002a2:	8d 50 ff             	lea    -0x1(%eax),%edx
801002a5:	8b 45 08             	mov    0x8(%ebp),%eax
801002a8:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002ab:	8b 45 08             	mov    0x8(%ebp),%eax
801002ae:	8b 40 4c             	mov    0x4c(%eax),%eax
801002b1:	85 c0                	test   %eax,%eax
801002b3:	75 47                	jne    801002fc <brelse+0xab>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002b5:	8b 45 08             	mov    0x8(%ebp),%eax
801002b8:	8b 40 54             	mov    0x54(%eax),%eax
801002bb:	8b 55 08             	mov    0x8(%ebp),%edx
801002be:	8b 52 50             	mov    0x50(%edx),%edx
801002c1:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002c4:	8b 45 08             	mov    0x8(%ebp),%eax
801002c7:	8b 40 50             	mov    0x50(%eax),%eax
801002ca:	8b 55 08             	mov    0x8(%ebp),%edx
801002cd:	8b 52 54             	mov    0x54(%edx),%edx
801002d0:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
801002d3:	8b 15 d0 fc 10 80    	mov    0x8010fcd0,%edx
801002d9:	8b 45 08             	mov    0x8(%ebp),%eax
801002dc:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801002df:	8b 45 08             	mov    0x8(%ebp),%eax
801002e2:	c7 40 50 7c fc 10 80 	movl   $0x8010fc7c,0x50(%eax)
    bcache.head.next->prev = b;
801002e9:	a1 d0 fc 10 80       	mov    0x8010fcd0,%eax
801002ee:	8b 55 08             	mov    0x8(%ebp),%edx
801002f1:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801002f4:	8b 45 08             	mov    0x8(%ebp),%eax
801002f7:	a3 d0 fc 10 80       	mov    %eax,0x8010fcd0
  }
  
  release(&bcache.lock);
801002fc:	83 ec 0c             	sub    $0xc,%esp
801002ff:	68 80 b5 10 80       	push   $0x8010b580
80100304:	e8 fa 4f 00 00       	call   80105303 <release>
80100309:	83 c4 10             	add    $0x10,%esp
}
8010030c:	90                   	nop
8010030d:	c9                   	leave  
8010030e:	c3                   	ret    

8010030f <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010030f:	55                   	push   %ebp
80100310:	89 e5                	mov    %esp,%ebp
80100312:	83 ec 14             	sub    $0x14,%esp
80100315:	8b 45 08             	mov    0x8(%ebp),%eax
80100318:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010031c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80100320:	89 c2                	mov    %eax,%edx
80100322:	ec                   	in     (%dx),%al
80100323:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80100326:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010032a:	c9                   	leave  
8010032b:	c3                   	ret    

8010032c <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010032c:	55                   	push   %ebp
8010032d:	89 e5                	mov    %esp,%ebp
8010032f:	83 ec 08             	sub    $0x8,%esp
80100332:	8b 45 08             	mov    0x8(%ebp),%eax
80100335:	8b 55 0c             	mov    0xc(%ebp),%edx
80100338:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010033c:	89 d0                	mov    %edx,%eax
8010033e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100341:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100345:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80100349:	ee                   	out    %al,(%dx)
}
8010034a:	90                   	nop
8010034b:	c9                   	leave  
8010034c:	c3                   	ret    

8010034d <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010034d:	55                   	push   %ebp
8010034e:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100350:	fa                   	cli    
}
80100351:	90                   	nop
80100352:	5d                   	pop    %ebp
80100353:	c3                   	ret    

80100354 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100354:	55                   	push   %ebp
80100355:	89 e5                	mov    %esp,%ebp
80100357:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010035a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010035e:	74 1c                	je     8010037c <printint+0x28>
80100360:	8b 45 08             	mov    0x8(%ebp),%eax
80100363:	c1 e8 1f             	shr    $0x1f,%eax
80100366:	0f b6 c0             	movzbl %al,%eax
80100369:	89 45 10             	mov    %eax,0x10(%ebp)
8010036c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100370:	74 0a                	je     8010037c <printint+0x28>
    x = -xx;
80100372:	8b 45 08             	mov    0x8(%ebp),%eax
80100375:	f7 d8                	neg    %eax
80100377:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010037a:	eb 06                	jmp    80100382 <printint+0x2e>
  else
    x = xx;
8010037c:	8b 45 08             	mov    0x8(%ebp),%eax
8010037f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100382:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100389:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010038c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010038f:	ba 00 00 00 00       	mov    $0x0,%edx
80100394:	f7 f1                	div    %ecx
80100396:	89 d1                	mov    %edx,%ecx
80100398:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010039b:	8d 50 01             	lea    0x1(%eax),%edx
8010039e:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003a1:	0f b6 91 04 90 10 80 	movzbl -0x7fef6ffc(%ecx),%edx
801003a8:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003b2:	ba 00 00 00 00       	mov    $0x0,%edx
801003b7:	f7 f1                	div    %ecx
801003b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003c0:	75 c7                	jne    80100389 <printint+0x35>

  if(sign)
801003c2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003c6:	74 2a                	je     801003f2 <printint+0x9e>
    buf[i++] = '-';
801003c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003cb:	8d 50 01             	lea    0x1(%eax),%edx
801003ce:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003d1:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003d6:	eb 1a                	jmp    801003f2 <printint+0x9e>
    consputc(buf[i]);
801003d8:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003de:	01 d0                	add    %edx,%eax
801003e0:	0f b6 00             	movzbl (%eax),%eax
801003e3:	0f be c0             	movsbl %al,%eax
801003e6:	83 ec 0c             	sub    $0xc,%esp
801003e9:	50                   	push   %eax
801003ea:	e8 f9 03 00 00       	call   801007e8 <consputc>
801003ef:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003f2:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003fa:	79 dc                	jns    801003d8 <printint+0x84>
}
801003fc:	90                   	nop
801003fd:	90                   	nop
801003fe:	c9                   	leave  
801003ff:	c3                   	ret    

80100400 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
80100400:	55                   	push   %ebp
80100401:	89 e5                	mov    %esp,%ebp
80100403:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
80100406:	a1 b4 ff 10 80       	mov    0x8010ffb4,%eax
8010040b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
8010040e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100412:	74 10                	je     80100424 <cprintf+0x24>
    acquire(&cons.lock);
80100414:	83 ec 0c             	sub    $0xc,%esp
80100417:	68 80 ff 10 80       	push   $0x8010ff80
8010041c:	e8 74 4e 00 00       	call   80105295 <acquire>
80100421:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100424:	8b 45 08             	mov    0x8(%ebp),%eax
80100427:	85 c0                	test   %eax,%eax
80100429:	75 0d                	jne    80100438 <cprintf+0x38>
    panic("null fmt");
8010042b:	83 ec 0c             	sub    $0xc,%esp
8010042e:	68 f5 86 10 80       	push   $0x801086f5
80100433:	e8 7d 01 00 00       	call   801005b5 <panic>

  argp = (uint*)(void*)(&fmt + 1);
80100438:	8d 45 0c             	lea    0xc(%ebp),%eax
8010043b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010043e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100445:	e9 2f 01 00 00       	jmp    80100579 <cprintf+0x179>
    if(c != '%'){
8010044a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010044e:	74 13                	je     80100463 <cprintf+0x63>
      consputc(c);
80100450:	83 ec 0c             	sub    $0xc,%esp
80100453:	ff 75 e4             	push   -0x1c(%ebp)
80100456:	e8 8d 03 00 00       	call   801007e8 <consputc>
8010045b:	83 c4 10             	add    $0x10,%esp
      continue;
8010045e:	e9 12 01 00 00       	jmp    80100575 <cprintf+0x175>
    }
    c = fmt[++i] & 0xff;
80100463:	8b 55 08             	mov    0x8(%ebp),%edx
80100466:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010046a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010046d:	01 d0                	add    %edx,%eax
8010046f:	0f b6 00             	movzbl (%eax),%eax
80100472:	0f be c0             	movsbl %al,%eax
80100475:	25 ff 00 00 00       	and    $0xff,%eax
8010047a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
8010047d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100481:	0f 84 14 01 00 00    	je     8010059b <cprintf+0x19b>
      break;
    switch(c){
80100487:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
8010048b:	74 5e                	je     801004eb <cprintf+0xeb>
8010048d:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100491:	0f 8f c2 00 00 00    	jg     80100559 <cprintf+0x159>
80100497:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
8010049b:	74 6b                	je     80100508 <cprintf+0x108>
8010049d:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
801004a1:	0f 8f b2 00 00 00    	jg     80100559 <cprintf+0x159>
801004a7:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004ab:	74 3e                	je     801004eb <cprintf+0xeb>
801004ad:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004b1:	0f 8f a2 00 00 00    	jg     80100559 <cprintf+0x159>
801004b7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004bb:	0f 84 89 00 00 00    	je     8010054a <cprintf+0x14a>
801004c1:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
801004c5:	0f 85 8e 00 00 00    	jne    80100559 <cprintf+0x159>
    case 'd':
      printint(*argp++, 10, 1);
801004cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004ce:	8d 50 04             	lea    0x4(%eax),%edx
801004d1:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004d4:	8b 00                	mov    (%eax),%eax
801004d6:	83 ec 04             	sub    $0x4,%esp
801004d9:	6a 01                	push   $0x1
801004db:	6a 0a                	push   $0xa
801004dd:	50                   	push   %eax
801004de:	e8 71 fe ff ff       	call   80100354 <printint>
801004e3:	83 c4 10             	add    $0x10,%esp
      break;
801004e6:	e9 8a 00 00 00       	jmp    80100575 <cprintf+0x175>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004ee:	8d 50 04             	lea    0x4(%eax),%edx
801004f1:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004f4:	8b 00                	mov    (%eax),%eax
801004f6:	83 ec 04             	sub    $0x4,%esp
801004f9:	6a 00                	push   $0x0
801004fb:	6a 10                	push   $0x10
801004fd:	50                   	push   %eax
801004fe:	e8 51 fe ff ff       	call   80100354 <printint>
80100503:	83 c4 10             	add    $0x10,%esp
      break;
80100506:	eb 6d                	jmp    80100575 <cprintf+0x175>
    case 's':
      if((s = (char*)*argp++) == 0)
80100508:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010050b:	8d 50 04             	lea    0x4(%eax),%edx
8010050e:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100511:	8b 00                	mov    (%eax),%eax
80100513:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100516:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010051a:	75 22                	jne    8010053e <cprintf+0x13e>
        s = "(null)";
8010051c:	c7 45 ec fe 86 10 80 	movl   $0x801086fe,-0x14(%ebp)
      for(; *s; s++)
80100523:	eb 19                	jmp    8010053e <cprintf+0x13e>
        consputc(*s);
80100525:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100528:	0f b6 00             	movzbl (%eax),%eax
8010052b:	0f be c0             	movsbl %al,%eax
8010052e:	83 ec 0c             	sub    $0xc,%esp
80100531:	50                   	push   %eax
80100532:	e8 b1 02 00 00       	call   801007e8 <consputc>
80100537:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010053a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010053e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100541:	0f b6 00             	movzbl (%eax),%eax
80100544:	84 c0                	test   %al,%al
80100546:	75 dd                	jne    80100525 <cprintf+0x125>
      break;
80100548:	eb 2b                	jmp    80100575 <cprintf+0x175>
    case '%':
      consputc('%');
8010054a:	83 ec 0c             	sub    $0xc,%esp
8010054d:	6a 25                	push   $0x25
8010054f:	e8 94 02 00 00       	call   801007e8 <consputc>
80100554:	83 c4 10             	add    $0x10,%esp
      break;
80100557:	eb 1c                	jmp    80100575 <cprintf+0x175>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100559:	83 ec 0c             	sub    $0xc,%esp
8010055c:	6a 25                	push   $0x25
8010055e:	e8 85 02 00 00       	call   801007e8 <consputc>
80100563:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100566:	83 ec 0c             	sub    $0xc,%esp
80100569:	ff 75 e4             	push   -0x1c(%ebp)
8010056c:	e8 77 02 00 00       	call   801007e8 <consputc>
80100571:	83 c4 10             	add    $0x10,%esp
      break;
80100574:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100575:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100579:	8b 55 08             	mov    0x8(%ebp),%edx
8010057c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010057f:	01 d0                	add    %edx,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f be c0             	movsbl %al,%eax
80100587:	25 ff 00 00 00       	and    $0xff,%eax
8010058c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010058f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100593:	0f 85 b1 fe ff ff    	jne    8010044a <cprintf+0x4a>
80100599:	eb 01                	jmp    8010059c <cprintf+0x19c>
      break;
8010059b:	90                   	nop
    }
  }

  if(locking)
8010059c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801005a0:	74 10                	je     801005b2 <cprintf+0x1b2>
    release(&cons.lock);
801005a2:	83 ec 0c             	sub    $0xc,%esp
801005a5:	68 80 ff 10 80       	push   $0x8010ff80
801005aa:	e8 54 4d 00 00       	call   80105303 <release>
801005af:	83 c4 10             	add    $0x10,%esp
}
801005b2:	90                   	nop
801005b3:	c9                   	leave  
801005b4:	c3                   	ret    

801005b5 <panic>:

void
panic(char *s)
{
801005b5:	55                   	push   %ebp
801005b6:	89 e5                	mov    %esp,%ebp
801005b8:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005bb:	e8 8d fd ff ff       	call   8010034d <cli>
  cons.locking = 0;
801005c0:	c7 05 b4 ff 10 80 00 	movl   $0x0,0x8010ffb4
801005c7:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005ca:	e8 21 2a 00 00       	call   80102ff0 <lapicid>
801005cf:	83 ec 08             	sub    $0x8,%esp
801005d2:	50                   	push   %eax
801005d3:	68 05 87 10 80       	push   $0x80108705
801005d8:	e8 23 fe ff ff       	call   80100400 <cprintf>
801005dd:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005e0:	8b 45 08             	mov    0x8(%ebp),%eax
801005e3:	83 ec 0c             	sub    $0xc,%esp
801005e6:	50                   	push   %eax
801005e7:	e8 14 fe ff ff       	call   80100400 <cprintf>
801005ec:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005ef:	83 ec 0c             	sub    $0xc,%esp
801005f2:	68 19 87 10 80       	push   $0x80108719
801005f7:	e8 04 fe ff ff       	call   80100400 <cprintf>
801005fc:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005ff:	83 ec 08             	sub    $0x8,%esp
80100602:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100605:	50                   	push   %eax
80100606:	8d 45 08             	lea    0x8(%ebp),%eax
80100609:	50                   	push   %eax
8010060a:	e8 46 4d 00 00       	call   80105355 <getcallerpcs>
8010060f:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100612:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100619:	eb 1c                	jmp    80100637 <panic+0x82>
    cprintf(" %p", pcs[i]);
8010061b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010061e:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100622:	83 ec 08             	sub    $0x8,%esp
80100625:	50                   	push   %eax
80100626:	68 1b 87 10 80       	push   $0x8010871b
8010062b:	e8 d0 fd ff ff       	call   80100400 <cprintf>
80100630:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100633:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100637:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010063b:	7e de                	jle    8010061b <panic+0x66>
  panicked = 1; // freeze other CPU
8010063d:	c7 05 6c ff 10 80 01 	movl   $0x1,0x8010ff6c
80100644:	00 00 00 
  for(;;)
80100647:	eb fe                	jmp    80100647 <panic+0x92>

80100649 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100649:	55                   	push   %ebp
8010064a:	89 e5                	mov    %esp,%ebp
8010064c:	53                   	push   %ebx
8010064d:	83 ec 14             	sub    $0x14,%esp
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
80100650:	6a 0e                	push   $0xe
80100652:	68 d4 03 00 00       	push   $0x3d4
80100657:	e8 d0 fc ff ff       	call   8010032c <outb>
8010065c:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
8010065f:	68 d5 03 00 00       	push   $0x3d5
80100664:	e8 a6 fc ff ff       	call   8010030f <inb>
80100669:	83 c4 04             	add    $0x4,%esp
8010066c:	0f b6 c0             	movzbl %al,%eax
8010066f:	c1 e0 08             	shl    $0x8,%eax
80100672:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
80100675:	6a 0f                	push   $0xf
80100677:	68 d4 03 00 00       	push   $0x3d4
8010067c:	e8 ab fc ff ff       	call   8010032c <outb>
80100681:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
80100684:	68 d5 03 00 00       	push   $0x3d5
80100689:	e8 81 fc ff ff       	call   8010030f <inb>
8010068e:	83 c4 04             	add    $0x4,%esp
80100691:	0f b6 c0             	movzbl %al,%eax
80100694:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100697:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
8010069b:	75 34                	jne    801006d1 <cgaputc+0x88>
    pos += 80 - pos%80;
8010069d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006a0:	ba 67 66 66 66       	mov    $0x66666667,%edx
801006a5:	89 c8                	mov    %ecx,%eax
801006a7:	f7 ea                	imul   %edx
801006a9:	89 d0                	mov    %edx,%eax
801006ab:	c1 f8 05             	sar    $0x5,%eax
801006ae:	89 cb                	mov    %ecx,%ebx
801006b0:	c1 fb 1f             	sar    $0x1f,%ebx
801006b3:	29 d8                	sub    %ebx,%eax
801006b5:	89 c2                	mov    %eax,%edx
801006b7:	89 d0                	mov    %edx,%eax
801006b9:	c1 e0 02             	shl    $0x2,%eax
801006bc:	01 d0                	add    %edx,%eax
801006be:	c1 e0 04             	shl    $0x4,%eax
801006c1:	29 c1                	sub    %eax,%ecx
801006c3:	89 ca                	mov    %ecx,%edx
801006c5:	b8 50 00 00 00       	mov    $0x50,%eax
801006ca:	29 d0                	sub    %edx,%eax
801006cc:	01 45 f4             	add    %eax,-0xc(%ebp)
801006cf:	eb 38                	jmp    80100709 <cgaputc+0xc0>
  else if(c == BACKSPACE){
801006d1:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006d8:	75 0c                	jne    801006e6 <cgaputc+0x9d>
    if(pos > 0) --pos;
801006da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006de:	7e 29                	jle    80100709 <cgaputc+0xc0>
801006e0:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801006e4:	eb 23                	jmp    80100709 <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
801006e6:	8b 45 08             	mov    0x8(%ebp),%eax
801006e9:	0f b6 c0             	movzbl %al,%eax
801006ec:	80 cc 07             	or     $0x7,%ah
801006ef:	89 c1                	mov    %eax,%ecx
801006f1:	8b 1d 00 90 10 80    	mov    0x80109000,%ebx
801006f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006fa:	8d 50 01             	lea    0x1(%eax),%edx
801006fd:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100700:	01 c0                	add    %eax,%eax
80100702:	01 d8                	add    %ebx,%eax
80100704:	89 ca                	mov    %ecx,%edx
80100706:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
80100709:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010070d:	78 09                	js     80100718 <cgaputc+0xcf>
8010070f:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
80100716:	7e 0d                	jle    80100725 <cgaputc+0xdc>
    panic("pos under/overflow");
80100718:	83 ec 0c             	sub    $0xc,%esp
8010071b:	68 1f 87 10 80       	push   $0x8010871f
80100720:	e8 90 fe ff ff       	call   801005b5 <panic>

  if((pos/80) >= 24){  // Scroll up.
80100725:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
8010072c:	7e 4d                	jle    8010077b <cgaputc+0x132>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
8010072e:	a1 00 90 10 80       	mov    0x80109000,%eax
80100733:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
80100739:	a1 00 90 10 80       	mov    0x80109000,%eax
8010073e:	83 ec 04             	sub    $0x4,%esp
80100741:	68 60 0e 00 00       	push   $0xe60
80100746:	52                   	push   %edx
80100747:	50                   	push   %eax
80100748:	e8 8d 4e 00 00       	call   801055da <memmove>
8010074d:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
80100750:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100754:	b8 80 07 00 00       	mov    $0x780,%eax
80100759:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010075c:	8d 14 00             	lea    (%eax,%eax,1),%edx
8010075f:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
80100765:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100768:	01 c0                	add    %eax,%eax
8010076a:	01 c8                	add    %ecx,%eax
8010076c:	83 ec 04             	sub    $0x4,%esp
8010076f:	52                   	push   %edx
80100770:	6a 00                	push   $0x0
80100772:	50                   	push   %eax
80100773:	e8 a3 4d 00 00       	call   8010551b <memset>
80100778:	83 c4 10             	add    $0x10,%esp
  }

  outb(CRTPORT, 14);
8010077b:	83 ec 08             	sub    $0x8,%esp
8010077e:	6a 0e                	push   $0xe
80100780:	68 d4 03 00 00       	push   $0x3d4
80100785:	e8 a2 fb ff ff       	call   8010032c <outb>
8010078a:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
8010078d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100790:	c1 f8 08             	sar    $0x8,%eax
80100793:	0f b6 c0             	movzbl %al,%eax
80100796:	83 ec 08             	sub    $0x8,%esp
80100799:	50                   	push   %eax
8010079a:	68 d5 03 00 00       	push   $0x3d5
8010079f:	e8 88 fb ff ff       	call   8010032c <outb>
801007a4:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
801007a7:	83 ec 08             	sub    $0x8,%esp
801007aa:	6a 0f                	push   $0xf
801007ac:	68 d4 03 00 00       	push   $0x3d4
801007b1:	e8 76 fb ff ff       	call   8010032c <outb>
801007b6:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
801007b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007bc:	0f b6 c0             	movzbl %al,%eax
801007bf:	83 ec 08             	sub    $0x8,%esp
801007c2:	50                   	push   %eax
801007c3:	68 d5 03 00 00       	push   $0x3d5
801007c8:	e8 5f fb ff ff       	call   8010032c <outb>
801007cd:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
801007d0:	8b 15 00 90 10 80    	mov    0x80109000,%edx
801007d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007d9:	01 c0                	add    %eax,%eax
801007db:	01 d0                	add    %edx,%eax
801007dd:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
801007e2:	90                   	nop
801007e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801007e6:	c9                   	leave  
801007e7:	c3                   	ret    

801007e8 <consputc>:

void
consputc(int c)
{
801007e8:	55                   	push   %ebp
801007e9:	89 e5                	mov    %esp,%ebp
801007eb:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
801007ee:	a1 6c ff 10 80       	mov    0x8010ff6c,%eax
801007f3:	85 c0                	test   %eax,%eax
801007f5:	74 07                	je     801007fe <consputc+0x16>
    cli();
801007f7:	e8 51 fb ff ff       	call   8010034d <cli>
    for(;;)
801007fc:	eb fe                	jmp    801007fc <consputc+0x14>
      ;
  }

  if(c == BACKSPACE){
801007fe:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100805:	75 29                	jne    80100830 <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100807:	83 ec 0c             	sub    $0xc,%esp
8010080a:	6a 08                	push   $0x8
8010080c:	e8 68 66 00 00       	call   80106e79 <uartputc>
80100811:	83 c4 10             	add    $0x10,%esp
80100814:	83 ec 0c             	sub    $0xc,%esp
80100817:	6a 20                	push   $0x20
80100819:	e8 5b 66 00 00       	call   80106e79 <uartputc>
8010081e:	83 c4 10             	add    $0x10,%esp
80100821:	83 ec 0c             	sub    $0xc,%esp
80100824:	6a 08                	push   $0x8
80100826:	e8 4e 66 00 00       	call   80106e79 <uartputc>
8010082b:	83 c4 10             	add    $0x10,%esp
8010082e:	eb 0e                	jmp    8010083e <consputc+0x56>
  } else
    uartputc(c);
80100830:	83 ec 0c             	sub    $0xc,%esp
80100833:	ff 75 08             	push   0x8(%ebp)
80100836:	e8 3e 66 00 00       	call   80106e79 <uartputc>
8010083b:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
8010083e:	83 ec 0c             	sub    $0xc,%esp
80100841:	ff 75 08             	push   0x8(%ebp)
80100844:	e8 00 fe ff ff       	call   80100649 <cgaputc>
80100849:	83 c4 10             	add    $0x10,%esp
}
8010084c:	90                   	nop
8010084d:	c9                   	leave  
8010084e:	c3                   	ret    

8010084f <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
8010084f:	55                   	push   %ebp
80100850:	89 e5                	mov    %esp,%ebp
80100852:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
80100855:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
8010085c:	83 ec 0c             	sub    $0xc,%esp
8010085f:	68 80 ff 10 80       	push   $0x8010ff80
80100864:	e8 2c 4a 00 00       	call   80105295 <acquire>
80100869:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
8010086c:	e9 50 01 00 00       	jmp    801009c1 <consoleintr+0x172>
    switch(c){
80100871:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100875:	0f 84 81 00 00 00    	je     801008fc <consoleintr+0xad>
8010087b:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
8010087f:	0f 8f ac 00 00 00    	jg     80100931 <consoleintr+0xe2>
80100885:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100889:	74 43                	je     801008ce <consoleintr+0x7f>
8010088b:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
8010088f:	0f 8f 9c 00 00 00    	jg     80100931 <consoleintr+0xe2>
80100895:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
80100899:	74 61                	je     801008fc <consoleintr+0xad>
8010089b:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
8010089f:	0f 85 8c 00 00 00    	jne    80100931 <consoleintr+0xe2>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
801008a5:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
801008ac:	e9 10 01 00 00       	jmp    801009c1 <consoleintr+0x172>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801008b1:	a1 68 ff 10 80       	mov    0x8010ff68,%eax
801008b6:	83 e8 01             	sub    $0x1,%eax
801008b9:	a3 68 ff 10 80       	mov    %eax,0x8010ff68
        consputc(BACKSPACE);
801008be:	83 ec 0c             	sub    $0xc,%esp
801008c1:	68 00 01 00 00       	push   $0x100
801008c6:	e8 1d ff ff ff       	call   801007e8 <consputc>
801008cb:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
801008ce:	8b 15 68 ff 10 80    	mov    0x8010ff68,%edx
801008d4:	a1 64 ff 10 80       	mov    0x8010ff64,%eax
801008d9:	39 c2                	cmp    %eax,%edx
801008db:	0f 84 e0 00 00 00    	je     801009c1 <consoleintr+0x172>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801008e1:	a1 68 ff 10 80       	mov    0x8010ff68,%eax
801008e6:	83 e8 01             	sub    $0x1,%eax
801008e9:	83 e0 7f             	and    $0x7f,%eax
801008ec:	0f b6 80 e0 fe 10 80 	movzbl -0x7fef0120(%eax),%eax
      while(input.e != input.w &&
801008f3:	3c 0a                	cmp    $0xa,%al
801008f5:	75 ba                	jne    801008b1 <consoleintr+0x62>
      }
      break;
801008f7:	e9 c5 00 00 00       	jmp    801009c1 <consoleintr+0x172>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008fc:	8b 15 68 ff 10 80    	mov    0x8010ff68,%edx
80100902:	a1 64 ff 10 80       	mov    0x8010ff64,%eax
80100907:	39 c2                	cmp    %eax,%edx
80100909:	0f 84 b2 00 00 00    	je     801009c1 <consoleintr+0x172>
        input.e--;
8010090f:	a1 68 ff 10 80       	mov    0x8010ff68,%eax
80100914:	83 e8 01             	sub    $0x1,%eax
80100917:	a3 68 ff 10 80       	mov    %eax,0x8010ff68
        consputc(BACKSPACE);
8010091c:	83 ec 0c             	sub    $0xc,%esp
8010091f:	68 00 01 00 00       	push   $0x100
80100924:	e8 bf fe ff ff       	call   801007e8 <consputc>
80100929:	83 c4 10             	add    $0x10,%esp
      }
      break;
8010092c:	e9 90 00 00 00       	jmp    801009c1 <consoleintr+0x172>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100931:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100935:	0f 84 85 00 00 00    	je     801009c0 <consoleintr+0x171>
8010093b:	a1 68 ff 10 80       	mov    0x8010ff68,%eax
80100940:	8b 15 60 ff 10 80    	mov    0x8010ff60,%edx
80100946:	29 d0                	sub    %edx,%eax
80100948:	83 f8 7f             	cmp    $0x7f,%eax
8010094b:	77 73                	ja     801009c0 <consoleintr+0x171>
        c = (c == '\r') ? '\n' : c;
8010094d:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80100951:	74 05                	je     80100958 <consoleintr+0x109>
80100953:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100956:	eb 05                	jmp    8010095d <consoleintr+0x10e>
80100958:	b8 0a 00 00 00       	mov    $0xa,%eax
8010095d:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
80100960:	a1 68 ff 10 80       	mov    0x8010ff68,%eax
80100965:	8d 50 01             	lea    0x1(%eax),%edx
80100968:	89 15 68 ff 10 80    	mov    %edx,0x8010ff68
8010096e:	83 e0 7f             	and    $0x7f,%eax
80100971:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100974:	88 90 e0 fe 10 80    	mov    %dl,-0x7fef0120(%eax)
        consputc(c);
8010097a:	83 ec 0c             	sub    $0xc,%esp
8010097d:	ff 75 f0             	push   -0x10(%ebp)
80100980:	e8 63 fe ff ff       	call   801007e8 <consputc>
80100985:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100988:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
8010098c:	74 18                	je     801009a6 <consoleintr+0x157>
8010098e:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100992:	74 12                	je     801009a6 <consoleintr+0x157>
80100994:	a1 68 ff 10 80       	mov    0x8010ff68,%eax
80100999:	8b 15 60 ff 10 80    	mov    0x8010ff60,%edx
8010099f:	83 ea 80             	sub    $0xffffff80,%edx
801009a2:	39 d0                	cmp    %edx,%eax
801009a4:	75 1a                	jne    801009c0 <consoleintr+0x171>
          input.w = input.e;
801009a6:	a1 68 ff 10 80       	mov    0x8010ff68,%eax
801009ab:	a3 64 ff 10 80       	mov    %eax,0x8010ff64
          wakeup(&input.r);
801009b0:	83 ec 0c             	sub    $0xc,%esp
801009b3:	68 60 ff 10 80       	push   $0x8010ff60
801009b8:	e8 1c 44 00 00       	call   80104dd9 <wakeup>
801009bd:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
801009c0:	90                   	nop
  while((c = getc()) >= 0){
801009c1:	8b 45 08             	mov    0x8(%ebp),%eax
801009c4:	ff d0                	call   *%eax
801009c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801009c9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801009cd:	0f 89 9e fe ff ff    	jns    80100871 <consoleintr+0x22>
    }
  }
  release(&cons.lock);
801009d3:	83 ec 0c             	sub    $0xc,%esp
801009d6:	68 80 ff 10 80       	push   $0x8010ff80
801009db:	e8 23 49 00 00       	call   80105303 <release>
801009e0:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009e7:	74 05                	je     801009ee <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
801009e9:	e8 a9 44 00 00       	call   80104e97 <procdump>
  }
}
801009ee:	90                   	nop
801009ef:	c9                   	leave  
801009f0:	c3                   	ret    

801009f1 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
801009f1:	55                   	push   %ebp
801009f2:	89 e5                	mov    %esp,%ebp
801009f4:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
801009f7:	83 ec 0c             	sub    $0xc,%esp
801009fa:	ff 75 08             	push   0x8(%ebp)
801009fd:	e8 2b 11 00 00       	call   80101b2d <iunlock>
80100a02:	83 c4 10             	add    $0x10,%esp
  target = n;
80100a05:	8b 45 10             	mov    0x10(%ebp),%eax
80100a08:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a0b:	83 ec 0c             	sub    $0xc,%esp
80100a0e:	68 80 ff 10 80       	push   $0x8010ff80
80100a13:	e8 7d 48 00 00       	call   80105295 <acquire>
80100a18:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100a1b:	e9 ab 00 00 00       	jmp    80100acb <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
80100a20:	e8 b5 38 00 00       	call   801042da <myproc>
80100a25:	8b 40 24             	mov    0x24(%eax),%eax
80100a28:	85 c0                	test   %eax,%eax
80100a2a:	74 28                	je     80100a54 <consoleread+0x63>
        release(&cons.lock);
80100a2c:	83 ec 0c             	sub    $0xc,%esp
80100a2f:	68 80 ff 10 80       	push   $0x8010ff80
80100a34:	e8 ca 48 00 00       	call   80105303 <release>
80100a39:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a3c:	83 ec 0c             	sub    $0xc,%esp
80100a3f:	ff 75 08             	push   0x8(%ebp)
80100a42:	e8 d3 0f 00 00       	call   80101a1a <ilock>
80100a47:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a4f:	e9 a9 00 00 00       	jmp    80100afd <consoleread+0x10c>
      }
      sleep(&input.r, &cons.lock);
80100a54:	83 ec 08             	sub    $0x8,%esp
80100a57:	68 80 ff 10 80       	push   $0x8010ff80
80100a5c:	68 60 ff 10 80       	push   $0x8010ff60
80100a61:	e8 75 42 00 00       	call   80104cdb <sleep>
80100a66:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100a69:	8b 15 60 ff 10 80    	mov    0x8010ff60,%edx
80100a6f:	a1 64 ff 10 80       	mov    0x8010ff64,%eax
80100a74:	39 c2                	cmp    %eax,%edx
80100a76:	74 a8                	je     80100a20 <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a78:	a1 60 ff 10 80       	mov    0x8010ff60,%eax
80100a7d:	8d 50 01             	lea    0x1(%eax),%edx
80100a80:	89 15 60 ff 10 80    	mov    %edx,0x8010ff60
80100a86:	83 e0 7f             	and    $0x7f,%eax
80100a89:	0f b6 80 e0 fe 10 80 	movzbl -0x7fef0120(%eax),%eax
80100a90:	0f be c0             	movsbl %al,%eax
80100a93:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a96:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a9a:	75 17                	jne    80100ab3 <consoleread+0xc2>
      if(n < target){
80100a9c:	8b 45 10             	mov    0x10(%ebp),%eax
80100a9f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100aa2:	76 2f                	jbe    80100ad3 <consoleread+0xe2>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100aa4:	a1 60 ff 10 80       	mov    0x8010ff60,%eax
80100aa9:	83 e8 01             	sub    $0x1,%eax
80100aac:	a3 60 ff 10 80       	mov    %eax,0x8010ff60
      }
      break;
80100ab1:	eb 20                	jmp    80100ad3 <consoleread+0xe2>
    }
    *dst++ = c;
80100ab3:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ab6:	8d 50 01             	lea    0x1(%eax),%edx
80100ab9:	89 55 0c             	mov    %edx,0xc(%ebp)
80100abc:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100abf:	88 10                	mov    %dl,(%eax)
    --n;
80100ac1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100ac5:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100ac9:	74 0b                	je     80100ad6 <consoleread+0xe5>
  while(n > 0){
80100acb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100acf:	7f 98                	jg     80100a69 <consoleread+0x78>
80100ad1:	eb 04                	jmp    80100ad7 <consoleread+0xe6>
      break;
80100ad3:	90                   	nop
80100ad4:	eb 01                	jmp    80100ad7 <consoleread+0xe6>
      break;
80100ad6:	90                   	nop
  }
  release(&cons.lock);
80100ad7:	83 ec 0c             	sub    $0xc,%esp
80100ada:	68 80 ff 10 80       	push   $0x8010ff80
80100adf:	e8 1f 48 00 00       	call   80105303 <release>
80100ae4:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ae7:	83 ec 0c             	sub    $0xc,%esp
80100aea:	ff 75 08             	push   0x8(%ebp)
80100aed:	e8 28 0f 00 00       	call   80101a1a <ilock>
80100af2:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100af5:	8b 55 10             	mov    0x10(%ebp),%edx
80100af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100afb:	29 d0                	sub    %edx,%eax
}
80100afd:	c9                   	leave  
80100afe:	c3                   	ret    

80100aff <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100aff:	55                   	push   %ebp
80100b00:	89 e5                	mov    %esp,%ebp
80100b02:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100b05:	83 ec 0c             	sub    $0xc,%esp
80100b08:	ff 75 08             	push   0x8(%ebp)
80100b0b:	e8 1d 10 00 00       	call   80101b2d <iunlock>
80100b10:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100b13:	83 ec 0c             	sub    $0xc,%esp
80100b16:	68 80 ff 10 80       	push   $0x8010ff80
80100b1b:	e8 75 47 00 00       	call   80105295 <acquire>
80100b20:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b23:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100b2a:	eb 21                	jmp    80100b4d <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100b2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b32:	01 d0                	add    %edx,%eax
80100b34:	0f b6 00             	movzbl (%eax),%eax
80100b37:	0f be c0             	movsbl %al,%eax
80100b3a:	0f b6 c0             	movzbl %al,%eax
80100b3d:	83 ec 0c             	sub    $0xc,%esp
80100b40:	50                   	push   %eax
80100b41:	e8 a2 fc ff ff       	call   801007e8 <consputc>
80100b46:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b49:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b50:	3b 45 10             	cmp    0x10(%ebp),%eax
80100b53:	7c d7                	jl     80100b2c <consolewrite+0x2d>
  release(&cons.lock);
80100b55:	83 ec 0c             	sub    $0xc,%esp
80100b58:	68 80 ff 10 80       	push   $0x8010ff80
80100b5d:	e8 a1 47 00 00       	call   80105303 <release>
80100b62:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b65:	83 ec 0c             	sub    $0xc,%esp
80100b68:	ff 75 08             	push   0x8(%ebp)
80100b6b:	e8 aa 0e 00 00       	call   80101a1a <ilock>
80100b70:	83 c4 10             	add    $0x10,%esp

  return n;
80100b73:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b76:	c9                   	leave  
80100b77:	c3                   	ret    

80100b78 <consoleinit>:

void
consoleinit(void)
{
80100b78:	55                   	push   %ebp
80100b79:	89 e5                	mov    %esp,%ebp
80100b7b:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100b7e:	83 ec 08             	sub    $0x8,%esp
80100b81:	68 32 87 10 80       	push   $0x80108732
80100b86:	68 80 ff 10 80       	push   $0x8010ff80
80100b8b:	e8 e3 46 00 00       	call   80105273 <initlock>
80100b90:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b93:	c7 05 cc ff 10 80 ff 	movl   $0x80100aff,0x8010ffcc
80100b9a:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b9d:	c7 05 c8 ff 10 80 f1 	movl   $0x801009f1,0x8010ffc8
80100ba4:	09 10 80 
  cons.locking = 1;
80100ba7:	c7 05 b4 ff 10 80 01 	movl   $0x1,0x8010ffb4
80100bae:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100bb1:	83 ec 08             	sub    $0x8,%esp
80100bb4:	6a 00                	push   $0x0
80100bb6:	6a 01                	push   $0x1
80100bb8:	e8 67 1f 00 00       	call   80102b24 <ioapicenable>
80100bbd:	83 c4 10             	add    $0x10,%esp
}
80100bc0:	90                   	nop
80100bc1:	c9                   	leave  
80100bc2:	c3                   	ret    

80100bc3 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100bc3:	55                   	push   %ebp
80100bc4:	89 e5                	mov    %esp,%ebp
80100bc6:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100bcc:	e8 09 37 00 00       	call   801042da <myproc>
80100bd1:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100bd4:	e8 59 29 00 00       	call   80103532 <begin_op>

  if((ip = namei(path)) == 0){
80100bd9:	83 ec 0c             	sub    $0xc,%esp
80100bdc:	ff 75 08             	push   0x8(%ebp)
80100bdf:	e8 69 19 00 00       	call   8010254d <namei>
80100be4:	83 c4 10             	add    $0x10,%esp
80100be7:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100bea:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bee:	75 1f                	jne    80100c0f <exec+0x4c>
    end_op();
80100bf0:	e8 c9 29 00 00       	call   801035be <end_op>
    cprintf("exec: fail\n");
80100bf5:	83 ec 0c             	sub    $0xc,%esp
80100bf8:	68 3a 87 10 80       	push   $0x8010873a
80100bfd:	e8 fe f7 ff ff       	call   80100400 <cprintf>
80100c02:	83 c4 10             	add    $0x10,%esp
    return -1;
80100c05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c0a:	e9 f1 03 00 00       	jmp    80101000 <exec+0x43d>
  }
  ilock(ip);
80100c0f:	83 ec 0c             	sub    $0xc,%esp
80100c12:	ff 75 d8             	push   -0x28(%ebp)
80100c15:	e8 00 0e 00 00       	call   80101a1a <ilock>
80100c1a:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100c1d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100c24:	6a 34                	push   $0x34
80100c26:	6a 00                	push   $0x0
80100c28:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100c2e:	50                   	push   %eax
80100c2f:	ff 75 d8             	push   -0x28(%ebp)
80100c32:	e8 cf 12 00 00       	call   80101f06 <readi>
80100c37:	83 c4 10             	add    $0x10,%esp
80100c3a:	83 f8 34             	cmp    $0x34,%eax
80100c3d:	0f 85 66 03 00 00    	jne    80100fa9 <exec+0x3e6>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c43:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c49:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c4e:	0f 85 58 03 00 00    	jne    80100fac <exec+0x3e9>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c54:	e8 1c 72 00 00       	call   80107e75 <setupkvm>
80100c59:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c5c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c60:	0f 84 49 03 00 00    	je     80100faf <exec+0x3ec>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c66:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c6d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c74:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c7a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c7d:	e9 de 00 00 00       	jmp    80100d60 <exec+0x19d>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c82:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c85:	6a 20                	push   $0x20
80100c87:	50                   	push   %eax
80100c88:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c8e:	50                   	push   %eax
80100c8f:	ff 75 d8             	push   -0x28(%ebp)
80100c92:	e8 6f 12 00 00       	call   80101f06 <readi>
80100c97:	83 c4 10             	add    $0x10,%esp
80100c9a:	83 f8 20             	cmp    $0x20,%eax
80100c9d:	0f 85 0f 03 00 00    	jne    80100fb2 <exec+0x3ef>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100ca3:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100ca9:	83 f8 01             	cmp    $0x1,%eax
80100cac:	0f 85 a0 00 00 00    	jne    80100d52 <exec+0x18f>
      continue;
    if(ph.memsz < ph.filesz)
80100cb2:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100cb8:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100cbe:	39 c2                	cmp    %eax,%edx
80100cc0:	0f 82 ef 02 00 00    	jb     80100fb5 <exec+0x3f2>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100cc6:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ccc:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cd2:	01 c2                	add    %eax,%edx
80100cd4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cda:	39 c2                	cmp    %eax,%edx
80100cdc:	0f 82 d6 02 00 00    	jb     80100fb8 <exec+0x3f5>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100ce2:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ce8:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cee:	01 d0                	add    %edx,%eax
80100cf0:	83 ec 04             	sub    $0x4,%esp
80100cf3:	50                   	push   %eax
80100cf4:	ff 75 e0             	push   -0x20(%ebp)
80100cf7:	ff 75 d4             	push   -0x2c(%ebp)
80100cfa:	e8 1c 75 00 00       	call   8010821b <allocuvm>
80100cff:	83 c4 10             	add    $0x10,%esp
80100d02:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d05:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d09:	0f 84 ac 02 00 00    	je     80100fbb <exec+0x3f8>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100d0f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d15:	25 ff 0f 00 00       	and    $0xfff,%eax
80100d1a:	85 c0                	test   %eax,%eax
80100d1c:	0f 85 9c 02 00 00    	jne    80100fbe <exec+0x3fb>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100d22:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100d28:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d2e:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100d34:	83 ec 0c             	sub    $0xc,%esp
80100d37:	52                   	push   %edx
80100d38:	50                   	push   %eax
80100d39:	ff 75 d8             	push   -0x28(%ebp)
80100d3c:	51                   	push   %ecx
80100d3d:	ff 75 d4             	push   -0x2c(%ebp)
80100d40:	e8 09 74 00 00       	call   8010814e <loaduvm>
80100d45:	83 c4 20             	add    $0x20,%esp
80100d48:	85 c0                	test   %eax,%eax
80100d4a:	0f 88 71 02 00 00    	js     80100fc1 <exec+0x3fe>
80100d50:	eb 01                	jmp    80100d53 <exec+0x190>
      continue;
80100d52:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d53:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d57:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d5a:	83 c0 20             	add    $0x20,%eax
80100d5d:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d60:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100d67:	0f b7 c0             	movzwl %ax,%eax
80100d6a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d6d:	0f 8c 0f ff ff ff    	jl     80100c82 <exec+0xbf>
      goto bad;
  }
  iunlockput(ip);
80100d73:	83 ec 0c             	sub    $0xc,%esp
80100d76:	ff 75 d8             	push   -0x28(%ebp)
80100d79:	e8 cd 0e 00 00       	call   80101c4b <iunlockput>
80100d7e:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d81:	e8 38 28 00 00       	call   801035be <end_op>
  ip = 0;
80100d86:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d90:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d95:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d9a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100da0:	05 00 20 00 00       	add    $0x2000,%eax
80100da5:	83 ec 04             	sub    $0x4,%esp
80100da8:	50                   	push   %eax
80100da9:	ff 75 e0             	push   -0x20(%ebp)
80100dac:	ff 75 d4             	push   -0x2c(%ebp)
80100daf:	e8 67 74 00 00       	call   8010821b <allocuvm>
80100db4:	83 c4 10             	add    $0x10,%esp
80100db7:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100dba:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100dbe:	0f 84 00 02 00 00    	je     80100fc4 <exec+0x401>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100dc4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100dc7:	2d 00 20 00 00       	sub    $0x2000,%eax
80100dcc:	83 ec 08             	sub    $0x8,%esp
80100dcf:	50                   	push   %eax
80100dd0:	ff 75 d4             	push   -0x2c(%ebp)
80100dd3:	e8 a5 76 00 00       	call   8010847d <clearpteu>
80100dd8:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100ddb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100dde:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100de1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100de8:	e9 96 00 00 00       	jmp    80100e83 <exec+0x2c0>
    if(argc >= MAXARG)
80100ded:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100df1:	0f 87 d0 01 00 00    	ja     80100fc7 <exec+0x404>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100df7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dfa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e01:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e04:	01 d0                	add    %edx,%eax
80100e06:	8b 00                	mov    (%eax),%eax
80100e08:	83 ec 0c             	sub    $0xc,%esp
80100e0b:	50                   	push   %eax
80100e0c:	e8 58 49 00 00       	call   80105769 <strlen>
80100e11:	83 c4 10             	add    $0x10,%esp
80100e14:	89 c2                	mov    %eax,%edx
80100e16:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e19:	29 d0                	sub    %edx,%eax
80100e1b:	83 e8 01             	sub    $0x1,%eax
80100e1e:	83 e0 fc             	and    $0xfffffffc,%eax
80100e21:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e27:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e2e:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e31:	01 d0                	add    %edx,%eax
80100e33:	8b 00                	mov    (%eax),%eax
80100e35:	83 ec 0c             	sub    $0xc,%esp
80100e38:	50                   	push   %eax
80100e39:	e8 2b 49 00 00       	call   80105769 <strlen>
80100e3e:	83 c4 10             	add    $0x10,%esp
80100e41:	83 c0 01             	add    $0x1,%eax
80100e44:	89 c2                	mov    %eax,%edx
80100e46:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e49:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100e50:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e53:	01 c8                	add    %ecx,%eax
80100e55:	8b 00                	mov    (%eax),%eax
80100e57:	52                   	push   %edx
80100e58:	50                   	push   %eax
80100e59:	ff 75 dc             	push   -0x24(%ebp)
80100e5c:	ff 75 d4             	push   -0x2c(%ebp)
80100e5f:	e8 c5 77 00 00       	call   80108629 <copyout>
80100e64:	83 c4 10             	add    $0x10,%esp
80100e67:	85 c0                	test   %eax,%eax
80100e69:	0f 88 5b 01 00 00    	js     80100fca <exec+0x407>
      goto bad;
    ustack[3+argc] = sp;
80100e6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e72:	8d 50 03             	lea    0x3(%eax),%edx
80100e75:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e78:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e7f:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e86:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e8d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e90:	01 d0                	add    %edx,%eax
80100e92:	8b 00                	mov    (%eax),%eax
80100e94:	85 c0                	test   %eax,%eax
80100e96:	0f 85 51 ff ff ff    	jne    80100ded <exec+0x22a>
  }
  ustack[3+argc] = 0;
80100e9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e9f:	83 c0 03             	add    $0x3,%eax
80100ea2:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100ea9:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100ead:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100eb4:	ff ff ff 
  ustack[1] = argc;
80100eb7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eba:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100ec0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ec3:	83 c0 01             	add    $0x1,%eax
80100ec6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ecd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ed0:	29 d0                	sub    %edx,%eax
80100ed2:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100ed8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100edb:	83 c0 04             	add    $0x4,%eax
80100ede:	c1 e0 02             	shl    $0x2,%eax
80100ee1:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100ee4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ee7:	83 c0 04             	add    $0x4,%eax
80100eea:	c1 e0 02             	shl    $0x2,%eax
80100eed:	50                   	push   %eax
80100eee:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100ef4:	50                   	push   %eax
80100ef5:	ff 75 dc             	push   -0x24(%ebp)
80100ef8:	ff 75 d4             	push   -0x2c(%ebp)
80100efb:	e8 29 77 00 00       	call   80108629 <copyout>
80100f00:	83 c4 10             	add    $0x10,%esp
80100f03:	85 c0                	test   %eax,%eax
80100f05:	0f 88 c2 00 00 00    	js     80100fcd <exec+0x40a>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f0b:	8b 45 08             	mov    0x8(%ebp),%eax
80100f0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f14:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f17:	eb 17                	jmp    80100f30 <exec+0x36d>
    if(*s == '/')
80100f19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f1c:	0f b6 00             	movzbl (%eax),%eax
80100f1f:	3c 2f                	cmp    $0x2f,%al
80100f21:	75 09                	jne    80100f2c <exec+0x369>
      last = s+1;
80100f23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f26:	83 c0 01             	add    $0x1,%eax
80100f29:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100f2c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100f30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f33:	0f b6 00             	movzbl (%eax),%eax
80100f36:	84 c0                	test   %al,%al
80100f38:	75 df                	jne    80100f19 <exec+0x356>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100f3a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f3d:	83 c0 6c             	add    $0x6c,%eax
80100f40:	83 ec 04             	sub    $0x4,%esp
80100f43:	6a 10                	push   $0x10
80100f45:	ff 75 f0             	push   -0x10(%ebp)
80100f48:	50                   	push   %eax
80100f49:	e8 d0 47 00 00       	call   8010571e <safestrcpy>
80100f4e:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f51:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f54:	8b 40 04             	mov    0x4(%eax),%eax
80100f57:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f5a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f5d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f60:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f63:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f66:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f69:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f6b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f6e:	8b 40 18             	mov    0x18(%eax),%eax
80100f71:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f77:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f7a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f7d:	8b 40 18             	mov    0x18(%eax),%eax
80100f80:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f83:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f86:	83 ec 0c             	sub    $0xc,%esp
80100f89:	ff 75 d0             	push   -0x30(%ebp)
80100f8c:	e8 ae 6f 00 00       	call   80107f3f <switchuvm>
80100f91:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f94:	83 ec 0c             	sub    $0xc,%esp
80100f97:	ff 75 cc             	push   -0x34(%ebp)
80100f9a:	e8 45 74 00 00       	call   801083e4 <freevm>
80100f9f:	83 c4 10             	add    $0x10,%esp
  return 0;
80100fa2:	b8 00 00 00 00       	mov    $0x0,%eax
80100fa7:	eb 57                	jmp    80101000 <exec+0x43d>
    goto bad;
80100fa9:	90                   	nop
80100faa:	eb 22                	jmp    80100fce <exec+0x40b>
    goto bad;
80100fac:	90                   	nop
80100fad:	eb 1f                	jmp    80100fce <exec+0x40b>
    goto bad;
80100faf:	90                   	nop
80100fb0:	eb 1c                	jmp    80100fce <exec+0x40b>
      goto bad;
80100fb2:	90                   	nop
80100fb3:	eb 19                	jmp    80100fce <exec+0x40b>
      goto bad;
80100fb5:	90                   	nop
80100fb6:	eb 16                	jmp    80100fce <exec+0x40b>
      goto bad;
80100fb8:	90                   	nop
80100fb9:	eb 13                	jmp    80100fce <exec+0x40b>
      goto bad;
80100fbb:	90                   	nop
80100fbc:	eb 10                	jmp    80100fce <exec+0x40b>
      goto bad;
80100fbe:	90                   	nop
80100fbf:	eb 0d                	jmp    80100fce <exec+0x40b>
      goto bad;
80100fc1:	90                   	nop
80100fc2:	eb 0a                	jmp    80100fce <exec+0x40b>
    goto bad;
80100fc4:	90                   	nop
80100fc5:	eb 07                	jmp    80100fce <exec+0x40b>
      goto bad;
80100fc7:	90                   	nop
80100fc8:	eb 04                	jmp    80100fce <exec+0x40b>
      goto bad;
80100fca:	90                   	nop
80100fcb:	eb 01                	jmp    80100fce <exec+0x40b>
    goto bad;
80100fcd:	90                   	nop

 bad:
  if(pgdir)
80100fce:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100fd2:	74 0e                	je     80100fe2 <exec+0x41f>
    freevm(pgdir);
80100fd4:	83 ec 0c             	sub    $0xc,%esp
80100fd7:	ff 75 d4             	push   -0x2c(%ebp)
80100fda:	e8 05 74 00 00       	call   801083e4 <freevm>
80100fdf:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100fe2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fe6:	74 13                	je     80100ffb <exec+0x438>
    iunlockput(ip);
80100fe8:	83 ec 0c             	sub    $0xc,%esp
80100feb:	ff 75 d8             	push   -0x28(%ebp)
80100fee:	e8 58 0c 00 00       	call   80101c4b <iunlockput>
80100ff3:	83 c4 10             	add    $0x10,%esp
    end_op();
80100ff6:	e8 c3 25 00 00       	call   801035be <end_op>
  }
  return -1;
80100ffb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101000:	c9                   	leave  
80101001:	c3                   	ret    

80101002 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101002:	55                   	push   %ebp
80101003:	89 e5                	mov    %esp,%ebp
80101005:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80101008:	83 ec 08             	sub    $0x8,%esp
8010100b:	68 46 87 10 80       	push   $0x80108746
80101010:	68 20 00 11 80       	push   $0x80110020
80101015:	e8 59 42 00 00       	call   80105273 <initlock>
8010101a:	83 c4 10             	add    $0x10,%esp
}
8010101d:	90                   	nop
8010101e:	c9                   	leave  
8010101f:	c3                   	ret    

80101020 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101020:	55                   	push   %ebp
80101021:	89 e5                	mov    %esp,%ebp
80101023:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80101026:	83 ec 0c             	sub    $0xc,%esp
80101029:	68 20 00 11 80       	push   $0x80110020
8010102e:	e8 62 42 00 00       	call   80105295 <acquire>
80101033:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101036:	c7 45 f4 54 00 11 80 	movl   $0x80110054,-0xc(%ebp)
8010103d:	eb 2d                	jmp    8010106c <filealloc+0x4c>
    if(f->ref == 0){
8010103f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101042:	8b 40 04             	mov    0x4(%eax),%eax
80101045:	85 c0                	test   %eax,%eax
80101047:	75 1f                	jne    80101068 <filealloc+0x48>
      f->ref = 1;
80101049:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010104c:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101053:	83 ec 0c             	sub    $0xc,%esp
80101056:	68 20 00 11 80       	push   $0x80110020
8010105b:	e8 a3 42 00 00       	call   80105303 <release>
80101060:	83 c4 10             	add    $0x10,%esp
      return f;
80101063:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101066:	eb 23                	jmp    8010108b <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101068:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
8010106c:	b8 b4 09 11 80       	mov    $0x801109b4,%eax
80101071:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101074:	72 c9                	jb     8010103f <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
80101076:	83 ec 0c             	sub    $0xc,%esp
80101079:	68 20 00 11 80       	push   $0x80110020
8010107e:	e8 80 42 00 00       	call   80105303 <release>
80101083:	83 c4 10             	add    $0x10,%esp
  return 0;
80101086:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010108b:	c9                   	leave  
8010108c:	c3                   	ret    

8010108d <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010108d:	55                   	push   %ebp
8010108e:	89 e5                	mov    %esp,%ebp
80101090:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101093:	83 ec 0c             	sub    $0xc,%esp
80101096:	68 20 00 11 80       	push   $0x80110020
8010109b:	e8 f5 41 00 00       	call   80105295 <acquire>
801010a0:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010a3:	8b 45 08             	mov    0x8(%ebp),%eax
801010a6:	8b 40 04             	mov    0x4(%eax),%eax
801010a9:	85 c0                	test   %eax,%eax
801010ab:	7f 0d                	jg     801010ba <filedup+0x2d>
    panic("filedup");
801010ad:	83 ec 0c             	sub    $0xc,%esp
801010b0:	68 4d 87 10 80       	push   $0x8010874d
801010b5:	e8 fb f4 ff ff       	call   801005b5 <panic>
  f->ref++;
801010ba:	8b 45 08             	mov    0x8(%ebp),%eax
801010bd:	8b 40 04             	mov    0x4(%eax),%eax
801010c0:	8d 50 01             	lea    0x1(%eax),%edx
801010c3:	8b 45 08             	mov    0x8(%ebp),%eax
801010c6:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801010c9:	83 ec 0c             	sub    $0xc,%esp
801010cc:	68 20 00 11 80       	push   $0x80110020
801010d1:	e8 2d 42 00 00       	call   80105303 <release>
801010d6:	83 c4 10             	add    $0x10,%esp
  return f;
801010d9:	8b 45 08             	mov    0x8(%ebp),%eax
}
801010dc:	c9                   	leave  
801010dd:	c3                   	ret    

801010de <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801010de:	55                   	push   %ebp
801010df:	89 e5                	mov    %esp,%ebp
801010e1:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010e4:	83 ec 0c             	sub    $0xc,%esp
801010e7:	68 20 00 11 80       	push   $0x80110020
801010ec:	e8 a4 41 00 00       	call   80105295 <acquire>
801010f1:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010f4:	8b 45 08             	mov    0x8(%ebp),%eax
801010f7:	8b 40 04             	mov    0x4(%eax),%eax
801010fa:	85 c0                	test   %eax,%eax
801010fc:	7f 0d                	jg     8010110b <fileclose+0x2d>
    panic("fileclose");
801010fe:	83 ec 0c             	sub    $0xc,%esp
80101101:	68 55 87 10 80       	push   $0x80108755
80101106:	e8 aa f4 ff ff       	call   801005b5 <panic>
  if(--f->ref > 0){
8010110b:	8b 45 08             	mov    0x8(%ebp),%eax
8010110e:	8b 40 04             	mov    0x4(%eax),%eax
80101111:	8d 50 ff             	lea    -0x1(%eax),%edx
80101114:	8b 45 08             	mov    0x8(%ebp),%eax
80101117:	89 50 04             	mov    %edx,0x4(%eax)
8010111a:	8b 45 08             	mov    0x8(%ebp),%eax
8010111d:	8b 40 04             	mov    0x4(%eax),%eax
80101120:	85 c0                	test   %eax,%eax
80101122:	7e 15                	jle    80101139 <fileclose+0x5b>
    release(&ftable.lock);
80101124:	83 ec 0c             	sub    $0xc,%esp
80101127:	68 20 00 11 80       	push   $0x80110020
8010112c:	e8 d2 41 00 00       	call   80105303 <release>
80101131:	83 c4 10             	add    $0x10,%esp
80101134:	e9 8b 00 00 00       	jmp    801011c4 <fileclose+0xe6>
    return;
  }
  ff = *f;
80101139:	8b 45 08             	mov    0x8(%ebp),%eax
8010113c:	8b 10                	mov    (%eax),%edx
8010113e:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101141:	8b 50 04             	mov    0x4(%eax),%edx
80101144:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101147:	8b 50 08             	mov    0x8(%eax),%edx
8010114a:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010114d:	8b 50 0c             	mov    0xc(%eax),%edx
80101150:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101153:	8b 50 10             	mov    0x10(%eax),%edx
80101156:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101159:	8b 40 14             	mov    0x14(%eax),%eax
8010115c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010115f:	8b 45 08             	mov    0x8(%ebp),%eax
80101162:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101169:	8b 45 08             	mov    0x8(%ebp),%eax
8010116c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101172:	83 ec 0c             	sub    $0xc,%esp
80101175:	68 20 00 11 80       	push   $0x80110020
8010117a:	e8 84 41 00 00       	call   80105303 <release>
8010117f:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101182:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101185:	83 f8 01             	cmp    $0x1,%eax
80101188:	75 19                	jne    801011a3 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
8010118a:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010118e:	0f be d0             	movsbl %al,%edx
80101191:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101194:	83 ec 08             	sub    $0x8,%esp
80101197:	52                   	push   %edx
80101198:	50                   	push   %eax
80101199:	e8 8a 2d 00 00       	call   80103f28 <pipeclose>
8010119e:	83 c4 10             	add    $0x10,%esp
801011a1:	eb 21                	jmp    801011c4 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
801011a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011a6:	83 f8 02             	cmp    $0x2,%eax
801011a9:	75 19                	jne    801011c4 <fileclose+0xe6>
    begin_op();
801011ab:	e8 82 23 00 00       	call   80103532 <begin_op>
    iput(ff.ip);
801011b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801011b3:	83 ec 0c             	sub    $0xc,%esp
801011b6:	50                   	push   %eax
801011b7:	e8 bf 09 00 00       	call   80101b7b <iput>
801011bc:	83 c4 10             	add    $0x10,%esp
    end_op();
801011bf:	e8 fa 23 00 00       	call   801035be <end_op>
  }
}
801011c4:	c9                   	leave  
801011c5:	c3                   	ret    

801011c6 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801011c6:	55                   	push   %ebp
801011c7:	89 e5                	mov    %esp,%ebp
801011c9:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
801011cc:	8b 45 08             	mov    0x8(%ebp),%eax
801011cf:	8b 00                	mov    (%eax),%eax
801011d1:	83 f8 02             	cmp    $0x2,%eax
801011d4:	75 40                	jne    80101216 <filestat+0x50>
    ilock(f->ip);
801011d6:	8b 45 08             	mov    0x8(%ebp),%eax
801011d9:	8b 40 10             	mov    0x10(%eax),%eax
801011dc:	83 ec 0c             	sub    $0xc,%esp
801011df:	50                   	push   %eax
801011e0:	e8 35 08 00 00       	call   80101a1a <ilock>
801011e5:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011e8:	8b 45 08             	mov    0x8(%ebp),%eax
801011eb:	8b 40 10             	mov    0x10(%eax),%eax
801011ee:	83 ec 08             	sub    $0x8,%esp
801011f1:	ff 75 0c             	push   0xc(%ebp)
801011f4:	50                   	push   %eax
801011f5:	e8 c6 0c 00 00       	call   80101ec0 <stati>
801011fa:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011fd:	8b 45 08             	mov    0x8(%ebp),%eax
80101200:	8b 40 10             	mov    0x10(%eax),%eax
80101203:	83 ec 0c             	sub    $0xc,%esp
80101206:	50                   	push   %eax
80101207:	e8 21 09 00 00       	call   80101b2d <iunlock>
8010120c:	83 c4 10             	add    $0x10,%esp
    return 0;
8010120f:	b8 00 00 00 00       	mov    $0x0,%eax
80101214:	eb 05                	jmp    8010121b <filestat+0x55>
  }
  return -1;
80101216:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010121b:	c9                   	leave  
8010121c:	c3                   	ret    

8010121d <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
8010121d:	55                   	push   %ebp
8010121e:	89 e5                	mov    %esp,%ebp
80101220:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101223:	8b 45 08             	mov    0x8(%ebp),%eax
80101226:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010122a:	84 c0                	test   %al,%al
8010122c:	75 0a                	jne    80101238 <fileread+0x1b>
    return -1;
8010122e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101233:	e9 9b 00 00 00       	jmp    801012d3 <fileread+0xb6>
  if(f->type == FD_PIPE)
80101238:	8b 45 08             	mov    0x8(%ebp),%eax
8010123b:	8b 00                	mov    (%eax),%eax
8010123d:	83 f8 01             	cmp    $0x1,%eax
80101240:	75 1a                	jne    8010125c <fileread+0x3f>
    return piperead(f->pipe, addr, n);
80101242:	8b 45 08             	mov    0x8(%ebp),%eax
80101245:	8b 40 0c             	mov    0xc(%eax),%eax
80101248:	83 ec 04             	sub    $0x4,%esp
8010124b:	ff 75 10             	push   0x10(%ebp)
8010124e:	ff 75 0c             	push   0xc(%ebp)
80101251:	50                   	push   %eax
80101252:	e8 7e 2e 00 00       	call   801040d5 <piperead>
80101257:	83 c4 10             	add    $0x10,%esp
8010125a:	eb 77                	jmp    801012d3 <fileread+0xb6>
  if(f->type == FD_INODE){
8010125c:	8b 45 08             	mov    0x8(%ebp),%eax
8010125f:	8b 00                	mov    (%eax),%eax
80101261:	83 f8 02             	cmp    $0x2,%eax
80101264:	75 60                	jne    801012c6 <fileread+0xa9>
    ilock(f->ip);
80101266:	8b 45 08             	mov    0x8(%ebp),%eax
80101269:	8b 40 10             	mov    0x10(%eax),%eax
8010126c:	83 ec 0c             	sub    $0xc,%esp
8010126f:	50                   	push   %eax
80101270:	e8 a5 07 00 00       	call   80101a1a <ilock>
80101275:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101278:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010127b:	8b 45 08             	mov    0x8(%ebp),%eax
8010127e:	8b 50 14             	mov    0x14(%eax),%edx
80101281:	8b 45 08             	mov    0x8(%ebp),%eax
80101284:	8b 40 10             	mov    0x10(%eax),%eax
80101287:	51                   	push   %ecx
80101288:	52                   	push   %edx
80101289:	ff 75 0c             	push   0xc(%ebp)
8010128c:	50                   	push   %eax
8010128d:	e8 74 0c 00 00       	call   80101f06 <readi>
80101292:	83 c4 10             	add    $0x10,%esp
80101295:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101298:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010129c:	7e 11                	jle    801012af <fileread+0x92>
      f->off += r;
8010129e:	8b 45 08             	mov    0x8(%ebp),%eax
801012a1:	8b 50 14             	mov    0x14(%eax),%edx
801012a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012a7:	01 c2                	add    %eax,%edx
801012a9:	8b 45 08             	mov    0x8(%ebp),%eax
801012ac:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801012af:	8b 45 08             	mov    0x8(%ebp),%eax
801012b2:	8b 40 10             	mov    0x10(%eax),%eax
801012b5:	83 ec 0c             	sub    $0xc,%esp
801012b8:	50                   	push   %eax
801012b9:	e8 6f 08 00 00       	call   80101b2d <iunlock>
801012be:	83 c4 10             	add    $0x10,%esp
    return r;
801012c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012c4:	eb 0d                	jmp    801012d3 <fileread+0xb6>
  }
  panic("fileread");
801012c6:	83 ec 0c             	sub    $0xc,%esp
801012c9:	68 5f 87 10 80       	push   $0x8010875f
801012ce:	e8 e2 f2 ff ff       	call   801005b5 <panic>
}
801012d3:	c9                   	leave  
801012d4:	c3                   	ret    

801012d5 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801012d5:	55                   	push   %ebp
801012d6:	89 e5                	mov    %esp,%ebp
801012d8:	53                   	push   %ebx
801012d9:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801012dc:	8b 45 08             	mov    0x8(%ebp),%eax
801012df:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012e3:	84 c0                	test   %al,%al
801012e5:	75 0a                	jne    801012f1 <filewrite+0x1c>
    return -1;
801012e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012ec:	e9 1b 01 00 00       	jmp    8010140c <filewrite+0x137>
  if(f->type == FD_PIPE)
801012f1:	8b 45 08             	mov    0x8(%ebp),%eax
801012f4:	8b 00                	mov    (%eax),%eax
801012f6:	83 f8 01             	cmp    $0x1,%eax
801012f9:	75 1d                	jne    80101318 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801012fb:	8b 45 08             	mov    0x8(%ebp),%eax
801012fe:	8b 40 0c             	mov    0xc(%eax),%eax
80101301:	83 ec 04             	sub    $0x4,%esp
80101304:	ff 75 10             	push   0x10(%ebp)
80101307:	ff 75 0c             	push   0xc(%ebp)
8010130a:	50                   	push   %eax
8010130b:	e8 c3 2c 00 00       	call   80103fd3 <pipewrite>
80101310:	83 c4 10             	add    $0x10,%esp
80101313:	e9 f4 00 00 00       	jmp    8010140c <filewrite+0x137>
  if(f->type == FD_INODE){
80101318:	8b 45 08             	mov    0x8(%ebp),%eax
8010131b:	8b 00                	mov    (%eax),%eax
8010131d:	83 f8 02             	cmp    $0x2,%eax
80101320:	0f 85 d9 00 00 00    	jne    801013ff <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
80101326:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
8010132d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101334:	e9 a3 00 00 00       	jmp    801013dc <filewrite+0x107>
      int n1 = n - i;
80101339:	8b 45 10             	mov    0x10(%ebp),%eax
8010133c:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010133f:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101342:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101345:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101348:	7e 06                	jle    80101350 <filewrite+0x7b>
        n1 = max;
8010134a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010134d:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101350:	e8 dd 21 00 00       	call   80103532 <begin_op>
      ilock(f->ip);
80101355:	8b 45 08             	mov    0x8(%ebp),%eax
80101358:	8b 40 10             	mov    0x10(%eax),%eax
8010135b:	83 ec 0c             	sub    $0xc,%esp
8010135e:	50                   	push   %eax
8010135f:	e8 b6 06 00 00       	call   80101a1a <ilock>
80101364:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101367:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010136a:	8b 45 08             	mov    0x8(%ebp),%eax
8010136d:	8b 50 14             	mov    0x14(%eax),%edx
80101370:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101373:	8b 45 0c             	mov    0xc(%ebp),%eax
80101376:	01 c3                	add    %eax,%ebx
80101378:	8b 45 08             	mov    0x8(%ebp),%eax
8010137b:	8b 40 10             	mov    0x10(%eax),%eax
8010137e:	51                   	push   %ecx
8010137f:	52                   	push   %edx
80101380:	53                   	push   %ebx
80101381:	50                   	push   %eax
80101382:	e8 d4 0c 00 00       	call   8010205b <writei>
80101387:	83 c4 10             	add    $0x10,%esp
8010138a:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010138d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101391:	7e 11                	jle    801013a4 <filewrite+0xcf>
        f->off += r;
80101393:	8b 45 08             	mov    0x8(%ebp),%eax
80101396:	8b 50 14             	mov    0x14(%eax),%edx
80101399:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010139c:	01 c2                	add    %eax,%edx
8010139e:	8b 45 08             	mov    0x8(%ebp),%eax
801013a1:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801013a4:	8b 45 08             	mov    0x8(%ebp),%eax
801013a7:	8b 40 10             	mov    0x10(%eax),%eax
801013aa:	83 ec 0c             	sub    $0xc,%esp
801013ad:	50                   	push   %eax
801013ae:	e8 7a 07 00 00       	call   80101b2d <iunlock>
801013b3:	83 c4 10             	add    $0x10,%esp
      end_op();
801013b6:	e8 03 22 00 00       	call   801035be <end_op>

      if(r < 0)
801013bb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013bf:	78 29                	js     801013ea <filewrite+0x115>
        break;
      if(r != n1)
801013c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013c4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801013c7:	74 0d                	je     801013d6 <filewrite+0x101>
        panic("short filewrite");
801013c9:	83 ec 0c             	sub    $0xc,%esp
801013cc:	68 68 87 10 80       	push   $0x80108768
801013d1:	e8 df f1 ff ff       	call   801005b5 <panic>
      i += r;
801013d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013d9:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
801013dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013df:	3b 45 10             	cmp    0x10(%ebp),%eax
801013e2:	0f 8c 51 ff ff ff    	jl     80101339 <filewrite+0x64>
801013e8:	eb 01                	jmp    801013eb <filewrite+0x116>
        break;
801013ea:	90                   	nop
    }
    return i == n ? n : -1;
801013eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ee:	3b 45 10             	cmp    0x10(%ebp),%eax
801013f1:	75 05                	jne    801013f8 <filewrite+0x123>
801013f3:	8b 45 10             	mov    0x10(%ebp),%eax
801013f6:	eb 14                	jmp    8010140c <filewrite+0x137>
801013f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013fd:	eb 0d                	jmp    8010140c <filewrite+0x137>
  }
  panic("filewrite");
801013ff:	83 ec 0c             	sub    $0xc,%esp
80101402:	68 78 87 10 80       	push   $0x80108778
80101407:	e8 a9 f1 ff ff       	call   801005b5 <panic>
}
8010140c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010140f:	c9                   	leave  
80101410:	c3                   	ret    

80101411 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101411:	55                   	push   %ebp
80101412:	89 e5                	mov    %esp,%ebp
80101414:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
80101417:	8b 45 08             	mov    0x8(%ebp),%eax
8010141a:	83 ec 08             	sub    $0x8,%esp
8010141d:	6a 01                	push   $0x1
8010141f:	50                   	push   %eax
80101420:	e8 aa ed ff ff       	call   801001cf <bread>
80101425:	83 c4 10             	add    $0x10,%esp
80101428:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010142b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010142e:	83 c0 5c             	add    $0x5c,%eax
80101431:	83 ec 04             	sub    $0x4,%esp
80101434:	6a 1c                	push   $0x1c
80101436:	50                   	push   %eax
80101437:	ff 75 0c             	push   0xc(%ebp)
8010143a:	e8 9b 41 00 00       	call   801055da <memmove>
8010143f:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101442:	83 ec 0c             	sub    $0xc,%esp
80101445:	ff 75 f4             	push   -0xc(%ebp)
80101448:	e8 04 ee ff ff       	call   80100251 <brelse>
8010144d:	83 c4 10             	add    $0x10,%esp
}
80101450:	90                   	nop
80101451:	c9                   	leave  
80101452:	c3                   	ret    

80101453 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101453:	55                   	push   %ebp
80101454:	89 e5                	mov    %esp,%ebp
80101456:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101459:	8b 55 0c             	mov    0xc(%ebp),%edx
8010145c:	8b 45 08             	mov    0x8(%ebp),%eax
8010145f:	83 ec 08             	sub    $0x8,%esp
80101462:	52                   	push   %edx
80101463:	50                   	push   %eax
80101464:	e8 66 ed ff ff       	call   801001cf <bread>
80101469:	83 c4 10             	add    $0x10,%esp
8010146c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010146f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101472:	83 c0 5c             	add    $0x5c,%eax
80101475:	83 ec 04             	sub    $0x4,%esp
80101478:	68 00 02 00 00       	push   $0x200
8010147d:	6a 00                	push   $0x0
8010147f:	50                   	push   %eax
80101480:	e8 96 40 00 00       	call   8010551b <memset>
80101485:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101488:	83 ec 0c             	sub    $0xc,%esp
8010148b:	ff 75 f4             	push   -0xc(%ebp)
8010148e:	e8 d8 22 00 00       	call   8010376b <log_write>
80101493:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101496:	83 ec 0c             	sub    $0xc,%esp
80101499:	ff 75 f4             	push   -0xc(%ebp)
8010149c:	e8 b0 ed ff ff       	call   80100251 <brelse>
801014a1:	83 c4 10             	add    $0x10,%esp
}
801014a4:	90                   	nop
801014a5:	c9                   	leave  
801014a6:	c3                   	ret    

801014a7 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801014a7:	55                   	push   %ebp
801014a8:	89 e5                	mov    %esp,%ebp
801014aa:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801014ad:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801014b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801014bb:	e9 0b 01 00 00       	jmp    801015cb <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
801014c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014c3:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801014c9:	85 c0                	test   %eax,%eax
801014cb:	0f 48 c2             	cmovs  %edx,%eax
801014ce:	c1 f8 0c             	sar    $0xc,%eax
801014d1:	89 c2                	mov    %eax,%edx
801014d3:	a1 d8 09 11 80       	mov    0x801109d8,%eax
801014d8:	01 d0                	add    %edx,%eax
801014da:	83 ec 08             	sub    $0x8,%esp
801014dd:	50                   	push   %eax
801014de:	ff 75 08             	push   0x8(%ebp)
801014e1:	e8 e9 ec ff ff       	call   801001cf <bread>
801014e6:	83 c4 10             	add    $0x10,%esp
801014e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014ec:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014f3:	e9 9e 00 00 00       	jmp    80101596 <balloc+0xef>
      m = 1 << (bi % 8);
801014f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014fb:	83 e0 07             	and    $0x7,%eax
801014fe:	ba 01 00 00 00       	mov    $0x1,%edx
80101503:	89 c1                	mov    %eax,%ecx
80101505:	d3 e2                	shl    %cl,%edx
80101507:	89 d0                	mov    %edx,%eax
80101509:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010150c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010150f:	8d 50 07             	lea    0x7(%eax),%edx
80101512:	85 c0                	test   %eax,%eax
80101514:	0f 48 c2             	cmovs  %edx,%eax
80101517:	c1 f8 03             	sar    $0x3,%eax
8010151a:	89 c2                	mov    %eax,%edx
8010151c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010151f:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101524:	0f b6 c0             	movzbl %al,%eax
80101527:	23 45 e8             	and    -0x18(%ebp),%eax
8010152a:	85 c0                	test   %eax,%eax
8010152c:	75 64                	jne    80101592 <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
8010152e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101531:	8d 50 07             	lea    0x7(%eax),%edx
80101534:	85 c0                	test   %eax,%eax
80101536:	0f 48 c2             	cmovs  %edx,%eax
80101539:	c1 f8 03             	sar    $0x3,%eax
8010153c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010153f:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101544:	89 d1                	mov    %edx,%ecx
80101546:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101549:	09 ca                	or     %ecx,%edx
8010154b:	89 d1                	mov    %edx,%ecx
8010154d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101550:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101554:	83 ec 0c             	sub    $0xc,%esp
80101557:	ff 75 ec             	push   -0x14(%ebp)
8010155a:	e8 0c 22 00 00       	call   8010376b <log_write>
8010155f:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101562:	83 ec 0c             	sub    $0xc,%esp
80101565:	ff 75 ec             	push   -0x14(%ebp)
80101568:	e8 e4 ec ff ff       	call   80100251 <brelse>
8010156d:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101570:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101573:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101576:	01 c2                	add    %eax,%edx
80101578:	8b 45 08             	mov    0x8(%ebp),%eax
8010157b:	83 ec 08             	sub    $0x8,%esp
8010157e:	52                   	push   %edx
8010157f:	50                   	push   %eax
80101580:	e8 ce fe ff ff       	call   80101453 <bzero>
80101585:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101588:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010158b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010158e:	01 d0                	add    %edx,%eax
80101590:	eb 57                	jmp    801015e9 <balloc+0x142>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101592:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101596:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010159d:	7f 17                	jg     801015b6 <balloc+0x10f>
8010159f:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015a5:	01 d0                	add    %edx,%eax
801015a7:	89 c2                	mov    %eax,%edx
801015a9:	a1 c0 09 11 80       	mov    0x801109c0,%eax
801015ae:	39 c2                	cmp    %eax,%edx
801015b0:	0f 82 42 ff ff ff    	jb     801014f8 <balloc+0x51>
      }
    }
    brelse(bp);
801015b6:	83 ec 0c             	sub    $0xc,%esp
801015b9:	ff 75 ec             	push   -0x14(%ebp)
801015bc:	e8 90 ec ff ff       	call   80100251 <brelse>
801015c1:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
801015c4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801015cb:	8b 15 c0 09 11 80    	mov    0x801109c0,%edx
801015d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015d4:	39 c2                	cmp    %eax,%edx
801015d6:	0f 87 e4 fe ff ff    	ja     801014c0 <balloc+0x19>
  }
  panic("balloc: out of blocks");
801015dc:	83 ec 0c             	sub    $0xc,%esp
801015df:	68 84 87 10 80       	push   $0x80108784
801015e4:	e8 cc ef ff ff       	call   801005b5 <panic>
}
801015e9:	c9                   	leave  
801015ea:	c3                   	ret    

801015eb <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801015eb:	55                   	push   %ebp
801015ec:	89 e5                	mov    %esp,%ebp
801015ee:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
801015f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801015f4:	c1 e8 0c             	shr    $0xc,%eax
801015f7:	89 c2                	mov    %eax,%edx
801015f9:	a1 d8 09 11 80       	mov    0x801109d8,%eax
801015fe:	01 c2                	add    %eax,%edx
80101600:	8b 45 08             	mov    0x8(%ebp),%eax
80101603:	83 ec 08             	sub    $0x8,%esp
80101606:	52                   	push   %edx
80101607:	50                   	push   %eax
80101608:	e8 c2 eb ff ff       	call   801001cf <bread>
8010160d:	83 c4 10             	add    $0x10,%esp
80101610:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101613:	8b 45 0c             	mov    0xc(%ebp),%eax
80101616:	25 ff 0f 00 00       	and    $0xfff,%eax
8010161b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010161e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101621:	83 e0 07             	and    $0x7,%eax
80101624:	ba 01 00 00 00       	mov    $0x1,%edx
80101629:	89 c1                	mov    %eax,%ecx
8010162b:	d3 e2                	shl    %cl,%edx
8010162d:	89 d0                	mov    %edx,%eax
8010162f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101632:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101635:	8d 50 07             	lea    0x7(%eax),%edx
80101638:	85 c0                	test   %eax,%eax
8010163a:	0f 48 c2             	cmovs  %edx,%eax
8010163d:	c1 f8 03             	sar    $0x3,%eax
80101640:	89 c2                	mov    %eax,%edx
80101642:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101645:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
8010164a:	0f b6 c0             	movzbl %al,%eax
8010164d:	23 45 ec             	and    -0x14(%ebp),%eax
80101650:	85 c0                	test   %eax,%eax
80101652:	75 0d                	jne    80101661 <bfree+0x76>
    panic("freeing free block");
80101654:	83 ec 0c             	sub    $0xc,%esp
80101657:	68 9a 87 10 80       	push   $0x8010879a
8010165c:	e8 54 ef ff ff       	call   801005b5 <panic>
  bp->data[bi/8] &= ~m;
80101661:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101664:	8d 50 07             	lea    0x7(%eax),%edx
80101667:	85 c0                	test   %eax,%eax
80101669:	0f 48 c2             	cmovs  %edx,%eax
8010166c:	c1 f8 03             	sar    $0x3,%eax
8010166f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101672:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101677:	89 d1                	mov    %edx,%ecx
80101679:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010167c:	f7 d2                	not    %edx
8010167e:	21 ca                	and    %ecx,%edx
80101680:	89 d1                	mov    %edx,%ecx
80101682:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101685:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101689:	83 ec 0c             	sub    $0xc,%esp
8010168c:	ff 75 f4             	push   -0xc(%ebp)
8010168f:	e8 d7 20 00 00       	call   8010376b <log_write>
80101694:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101697:	83 ec 0c             	sub    $0xc,%esp
8010169a:	ff 75 f4             	push   -0xc(%ebp)
8010169d:	e8 af eb ff ff       	call   80100251 <brelse>
801016a2:	83 c4 10             	add    $0x10,%esp
}
801016a5:	90                   	nop
801016a6:	c9                   	leave  
801016a7:	c3                   	ret    

801016a8 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801016a8:	55                   	push   %ebp
801016a9:	89 e5                	mov    %esp,%ebp
801016ab:	57                   	push   %edi
801016ac:	56                   	push   %esi
801016ad:	53                   	push   %ebx
801016ae:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
801016b1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
801016b8:	83 ec 08             	sub    $0x8,%esp
801016bb:	68 ad 87 10 80       	push   $0x801087ad
801016c0:	68 e0 09 11 80       	push   $0x801109e0
801016c5:	e8 a9 3b 00 00       	call   80105273 <initlock>
801016ca:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016cd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801016d4:	eb 2d                	jmp    80101703 <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
801016d6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801016d9:	89 d0                	mov    %edx,%eax
801016db:	c1 e0 03             	shl    $0x3,%eax
801016de:	01 d0                	add    %edx,%eax
801016e0:	c1 e0 04             	shl    $0x4,%eax
801016e3:	83 c0 30             	add    $0x30,%eax
801016e6:	05 e0 09 11 80       	add    $0x801109e0,%eax
801016eb:	83 c0 10             	add    $0x10,%eax
801016ee:	83 ec 08             	sub    $0x8,%esp
801016f1:	68 b4 87 10 80       	push   $0x801087b4
801016f6:	50                   	push   %eax
801016f7:	e8 f4 39 00 00       	call   801050f0 <initsleeplock>
801016fc:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016ff:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101703:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
80101707:	7e cd                	jle    801016d6 <iinit+0x2e>
  }

  readsb(dev, &sb);
80101709:	83 ec 08             	sub    $0x8,%esp
8010170c:	68 c0 09 11 80       	push   $0x801109c0
80101711:	ff 75 08             	push   0x8(%ebp)
80101714:	e8 f8 fc ff ff       	call   80101411 <readsb>
80101719:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
8010171c:	a1 d8 09 11 80       	mov    0x801109d8,%eax
80101721:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80101724:	8b 3d d4 09 11 80    	mov    0x801109d4,%edi
8010172a:	8b 35 d0 09 11 80    	mov    0x801109d0,%esi
80101730:	8b 1d cc 09 11 80    	mov    0x801109cc,%ebx
80101736:	8b 0d c8 09 11 80    	mov    0x801109c8,%ecx
8010173c:	8b 15 c4 09 11 80    	mov    0x801109c4,%edx
80101742:	a1 c0 09 11 80       	mov    0x801109c0,%eax
80101747:	ff 75 d4             	push   -0x2c(%ebp)
8010174a:	57                   	push   %edi
8010174b:	56                   	push   %esi
8010174c:	53                   	push   %ebx
8010174d:	51                   	push   %ecx
8010174e:	52                   	push   %edx
8010174f:	50                   	push   %eax
80101750:	68 bc 87 10 80       	push   $0x801087bc
80101755:	e8 a6 ec ff ff       	call   80100400 <cprintf>
8010175a:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010175d:	90                   	nop
8010175e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101761:	5b                   	pop    %ebx
80101762:	5e                   	pop    %esi
80101763:	5f                   	pop    %edi
80101764:	5d                   	pop    %ebp
80101765:	c3                   	ret    

80101766 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101766:	55                   	push   %ebp
80101767:	89 e5                	mov    %esp,%ebp
80101769:	83 ec 28             	sub    $0x28,%esp
8010176c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010176f:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101773:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010177a:	e9 9e 00 00 00       	jmp    8010181d <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
8010177f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101782:	c1 e8 03             	shr    $0x3,%eax
80101785:	89 c2                	mov    %eax,%edx
80101787:	a1 d4 09 11 80       	mov    0x801109d4,%eax
8010178c:	01 d0                	add    %edx,%eax
8010178e:	83 ec 08             	sub    $0x8,%esp
80101791:	50                   	push   %eax
80101792:	ff 75 08             	push   0x8(%ebp)
80101795:	e8 35 ea ff ff       	call   801001cf <bread>
8010179a:	83 c4 10             	add    $0x10,%esp
8010179d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801017a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017a3:	8d 50 5c             	lea    0x5c(%eax),%edx
801017a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017a9:	83 e0 07             	and    $0x7,%eax
801017ac:	c1 e0 06             	shl    $0x6,%eax
801017af:	01 d0                	add    %edx,%eax
801017b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801017b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017b7:	0f b7 00             	movzwl (%eax),%eax
801017ba:	66 85 c0             	test   %ax,%ax
801017bd:	75 4c                	jne    8010180b <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
801017bf:	83 ec 04             	sub    $0x4,%esp
801017c2:	6a 40                	push   $0x40
801017c4:	6a 00                	push   $0x0
801017c6:	ff 75 ec             	push   -0x14(%ebp)
801017c9:	e8 4d 3d 00 00       	call   8010551b <memset>
801017ce:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017d4:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017d8:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017db:	83 ec 0c             	sub    $0xc,%esp
801017de:	ff 75 f0             	push   -0x10(%ebp)
801017e1:	e8 85 1f 00 00       	call   8010376b <log_write>
801017e6:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017e9:	83 ec 0c             	sub    $0xc,%esp
801017ec:	ff 75 f0             	push   -0x10(%ebp)
801017ef:	e8 5d ea ff ff       	call   80100251 <brelse>
801017f4:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017fa:	83 ec 08             	sub    $0x8,%esp
801017fd:	50                   	push   %eax
801017fe:	ff 75 08             	push   0x8(%ebp)
80101801:	e8 f8 00 00 00       	call   801018fe <iget>
80101806:	83 c4 10             	add    $0x10,%esp
80101809:	eb 30                	jmp    8010183b <ialloc+0xd5>
    }
    brelse(bp);
8010180b:	83 ec 0c             	sub    $0xc,%esp
8010180e:	ff 75 f0             	push   -0x10(%ebp)
80101811:	e8 3b ea ff ff       	call   80100251 <brelse>
80101816:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
80101819:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010181d:	8b 15 c8 09 11 80    	mov    0x801109c8,%edx
80101823:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101826:	39 c2                	cmp    %eax,%edx
80101828:	0f 87 51 ff ff ff    	ja     8010177f <ialloc+0x19>
  }
  panic("ialloc: no inodes");
8010182e:	83 ec 0c             	sub    $0xc,%esp
80101831:	68 0f 88 10 80       	push   $0x8010880f
80101836:	e8 7a ed ff ff       	call   801005b5 <panic>
}
8010183b:	c9                   	leave  
8010183c:	c3                   	ret    

8010183d <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
8010183d:	55                   	push   %ebp
8010183e:	89 e5                	mov    %esp,%ebp
80101840:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101843:	8b 45 08             	mov    0x8(%ebp),%eax
80101846:	8b 40 04             	mov    0x4(%eax),%eax
80101849:	c1 e8 03             	shr    $0x3,%eax
8010184c:	89 c2                	mov    %eax,%edx
8010184e:	a1 d4 09 11 80       	mov    0x801109d4,%eax
80101853:	01 c2                	add    %eax,%edx
80101855:	8b 45 08             	mov    0x8(%ebp),%eax
80101858:	8b 00                	mov    (%eax),%eax
8010185a:	83 ec 08             	sub    $0x8,%esp
8010185d:	52                   	push   %edx
8010185e:	50                   	push   %eax
8010185f:	e8 6b e9 ff ff       	call   801001cf <bread>
80101864:	83 c4 10             	add    $0x10,%esp
80101867:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010186a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010186d:	8d 50 5c             	lea    0x5c(%eax),%edx
80101870:	8b 45 08             	mov    0x8(%ebp),%eax
80101873:	8b 40 04             	mov    0x4(%eax),%eax
80101876:	83 e0 07             	and    $0x7,%eax
80101879:	c1 e0 06             	shl    $0x6,%eax
8010187c:	01 d0                	add    %edx,%eax
8010187e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101881:	8b 45 08             	mov    0x8(%ebp),%eax
80101884:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101888:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010188b:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010188e:	8b 45 08             	mov    0x8(%ebp),%eax
80101891:	0f b7 50 52          	movzwl 0x52(%eax),%edx
80101895:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101898:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010189c:	8b 45 08             	mov    0x8(%ebp),%eax
8010189f:	0f b7 50 54          	movzwl 0x54(%eax),%edx
801018a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018a6:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801018aa:	8b 45 08             	mov    0x8(%ebp),%eax
801018ad:	0f b7 50 56          	movzwl 0x56(%eax),%edx
801018b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018b4:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801018b8:	8b 45 08             	mov    0x8(%ebp),%eax
801018bb:	8b 50 58             	mov    0x58(%eax),%edx
801018be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018c1:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801018c4:	8b 45 08             	mov    0x8(%ebp),%eax
801018c7:	8d 50 5c             	lea    0x5c(%eax),%edx
801018ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018cd:	83 c0 0c             	add    $0xc,%eax
801018d0:	83 ec 04             	sub    $0x4,%esp
801018d3:	6a 34                	push   $0x34
801018d5:	52                   	push   %edx
801018d6:	50                   	push   %eax
801018d7:	e8 fe 3c 00 00       	call   801055da <memmove>
801018dc:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018df:	83 ec 0c             	sub    $0xc,%esp
801018e2:	ff 75 f4             	push   -0xc(%ebp)
801018e5:	e8 81 1e 00 00       	call   8010376b <log_write>
801018ea:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018ed:	83 ec 0c             	sub    $0xc,%esp
801018f0:	ff 75 f4             	push   -0xc(%ebp)
801018f3:	e8 59 e9 ff ff       	call   80100251 <brelse>
801018f8:	83 c4 10             	add    $0x10,%esp
}
801018fb:	90                   	nop
801018fc:	c9                   	leave  
801018fd:	c3                   	ret    

801018fe <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018fe:	55                   	push   %ebp
801018ff:	89 e5                	mov    %esp,%ebp
80101901:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101904:	83 ec 0c             	sub    $0xc,%esp
80101907:	68 e0 09 11 80       	push   $0x801109e0
8010190c:	e8 84 39 00 00       	call   80105295 <acquire>
80101911:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101914:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010191b:	c7 45 f4 14 0a 11 80 	movl   $0x80110a14,-0xc(%ebp)
80101922:	eb 60                	jmp    80101984 <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101927:	8b 40 08             	mov    0x8(%eax),%eax
8010192a:	85 c0                	test   %eax,%eax
8010192c:	7e 39                	jle    80101967 <iget+0x69>
8010192e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101931:	8b 00                	mov    (%eax),%eax
80101933:	39 45 08             	cmp    %eax,0x8(%ebp)
80101936:	75 2f                	jne    80101967 <iget+0x69>
80101938:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010193b:	8b 40 04             	mov    0x4(%eax),%eax
8010193e:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101941:	75 24                	jne    80101967 <iget+0x69>
      ip->ref++;
80101943:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101946:	8b 40 08             	mov    0x8(%eax),%eax
80101949:	8d 50 01             	lea    0x1(%eax),%edx
8010194c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010194f:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101952:	83 ec 0c             	sub    $0xc,%esp
80101955:	68 e0 09 11 80       	push   $0x801109e0
8010195a:	e8 a4 39 00 00       	call   80105303 <release>
8010195f:	83 c4 10             	add    $0x10,%esp
      return ip;
80101962:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101965:	eb 77                	jmp    801019de <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101967:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010196b:	75 10                	jne    8010197d <iget+0x7f>
8010196d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101970:	8b 40 08             	mov    0x8(%eax),%eax
80101973:	85 c0                	test   %eax,%eax
80101975:	75 06                	jne    8010197d <iget+0x7f>
      empty = ip;
80101977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010197a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010197d:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101984:	81 7d f4 34 26 11 80 	cmpl   $0x80112634,-0xc(%ebp)
8010198b:	72 97                	jb     80101924 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010198d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101991:	75 0d                	jne    801019a0 <iget+0xa2>
    panic("iget: no inodes");
80101993:	83 ec 0c             	sub    $0xc,%esp
80101996:	68 21 88 10 80       	push   $0x80108821
8010199b:	e8 15 ec ff ff       	call   801005b5 <panic>

  ip = empty;
801019a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801019a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a9:	8b 55 08             	mov    0x8(%ebp),%edx
801019ac:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801019ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019b1:	8b 55 0c             	mov    0xc(%ebp),%edx
801019b4:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
801019b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ba:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
801019c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019c4:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
801019cb:	83 ec 0c             	sub    $0xc,%esp
801019ce:	68 e0 09 11 80       	push   $0x801109e0
801019d3:	e8 2b 39 00 00       	call   80105303 <release>
801019d8:	83 c4 10             	add    $0x10,%esp

  return ip;
801019db:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019de:	c9                   	leave  
801019df:	c3                   	ret    

801019e0 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019e0:	55                   	push   %ebp
801019e1:	89 e5                	mov    %esp,%ebp
801019e3:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019e6:	83 ec 0c             	sub    $0xc,%esp
801019e9:	68 e0 09 11 80       	push   $0x801109e0
801019ee:	e8 a2 38 00 00       	call   80105295 <acquire>
801019f3:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019f6:	8b 45 08             	mov    0x8(%ebp),%eax
801019f9:	8b 40 08             	mov    0x8(%eax),%eax
801019fc:	8d 50 01             	lea    0x1(%eax),%edx
801019ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101a02:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a05:	83 ec 0c             	sub    $0xc,%esp
80101a08:	68 e0 09 11 80       	push   $0x801109e0
80101a0d:	e8 f1 38 00 00       	call   80105303 <release>
80101a12:	83 c4 10             	add    $0x10,%esp
  return ip;
80101a15:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101a18:	c9                   	leave  
80101a19:	c3                   	ret    

80101a1a <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101a1a:	55                   	push   %ebp
80101a1b:	89 e5                	mov    %esp,%ebp
80101a1d:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101a20:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a24:	74 0a                	je     80101a30 <ilock+0x16>
80101a26:	8b 45 08             	mov    0x8(%ebp),%eax
80101a29:	8b 40 08             	mov    0x8(%eax),%eax
80101a2c:	85 c0                	test   %eax,%eax
80101a2e:	7f 0d                	jg     80101a3d <ilock+0x23>
    panic("ilock");
80101a30:	83 ec 0c             	sub    $0xc,%esp
80101a33:	68 31 88 10 80       	push   $0x80108831
80101a38:	e8 78 eb ff ff       	call   801005b5 <panic>

  acquiresleep(&ip->lock);
80101a3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a40:	83 c0 0c             	add    $0xc,%eax
80101a43:	83 ec 0c             	sub    $0xc,%esp
80101a46:	50                   	push   %eax
80101a47:	e8 e0 36 00 00       	call   8010512c <acquiresleep>
80101a4c:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a52:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a55:	85 c0                	test   %eax,%eax
80101a57:	0f 85 cd 00 00 00    	jne    80101b2a <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a60:	8b 40 04             	mov    0x4(%eax),%eax
80101a63:	c1 e8 03             	shr    $0x3,%eax
80101a66:	89 c2                	mov    %eax,%edx
80101a68:	a1 d4 09 11 80       	mov    0x801109d4,%eax
80101a6d:	01 c2                	add    %eax,%edx
80101a6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a72:	8b 00                	mov    (%eax),%eax
80101a74:	83 ec 08             	sub    $0x8,%esp
80101a77:	52                   	push   %edx
80101a78:	50                   	push   %eax
80101a79:	e8 51 e7 ff ff       	call   801001cf <bread>
80101a7e:	83 c4 10             	add    $0x10,%esp
80101a81:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a87:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8d:	8b 40 04             	mov    0x4(%eax),%eax
80101a90:	83 e0 07             	and    $0x7,%eax
80101a93:	c1 e0 06             	shl    $0x6,%eax
80101a96:	01 d0                	add    %edx,%eax
80101a98:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a9e:	0f b7 10             	movzwl (%eax),%edx
80101aa1:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa4:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101aa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aab:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101aaf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab2:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101ab6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ab9:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101abd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac0:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101ac4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ac7:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101acb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ace:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101ad2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ad5:	8b 50 08             	mov    0x8(%eax),%edx
80101ad8:	8b 45 08             	mov    0x8(%ebp),%eax
80101adb:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101ade:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ae1:	8d 50 0c             	lea    0xc(%eax),%edx
80101ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae7:	83 c0 5c             	add    $0x5c,%eax
80101aea:	83 ec 04             	sub    $0x4,%esp
80101aed:	6a 34                	push   $0x34
80101aef:	52                   	push   %edx
80101af0:	50                   	push   %eax
80101af1:	e8 e4 3a 00 00       	call   801055da <memmove>
80101af6:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101af9:	83 ec 0c             	sub    $0xc,%esp
80101afc:	ff 75 f4             	push   -0xc(%ebp)
80101aff:	e8 4d e7 ff ff       	call   80100251 <brelse>
80101b04:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101b07:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0a:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101b11:	8b 45 08             	mov    0x8(%ebp),%eax
80101b14:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101b18:	66 85 c0             	test   %ax,%ax
80101b1b:	75 0d                	jne    80101b2a <ilock+0x110>
      panic("ilock: no type");
80101b1d:	83 ec 0c             	sub    $0xc,%esp
80101b20:	68 37 88 10 80       	push   $0x80108837
80101b25:	e8 8b ea ff ff       	call   801005b5 <panic>
  }
}
80101b2a:	90                   	nop
80101b2b:	c9                   	leave  
80101b2c:	c3                   	ret    

80101b2d <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101b2d:	55                   	push   %ebp
80101b2e:	89 e5                	mov    %esp,%ebp
80101b30:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b33:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b37:	74 20                	je     80101b59 <iunlock+0x2c>
80101b39:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3c:	83 c0 0c             	add    $0xc,%eax
80101b3f:	83 ec 0c             	sub    $0xc,%esp
80101b42:	50                   	push   %eax
80101b43:	e8 96 36 00 00       	call   801051de <holdingsleep>
80101b48:	83 c4 10             	add    $0x10,%esp
80101b4b:	85 c0                	test   %eax,%eax
80101b4d:	74 0a                	je     80101b59 <iunlock+0x2c>
80101b4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b52:	8b 40 08             	mov    0x8(%eax),%eax
80101b55:	85 c0                	test   %eax,%eax
80101b57:	7f 0d                	jg     80101b66 <iunlock+0x39>
    panic("iunlock");
80101b59:	83 ec 0c             	sub    $0xc,%esp
80101b5c:	68 46 88 10 80       	push   $0x80108846
80101b61:	e8 4f ea ff ff       	call   801005b5 <panic>

  releasesleep(&ip->lock);
80101b66:	8b 45 08             	mov    0x8(%ebp),%eax
80101b69:	83 c0 0c             	add    $0xc,%eax
80101b6c:	83 ec 0c             	sub    $0xc,%esp
80101b6f:	50                   	push   %eax
80101b70:	e8 1b 36 00 00       	call   80105190 <releasesleep>
80101b75:	83 c4 10             	add    $0x10,%esp
}
80101b78:	90                   	nop
80101b79:	c9                   	leave  
80101b7a:	c3                   	ret    

80101b7b <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b7b:	55                   	push   %ebp
80101b7c:	89 e5                	mov    %esp,%ebp
80101b7e:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101b81:	8b 45 08             	mov    0x8(%ebp),%eax
80101b84:	83 c0 0c             	add    $0xc,%eax
80101b87:	83 ec 0c             	sub    $0xc,%esp
80101b8a:	50                   	push   %eax
80101b8b:	e8 9c 35 00 00       	call   8010512c <acquiresleep>
80101b90:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101b93:	8b 45 08             	mov    0x8(%ebp),%eax
80101b96:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b99:	85 c0                	test   %eax,%eax
80101b9b:	74 6a                	je     80101c07 <iput+0x8c>
80101b9d:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba0:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101ba4:	66 85 c0             	test   %ax,%ax
80101ba7:	75 5e                	jne    80101c07 <iput+0x8c>
    acquire(&icache.lock);
80101ba9:	83 ec 0c             	sub    $0xc,%esp
80101bac:	68 e0 09 11 80       	push   $0x801109e0
80101bb1:	e8 df 36 00 00       	call   80105295 <acquire>
80101bb6:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbc:	8b 40 08             	mov    0x8(%eax),%eax
80101bbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101bc2:	83 ec 0c             	sub    $0xc,%esp
80101bc5:	68 e0 09 11 80       	push   $0x801109e0
80101bca:	e8 34 37 00 00       	call   80105303 <release>
80101bcf:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101bd2:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101bd6:	75 2f                	jne    80101c07 <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101bd8:	83 ec 0c             	sub    $0xc,%esp
80101bdb:	ff 75 08             	push   0x8(%ebp)
80101bde:	e8 ad 01 00 00       	call   80101d90 <itrunc>
80101be3:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101be6:	8b 45 08             	mov    0x8(%ebp),%eax
80101be9:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101bef:	83 ec 0c             	sub    $0xc,%esp
80101bf2:	ff 75 08             	push   0x8(%ebp)
80101bf5:	e8 43 fc ff ff       	call   8010183d <iupdate>
80101bfa:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101bfd:	8b 45 08             	mov    0x8(%ebp),%eax
80101c00:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101c07:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0a:	83 c0 0c             	add    $0xc,%eax
80101c0d:	83 ec 0c             	sub    $0xc,%esp
80101c10:	50                   	push   %eax
80101c11:	e8 7a 35 00 00       	call   80105190 <releasesleep>
80101c16:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101c19:	83 ec 0c             	sub    $0xc,%esp
80101c1c:	68 e0 09 11 80       	push   $0x801109e0
80101c21:	e8 6f 36 00 00       	call   80105295 <acquire>
80101c26:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101c29:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2c:	8b 40 08             	mov    0x8(%eax),%eax
80101c2f:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c32:	8b 45 08             	mov    0x8(%ebp),%eax
80101c35:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c38:	83 ec 0c             	sub    $0xc,%esp
80101c3b:	68 e0 09 11 80       	push   $0x801109e0
80101c40:	e8 be 36 00 00       	call   80105303 <release>
80101c45:	83 c4 10             	add    $0x10,%esp
}
80101c48:	90                   	nop
80101c49:	c9                   	leave  
80101c4a:	c3                   	ret    

80101c4b <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c4b:	55                   	push   %ebp
80101c4c:	89 e5                	mov    %esp,%ebp
80101c4e:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c51:	83 ec 0c             	sub    $0xc,%esp
80101c54:	ff 75 08             	push   0x8(%ebp)
80101c57:	e8 d1 fe ff ff       	call   80101b2d <iunlock>
80101c5c:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c5f:	83 ec 0c             	sub    $0xc,%esp
80101c62:	ff 75 08             	push   0x8(%ebp)
80101c65:	e8 11 ff ff ff       	call   80101b7b <iput>
80101c6a:	83 c4 10             	add    $0x10,%esp
}
80101c6d:	90                   	nop
80101c6e:	c9                   	leave  
80101c6f:	c3                   	ret    

80101c70 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c70:	55                   	push   %ebp
80101c71:	89 e5                	mov    %esp,%ebp
80101c73:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c76:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c7a:	77 42                	ja     80101cbe <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c82:	83 c2 14             	add    $0x14,%edx
80101c85:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c89:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c8c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c90:	75 24                	jne    80101cb6 <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c92:	8b 45 08             	mov    0x8(%ebp),%eax
80101c95:	8b 00                	mov    (%eax),%eax
80101c97:	83 ec 0c             	sub    $0xc,%esp
80101c9a:	50                   	push   %eax
80101c9b:	e8 07 f8 ff ff       	call   801014a7 <balloc>
80101ca0:	83 c4 10             	add    $0x10,%esp
80101ca3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ca6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca9:	8b 55 0c             	mov    0xc(%ebp),%edx
80101cac:	8d 4a 14             	lea    0x14(%edx),%ecx
80101caf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cb2:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cb9:	e9 d0 00 00 00       	jmp    80101d8e <bmap+0x11e>
  }
  bn -= NDIRECT;
80101cbe:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101cc2:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101cc6:	0f 87 b5 00 00 00    	ja     80101d81 <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101ccc:	8b 45 08             	mov    0x8(%ebp),%eax
80101ccf:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101cd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cd8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cdc:	75 20                	jne    80101cfe <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cde:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce1:	8b 00                	mov    (%eax),%eax
80101ce3:	83 ec 0c             	sub    $0xc,%esp
80101ce6:	50                   	push   %eax
80101ce7:	e8 bb f7 ff ff       	call   801014a7 <balloc>
80101cec:	83 c4 10             	add    $0x10,%esp
80101cef:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cf2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cf8:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101cfe:	8b 45 08             	mov    0x8(%ebp),%eax
80101d01:	8b 00                	mov    (%eax),%eax
80101d03:	83 ec 08             	sub    $0x8,%esp
80101d06:	ff 75 f4             	push   -0xc(%ebp)
80101d09:	50                   	push   %eax
80101d0a:	e8 c0 e4 ff ff       	call   801001cf <bread>
80101d0f:	83 c4 10             	add    $0x10,%esp
80101d12:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d18:	83 c0 5c             	add    $0x5c,%eax
80101d1b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101d1e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d21:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d28:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d2b:	01 d0                	add    %edx,%eax
80101d2d:	8b 00                	mov    (%eax),%eax
80101d2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d32:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d36:	75 36                	jne    80101d6e <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
80101d38:	8b 45 08             	mov    0x8(%ebp),%eax
80101d3b:	8b 00                	mov    (%eax),%eax
80101d3d:	83 ec 0c             	sub    $0xc,%esp
80101d40:	50                   	push   %eax
80101d41:	e8 61 f7 ff ff       	call   801014a7 <balloc>
80101d46:	83 c4 10             	add    $0x10,%esp
80101d49:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d4c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d4f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d56:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d59:	01 c2                	add    %eax,%edx
80101d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d5e:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d60:	83 ec 0c             	sub    $0xc,%esp
80101d63:	ff 75 f0             	push   -0x10(%ebp)
80101d66:	e8 00 1a 00 00       	call   8010376b <log_write>
80101d6b:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d6e:	83 ec 0c             	sub    $0xc,%esp
80101d71:	ff 75 f0             	push   -0x10(%ebp)
80101d74:	e8 d8 e4 ff ff       	call   80100251 <brelse>
80101d79:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d7f:	eb 0d                	jmp    80101d8e <bmap+0x11e>
  }

  panic("bmap: out of range");
80101d81:	83 ec 0c             	sub    $0xc,%esp
80101d84:	68 4e 88 10 80       	push   $0x8010884e
80101d89:	e8 27 e8 ff ff       	call   801005b5 <panic>
}
80101d8e:	c9                   	leave  
80101d8f:	c3                   	ret    

80101d90 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d90:	55                   	push   %ebp
80101d91:	89 e5                	mov    %esp,%ebp
80101d93:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d96:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d9d:	eb 45                	jmp    80101de4 <itrunc+0x54>
    if(ip->addrs[i]){
80101d9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101da2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101da5:	83 c2 14             	add    $0x14,%edx
80101da8:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101dac:	85 c0                	test   %eax,%eax
80101dae:	74 30                	je     80101de0 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101db0:	8b 45 08             	mov    0x8(%ebp),%eax
80101db3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101db6:	83 c2 14             	add    $0x14,%edx
80101db9:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101dbd:	8b 55 08             	mov    0x8(%ebp),%edx
80101dc0:	8b 12                	mov    (%edx),%edx
80101dc2:	83 ec 08             	sub    $0x8,%esp
80101dc5:	50                   	push   %eax
80101dc6:	52                   	push   %edx
80101dc7:	e8 1f f8 ff ff       	call   801015eb <bfree>
80101dcc:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101dcf:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dd5:	83 c2 14             	add    $0x14,%edx
80101dd8:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101ddf:	00 
  for(i = 0; i < NDIRECT; i++){
80101de0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101de4:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101de8:	7e b5                	jle    80101d9f <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101dea:	8b 45 08             	mov    0x8(%ebp),%eax
80101ded:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101df3:	85 c0                	test   %eax,%eax
80101df5:	0f 84 aa 00 00 00    	je     80101ea5 <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dfb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dfe:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101e04:	8b 45 08             	mov    0x8(%ebp),%eax
80101e07:	8b 00                	mov    (%eax),%eax
80101e09:	83 ec 08             	sub    $0x8,%esp
80101e0c:	52                   	push   %edx
80101e0d:	50                   	push   %eax
80101e0e:	e8 bc e3 ff ff       	call   801001cf <bread>
80101e13:	83 c4 10             	add    $0x10,%esp
80101e16:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101e19:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e1c:	83 c0 5c             	add    $0x5c,%eax
80101e1f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101e22:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e29:	eb 3c                	jmp    80101e67 <itrunc+0xd7>
      if(a[j])
80101e2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e2e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e35:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e38:	01 d0                	add    %edx,%eax
80101e3a:	8b 00                	mov    (%eax),%eax
80101e3c:	85 c0                	test   %eax,%eax
80101e3e:	74 23                	je     80101e63 <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101e40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e43:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e4a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e4d:	01 d0                	add    %edx,%eax
80101e4f:	8b 00                	mov    (%eax),%eax
80101e51:	8b 55 08             	mov    0x8(%ebp),%edx
80101e54:	8b 12                	mov    (%edx),%edx
80101e56:	83 ec 08             	sub    $0x8,%esp
80101e59:	50                   	push   %eax
80101e5a:	52                   	push   %edx
80101e5b:	e8 8b f7 ff ff       	call   801015eb <bfree>
80101e60:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e63:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e6a:	83 f8 7f             	cmp    $0x7f,%eax
80101e6d:	76 bc                	jbe    80101e2b <itrunc+0x9b>
    }
    brelse(bp);
80101e6f:	83 ec 0c             	sub    $0xc,%esp
80101e72:	ff 75 ec             	push   -0x14(%ebp)
80101e75:	e8 d7 e3 ff ff       	call   80100251 <brelse>
80101e7a:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e80:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e86:	8b 55 08             	mov    0x8(%ebp),%edx
80101e89:	8b 12                	mov    (%edx),%edx
80101e8b:	83 ec 08             	sub    $0x8,%esp
80101e8e:	50                   	push   %eax
80101e8f:	52                   	push   %edx
80101e90:	e8 56 f7 ff ff       	call   801015eb <bfree>
80101e95:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e98:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9b:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101ea2:	00 00 00 
  }

  ip->size = 0;
80101ea5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea8:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101eaf:	83 ec 0c             	sub    $0xc,%esp
80101eb2:	ff 75 08             	push   0x8(%ebp)
80101eb5:	e8 83 f9 ff ff       	call   8010183d <iupdate>
80101eba:	83 c4 10             	add    $0x10,%esp
}
80101ebd:	90                   	nop
80101ebe:	c9                   	leave  
80101ebf:	c3                   	ret    

80101ec0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101ec0:	55                   	push   %ebp
80101ec1:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101ec3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec6:	8b 00                	mov    (%eax),%eax
80101ec8:	89 c2                	mov    %eax,%edx
80101eca:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ecd:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ed0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed3:	8b 50 04             	mov    0x4(%eax),%edx
80101ed6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed9:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101edc:	8b 45 08             	mov    0x8(%ebp),%eax
80101edf:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101ee3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ee6:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101ee9:	8b 45 08             	mov    0x8(%ebp),%eax
80101eec:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101ef0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ef3:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ef7:	8b 45 08             	mov    0x8(%ebp),%eax
80101efa:	8b 50 58             	mov    0x58(%eax),%edx
80101efd:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f00:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f03:	90                   	nop
80101f04:	5d                   	pop    %ebp
80101f05:	c3                   	ret    

80101f06 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101f06:	55                   	push   %ebp
80101f07:	89 e5                	mov    %esp,%ebp
80101f09:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101f13:	66 83 f8 03          	cmp    $0x3,%ax
80101f17:	75 5c                	jne    80101f75 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101f19:	8b 45 08             	mov    0x8(%ebp),%eax
80101f1c:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f20:	66 85 c0             	test   %ax,%ax
80101f23:	78 20                	js     80101f45 <readi+0x3f>
80101f25:	8b 45 08             	mov    0x8(%ebp),%eax
80101f28:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f2c:	66 83 f8 09          	cmp    $0x9,%ax
80101f30:	7f 13                	jg     80101f45 <readi+0x3f>
80101f32:	8b 45 08             	mov    0x8(%ebp),%eax
80101f35:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f39:	98                   	cwtl   
80101f3a:	8b 04 c5 c0 ff 10 80 	mov    -0x7fef0040(,%eax,8),%eax
80101f41:	85 c0                	test   %eax,%eax
80101f43:	75 0a                	jne    80101f4f <readi+0x49>
      return -1;
80101f45:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f4a:	e9 0a 01 00 00       	jmp    80102059 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f52:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f56:	98                   	cwtl   
80101f57:	8b 04 c5 c0 ff 10 80 	mov    -0x7fef0040(,%eax,8),%eax
80101f5e:	8b 55 14             	mov    0x14(%ebp),%edx
80101f61:	83 ec 04             	sub    $0x4,%esp
80101f64:	52                   	push   %edx
80101f65:	ff 75 0c             	push   0xc(%ebp)
80101f68:	ff 75 08             	push   0x8(%ebp)
80101f6b:	ff d0                	call   *%eax
80101f6d:	83 c4 10             	add    $0x10,%esp
80101f70:	e9 e4 00 00 00       	jmp    80102059 <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f75:	8b 45 08             	mov    0x8(%ebp),%eax
80101f78:	8b 40 58             	mov    0x58(%eax),%eax
80101f7b:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f7e:	77 0d                	ja     80101f8d <readi+0x87>
80101f80:	8b 55 10             	mov    0x10(%ebp),%edx
80101f83:	8b 45 14             	mov    0x14(%ebp),%eax
80101f86:	01 d0                	add    %edx,%eax
80101f88:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f8b:	76 0a                	jbe    80101f97 <readi+0x91>
    return -1;
80101f8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f92:	e9 c2 00 00 00       	jmp    80102059 <readi+0x153>
  if(off + n > ip->size)
80101f97:	8b 55 10             	mov    0x10(%ebp),%edx
80101f9a:	8b 45 14             	mov    0x14(%ebp),%eax
80101f9d:	01 c2                	add    %eax,%edx
80101f9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa2:	8b 40 58             	mov    0x58(%eax),%eax
80101fa5:	39 c2                	cmp    %eax,%edx
80101fa7:	76 0c                	jbe    80101fb5 <readi+0xaf>
    n = ip->size - off;
80101fa9:	8b 45 08             	mov    0x8(%ebp),%eax
80101fac:	8b 40 58             	mov    0x58(%eax),%eax
80101faf:	2b 45 10             	sub    0x10(%ebp),%eax
80101fb2:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101fb5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101fbc:	e9 89 00 00 00       	jmp    8010204a <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101fc1:	8b 45 10             	mov    0x10(%ebp),%eax
80101fc4:	c1 e8 09             	shr    $0x9,%eax
80101fc7:	83 ec 08             	sub    $0x8,%esp
80101fca:	50                   	push   %eax
80101fcb:	ff 75 08             	push   0x8(%ebp)
80101fce:	e8 9d fc ff ff       	call   80101c70 <bmap>
80101fd3:	83 c4 10             	add    $0x10,%esp
80101fd6:	8b 55 08             	mov    0x8(%ebp),%edx
80101fd9:	8b 12                	mov    (%edx),%edx
80101fdb:	83 ec 08             	sub    $0x8,%esp
80101fde:	50                   	push   %eax
80101fdf:	52                   	push   %edx
80101fe0:	e8 ea e1 ff ff       	call   801001cf <bread>
80101fe5:	83 c4 10             	add    $0x10,%esp
80101fe8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101feb:	8b 45 10             	mov    0x10(%ebp),%eax
80101fee:	25 ff 01 00 00       	and    $0x1ff,%eax
80101ff3:	ba 00 02 00 00       	mov    $0x200,%edx
80101ff8:	29 c2                	sub    %eax,%edx
80101ffa:	8b 45 14             	mov    0x14(%ebp),%eax
80101ffd:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102000:	39 c2                	cmp    %eax,%edx
80102002:	0f 46 c2             	cmovbe %edx,%eax
80102005:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102008:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010200b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010200e:	8b 45 10             	mov    0x10(%ebp),%eax
80102011:	25 ff 01 00 00       	and    $0x1ff,%eax
80102016:	01 d0                	add    %edx,%eax
80102018:	83 ec 04             	sub    $0x4,%esp
8010201b:	ff 75 ec             	push   -0x14(%ebp)
8010201e:	50                   	push   %eax
8010201f:	ff 75 0c             	push   0xc(%ebp)
80102022:	e8 b3 35 00 00       	call   801055da <memmove>
80102027:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010202a:	83 ec 0c             	sub    $0xc,%esp
8010202d:	ff 75 f0             	push   -0x10(%ebp)
80102030:	e8 1c e2 ff ff       	call   80100251 <brelse>
80102035:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102038:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010203b:	01 45 f4             	add    %eax,-0xc(%ebp)
8010203e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102041:	01 45 10             	add    %eax,0x10(%ebp)
80102044:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102047:	01 45 0c             	add    %eax,0xc(%ebp)
8010204a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010204d:	3b 45 14             	cmp    0x14(%ebp),%eax
80102050:	0f 82 6b ff ff ff    	jb     80101fc1 <readi+0xbb>
  }
  return n;
80102056:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102059:	c9                   	leave  
8010205a:	c3                   	ret    

8010205b <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010205b:	55                   	push   %ebp
8010205c:	89 e5                	mov    %esp,%ebp
8010205e:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102061:	8b 45 08             	mov    0x8(%ebp),%eax
80102064:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102068:	66 83 f8 03          	cmp    $0x3,%ax
8010206c:	75 5c                	jne    801020ca <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010206e:	8b 45 08             	mov    0x8(%ebp),%eax
80102071:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102075:	66 85 c0             	test   %ax,%ax
80102078:	78 20                	js     8010209a <writei+0x3f>
8010207a:	8b 45 08             	mov    0x8(%ebp),%eax
8010207d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102081:	66 83 f8 09          	cmp    $0x9,%ax
80102085:	7f 13                	jg     8010209a <writei+0x3f>
80102087:	8b 45 08             	mov    0x8(%ebp),%eax
8010208a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010208e:	98                   	cwtl   
8010208f:	8b 04 c5 c4 ff 10 80 	mov    -0x7fef003c(,%eax,8),%eax
80102096:	85 c0                	test   %eax,%eax
80102098:	75 0a                	jne    801020a4 <writei+0x49>
      return -1;
8010209a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010209f:	e9 3b 01 00 00       	jmp    801021df <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
801020a4:	8b 45 08             	mov    0x8(%ebp),%eax
801020a7:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020ab:	98                   	cwtl   
801020ac:	8b 04 c5 c4 ff 10 80 	mov    -0x7fef003c(,%eax,8),%eax
801020b3:	8b 55 14             	mov    0x14(%ebp),%edx
801020b6:	83 ec 04             	sub    $0x4,%esp
801020b9:	52                   	push   %edx
801020ba:	ff 75 0c             	push   0xc(%ebp)
801020bd:	ff 75 08             	push   0x8(%ebp)
801020c0:	ff d0                	call   *%eax
801020c2:	83 c4 10             	add    $0x10,%esp
801020c5:	e9 15 01 00 00       	jmp    801021df <writei+0x184>
  }

  if(off > ip->size || off + n < off)
801020ca:	8b 45 08             	mov    0x8(%ebp),%eax
801020cd:	8b 40 58             	mov    0x58(%eax),%eax
801020d0:	39 45 10             	cmp    %eax,0x10(%ebp)
801020d3:	77 0d                	ja     801020e2 <writei+0x87>
801020d5:	8b 55 10             	mov    0x10(%ebp),%edx
801020d8:	8b 45 14             	mov    0x14(%ebp),%eax
801020db:	01 d0                	add    %edx,%eax
801020dd:	39 45 10             	cmp    %eax,0x10(%ebp)
801020e0:	76 0a                	jbe    801020ec <writei+0x91>
    return -1;
801020e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020e7:	e9 f3 00 00 00       	jmp    801021df <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020ec:	8b 55 10             	mov    0x10(%ebp),%edx
801020ef:	8b 45 14             	mov    0x14(%ebp),%eax
801020f2:	01 d0                	add    %edx,%eax
801020f4:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020f9:	76 0a                	jbe    80102105 <writei+0xaa>
    return -1;
801020fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102100:	e9 da 00 00 00       	jmp    801021df <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102105:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010210c:	e9 97 00 00 00       	jmp    801021a8 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102111:	8b 45 10             	mov    0x10(%ebp),%eax
80102114:	c1 e8 09             	shr    $0x9,%eax
80102117:	83 ec 08             	sub    $0x8,%esp
8010211a:	50                   	push   %eax
8010211b:	ff 75 08             	push   0x8(%ebp)
8010211e:	e8 4d fb ff ff       	call   80101c70 <bmap>
80102123:	83 c4 10             	add    $0x10,%esp
80102126:	8b 55 08             	mov    0x8(%ebp),%edx
80102129:	8b 12                	mov    (%edx),%edx
8010212b:	83 ec 08             	sub    $0x8,%esp
8010212e:	50                   	push   %eax
8010212f:	52                   	push   %edx
80102130:	e8 9a e0 ff ff       	call   801001cf <bread>
80102135:	83 c4 10             	add    $0x10,%esp
80102138:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010213b:	8b 45 10             	mov    0x10(%ebp),%eax
8010213e:	25 ff 01 00 00       	and    $0x1ff,%eax
80102143:	ba 00 02 00 00       	mov    $0x200,%edx
80102148:	29 c2                	sub    %eax,%edx
8010214a:	8b 45 14             	mov    0x14(%ebp),%eax
8010214d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102150:	39 c2                	cmp    %eax,%edx
80102152:	0f 46 c2             	cmovbe %edx,%eax
80102155:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102158:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010215b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010215e:	8b 45 10             	mov    0x10(%ebp),%eax
80102161:	25 ff 01 00 00       	and    $0x1ff,%eax
80102166:	01 d0                	add    %edx,%eax
80102168:	83 ec 04             	sub    $0x4,%esp
8010216b:	ff 75 ec             	push   -0x14(%ebp)
8010216e:	ff 75 0c             	push   0xc(%ebp)
80102171:	50                   	push   %eax
80102172:	e8 63 34 00 00       	call   801055da <memmove>
80102177:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010217a:	83 ec 0c             	sub    $0xc,%esp
8010217d:	ff 75 f0             	push   -0x10(%ebp)
80102180:	e8 e6 15 00 00       	call   8010376b <log_write>
80102185:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102188:	83 ec 0c             	sub    $0xc,%esp
8010218b:	ff 75 f0             	push   -0x10(%ebp)
8010218e:	e8 be e0 ff ff       	call   80100251 <brelse>
80102193:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102196:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102199:	01 45 f4             	add    %eax,-0xc(%ebp)
8010219c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010219f:	01 45 10             	add    %eax,0x10(%ebp)
801021a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021a5:	01 45 0c             	add    %eax,0xc(%ebp)
801021a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021ab:	3b 45 14             	cmp    0x14(%ebp),%eax
801021ae:	0f 82 5d ff ff ff    	jb     80102111 <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
801021b4:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801021b8:	74 22                	je     801021dc <writei+0x181>
801021ba:	8b 45 08             	mov    0x8(%ebp),%eax
801021bd:	8b 40 58             	mov    0x58(%eax),%eax
801021c0:	39 45 10             	cmp    %eax,0x10(%ebp)
801021c3:	76 17                	jbe    801021dc <writei+0x181>
    ip->size = off;
801021c5:	8b 45 08             	mov    0x8(%ebp),%eax
801021c8:	8b 55 10             	mov    0x10(%ebp),%edx
801021cb:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
801021ce:	83 ec 0c             	sub    $0xc,%esp
801021d1:	ff 75 08             	push   0x8(%ebp)
801021d4:	e8 64 f6 ff ff       	call   8010183d <iupdate>
801021d9:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021dc:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021df:	c9                   	leave  
801021e0:	c3                   	ret    

801021e1 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021e1:	55                   	push   %ebp
801021e2:	89 e5                	mov    %esp,%ebp
801021e4:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021e7:	83 ec 04             	sub    $0x4,%esp
801021ea:	6a 0e                	push   $0xe
801021ec:	ff 75 0c             	push   0xc(%ebp)
801021ef:	ff 75 08             	push   0x8(%ebp)
801021f2:	e8 79 34 00 00       	call   80105670 <strncmp>
801021f7:	83 c4 10             	add    $0x10,%esp
}
801021fa:	c9                   	leave  
801021fb:	c3                   	ret    

801021fc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021fc:	55                   	push   %ebp
801021fd:	89 e5                	mov    %esp,%ebp
801021ff:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102202:	8b 45 08             	mov    0x8(%ebp),%eax
80102205:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102209:	66 83 f8 01          	cmp    $0x1,%ax
8010220d:	74 0d                	je     8010221c <dirlookup+0x20>
    panic("dirlookup not DIR");
8010220f:	83 ec 0c             	sub    $0xc,%esp
80102212:	68 61 88 10 80       	push   $0x80108861
80102217:	e8 99 e3 ff ff       	call   801005b5 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
8010221c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102223:	eb 7b                	jmp    801022a0 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102225:	6a 10                	push   $0x10
80102227:	ff 75 f4             	push   -0xc(%ebp)
8010222a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010222d:	50                   	push   %eax
8010222e:	ff 75 08             	push   0x8(%ebp)
80102231:	e8 d0 fc ff ff       	call   80101f06 <readi>
80102236:	83 c4 10             	add    $0x10,%esp
80102239:	83 f8 10             	cmp    $0x10,%eax
8010223c:	74 0d                	je     8010224b <dirlookup+0x4f>
      panic("dirlookup read");
8010223e:	83 ec 0c             	sub    $0xc,%esp
80102241:	68 73 88 10 80       	push   $0x80108873
80102246:	e8 6a e3 ff ff       	call   801005b5 <panic>
    if(de.inum == 0)
8010224b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010224f:	66 85 c0             	test   %ax,%ax
80102252:	74 47                	je     8010229b <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102254:	83 ec 08             	sub    $0x8,%esp
80102257:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010225a:	83 c0 02             	add    $0x2,%eax
8010225d:	50                   	push   %eax
8010225e:	ff 75 0c             	push   0xc(%ebp)
80102261:	e8 7b ff ff ff       	call   801021e1 <namecmp>
80102266:	83 c4 10             	add    $0x10,%esp
80102269:	85 c0                	test   %eax,%eax
8010226b:	75 2f                	jne    8010229c <dirlookup+0xa0>
      // entry matches path element
      if(poff)
8010226d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102271:	74 08                	je     8010227b <dirlookup+0x7f>
        *poff = off;
80102273:	8b 45 10             	mov    0x10(%ebp),%eax
80102276:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102279:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010227b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010227f:	0f b7 c0             	movzwl %ax,%eax
80102282:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102285:	8b 45 08             	mov    0x8(%ebp),%eax
80102288:	8b 00                	mov    (%eax),%eax
8010228a:	83 ec 08             	sub    $0x8,%esp
8010228d:	ff 75 f0             	push   -0x10(%ebp)
80102290:	50                   	push   %eax
80102291:	e8 68 f6 ff ff       	call   801018fe <iget>
80102296:	83 c4 10             	add    $0x10,%esp
80102299:	eb 19                	jmp    801022b4 <dirlookup+0xb8>
      continue;
8010229b:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
8010229c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801022a0:	8b 45 08             	mov    0x8(%ebp),%eax
801022a3:	8b 40 58             	mov    0x58(%eax),%eax
801022a6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801022a9:	0f 82 76 ff ff ff    	jb     80102225 <dirlookup+0x29>
    }
  }

  return 0;
801022af:	b8 00 00 00 00       	mov    $0x0,%eax
}
801022b4:	c9                   	leave  
801022b5:	c3                   	ret    

801022b6 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801022b6:	55                   	push   %ebp
801022b7:	89 e5                	mov    %esp,%ebp
801022b9:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801022bc:	83 ec 04             	sub    $0x4,%esp
801022bf:	6a 00                	push   $0x0
801022c1:	ff 75 0c             	push   0xc(%ebp)
801022c4:	ff 75 08             	push   0x8(%ebp)
801022c7:	e8 30 ff ff ff       	call   801021fc <dirlookup>
801022cc:	83 c4 10             	add    $0x10,%esp
801022cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022d2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022d6:	74 18                	je     801022f0 <dirlink+0x3a>
    iput(ip);
801022d8:	83 ec 0c             	sub    $0xc,%esp
801022db:	ff 75 f0             	push   -0x10(%ebp)
801022de:	e8 98 f8 ff ff       	call   80101b7b <iput>
801022e3:	83 c4 10             	add    $0x10,%esp
    return -1;
801022e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022eb:	e9 9c 00 00 00       	jmp    8010238c <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022f7:	eb 39                	jmp    80102332 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022fc:	6a 10                	push   $0x10
801022fe:	50                   	push   %eax
801022ff:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102302:	50                   	push   %eax
80102303:	ff 75 08             	push   0x8(%ebp)
80102306:	e8 fb fb ff ff       	call   80101f06 <readi>
8010230b:	83 c4 10             	add    $0x10,%esp
8010230e:	83 f8 10             	cmp    $0x10,%eax
80102311:	74 0d                	je     80102320 <dirlink+0x6a>
      panic("dirlink read");
80102313:	83 ec 0c             	sub    $0xc,%esp
80102316:	68 82 88 10 80       	push   $0x80108882
8010231b:	e8 95 e2 ff ff       	call   801005b5 <panic>
    if(de.inum == 0)
80102320:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102324:	66 85 c0             	test   %ax,%ax
80102327:	74 18                	je     80102341 <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
80102329:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010232c:	83 c0 10             	add    $0x10,%eax
8010232f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102332:	8b 45 08             	mov    0x8(%ebp),%eax
80102335:	8b 50 58             	mov    0x58(%eax),%edx
80102338:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010233b:	39 c2                	cmp    %eax,%edx
8010233d:	77 ba                	ja     801022f9 <dirlink+0x43>
8010233f:	eb 01                	jmp    80102342 <dirlink+0x8c>
      break;
80102341:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102342:	83 ec 04             	sub    $0x4,%esp
80102345:	6a 0e                	push   $0xe
80102347:	ff 75 0c             	push   0xc(%ebp)
8010234a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010234d:	83 c0 02             	add    $0x2,%eax
80102350:	50                   	push   %eax
80102351:	e8 70 33 00 00       	call   801056c6 <strncpy>
80102356:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102359:	8b 45 10             	mov    0x10(%ebp),%eax
8010235c:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102360:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102363:	6a 10                	push   $0x10
80102365:	50                   	push   %eax
80102366:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102369:	50                   	push   %eax
8010236a:	ff 75 08             	push   0x8(%ebp)
8010236d:	e8 e9 fc ff ff       	call   8010205b <writei>
80102372:	83 c4 10             	add    $0x10,%esp
80102375:	83 f8 10             	cmp    $0x10,%eax
80102378:	74 0d                	je     80102387 <dirlink+0xd1>
    panic("dirlink");
8010237a:	83 ec 0c             	sub    $0xc,%esp
8010237d:	68 8f 88 10 80       	push   $0x8010888f
80102382:	e8 2e e2 ff ff       	call   801005b5 <panic>

  return 0;
80102387:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010238c:	c9                   	leave  
8010238d:	c3                   	ret    

8010238e <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010238e:	55                   	push   %ebp
8010238f:	89 e5                	mov    %esp,%ebp
80102391:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102394:	eb 04                	jmp    8010239a <skipelem+0xc>
    path++;
80102396:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010239a:	8b 45 08             	mov    0x8(%ebp),%eax
8010239d:	0f b6 00             	movzbl (%eax),%eax
801023a0:	3c 2f                	cmp    $0x2f,%al
801023a2:	74 f2                	je     80102396 <skipelem+0x8>
  if(*path == 0)
801023a4:	8b 45 08             	mov    0x8(%ebp),%eax
801023a7:	0f b6 00             	movzbl (%eax),%eax
801023aa:	84 c0                	test   %al,%al
801023ac:	75 07                	jne    801023b5 <skipelem+0x27>
    return 0;
801023ae:	b8 00 00 00 00       	mov    $0x0,%eax
801023b3:	eb 77                	jmp    8010242c <skipelem+0x9e>
  s = path;
801023b5:	8b 45 08             	mov    0x8(%ebp),%eax
801023b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801023bb:	eb 04                	jmp    801023c1 <skipelem+0x33>
    path++;
801023bd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
801023c1:	8b 45 08             	mov    0x8(%ebp),%eax
801023c4:	0f b6 00             	movzbl (%eax),%eax
801023c7:	3c 2f                	cmp    $0x2f,%al
801023c9:	74 0a                	je     801023d5 <skipelem+0x47>
801023cb:	8b 45 08             	mov    0x8(%ebp),%eax
801023ce:	0f b6 00             	movzbl (%eax),%eax
801023d1:	84 c0                	test   %al,%al
801023d3:	75 e8                	jne    801023bd <skipelem+0x2f>
  len = path - s;
801023d5:	8b 45 08             	mov    0x8(%ebp),%eax
801023d8:	2b 45 f4             	sub    -0xc(%ebp),%eax
801023db:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023de:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023e2:	7e 15                	jle    801023f9 <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023e4:	83 ec 04             	sub    $0x4,%esp
801023e7:	6a 0e                	push   $0xe
801023e9:	ff 75 f4             	push   -0xc(%ebp)
801023ec:	ff 75 0c             	push   0xc(%ebp)
801023ef:	e8 e6 31 00 00       	call   801055da <memmove>
801023f4:	83 c4 10             	add    $0x10,%esp
801023f7:	eb 26                	jmp    8010241f <skipelem+0x91>
  else {
    memmove(name, s, len);
801023f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023fc:	83 ec 04             	sub    $0x4,%esp
801023ff:	50                   	push   %eax
80102400:	ff 75 f4             	push   -0xc(%ebp)
80102403:	ff 75 0c             	push   0xc(%ebp)
80102406:	e8 cf 31 00 00       	call   801055da <memmove>
8010240b:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
8010240e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102411:	8b 45 0c             	mov    0xc(%ebp),%eax
80102414:	01 d0                	add    %edx,%eax
80102416:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102419:	eb 04                	jmp    8010241f <skipelem+0x91>
    path++;
8010241b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010241f:	8b 45 08             	mov    0x8(%ebp),%eax
80102422:	0f b6 00             	movzbl (%eax),%eax
80102425:	3c 2f                	cmp    $0x2f,%al
80102427:	74 f2                	je     8010241b <skipelem+0x8d>
  return path;
80102429:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010242c:	c9                   	leave  
8010242d:	c3                   	ret    

8010242e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010242e:	55                   	push   %ebp
8010242f:	89 e5                	mov    %esp,%ebp
80102431:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102434:	8b 45 08             	mov    0x8(%ebp),%eax
80102437:	0f b6 00             	movzbl (%eax),%eax
8010243a:	3c 2f                	cmp    $0x2f,%al
8010243c:	75 17                	jne    80102455 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
8010243e:	83 ec 08             	sub    $0x8,%esp
80102441:	6a 01                	push   $0x1
80102443:	6a 01                	push   $0x1
80102445:	e8 b4 f4 ff ff       	call   801018fe <iget>
8010244a:	83 c4 10             	add    $0x10,%esp
8010244d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102450:	e9 ba 00 00 00       	jmp    8010250f <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
80102455:	e8 80 1e 00 00       	call   801042da <myproc>
8010245a:	8b 40 68             	mov    0x68(%eax),%eax
8010245d:	83 ec 0c             	sub    $0xc,%esp
80102460:	50                   	push   %eax
80102461:	e8 7a f5 ff ff       	call   801019e0 <idup>
80102466:	83 c4 10             	add    $0x10,%esp
80102469:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010246c:	e9 9e 00 00 00       	jmp    8010250f <namex+0xe1>
    ilock(ip);
80102471:	83 ec 0c             	sub    $0xc,%esp
80102474:	ff 75 f4             	push   -0xc(%ebp)
80102477:	e8 9e f5 ff ff       	call   80101a1a <ilock>
8010247c:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010247f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102482:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102486:	66 83 f8 01          	cmp    $0x1,%ax
8010248a:	74 18                	je     801024a4 <namex+0x76>
      iunlockput(ip);
8010248c:	83 ec 0c             	sub    $0xc,%esp
8010248f:	ff 75 f4             	push   -0xc(%ebp)
80102492:	e8 b4 f7 ff ff       	call   80101c4b <iunlockput>
80102497:	83 c4 10             	add    $0x10,%esp
      return 0;
8010249a:	b8 00 00 00 00       	mov    $0x0,%eax
8010249f:	e9 a7 00 00 00       	jmp    8010254b <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
801024a4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801024a8:	74 20                	je     801024ca <namex+0x9c>
801024aa:	8b 45 08             	mov    0x8(%ebp),%eax
801024ad:	0f b6 00             	movzbl (%eax),%eax
801024b0:	84 c0                	test   %al,%al
801024b2:	75 16                	jne    801024ca <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
801024b4:	83 ec 0c             	sub    $0xc,%esp
801024b7:	ff 75 f4             	push   -0xc(%ebp)
801024ba:	e8 6e f6 ff ff       	call   80101b2d <iunlock>
801024bf:	83 c4 10             	add    $0x10,%esp
      return ip;
801024c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024c5:	e9 81 00 00 00       	jmp    8010254b <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801024ca:	83 ec 04             	sub    $0x4,%esp
801024cd:	6a 00                	push   $0x0
801024cf:	ff 75 10             	push   0x10(%ebp)
801024d2:	ff 75 f4             	push   -0xc(%ebp)
801024d5:	e8 22 fd ff ff       	call   801021fc <dirlookup>
801024da:	83 c4 10             	add    $0x10,%esp
801024dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024e4:	75 15                	jne    801024fb <namex+0xcd>
      iunlockput(ip);
801024e6:	83 ec 0c             	sub    $0xc,%esp
801024e9:	ff 75 f4             	push   -0xc(%ebp)
801024ec:	e8 5a f7 ff ff       	call   80101c4b <iunlockput>
801024f1:	83 c4 10             	add    $0x10,%esp
      return 0;
801024f4:	b8 00 00 00 00       	mov    $0x0,%eax
801024f9:	eb 50                	jmp    8010254b <namex+0x11d>
    }
    iunlockput(ip);
801024fb:	83 ec 0c             	sub    $0xc,%esp
801024fe:	ff 75 f4             	push   -0xc(%ebp)
80102501:	e8 45 f7 ff ff       	call   80101c4b <iunlockput>
80102506:	83 c4 10             	add    $0x10,%esp
    ip = next;
80102509:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010250c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
8010250f:	83 ec 08             	sub    $0x8,%esp
80102512:	ff 75 10             	push   0x10(%ebp)
80102515:	ff 75 08             	push   0x8(%ebp)
80102518:	e8 71 fe ff ff       	call   8010238e <skipelem>
8010251d:	83 c4 10             	add    $0x10,%esp
80102520:	89 45 08             	mov    %eax,0x8(%ebp)
80102523:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102527:	0f 85 44 ff ff ff    	jne    80102471 <namex+0x43>
  }
  if(nameiparent){
8010252d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102531:	74 15                	je     80102548 <namex+0x11a>
    iput(ip);
80102533:	83 ec 0c             	sub    $0xc,%esp
80102536:	ff 75 f4             	push   -0xc(%ebp)
80102539:	e8 3d f6 ff ff       	call   80101b7b <iput>
8010253e:	83 c4 10             	add    $0x10,%esp
    return 0;
80102541:	b8 00 00 00 00       	mov    $0x0,%eax
80102546:	eb 03                	jmp    8010254b <namex+0x11d>
  }
  return ip;
80102548:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010254b:	c9                   	leave  
8010254c:	c3                   	ret    

8010254d <namei>:

struct inode*
namei(char *path)
{
8010254d:	55                   	push   %ebp
8010254e:	89 e5                	mov    %esp,%ebp
80102550:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102553:	83 ec 04             	sub    $0x4,%esp
80102556:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102559:	50                   	push   %eax
8010255a:	6a 00                	push   $0x0
8010255c:	ff 75 08             	push   0x8(%ebp)
8010255f:	e8 ca fe ff ff       	call   8010242e <namex>
80102564:	83 c4 10             	add    $0x10,%esp
}
80102567:	c9                   	leave  
80102568:	c3                   	ret    

80102569 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102569:	55                   	push   %ebp
8010256a:	89 e5                	mov    %esp,%ebp
8010256c:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010256f:	83 ec 04             	sub    $0x4,%esp
80102572:	ff 75 0c             	push   0xc(%ebp)
80102575:	6a 01                	push   $0x1
80102577:	ff 75 08             	push   0x8(%ebp)
8010257a:	e8 af fe ff ff       	call   8010242e <namex>
8010257f:	83 c4 10             	add    $0x10,%esp
}
80102582:	c9                   	leave  
80102583:	c3                   	ret    

80102584 <inb>:
{
80102584:	55                   	push   %ebp
80102585:	89 e5                	mov    %esp,%ebp
80102587:	83 ec 14             	sub    $0x14,%esp
8010258a:	8b 45 08             	mov    0x8(%ebp),%eax
8010258d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102591:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102595:	89 c2                	mov    %eax,%edx
80102597:	ec                   	in     (%dx),%al
80102598:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010259b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010259f:	c9                   	leave  
801025a0:	c3                   	ret    

801025a1 <insl>:
{
801025a1:	55                   	push   %ebp
801025a2:	89 e5                	mov    %esp,%ebp
801025a4:	57                   	push   %edi
801025a5:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801025a6:	8b 55 08             	mov    0x8(%ebp),%edx
801025a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025ac:	8b 45 10             	mov    0x10(%ebp),%eax
801025af:	89 cb                	mov    %ecx,%ebx
801025b1:	89 df                	mov    %ebx,%edi
801025b3:	89 c1                	mov    %eax,%ecx
801025b5:	fc                   	cld    
801025b6:	f3 6d                	rep insl (%dx),%es:(%edi)
801025b8:	89 c8                	mov    %ecx,%eax
801025ba:	89 fb                	mov    %edi,%ebx
801025bc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025bf:	89 45 10             	mov    %eax,0x10(%ebp)
}
801025c2:	90                   	nop
801025c3:	5b                   	pop    %ebx
801025c4:	5f                   	pop    %edi
801025c5:	5d                   	pop    %ebp
801025c6:	c3                   	ret    

801025c7 <outb>:
{
801025c7:	55                   	push   %ebp
801025c8:	89 e5                	mov    %esp,%ebp
801025ca:	83 ec 08             	sub    $0x8,%esp
801025cd:	8b 45 08             	mov    0x8(%ebp),%eax
801025d0:	8b 55 0c             	mov    0xc(%ebp),%edx
801025d3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801025d7:	89 d0                	mov    %edx,%eax
801025d9:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025dc:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801025e0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801025e4:	ee                   	out    %al,(%dx)
}
801025e5:	90                   	nop
801025e6:	c9                   	leave  
801025e7:	c3                   	ret    

801025e8 <outsl>:
{
801025e8:	55                   	push   %ebp
801025e9:	89 e5                	mov    %esp,%ebp
801025eb:	56                   	push   %esi
801025ec:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801025ed:	8b 55 08             	mov    0x8(%ebp),%edx
801025f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025f3:	8b 45 10             	mov    0x10(%ebp),%eax
801025f6:	89 cb                	mov    %ecx,%ebx
801025f8:	89 de                	mov    %ebx,%esi
801025fa:	89 c1                	mov    %eax,%ecx
801025fc:	fc                   	cld    
801025fd:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801025ff:	89 c8                	mov    %ecx,%eax
80102601:	89 f3                	mov    %esi,%ebx
80102603:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102606:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102609:	90                   	nop
8010260a:	5b                   	pop    %ebx
8010260b:	5e                   	pop    %esi
8010260c:	5d                   	pop    %ebp
8010260d:	c3                   	ret    

8010260e <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010260e:	55                   	push   %ebp
8010260f:	89 e5                	mov    %esp,%ebp
80102611:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102614:	90                   	nop
80102615:	68 f7 01 00 00       	push   $0x1f7
8010261a:	e8 65 ff ff ff       	call   80102584 <inb>
8010261f:	83 c4 04             	add    $0x4,%esp
80102622:	0f b6 c0             	movzbl %al,%eax
80102625:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102628:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010262b:	25 c0 00 00 00       	and    $0xc0,%eax
80102630:	83 f8 40             	cmp    $0x40,%eax
80102633:	75 e0                	jne    80102615 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102635:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102639:	74 11                	je     8010264c <idewait+0x3e>
8010263b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010263e:	83 e0 21             	and    $0x21,%eax
80102641:	85 c0                	test   %eax,%eax
80102643:	74 07                	je     8010264c <idewait+0x3e>
    return -1;
80102645:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010264a:	eb 05                	jmp    80102651 <idewait+0x43>
  return 0;
8010264c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102651:	c9                   	leave  
80102652:	c3                   	ret    

80102653 <ideinit>:

void
ideinit(void)
{
80102653:	55                   	push   %ebp
80102654:	89 e5                	mov    %esp,%ebp
80102656:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
80102659:	83 ec 08             	sub    $0x8,%esp
8010265c:	68 97 88 10 80       	push   $0x80108897
80102661:	68 40 26 11 80       	push   $0x80112640
80102666:	e8 08 2c 00 00       	call   80105273 <initlock>
8010266b:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
8010266e:	a1 40 2d 11 80       	mov    0x80112d40,%eax
80102673:	83 e8 01             	sub    $0x1,%eax
80102676:	83 ec 08             	sub    $0x8,%esp
80102679:	50                   	push   %eax
8010267a:	6a 0e                	push   $0xe
8010267c:	e8 a3 04 00 00       	call   80102b24 <ioapicenable>
80102681:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102684:	83 ec 0c             	sub    $0xc,%esp
80102687:	6a 00                	push   $0x0
80102689:	e8 80 ff ff ff       	call   8010260e <idewait>
8010268e:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102691:	83 ec 08             	sub    $0x8,%esp
80102694:	68 f0 00 00 00       	push   $0xf0
80102699:	68 f6 01 00 00       	push   $0x1f6
8010269e:	e8 24 ff ff ff       	call   801025c7 <outb>
801026a3:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
801026a6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801026ad:	eb 24                	jmp    801026d3 <ideinit+0x80>
    if(inb(0x1f7) != 0){
801026af:	83 ec 0c             	sub    $0xc,%esp
801026b2:	68 f7 01 00 00       	push   $0x1f7
801026b7:	e8 c8 fe ff ff       	call   80102584 <inb>
801026bc:	83 c4 10             	add    $0x10,%esp
801026bf:	84 c0                	test   %al,%al
801026c1:	74 0c                	je     801026cf <ideinit+0x7c>
      havedisk1 = 1;
801026c3:	c7 05 78 26 11 80 01 	movl   $0x1,0x80112678
801026ca:	00 00 00 
      break;
801026cd:	eb 0d                	jmp    801026dc <ideinit+0x89>
  for(i=0; i<1000; i++){
801026cf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801026d3:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801026da:	7e d3                	jle    801026af <ideinit+0x5c>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801026dc:	83 ec 08             	sub    $0x8,%esp
801026df:	68 e0 00 00 00       	push   $0xe0
801026e4:	68 f6 01 00 00       	push   $0x1f6
801026e9:	e8 d9 fe ff ff       	call   801025c7 <outb>
801026ee:	83 c4 10             	add    $0x10,%esp
}
801026f1:	90                   	nop
801026f2:	c9                   	leave  
801026f3:	c3                   	ret    

801026f4 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801026f4:	55                   	push   %ebp
801026f5:	89 e5                	mov    %esp,%ebp
801026f7:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801026fa:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026fe:	75 0d                	jne    8010270d <idestart+0x19>
    panic("idestart");
80102700:	83 ec 0c             	sub    $0xc,%esp
80102703:	68 9b 88 10 80       	push   $0x8010889b
80102708:	e8 a8 de ff ff       	call   801005b5 <panic>
  if(b->blockno >= FSSIZE)
8010270d:	8b 45 08             	mov    0x8(%ebp),%eax
80102710:	8b 40 08             	mov    0x8(%eax),%eax
80102713:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102718:	76 0d                	jbe    80102727 <idestart+0x33>
    panic("incorrect blockno");
8010271a:	83 ec 0c             	sub    $0xc,%esp
8010271d:	68 a4 88 10 80       	push   $0x801088a4
80102722:	e8 8e de ff ff       	call   801005b5 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102727:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
8010272e:	8b 45 08             	mov    0x8(%ebp),%eax
80102731:	8b 50 08             	mov    0x8(%eax),%edx
80102734:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102737:	0f af c2             	imul   %edx,%eax
8010273a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
8010273d:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102741:	75 07                	jne    8010274a <idestart+0x56>
80102743:	b8 20 00 00 00       	mov    $0x20,%eax
80102748:	eb 05                	jmp    8010274f <idestart+0x5b>
8010274a:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010274f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
80102752:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102756:	75 07                	jne    8010275f <idestart+0x6b>
80102758:	b8 30 00 00 00       	mov    $0x30,%eax
8010275d:	eb 05                	jmp    80102764 <idestart+0x70>
8010275f:	b8 c5 00 00 00       	mov    $0xc5,%eax
80102764:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102767:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
8010276b:	7e 0d                	jle    8010277a <idestart+0x86>
8010276d:	83 ec 0c             	sub    $0xc,%esp
80102770:	68 9b 88 10 80       	push   $0x8010889b
80102775:	e8 3b de ff ff       	call   801005b5 <panic>

  idewait(0);
8010277a:	83 ec 0c             	sub    $0xc,%esp
8010277d:	6a 00                	push   $0x0
8010277f:	e8 8a fe ff ff       	call   8010260e <idewait>
80102784:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102787:	83 ec 08             	sub    $0x8,%esp
8010278a:	6a 00                	push   $0x0
8010278c:	68 f6 03 00 00       	push   $0x3f6
80102791:	e8 31 fe ff ff       	call   801025c7 <outb>
80102796:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102799:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010279c:	0f b6 c0             	movzbl %al,%eax
8010279f:	83 ec 08             	sub    $0x8,%esp
801027a2:	50                   	push   %eax
801027a3:	68 f2 01 00 00       	push   $0x1f2
801027a8:	e8 1a fe ff ff       	call   801025c7 <outb>
801027ad:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
801027b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027b3:	0f b6 c0             	movzbl %al,%eax
801027b6:	83 ec 08             	sub    $0x8,%esp
801027b9:	50                   	push   %eax
801027ba:	68 f3 01 00 00       	push   $0x1f3
801027bf:	e8 03 fe ff ff       	call   801025c7 <outb>
801027c4:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
801027c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027ca:	c1 f8 08             	sar    $0x8,%eax
801027cd:	0f b6 c0             	movzbl %al,%eax
801027d0:	83 ec 08             	sub    $0x8,%esp
801027d3:	50                   	push   %eax
801027d4:	68 f4 01 00 00       	push   $0x1f4
801027d9:	e8 e9 fd ff ff       	call   801025c7 <outb>
801027de:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
801027e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027e4:	c1 f8 10             	sar    $0x10,%eax
801027e7:	0f b6 c0             	movzbl %al,%eax
801027ea:	83 ec 08             	sub    $0x8,%esp
801027ed:	50                   	push   %eax
801027ee:	68 f5 01 00 00       	push   $0x1f5
801027f3:	e8 cf fd ff ff       	call   801025c7 <outb>
801027f8:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801027fb:	8b 45 08             	mov    0x8(%ebp),%eax
801027fe:	8b 40 04             	mov    0x4(%eax),%eax
80102801:	c1 e0 04             	shl    $0x4,%eax
80102804:	83 e0 10             	and    $0x10,%eax
80102807:	89 c2                	mov    %eax,%edx
80102809:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010280c:	c1 f8 18             	sar    $0x18,%eax
8010280f:	83 e0 0f             	and    $0xf,%eax
80102812:	09 d0                	or     %edx,%eax
80102814:	83 c8 e0             	or     $0xffffffe0,%eax
80102817:	0f b6 c0             	movzbl %al,%eax
8010281a:	83 ec 08             	sub    $0x8,%esp
8010281d:	50                   	push   %eax
8010281e:	68 f6 01 00 00       	push   $0x1f6
80102823:	e8 9f fd ff ff       	call   801025c7 <outb>
80102828:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
8010282b:	8b 45 08             	mov    0x8(%ebp),%eax
8010282e:	8b 00                	mov    (%eax),%eax
80102830:	83 e0 04             	and    $0x4,%eax
80102833:	85 c0                	test   %eax,%eax
80102835:	74 35                	je     8010286c <idestart+0x178>
    outb(0x1f7, write_cmd);
80102837:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010283a:	0f b6 c0             	movzbl %al,%eax
8010283d:	83 ec 08             	sub    $0x8,%esp
80102840:	50                   	push   %eax
80102841:	68 f7 01 00 00       	push   $0x1f7
80102846:	e8 7c fd ff ff       	call   801025c7 <outb>
8010284b:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
8010284e:	8b 45 08             	mov    0x8(%ebp),%eax
80102851:	83 c0 5c             	add    $0x5c,%eax
80102854:	83 ec 04             	sub    $0x4,%esp
80102857:	68 80 00 00 00       	push   $0x80
8010285c:	50                   	push   %eax
8010285d:	68 f0 01 00 00       	push   $0x1f0
80102862:	e8 81 fd ff ff       	call   801025e8 <outsl>
80102867:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
8010286a:	eb 17                	jmp    80102883 <idestart+0x18f>
    outb(0x1f7, read_cmd);
8010286c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010286f:	0f b6 c0             	movzbl %al,%eax
80102872:	83 ec 08             	sub    $0x8,%esp
80102875:	50                   	push   %eax
80102876:	68 f7 01 00 00       	push   $0x1f7
8010287b:	e8 47 fd ff ff       	call   801025c7 <outb>
80102880:	83 c4 10             	add    $0x10,%esp
}
80102883:	90                   	nop
80102884:	c9                   	leave  
80102885:	c3                   	ret    

80102886 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102886:	55                   	push   %ebp
80102887:	89 e5                	mov    %esp,%ebp
80102889:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
8010288c:	83 ec 0c             	sub    $0xc,%esp
8010288f:	68 40 26 11 80       	push   $0x80112640
80102894:	e8 fc 29 00 00       	call   80105295 <acquire>
80102899:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
8010289c:	a1 74 26 11 80       	mov    0x80112674,%eax
801028a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801028a4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801028a8:	75 15                	jne    801028bf <ideintr+0x39>
    release(&idelock);
801028aa:	83 ec 0c             	sub    $0xc,%esp
801028ad:	68 40 26 11 80       	push   $0x80112640
801028b2:	e8 4c 2a 00 00       	call   80105303 <release>
801028b7:	83 c4 10             	add    $0x10,%esp
    return;
801028ba:	e9 9a 00 00 00       	jmp    80102959 <ideintr+0xd3>
  }
  idequeue = b->qnext;
801028bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c2:	8b 40 58             	mov    0x58(%eax),%eax
801028c5:	a3 74 26 11 80       	mov    %eax,0x80112674

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801028ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028cd:	8b 00                	mov    (%eax),%eax
801028cf:	83 e0 04             	and    $0x4,%eax
801028d2:	85 c0                	test   %eax,%eax
801028d4:	75 2d                	jne    80102903 <ideintr+0x7d>
801028d6:	83 ec 0c             	sub    $0xc,%esp
801028d9:	6a 01                	push   $0x1
801028db:	e8 2e fd ff ff       	call   8010260e <idewait>
801028e0:	83 c4 10             	add    $0x10,%esp
801028e3:	85 c0                	test   %eax,%eax
801028e5:	78 1c                	js     80102903 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
801028e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ea:	83 c0 5c             	add    $0x5c,%eax
801028ed:	83 ec 04             	sub    $0x4,%esp
801028f0:	68 80 00 00 00       	push   $0x80
801028f5:	50                   	push   %eax
801028f6:	68 f0 01 00 00       	push   $0x1f0
801028fb:	e8 a1 fc ff ff       	call   801025a1 <insl>
80102900:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102903:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102906:	8b 00                	mov    (%eax),%eax
80102908:	83 c8 02             	or     $0x2,%eax
8010290b:	89 c2                	mov    %eax,%edx
8010290d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102910:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102912:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102915:	8b 00                	mov    (%eax),%eax
80102917:	83 e0 fb             	and    $0xfffffffb,%eax
8010291a:	89 c2                	mov    %eax,%edx
8010291c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010291f:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102921:	83 ec 0c             	sub    $0xc,%esp
80102924:	ff 75 f4             	push   -0xc(%ebp)
80102927:	e8 ad 24 00 00       	call   80104dd9 <wakeup>
8010292c:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
8010292f:	a1 74 26 11 80       	mov    0x80112674,%eax
80102934:	85 c0                	test   %eax,%eax
80102936:	74 11                	je     80102949 <ideintr+0xc3>
    idestart(idequeue);
80102938:	a1 74 26 11 80       	mov    0x80112674,%eax
8010293d:	83 ec 0c             	sub    $0xc,%esp
80102940:	50                   	push   %eax
80102941:	e8 ae fd ff ff       	call   801026f4 <idestart>
80102946:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102949:	83 ec 0c             	sub    $0xc,%esp
8010294c:	68 40 26 11 80       	push   $0x80112640
80102951:	e8 ad 29 00 00       	call   80105303 <release>
80102956:	83 c4 10             	add    $0x10,%esp
}
80102959:	c9                   	leave  
8010295a:	c3                   	ret    

8010295b <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010295b:	55                   	push   %ebp
8010295c:	89 e5                	mov    %esp,%ebp
8010295e:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102961:	8b 45 08             	mov    0x8(%ebp),%eax
80102964:	83 c0 0c             	add    $0xc,%eax
80102967:	83 ec 0c             	sub    $0xc,%esp
8010296a:	50                   	push   %eax
8010296b:	e8 6e 28 00 00       	call   801051de <holdingsleep>
80102970:	83 c4 10             	add    $0x10,%esp
80102973:	85 c0                	test   %eax,%eax
80102975:	75 0d                	jne    80102984 <iderw+0x29>
    panic("iderw: buf not locked");
80102977:	83 ec 0c             	sub    $0xc,%esp
8010297a:	68 b6 88 10 80       	push   $0x801088b6
8010297f:	e8 31 dc ff ff       	call   801005b5 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102984:	8b 45 08             	mov    0x8(%ebp),%eax
80102987:	8b 00                	mov    (%eax),%eax
80102989:	83 e0 06             	and    $0x6,%eax
8010298c:	83 f8 02             	cmp    $0x2,%eax
8010298f:	75 0d                	jne    8010299e <iderw+0x43>
    panic("iderw: nothing to do");
80102991:	83 ec 0c             	sub    $0xc,%esp
80102994:	68 cc 88 10 80       	push   $0x801088cc
80102999:	e8 17 dc ff ff       	call   801005b5 <panic>
  if(b->dev != 0 && !havedisk1)
8010299e:	8b 45 08             	mov    0x8(%ebp),%eax
801029a1:	8b 40 04             	mov    0x4(%eax),%eax
801029a4:	85 c0                	test   %eax,%eax
801029a6:	74 16                	je     801029be <iderw+0x63>
801029a8:	a1 78 26 11 80       	mov    0x80112678,%eax
801029ad:	85 c0                	test   %eax,%eax
801029af:	75 0d                	jne    801029be <iderw+0x63>
    panic("iderw: ide disk 1 not present");
801029b1:	83 ec 0c             	sub    $0xc,%esp
801029b4:	68 e1 88 10 80       	push   $0x801088e1
801029b9:	e8 f7 db ff ff       	call   801005b5 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801029be:	83 ec 0c             	sub    $0xc,%esp
801029c1:	68 40 26 11 80       	push   $0x80112640
801029c6:	e8 ca 28 00 00       	call   80105295 <acquire>
801029cb:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
801029ce:	8b 45 08             	mov    0x8(%ebp),%eax
801029d1:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801029d8:	c7 45 f4 74 26 11 80 	movl   $0x80112674,-0xc(%ebp)
801029df:	eb 0b                	jmp    801029ec <iderw+0x91>
801029e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029e4:	8b 00                	mov    (%eax),%eax
801029e6:	83 c0 58             	add    $0x58,%eax
801029e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029ef:	8b 00                	mov    (%eax),%eax
801029f1:	85 c0                	test   %eax,%eax
801029f3:	75 ec                	jne    801029e1 <iderw+0x86>
    ;
  *pp = b;
801029f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029f8:	8b 55 08             	mov    0x8(%ebp),%edx
801029fb:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
801029fd:	a1 74 26 11 80       	mov    0x80112674,%eax
80102a02:	39 45 08             	cmp    %eax,0x8(%ebp)
80102a05:	75 23                	jne    80102a2a <iderw+0xcf>
    idestart(b);
80102a07:	83 ec 0c             	sub    $0xc,%esp
80102a0a:	ff 75 08             	push   0x8(%ebp)
80102a0d:	e8 e2 fc ff ff       	call   801026f4 <idestart>
80102a12:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a15:	eb 13                	jmp    80102a2a <iderw+0xcf>
    sleep(b, &idelock);
80102a17:	83 ec 08             	sub    $0x8,%esp
80102a1a:	68 40 26 11 80       	push   $0x80112640
80102a1f:	ff 75 08             	push   0x8(%ebp)
80102a22:	e8 b4 22 00 00       	call   80104cdb <sleep>
80102a27:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a2a:	8b 45 08             	mov    0x8(%ebp),%eax
80102a2d:	8b 00                	mov    (%eax),%eax
80102a2f:	83 e0 06             	and    $0x6,%eax
80102a32:	83 f8 02             	cmp    $0x2,%eax
80102a35:	75 e0                	jne    80102a17 <iderw+0xbc>
  }


  release(&idelock);
80102a37:	83 ec 0c             	sub    $0xc,%esp
80102a3a:	68 40 26 11 80       	push   $0x80112640
80102a3f:	e8 bf 28 00 00       	call   80105303 <release>
80102a44:	83 c4 10             	add    $0x10,%esp
}
80102a47:	90                   	nop
80102a48:	c9                   	leave  
80102a49:	c3                   	ret    

80102a4a <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102a4a:	55                   	push   %ebp
80102a4b:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a4d:	a1 7c 26 11 80       	mov    0x8011267c,%eax
80102a52:	8b 55 08             	mov    0x8(%ebp),%edx
80102a55:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102a57:	a1 7c 26 11 80       	mov    0x8011267c,%eax
80102a5c:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a5f:	5d                   	pop    %ebp
80102a60:	c3                   	ret    

80102a61 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102a61:	55                   	push   %ebp
80102a62:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a64:	a1 7c 26 11 80       	mov    0x8011267c,%eax
80102a69:	8b 55 08             	mov    0x8(%ebp),%edx
80102a6c:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102a6e:	a1 7c 26 11 80       	mov    0x8011267c,%eax
80102a73:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a76:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a79:	90                   	nop
80102a7a:	5d                   	pop    %ebp
80102a7b:	c3                   	ret    

80102a7c <ioapicinit>:

void
ioapicinit(void)
{
80102a7c:	55                   	push   %ebp
80102a7d:	89 e5                	mov    %esp,%ebp
80102a7f:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a82:	c7 05 7c 26 11 80 00 	movl   $0xfec00000,0x8011267c
80102a89:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a8c:	6a 01                	push   $0x1
80102a8e:	e8 b7 ff ff ff       	call   80102a4a <ioapicread>
80102a93:	83 c4 04             	add    $0x4,%esp
80102a96:	c1 e8 10             	shr    $0x10,%eax
80102a99:	25 ff 00 00 00       	and    $0xff,%eax
80102a9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102aa1:	6a 00                	push   $0x0
80102aa3:	e8 a2 ff ff ff       	call   80102a4a <ioapicread>
80102aa8:	83 c4 04             	add    $0x4,%esp
80102aab:	c1 e8 18             	shr    $0x18,%eax
80102aae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102ab1:	0f b6 05 44 2d 11 80 	movzbl 0x80112d44,%eax
80102ab8:	0f b6 c0             	movzbl %al,%eax
80102abb:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102abe:	74 10                	je     80102ad0 <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102ac0:	83 ec 0c             	sub    $0xc,%esp
80102ac3:	68 00 89 10 80       	push   $0x80108900
80102ac8:	e8 33 d9 ff ff       	call   80100400 <cprintf>
80102acd:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102ad0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102ad7:	eb 3f                	jmp    80102b18 <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102adc:	83 c0 20             	add    $0x20,%eax
80102adf:	0d 00 00 01 00       	or     $0x10000,%eax
80102ae4:	89 c2                	mov    %eax,%edx
80102ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae9:	83 c0 08             	add    $0x8,%eax
80102aec:	01 c0                	add    %eax,%eax
80102aee:	83 ec 08             	sub    $0x8,%esp
80102af1:	52                   	push   %edx
80102af2:	50                   	push   %eax
80102af3:	e8 69 ff ff ff       	call   80102a61 <ioapicwrite>
80102af8:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102afe:	83 c0 08             	add    $0x8,%eax
80102b01:	01 c0                	add    %eax,%eax
80102b03:	83 c0 01             	add    $0x1,%eax
80102b06:	83 ec 08             	sub    $0x8,%esp
80102b09:	6a 00                	push   $0x0
80102b0b:	50                   	push   %eax
80102b0c:	e8 50 ff ff ff       	call   80102a61 <ioapicwrite>
80102b11:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102b14:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b1b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102b1e:	7e b9                	jle    80102ad9 <ioapicinit+0x5d>
  }
}
80102b20:	90                   	nop
80102b21:	90                   	nop
80102b22:	c9                   	leave  
80102b23:	c3                   	ret    

80102b24 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102b24:	55                   	push   %ebp
80102b25:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102b27:	8b 45 08             	mov    0x8(%ebp),%eax
80102b2a:	83 c0 20             	add    $0x20,%eax
80102b2d:	89 c2                	mov    %eax,%edx
80102b2f:	8b 45 08             	mov    0x8(%ebp),%eax
80102b32:	83 c0 08             	add    $0x8,%eax
80102b35:	01 c0                	add    %eax,%eax
80102b37:	52                   	push   %edx
80102b38:	50                   	push   %eax
80102b39:	e8 23 ff ff ff       	call   80102a61 <ioapicwrite>
80102b3e:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b41:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b44:	c1 e0 18             	shl    $0x18,%eax
80102b47:	89 c2                	mov    %eax,%edx
80102b49:	8b 45 08             	mov    0x8(%ebp),%eax
80102b4c:	83 c0 08             	add    $0x8,%eax
80102b4f:	01 c0                	add    %eax,%eax
80102b51:	83 c0 01             	add    $0x1,%eax
80102b54:	52                   	push   %edx
80102b55:	50                   	push   %eax
80102b56:	e8 06 ff ff ff       	call   80102a61 <ioapicwrite>
80102b5b:	83 c4 08             	add    $0x8,%esp
}
80102b5e:	90                   	nop
80102b5f:	c9                   	leave  
80102b60:	c3                   	ret    

80102b61 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b61:	55                   	push   %ebp
80102b62:	89 e5                	mov    %esp,%ebp
80102b64:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102b67:	83 ec 08             	sub    $0x8,%esp
80102b6a:	68 32 89 10 80       	push   $0x80108932
80102b6f:	68 80 26 11 80       	push   $0x80112680
80102b74:	e8 fa 26 00 00       	call   80105273 <initlock>
80102b79:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102b7c:	c7 05 b4 26 11 80 00 	movl   $0x0,0x801126b4
80102b83:	00 00 00 
  freerange(vstart, vend);
80102b86:	83 ec 08             	sub    $0x8,%esp
80102b89:	ff 75 0c             	push   0xc(%ebp)
80102b8c:	ff 75 08             	push   0x8(%ebp)
80102b8f:	e8 2a 00 00 00       	call   80102bbe <freerange>
80102b94:	83 c4 10             	add    $0x10,%esp
}
80102b97:	90                   	nop
80102b98:	c9                   	leave  
80102b99:	c3                   	ret    

80102b9a <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102b9a:	55                   	push   %ebp
80102b9b:	89 e5                	mov    %esp,%ebp
80102b9d:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102ba0:	83 ec 08             	sub    $0x8,%esp
80102ba3:	ff 75 0c             	push   0xc(%ebp)
80102ba6:	ff 75 08             	push   0x8(%ebp)
80102ba9:	e8 10 00 00 00       	call   80102bbe <freerange>
80102bae:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102bb1:	c7 05 b4 26 11 80 01 	movl   $0x1,0x801126b4
80102bb8:	00 00 00 
}
80102bbb:	90                   	nop
80102bbc:	c9                   	leave  
80102bbd:	c3                   	ret    

80102bbe <freerange>:

void
freerange(void *vstart, void *vend)
{
80102bbe:	55                   	push   %ebp
80102bbf:	89 e5                	mov    %esp,%ebp
80102bc1:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102bc4:	8b 45 08             	mov    0x8(%ebp),%eax
80102bc7:	05 ff 0f 00 00       	add    $0xfff,%eax
80102bcc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102bd1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bd4:	eb 15                	jmp    80102beb <freerange+0x2d>
    kfree(p);
80102bd6:	83 ec 0c             	sub    $0xc,%esp
80102bd9:	ff 75 f4             	push   -0xc(%ebp)
80102bdc:	e8 1b 00 00 00       	call   80102bfc <kfree>
80102be1:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102be4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102beb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bee:	05 00 10 00 00       	add    $0x1000,%eax
80102bf3:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102bf6:	73 de                	jae    80102bd6 <freerange+0x18>
}
80102bf8:	90                   	nop
80102bf9:	90                   	nop
80102bfa:	c9                   	leave  
80102bfb:	c3                   	ret    

80102bfc <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102bfc:	55                   	push   %ebp
80102bfd:	89 e5                	mov    %esp,%ebp
80102bff:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102c02:	8b 45 08             	mov    0x8(%ebp),%eax
80102c05:	25 ff 0f 00 00       	and    $0xfff,%eax
80102c0a:	85 c0                	test   %eax,%eax
80102c0c:	75 18                	jne    80102c26 <kfree+0x2a>
80102c0e:	81 7d 08 e0 68 11 80 	cmpl   $0x801168e0,0x8(%ebp)
80102c15:	72 0f                	jb     80102c26 <kfree+0x2a>
80102c17:	8b 45 08             	mov    0x8(%ebp),%eax
80102c1a:	05 00 00 00 80       	add    $0x80000000,%eax
80102c1f:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102c24:	76 0d                	jbe    80102c33 <kfree+0x37>
    panic("kfree");
80102c26:	83 ec 0c             	sub    $0xc,%esp
80102c29:	68 37 89 10 80       	push   $0x80108937
80102c2e:	e8 82 d9 ff ff       	call   801005b5 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c33:	83 ec 04             	sub    $0x4,%esp
80102c36:	68 00 10 00 00       	push   $0x1000
80102c3b:	6a 01                	push   $0x1
80102c3d:	ff 75 08             	push   0x8(%ebp)
80102c40:	e8 d6 28 00 00       	call   8010551b <memset>
80102c45:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102c48:	a1 b4 26 11 80       	mov    0x801126b4,%eax
80102c4d:	85 c0                	test   %eax,%eax
80102c4f:	74 10                	je     80102c61 <kfree+0x65>
    acquire(&kmem.lock);
80102c51:	83 ec 0c             	sub    $0xc,%esp
80102c54:	68 80 26 11 80       	push   $0x80112680
80102c59:	e8 37 26 00 00       	call   80105295 <acquire>
80102c5e:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102c61:	8b 45 08             	mov    0x8(%ebp),%eax
80102c64:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c67:	8b 15 b8 26 11 80    	mov    0x801126b8,%edx
80102c6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c70:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c75:	a3 b8 26 11 80       	mov    %eax,0x801126b8
  if(kmem.use_lock)
80102c7a:	a1 b4 26 11 80       	mov    0x801126b4,%eax
80102c7f:	85 c0                	test   %eax,%eax
80102c81:	74 10                	je     80102c93 <kfree+0x97>
    release(&kmem.lock);
80102c83:	83 ec 0c             	sub    $0xc,%esp
80102c86:	68 80 26 11 80       	push   $0x80112680
80102c8b:	e8 73 26 00 00       	call   80105303 <release>
80102c90:	83 c4 10             	add    $0x10,%esp
}
80102c93:	90                   	nop
80102c94:	c9                   	leave  
80102c95:	c3                   	ret    

80102c96 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c96:	55                   	push   %ebp
80102c97:	89 e5                	mov    %esp,%ebp
80102c99:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102c9c:	a1 b4 26 11 80       	mov    0x801126b4,%eax
80102ca1:	85 c0                	test   %eax,%eax
80102ca3:	74 10                	je     80102cb5 <kalloc+0x1f>
    acquire(&kmem.lock);
80102ca5:	83 ec 0c             	sub    $0xc,%esp
80102ca8:	68 80 26 11 80       	push   $0x80112680
80102cad:	e8 e3 25 00 00       	call   80105295 <acquire>
80102cb2:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102cb5:	a1 b8 26 11 80       	mov    0x801126b8,%eax
80102cba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102cbd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102cc1:	74 0a                	je     80102ccd <kalloc+0x37>
    kmem.freelist = r->next;
80102cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cc6:	8b 00                	mov    (%eax),%eax
80102cc8:	a3 b8 26 11 80       	mov    %eax,0x801126b8
  if(kmem.use_lock)
80102ccd:	a1 b4 26 11 80       	mov    0x801126b4,%eax
80102cd2:	85 c0                	test   %eax,%eax
80102cd4:	74 10                	je     80102ce6 <kalloc+0x50>
    release(&kmem.lock);
80102cd6:	83 ec 0c             	sub    $0xc,%esp
80102cd9:	68 80 26 11 80       	push   $0x80112680
80102cde:	e8 20 26 00 00       	call   80105303 <release>
80102ce3:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102ce6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102ce9:	c9                   	leave  
80102cea:	c3                   	ret    

80102ceb <inb>:
{
80102ceb:	55                   	push   %ebp
80102cec:	89 e5                	mov    %esp,%ebp
80102cee:	83 ec 14             	sub    $0x14,%esp
80102cf1:	8b 45 08             	mov    0x8(%ebp),%eax
80102cf4:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cf8:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102cfc:	89 c2                	mov    %eax,%edx
80102cfe:	ec                   	in     (%dx),%al
80102cff:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d02:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d06:	c9                   	leave  
80102d07:	c3                   	ret    

80102d08 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102d08:	55                   	push   %ebp
80102d09:	89 e5                	mov    %esp,%ebp
80102d0b:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102d0e:	6a 64                	push   $0x64
80102d10:	e8 d6 ff ff ff       	call   80102ceb <inb>
80102d15:	83 c4 04             	add    $0x4,%esp
80102d18:	0f b6 c0             	movzbl %al,%eax
80102d1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d21:	83 e0 01             	and    $0x1,%eax
80102d24:	85 c0                	test   %eax,%eax
80102d26:	75 0a                	jne    80102d32 <kbdgetc+0x2a>
    return -1;
80102d28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d2d:	e9 23 01 00 00       	jmp    80102e55 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102d32:	6a 60                	push   $0x60
80102d34:	e8 b2 ff ff ff       	call   80102ceb <inb>
80102d39:	83 c4 04             	add    $0x4,%esp
80102d3c:	0f b6 c0             	movzbl %al,%eax
80102d3f:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102d42:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d49:	75 17                	jne    80102d62 <kbdgetc+0x5a>
    shift |= E0ESC;
80102d4b:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102d50:	83 c8 40             	or     $0x40,%eax
80102d53:	a3 bc 26 11 80       	mov    %eax,0x801126bc
    return 0;
80102d58:	b8 00 00 00 00       	mov    $0x0,%eax
80102d5d:	e9 f3 00 00 00       	jmp    80102e55 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102d62:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d65:	25 80 00 00 00       	and    $0x80,%eax
80102d6a:	85 c0                	test   %eax,%eax
80102d6c:	74 45                	je     80102db3 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d6e:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102d73:	83 e0 40             	and    $0x40,%eax
80102d76:	85 c0                	test   %eax,%eax
80102d78:	75 08                	jne    80102d82 <kbdgetc+0x7a>
80102d7a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d7d:	83 e0 7f             	and    $0x7f,%eax
80102d80:	eb 03                	jmp    80102d85 <kbdgetc+0x7d>
80102d82:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d85:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d88:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d8b:	05 20 90 10 80       	add    $0x80109020,%eax
80102d90:	0f b6 00             	movzbl (%eax),%eax
80102d93:	83 c8 40             	or     $0x40,%eax
80102d96:	0f b6 c0             	movzbl %al,%eax
80102d99:	f7 d0                	not    %eax
80102d9b:	89 c2                	mov    %eax,%edx
80102d9d:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102da2:	21 d0                	and    %edx,%eax
80102da4:	a3 bc 26 11 80       	mov    %eax,0x801126bc
    return 0;
80102da9:	b8 00 00 00 00       	mov    $0x0,%eax
80102dae:	e9 a2 00 00 00       	jmp    80102e55 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102db3:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102db8:	83 e0 40             	and    $0x40,%eax
80102dbb:	85 c0                	test   %eax,%eax
80102dbd:	74 14                	je     80102dd3 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102dbf:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102dc6:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102dcb:	83 e0 bf             	and    $0xffffffbf,%eax
80102dce:	a3 bc 26 11 80       	mov    %eax,0x801126bc
  }

  shift |= shiftcode[data];
80102dd3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dd6:	05 20 90 10 80       	add    $0x80109020,%eax
80102ddb:	0f b6 00             	movzbl (%eax),%eax
80102dde:	0f b6 d0             	movzbl %al,%edx
80102de1:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102de6:	09 d0                	or     %edx,%eax
80102de8:	a3 bc 26 11 80       	mov    %eax,0x801126bc
  shift ^= togglecode[data];
80102ded:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102df0:	05 20 91 10 80       	add    $0x80109120,%eax
80102df5:	0f b6 00             	movzbl (%eax),%eax
80102df8:	0f b6 d0             	movzbl %al,%edx
80102dfb:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102e00:	31 d0                	xor    %edx,%eax
80102e02:	a3 bc 26 11 80       	mov    %eax,0x801126bc
  c = charcode[shift & (CTL | SHIFT)][data];
80102e07:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102e0c:	83 e0 03             	and    $0x3,%eax
80102e0f:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102e16:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e19:	01 d0                	add    %edx,%eax
80102e1b:	0f b6 00             	movzbl (%eax),%eax
80102e1e:	0f b6 c0             	movzbl %al,%eax
80102e21:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102e24:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102e29:	83 e0 08             	and    $0x8,%eax
80102e2c:	85 c0                	test   %eax,%eax
80102e2e:	74 22                	je     80102e52 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e30:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e34:	76 0c                	jbe    80102e42 <kbdgetc+0x13a>
80102e36:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e3a:	77 06                	ja     80102e42 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102e3c:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102e40:	eb 10                	jmp    80102e52 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102e42:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102e46:	76 0a                	jbe    80102e52 <kbdgetc+0x14a>
80102e48:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e4c:	77 04                	ja     80102e52 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e4e:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e52:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e55:	c9                   	leave  
80102e56:	c3                   	ret    

80102e57 <kbdintr>:

void
kbdintr(void)
{
80102e57:	55                   	push   %ebp
80102e58:	89 e5                	mov    %esp,%ebp
80102e5a:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102e5d:	83 ec 0c             	sub    $0xc,%esp
80102e60:	68 08 2d 10 80       	push   $0x80102d08
80102e65:	e8 e5 d9 ff ff       	call   8010084f <consoleintr>
80102e6a:	83 c4 10             	add    $0x10,%esp
}
80102e6d:	90                   	nop
80102e6e:	c9                   	leave  
80102e6f:	c3                   	ret    

80102e70 <inb>:
{
80102e70:	55                   	push   %ebp
80102e71:	89 e5                	mov    %esp,%ebp
80102e73:	83 ec 14             	sub    $0x14,%esp
80102e76:	8b 45 08             	mov    0x8(%ebp),%eax
80102e79:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e7d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e81:	89 c2                	mov    %eax,%edx
80102e83:	ec                   	in     (%dx),%al
80102e84:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e87:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e8b:	c9                   	leave  
80102e8c:	c3                   	ret    

80102e8d <outb>:
{
80102e8d:	55                   	push   %ebp
80102e8e:	89 e5                	mov    %esp,%ebp
80102e90:	83 ec 08             	sub    $0x8,%esp
80102e93:	8b 45 08             	mov    0x8(%ebp),%eax
80102e96:	8b 55 0c             	mov    0xc(%ebp),%edx
80102e99:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102e9d:	89 d0                	mov    %edx,%eax
80102e9f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ea2:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102ea6:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102eaa:	ee                   	out    %al,(%dx)
}
80102eab:	90                   	nop
80102eac:	c9                   	leave  
80102ead:	c3                   	ret    

80102eae <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102eae:	55                   	push   %ebp
80102eaf:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102eb1:	8b 15 c0 26 11 80    	mov    0x801126c0,%edx
80102eb7:	8b 45 08             	mov    0x8(%ebp),%eax
80102eba:	c1 e0 02             	shl    $0x2,%eax
80102ebd:	01 c2                	add    %eax,%edx
80102ebf:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ec2:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102ec4:	a1 c0 26 11 80       	mov    0x801126c0,%eax
80102ec9:	83 c0 20             	add    $0x20,%eax
80102ecc:	8b 00                	mov    (%eax),%eax
}
80102ece:	90                   	nop
80102ecf:	5d                   	pop    %ebp
80102ed0:	c3                   	ret    

80102ed1 <lapicinit>:

void
lapicinit(void)
{
80102ed1:	55                   	push   %ebp
80102ed2:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102ed4:	a1 c0 26 11 80       	mov    0x801126c0,%eax
80102ed9:	85 c0                	test   %eax,%eax
80102edb:	0f 84 0c 01 00 00    	je     80102fed <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102ee1:	68 3f 01 00 00       	push   $0x13f
80102ee6:	6a 3c                	push   $0x3c
80102ee8:	e8 c1 ff ff ff       	call   80102eae <lapicw>
80102eed:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102ef0:	6a 0b                	push   $0xb
80102ef2:	68 f8 00 00 00       	push   $0xf8
80102ef7:	e8 b2 ff ff ff       	call   80102eae <lapicw>
80102efc:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102eff:	68 20 00 02 00       	push   $0x20020
80102f04:	68 c8 00 00 00       	push   $0xc8
80102f09:	e8 a0 ff ff ff       	call   80102eae <lapicw>
80102f0e:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102f11:	68 80 96 98 00       	push   $0x989680
80102f16:	68 e0 00 00 00       	push   $0xe0
80102f1b:	e8 8e ff ff ff       	call   80102eae <lapicw>
80102f20:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f23:	68 00 00 01 00       	push   $0x10000
80102f28:	68 d4 00 00 00       	push   $0xd4
80102f2d:	e8 7c ff ff ff       	call   80102eae <lapicw>
80102f32:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102f35:	68 00 00 01 00       	push   $0x10000
80102f3a:	68 d8 00 00 00       	push   $0xd8
80102f3f:	e8 6a ff ff ff       	call   80102eae <lapicw>
80102f44:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f47:	a1 c0 26 11 80       	mov    0x801126c0,%eax
80102f4c:	83 c0 30             	add    $0x30,%eax
80102f4f:	8b 00                	mov    (%eax),%eax
80102f51:	c1 e8 10             	shr    $0x10,%eax
80102f54:	25 fc 00 00 00       	and    $0xfc,%eax
80102f59:	85 c0                	test   %eax,%eax
80102f5b:	74 12                	je     80102f6f <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102f5d:	68 00 00 01 00       	push   $0x10000
80102f62:	68 d0 00 00 00       	push   $0xd0
80102f67:	e8 42 ff ff ff       	call   80102eae <lapicw>
80102f6c:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f6f:	6a 33                	push   $0x33
80102f71:	68 dc 00 00 00       	push   $0xdc
80102f76:	e8 33 ff ff ff       	call   80102eae <lapicw>
80102f7b:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f7e:	6a 00                	push   $0x0
80102f80:	68 a0 00 00 00       	push   $0xa0
80102f85:	e8 24 ff ff ff       	call   80102eae <lapicw>
80102f8a:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102f8d:	6a 00                	push   $0x0
80102f8f:	68 a0 00 00 00       	push   $0xa0
80102f94:	e8 15 ff ff ff       	call   80102eae <lapicw>
80102f99:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102f9c:	6a 00                	push   $0x0
80102f9e:	6a 2c                	push   $0x2c
80102fa0:	e8 09 ff ff ff       	call   80102eae <lapicw>
80102fa5:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102fa8:	6a 00                	push   $0x0
80102faa:	68 c4 00 00 00       	push   $0xc4
80102faf:	e8 fa fe ff ff       	call   80102eae <lapicw>
80102fb4:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102fb7:	68 00 85 08 00       	push   $0x88500
80102fbc:	68 c0 00 00 00       	push   $0xc0
80102fc1:	e8 e8 fe ff ff       	call   80102eae <lapicw>
80102fc6:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102fc9:	90                   	nop
80102fca:	a1 c0 26 11 80       	mov    0x801126c0,%eax
80102fcf:	05 00 03 00 00       	add    $0x300,%eax
80102fd4:	8b 00                	mov    (%eax),%eax
80102fd6:	25 00 10 00 00       	and    $0x1000,%eax
80102fdb:	85 c0                	test   %eax,%eax
80102fdd:	75 eb                	jne    80102fca <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102fdf:	6a 00                	push   $0x0
80102fe1:	6a 20                	push   $0x20
80102fe3:	e8 c6 fe ff ff       	call   80102eae <lapicw>
80102fe8:	83 c4 08             	add    $0x8,%esp
80102feb:	eb 01                	jmp    80102fee <lapicinit+0x11d>
    return;
80102fed:	90                   	nop
}
80102fee:	c9                   	leave  
80102fef:	c3                   	ret    

80102ff0 <lapicid>:

int
lapicid(void)
{
80102ff0:	55                   	push   %ebp
80102ff1:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80102ff3:	a1 c0 26 11 80       	mov    0x801126c0,%eax
80102ff8:	85 c0                	test   %eax,%eax
80102ffa:	75 07                	jne    80103003 <lapicid+0x13>
    return 0;
80102ffc:	b8 00 00 00 00       	mov    $0x0,%eax
80103001:	eb 0d                	jmp    80103010 <lapicid+0x20>
  return lapic[ID] >> 24;
80103003:	a1 c0 26 11 80       	mov    0x801126c0,%eax
80103008:	83 c0 20             	add    $0x20,%eax
8010300b:	8b 00                	mov    (%eax),%eax
8010300d:	c1 e8 18             	shr    $0x18,%eax
}
80103010:	5d                   	pop    %ebp
80103011:	c3                   	ret    

80103012 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103012:	55                   	push   %ebp
80103013:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103015:	a1 c0 26 11 80       	mov    0x801126c0,%eax
8010301a:	85 c0                	test   %eax,%eax
8010301c:	74 0c                	je     8010302a <lapiceoi+0x18>
    lapicw(EOI, 0);
8010301e:	6a 00                	push   $0x0
80103020:	6a 2c                	push   $0x2c
80103022:	e8 87 fe ff ff       	call   80102eae <lapicw>
80103027:	83 c4 08             	add    $0x8,%esp
}
8010302a:	90                   	nop
8010302b:	c9                   	leave  
8010302c:	c3                   	ret    

8010302d <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010302d:	55                   	push   %ebp
8010302e:	89 e5                	mov    %esp,%ebp
}
80103030:	90                   	nop
80103031:	5d                   	pop    %ebp
80103032:	c3                   	ret    

80103033 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103033:	55                   	push   %ebp
80103034:	89 e5                	mov    %esp,%ebp
80103036:	83 ec 14             	sub    $0x14,%esp
80103039:	8b 45 08             	mov    0x8(%ebp),%eax
8010303c:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
8010303f:	6a 0f                	push   $0xf
80103041:	6a 70                	push   $0x70
80103043:	e8 45 fe ff ff       	call   80102e8d <outb>
80103048:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
8010304b:	6a 0a                	push   $0xa
8010304d:	6a 71                	push   $0x71
8010304f:	e8 39 fe ff ff       	call   80102e8d <outb>
80103054:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103057:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010305e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103061:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103066:	8b 45 0c             	mov    0xc(%ebp),%eax
80103069:	c1 e8 04             	shr    $0x4,%eax
8010306c:	89 c2                	mov    %eax,%edx
8010306e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103071:	83 c0 02             	add    $0x2,%eax
80103074:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103077:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010307b:	c1 e0 18             	shl    $0x18,%eax
8010307e:	50                   	push   %eax
8010307f:	68 c4 00 00 00       	push   $0xc4
80103084:	e8 25 fe ff ff       	call   80102eae <lapicw>
80103089:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010308c:	68 00 c5 00 00       	push   $0xc500
80103091:	68 c0 00 00 00       	push   $0xc0
80103096:	e8 13 fe ff ff       	call   80102eae <lapicw>
8010309b:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010309e:	68 c8 00 00 00       	push   $0xc8
801030a3:	e8 85 ff ff ff       	call   8010302d <microdelay>
801030a8:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801030ab:	68 00 85 00 00       	push   $0x8500
801030b0:	68 c0 00 00 00       	push   $0xc0
801030b5:	e8 f4 fd ff ff       	call   80102eae <lapicw>
801030ba:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801030bd:	6a 64                	push   $0x64
801030bf:	e8 69 ff ff ff       	call   8010302d <microdelay>
801030c4:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030c7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801030ce:	eb 3d                	jmp    8010310d <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
801030d0:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030d4:	c1 e0 18             	shl    $0x18,%eax
801030d7:	50                   	push   %eax
801030d8:	68 c4 00 00 00       	push   $0xc4
801030dd:	e8 cc fd ff ff       	call   80102eae <lapicw>
801030e2:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801030e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801030e8:	c1 e8 0c             	shr    $0xc,%eax
801030eb:	80 cc 06             	or     $0x6,%ah
801030ee:	50                   	push   %eax
801030ef:	68 c0 00 00 00       	push   $0xc0
801030f4:	e8 b5 fd ff ff       	call   80102eae <lapicw>
801030f9:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801030fc:	68 c8 00 00 00       	push   $0xc8
80103101:	e8 27 ff ff ff       	call   8010302d <microdelay>
80103106:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80103109:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010310d:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103111:	7e bd                	jle    801030d0 <lapicstartap+0x9d>
  }
}
80103113:	90                   	nop
80103114:	90                   	nop
80103115:	c9                   	leave  
80103116:	c3                   	ret    

80103117 <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
80103117:	55                   	push   %ebp
80103118:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
8010311a:	8b 45 08             	mov    0x8(%ebp),%eax
8010311d:	0f b6 c0             	movzbl %al,%eax
80103120:	50                   	push   %eax
80103121:	6a 70                	push   $0x70
80103123:	e8 65 fd ff ff       	call   80102e8d <outb>
80103128:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010312b:	68 c8 00 00 00       	push   $0xc8
80103130:	e8 f8 fe ff ff       	call   8010302d <microdelay>
80103135:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103138:	6a 71                	push   $0x71
8010313a:	e8 31 fd ff ff       	call   80102e70 <inb>
8010313f:	83 c4 04             	add    $0x4,%esp
80103142:	0f b6 c0             	movzbl %al,%eax
}
80103145:	c9                   	leave  
80103146:	c3                   	ret    

80103147 <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
80103147:	55                   	push   %ebp
80103148:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
8010314a:	6a 00                	push   $0x0
8010314c:	e8 c6 ff ff ff       	call   80103117 <cmos_read>
80103151:	83 c4 04             	add    $0x4,%esp
80103154:	8b 55 08             	mov    0x8(%ebp),%edx
80103157:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103159:	6a 02                	push   $0x2
8010315b:	e8 b7 ff ff ff       	call   80103117 <cmos_read>
80103160:	83 c4 04             	add    $0x4,%esp
80103163:	8b 55 08             	mov    0x8(%ebp),%edx
80103166:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103169:	6a 04                	push   $0x4
8010316b:	e8 a7 ff ff ff       	call   80103117 <cmos_read>
80103170:	83 c4 04             	add    $0x4,%esp
80103173:	8b 55 08             	mov    0x8(%ebp),%edx
80103176:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103179:	6a 07                	push   $0x7
8010317b:	e8 97 ff ff ff       	call   80103117 <cmos_read>
80103180:	83 c4 04             	add    $0x4,%esp
80103183:	8b 55 08             	mov    0x8(%ebp),%edx
80103186:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103189:	6a 08                	push   $0x8
8010318b:	e8 87 ff ff ff       	call   80103117 <cmos_read>
80103190:	83 c4 04             	add    $0x4,%esp
80103193:	8b 55 08             	mov    0x8(%ebp),%edx
80103196:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103199:	6a 09                	push   $0x9
8010319b:	e8 77 ff ff ff       	call   80103117 <cmos_read>
801031a0:	83 c4 04             	add    $0x4,%esp
801031a3:	8b 55 08             	mov    0x8(%ebp),%edx
801031a6:	89 42 14             	mov    %eax,0x14(%edx)
}
801031a9:	90                   	nop
801031aa:	c9                   	leave  
801031ab:	c3                   	ret    

801031ac <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
801031ac:	55                   	push   %ebp
801031ad:	89 e5                	mov    %esp,%ebp
801031af:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801031b2:	6a 0b                	push   $0xb
801031b4:	e8 5e ff ff ff       	call   80103117 <cmos_read>
801031b9:	83 c4 04             	add    $0x4,%esp
801031bc:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801031bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031c2:	83 e0 04             	and    $0x4,%eax
801031c5:	85 c0                	test   %eax,%eax
801031c7:	0f 94 c0             	sete   %al
801031ca:	0f b6 c0             	movzbl %al,%eax
801031cd:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801031d0:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031d3:	50                   	push   %eax
801031d4:	e8 6e ff ff ff       	call   80103147 <fill_rtcdate>
801031d9:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801031dc:	6a 0a                	push   $0xa
801031de:	e8 34 ff ff ff       	call   80103117 <cmos_read>
801031e3:	83 c4 04             	add    $0x4,%esp
801031e6:	25 80 00 00 00       	and    $0x80,%eax
801031eb:	85 c0                	test   %eax,%eax
801031ed:	75 27                	jne    80103216 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
801031ef:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031f2:	50                   	push   %eax
801031f3:	e8 4f ff ff ff       	call   80103147 <fill_rtcdate>
801031f8:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801031fb:	83 ec 04             	sub    $0x4,%esp
801031fe:	6a 18                	push   $0x18
80103200:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103203:	50                   	push   %eax
80103204:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103207:	50                   	push   %eax
80103208:	e8 75 23 00 00       	call   80105582 <memcmp>
8010320d:	83 c4 10             	add    $0x10,%esp
80103210:	85 c0                	test   %eax,%eax
80103212:	74 05                	je     80103219 <cmostime+0x6d>
80103214:	eb ba                	jmp    801031d0 <cmostime+0x24>
        continue;
80103216:	90                   	nop
    fill_rtcdate(&t1);
80103217:	eb b7                	jmp    801031d0 <cmostime+0x24>
      break;
80103219:	90                   	nop
  }

  // convert
  if(bcd) {
8010321a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010321e:	0f 84 b4 00 00 00    	je     801032d8 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103224:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103227:	c1 e8 04             	shr    $0x4,%eax
8010322a:	89 c2                	mov    %eax,%edx
8010322c:	89 d0                	mov    %edx,%eax
8010322e:	c1 e0 02             	shl    $0x2,%eax
80103231:	01 d0                	add    %edx,%eax
80103233:	01 c0                	add    %eax,%eax
80103235:	89 c2                	mov    %eax,%edx
80103237:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010323a:	83 e0 0f             	and    $0xf,%eax
8010323d:	01 d0                	add    %edx,%eax
8010323f:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103242:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103245:	c1 e8 04             	shr    $0x4,%eax
80103248:	89 c2                	mov    %eax,%edx
8010324a:	89 d0                	mov    %edx,%eax
8010324c:	c1 e0 02             	shl    $0x2,%eax
8010324f:	01 d0                	add    %edx,%eax
80103251:	01 c0                	add    %eax,%eax
80103253:	89 c2                	mov    %eax,%edx
80103255:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103258:	83 e0 0f             	and    $0xf,%eax
8010325b:	01 d0                	add    %edx,%eax
8010325d:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103260:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103263:	c1 e8 04             	shr    $0x4,%eax
80103266:	89 c2                	mov    %eax,%edx
80103268:	89 d0                	mov    %edx,%eax
8010326a:	c1 e0 02             	shl    $0x2,%eax
8010326d:	01 d0                	add    %edx,%eax
8010326f:	01 c0                	add    %eax,%eax
80103271:	89 c2                	mov    %eax,%edx
80103273:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103276:	83 e0 0f             	and    $0xf,%eax
80103279:	01 d0                	add    %edx,%eax
8010327b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010327e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103281:	c1 e8 04             	shr    $0x4,%eax
80103284:	89 c2                	mov    %eax,%edx
80103286:	89 d0                	mov    %edx,%eax
80103288:	c1 e0 02             	shl    $0x2,%eax
8010328b:	01 d0                	add    %edx,%eax
8010328d:	01 c0                	add    %eax,%eax
8010328f:	89 c2                	mov    %eax,%edx
80103291:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103294:	83 e0 0f             	and    $0xf,%eax
80103297:	01 d0                	add    %edx,%eax
80103299:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
8010329c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010329f:	c1 e8 04             	shr    $0x4,%eax
801032a2:	89 c2                	mov    %eax,%edx
801032a4:	89 d0                	mov    %edx,%eax
801032a6:	c1 e0 02             	shl    $0x2,%eax
801032a9:	01 d0                	add    %edx,%eax
801032ab:	01 c0                	add    %eax,%eax
801032ad:	89 c2                	mov    %eax,%edx
801032af:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032b2:	83 e0 0f             	and    $0xf,%eax
801032b5:	01 d0                	add    %edx,%eax
801032b7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801032ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032bd:	c1 e8 04             	shr    $0x4,%eax
801032c0:	89 c2                	mov    %eax,%edx
801032c2:	89 d0                	mov    %edx,%eax
801032c4:	c1 e0 02             	shl    $0x2,%eax
801032c7:	01 d0                	add    %edx,%eax
801032c9:	01 c0                	add    %eax,%eax
801032cb:	89 c2                	mov    %eax,%edx
801032cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032d0:	83 e0 0f             	and    $0xf,%eax
801032d3:	01 d0                	add    %edx,%eax
801032d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801032d8:	8b 45 08             	mov    0x8(%ebp),%eax
801032db:	8b 55 d8             	mov    -0x28(%ebp),%edx
801032de:	89 10                	mov    %edx,(%eax)
801032e0:	8b 55 dc             	mov    -0x24(%ebp),%edx
801032e3:	89 50 04             	mov    %edx,0x4(%eax)
801032e6:	8b 55 e0             	mov    -0x20(%ebp),%edx
801032e9:	89 50 08             	mov    %edx,0x8(%eax)
801032ec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801032ef:	89 50 0c             	mov    %edx,0xc(%eax)
801032f2:	8b 55 e8             	mov    -0x18(%ebp),%edx
801032f5:	89 50 10             	mov    %edx,0x10(%eax)
801032f8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801032fb:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801032fe:	8b 45 08             	mov    0x8(%ebp),%eax
80103301:	8b 40 14             	mov    0x14(%eax),%eax
80103304:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
8010330a:	8b 45 08             	mov    0x8(%ebp),%eax
8010330d:	89 50 14             	mov    %edx,0x14(%eax)
}
80103310:	90                   	nop
80103311:	c9                   	leave  
80103312:	c3                   	ret    

80103313 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103313:	55                   	push   %ebp
80103314:	89 e5                	mov    %esp,%ebp
80103316:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103319:	83 ec 08             	sub    $0x8,%esp
8010331c:	68 3d 89 10 80       	push   $0x8010893d
80103321:	68 e0 26 11 80       	push   $0x801126e0
80103326:	e8 48 1f 00 00       	call   80105273 <initlock>
8010332b:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010332e:	83 ec 08             	sub    $0x8,%esp
80103331:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103334:	50                   	push   %eax
80103335:	ff 75 08             	push   0x8(%ebp)
80103338:	e8 d4 e0 ff ff       	call   80101411 <readsb>
8010333d:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80103340:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103343:	a3 14 27 11 80       	mov    %eax,0x80112714
  log.size = sb.nlog;
80103348:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010334b:	a3 18 27 11 80       	mov    %eax,0x80112718
  log.dev = dev;
80103350:	8b 45 08             	mov    0x8(%ebp),%eax
80103353:	a3 24 27 11 80       	mov    %eax,0x80112724
  recover_from_log();
80103358:	e8 b3 01 00 00       	call   80103510 <recover_from_log>
}
8010335d:	90                   	nop
8010335e:	c9                   	leave  
8010335f:	c3                   	ret    

80103360 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80103360:	55                   	push   %ebp
80103361:	89 e5                	mov    %esp,%ebp
80103363:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103366:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010336d:	e9 95 00 00 00       	jmp    80103407 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103372:	8b 15 14 27 11 80    	mov    0x80112714,%edx
80103378:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010337b:	01 d0                	add    %edx,%eax
8010337d:	83 c0 01             	add    $0x1,%eax
80103380:	89 c2                	mov    %eax,%edx
80103382:	a1 24 27 11 80       	mov    0x80112724,%eax
80103387:	83 ec 08             	sub    $0x8,%esp
8010338a:	52                   	push   %edx
8010338b:	50                   	push   %eax
8010338c:	e8 3e ce ff ff       	call   801001cf <bread>
80103391:	83 c4 10             	add    $0x10,%esp
80103394:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103397:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010339a:	83 c0 10             	add    $0x10,%eax
8010339d:	8b 04 85 ec 26 11 80 	mov    -0x7feed914(,%eax,4),%eax
801033a4:	89 c2                	mov    %eax,%edx
801033a6:	a1 24 27 11 80       	mov    0x80112724,%eax
801033ab:	83 ec 08             	sub    $0x8,%esp
801033ae:	52                   	push   %edx
801033af:	50                   	push   %eax
801033b0:	e8 1a ce ff ff       	call   801001cf <bread>
801033b5:	83 c4 10             	add    $0x10,%esp
801033b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801033bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033be:	8d 50 5c             	lea    0x5c(%eax),%edx
801033c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033c4:	83 c0 5c             	add    $0x5c,%eax
801033c7:	83 ec 04             	sub    $0x4,%esp
801033ca:	68 00 02 00 00       	push   $0x200
801033cf:	52                   	push   %edx
801033d0:	50                   	push   %eax
801033d1:	e8 04 22 00 00       	call   801055da <memmove>
801033d6:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801033d9:	83 ec 0c             	sub    $0xc,%esp
801033dc:	ff 75 ec             	push   -0x14(%ebp)
801033df:	e8 24 ce ff ff       	call   80100208 <bwrite>
801033e4:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
801033e7:	83 ec 0c             	sub    $0xc,%esp
801033ea:	ff 75 f0             	push   -0x10(%ebp)
801033ed:	e8 5f ce ff ff       	call   80100251 <brelse>
801033f2:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801033f5:	83 ec 0c             	sub    $0xc,%esp
801033f8:	ff 75 ec             	push   -0x14(%ebp)
801033fb:	e8 51 ce ff ff       	call   80100251 <brelse>
80103400:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103403:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103407:	a1 28 27 11 80       	mov    0x80112728,%eax
8010340c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010340f:	0f 8c 5d ff ff ff    	jl     80103372 <install_trans+0x12>
  }
}
80103415:	90                   	nop
80103416:	90                   	nop
80103417:	c9                   	leave  
80103418:	c3                   	ret    

80103419 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103419:	55                   	push   %ebp
8010341a:	89 e5                	mov    %esp,%ebp
8010341c:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010341f:	a1 14 27 11 80       	mov    0x80112714,%eax
80103424:	89 c2                	mov    %eax,%edx
80103426:	a1 24 27 11 80       	mov    0x80112724,%eax
8010342b:	83 ec 08             	sub    $0x8,%esp
8010342e:	52                   	push   %edx
8010342f:	50                   	push   %eax
80103430:	e8 9a cd ff ff       	call   801001cf <bread>
80103435:	83 c4 10             	add    $0x10,%esp
80103438:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010343b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010343e:	83 c0 5c             	add    $0x5c,%eax
80103441:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103444:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103447:	8b 00                	mov    (%eax),%eax
80103449:	a3 28 27 11 80       	mov    %eax,0x80112728
  for (i = 0; i < log.lh.n; i++) {
8010344e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103455:	eb 1b                	jmp    80103472 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103457:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010345a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010345d:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103461:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103464:	83 c2 10             	add    $0x10,%edx
80103467:	89 04 95 ec 26 11 80 	mov    %eax,-0x7feed914(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010346e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103472:	a1 28 27 11 80       	mov    0x80112728,%eax
80103477:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010347a:	7c db                	jl     80103457 <read_head+0x3e>
  }
  brelse(buf);
8010347c:	83 ec 0c             	sub    $0xc,%esp
8010347f:	ff 75 f0             	push   -0x10(%ebp)
80103482:	e8 ca cd ff ff       	call   80100251 <brelse>
80103487:	83 c4 10             	add    $0x10,%esp
}
8010348a:	90                   	nop
8010348b:	c9                   	leave  
8010348c:	c3                   	ret    

8010348d <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010348d:	55                   	push   %ebp
8010348e:	89 e5                	mov    %esp,%ebp
80103490:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103493:	a1 14 27 11 80       	mov    0x80112714,%eax
80103498:	89 c2                	mov    %eax,%edx
8010349a:	a1 24 27 11 80       	mov    0x80112724,%eax
8010349f:	83 ec 08             	sub    $0x8,%esp
801034a2:	52                   	push   %edx
801034a3:	50                   	push   %eax
801034a4:	e8 26 cd ff ff       	call   801001cf <bread>
801034a9:	83 c4 10             	add    $0x10,%esp
801034ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801034af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034b2:	83 c0 5c             	add    $0x5c,%eax
801034b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034b8:	8b 15 28 27 11 80    	mov    0x80112728,%edx
801034be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034c1:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034ca:	eb 1b                	jmp    801034e7 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
801034cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034cf:	83 c0 10             	add    $0x10,%eax
801034d2:	8b 0c 85 ec 26 11 80 	mov    -0x7feed914(,%eax,4),%ecx
801034d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034df:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801034e3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034e7:	a1 28 27 11 80       	mov    0x80112728,%eax
801034ec:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801034ef:	7c db                	jl     801034cc <write_head+0x3f>
  }
  bwrite(buf);
801034f1:	83 ec 0c             	sub    $0xc,%esp
801034f4:	ff 75 f0             	push   -0x10(%ebp)
801034f7:	e8 0c cd ff ff       	call   80100208 <bwrite>
801034fc:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801034ff:	83 ec 0c             	sub    $0xc,%esp
80103502:	ff 75 f0             	push   -0x10(%ebp)
80103505:	e8 47 cd ff ff       	call   80100251 <brelse>
8010350a:	83 c4 10             	add    $0x10,%esp
}
8010350d:	90                   	nop
8010350e:	c9                   	leave  
8010350f:	c3                   	ret    

80103510 <recover_from_log>:

static void
recover_from_log(void)
{
80103510:	55                   	push   %ebp
80103511:	89 e5                	mov    %esp,%ebp
80103513:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103516:	e8 fe fe ff ff       	call   80103419 <read_head>
  install_trans(); // if committed, copy from log to disk
8010351b:	e8 40 fe ff ff       	call   80103360 <install_trans>
  log.lh.n = 0;
80103520:	c7 05 28 27 11 80 00 	movl   $0x0,0x80112728
80103527:	00 00 00 
  write_head(); // clear the log
8010352a:	e8 5e ff ff ff       	call   8010348d <write_head>
}
8010352f:	90                   	nop
80103530:	c9                   	leave  
80103531:	c3                   	ret    

80103532 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103532:	55                   	push   %ebp
80103533:	89 e5                	mov    %esp,%ebp
80103535:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103538:	83 ec 0c             	sub    $0xc,%esp
8010353b:	68 e0 26 11 80       	push   $0x801126e0
80103540:	e8 50 1d 00 00       	call   80105295 <acquire>
80103545:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103548:	a1 20 27 11 80       	mov    0x80112720,%eax
8010354d:	85 c0                	test   %eax,%eax
8010354f:	74 17                	je     80103568 <begin_op+0x36>
      sleep(&log, &log.lock);
80103551:	83 ec 08             	sub    $0x8,%esp
80103554:	68 e0 26 11 80       	push   $0x801126e0
80103559:	68 e0 26 11 80       	push   $0x801126e0
8010355e:	e8 78 17 00 00       	call   80104cdb <sleep>
80103563:	83 c4 10             	add    $0x10,%esp
80103566:	eb e0                	jmp    80103548 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103568:	8b 0d 28 27 11 80    	mov    0x80112728,%ecx
8010356e:	a1 1c 27 11 80       	mov    0x8011271c,%eax
80103573:	8d 50 01             	lea    0x1(%eax),%edx
80103576:	89 d0                	mov    %edx,%eax
80103578:	c1 e0 02             	shl    $0x2,%eax
8010357b:	01 d0                	add    %edx,%eax
8010357d:	01 c0                	add    %eax,%eax
8010357f:	01 c8                	add    %ecx,%eax
80103581:	83 f8 1e             	cmp    $0x1e,%eax
80103584:	7e 17                	jle    8010359d <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103586:	83 ec 08             	sub    $0x8,%esp
80103589:	68 e0 26 11 80       	push   $0x801126e0
8010358e:	68 e0 26 11 80       	push   $0x801126e0
80103593:	e8 43 17 00 00       	call   80104cdb <sleep>
80103598:	83 c4 10             	add    $0x10,%esp
8010359b:	eb ab                	jmp    80103548 <begin_op+0x16>
    } else {
      log.outstanding += 1;
8010359d:	a1 1c 27 11 80       	mov    0x8011271c,%eax
801035a2:	83 c0 01             	add    $0x1,%eax
801035a5:	a3 1c 27 11 80       	mov    %eax,0x8011271c
      release(&log.lock);
801035aa:	83 ec 0c             	sub    $0xc,%esp
801035ad:	68 e0 26 11 80       	push   $0x801126e0
801035b2:	e8 4c 1d 00 00       	call   80105303 <release>
801035b7:	83 c4 10             	add    $0x10,%esp
      break;
801035ba:	90                   	nop
    }
  }
}
801035bb:	90                   	nop
801035bc:	c9                   	leave  
801035bd:	c3                   	ret    

801035be <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801035be:	55                   	push   %ebp
801035bf:	89 e5                	mov    %esp,%ebp
801035c1:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801035c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801035cb:	83 ec 0c             	sub    $0xc,%esp
801035ce:	68 e0 26 11 80       	push   $0x801126e0
801035d3:	e8 bd 1c 00 00       	call   80105295 <acquire>
801035d8:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801035db:	a1 1c 27 11 80       	mov    0x8011271c,%eax
801035e0:	83 e8 01             	sub    $0x1,%eax
801035e3:	a3 1c 27 11 80       	mov    %eax,0x8011271c
  if(log.committing)
801035e8:	a1 20 27 11 80       	mov    0x80112720,%eax
801035ed:	85 c0                	test   %eax,%eax
801035ef:	74 0d                	je     801035fe <end_op+0x40>
    panic("log.committing");
801035f1:	83 ec 0c             	sub    $0xc,%esp
801035f4:	68 41 89 10 80       	push   $0x80108941
801035f9:	e8 b7 cf ff ff       	call   801005b5 <panic>
  if(log.outstanding == 0){
801035fe:	a1 1c 27 11 80       	mov    0x8011271c,%eax
80103603:	85 c0                	test   %eax,%eax
80103605:	75 13                	jne    8010361a <end_op+0x5c>
    do_commit = 1;
80103607:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010360e:	c7 05 20 27 11 80 01 	movl   $0x1,0x80112720
80103615:	00 00 00 
80103618:	eb 10                	jmp    8010362a <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
8010361a:	83 ec 0c             	sub    $0xc,%esp
8010361d:	68 e0 26 11 80       	push   $0x801126e0
80103622:	e8 b2 17 00 00       	call   80104dd9 <wakeup>
80103627:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
8010362a:	83 ec 0c             	sub    $0xc,%esp
8010362d:	68 e0 26 11 80       	push   $0x801126e0
80103632:	e8 cc 1c 00 00       	call   80105303 <release>
80103637:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
8010363a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010363e:	74 3f                	je     8010367f <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103640:	e8 f6 00 00 00       	call   8010373b <commit>
    acquire(&log.lock);
80103645:	83 ec 0c             	sub    $0xc,%esp
80103648:	68 e0 26 11 80       	push   $0x801126e0
8010364d:	e8 43 1c 00 00       	call   80105295 <acquire>
80103652:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103655:	c7 05 20 27 11 80 00 	movl   $0x0,0x80112720
8010365c:	00 00 00 
    wakeup(&log);
8010365f:	83 ec 0c             	sub    $0xc,%esp
80103662:	68 e0 26 11 80       	push   $0x801126e0
80103667:	e8 6d 17 00 00       	call   80104dd9 <wakeup>
8010366c:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010366f:	83 ec 0c             	sub    $0xc,%esp
80103672:	68 e0 26 11 80       	push   $0x801126e0
80103677:	e8 87 1c 00 00       	call   80105303 <release>
8010367c:	83 c4 10             	add    $0x10,%esp
  }
}
8010367f:	90                   	nop
80103680:	c9                   	leave  
80103681:	c3                   	ret    

80103682 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103682:	55                   	push   %ebp
80103683:	89 e5                	mov    %esp,%ebp
80103685:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103688:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010368f:	e9 95 00 00 00       	jmp    80103729 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103694:	8b 15 14 27 11 80    	mov    0x80112714,%edx
8010369a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010369d:	01 d0                	add    %edx,%eax
8010369f:	83 c0 01             	add    $0x1,%eax
801036a2:	89 c2                	mov    %eax,%edx
801036a4:	a1 24 27 11 80       	mov    0x80112724,%eax
801036a9:	83 ec 08             	sub    $0x8,%esp
801036ac:	52                   	push   %edx
801036ad:	50                   	push   %eax
801036ae:	e8 1c cb ff ff       	call   801001cf <bread>
801036b3:	83 c4 10             	add    $0x10,%esp
801036b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801036b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036bc:	83 c0 10             	add    $0x10,%eax
801036bf:	8b 04 85 ec 26 11 80 	mov    -0x7feed914(,%eax,4),%eax
801036c6:	89 c2                	mov    %eax,%edx
801036c8:	a1 24 27 11 80       	mov    0x80112724,%eax
801036cd:	83 ec 08             	sub    $0x8,%esp
801036d0:	52                   	push   %edx
801036d1:	50                   	push   %eax
801036d2:	e8 f8 ca ff ff       	call   801001cf <bread>
801036d7:	83 c4 10             	add    $0x10,%esp
801036da:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801036dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036e0:	8d 50 5c             	lea    0x5c(%eax),%edx
801036e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036e6:	83 c0 5c             	add    $0x5c,%eax
801036e9:	83 ec 04             	sub    $0x4,%esp
801036ec:	68 00 02 00 00       	push   $0x200
801036f1:	52                   	push   %edx
801036f2:	50                   	push   %eax
801036f3:	e8 e2 1e 00 00       	call   801055da <memmove>
801036f8:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801036fb:	83 ec 0c             	sub    $0xc,%esp
801036fe:	ff 75 f0             	push   -0x10(%ebp)
80103701:	e8 02 cb ff ff       	call   80100208 <bwrite>
80103706:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103709:	83 ec 0c             	sub    $0xc,%esp
8010370c:	ff 75 ec             	push   -0x14(%ebp)
8010370f:	e8 3d cb ff ff       	call   80100251 <brelse>
80103714:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103717:	83 ec 0c             	sub    $0xc,%esp
8010371a:	ff 75 f0             	push   -0x10(%ebp)
8010371d:	e8 2f cb ff ff       	call   80100251 <brelse>
80103722:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103725:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103729:	a1 28 27 11 80       	mov    0x80112728,%eax
8010372e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103731:	0f 8c 5d ff ff ff    	jl     80103694 <write_log+0x12>
  }
}
80103737:	90                   	nop
80103738:	90                   	nop
80103739:	c9                   	leave  
8010373a:	c3                   	ret    

8010373b <commit>:

static void
commit()
{
8010373b:	55                   	push   %ebp
8010373c:	89 e5                	mov    %esp,%ebp
8010373e:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103741:	a1 28 27 11 80       	mov    0x80112728,%eax
80103746:	85 c0                	test   %eax,%eax
80103748:	7e 1e                	jle    80103768 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
8010374a:	e8 33 ff ff ff       	call   80103682 <write_log>
    write_head();    // Write header to disk -- the real commit
8010374f:	e8 39 fd ff ff       	call   8010348d <write_head>
    install_trans(); // Now install writes to home locations
80103754:	e8 07 fc ff ff       	call   80103360 <install_trans>
    log.lh.n = 0;
80103759:	c7 05 28 27 11 80 00 	movl   $0x0,0x80112728
80103760:	00 00 00 
    write_head();    // Erase the transaction from the log
80103763:	e8 25 fd ff ff       	call   8010348d <write_head>
  }
}
80103768:	90                   	nop
80103769:	c9                   	leave  
8010376a:	c3                   	ret    

8010376b <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010376b:	55                   	push   %ebp
8010376c:	89 e5                	mov    %esp,%ebp
8010376e:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103771:	a1 28 27 11 80       	mov    0x80112728,%eax
80103776:	83 f8 1d             	cmp    $0x1d,%eax
80103779:	7f 12                	jg     8010378d <log_write+0x22>
8010377b:	a1 28 27 11 80       	mov    0x80112728,%eax
80103780:	8b 15 18 27 11 80    	mov    0x80112718,%edx
80103786:	83 ea 01             	sub    $0x1,%edx
80103789:	39 d0                	cmp    %edx,%eax
8010378b:	7c 0d                	jl     8010379a <log_write+0x2f>
    panic("too big a transaction");
8010378d:	83 ec 0c             	sub    $0xc,%esp
80103790:	68 50 89 10 80       	push   $0x80108950
80103795:	e8 1b ce ff ff       	call   801005b5 <panic>
  if (log.outstanding < 1)
8010379a:	a1 1c 27 11 80       	mov    0x8011271c,%eax
8010379f:	85 c0                	test   %eax,%eax
801037a1:	7f 0d                	jg     801037b0 <log_write+0x45>
    panic("log_write outside of trans");
801037a3:	83 ec 0c             	sub    $0xc,%esp
801037a6:	68 66 89 10 80       	push   $0x80108966
801037ab:	e8 05 ce ff ff       	call   801005b5 <panic>

  acquire(&log.lock);
801037b0:	83 ec 0c             	sub    $0xc,%esp
801037b3:	68 e0 26 11 80       	push   $0x801126e0
801037b8:	e8 d8 1a 00 00       	call   80105295 <acquire>
801037bd:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801037c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037c7:	eb 1d                	jmp    801037e6 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801037c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037cc:	83 c0 10             	add    $0x10,%eax
801037cf:	8b 04 85 ec 26 11 80 	mov    -0x7feed914(,%eax,4),%eax
801037d6:	89 c2                	mov    %eax,%edx
801037d8:	8b 45 08             	mov    0x8(%ebp),%eax
801037db:	8b 40 08             	mov    0x8(%eax),%eax
801037de:	39 c2                	cmp    %eax,%edx
801037e0:	74 10                	je     801037f2 <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801037e2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801037e6:	a1 28 27 11 80       	mov    0x80112728,%eax
801037eb:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801037ee:	7c d9                	jl     801037c9 <log_write+0x5e>
801037f0:	eb 01                	jmp    801037f3 <log_write+0x88>
      break;
801037f2:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801037f3:	8b 45 08             	mov    0x8(%ebp),%eax
801037f6:	8b 40 08             	mov    0x8(%eax),%eax
801037f9:	89 c2                	mov    %eax,%edx
801037fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037fe:	83 c0 10             	add    $0x10,%eax
80103801:	89 14 85 ec 26 11 80 	mov    %edx,-0x7feed914(,%eax,4)
  if (i == log.lh.n)
80103808:	a1 28 27 11 80       	mov    0x80112728,%eax
8010380d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103810:	75 0d                	jne    8010381f <log_write+0xb4>
    log.lh.n++;
80103812:	a1 28 27 11 80       	mov    0x80112728,%eax
80103817:	83 c0 01             	add    $0x1,%eax
8010381a:	a3 28 27 11 80       	mov    %eax,0x80112728
  b->flags |= B_DIRTY; // prevent eviction
8010381f:	8b 45 08             	mov    0x8(%ebp),%eax
80103822:	8b 00                	mov    (%eax),%eax
80103824:	83 c8 04             	or     $0x4,%eax
80103827:	89 c2                	mov    %eax,%edx
80103829:	8b 45 08             	mov    0x8(%ebp),%eax
8010382c:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010382e:	83 ec 0c             	sub    $0xc,%esp
80103831:	68 e0 26 11 80       	push   $0x801126e0
80103836:	e8 c8 1a 00 00       	call   80105303 <release>
8010383b:	83 c4 10             	add    $0x10,%esp
}
8010383e:	90                   	nop
8010383f:	c9                   	leave  
80103840:	c3                   	ret    

80103841 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103841:	55                   	push   %ebp
80103842:	89 e5                	mov    %esp,%ebp
80103844:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103847:	8b 55 08             	mov    0x8(%ebp),%edx
8010384a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010384d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103850:	f0 87 02             	lock xchg %eax,(%edx)
80103853:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103856:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103859:	c9                   	leave  
8010385a:	c3                   	ret    

8010385b <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010385b:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010385f:	83 e4 f0             	and    $0xfffffff0,%esp
80103862:	ff 71 fc             	push   -0x4(%ecx)
80103865:	55                   	push   %ebp
80103866:	89 e5                	mov    %esp,%ebp
80103868:	51                   	push   %ecx
80103869:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010386c:	83 ec 08             	sub    $0x8,%esp
8010386f:	68 00 00 40 80       	push   $0x80400000
80103874:	68 e0 68 11 80       	push   $0x801168e0
80103879:	e8 e3 f2 ff ff       	call   80102b61 <kinit1>
8010387e:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103881:	e8 88 46 00 00       	call   80107f0e <kvmalloc>
  mpinit();        // detect other processors
80103886:	e8 bd 03 00 00       	call   80103c48 <mpinit>
  lapicinit();     // interrupt controller
8010388b:	e8 41 f6 ff ff       	call   80102ed1 <lapicinit>
  seginit();       // segment descriptors
80103890:	e8 64 41 00 00       	call   801079f9 <seginit>
  picinit();       // disable pic
80103895:	e8 15 05 00 00       	call   80103daf <picinit>
  ioapicinit();    // another interrupt controller
8010389a:	e8 dd f1 ff ff       	call   80102a7c <ioapicinit>
  consoleinit();   // console hardware
8010389f:	e8 d4 d2 ff ff       	call   80100b78 <consoleinit>
  uartinit();      // serial port
801038a4:	e8 e9 34 00 00       	call   80106d92 <uartinit>
  pinit();         // process table
801038a9:	e8 7b 09 00 00       	call   80104229 <pinit>
  tvinit();        // trap vectors
801038ae:	e8 bf 30 00 00       	call   80106972 <tvinit>
  binit();         // buffer cache
801038b3:	e8 7c c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801038b8:	e8 45 d7 ff ff       	call   80101002 <fileinit>
  ideinit();       // disk 
801038bd:	e8 91 ed ff ff       	call   80102653 <ideinit>
  startothers();   // start other processors
801038c2:	e8 80 00 00 00       	call   80103947 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801038c7:	83 ec 08             	sub    $0x8,%esp
801038ca:	68 00 00 00 8e       	push   $0x8e000000
801038cf:	68 00 00 40 80       	push   $0x80400000
801038d4:	e8 c1 f2 ff ff       	call   80102b9a <kinit2>
801038d9:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
801038dc:	e8 e1 0b 00 00       	call   801044c2 <userinit>
  mpmain();        // finish this processor's setup
801038e1:	e8 1a 00 00 00       	call   80103900 <mpmain>

801038e6 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801038e6:	55                   	push   %ebp
801038e7:	89 e5                	mov    %esp,%ebp
801038e9:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801038ec:	e8 35 46 00 00       	call   80107f26 <switchkvm>
  seginit();
801038f1:	e8 03 41 00 00       	call   801079f9 <seginit>
  lapicinit();
801038f6:	e8 d6 f5 ff ff       	call   80102ed1 <lapicinit>
  mpmain();
801038fb:	e8 00 00 00 00       	call   80103900 <mpmain>

80103900 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103900:	55                   	push   %ebp
80103901:	89 e5                	mov    %esp,%ebp
80103903:	53                   	push   %ebx
80103904:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103907:	e8 3b 09 00 00       	call   80104247 <cpuid>
8010390c:	89 c3                	mov    %eax,%ebx
8010390e:	e8 34 09 00 00       	call   80104247 <cpuid>
80103913:	83 ec 04             	sub    $0x4,%esp
80103916:	53                   	push   %ebx
80103917:	50                   	push   %eax
80103918:	68 81 89 10 80       	push   $0x80108981
8010391d:	e8 de ca ff ff       	call   80100400 <cprintf>
80103922:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103925:	e8 be 31 00 00       	call   80106ae8 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
8010392a:	e8 33 09 00 00       	call   80104262 <mycpu>
8010392f:	05 a0 00 00 00       	add    $0xa0,%eax
80103934:	83 ec 08             	sub    $0x8,%esp
80103937:	6a 01                	push   $0x1
80103939:	50                   	push   %eax
8010393a:	e8 02 ff ff ff       	call   80103841 <xchg>
8010393f:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103942:	e8 0c 11 00 00       	call   80104a53 <scheduler>

80103947 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103947:	55                   	push   %ebp
80103948:	89 e5                	mov    %esp,%ebp
8010394a:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
8010394d:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103954:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103959:	83 ec 04             	sub    $0x4,%esp
8010395c:	50                   	push   %eax
8010395d:	68 ec b4 10 80       	push   $0x8010b4ec
80103962:	ff 75 f0             	push   -0x10(%ebp)
80103965:	e8 70 1c 00 00       	call   801055da <memmove>
8010396a:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
8010396d:	c7 45 f4 c0 27 11 80 	movl   $0x801127c0,-0xc(%ebp)
80103974:	eb 79                	jmp    801039ef <startothers+0xa8>
    if(c == mycpu())  // We've started already.
80103976:	e8 e7 08 00 00       	call   80104262 <mycpu>
8010397b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010397e:	74 67                	je     801039e7 <startothers+0xa0>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103980:	e8 11 f3 ff ff       	call   80102c96 <kalloc>
80103985:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103988:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010398b:	83 e8 04             	sub    $0x4,%eax
8010398e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103991:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103997:	89 10                	mov    %edx,(%eax)
    *(void(**)(void))(code-8) = mpenter;
80103999:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010399c:	83 e8 08             	sub    $0x8,%eax
8010399f:	c7 00 e6 38 10 80    	movl   $0x801038e6,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801039a5:	b8 00 a0 10 80       	mov    $0x8010a000,%eax
801039aa:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801039b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039b3:	83 e8 0c             	sub    $0xc,%eax
801039b6:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801039b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039bb:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801039c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039c4:	0f b6 00             	movzbl (%eax),%eax
801039c7:	0f b6 c0             	movzbl %al,%eax
801039ca:	83 ec 08             	sub    $0x8,%esp
801039cd:	52                   	push   %edx
801039ce:	50                   	push   %eax
801039cf:	e8 5f f6 ff ff       	call   80103033 <lapicstartap>
801039d4:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801039d7:	90                   	nop
801039d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039db:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801039e1:	85 c0                	test   %eax,%eax
801039e3:	74 f3                	je     801039d8 <startothers+0x91>
801039e5:	eb 01                	jmp    801039e8 <startothers+0xa1>
      continue;
801039e7:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
801039e8:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
801039ef:	a1 40 2d 11 80       	mov    0x80112d40,%eax
801039f4:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801039fa:	05 c0 27 11 80       	add    $0x801127c0,%eax
801039ff:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a02:	0f 82 6e ff ff ff    	jb     80103976 <startothers+0x2f>
      ;
  }
}
80103a08:	90                   	nop
80103a09:	90                   	nop
80103a0a:	c9                   	leave  
80103a0b:	c3                   	ret    

80103a0c <inb>:
{
80103a0c:	55                   	push   %ebp
80103a0d:	89 e5                	mov    %esp,%ebp
80103a0f:	83 ec 14             	sub    $0x14,%esp
80103a12:	8b 45 08             	mov    0x8(%ebp),%eax
80103a15:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103a19:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103a1d:	89 c2                	mov    %eax,%edx
80103a1f:	ec                   	in     (%dx),%al
80103a20:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103a23:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103a27:	c9                   	leave  
80103a28:	c3                   	ret    

80103a29 <outb>:
{
80103a29:	55                   	push   %ebp
80103a2a:	89 e5                	mov    %esp,%ebp
80103a2c:	83 ec 08             	sub    $0x8,%esp
80103a2f:	8b 45 08             	mov    0x8(%ebp),%eax
80103a32:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a35:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103a39:	89 d0                	mov    %edx,%eax
80103a3b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103a3e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103a42:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103a46:	ee                   	out    %al,(%dx)
}
80103a47:	90                   	nop
80103a48:	c9                   	leave  
80103a49:	c3                   	ret    

80103a4a <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103a4a:	55                   	push   %ebp
80103a4b:	89 e5                	mov    %esp,%ebp
80103a4d:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103a50:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103a57:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103a5e:	eb 15                	jmp    80103a75 <sum+0x2b>
    sum += addr[i];
80103a60:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103a63:	8b 45 08             	mov    0x8(%ebp),%eax
80103a66:	01 d0                	add    %edx,%eax
80103a68:	0f b6 00             	movzbl (%eax),%eax
80103a6b:	0f b6 c0             	movzbl %al,%eax
80103a6e:	01 45 f8             	add    %eax,-0x8(%ebp)
  for(i=0; i<len; i++)
80103a71:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103a75:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a78:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103a7b:	7c e3                	jl     80103a60 <sum+0x16>
  return sum;
80103a7d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103a80:	c9                   	leave  
80103a81:	c3                   	ret    

80103a82 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103a82:	55                   	push   %ebp
80103a83:	89 e5                	mov    %esp,%ebp
80103a85:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103a88:	8b 45 08             	mov    0x8(%ebp),%eax
80103a8b:	05 00 00 00 80       	add    $0x80000000,%eax
80103a90:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103a93:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a99:	01 d0                	add    %edx,%eax
80103a9b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103a9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103aa1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103aa4:	eb 36                	jmp    80103adc <mpsearch1+0x5a>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103aa6:	83 ec 04             	sub    $0x4,%esp
80103aa9:	6a 04                	push   $0x4
80103aab:	68 98 89 10 80       	push   $0x80108998
80103ab0:	ff 75 f4             	push   -0xc(%ebp)
80103ab3:	e8 ca 1a 00 00       	call   80105582 <memcmp>
80103ab8:	83 c4 10             	add    $0x10,%esp
80103abb:	85 c0                	test   %eax,%eax
80103abd:	75 19                	jne    80103ad8 <mpsearch1+0x56>
80103abf:	83 ec 08             	sub    $0x8,%esp
80103ac2:	6a 10                	push   $0x10
80103ac4:	ff 75 f4             	push   -0xc(%ebp)
80103ac7:	e8 7e ff ff ff       	call   80103a4a <sum>
80103acc:	83 c4 10             	add    $0x10,%esp
80103acf:	84 c0                	test   %al,%al
80103ad1:	75 05                	jne    80103ad8 <mpsearch1+0x56>
      return (struct mp*)p;
80103ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ad6:	eb 11                	jmp    80103ae9 <mpsearch1+0x67>
  for(p = addr; p < e; p += sizeof(struct mp))
80103ad8:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103adf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103ae2:	72 c2                	jb     80103aa6 <mpsearch1+0x24>
  return 0;
80103ae4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103ae9:	c9                   	leave  
80103aea:	c3                   	ret    

80103aeb <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103aeb:	55                   	push   %ebp
80103aec:	89 e5                	mov    %esp,%ebp
80103aee:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103af1:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103afb:	83 c0 0f             	add    $0xf,%eax
80103afe:	0f b6 00             	movzbl (%eax),%eax
80103b01:	0f b6 c0             	movzbl %al,%eax
80103b04:	c1 e0 08             	shl    $0x8,%eax
80103b07:	89 c2                	mov    %eax,%edx
80103b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b0c:	83 c0 0e             	add    $0xe,%eax
80103b0f:	0f b6 00             	movzbl (%eax),%eax
80103b12:	0f b6 c0             	movzbl %al,%eax
80103b15:	09 d0                	or     %edx,%eax
80103b17:	c1 e0 04             	shl    $0x4,%eax
80103b1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103b1d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103b21:	74 21                	je     80103b44 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103b23:	83 ec 08             	sub    $0x8,%esp
80103b26:	68 00 04 00 00       	push   $0x400
80103b2b:	ff 75 f0             	push   -0x10(%ebp)
80103b2e:	e8 4f ff ff ff       	call   80103a82 <mpsearch1>
80103b33:	83 c4 10             	add    $0x10,%esp
80103b36:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b39:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b3d:	74 51                	je     80103b90 <mpsearch+0xa5>
      return mp;
80103b3f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b42:	eb 61                	jmp    80103ba5 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b47:	83 c0 14             	add    $0x14,%eax
80103b4a:	0f b6 00             	movzbl (%eax),%eax
80103b4d:	0f b6 c0             	movzbl %al,%eax
80103b50:	c1 e0 08             	shl    $0x8,%eax
80103b53:	89 c2                	mov    %eax,%edx
80103b55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b58:	83 c0 13             	add    $0x13,%eax
80103b5b:	0f b6 00             	movzbl (%eax),%eax
80103b5e:	0f b6 c0             	movzbl %al,%eax
80103b61:	09 d0                	or     %edx,%eax
80103b63:	c1 e0 0a             	shl    $0xa,%eax
80103b66:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103b69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b6c:	2d 00 04 00 00       	sub    $0x400,%eax
80103b71:	83 ec 08             	sub    $0x8,%esp
80103b74:	68 00 04 00 00       	push   $0x400
80103b79:	50                   	push   %eax
80103b7a:	e8 03 ff ff ff       	call   80103a82 <mpsearch1>
80103b7f:	83 c4 10             	add    $0x10,%esp
80103b82:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b85:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b89:	74 05                	je     80103b90 <mpsearch+0xa5>
      return mp;
80103b8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b8e:	eb 15                	jmp    80103ba5 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103b90:	83 ec 08             	sub    $0x8,%esp
80103b93:	68 00 00 01 00       	push   $0x10000
80103b98:	68 00 00 0f 00       	push   $0xf0000
80103b9d:	e8 e0 fe ff ff       	call   80103a82 <mpsearch1>
80103ba2:	83 c4 10             	add    $0x10,%esp
}
80103ba5:	c9                   	leave  
80103ba6:	c3                   	ret    

80103ba7 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103ba7:	55                   	push   %ebp
80103ba8:	89 e5                	mov    %esp,%ebp
80103baa:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103bad:	e8 39 ff ff ff       	call   80103aeb <mpsearch>
80103bb2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103bb5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103bb9:	74 0a                	je     80103bc5 <mpconfig+0x1e>
80103bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bbe:	8b 40 04             	mov    0x4(%eax),%eax
80103bc1:	85 c0                	test   %eax,%eax
80103bc3:	75 07                	jne    80103bcc <mpconfig+0x25>
    return 0;
80103bc5:	b8 00 00 00 00       	mov    $0x0,%eax
80103bca:	eb 7a                	jmp    80103c46 <mpconfig+0x9f>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bcf:	8b 40 04             	mov    0x4(%eax),%eax
80103bd2:	05 00 00 00 80       	add    $0x80000000,%eax
80103bd7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103bda:	83 ec 04             	sub    $0x4,%esp
80103bdd:	6a 04                	push   $0x4
80103bdf:	68 9d 89 10 80       	push   $0x8010899d
80103be4:	ff 75 f0             	push   -0x10(%ebp)
80103be7:	e8 96 19 00 00       	call   80105582 <memcmp>
80103bec:	83 c4 10             	add    $0x10,%esp
80103bef:	85 c0                	test   %eax,%eax
80103bf1:	74 07                	je     80103bfa <mpconfig+0x53>
    return 0;
80103bf3:	b8 00 00 00 00       	mov    $0x0,%eax
80103bf8:	eb 4c                	jmp    80103c46 <mpconfig+0x9f>
  if(conf->version != 1 && conf->version != 4)
80103bfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bfd:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103c01:	3c 01                	cmp    $0x1,%al
80103c03:	74 12                	je     80103c17 <mpconfig+0x70>
80103c05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c08:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103c0c:	3c 04                	cmp    $0x4,%al
80103c0e:	74 07                	je     80103c17 <mpconfig+0x70>
    return 0;
80103c10:	b8 00 00 00 00       	mov    $0x0,%eax
80103c15:	eb 2f                	jmp    80103c46 <mpconfig+0x9f>
  if(sum((uchar*)conf, conf->length) != 0)
80103c17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c1a:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c1e:	0f b7 c0             	movzwl %ax,%eax
80103c21:	83 ec 08             	sub    $0x8,%esp
80103c24:	50                   	push   %eax
80103c25:	ff 75 f0             	push   -0x10(%ebp)
80103c28:	e8 1d fe ff ff       	call   80103a4a <sum>
80103c2d:	83 c4 10             	add    $0x10,%esp
80103c30:	84 c0                	test   %al,%al
80103c32:	74 07                	je     80103c3b <mpconfig+0x94>
    return 0;
80103c34:	b8 00 00 00 00       	mov    $0x0,%eax
80103c39:	eb 0b                	jmp    80103c46 <mpconfig+0x9f>
  *pmp = mp;
80103c3b:	8b 45 08             	mov    0x8(%ebp),%eax
80103c3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c41:	89 10                	mov    %edx,(%eax)
  return conf;
80103c43:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103c46:	c9                   	leave  
80103c47:	c3                   	ret    

80103c48 <mpinit>:

void
mpinit(void)
{
80103c48:	55                   	push   %ebp
80103c49:	89 e5                	mov    %esp,%ebp
80103c4b:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103c4e:	83 ec 0c             	sub    $0xc,%esp
80103c51:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103c54:	50                   	push   %eax
80103c55:	e8 4d ff ff ff       	call   80103ba7 <mpconfig>
80103c5a:	83 c4 10             	add    $0x10,%esp
80103c5d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c60:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c64:	75 0d                	jne    80103c73 <mpinit+0x2b>
    panic("Expect to run on an SMP");
80103c66:	83 ec 0c             	sub    $0xc,%esp
80103c69:	68 a2 89 10 80       	push   $0x801089a2
80103c6e:	e8 42 c9 ff ff       	call   801005b5 <panic>
  ismp = 1;
80103c73:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103c7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c7d:	8b 40 24             	mov    0x24(%eax),%eax
80103c80:	a3 c0 26 11 80       	mov    %eax,0x801126c0
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c85:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c88:	83 c0 2c             	add    $0x2c,%eax
80103c8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c8e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c91:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c95:	0f b7 d0             	movzwl %ax,%edx
80103c98:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c9b:	01 d0                	add    %edx,%eax
80103c9d:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103ca0:	e9 8c 00 00 00       	jmp    80103d31 <mpinit+0xe9>
    switch(*p){
80103ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca8:	0f b6 00             	movzbl (%eax),%eax
80103cab:	0f b6 c0             	movzbl %al,%eax
80103cae:	83 f8 04             	cmp    $0x4,%eax
80103cb1:	7f 76                	jg     80103d29 <mpinit+0xe1>
80103cb3:	83 f8 03             	cmp    $0x3,%eax
80103cb6:	7d 6b                	jge    80103d23 <mpinit+0xdb>
80103cb8:	83 f8 02             	cmp    $0x2,%eax
80103cbb:	74 4e                	je     80103d0b <mpinit+0xc3>
80103cbd:	83 f8 02             	cmp    $0x2,%eax
80103cc0:	7f 67                	jg     80103d29 <mpinit+0xe1>
80103cc2:	85 c0                	test   %eax,%eax
80103cc4:	74 07                	je     80103ccd <mpinit+0x85>
80103cc6:	83 f8 01             	cmp    $0x1,%eax
80103cc9:	74 58                	je     80103d23 <mpinit+0xdb>
80103ccb:	eb 5c                	jmp    80103d29 <mpinit+0xe1>
    case MPPROC:
      proc = (struct mpproc*)p;
80103ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd0:	89 45 e0             	mov    %eax,-0x20(%ebp)
      if(ncpu < NCPU) {
80103cd3:	a1 40 2d 11 80       	mov    0x80112d40,%eax
80103cd8:	83 f8 07             	cmp    $0x7,%eax
80103cdb:	7f 28                	jg     80103d05 <mpinit+0xbd>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103cdd:	8b 15 40 2d 11 80    	mov    0x80112d40,%edx
80103ce3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ce6:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103cea:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80103cf0:	81 c2 c0 27 11 80    	add    $0x801127c0,%edx
80103cf6:	88 02                	mov    %al,(%edx)
        ncpu++;
80103cf8:	a1 40 2d 11 80       	mov    0x80112d40,%eax
80103cfd:	83 c0 01             	add    $0x1,%eax
80103d00:	a3 40 2d 11 80       	mov    %eax,0x80112d40
      }
      p += sizeof(struct mpproc);
80103d05:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103d09:	eb 26                	jmp    80103d31 <mpinit+0xe9>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d0e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103d11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103d14:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d18:	a2 44 2d 11 80       	mov    %al,0x80112d44
      p += sizeof(struct mpioapic);
80103d1d:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d21:	eb 0e                	jmp    80103d31 <mpinit+0xe9>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103d23:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d27:	eb 08                	jmp    80103d31 <mpinit+0xe9>
    default:
      ismp = 0;
80103d29:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103d30:	90                   	nop
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d34:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103d37:	0f 82 68 ff ff ff    	jb     80103ca5 <mpinit+0x5d>
    }
  }
  if(!ismp)
80103d3d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d41:	75 0d                	jne    80103d50 <mpinit+0x108>
    panic("Didn't find a suitable machine");
80103d43:	83 ec 0c             	sub    $0xc,%esp
80103d46:	68 bc 89 10 80       	push   $0x801089bc
80103d4b:	e8 65 c8 ff ff       	call   801005b5 <panic>

  if(mp->imcrp){
80103d50:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d53:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103d57:	84 c0                	test   %al,%al
80103d59:	74 30                	je     80103d8b <mpinit+0x143>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103d5b:	83 ec 08             	sub    $0x8,%esp
80103d5e:	6a 70                	push   $0x70
80103d60:	6a 22                	push   $0x22
80103d62:	e8 c2 fc ff ff       	call   80103a29 <outb>
80103d67:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103d6a:	83 ec 0c             	sub    $0xc,%esp
80103d6d:	6a 23                	push   $0x23
80103d6f:	e8 98 fc ff ff       	call   80103a0c <inb>
80103d74:	83 c4 10             	add    $0x10,%esp
80103d77:	83 c8 01             	or     $0x1,%eax
80103d7a:	0f b6 c0             	movzbl %al,%eax
80103d7d:	83 ec 08             	sub    $0x8,%esp
80103d80:	50                   	push   %eax
80103d81:	6a 23                	push   $0x23
80103d83:	e8 a1 fc ff ff       	call   80103a29 <outb>
80103d88:	83 c4 10             	add    $0x10,%esp
  }
}
80103d8b:	90                   	nop
80103d8c:	c9                   	leave  
80103d8d:	c3                   	ret    

80103d8e <outb>:
{
80103d8e:	55                   	push   %ebp
80103d8f:	89 e5                	mov    %esp,%ebp
80103d91:	83 ec 08             	sub    $0x8,%esp
80103d94:	8b 45 08             	mov    0x8(%ebp),%eax
80103d97:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d9a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103d9e:	89 d0                	mov    %edx,%eax
80103da0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103da3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103da7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103dab:	ee                   	out    %al,(%dx)
}
80103dac:	90                   	nop
80103dad:	c9                   	leave  
80103dae:	c3                   	ret    

80103daf <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103daf:	55                   	push   %ebp
80103db0:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103db2:	68 ff 00 00 00       	push   $0xff
80103db7:	6a 21                	push   $0x21
80103db9:	e8 d0 ff ff ff       	call   80103d8e <outb>
80103dbe:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103dc1:	68 ff 00 00 00       	push   $0xff
80103dc6:	68 a1 00 00 00       	push   $0xa1
80103dcb:	e8 be ff ff ff       	call   80103d8e <outb>
80103dd0:	83 c4 08             	add    $0x8,%esp
}
80103dd3:	90                   	nop
80103dd4:	c9                   	leave  
80103dd5:	c3                   	ret    

80103dd6 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103dd6:	55                   	push   %ebp
80103dd7:	89 e5                	mov    %esp,%ebp
80103dd9:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103ddc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103de3:	8b 45 0c             	mov    0xc(%ebp),%eax
80103de6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103dec:	8b 45 0c             	mov    0xc(%ebp),%eax
80103def:	8b 10                	mov    (%eax),%edx
80103df1:	8b 45 08             	mov    0x8(%ebp),%eax
80103df4:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103df6:	e8 25 d2 ff ff       	call   80101020 <filealloc>
80103dfb:	8b 55 08             	mov    0x8(%ebp),%edx
80103dfe:	89 02                	mov    %eax,(%edx)
80103e00:	8b 45 08             	mov    0x8(%ebp),%eax
80103e03:	8b 00                	mov    (%eax),%eax
80103e05:	85 c0                	test   %eax,%eax
80103e07:	0f 84 c8 00 00 00    	je     80103ed5 <pipealloc+0xff>
80103e0d:	e8 0e d2 ff ff       	call   80101020 <filealloc>
80103e12:	8b 55 0c             	mov    0xc(%ebp),%edx
80103e15:	89 02                	mov    %eax,(%edx)
80103e17:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e1a:	8b 00                	mov    (%eax),%eax
80103e1c:	85 c0                	test   %eax,%eax
80103e1e:	0f 84 b1 00 00 00    	je     80103ed5 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103e24:	e8 6d ee ff ff       	call   80102c96 <kalloc>
80103e29:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e2c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e30:	0f 84 a2 00 00 00    	je     80103ed8 <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
80103e36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e39:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103e40:	00 00 00 
  p->writeopen = 1;
80103e43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e46:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103e4d:	00 00 00 
  p->nwrite = 0;
80103e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e53:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103e5a:	00 00 00 
  p->nread = 0;
80103e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e60:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103e67:	00 00 00 
  initlock(&p->lock, "pipe");
80103e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e6d:	83 ec 08             	sub    $0x8,%esp
80103e70:	68 db 89 10 80       	push   $0x801089db
80103e75:	50                   	push   %eax
80103e76:	e8 f8 13 00 00       	call   80105273 <initlock>
80103e7b:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103e7e:	8b 45 08             	mov    0x8(%ebp),%eax
80103e81:	8b 00                	mov    (%eax),%eax
80103e83:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103e89:	8b 45 08             	mov    0x8(%ebp),%eax
80103e8c:	8b 00                	mov    (%eax),%eax
80103e8e:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103e92:	8b 45 08             	mov    0x8(%ebp),%eax
80103e95:	8b 00                	mov    (%eax),%eax
80103e97:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103e9b:	8b 45 08             	mov    0x8(%ebp),%eax
80103e9e:	8b 00                	mov    (%eax),%eax
80103ea0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ea3:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103ea6:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ea9:	8b 00                	mov    (%eax),%eax
80103eab:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103eb1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103eb4:	8b 00                	mov    (%eax),%eax
80103eb6:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103eba:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ebd:	8b 00                	mov    (%eax),%eax
80103ebf:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103ec3:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ec6:	8b 00                	mov    (%eax),%eax
80103ec8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ecb:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103ece:	b8 00 00 00 00       	mov    $0x0,%eax
80103ed3:	eb 51                	jmp    80103f26 <pipealloc+0x150>
    goto bad;
80103ed5:	90                   	nop
80103ed6:	eb 01                	jmp    80103ed9 <pipealloc+0x103>
    goto bad;
80103ed8:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103ed9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103edd:	74 0e                	je     80103eed <pipealloc+0x117>
    kfree((char*)p);
80103edf:	83 ec 0c             	sub    $0xc,%esp
80103ee2:	ff 75 f4             	push   -0xc(%ebp)
80103ee5:	e8 12 ed ff ff       	call   80102bfc <kfree>
80103eea:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103eed:	8b 45 08             	mov    0x8(%ebp),%eax
80103ef0:	8b 00                	mov    (%eax),%eax
80103ef2:	85 c0                	test   %eax,%eax
80103ef4:	74 11                	je     80103f07 <pipealloc+0x131>
    fileclose(*f0);
80103ef6:	8b 45 08             	mov    0x8(%ebp),%eax
80103ef9:	8b 00                	mov    (%eax),%eax
80103efb:	83 ec 0c             	sub    $0xc,%esp
80103efe:	50                   	push   %eax
80103eff:	e8 da d1 ff ff       	call   801010de <fileclose>
80103f04:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103f07:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f0a:	8b 00                	mov    (%eax),%eax
80103f0c:	85 c0                	test   %eax,%eax
80103f0e:	74 11                	je     80103f21 <pipealloc+0x14b>
    fileclose(*f1);
80103f10:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f13:	8b 00                	mov    (%eax),%eax
80103f15:	83 ec 0c             	sub    $0xc,%esp
80103f18:	50                   	push   %eax
80103f19:	e8 c0 d1 ff ff       	call   801010de <fileclose>
80103f1e:	83 c4 10             	add    $0x10,%esp
  return -1;
80103f21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103f26:	c9                   	leave  
80103f27:	c3                   	ret    

80103f28 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103f28:	55                   	push   %ebp
80103f29:	89 e5                	mov    %esp,%ebp
80103f2b:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80103f2e:	8b 45 08             	mov    0x8(%ebp),%eax
80103f31:	83 ec 0c             	sub    $0xc,%esp
80103f34:	50                   	push   %eax
80103f35:	e8 5b 13 00 00       	call   80105295 <acquire>
80103f3a:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103f3d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103f41:	74 23                	je     80103f66 <pipeclose+0x3e>
    p->writeopen = 0;
80103f43:	8b 45 08             	mov    0x8(%ebp),%eax
80103f46:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103f4d:	00 00 00 
    wakeup(&p->nread);
80103f50:	8b 45 08             	mov    0x8(%ebp),%eax
80103f53:	05 34 02 00 00       	add    $0x234,%eax
80103f58:	83 ec 0c             	sub    $0xc,%esp
80103f5b:	50                   	push   %eax
80103f5c:	e8 78 0e 00 00       	call   80104dd9 <wakeup>
80103f61:	83 c4 10             	add    $0x10,%esp
80103f64:	eb 21                	jmp    80103f87 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80103f66:	8b 45 08             	mov    0x8(%ebp),%eax
80103f69:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103f70:	00 00 00 
    wakeup(&p->nwrite);
80103f73:	8b 45 08             	mov    0x8(%ebp),%eax
80103f76:	05 38 02 00 00       	add    $0x238,%eax
80103f7b:	83 ec 0c             	sub    $0xc,%esp
80103f7e:	50                   	push   %eax
80103f7f:	e8 55 0e 00 00       	call   80104dd9 <wakeup>
80103f84:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103f87:	8b 45 08             	mov    0x8(%ebp),%eax
80103f8a:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103f90:	85 c0                	test   %eax,%eax
80103f92:	75 2c                	jne    80103fc0 <pipeclose+0x98>
80103f94:	8b 45 08             	mov    0x8(%ebp),%eax
80103f97:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103f9d:	85 c0                	test   %eax,%eax
80103f9f:	75 1f                	jne    80103fc0 <pipeclose+0x98>
    release(&p->lock);
80103fa1:	8b 45 08             	mov    0x8(%ebp),%eax
80103fa4:	83 ec 0c             	sub    $0xc,%esp
80103fa7:	50                   	push   %eax
80103fa8:	e8 56 13 00 00       	call   80105303 <release>
80103fad:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103fb0:	83 ec 0c             	sub    $0xc,%esp
80103fb3:	ff 75 08             	push   0x8(%ebp)
80103fb6:	e8 41 ec ff ff       	call   80102bfc <kfree>
80103fbb:	83 c4 10             	add    $0x10,%esp
80103fbe:	eb 10                	jmp    80103fd0 <pipeclose+0xa8>
  } else
    release(&p->lock);
80103fc0:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc3:	83 ec 0c             	sub    $0xc,%esp
80103fc6:	50                   	push   %eax
80103fc7:	e8 37 13 00 00       	call   80105303 <release>
80103fcc:	83 c4 10             	add    $0x10,%esp
}
80103fcf:	90                   	nop
80103fd0:	90                   	nop
80103fd1:	c9                   	leave  
80103fd2:	c3                   	ret    

80103fd3 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103fd3:	55                   	push   %ebp
80103fd4:	89 e5                	mov    %esp,%ebp
80103fd6:	53                   	push   %ebx
80103fd7:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103fda:	8b 45 08             	mov    0x8(%ebp),%eax
80103fdd:	83 ec 0c             	sub    $0xc,%esp
80103fe0:	50                   	push   %eax
80103fe1:	e8 af 12 00 00       	call   80105295 <acquire>
80103fe6:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103fe9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103ff0:	e9 ad 00 00 00       	jmp    801040a2 <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80103ff5:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff8:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103ffe:	85 c0                	test   %eax,%eax
80104000:	74 0c                	je     8010400e <pipewrite+0x3b>
80104002:	e8 d3 02 00 00       	call   801042da <myproc>
80104007:	8b 40 24             	mov    0x24(%eax),%eax
8010400a:	85 c0                	test   %eax,%eax
8010400c:	74 19                	je     80104027 <pipewrite+0x54>
        release(&p->lock);
8010400e:	8b 45 08             	mov    0x8(%ebp),%eax
80104011:	83 ec 0c             	sub    $0xc,%esp
80104014:	50                   	push   %eax
80104015:	e8 e9 12 00 00       	call   80105303 <release>
8010401a:	83 c4 10             	add    $0x10,%esp
        return -1;
8010401d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104022:	e9 a9 00 00 00       	jmp    801040d0 <pipewrite+0xfd>
      }
      wakeup(&p->nread);
80104027:	8b 45 08             	mov    0x8(%ebp),%eax
8010402a:	05 34 02 00 00       	add    $0x234,%eax
8010402f:	83 ec 0c             	sub    $0xc,%esp
80104032:	50                   	push   %eax
80104033:	e8 a1 0d 00 00       	call   80104dd9 <wakeup>
80104038:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010403b:	8b 45 08             	mov    0x8(%ebp),%eax
8010403e:	8b 55 08             	mov    0x8(%ebp),%edx
80104041:	81 c2 38 02 00 00    	add    $0x238,%edx
80104047:	83 ec 08             	sub    $0x8,%esp
8010404a:	50                   	push   %eax
8010404b:	52                   	push   %edx
8010404c:	e8 8a 0c 00 00       	call   80104cdb <sleep>
80104051:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104054:	8b 45 08             	mov    0x8(%ebp),%eax
80104057:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010405d:	8b 45 08             	mov    0x8(%ebp),%eax
80104060:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104066:	05 00 02 00 00       	add    $0x200,%eax
8010406b:	39 c2                	cmp    %eax,%edx
8010406d:	74 86                	je     80103ff5 <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010406f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104072:	8b 45 0c             	mov    0xc(%ebp),%eax
80104075:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104078:	8b 45 08             	mov    0x8(%ebp),%eax
8010407b:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104081:	8d 48 01             	lea    0x1(%eax),%ecx
80104084:	8b 55 08             	mov    0x8(%ebp),%edx
80104087:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010408d:	25 ff 01 00 00       	and    $0x1ff,%eax
80104092:	89 c1                	mov    %eax,%ecx
80104094:	0f b6 13             	movzbl (%ebx),%edx
80104097:	8b 45 08             	mov    0x8(%ebp),%eax
8010409a:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
8010409e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801040a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a5:	3b 45 10             	cmp    0x10(%ebp),%eax
801040a8:	7c aa                	jl     80104054 <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801040aa:	8b 45 08             	mov    0x8(%ebp),%eax
801040ad:	05 34 02 00 00       	add    $0x234,%eax
801040b2:	83 ec 0c             	sub    $0xc,%esp
801040b5:	50                   	push   %eax
801040b6:	e8 1e 0d 00 00       	call   80104dd9 <wakeup>
801040bb:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801040be:	8b 45 08             	mov    0x8(%ebp),%eax
801040c1:	83 ec 0c             	sub    $0xc,%esp
801040c4:	50                   	push   %eax
801040c5:	e8 39 12 00 00       	call   80105303 <release>
801040ca:	83 c4 10             	add    $0x10,%esp
  return n;
801040cd:	8b 45 10             	mov    0x10(%ebp),%eax
}
801040d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801040d3:	c9                   	leave  
801040d4:	c3                   	ret    

801040d5 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801040d5:	55                   	push   %ebp
801040d6:	89 e5                	mov    %esp,%ebp
801040d8:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
801040db:	8b 45 08             	mov    0x8(%ebp),%eax
801040de:	83 ec 0c             	sub    $0xc,%esp
801040e1:	50                   	push   %eax
801040e2:	e8 ae 11 00 00       	call   80105295 <acquire>
801040e7:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801040ea:	eb 3e                	jmp    8010412a <piperead+0x55>
    if(myproc()->killed){
801040ec:	e8 e9 01 00 00       	call   801042da <myproc>
801040f1:	8b 40 24             	mov    0x24(%eax),%eax
801040f4:	85 c0                	test   %eax,%eax
801040f6:	74 19                	je     80104111 <piperead+0x3c>
      release(&p->lock);
801040f8:	8b 45 08             	mov    0x8(%ebp),%eax
801040fb:	83 ec 0c             	sub    $0xc,%esp
801040fe:	50                   	push   %eax
801040ff:	e8 ff 11 00 00       	call   80105303 <release>
80104104:	83 c4 10             	add    $0x10,%esp
      return -1;
80104107:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010410c:	e9 be 00 00 00       	jmp    801041cf <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104111:	8b 45 08             	mov    0x8(%ebp),%eax
80104114:	8b 55 08             	mov    0x8(%ebp),%edx
80104117:	81 c2 34 02 00 00    	add    $0x234,%edx
8010411d:	83 ec 08             	sub    $0x8,%esp
80104120:	50                   	push   %eax
80104121:	52                   	push   %edx
80104122:	e8 b4 0b 00 00       	call   80104cdb <sleep>
80104127:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010412a:	8b 45 08             	mov    0x8(%ebp),%eax
8010412d:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104133:	8b 45 08             	mov    0x8(%ebp),%eax
80104136:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010413c:	39 c2                	cmp    %eax,%edx
8010413e:	75 0d                	jne    8010414d <piperead+0x78>
80104140:	8b 45 08             	mov    0x8(%ebp),%eax
80104143:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104149:	85 c0                	test   %eax,%eax
8010414b:	75 9f                	jne    801040ec <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010414d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104154:	eb 48                	jmp    8010419e <piperead+0xc9>
    if(p->nread == p->nwrite)
80104156:	8b 45 08             	mov    0x8(%ebp),%eax
80104159:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010415f:	8b 45 08             	mov    0x8(%ebp),%eax
80104162:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104168:	39 c2                	cmp    %eax,%edx
8010416a:	74 3c                	je     801041a8 <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010416c:	8b 45 08             	mov    0x8(%ebp),%eax
8010416f:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104175:	8d 48 01             	lea    0x1(%eax),%ecx
80104178:	8b 55 08             	mov    0x8(%ebp),%edx
8010417b:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104181:	25 ff 01 00 00       	and    $0x1ff,%eax
80104186:	89 c1                	mov    %eax,%ecx
80104188:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010418b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010418e:	01 c2                	add    %eax,%edx
80104190:	8b 45 08             	mov    0x8(%ebp),%eax
80104193:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80104198:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010419a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010419e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041a1:	3b 45 10             	cmp    0x10(%ebp),%eax
801041a4:	7c b0                	jl     80104156 <piperead+0x81>
801041a6:	eb 01                	jmp    801041a9 <piperead+0xd4>
      break;
801041a8:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801041a9:	8b 45 08             	mov    0x8(%ebp),%eax
801041ac:	05 38 02 00 00       	add    $0x238,%eax
801041b1:	83 ec 0c             	sub    $0xc,%esp
801041b4:	50                   	push   %eax
801041b5:	e8 1f 0c 00 00       	call   80104dd9 <wakeup>
801041ba:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801041bd:	8b 45 08             	mov    0x8(%ebp),%eax
801041c0:	83 ec 0c             	sub    $0xc,%esp
801041c3:	50                   	push   %eax
801041c4:	e8 3a 11 00 00       	call   80105303 <release>
801041c9:	83 c4 10             	add    $0x10,%esp
  return i;
801041cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801041cf:	c9                   	leave  
801041d0:	c3                   	ret    

801041d1 <readeflags>:
{
801041d1:	55                   	push   %ebp
801041d2:	89 e5                	mov    %esp,%ebp
801041d4:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801041d7:	9c                   	pushf  
801041d8:	58                   	pop    %eax
801041d9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801041dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801041df:	c9                   	leave  
801041e0:	c3                   	ret    

801041e1 <sti>:
{
801041e1:	55                   	push   %ebp
801041e2:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801041e4:	fb                   	sti    
}
801041e5:	90                   	nop
801041e6:	5d                   	pop    %ebp
801041e7:	c3                   	ret    

801041e8 <update_priority>:

static void wakeup1(void *chan);

void
update_priority(struct proc *p)
{
801041e8:	55                   	push   %ebp
801041e9:	89 e5                	mov    %esp,%ebp
801041eb:	83 ec 08             	sub    $0x8,%esp
  if (p == 0) {
801041ee:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801041f2:	75 0d                	jne    80104201 <update_priority+0x19>
    panic("updatepriority: null pointer");
801041f4:	83 ec 0c             	sub    $0xc,%esp
801041f7:	68 e0 89 10 80       	push   $0x801089e0
801041fc:	e8 b4 c3 ff ff       	call   801005b5 <panic>
  }

  // calculate priority based on cpu_ticks and nice value
  // assuming lower values have higher priority
  p->priority = p->cpu_ticks / 2 + p->nice;
80104201:	8b 45 08             	mov    0x8(%ebp),%eax
80104204:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
8010420a:	89 c2                	mov    %eax,%edx
8010420c:	c1 ea 1f             	shr    $0x1f,%edx
8010420f:	01 d0                	add    %edx,%eax
80104211:	d1 f8                	sar    %eax
80104213:	89 c2                	mov    %eax,%edx
80104215:	8b 45 08             	mov    0x8(%ebp),%eax
80104218:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010421e:	01 c2                	add    %eax,%edx
80104220:	8b 45 08             	mov    0x8(%ebp),%eax
80104223:	89 50 7c             	mov    %edx,0x7c(%eax)
}
80104226:	90                   	nop
80104227:	c9                   	leave  
80104228:	c3                   	ret    

80104229 <pinit>:

void
pinit(void)
{
80104229:	55                   	push   %ebp
8010422a:	89 e5                	mov    %esp,%ebp
8010422c:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
8010422f:	83 ec 08             	sub    $0x8,%esp
80104232:	68 fd 89 10 80       	push   $0x801089fd
80104237:	68 60 2d 11 80       	push   $0x80112d60
8010423c:	e8 32 10 00 00       	call   80105273 <initlock>
80104241:	83 c4 10             	add    $0x10,%esp
}
80104244:	90                   	nop
80104245:	c9                   	leave  
80104246:	c3                   	ret    

80104247 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80104247:	55                   	push   %ebp
80104248:	89 e5                	mov    %esp,%ebp
8010424a:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
8010424d:	e8 10 00 00 00       	call   80104262 <mycpu>
80104252:	2d c0 27 11 80       	sub    $0x801127c0,%eax
80104257:	c1 f8 04             	sar    $0x4,%eax
8010425a:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80104260:	c9                   	leave  
80104261:	c3                   	ret    

80104262 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80104262:	55                   	push   %ebp
80104263:	89 e5                	mov    %esp,%ebp
80104265:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
80104268:	e8 64 ff ff ff       	call   801041d1 <readeflags>
8010426d:	25 00 02 00 00       	and    $0x200,%eax
80104272:	85 c0                	test   %eax,%eax
80104274:	74 0d                	je     80104283 <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
80104276:	83 ec 0c             	sub    $0xc,%esp
80104279:	68 04 8a 10 80       	push   $0x80108a04
8010427e:	e8 32 c3 ff ff       	call   801005b5 <panic>
  
  apicid = lapicid();
80104283:	e8 68 ed ff ff       	call   80102ff0 <lapicid>
80104288:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
8010428b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104292:	eb 2d                	jmp    801042c1 <mycpu+0x5f>
    if (cpus[i].apicid == apicid)
80104294:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104297:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010429d:	05 c0 27 11 80       	add    $0x801127c0,%eax
801042a2:	0f b6 00             	movzbl (%eax),%eax
801042a5:	0f b6 c0             	movzbl %al,%eax
801042a8:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801042ab:	75 10                	jne    801042bd <mycpu+0x5b>
      return &cpus[i];
801042ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042b0:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801042b6:	05 c0 27 11 80       	add    $0x801127c0,%eax
801042bb:	eb 1b                	jmp    801042d8 <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
801042bd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801042c1:	a1 40 2d 11 80       	mov    0x80112d40,%eax
801042c6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801042c9:	7c c9                	jl     80104294 <mycpu+0x32>
  }
  panic("unknown apicid\n");
801042cb:	83 ec 0c             	sub    $0xc,%esp
801042ce:	68 2a 8a 10 80       	push   $0x80108a2a
801042d3:	e8 dd c2 ff ff       	call   801005b5 <panic>
}
801042d8:	c9                   	leave  
801042d9:	c3                   	ret    

801042da <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
801042da:	55                   	push   %ebp
801042db:	89 e5                	mov    %esp,%ebp
801042dd:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
801042e0:	e8 2b 11 00 00       	call   80105410 <pushcli>
  c = mycpu();
801042e5:	e8 78 ff ff ff       	call   80104262 <mycpu>
801042ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
801042ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042f0:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801042f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
801042f9:	e8 5f 11 00 00       	call   8010545d <popcli>
  return p;
801042fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80104301:	c9                   	leave  
80104302:	c3                   	ret    

80104303 <recalculate_priorities>:

void recalculate_priorities(void) {
80104303:	55                   	push   %ebp
80104304:	89 e5                	mov    %esp,%ebp
80104306:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock); // Lock the process table
80104309:	83 ec 0c             	sub    $0xc,%esp
8010430c:	68 60 2d 11 80       	push   $0x80112d60
80104311:	e8 7f 0f 00 00       	call   80105295 <acquire>
80104316:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104319:	c7 45 f4 94 2d 11 80 	movl   $0x80112d94,-0xc(%ebp)
80104320:	eb 56                	jmp    80104378 <recalculate_priorities+0x75>
    if(p->state == UNUSED)
80104322:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104325:	8b 40 0c             	mov    0xc(%eax),%eax
80104328:	85 c0                	test   %eax,%eax
8010432a:	74 44                	je     80104370 <recalculate_priorities+0x6d>
      continue;

    p->cpu_ticks = p->cpu_ticks / 2; // Apply decay function
8010432c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010432f:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104335:	89 c2                	mov    %eax,%edx
80104337:	c1 ea 1f             	shr    $0x1f,%edx
8010433a:	01 d0                	add    %edx,%eax
8010433c:	d1 f8                	sar    %eax
8010433e:	89 c2                	mov    %eax,%edx
80104340:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104343:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
    p->priority = p->cpu_ticks / 2 + p->nice; // Recalculate priority
80104349:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010434c:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104352:	89 c2                	mov    %eax,%edx
80104354:	c1 ea 1f             	shr    $0x1f,%edx
80104357:	01 d0                	add    %edx,%eax
80104359:	d1 f8                	sar    %eax
8010435b:	89 c2                	mov    %eax,%edx
8010435d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104360:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104366:	01 c2                	add    %eax,%edx
80104368:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010436b:	89 50 7c             	mov    %edx,0x7c(%eax)
8010436e:	eb 01                	jmp    80104371 <recalculate_priorities+0x6e>
      continue;
80104370:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104371:	81 45 f4 8c 00 00 00 	addl   $0x8c,-0xc(%ebp)
80104378:	81 7d f4 94 50 11 80 	cmpl   $0x80115094,-0xc(%ebp)
8010437f:	72 a1                	jb     80104322 <recalculate_priorities+0x1f>
  }

  release(&ptable.lock); // Unlock the process table
80104381:	83 ec 0c             	sub    $0xc,%esp
80104384:	68 60 2d 11 80       	push   $0x80112d60
80104389:	e8 75 0f 00 00       	call   80105303 <release>
8010438e:	83 c4 10             	add    $0x10,%esp
}
80104391:	90                   	nop
80104392:	c9                   	leave  
80104393:	c3                   	ret    

80104394 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104394:	55                   	push   %ebp
80104395:	89 e5                	mov    %esp,%ebp
80104397:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
8010439a:	83 ec 0c             	sub    $0xc,%esp
8010439d:	68 60 2d 11 80       	push   $0x80112d60
801043a2:	e8 ee 0e 00 00       	call   80105295 <acquire>
801043a7:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043aa:	c7 45 f4 94 2d 11 80 	movl   $0x80112d94,-0xc(%ebp)
801043b1:	eb 11                	jmp    801043c4 <allocproc+0x30>
    if(p->state == UNUSED)
801043b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043b6:	8b 40 0c             	mov    0xc(%eax),%eax
801043b9:	85 c0                	test   %eax,%eax
801043bb:	74 2a                	je     801043e7 <allocproc+0x53>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043bd:	81 45 f4 8c 00 00 00 	addl   $0x8c,-0xc(%ebp)
801043c4:	81 7d f4 94 50 11 80 	cmpl   $0x80115094,-0xc(%ebp)
801043cb:	72 e6                	jb     801043b3 <allocproc+0x1f>
      goto found;

  release(&ptable.lock);
801043cd:	83 ec 0c             	sub    $0xc,%esp
801043d0:	68 60 2d 11 80       	push   $0x80112d60
801043d5:	e8 29 0f 00 00       	call   80105303 <release>
801043da:	83 c4 10             	add    $0x10,%esp
  return 0;
801043dd:	b8 00 00 00 00       	mov    $0x0,%eax
801043e2:	e9 d9 00 00 00       	jmp    801044c0 <allocproc+0x12c>
      goto found;
801043e7:	90                   	nop

found:
  p->state = EMBRYO;
801043e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043eb:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801043f2:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801043f7:	8d 50 01             	lea    0x1(%eax),%edx
801043fa:	89 15 00 b0 10 80    	mov    %edx,0x8010b000
80104400:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104403:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80104406:	83 ec 0c             	sub    $0xc,%esp
80104409:	68 60 2d 11 80       	push   $0x80112d60
8010440e:	e8 f0 0e 00 00       	call   80105303 <release>
80104413:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104416:	e8 7b e8 ff ff       	call   80102c96 <kalloc>
8010441b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010441e:	89 42 08             	mov    %eax,0x8(%edx)
80104421:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104424:	8b 40 08             	mov    0x8(%eax),%eax
80104427:	85 c0                	test   %eax,%eax
80104429:	75 14                	jne    8010443f <allocproc+0xab>
    p->state = UNUSED;
8010442b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104435:	b8 00 00 00 00       	mov    $0x0,%eax
8010443a:	e9 81 00 00 00       	jmp    801044c0 <allocproc+0x12c>
  }
  sp = p->kstack + KSTACKSIZE;
8010443f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104442:	8b 40 08             	mov    0x8(%eax),%eax
80104445:	05 00 10 00 00       	add    $0x1000,%eax
8010444a:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010444d:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104451:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104454:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104457:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010445a:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010445e:	ba 2c 69 10 80       	mov    $0x8010692c,%edx
80104463:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104466:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104468:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010446c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104472:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104475:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104478:	8b 40 1c             	mov    0x1c(%eax),%eax
8010447b:	83 ec 04             	sub    $0x4,%esp
8010447e:	6a 14                	push   $0x14
80104480:	6a 00                	push   $0x0
80104482:	50                   	push   %eax
80104483:	e8 93 10 00 00       	call   8010551b <memset>
80104488:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
8010448b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010448e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104491:	ba 95 4c 10 80       	mov    $0x80104c95,%edx
80104496:	89 50 10             	mov    %edx,0x10(%eax)

  p->nice = 0;       // default nice value
80104499:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010449c:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
801044a3:	00 00 00 
  p->priority = 0;   // default priority
801044a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a9:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
  p->cpu_ticks = 0;  // no CPU usage at the start
801044b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b3:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
801044ba:	00 00 00 

  return p;
801044bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801044c0:	c9                   	leave  
801044c1:	c3                   	ret    

801044c2 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801044c2:	55                   	push   %ebp
801044c3:	89 e5                	mov    %esp,%ebp
801044c5:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
801044c8:	e8 c7 fe ff ff       	call   80104394 <allocproc>
801044cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
801044d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d3:	a3 94 50 11 80       	mov    %eax,0x80115094
  if((p->pgdir = setupkvm()) == 0)
801044d8:	e8 98 39 00 00       	call   80107e75 <setupkvm>
801044dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044e0:	89 42 04             	mov    %eax,0x4(%edx)
801044e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e6:	8b 40 04             	mov    0x4(%eax),%eax
801044e9:	85 c0                	test   %eax,%eax
801044eb:	75 0d                	jne    801044fa <userinit+0x38>
    panic("userinit: out of memory?");
801044ed:	83 ec 0c             	sub    $0xc,%esp
801044f0:	68 3a 8a 10 80       	push   $0x80108a3a
801044f5:	e8 bb c0 ff ff       	call   801005b5 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801044fa:	ba 2c 00 00 00       	mov    $0x2c,%edx
801044ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104502:	8b 40 04             	mov    0x4(%eax),%eax
80104505:	83 ec 04             	sub    $0x4,%esp
80104508:	52                   	push   %edx
80104509:	68 c0 b4 10 80       	push   $0x8010b4c0
8010450e:	50                   	push   %eax
8010450f:	e8 ca 3b 00 00       	call   801080de <inituvm>
80104514:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104517:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451a:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104520:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104523:	8b 40 18             	mov    0x18(%eax),%eax
80104526:	83 ec 04             	sub    $0x4,%esp
80104529:	6a 4c                	push   $0x4c
8010452b:	6a 00                	push   $0x0
8010452d:	50                   	push   %eax
8010452e:	e8 e8 0f 00 00       	call   8010551b <memset>
80104533:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104536:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104539:	8b 40 18             	mov    0x18(%eax),%eax
8010453c:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104542:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104545:	8b 40 18             	mov    0x18(%eax),%eax
80104548:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010454e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104551:	8b 50 18             	mov    0x18(%eax),%edx
80104554:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104557:	8b 40 18             	mov    0x18(%eax),%eax
8010455a:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010455e:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104562:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104565:	8b 50 18             	mov    0x18(%eax),%edx
80104568:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010456b:	8b 40 18             	mov    0x18(%eax),%eax
8010456e:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104572:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104576:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104579:	8b 40 18             	mov    0x18(%eax),%eax
8010457c:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104583:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104586:	8b 40 18             	mov    0x18(%eax),%eax
80104589:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104590:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104593:	8b 40 18             	mov    0x18(%eax),%eax
80104596:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010459d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a0:	83 c0 6c             	add    $0x6c,%eax
801045a3:	83 ec 04             	sub    $0x4,%esp
801045a6:	6a 10                	push   $0x10
801045a8:	68 53 8a 10 80       	push   $0x80108a53
801045ad:	50                   	push   %eax
801045ae:	e8 6b 11 00 00       	call   8010571e <safestrcpy>
801045b3:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801045b6:	83 ec 0c             	sub    $0xc,%esp
801045b9:	68 5c 8a 10 80       	push   $0x80108a5c
801045be:	e8 8a df ff ff       	call   8010254d <namei>
801045c3:	83 c4 10             	add    $0x10,%esp
801045c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045c9:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
801045cc:	83 ec 0c             	sub    $0xc,%esp
801045cf:	68 60 2d 11 80       	push   $0x80112d60
801045d4:	e8 bc 0c 00 00       	call   80105295 <acquire>
801045d9:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
801045dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045df:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801045e6:	83 ec 0c             	sub    $0xc,%esp
801045e9:	68 60 2d 11 80       	push   $0x80112d60
801045ee:	e8 10 0d 00 00       	call   80105303 <release>
801045f3:	83 c4 10             	add    $0x10,%esp
}
801045f6:	90                   	nop
801045f7:	c9                   	leave  
801045f8:	c3                   	ret    

801045f9 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801045f9:	55                   	push   %ebp
801045fa:	89 e5                	mov    %esp,%ebp
801045fc:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
801045ff:	e8 d6 fc ff ff       	call   801042da <myproc>
80104604:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80104607:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010460a:	8b 00                	mov    (%eax),%eax
8010460c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010460f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104613:	7e 2e                	jle    80104643 <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104615:	8b 55 08             	mov    0x8(%ebp),%edx
80104618:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010461b:	01 c2                	add    %eax,%edx
8010461d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104620:	8b 40 04             	mov    0x4(%eax),%eax
80104623:	83 ec 04             	sub    $0x4,%esp
80104626:	52                   	push   %edx
80104627:	ff 75 f4             	push   -0xc(%ebp)
8010462a:	50                   	push   %eax
8010462b:	e8 eb 3b 00 00       	call   8010821b <allocuvm>
80104630:	83 c4 10             	add    $0x10,%esp
80104633:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104636:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010463a:	75 3b                	jne    80104677 <growproc+0x7e>
      return -1;
8010463c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104641:	eb 4f                	jmp    80104692 <growproc+0x99>
  } else if(n < 0){
80104643:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104647:	79 2e                	jns    80104677 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104649:	8b 55 08             	mov    0x8(%ebp),%edx
8010464c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010464f:	01 c2                	add    %eax,%edx
80104651:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104654:	8b 40 04             	mov    0x4(%eax),%eax
80104657:	83 ec 04             	sub    $0x4,%esp
8010465a:	52                   	push   %edx
8010465b:	ff 75 f4             	push   -0xc(%ebp)
8010465e:	50                   	push   %eax
8010465f:	e8 bc 3c 00 00       	call   80108320 <deallocuvm>
80104664:	83 c4 10             	add    $0x10,%esp
80104667:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010466a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010466e:	75 07                	jne    80104677 <growproc+0x7e>
      return -1;
80104670:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104675:	eb 1b                	jmp    80104692 <growproc+0x99>
  }
  curproc->sz = sz;
80104677:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010467a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010467d:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
8010467f:	83 ec 0c             	sub    $0xc,%esp
80104682:	ff 75 f0             	push   -0x10(%ebp)
80104685:	e8 b5 38 00 00       	call   80107f3f <switchuvm>
8010468a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010468d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104692:	c9                   	leave  
80104693:	c3                   	ret    

80104694 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104694:	55                   	push   %ebp
80104695:	89 e5                	mov    %esp,%ebp
80104697:	57                   	push   %edi
80104698:	56                   	push   %esi
80104699:	53                   	push   %ebx
8010469a:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
8010469d:	e8 38 fc ff ff       	call   801042da <myproc>
801046a2:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
801046a5:	e8 ea fc ff ff       	call   80104394 <allocproc>
801046aa:	89 45 dc             	mov    %eax,-0x24(%ebp)
801046ad:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801046b1:	75 0a                	jne    801046bd <fork+0x29>
    return -1;
801046b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046b8:	e9 48 01 00 00       	jmp    80104805 <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801046bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046c0:	8b 10                	mov    (%eax),%edx
801046c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046c5:	8b 40 04             	mov    0x4(%eax),%eax
801046c8:	83 ec 08             	sub    $0x8,%esp
801046cb:	52                   	push   %edx
801046cc:	50                   	push   %eax
801046cd:	e8 ec 3d 00 00       	call   801084be <copyuvm>
801046d2:	83 c4 10             	add    $0x10,%esp
801046d5:	8b 55 dc             	mov    -0x24(%ebp),%edx
801046d8:	89 42 04             	mov    %eax,0x4(%edx)
801046db:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046de:	8b 40 04             	mov    0x4(%eax),%eax
801046e1:	85 c0                	test   %eax,%eax
801046e3:	75 30                	jne    80104715 <fork+0x81>
    kfree(np->kstack);
801046e5:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046e8:	8b 40 08             	mov    0x8(%eax),%eax
801046eb:	83 ec 0c             	sub    $0xc,%esp
801046ee:	50                   	push   %eax
801046ef:	e8 08 e5 ff ff       	call   80102bfc <kfree>
801046f4:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801046f7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046fa:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104701:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104704:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010470b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104710:	e9 f0 00 00 00       	jmp    80104805 <fork+0x171>
  }
  np->sz = curproc->sz;
80104715:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104718:	8b 10                	mov    (%eax),%edx
8010471a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010471d:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
8010471f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104722:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104725:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80104728:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010472b:	8b 48 18             	mov    0x18(%eax),%ecx
8010472e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104731:	8b 40 18             	mov    0x18(%eax),%eax
80104734:	89 c2                	mov    %eax,%edx
80104736:	89 cb                	mov    %ecx,%ebx
80104738:	b8 13 00 00 00       	mov    $0x13,%eax
8010473d:	89 d7                	mov    %edx,%edi
8010473f:	89 de                	mov    %ebx,%esi
80104741:	89 c1                	mov    %eax,%ecx
80104743:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104745:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104748:	8b 40 18             	mov    0x18(%eax),%eax
8010474b:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104752:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104759:	eb 3b                	jmp    80104796 <fork+0x102>
    if(curproc->ofile[i])
8010475b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010475e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104761:	83 c2 08             	add    $0x8,%edx
80104764:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104768:	85 c0                	test   %eax,%eax
8010476a:	74 26                	je     80104792 <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
8010476c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010476f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104772:	83 c2 08             	add    $0x8,%edx
80104775:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104779:	83 ec 0c             	sub    $0xc,%esp
8010477c:	50                   	push   %eax
8010477d:	e8 0b c9 ff ff       	call   8010108d <filedup>
80104782:	83 c4 10             	add    $0x10,%esp
80104785:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104788:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010478b:	83 c1 08             	add    $0x8,%ecx
8010478e:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80104792:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104796:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010479a:	7e bf                	jle    8010475b <fork+0xc7>
  np->cwd = idup(curproc->cwd);
8010479c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010479f:	8b 40 68             	mov    0x68(%eax),%eax
801047a2:	83 ec 0c             	sub    $0xc,%esp
801047a5:	50                   	push   %eax
801047a6:	e8 35 d2 ff ff       	call   801019e0 <idup>
801047ab:	83 c4 10             	add    $0x10,%esp
801047ae:	8b 55 dc             	mov    -0x24(%ebp),%edx
801047b1:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801047b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047b7:	8d 50 6c             	lea    0x6c(%eax),%edx
801047ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
801047bd:	83 c0 6c             	add    $0x6c,%eax
801047c0:	83 ec 04             	sub    $0x4,%esp
801047c3:	6a 10                	push   $0x10
801047c5:	52                   	push   %edx
801047c6:	50                   	push   %eax
801047c7:	e8 52 0f 00 00       	call   8010571e <safestrcpy>
801047cc:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
801047cf:	8b 45 dc             	mov    -0x24(%ebp),%eax
801047d2:	8b 40 10             	mov    0x10(%eax),%eax
801047d5:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
801047d8:	83 ec 0c             	sub    $0xc,%esp
801047db:	68 60 2d 11 80       	push   $0x80112d60
801047e0:	e8 b0 0a 00 00       	call   80105295 <acquire>
801047e5:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
801047e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801047eb:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801047f2:	83 ec 0c             	sub    $0xc,%esp
801047f5:	68 60 2d 11 80       	push   $0x80112d60
801047fa:	e8 04 0b 00 00       	call   80105303 <release>
801047ff:	83 c4 10             	add    $0x10,%esp

  return pid;
80104802:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104805:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104808:	5b                   	pop    %ebx
80104809:	5e                   	pop    %esi
8010480a:	5f                   	pop    %edi
8010480b:	5d                   	pop    %ebp
8010480c:	c3                   	ret    

8010480d <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010480d:	55                   	push   %ebp
8010480e:	89 e5                	mov    %esp,%ebp
80104810:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104813:	e8 c2 fa ff ff       	call   801042da <myproc>
80104818:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
8010481b:	a1 94 50 11 80       	mov    0x80115094,%eax
80104820:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104823:	75 0d                	jne    80104832 <exit+0x25>
    panic("init exiting");
80104825:	83 ec 0c             	sub    $0xc,%esp
80104828:	68 5e 8a 10 80       	push   $0x80108a5e
8010482d:	e8 83 bd ff ff       	call   801005b5 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104832:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104839:	eb 3f                	jmp    8010487a <exit+0x6d>
    if(curproc->ofile[fd]){
8010483b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010483e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104841:	83 c2 08             	add    $0x8,%edx
80104844:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104848:	85 c0                	test   %eax,%eax
8010484a:	74 2a                	je     80104876 <exit+0x69>
      fileclose(curproc->ofile[fd]);
8010484c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010484f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104852:	83 c2 08             	add    $0x8,%edx
80104855:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104859:	83 ec 0c             	sub    $0xc,%esp
8010485c:	50                   	push   %eax
8010485d:	e8 7c c8 ff ff       	call   801010de <fileclose>
80104862:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80104865:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104868:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010486b:	83 c2 08             	add    $0x8,%edx
8010486e:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104875:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104876:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010487a:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010487e:	7e bb                	jle    8010483b <exit+0x2e>
    }
  }

  begin_op();
80104880:	e8 ad ec ff ff       	call   80103532 <begin_op>
  iput(curproc->cwd);
80104885:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104888:	8b 40 68             	mov    0x68(%eax),%eax
8010488b:	83 ec 0c             	sub    $0xc,%esp
8010488e:	50                   	push   %eax
8010488f:	e8 e7 d2 ff ff       	call   80101b7b <iput>
80104894:	83 c4 10             	add    $0x10,%esp
  end_op();
80104897:	e8 22 ed ff ff       	call   801035be <end_op>
  curproc->cwd = 0;
8010489c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010489f:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801048a6:	83 ec 0c             	sub    $0xc,%esp
801048a9:	68 60 2d 11 80       	push   $0x80112d60
801048ae:	e8 e2 09 00 00       	call   80105295 <acquire>
801048b3:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
801048b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801048b9:	8b 40 14             	mov    0x14(%eax),%eax
801048bc:	83 ec 0c             	sub    $0xc,%esp
801048bf:	50                   	push   %eax
801048c0:	e8 bd 04 00 00       	call   80104d82 <wakeup1>
801048c5:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048c8:	c7 45 f4 94 2d 11 80 	movl   $0x80112d94,-0xc(%ebp)
801048cf:	eb 3a                	jmp    8010490b <exit+0xfe>
    if(p->parent == curproc){
801048d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048d4:	8b 40 14             	mov    0x14(%eax),%eax
801048d7:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801048da:	75 28                	jne    80104904 <exit+0xf7>
      p->parent = initproc;
801048dc:	8b 15 94 50 11 80    	mov    0x80115094,%edx
801048e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e5:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801048e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048eb:	8b 40 0c             	mov    0xc(%eax),%eax
801048ee:	83 f8 05             	cmp    $0x5,%eax
801048f1:	75 11                	jne    80104904 <exit+0xf7>
        wakeup1(initproc);
801048f3:	a1 94 50 11 80       	mov    0x80115094,%eax
801048f8:	83 ec 0c             	sub    $0xc,%esp
801048fb:	50                   	push   %eax
801048fc:	e8 81 04 00 00       	call   80104d82 <wakeup1>
80104901:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104904:	81 45 f4 8c 00 00 00 	addl   $0x8c,-0xc(%ebp)
8010490b:	81 7d f4 94 50 11 80 	cmpl   $0x80115094,-0xc(%ebp)
80104912:	72 bd                	jb     801048d1 <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104914:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104917:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010491e:	e8 7f 02 00 00       	call   80104ba2 <sched>
  panic("zombie exit");
80104923:	83 ec 0c             	sub    $0xc,%esp
80104926:	68 6b 8a 10 80       	push   $0x80108a6b
8010492b:	e8 85 bc ff ff       	call   801005b5 <panic>

80104930 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104930:	55                   	push   %ebp
80104931:	89 e5                	mov    %esp,%ebp
80104933:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104936:	e8 9f f9 ff ff       	call   801042da <myproc>
8010493b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
8010493e:	83 ec 0c             	sub    $0xc,%esp
80104941:	68 60 2d 11 80       	push   $0x80112d60
80104946:	e8 4a 09 00 00       	call   80105295 <acquire>
8010494b:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
8010494e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104955:	c7 45 f4 94 2d 11 80 	movl   $0x80112d94,-0xc(%ebp)
8010495c:	e9 a4 00 00 00       	jmp    80104a05 <wait+0xd5>
      if(p->parent != curproc)
80104961:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104964:	8b 40 14             	mov    0x14(%eax),%eax
80104967:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010496a:	0f 85 8d 00 00 00    	jne    801049fd <wait+0xcd>
        continue;
      havekids = 1;
80104970:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010497a:	8b 40 0c             	mov    0xc(%eax),%eax
8010497d:	83 f8 05             	cmp    $0x5,%eax
80104980:	75 7c                	jne    801049fe <wait+0xce>
        // Found one.
        pid = p->pid;
80104982:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104985:	8b 40 10             	mov    0x10(%eax),%eax
80104988:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
8010498b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010498e:	8b 40 08             	mov    0x8(%eax),%eax
80104991:	83 ec 0c             	sub    $0xc,%esp
80104994:	50                   	push   %eax
80104995:	e8 62 e2 ff ff       	call   80102bfc <kfree>
8010499a:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010499d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801049a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049aa:	8b 40 04             	mov    0x4(%eax),%eax
801049ad:	83 ec 0c             	sub    $0xc,%esp
801049b0:	50                   	push   %eax
801049b1:	e8 2e 3a 00 00       	call   801083e4 <freevm>
801049b6:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
801049b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049bc:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801049c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c6:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801049cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049d0:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801049d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049d7:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
801049de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049e1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
801049e8:	83 ec 0c             	sub    $0xc,%esp
801049eb:	68 60 2d 11 80       	push   $0x80112d60
801049f0:	e8 0e 09 00 00       	call   80105303 <release>
801049f5:	83 c4 10             	add    $0x10,%esp
        return pid;
801049f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801049fb:	eb 54                	jmp    80104a51 <wait+0x121>
        continue;
801049fd:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049fe:	81 45 f4 8c 00 00 00 	addl   $0x8c,-0xc(%ebp)
80104a05:	81 7d f4 94 50 11 80 	cmpl   $0x80115094,-0xc(%ebp)
80104a0c:	0f 82 4f ff ff ff    	jb     80104961 <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104a12:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104a16:	74 0a                	je     80104a22 <wait+0xf2>
80104a18:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a1b:	8b 40 24             	mov    0x24(%eax),%eax
80104a1e:	85 c0                	test   %eax,%eax
80104a20:	74 17                	je     80104a39 <wait+0x109>
      release(&ptable.lock);
80104a22:	83 ec 0c             	sub    $0xc,%esp
80104a25:	68 60 2d 11 80       	push   $0x80112d60
80104a2a:	e8 d4 08 00 00       	call   80105303 <release>
80104a2f:	83 c4 10             	add    $0x10,%esp
      return -1;
80104a32:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a37:	eb 18                	jmp    80104a51 <wait+0x121>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104a39:	83 ec 08             	sub    $0x8,%esp
80104a3c:	68 60 2d 11 80       	push   $0x80112d60
80104a41:	ff 75 ec             	push   -0x14(%ebp)
80104a44:	e8 92 02 00 00       	call   80104cdb <sleep>
80104a49:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104a4c:	e9 fd fe ff ff       	jmp    8010494e <wait+0x1e>
  }
}
80104a51:	c9                   	leave  
80104a52:	c3                   	ret    

80104a53 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104a53:	55                   	push   %ebp
80104a54:	89 e5                	mov    %esp,%ebp
80104a56:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104a59:	e8 04 f8 ff ff       	call   80104262 <mycpu>
80104a5e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  c->proc = 0;
80104a61:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104a64:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104a6b:	00 00 00 

  int last_recalc_ticks = -1;
80104a6e:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104a75:	e8 67 f7 ff ff       	call   801041e1 <sti>
    if (ticks % 100 == 0 && ticks != last_recalc_ticks) {
80104a7a:	8b 0d d4 58 11 80    	mov    0x801158d4,%ecx
80104a80:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
80104a85:	89 c8                	mov    %ecx,%eax
80104a87:	f7 e2                	mul    %edx
80104a89:	89 d0                	mov    %edx,%eax
80104a8b:	c1 e8 05             	shr    $0x5,%eax
80104a8e:	6b d0 64             	imul   $0x64,%eax,%edx
80104a91:	89 c8                	mov    %ecx,%eax
80104a93:	29 d0                	sub    %edx,%eax
80104a95:	85 c0                	test   %eax,%eax
80104a97:	75 1a                	jne    80104ab3 <scheduler+0x60>
80104a99:	8b 15 d4 58 11 80    	mov    0x801158d4,%edx
80104a9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104aa2:	39 c2                	cmp    %eax,%edx
80104aa4:	74 0d                	je     80104ab3 <scheduler+0x60>
      // cprintf("recalculating priorities!\n");
      recalculate_priorities();
80104aa6:	e8 58 f8 ff ff       	call   80104303 <recalculate_priorities>
      last_recalc_ticks = ticks;
80104aab:	a1 d4 58 11 80       	mov    0x801158d4,%eax
80104ab0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104ab3:	83 ec 0c             	sub    $0xc,%esp
80104ab6:	68 60 2d 11 80       	push   $0x80112d60
80104abb:	e8 d5 07 00 00       	call   80105295 <acquire>
80104ac0:	83 c4 10             	add    $0x10,%esp

    int highestPrio = 1000000;  // Initialize as null pointer
80104ac3:	c7 45 ec 40 42 0f 00 	movl   $0xf4240,-0x14(%ebp)
    struct proc *selected = 0;
80104aca:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ad1:	c7 45 f4 94 2d 11 80 	movl   $0x80112d94,-0xc(%ebp)
80104ad8:	eb 40                	jmp    80104b1a <scheduler+0xc7>
      if(p->state != RUNNABLE)
80104ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104add:	8b 40 0c             	mov    0xc(%eax),%eax
80104ae0:	83 f8 03             	cmp    $0x3,%eax
80104ae3:	75 2d                	jne    80104b12 <scheduler+0xbf>
        continue;
      // Check for the process with the highest priority
      if((highestPrio == 1000000 || p->priority <= highestPrio) && p != selected){
80104ae5:	81 7d ec 40 42 0f 00 	cmpl   $0xf4240,-0x14(%ebp)
80104aec:	74 0b                	je     80104af9 <scheduler+0xa6>
80104aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af1:	8b 40 7c             	mov    0x7c(%eax),%eax
80104af4:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104af7:	7c 1a                	jl     80104b13 <scheduler+0xc0>
80104af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104afc:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80104aff:	74 12                	je     80104b13 <scheduler+0xc0>
        highestPrio = p->priority;
80104b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b04:	8b 40 7c             	mov    0x7c(%eax),%eax
80104b07:	89 45 ec             	mov    %eax,-0x14(%ebp)
        selected = p;
80104b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b0d:	89 45 e8             	mov    %eax,-0x18(%ebp)
80104b10:	eb 01                	jmp    80104b13 <scheduler+0xc0>
        continue;
80104b12:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b13:	81 45 f4 8c 00 00 00 	addl   $0x8c,-0xc(%ebp)
80104b1a:	81 7d f4 94 50 11 80 	cmpl   $0x80115094,-0xc(%ebp)
80104b21:	72 b7                	jb     80104ada <scheduler+0x87>
      }
    }


    if(selected != 0){
80104b23:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80104b27:	74 64                	je     80104b8d <scheduler+0x13a>

      // Switch to chosen process. It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = selected;
80104b29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104b2c:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104b2f:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      selected->cpu_ticks++;
80104b35:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104b38:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104b3e:	8d 50 01             	lea    0x1(%eax),%edx
80104b41:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104b44:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
      // cprintf("%d\n", highPrioProc->cpu_ticks);
      // cprintf("%d\n", highPrioProc->priority);

      switchuvm(selected);
80104b4a:	83 ec 0c             	sub    $0xc,%esp
80104b4d:	ff 75 e8             	push   -0x18(%ebp)
80104b50:	e8 ea 33 00 00       	call   80107f3f <switchuvm>
80104b55:	83 c4 10             	add    $0x10,%esp
      selected->state = RUNNING;
80104b58:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104b5b:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), selected->context);
80104b62:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104b65:	8b 40 1c             	mov    0x1c(%eax),%eax
80104b68:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104b6b:	83 c2 04             	add    $0x4,%edx
80104b6e:	83 ec 08             	sub    $0x8,%esp
80104b71:	50                   	push   %eax
80104b72:	52                   	push   %edx
80104b73:	e8 18 0c 00 00       	call   80105790 <swtch>
80104b78:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104b7b:	e8 a6 33 00 00       	call   80107f26 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104b80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104b83:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104b8a:	00 00 00 
    }
    release(&ptable.lock);
80104b8d:	83 ec 0c             	sub    $0xc,%esp
80104b90:	68 60 2d 11 80       	push   $0x80112d60
80104b95:	e8 69 07 00 00       	call   80105303 <release>
80104b9a:	83 c4 10             	add    $0x10,%esp
  for(;;){
80104b9d:	e9 d3 fe ff ff       	jmp    80104a75 <scheduler+0x22>

80104ba2 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104ba2:	55                   	push   %ebp
80104ba3:	89 e5                	mov    %esp,%ebp
80104ba5:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104ba8:	e8 2d f7 ff ff       	call   801042da <myproc>
80104bad:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104bb0:	83 ec 0c             	sub    $0xc,%esp
80104bb3:	68 60 2d 11 80       	push   $0x80112d60
80104bb8:	e8 13 08 00 00       	call   801053d0 <holding>
80104bbd:	83 c4 10             	add    $0x10,%esp
80104bc0:	85 c0                	test   %eax,%eax
80104bc2:	75 0d                	jne    80104bd1 <sched+0x2f>
    panic("sched ptable.lock");
80104bc4:	83 ec 0c             	sub    $0xc,%esp
80104bc7:	68 77 8a 10 80       	push   $0x80108a77
80104bcc:	e8 e4 b9 ff ff       	call   801005b5 <panic>
  if(mycpu()->ncli != 1)
80104bd1:	e8 8c f6 ff ff       	call   80104262 <mycpu>
80104bd6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104bdc:	83 f8 01             	cmp    $0x1,%eax
80104bdf:	74 0d                	je     80104bee <sched+0x4c>
    panic("sched locks");
80104be1:	83 ec 0c             	sub    $0xc,%esp
80104be4:	68 89 8a 10 80       	push   $0x80108a89
80104be9:	e8 c7 b9 ff ff       	call   801005b5 <panic>
  if(p->state == RUNNING)
80104bee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf1:	8b 40 0c             	mov    0xc(%eax),%eax
80104bf4:	83 f8 04             	cmp    $0x4,%eax
80104bf7:	75 0d                	jne    80104c06 <sched+0x64>
    panic("sched running");
80104bf9:	83 ec 0c             	sub    $0xc,%esp
80104bfc:	68 95 8a 10 80       	push   $0x80108a95
80104c01:	e8 af b9 ff ff       	call   801005b5 <panic>
  if(readeflags()&FL_IF)
80104c06:	e8 c6 f5 ff ff       	call   801041d1 <readeflags>
80104c0b:	25 00 02 00 00       	and    $0x200,%eax
80104c10:	85 c0                	test   %eax,%eax
80104c12:	74 0d                	je     80104c21 <sched+0x7f>
    panic("sched interruptible");
80104c14:	83 ec 0c             	sub    $0xc,%esp
80104c17:	68 a3 8a 10 80       	push   $0x80108aa3
80104c1c:	e8 94 b9 ff ff       	call   801005b5 <panic>
  intena = mycpu()->intena;
80104c21:	e8 3c f6 ff ff       	call   80104262 <mycpu>
80104c26:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104c2c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104c2f:	e8 2e f6 ff ff       	call   80104262 <mycpu>
80104c34:	8b 40 04             	mov    0x4(%eax),%eax
80104c37:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c3a:	83 c2 1c             	add    $0x1c,%edx
80104c3d:	83 ec 08             	sub    $0x8,%esp
80104c40:	50                   	push   %eax
80104c41:	52                   	push   %edx
80104c42:	e8 49 0b 00 00       	call   80105790 <swtch>
80104c47:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104c4a:	e8 13 f6 ff ff       	call   80104262 <mycpu>
80104c4f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104c52:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104c58:	90                   	nop
80104c59:	c9                   	leave  
80104c5a:	c3                   	ret    

80104c5b <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104c5b:	55                   	push   %ebp
80104c5c:	89 e5                	mov    %esp,%ebp
80104c5e:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104c61:	83 ec 0c             	sub    $0xc,%esp
80104c64:	68 60 2d 11 80       	push   $0x80112d60
80104c69:	e8 27 06 00 00       	call   80105295 <acquire>
80104c6e:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104c71:	e8 64 f6 ff ff       	call   801042da <myproc>
80104c76:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104c7d:	e8 20 ff ff ff       	call   80104ba2 <sched>
  release(&ptable.lock);
80104c82:	83 ec 0c             	sub    $0xc,%esp
80104c85:	68 60 2d 11 80       	push   $0x80112d60
80104c8a:	e8 74 06 00 00       	call   80105303 <release>
80104c8f:	83 c4 10             	add    $0x10,%esp
}
80104c92:	90                   	nop
80104c93:	c9                   	leave  
80104c94:	c3                   	ret    

80104c95 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104c95:	55                   	push   %ebp
80104c96:	89 e5                	mov    %esp,%ebp
80104c98:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104c9b:	83 ec 0c             	sub    $0xc,%esp
80104c9e:	68 60 2d 11 80       	push   $0x80112d60
80104ca3:	e8 5b 06 00 00       	call   80105303 <release>
80104ca8:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104cab:	a1 04 b0 10 80       	mov    0x8010b004,%eax
80104cb0:	85 c0                	test   %eax,%eax
80104cb2:	74 24                	je     80104cd8 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104cb4:	c7 05 04 b0 10 80 00 	movl   $0x0,0x8010b004
80104cbb:	00 00 00 
    iinit(ROOTDEV);
80104cbe:	83 ec 0c             	sub    $0xc,%esp
80104cc1:	6a 01                	push   $0x1
80104cc3:	e8 e0 c9 ff ff       	call   801016a8 <iinit>
80104cc8:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104ccb:	83 ec 0c             	sub    $0xc,%esp
80104cce:	6a 01                	push   $0x1
80104cd0:	e8 3e e6 ff ff       	call   80103313 <initlog>
80104cd5:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104cd8:	90                   	nop
80104cd9:	c9                   	leave  
80104cda:	c3                   	ret    

80104cdb <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104cdb:	55                   	push   %ebp
80104cdc:	89 e5                	mov    %esp,%ebp
80104cde:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104ce1:	e8 f4 f5 ff ff       	call   801042da <myproc>
80104ce6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104ce9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104ced:	75 0d                	jne    80104cfc <sleep+0x21>
    panic("sleep");
80104cef:	83 ec 0c             	sub    $0xc,%esp
80104cf2:	68 b7 8a 10 80       	push   $0x80108ab7
80104cf7:	e8 b9 b8 ff ff       	call   801005b5 <panic>

  if(lk == 0)
80104cfc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104d00:	75 0d                	jne    80104d0f <sleep+0x34>
    panic("sleep without lk");
80104d02:	83 ec 0c             	sub    $0xc,%esp
80104d05:	68 bd 8a 10 80       	push   $0x80108abd
80104d0a:	e8 a6 b8 ff ff       	call   801005b5 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104d0f:	81 7d 0c 60 2d 11 80 	cmpl   $0x80112d60,0xc(%ebp)
80104d16:	74 1e                	je     80104d36 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104d18:	83 ec 0c             	sub    $0xc,%esp
80104d1b:	68 60 2d 11 80       	push   $0x80112d60
80104d20:	e8 70 05 00 00       	call   80105295 <acquire>
80104d25:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104d28:	83 ec 0c             	sub    $0xc,%esp
80104d2b:	ff 75 0c             	push   0xc(%ebp)
80104d2e:	e8 d0 05 00 00       	call   80105303 <release>
80104d33:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104d36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d39:	8b 55 08             	mov    0x8(%ebp),%edx
80104d3c:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104d3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d42:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104d49:	e8 54 fe ff ff       	call   80104ba2 <sched>

  // Tidy up.
  p->chan = 0;
80104d4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d51:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104d58:	81 7d 0c 60 2d 11 80 	cmpl   $0x80112d60,0xc(%ebp)
80104d5f:	74 1e                	je     80104d7f <sleep+0xa4>
    release(&ptable.lock);
80104d61:	83 ec 0c             	sub    $0xc,%esp
80104d64:	68 60 2d 11 80       	push   $0x80112d60
80104d69:	e8 95 05 00 00       	call   80105303 <release>
80104d6e:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104d71:	83 ec 0c             	sub    $0xc,%esp
80104d74:	ff 75 0c             	push   0xc(%ebp)
80104d77:	e8 19 05 00 00       	call   80105295 <acquire>
80104d7c:	83 c4 10             	add    $0x10,%esp
  }
}
80104d7f:	90                   	nop
80104d80:	c9                   	leave  
80104d81:	c3                   	ret    

80104d82 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104d82:	55                   	push   %ebp
80104d83:	89 e5                	mov    %esp,%ebp
80104d85:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104d88:	c7 45 fc 94 2d 11 80 	movl   $0x80112d94,-0x4(%ebp)
80104d8f:	eb 3b                	jmp    80104dcc <wakeup1+0x4a>
    if(p->state == SLEEPING && p->chan == chan && p->wakeup_tick <= ticks)
80104d91:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d94:	8b 40 0c             	mov    0xc(%eax),%eax
80104d97:	83 f8 02             	cmp    $0x2,%eax
80104d9a:	75 29                	jne    80104dc5 <wakeup1+0x43>
80104d9c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d9f:	8b 40 20             	mov    0x20(%eax),%eax
80104da2:	39 45 08             	cmp    %eax,0x8(%ebp)
80104da5:	75 1e                	jne    80104dc5 <wakeup1+0x43>
80104da7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104daa:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80104db0:	89 c2                	mov    %eax,%edx
80104db2:	a1 d4 58 11 80       	mov    0x801158d4,%eax
80104db7:	39 c2                	cmp    %eax,%edx
80104db9:	77 0a                	ja     80104dc5 <wakeup1+0x43>
      p->state = RUNNABLE;
80104dbb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dbe:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104dc5:	81 45 fc 8c 00 00 00 	addl   $0x8c,-0x4(%ebp)
80104dcc:	81 7d fc 94 50 11 80 	cmpl   $0x80115094,-0x4(%ebp)
80104dd3:	72 bc                	jb     80104d91 <wakeup1+0xf>
}
80104dd5:	90                   	nop
80104dd6:	90                   	nop
80104dd7:	c9                   	leave  
80104dd8:	c3                   	ret    

80104dd9 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104dd9:	55                   	push   %ebp
80104dda:	89 e5                	mov    %esp,%ebp
80104ddc:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104ddf:	83 ec 0c             	sub    $0xc,%esp
80104de2:	68 60 2d 11 80       	push   $0x80112d60
80104de7:	e8 a9 04 00 00       	call   80105295 <acquire>
80104dec:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104def:	83 ec 0c             	sub    $0xc,%esp
80104df2:	ff 75 08             	push   0x8(%ebp)
80104df5:	e8 88 ff ff ff       	call   80104d82 <wakeup1>
80104dfa:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104dfd:	83 ec 0c             	sub    $0xc,%esp
80104e00:	68 60 2d 11 80       	push   $0x80112d60
80104e05:	e8 f9 04 00 00       	call   80105303 <release>
80104e0a:	83 c4 10             	add    $0x10,%esp
}
80104e0d:	90                   	nop
80104e0e:	c9                   	leave  
80104e0f:	c3                   	ret    

80104e10 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104e10:	55                   	push   %ebp
80104e11:	89 e5                	mov    %esp,%ebp
80104e13:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104e16:	83 ec 0c             	sub    $0xc,%esp
80104e19:	68 60 2d 11 80       	push   $0x80112d60
80104e1e:	e8 72 04 00 00       	call   80105295 <acquire>
80104e23:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e26:	c7 45 f4 94 2d 11 80 	movl   $0x80112d94,-0xc(%ebp)
80104e2d:	eb 48                	jmp    80104e77 <kill+0x67>
    if(p->pid == pid){
80104e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e32:	8b 40 10             	mov    0x10(%eax),%eax
80104e35:	39 45 08             	cmp    %eax,0x8(%ebp)
80104e38:	75 36                	jne    80104e70 <kill+0x60>
      p->killed = 1;
80104e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e3d:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e47:	8b 40 0c             	mov    0xc(%eax),%eax
80104e4a:	83 f8 02             	cmp    $0x2,%eax
80104e4d:	75 0a                	jne    80104e59 <kill+0x49>
        p->state = RUNNABLE;
80104e4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e52:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104e59:	83 ec 0c             	sub    $0xc,%esp
80104e5c:	68 60 2d 11 80       	push   $0x80112d60
80104e61:	e8 9d 04 00 00       	call   80105303 <release>
80104e66:	83 c4 10             	add    $0x10,%esp
      return 0;
80104e69:	b8 00 00 00 00       	mov    $0x0,%eax
80104e6e:	eb 25                	jmp    80104e95 <kill+0x85>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e70:	81 45 f4 8c 00 00 00 	addl   $0x8c,-0xc(%ebp)
80104e77:	81 7d f4 94 50 11 80 	cmpl   $0x80115094,-0xc(%ebp)
80104e7e:	72 af                	jb     80104e2f <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104e80:	83 ec 0c             	sub    $0xc,%esp
80104e83:	68 60 2d 11 80       	push   $0x80112d60
80104e88:	e8 76 04 00 00       	call   80105303 <release>
80104e8d:	83 c4 10             	add    $0x10,%esp
  return -1;
80104e90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104e95:	c9                   	leave  
80104e96:	c3                   	ret    

80104e97 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104e97:	55                   	push   %ebp
80104e98:	89 e5                	mov    %esp,%ebp
80104e9a:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e9d:	c7 45 f0 94 2d 11 80 	movl   $0x80112d94,-0x10(%ebp)
80104ea4:	e9 da 00 00 00       	jmp    80104f83 <procdump+0xec>
    if(p->state == UNUSED)
80104ea9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104eac:	8b 40 0c             	mov    0xc(%eax),%eax
80104eaf:	85 c0                	test   %eax,%eax
80104eb1:	0f 84 c4 00 00 00    	je     80104f7b <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104eb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104eba:	8b 40 0c             	mov    0xc(%eax),%eax
80104ebd:	83 f8 05             	cmp    $0x5,%eax
80104ec0:	77 23                	ja     80104ee5 <procdump+0x4e>
80104ec2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ec5:	8b 40 0c             	mov    0xc(%eax),%eax
80104ec8:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104ecf:	85 c0                	test   %eax,%eax
80104ed1:	74 12                	je     80104ee5 <procdump+0x4e>
      state = states[p->state];
80104ed3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ed6:	8b 40 0c             	mov    0xc(%eax),%eax
80104ed9:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104ee0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104ee3:	eb 07                	jmp    80104eec <procdump+0x55>
    else
      state = "???";
80104ee5:	c7 45 ec ce 8a 10 80 	movl   $0x80108ace,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104eec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104eef:	8d 50 6c             	lea    0x6c(%eax),%edx
80104ef2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ef5:	8b 40 10             	mov    0x10(%eax),%eax
80104ef8:	52                   	push   %edx
80104ef9:	ff 75 ec             	push   -0x14(%ebp)
80104efc:	50                   	push   %eax
80104efd:	68 d2 8a 10 80       	push   $0x80108ad2
80104f02:	e8 f9 b4 ff ff       	call   80100400 <cprintf>
80104f07:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104f0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f0d:	8b 40 0c             	mov    0xc(%eax),%eax
80104f10:	83 f8 02             	cmp    $0x2,%eax
80104f13:	75 54                	jne    80104f69 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104f15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f18:	8b 40 1c             	mov    0x1c(%eax),%eax
80104f1b:	8b 40 0c             	mov    0xc(%eax),%eax
80104f1e:	83 c0 08             	add    $0x8,%eax
80104f21:	89 c2                	mov    %eax,%edx
80104f23:	83 ec 08             	sub    $0x8,%esp
80104f26:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104f29:	50                   	push   %eax
80104f2a:	52                   	push   %edx
80104f2b:	e8 25 04 00 00       	call   80105355 <getcallerpcs>
80104f30:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104f33:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104f3a:	eb 1c                	jmp    80104f58 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104f3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f3f:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104f43:	83 ec 08             	sub    $0x8,%esp
80104f46:	50                   	push   %eax
80104f47:	68 db 8a 10 80       	push   $0x80108adb
80104f4c:	e8 af b4 ff ff       	call   80100400 <cprintf>
80104f51:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104f54:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104f58:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104f5c:	7f 0b                	jg     80104f69 <procdump+0xd2>
80104f5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f61:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104f65:	85 c0                	test   %eax,%eax
80104f67:	75 d3                	jne    80104f3c <procdump+0xa5>
    }
    cprintf("\n");
80104f69:	83 ec 0c             	sub    $0xc,%esp
80104f6c:	68 df 8a 10 80       	push   $0x80108adf
80104f71:	e8 8a b4 ff ff       	call   80100400 <cprintf>
80104f76:	83 c4 10             	add    $0x10,%esp
80104f79:	eb 01                	jmp    80104f7c <procdump+0xe5>
      continue;
80104f7b:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f7c:	81 45 f0 8c 00 00 00 	addl   $0x8c,-0x10(%ebp)
80104f83:	81 7d f0 94 50 11 80 	cmpl   $0x80115094,-0x10(%ebp)
80104f8a:	0f 82 19 ff ff ff    	jb     80104ea9 <procdump+0x12>
  }
}
80104f90:	90                   	nop
80104f91:	90                   	nop
80104f92:	c9                   	leave  
80104f93:	c3                   	ret    

80104f94 <nice>:

int
nice(int n)
{
80104f94:	55                   	push   %ebp
80104f95:	89 e5                	mov    %esp,%ebp
80104f97:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104f9a:	e8 3b f3 ff ff       	call   801042da <myproc>
80104f9f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  acquire(&ptable.lock);
80104fa2:	83 ec 0c             	sub    $0xc,%esp
80104fa5:	68 60 2d 11 80       	push   $0x80112d60
80104faa:	e8 e6 02 00 00       	call   80105295 <acquire>
80104faf:	83 c4 10             	add    $0x10,%esp

  if(n < 0 || n > 20){
80104fb2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104fb6:	78 06                	js     80104fbe <nice+0x2a>
80104fb8:	83 7d 08 14          	cmpl   $0x14,0x8(%ebp)
80104fbc:	7e 17                	jle    80104fd5 <nice+0x41>
    release(&ptable.lock);
80104fbe:	83 ec 0c             	sub    $0xc,%esp
80104fc1:	68 60 2d 11 80       	push   $0x80112d60
80104fc6:	e8 38 03 00 00       	call   80105303 <release>
80104fcb:	83 c4 10             	add    $0x10,%esp
    return -1; // outside the valid range
80104fce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fd3:	eb 2b                	jmp    80105000 <nice+0x6c>
  }

  int previous_nice = curproc->nice;
80104fd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fd8:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104fde:	89 45 f0             	mov    %eax,-0x10(%ebp)
  curproc->nice = n;
80104fe1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fe4:	8b 55 08             	mov    0x8(%ebp),%edx
80104fe7:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

  release(&ptable.lock);
80104fed:	83 ec 0c             	sub    $0xc,%esp
80104ff0:	68 60 2d 11 80       	push   $0x80112d60
80104ff5:	e8 09 03 00 00       	call   80105303 <release>
80104ffa:	83 c4 10             	add    $0x10,%esp

  return previous_nice; // for success
80104ffd:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105000:	c9                   	leave  
80105001:	c3                   	ret    

80105002 <getschedstate>:

int
getschedstate(struct pschedinfo *psi)
{
80105002:	55                   	push   %ebp
80105003:	89 e5                	mov    %esp,%ebp
80105005:	83 ec 18             	sub    $0x18,%esp
    if(psi == 0) {
80105008:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010500c:	75 0a                	jne    80105018 <getschedstate+0x16>
        return -1; // return error if bad pointer
8010500e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105013:	e9 d6 00 00 00       	jmp    801050ee <getschedstate+0xec>
    }

    acquire(&ptable.lock); // protect against concurrent modifications
80105018:	83 ec 0c             	sub    $0xc,%esp
8010501b:	68 60 2d 11 80       	push   $0x80112d60
80105020:	e8 70 02 00 00       	call   80105295 <acquire>
80105025:	83 c4 10             	add    $0x10,%esp

    for(int i = 0; i < NPROC; i++) {
80105028:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010502f:	e9 9b 00 00 00       	jmp    801050cf <getschedstate+0xcd>
        psi->inuse[i] = ptable.proc[i].state != UNUSED;
80105034:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105037:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
8010503d:	05 a0 2d 11 80       	add    $0x80112da0,%eax
80105042:	8b 00                	mov    (%eax),%eax
80105044:	85 c0                	test   %eax,%eax
80105046:	0f 95 c0             	setne  %al
80105049:	0f b6 c8             	movzbl %al,%ecx
8010504c:	8b 45 08             	mov    0x8(%ebp),%eax
8010504f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105052:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
        psi->priority[i] = ptable.proc[i].priority;
80105055:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105058:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
8010505e:	05 10 2e 11 80       	add    $0x80112e10,%eax
80105063:	8b 10                	mov    (%eax),%edx
80105065:	8b 45 08             	mov    0x8(%ebp),%eax
80105068:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010506b:	83 c1 40             	add    $0x40,%ecx
8010506e:	89 14 88             	mov    %edx,(%eax,%ecx,4)
        psi->nice[i] = ptable.proc[i].nice;
80105071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105074:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
8010507a:	05 14 2e 11 80       	add    $0x80112e14,%eax
8010507f:	8b 10                	mov    (%eax),%edx
80105081:	8b 45 08             	mov    0x8(%ebp),%eax
80105084:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80105087:	83 e9 80             	sub    $0xffffff80,%ecx
8010508a:	89 14 88             	mov    %edx,(%eax,%ecx,4)
        psi->pid[i] = ptable.proc[i].pid;
8010508d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105090:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
80105096:	05 a4 2d 11 80       	add    $0x80112da4,%eax
8010509b:	8b 10                	mov    (%eax),%edx
8010509d:	8b 45 08             	mov    0x8(%ebp),%eax
801050a0:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801050a3:	81 c1 c0 00 00 00    	add    $0xc0,%ecx
801050a9:	89 14 88             	mov    %edx,(%eax,%ecx,4)
        psi->ticks[i] = ptable.proc[i].cpu_ticks;
801050ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050af:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
801050b5:	05 18 2e 11 80       	add    $0x80112e18,%eax
801050ba:	8b 10                	mov    (%eax),%edx
801050bc:	8b 45 08             	mov    0x8(%ebp),%eax
801050bf:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801050c2:	81 c1 00 01 00 00    	add    $0x100,%ecx
801050c8:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    for(int i = 0; i < NPROC; i++) {
801050cb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801050cf:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801050d3:	0f 8e 5b ff ff ff    	jle    80105034 <getschedstate+0x32>
    }

    release(&ptable.lock);
801050d9:	83 ec 0c             	sub    $0xc,%esp
801050dc:	68 60 2d 11 80       	push   $0x80112d60
801050e1:	e8 1d 02 00 00       	call   80105303 <release>
801050e6:	83 c4 10             	add    $0x10,%esp

    return 0;
801050e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801050ee:	c9                   	leave  
801050ef:	c3                   	ret    

801050f0 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801050f0:	55                   	push   %ebp
801050f1:	89 e5                	mov    %esp,%ebp
801050f3:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
801050f6:	8b 45 08             	mov    0x8(%ebp),%eax
801050f9:	83 c0 04             	add    $0x4,%eax
801050fc:	83 ec 08             	sub    $0x8,%esp
801050ff:	68 0b 8b 10 80       	push   $0x80108b0b
80105104:	50                   	push   %eax
80105105:	e8 69 01 00 00       	call   80105273 <initlock>
8010510a:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
8010510d:	8b 45 08             	mov    0x8(%ebp),%eax
80105110:	8b 55 0c             	mov    0xc(%ebp),%edx
80105113:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80105116:	8b 45 08             	mov    0x8(%ebp),%eax
80105119:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010511f:	8b 45 08             	mov    0x8(%ebp),%eax
80105122:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80105129:	90                   	nop
8010512a:	c9                   	leave  
8010512b:	c3                   	ret    

8010512c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
8010512c:	55                   	push   %ebp
8010512d:	89 e5                	mov    %esp,%ebp
8010512f:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80105132:	8b 45 08             	mov    0x8(%ebp),%eax
80105135:	83 c0 04             	add    $0x4,%eax
80105138:	83 ec 0c             	sub    $0xc,%esp
8010513b:	50                   	push   %eax
8010513c:	e8 54 01 00 00       	call   80105295 <acquire>
80105141:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80105144:	eb 15                	jmp    8010515b <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80105146:	8b 45 08             	mov    0x8(%ebp),%eax
80105149:	83 c0 04             	add    $0x4,%eax
8010514c:	83 ec 08             	sub    $0x8,%esp
8010514f:	50                   	push   %eax
80105150:	ff 75 08             	push   0x8(%ebp)
80105153:	e8 83 fb ff ff       	call   80104cdb <sleep>
80105158:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
8010515b:	8b 45 08             	mov    0x8(%ebp),%eax
8010515e:	8b 00                	mov    (%eax),%eax
80105160:	85 c0                	test   %eax,%eax
80105162:	75 e2                	jne    80105146 <acquiresleep+0x1a>
  }
  lk->locked = 1;
80105164:	8b 45 08             	mov    0x8(%ebp),%eax
80105167:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
8010516d:	e8 68 f1 ff ff       	call   801042da <myproc>
80105172:	8b 50 10             	mov    0x10(%eax),%edx
80105175:	8b 45 08             	mov    0x8(%ebp),%eax
80105178:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
8010517b:	8b 45 08             	mov    0x8(%ebp),%eax
8010517e:	83 c0 04             	add    $0x4,%eax
80105181:	83 ec 0c             	sub    $0xc,%esp
80105184:	50                   	push   %eax
80105185:	e8 79 01 00 00       	call   80105303 <release>
8010518a:	83 c4 10             	add    $0x10,%esp
}
8010518d:	90                   	nop
8010518e:	c9                   	leave  
8010518f:	c3                   	ret    

80105190 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80105190:	55                   	push   %ebp
80105191:	89 e5                	mov    %esp,%ebp
80105193:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80105196:	8b 45 08             	mov    0x8(%ebp),%eax
80105199:	83 c0 04             	add    $0x4,%eax
8010519c:	83 ec 0c             	sub    $0xc,%esp
8010519f:	50                   	push   %eax
801051a0:	e8 f0 00 00 00       	call   80105295 <acquire>
801051a5:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
801051a8:	8b 45 08             	mov    0x8(%ebp),%eax
801051ab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801051b1:	8b 45 08             	mov    0x8(%ebp),%eax
801051b4:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
801051bb:	83 ec 0c             	sub    $0xc,%esp
801051be:	ff 75 08             	push   0x8(%ebp)
801051c1:	e8 13 fc ff ff       	call   80104dd9 <wakeup>
801051c6:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
801051c9:	8b 45 08             	mov    0x8(%ebp),%eax
801051cc:	83 c0 04             	add    $0x4,%eax
801051cf:	83 ec 0c             	sub    $0xc,%esp
801051d2:	50                   	push   %eax
801051d3:	e8 2b 01 00 00       	call   80105303 <release>
801051d8:	83 c4 10             	add    $0x10,%esp
}
801051db:	90                   	nop
801051dc:	c9                   	leave  
801051dd:	c3                   	ret    

801051de <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801051de:	55                   	push   %ebp
801051df:	89 e5                	mov    %esp,%ebp
801051e1:	53                   	push   %ebx
801051e2:	83 ec 14             	sub    $0x14,%esp
  int r;
  
  acquire(&lk->lk);
801051e5:	8b 45 08             	mov    0x8(%ebp),%eax
801051e8:	83 c0 04             	add    $0x4,%eax
801051eb:	83 ec 0c             	sub    $0xc,%esp
801051ee:	50                   	push   %eax
801051ef:	e8 a1 00 00 00       	call   80105295 <acquire>
801051f4:	83 c4 10             	add    $0x10,%esp
  r = lk->locked && (lk->pid == myproc()->pid);
801051f7:	8b 45 08             	mov    0x8(%ebp),%eax
801051fa:	8b 00                	mov    (%eax),%eax
801051fc:	85 c0                	test   %eax,%eax
801051fe:	74 19                	je     80105219 <holdingsleep+0x3b>
80105200:	8b 45 08             	mov    0x8(%ebp),%eax
80105203:	8b 58 3c             	mov    0x3c(%eax),%ebx
80105206:	e8 cf f0 ff ff       	call   801042da <myproc>
8010520b:	8b 40 10             	mov    0x10(%eax),%eax
8010520e:	39 c3                	cmp    %eax,%ebx
80105210:	75 07                	jne    80105219 <holdingsleep+0x3b>
80105212:	b8 01 00 00 00       	mov    $0x1,%eax
80105217:	eb 05                	jmp    8010521e <holdingsleep+0x40>
80105219:	b8 00 00 00 00       	mov    $0x0,%eax
8010521e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80105221:	8b 45 08             	mov    0x8(%ebp),%eax
80105224:	83 c0 04             	add    $0x4,%eax
80105227:	83 ec 0c             	sub    $0xc,%esp
8010522a:	50                   	push   %eax
8010522b:	e8 d3 00 00 00       	call   80105303 <release>
80105230:	83 c4 10             	add    $0x10,%esp
  return r;
80105233:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105236:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105239:	c9                   	leave  
8010523a:	c3                   	ret    

8010523b <readeflags>:
{
8010523b:	55                   	push   %ebp
8010523c:	89 e5                	mov    %esp,%ebp
8010523e:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105241:	9c                   	pushf  
80105242:	58                   	pop    %eax
80105243:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105246:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105249:	c9                   	leave  
8010524a:	c3                   	ret    

8010524b <cli>:
{
8010524b:	55                   	push   %ebp
8010524c:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010524e:	fa                   	cli    
}
8010524f:	90                   	nop
80105250:	5d                   	pop    %ebp
80105251:	c3                   	ret    

80105252 <sti>:
{
80105252:	55                   	push   %ebp
80105253:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105255:	fb                   	sti    
}
80105256:	90                   	nop
80105257:	5d                   	pop    %ebp
80105258:	c3                   	ret    

80105259 <xchg>:
{
80105259:	55                   	push   %ebp
8010525a:	89 e5                	mov    %esp,%ebp
8010525c:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
8010525f:	8b 55 08             	mov    0x8(%ebp),%edx
80105262:	8b 45 0c             	mov    0xc(%ebp),%eax
80105265:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105268:	f0 87 02             	lock xchg %eax,(%edx)
8010526b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
8010526e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105271:	c9                   	leave  
80105272:	c3                   	ret    

80105273 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105273:	55                   	push   %ebp
80105274:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105276:	8b 45 08             	mov    0x8(%ebp),%eax
80105279:	8b 55 0c             	mov    0xc(%ebp),%edx
8010527c:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010527f:	8b 45 08             	mov    0x8(%ebp),%eax
80105282:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105288:	8b 45 08             	mov    0x8(%ebp),%eax
8010528b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105292:	90                   	nop
80105293:	5d                   	pop    %ebp
80105294:	c3                   	ret    

80105295 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105295:	55                   	push   %ebp
80105296:	89 e5                	mov    %esp,%ebp
80105298:	53                   	push   %ebx
80105299:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010529c:	e8 6f 01 00 00       	call   80105410 <pushcli>
  if(holding(lk))
801052a1:	8b 45 08             	mov    0x8(%ebp),%eax
801052a4:	83 ec 0c             	sub    $0xc,%esp
801052a7:	50                   	push   %eax
801052a8:	e8 23 01 00 00       	call   801053d0 <holding>
801052ad:	83 c4 10             	add    $0x10,%esp
801052b0:	85 c0                	test   %eax,%eax
801052b2:	74 0d                	je     801052c1 <acquire+0x2c>
    panic("acquire");
801052b4:	83 ec 0c             	sub    $0xc,%esp
801052b7:	68 16 8b 10 80       	push   $0x80108b16
801052bc:	e8 f4 b2 ff ff       	call   801005b5 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
801052c1:	90                   	nop
801052c2:	8b 45 08             	mov    0x8(%ebp),%eax
801052c5:	83 ec 08             	sub    $0x8,%esp
801052c8:	6a 01                	push   $0x1
801052ca:	50                   	push   %eax
801052cb:	e8 89 ff ff ff       	call   80105259 <xchg>
801052d0:	83 c4 10             	add    $0x10,%esp
801052d3:	85 c0                	test   %eax,%eax
801052d5:	75 eb                	jne    801052c2 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
801052d7:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
801052dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
801052df:	e8 7e ef ff ff       	call   80104262 <mycpu>
801052e4:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
801052e7:	8b 45 08             	mov    0x8(%ebp),%eax
801052ea:	83 c0 0c             	add    $0xc,%eax
801052ed:	83 ec 08             	sub    $0x8,%esp
801052f0:	50                   	push   %eax
801052f1:	8d 45 08             	lea    0x8(%ebp),%eax
801052f4:	50                   	push   %eax
801052f5:	e8 5b 00 00 00       	call   80105355 <getcallerpcs>
801052fa:	83 c4 10             	add    $0x10,%esp
}
801052fd:	90                   	nop
801052fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105301:	c9                   	leave  
80105302:	c3                   	ret    

80105303 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105303:	55                   	push   %ebp
80105304:	89 e5                	mov    %esp,%ebp
80105306:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105309:	83 ec 0c             	sub    $0xc,%esp
8010530c:	ff 75 08             	push   0x8(%ebp)
8010530f:	e8 bc 00 00 00       	call   801053d0 <holding>
80105314:	83 c4 10             	add    $0x10,%esp
80105317:	85 c0                	test   %eax,%eax
80105319:	75 0d                	jne    80105328 <release+0x25>
    panic("release");
8010531b:	83 ec 0c             	sub    $0xc,%esp
8010531e:	68 1e 8b 10 80       	push   $0x80108b1e
80105323:	e8 8d b2 ff ff       	call   801005b5 <panic>

  lk->pcs[0] = 0;
80105328:	8b 45 08             	mov    0x8(%ebp),%eax
8010532b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105332:	8b 45 08             	mov    0x8(%ebp),%eax
80105335:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
8010533c:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80105341:	8b 45 08             	mov    0x8(%ebp),%eax
80105344:	8b 55 08             	mov    0x8(%ebp),%edx
80105347:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
8010534d:	e8 0b 01 00 00       	call   8010545d <popcli>
}
80105352:	90                   	nop
80105353:	c9                   	leave  
80105354:	c3                   	ret    

80105355 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105355:	55                   	push   %ebp
80105356:	89 e5                	mov    %esp,%ebp
80105358:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
8010535b:	8b 45 08             	mov    0x8(%ebp),%eax
8010535e:	83 e8 08             	sub    $0x8,%eax
80105361:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105364:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010536b:	eb 38                	jmp    801053a5 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
8010536d:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105371:	74 53                	je     801053c6 <getcallerpcs+0x71>
80105373:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
8010537a:	76 4a                	jbe    801053c6 <getcallerpcs+0x71>
8010537c:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105380:	74 44                	je     801053c6 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105382:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105385:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010538c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010538f:	01 c2                	add    %eax,%edx
80105391:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105394:	8b 40 04             	mov    0x4(%eax),%eax
80105397:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105399:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010539c:	8b 00                	mov    (%eax),%eax
8010539e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801053a1:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801053a5:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801053a9:	7e c2                	jle    8010536d <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
801053ab:	eb 19                	jmp    801053c6 <getcallerpcs+0x71>
    pcs[i] = 0;
801053ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053b0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801053b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801053ba:	01 d0                	add    %edx,%eax
801053bc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
801053c2:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801053c6:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801053ca:	7e e1                	jle    801053ad <getcallerpcs+0x58>
}
801053cc:	90                   	nop
801053cd:	90                   	nop
801053ce:	c9                   	leave  
801053cf:	c3                   	ret    

801053d0 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801053d0:	55                   	push   %ebp
801053d1:	89 e5                	mov    %esp,%ebp
801053d3:	53                   	push   %ebx
801053d4:	83 ec 14             	sub    $0x14,%esp
  int r;
  pushcli();
801053d7:	e8 34 00 00 00       	call   80105410 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
801053dc:	8b 45 08             	mov    0x8(%ebp),%eax
801053df:	8b 00                	mov    (%eax),%eax
801053e1:	85 c0                	test   %eax,%eax
801053e3:	74 16                	je     801053fb <holding+0x2b>
801053e5:	8b 45 08             	mov    0x8(%ebp),%eax
801053e8:	8b 58 08             	mov    0x8(%eax),%ebx
801053eb:	e8 72 ee ff ff       	call   80104262 <mycpu>
801053f0:	39 c3                	cmp    %eax,%ebx
801053f2:	75 07                	jne    801053fb <holding+0x2b>
801053f4:	b8 01 00 00 00       	mov    $0x1,%eax
801053f9:	eb 05                	jmp    80105400 <holding+0x30>
801053fb:	b8 00 00 00 00       	mov    $0x0,%eax
80105400:	89 45 f4             	mov    %eax,-0xc(%ebp)
  popcli();
80105403:	e8 55 00 00 00       	call   8010545d <popcli>
  return r;
80105408:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010540b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010540e:	c9                   	leave  
8010540f:	c3                   	ret    

80105410 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105410:	55                   	push   %ebp
80105411:	89 e5                	mov    %esp,%ebp
80105413:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80105416:	e8 20 fe ff ff       	call   8010523b <readeflags>
8010541b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
8010541e:	e8 28 fe ff ff       	call   8010524b <cli>
  if(mycpu()->ncli == 0)
80105423:	e8 3a ee ff ff       	call   80104262 <mycpu>
80105428:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010542e:	85 c0                	test   %eax,%eax
80105430:	75 14                	jne    80105446 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80105432:	e8 2b ee ff ff       	call   80104262 <mycpu>
80105437:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010543a:	81 e2 00 02 00 00    	and    $0x200,%edx
80105440:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80105446:	e8 17 ee ff ff       	call   80104262 <mycpu>
8010544b:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105451:	83 c2 01             	add    $0x1,%edx
80105454:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
8010545a:	90                   	nop
8010545b:	c9                   	leave  
8010545c:	c3                   	ret    

8010545d <popcli>:

void
popcli(void)
{
8010545d:	55                   	push   %ebp
8010545e:	89 e5                	mov    %esp,%ebp
80105460:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105463:	e8 d3 fd ff ff       	call   8010523b <readeflags>
80105468:	25 00 02 00 00       	and    $0x200,%eax
8010546d:	85 c0                	test   %eax,%eax
8010546f:	74 0d                	je     8010547e <popcli+0x21>
    panic("popcli - interruptible");
80105471:	83 ec 0c             	sub    $0xc,%esp
80105474:	68 26 8b 10 80       	push   $0x80108b26
80105479:	e8 37 b1 ff ff       	call   801005b5 <panic>
  if(--mycpu()->ncli < 0)
8010547e:	e8 df ed ff ff       	call   80104262 <mycpu>
80105483:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105489:	83 ea 01             	sub    $0x1,%edx
8010548c:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80105492:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105498:	85 c0                	test   %eax,%eax
8010549a:	79 0d                	jns    801054a9 <popcli+0x4c>
    panic("popcli");
8010549c:	83 ec 0c             	sub    $0xc,%esp
8010549f:	68 3d 8b 10 80       	push   $0x80108b3d
801054a4:	e8 0c b1 ff ff       	call   801005b5 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
801054a9:	e8 b4 ed ff ff       	call   80104262 <mycpu>
801054ae:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801054b4:	85 c0                	test   %eax,%eax
801054b6:	75 14                	jne    801054cc <popcli+0x6f>
801054b8:	e8 a5 ed ff ff       	call   80104262 <mycpu>
801054bd:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801054c3:	85 c0                	test   %eax,%eax
801054c5:	74 05                	je     801054cc <popcli+0x6f>
    sti();
801054c7:	e8 86 fd ff ff       	call   80105252 <sti>
}
801054cc:	90                   	nop
801054cd:	c9                   	leave  
801054ce:	c3                   	ret    

801054cf <stosb>:
{
801054cf:	55                   	push   %ebp
801054d0:	89 e5                	mov    %esp,%ebp
801054d2:	57                   	push   %edi
801054d3:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801054d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
801054d7:	8b 55 10             	mov    0x10(%ebp),%edx
801054da:	8b 45 0c             	mov    0xc(%ebp),%eax
801054dd:	89 cb                	mov    %ecx,%ebx
801054df:	89 df                	mov    %ebx,%edi
801054e1:	89 d1                	mov    %edx,%ecx
801054e3:	fc                   	cld    
801054e4:	f3 aa                	rep stos %al,%es:(%edi)
801054e6:	89 ca                	mov    %ecx,%edx
801054e8:	89 fb                	mov    %edi,%ebx
801054ea:	89 5d 08             	mov    %ebx,0x8(%ebp)
801054ed:	89 55 10             	mov    %edx,0x10(%ebp)
}
801054f0:	90                   	nop
801054f1:	5b                   	pop    %ebx
801054f2:	5f                   	pop    %edi
801054f3:	5d                   	pop    %ebp
801054f4:	c3                   	ret    

801054f5 <stosl>:
{
801054f5:	55                   	push   %ebp
801054f6:	89 e5                	mov    %esp,%ebp
801054f8:	57                   	push   %edi
801054f9:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801054fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
801054fd:	8b 55 10             	mov    0x10(%ebp),%edx
80105500:	8b 45 0c             	mov    0xc(%ebp),%eax
80105503:	89 cb                	mov    %ecx,%ebx
80105505:	89 df                	mov    %ebx,%edi
80105507:	89 d1                	mov    %edx,%ecx
80105509:	fc                   	cld    
8010550a:	f3 ab                	rep stos %eax,%es:(%edi)
8010550c:	89 ca                	mov    %ecx,%edx
8010550e:	89 fb                	mov    %edi,%ebx
80105510:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105513:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105516:	90                   	nop
80105517:	5b                   	pop    %ebx
80105518:	5f                   	pop    %edi
80105519:	5d                   	pop    %ebp
8010551a:	c3                   	ret    

8010551b <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010551b:	55                   	push   %ebp
8010551c:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
8010551e:	8b 45 08             	mov    0x8(%ebp),%eax
80105521:	83 e0 03             	and    $0x3,%eax
80105524:	85 c0                	test   %eax,%eax
80105526:	75 43                	jne    8010556b <memset+0x50>
80105528:	8b 45 10             	mov    0x10(%ebp),%eax
8010552b:	83 e0 03             	and    $0x3,%eax
8010552e:	85 c0                	test   %eax,%eax
80105530:	75 39                	jne    8010556b <memset+0x50>
    c &= 0xFF;
80105532:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105539:	8b 45 10             	mov    0x10(%ebp),%eax
8010553c:	c1 e8 02             	shr    $0x2,%eax
8010553f:	89 c2                	mov    %eax,%edx
80105541:	8b 45 0c             	mov    0xc(%ebp),%eax
80105544:	c1 e0 18             	shl    $0x18,%eax
80105547:	89 c1                	mov    %eax,%ecx
80105549:	8b 45 0c             	mov    0xc(%ebp),%eax
8010554c:	c1 e0 10             	shl    $0x10,%eax
8010554f:	09 c1                	or     %eax,%ecx
80105551:	8b 45 0c             	mov    0xc(%ebp),%eax
80105554:	c1 e0 08             	shl    $0x8,%eax
80105557:	09 c8                	or     %ecx,%eax
80105559:	0b 45 0c             	or     0xc(%ebp),%eax
8010555c:	52                   	push   %edx
8010555d:	50                   	push   %eax
8010555e:	ff 75 08             	push   0x8(%ebp)
80105561:	e8 8f ff ff ff       	call   801054f5 <stosl>
80105566:	83 c4 0c             	add    $0xc,%esp
80105569:	eb 12                	jmp    8010557d <memset+0x62>
  } else
    stosb(dst, c, n);
8010556b:	8b 45 10             	mov    0x10(%ebp),%eax
8010556e:	50                   	push   %eax
8010556f:	ff 75 0c             	push   0xc(%ebp)
80105572:	ff 75 08             	push   0x8(%ebp)
80105575:	e8 55 ff ff ff       	call   801054cf <stosb>
8010557a:	83 c4 0c             	add    $0xc,%esp
  return dst;
8010557d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105580:	c9                   	leave  
80105581:	c3                   	ret    

80105582 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105582:	55                   	push   %ebp
80105583:	89 e5                	mov    %esp,%ebp
80105585:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105588:	8b 45 08             	mov    0x8(%ebp),%eax
8010558b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
8010558e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105591:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105594:	eb 30                	jmp    801055c6 <memcmp+0x44>
    if(*s1 != *s2)
80105596:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105599:	0f b6 10             	movzbl (%eax),%edx
8010559c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010559f:	0f b6 00             	movzbl (%eax),%eax
801055a2:	38 c2                	cmp    %al,%dl
801055a4:	74 18                	je     801055be <memcmp+0x3c>
      return *s1 - *s2;
801055a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055a9:	0f b6 00             	movzbl (%eax),%eax
801055ac:	0f b6 d0             	movzbl %al,%edx
801055af:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055b2:	0f b6 00             	movzbl (%eax),%eax
801055b5:	0f b6 c8             	movzbl %al,%ecx
801055b8:	89 d0                	mov    %edx,%eax
801055ba:	29 c8                	sub    %ecx,%eax
801055bc:	eb 1a                	jmp    801055d8 <memcmp+0x56>
    s1++, s2++;
801055be:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801055c2:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
801055c6:	8b 45 10             	mov    0x10(%ebp),%eax
801055c9:	8d 50 ff             	lea    -0x1(%eax),%edx
801055cc:	89 55 10             	mov    %edx,0x10(%ebp)
801055cf:	85 c0                	test   %eax,%eax
801055d1:	75 c3                	jne    80105596 <memcmp+0x14>
  }

  return 0;
801055d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055d8:	c9                   	leave  
801055d9:	c3                   	ret    

801055da <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801055da:	55                   	push   %ebp
801055db:	89 e5                	mov    %esp,%ebp
801055dd:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801055e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801055e3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801055e6:	8b 45 08             	mov    0x8(%ebp),%eax
801055e9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801055ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055ef:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801055f2:	73 54                	jae    80105648 <memmove+0x6e>
801055f4:	8b 55 fc             	mov    -0x4(%ebp),%edx
801055f7:	8b 45 10             	mov    0x10(%ebp),%eax
801055fa:	01 d0                	add    %edx,%eax
801055fc:	39 45 f8             	cmp    %eax,-0x8(%ebp)
801055ff:	73 47                	jae    80105648 <memmove+0x6e>
    s += n;
80105601:	8b 45 10             	mov    0x10(%ebp),%eax
80105604:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105607:	8b 45 10             	mov    0x10(%ebp),%eax
8010560a:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
8010560d:	eb 13                	jmp    80105622 <memmove+0x48>
      *--d = *--s;
8010560f:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105613:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105617:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010561a:	0f b6 10             	movzbl (%eax),%edx
8010561d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105620:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105622:	8b 45 10             	mov    0x10(%ebp),%eax
80105625:	8d 50 ff             	lea    -0x1(%eax),%edx
80105628:	89 55 10             	mov    %edx,0x10(%ebp)
8010562b:	85 c0                	test   %eax,%eax
8010562d:	75 e0                	jne    8010560f <memmove+0x35>
  if(s < d && s + n > d){
8010562f:	eb 24                	jmp    80105655 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80105631:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105634:	8d 42 01             	lea    0x1(%edx),%eax
80105637:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010563a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010563d:	8d 48 01             	lea    0x1(%eax),%ecx
80105640:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80105643:	0f b6 12             	movzbl (%edx),%edx
80105646:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105648:	8b 45 10             	mov    0x10(%ebp),%eax
8010564b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010564e:	89 55 10             	mov    %edx,0x10(%ebp)
80105651:	85 c0                	test   %eax,%eax
80105653:	75 dc                	jne    80105631 <memmove+0x57>

  return dst;
80105655:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105658:	c9                   	leave  
80105659:	c3                   	ret    

8010565a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
8010565a:	55                   	push   %ebp
8010565b:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
8010565d:	ff 75 10             	push   0x10(%ebp)
80105660:	ff 75 0c             	push   0xc(%ebp)
80105663:	ff 75 08             	push   0x8(%ebp)
80105666:	e8 6f ff ff ff       	call   801055da <memmove>
8010566b:	83 c4 0c             	add    $0xc,%esp
}
8010566e:	c9                   	leave  
8010566f:	c3                   	ret    

80105670 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105670:	55                   	push   %ebp
80105671:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105673:	eb 0c                	jmp    80105681 <strncmp+0x11>
    n--, p++, q++;
80105675:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105679:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010567d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80105681:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105685:	74 1a                	je     801056a1 <strncmp+0x31>
80105687:	8b 45 08             	mov    0x8(%ebp),%eax
8010568a:	0f b6 00             	movzbl (%eax),%eax
8010568d:	84 c0                	test   %al,%al
8010568f:	74 10                	je     801056a1 <strncmp+0x31>
80105691:	8b 45 08             	mov    0x8(%ebp),%eax
80105694:	0f b6 10             	movzbl (%eax),%edx
80105697:	8b 45 0c             	mov    0xc(%ebp),%eax
8010569a:	0f b6 00             	movzbl (%eax),%eax
8010569d:	38 c2                	cmp    %al,%dl
8010569f:	74 d4                	je     80105675 <strncmp+0x5>
  if(n == 0)
801056a1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056a5:	75 07                	jne    801056ae <strncmp+0x3e>
    return 0;
801056a7:	b8 00 00 00 00       	mov    $0x0,%eax
801056ac:	eb 16                	jmp    801056c4 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
801056ae:	8b 45 08             	mov    0x8(%ebp),%eax
801056b1:	0f b6 00             	movzbl (%eax),%eax
801056b4:	0f b6 d0             	movzbl %al,%edx
801056b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801056ba:	0f b6 00             	movzbl (%eax),%eax
801056bd:	0f b6 c8             	movzbl %al,%ecx
801056c0:	89 d0                	mov    %edx,%eax
801056c2:	29 c8                	sub    %ecx,%eax
}
801056c4:	5d                   	pop    %ebp
801056c5:	c3                   	ret    

801056c6 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801056c6:	55                   	push   %ebp
801056c7:	89 e5                	mov    %esp,%ebp
801056c9:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801056cc:	8b 45 08             	mov    0x8(%ebp),%eax
801056cf:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801056d2:	90                   	nop
801056d3:	8b 45 10             	mov    0x10(%ebp),%eax
801056d6:	8d 50 ff             	lea    -0x1(%eax),%edx
801056d9:	89 55 10             	mov    %edx,0x10(%ebp)
801056dc:	85 c0                	test   %eax,%eax
801056de:	7e 2c                	jle    8010570c <strncpy+0x46>
801056e0:	8b 55 0c             	mov    0xc(%ebp),%edx
801056e3:	8d 42 01             	lea    0x1(%edx),%eax
801056e6:	89 45 0c             	mov    %eax,0xc(%ebp)
801056e9:	8b 45 08             	mov    0x8(%ebp),%eax
801056ec:	8d 48 01             	lea    0x1(%eax),%ecx
801056ef:	89 4d 08             	mov    %ecx,0x8(%ebp)
801056f2:	0f b6 12             	movzbl (%edx),%edx
801056f5:	88 10                	mov    %dl,(%eax)
801056f7:	0f b6 00             	movzbl (%eax),%eax
801056fa:	84 c0                	test   %al,%al
801056fc:	75 d5                	jne    801056d3 <strncpy+0xd>
    ;
  while(n-- > 0)
801056fe:	eb 0c                	jmp    8010570c <strncpy+0x46>
    *s++ = 0;
80105700:	8b 45 08             	mov    0x8(%ebp),%eax
80105703:	8d 50 01             	lea    0x1(%eax),%edx
80105706:	89 55 08             	mov    %edx,0x8(%ebp)
80105709:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
8010570c:	8b 45 10             	mov    0x10(%ebp),%eax
8010570f:	8d 50 ff             	lea    -0x1(%eax),%edx
80105712:	89 55 10             	mov    %edx,0x10(%ebp)
80105715:	85 c0                	test   %eax,%eax
80105717:	7f e7                	jg     80105700 <strncpy+0x3a>
  return os;
80105719:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010571c:	c9                   	leave  
8010571d:	c3                   	ret    

8010571e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010571e:	55                   	push   %ebp
8010571f:	89 e5                	mov    %esp,%ebp
80105721:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105724:	8b 45 08             	mov    0x8(%ebp),%eax
80105727:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010572a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010572e:	7f 05                	jg     80105735 <safestrcpy+0x17>
    return os;
80105730:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105733:	eb 32                	jmp    80105767 <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80105735:	90                   	nop
80105736:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010573a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010573e:	7e 1e                	jle    8010575e <safestrcpy+0x40>
80105740:	8b 55 0c             	mov    0xc(%ebp),%edx
80105743:	8d 42 01             	lea    0x1(%edx),%eax
80105746:	89 45 0c             	mov    %eax,0xc(%ebp)
80105749:	8b 45 08             	mov    0x8(%ebp),%eax
8010574c:	8d 48 01             	lea    0x1(%eax),%ecx
8010574f:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105752:	0f b6 12             	movzbl (%edx),%edx
80105755:	88 10                	mov    %dl,(%eax)
80105757:	0f b6 00             	movzbl (%eax),%eax
8010575a:	84 c0                	test   %al,%al
8010575c:	75 d8                	jne    80105736 <safestrcpy+0x18>
    ;
  *s = 0;
8010575e:	8b 45 08             	mov    0x8(%ebp),%eax
80105761:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105764:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105767:	c9                   	leave  
80105768:	c3                   	ret    

80105769 <strlen>:

int
strlen(const char *s)
{
80105769:	55                   	push   %ebp
8010576a:	89 e5                	mov    %esp,%ebp
8010576c:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010576f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105776:	eb 04                	jmp    8010577c <strlen+0x13>
80105778:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010577c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010577f:	8b 45 08             	mov    0x8(%ebp),%eax
80105782:	01 d0                	add    %edx,%eax
80105784:	0f b6 00             	movzbl (%eax),%eax
80105787:	84 c0                	test   %al,%al
80105789:	75 ed                	jne    80105778 <strlen+0xf>
    ;
  return n;
8010578b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010578e:	c9                   	leave  
8010578f:	c3                   	ret    

80105790 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105790:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105794:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80105798:	55                   	push   %ebp
  pushl %ebx
80105799:	53                   	push   %ebx
  pushl %esi
8010579a:	56                   	push   %esi
  pushl %edi
8010579b:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010579c:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010579e:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
801057a0:	5f                   	pop    %edi
  popl %esi
801057a1:	5e                   	pop    %esi
  popl %ebx
801057a2:	5b                   	pop    %ebx
  popl %ebp
801057a3:	5d                   	pop    %ebp
  ret
801057a4:	c3                   	ret    

801057a5 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801057a5:	55                   	push   %ebp
801057a6:	89 e5                	mov    %esp,%ebp
801057a8:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801057ab:	e8 2a eb ff ff       	call   801042da <myproc>
801057b0:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801057b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057b6:	8b 00                	mov    (%eax),%eax
801057b8:	39 45 08             	cmp    %eax,0x8(%ebp)
801057bb:	73 0f                	jae    801057cc <fetchint+0x27>
801057bd:	8b 45 08             	mov    0x8(%ebp),%eax
801057c0:	8d 50 04             	lea    0x4(%eax),%edx
801057c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057c6:	8b 00                	mov    (%eax),%eax
801057c8:	39 c2                	cmp    %eax,%edx
801057ca:	76 07                	jbe    801057d3 <fetchint+0x2e>
    return -1;
801057cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057d1:	eb 0f                	jmp    801057e2 <fetchint+0x3d>
  *ip = *(int*)(addr);
801057d3:	8b 45 08             	mov    0x8(%ebp),%eax
801057d6:	8b 10                	mov    (%eax),%edx
801057d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801057db:	89 10                	mov    %edx,(%eax)
  return 0;
801057dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801057e2:	c9                   	leave  
801057e3:	c3                   	ret    

801057e4 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801057e4:	55                   	push   %ebp
801057e5:	89 e5                	mov    %esp,%ebp
801057e7:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
801057ea:	e8 eb ea ff ff       	call   801042da <myproc>
801057ef:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
801057f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057f5:	8b 00                	mov    (%eax),%eax
801057f7:	39 45 08             	cmp    %eax,0x8(%ebp)
801057fa:	72 07                	jb     80105803 <fetchstr+0x1f>
    return -1;
801057fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105801:	eb 41                	jmp    80105844 <fetchstr+0x60>
  *pp = (char*)addr;
80105803:	8b 55 08             	mov    0x8(%ebp),%edx
80105806:	8b 45 0c             	mov    0xc(%ebp),%eax
80105809:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
8010580b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010580e:	8b 00                	mov    (%eax),%eax
80105810:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105813:	8b 45 0c             	mov    0xc(%ebp),%eax
80105816:	8b 00                	mov    (%eax),%eax
80105818:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010581b:	eb 1a                	jmp    80105837 <fetchstr+0x53>
    if(*s == 0)
8010581d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105820:	0f b6 00             	movzbl (%eax),%eax
80105823:	84 c0                	test   %al,%al
80105825:	75 0c                	jne    80105833 <fetchstr+0x4f>
      return s - *pp;
80105827:	8b 45 0c             	mov    0xc(%ebp),%eax
8010582a:	8b 10                	mov    (%eax),%edx
8010582c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010582f:	29 d0                	sub    %edx,%eax
80105831:	eb 11                	jmp    80105844 <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
80105833:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105837:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010583a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010583d:	72 de                	jb     8010581d <fetchstr+0x39>
  }
  return -1;
8010583f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105844:	c9                   	leave  
80105845:	c3                   	ret    

80105846 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105846:	55                   	push   %ebp
80105847:	89 e5                	mov    %esp,%ebp
80105849:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
8010584c:	e8 89 ea ff ff       	call   801042da <myproc>
80105851:	8b 40 18             	mov    0x18(%eax),%eax
80105854:	8b 50 44             	mov    0x44(%eax),%edx
80105857:	8b 45 08             	mov    0x8(%ebp),%eax
8010585a:	c1 e0 02             	shl    $0x2,%eax
8010585d:	01 d0                	add    %edx,%eax
8010585f:	83 c0 04             	add    $0x4,%eax
80105862:	83 ec 08             	sub    $0x8,%esp
80105865:	ff 75 0c             	push   0xc(%ebp)
80105868:	50                   	push   %eax
80105869:	e8 37 ff ff ff       	call   801057a5 <fetchint>
8010586e:	83 c4 10             	add    $0x10,%esp
}
80105871:	c9                   	leave  
80105872:	c3                   	ret    

80105873 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105873:	55                   	push   %ebp
80105874:	89 e5                	mov    %esp,%ebp
80105876:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80105879:	e8 5c ea ff ff       	call   801042da <myproc>
8010587e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105881:	83 ec 08             	sub    $0x8,%esp
80105884:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105887:	50                   	push   %eax
80105888:	ff 75 08             	push   0x8(%ebp)
8010588b:	e8 b6 ff ff ff       	call   80105846 <argint>
80105890:	83 c4 10             	add    $0x10,%esp
80105893:	85 c0                	test   %eax,%eax
80105895:	79 07                	jns    8010589e <argptr+0x2b>
    return -1;
80105897:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010589c:	eb 3b                	jmp    801058d9 <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
8010589e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801058a2:	78 1f                	js     801058c3 <argptr+0x50>
801058a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058a7:	8b 00                	mov    (%eax),%eax
801058a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801058ac:	39 d0                	cmp    %edx,%eax
801058ae:	76 13                	jbe    801058c3 <argptr+0x50>
801058b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058b3:	89 c2                	mov    %eax,%edx
801058b5:	8b 45 10             	mov    0x10(%ebp),%eax
801058b8:	01 c2                	add    %eax,%edx
801058ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058bd:	8b 00                	mov    (%eax),%eax
801058bf:	39 c2                	cmp    %eax,%edx
801058c1:	76 07                	jbe    801058ca <argptr+0x57>
    return -1;
801058c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058c8:	eb 0f                	jmp    801058d9 <argptr+0x66>
  *pp = (char*)i;
801058ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058cd:	89 c2                	mov    %eax,%edx
801058cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801058d2:	89 10                	mov    %edx,(%eax)
  return 0;
801058d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058d9:	c9                   	leave  
801058da:	c3                   	ret    

801058db <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801058db:	55                   	push   %ebp
801058dc:	89 e5                	mov    %esp,%ebp
801058de:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801058e1:	83 ec 08             	sub    $0x8,%esp
801058e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058e7:	50                   	push   %eax
801058e8:	ff 75 08             	push   0x8(%ebp)
801058eb:	e8 56 ff ff ff       	call   80105846 <argint>
801058f0:	83 c4 10             	add    $0x10,%esp
801058f3:	85 c0                	test   %eax,%eax
801058f5:	79 07                	jns    801058fe <argstr+0x23>
    return -1;
801058f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058fc:	eb 12                	jmp    80105910 <argstr+0x35>
  return fetchstr(addr, pp);
801058fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105901:	83 ec 08             	sub    $0x8,%esp
80105904:	ff 75 0c             	push   0xc(%ebp)
80105907:	50                   	push   %eax
80105908:	e8 d7 fe ff ff       	call   801057e4 <fetchstr>
8010590d:	83 c4 10             	add    $0x10,%esp
}
80105910:	c9                   	leave  
80105911:	c3                   	ret    

80105912 <syscall>:
[SYS_getschedstate]  sys_getschedstate,
};

void
syscall(void)
{
80105912:	55                   	push   %ebp
80105913:	89 e5                	mov    %esp,%ebp
80105915:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105918:	e8 bd e9 ff ff       	call   801042da <myproc>
8010591d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105920:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105923:	8b 40 18             	mov    0x18(%eax),%eax
80105926:	8b 40 1c             	mov    0x1c(%eax),%eax
80105929:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010592c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105930:	7e 2f                	jle    80105961 <syscall+0x4f>
80105932:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105935:	83 f8 17             	cmp    $0x17,%eax
80105938:	77 27                	ja     80105961 <syscall+0x4f>
8010593a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010593d:	8b 04 85 20 b0 10 80 	mov    -0x7fef4fe0(,%eax,4),%eax
80105944:	85 c0                	test   %eax,%eax
80105946:	74 19                	je     80105961 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80105948:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010594b:	8b 04 85 20 b0 10 80 	mov    -0x7fef4fe0(,%eax,4),%eax
80105952:	ff d0                	call   *%eax
80105954:	89 c2                	mov    %eax,%edx
80105956:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105959:	8b 40 18             	mov    0x18(%eax),%eax
8010595c:	89 50 1c             	mov    %edx,0x1c(%eax)
8010595f:	eb 2c                	jmp    8010598d <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105961:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105964:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80105967:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010596a:	8b 40 10             	mov    0x10(%eax),%eax
8010596d:	ff 75 f0             	push   -0x10(%ebp)
80105970:	52                   	push   %edx
80105971:	50                   	push   %eax
80105972:	68 44 8b 10 80       	push   $0x80108b44
80105977:	e8 84 aa ff ff       	call   80100400 <cprintf>
8010597c:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
8010597f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105982:	8b 40 18             	mov    0x18(%eax),%eax
80105985:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010598c:	90                   	nop
8010598d:	90                   	nop
8010598e:	c9                   	leave  
8010598f:	c3                   	ret    

80105990 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105990:	55                   	push   %ebp
80105991:	89 e5                	mov    %esp,%ebp
80105993:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105996:	83 ec 08             	sub    $0x8,%esp
80105999:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010599c:	50                   	push   %eax
8010599d:	ff 75 08             	push   0x8(%ebp)
801059a0:	e8 a1 fe ff ff       	call   80105846 <argint>
801059a5:	83 c4 10             	add    $0x10,%esp
801059a8:	85 c0                	test   %eax,%eax
801059aa:	79 07                	jns    801059b3 <argfd+0x23>
    return -1;
801059ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059b1:	eb 4f                	jmp    80105a02 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801059b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059b6:	85 c0                	test   %eax,%eax
801059b8:	78 20                	js     801059da <argfd+0x4a>
801059ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059bd:	83 f8 0f             	cmp    $0xf,%eax
801059c0:	7f 18                	jg     801059da <argfd+0x4a>
801059c2:	e8 13 e9 ff ff       	call   801042da <myproc>
801059c7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059ca:	83 c2 08             	add    $0x8,%edx
801059cd:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801059d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059d4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059d8:	75 07                	jne    801059e1 <argfd+0x51>
    return -1;
801059da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059df:	eb 21                	jmp    80105a02 <argfd+0x72>
  if(pfd)
801059e1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801059e5:	74 08                	je     801059ef <argfd+0x5f>
    *pfd = fd;
801059e7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801059ed:	89 10                	mov    %edx,(%eax)
  if(pf)
801059ef:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801059f3:	74 08                	je     801059fd <argfd+0x6d>
    *pf = f;
801059f5:	8b 45 10             	mov    0x10(%ebp),%eax
801059f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059fb:	89 10                	mov    %edx,(%eax)
  return 0;
801059fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a02:	c9                   	leave  
80105a03:	c3                   	ret    

80105a04 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105a04:	55                   	push   %ebp
80105a05:	89 e5                	mov    %esp,%ebp
80105a07:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105a0a:	e8 cb e8 ff ff       	call   801042da <myproc>
80105a0f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105a12:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105a19:	eb 2a                	jmp    80105a45 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80105a1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a1e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a21:	83 c2 08             	add    $0x8,%edx
80105a24:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105a28:	85 c0                	test   %eax,%eax
80105a2a:	75 15                	jne    80105a41 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105a2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a2f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a32:	8d 4a 08             	lea    0x8(%edx),%ecx
80105a35:	8b 55 08             	mov    0x8(%ebp),%edx
80105a38:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105a3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a3f:	eb 0f                	jmp    80105a50 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80105a41:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105a45:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105a49:	7e d0                	jle    80105a1b <fdalloc+0x17>
    }
  }
  return -1;
80105a4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a50:	c9                   	leave  
80105a51:	c3                   	ret    

80105a52 <sys_dup>:

int
sys_dup(void)
{
80105a52:	55                   	push   %ebp
80105a53:	89 e5                	mov    %esp,%ebp
80105a55:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105a58:	83 ec 04             	sub    $0x4,%esp
80105a5b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a5e:	50                   	push   %eax
80105a5f:	6a 00                	push   $0x0
80105a61:	6a 00                	push   $0x0
80105a63:	e8 28 ff ff ff       	call   80105990 <argfd>
80105a68:	83 c4 10             	add    $0x10,%esp
80105a6b:	85 c0                	test   %eax,%eax
80105a6d:	79 07                	jns    80105a76 <sys_dup+0x24>
    return -1;
80105a6f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a74:	eb 31                	jmp    80105aa7 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105a76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a79:	83 ec 0c             	sub    $0xc,%esp
80105a7c:	50                   	push   %eax
80105a7d:	e8 82 ff ff ff       	call   80105a04 <fdalloc>
80105a82:	83 c4 10             	add    $0x10,%esp
80105a85:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a88:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a8c:	79 07                	jns    80105a95 <sys_dup+0x43>
    return -1;
80105a8e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a93:	eb 12                	jmp    80105aa7 <sys_dup+0x55>
  filedup(f);
80105a95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a98:	83 ec 0c             	sub    $0xc,%esp
80105a9b:	50                   	push   %eax
80105a9c:	e8 ec b5 ff ff       	call   8010108d <filedup>
80105aa1:	83 c4 10             	add    $0x10,%esp
  return fd;
80105aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105aa7:	c9                   	leave  
80105aa8:	c3                   	ret    

80105aa9 <sys_read>:

int
sys_read(void)
{
80105aa9:	55                   	push   %ebp
80105aaa:	89 e5                	mov    %esp,%ebp
80105aac:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105aaf:	83 ec 04             	sub    $0x4,%esp
80105ab2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ab5:	50                   	push   %eax
80105ab6:	6a 00                	push   $0x0
80105ab8:	6a 00                	push   $0x0
80105aba:	e8 d1 fe ff ff       	call   80105990 <argfd>
80105abf:	83 c4 10             	add    $0x10,%esp
80105ac2:	85 c0                	test   %eax,%eax
80105ac4:	78 2e                	js     80105af4 <sys_read+0x4b>
80105ac6:	83 ec 08             	sub    $0x8,%esp
80105ac9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105acc:	50                   	push   %eax
80105acd:	6a 02                	push   $0x2
80105acf:	e8 72 fd ff ff       	call   80105846 <argint>
80105ad4:	83 c4 10             	add    $0x10,%esp
80105ad7:	85 c0                	test   %eax,%eax
80105ad9:	78 19                	js     80105af4 <sys_read+0x4b>
80105adb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ade:	83 ec 04             	sub    $0x4,%esp
80105ae1:	50                   	push   %eax
80105ae2:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ae5:	50                   	push   %eax
80105ae6:	6a 01                	push   $0x1
80105ae8:	e8 86 fd ff ff       	call   80105873 <argptr>
80105aed:	83 c4 10             	add    $0x10,%esp
80105af0:	85 c0                	test   %eax,%eax
80105af2:	79 07                	jns    80105afb <sys_read+0x52>
    return -1;
80105af4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105af9:	eb 17                	jmp    80105b12 <sys_read+0x69>
  return fileread(f, p, n);
80105afb:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105afe:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b04:	83 ec 04             	sub    $0x4,%esp
80105b07:	51                   	push   %ecx
80105b08:	52                   	push   %edx
80105b09:	50                   	push   %eax
80105b0a:	e8 0e b7 ff ff       	call   8010121d <fileread>
80105b0f:	83 c4 10             	add    $0x10,%esp
}
80105b12:	c9                   	leave  
80105b13:	c3                   	ret    

80105b14 <sys_write>:

int
sys_write(void)
{
80105b14:	55                   	push   %ebp
80105b15:	89 e5                	mov    %esp,%ebp
80105b17:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105b1a:	83 ec 04             	sub    $0x4,%esp
80105b1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b20:	50                   	push   %eax
80105b21:	6a 00                	push   $0x0
80105b23:	6a 00                	push   $0x0
80105b25:	e8 66 fe ff ff       	call   80105990 <argfd>
80105b2a:	83 c4 10             	add    $0x10,%esp
80105b2d:	85 c0                	test   %eax,%eax
80105b2f:	78 2e                	js     80105b5f <sys_write+0x4b>
80105b31:	83 ec 08             	sub    $0x8,%esp
80105b34:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b37:	50                   	push   %eax
80105b38:	6a 02                	push   $0x2
80105b3a:	e8 07 fd ff ff       	call   80105846 <argint>
80105b3f:	83 c4 10             	add    $0x10,%esp
80105b42:	85 c0                	test   %eax,%eax
80105b44:	78 19                	js     80105b5f <sys_write+0x4b>
80105b46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b49:	83 ec 04             	sub    $0x4,%esp
80105b4c:	50                   	push   %eax
80105b4d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b50:	50                   	push   %eax
80105b51:	6a 01                	push   $0x1
80105b53:	e8 1b fd ff ff       	call   80105873 <argptr>
80105b58:	83 c4 10             	add    $0x10,%esp
80105b5b:	85 c0                	test   %eax,%eax
80105b5d:	79 07                	jns    80105b66 <sys_write+0x52>
    return -1;
80105b5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b64:	eb 17                	jmp    80105b7d <sys_write+0x69>
  return filewrite(f, p, n);
80105b66:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105b69:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105b6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b6f:	83 ec 04             	sub    $0x4,%esp
80105b72:	51                   	push   %ecx
80105b73:	52                   	push   %edx
80105b74:	50                   	push   %eax
80105b75:	e8 5b b7 ff ff       	call   801012d5 <filewrite>
80105b7a:	83 c4 10             	add    $0x10,%esp
}
80105b7d:	c9                   	leave  
80105b7e:	c3                   	ret    

80105b7f <sys_close>:

int
sys_close(void)
{
80105b7f:	55                   	push   %ebp
80105b80:	89 e5                	mov    %esp,%ebp
80105b82:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105b85:	83 ec 04             	sub    $0x4,%esp
80105b88:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b8b:	50                   	push   %eax
80105b8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b8f:	50                   	push   %eax
80105b90:	6a 00                	push   $0x0
80105b92:	e8 f9 fd ff ff       	call   80105990 <argfd>
80105b97:	83 c4 10             	add    $0x10,%esp
80105b9a:	85 c0                	test   %eax,%eax
80105b9c:	79 07                	jns    80105ba5 <sys_close+0x26>
    return -1;
80105b9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ba3:	eb 27                	jmp    80105bcc <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
80105ba5:	e8 30 e7 ff ff       	call   801042da <myproc>
80105baa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105bad:	83 c2 08             	add    $0x8,%edx
80105bb0:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105bb7:	00 
  fileclose(f);
80105bb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bbb:	83 ec 0c             	sub    $0xc,%esp
80105bbe:	50                   	push   %eax
80105bbf:	e8 1a b5 ff ff       	call   801010de <fileclose>
80105bc4:	83 c4 10             	add    $0x10,%esp
  return 0;
80105bc7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105bcc:	c9                   	leave  
80105bcd:	c3                   	ret    

80105bce <sys_fstat>:

int
sys_fstat(void)
{
80105bce:	55                   	push   %ebp
80105bcf:	89 e5                	mov    %esp,%ebp
80105bd1:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105bd4:	83 ec 04             	sub    $0x4,%esp
80105bd7:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bda:	50                   	push   %eax
80105bdb:	6a 00                	push   $0x0
80105bdd:	6a 00                	push   $0x0
80105bdf:	e8 ac fd ff ff       	call   80105990 <argfd>
80105be4:	83 c4 10             	add    $0x10,%esp
80105be7:	85 c0                	test   %eax,%eax
80105be9:	78 17                	js     80105c02 <sys_fstat+0x34>
80105beb:	83 ec 04             	sub    $0x4,%esp
80105bee:	6a 14                	push   $0x14
80105bf0:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bf3:	50                   	push   %eax
80105bf4:	6a 01                	push   $0x1
80105bf6:	e8 78 fc ff ff       	call   80105873 <argptr>
80105bfb:	83 c4 10             	add    $0x10,%esp
80105bfe:	85 c0                	test   %eax,%eax
80105c00:	79 07                	jns    80105c09 <sys_fstat+0x3b>
    return -1;
80105c02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c07:	eb 13                	jmp    80105c1c <sys_fstat+0x4e>
  return filestat(f, st);
80105c09:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c0f:	83 ec 08             	sub    $0x8,%esp
80105c12:	52                   	push   %edx
80105c13:	50                   	push   %eax
80105c14:	e8 ad b5 ff ff       	call   801011c6 <filestat>
80105c19:	83 c4 10             	add    $0x10,%esp
}
80105c1c:	c9                   	leave  
80105c1d:	c3                   	ret    

80105c1e <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105c1e:	55                   	push   %ebp
80105c1f:	89 e5                	mov    %esp,%ebp
80105c21:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105c24:	83 ec 08             	sub    $0x8,%esp
80105c27:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105c2a:	50                   	push   %eax
80105c2b:	6a 00                	push   $0x0
80105c2d:	e8 a9 fc ff ff       	call   801058db <argstr>
80105c32:	83 c4 10             	add    $0x10,%esp
80105c35:	85 c0                	test   %eax,%eax
80105c37:	78 15                	js     80105c4e <sys_link+0x30>
80105c39:	83 ec 08             	sub    $0x8,%esp
80105c3c:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105c3f:	50                   	push   %eax
80105c40:	6a 01                	push   $0x1
80105c42:	e8 94 fc ff ff       	call   801058db <argstr>
80105c47:	83 c4 10             	add    $0x10,%esp
80105c4a:	85 c0                	test   %eax,%eax
80105c4c:	79 0a                	jns    80105c58 <sys_link+0x3a>
    return -1;
80105c4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c53:	e9 68 01 00 00       	jmp    80105dc0 <sys_link+0x1a2>

  begin_op();
80105c58:	e8 d5 d8 ff ff       	call   80103532 <begin_op>
  if((ip = namei(old)) == 0){
80105c5d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105c60:	83 ec 0c             	sub    $0xc,%esp
80105c63:	50                   	push   %eax
80105c64:	e8 e4 c8 ff ff       	call   8010254d <namei>
80105c69:	83 c4 10             	add    $0x10,%esp
80105c6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c6f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c73:	75 0f                	jne    80105c84 <sys_link+0x66>
    end_op();
80105c75:	e8 44 d9 ff ff       	call   801035be <end_op>
    return -1;
80105c7a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c7f:	e9 3c 01 00 00       	jmp    80105dc0 <sys_link+0x1a2>
  }

  ilock(ip);
80105c84:	83 ec 0c             	sub    $0xc,%esp
80105c87:	ff 75 f4             	push   -0xc(%ebp)
80105c8a:	e8 8b bd ff ff       	call   80101a1a <ilock>
80105c8f:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105c92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c95:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105c99:	66 83 f8 01          	cmp    $0x1,%ax
80105c9d:	75 1d                	jne    80105cbc <sys_link+0x9e>
    iunlockput(ip);
80105c9f:	83 ec 0c             	sub    $0xc,%esp
80105ca2:	ff 75 f4             	push   -0xc(%ebp)
80105ca5:	e8 a1 bf ff ff       	call   80101c4b <iunlockput>
80105caa:	83 c4 10             	add    $0x10,%esp
    end_op();
80105cad:	e8 0c d9 ff ff       	call   801035be <end_op>
    return -1;
80105cb2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cb7:	e9 04 01 00 00       	jmp    80105dc0 <sys_link+0x1a2>
  }

  ip->nlink++;
80105cbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cbf:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105cc3:	83 c0 01             	add    $0x1,%eax
80105cc6:	89 c2                	mov    %eax,%edx
80105cc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ccb:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105ccf:	83 ec 0c             	sub    $0xc,%esp
80105cd2:	ff 75 f4             	push   -0xc(%ebp)
80105cd5:	e8 63 bb ff ff       	call   8010183d <iupdate>
80105cda:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105cdd:	83 ec 0c             	sub    $0xc,%esp
80105ce0:	ff 75 f4             	push   -0xc(%ebp)
80105ce3:	e8 45 be ff ff       	call   80101b2d <iunlock>
80105ce8:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105ceb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105cee:	83 ec 08             	sub    $0x8,%esp
80105cf1:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105cf4:	52                   	push   %edx
80105cf5:	50                   	push   %eax
80105cf6:	e8 6e c8 ff ff       	call   80102569 <nameiparent>
80105cfb:	83 c4 10             	add    $0x10,%esp
80105cfe:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d01:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d05:	74 71                	je     80105d78 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105d07:	83 ec 0c             	sub    $0xc,%esp
80105d0a:	ff 75 f0             	push   -0x10(%ebp)
80105d0d:	e8 08 bd ff ff       	call   80101a1a <ilock>
80105d12:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105d15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d18:	8b 10                	mov    (%eax),%edx
80105d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d1d:	8b 00                	mov    (%eax),%eax
80105d1f:	39 c2                	cmp    %eax,%edx
80105d21:	75 1d                	jne    80105d40 <sys_link+0x122>
80105d23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d26:	8b 40 04             	mov    0x4(%eax),%eax
80105d29:	83 ec 04             	sub    $0x4,%esp
80105d2c:	50                   	push   %eax
80105d2d:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105d30:	50                   	push   %eax
80105d31:	ff 75 f0             	push   -0x10(%ebp)
80105d34:	e8 7d c5 ff ff       	call   801022b6 <dirlink>
80105d39:	83 c4 10             	add    $0x10,%esp
80105d3c:	85 c0                	test   %eax,%eax
80105d3e:	79 10                	jns    80105d50 <sys_link+0x132>
    iunlockput(dp);
80105d40:	83 ec 0c             	sub    $0xc,%esp
80105d43:	ff 75 f0             	push   -0x10(%ebp)
80105d46:	e8 00 bf ff ff       	call   80101c4b <iunlockput>
80105d4b:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105d4e:	eb 29                	jmp    80105d79 <sys_link+0x15b>
  }
  iunlockput(dp);
80105d50:	83 ec 0c             	sub    $0xc,%esp
80105d53:	ff 75 f0             	push   -0x10(%ebp)
80105d56:	e8 f0 be ff ff       	call   80101c4b <iunlockput>
80105d5b:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105d5e:	83 ec 0c             	sub    $0xc,%esp
80105d61:	ff 75 f4             	push   -0xc(%ebp)
80105d64:	e8 12 be ff ff       	call   80101b7b <iput>
80105d69:	83 c4 10             	add    $0x10,%esp

  end_op();
80105d6c:	e8 4d d8 ff ff       	call   801035be <end_op>

  return 0;
80105d71:	b8 00 00 00 00       	mov    $0x0,%eax
80105d76:	eb 48                	jmp    80105dc0 <sys_link+0x1a2>
    goto bad;
80105d78:	90                   	nop

bad:
  ilock(ip);
80105d79:	83 ec 0c             	sub    $0xc,%esp
80105d7c:	ff 75 f4             	push   -0xc(%ebp)
80105d7f:	e8 96 bc ff ff       	call   80101a1a <ilock>
80105d84:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105d87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d8a:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105d8e:	83 e8 01             	sub    $0x1,%eax
80105d91:	89 c2                	mov    %eax,%edx
80105d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d96:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105d9a:	83 ec 0c             	sub    $0xc,%esp
80105d9d:	ff 75 f4             	push   -0xc(%ebp)
80105da0:	e8 98 ba ff ff       	call   8010183d <iupdate>
80105da5:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105da8:	83 ec 0c             	sub    $0xc,%esp
80105dab:	ff 75 f4             	push   -0xc(%ebp)
80105dae:	e8 98 be ff ff       	call   80101c4b <iunlockput>
80105db3:	83 c4 10             	add    $0x10,%esp
  end_op();
80105db6:	e8 03 d8 ff ff       	call   801035be <end_op>
  return -1;
80105dbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105dc0:	c9                   	leave  
80105dc1:	c3                   	ret    

80105dc2 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105dc2:	55                   	push   %ebp
80105dc3:	89 e5                	mov    %esp,%ebp
80105dc5:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105dc8:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105dcf:	eb 40                	jmp    80105e11 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105dd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dd4:	6a 10                	push   $0x10
80105dd6:	50                   	push   %eax
80105dd7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105dda:	50                   	push   %eax
80105ddb:	ff 75 08             	push   0x8(%ebp)
80105dde:	e8 23 c1 ff ff       	call   80101f06 <readi>
80105de3:	83 c4 10             	add    $0x10,%esp
80105de6:	83 f8 10             	cmp    $0x10,%eax
80105de9:	74 0d                	je     80105df8 <isdirempty+0x36>
      panic("isdirempty: readi");
80105deb:	83 ec 0c             	sub    $0xc,%esp
80105dee:	68 60 8b 10 80       	push   $0x80108b60
80105df3:	e8 bd a7 ff ff       	call   801005b5 <panic>
    if(de.inum != 0)
80105df8:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105dfc:	66 85 c0             	test   %ax,%ax
80105dff:	74 07                	je     80105e08 <isdirempty+0x46>
      return 0;
80105e01:	b8 00 00 00 00       	mov    $0x0,%eax
80105e06:	eb 1b                	jmp    80105e23 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e0b:	83 c0 10             	add    $0x10,%eax
80105e0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e11:	8b 45 08             	mov    0x8(%ebp),%eax
80105e14:	8b 50 58             	mov    0x58(%eax),%edx
80105e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e1a:	39 c2                	cmp    %eax,%edx
80105e1c:	77 b3                	ja     80105dd1 <isdirempty+0xf>
  }
  return 1;
80105e1e:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105e23:	c9                   	leave  
80105e24:	c3                   	ret    

80105e25 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105e25:	55                   	push   %ebp
80105e26:	89 e5                	mov    %esp,%ebp
80105e28:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105e2b:	83 ec 08             	sub    $0x8,%esp
80105e2e:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105e31:	50                   	push   %eax
80105e32:	6a 00                	push   $0x0
80105e34:	e8 a2 fa ff ff       	call   801058db <argstr>
80105e39:	83 c4 10             	add    $0x10,%esp
80105e3c:	85 c0                	test   %eax,%eax
80105e3e:	79 0a                	jns    80105e4a <sys_unlink+0x25>
    return -1;
80105e40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e45:	e9 bf 01 00 00       	jmp    80106009 <sys_unlink+0x1e4>

  begin_op();
80105e4a:	e8 e3 d6 ff ff       	call   80103532 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105e4f:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105e52:	83 ec 08             	sub    $0x8,%esp
80105e55:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105e58:	52                   	push   %edx
80105e59:	50                   	push   %eax
80105e5a:	e8 0a c7 ff ff       	call   80102569 <nameiparent>
80105e5f:	83 c4 10             	add    $0x10,%esp
80105e62:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e69:	75 0f                	jne    80105e7a <sys_unlink+0x55>
    end_op();
80105e6b:	e8 4e d7 ff ff       	call   801035be <end_op>
    return -1;
80105e70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e75:	e9 8f 01 00 00       	jmp    80106009 <sys_unlink+0x1e4>
  }

  ilock(dp);
80105e7a:	83 ec 0c             	sub    $0xc,%esp
80105e7d:	ff 75 f4             	push   -0xc(%ebp)
80105e80:	e8 95 bb ff ff       	call   80101a1a <ilock>
80105e85:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105e88:	83 ec 08             	sub    $0x8,%esp
80105e8b:	68 72 8b 10 80       	push   $0x80108b72
80105e90:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105e93:	50                   	push   %eax
80105e94:	e8 48 c3 ff ff       	call   801021e1 <namecmp>
80105e99:	83 c4 10             	add    $0x10,%esp
80105e9c:	85 c0                	test   %eax,%eax
80105e9e:	0f 84 49 01 00 00    	je     80105fed <sys_unlink+0x1c8>
80105ea4:	83 ec 08             	sub    $0x8,%esp
80105ea7:	68 74 8b 10 80       	push   $0x80108b74
80105eac:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105eaf:	50                   	push   %eax
80105eb0:	e8 2c c3 ff ff       	call   801021e1 <namecmp>
80105eb5:	83 c4 10             	add    $0x10,%esp
80105eb8:	85 c0                	test   %eax,%eax
80105eba:	0f 84 2d 01 00 00    	je     80105fed <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105ec0:	83 ec 04             	sub    $0x4,%esp
80105ec3:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105ec6:	50                   	push   %eax
80105ec7:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105eca:	50                   	push   %eax
80105ecb:	ff 75 f4             	push   -0xc(%ebp)
80105ece:	e8 29 c3 ff ff       	call   801021fc <dirlookup>
80105ed3:	83 c4 10             	add    $0x10,%esp
80105ed6:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ed9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105edd:	0f 84 0d 01 00 00    	je     80105ff0 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105ee3:	83 ec 0c             	sub    $0xc,%esp
80105ee6:	ff 75 f0             	push   -0x10(%ebp)
80105ee9:	e8 2c bb ff ff       	call   80101a1a <ilock>
80105eee:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105ef1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ef4:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105ef8:	66 85 c0             	test   %ax,%ax
80105efb:	7f 0d                	jg     80105f0a <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105efd:	83 ec 0c             	sub    $0xc,%esp
80105f00:	68 77 8b 10 80       	push   $0x80108b77
80105f05:	e8 ab a6 ff ff       	call   801005b5 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105f0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f0d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105f11:	66 83 f8 01          	cmp    $0x1,%ax
80105f15:	75 25                	jne    80105f3c <sys_unlink+0x117>
80105f17:	83 ec 0c             	sub    $0xc,%esp
80105f1a:	ff 75 f0             	push   -0x10(%ebp)
80105f1d:	e8 a0 fe ff ff       	call   80105dc2 <isdirempty>
80105f22:	83 c4 10             	add    $0x10,%esp
80105f25:	85 c0                	test   %eax,%eax
80105f27:	75 13                	jne    80105f3c <sys_unlink+0x117>
    iunlockput(ip);
80105f29:	83 ec 0c             	sub    $0xc,%esp
80105f2c:	ff 75 f0             	push   -0x10(%ebp)
80105f2f:	e8 17 bd ff ff       	call   80101c4b <iunlockput>
80105f34:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105f37:	e9 b5 00 00 00       	jmp    80105ff1 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105f3c:	83 ec 04             	sub    $0x4,%esp
80105f3f:	6a 10                	push   $0x10
80105f41:	6a 00                	push   $0x0
80105f43:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105f46:	50                   	push   %eax
80105f47:	e8 cf f5 ff ff       	call   8010551b <memset>
80105f4c:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105f4f:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105f52:	6a 10                	push   $0x10
80105f54:	50                   	push   %eax
80105f55:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105f58:	50                   	push   %eax
80105f59:	ff 75 f4             	push   -0xc(%ebp)
80105f5c:	e8 fa c0 ff ff       	call   8010205b <writei>
80105f61:	83 c4 10             	add    $0x10,%esp
80105f64:	83 f8 10             	cmp    $0x10,%eax
80105f67:	74 0d                	je     80105f76 <sys_unlink+0x151>
    panic("unlink: writei");
80105f69:	83 ec 0c             	sub    $0xc,%esp
80105f6c:	68 89 8b 10 80       	push   $0x80108b89
80105f71:	e8 3f a6 ff ff       	call   801005b5 <panic>
  if(ip->type == T_DIR){
80105f76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f79:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105f7d:	66 83 f8 01          	cmp    $0x1,%ax
80105f81:	75 21                	jne    80105fa4 <sys_unlink+0x17f>
    dp->nlink--;
80105f83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f86:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105f8a:	83 e8 01             	sub    $0x1,%eax
80105f8d:	89 c2                	mov    %eax,%edx
80105f8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f92:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105f96:	83 ec 0c             	sub    $0xc,%esp
80105f99:	ff 75 f4             	push   -0xc(%ebp)
80105f9c:	e8 9c b8 ff ff       	call   8010183d <iupdate>
80105fa1:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105fa4:	83 ec 0c             	sub    $0xc,%esp
80105fa7:	ff 75 f4             	push   -0xc(%ebp)
80105faa:	e8 9c bc ff ff       	call   80101c4b <iunlockput>
80105faf:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105fb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fb5:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105fb9:	83 e8 01             	sub    $0x1,%eax
80105fbc:	89 c2                	mov    %eax,%edx
80105fbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fc1:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105fc5:	83 ec 0c             	sub    $0xc,%esp
80105fc8:	ff 75 f0             	push   -0x10(%ebp)
80105fcb:	e8 6d b8 ff ff       	call   8010183d <iupdate>
80105fd0:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105fd3:	83 ec 0c             	sub    $0xc,%esp
80105fd6:	ff 75 f0             	push   -0x10(%ebp)
80105fd9:	e8 6d bc ff ff       	call   80101c4b <iunlockput>
80105fde:	83 c4 10             	add    $0x10,%esp

  end_op();
80105fe1:	e8 d8 d5 ff ff       	call   801035be <end_op>

  return 0;
80105fe6:	b8 00 00 00 00       	mov    $0x0,%eax
80105feb:	eb 1c                	jmp    80106009 <sys_unlink+0x1e4>
    goto bad;
80105fed:	90                   	nop
80105fee:	eb 01                	jmp    80105ff1 <sys_unlink+0x1cc>
    goto bad;
80105ff0:	90                   	nop

bad:
  iunlockput(dp);
80105ff1:	83 ec 0c             	sub    $0xc,%esp
80105ff4:	ff 75 f4             	push   -0xc(%ebp)
80105ff7:	e8 4f bc ff ff       	call   80101c4b <iunlockput>
80105ffc:	83 c4 10             	add    $0x10,%esp
  end_op();
80105fff:	e8 ba d5 ff ff       	call   801035be <end_op>
  return -1;
80106004:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106009:	c9                   	leave  
8010600a:	c3                   	ret    

8010600b <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010600b:	55                   	push   %ebp
8010600c:	89 e5                	mov    %esp,%ebp
8010600e:	83 ec 38             	sub    $0x38,%esp
80106011:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106014:	8b 55 10             	mov    0x10(%ebp),%edx
80106017:	8b 45 14             	mov    0x14(%ebp),%eax
8010601a:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010601e:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106022:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106026:	83 ec 08             	sub    $0x8,%esp
80106029:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010602c:	50                   	push   %eax
8010602d:	ff 75 08             	push   0x8(%ebp)
80106030:	e8 34 c5 ff ff       	call   80102569 <nameiparent>
80106035:	83 c4 10             	add    $0x10,%esp
80106038:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010603b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010603f:	75 0a                	jne    8010604b <create+0x40>
    return 0;
80106041:	b8 00 00 00 00       	mov    $0x0,%eax
80106046:	e9 8e 01 00 00       	jmp    801061d9 <create+0x1ce>
  ilock(dp);
8010604b:	83 ec 0c             	sub    $0xc,%esp
8010604e:	ff 75 f4             	push   -0xc(%ebp)
80106051:	e8 c4 b9 ff ff       	call   80101a1a <ilock>
80106056:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, 0)) != 0){
80106059:	83 ec 04             	sub    $0x4,%esp
8010605c:	6a 00                	push   $0x0
8010605e:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106061:	50                   	push   %eax
80106062:	ff 75 f4             	push   -0xc(%ebp)
80106065:	e8 92 c1 ff ff       	call   801021fc <dirlookup>
8010606a:	83 c4 10             	add    $0x10,%esp
8010606d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106070:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106074:	74 50                	je     801060c6 <create+0xbb>
    iunlockput(dp);
80106076:	83 ec 0c             	sub    $0xc,%esp
80106079:	ff 75 f4             	push   -0xc(%ebp)
8010607c:	e8 ca bb ff ff       	call   80101c4b <iunlockput>
80106081:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80106084:	83 ec 0c             	sub    $0xc,%esp
80106087:	ff 75 f0             	push   -0x10(%ebp)
8010608a:	e8 8b b9 ff ff       	call   80101a1a <ilock>
8010608f:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80106092:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106097:	75 15                	jne    801060ae <create+0xa3>
80106099:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010609c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801060a0:	66 83 f8 02          	cmp    $0x2,%ax
801060a4:	75 08                	jne    801060ae <create+0xa3>
      return ip;
801060a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060a9:	e9 2b 01 00 00       	jmp    801061d9 <create+0x1ce>
    iunlockput(ip);
801060ae:	83 ec 0c             	sub    $0xc,%esp
801060b1:	ff 75 f0             	push   -0x10(%ebp)
801060b4:	e8 92 bb ff ff       	call   80101c4b <iunlockput>
801060b9:	83 c4 10             	add    $0x10,%esp
    return 0;
801060bc:	b8 00 00 00 00       	mov    $0x0,%eax
801060c1:	e9 13 01 00 00       	jmp    801061d9 <create+0x1ce>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801060c6:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801060ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060cd:	8b 00                	mov    (%eax),%eax
801060cf:	83 ec 08             	sub    $0x8,%esp
801060d2:	52                   	push   %edx
801060d3:	50                   	push   %eax
801060d4:	e8 8d b6 ff ff       	call   80101766 <ialloc>
801060d9:	83 c4 10             	add    $0x10,%esp
801060dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
801060df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801060e3:	75 0d                	jne    801060f2 <create+0xe7>
    panic("create: ialloc");
801060e5:	83 ec 0c             	sub    $0xc,%esp
801060e8:	68 98 8b 10 80       	push   $0x80108b98
801060ed:	e8 c3 a4 ff ff       	call   801005b5 <panic>

  ilock(ip);
801060f2:	83 ec 0c             	sub    $0xc,%esp
801060f5:	ff 75 f0             	push   -0x10(%ebp)
801060f8:	e8 1d b9 ff ff       	call   80101a1a <ilock>
801060fd:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80106100:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106103:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106107:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
8010610b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010610e:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106112:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80106116:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106119:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
8010611f:	83 ec 0c             	sub    $0xc,%esp
80106122:	ff 75 f0             	push   -0x10(%ebp)
80106125:	e8 13 b7 ff ff       	call   8010183d <iupdate>
8010612a:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
8010612d:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106132:	75 6a                	jne    8010619e <create+0x193>
    dp->nlink++;  // for ".."
80106134:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106137:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010613b:	83 c0 01             	add    $0x1,%eax
8010613e:	89 c2                	mov    %eax,%edx
80106140:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106143:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80106147:	83 ec 0c             	sub    $0xc,%esp
8010614a:	ff 75 f4             	push   -0xc(%ebp)
8010614d:	e8 eb b6 ff ff       	call   8010183d <iupdate>
80106152:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106155:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106158:	8b 40 04             	mov    0x4(%eax),%eax
8010615b:	83 ec 04             	sub    $0x4,%esp
8010615e:	50                   	push   %eax
8010615f:	68 72 8b 10 80       	push   $0x80108b72
80106164:	ff 75 f0             	push   -0x10(%ebp)
80106167:	e8 4a c1 ff ff       	call   801022b6 <dirlink>
8010616c:	83 c4 10             	add    $0x10,%esp
8010616f:	85 c0                	test   %eax,%eax
80106171:	78 1e                	js     80106191 <create+0x186>
80106173:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106176:	8b 40 04             	mov    0x4(%eax),%eax
80106179:	83 ec 04             	sub    $0x4,%esp
8010617c:	50                   	push   %eax
8010617d:	68 74 8b 10 80       	push   $0x80108b74
80106182:	ff 75 f0             	push   -0x10(%ebp)
80106185:	e8 2c c1 ff ff       	call   801022b6 <dirlink>
8010618a:	83 c4 10             	add    $0x10,%esp
8010618d:	85 c0                	test   %eax,%eax
8010618f:	79 0d                	jns    8010619e <create+0x193>
      panic("create dots");
80106191:	83 ec 0c             	sub    $0xc,%esp
80106194:	68 a7 8b 10 80       	push   $0x80108ba7
80106199:	e8 17 a4 ff ff       	call   801005b5 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
8010619e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061a1:	8b 40 04             	mov    0x4(%eax),%eax
801061a4:	83 ec 04             	sub    $0x4,%esp
801061a7:	50                   	push   %eax
801061a8:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801061ab:	50                   	push   %eax
801061ac:	ff 75 f4             	push   -0xc(%ebp)
801061af:	e8 02 c1 ff ff       	call   801022b6 <dirlink>
801061b4:	83 c4 10             	add    $0x10,%esp
801061b7:	85 c0                	test   %eax,%eax
801061b9:	79 0d                	jns    801061c8 <create+0x1bd>
    panic("create: dirlink");
801061bb:	83 ec 0c             	sub    $0xc,%esp
801061be:	68 b3 8b 10 80       	push   $0x80108bb3
801061c3:	e8 ed a3 ff ff       	call   801005b5 <panic>

  iunlockput(dp);
801061c8:	83 ec 0c             	sub    $0xc,%esp
801061cb:	ff 75 f4             	push   -0xc(%ebp)
801061ce:	e8 78 ba ff ff       	call   80101c4b <iunlockput>
801061d3:	83 c4 10             	add    $0x10,%esp

  return ip;
801061d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801061d9:	c9                   	leave  
801061da:	c3                   	ret    

801061db <sys_open>:

int
sys_open(void)
{
801061db:	55                   	push   %ebp
801061dc:	89 e5                	mov    %esp,%ebp
801061de:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801061e1:	83 ec 08             	sub    $0x8,%esp
801061e4:	8d 45 e8             	lea    -0x18(%ebp),%eax
801061e7:	50                   	push   %eax
801061e8:	6a 00                	push   $0x0
801061ea:	e8 ec f6 ff ff       	call   801058db <argstr>
801061ef:	83 c4 10             	add    $0x10,%esp
801061f2:	85 c0                	test   %eax,%eax
801061f4:	78 15                	js     8010620b <sys_open+0x30>
801061f6:	83 ec 08             	sub    $0x8,%esp
801061f9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801061fc:	50                   	push   %eax
801061fd:	6a 01                	push   $0x1
801061ff:	e8 42 f6 ff ff       	call   80105846 <argint>
80106204:	83 c4 10             	add    $0x10,%esp
80106207:	85 c0                	test   %eax,%eax
80106209:	79 0a                	jns    80106215 <sys_open+0x3a>
    return -1;
8010620b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106210:	e9 61 01 00 00       	jmp    80106376 <sys_open+0x19b>

  begin_op();
80106215:	e8 18 d3 ff ff       	call   80103532 <begin_op>

  if(omode & O_CREATE){
8010621a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010621d:	25 00 02 00 00       	and    $0x200,%eax
80106222:	85 c0                	test   %eax,%eax
80106224:	74 2a                	je     80106250 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80106226:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106229:	6a 00                	push   $0x0
8010622b:	6a 00                	push   $0x0
8010622d:	6a 02                	push   $0x2
8010622f:	50                   	push   %eax
80106230:	e8 d6 fd ff ff       	call   8010600b <create>
80106235:	83 c4 10             	add    $0x10,%esp
80106238:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
8010623b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010623f:	75 75                	jne    801062b6 <sys_open+0xdb>
      end_op();
80106241:	e8 78 d3 ff ff       	call   801035be <end_op>
      return -1;
80106246:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010624b:	e9 26 01 00 00       	jmp    80106376 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80106250:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106253:	83 ec 0c             	sub    $0xc,%esp
80106256:	50                   	push   %eax
80106257:	e8 f1 c2 ff ff       	call   8010254d <namei>
8010625c:	83 c4 10             	add    $0x10,%esp
8010625f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106262:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106266:	75 0f                	jne    80106277 <sys_open+0x9c>
      end_op();
80106268:	e8 51 d3 ff ff       	call   801035be <end_op>
      return -1;
8010626d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106272:	e9 ff 00 00 00       	jmp    80106376 <sys_open+0x19b>
    }
    ilock(ip);
80106277:	83 ec 0c             	sub    $0xc,%esp
8010627a:	ff 75 f4             	push   -0xc(%ebp)
8010627d:	e8 98 b7 ff ff       	call   80101a1a <ilock>
80106282:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106285:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106288:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010628c:	66 83 f8 01          	cmp    $0x1,%ax
80106290:	75 24                	jne    801062b6 <sys_open+0xdb>
80106292:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106295:	85 c0                	test   %eax,%eax
80106297:	74 1d                	je     801062b6 <sys_open+0xdb>
      iunlockput(ip);
80106299:	83 ec 0c             	sub    $0xc,%esp
8010629c:	ff 75 f4             	push   -0xc(%ebp)
8010629f:	e8 a7 b9 ff ff       	call   80101c4b <iunlockput>
801062a4:	83 c4 10             	add    $0x10,%esp
      end_op();
801062a7:	e8 12 d3 ff ff       	call   801035be <end_op>
      return -1;
801062ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062b1:	e9 c0 00 00 00       	jmp    80106376 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801062b6:	e8 65 ad ff ff       	call   80101020 <filealloc>
801062bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801062be:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801062c2:	74 17                	je     801062db <sys_open+0x100>
801062c4:	83 ec 0c             	sub    $0xc,%esp
801062c7:	ff 75 f0             	push   -0x10(%ebp)
801062ca:	e8 35 f7 ff ff       	call   80105a04 <fdalloc>
801062cf:	83 c4 10             	add    $0x10,%esp
801062d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
801062d5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801062d9:	79 2e                	jns    80106309 <sys_open+0x12e>
    if(f)
801062db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801062df:	74 0e                	je     801062ef <sys_open+0x114>
      fileclose(f);
801062e1:	83 ec 0c             	sub    $0xc,%esp
801062e4:	ff 75 f0             	push   -0x10(%ebp)
801062e7:	e8 f2 ad ff ff       	call   801010de <fileclose>
801062ec:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801062ef:	83 ec 0c             	sub    $0xc,%esp
801062f2:	ff 75 f4             	push   -0xc(%ebp)
801062f5:	e8 51 b9 ff ff       	call   80101c4b <iunlockput>
801062fa:	83 c4 10             	add    $0x10,%esp
    end_op();
801062fd:	e8 bc d2 ff ff       	call   801035be <end_op>
    return -1;
80106302:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106307:	eb 6d                	jmp    80106376 <sys_open+0x19b>
  }
  iunlock(ip);
80106309:	83 ec 0c             	sub    $0xc,%esp
8010630c:	ff 75 f4             	push   -0xc(%ebp)
8010630f:	e8 19 b8 ff ff       	call   80101b2d <iunlock>
80106314:	83 c4 10             	add    $0x10,%esp
  end_op();
80106317:	e8 a2 d2 ff ff       	call   801035be <end_op>

  f->type = FD_INODE;
8010631c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010631f:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106325:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106328:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010632b:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010632e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106331:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106338:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010633b:	83 e0 01             	and    $0x1,%eax
8010633e:	85 c0                	test   %eax,%eax
80106340:	0f 94 c0             	sete   %al
80106343:	89 c2                	mov    %eax,%edx
80106345:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106348:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010634b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010634e:	83 e0 01             	and    $0x1,%eax
80106351:	85 c0                	test   %eax,%eax
80106353:	75 0a                	jne    8010635f <sys_open+0x184>
80106355:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106358:	83 e0 02             	and    $0x2,%eax
8010635b:	85 c0                	test   %eax,%eax
8010635d:	74 07                	je     80106366 <sys_open+0x18b>
8010635f:	b8 01 00 00 00       	mov    $0x1,%eax
80106364:	eb 05                	jmp    8010636b <sys_open+0x190>
80106366:	b8 00 00 00 00       	mov    $0x0,%eax
8010636b:	89 c2                	mov    %eax,%edx
8010636d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106370:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106373:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106376:	c9                   	leave  
80106377:	c3                   	ret    

80106378 <sys_mkdir>:

int
sys_mkdir(void)
{
80106378:	55                   	push   %ebp
80106379:	89 e5                	mov    %esp,%ebp
8010637b:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010637e:	e8 af d1 ff ff       	call   80103532 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106383:	83 ec 08             	sub    $0x8,%esp
80106386:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106389:	50                   	push   %eax
8010638a:	6a 00                	push   $0x0
8010638c:	e8 4a f5 ff ff       	call   801058db <argstr>
80106391:	83 c4 10             	add    $0x10,%esp
80106394:	85 c0                	test   %eax,%eax
80106396:	78 1b                	js     801063b3 <sys_mkdir+0x3b>
80106398:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010639b:	6a 00                	push   $0x0
8010639d:	6a 00                	push   $0x0
8010639f:	6a 01                	push   $0x1
801063a1:	50                   	push   %eax
801063a2:	e8 64 fc ff ff       	call   8010600b <create>
801063a7:	83 c4 10             	add    $0x10,%esp
801063aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
801063ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063b1:	75 0c                	jne    801063bf <sys_mkdir+0x47>
    end_op();
801063b3:	e8 06 d2 ff ff       	call   801035be <end_op>
    return -1;
801063b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063bd:	eb 18                	jmp    801063d7 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
801063bf:	83 ec 0c             	sub    $0xc,%esp
801063c2:	ff 75 f4             	push   -0xc(%ebp)
801063c5:	e8 81 b8 ff ff       	call   80101c4b <iunlockput>
801063ca:	83 c4 10             	add    $0x10,%esp
  end_op();
801063cd:	e8 ec d1 ff ff       	call   801035be <end_op>
  return 0;
801063d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801063d7:	c9                   	leave  
801063d8:	c3                   	ret    

801063d9 <sys_mknod>:

int
sys_mknod(void)
{
801063d9:	55                   	push   %ebp
801063da:	89 e5                	mov    %esp,%ebp
801063dc:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
801063df:	e8 4e d1 ff ff       	call   80103532 <begin_op>
  if((argstr(0, &path)) < 0 ||
801063e4:	83 ec 08             	sub    $0x8,%esp
801063e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063ea:	50                   	push   %eax
801063eb:	6a 00                	push   $0x0
801063ed:	e8 e9 f4 ff ff       	call   801058db <argstr>
801063f2:	83 c4 10             	add    $0x10,%esp
801063f5:	85 c0                	test   %eax,%eax
801063f7:	78 4f                	js     80106448 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
801063f9:	83 ec 08             	sub    $0x8,%esp
801063fc:	8d 45 ec             	lea    -0x14(%ebp),%eax
801063ff:	50                   	push   %eax
80106400:	6a 01                	push   $0x1
80106402:	e8 3f f4 ff ff       	call   80105846 <argint>
80106407:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
8010640a:	85 c0                	test   %eax,%eax
8010640c:	78 3a                	js     80106448 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
8010640e:	83 ec 08             	sub    $0x8,%esp
80106411:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106414:	50                   	push   %eax
80106415:	6a 02                	push   $0x2
80106417:	e8 2a f4 ff ff       	call   80105846 <argint>
8010641c:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
8010641f:	85 c0                	test   %eax,%eax
80106421:	78 25                	js     80106448 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80106423:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106426:	0f bf c8             	movswl %ax,%ecx
80106429:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010642c:	0f bf d0             	movswl %ax,%edx
8010642f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106432:	51                   	push   %ecx
80106433:	52                   	push   %edx
80106434:	6a 03                	push   $0x3
80106436:	50                   	push   %eax
80106437:	e8 cf fb ff ff       	call   8010600b <create>
8010643c:	83 c4 10             	add    $0x10,%esp
8010643f:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80106442:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106446:	75 0c                	jne    80106454 <sys_mknod+0x7b>
    end_op();
80106448:	e8 71 d1 ff ff       	call   801035be <end_op>
    return -1;
8010644d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106452:	eb 18                	jmp    8010646c <sys_mknod+0x93>
  }
  iunlockput(ip);
80106454:	83 ec 0c             	sub    $0xc,%esp
80106457:	ff 75 f4             	push   -0xc(%ebp)
8010645a:	e8 ec b7 ff ff       	call   80101c4b <iunlockput>
8010645f:	83 c4 10             	add    $0x10,%esp
  end_op();
80106462:	e8 57 d1 ff ff       	call   801035be <end_op>
  return 0;
80106467:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010646c:	c9                   	leave  
8010646d:	c3                   	ret    

8010646e <sys_chdir>:

int
sys_chdir(void)
{
8010646e:	55                   	push   %ebp
8010646f:	89 e5                	mov    %esp,%ebp
80106471:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80106474:	e8 61 de ff ff       	call   801042da <myproc>
80106479:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
8010647c:	e8 b1 d0 ff ff       	call   80103532 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106481:	83 ec 08             	sub    $0x8,%esp
80106484:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106487:	50                   	push   %eax
80106488:	6a 00                	push   $0x0
8010648a:	e8 4c f4 ff ff       	call   801058db <argstr>
8010648f:	83 c4 10             	add    $0x10,%esp
80106492:	85 c0                	test   %eax,%eax
80106494:	78 18                	js     801064ae <sys_chdir+0x40>
80106496:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106499:	83 ec 0c             	sub    $0xc,%esp
8010649c:	50                   	push   %eax
8010649d:	e8 ab c0 ff ff       	call   8010254d <namei>
801064a2:	83 c4 10             	add    $0x10,%esp
801064a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801064a8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801064ac:	75 0c                	jne    801064ba <sys_chdir+0x4c>
    end_op();
801064ae:	e8 0b d1 ff ff       	call   801035be <end_op>
    return -1;
801064b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064b8:	eb 68                	jmp    80106522 <sys_chdir+0xb4>
  }
  ilock(ip);
801064ba:	83 ec 0c             	sub    $0xc,%esp
801064bd:	ff 75 f0             	push   -0x10(%ebp)
801064c0:	e8 55 b5 ff ff       	call   80101a1a <ilock>
801064c5:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
801064c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064cb:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801064cf:	66 83 f8 01          	cmp    $0x1,%ax
801064d3:	74 1a                	je     801064ef <sys_chdir+0x81>
    iunlockput(ip);
801064d5:	83 ec 0c             	sub    $0xc,%esp
801064d8:	ff 75 f0             	push   -0x10(%ebp)
801064db:	e8 6b b7 ff ff       	call   80101c4b <iunlockput>
801064e0:	83 c4 10             	add    $0x10,%esp
    end_op();
801064e3:	e8 d6 d0 ff ff       	call   801035be <end_op>
    return -1;
801064e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064ed:	eb 33                	jmp    80106522 <sys_chdir+0xb4>
  }
  iunlock(ip);
801064ef:	83 ec 0c             	sub    $0xc,%esp
801064f2:	ff 75 f0             	push   -0x10(%ebp)
801064f5:	e8 33 b6 ff ff       	call   80101b2d <iunlock>
801064fa:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
801064fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106500:	8b 40 68             	mov    0x68(%eax),%eax
80106503:	83 ec 0c             	sub    $0xc,%esp
80106506:	50                   	push   %eax
80106507:	e8 6f b6 ff ff       	call   80101b7b <iput>
8010650c:	83 c4 10             	add    $0x10,%esp
  end_op();
8010650f:	e8 aa d0 ff ff       	call   801035be <end_op>
  curproc->cwd = ip;
80106514:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106517:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010651a:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
8010651d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106522:	c9                   	leave  
80106523:	c3                   	ret    

80106524 <sys_exec>:

int
sys_exec(void)
{
80106524:	55                   	push   %ebp
80106525:	89 e5                	mov    %esp,%ebp
80106527:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010652d:	83 ec 08             	sub    $0x8,%esp
80106530:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106533:	50                   	push   %eax
80106534:	6a 00                	push   $0x0
80106536:	e8 a0 f3 ff ff       	call   801058db <argstr>
8010653b:	83 c4 10             	add    $0x10,%esp
8010653e:	85 c0                	test   %eax,%eax
80106540:	78 18                	js     8010655a <sys_exec+0x36>
80106542:	83 ec 08             	sub    $0x8,%esp
80106545:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010654b:	50                   	push   %eax
8010654c:	6a 01                	push   $0x1
8010654e:	e8 f3 f2 ff ff       	call   80105846 <argint>
80106553:	83 c4 10             	add    $0x10,%esp
80106556:	85 c0                	test   %eax,%eax
80106558:	79 0a                	jns    80106564 <sys_exec+0x40>
    return -1;
8010655a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010655f:	e9 c6 00 00 00       	jmp    8010662a <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106564:	83 ec 04             	sub    $0x4,%esp
80106567:	68 80 00 00 00       	push   $0x80
8010656c:	6a 00                	push   $0x0
8010656e:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106574:	50                   	push   %eax
80106575:	e8 a1 ef ff ff       	call   8010551b <memset>
8010657a:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
8010657d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106584:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106587:	83 f8 1f             	cmp    $0x1f,%eax
8010658a:	76 0a                	jbe    80106596 <sys_exec+0x72>
      return -1;
8010658c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106591:	e9 94 00 00 00       	jmp    8010662a <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106596:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106599:	c1 e0 02             	shl    $0x2,%eax
8010659c:	89 c2                	mov    %eax,%edx
8010659e:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801065a4:	01 c2                	add    %eax,%edx
801065a6:	83 ec 08             	sub    $0x8,%esp
801065a9:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801065af:	50                   	push   %eax
801065b0:	52                   	push   %edx
801065b1:	e8 ef f1 ff ff       	call   801057a5 <fetchint>
801065b6:	83 c4 10             	add    $0x10,%esp
801065b9:	85 c0                	test   %eax,%eax
801065bb:	79 07                	jns    801065c4 <sys_exec+0xa0>
      return -1;
801065bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065c2:	eb 66                	jmp    8010662a <sys_exec+0x106>
    if(uarg == 0){
801065c4:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801065ca:	85 c0                	test   %eax,%eax
801065cc:	75 27                	jne    801065f5 <sys_exec+0xd1>
      argv[i] = 0;
801065ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065d1:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801065d8:	00 00 00 00 
      break;
801065dc:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801065dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065e0:	83 ec 08             	sub    $0x8,%esp
801065e3:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801065e9:	52                   	push   %edx
801065ea:	50                   	push   %eax
801065eb:	e8 d3 a5 ff ff       	call   80100bc3 <exec>
801065f0:	83 c4 10             	add    $0x10,%esp
801065f3:	eb 35                	jmp    8010662a <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
801065f5:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801065fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065fe:	c1 e0 02             	shl    $0x2,%eax
80106601:	01 c2                	add    %eax,%edx
80106603:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106609:	83 ec 08             	sub    $0x8,%esp
8010660c:	52                   	push   %edx
8010660d:	50                   	push   %eax
8010660e:	e8 d1 f1 ff ff       	call   801057e4 <fetchstr>
80106613:	83 c4 10             	add    $0x10,%esp
80106616:	85 c0                	test   %eax,%eax
80106618:	79 07                	jns    80106621 <sys_exec+0xfd>
      return -1;
8010661a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010661f:	eb 09                	jmp    8010662a <sys_exec+0x106>
  for(i=0;; i++){
80106621:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80106625:	e9 5a ff ff ff       	jmp    80106584 <sys_exec+0x60>
}
8010662a:	c9                   	leave  
8010662b:	c3                   	ret    

8010662c <sys_pipe>:

int
sys_pipe(void)
{
8010662c:	55                   	push   %ebp
8010662d:	89 e5                	mov    %esp,%ebp
8010662f:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106632:	83 ec 04             	sub    $0x4,%esp
80106635:	6a 08                	push   $0x8
80106637:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010663a:	50                   	push   %eax
8010663b:	6a 00                	push   $0x0
8010663d:	e8 31 f2 ff ff       	call   80105873 <argptr>
80106642:	83 c4 10             	add    $0x10,%esp
80106645:	85 c0                	test   %eax,%eax
80106647:	79 0a                	jns    80106653 <sys_pipe+0x27>
    return -1;
80106649:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010664e:	e9 ae 00 00 00       	jmp    80106701 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80106653:	83 ec 08             	sub    $0x8,%esp
80106656:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106659:	50                   	push   %eax
8010665a:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010665d:	50                   	push   %eax
8010665e:	e8 73 d7 ff ff       	call   80103dd6 <pipealloc>
80106663:	83 c4 10             	add    $0x10,%esp
80106666:	85 c0                	test   %eax,%eax
80106668:	79 0a                	jns    80106674 <sys_pipe+0x48>
    return -1;
8010666a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010666f:	e9 8d 00 00 00       	jmp    80106701 <sys_pipe+0xd5>
  fd0 = -1;
80106674:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010667b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010667e:	83 ec 0c             	sub    $0xc,%esp
80106681:	50                   	push   %eax
80106682:	e8 7d f3 ff ff       	call   80105a04 <fdalloc>
80106687:	83 c4 10             	add    $0x10,%esp
8010668a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010668d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106691:	78 18                	js     801066ab <sys_pipe+0x7f>
80106693:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106696:	83 ec 0c             	sub    $0xc,%esp
80106699:	50                   	push   %eax
8010669a:	e8 65 f3 ff ff       	call   80105a04 <fdalloc>
8010669f:	83 c4 10             	add    $0x10,%esp
801066a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801066a5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801066a9:	79 3e                	jns    801066e9 <sys_pipe+0xbd>
    if(fd0 >= 0)
801066ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801066af:	78 13                	js     801066c4 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
801066b1:	e8 24 dc ff ff       	call   801042da <myproc>
801066b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066b9:	83 c2 08             	add    $0x8,%edx
801066bc:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801066c3:	00 
    fileclose(rf);
801066c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801066c7:	83 ec 0c             	sub    $0xc,%esp
801066ca:	50                   	push   %eax
801066cb:	e8 0e aa ff ff       	call   801010de <fileclose>
801066d0:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
801066d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801066d6:	83 ec 0c             	sub    $0xc,%esp
801066d9:	50                   	push   %eax
801066da:	e8 ff a9 ff ff       	call   801010de <fileclose>
801066df:	83 c4 10             	add    $0x10,%esp
    return -1;
801066e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066e7:	eb 18                	jmp    80106701 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
801066e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801066ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066ef:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801066f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801066f4:	8d 50 04             	lea    0x4(%eax),%edx
801066f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066fa:	89 02                	mov    %eax,(%edx)
  return 0;
801066fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106701:	c9                   	leave  
80106702:	c3                   	ret    

80106703 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106703:	55                   	push   %ebp
80106704:	89 e5                	mov    %esp,%ebp
80106706:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106709:	e8 86 df ff ff       	call   80104694 <fork>
}
8010670e:	c9                   	leave  
8010670f:	c3                   	ret    

80106710 <sys_exit>:

int
sys_exit(void)
{
80106710:	55                   	push   %ebp
80106711:	89 e5                	mov    %esp,%ebp
80106713:	83 ec 08             	sub    $0x8,%esp
  exit();
80106716:	e8 f2 e0 ff ff       	call   8010480d <exit>
  return 0;  // not reached
8010671b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106720:	c9                   	leave  
80106721:	c3                   	ret    

80106722 <sys_wait>:

int
sys_wait(void)
{
80106722:	55                   	push   %ebp
80106723:	89 e5                	mov    %esp,%ebp
80106725:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106728:	e8 03 e2 ff ff       	call   80104930 <wait>
}
8010672d:	c9                   	leave  
8010672e:	c3                   	ret    

8010672f <sys_kill>:

int
sys_kill(void)
{
8010672f:	55                   	push   %ebp
80106730:	89 e5                	mov    %esp,%ebp
80106732:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106735:	83 ec 08             	sub    $0x8,%esp
80106738:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010673b:	50                   	push   %eax
8010673c:	6a 00                	push   $0x0
8010673e:	e8 03 f1 ff ff       	call   80105846 <argint>
80106743:	83 c4 10             	add    $0x10,%esp
80106746:	85 c0                	test   %eax,%eax
80106748:	79 07                	jns    80106751 <sys_kill+0x22>
    return -1;
8010674a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010674f:	eb 0f                	jmp    80106760 <sys_kill+0x31>
  return kill(pid);
80106751:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106754:	83 ec 0c             	sub    $0xc,%esp
80106757:	50                   	push   %eax
80106758:	e8 b3 e6 ff ff       	call   80104e10 <kill>
8010675d:	83 c4 10             	add    $0x10,%esp
}
80106760:	c9                   	leave  
80106761:	c3                   	ret    

80106762 <sys_getpid>:

int
sys_getpid(void)
{
80106762:	55                   	push   %ebp
80106763:	89 e5                	mov    %esp,%ebp
80106765:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106768:	e8 6d db ff ff       	call   801042da <myproc>
8010676d:	8b 40 10             	mov    0x10(%eax),%eax
}
80106770:	c9                   	leave  
80106771:	c3                   	ret    

80106772 <sys_sbrk>:

int
sys_sbrk(void)
{
80106772:	55                   	push   %ebp
80106773:	89 e5                	mov    %esp,%ebp
80106775:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106778:	83 ec 08             	sub    $0x8,%esp
8010677b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010677e:	50                   	push   %eax
8010677f:	6a 00                	push   $0x0
80106781:	e8 c0 f0 ff ff       	call   80105846 <argint>
80106786:	83 c4 10             	add    $0x10,%esp
80106789:	85 c0                	test   %eax,%eax
8010678b:	79 07                	jns    80106794 <sys_sbrk+0x22>
    return -1;
8010678d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106792:	eb 27                	jmp    801067bb <sys_sbrk+0x49>
  addr = myproc()->sz;
80106794:	e8 41 db ff ff       	call   801042da <myproc>
80106799:	8b 00                	mov    (%eax),%eax
8010679b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010679e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067a1:	83 ec 0c             	sub    $0xc,%esp
801067a4:	50                   	push   %eax
801067a5:	e8 4f de ff ff       	call   801045f9 <growproc>
801067aa:	83 c4 10             	add    $0x10,%esp
801067ad:	85 c0                	test   %eax,%eax
801067af:	79 07                	jns    801067b8 <sys_sbrk+0x46>
    return -1;
801067b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067b6:	eb 03                	jmp    801067bb <sys_sbrk+0x49>
  return addr;
801067b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801067bb:	c9                   	leave  
801067bc:	c3                   	ret    

801067bd <sys_sleep>:

int
sys_sleep(void)
{
801067bd:	55                   	push   %ebp
801067be:	89 e5                	mov    %esp,%ebp
801067c0:	53                   	push   %ebx
801067c1:	83 ec 14             	sub    $0x14,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801067c4:	83 ec 08             	sub    $0x8,%esp
801067c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801067ca:	50                   	push   %eax
801067cb:	6a 00                	push   $0x0
801067cd:	e8 74 f0 ff ff       	call   80105846 <argint>
801067d2:	83 c4 10             	add    $0x10,%esp
801067d5:	85 c0                	test   %eax,%eax
801067d7:	79 0a                	jns    801067e3 <sys_sleep+0x26>
    return -1;
801067d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067de:	e9 8e 00 00 00       	jmp    80106871 <sys_sleep+0xb4>
  acquire(&tickslock);
801067e3:	83 ec 0c             	sub    $0xc,%esp
801067e6:	68 a0 58 11 80       	push   $0x801158a0
801067eb:	e8 a5 ea ff ff       	call   80105295 <acquire>
801067f0:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801067f3:	a1 d4 58 11 80       	mov    0x801158d4,%eax
801067f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  myproc()->wakeup_tick = ticks0 + n;
801067fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067fe:	89 c2                	mov    %eax,%edx
80106800:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106803:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80106806:	e8 cf da ff ff       	call   801042da <myproc>
8010680b:	89 da                	mov    %ebx,%edx
8010680d:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
  while(ticks - ticks0 < n){
80106813:	eb 38                	jmp    8010684d <sys_sleep+0x90>
    if(myproc()->killed){
80106815:	e8 c0 da ff ff       	call   801042da <myproc>
8010681a:	8b 40 24             	mov    0x24(%eax),%eax
8010681d:	85 c0                	test   %eax,%eax
8010681f:	74 17                	je     80106838 <sys_sleep+0x7b>
      release(&tickslock);
80106821:	83 ec 0c             	sub    $0xc,%esp
80106824:	68 a0 58 11 80       	push   $0x801158a0
80106829:	e8 d5 ea ff ff       	call   80105303 <release>
8010682e:	83 c4 10             	add    $0x10,%esp
      return -1;
80106831:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106836:	eb 39                	jmp    80106871 <sys_sleep+0xb4>
    }
    sleep(&ticks, &tickslock);
80106838:	83 ec 08             	sub    $0x8,%esp
8010683b:	68 a0 58 11 80       	push   $0x801158a0
80106840:	68 d4 58 11 80       	push   $0x801158d4
80106845:	e8 91 e4 ff ff       	call   80104cdb <sleep>
8010684a:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
8010684d:	a1 d4 58 11 80       	mov    0x801158d4,%eax
80106852:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106855:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106858:	39 d0                	cmp    %edx,%eax
8010685a:	72 b9                	jb     80106815 <sys_sleep+0x58>
  }
  release(&tickslock);
8010685c:	83 ec 0c             	sub    $0xc,%esp
8010685f:	68 a0 58 11 80       	push   $0x801158a0
80106864:	e8 9a ea ff ff       	call   80105303 <release>
80106869:	83 c4 10             	add    $0x10,%esp
  return 0;
8010686c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106871:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106874:	c9                   	leave  
80106875:	c3                   	ret    

80106876 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106876:	55                   	push   %ebp
80106877:	89 e5                	mov    %esp,%ebp
80106879:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
8010687c:	83 ec 0c             	sub    $0xc,%esp
8010687f:	68 a0 58 11 80       	push   $0x801158a0
80106884:	e8 0c ea ff ff       	call   80105295 <acquire>
80106889:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
8010688c:	a1 d4 58 11 80       	mov    0x801158d4,%eax
80106891:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106894:	83 ec 0c             	sub    $0xc,%esp
80106897:	68 a0 58 11 80       	push   $0x801158a0
8010689c:	e8 62 ea ff ff       	call   80105303 <release>
801068a1:	83 c4 10             	add    $0x10,%esp
  return xticks;
801068a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801068a7:	c9                   	leave  
801068a8:	c3                   	ret    

801068a9 <sys_nice>:

int
sys_nice(void)
{
801068a9:	55                   	push   %ebp
801068aa:	89 e5                	mov    %esp,%ebp
801068ac:	83 ec 18             	sub    $0x18,%esp
  int n;
  
  // argint gets the nth 32-bit system call argument.
  if(argint(0, &n) < 0)
801068af:	83 ec 08             	sub    $0x8,%esp
801068b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801068b5:	50                   	push   %eax
801068b6:	6a 00                	push   $0x0
801068b8:	e8 89 ef ff ff       	call   80105846 <argint>
801068bd:	83 c4 10             	add    $0x10,%esp
801068c0:	85 c0                	test   %eax,%eax
801068c2:	79 07                	jns    801068cb <sys_nice+0x22>
    return -1;
801068c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068c9:	eb 0f                	jmp    801068da <sys_nice+0x31>

  return nice(n); // This function should be implemented in proc.c
801068cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068ce:	83 ec 0c             	sub    $0xc,%esp
801068d1:	50                   	push   %eax
801068d2:	e8 bd e6 ff ff       	call   80104f94 <nice>
801068d7:	83 c4 10             	add    $0x10,%esp
}
801068da:	c9                   	leave  
801068db:	c3                   	ret    

801068dc <sys_getschedstate>:

int
sys_getschedstate(void)
{
801068dc:	55                   	push   %ebp
801068dd:	89 e5                	mov    %esp,%ebp
801068df:	83 ec 18             	sub    $0x18,%esp
    struct pschedinfo *psi;
    
    // Check if the argument is valid
    if(argptr(0, (char**)&psi, sizeof(*psi)) < 0)
801068e2:	83 ec 04             	sub    $0x4,%esp
801068e5:	68 00 05 00 00       	push   $0x500
801068ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
801068ed:	50                   	push   %eax
801068ee:	6a 00                	push   $0x0
801068f0:	e8 7e ef ff ff       	call   80105873 <argptr>
801068f5:	83 c4 10             	add    $0x10,%esp
801068f8:	85 c0                	test   %eax,%eax
801068fa:	79 07                	jns    80106903 <sys_getschedstate+0x27>
        return -1;
801068fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106901:	eb 0f                	jmp    80106912 <sys_getschedstate+0x36>

    return getschedstate(psi);
80106903:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106906:	83 ec 0c             	sub    $0xc,%esp
80106909:	50                   	push   %eax
8010690a:	e8 f3 e6 ff ff       	call   80105002 <getschedstate>
8010690f:	83 c4 10             	add    $0x10,%esp
}
80106912:	c9                   	leave  
80106913:	c3                   	ret    

80106914 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106914:	1e                   	push   %ds
  pushl %es
80106915:	06                   	push   %es
  pushl %fs
80106916:	0f a0                	push   %fs
  pushl %gs
80106918:	0f a8                	push   %gs
  pushal
8010691a:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
8010691b:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010691f:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106921:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106923:	54                   	push   %esp
  call trap
80106924:	e8 d7 01 00 00       	call   80106b00 <trap>
  addl $4, %esp
80106929:	83 c4 04             	add    $0x4,%esp

8010692c <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010692c:	61                   	popa   
  popl %gs
8010692d:	0f a9                	pop    %gs
  popl %fs
8010692f:	0f a1                	pop    %fs
  popl %es
80106931:	07                   	pop    %es
  popl %ds
80106932:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106933:	83 c4 08             	add    $0x8,%esp
  iret
80106936:	cf                   	iret   

80106937 <lidt>:
{
80106937:	55                   	push   %ebp
80106938:	89 e5                	mov    %esp,%ebp
8010693a:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010693d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106940:	83 e8 01             	sub    $0x1,%eax
80106943:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106947:	8b 45 08             	mov    0x8(%ebp),%eax
8010694a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010694e:	8b 45 08             	mov    0x8(%ebp),%eax
80106951:	c1 e8 10             	shr    $0x10,%eax
80106954:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106958:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010695b:	0f 01 18             	lidtl  (%eax)
}
8010695e:	90                   	nop
8010695f:	c9                   	leave  
80106960:	c3                   	ret    

80106961 <rcr2>:

static inline uint
rcr2(void)
{
80106961:	55                   	push   %ebp
80106962:	89 e5                	mov    %esp,%ebp
80106964:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106967:	0f 20 d0             	mov    %cr2,%eax
8010696a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
8010696d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106970:	c9                   	leave  
80106971:	c3                   	ret    

80106972 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106972:	55                   	push   %ebp
80106973:	89 e5                	mov    %esp,%ebp
80106975:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106978:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010697f:	e9 c3 00 00 00       	jmp    80106a47 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106984:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106987:	8b 04 85 80 b0 10 80 	mov    -0x7fef4f80(,%eax,4),%eax
8010698e:	89 c2                	mov    %eax,%edx
80106990:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106993:	66 89 14 c5 a0 50 11 	mov    %dx,-0x7feeaf60(,%eax,8)
8010699a:	80 
8010699b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010699e:	66 c7 04 c5 a2 50 11 	movw   $0x8,-0x7feeaf5e(,%eax,8)
801069a5:	80 08 00 
801069a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ab:	0f b6 14 c5 a4 50 11 	movzbl -0x7feeaf5c(,%eax,8),%edx
801069b2:	80 
801069b3:	83 e2 e0             	and    $0xffffffe0,%edx
801069b6:	88 14 c5 a4 50 11 80 	mov    %dl,-0x7feeaf5c(,%eax,8)
801069bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069c0:	0f b6 14 c5 a4 50 11 	movzbl -0x7feeaf5c(,%eax,8),%edx
801069c7:	80 
801069c8:	83 e2 1f             	and    $0x1f,%edx
801069cb:	88 14 c5 a4 50 11 80 	mov    %dl,-0x7feeaf5c(,%eax,8)
801069d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069d5:	0f b6 14 c5 a5 50 11 	movzbl -0x7feeaf5b(,%eax,8),%edx
801069dc:	80 
801069dd:	83 e2 f0             	and    $0xfffffff0,%edx
801069e0:	83 ca 0e             	or     $0xe,%edx
801069e3:	88 14 c5 a5 50 11 80 	mov    %dl,-0x7feeaf5b(,%eax,8)
801069ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ed:	0f b6 14 c5 a5 50 11 	movzbl -0x7feeaf5b(,%eax,8),%edx
801069f4:	80 
801069f5:	83 e2 ef             	and    $0xffffffef,%edx
801069f8:	88 14 c5 a5 50 11 80 	mov    %dl,-0x7feeaf5b(,%eax,8)
801069ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a02:	0f b6 14 c5 a5 50 11 	movzbl -0x7feeaf5b(,%eax,8),%edx
80106a09:	80 
80106a0a:	83 e2 9f             	and    $0xffffff9f,%edx
80106a0d:	88 14 c5 a5 50 11 80 	mov    %dl,-0x7feeaf5b(,%eax,8)
80106a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a17:	0f b6 14 c5 a5 50 11 	movzbl -0x7feeaf5b(,%eax,8),%edx
80106a1e:	80 
80106a1f:	83 ca 80             	or     $0xffffff80,%edx
80106a22:	88 14 c5 a5 50 11 80 	mov    %dl,-0x7feeaf5b(,%eax,8)
80106a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a2c:	8b 04 85 80 b0 10 80 	mov    -0x7fef4f80(,%eax,4),%eax
80106a33:	c1 e8 10             	shr    $0x10,%eax
80106a36:	89 c2                	mov    %eax,%edx
80106a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a3b:	66 89 14 c5 a6 50 11 	mov    %dx,-0x7feeaf5a(,%eax,8)
80106a42:	80 
  for(i = 0; i < 256; i++)
80106a43:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106a47:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106a4e:	0f 8e 30 ff ff ff    	jle    80106984 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106a54:	a1 80 b1 10 80       	mov    0x8010b180,%eax
80106a59:	66 a3 a0 52 11 80    	mov    %ax,0x801152a0
80106a5f:	66 c7 05 a2 52 11 80 	movw   $0x8,0x801152a2
80106a66:	08 00 
80106a68:	0f b6 05 a4 52 11 80 	movzbl 0x801152a4,%eax
80106a6f:	83 e0 e0             	and    $0xffffffe0,%eax
80106a72:	a2 a4 52 11 80       	mov    %al,0x801152a4
80106a77:	0f b6 05 a4 52 11 80 	movzbl 0x801152a4,%eax
80106a7e:	83 e0 1f             	and    $0x1f,%eax
80106a81:	a2 a4 52 11 80       	mov    %al,0x801152a4
80106a86:	0f b6 05 a5 52 11 80 	movzbl 0x801152a5,%eax
80106a8d:	83 c8 0f             	or     $0xf,%eax
80106a90:	a2 a5 52 11 80       	mov    %al,0x801152a5
80106a95:	0f b6 05 a5 52 11 80 	movzbl 0x801152a5,%eax
80106a9c:	83 e0 ef             	and    $0xffffffef,%eax
80106a9f:	a2 a5 52 11 80       	mov    %al,0x801152a5
80106aa4:	0f b6 05 a5 52 11 80 	movzbl 0x801152a5,%eax
80106aab:	83 c8 60             	or     $0x60,%eax
80106aae:	a2 a5 52 11 80       	mov    %al,0x801152a5
80106ab3:	0f b6 05 a5 52 11 80 	movzbl 0x801152a5,%eax
80106aba:	83 c8 80             	or     $0xffffff80,%eax
80106abd:	a2 a5 52 11 80       	mov    %al,0x801152a5
80106ac2:	a1 80 b1 10 80       	mov    0x8010b180,%eax
80106ac7:	c1 e8 10             	shr    $0x10,%eax
80106aca:	66 a3 a6 52 11 80    	mov    %ax,0x801152a6

  initlock(&tickslock, "time");
80106ad0:	83 ec 08             	sub    $0x8,%esp
80106ad3:	68 c4 8b 10 80       	push   $0x80108bc4
80106ad8:	68 a0 58 11 80       	push   $0x801158a0
80106add:	e8 91 e7 ff ff       	call   80105273 <initlock>
80106ae2:	83 c4 10             	add    $0x10,%esp
}
80106ae5:	90                   	nop
80106ae6:	c9                   	leave  
80106ae7:	c3                   	ret    

80106ae8 <idtinit>:

void
idtinit(void)
{
80106ae8:	55                   	push   %ebp
80106ae9:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106aeb:	68 00 08 00 00       	push   $0x800
80106af0:	68 a0 50 11 80       	push   $0x801150a0
80106af5:	e8 3d fe ff ff       	call   80106937 <lidt>
80106afa:	83 c4 08             	add    $0x8,%esp
}
80106afd:	90                   	nop
80106afe:	c9                   	leave  
80106aff:	c3                   	ret    

80106b00 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106b00:	55                   	push   %ebp
80106b01:	89 e5                	mov    %esp,%ebp
80106b03:	57                   	push   %edi
80106b04:	56                   	push   %esi
80106b05:	53                   	push   %ebx
80106b06:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80106b09:	8b 45 08             	mov    0x8(%ebp),%eax
80106b0c:	8b 40 30             	mov    0x30(%eax),%eax
80106b0f:	83 f8 40             	cmp    $0x40,%eax
80106b12:	75 3b                	jne    80106b4f <trap+0x4f>
    if(myproc()->killed)
80106b14:	e8 c1 d7 ff ff       	call   801042da <myproc>
80106b19:	8b 40 24             	mov    0x24(%eax),%eax
80106b1c:	85 c0                	test   %eax,%eax
80106b1e:	74 05                	je     80106b25 <trap+0x25>
      exit();
80106b20:	e8 e8 dc ff ff       	call   8010480d <exit>
    myproc()->tf = tf;
80106b25:	e8 b0 d7 ff ff       	call   801042da <myproc>
80106b2a:	8b 55 08             	mov    0x8(%ebp),%edx
80106b2d:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106b30:	e8 dd ed ff ff       	call   80105912 <syscall>
    if(myproc()->killed)
80106b35:	e8 a0 d7 ff ff       	call   801042da <myproc>
80106b3a:	8b 40 24             	mov    0x24(%eax),%eax
80106b3d:	85 c0                	test   %eax,%eax
80106b3f:	0f 84 06 02 00 00    	je     80106d4b <trap+0x24b>
      exit();
80106b45:	e8 c3 dc ff ff       	call   8010480d <exit>
    return;
80106b4a:	e9 fc 01 00 00       	jmp    80106d4b <trap+0x24b>
  }

  switch(tf->trapno){
80106b4f:	8b 45 08             	mov    0x8(%ebp),%eax
80106b52:	8b 40 30             	mov    0x30(%eax),%eax
80106b55:	83 e8 20             	sub    $0x20,%eax
80106b58:	83 f8 1f             	cmp    $0x1f,%eax
80106b5b:	0f 87 b5 00 00 00    	ja     80106c16 <trap+0x116>
80106b61:	8b 04 85 6c 8c 10 80 	mov    -0x7fef7394(,%eax,4),%eax
80106b68:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106b6a:	e8 d8 d6 ff ff       	call   80104247 <cpuid>
80106b6f:	85 c0                	test   %eax,%eax
80106b71:	75 3d                	jne    80106bb0 <trap+0xb0>
      acquire(&tickslock);
80106b73:	83 ec 0c             	sub    $0xc,%esp
80106b76:	68 a0 58 11 80       	push   $0x801158a0
80106b7b:	e8 15 e7 ff ff       	call   80105295 <acquire>
80106b80:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106b83:	a1 d4 58 11 80       	mov    0x801158d4,%eax
80106b88:	83 c0 01             	add    $0x1,%eax
80106b8b:	a3 d4 58 11 80       	mov    %eax,0x801158d4
      wakeup(&ticks);
80106b90:	83 ec 0c             	sub    $0xc,%esp
80106b93:	68 d4 58 11 80       	push   $0x801158d4
80106b98:	e8 3c e2 ff ff       	call   80104dd9 <wakeup>
80106b9d:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106ba0:	83 ec 0c             	sub    $0xc,%esp
80106ba3:	68 a0 58 11 80       	push   $0x801158a0
80106ba8:	e8 56 e7 ff ff       	call   80105303 <release>
80106bad:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106bb0:	e8 5d c4 ff ff       	call   80103012 <lapiceoi>
    break;
80106bb5:	e9 11 01 00 00       	jmp    80106ccb <trap+0x1cb>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106bba:	e8 c7 bc ff ff       	call   80102886 <ideintr>
    lapiceoi();
80106bbf:	e8 4e c4 ff ff       	call   80103012 <lapiceoi>
    break;
80106bc4:	e9 02 01 00 00       	jmp    80106ccb <trap+0x1cb>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106bc9:	e8 89 c2 ff ff       	call   80102e57 <kbdintr>
    lapiceoi();
80106bce:	e8 3f c4 ff ff       	call   80103012 <lapiceoi>
    break;
80106bd3:	e9 f3 00 00 00       	jmp    80106ccb <trap+0x1cb>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106bd8:	e8 44 03 00 00       	call   80106f21 <uartintr>
    lapiceoi();
80106bdd:	e8 30 c4 ff ff       	call   80103012 <lapiceoi>
    break;
80106be2:	e9 e4 00 00 00       	jmp    80106ccb <trap+0x1cb>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106be7:	8b 45 08             	mov    0x8(%ebp),%eax
80106bea:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106bed:	8b 45 08             	mov    0x8(%ebp),%eax
80106bf0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106bf4:	0f b7 d8             	movzwl %ax,%ebx
80106bf7:	e8 4b d6 ff ff       	call   80104247 <cpuid>
80106bfc:	56                   	push   %esi
80106bfd:	53                   	push   %ebx
80106bfe:	50                   	push   %eax
80106bff:	68 cc 8b 10 80       	push   $0x80108bcc
80106c04:	e8 f7 97 ff ff       	call   80100400 <cprintf>
80106c09:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106c0c:	e8 01 c4 ff ff       	call   80103012 <lapiceoi>
    break;
80106c11:	e9 b5 00 00 00       	jmp    80106ccb <trap+0x1cb>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106c16:	e8 bf d6 ff ff       	call   801042da <myproc>
80106c1b:	85 c0                	test   %eax,%eax
80106c1d:	74 11                	je     80106c30 <trap+0x130>
80106c1f:	8b 45 08             	mov    0x8(%ebp),%eax
80106c22:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106c26:	0f b7 c0             	movzwl %ax,%eax
80106c29:	83 e0 03             	and    $0x3,%eax
80106c2c:	85 c0                	test   %eax,%eax
80106c2e:	75 39                	jne    80106c69 <trap+0x169>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c30:	e8 2c fd ff ff       	call   80106961 <rcr2>
80106c35:	89 c3                	mov    %eax,%ebx
80106c37:	8b 45 08             	mov    0x8(%ebp),%eax
80106c3a:	8b 70 38             	mov    0x38(%eax),%esi
80106c3d:	e8 05 d6 ff ff       	call   80104247 <cpuid>
80106c42:	8b 55 08             	mov    0x8(%ebp),%edx
80106c45:	8b 52 30             	mov    0x30(%edx),%edx
80106c48:	83 ec 0c             	sub    $0xc,%esp
80106c4b:	53                   	push   %ebx
80106c4c:	56                   	push   %esi
80106c4d:	50                   	push   %eax
80106c4e:	52                   	push   %edx
80106c4f:	68 f0 8b 10 80       	push   $0x80108bf0
80106c54:	e8 a7 97 ff ff       	call   80100400 <cprintf>
80106c59:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106c5c:	83 ec 0c             	sub    $0xc,%esp
80106c5f:	68 22 8c 10 80       	push   $0x80108c22
80106c64:	e8 4c 99 ff ff       	call   801005b5 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c69:	e8 f3 fc ff ff       	call   80106961 <rcr2>
80106c6e:	89 c6                	mov    %eax,%esi
80106c70:	8b 45 08             	mov    0x8(%ebp),%eax
80106c73:	8b 40 38             	mov    0x38(%eax),%eax
80106c76:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106c79:	e8 c9 d5 ff ff       	call   80104247 <cpuid>
80106c7e:	89 c3                	mov    %eax,%ebx
80106c80:	8b 45 08             	mov    0x8(%ebp),%eax
80106c83:	8b 48 34             	mov    0x34(%eax),%ecx
80106c86:	89 4d e0             	mov    %ecx,-0x20(%ebp)
80106c89:	8b 45 08             	mov    0x8(%ebp),%eax
80106c8c:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106c8f:	e8 46 d6 ff ff       	call   801042da <myproc>
80106c94:	8d 50 6c             	lea    0x6c(%eax),%edx
80106c97:	89 55 dc             	mov    %edx,-0x24(%ebp)
80106c9a:	e8 3b d6 ff ff       	call   801042da <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c9f:	8b 40 10             	mov    0x10(%eax),%eax
80106ca2:	56                   	push   %esi
80106ca3:	ff 75 e4             	push   -0x1c(%ebp)
80106ca6:	53                   	push   %ebx
80106ca7:	ff 75 e0             	push   -0x20(%ebp)
80106caa:	57                   	push   %edi
80106cab:	ff 75 dc             	push   -0x24(%ebp)
80106cae:	50                   	push   %eax
80106caf:	68 28 8c 10 80       	push   $0x80108c28
80106cb4:	e8 47 97 ff ff       	call   80100400 <cprintf>
80106cb9:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106cbc:	e8 19 d6 ff ff       	call   801042da <myproc>
80106cc1:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106cc8:	eb 01                	jmp    80106ccb <trap+0x1cb>
    break;
80106cca:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106ccb:	e8 0a d6 ff ff       	call   801042da <myproc>
80106cd0:	85 c0                	test   %eax,%eax
80106cd2:	74 23                	je     80106cf7 <trap+0x1f7>
80106cd4:	e8 01 d6 ff ff       	call   801042da <myproc>
80106cd9:	8b 40 24             	mov    0x24(%eax),%eax
80106cdc:	85 c0                	test   %eax,%eax
80106cde:	74 17                	je     80106cf7 <trap+0x1f7>
80106ce0:	8b 45 08             	mov    0x8(%ebp),%eax
80106ce3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106ce7:	0f b7 c0             	movzwl %ax,%eax
80106cea:	83 e0 03             	and    $0x3,%eax
80106ced:	83 f8 03             	cmp    $0x3,%eax
80106cf0:	75 05                	jne    80106cf7 <trap+0x1f7>
    exit();
80106cf2:	e8 16 db ff ff       	call   8010480d <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106cf7:	e8 de d5 ff ff       	call   801042da <myproc>
80106cfc:	85 c0                	test   %eax,%eax
80106cfe:	74 1d                	je     80106d1d <trap+0x21d>
80106d00:	e8 d5 d5 ff ff       	call   801042da <myproc>
80106d05:	8b 40 0c             	mov    0xc(%eax),%eax
80106d08:	83 f8 04             	cmp    $0x4,%eax
80106d0b:	75 10                	jne    80106d1d <trap+0x21d>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106d0d:	8b 45 08             	mov    0x8(%ebp),%eax
80106d10:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106d13:	83 f8 20             	cmp    $0x20,%eax
80106d16:	75 05                	jne    80106d1d <trap+0x21d>
    yield();
80106d18:	e8 3e df ff ff       	call   80104c5b <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106d1d:	e8 b8 d5 ff ff       	call   801042da <myproc>
80106d22:	85 c0                	test   %eax,%eax
80106d24:	74 26                	je     80106d4c <trap+0x24c>
80106d26:	e8 af d5 ff ff       	call   801042da <myproc>
80106d2b:	8b 40 24             	mov    0x24(%eax),%eax
80106d2e:	85 c0                	test   %eax,%eax
80106d30:	74 1a                	je     80106d4c <trap+0x24c>
80106d32:	8b 45 08             	mov    0x8(%ebp),%eax
80106d35:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106d39:	0f b7 c0             	movzwl %ax,%eax
80106d3c:	83 e0 03             	and    $0x3,%eax
80106d3f:	83 f8 03             	cmp    $0x3,%eax
80106d42:	75 08                	jne    80106d4c <trap+0x24c>
    exit();
80106d44:	e8 c4 da ff ff       	call   8010480d <exit>
80106d49:	eb 01                	jmp    80106d4c <trap+0x24c>
    return;
80106d4b:	90                   	nop
}
80106d4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106d4f:	5b                   	pop    %ebx
80106d50:	5e                   	pop    %esi
80106d51:	5f                   	pop    %edi
80106d52:	5d                   	pop    %ebp
80106d53:	c3                   	ret    

80106d54 <inb>:
{
80106d54:	55                   	push   %ebp
80106d55:	89 e5                	mov    %esp,%ebp
80106d57:	83 ec 14             	sub    $0x14,%esp
80106d5a:	8b 45 08             	mov    0x8(%ebp),%eax
80106d5d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106d61:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106d65:	89 c2                	mov    %eax,%edx
80106d67:	ec                   	in     (%dx),%al
80106d68:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106d6b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106d6f:	c9                   	leave  
80106d70:	c3                   	ret    

80106d71 <outb>:
{
80106d71:	55                   	push   %ebp
80106d72:	89 e5                	mov    %esp,%ebp
80106d74:	83 ec 08             	sub    $0x8,%esp
80106d77:	8b 45 08             	mov    0x8(%ebp),%eax
80106d7a:	8b 55 0c             	mov    0xc(%ebp),%edx
80106d7d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106d81:	89 d0                	mov    %edx,%eax
80106d83:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106d86:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106d8a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106d8e:	ee                   	out    %al,(%dx)
}
80106d8f:	90                   	nop
80106d90:	c9                   	leave  
80106d91:	c3                   	ret    

80106d92 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106d92:	55                   	push   %ebp
80106d93:	89 e5                	mov    %esp,%ebp
80106d95:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106d98:	6a 00                	push   $0x0
80106d9a:	68 fa 03 00 00       	push   $0x3fa
80106d9f:	e8 cd ff ff ff       	call   80106d71 <outb>
80106da4:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106da7:	68 80 00 00 00       	push   $0x80
80106dac:	68 fb 03 00 00       	push   $0x3fb
80106db1:	e8 bb ff ff ff       	call   80106d71 <outb>
80106db6:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106db9:	6a 0c                	push   $0xc
80106dbb:	68 f8 03 00 00       	push   $0x3f8
80106dc0:	e8 ac ff ff ff       	call   80106d71 <outb>
80106dc5:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106dc8:	6a 00                	push   $0x0
80106dca:	68 f9 03 00 00       	push   $0x3f9
80106dcf:	e8 9d ff ff ff       	call   80106d71 <outb>
80106dd4:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106dd7:	6a 03                	push   $0x3
80106dd9:	68 fb 03 00 00       	push   $0x3fb
80106dde:	e8 8e ff ff ff       	call   80106d71 <outb>
80106de3:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106de6:	6a 00                	push   $0x0
80106de8:	68 fc 03 00 00       	push   $0x3fc
80106ded:	e8 7f ff ff ff       	call   80106d71 <outb>
80106df2:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106df5:	6a 01                	push   $0x1
80106df7:	68 f9 03 00 00       	push   $0x3f9
80106dfc:	e8 70 ff ff ff       	call   80106d71 <outb>
80106e01:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106e04:	68 fd 03 00 00       	push   $0x3fd
80106e09:	e8 46 ff ff ff       	call   80106d54 <inb>
80106e0e:	83 c4 04             	add    $0x4,%esp
80106e11:	3c ff                	cmp    $0xff,%al
80106e13:	74 61                	je     80106e76 <uartinit+0xe4>
    return;
  uart = 1;
80106e15:	c7 05 d8 58 11 80 01 	movl   $0x1,0x801158d8
80106e1c:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106e1f:	68 fa 03 00 00       	push   $0x3fa
80106e24:	e8 2b ff ff ff       	call   80106d54 <inb>
80106e29:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106e2c:	68 f8 03 00 00       	push   $0x3f8
80106e31:	e8 1e ff ff ff       	call   80106d54 <inb>
80106e36:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106e39:	83 ec 08             	sub    $0x8,%esp
80106e3c:	6a 00                	push   $0x0
80106e3e:	6a 04                	push   $0x4
80106e40:	e8 df bc ff ff       	call   80102b24 <ioapicenable>
80106e45:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106e48:	c7 45 f4 ec 8c 10 80 	movl   $0x80108cec,-0xc(%ebp)
80106e4f:	eb 19                	jmp    80106e6a <uartinit+0xd8>
    uartputc(*p);
80106e51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e54:	0f b6 00             	movzbl (%eax),%eax
80106e57:	0f be c0             	movsbl %al,%eax
80106e5a:	83 ec 0c             	sub    $0xc,%esp
80106e5d:	50                   	push   %eax
80106e5e:	e8 16 00 00 00       	call   80106e79 <uartputc>
80106e63:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106e66:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e6d:	0f b6 00             	movzbl (%eax),%eax
80106e70:	84 c0                	test   %al,%al
80106e72:	75 dd                	jne    80106e51 <uartinit+0xbf>
80106e74:	eb 01                	jmp    80106e77 <uartinit+0xe5>
    return;
80106e76:	90                   	nop
}
80106e77:	c9                   	leave  
80106e78:	c3                   	ret    

80106e79 <uartputc>:

void
uartputc(int c)
{
80106e79:	55                   	push   %ebp
80106e7a:	89 e5                	mov    %esp,%ebp
80106e7c:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106e7f:	a1 d8 58 11 80       	mov    0x801158d8,%eax
80106e84:	85 c0                	test   %eax,%eax
80106e86:	74 53                	je     80106edb <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106e88:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106e8f:	eb 11                	jmp    80106ea2 <uartputc+0x29>
    microdelay(10);
80106e91:	83 ec 0c             	sub    $0xc,%esp
80106e94:	6a 0a                	push   $0xa
80106e96:	e8 92 c1 ff ff       	call   8010302d <microdelay>
80106e9b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106e9e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106ea2:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106ea6:	7f 1a                	jg     80106ec2 <uartputc+0x49>
80106ea8:	83 ec 0c             	sub    $0xc,%esp
80106eab:	68 fd 03 00 00       	push   $0x3fd
80106eb0:	e8 9f fe ff ff       	call   80106d54 <inb>
80106eb5:	83 c4 10             	add    $0x10,%esp
80106eb8:	0f b6 c0             	movzbl %al,%eax
80106ebb:	83 e0 20             	and    $0x20,%eax
80106ebe:	85 c0                	test   %eax,%eax
80106ec0:	74 cf                	je     80106e91 <uartputc+0x18>
  outb(COM1+0, c);
80106ec2:	8b 45 08             	mov    0x8(%ebp),%eax
80106ec5:	0f b6 c0             	movzbl %al,%eax
80106ec8:	83 ec 08             	sub    $0x8,%esp
80106ecb:	50                   	push   %eax
80106ecc:	68 f8 03 00 00       	push   $0x3f8
80106ed1:	e8 9b fe ff ff       	call   80106d71 <outb>
80106ed6:	83 c4 10             	add    $0x10,%esp
80106ed9:	eb 01                	jmp    80106edc <uartputc+0x63>
    return;
80106edb:	90                   	nop
}
80106edc:	c9                   	leave  
80106edd:	c3                   	ret    

80106ede <uartgetc>:

static int
uartgetc(void)
{
80106ede:	55                   	push   %ebp
80106edf:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106ee1:	a1 d8 58 11 80       	mov    0x801158d8,%eax
80106ee6:	85 c0                	test   %eax,%eax
80106ee8:	75 07                	jne    80106ef1 <uartgetc+0x13>
    return -1;
80106eea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106eef:	eb 2e                	jmp    80106f1f <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106ef1:	68 fd 03 00 00       	push   $0x3fd
80106ef6:	e8 59 fe ff ff       	call   80106d54 <inb>
80106efb:	83 c4 04             	add    $0x4,%esp
80106efe:	0f b6 c0             	movzbl %al,%eax
80106f01:	83 e0 01             	and    $0x1,%eax
80106f04:	85 c0                	test   %eax,%eax
80106f06:	75 07                	jne    80106f0f <uartgetc+0x31>
    return -1;
80106f08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f0d:	eb 10                	jmp    80106f1f <uartgetc+0x41>
  return inb(COM1+0);
80106f0f:	68 f8 03 00 00       	push   $0x3f8
80106f14:	e8 3b fe ff ff       	call   80106d54 <inb>
80106f19:	83 c4 04             	add    $0x4,%esp
80106f1c:	0f b6 c0             	movzbl %al,%eax
}
80106f1f:	c9                   	leave  
80106f20:	c3                   	ret    

80106f21 <uartintr>:

void
uartintr(void)
{
80106f21:	55                   	push   %ebp
80106f22:	89 e5                	mov    %esp,%ebp
80106f24:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106f27:	83 ec 0c             	sub    $0xc,%esp
80106f2a:	68 de 6e 10 80       	push   $0x80106ede
80106f2f:	e8 1b 99 ff ff       	call   8010084f <consoleintr>
80106f34:	83 c4 10             	add    $0x10,%esp
}
80106f37:	90                   	nop
80106f38:	c9                   	leave  
80106f39:	c3                   	ret    

80106f3a <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106f3a:	6a 00                	push   $0x0
  pushl $0
80106f3c:	6a 00                	push   $0x0
  jmp alltraps
80106f3e:	e9 d1 f9 ff ff       	jmp    80106914 <alltraps>

80106f43 <vector1>:
.globl vector1
vector1:
  pushl $0
80106f43:	6a 00                	push   $0x0
  pushl $1
80106f45:	6a 01                	push   $0x1
  jmp alltraps
80106f47:	e9 c8 f9 ff ff       	jmp    80106914 <alltraps>

80106f4c <vector2>:
.globl vector2
vector2:
  pushl $0
80106f4c:	6a 00                	push   $0x0
  pushl $2
80106f4e:	6a 02                	push   $0x2
  jmp alltraps
80106f50:	e9 bf f9 ff ff       	jmp    80106914 <alltraps>

80106f55 <vector3>:
.globl vector3
vector3:
  pushl $0
80106f55:	6a 00                	push   $0x0
  pushl $3
80106f57:	6a 03                	push   $0x3
  jmp alltraps
80106f59:	e9 b6 f9 ff ff       	jmp    80106914 <alltraps>

80106f5e <vector4>:
.globl vector4
vector4:
  pushl $0
80106f5e:	6a 00                	push   $0x0
  pushl $4
80106f60:	6a 04                	push   $0x4
  jmp alltraps
80106f62:	e9 ad f9 ff ff       	jmp    80106914 <alltraps>

80106f67 <vector5>:
.globl vector5
vector5:
  pushl $0
80106f67:	6a 00                	push   $0x0
  pushl $5
80106f69:	6a 05                	push   $0x5
  jmp alltraps
80106f6b:	e9 a4 f9 ff ff       	jmp    80106914 <alltraps>

80106f70 <vector6>:
.globl vector6
vector6:
  pushl $0
80106f70:	6a 00                	push   $0x0
  pushl $6
80106f72:	6a 06                	push   $0x6
  jmp alltraps
80106f74:	e9 9b f9 ff ff       	jmp    80106914 <alltraps>

80106f79 <vector7>:
.globl vector7
vector7:
  pushl $0
80106f79:	6a 00                	push   $0x0
  pushl $7
80106f7b:	6a 07                	push   $0x7
  jmp alltraps
80106f7d:	e9 92 f9 ff ff       	jmp    80106914 <alltraps>

80106f82 <vector8>:
.globl vector8
vector8:
  pushl $8
80106f82:	6a 08                	push   $0x8
  jmp alltraps
80106f84:	e9 8b f9 ff ff       	jmp    80106914 <alltraps>

80106f89 <vector9>:
.globl vector9
vector9:
  pushl $0
80106f89:	6a 00                	push   $0x0
  pushl $9
80106f8b:	6a 09                	push   $0x9
  jmp alltraps
80106f8d:	e9 82 f9 ff ff       	jmp    80106914 <alltraps>

80106f92 <vector10>:
.globl vector10
vector10:
  pushl $10
80106f92:	6a 0a                	push   $0xa
  jmp alltraps
80106f94:	e9 7b f9 ff ff       	jmp    80106914 <alltraps>

80106f99 <vector11>:
.globl vector11
vector11:
  pushl $11
80106f99:	6a 0b                	push   $0xb
  jmp alltraps
80106f9b:	e9 74 f9 ff ff       	jmp    80106914 <alltraps>

80106fa0 <vector12>:
.globl vector12
vector12:
  pushl $12
80106fa0:	6a 0c                	push   $0xc
  jmp alltraps
80106fa2:	e9 6d f9 ff ff       	jmp    80106914 <alltraps>

80106fa7 <vector13>:
.globl vector13
vector13:
  pushl $13
80106fa7:	6a 0d                	push   $0xd
  jmp alltraps
80106fa9:	e9 66 f9 ff ff       	jmp    80106914 <alltraps>

80106fae <vector14>:
.globl vector14
vector14:
  pushl $14
80106fae:	6a 0e                	push   $0xe
  jmp alltraps
80106fb0:	e9 5f f9 ff ff       	jmp    80106914 <alltraps>

80106fb5 <vector15>:
.globl vector15
vector15:
  pushl $0
80106fb5:	6a 00                	push   $0x0
  pushl $15
80106fb7:	6a 0f                	push   $0xf
  jmp alltraps
80106fb9:	e9 56 f9 ff ff       	jmp    80106914 <alltraps>

80106fbe <vector16>:
.globl vector16
vector16:
  pushl $0
80106fbe:	6a 00                	push   $0x0
  pushl $16
80106fc0:	6a 10                	push   $0x10
  jmp alltraps
80106fc2:	e9 4d f9 ff ff       	jmp    80106914 <alltraps>

80106fc7 <vector17>:
.globl vector17
vector17:
  pushl $17
80106fc7:	6a 11                	push   $0x11
  jmp alltraps
80106fc9:	e9 46 f9 ff ff       	jmp    80106914 <alltraps>

80106fce <vector18>:
.globl vector18
vector18:
  pushl $0
80106fce:	6a 00                	push   $0x0
  pushl $18
80106fd0:	6a 12                	push   $0x12
  jmp alltraps
80106fd2:	e9 3d f9 ff ff       	jmp    80106914 <alltraps>

80106fd7 <vector19>:
.globl vector19
vector19:
  pushl $0
80106fd7:	6a 00                	push   $0x0
  pushl $19
80106fd9:	6a 13                	push   $0x13
  jmp alltraps
80106fdb:	e9 34 f9 ff ff       	jmp    80106914 <alltraps>

80106fe0 <vector20>:
.globl vector20
vector20:
  pushl $0
80106fe0:	6a 00                	push   $0x0
  pushl $20
80106fe2:	6a 14                	push   $0x14
  jmp alltraps
80106fe4:	e9 2b f9 ff ff       	jmp    80106914 <alltraps>

80106fe9 <vector21>:
.globl vector21
vector21:
  pushl $0
80106fe9:	6a 00                	push   $0x0
  pushl $21
80106feb:	6a 15                	push   $0x15
  jmp alltraps
80106fed:	e9 22 f9 ff ff       	jmp    80106914 <alltraps>

80106ff2 <vector22>:
.globl vector22
vector22:
  pushl $0
80106ff2:	6a 00                	push   $0x0
  pushl $22
80106ff4:	6a 16                	push   $0x16
  jmp alltraps
80106ff6:	e9 19 f9 ff ff       	jmp    80106914 <alltraps>

80106ffb <vector23>:
.globl vector23
vector23:
  pushl $0
80106ffb:	6a 00                	push   $0x0
  pushl $23
80106ffd:	6a 17                	push   $0x17
  jmp alltraps
80106fff:	e9 10 f9 ff ff       	jmp    80106914 <alltraps>

80107004 <vector24>:
.globl vector24
vector24:
  pushl $0
80107004:	6a 00                	push   $0x0
  pushl $24
80107006:	6a 18                	push   $0x18
  jmp alltraps
80107008:	e9 07 f9 ff ff       	jmp    80106914 <alltraps>

8010700d <vector25>:
.globl vector25
vector25:
  pushl $0
8010700d:	6a 00                	push   $0x0
  pushl $25
8010700f:	6a 19                	push   $0x19
  jmp alltraps
80107011:	e9 fe f8 ff ff       	jmp    80106914 <alltraps>

80107016 <vector26>:
.globl vector26
vector26:
  pushl $0
80107016:	6a 00                	push   $0x0
  pushl $26
80107018:	6a 1a                	push   $0x1a
  jmp alltraps
8010701a:	e9 f5 f8 ff ff       	jmp    80106914 <alltraps>

8010701f <vector27>:
.globl vector27
vector27:
  pushl $0
8010701f:	6a 00                	push   $0x0
  pushl $27
80107021:	6a 1b                	push   $0x1b
  jmp alltraps
80107023:	e9 ec f8 ff ff       	jmp    80106914 <alltraps>

80107028 <vector28>:
.globl vector28
vector28:
  pushl $0
80107028:	6a 00                	push   $0x0
  pushl $28
8010702a:	6a 1c                	push   $0x1c
  jmp alltraps
8010702c:	e9 e3 f8 ff ff       	jmp    80106914 <alltraps>

80107031 <vector29>:
.globl vector29
vector29:
  pushl $0
80107031:	6a 00                	push   $0x0
  pushl $29
80107033:	6a 1d                	push   $0x1d
  jmp alltraps
80107035:	e9 da f8 ff ff       	jmp    80106914 <alltraps>

8010703a <vector30>:
.globl vector30
vector30:
  pushl $0
8010703a:	6a 00                	push   $0x0
  pushl $30
8010703c:	6a 1e                	push   $0x1e
  jmp alltraps
8010703e:	e9 d1 f8 ff ff       	jmp    80106914 <alltraps>

80107043 <vector31>:
.globl vector31
vector31:
  pushl $0
80107043:	6a 00                	push   $0x0
  pushl $31
80107045:	6a 1f                	push   $0x1f
  jmp alltraps
80107047:	e9 c8 f8 ff ff       	jmp    80106914 <alltraps>

8010704c <vector32>:
.globl vector32
vector32:
  pushl $0
8010704c:	6a 00                	push   $0x0
  pushl $32
8010704e:	6a 20                	push   $0x20
  jmp alltraps
80107050:	e9 bf f8 ff ff       	jmp    80106914 <alltraps>

80107055 <vector33>:
.globl vector33
vector33:
  pushl $0
80107055:	6a 00                	push   $0x0
  pushl $33
80107057:	6a 21                	push   $0x21
  jmp alltraps
80107059:	e9 b6 f8 ff ff       	jmp    80106914 <alltraps>

8010705e <vector34>:
.globl vector34
vector34:
  pushl $0
8010705e:	6a 00                	push   $0x0
  pushl $34
80107060:	6a 22                	push   $0x22
  jmp alltraps
80107062:	e9 ad f8 ff ff       	jmp    80106914 <alltraps>

80107067 <vector35>:
.globl vector35
vector35:
  pushl $0
80107067:	6a 00                	push   $0x0
  pushl $35
80107069:	6a 23                	push   $0x23
  jmp alltraps
8010706b:	e9 a4 f8 ff ff       	jmp    80106914 <alltraps>

80107070 <vector36>:
.globl vector36
vector36:
  pushl $0
80107070:	6a 00                	push   $0x0
  pushl $36
80107072:	6a 24                	push   $0x24
  jmp alltraps
80107074:	e9 9b f8 ff ff       	jmp    80106914 <alltraps>

80107079 <vector37>:
.globl vector37
vector37:
  pushl $0
80107079:	6a 00                	push   $0x0
  pushl $37
8010707b:	6a 25                	push   $0x25
  jmp alltraps
8010707d:	e9 92 f8 ff ff       	jmp    80106914 <alltraps>

80107082 <vector38>:
.globl vector38
vector38:
  pushl $0
80107082:	6a 00                	push   $0x0
  pushl $38
80107084:	6a 26                	push   $0x26
  jmp alltraps
80107086:	e9 89 f8 ff ff       	jmp    80106914 <alltraps>

8010708b <vector39>:
.globl vector39
vector39:
  pushl $0
8010708b:	6a 00                	push   $0x0
  pushl $39
8010708d:	6a 27                	push   $0x27
  jmp alltraps
8010708f:	e9 80 f8 ff ff       	jmp    80106914 <alltraps>

80107094 <vector40>:
.globl vector40
vector40:
  pushl $0
80107094:	6a 00                	push   $0x0
  pushl $40
80107096:	6a 28                	push   $0x28
  jmp alltraps
80107098:	e9 77 f8 ff ff       	jmp    80106914 <alltraps>

8010709d <vector41>:
.globl vector41
vector41:
  pushl $0
8010709d:	6a 00                	push   $0x0
  pushl $41
8010709f:	6a 29                	push   $0x29
  jmp alltraps
801070a1:	e9 6e f8 ff ff       	jmp    80106914 <alltraps>

801070a6 <vector42>:
.globl vector42
vector42:
  pushl $0
801070a6:	6a 00                	push   $0x0
  pushl $42
801070a8:	6a 2a                	push   $0x2a
  jmp alltraps
801070aa:	e9 65 f8 ff ff       	jmp    80106914 <alltraps>

801070af <vector43>:
.globl vector43
vector43:
  pushl $0
801070af:	6a 00                	push   $0x0
  pushl $43
801070b1:	6a 2b                	push   $0x2b
  jmp alltraps
801070b3:	e9 5c f8 ff ff       	jmp    80106914 <alltraps>

801070b8 <vector44>:
.globl vector44
vector44:
  pushl $0
801070b8:	6a 00                	push   $0x0
  pushl $44
801070ba:	6a 2c                	push   $0x2c
  jmp alltraps
801070bc:	e9 53 f8 ff ff       	jmp    80106914 <alltraps>

801070c1 <vector45>:
.globl vector45
vector45:
  pushl $0
801070c1:	6a 00                	push   $0x0
  pushl $45
801070c3:	6a 2d                	push   $0x2d
  jmp alltraps
801070c5:	e9 4a f8 ff ff       	jmp    80106914 <alltraps>

801070ca <vector46>:
.globl vector46
vector46:
  pushl $0
801070ca:	6a 00                	push   $0x0
  pushl $46
801070cc:	6a 2e                	push   $0x2e
  jmp alltraps
801070ce:	e9 41 f8 ff ff       	jmp    80106914 <alltraps>

801070d3 <vector47>:
.globl vector47
vector47:
  pushl $0
801070d3:	6a 00                	push   $0x0
  pushl $47
801070d5:	6a 2f                	push   $0x2f
  jmp alltraps
801070d7:	e9 38 f8 ff ff       	jmp    80106914 <alltraps>

801070dc <vector48>:
.globl vector48
vector48:
  pushl $0
801070dc:	6a 00                	push   $0x0
  pushl $48
801070de:	6a 30                	push   $0x30
  jmp alltraps
801070e0:	e9 2f f8 ff ff       	jmp    80106914 <alltraps>

801070e5 <vector49>:
.globl vector49
vector49:
  pushl $0
801070e5:	6a 00                	push   $0x0
  pushl $49
801070e7:	6a 31                	push   $0x31
  jmp alltraps
801070e9:	e9 26 f8 ff ff       	jmp    80106914 <alltraps>

801070ee <vector50>:
.globl vector50
vector50:
  pushl $0
801070ee:	6a 00                	push   $0x0
  pushl $50
801070f0:	6a 32                	push   $0x32
  jmp alltraps
801070f2:	e9 1d f8 ff ff       	jmp    80106914 <alltraps>

801070f7 <vector51>:
.globl vector51
vector51:
  pushl $0
801070f7:	6a 00                	push   $0x0
  pushl $51
801070f9:	6a 33                	push   $0x33
  jmp alltraps
801070fb:	e9 14 f8 ff ff       	jmp    80106914 <alltraps>

80107100 <vector52>:
.globl vector52
vector52:
  pushl $0
80107100:	6a 00                	push   $0x0
  pushl $52
80107102:	6a 34                	push   $0x34
  jmp alltraps
80107104:	e9 0b f8 ff ff       	jmp    80106914 <alltraps>

80107109 <vector53>:
.globl vector53
vector53:
  pushl $0
80107109:	6a 00                	push   $0x0
  pushl $53
8010710b:	6a 35                	push   $0x35
  jmp alltraps
8010710d:	e9 02 f8 ff ff       	jmp    80106914 <alltraps>

80107112 <vector54>:
.globl vector54
vector54:
  pushl $0
80107112:	6a 00                	push   $0x0
  pushl $54
80107114:	6a 36                	push   $0x36
  jmp alltraps
80107116:	e9 f9 f7 ff ff       	jmp    80106914 <alltraps>

8010711b <vector55>:
.globl vector55
vector55:
  pushl $0
8010711b:	6a 00                	push   $0x0
  pushl $55
8010711d:	6a 37                	push   $0x37
  jmp alltraps
8010711f:	e9 f0 f7 ff ff       	jmp    80106914 <alltraps>

80107124 <vector56>:
.globl vector56
vector56:
  pushl $0
80107124:	6a 00                	push   $0x0
  pushl $56
80107126:	6a 38                	push   $0x38
  jmp alltraps
80107128:	e9 e7 f7 ff ff       	jmp    80106914 <alltraps>

8010712d <vector57>:
.globl vector57
vector57:
  pushl $0
8010712d:	6a 00                	push   $0x0
  pushl $57
8010712f:	6a 39                	push   $0x39
  jmp alltraps
80107131:	e9 de f7 ff ff       	jmp    80106914 <alltraps>

80107136 <vector58>:
.globl vector58
vector58:
  pushl $0
80107136:	6a 00                	push   $0x0
  pushl $58
80107138:	6a 3a                	push   $0x3a
  jmp alltraps
8010713a:	e9 d5 f7 ff ff       	jmp    80106914 <alltraps>

8010713f <vector59>:
.globl vector59
vector59:
  pushl $0
8010713f:	6a 00                	push   $0x0
  pushl $59
80107141:	6a 3b                	push   $0x3b
  jmp alltraps
80107143:	e9 cc f7 ff ff       	jmp    80106914 <alltraps>

80107148 <vector60>:
.globl vector60
vector60:
  pushl $0
80107148:	6a 00                	push   $0x0
  pushl $60
8010714a:	6a 3c                	push   $0x3c
  jmp alltraps
8010714c:	e9 c3 f7 ff ff       	jmp    80106914 <alltraps>

80107151 <vector61>:
.globl vector61
vector61:
  pushl $0
80107151:	6a 00                	push   $0x0
  pushl $61
80107153:	6a 3d                	push   $0x3d
  jmp alltraps
80107155:	e9 ba f7 ff ff       	jmp    80106914 <alltraps>

8010715a <vector62>:
.globl vector62
vector62:
  pushl $0
8010715a:	6a 00                	push   $0x0
  pushl $62
8010715c:	6a 3e                	push   $0x3e
  jmp alltraps
8010715e:	e9 b1 f7 ff ff       	jmp    80106914 <alltraps>

80107163 <vector63>:
.globl vector63
vector63:
  pushl $0
80107163:	6a 00                	push   $0x0
  pushl $63
80107165:	6a 3f                	push   $0x3f
  jmp alltraps
80107167:	e9 a8 f7 ff ff       	jmp    80106914 <alltraps>

8010716c <vector64>:
.globl vector64
vector64:
  pushl $0
8010716c:	6a 00                	push   $0x0
  pushl $64
8010716e:	6a 40                	push   $0x40
  jmp alltraps
80107170:	e9 9f f7 ff ff       	jmp    80106914 <alltraps>

80107175 <vector65>:
.globl vector65
vector65:
  pushl $0
80107175:	6a 00                	push   $0x0
  pushl $65
80107177:	6a 41                	push   $0x41
  jmp alltraps
80107179:	e9 96 f7 ff ff       	jmp    80106914 <alltraps>

8010717e <vector66>:
.globl vector66
vector66:
  pushl $0
8010717e:	6a 00                	push   $0x0
  pushl $66
80107180:	6a 42                	push   $0x42
  jmp alltraps
80107182:	e9 8d f7 ff ff       	jmp    80106914 <alltraps>

80107187 <vector67>:
.globl vector67
vector67:
  pushl $0
80107187:	6a 00                	push   $0x0
  pushl $67
80107189:	6a 43                	push   $0x43
  jmp alltraps
8010718b:	e9 84 f7 ff ff       	jmp    80106914 <alltraps>

80107190 <vector68>:
.globl vector68
vector68:
  pushl $0
80107190:	6a 00                	push   $0x0
  pushl $68
80107192:	6a 44                	push   $0x44
  jmp alltraps
80107194:	e9 7b f7 ff ff       	jmp    80106914 <alltraps>

80107199 <vector69>:
.globl vector69
vector69:
  pushl $0
80107199:	6a 00                	push   $0x0
  pushl $69
8010719b:	6a 45                	push   $0x45
  jmp alltraps
8010719d:	e9 72 f7 ff ff       	jmp    80106914 <alltraps>

801071a2 <vector70>:
.globl vector70
vector70:
  pushl $0
801071a2:	6a 00                	push   $0x0
  pushl $70
801071a4:	6a 46                	push   $0x46
  jmp alltraps
801071a6:	e9 69 f7 ff ff       	jmp    80106914 <alltraps>

801071ab <vector71>:
.globl vector71
vector71:
  pushl $0
801071ab:	6a 00                	push   $0x0
  pushl $71
801071ad:	6a 47                	push   $0x47
  jmp alltraps
801071af:	e9 60 f7 ff ff       	jmp    80106914 <alltraps>

801071b4 <vector72>:
.globl vector72
vector72:
  pushl $0
801071b4:	6a 00                	push   $0x0
  pushl $72
801071b6:	6a 48                	push   $0x48
  jmp alltraps
801071b8:	e9 57 f7 ff ff       	jmp    80106914 <alltraps>

801071bd <vector73>:
.globl vector73
vector73:
  pushl $0
801071bd:	6a 00                	push   $0x0
  pushl $73
801071bf:	6a 49                	push   $0x49
  jmp alltraps
801071c1:	e9 4e f7 ff ff       	jmp    80106914 <alltraps>

801071c6 <vector74>:
.globl vector74
vector74:
  pushl $0
801071c6:	6a 00                	push   $0x0
  pushl $74
801071c8:	6a 4a                	push   $0x4a
  jmp alltraps
801071ca:	e9 45 f7 ff ff       	jmp    80106914 <alltraps>

801071cf <vector75>:
.globl vector75
vector75:
  pushl $0
801071cf:	6a 00                	push   $0x0
  pushl $75
801071d1:	6a 4b                	push   $0x4b
  jmp alltraps
801071d3:	e9 3c f7 ff ff       	jmp    80106914 <alltraps>

801071d8 <vector76>:
.globl vector76
vector76:
  pushl $0
801071d8:	6a 00                	push   $0x0
  pushl $76
801071da:	6a 4c                	push   $0x4c
  jmp alltraps
801071dc:	e9 33 f7 ff ff       	jmp    80106914 <alltraps>

801071e1 <vector77>:
.globl vector77
vector77:
  pushl $0
801071e1:	6a 00                	push   $0x0
  pushl $77
801071e3:	6a 4d                	push   $0x4d
  jmp alltraps
801071e5:	e9 2a f7 ff ff       	jmp    80106914 <alltraps>

801071ea <vector78>:
.globl vector78
vector78:
  pushl $0
801071ea:	6a 00                	push   $0x0
  pushl $78
801071ec:	6a 4e                	push   $0x4e
  jmp alltraps
801071ee:	e9 21 f7 ff ff       	jmp    80106914 <alltraps>

801071f3 <vector79>:
.globl vector79
vector79:
  pushl $0
801071f3:	6a 00                	push   $0x0
  pushl $79
801071f5:	6a 4f                	push   $0x4f
  jmp alltraps
801071f7:	e9 18 f7 ff ff       	jmp    80106914 <alltraps>

801071fc <vector80>:
.globl vector80
vector80:
  pushl $0
801071fc:	6a 00                	push   $0x0
  pushl $80
801071fe:	6a 50                	push   $0x50
  jmp alltraps
80107200:	e9 0f f7 ff ff       	jmp    80106914 <alltraps>

80107205 <vector81>:
.globl vector81
vector81:
  pushl $0
80107205:	6a 00                	push   $0x0
  pushl $81
80107207:	6a 51                	push   $0x51
  jmp alltraps
80107209:	e9 06 f7 ff ff       	jmp    80106914 <alltraps>

8010720e <vector82>:
.globl vector82
vector82:
  pushl $0
8010720e:	6a 00                	push   $0x0
  pushl $82
80107210:	6a 52                	push   $0x52
  jmp alltraps
80107212:	e9 fd f6 ff ff       	jmp    80106914 <alltraps>

80107217 <vector83>:
.globl vector83
vector83:
  pushl $0
80107217:	6a 00                	push   $0x0
  pushl $83
80107219:	6a 53                	push   $0x53
  jmp alltraps
8010721b:	e9 f4 f6 ff ff       	jmp    80106914 <alltraps>

80107220 <vector84>:
.globl vector84
vector84:
  pushl $0
80107220:	6a 00                	push   $0x0
  pushl $84
80107222:	6a 54                	push   $0x54
  jmp alltraps
80107224:	e9 eb f6 ff ff       	jmp    80106914 <alltraps>

80107229 <vector85>:
.globl vector85
vector85:
  pushl $0
80107229:	6a 00                	push   $0x0
  pushl $85
8010722b:	6a 55                	push   $0x55
  jmp alltraps
8010722d:	e9 e2 f6 ff ff       	jmp    80106914 <alltraps>

80107232 <vector86>:
.globl vector86
vector86:
  pushl $0
80107232:	6a 00                	push   $0x0
  pushl $86
80107234:	6a 56                	push   $0x56
  jmp alltraps
80107236:	e9 d9 f6 ff ff       	jmp    80106914 <alltraps>

8010723b <vector87>:
.globl vector87
vector87:
  pushl $0
8010723b:	6a 00                	push   $0x0
  pushl $87
8010723d:	6a 57                	push   $0x57
  jmp alltraps
8010723f:	e9 d0 f6 ff ff       	jmp    80106914 <alltraps>

80107244 <vector88>:
.globl vector88
vector88:
  pushl $0
80107244:	6a 00                	push   $0x0
  pushl $88
80107246:	6a 58                	push   $0x58
  jmp alltraps
80107248:	e9 c7 f6 ff ff       	jmp    80106914 <alltraps>

8010724d <vector89>:
.globl vector89
vector89:
  pushl $0
8010724d:	6a 00                	push   $0x0
  pushl $89
8010724f:	6a 59                	push   $0x59
  jmp alltraps
80107251:	e9 be f6 ff ff       	jmp    80106914 <alltraps>

80107256 <vector90>:
.globl vector90
vector90:
  pushl $0
80107256:	6a 00                	push   $0x0
  pushl $90
80107258:	6a 5a                	push   $0x5a
  jmp alltraps
8010725a:	e9 b5 f6 ff ff       	jmp    80106914 <alltraps>

8010725f <vector91>:
.globl vector91
vector91:
  pushl $0
8010725f:	6a 00                	push   $0x0
  pushl $91
80107261:	6a 5b                	push   $0x5b
  jmp alltraps
80107263:	e9 ac f6 ff ff       	jmp    80106914 <alltraps>

80107268 <vector92>:
.globl vector92
vector92:
  pushl $0
80107268:	6a 00                	push   $0x0
  pushl $92
8010726a:	6a 5c                	push   $0x5c
  jmp alltraps
8010726c:	e9 a3 f6 ff ff       	jmp    80106914 <alltraps>

80107271 <vector93>:
.globl vector93
vector93:
  pushl $0
80107271:	6a 00                	push   $0x0
  pushl $93
80107273:	6a 5d                	push   $0x5d
  jmp alltraps
80107275:	e9 9a f6 ff ff       	jmp    80106914 <alltraps>

8010727a <vector94>:
.globl vector94
vector94:
  pushl $0
8010727a:	6a 00                	push   $0x0
  pushl $94
8010727c:	6a 5e                	push   $0x5e
  jmp alltraps
8010727e:	e9 91 f6 ff ff       	jmp    80106914 <alltraps>

80107283 <vector95>:
.globl vector95
vector95:
  pushl $0
80107283:	6a 00                	push   $0x0
  pushl $95
80107285:	6a 5f                	push   $0x5f
  jmp alltraps
80107287:	e9 88 f6 ff ff       	jmp    80106914 <alltraps>

8010728c <vector96>:
.globl vector96
vector96:
  pushl $0
8010728c:	6a 00                	push   $0x0
  pushl $96
8010728e:	6a 60                	push   $0x60
  jmp alltraps
80107290:	e9 7f f6 ff ff       	jmp    80106914 <alltraps>

80107295 <vector97>:
.globl vector97
vector97:
  pushl $0
80107295:	6a 00                	push   $0x0
  pushl $97
80107297:	6a 61                	push   $0x61
  jmp alltraps
80107299:	e9 76 f6 ff ff       	jmp    80106914 <alltraps>

8010729e <vector98>:
.globl vector98
vector98:
  pushl $0
8010729e:	6a 00                	push   $0x0
  pushl $98
801072a0:	6a 62                	push   $0x62
  jmp alltraps
801072a2:	e9 6d f6 ff ff       	jmp    80106914 <alltraps>

801072a7 <vector99>:
.globl vector99
vector99:
  pushl $0
801072a7:	6a 00                	push   $0x0
  pushl $99
801072a9:	6a 63                	push   $0x63
  jmp alltraps
801072ab:	e9 64 f6 ff ff       	jmp    80106914 <alltraps>

801072b0 <vector100>:
.globl vector100
vector100:
  pushl $0
801072b0:	6a 00                	push   $0x0
  pushl $100
801072b2:	6a 64                	push   $0x64
  jmp alltraps
801072b4:	e9 5b f6 ff ff       	jmp    80106914 <alltraps>

801072b9 <vector101>:
.globl vector101
vector101:
  pushl $0
801072b9:	6a 00                	push   $0x0
  pushl $101
801072bb:	6a 65                	push   $0x65
  jmp alltraps
801072bd:	e9 52 f6 ff ff       	jmp    80106914 <alltraps>

801072c2 <vector102>:
.globl vector102
vector102:
  pushl $0
801072c2:	6a 00                	push   $0x0
  pushl $102
801072c4:	6a 66                	push   $0x66
  jmp alltraps
801072c6:	e9 49 f6 ff ff       	jmp    80106914 <alltraps>

801072cb <vector103>:
.globl vector103
vector103:
  pushl $0
801072cb:	6a 00                	push   $0x0
  pushl $103
801072cd:	6a 67                	push   $0x67
  jmp alltraps
801072cf:	e9 40 f6 ff ff       	jmp    80106914 <alltraps>

801072d4 <vector104>:
.globl vector104
vector104:
  pushl $0
801072d4:	6a 00                	push   $0x0
  pushl $104
801072d6:	6a 68                	push   $0x68
  jmp alltraps
801072d8:	e9 37 f6 ff ff       	jmp    80106914 <alltraps>

801072dd <vector105>:
.globl vector105
vector105:
  pushl $0
801072dd:	6a 00                	push   $0x0
  pushl $105
801072df:	6a 69                	push   $0x69
  jmp alltraps
801072e1:	e9 2e f6 ff ff       	jmp    80106914 <alltraps>

801072e6 <vector106>:
.globl vector106
vector106:
  pushl $0
801072e6:	6a 00                	push   $0x0
  pushl $106
801072e8:	6a 6a                	push   $0x6a
  jmp alltraps
801072ea:	e9 25 f6 ff ff       	jmp    80106914 <alltraps>

801072ef <vector107>:
.globl vector107
vector107:
  pushl $0
801072ef:	6a 00                	push   $0x0
  pushl $107
801072f1:	6a 6b                	push   $0x6b
  jmp alltraps
801072f3:	e9 1c f6 ff ff       	jmp    80106914 <alltraps>

801072f8 <vector108>:
.globl vector108
vector108:
  pushl $0
801072f8:	6a 00                	push   $0x0
  pushl $108
801072fa:	6a 6c                	push   $0x6c
  jmp alltraps
801072fc:	e9 13 f6 ff ff       	jmp    80106914 <alltraps>

80107301 <vector109>:
.globl vector109
vector109:
  pushl $0
80107301:	6a 00                	push   $0x0
  pushl $109
80107303:	6a 6d                	push   $0x6d
  jmp alltraps
80107305:	e9 0a f6 ff ff       	jmp    80106914 <alltraps>

8010730a <vector110>:
.globl vector110
vector110:
  pushl $0
8010730a:	6a 00                	push   $0x0
  pushl $110
8010730c:	6a 6e                	push   $0x6e
  jmp alltraps
8010730e:	e9 01 f6 ff ff       	jmp    80106914 <alltraps>

80107313 <vector111>:
.globl vector111
vector111:
  pushl $0
80107313:	6a 00                	push   $0x0
  pushl $111
80107315:	6a 6f                	push   $0x6f
  jmp alltraps
80107317:	e9 f8 f5 ff ff       	jmp    80106914 <alltraps>

8010731c <vector112>:
.globl vector112
vector112:
  pushl $0
8010731c:	6a 00                	push   $0x0
  pushl $112
8010731e:	6a 70                	push   $0x70
  jmp alltraps
80107320:	e9 ef f5 ff ff       	jmp    80106914 <alltraps>

80107325 <vector113>:
.globl vector113
vector113:
  pushl $0
80107325:	6a 00                	push   $0x0
  pushl $113
80107327:	6a 71                	push   $0x71
  jmp alltraps
80107329:	e9 e6 f5 ff ff       	jmp    80106914 <alltraps>

8010732e <vector114>:
.globl vector114
vector114:
  pushl $0
8010732e:	6a 00                	push   $0x0
  pushl $114
80107330:	6a 72                	push   $0x72
  jmp alltraps
80107332:	e9 dd f5 ff ff       	jmp    80106914 <alltraps>

80107337 <vector115>:
.globl vector115
vector115:
  pushl $0
80107337:	6a 00                	push   $0x0
  pushl $115
80107339:	6a 73                	push   $0x73
  jmp alltraps
8010733b:	e9 d4 f5 ff ff       	jmp    80106914 <alltraps>

80107340 <vector116>:
.globl vector116
vector116:
  pushl $0
80107340:	6a 00                	push   $0x0
  pushl $116
80107342:	6a 74                	push   $0x74
  jmp alltraps
80107344:	e9 cb f5 ff ff       	jmp    80106914 <alltraps>

80107349 <vector117>:
.globl vector117
vector117:
  pushl $0
80107349:	6a 00                	push   $0x0
  pushl $117
8010734b:	6a 75                	push   $0x75
  jmp alltraps
8010734d:	e9 c2 f5 ff ff       	jmp    80106914 <alltraps>

80107352 <vector118>:
.globl vector118
vector118:
  pushl $0
80107352:	6a 00                	push   $0x0
  pushl $118
80107354:	6a 76                	push   $0x76
  jmp alltraps
80107356:	e9 b9 f5 ff ff       	jmp    80106914 <alltraps>

8010735b <vector119>:
.globl vector119
vector119:
  pushl $0
8010735b:	6a 00                	push   $0x0
  pushl $119
8010735d:	6a 77                	push   $0x77
  jmp alltraps
8010735f:	e9 b0 f5 ff ff       	jmp    80106914 <alltraps>

80107364 <vector120>:
.globl vector120
vector120:
  pushl $0
80107364:	6a 00                	push   $0x0
  pushl $120
80107366:	6a 78                	push   $0x78
  jmp alltraps
80107368:	e9 a7 f5 ff ff       	jmp    80106914 <alltraps>

8010736d <vector121>:
.globl vector121
vector121:
  pushl $0
8010736d:	6a 00                	push   $0x0
  pushl $121
8010736f:	6a 79                	push   $0x79
  jmp alltraps
80107371:	e9 9e f5 ff ff       	jmp    80106914 <alltraps>

80107376 <vector122>:
.globl vector122
vector122:
  pushl $0
80107376:	6a 00                	push   $0x0
  pushl $122
80107378:	6a 7a                	push   $0x7a
  jmp alltraps
8010737a:	e9 95 f5 ff ff       	jmp    80106914 <alltraps>

8010737f <vector123>:
.globl vector123
vector123:
  pushl $0
8010737f:	6a 00                	push   $0x0
  pushl $123
80107381:	6a 7b                	push   $0x7b
  jmp alltraps
80107383:	e9 8c f5 ff ff       	jmp    80106914 <alltraps>

80107388 <vector124>:
.globl vector124
vector124:
  pushl $0
80107388:	6a 00                	push   $0x0
  pushl $124
8010738a:	6a 7c                	push   $0x7c
  jmp alltraps
8010738c:	e9 83 f5 ff ff       	jmp    80106914 <alltraps>

80107391 <vector125>:
.globl vector125
vector125:
  pushl $0
80107391:	6a 00                	push   $0x0
  pushl $125
80107393:	6a 7d                	push   $0x7d
  jmp alltraps
80107395:	e9 7a f5 ff ff       	jmp    80106914 <alltraps>

8010739a <vector126>:
.globl vector126
vector126:
  pushl $0
8010739a:	6a 00                	push   $0x0
  pushl $126
8010739c:	6a 7e                	push   $0x7e
  jmp alltraps
8010739e:	e9 71 f5 ff ff       	jmp    80106914 <alltraps>

801073a3 <vector127>:
.globl vector127
vector127:
  pushl $0
801073a3:	6a 00                	push   $0x0
  pushl $127
801073a5:	6a 7f                	push   $0x7f
  jmp alltraps
801073a7:	e9 68 f5 ff ff       	jmp    80106914 <alltraps>

801073ac <vector128>:
.globl vector128
vector128:
  pushl $0
801073ac:	6a 00                	push   $0x0
  pushl $128
801073ae:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801073b3:	e9 5c f5 ff ff       	jmp    80106914 <alltraps>

801073b8 <vector129>:
.globl vector129
vector129:
  pushl $0
801073b8:	6a 00                	push   $0x0
  pushl $129
801073ba:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801073bf:	e9 50 f5 ff ff       	jmp    80106914 <alltraps>

801073c4 <vector130>:
.globl vector130
vector130:
  pushl $0
801073c4:	6a 00                	push   $0x0
  pushl $130
801073c6:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801073cb:	e9 44 f5 ff ff       	jmp    80106914 <alltraps>

801073d0 <vector131>:
.globl vector131
vector131:
  pushl $0
801073d0:	6a 00                	push   $0x0
  pushl $131
801073d2:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801073d7:	e9 38 f5 ff ff       	jmp    80106914 <alltraps>

801073dc <vector132>:
.globl vector132
vector132:
  pushl $0
801073dc:	6a 00                	push   $0x0
  pushl $132
801073de:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801073e3:	e9 2c f5 ff ff       	jmp    80106914 <alltraps>

801073e8 <vector133>:
.globl vector133
vector133:
  pushl $0
801073e8:	6a 00                	push   $0x0
  pushl $133
801073ea:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801073ef:	e9 20 f5 ff ff       	jmp    80106914 <alltraps>

801073f4 <vector134>:
.globl vector134
vector134:
  pushl $0
801073f4:	6a 00                	push   $0x0
  pushl $134
801073f6:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801073fb:	e9 14 f5 ff ff       	jmp    80106914 <alltraps>

80107400 <vector135>:
.globl vector135
vector135:
  pushl $0
80107400:	6a 00                	push   $0x0
  pushl $135
80107402:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107407:	e9 08 f5 ff ff       	jmp    80106914 <alltraps>

8010740c <vector136>:
.globl vector136
vector136:
  pushl $0
8010740c:	6a 00                	push   $0x0
  pushl $136
8010740e:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107413:	e9 fc f4 ff ff       	jmp    80106914 <alltraps>

80107418 <vector137>:
.globl vector137
vector137:
  pushl $0
80107418:	6a 00                	push   $0x0
  pushl $137
8010741a:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010741f:	e9 f0 f4 ff ff       	jmp    80106914 <alltraps>

80107424 <vector138>:
.globl vector138
vector138:
  pushl $0
80107424:	6a 00                	push   $0x0
  pushl $138
80107426:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010742b:	e9 e4 f4 ff ff       	jmp    80106914 <alltraps>

80107430 <vector139>:
.globl vector139
vector139:
  pushl $0
80107430:	6a 00                	push   $0x0
  pushl $139
80107432:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107437:	e9 d8 f4 ff ff       	jmp    80106914 <alltraps>

8010743c <vector140>:
.globl vector140
vector140:
  pushl $0
8010743c:	6a 00                	push   $0x0
  pushl $140
8010743e:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107443:	e9 cc f4 ff ff       	jmp    80106914 <alltraps>

80107448 <vector141>:
.globl vector141
vector141:
  pushl $0
80107448:	6a 00                	push   $0x0
  pushl $141
8010744a:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010744f:	e9 c0 f4 ff ff       	jmp    80106914 <alltraps>

80107454 <vector142>:
.globl vector142
vector142:
  pushl $0
80107454:	6a 00                	push   $0x0
  pushl $142
80107456:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010745b:	e9 b4 f4 ff ff       	jmp    80106914 <alltraps>

80107460 <vector143>:
.globl vector143
vector143:
  pushl $0
80107460:	6a 00                	push   $0x0
  pushl $143
80107462:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107467:	e9 a8 f4 ff ff       	jmp    80106914 <alltraps>

8010746c <vector144>:
.globl vector144
vector144:
  pushl $0
8010746c:	6a 00                	push   $0x0
  pushl $144
8010746e:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107473:	e9 9c f4 ff ff       	jmp    80106914 <alltraps>

80107478 <vector145>:
.globl vector145
vector145:
  pushl $0
80107478:	6a 00                	push   $0x0
  pushl $145
8010747a:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010747f:	e9 90 f4 ff ff       	jmp    80106914 <alltraps>

80107484 <vector146>:
.globl vector146
vector146:
  pushl $0
80107484:	6a 00                	push   $0x0
  pushl $146
80107486:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010748b:	e9 84 f4 ff ff       	jmp    80106914 <alltraps>

80107490 <vector147>:
.globl vector147
vector147:
  pushl $0
80107490:	6a 00                	push   $0x0
  pushl $147
80107492:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107497:	e9 78 f4 ff ff       	jmp    80106914 <alltraps>

8010749c <vector148>:
.globl vector148
vector148:
  pushl $0
8010749c:	6a 00                	push   $0x0
  pushl $148
8010749e:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801074a3:	e9 6c f4 ff ff       	jmp    80106914 <alltraps>

801074a8 <vector149>:
.globl vector149
vector149:
  pushl $0
801074a8:	6a 00                	push   $0x0
  pushl $149
801074aa:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801074af:	e9 60 f4 ff ff       	jmp    80106914 <alltraps>

801074b4 <vector150>:
.globl vector150
vector150:
  pushl $0
801074b4:	6a 00                	push   $0x0
  pushl $150
801074b6:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801074bb:	e9 54 f4 ff ff       	jmp    80106914 <alltraps>

801074c0 <vector151>:
.globl vector151
vector151:
  pushl $0
801074c0:	6a 00                	push   $0x0
  pushl $151
801074c2:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801074c7:	e9 48 f4 ff ff       	jmp    80106914 <alltraps>

801074cc <vector152>:
.globl vector152
vector152:
  pushl $0
801074cc:	6a 00                	push   $0x0
  pushl $152
801074ce:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801074d3:	e9 3c f4 ff ff       	jmp    80106914 <alltraps>

801074d8 <vector153>:
.globl vector153
vector153:
  pushl $0
801074d8:	6a 00                	push   $0x0
  pushl $153
801074da:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801074df:	e9 30 f4 ff ff       	jmp    80106914 <alltraps>

801074e4 <vector154>:
.globl vector154
vector154:
  pushl $0
801074e4:	6a 00                	push   $0x0
  pushl $154
801074e6:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801074eb:	e9 24 f4 ff ff       	jmp    80106914 <alltraps>

801074f0 <vector155>:
.globl vector155
vector155:
  pushl $0
801074f0:	6a 00                	push   $0x0
  pushl $155
801074f2:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801074f7:	e9 18 f4 ff ff       	jmp    80106914 <alltraps>

801074fc <vector156>:
.globl vector156
vector156:
  pushl $0
801074fc:	6a 00                	push   $0x0
  pushl $156
801074fe:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107503:	e9 0c f4 ff ff       	jmp    80106914 <alltraps>

80107508 <vector157>:
.globl vector157
vector157:
  pushl $0
80107508:	6a 00                	push   $0x0
  pushl $157
8010750a:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010750f:	e9 00 f4 ff ff       	jmp    80106914 <alltraps>

80107514 <vector158>:
.globl vector158
vector158:
  pushl $0
80107514:	6a 00                	push   $0x0
  pushl $158
80107516:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010751b:	e9 f4 f3 ff ff       	jmp    80106914 <alltraps>

80107520 <vector159>:
.globl vector159
vector159:
  pushl $0
80107520:	6a 00                	push   $0x0
  pushl $159
80107522:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107527:	e9 e8 f3 ff ff       	jmp    80106914 <alltraps>

8010752c <vector160>:
.globl vector160
vector160:
  pushl $0
8010752c:	6a 00                	push   $0x0
  pushl $160
8010752e:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107533:	e9 dc f3 ff ff       	jmp    80106914 <alltraps>

80107538 <vector161>:
.globl vector161
vector161:
  pushl $0
80107538:	6a 00                	push   $0x0
  pushl $161
8010753a:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010753f:	e9 d0 f3 ff ff       	jmp    80106914 <alltraps>

80107544 <vector162>:
.globl vector162
vector162:
  pushl $0
80107544:	6a 00                	push   $0x0
  pushl $162
80107546:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010754b:	e9 c4 f3 ff ff       	jmp    80106914 <alltraps>

80107550 <vector163>:
.globl vector163
vector163:
  pushl $0
80107550:	6a 00                	push   $0x0
  pushl $163
80107552:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107557:	e9 b8 f3 ff ff       	jmp    80106914 <alltraps>

8010755c <vector164>:
.globl vector164
vector164:
  pushl $0
8010755c:	6a 00                	push   $0x0
  pushl $164
8010755e:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107563:	e9 ac f3 ff ff       	jmp    80106914 <alltraps>

80107568 <vector165>:
.globl vector165
vector165:
  pushl $0
80107568:	6a 00                	push   $0x0
  pushl $165
8010756a:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010756f:	e9 a0 f3 ff ff       	jmp    80106914 <alltraps>

80107574 <vector166>:
.globl vector166
vector166:
  pushl $0
80107574:	6a 00                	push   $0x0
  pushl $166
80107576:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010757b:	e9 94 f3 ff ff       	jmp    80106914 <alltraps>

80107580 <vector167>:
.globl vector167
vector167:
  pushl $0
80107580:	6a 00                	push   $0x0
  pushl $167
80107582:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107587:	e9 88 f3 ff ff       	jmp    80106914 <alltraps>

8010758c <vector168>:
.globl vector168
vector168:
  pushl $0
8010758c:	6a 00                	push   $0x0
  pushl $168
8010758e:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107593:	e9 7c f3 ff ff       	jmp    80106914 <alltraps>

80107598 <vector169>:
.globl vector169
vector169:
  pushl $0
80107598:	6a 00                	push   $0x0
  pushl $169
8010759a:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010759f:	e9 70 f3 ff ff       	jmp    80106914 <alltraps>

801075a4 <vector170>:
.globl vector170
vector170:
  pushl $0
801075a4:	6a 00                	push   $0x0
  pushl $170
801075a6:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801075ab:	e9 64 f3 ff ff       	jmp    80106914 <alltraps>

801075b0 <vector171>:
.globl vector171
vector171:
  pushl $0
801075b0:	6a 00                	push   $0x0
  pushl $171
801075b2:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801075b7:	e9 58 f3 ff ff       	jmp    80106914 <alltraps>

801075bc <vector172>:
.globl vector172
vector172:
  pushl $0
801075bc:	6a 00                	push   $0x0
  pushl $172
801075be:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801075c3:	e9 4c f3 ff ff       	jmp    80106914 <alltraps>

801075c8 <vector173>:
.globl vector173
vector173:
  pushl $0
801075c8:	6a 00                	push   $0x0
  pushl $173
801075ca:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801075cf:	e9 40 f3 ff ff       	jmp    80106914 <alltraps>

801075d4 <vector174>:
.globl vector174
vector174:
  pushl $0
801075d4:	6a 00                	push   $0x0
  pushl $174
801075d6:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801075db:	e9 34 f3 ff ff       	jmp    80106914 <alltraps>

801075e0 <vector175>:
.globl vector175
vector175:
  pushl $0
801075e0:	6a 00                	push   $0x0
  pushl $175
801075e2:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801075e7:	e9 28 f3 ff ff       	jmp    80106914 <alltraps>

801075ec <vector176>:
.globl vector176
vector176:
  pushl $0
801075ec:	6a 00                	push   $0x0
  pushl $176
801075ee:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801075f3:	e9 1c f3 ff ff       	jmp    80106914 <alltraps>

801075f8 <vector177>:
.globl vector177
vector177:
  pushl $0
801075f8:	6a 00                	push   $0x0
  pushl $177
801075fa:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801075ff:	e9 10 f3 ff ff       	jmp    80106914 <alltraps>

80107604 <vector178>:
.globl vector178
vector178:
  pushl $0
80107604:	6a 00                	push   $0x0
  pushl $178
80107606:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010760b:	e9 04 f3 ff ff       	jmp    80106914 <alltraps>

80107610 <vector179>:
.globl vector179
vector179:
  pushl $0
80107610:	6a 00                	push   $0x0
  pushl $179
80107612:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107617:	e9 f8 f2 ff ff       	jmp    80106914 <alltraps>

8010761c <vector180>:
.globl vector180
vector180:
  pushl $0
8010761c:	6a 00                	push   $0x0
  pushl $180
8010761e:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107623:	e9 ec f2 ff ff       	jmp    80106914 <alltraps>

80107628 <vector181>:
.globl vector181
vector181:
  pushl $0
80107628:	6a 00                	push   $0x0
  pushl $181
8010762a:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010762f:	e9 e0 f2 ff ff       	jmp    80106914 <alltraps>

80107634 <vector182>:
.globl vector182
vector182:
  pushl $0
80107634:	6a 00                	push   $0x0
  pushl $182
80107636:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010763b:	e9 d4 f2 ff ff       	jmp    80106914 <alltraps>

80107640 <vector183>:
.globl vector183
vector183:
  pushl $0
80107640:	6a 00                	push   $0x0
  pushl $183
80107642:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107647:	e9 c8 f2 ff ff       	jmp    80106914 <alltraps>

8010764c <vector184>:
.globl vector184
vector184:
  pushl $0
8010764c:	6a 00                	push   $0x0
  pushl $184
8010764e:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107653:	e9 bc f2 ff ff       	jmp    80106914 <alltraps>

80107658 <vector185>:
.globl vector185
vector185:
  pushl $0
80107658:	6a 00                	push   $0x0
  pushl $185
8010765a:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010765f:	e9 b0 f2 ff ff       	jmp    80106914 <alltraps>

80107664 <vector186>:
.globl vector186
vector186:
  pushl $0
80107664:	6a 00                	push   $0x0
  pushl $186
80107666:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010766b:	e9 a4 f2 ff ff       	jmp    80106914 <alltraps>

80107670 <vector187>:
.globl vector187
vector187:
  pushl $0
80107670:	6a 00                	push   $0x0
  pushl $187
80107672:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107677:	e9 98 f2 ff ff       	jmp    80106914 <alltraps>

8010767c <vector188>:
.globl vector188
vector188:
  pushl $0
8010767c:	6a 00                	push   $0x0
  pushl $188
8010767e:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107683:	e9 8c f2 ff ff       	jmp    80106914 <alltraps>

80107688 <vector189>:
.globl vector189
vector189:
  pushl $0
80107688:	6a 00                	push   $0x0
  pushl $189
8010768a:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010768f:	e9 80 f2 ff ff       	jmp    80106914 <alltraps>

80107694 <vector190>:
.globl vector190
vector190:
  pushl $0
80107694:	6a 00                	push   $0x0
  pushl $190
80107696:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010769b:	e9 74 f2 ff ff       	jmp    80106914 <alltraps>

801076a0 <vector191>:
.globl vector191
vector191:
  pushl $0
801076a0:	6a 00                	push   $0x0
  pushl $191
801076a2:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801076a7:	e9 68 f2 ff ff       	jmp    80106914 <alltraps>

801076ac <vector192>:
.globl vector192
vector192:
  pushl $0
801076ac:	6a 00                	push   $0x0
  pushl $192
801076ae:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801076b3:	e9 5c f2 ff ff       	jmp    80106914 <alltraps>

801076b8 <vector193>:
.globl vector193
vector193:
  pushl $0
801076b8:	6a 00                	push   $0x0
  pushl $193
801076ba:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801076bf:	e9 50 f2 ff ff       	jmp    80106914 <alltraps>

801076c4 <vector194>:
.globl vector194
vector194:
  pushl $0
801076c4:	6a 00                	push   $0x0
  pushl $194
801076c6:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801076cb:	e9 44 f2 ff ff       	jmp    80106914 <alltraps>

801076d0 <vector195>:
.globl vector195
vector195:
  pushl $0
801076d0:	6a 00                	push   $0x0
  pushl $195
801076d2:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801076d7:	e9 38 f2 ff ff       	jmp    80106914 <alltraps>

801076dc <vector196>:
.globl vector196
vector196:
  pushl $0
801076dc:	6a 00                	push   $0x0
  pushl $196
801076de:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801076e3:	e9 2c f2 ff ff       	jmp    80106914 <alltraps>

801076e8 <vector197>:
.globl vector197
vector197:
  pushl $0
801076e8:	6a 00                	push   $0x0
  pushl $197
801076ea:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801076ef:	e9 20 f2 ff ff       	jmp    80106914 <alltraps>

801076f4 <vector198>:
.globl vector198
vector198:
  pushl $0
801076f4:	6a 00                	push   $0x0
  pushl $198
801076f6:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801076fb:	e9 14 f2 ff ff       	jmp    80106914 <alltraps>

80107700 <vector199>:
.globl vector199
vector199:
  pushl $0
80107700:	6a 00                	push   $0x0
  pushl $199
80107702:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107707:	e9 08 f2 ff ff       	jmp    80106914 <alltraps>

8010770c <vector200>:
.globl vector200
vector200:
  pushl $0
8010770c:	6a 00                	push   $0x0
  pushl $200
8010770e:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107713:	e9 fc f1 ff ff       	jmp    80106914 <alltraps>

80107718 <vector201>:
.globl vector201
vector201:
  pushl $0
80107718:	6a 00                	push   $0x0
  pushl $201
8010771a:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010771f:	e9 f0 f1 ff ff       	jmp    80106914 <alltraps>

80107724 <vector202>:
.globl vector202
vector202:
  pushl $0
80107724:	6a 00                	push   $0x0
  pushl $202
80107726:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010772b:	e9 e4 f1 ff ff       	jmp    80106914 <alltraps>

80107730 <vector203>:
.globl vector203
vector203:
  pushl $0
80107730:	6a 00                	push   $0x0
  pushl $203
80107732:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107737:	e9 d8 f1 ff ff       	jmp    80106914 <alltraps>

8010773c <vector204>:
.globl vector204
vector204:
  pushl $0
8010773c:	6a 00                	push   $0x0
  pushl $204
8010773e:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107743:	e9 cc f1 ff ff       	jmp    80106914 <alltraps>

80107748 <vector205>:
.globl vector205
vector205:
  pushl $0
80107748:	6a 00                	push   $0x0
  pushl $205
8010774a:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010774f:	e9 c0 f1 ff ff       	jmp    80106914 <alltraps>

80107754 <vector206>:
.globl vector206
vector206:
  pushl $0
80107754:	6a 00                	push   $0x0
  pushl $206
80107756:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010775b:	e9 b4 f1 ff ff       	jmp    80106914 <alltraps>

80107760 <vector207>:
.globl vector207
vector207:
  pushl $0
80107760:	6a 00                	push   $0x0
  pushl $207
80107762:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107767:	e9 a8 f1 ff ff       	jmp    80106914 <alltraps>

8010776c <vector208>:
.globl vector208
vector208:
  pushl $0
8010776c:	6a 00                	push   $0x0
  pushl $208
8010776e:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107773:	e9 9c f1 ff ff       	jmp    80106914 <alltraps>

80107778 <vector209>:
.globl vector209
vector209:
  pushl $0
80107778:	6a 00                	push   $0x0
  pushl $209
8010777a:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010777f:	e9 90 f1 ff ff       	jmp    80106914 <alltraps>

80107784 <vector210>:
.globl vector210
vector210:
  pushl $0
80107784:	6a 00                	push   $0x0
  pushl $210
80107786:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010778b:	e9 84 f1 ff ff       	jmp    80106914 <alltraps>

80107790 <vector211>:
.globl vector211
vector211:
  pushl $0
80107790:	6a 00                	push   $0x0
  pushl $211
80107792:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107797:	e9 78 f1 ff ff       	jmp    80106914 <alltraps>

8010779c <vector212>:
.globl vector212
vector212:
  pushl $0
8010779c:	6a 00                	push   $0x0
  pushl $212
8010779e:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801077a3:	e9 6c f1 ff ff       	jmp    80106914 <alltraps>

801077a8 <vector213>:
.globl vector213
vector213:
  pushl $0
801077a8:	6a 00                	push   $0x0
  pushl $213
801077aa:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801077af:	e9 60 f1 ff ff       	jmp    80106914 <alltraps>

801077b4 <vector214>:
.globl vector214
vector214:
  pushl $0
801077b4:	6a 00                	push   $0x0
  pushl $214
801077b6:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801077bb:	e9 54 f1 ff ff       	jmp    80106914 <alltraps>

801077c0 <vector215>:
.globl vector215
vector215:
  pushl $0
801077c0:	6a 00                	push   $0x0
  pushl $215
801077c2:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801077c7:	e9 48 f1 ff ff       	jmp    80106914 <alltraps>

801077cc <vector216>:
.globl vector216
vector216:
  pushl $0
801077cc:	6a 00                	push   $0x0
  pushl $216
801077ce:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801077d3:	e9 3c f1 ff ff       	jmp    80106914 <alltraps>

801077d8 <vector217>:
.globl vector217
vector217:
  pushl $0
801077d8:	6a 00                	push   $0x0
  pushl $217
801077da:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801077df:	e9 30 f1 ff ff       	jmp    80106914 <alltraps>

801077e4 <vector218>:
.globl vector218
vector218:
  pushl $0
801077e4:	6a 00                	push   $0x0
  pushl $218
801077e6:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801077eb:	e9 24 f1 ff ff       	jmp    80106914 <alltraps>

801077f0 <vector219>:
.globl vector219
vector219:
  pushl $0
801077f0:	6a 00                	push   $0x0
  pushl $219
801077f2:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801077f7:	e9 18 f1 ff ff       	jmp    80106914 <alltraps>

801077fc <vector220>:
.globl vector220
vector220:
  pushl $0
801077fc:	6a 00                	push   $0x0
  pushl $220
801077fe:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107803:	e9 0c f1 ff ff       	jmp    80106914 <alltraps>

80107808 <vector221>:
.globl vector221
vector221:
  pushl $0
80107808:	6a 00                	push   $0x0
  pushl $221
8010780a:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010780f:	e9 00 f1 ff ff       	jmp    80106914 <alltraps>

80107814 <vector222>:
.globl vector222
vector222:
  pushl $0
80107814:	6a 00                	push   $0x0
  pushl $222
80107816:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010781b:	e9 f4 f0 ff ff       	jmp    80106914 <alltraps>

80107820 <vector223>:
.globl vector223
vector223:
  pushl $0
80107820:	6a 00                	push   $0x0
  pushl $223
80107822:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107827:	e9 e8 f0 ff ff       	jmp    80106914 <alltraps>

8010782c <vector224>:
.globl vector224
vector224:
  pushl $0
8010782c:	6a 00                	push   $0x0
  pushl $224
8010782e:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107833:	e9 dc f0 ff ff       	jmp    80106914 <alltraps>

80107838 <vector225>:
.globl vector225
vector225:
  pushl $0
80107838:	6a 00                	push   $0x0
  pushl $225
8010783a:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010783f:	e9 d0 f0 ff ff       	jmp    80106914 <alltraps>

80107844 <vector226>:
.globl vector226
vector226:
  pushl $0
80107844:	6a 00                	push   $0x0
  pushl $226
80107846:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010784b:	e9 c4 f0 ff ff       	jmp    80106914 <alltraps>

80107850 <vector227>:
.globl vector227
vector227:
  pushl $0
80107850:	6a 00                	push   $0x0
  pushl $227
80107852:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107857:	e9 b8 f0 ff ff       	jmp    80106914 <alltraps>

8010785c <vector228>:
.globl vector228
vector228:
  pushl $0
8010785c:	6a 00                	push   $0x0
  pushl $228
8010785e:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107863:	e9 ac f0 ff ff       	jmp    80106914 <alltraps>

80107868 <vector229>:
.globl vector229
vector229:
  pushl $0
80107868:	6a 00                	push   $0x0
  pushl $229
8010786a:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010786f:	e9 a0 f0 ff ff       	jmp    80106914 <alltraps>

80107874 <vector230>:
.globl vector230
vector230:
  pushl $0
80107874:	6a 00                	push   $0x0
  pushl $230
80107876:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010787b:	e9 94 f0 ff ff       	jmp    80106914 <alltraps>

80107880 <vector231>:
.globl vector231
vector231:
  pushl $0
80107880:	6a 00                	push   $0x0
  pushl $231
80107882:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107887:	e9 88 f0 ff ff       	jmp    80106914 <alltraps>

8010788c <vector232>:
.globl vector232
vector232:
  pushl $0
8010788c:	6a 00                	push   $0x0
  pushl $232
8010788e:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107893:	e9 7c f0 ff ff       	jmp    80106914 <alltraps>

80107898 <vector233>:
.globl vector233
vector233:
  pushl $0
80107898:	6a 00                	push   $0x0
  pushl $233
8010789a:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010789f:	e9 70 f0 ff ff       	jmp    80106914 <alltraps>

801078a4 <vector234>:
.globl vector234
vector234:
  pushl $0
801078a4:	6a 00                	push   $0x0
  pushl $234
801078a6:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801078ab:	e9 64 f0 ff ff       	jmp    80106914 <alltraps>

801078b0 <vector235>:
.globl vector235
vector235:
  pushl $0
801078b0:	6a 00                	push   $0x0
  pushl $235
801078b2:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801078b7:	e9 58 f0 ff ff       	jmp    80106914 <alltraps>

801078bc <vector236>:
.globl vector236
vector236:
  pushl $0
801078bc:	6a 00                	push   $0x0
  pushl $236
801078be:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801078c3:	e9 4c f0 ff ff       	jmp    80106914 <alltraps>

801078c8 <vector237>:
.globl vector237
vector237:
  pushl $0
801078c8:	6a 00                	push   $0x0
  pushl $237
801078ca:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801078cf:	e9 40 f0 ff ff       	jmp    80106914 <alltraps>

801078d4 <vector238>:
.globl vector238
vector238:
  pushl $0
801078d4:	6a 00                	push   $0x0
  pushl $238
801078d6:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801078db:	e9 34 f0 ff ff       	jmp    80106914 <alltraps>

801078e0 <vector239>:
.globl vector239
vector239:
  pushl $0
801078e0:	6a 00                	push   $0x0
  pushl $239
801078e2:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801078e7:	e9 28 f0 ff ff       	jmp    80106914 <alltraps>

801078ec <vector240>:
.globl vector240
vector240:
  pushl $0
801078ec:	6a 00                	push   $0x0
  pushl $240
801078ee:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801078f3:	e9 1c f0 ff ff       	jmp    80106914 <alltraps>

801078f8 <vector241>:
.globl vector241
vector241:
  pushl $0
801078f8:	6a 00                	push   $0x0
  pushl $241
801078fa:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801078ff:	e9 10 f0 ff ff       	jmp    80106914 <alltraps>

80107904 <vector242>:
.globl vector242
vector242:
  pushl $0
80107904:	6a 00                	push   $0x0
  pushl $242
80107906:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010790b:	e9 04 f0 ff ff       	jmp    80106914 <alltraps>

80107910 <vector243>:
.globl vector243
vector243:
  pushl $0
80107910:	6a 00                	push   $0x0
  pushl $243
80107912:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107917:	e9 f8 ef ff ff       	jmp    80106914 <alltraps>

8010791c <vector244>:
.globl vector244
vector244:
  pushl $0
8010791c:	6a 00                	push   $0x0
  pushl $244
8010791e:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107923:	e9 ec ef ff ff       	jmp    80106914 <alltraps>

80107928 <vector245>:
.globl vector245
vector245:
  pushl $0
80107928:	6a 00                	push   $0x0
  pushl $245
8010792a:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010792f:	e9 e0 ef ff ff       	jmp    80106914 <alltraps>

80107934 <vector246>:
.globl vector246
vector246:
  pushl $0
80107934:	6a 00                	push   $0x0
  pushl $246
80107936:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010793b:	e9 d4 ef ff ff       	jmp    80106914 <alltraps>

80107940 <vector247>:
.globl vector247
vector247:
  pushl $0
80107940:	6a 00                	push   $0x0
  pushl $247
80107942:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107947:	e9 c8 ef ff ff       	jmp    80106914 <alltraps>

8010794c <vector248>:
.globl vector248
vector248:
  pushl $0
8010794c:	6a 00                	push   $0x0
  pushl $248
8010794e:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107953:	e9 bc ef ff ff       	jmp    80106914 <alltraps>

80107958 <vector249>:
.globl vector249
vector249:
  pushl $0
80107958:	6a 00                	push   $0x0
  pushl $249
8010795a:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010795f:	e9 b0 ef ff ff       	jmp    80106914 <alltraps>

80107964 <vector250>:
.globl vector250
vector250:
  pushl $0
80107964:	6a 00                	push   $0x0
  pushl $250
80107966:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010796b:	e9 a4 ef ff ff       	jmp    80106914 <alltraps>

80107970 <vector251>:
.globl vector251
vector251:
  pushl $0
80107970:	6a 00                	push   $0x0
  pushl $251
80107972:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107977:	e9 98 ef ff ff       	jmp    80106914 <alltraps>

8010797c <vector252>:
.globl vector252
vector252:
  pushl $0
8010797c:	6a 00                	push   $0x0
  pushl $252
8010797e:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107983:	e9 8c ef ff ff       	jmp    80106914 <alltraps>

80107988 <vector253>:
.globl vector253
vector253:
  pushl $0
80107988:	6a 00                	push   $0x0
  pushl $253
8010798a:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010798f:	e9 80 ef ff ff       	jmp    80106914 <alltraps>

80107994 <vector254>:
.globl vector254
vector254:
  pushl $0
80107994:	6a 00                	push   $0x0
  pushl $254
80107996:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010799b:	e9 74 ef ff ff       	jmp    80106914 <alltraps>

801079a0 <vector255>:
.globl vector255
vector255:
  pushl $0
801079a0:	6a 00                	push   $0x0
  pushl $255
801079a2:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801079a7:	e9 68 ef ff ff       	jmp    80106914 <alltraps>

801079ac <lgdt>:
{
801079ac:	55                   	push   %ebp
801079ad:	89 e5                	mov    %esp,%ebp
801079af:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801079b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801079b5:	83 e8 01             	sub    $0x1,%eax
801079b8:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801079bc:	8b 45 08             	mov    0x8(%ebp),%eax
801079bf:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801079c3:	8b 45 08             	mov    0x8(%ebp),%eax
801079c6:	c1 e8 10             	shr    $0x10,%eax
801079c9:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
801079cd:	8d 45 fa             	lea    -0x6(%ebp),%eax
801079d0:	0f 01 10             	lgdtl  (%eax)
}
801079d3:	90                   	nop
801079d4:	c9                   	leave  
801079d5:	c3                   	ret    

801079d6 <ltr>:
{
801079d6:	55                   	push   %ebp
801079d7:	89 e5                	mov    %esp,%ebp
801079d9:	83 ec 04             	sub    $0x4,%esp
801079dc:	8b 45 08             	mov    0x8(%ebp),%eax
801079df:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801079e3:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801079e7:	0f 00 d8             	ltr    %ax
}
801079ea:	90                   	nop
801079eb:	c9                   	leave  
801079ec:	c3                   	ret    

801079ed <lcr3>:

static inline void
lcr3(uint val)
{
801079ed:	55                   	push   %ebp
801079ee:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801079f0:	8b 45 08             	mov    0x8(%ebp),%eax
801079f3:	0f 22 d8             	mov    %eax,%cr3
}
801079f6:	90                   	nop
801079f7:	5d                   	pop    %ebp
801079f8:	c3                   	ret    

801079f9 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801079f9:	55                   	push   %ebp
801079fa:	89 e5                	mov    %esp,%ebp
801079fc:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
801079ff:	e8 43 c8 ff ff       	call   80104247 <cpuid>
80107a04:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107a0a:	05 c0 27 11 80       	add    $0x801127c0,%eax
80107a0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a15:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a1e:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a27:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a2e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a32:	83 e2 f0             	and    $0xfffffff0,%edx
80107a35:	83 ca 0a             	or     $0xa,%edx
80107a38:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a3e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a42:	83 ca 10             	or     $0x10,%edx
80107a45:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a4b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a4f:	83 e2 9f             	and    $0xffffff9f,%edx
80107a52:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a58:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a5c:	83 ca 80             	or     $0xffffff80,%edx
80107a5f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a65:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a69:	83 ca 0f             	or     $0xf,%edx
80107a6c:	88 50 7e             	mov    %dl,0x7e(%eax)
80107a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a72:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a76:	83 e2 ef             	and    $0xffffffef,%edx
80107a79:	88 50 7e             	mov    %dl,0x7e(%eax)
80107a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a83:	83 e2 df             	and    $0xffffffdf,%edx
80107a86:	88 50 7e             	mov    %dl,0x7e(%eax)
80107a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a8c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a90:	83 ca 40             	or     $0x40,%edx
80107a93:	88 50 7e             	mov    %dl,0x7e(%eax)
80107a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a99:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a9d:	83 ca 80             	or     $0xffffff80,%edx
80107aa0:	88 50 7e             	mov    %dl,0x7e(%eax)
80107aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa6:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aad:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107ab4:	ff ff 
80107ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab9:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107ac0:	00 00 
80107ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac5:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107acf:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107ad6:	83 e2 f0             	and    $0xfffffff0,%edx
80107ad9:	83 ca 02             	or     $0x2,%edx
80107adc:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae5:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107aec:	83 ca 10             	or     $0x10,%edx
80107aef:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af8:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107aff:	83 e2 9f             	and    $0xffffff9f,%edx
80107b02:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0b:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b12:	83 ca 80             	or     $0xffffff80,%edx
80107b15:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b1e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b25:	83 ca 0f             	or     $0xf,%edx
80107b28:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b31:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b38:	83 e2 ef             	and    $0xffffffef,%edx
80107b3b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b44:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b4b:	83 e2 df             	and    $0xffffffdf,%edx
80107b4e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b57:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b5e:	83 ca 40             	or     $0x40,%edx
80107b61:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b6a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b71:	83 ca 80             	or     $0xffffff80,%edx
80107b74:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b7d:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b87:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107b8e:	ff ff 
80107b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b93:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107b9a:	00 00 
80107b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b9f:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba9:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107bb0:	83 e2 f0             	and    $0xfffffff0,%edx
80107bb3:	83 ca 0a             	or     $0xa,%edx
80107bb6:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bbf:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107bc6:	83 ca 10             	or     $0x10,%edx
80107bc9:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd2:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107bd9:	83 ca 60             	or     $0x60,%edx
80107bdc:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be5:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107bec:	83 ca 80             	or     $0xffffff80,%edx
80107bef:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107bf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf8:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107bff:	83 ca 0f             	or     $0xf,%edx
80107c02:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c12:	83 e2 ef             	and    $0xffffffef,%edx
80107c15:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c1e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c25:	83 e2 df             	and    $0xffffffdf,%edx
80107c28:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c31:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c38:	83 ca 40             	or     $0x40,%edx
80107c3b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c44:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c4b:	83 ca 80             	or     $0xffffff80,%edx
80107c4e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c57:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c61:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107c68:	ff ff 
80107c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c6d:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107c74:	00 00 
80107c76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c79:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c83:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c8a:	83 e2 f0             	and    $0xfffffff0,%edx
80107c8d:	83 ca 02             	or     $0x2,%edx
80107c90:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c99:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ca0:	83 ca 10             	or     $0x10,%edx
80107ca3:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cac:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107cb3:	83 ca 60             	or     $0x60,%edx
80107cb6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107cbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cbf:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107cc6:	83 ca 80             	or     $0xffffff80,%edx
80107cc9:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ccf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd2:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107cd9:	83 ca 0f             	or     $0xf,%edx
80107cdc:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ce2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce5:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107cec:	83 e2 ef             	and    $0xffffffef,%edx
80107cef:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107cf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf8:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107cff:	83 e2 df             	and    $0xffffffdf,%edx
80107d02:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d0b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d12:	83 ca 40             	or     $0x40,%edx
80107d15:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d1e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d25:	83 ca 80             	or     $0xffffff80,%edx
80107d28:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d31:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3b:	83 c0 70             	add    $0x70,%eax
80107d3e:	83 ec 08             	sub    $0x8,%esp
80107d41:	6a 30                	push   $0x30
80107d43:	50                   	push   %eax
80107d44:	e8 63 fc ff ff       	call   801079ac <lgdt>
80107d49:	83 c4 10             	add    $0x10,%esp
}
80107d4c:	90                   	nop
80107d4d:	c9                   	leave  
80107d4e:	c3                   	ret    

80107d4f <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107d4f:	55                   	push   %ebp
80107d50:	89 e5                	mov    %esp,%ebp
80107d52:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107d55:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d58:	c1 e8 16             	shr    $0x16,%eax
80107d5b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107d62:	8b 45 08             	mov    0x8(%ebp),%eax
80107d65:	01 d0                	add    %edx,%eax
80107d67:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107d6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d6d:	8b 00                	mov    (%eax),%eax
80107d6f:	83 e0 01             	and    $0x1,%eax
80107d72:	85 c0                	test   %eax,%eax
80107d74:	74 14                	je     80107d8a <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107d76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d79:	8b 00                	mov    (%eax),%eax
80107d7b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d80:	05 00 00 00 80       	add    $0x80000000,%eax
80107d85:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107d88:	eb 42                	jmp    80107dcc <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107d8a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107d8e:	74 0e                	je     80107d9e <walkpgdir+0x4f>
80107d90:	e8 01 af ff ff       	call   80102c96 <kalloc>
80107d95:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107d98:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107d9c:	75 07                	jne    80107da5 <walkpgdir+0x56>
      return 0;
80107d9e:	b8 00 00 00 00       	mov    $0x0,%eax
80107da3:	eb 3e                	jmp    80107de3 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107da5:	83 ec 04             	sub    $0x4,%esp
80107da8:	68 00 10 00 00       	push   $0x1000
80107dad:	6a 00                	push   $0x0
80107daf:	ff 75 f4             	push   -0xc(%ebp)
80107db2:	e8 64 d7 ff ff       	call   8010551b <memset>
80107db7:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dbd:	05 00 00 00 80       	add    $0x80000000,%eax
80107dc2:	83 c8 07             	or     $0x7,%eax
80107dc5:	89 c2                	mov    %eax,%edx
80107dc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107dca:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107dcc:	8b 45 0c             	mov    0xc(%ebp),%eax
80107dcf:	c1 e8 0c             	shr    $0xc,%eax
80107dd2:	25 ff 03 00 00       	and    $0x3ff,%eax
80107dd7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107dde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de1:	01 d0                	add    %edx,%eax
}
80107de3:	c9                   	leave  
80107de4:	c3                   	ret    

80107de5 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107de5:	55                   	push   %ebp
80107de6:	89 e5                	mov    %esp,%ebp
80107de8:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107deb:	8b 45 0c             	mov    0xc(%ebp),%eax
80107dee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107df3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107df6:	8b 55 0c             	mov    0xc(%ebp),%edx
80107df9:	8b 45 10             	mov    0x10(%ebp),%eax
80107dfc:	01 d0                	add    %edx,%eax
80107dfe:	83 e8 01             	sub    $0x1,%eax
80107e01:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e06:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107e09:	83 ec 04             	sub    $0x4,%esp
80107e0c:	6a 01                	push   $0x1
80107e0e:	ff 75 f4             	push   -0xc(%ebp)
80107e11:	ff 75 08             	push   0x8(%ebp)
80107e14:	e8 36 ff ff ff       	call   80107d4f <walkpgdir>
80107e19:	83 c4 10             	add    $0x10,%esp
80107e1c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107e1f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107e23:	75 07                	jne    80107e2c <mappages+0x47>
      return -1;
80107e25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e2a:	eb 47                	jmp    80107e73 <mappages+0x8e>
    if(*pte & PTE_P)
80107e2c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e2f:	8b 00                	mov    (%eax),%eax
80107e31:	83 e0 01             	and    $0x1,%eax
80107e34:	85 c0                	test   %eax,%eax
80107e36:	74 0d                	je     80107e45 <mappages+0x60>
      panic("remap");
80107e38:	83 ec 0c             	sub    $0xc,%esp
80107e3b:	68 f4 8c 10 80       	push   $0x80108cf4
80107e40:	e8 70 87 ff ff       	call   801005b5 <panic>
    *pte = pa | perm | PTE_P;
80107e45:	8b 45 18             	mov    0x18(%ebp),%eax
80107e48:	0b 45 14             	or     0x14(%ebp),%eax
80107e4b:	83 c8 01             	or     $0x1,%eax
80107e4e:	89 c2                	mov    %eax,%edx
80107e50:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e53:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e58:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107e5b:	74 10                	je     80107e6d <mappages+0x88>
      break;
    a += PGSIZE;
80107e5d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107e64:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107e6b:	eb 9c                	jmp    80107e09 <mappages+0x24>
      break;
80107e6d:	90                   	nop
  }
  return 0;
80107e6e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107e73:	c9                   	leave  
80107e74:	c3                   	ret    

80107e75 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107e75:	55                   	push   %ebp
80107e76:	89 e5                	mov    %esp,%ebp
80107e78:	53                   	push   %ebx
80107e79:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107e7c:	e8 15 ae ff ff       	call   80102c96 <kalloc>
80107e81:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107e84:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107e88:	75 07                	jne    80107e91 <setupkvm+0x1c>
    return 0;
80107e8a:	b8 00 00 00 00       	mov    $0x0,%eax
80107e8f:	eb 78                	jmp    80107f09 <setupkvm+0x94>
  memset(pgdir, 0, PGSIZE);
80107e91:	83 ec 04             	sub    $0x4,%esp
80107e94:	68 00 10 00 00       	push   $0x1000
80107e99:	6a 00                	push   $0x0
80107e9b:	ff 75 f0             	push   -0x10(%ebp)
80107e9e:	e8 78 d6 ff ff       	call   8010551b <memset>
80107ea3:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107ea6:	c7 45 f4 80 b4 10 80 	movl   $0x8010b480,-0xc(%ebp)
80107ead:	eb 4e                	jmp    80107efd <setupkvm+0x88>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107eaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb2:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb8:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ebe:	8b 58 08             	mov    0x8(%eax),%ebx
80107ec1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec4:	8b 40 04             	mov    0x4(%eax),%eax
80107ec7:	29 c3                	sub    %eax,%ebx
80107ec9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ecc:	8b 00                	mov    (%eax),%eax
80107ece:	83 ec 0c             	sub    $0xc,%esp
80107ed1:	51                   	push   %ecx
80107ed2:	52                   	push   %edx
80107ed3:	53                   	push   %ebx
80107ed4:	50                   	push   %eax
80107ed5:	ff 75 f0             	push   -0x10(%ebp)
80107ed8:	e8 08 ff ff ff       	call   80107de5 <mappages>
80107edd:	83 c4 20             	add    $0x20,%esp
80107ee0:	85 c0                	test   %eax,%eax
80107ee2:	79 15                	jns    80107ef9 <setupkvm+0x84>
      freevm(pgdir);
80107ee4:	83 ec 0c             	sub    $0xc,%esp
80107ee7:	ff 75 f0             	push   -0x10(%ebp)
80107eea:	e8 f5 04 00 00       	call   801083e4 <freevm>
80107eef:	83 c4 10             	add    $0x10,%esp
      return 0;
80107ef2:	b8 00 00 00 00       	mov    $0x0,%eax
80107ef7:	eb 10                	jmp    80107f09 <setupkvm+0x94>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107ef9:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107efd:	81 7d f4 c0 b4 10 80 	cmpl   $0x8010b4c0,-0xc(%ebp)
80107f04:	72 a9                	jb     80107eaf <setupkvm+0x3a>
    }
  return pgdir;
80107f06:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107f09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107f0c:	c9                   	leave  
80107f0d:	c3                   	ret    

80107f0e <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107f0e:	55                   	push   %ebp
80107f0f:	89 e5                	mov    %esp,%ebp
80107f11:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107f14:	e8 5c ff ff ff       	call   80107e75 <setupkvm>
80107f19:	a3 dc 58 11 80       	mov    %eax,0x801158dc
  switchkvm();
80107f1e:	e8 03 00 00 00       	call   80107f26 <switchkvm>
}
80107f23:	90                   	nop
80107f24:	c9                   	leave  
80107f25:	c3                   	ret    

80107f26 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107f26:	55                   	push   %ebp
80107f27:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107f29:	a1 dc 58 11 80       	mov    0x801158dc,%eax
80107f2e:	05 00 00 00 80       	add    $0x80000000,%eax
80107f33:	50                   	push   %eax
80107f34:	e8 b4 fa ff ff       	call   801079ed <lcr3>
80107f39:	83 c4 04             	add    $0x4,%esp
}
80107f3c:	90                   	nop
80107f3d:	c9                   	leave  
80107f3e:	c3                   	ret    

80107f3f <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107f3f:	55                   	push   %ebp
80107f40:	89 e5                	mov    %esp,%ebp
80107f42:	56                   	push   %esi
80107f43:	53                   	push   %ebx
80107f44:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107f47:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107f4b:	75 0d                	jne    80107f5a <switchuvm+0x1b>
    panic("switchuvm: no process");
80107f4d:	83 ec 0c             	sub    $0xc,%esp
80107f50:	68 fa 8c 10 80       	push   $0x80108cfa
80107f55:	e8 5b 86 ff ff       	call   801005b5 <panic>
  if(p->kstack == 0)
80107f5a:	8b 45 08             	mov    0x8(%ebp),%eax
80107f5d:	8b 40 08             	mov    0x8(%eax),%eax
80107f60:	85 c0                	test   %eax,%eax
80107f62:	75 0d                	jne    80107f71 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107f64:	83 ec 0c             	sub    $0xc,%esp
80107f67:	68 10 8d 10 80       	push   $0x80108d10
80107f6c:	e8 44 86 ff ff       	call   801005b5 <panic>
  if(p->pgdir == 0)
80107f71:	8b 45 08             	mov    0x8(%ebp),%eax
80107f74:	8b 40 04             	mov    0x4(%eax),%eax
80107f77:	85 c0                	test   %eax,%eax
80107f79:	75 0d                	jne    80107f88 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107f7b:	83 ec 0c             	sub    $0xc,%esp
80107f7e:	68 25 8d 10 80       	push   $0x80108d25
80107f83:	e8 2d 86 ff ff       	call   801005b5 <panic>

  pushcli();
80107f88:	e8 83 d4 ff ff       	call   80105410 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107f8d:	e8 d0 c2 ff ff       	call   80104262 <mycpu>
80107f92:	89 c3                	mov    %eax,%ebx
80107f94:	e8 c9 c2 ff ff       	call   80104262 <mycpu>
80107f99:	83 c0 08             	add    $0x8,%eax
80107f9c:	89 c6                	mov    %eax,%esi
80107f9e:	e8 bf c2 ff ff       	call   80104262 <mycpu>
80107fa3:	83 c0 08             	add    $0x8,%eax
80107fa6:	c1 e8 10             	shr    $0x10,%eax
80107fa9:	88 45 f7             	mov    %al,-0x9(%ebp)
80107fac:	e8 b1 c2 ff ff       	call   80104262 <mycpu>
80107fb1:	83 c0 08             	add    $0x8,%eax
80107fb4:	c1 e8 18             	shr    $0x18,%eax
80107fb7:	89 c2                	mov    %eax,%edx
80107fb9:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107fc0:	67 00 
80107fc2:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107fc9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107fcd:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107fd3:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107fda:	83 e0 f0             	and    $0xfffffff0,%eax
80107fdd:	83 c8 09             	or     $0x9,%eax
80107fe0:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107fe6:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107fed:	83 c8 10             	or     $0x10,%eax
80107ff0:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107ff6:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107ffd:	83 e0 9f             	and    $0xffffff9f,%eax
80108000:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108006:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010800d:	83 c8 80             	or     $0xffffff80,%eax
80108010:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108016:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010801d:	83 e0 f0             	and    $0xfffffff0,%eax
80108020:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108026:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010802d:	83 e0 ef             	and    $0xffffffef,%eax
80108030:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108036:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010803d:	83 e0 df             	and    $0xffffffdf,%eax
80108040:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108046:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010804d:	83 c8 40             	or     $0x40,%eax
80108050:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108056:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010805d:	83 e0 7f             	and    $0x7f,%eax
80108060:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108066:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
8010806c:	e8 f1 c1 ff ff       	call   80104262 <mycpu>
80108071:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108078:	83 e2 ef             	and    $0xffffffef,%edx
8010807b:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80108081:	e8 dc c1 ff ff       	call   80104262 <mycpu>
80108086:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
8010808c:	8b 45 08             	mov    0x8(%ebp),%eax
8010808f:	8b 40 08             	mov    0x8(%eax),%eax
80108092:	89 c3                	mov    %eax,%ebx
80108094:	e8 c9 c1 ff ff       	call   80104262 <mycpu>
80108099:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
8010809f:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801080a2:	e8 bb c1 ff ff       	call   80104262 <mycpu>
801080a7:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
801080ad:	83 ec 0c             	sub    $0xc,%esp
801080b0:	6a 28                	push   $0x28
801080b2:	e8 1f f9 ff ff       	call   801079d6 <ltr>
801080b7:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
801080ba:	8b 45 08             	mov    0x8(%ebp),%eax
801080bd:	8b 40 04             	mov    0x4(%eax),%eax
801080c0:	05 00 00 00 80       	add    $0x80000000,%eax
801080c5:	83 ec 0c             	sub    $0xc,%esp
801080c8:	50                   	push   %eax
801080c9:	e8 1f f9 ff ff       	call   801079ed <lcr3>
801080ce:	83 c4 10             	add    $0x10,%esp
  popcli();
801080d1:	e8 87 d3 ff ff       	call   8010545d <popcli>
}
801080d6:	90                   	nop
801080d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
801080da:	5b                   	pop    %ebx
801080db:	5e                   	pop    %esi
801080dc:	5d                   	pop    %ebp
801080dd:	c3                   	ret    

801080de <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801080de:	55                   	push   %ebp
801080df:	89 e5                	mov    %esp,%ebp
801080e1:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
801080e4:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801080eb:	76 0d                	jbe    801080fa <inituvm+0x1c>
    panic("inituvm: more than a page");
801080ed:	83 ec 0c             	sub    $0xc,%esp
801080f0:	68 39 8d 10 80       	push   $0x80108d39
801080f5:	e8 bb 84 ff ff       	call   801005b5 <panic>
  mem = kalloc();
801080fa:	e8 97 ab ff ff       	call   80102c96 <kalloc>
801080ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108102:	83 ec 04             	sub    $0x4,%esp
80108105:	68 00 10 00 00       	push   $0x1000
8010810a:	6a 00                	push   $0x0
8010810c:	ff 75 f4             	push   -0xc(%ebp)
8010810f:	e8 07 d4 ff ff       	call   8010551b <memset>
80108114:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80108117:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010811a:	05 00 00 00 80       	add    $0x80000000,%eax
8010811f:	83 ec 0c             	sub    $0xc,%esp
80108122:	6a 06                	push   $0x6
80108124:	50                   	push   %eax
80108125:	68 00 10 00 00       	push   $0x1000
8010812a:	6a 00                	push   $0x0
8010812c:	ff 75 08             	push   0x8(%ebp)
8010812f:	e8 b1 fc ff ff       	call   80107de5 <mappages>
80108134:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108137:	83 ec 04             	sub    $0x4,%esp
8010813a:	ff 75 10             	push   0x10(%ebp)
8010813d:	ff 75 0c             	push   0xc(%ebp)
80108140:	ff 75 f4             	push   -0xc(%ebp)
80108143:	e8 92 d4 ff ff       	call   801055da <memmove>
80108148:	83 c4 10             	add    $0x10,%esp
}
8010814b:	90                   	nop
8010814c:	c9                   	leave  
8010814d:	c3                   	ret    

8010814e <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010814e:	55                   	push   %ebp
8010814f:	89 e5                	mov    %esp,%ebp
80108151:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108154:	8b 45 0c             	mov    0xc(%ebp),%eax
80108157:	25 ff 0f 00 00       	and    $0xfff,%eax
8010815c:	85 c0                	test   %eax,%eax
8010815e:	74 0d                	je     8010816d <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80108160:	83 ec 0c             	sub    $0xc,%esp
80108163:	68 54 8d 10 80       	push   $0x80108d54
80108168:	e8 48 84 ff ff       	call   801005b5 <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010816d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108174:	e9 8f 00 00 00       	jmp    80108208 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108179:	8b 55 0c             	mov    0xc(%ebp),%edx
8010817c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010817f:	01 d0                	add    %edx,%eax
80108181:	83 ec 04             	sub    $0x4,%esp
80108184:	6a 00                	push   $0x0
80108186:	50                   	push   %eax
80108187:	ff 75 08             	push   0x8(%ebp)
8010818a:	e8 c0 fb ff ff       	call   80107d4f <walkpgdir>
8010818f:	83 c4 10             	add    $0x10,%esp
80108192:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108195:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108199:	75 0d                	jne    801081a8 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
8010819b:	83 ec 0c             	sub    $0xc,%esp
8010819e:	68 77 8d 10 80       	push   $0x80108d77
801081a3:	e8 0d 84 ff ff       	call   801005b5 <panic>
    pa = PTE_ADDR(*pte);
801081a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081ab:	8b 00                	mov    (%eax),%eax
801081ad:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081b2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801081b5:	8b 45 18             	mov    0x18(%ebp),%eax
801081b8:	2b 45 f4             	sub    -0xc(%ebp),%eax
801081bb:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801081c0:	77 0b                	ja     801081cd <loaduvm+0x7f>
      n = sz - i;
801081c2:	8b 45 18             	mov    0x18(%ebp),%eax
801081c5:	2b 45 f4             	sub    -0xc(%ebp),%eax
801081c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801081cb:	eb 07                	jmp    801081d4 <loaduvm+0x86>
    else
      n = PGSIZE;
801081cd:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
801081d4:	8b 55 14             	mov    0x14(%ebp),%edx
801081d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081da:	01 d0                	add    %edx,%eax
801081dc:	8b 55 e8             	mov    -0x18(%ebp),%edx
801081df:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801081e5:	ff 75 f0             	push   -0x10(%ebp)
801081e8:	50                   	push   %eax
801081e9:	52                   	push   %edx
801081ea:	ff 75 10             	push   0x10(%ebp)
801081ed:	e8 14 9d ff ff       	call   80101f06 <readi>
801081f2:	83 c4 10             	add    $0x10,%esp
801081f5:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801081f8:	74 07                	je     80108201 <loaduvm+0xb3>
      return -1;
801081fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801081ff:	eb 18                	jmp    80108219 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80108201:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108208:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010820b:	3b 45 18             	cmp    0x18(%ebp),%eax
8010820e:	0f 82 65 ff ff ff    	jb     80108179 <loaduvm+0x2b>
  }
  return 0;
80108214:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108219:	c9                   	leave  
8010821a:	c3                   	ret    

8010821b <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010821b:	55                   	push   %ebp
8010821c:	89 e5                	mov    %esp,%ebp
8010821e:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108221:	8b 45 10             	mov    0x10(%ebp),%eax
80108224:	85 c0                	test   %eax,%eax
80108226:	79 0a                	jns    80108232 <allocuvm+0x17>
    return 0;
80108228:	b8 00 00 00 00       	mov    $0x0,%eax
8010822d:	e9 ec 00 00 00       	jmp    8010831e <allocuvm+0x103>
  if(newsz < oldsz)
80108232:	8b 45 10             	mov    0x10(%ebp),%eax
80108235:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108238:	73 08                	jae    80108242 <allocuvm+0x27>
    return oldsz;
8010823a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010823d:	e9 dc 00 00 00       	jmp    8010831e <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80108242:	8b 45 0c             	mov    0xc(%ebp),%eax
80108245:	05 ff 0f 00 00       	add    $0xfff,%eax
8010824a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010824f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108252:	e9 b8 00 00 00       	jmp    8010830f <allocuvm+0xf4>
    mem = kalloc();
80108257:	e8 3a aa ff ff       	call   80102c96 <kalloc>
8010825c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010825f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108263:	75 2e                	jne    80108293 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80108265:	83 ec 0c             	sub    $0xc,%esp
80108268:	68 95 8d 10 80       	push   $0x80108d95
8010826d:	e8 8e 81 ff ff       	call   80100400 <cprintf>
80108272:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108275:	83 ec 04             	sub    $0x4,%esp
80108278:	ff 75 0c             	push   0xc(%ebp)
8010827b:	ff 75 10             	push   0x10(%ebp)
8010827e:	ff 75 08             	push   0x8(%ebp)
80108281:	e8 9a 00 00 00       	call   80108320 <deallocuvm>
80108286:	83 c4 10             	add    $0x10,%esp
      return 0;
80108289:	b8 00 00 00 00       	mov    $0x0,%eax
8010828e:	e9 8b 00 00 00       	jmp    8010831e <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80108293:	83 ec 04             	sub    $0x4,%esp
80108296:	68 00 10 00 00       	push   $0x1000
8010829b:	6a 00                	push   $0x0
8010829d:	ff 75 f0             	push   -0x10(%ebp)
801082a0:	e8 76 d2 ff ff       	call   8010551b <memset>
801082a5:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801082a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082ab:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801082b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082b4:	83 ec 0c             	sub    $0xc,%esp
801082b7:	6a 06                	push   $0x6
801082b9:	52                   	push   %edx
801082ba:	68 00 10 00 00       	push   $0x1000
801082bf:	50                   	push   %eax
801082c0:	ff 75 08             	push   0x8(%ebp)
801082c3:	e8 1d fb ff ff       	call   80107de5 <mappages>
801082c8:	83 c4 20             	add    $0x20,%esp
801082cb:	85 c0                	test   %eax,%eax
801082cd:	79 39                	jns    80108308 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
801082cf:	83 ec 0c             	sub    $0xc,%esp
801082d2:	68 ad 8d 10 80       	push   $0x80108dad
801082d7:	e8 24 81 ff ff       	call   80100400 <cprintf>
801082dc:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801082df:	83 ec 04             	sub    $0x4,%esp
801082e2:	ff 75 0c             	push   0xc(%ebp)
801082e5:	ff 75 10             	push   0x10(%ebp)
801082e8:	ff 75 08             	push   0x8(%ebp)
801082eb:	e8 30 00 00 00       	call   80108320 <deallocuvm>
801082f0:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
801082f3:	83 ec 0c             	sub    $0xc,%esp
801082f6:	ff 75 f0             	push   -0x10(%ebp)
801082f9:	e8 fe a8 ff ff       	call   80102bfc <kfree>
801082fe:	83 c4 10             	add    $0x10,%esp
      return 0;
80108301:	b8 00 00 00 00       	mov    $0x0,%eax
80108306:	eb 16                	jmp    8010831e <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80108308:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010830f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108312:	3b 45 10             	cmp    0x10(%ebp),%eax
80108315:	0f 82 3c ff ff ff    	jb     80108257 <allocuvm+0x3c>
    }
  }
  return newsz;
8010831b:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010831e:	c9                   	leave  
8010831f:	c3                   	ret    

80108320 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108320:	55                   	push   %ebp
80108321:	89 e5                	mov    %esp,%ebp
80108323:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108326:	8b 45 10             	mov    0x10(%ebp),%eax
80108329:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010832c:	72 08                	jb     80108336 <deallocuvm+0x16>
    return oldsz;
8010832e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108331:	e9 ac 00 00 00       	jmp    801083e2 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80108336:	8b 45 10             	mov    0x10(%ebp),%eax
80108339:	05 ff 0f 00 00       	add    $0xfff,%eax
8010833e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108343:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108346:	e9 88 00 00 00       	jmp    801083d3 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010834b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010834e:	83 ec 04             	sub    $0x4,%esp
80108351:	6a 00                	push   $0x0
80108353:	50                   	push   %eax
80108354:	ff 75 08             	push   0x8(%ebp)
80108357:	e8 f3 f9 ff ff       	call   80107d4f <walkpgdir>
8010835c:	83 c4 10             	add    $0x10,%esp
8010835f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108362:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108366:	75 16                	jne    8010837e <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80108368:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010836b:	c1 e8 16             	shr    $0x16,%eax
8010836e:	83 c0 01             	add    $0x1,%eax
80108371:	c1 e0 16             	shl    $0x16,%eax
80108374:	2d 00 10 00 00       	sub    $0x1000,%eax
80108379:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010837c:	eb 4e                	jmp    801083cc <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
8010837e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108381:	8b 00                	mov    (%eax),%eax
80108383:	83 e0 01             	and    $0x1,%eax
80108386:	85 c0                	test   %eax,%eax
80108388:	74 42                	je     801083cc <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
8010838a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010838d:	8b 00                	mov    (%eax),%eax
8010838f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108394:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108397:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010839b:	75 0d                	jne    801083aa <deallocuvm+0x8a>
        panic("kfree");
8010839d:	83 ec 0c             	sub    $0xc,%esp
801083a0:	68 c9 8d 10 80       	push   $0x80108dc9
801083a5:	e8 0b 82 ff ff       	call   801005b5 <panic>
      char *v = P2V(pa);
801083aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083ad:	05 00 00 00 80       	add    $0x80000000,%eax
801083b2:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801083b5:	83 ec 0c             	sub    $0xc,%esp
801083b8:	ff 75 e8             	push   -0x18(%ebp)
801083bb:	e8 3c a8 ff ff       	call   80102bfc <kfree>
801083c0:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801083c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083c6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
801083cc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801083d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083d6:	3b 45 0c             	cmp    0xc(%ebp),%eax
801083d9:	0f 82 6c ff ff ff    	jb     8010834b <deallocuvm+0x2b>
    }
  }
  return newsz;
801083df:	8b 45 10             	mov    0x10(%ebp),%eax
}
801083e2:	c9                   	leave  
801083e3:	c3                   	ret    

801083e4 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801083e4:	55                   	push   %ebp
801083e5:	89 e5                	mov    %esp,%ebp
801083e7:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801083ea:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801083ee:	75 0d                	jne    801083fd <freevm+0x19>
    panic("freevm: no pgdir");
801083f0:	83 ec 0c             	sub    $0xc,%esp
801083f3:	68 cf 8d 10 80       	push   $0x80108dcf
801083f8:	e8 b8 81 ff ff       	call   801005b5 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801083fd:	83 ec 04             	sub    $0x4,%esp
80108400:	6a 00                	push   $0x0
80108402:	68 00 00 00 80       	push   $0x80000000
80108407:	ff 75 08             	push   0x8(%ebp)
8010840a:	e8 11 ff ff ff       	call   80108320 <deallocuvm>
8010840f:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108412:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108419:	eb 48                	jmp    80108463 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
8010841b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010841e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108425:	8b 45 08             	mov    0x8(%ebp),%eax
80108428:	01 d0                	add    %edx,%eax
8010842a:	8b 00                	mov    (%eax),%eax
8010842c:	83 e0 01             	and    $0x1,%eax
8010842f:	85 c0                	test   %eax,%eax
80108431:	74 2c                	je     8010845f <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108433:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108436:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010843d:	8b 45 08             	mov    0x8(%ebp),%eax
80108440:	01 d0                	add    %edx,%eax
80108442:	8b 00                	mov    (%eax),%eax
80108444:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108449:	05 00 00 00 80       	add    $0x80000000,%eax
8010844e:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108451:	83 ec 0c             	sub    $0xc,%esp
80108454:	ff 75 f0             	push   -0x10(%ebp)
80108457:	e8 a0 a7 ff ff       	call   80102bfc <kfree>
8010845c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010845f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108463:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010846a:	76 af                	jbe    8010841b <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
8010846c:	83 ec 0c             	sub    $0xc,%esp
8010846f:	ff 75 08             	push   0x8(%ebp)
80108472:	e8 85 a7 ff ff       	call   80102bfc <kfree>
80108477:	83 c4 10             	add    $0x10,%esp
}
8010847a:	90                   	nop
8010847b:	c9                   	leave  
8010847c:	c3                   	ret    

8010847d <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010847d:	55                   	push   %ebp
8010847e:	89 e5                	mov    %esp,%ebp
80108480:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108483:	83 ec 04             	sub    $0x4,%esp
80108486:	6a 00                	push   $0x0
80108488:	ff 75 0c             	push   0xc(%ebp)
8010848b:	ff 75 08             	push   0x8(%ebp)
8010848e:	e8 bc f8 ff ff       	call   80107d4f <walkpgdir>
80108493:	83 c4 10             	add    $0x10,%esp
80108496:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108499:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010849d:	75 0d                	jne    801084ac <clearpteu+0x2f>
    panic("clearpteu");
8010849f:	83 ec 0c             	sub    $0xc,%esp
801084a2:	68 e0 8d 10 80       	push   $0x80108de0
801084a7:	e8 09 81 ff ff       	call   801005b5 <panic>
  *pte &= ~PTE_U;
801084ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084af:	8b 00                	mov    (%eax),%eax
801084b1:	83 e0 fb             	and    $0xfffffffb,%eax
801084b4:	89 c2                	mov    %eax,%edx
801084b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084b9:	89 10                	mov    %edx,(%eax)
}
801084bb:	90                   	nop
801084bc:	c9                   	leave  
801084bd:	c3                   	ret    

801084be <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801084be:	55                   	push   %ebp
801084bf:	89 e5                	mov    %esp,%ebp
801084c1:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801084c4:	e8 ac f9 ff ff       	call   80107e75 <setupkvm>
801084c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801084cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801084d0:	75 0a                	jne    801084dc <copyuvm+0x1e>
    return 0;
801084d2:	b8 00 00 00 00       	mov    $0x0,%eax
801084d7:	e9 f8 00 00 00       	jmp    801085d4 <copyuvm+0x116>
  for(i = 0; i < sz; i += PGSIZE){
801084dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801084e3:	e9 c7 00 00 00       	jmp    801085af <copyuvm+0xf1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801084e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084eb:	83 ec 04             	sub    $0x4,%esp
801084ee:	6a 00                	push   $0x0
801084f0:	50                   	push   %eax
801084f1:	ff 75 08             	push   0x8(%ebp)
801084f4:	e8 56 f8 ff ff       	call   80107d4f <walkpgdir>
801084f9:	83 c4 10             	add    $0x10,%esp
801084fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
801084ff:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108503:	75 0d                	jne    80108512 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
80108505:	83 ec 0c             	sub    $0xc,%esp
80108508:	68 ea 8d 10 80       	push   $0x80108dea
8010850d:	e8 a3 80 ff ff       	call   801005b5 <panic>
    if(!(*pte & PTE_P))
80108512:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108515:	8b 00                	mov    (%eax),%eax
80108517:	83 e0 01             	and    $0x1,%eax
8010851a:	85 c0                	test   %eax,%eax
8010851c:	75 0d                	jne    8010852b <copyuvm+0x6d>
      panic("copyuvm: page not present");
8010851e:	83 ec 0c             	sub    $0xc,%esp
80108521:	68 04 8e 10 80       	push   $0x80108e04
80108526:	e8 8a 80 ff ff       	call   801005b5 <panic>
    pa = PTE_ADDR(*pte);
8010852b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010852e:	8b 00                	mov    (%eax),%eax
80108530:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108535:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108538:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010853b:	8b 00                	mov    (%eax),%eax
8010853d:	25 ff 0f 00 00       	and    $0xfff,%eax
80108542:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108545:	e8 4c a7 ff ff       	call   80102c96 <kalloc>
8010854a:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010854d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108551:	74 6d                	je     801085c0 <copyuvm+0x102>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108553:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108556:	05 00 00 00 80       	add    $0x80000000,%eax
8010855b:	83 ec 04             	sub    $0x4,%esp
8010855e:	68 00 10 00 00       	push   $0x1000
80108563:	50                   	push   %eax
80108564:	ff 75 e0             	push   -0x20(%ebp)
80108567:	e8 6e d0 ff ff       	call   801055da <memmove>
8010856c:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
8010856f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108572:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108575:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
8010857b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010857e:	83 ec 0c             	sub    $0xc,%esp
80108581:	52                   	push   %edx
80108582:	51                   	push   %ecx
80108583:	68 00 10 00 00       	push   $0x1000
80108588:	50                   	push   %eax
80108589:	ff 75 f0             	push   -0x10(%ebp)
8010858c:	e8 54 f8 ff ff       	call   80107de5 <mappages>
80108591:	83 c4 20             	add    $0x20,%esp
80108594:	85 c0                	test   %eax,%eax
80108596:	79 10                	jns    801085a8 <copyuvm+0xea>
      kfree(mem);
80108598:	83 ec 0c             	sub    $0xc,%esp
8010859b:	ff 75 e0             	push   -0x20(%ebp)
8010859e:	e8 59 a6 ff ff       	call   80102bfc <kfree>
801085a3:	83 c4 10             	add    $0x10,%esp
      goto bad;
801085a6:	eb 19                	jmp    801085c1 <copyuvm+0x103>
  for(i = 0; i < sz; i += PGSIZE){
801085a8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801085af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b2:	3b 45 0c             	cmp    0xc(%ebp),%eax
801085b5:	0f 82 2d ff ff ff    	jb     801084e8 <copyuvm+0x2a>
    }
  }
  return d;
801085bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085be:	eb 14                	jmp    801085d4 <copyuvm+0x116>
      goto bad;
801085c0:	90                   	nop

bad:
  freevm(d);
801085c1:	83 ec 0c             	sub    $0xc,%esp
801085c4:	ff 75 f0             	push   -0x10(%ebp)
801085c7:	e8 18 fe ff ff       	call   801083e4 <freevm>
801085cc:	83 c4 10             	add    $0x10,%esp
  return 0;
801085cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
801085d4:	c9                   	leave  
801085d5:	c3                   	ret    

801085d6 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801085d6:	55                   	push   %ebp
801085d7:	89 e5                	mov    %esp,%ebp
801085d9:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801085dc:	83 ec 04             	sub    $0x4,%esp
801085df:	6a 00                	push   $0x0
801085e1:	ff 75 0c             	push   0xc(%ebp)
801085e4:	ff 75 08             	push   0x8(%ebp)
801085e7:	e8 63 f7 ff ff       	call   80107d4f <walkpgdir>
801085ec:	83 c4 10             	add    $0x10,%esp
801085ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801085f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f5:	8b 00                	mov    (%eax),%eax
801085f7:	83 e0 01             	and    $0x1,%eax
801085fa:	85 c0                	test   %eax,%eax
801085fc:	75 07                	jne    80108605 <uva2ka+0x2f>
    return 0;
801085fe:	b8 00 00 00 00       	mov    $0x0,%eax
80108603:	eb 22                	jmp    80108627 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80108605:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108608:	8b 00                	mov    (%eax),%eax
8010860a:	83 e0 04             	and    $0x4,%eax
8010860d:	85 c0                	test   %eax,%eax
8010860f:	75 07                	jne    80108618 <uva2ka+0x42>
    return 0;
80108611:	b8 00 00 00 00       	mov    $0x0,%eax
80108616:	eb 0f                	jmp    80108627 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80108618:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010861b:	8b 00                	mov    (%eax),%eax
8010861d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108622:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108627:	c9                   	leave  
80108628:	c3                   	ret    

80108629 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108629:	55                   	push   %ebp
8010862a:	89 e5                	mov    %esp,%ebp
8010862c:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010862f:	8b 45 10             	mov    0x10(%ebp),%eax
80108632:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108635:	eb 7f                	jmp    801086b6 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80108637:	8b 45 0c             	mov    0xc(%ebp),%eax
8010863a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010863f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108642:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108645:	83 ec 08             	sub    $0x8,%esp
80108648:	50                   	push   %eax
80108649:	ff 75 08             	push   0x8(%ebp)
8010864c:	e8 85 ff ff ff       	call   801085d6 <uva2ka>
80108651:	83 c4 10             	add    $0x10,%esp
80108654:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108657:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010865b:	75 07                	jne    80108664 <copyout+0x3b>
      return -1;
8010865d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108662:	eb 61                	jmp    801086c5 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80108664:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108667:	2b 45 0c             	sub    0xc(%ebp),%eax
8010866a:	05 00 10 00 00       	add    $0x1000,%eax
8010866f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108672:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108675:	3b 45 14             	cmp    0x14(%ebp),%eax
80108678:	76 06                	jbe    80108680 <copyout+0x57>
      n = len;
8010867a:	8b 45 14             	mov    0x14(%ebp),%eax
8010867d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108680:	8b 45 0c             	mov    0xc(%ebp),%eax
80108683:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108686:	89 c2                	mov    %eax,%edx
80108688:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010868b:	01 d0                	add    %edx,%eax
8010868d:	83 ec 04             	sub    $0x4,%esp
80108690:	ff 75 f0             	push   -0x10(%ebp)
80108693:	ff 75 f4             	push   -0xc(%ebp)
80108696:	50                   	push   %eax
80108697:	e8 3e cf ff ff       	call   801055da <memmove>
8010869c:	83 c4 10             	add    $0x10,%esp
    len -= n;
8010869f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086a2:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801086a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086a8:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801086ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086ae:	05 00 10 00 00       	add    $0x1000,%eax
801086b3:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
801086b6:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801086ba:	0f 85 77 ff ff ff    	jne    80108637 <copyout+0xe>
  }
  return 0;
801086c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801086c5:	c9                   	leave  
801086c6:	c3                   	ret    
