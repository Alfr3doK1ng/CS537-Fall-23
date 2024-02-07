
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
80100015:	b8 00 90 10 00       	mov    $0x109000,%eax
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
80100028:	bc 10 55 11 80       	mov    $0x80115510,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 80 31 10 80       	mov    $0x80103180,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax
80100034:	66 90                	xchg   %ax,%ax
80100036:	66 90                	xchg   %ax,%ax
80100038:	66 90                	xchg   %ax,%ax
8010003a:	66 90                	xchg   %ax,%ax
8010003c:	66 90                	xchg   %ax,%ax
8010003e:	66 90                	xchg   %ax,%ax

80100040 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100040:	55                   	push   %ebp
80100041:	89 e5                	mov    %esp,%ebp
80100043:	53                   	push   %ebx

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100044:	bb 94 a5 10 80       	mov    $0x8010a594,%ebx
{
80100049:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
8010004c:	68 00 73 10 80       	push   $0x80107300
80100051:	68 60 a5 10 80       	push   $0x8010a560
80100056:	e8 95 44 00 00       	call   801044f0 <initlock>
  bcache.head.next = &bcache.head;
8010005b:	83 c4 10             	add    $0x10,%esp
8010005e:	b8 5c ec 10 80       	mov    $0x8010ec5c,%eax
  bcache.head.prev = &bcache.head;
80100063:	c7 05 ac ec 10 80 5c 	movl   $0x8010ec5c,0x8010ecac
8010006a:	ec 10 80 
  bcache.head.next = &bcache.head;
8010006d:	c7 05 b0 ec 10 80 5c 	movl   $0x8010ec5c,0x8010ecb0
80100074:	ec 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100077:	eb 09                	jmp    80100082 <binit+0x42>
80100079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100080:	89 d3                	mov    %edx,%ebx
    b->next = bcache.head.next;
80100082:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
    initsleeplock(&b->lock, "buffer");
80100085:	83 ec 08             	sub    $0x8,%esp
80100088:	8d 43 0c             	lea    0xc(%ebx),%eax
    b->prev = &bcache.head;
8010008b:	c7 43 50 5c ec 10 80 	movl   $0x8010ec5c,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
80100092:	68 07 73 10 80       	push   $0x80107307
80100097:	50                   	push   %eax
80100098:	e8 23 43 00 00       	call   801043c0 <initsleeplock>
    bcache.head.next->prev = b;
8010009d:	a1 b0 ec 10 80       	mov    0x8010ecb0,%eax
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000a2:	8d 93 5c 02 00 00    	lea    0x25c(%ebx),%edx
801000a8:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000ab:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
801000ae:	89 d8                	mov    %ebx,%eax
801000b0:	89 1d b0 ec 10 80    	mov    %ebx,0x8010ecb0
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000b6:	81 fb 00 ea 10 80    	cmp    $0x8010ea00,%ebx
801000bc:	75 c2                	jne    80100080 <binit+0x40>
  }
}
801000be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801000c1:	c9                   	leave  
801000c2:	c3                   	ret    
801000c3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801000ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801000d0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801000d0:	55                   	push   %ebp
801000d1:	89 e5                	mov    %esp,%ebp
801000d3:	57                   	push   %edi
801000d4:	56                   	push   %esi
801000d5:	53                   	push   %ebx
801000d6:	83 ec 18             	sub    $0x18,%esp
801000d9:	8b 75 08             	mov    0x8(%ebp),%esi
801000dc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  acquire(&bcache.lock);
801000df:	68 60 a5 10 80       	push   $0x8010a560
801000e4:	e8 d7 45 00 00       	call   801046c0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000e9:	8b 1d b0 ec 10 80    	mov    0x8010ecb0,%ebx
801000ef:	83 c4 10             	add    $0x10,%esp
801000f2:	81 fb 5c ec 10 80    	cmp    $0x8010ec5c,%ebx
801000f8:	75 11                	jne    8010010b <bread+0x3b>
801000fa:	eb 24                	jmp    80100120 <bread+0x50>
801000fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100100:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100103:	81 fb 5c ec 10 80    	cmp    $0x8010ec5c,%ebx
80100109:	74 15                	je     80100120 <bread+0x50>
    if(b->dev == dev && b->blockno == blockno){
8010010b:	3b 73 04             	cmp    0x4(%ebx),%esi
8010010e:	75 f0                	jne    80100100 <bread+0x30>
80100110:	3b 7b 08             	cmp    0x8(%ebx),%edi
80100113:	75 eb                	jne    80100100 <bread+0x30>
      b->refcnt++;
80100115:	83 43 4c 01          	addl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
80100119:	eb 3f                	jmp    8010015a <bread+0x8a>
8010011b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010011f:	90                   	nop
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100120:	8b 1d ac ec 10 80    	mov    0x8010ecac,%ebx
80100126:	81 fb 5c ec 10 80    	cmp    $0x8010ec5c,%ebx
8010012c:	75 0d                	jne    8010013b <bread+0x6b>
8010012e:	eb 6e                	jmp    8010019e <bread+0xce>
80100130:	8b 5b 50             	mov    0x50(%ebx),%ebx
80100133:	81 fb 5c ec 10 80    	cmp    $0x8010ec5c,%ebx
80100139:	74 63                	je     8010019e <bread+0xce>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010013b:	8b 43 4c             	mov    0x4c(%ebx),%eax
8010013e:	85 c0                	test   %eax,%eax
80100140:	75 ee                	jne    80100130 <bread+0x60>
80100142:	f6 03 04             	testb  $0x4,(%ebx)
80100145:	75 e9                	jne    80100130 <bread+0x60>
      b->dev = dev;
80100147:	89 73 04             	mov    %esi,0x4(%ebx)
      b->blockno = blockno;
8010014a:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = 0;
8010014d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
      b->refcnt = 1;
80100153:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
8010015a:	83 ec 0c             	sub    $0xc,%esp
8010015d:	68 60 a5 10 80       	push   $0x8010a560
80100162:	e8 f9 44 00 00       	call   80104660 <release>
      acquiresleep(&b->lock);
80100167:	8d 43 0c             	lea    0xc(%ebx),%eax
8010016a:	89 04 24             	mov    %eax,(%esp)
8010016d:	e8 8e 42 00 00       	call   80104400 <acquiresleep>
      return b;
80100172:	83 c4 10             	add    $0x10,%esp
  struct buf *b;

  b = bget(dev, blockno);
  if((b->flags & B_VALID) == 0) {
80100175:	f6 03 02             	testb  $0x2,(%ebx)
80100178:	74 0e                	je     80100188 <bread+0xb8>
    iderw(b);
  }
  return b;
}
8010017a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010017d:	89 d8                	mov    %ebx,%eax
8010017f:	5b                   	pop    %ebx
80100180:	5e                   	pop    %esi
80100181:	5f                   	pop    %edi
80100182:	5d                   	pop    %ebp
80100183:	c3                   	ret    
80100184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    iderw(b);
80100188:	83 ec 0c             	sub    $0xc,%esp
8010018b:	53                   	push   %ebx
8010018c:	e8 6f 22 00 00       	call   80102400 <iderw>
80100191:	83 c4 10             	add    $0x10,%esp
}
80100194:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100197:	89 d8                	mov    %ebx,%eax
80100199:	5b                   	pop    %ebx
8010019a:	5e                   	pop    %esi
8010019b:	5f                   	pop    %edi
8010019c:	5d                   	pop    %ebp
8010019d:	c3                   	ret    
  panic("bget: no buffers");
8010019e:	83 ec 0c             	sub    $0xc,%esp
801001a1:	68 0e 73 10 80       	push   $0x8010730e
801001a6:	e8 d5 01 00 00       	call   80100380 <panic>
801001ab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801001af:	90                   	nop

801001b0 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
801001b0:	55                   	push   %ebp
801001b1:	89 e5                	mov    %esp,%ebp
801001b3:	53                   	push   %ebx
801001b4:	83 ec 10             	sub    $0x10,%esp
801001b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001ba:	8d 43 0c             	lea    0xc(%ebx),%eax
801001bd:	50                   	push   %eax
801001be:	e8 dd 42 00 00       	call   801044a0 <holdingsleep>
801001c3:	83 c4 10             	add    $0x10,%esp
801001c6:	85 c0                	test   %eax,%eax
801001c8:	74 0f                	je     801001d9 <bwrite+0x29>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001ca:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801001cd:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
801001d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001d3:	c9                   	leave  
  iderw(b);
801001d4:	e9 27 22 00 00       	jmp    80102400 <iderw>
    panic("bwrite");
801001d9:	83 ec 0c             	sub    $0xc,%esp
801001dc:	68 1f 73 10 80       	push   $0x8010731f
801001e1:	e8 9a 01 00 00       	call   80100380 <panic>
801001e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801001ed:	8d 76 00             	lea    0x0(%esi),%esi

801001f0 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
801001f0:	55                   	push   %ebp
801001f1:	89 e5                	mov    %esp,%ebp
801001f3:	56                   	push   %esi
801001f4:	53                   	push   %ebx
801001f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001f8:	8d 73 0c             	lea    0xc(%ebx),%esi
801001fb:	83 ec 0c             	sub    $0xc,%esp
801001fe:	56                   	push   %esi
801001ff:	e8 9c 42 00 00       	call   801044a0 <holdingsleep>
80100204:	83 c4 10             	add    $0x10,%esp
80100207:	85 c0                	test   %eax,%eax
80100209:	74 66                	je     80100271 <brelse+0x81>
    panic("brelse");

  releasesleep(&b->lock);
8010020b:	83 ec 0c             	sub    $0xc,%esp
8010020e:	56                   	push   %esi
8010020f:	e8 4c 42 00 00       	call   80104460 <releasesleep>

  acquire(&bcache.lock);
80100214:	c7 04 24 60 a5 10 80 	movl   $0x8010a560,(%esp)
8010021b:	e8 a0 44 00 00       	call   801046c0 <acquire>
  b->refcnt--;
80100220:	8b 43 4c             	mov    0x4c(%ebx),%eax
  if (b->refcnt == 0) {
80100223:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
80100226:	83 e8 01             	sub    $0x1,%eax
80100229:	89 43 4c             	mov    %eax,0x4c(%ebx)
  if (b->refcnt == 0) {
8010022c:	85 c0                	test   %eax,%eax
8010022e:	75 2f                	jne    8010025f <brelse+0x6f>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100230:	8b 43 54             	mov    0x54(%ebx),%eax
80100233:	8b 53 50             	mov    0x50(%ebx),%edx
80100236:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
80100239:	8b 43 50             	mov    0x50(%ebx),%eax
8010023c:	8b 53 54             	mov    0x54(%ebx),%edx
8010023f:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100242:	a1 b0 ec 10 80       	mov    0x8010ecb0,%eax
    b->prev = &bcache.head;
80100247:	c7 43 50 5c ec 10 80 	movl   $0x8010ec5c,0x50(%ebx)
    b->next = bcache.head.next;
8010024e:	89 43 54             	mov    %eax,0x54(%ebx)
    bcache.head.next->prev = b;
80100251:	a1 b0 ec 10 80       	mov    0x8010ecb0,%eax
80100256:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100259:	89 1d b0 ec 10 80    	mov    %ebx,0x8010ecb0
  }
  
  release(&bcache.lock);
8010025f:	c7 45 08 60 a5 10 80 	movl   $0x8010a560,0x8(%ebp)
}
80100266:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100269:	5b                   	pop    %ebx
8010026a:	5e                   	pop    %esi
8010026b:	5d                   	pop    %ebp
  release(&bcache.lock);
8010026c:	e9 ef 43 00 00       	jmp    80104660 <release>
    panic("brelse");
80100271:	83 ec 0c             	sub    $0xc,%esp
80100274:	68 26 73 10 80       	push   $0x80107326
80100279:	e8 02 01 00 00       	call   80100380 <panic>
8010027e:	66 90                	xchg   %ax,%ax

80100280 <consoleread>:
  }
}

int
consoleread(struct inode *ip, char *dst, int n)
{
80100280:	55                   	push   %ebp
80100281:	89 e5                	mov    %esp,%ebp
80100283:	57                   	push   %edi
80100284:	56                   	push   %esi
80100285:	53                   	push   %ebx
80100286:	83 ec 18             	sub    $0x18,%esp
80100289:	8b 5d 10             	mov    0x10(%ebp),%ebx
8010028c:	8b 75 0c             	mov    0xc(%ebp),%esi
  uint target;
  int c;

  iunlock(ip);
8010028f:	ff 75 08             	push   0x8(%ebp)
  target = n;
80100292:	89 df                	mov    %ebx,%edi
  iunlock(ip);
80100294:	e8 e7 16 00 00       	call   80101980 <iunlock>
  acquire(&cons.lock);
80100299:	c7 04 24 60 ef 10 80 	movl   $0x8010ef60,(%esp)
801002a0:	e8 1b 44 00 00       	call   801046c0 <acquire>
  while(n > 0){
801002a5:	83 c4 10             	add    $0x10,%esp
801002a8:	85 db                	test   %ebx,%ebx
801002aa:	0f 8e 94 00 00 00    	jle    80100344 <consoleread+0xc4>
    while(input.r == input.w){
801002b0:	a1 40 ef 10 80       	mov    0x8010ef40,%eax
801002b5:	3b 05 44 ef 10 80    	cmp    0x8010ef44,%eax
801002bb:	74 25                	je     801002e2 <consoleread+0x62>
801002bd:	eb 59                	jmp    80100318 <consoleread+0x98>
801002bf:	90                   	nop
      if(myproc()->killed){
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
801002c0:	83 ec 08             	sub    $0x8,%esp
801002c3:	68 60 ef 10 80       	push   $0x8010ef60
801002c8:	68 40 ef 10 80       	push   $0x8010ef40
801002cd:	e8 8e 3e 00 00       	call   80104160 <sleep>
    while(input.r == input.w){
801002d2:	a1 40 ef 10 80       	mov    0x8010ef40,%eax
801002d7:	83 c4 10             	add    $0x10,%esp
801002da:	3b 05 44 ef 10 80    	cmp    0x8010ef44,%eax
801002e0:	75 36                	jne    80100318 <consoleread+0x98>
      if(myproc()->killed){
801002e2:	e8 a9 37 00 00       	call   80103a90 <myproc>
801002e7:	8b 48 24             	mov    0x24(%eax),%ecx
801002ea:	85 c9                	test   %ecx,%ecx
801002ec:	74 d2                	je     801002c0 <consoleread+0x40>
        release(&cons.lock);
801002ee:	83 ec 0c             	sub    $0xc,%esp
801002f1:	68 60 ef 10 80       	push   $0x8010ef60
801002f6:	e8 65 43 00 00       	call   80104660 <release>
        ilock(ip);
801002fb:	5a                   	pop    %edx
801002fc:	ff 75 08             	push   0x8(%ebp)
801002ff:	e8 9c 15 00 00       	call   801018a0 <ilock>
        return -1;
80100304:	83 c4 10             	add    $0x10,%esp
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
80100307:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return -1;
8010030a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010030f:	5b                   	pop    %ebx
80100310:	5e                   	pop    %esi
80100311:	5f                   	pop    %edi
80100312:	5d                   	pop    %ebp
80100313:	c3                   	ret    
80100314:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    c = input.buf[input.r++ % INPUT_BUF];
80100318:	8d 50 01             	lea    0x1(%eax),%edx
8010031b:	89 15 40 ef 10 80    	mov    %edx,0x8010ef40
80100321:	89 c2                	mov    %eax,%edx
80100323:	83 e2 7f             	and    $0x7f,%edx
80100326:	0f be 8a c0 ee 10 80 	movsbl -0x7fef1140(%edx),%ecx
    if(c == C('D')){  // EOF
8010032d:	80 f9 04             	cmp    $0x4,%cl
80100330:	74 37                	je     80100369 <consoleread+0xe9>
    *dst++ = c;
80100332:	83 c6 01             	add    $0x1,%esi
    --n;
80100335:	83 eb 01             	sub    $0x1,%ebx
    *dst++ = c;
80100338:	88 4e ff             	mov    %cl,-0x1(%esi)
    if(c == '\n')
8010033b:	83 f9 0a             	cmp    $0xa,%ecx
8010033e:	0f 85 64 ff ff ff    	jne    801002a8 <consoleread+0x28>
  release(&cons.lock);
80100344:	83 ec 0c             	sub    $0xc,%esp
80100347:	68 60 ef 10 80       	push   $0x8010ef60
8010034c:	e8 0f 43 00 00       	call   80104660 <release>
  ilock(ip);
80100351:	58                   	pop    %eax
80100352:	ff 75 08             	push   0x8(%ebp)
80100355:	e8 46 15 00 00       	call   801018a0 <ilock>
  return target - n;
8010035a:	89 f8                	mov    %edi,%eax
8010035c:	83 c4 10             	add    $0x10,%esp
}
8010035f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return target - n;
80100362:	29 d8                	sub    %ebx,%eax
}
80100364:	5b                   	pop    %ebx
80100365:	5e                   	pop    %esi
80100366:	5f                   	pop    %edi
80100367:	5d                   	pop    %ebp
80100368:	c3                   	ret    
      if(n < target){
80100369:	39 fb                	cmp    %edi,%ebx
8010036b:	73 d7                	jae    80100344 <consoleread+0xc4>
        input.r--;
8010036d:	a3 40 ef 10 80       	mov    %eax,0x8010ef40
80100372:	eb d0                	jmp    80100344 <consoleread+0xc4>
80100374:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010037b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010037f:	90                   	nop

80100380 <panic>:
{
80100380:	55                   	push   %ebp
80100381:	89 e5                	mov    %esp,%ebp
80100383:	56                   	push   %esi
80100384:	53                   	push   %ebx
80100385:	83 ec 30             	sub    $0x30,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
80100388:	fa                   	cli    
  cons.locking = 0;
80100389:	c7 05 94 ef 10 80 00 	movl   $0x0,0x8010ef94
80100390:	00 00 00 
  getcallerpcs(&s, pcs);
80100393:	8d 5d d0             	lea    -0x30(%ebp),%ebx
80100396:	8d 75 f8             	lea    -0x8(%ebp),%esi
  cprintf("lapicid %d: panic: ", lapicid());
80100399:	e8 72 26 00 00       	call   80102a10 <lapicid>
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	50                   	push   %eax
801003a2:	68 2d 73 10 80       	push   $0x8010732d
801003a7:	e8 f4 02 00 00       	call   801006a0 <cprintf>
  cprintf(s);
801003ac:	58                   	pop    %eax
801003ad:	ff 75 08             	push   0x8(%ebp)
801003b0:	e8 eb 02 00 00       	call   801006a0 <cprintf>
  cprintf("\n");
801003b5:	c7 04 24 5b 7c 10 80 	movl   $0x80107c5b,(%esp)
801003bc:	e8 df 02 00 00       	call   801006a0 <cprintf>
  getcallerpcs(&s, pcs);
801003c1:	8d 45 08             	lea    0x8(%ebp),%eax
801003c4:	5a                   	pop    %edx
801003c5:	59                   	pop    %ecx
801003c6:	53                   	push   %ebx
801003c7:	50                   	push   %eax
801003c8:	e8 43 41 00 00       	call   80104510 <getcallerpcs>
  for(i=0; i<10; i++)
801003cd:	83 c4 10             	add    $0x10,%esp
    cprintf(" %p", pcs[i]);
801003d0:	83 ec 08             	sub    $0x8,%esp
801003d3:	ff 33                	push   (%ebx)
  for(i=0; i<10; i++)
801003d5:	83 c3 04             	add    $0x4,%ebx
    cprintf(" %p", pcs[i]);
801003d8:	68 41 73 10 80       	push   $0x80107341
801003dd:	e8 be 02 00 00       	call   801006a0 <cprintf>
  for(i=0; i<10; i++)
801003e2:	83 c4 10             	add    $0x10,%esp
801003e5:	39 f3                	cmp    %esi,%ebx
801003e7:	75 e7                	jne    801003d0 <panic+0x50>
  panicked = 1; // freeze other CPU
801003e9:	c7 05 98 ef 10 80 01 	movl   $0x1,0x8010ef98
801003f0:	00 00 00 
  for(;;)
801003f3:	eb fe                	jmp    801003f3 <panic+0x73>
801003f5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801003fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80100400 <consputc.part.0>:
consputc(int c)
80100400:	55                   	push   %ebp
80100401:	89 e5                	mov    %esp,%ebp
80100403:	57                   	push   %edi
80100404:	56                   	push   %esi
80100405:	53                   	push   %ebx
80100406:	89 c3                	mov    %eax,%ebx
80100408:	83 ec 1c             	sub    $0x1c,%esp
  if(c == BACKSPACE){
8010040b:	3d 00 01 00 00       	cmp    $0x100,%eax
80100410:	0f 84 ea 00 00 00    	je     80100500 <consputc.part.0+0x100>
    uartputc(c);
80100416:	83 ec 0c             	sub    $0xc,%esp
80100419:	50                   	push   %eax
8010041a:	e8 01 5a 00 00       	call   80105e20 <uartputc>
8010041f:	83 c4 10             	add    $0x10,%esp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100422:	bf d4 03 00 00       	mov    $0x3d4,%edi
80100427:	b8 0e 00 00 00       	mov    $0xe,%eax
8010042c:	89 fa                	mov    %edi,%edx
8010042e:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010042f:	be d5 03 00 00       	mov    $0x3d5,%esi
80100434:	89 f2                	mov    %esi,%edx
80100436:	ec                   	in     (%dx),%al
  pos = inb(CRTPORT+1) << 8;
80100437:	0f b6 c8             	movzbl %al,%ecx
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010043a:	89 fa                	mov    %edi,%edx
8010043c:	b8 0f 00 00 00       	mov    $0xf,%eax
80100441:	c1 e1 08             	shl    $0x8,%ecx
80100444:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80100445:	89 f2                	mov    %esi,%edx
80100447:	ec                   	in     (%dx),%al
  pos |= inb(CRTPORT+1);
80100448:	0f b6 c0             	movzbl %al,%eax
8010044b:	09 c8                	or     %ecx,%eax
  if(c == '\n')
8010044d:	83 fb 0a             	cmp    $0xa,%ebx
80100450:	0f 84 92 00 00 00    	je     801004e8 <consputc.part.0+0xe8>
  else if(c == BACKSPACE){
80100456:	81 fb 00 01 00 00    	cmp    $0x100,%ebx
8010045c:	74 72                	je     801004d0 <consputc.part.0+0xd0>
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010045e:	0f b6 db             	movzbl %bl,%ebx
80100461:	8d 70 01             	lea    0x1(%eax),%esi
80100464:	80 cf 07             	or     $0x7,%bh
80100467:	66 89 9c 00 00 80 0b 	mov    %bx,-0x7ff48000(%eax,%eax,1)
8010046e:	80 
  if(pos < 0 || pos > 25*80)
8010046f:	81 fe d0 07 00 00    	cmp    $0x7d0,%esi
80100475:	0f 8f fb 00 00 00    	jg     80100576 <consputc.part.0+0x176>
  if((pos/80) >= 24){  // Scroll up.
8010047b:	81 fe 7f 07 00 00    	cmp    $0x77f,%esi
80100481:	0f 8f a9 00 00 00    	jg     80100530 <consputc.part.0+0x130>
  outb(CRTPORT+1, pos>>8);
80100487:	89 f0                	mov    %esi,%eax
  crt[pos] = ' ' | 0x0700;
80100489:	8d b4 36 00 80 0b 80 	lea    -0x7ff48000(%esi,%esi,1),%esi
  outb(CRTPORT+1, pos);
80100490:	88 45 e7             	mov    %al,-0x19(%ebp)
  outb(CRTPORT+1, pos>>8);
80100493:	0f b6 fc             	movzbl %ah,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100496:	bb d4 03 00 00       	mov    $0x3d4,%ebx
8010049b:	b8 0e 00 00 00       	mov    $0xe,%eax
801004a0:	89 da                	mov    %ebx,%edx
801004a2:	ee                   	out    %al,(%dx)
801004a3:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
801004a8:	89 f8                	mov    %edi,%eax
801004aa:	89 ca                	mov    %ecx,%edx
801004ac:	ee                   	out    %al,(%dx)
801004ad:	b8 0f 00 00 00       	mov    $0xf,%eax
801004b2:	89 da                	mov    %ebx,%edx
801004b4:	ee                   	out    %al,(%dx)
801004b5:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
801004b9:	89 ca                	mov    %ecx,%edx
801004bb:	ee                   	out    %al,(%dx)
  crt[pos] = ' ' | 0x0700;
801004bc:	b8 20 07 00 00       	mov    $0x720,%eax
801004c1:	66 89 06             	mov    %ax,(%esi)
}
801004c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801004c7:	5b                   	pop    %ebx
801004c8:	5e                   	pop    %esi
801004c9:	5f                   	pop    %edi
801004ca:	5d                   	pop    %ebp
801004cb:	c3                   	ret    
801004cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(pos > 0) --pos;
801004d0:	8d 70 ff             	lea    -0x1(%eax),%esi
801004d3:	85 c0                	test   %eax,%eax
801004d5:	75 98                	jne    8010046f <consputc.part.0+0x6f>
801004d7:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
801004db:	be 00 80 0b 80       	mov    $0x800b8000,%esi
801004e0:	31 ff                	xor    %edi,%edi
801004e2:	eb b2                	jmp    80100496 <consputc.part.0+0x96>
801004e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    pos += 80 - pos%80;
801004e8:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
801004ed:	f7 e2                	mul    %edx
801004ef:	c1 ea 06             	shr    $0x6,%edx
801004f2:	8d 04 92             	lea    (%edx,%edx,4),%eax
801004f5:	c1 e0 04             	shl    $0x4,%eax
801004f8:	8d 70 50             	lea    0x50(%eax),%esi
801004fb:	e9 6f ff ff ff       	jmp    8010046f <consputc.part.0+0x6f>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100500:	83 ec 0c             	sub    $0xc,%esp
80100503:	6a 08                	push   $0x8
80100505:	e8 16 59 00 00       	call   80105e20 <uartputc>
8010050a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100511:	e8 0a 59 00 00       	call   80105e20 <uartputc>
80100516:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010051d:	e8 fe 58 00 00       	call   80105e20 <uartputc>
80100522:	83 c4 10             	add    $0x10,%esp
80100525:	e9 f8 fe ff ff       	jmp    80100422 <consputc.part.0+0x22>
8010052a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100530:	83 ec 04             	sub    $0x4,%esp
    pos -= 80;
80100533:	8d 5e b0             	lea    -0x50(%esi),%ebx
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100536:	8d b4 36 60 7f 0b 80 	lea    -0x7ff480a0(%esi,%esi,1),%esi
  outb(CRTPORT+1, pos);
8010053d:	bf 07 00 00 00       	mov    $0x7,%edi
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100542:	68 60 0e 00 00       	push   $0xe60
80100547:	68 a0 80 0b 80       	push   $0x800b80a0
8010054c:	68 00 80 0b 80       	push   $0x800b8000
80100551:	e8 ca 42 00 00       	call   80104820 <memmove>
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100556:	b8 80 07 00 00       	mov    $0x780,%eax
8010055b:	83 c4 0c             	add    $0xc,%esp
8010055e:	29 d8                	sub    %ebx,%eax
80100560:	01 c0                	add    %eax,%eax
80100562:	50                   	push   %eax
80100563:	6a 00                	push   $0x0
80100565:	56                   	push   %esi
80100566:	e8 15 42 00 00       	call   80104780 <memset>
  outb(CRTPORT+1, pos);
8010056b:	88 5d e7             	mov    %bl,-0x19(%ebp)
8010056e:	83 c4 10             	add    $0x10,%esp
80100571:	e9 20 ff ff ff       	jmp    80100496 <consputc.part.0+0x96>
    panic("pos under/overflow");
80100576:	83 ec 0c             	sub    $0xc,%esp
80100579:	68 45 73 10 80       	push   $0x80107345
8010057e:	e8 fd fd ff ff       	call   80100380 <panic>
80100583:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010058a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80100590 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100590:	55                   	push   %ebp
80100591:	89 e5                	mov    %esp,%ebp
80100593:	57                   	push   %edi
80100594:	56                   	push   %esi
80100595:	53                   	push   %ebx
80100596:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100599:	ff 75 08             	push   0x8(%ebp)
{
8010059c:	8b 75 10             	mov    0x10(%ebp),%esi
  iunlock(ip);
8010059f:	e8 dc 13 00 00       	call   80101980 <iunlock>
  acquire(&cons.lock);
801005a4:	c7 04 24 60 ef 10 80 	movl   $0x8010ef60,(%esp)
801005ab:	e8 10 41 00 00       	call   801046c0 <acquire>
  for(i = 0; i < n; i++)
801005b0:	83 c4 10             	add    $0x10,%esp
801005b3:	85 f6                	test   %esi,%esi
801005b5:	7e 25                	jle    801005dc <consolewrite+0x4c>
801005b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
801005ba:	8d 3c 33             	lea    (%ebx,%esi,1),%edi
  if(panicked){
801005bd:	8b 15 98 ef 10 80    	mov    0x8010ef98,%edx
    consputc(buf[i] & 0xff);
801005c3:	0f b6 03             	movzbl (%ebx),%eax
  if(panicked){
801005c6:	85 d2                	test   %edx,%edx
801005c8:	74 06                	je     801005d0 <consolewrite+0x40>
  asm volatile("cli");
801005ca:	fa                   	cli    
    for(;;)
801005cb:	eb fe                	jmp    801005cb <consolewrite+0x3b>
801005cd:	8d 76 00             	lea    0x0(%esi),%esi
801005d0:	e8 2b fe ff ff       	call   80100400 <consputc.part.0>
  for(i = 0; i < n; i++)
801005d5:	83 c3 01             	add    $0x1,%ebx
801005d8:	39 df                	cmp    %ebx,%edi
801005da:	75 e1                	jne    801005bd <consolewrite+0x2d>
  release(&cons.lock);
801005dc:	83 ec 0c             	sub    $0xc,%esp
801005df:	68 60 ef 10 80       	push   $0x8010ef60
801005e4:	e8 77 40 00 00       	call   80104660 <release>
  ilock(ip);
801005e9:	58                   	pop    %eax
801005ea:	ff 75 08             	push   0x8(%ebp)
801005ed:	e8 ae 12 00 00       	call   801018a0 <ilock>

  return n;
}
801005f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801005f5:	89 f0                	mov    %esi,%eax
801005f7:	5b                   	pop    %ebx
801005f8:	5e                   	pop    %esi
801005f9:	5f                   	pop    %edi
801005fa:	5d                   	pop    %ebp
801005fb:	c3                   	ret    
801005fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80100600 <printint>:
{
80100600:	55                   	push   %ebp
80100601:	89 e5                	mov    %esp,%ebp
80100603:	57                   	push   %edi
80100604:	56                   	push   %esi
80100605:	53                   	push   %ebx
80100606:	83 ec 2c             	sub    $0x2c,%esp
80100609:	89 55 d4             	mov    %edx,-0x2c(%ebp)
8010060c:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  if(sign && (sign = xx < 0))
8010060f:	85 c9                	test   %ecx,%ecx
80100611:	74 04                	je     80100617 <printint+0x17>
80100613:	85 c0                	test   %eax,%eax
80100615:	78 6d                	js     80100684 <printint+0x84>
    x = xx;
80100617:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
8010061e:	89 c1                	mov    %eax,%ecx
  i = 0;
80100620:	31 db                	xor    %ebx,%ebx
80100622:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    buf[i++] = digits[x % base];
80100628:	89 c8                	mov    %ecx,%eax
8010062a:	31 d2                	xor    %edx,%edx
8010062c:	89 de                	mov    %ebx,%esi
8010062e:	89 cf                	mov    %ecx,%edi
80100630:	f7 75 d4             	divl   -0x2c(%ebp)
80100633:	8d 5b 01             	lea    0x1(%ebx),%ebx
80100636:	0f b6 92 70 73 10 80 	movzbl -0x7fef8c90(%edx),%edx
  }while((x /= base) != 0);
8010063d:	89 c1                	mov    %eax,%ecx
    buf[i++] = digits[x % base];
8010063f:	88 54 1d d7          	mov    %dl,-0x29(%ebp,%ebx,1)
  }while((x /= base) != 0);
80100643:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
80100646:	73 e0                	jae    80100628 <printint+0x28>
  if(sign)
80100648:	8b 4d d0             	mov    -0x30(%ebp),%ecx
8010064b:	85 c9                	test   %ecx,%ecx
8010064d:	74 0c                	je     8010065b <printint+0x5b>
    buf[i++] = '-';
8010064f:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
    buf[i++] = digits[x % base];
80100654:	89 de                	mov    %ebx,%esi
    buf[i++] = '-';
80100656:	ba 2d 00 00 00       	mov    $0x2d,%edx
  while(--i >= 0)
8010065b:	8d 5c 35 d7          	lea    -0x29(%ebp,%esi,1),%ebx
8010065f:	0f be c2             	movsbl %dl,%eax
  if(panicked){
80100662:	8b 15 98 ef 10 80    	mov    0x8010ef98,%edx
80100668:	85 d2                	test   %edx,%edx
8010066a:	74 04                	je     80100670 <printint+0x70>
8010066c:	fa                   	cli    
    for(;;)
8010066d:	eb fe                	jmp    8010066d <printint+0x6d>
8010066f:	90                   	nop
80100670:	e8 8b fd ff ff       	call   80100400 <consputc.part.0>
  while(--i >= 0)
80100675:	8d 45 d7             	lea    -0x29(%ebp),%eax
80100678:	39 c3                	cmp    %eax,%ebx
8010067a:	74 0e                	je     8010068a <printint+0x8a>
    consputc(buf[i]);
8010067c:	0f be 03             	movsbl (%ebx),%eax
8010067f:	83 eb 01             	sub    $0x1,%ebx
80100682:	eb de                	jmp    80100662 <printint+0x62>
    x = -xx;
80100684:	f7 d8                	neg    %eax
80100686:	89 c1                	mov    %eax,%ecx
80100688:	eb 96                	jmp    80100620 <printint+0x20>
}
8010068a:	83 c4 2c             	add    $0x2c,%esp
8010068d:	5b                   	pop    %ebx
8010068e:	5e                   	pop    %esi
8010068f:	5f                   	pop    %edi
80100690:	5d                   	pop    %ebp
80100691:	c3                   	ret    
80100692:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100699:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801006a0 <cprintf>:
{
801006a0:	55                   	push   %ebp
801006a1:	89 e5                	mov    %esp,%ebp
801006a3:	57                   	push   %edi
801006a4:	56                   	push   %esi
801006a5:	53                   	push   %ebx
801006a6:	83 ec 1c             	sub    $0x1c,%esp
  locking = cons.locking;
801006a9:	a1 94 ef 10 80       	mov    0x8010ef94,%eax
801006ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(locking)
801006b1:	85 c0                	test   %eax,%eax
801006b3:	0f 85 27 01 00 00    	jne    801007e0 <cprintf+0x140>
  if (fmt == 0)
801006b9:	8b 75 08             	mov    0x8(%ebp),%esi
801006bc:	85 f6                	test   %esi,%esi
801006be:	0f 84 ac 01 00 00    	je     80100870 <cprintf+0x1d0>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801006c4:	0f b6 06             	movzbl (%esi),%eax
  argp = (uint*)(void*)(&fmt + 1);
801006c7:	8d 7d 0c             	lea    0xc(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801006ca:	31 db                	xor    %ebx,%ebx
801006cc:	85 c0                	test   %eax,%eax
801006ce:	74 56                	je     80100726 <cprintf+0x86>
    if(c != '%'){
801006d0:	83 f8 25             	cmp    $0x25,%eax
801006d3:	0f 85 cf 00 00 00    	jne    801007a8 <cprintf+0x108>
    c = fmt[++i] & 0xff;
801006d9:	83 c3 01             	add    $0x1,%ebx
801006dc:	0f b6 14 1e          	movzbl (%esi,%ebx,1),%edx
    if(c == 0)
801006e0:	85 d2                	test   %edx,%edx
801006e2:	74 42                	je     80100726 <cprintf+0x86>
    switch(c){
801006e4:	83 fa 70             	cmp    $0x70,%edx
801006e7:	0f 84 90 00 00 00    	je     8010077d <cprintf+0xdd>
801006ed:	7f 51                	jg     80100740 <cprintf+0xa0>
801006ef:	83 fa 25             	cmp    $0x25,%edx
801006f2:	0f 84 c0 00 00 00    	je     801007b8 <cprintf+0x118>
801006f8:	83 fa 64             	cmp    $0x64,%edx
801006fb:	0f 85 f4 00 00 00    	jne    801007f5 <cprintf+0x155>
      printint(*argp++, 10, 1);
80100701:	8d 47 04             	lea    0x4(%edi),%eax
80100704:	b9 01 00 00 00       	mov    $0x1,%ecx
80100709:	ba 0a 00 00 00       	mov    $0xa,%edx
8010070e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100711:	8b 07                	mov    (%edi),%eax
80100713:	e8 e8 fe ff ff       	call   80100600 <printint>
80100718:	8b 7d e0             	mov    -0x20(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010071b:	83 c3 01             	add    $0x1,%ebx
8010071e:	0f b6 04 1e          	movzbl (%esi,%ebx,1),%eax
80100722:	85 c0                	test   %eax,%eax
80100724:	75 aa                	jne    801006d0 <cprintf+0x30>
  if(locking)
80100726:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100729:	85 c0                	test   %eax,%eax
8010072b:	0f 85 22 01 00 00    	jne    80100853 <cprintf+0x1b3>
}
80100731:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100734:	5b                   	pop    %ebx
80100735:	5e                   	pop    %esi
80100736:	5f                   	pop    %edi
80100737:	5d                   	pop    %ebp
80100738:	c3                   	ret    
80100739:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    switch(c){
80100740:	83 fa 73             	cmp    $0x73,%edx
80100743:	75 33                	jne    80100778 <cprintf+0xd8>
      if((s = (char*)*argp++) == 0)
80100745:	8d 47 04             	lea    0x4(%edi),%eax
80100748:	8b 3f                	mov    (%edi),%edi
8010074a:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010074d:	85 ff                	test   %edi,%edi
8010074f:	0f 84 e3 00 00 00    	je     80100838 <cprintf+0x198>
      for(; *s; s++)
80100755:	0f be 07             	movsbl (%edi),%eax
80100758:	84 c0                	test   %al,%al
8010075a:	0f 84 08 01 00 00    	je     80100868 <cprintf+0x1c8>
  if(panicked){
80100760:	8b 15 98 ef 10 80    	mov    0x8010ef98,%edx
80100766:	85 d2                	test   %edx,%edx
80100768:	0f 84 b2 00 00 00    	je     80100820 <cprintf+0x180>
8010076e:	fa                   	cli    
    for(;;)
8010076f:	eb fe                	jmp    8010076f <cprintf+0xcf>
80100771:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    switch(c){
80100778:	83 fa 78             	cmp    $0x78,%edx
8010077b:	75 78                	jne    801007f5 <cprintf+0x155>
      printint(*argp++, 16, 0);
8010077d:	8d 47 04             	lea    0x4(%edi),%eax
80100780:	31 c9                	xor    %ecx,%ecx
80100782:	ba 10 00 00 00       	mov    $0x10,%edx
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100787:	83 c3 01             	add    $0x1,%ebx
      printint(*argp++, 16, 0);
8010078a:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010078d:	8b 07                	mov    (%edi),%eax
8010078f:	e8 6c fe ff ff       	call   80100600 <printint>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100794:	0f b6 04 1e          	movzbl (%esi,%ebx,1),%eax
      printint(*argp++, 16, 0);
80100798:	8b 7d e0             	mov    -0x20(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010079b:	85 c0                	test   %eax,%eax
8010079d:	0f 85 2d ff ff ff    	jne    801006d0 <cprintf+0x30>
801007a3:	eb 81                	jmp    80100726 <cprintf+0x86>
801007a5:	8d 76 00             	lea    0x0(%esi),%esi
  if(panicked){
801007a8:	8b 0d 98 ef 10 80    	mov    0x8010ef98,%ecx
801007ae:	85 c9                	test   %ecx,%ecx
801007b0:	74 14                	je     801007c6 <cprintf+0x126>
801007b2:	fa                   	cli    
    for(;;)
801007b3:	eb fe                	jmp    801007b3 <cprintf+0x113>
801007b5:	8d 76 00             	lea    0x0(%esi),%esi
  if(panicked){
801007b8:	a1 98 ef 10 80       	mov    0x8010ef98,%eax
801007bd:	85 c0                	test   %eax,%eax
801007bf:	75 6c                	jne    8010082d <cprintf+0x18d>
801007c1:	b8 25 00 00 00       	mov    $0x25,%eax
801007c6:	e8 35 fc ff ff       	call   80100400 <consputc.part.0>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801007cb:	83 c3 01             	add    $0x1,%ebx
801007ce:	0f b6 04 1e          	movzbl (%esi,%ebx,1),%eax
801007d2:	85 c0                	test   %eax,%eax
801007d4:	0f 85 f6 fe ff ff    	jne    801006d0 <cprintf+0x30>
801007da:	e9 47 ff ff ff       	jmp    80100726 <cprintf+0x86>
801007df:	90                   	nop
    acquire(&cons.lock);
801007e0:	83 ec 0c             	sub    $0xc,%esp
801007e3:	68 60 ef 10 80       	push   $0x8010ef60
801007e8:	e8 d3 3e 00 00       	call   801046c0 <acquire>
801007ed:	83 c4 10             	add    $0x10,%esp
801007f0:	e9 c4 fe ff ff       	jmp    801006b9 <cprintf+0x19>
  if(panicked){
801007f5:	8b 0d 98 ef 10 80    	mov    0x8010ef98,%ecx
801007fb:	85 c9                	test   %ecx,%ecx
801007fd:	75 31                	jne    80100830 <cprintf+0x190>
801007ff:	b8 25 00 00 00       	mov    $0x25,%eax
80100804:	89 55 e0             	mov    %edx,-0x20(%ebp)
80100807:	e8 f4 fb ff ff       	call   80100400 <consputc.part.0>
8010080c:	8b 15 98 ef 10 80    	mov    0x8010ef98,%edx
80100812:	85 d2                	test   %edx,%edx
80100814:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100817:	74 2e                	je     80100847 <cprintf+0x1a7>
80100819:	fa                   	cli    
    for(;;)
8010081a:	eb fe                	jmp    8010081a <cprintf+0x17a>
8010081c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100820:	e8 db fb ff ff       	call   80100400 <consputc.part.0>
      for(; *s; s++)
80100825:	83 c7 01             	add    $0x1,%edi
80100828:	e9 28 ff ff ff       	jmp    80100755 <cprintf+0xb5>
8010082d:	fa                   	cli    
    for(;;)
8010082e:	eb fe                	jmp    8010082e <cprintf+0x18e>
80100830:	fa                   	cli    
80100831:	eb fe                	jmp    80100831 <cprintf+0x191>
80100833:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100837:	90                   	nop
        s = "(null)";
80100838:	bf 58 73 10 80       	mov    $0x80107358,%edi
      for(; *s; s++)
8010083d:	b8 28 00 00 00       	mov    $0x28,%eax
80100842:	e9 19 ff ff ff       	jmp    80100760 <cprintf+0xc0>
80100847:	89 d0                	mov    %edx,%eax
80100849:	e8 b2 fb ff ff       	call   80100400 <consputc.part.0>
8010084e:	e9 c8 fe ff ff       	jmp    8010071b <cprintf+0x7b>
    release(&cons.lock);
80100853:	83 ec 0c             	sub    $0xc,%esp
80100856:	68 60 ef 10 80       	push   $0x8010ef60
8010085b:	e8 00 3e 00 00       	call   80104660 <release>
80100860:	83 c4 10             	add    $0x10,%esp
}
80100863:	e9 c9 fe ff ff       	jmp    80100731 <cprintf+0x91>
      if((s = (char*)*argp++) == 0)
80100868:	8b 7d e0             	mov    -0x20(%ebp),%edi
8010086b:	e9 ab fe ff ff       	jmp    8010071b <cprintf+0x7b>
    panic("null fmt");
80100870:	83 ec 0c             	sub    $0xc,%esp
80100873:	68 5f 73 10 80       	push   $0x8010735f
80100878:	e8 03 fb ff ff       	call   80100380 <panic>
8010087d:	8d 76 00             	lea    0x0(%esi),%esi

80100880 <consoleintr>:
{
80100880:	55                   	push   %ebp
80100881:	89 e5                	mov    %esp,%ebp
80100883:	57                   	push   %edi
80100884:	56                   	push   %esi
  int c, doprocdump = 0;
80100885:	31 f6                	xor    %esi,%esi
{
80100887:	53                   	push   %ebx
80100888:	83 ec 18             	sub    $0x18,%esp
8010088b:	8b 7d 08             	mov    0x8(%ebp),%edi
  acquire(&cons.lock);
8010088e:	68 60 ef 10 80       	push   $0x8010ef60
80100893:	e8 28 3e 00 00       	call   801046c0 <acquire>
  while((c = getc()) >= 0){
80100898:	83 c4 10             	add    $0x10,%esp
8010089b:	eb 1a                	jmp    801008b7 <consoleintr+0x37>
8010089d:	8d 76 00             	lea    0x0(%esi),%esi
    switch(c){
801008a0:	83 fb 08             	cmp    $0x8,%ebx
801008a3:	0f 84 d7 00 00 00    	je     80100980 <consoleintr+0x100>
801008a9:	83 fb 10             	cmp    $0x10,%ebx
801008ac:	0f 85 32 01 00 00    	jne    801009e4 <consoleintr+0x164>
801008b2:	be 01 00 00 00       	mov    $0x1,%esi
  while((c = getc()) >= 0){
801008b7:	ff d7                	call   *%edi
801008b9:	89 c3                	mov    %eax,%ebx
801008bb:	85 c0                	test   %eax,%eax
801008bd:	0f 88 05 01 00 00    	js     801009c8 <consoleintr+0x148>
    switch(c){
801008c3:	83 fb 15             	cmp    $0x15,%ebx
801008c6:	74 78                	je     80100940 <consoleintr+0xc0>
801008c8:	7e d6                	jle    801008a0 <consoleintr+0x20>
801008ca:	83 fb 7f             	cmp    $0x7f,%ebx
801008cd:	0f 84 ad 00 00 00    	je     80100980 <consoleintr+0x100>
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008d3:	a1 48 ef 10 80       	mov    0x8010ef48,%eax
801008d8:	89 c2                	mov    %eax,%edx
801008da:	2b 15 40 ef 10 80    	sub    0x8010ef40,%edx
801008e0:	83 fa 7f             	cmp    $0x7f,%edx
801008e3:	77 d2                	ja     801008b7 <consoleintr+0x37>
        input.buf[input.e++ % INPUT_BUF] = c;
801008e5:	8d 48 01             	lea    0x1(%eax),%ecx
  if(panicked){
801008e8:	8b 15 98 ef 10 80    	mov    0x8010ef98,%edx
        input.buf[input.e++ % INPUT_BUF] = c;
801008ee:	83 e0 7f             	and    $0x7f,%eax
801008f1:	89 0d 48 ef 10 80    	mov    %ecx,0x8010ef48
        c = (c == '\r') ? '\n' : c;
801008f7:	83 fb 0d             	cmp    $0xd,%ebx
801008fa:	0f 84 13 01 00 00    	je     80100a13 <consoleintr+0x193>
        input.buf[input.e++ % INPUT_BUF] = c;
80100900:	88 98 c0 ee 10 80    	mov    %bl,-0x7fef1140(%eax)
  if(panicked){
80100906:	85 d2                	test   %edx,%edx
80100908:	0f 85 10 01 00 00    	jne    80100a1e <consoleintr+0x19e>
8010090e:	89 d8                	mov    %ebx,%eax
80100910:	e8 eb fa ff ff       	call   80100400 <consputc.part.0>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100915:	83 fb 0a             	cmp    $0xa,%ebx
80100918:	0f 84 14 01 00 00    	je     80100a32 <consoleintr+0x1b2>
8010091e:	83 fb 04             	cmp    $0x4,%ebx
80100921:	0f 84 0b 01 00 00    	je     80100a32 <consoleintr+0x1b2>
80100927:	a1 40 ef 10 80       	mov    0x8010ef40,%eax
8010092c:	83 e8 80             	sub    $0xffffff80,%eax
8010092f:	39 05 48 ef 10 80    	cmp    %eax,0x8010ef48
80100935:	75 80                	jne    801008b7 <consoleintr+0x37>
80100937:	e9 fb 00 00 00       	jmp    80100a37 <consoleintr+0x1b7>
8010093c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      while(input.e != input.w &&
80100940:	a1 48 ef 10 80       	mov    0x8010ef48,%eax
80100945:	39 05 44 ef 10 80    	cmp    %eax,0x8010ef44
8010094b:	0f 84 66 ff ff ff    	je     801008b7 <consoleintr+0x37>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100951:	83 e8 01             	sub    $0x1,%eax
80100954:	89 c2                	mov    %eax,%edx
80100956:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
80100959:	80 ba c0 ee 10 80 0a 	cmpb   $0xa,-0x7fef1140(%edx)
80100960:	0f 84 51 ff ff ff    	je     801008b7 <consoleintr+0x37>
  if(panicked){
80100966:	8b 15 98 ef 10 80    	mov    0x8010ef98,%edx
        input.e--;
8010096c:	a3 48 ef 10 80       	mov    %eax,0x8010ef48
  if(panicked){
80100971:	85 d2                	test   %edx,%edx
80100973:	74 33                	je     801009a8 <consoleintr+0x128>
80100975:	fa                   	cli    
    for(;;)
80100976:	eb fe                	jmp    80100976 <consoleintr+0xf6>
80100978:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010097f:	90                   	nop
      if(input.e != input.w){
80100980:	a1 48 ef 10 80       	mov    0x8010ef48,%eax
80100985:	3b 05 44 ef 10 80    	cmp    0x8010ef44,%eax
8010098b:	0f 84 26 ff ff ff    	je     801008b7 <consoleintr+0x37>
        input.e--;
80100991:	83 e8 01             	sub    $0x1,%eax
80100994:	a3 48 ef 10 80       	mov    %eax,0x8010ef48
  if(panicked){
80100999:	a1 98 ef 10 80       	mov    0x8010ef98,%eax
8010099e:	85 c0                	test   %eax,%eax
801009a0:	74 56                	je     801009f8 <consoleintr+0x178>
801009a2:	fa                   	cli    
    for(;;)
801009a3:	eb fe                	jmp    801009a3 <consoleintr+0x123>
801009a5:	8d 76 00             	lea    0x0(%esi),%esi
801009a8:	b8 00 01 00 00       	mov    $0x100,%eax
801009ad:	e8 4e fa ff ff       	call   80100400 <consputc.part.0>
      while(input.e != input.w &&
801009b2:	a1 48 ef 10 80       	mov    0x8010ef48,%eax
801009b7:	3b 05 44 ef 10 80    	cmp    0x8010ef44,%eax
801009bd:	75 92                	jne    80100951 <consoleintr+0xd1>
801009bf:	e9 f3 fe ff ff       	jmp    801008b7 <consoleintr+0x37>
801009c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  release(&cons.lock);
801009c8:	83 ec 0c             	sub    $0xc,%esp
801009cb:	68 60 ef 10 80       	push   $0x8010ef60
801009d0:	e8 8b 3c 00 00       	call   80104660 <release>
  if(doprocdump) {
801009d5:	83 c4 10             	add    $0x10,%esp
801009d8:	85 f6                	test   %esi,%esi
801009da:	75 2b                	jne    80100a07 <consoleintr+0x187>
}
801009dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
801009df:	5b                   	pop    %ebx
801009e0:	5e                   	pop    %esi
801009e1:	5f                   	pop    %edi
801009e2:	5d                   	pop    %ebp
801009e3:	c3                   	ret    
      if(c != 0 && input.e-input.r < INPUT_BUF){
801009e4:	85 db                	test   %ebx,%ebx
801009e6:	0f 84 cb fe ff ff    	je     801008b7 <consoleintr+0x37>
801009ec:	e9 e2 fe ff ff       	jmp    801008d3 <consoleintr+0x53>
801009f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801009f8:	b8 00 01 00 00       	mov    $0x100,%eax
801009fd:	e8 fe f9 ff ff       	call   80100400 <consputc.part.0>
80100a02:	e9 b0 fe ff ff       	jmp    801008b7 <consoleintr+0x37>
}
80100a07:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100a0a:	5b                   	pop    %ebx
80100a0b:	5e                   	pop    %esi
80100a0c:	5f                   	pop    %edi
80100a0d:	5d                   	pop    %ebp
    procdump();  // now call procdump() wo. cons.lock held
80100a0e:	e9 ed 38 00 00       	jmp    80104300 <procdump>
        input.buf[input.e++ % INPUT_BUF] = c;
80100a13:	c6 80 c0 ee 10 80 0a 	movb   $0xa,-0x7fef1140(%eax)
  if(panicked){
80100a1a:	85 d2                	test   %edx,%edx
80100a1c:	74 0a                	je     80100a28 <consoleintr+0x1a8>
80100a1e:	fa                   	cli    
    for(;;)
80100a1f:	eb fe                	jmp    80100a1f <consoleintr+0x19f>
80100a21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100a28:	b8 0a 00 00 00       	mov    $0xa,%eax
80100a2d:	e8 ce f9 ff ff       	call   80100400 <consputc.part.0>
          input.w = input.e;
80100a32:	a1 48 ef 10 80       	mov    0x8010ef48,%eax
          wakeup(&input.r);
80100a37:	83 ec 0c             	sub    $0xc,%esp
          input.w = input.e;
80100a3a:	a3 44 ef 10 80       	mov    %eax,0x8010ef44
          wakeup(&input.r);
80100a3f:	68 40 ef 10 80       	push   $0x8010ef40
80100a44:	e8 d7 37 00 00       	call   80104220 <wakeup>
80100a49:	83 c4 10             	add    $0x10,%esp
80100a4c:	e9 66 fe ff ff       	jmp    801008b7 <consoleintr+0x37>
80100a51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100a58:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100a5f:	90                   	nop

80100a60 <consoleinit>:

void
consoleinit(void)
{
80100a60:	55                   	push   %ebp
80100a61:	89 e5                	mov    %esp,%ebp
80100a63:	83 ec 10             	sub    $0x10,%esp
  initlock(&cons.lock, "console");
80100a66:	68 68 73 10 80       	push   $0x80107368
80100a6b:	68 60 ef 10 80       	push   $0x8010ef60
80100a70:	e8 7b 3a 00 00       	call   801044f0 <initlock>

  devsw[CONSOLE].write = consolewrite;
  devsw[CONSOLE].read = consoleread;
  cons.locking = 1;

  ioapicenable(IRQ_KBD, 0);
80100a75:	58                   	pop    %eax
80100a76:	5a                   	pop    %edx
80100a77:	6a 00                	push   $0x0
80100a79:	6a 01                	push   $0x1
  devsw[CONSOLE].write = consolewrite;
80100a7b:	c7 05 4c f9 10 80 90 	movl   $0x80100590,0x8010f94c
80100a82:	05 10 80 
  devsw[CONSOLE].read = consoleread;
80100a85:	c7 05 48 f9 10 80 80 	movl   $0x80100280,0x8010f948
80100a8c:	02 10 80 
  cons.locking = 1;
80100a8f:	c7 05 94 ef 10 80 01 	movl   $0x1,0x8010ef94
80100a96:	00 00 00 
  ioapicenable(IRQ_KBD, 0);
80100a99:	e8 02 1b 00 00       	call   801025a0 <ioapicenable>
}
80100a9e:	83 c4 10             	add    $0x10,%esp
80100aa1:	c9                   	leave  
80100aa2:	c3                   	ret    
80100aa3:	66 90                	xchg   %ax,%ax
80100aa5:	66 90                	xchg   %ax,%ax
80100aa7:	66 90                	xchg   %ax,%ax
80100aa9:	66 90                	xchg   %ax,%ax
80100aab:	66 90                	xchg   %ax,%ax
80100aad:	66 90                	xchg   %ax,%ax
80100aaf:	90                   	nop

80100ab0 <my_strcmp>:
#include "x86.h"
#include "elf.h"

extern char last_cat_arg[64];

int my_strcmp(const char *str1, const char *str2) {
80100ab0:	55                   	push   %ebp
80100ab1:	89 e5                	mov    %esp,%ebp
80100ab3:	53                   	push   %ebx
80100ab4:	8b 4d 08             	mov    0x8(%ebp),%ecx
80100ab7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    while (*str1 != '\0' && *str2 != '\0') {
80100aba:	0f be 01             	movsbl (%ecx),%eax
80100abd:	84 c0                	test   %al,%al
80100abf:	75 1b                	jne    80100adc <my_strcmp+0x2c>
80100ac1:	eb 3a                	jmp    80100afd <my_strcmp+0x4d>
80100ac3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100ac7:	90                   	nop
        if (*str1 != *str2) {
80100ac8:	38 c2                	cmp    %al,%dl
80100aca:	75 17                	jne    80100ae3 <my_strcmp+0x33>
    while (*str1 != '\0' && *str2 != '\0') {
80100acc:	0f be 41 01          	movsbl 0x1(%ecx),%eax
            return *str1 - *str2; // Return the ASCII difference
        }
        str1++;
80100ad0:	83 c1 01             	add    $0x1,%ecx
        str2++;
80100ad3:	8d 53 01             	lea    0x1(%ebx),%edx
    while (*str1 != '\0' && *str2 != '\0') {
80100ad6:	84 c0                	test   %al,%al
80100ad8:	74 16                	je     80100af0 <my_strcmp+0x40>
        str2++;
80100ada:	89 d3                	mov    %edx,%ebx
    while (*str1 != '\0' && *str2 != '\0') {
80100adc:	0f be 13             	movsbl (%ebx),%edx
80100adf:	84 d2                	test   %dl,%dl
80100ae1:	75 e5                	jne    80100ac8 <my_strcmp+0x18>
    }

    return *str1 - *str2; // In case strings are of different lengths
}
80100ae3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    return *str1 - *str2; // In case strings are of different lengths
80100ae6:	29 d0                	sub    %edx,%eax
}
80100ae8:	c9                   	leave  
80100ae9:	c3                   	ret    
80100aea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return *str1 - *str2; // In case strings are of different lengths
80100af0:	0f be 53 01          	movsbl 0x1(%ebx),%edx
80100af4:	31 c0                	xor    %eax,%eax
}
80100af6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100af9:	c9                   	leave  
    return *str1 - *str2; // In case strings are of different lengths
80100afa:	29 d0                	sub    %edx,%eax
}
80100afc:	c3                   	ret    
    return *str1 - *str2; // In case strings are of different lengths
80100afd:	0f be 13             	movsbl (%ebx),%edx
80100b00:	31 c0                	xor    %eax,%eax
80100b02:	eb df                	jmp    80100ae3 <my_strcmp+0x33>
80100b04:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100b0b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100b0f:	90                   	nop

80100b10 <exec>:

int
exec(char *path, char **argv)
{
80100b10:	55                   	push   %ebp
80100b11:	89 e5                	mov    %esp,%ebp
80100b13:	57                   	push   %edi
80100b14:	56                   	push   %esi
80100b15:	53                   	push   %ebx
80100b16:	81 ec 1c 01 00 00    	sub    $0x11c,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100b1c:	e8 6f 2f 00 00       	call   80103a90 <myproc>
80100b21:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)

  begin_op();
80100b27:	e8 54 23 00 00       	call   80102e80 <begin_op>

  if((ip = namei(path)) == 0){
80100b2c:	83 ec 0c             	sub    $0xc,%esp
80100b2f:	ff 75 08             	push   0x8(%ebp)
80100b32:	e8 89 16 00 00       	call   801021c0 <namei>
80100b37:	83 c4 10             	add    $0x10,%esp
80100b3a:	85 c0                	test   %eax,%eax
80100b3c:	0f 84 94 03 00 00    	je     80100ed6 <exec+0x3c6>
    end_op();
    cprintf("exec: fail\n");
    return -1;
  }
  ilock(ip);
80100b42:	83 ec 0c             	sub    $0xc,%esp
80100b45:	89 c3                	mov    %eax,%ebx
80100b47:	50                   	push   %eax
80100b48:	e8 53 0d 00 00       	call   801018a0 <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100b4d:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
80100b53:	6a 34                	push   $0x34
80100b55:	6a 00                	push   $0x0
80100b57:	50                   	push   %eax
80100b58:	53                   	push   %ebx
80100b59:	e8 52 10 00 00       	call   80101bb0 <readi>
80100b5e:	83 c4 20             	add    $0x20,%esp
80100b61:	83 f8 34             	cmp    $0x34,%eax
80100b64:	74 22                	je     80100b88 <exec+0x78>

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip){
    iunlockput(ip);
80100b66:	83 ec 0c             	sub    $0xc,%esp
80100b69:	53                   	push   %ebx
80100b6a:	e8 c1 0f 00 00       	call   80101b30 <iunlockput>
    end_op();
80100b6f:	e8 7c 23 00 00       	call   80102ef0 <end_op>
80100b74:	83 c4 10             	add    $0x10,%esp
  }
  return -1;
80100b77:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100b7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100b7f:	5b                   	pop    %ebx
80100b80:	5e                   	pop    %esi
80100b81:	5f                   	pop    %edi
80100b82:	5d                   	pop    %ebp
80100b83:	c3                   	ret    
80100b84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if(elf.magic != ELF_MAGIC)
80100b88:	81 bd 24 ff ff ff 7f 	cmpl   $0x464c457f,-0xdc(%ebp)
80100b8f:	45 4c 46 
80100b92:	75 d2                	jne    80100b66 <exec+0x56>
  if((pgdir = setupkvm()) == 0)
80100b94:	e8 17 64 00 00       	call   80106fb0 <setupkvm>
80100b99:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)
80100b9f:	85 c0                	test   %eax,%eax
80100ba1:	74 c3                	je     80100b66 <exec+0x56>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100ba3:	66 83 bd 50 ff ff ff 	cmpw   $0x0,-0xb0(%ebp)
80100baa:	00 
80100bab:	8b b5 40 ff ff ff    	mov    -0xc0(%ebp),%esi
80100bb1:	0f 84 3e 03 00 00    	je     80100ef5 <exec+0x3e5>
  sz = 0;
80100bb7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
80100bbe:	00 00 00 
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100bc1:	31 ff                	xor    %edi,%edi
80100bc3:	e9 8e 00 00 00       	jmp    80100c56 <exec+0x146>
80100bc8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100bcf:	90                   	nop
    if(ph.type != ELF_PROG_LOAD)
80100bd0:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
80100bd7:	75 6c                	jne    80100c45 <exec+0x135>
    if(ph.memsz < ph.filesz)
80100bd9:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
80100bdf:	3b 85 14 ff ff ff    	cmp    -0xec(%ebp),%eax
80100be5:	0f 82 87 00 00 00    	jb     80100c72 <exec+0x162>
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100beb:	03 85 0c ff ff ff    	add    -0xf4(%ebp),%eax
80100bf1:	72 7f                	jb     80100c72 <exec+0x162>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100bf3:	83 ec 04             	sub    $0x4,%esp
80100bf6:	50                   	push   %eax
80100bf7:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
80100bfd:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100c03:	e8 c8 61 00 00       	call   80106dd0 <allocuvm>
80100c08:	83 c4 10             	add    $0x10,%esp
80100c0b:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100c11:	85 c0                	test   %eax,%eax
80100c13:	74 5d                	je     80100c72 <exec+0x162>
    if(ph.vaddr % PGSIZE != 0)
80100c15:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100c1b:	a9 ff 0f 00 00       	test   $0xfff,%eax
80100c20:	75 50                	jne    80100c72 <exec+0x162>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c22:	83 ec 0c             	sub    $0xc,%esp
80100c25:	ff b5 14 ff ff ff    	push   -0xec(%ebp)
80100c2b:	ff b5 08 ff ff ff    	push   -0xf8(%ebp)
80100c31:	53                   	push   %ebx
80100c32:	50                   	push   %eax
80100c33:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100c39:	e8 a2 60 00 00       	call   80106ce0 <loaduvm>
80100c3e:	83 c4 20             	add    $0x20,%esp
80100c41:	85 c0                	test   %eax,%eax
80100c43:	78 2d                	js     80100c72 <exec+0x162>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c45:	0f b7 85 50 ff ff ff 	movzwl -0xb0(%ebp),%eax
80100c4c:	83 c7 01             	add    $0x1,%edi
80100c4f:	83 c6 20             	add    $0x20,%esi
80100c52:	39 f8                	cmp    %edi,%eax
80100c54:	7e 3a                	jle    80100c90 <exec+0x180>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c56:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
80100c5c:	6a 20                	push   $0x20
80100c5e:	56                   	push   %esi
80100c5f:	50                   	push   %eax
80100c60:	53                   	push   %ebx
80100c61:	e8 4a 0f 00 00       	call   80101bb0 <readi>
80100c66:	83 c4 10             	add    $0x10,%esp
80100c69:	83 f8 20             	cmp    $0x20,%eax
80100c6c:	0f 84 5e ff ff ff    	je     80100bd0 <exec+0xc0>
    freevm(pgdir);
80100c72:	83 ec 0c             	sub    $0xc,%esp
80100c75:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100c7b:	e8 b0 62 00 00       	call   80106f30 <freevm>
  if(ip){
80100c80:	83 c4 10             	add    $0x10,%esp
80100c83:	e9 de fe ff ff       	jmp    80100b66 <exec+0x56>
80100c88:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100c8f:	90                   	nop
  sz = PGROUNDUP(sz);
80100c90:	8b bd f0 fe ff ff    	mov    -0x110(%ebp),%edi
80100c96:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
80100c9c:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100ca2:	8d b7 00 20 00 00    	lea    0x2000(%edi),%esi
  iunlockput(ip);
80100ca8:	83 ec 0c             	sub    $0xc,%esp
80100cab:	53                   	push   %ebx
80100cac:	e8 7f 0e 00 00       	call   80101b30 <iunlockput>
  end_op();
80100cb1:	e8 3a 22 00 00       	call   80102ef0 <end_op>
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100cb6:	83 c4 0c             	add    $0xc,%esp
80100cb9:	56                   	push   %esi
80100cba:	57                   	push   %edi
80100cbb:	8b bd f4 fe ff ff    	mov    -0x10c(%ebp),%edi
80100cc1:	57                   	push   %edi
80100cc2:	e8 09 61 00 00       	call   80106dd0 <allocuvm>
80100cc7:	83 c4 10             	add    $0x10,%esp
80100cca:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100cd0:	89 c6                	mov    %eax,%esi
80100cd2:	85 c0                	test   %eax,%eax
80100cd4:	0f 84 92 00 00 00    	je     80100d6c <exec+0x25c>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100cda:	83 ec 08             	sub    $0x8,%esp
80100cdd:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
  for(argc = 0; argv[argc]; argc++) {
80100ce3:	31 db                	xor    %ebx,%ebx
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100ce5:	50                   	push   %eax
80100ce6:	57                   	push   %edi
80100ce7:	8d bd 58 ff ff ff    	lea    -0xa8(%ebp),%edi
80100ced:	e8 5e 63 00 00       	call   80107050 <clearpteu>
  for(argc = 0; argv[argc]; argc++) {
80100cf2:	8b 45 0c             	mov    0xc(%ebp),%eax
80100cf5:	83 c4 10             	add    $0x10,%esp
80100cf8:	8b 08                	mov    (%eax),%ecx
80100cfa:	89 8d e8 fe ff ff    	mov    %ecx,-0x118(%ebp)
80100d00:	89 c8                	mov    %ecx,%eax
80100d02:	85 c9                	test   %ecx,%ecx
80100d04:	0f 84 8a 00 00 00    	je     80100d94 <exec+0x284>
80100d0a:	8b bd f4 fe ff ff    	mov    -0x10c(%ebp),%edi
80100d10:	eb 25                	jmp    80100d37 <exec+0x227>
80100d12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80100d18:	8b 45 0c             	mov    0xc(%ebp),%eax
    ustack[3+argc] = sp;
80100d1b:	89 b4 9d 64 ff ff ff 	mov    %esi,-0x9c(%ebp,%ebx,4)
  for(argc = 0; argv[argc]; argc++) {
80100d22:	83 c3 01             	add    $0x1,%ebx
    ustack[3+argc] = sp;
80100d25:	8d 95 58 ff ff ff    	lea    -0xa8(%ebp),%edx
  for(argc = 0; argv[argc]; argc++) {
80100d2b:	8b 04 98             	mov    (%eax,%ebx,4),%eax
80100d2e:	85 c0                	test   %eax,%eax
80100d30:	74 55                	je     80100d87 <exec+0x277>
    if(argc >= MAXARG)
80100d32:	83 fb 20             	cmp    $0x20,%ebx
80100d35:	74 35                	je     80100d6c <exec+0x25c>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d37:	83 ec 0c             	sub    $0xc,%esp
80100d3a:	50                   	push   %eax
80100d3b:	e8 40 3c 00 00       	call   80104980 <strlen>
80100d40:	29 c6                	sub    %eax,%esi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d42:	58                   	pop    %eax
80100d43:	8b 45 0c             	mov    0xc(%ebp),%eax
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d46:	83 ee 01             	sub    $0x1,%esi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d49:	ff 34 98             	push   (%eax,%ebx,4)
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d4c:	83 e6 fc             	and    $0xfffffffc,%esi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d4f:	e8 2c 3c 00 00       	call   80104980 <strlen>
80100d54:	83 c0 01             	add    $0x1,%eax
80100d57:	50                   	push   %eax
80100d58:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d5b:	ff 34 98             	push   (%eax,%ebx,4)
80100d5e:	56                   	push   %esi
80100d5f:	57                   	push   %edi
80100d60:	e8 bb 64 00 00       	call   80107220 <copyout>
80100d65:	83 c4 20             	add    $0x20,%esp
80100d68:	85 c0                	test   %eax,%eax
80100d6a:	79 ac                	jns    80100d18 <exec+0x208>
    freevm(pgdir);
80100d6c:	83 ec 0c             	sub    $0xc,%esp
80100d6f:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100d75:	e8 b6 61 00 00       	call   80106f30 <freevm>
80100d7a:	83 c4 10             	add    $0x10,%esp
  return -1;
80100d7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100d82:	e9 f5 fd ff ff       	jmp    80100b7c <exec+0x6c>
80100d87:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d8a:	89 d7                	mov    %edx,%edi
80100d8c:	8b 00                	mov    (%eax),%eax
80100d8e:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
    while (*str1 != '\0' && *str2 != '\0') {
80100d94:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
  ustack[3+argc] = 0;
80100d9a:	c7 84 9d 64 ff ff ff 	movl   $0x0,-0x9c(%ebp,%ebx,4)
80100da1:	00 00 00 00 
    while (*str1 != '\0' && *str2 != '\0') {
80100da5:	0f be 08             	movsbl (%eax),%ecx
80100da8:	84 c9                	test   %cl,%cl
80100daa:	0f 84 6d 01 00 00    	je     80100f1d <exec+0x40d>
80100db0:	89 b5 e4 fe ff ff    	mov    %esi,-0x11c(%ebp)
80100db6:	b8 01 00 00 00       	mov    $0x1,%eax
80100dbb:	ba 63 00 00 00       	mov    $0x63,%edx
80100dc0:	8b b5 e8 fe ff ff    	mov    -0x118(%ebp),%esi
80100dc6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100dcd:	8d 76 00             	lea    0x0(%esi),%esi
        if (*str1 != *str2) {
80100dd0:	38 d1                	cmp    %dl,%cl
80100dd2:	0f 85 36 01 00 00    	jne    80100f0e <exec+0x3fe>
    while (*str1 != '\0' && *str2 != '\0') {
80100dd8:	0f be 0c 06          	movsbl (%esi,%eax,1),%ecx
80100ddc:	0f be 90 8d 73 10 80 	movsbl -0x7fef8c73(%eax),%edx
80100de3:	84 c9                	test   %cl,%cl
80100de5:	0f 84 16 01 00 00    	je     80100f01 <exec+0x3f1>
80100deb:	83 c0 01             	add    $0x1,%eax
80100dee:	84 d2                	test   %dl,%dl
80100df0:	75 de                	jne    80100dd0 <exec+0x2c0>
    return *str1 - *str2; // In case strings are of different lengths
80100df2:	8b b5 e4 fe ff ff    	mov    -0x11c(%ebp),%esi
80100df8:	0f be c1             	movsbl %cl,%eax
80100dfb:	29 d0                	sub    %edx,%eax
  if(my_strcmp(argv[0], "cat") == 0 && argc > 1)
80100dfd:	85 c0                	test   %eax,%eax
80100dff:	75 1e                	jne    80100e1f <exec+0x30f>
80100e01:	83 fb 01             	cmp    $0x1,%ebx
80100e04:	76 19                	jbe    80100e1f <exec+0x30f>
    safestrcpy(last_cat_arg, argv[argc-1], sizeof(last_cat_arg));
80100e06:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e09:	83 ec 04             	sub    $0x4,%esp
80100e0c:	6a 40                	push   $0x40
80100e0e:	ff 74 98 fc          	push   -0x4(%eax,%ebx,4)
80100e12:	68 20 a0 10 80       	push   $0x8010a020
80100e17:	e8 24 3b 00 00       	call   80104940 <safestrcpy>
80100e1c:	83 c4 10             	add    $0x10,%esp
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e1f:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
80100e26:	89 f2                	mov    %esi,%edx
  ustack[1] = argc;
80100e28:	89 9d 5c ff ff ff    	mov    %ebx,-0xa4(%ebp)
  ustack[0] = 0xffffffff;  // fake return PC
80100e2e:	c7 85 58 ff ff ff ff 	movl   $0xffffffff,-0xa8(%ebp)
80100e35:	ff ff ff 
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e38:	29 c2                	sub    %eax,%edx
  sp -= (3+argc+1) * 4;
80100e3a:	83 c0 0c             	add    $0xc,%eax
80100e3d:	29 c6                	sub    %eax,%esi
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e3f:	50                   	push   %eax
80100e40:	57                   	push   %edi
  sp -= (3+argc+1) * 4;
80100e41:	89 f3                	mov    %esi,%ebx
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e43:	56                   	push   %esi
80100e44:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e4a:	89 95 60 ff ff ff    	mov    %edx,-0xa0(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e50:	e8 cb 63 00 00       	call   80107220 <copyout>
80100e55:	83 c4 10             	add    $0x10,%esp
80100e58:	85 c0                	test   %eax,%eax
80100e5a:	0f 88 0c ff ff ff    	js     80100d6c <exec+0x25c>
  for(last=s=path; *s; s++)
80100e60:	8b 45 08             	mov    0x8(%ebp),%eax
80100e63:	8b 55 08             	mov    0x8(%ebp),%edx
80100e66:	8b 4d 08             	mov    0x8(%ebp),%ecx
80100e69:	0f b6 00             	movzbl (%eax),%eax
80100e6c:	84 c0                	test   %al,%al
80100e6e:	74 0f                	je     80100e7f <exec+0x36f>
      last = s+1;
80100e70:	83 c1 01             	add    $0x1,%ecx
80100e73:	3c 2f                	cmp    $0x2f,%al
  for(last=s=path; *s; s++)
80100e75:	0f b6 01             	movzbl (%ecx),%eax
      last = s+1;
80100e78:	0f 44 d1             	cmove  %ecx,%edx
  for(last=s=path; *s; s++)
80100e7b:	84 c0                	test   %al,%al
80100e7d:	75 f1                	jne    80100e70 <exec+0x360>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100e7f:	8b bd ec fe ff ff    	mov    -0x114(%ebp),%edi
80100e85:	83 ec 04             	sub    $0x4,%esp
80100e88:	6a 10                	push   $0x10
80100e8a:	89 f8                	mov    %edi,%eax
80100e8c:	52                   	push   %edx
80100e8d:	83 c0 6c             	add    $0x6c,%eax
80100e90:	50                   	push   %eax
80100e91:	e8 aa 3a 00 00       	call   80104940 <safestrcpy>
  curproc->pgdir = pgdir;
80100e96:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
  oldpgdir = curproc->pgdir;
80100e9c:	8b 77 04             	mov    0x4(%edi),%esi
  curproc->tf->eip = elf.entry;  // main
80100e9f:	8b 47 18             	mov    0x18(%edi),%eax
  curproc->pgdir = pgdir;
80100ea2:	89 57 04             	mov    %edx,0x4(%edi)
  curproc->sz = sz;
80100ea5:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100eab:	89 17                	mov    %edx,(%edi)
  curproc->tf->eip = elf.entry;  // main
80100ead:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
80100eb3:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100eb6:	8b 47 18             	mov    0x18(%edi),%eax
80100eb9:	89 58 44             	mov    %ebx,0x44(%eax)
  switchuvm(curproc);
80100ebc:	89 3c 24             	mov    %edi,(%esp)
80100ebf:	e8 8c 5c 00 00       	call   80106b50 <switchuvm>
  freevm(oldpgdir);
80100ec4:	89 34 24             	mov    %esi,(%esp)
80100ec7:	e8 64 60 00 00       	call   80106f30 <freevm>
  return 0;
80100ecc:	83 c4 10             	add    $0x10,%esp
80100ecf:	31 c0                	xor    %eax,%eax
80100ed1:	e9 a6 fc ff ff       	jmp    80100b7c <exec+0x6c>
    end_op();
80100ed6:	e8 15 20 00 00       	call   80102ef0 <end_op>
    cprintf("exec: fail\n");
80100edb:	83 ec 0c             	sub    $0xc,%esp
80100ede:	68 81 73 10 80       	push   $0x80107381
80100ee3:	e8 b8 f7 ff ff       	call   801006a0 <cprintf>
    return -1;
80100ee8:	83 c4 10             	add    $0x10,%esp
80100eeb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ef0:	e9 87 fc ff ff       	jmp    80100b7c <exec+0x6c>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100ef5:	be 00 20 00 00       	mov    $0x2000,%esi
80100efa:	31 ff                	xor    %edi,%edi
80100efc:	e9 a7 fd ff ff       	jmp    80100ca8 <exec+0x198>
80100f01:	8b b5 e4 fe ff ff    	mov    -0x11c(%ebp),%esi
80100f07:	31 c0                	xor    %eax,%eax
80100f09:	e9 ed fe ff ff       	jmp    80100dfb <exec+0x2eb>
            return *str1 - *str2; // Return the ASCII difference
80100f0e:	89 c8                	mov    %ecx,%eax
80100f10:	8b b5 e4 fe ff ff    	mov    -0x11c(%ebp),%esi
80100f16:	29 d0                	sub    %edx,%eax
80100f18:	e9 e0 fe ff ff       	jmp    80100dfd <exec+0x2ed>
    while (*str1 != '\0' && *str2 != '\0') {
80100f1d:	ba 63 00 00 00       	mov    $0x63,%edx
80100f22:	31 c0                	xor    %eax,%eax
80100f24:	e9 d2 fe ff ff       	jmp    80100dfb <exec+0x2eb>
80100f29:	66 90                	xchg   %ax,%ax
80100f2b:	66 90                	xchg   %ax,%ax
80100f2d:	66 90                	xchg   %ax,%ax
80100f2f:	90                   	nop

80100f30 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f30:	55                   	push   %ebp
80100f31:	89 e5                	mov    %esp,%ebp
80100f33:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
80100f36:	68 91 73 10 80       	push   $0x80107391
80100f3b:	68 a0 ef 10 80       	push   $0x8010efa0
80100f40:	e8 ab 35 00 00       	call   801044f0 <initlock>
}
80100f45:	83 c4 10             	add    $0x10,%esp
80100f48:	c9                   	leave  
80100f49:	c3                   	ret    
80100f4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80100f50 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f50:	55                   	push   %ebp
80100f51:	89 e5                	mov    %esp,%ebp
80100f53:	53                   	push   %ebx
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f54:	bb d4 ef 10 80       	mov    $0x8010efd4,%ebx
{
80100f59:	83 ec 10             	sub    $0x10,%esp
  acquire(&ftable.lock);
80100f5c:	68 a0 ef 10 80       	push   $0x8010efa0
80100f61:	e8 5a 37 00 00       	call   801046c0 <acquire>
80100f66:	83 c4 10             	add    $0x10,%esp
80100f69:	eb 10                	jmp    80100f7b <filealloc+0x2b>
80100f6b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100f6f:	90                   	nop
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f70:	83 c3 18             	add    $0x18,%ebx
80100f73:	81 fb 34 f9 10 80    	cmp    $0x8010f934,%ebx
80100f79:	74 25                	je     80100fa0 <filealloc+0x50>
    if(f->ref == 0){
80100f7b:	8b 43 04             	mov    0x4(%ebx),%eax
80100f7e:	85 c0                	test   %eax,%eax
80100f80:	75 ee                	jne    80100f70 <filealloc+0x20>
      f->ref = 1;
      release(&ftable.lock);
80100f82:	83 ec 0c             	sub    $0xc,%esp
      f->ref = 1;
80100f85:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100f8c:	68 a0 ef 10 80       	push   $0x8010efa0
80100f91:	e8 ca 36 00 00       	call   80104660 <release>
      return f;
    }
  }
  release(&ftable.lock);
  return 0;
}
80100f96:	89 d8                	mov    %ebx,%eax
      return f;
80100f98:	83 c4 10             	add    $0x10,%esp
}
80100f9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100f9e:	c9                   	leave  
80100f9f:	c3                   	ret    
  release(&ftable.lock);
80100fa0:	83 ec 0c             	sub    $0xc,%esp
  return 0;
80100fa3:	31 db                	xor    %ebx,%ebx
  release(&ftable.lock);
80100fa5:	68 a0 ef 10 80       	push   $0x8010efa0
80100faa:	e8 b1 36 00 00       	call   80104660 <release>
}
80100faf:	89 d8                	mov    %ebx,%eax
  return 0;
80100fb1:	83 c4 10             	add    $0x10,%esp
}
80100fb4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100fb7:	c9                   	leave  
80100fb8:	c3                   	ret    
80100fb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80100fc0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100fc0:	55                   	push   %ebp
80100fc1:	89 e5                	mov    %esp,%ebp
80100fc3:	53                   	push   %ebx
80100fc4:	83 ec 10             	sub    $0x10,%esp
80100fc7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100fca:	68 a0 ef 10 80       	push   $0x8010efa0
80100fcf:	e8 ec 36 00 00       	call   801046c0 <acquire>
  if(f->ref < 1)
80100fd4:	8b 43 04             	mov    0x4(%ebx),%eax
80100fd7:	83 c4 10             	add    $0x10,%esp
80100fda:	85 c0                	test   %eax,%eax
80100fdc:	7e 1a                	jle    80100ff8 <filedup+0x38>
    panic("filedup");
  f->ref++;
80100fde:	83 c0 01             	add    $0x1,%eax
  release(&ftable.lock);
80100fe1:	83 ec 0c             	sub    $0xc,%esp
  f->ref++;
80100fe4:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100fe7:	68 a0 ef 10 80       	push   $0x8010efa0
80100fec:	e8 6f 36 00 00       	call   80104660 <release>
  return f;
}
80100ff1:	89 d8                	mov    %ebx,%eax
80100ff3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100ff6:	c9                   	leave  
80100ff7:	c3                   	ret    
    panic("filedup");
80100ff8:	83 ec 0c             	sub    $0xc,%esp
80100ffb:	68 98 73 10 80       	push   $0x80107398
80101000:	e8 7b f3 ff ff       	call   80100380 <panic>
80101005:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010100c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101010 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101010:	55                   	push   %ebp
80101011:	89 e5                	mov    %esp,%ebp
80101013:	57                   	push   %edi
80101014:	56                   	push   %esi
80101015:	53                   	push   %ebx
80101016:	83 ec 28             	sub    $0x28,%esp
80101019:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
8010101c:	68 a0 ef 10 80       	push   $0x8010efa0
80101021:	e8 9a 36 00 00       	call   801046c0 <acquire>
  if(f->ref < 1)
80101026:	8b 53 04             	mov    0x4(%ebx),%edx
80101029:	83 c4 10             	add    $0x10,%esp
8010102c:	85 d2                	test   %edx,%edx
8010102e:	0f 8e a5 00 00 00    	jle    801010d9 <fileclose+0xc9>
    panic("fileclose");
  if(--f->ref > 0){
80101034:	83 ea 01             	sub    $0x1,%edx
80101037:	89 53 04             	mov    %edx,0x4(%ebx)
8010103a:	75 44                	jne    80101080 <fileclose+0x70>
    release(&ftable.lock);
    return;
  }
  ff = *f;
8010103c:	0f b6 43 09          	movzbl 0x9(%ebx),%eax
  f->ref = 0;
  f->type = FD_NONE;
  release(&ftable.lock);
80101040:	83 ec 0c             	sub    $0xc,%esp
  ff = *f;
80101043:	8b 3b                	mov    (%ebx),%edi
  f->type = FD_NONE;
80101045:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  ff = *f;
8010104b:	8b 73 0c             	mov    0xc(%ebx),%esi
8010104e:	88 45 e7             	mov    %al,-0x19(%ebp)
80101051:	8b 43 10             	mov    0x10(%ebx),%eax
  release(&ftable.lock);
80101054:	68 a0 ef 10 80       	push   $0x8010efa0
  ff = *f;
80101059:	89 45 e0             	mov    %eax,-0x20(%ebp)
  release(&ftable.lock);
8010105c:	e8 ff 35 00 00       	call   80104660 <release>

  if(ff.type == FD_PIPE)
80101061:	83 c4 10             	add    $0x10,%esp
80101064:	83 ff 01             	cmp    $0x1,%edi
80101067:	74 57                	je     801010c0 <fileclose+0xb0>
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE){
80101069:	83 ff 02             	cmp    $0x2,%edi
8010106c:	74 2a                	je     80101098 <fileclose+0x88>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
8010106e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101071:	5b                   	pop    %ebx
80101072:	5e                   	pop    %esi
80101073:	5f                   	pop    %edi
80101074:	5d                   	pop    %ebp
80101075:	c3                   	ret    
80101076:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010107d:	8d 76 00             	lea    0x0(%esi),%esi
    release(&ftable.lock);
80101080:	c7 45 08 a0 ef 10 80 	movl   $0x8010efa0,0x8(%ebp)
}
80101087:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010108a:	5b                   	pop    %ebx
8010108b:	5e                   	pop    %esi
8010108c:	5f                   	pop    %edi
8010108d:	5d                   	pop    %ebp
    release(&ftable.lock);
8010108e:	e9 cd 35 00 00       	jmp    80104660 <release>
80101093:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101097:	90                   	nop
    begin_op();
80101098:	e8 e3 1d 00 00       	call   80102e80 <begin_op>
    iput(ff.ip);
8010109d:	83 ec 0c             	sub    $0xc,%esp
801010a0:	ff 75 e0             	push   -0x20(%ebp)
801010a3:	e8 28 09 00 00       	call   801019d0 <iput>
    end_op();
801010a8:	83 c4 10             	add    $0x10,%esp
}
801010ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
801010ae:	5b                   	pop    %ebx
801010af:	5e                   	pop    %esi
801010b0:	5f                   	pop    %edi
801010b1:	5d                   	pop    %ebp
    end_op();
801010b2:	e9 39 1e 00 00       	jmp    80102ef0 <end_op>
801010b7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801010be:	66 90                	xchg   %ax,%ax
    pipeclose(ff.pipe, ff.writable);
801010c0:	0f be 5d e7          	movsbl -0x19(%ebp),%ebx
801010c4:	83 ec 08             	sub    $0x8,%esp
801010c7:	53                   	push   %ebx
801010c8:	56                   	push   %esi
801010c9:	e8 82 25 00 00       	call   80103650 <pipeclose>
801010ce:	83 c4 10             	add    $0x10,%esp
}
801010d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801010d4:	5b                   	pop    %ebx
801010d5:	5e                   	pop    %esi
801010d6:	5f                   	pop    %edi
801010d7:	5d                   	pop    %ebp
801010d8:	c3                   	ret    
    panic("fileclose");
801010d9:	83 ec 0c             	sub    $0xc,%esp
801010dc:	68 a0 73 10 80       	push   $0x801073a0
801010e1:	e8 9a f2 ff ff       	call   80100380 <panic>
801010e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801010ed:	8d 76 00             	lea    0x0(%esi),%esi

801010f0 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801010f0:	55                   	push   %ebp
801010f1:	89 e5                	mov    %esp,%ebp
801010f3:	53                   	push   %ebx
801010f4:	83 ec 04             	sub    $0x4,%esp
801010f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
801010fa:	83 3b 02             	cmpl   $0x2,(%ebx)
801010fd:	75 31                	jne    80101130 <filestat+0x40>
    ilock(f->ip);
801010ff:	83 ec 0c             	sub    $0xc,%esp
80101102:	ff 73 10             	push   0x10(%ebx)
80101105:	e8 96 07 00 00       	call   801018a0 <ilock>
    stati(f->ip, st);
8010110a:	58                   	pop    %eax
8010110b:	5a                   	pop    %edx
8010110c:	ff 75 0c             	push   0xc(%ebp)
8010110f:	ff 73 10             	push   0x10(%ebx)
80101112:	e8 69 0a 00 00       	call   80101b80 <stati>
    iunlock(f->ip);
80101117:	59                   	pop    %ecx
80101118:	ff 73 10             	push   0x10(%ebx)
8010111b:	e8 60 08 00 00       	call   80101980 <iunlock>
    return 0;
  }
  return -1;
}
80101120:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    return 0;
80101123:	83 c4 10             	add    $0x10,%esp
80101126:	31 c0                	xor    %eax,%eax
}
80101128:	c9                   	leave  
80101129:	c3                   	ret    
8010112a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80101130:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  return -1;
80101133:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101138:	c9                   	leave  
80101139:	c3                   	ret    
8010113a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101140 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101140:	55                   	push   %ebp
80101141:	89 e5                	mov    %esp,%ebp
80101143:	57                   	push   %edi
80101144:	56                   	push   %esi
80101145:	53                   	push   %ebx
80101146:	83 ec 0c             	sub    $0xc,%esp
80101149:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010114c:	8b 75 0c             	mov    0xc(%ebp),%esi
8010114f:	8b 7d 10             	mov    0x10(%ebp),%edi
  int r;

  if(f->readable == 0)
80101152:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80101156:	74 60                	je     801011b8 <fileread+0x78>
    return -1;
  if(f->type == FD_PIPE)
80101158:	8b 03                	mov    (%ebx),%eax
8010115a:	83 f8 01             	cmp    $0x1,%eax
8010115d:	74 41                	je     801011a0 <fileread+0x60>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
8010115f:	83 f8 02             	cmp    $0x2,%eax
80101162:	75 5b                	jne    801011bf <fileread+0x7f>
    ilock(f->ip);
80101164:	83 ec 0c             	sub    $0xc,%esp
80101167:	ff 73 10             	push   0x10(%ebx)
8010116a:	e8 31 07 00 00       	call   801018a0 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010116f:	57                   	push   %edi
80101170:	ff 73 14             	push   0x14(%ebx)
80101173:	56                   	push   %esi
80101174:	ff 73 10             	push   0x10(%ebx)
80101177:	e8 34 0a 00 00       	call   80101bb0 <readi>
8010117c:	83 c4 20             	add    $0x20,%esp
8010117f:	89 c6                	mov    %eax,%esi
80101181:	85 c0                	test   %eax,%eax
80101183:	7e 03                	jle    80101188 <fileread+0x48>
      f->off += r;
80101185:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80101188:	83 ec 0c             	sub    $0xc,%esp
8010118b:	ff 73 10             	push   0x10(%ebx)
8010118e:	e8 ed 07 00 00       	call   80101980 <iunlock>
    return r;
80101193:	83 c4 10             	add    $0x10,%esp
  }
  panic("fileread");
}
80101196:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101199:	89 f0                	mov    %esi,%eax
8010119b:	5b                   	pop    %ebx
8010119c:	5e                   	pop    %esi
8010119d:	5f                   	pop    %edi
8010119e:	5d                   	pop    %ebp
8010119f:	c3                   	ret    
    return piperead(f->pipe, addr, n);
801011a0:	8b 43 0c             	mov    0xc(%ebx),%eax
801011a3:	89 45 08             	mov    %eax,0x8(%ebp)
}
801011a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801011a9:	5b                   	pop    %ebx
801011aa:	5e                   	pop    %esi
801011ab:	5f                   	pop    %edi
801011ac:	5d                   	pop    %ebp
    return piperead(f->pipe, addr, n);
801011ad:	e9 3e 26 00 00       	jmp    801037f0 <piperead>
801011b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
801011b8:	be ff ff ff ff       	mov    $0xffffffff,%esi
801011bd:	eb d7                	jmp    80101196 <fileread+0x56>
  panic("fileread");
801011bf:	83 ec 0c             	sub    $0xc,%esp
801011c2:	68 aa 73 10 80       	push   $0x801073aa
801011c7:	e8 b4 f1 ff ff       	call   80100380 <panic>
801011cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801011d0 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801011d0:	55                   	push   %ebp
801011d1:	89 e5                	mov    %esp,%ebp
801011d3:	57                   	push   %edi
801011d4:	56                   	push   %esi
801011d5:	53                   	push   %ebx
801011d6:	83 ec 1c             	sub    $0x1c,%esp
801011d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801011dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
801011df:	89 45 dc             	mov    %eax,-0x24(%ebp)
801011e2:	8b 45 10             	mov    0x10(%ebp),%eax
  int r;

  if(f->writable == 0)
801011e5:	80 7b 09 00          	cmpb   $0x0,0x9(%ebx)
{
801011e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(f->writable == 0)
801011ec:	0f 84 bd 00 00 00    	je     801012af <filewrite+0xdf>
    return -1;
  if(f->type == FD_PIPE)
801011f2:	8b 03                	mov    (%ebx),%eax
801011f4:	83 f8 01             	cmp    $0x1,%eax
801011f7:	0f 84 bf 00 00 00    	je     801012bc <filewrite+0xec>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
801011fd:	83 f8 02             	cmp    $0x2,%eax
80101200:	0f 85 c8 00 00 00    	jne    801012ce <filewrite+0xfe>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101206:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    int i = 0;
80101209:	31 f6                	xor    %esi,%esi
    while(i < n){
8010120b:	85 c0                	test   %eax,%eax
8010120d:	7f 30                	jg     8010123f <filewrite+0x6f>
8010120f:	e9 94 00 00 00       	jmp    801012a8 <filewrite+0xd8>
80101214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
        f->off += r;
80101218:	01 43 14             	add    %eax,0x14(%ebx)
      iunlock(f->ip);
8010121b:	83 ec 0c             	sub    $0xc,%esp
8010121e:	ff 73 10             	push   0x10(%ebx)
        f->off += r;
80101221:	89 45 e0             	mov    %eax,-0x20(%ebp)
      iunlock(f->ip);
80101224:	e8 57 07 00 00       	call   80101980 <iunlock>
      end_op();
80101229:	e8 c2 1c 00 00       	call   80102ef0 <end_op>

      if(r < 0)
        break;
      if(r != n1)
8010122e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101231:	83 c4 10             	add    $0x10,%esp
80101234:	39 c7                	cmp    %eax,%edi
80101236:	75 5c                	jne    80101294 <filewrite+0xc4>
        panic("short filewrite");
      i += r;
80101238:	01 fe                	add    %edi,%esi
    while(i < n){
8010123a:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
8010123d:	7e 69                	jle    801012a8 <filewrite+0xd8>
      int n1 = n - i;
8010123f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80101242:	b8 00 06 00 00       	mov    $0x600,%eax
80101247:	29 f7                	sub    %esi,%edi
80101249:	39 c7                	cmp    %eax,%edi
8010124b:	0f 4f f8             	cmovg  %eax,%edi
      begin_op();
8010124e:	e8 2d 1c 00 00       	call   80102e80 <begin_op>
      ilock(f->ip);
80101253:	83 ec 0c             	sub    $0xc,%esp
80101256:	ff 73 10             	push   0x10(%ebx)
80101259:	e8 42 06 00 00       	call   801018a0 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010125e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101261:	57                   	push   %edi
80101262:	ff 73 14             	push   0x14(%ebx)
80101265:	01 f0                	add    %esi,%eax
80101267:	50                   	push   %eax
80101268:	ff 73 10             	push   0x10(%ebx)
8010126b:	e8 40 0a 00 00       	call   80101cb0 <writei>
80101270:	83 c4 20             	add    $0x20,%esp
80101273:	85 c0                	test   %eax,%eax
80101275:	7f a1                	jg     80101218 <filewrite+0x48>
      iunlock(f->ip);
80101277:	83 ec 0c             	sub    $0xc,%esp
8010127a:	ff 73 10             	push   0x10(%ebx)
8010127d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101280:	e8 fb 06 00 00       	call   80101980 <iunlock>
      end_op();
80101285:	e8 66 1c 00 00       	call   80102ef0 <end_op>
      if(r < 0)
8010128a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010128d:	83 c4 10             	add    $0x10,%esp
80101290:	85 c0                	test   %eax,%eax
80101292:	75 1b                	jne    801012af <filewrite+0xdf>
        panic("short filewrite");
80101294:	83 ec 0c             	sub    $0xc,%esp
80101297:	68 b3 73 10 80       	push   $0x801073b3
8010129c:	e8 df f0 ff ff       	call   80100380 <panic>
801012a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    }
    return i == n ? n : -1;
801012a8:	89 f0                	mov    %esi,%eax
801012aa:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
801012ad:	74 05                	je     801012b4 <filewrite+0xe4>
801012af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  panic("filewrite");
}
801012b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801012b7:	5b                   	pop    %ebx
801012b8:	5e                   	pop    %esi
801012b9:	5f                   	pop    %edi
801012ba:	5d                   	pop    %ebp
801012bb:	c3                   	ret    
    return pipewrite(f->pipe, addr, n);
801012bc:	8b 43 0c             	mov    0xc(%ebx),%eax
801012bf:	89 45 08             	mov    %eax,0x8(%ebp)
}
801012c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801012c5:	5b                   	pop    %ebx
801012c6:	5e                   	pop    %esi
801012c7:	5f                   	pop    %edi
801012c8:	5d                   	pop    %ebp
    return pipewrite(f->pipe, addr, n);
801012c9:	e9 22 24 00 00       	jmp    801036f0 <pipewrite>
  panic("filewrite");
801012ce:	83 ec 0c             	sub    $0xc,%esp
801012d1:	68 b9 73 10 80       	push   $0x801073b9
801012d6:	e8 a5 f0 ff ff       	call   80100380 <panic>
801012db:	66 90                	xchg   %ax,%ax
801012dd:	66 90                	xchg   %ax,%ax
801012df:	90                   	nop

801012e0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
801012e0:	55                   	push   %ebp
801012e1:	89 c1                	mov    %eax,%ecx
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
801012e3:	89 d0                	mov    %edx,%eax
801012e5:	c1 e8 0c             	shr    $0xc,%eax
801012e8:	03 05 0c 16 11 80    	add    0x8011160c,%eax
{
801012ee:	89 e5                	mov    %esp,%ebp
801012f0:	56                   	push   %esi
801012f1:	53                   	push   %ebx
801012f2:	89 d3                	mov    %edx,%ebx
  bp = bread(dev, BBLOCK(b, sb));
801012f4:	83 ec 08             	sub    $0x8,%esp
801012f7:	50                   	push   %eax
801012f8:	51                   	push   %ecx
801012f9:	e8 d2 ed ff ff       	call   801000d0 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
801012fe:	89 d9                	mov    %ebx,%ecx
  if((bp->data[bi/8] & m) == 0)
80101300:	c1 fb 03             	sar    $0x3,%ebx
80101303:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101306:	89 c6                	mov    %eax,%esi
  m = 1 << (bi % 8);
80101308:	83 e1 07             	and    $0x7,%ecx
8010130b:	b8 01 00 00 00       	mov    $0x1,%eax
  if((bp->data[bi/8] & m) == 0)
80101310:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
  m = 1 << (bi % 8);
80101316:	d3 e0                	shl    %cl,%eax
  if((bp->data[bi/8] & m) == 0)
80101318:	0f b6 4c 1e 5c       	movzbl 0x5c(%esi,%ebx,1),%ecx
8010131d:	85 c1                	test   %eax,%ecx
8010131f:	74 23                	je     80101344 <bfree+0x64>
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
80101321:	f7 d0                	not    %eax
  log_write(bp);
80101323:	83 ec 0c             	sub    $0xc,%esp
  bp->data[bi/8] &= ~m;
80101326:	21 c8                	and    %ecx,%eax
80101328:	88 44 1e 5c          	mov    %al,0x5c(%esi,%ebx,1)
  log_write(bp);
8010132c:	56                   	push   %esi
8010132d:	e8 2e 1d 00 00       	call   80103060 <log_write>
  brelse(bp);
80101332:	89 34 24             	mov    %esi,(%esp)
80101335:	e8 b6 ee ff ff       	call   801001f0 <brelse>
}
8010133a:	83 c4 10             	add    $0x10,%esp
8010133d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101340:	5b                   	pop    %ebx
80101341:	5e                   	pop    %esi
80101342:	5d                   	pop    %ebp
80101343:	c3                   	ret    
    panic("freeing free block");
80101344:	83 ec 0c             	sub    $0xc,%esp
80101347:	68 c3 73 10 80       	push   $0x801073c3
8010134c:	e8 2f f0 ff ff       	call   80100380 <panic>
80101351:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101358:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010135f:	90                   	nop

80101360 <balloc>:
{
80101360:	55                   	push   %ebp
80101361:	89 e5                	mov    %esp,%ebp
80101363:	57                   	push   %edi
80101364:	56                   	push   %esi
80101365:	53                   	push   %ebx
80101366:	83 ec 1c             	sub    $0x1c,%esp
  for(b = 0; b < sb.size; b += BPB){
80101369:	8b 0d f4 15 11 80    	mov    0x801115f4,%ecx
{
8010136f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101372:	85 c9                	test   %ecx,%ecx
80101374:	0f 84 87 00 00 00    	je     80101401 <balloc+0xa1>
8010137a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    bp = bread(dev, BBLOCK(b, sb));
80101381:	8b 75 dc             	mov    -0x24(%ebp),%esi
80101384:	83 ec 08             	sub    $0x8,%esp
80101387:	89 f0                	mov    %esi,%eax
80101389:	c1 f8 0c             	sar    $0xc,%eax
8010138c:	03 05 0c 16 11 80    	add    0x8011160c,%eax
80101392:	50                   	push   %eax
80101393:	ff 75 d8             	push   -0x28(%ebp)
80101396:	e8 35 ed ff ff       	call   801000d0 <bread>
8010139b:	83 c4 10             	add    $0x10,%esp
8010139e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801013a1:	a1 f4 15 11 80       	mov    0x801115f4,%eax
801013a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
801013a9:	31 c0                	xor    %eax,%eax
801013ab:	eb 2f                	jmp    801013dc <balloc+0x7c>
801013ad:	8d 76 00             	lea    0x0(%esi),%esi
      m = 1 << (bi % 8);
801013b0:	89 c1                	mov    %eax,%ecx
801013b2:	bb 01 00 00 00       	mov    $0x1,%ebx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801013b7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
      m = 1 << (bi % 8);
801013ba:	83 e1 07             	and    $0x7,%ecx
801013bd:	d3 e3                	shl    %cl,%ebx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801013bf:	89 c1                	mov    %eax,%ecx
801013c1:	c1 f9 03             	sar    $0x3,%ecx
801013c4:	0f b6 7c 0a 5c       	movzbl 0x5c(%edx,%ecx,1),%edi
801013c9:	89 fa                	mov    %edi,%edx
801013cb:	85 df                	test   %ebx,%edi
801013cd:	74 41                	je     80101410 <balloc+0xb0>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801013cf:	83 c0 01             	add    $0x1,%eax
801013d2:	83 c6 01             	add    $0x1,%esi
801013d5:	3d 00 10 00 00       	cmp    $0x1000,%eax
801013da:	74 05                	je     801013e1 <balloc+0x81>
801013dc:	39 75 e0             	cmp    %esi,-0x20(%ebp)
801013df:	77 cf                	ja     801013b0 <balloc+0x50>
    brelse(bp);
801013e1:	83 ec 0c             	sub    $0xc,%esp
801013e4:	ff 75 e4             	push   -0x1c(%ebp)
801013e7:	e8 04 ee ff ff       	call   801001f0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
801013ec:	81 45 dc 00 10 00 00 	addl   $0x1000,-0x24(%ebp)
801013f3:	83 c4 10             	add    $0x10,%esp
801013f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801013f9:	39 05 f4 15 11 80    	cmp    %eax,0x801115f4
801013ff:	77 80                	ja     80101381 <balloc+0x21>
  panic("balloc: out of blocks");
80101401:	83 ec 0c             	sub    $0xc,%esp
80101404:	68 d6 73 10 80       	push   $0x801073d6
80101409:	e8 72 ef ff ff       	call   80100380 <panic>
8010140e:	66 90                	xchg   %ax,%ax
        bp->data[bi/8] |= m;  // Mark block in use.
80101410:	8b 7d e4             	mov    -0x1c(%ebp),%edi
        log_write(bp);
80101413:	83 ec 0c             	sub    $0xc,%esp
        bp->data[bi/8] |= m;  // Mark block in use.
80101416:	09 da                	or     %ebx,%edx
80101418:	88 54 0f 5c          	mov    %dl,0x5c(%edi,%ecx,1)
        log_write(bp);
8010141c:	57                   	push   %edi
8010141d:	e8 3e 1c 00 00       	call   80103060 <log_write>
        brelse(bp);
80101422:	89 3c 24             	mov    %edi,(%esp)
80101425:	e8 c6 ed ff ff       	call   801001f0 <brelse>
  bp = bread(dev, bno);
8010142a:	58                   	pop    %eax
8010142b:	5a                   	pop    %edx
8010142c:	56                   	push   %esi
8010142d:	ff 75 d8             	push   -0x28(%ebp)
80101430:	e8 9b ec ff ff       	call   801000d0 <bread>
  memset(bp->data, 0, BSIZE);
80101435:	83 c4 0c             	add    $0xc,%esp
  bp = bread(dev, bno);
80101438:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
8010143a:	8d 40 5c             	lea    0x5c(%eax),%eax
8010143d:	68 00 02 00 00       	push   $0x200
80101442:	6a 00                	push   $0x0
80101444:	50                   	push   %eax
80101445:	e8 36 33 00 00       	call   80104780 <memset>
  log_write(bp);
8010144a:	89 1c 24             	mov    %ebx,(%esp)
8010144d:	e8 0e 1c 00 00       	call   80103060 <log_write>
  brelse(bp);
80101452:	89 1c 24             	mov    %ebx,(%esp)
80101455:	e8 96 ed ff ff       	call   801001f0 <brelse>
}
8010145a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010145d:	89 f0                	mov    %esi,%eax
8010145f:	5b                   	pop    %ebx
80101460:	5e                   	pop    %esi
80101461:	5f                   	pop    %edi
80101462:	5d                   	pop    %ebp
80101463:	c3                   	ret    
80101464:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010146b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010146f:	90                   	nop

80101470 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101470:	55                   	push   %ebp
80101471:	89 e5                	mov    %esp,%ebp
80101473:	57                   	push   %edi
80101474:	89 c7                	mov    %eax,%edi
80101476:	56                   	push   %esi
  struct inode *ip, *empty;

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
80101477:	31 f6                	xor    %esi,%esi
{
80101479:	53                   	push   %ebx
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010147a:	bb d4 f9 10 80       	mov    $0x8010f9d4,%ebx
{
8010147f:	83 ec 28             	sub    $0x28,%esp
80101482:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  acquire(&icache.lock);
80101485:	68 a0 f9 10 80       	push   $0x8010f9a0
8010148a:	e8 31 32 00 00       	call   801046c0 <acquire>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010148f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  acquire(&icache.lock);
80101492:	83 c4 10             	add    $0x10,%esp
80101495:	eb 1b                	jmp    801014b2 <iget+0x42>
80101497:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010149e:	66 90                	xchg   %ax,%ax
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801014a0:	39 3b                	cmp    %edi,(%ebx)
801014a2:	74 6c                	je     80101510 <iget+0xa0>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801014a4:	81 c3 90 00 00 00    	add    $0x90,%ebx
801014aa:	81 fb f4 15 11 80    	cmp    $0x801115f4,%ebx
801014b0:	73 26                	jae    801014d8 <iget+0x68>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801014b2:	8b 43 08             	mov    0x8(%ebx),%eax
801014b5:	85 c0                	test   %eax,%eax
801014b7:	7f e7                	jg     801014a0 <iget+0x30>
      ip->ref++;
      release(&icache.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801014b9:	85 f6                	test   %esi,%esi
801014bb:	75 e7                	jne    801014a4 <iget+0x34>
801014bd:	85 c0                	test   %eax,%eax
801014bf:	75 76                	jne    80101537 <iget+0xc7>
801014c1:	89 de                	mov    %ebx,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801014c3:	81 c3 90 00 00 00    	add    $0x90,%ebx
801014c9:	81 fb f4 15 11 80    	cmp    $0x801115f4,%ebx
801014cf:	72 e1                	jb     801014b2 <iget+0x42>
801014d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801014d8:	85 f6                	test   %esi,%esi
801014da:	74 79                	je     80101555 <iget+0xe5>
  ip = empty;
  ip->dev = dev;
  ip->inum = inum;
  ip->ref = 1;
  ip->valid = 0;
  release(&icache.lock);
801014dc:	83 ec 0c             	sub    $0xc,%esp
  ip->dev = dev;
801014df:	89 3e                	mov    %edi,(%esi)
  ip->inum = inum;
801014e1:	89 56 04             	mov    %edx,0x4(%esi)
  ip->ref = 1;
801014e4:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->valid = 0;
801014eb:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  release(&icache.lock);
801014f2:	68 a0 f9 10 80       	push   $0x8010f9a0
801014f7:	e8 64 31 00 00       	call   80104660 <release>

  return ip;
801014fc:	83 c4 10             	add    $0x10,%esp
}
801014ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101502:	89 f0                	mov    %esi,%eax
80101504:	5b                   	pop    %ebx
80101505:	5e                   	pop    %esi
80101506:	5f                   	pop    %edi
80101507:	5d                   	pop    %ebp
80101508:	c3                   	ret    
80101509:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101510:	39 53 04             	cmp    %edx,0x4(%ebx)
80101513:	75 8f                	jne    801014a4 <iget+0x34>
      release(&icache.lock);
80101515:	83 ec 0c             	sub    $0xc,%esp
      ip->ref++;
80101518:	83 c0 01             	add    $0x1,%eax
      return ip;
8010151b:	89 de                	mov    %ebx,%esi
      release(&icache.lock);
8010151d:	68 a0 f9 10 80       	push   $0x8010f9a0
      ip->ref++;
80101522:	89 43 08             	mov    %eax,0x8(%ebx)
      release(&icache.lock);
80101525:	e8 36 31 00 00       	call   80104660 <release>
      return ip;
8010152a:	83 c4 10             	add    $0x10,%esp
}
8010152d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101530:	89 f0                	mov    %esi,%eax
80101532:	5b                   	pop    %ebx
80101533:	5e                   	pop    %esi
80101534:	5f                   	pop    %edi
80101535:	5d                   	pop    %ebp
80101536:	c3                   	ret    
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101537:	81 c3 90 00 00 00    	add    $0x90,%ebx
8010153d:	81 fb f4 15 11 80    	cmp    $0x801115f4,%ebx
80101543:	73 10                	jae    80101555 <iget+0xe5>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101545:	8b 43 08             	mov    0x8(%ebx),%eax
80101548:	85 c0                	test   %eax,%eax
8010154a:	0f 8f 50 ff ff ff    	jg     801014a0 <iget+0x30>
80101550:	e9 68 ff ff ff       	jmp    801014bd <iget+0x4d>
    panic("iget: no inodes");
80101555:	83 ec 0c             	sub    $0xc,%esp
80101558:	68 ec 73 10 80       	push   $0x801073ec
8010155d:	e8 1e ee ff ff       	call   80100380 <panic>
80101562:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101569:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101570 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101570:	55                   	push   %ebp
80101571:	89 e5                	mov    %esp,%ebp
80101573:	57                   	push   %edi
80101574:	56                   	push   %esi
80101575:	89 c6                	mov    %eax,%esi
80101577:	53                   	push   %ebx
80101578:	83 ec 1c             	sub    $0x1c,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
8010157b:	83 fa 0b             	cmp    $0xb,%edx
8010157e:	0f 86 8c 00 00 00    	jbe    80101610 <bmap+0xa0>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
80101584:	8d 5a f4             	lea    -0xc(%edx),%ebx

  if(bn < NINDIRECT){
80101587:	83 fb 7f             	cmp    $0x7f,%ebx
8010158a:	0f 87 a2 00 00 00    	ja     80101632 <bmap+0xc2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101590:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101596:	85 c0                	test   %eax,%eax
80101598:	74 5e                	je     801015f8 <bmap+0x88>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
8010159a:	83 ec 08             	sub    $0x8,%esp
8010159d:	50                   	push   %eax
8010159e:	ff 36                	push   (%esi)
801015a0:	e8 2b eb ff ff       	call   801000d0 <bread>
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
801015a5:	83 c4 10             	add    $0x10,%esp
801015a8:	8d 5c 98 5c          	lea    0x5c(%eax,%ebx,4),%ebx
    bp = bread(ip->dev, addr);
801015ac:	89 c2                	mov    %eax,%edx
    if((addr = a[bn]) == 0){
801015ae:	8b 3b                	mov    (%ebx),%edi
801015b0:	85 ff                	test   %edi,%edi
801015b2:	74 1c                	je     801015d0 <bmap+0x60>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
801015b4:	83 ec 0c             	sub    $0xc,%esp
801015b7:	52                   	push   %edx
801015b8:	e8 33 ec ff ff       	call   801001f0 <brelse>
801015bd:	83 c4 10             	add    $0x10,%esp
    return addr;
  }

  panic("bmap: out of range");
}
801015c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801015c3:	89 f8                	mov    %edi,%eax
801015c5:	5b                   	pop    %ebx
801015c6:	5e                   	pop    %esi
801015c7:	5f                   	pop    %edi
801015c8:	5d                   	pop    %ebp
801015c9:	c3                   	ret    
801015ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801015d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      a[bn] = addr = balloc(ip->dev);
801015d3:	8b 06                	mov    (%esi),%eax
801015d5:	e8 86 fd ff ff       	call   80101360 <balloc>
      log_write(bp);
801015da:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801015dd:	83 ec 0c             	sub    $0xc,%esp
      a[bn] = addr = balloc(ip->dev);
801015e0:	89 03                	mov    %eax,(%ebx)
801015e2:	89 c7                	mov    %eax,%edi
      log_write(bp);
801015e4:	52                   	push   %edx
801015e5:	e8 76 1a 00 00       	call   80103060 <log_write>
801015ea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801015ed:	83 c4 10             	add    $0x10,%esp
801015f0:	eb c2                	jmp    801015b4 <bmap+0x44>
801015f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
801015f8:	8b 06                	mov    (%esi),%eax
801015fa:	e8 61 fd ff ff       	call   80101360 <balloc>
801015ff:	89 86 8c 00 00 00    	mov    %eax,0x8c(%esi)
80101605:	eb 93                	jmp    8010159a <bmap+0x2a>
80101607:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010160e:	66 90                	xchg   %ax,%ax
    if((addr = ip->addrs[bn]) == 0)
80101610:	8d 5a 14             	lea    0x14(%edx),%ebx
80101613:	8b 7c 98 0c          	mov    0xc(%eax,%ebx,4),%edi
80101617:	85 ff                	test   %edi,%edi
80101619:	75 a5                	jne    801015c0 <bmap+0x50>
      ip->addrs[bn] = addr = balloc(ip->dev);
8010161b:	8b 00                	mov    (%eax),%eax
8010161d:	e8 3e fd ff ff       	call   80101360 <balloc>
80101622:	89 44 9e 0c          	mov    %eax,0xc(%esi,%ebx,4)
80101626:	89 c7                	mov    %eax,%edi
}
80101628:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010162b:	5b                   	pop    %ebx
8010162c:	89 f8                	mov    %edi,%eax
8010162e:	5e                   	pop    %esi
8010162f:	5f                   	pop    %edi
80101630:	5d                   	pop    %ebp
80101631:	c3                   	ret    
  panic("bmap: out of range");
80101632:	83 ec 0c             	sub    $0xc,%esp
80101635:	68 fc 73 10 80       	push   $0x801073fc
8010163a:	e8 41 ed ff ff       	call   80100380 <panic>
8010163f:	90                   	nop

80101640 <readsb>:
{
80101640:	55                   	push   %ebp
80101641:	89 e5                	mov    %esp,%ebp
80101643:	56                   	push   %esi
80101644:	53                   	push   %ebx
80101645:	8b 75 0c             	mov    0xc(%ebp),%esi
  bp = bread(dev, 1);
80101648:	83 ec 08             	sub    $0x8,%esp
8010164b:	6a 01                	push   $0x1
8010164d:	ff 75 08             	push   0x8(%ebp)
80101650:	e8 7b ea ff ff       	call   801000d0 <bread>
  memmove(sb, bp->data, sizeof(*sb));
80101655:	83 c4 0c             	add    $0xc,%esp
  bp = bread(dev, 1);
80101658:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
8010165a:	8d 40 5c             	lea    0x5c(%eax),%eax
8010165d:	6a 1c                	push   $0x1c
8010165f:	50                   	push   %eax
80101660:	56                   	push   %esi
80101661:	e8 ba 31 00 00       	call   80104820 <memmove>
  brelse(bp);
80101666:	89 5d 08             	mov    %ebx,0x8(%ebp)
80101669:	83 c4 10             	add    $0x10,%esp
}
8010166c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010166f:	5b                   	pop    %ebx
80101670:	5e                   	pop    %esi
80101671:	5d                   	pop    %ebp
  brelse(bp);
80101672:	e9 79 eb ff ff       	jmp    801001f0 <brelse>
80101677:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010167e:	66 90                	xchg   %ax,%ax

80101680 <iinit>:
{
80101680:	55                   	push   %ebp
80101681:	89 e5                	mov    %esp,%ebp
80101683:	53                   	push   %ebx
80101684:	bb e0 f9 10 80       	mov    $0x8010f9e0,%ebx
80101689:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
8010168c:	68 0f 74 10 80       	push   $0x8010740f
80101691:	68 a0 f9 10 80       	push   $0x8010f9a0
80101696:	e8 55 2e 00 00       	call   801044f0 <initlock>
  for(i = 0; i < NINODE; i++) {
8010169b:	83 c4 10             	add    $0x10,%esp
8010169e:	66 90                	xchg   %ax,%ax
    initsleeplock(&icache.inode[i].lock, "inode");
801016a0:	83 ec 08             	sub    $0x8,%esp
801016a3:	68 16 74 10 80       	push   $0x80107416
801016a8:	53                   	push   %ebx
  for(i = 0; i < NINODE; i++) {
801016a9:	81 c3 90 00 00 00    	add    $0x90,%ebx
    initsleeplock(&icache.inode[i].lock, "inode");
801016af:	e8 0c 2d 00 00       	call   801043c0 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
801016b4:	83 c4 10             	add    $0x10,%esp
801016b7:	81 fb 00 16 11 80    	cmp    $0x80111600,%ebx
801016bd:	75 e1                	jne    801016a0 <iinit+0x20>
  bp = bread(dev, 1);
801016bf:	83 ec 08             	sub    $0x8,%esp
801016c2:	6a 01                	push   $0x1
801016c4:	ff 75 08             	push   0x8(%ebp)
801016c7:	e8 04 ea ff ff       	call   801000d0 <bread>
  memmove(sb, bp->data, sizeof(*sb));
801016cc:	83 c4 0c             	add    $0xc,%esp
  bp = bread(dev, 1);
801016cf:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
801016d1:	8d 40 5c             	lea    0x5c(%eax),%eax
801016d4:	6a 1c                	push   $0x1c
801016d6:	50                   	push   %eax
801016d7:	68 f4 15 11 80       	push   $0x801115f4
801016dc:	e8 3f 31 00 00       	call   80104820 <memmove>
  brelse(bp);
801016e1:	89 1c 24             	mov    %ebx,(%esp)
801016e4:	e8 07 eb ff ff       	call   801001f0 <brelse>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016e9:	ff 35 0c 16 11 80    	push   0x8011160c
801016ef:	ff 35 08 16 11 80    	push   0x80111608
801016f5:	ff 35 04 16 11 80    	push   0x80111604
801016fb:	ff 35 00 16 11 80    	push   0x80111600
80101701:	ff 35 fc 15 11 80    	push   0x801115fc
80101707:	ff 35 f8 15 11 80    	push   0x801115f8
8010170d:	ff 35 f4 15 11 80    	push   0x801115f4
80101713:	68 7c 74 10 80       	push   $0x8010747c
80101718:	e8 83 ef ff ff       	call   801006a0 <cprintf>
}
8010171d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101720:	83 c4 30             	add    $0x30,%esp
80101723:	c9                   	leave  
80101724:	c3                   	ret    
80101725:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010172c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101730 <ialloc>:
{
80101730:	55                   	push   %ebp
80101731:	89 e5                	mov    %esp,%ebp
80101733:	57                   	push   %edi
80101734:	56                   	push   %esi
80101735:	53                   	push   %ebx
80101736:	83 ec 1c             	sub    $0x1c,%esp
80101739:	8b 45 0c             	mov    0xc(%ebp),%eax
  for(inum = 1; inum < sb.ninodes; inum++){
8010173c:	83 3d fc 15 11 80 01 	cmpl   $0x1,0x801115fc
{
80101743:	8b 75 08             	mov    0x8(%ebp),%esi
80101746:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
80101749:	0f 86 91 00 00 00    	jbe    801017e0 <ialloc+0xb0>
8010174f:	bf 01 00 00 00       	mov    $0x1,%edi
80101754:	eb 21                	jmp    80101777 <ialloc+0x47>
80101756:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010175d:	8d 76 00             	lea    0x0(%esi),%esi
    brelse(bp);
80101760:	83 ec 0c             	sub    $0xc,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
80101763:	83 c7 01             	add    $0x1,%edi
    brelse(bp);
80101766:	53                   	push   %ebx
80101767:	e8 84 ea ff ff       	call   801001f0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
8010176c:	83 c4 10             	add    $0x10,%esp
8010176f:	3b 3d fc 15 11 80    	cmp    0x801115fc,%edi
80101775:	73 69                	jae    801017e0 <ialloc+0xb0>
    bp = bread(dev, IBLOCK(inum, sb));
80101777:	89 f8                	mov    %edi,%eax
80101779:	83 ec 08             	sub    $0x8,%esp
8010177c:	c1 e8 03             	shr    $0x3,%eax
8010177f:	03 05 08 16 11 80    	add    0x80111608,%eax
80101785:	50                   	push   %eax
80101786:	56                   	push   %esi
80101787:	e8 44 e9 ff ff       	call   801000d0 <bread>
    if(dip->type == 0){  // a free inode
8010178c:	83 c4 10             	add    $0x10,%esp
    bp = bread(dev, IBLOCK(inum, sb));
8010178f:	89 c3                	mov    %eax,%ebx
    dip = (struct dinode*)bp->data + inum%IPB;
80101791:	89 f8                	mov    %edi,%eax
80101793:	83 e0 07             	and    $0x7,%eax
80101796:	c1 e0 06             	shl    $0x6,%eax
80101799:	8d 4c 03 5c          	lea    0x5c(%ebx,%eax,1),%ecx
    if(dip->type == 0){  // a free inode
8010179d:	66 83 39 00          	cmpw   $0x0,(%ecx)
801017a1:	75 bd                	jne    80101760 <ialloc+0x30>
      memset(dip, 0, sizeof(*dip));
801017a3:	83 ec 04             	sub    $0x4,%esp
801017a6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
801017a9:	6a 40                	push   $0x40
801017ab:	6a 00                	push   $0x0
801017ad:	51                   	push   %ecx
801017ae:	e8 cd 2f 00 00       	call   80104780 <memset>
      dip->type = type;
801017b3:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801017b7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
801017ba:	66 89 01             	mov    %ax,(%ecx)
      log_write(bp);   // mark it allocated on the disk
801017bd:	89 1c 24             	mov    %ebx,(%esp)
801017c0:	e8 9b 18 00 00       	call   80103060 <log_write>
      brelse(bp);
801017c5:	89 1c 24             	mov    %ebx,(%esp)
801017c8:	e8 23 ea ff ff       	call   801001f0 <brelse>
      return iget(dev, inum);
801017cd:	83 c4 10             	add    $0x10,%esp
}
801017d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return iget(dev, inum);
801017d3:	89 fa                	mov    %edi,%edx
}
801017d5:	5b                   	pop    %ebx
      return iget(dev, inum);
801017d6:	89 f0                	mov    %esi,%eax
}
801017d8:	5e                   	pop    %esi
801017d9:	5f                   	pop    %edi
801017da:	5d                   	pop    %ebp
      return iget(dev, inum);
801017db:	e9 90 fc ff ff       	jmp    80101470 <iget>
  panic("ialloc: no inodes");
801017e0:	83 ec 0c             	sub    $0xc,%esp
801017e3:	68 1c 74 10 80       	push   $0x8010741c
801017e8:	e8 93 eb ff ff       	call   80100380 <panic>
801017ed:	8d 76 00             	lea    0x0(%esi),%esi

801017f0 <iupdate>:
{
801017f0:	55                   	push   %ebp
801017f1:	89 e5                	mov    %esp,%ebp
801017f3:	56                   	push   %esi
801017f4:	53                   	push   %ebx
801017f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801017f8:	8b 43 04             	mov    0x4(%ebx),%eax
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801017fb:	83 c3 5c             	add    $0x5c,%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801017fe:	83 ec 08             	sub    $0x8,%esp
80101801:	c1 e8 03             	shr    $0x3,%eax
80101804:	03 05 08 16 11 80    	add    0x80111608,%eax
8010180a:	50                   	push   %eax
8010180b:	ff 73 a4             	push   -0x5c(%ebx)
8010180e:	e8 bd e8 ff ff       	call   801000d0 <bread>
  dip->type = ip->type;
80101813:	0f b7 53 f4          	movzwl -0xc(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101817:	83 c4 0c             	add    $0xc,%esp
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010181a:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010181c:	8b 43 a8             	mov    -0x58(%ebx),%eax
8010181f:	83 e0 07             	and    $0x7,%eax
80101822:	c1 e0 06             	shl    $0x6,%eax
80101825:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
80101829:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010182c:	0f b7 53 f6          	movzwl -0xa(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101830:	83 c0 0c             	add    $0xc,%eax
  dip->major = ip->major;
80101833:	66 89 50 f6          	mov    %dx,-0xa(%eax)
  dip->minor = ip->minor;
80101837:	0f b7 53 f8          	movzwl -0x8(%ebx),%edx
8010183b:	66 89 50 f8          	mov    %dx,-0x8(%eax)
  dip->nlink = ip->nlink;
8010183f:	0f b7 53 fa          	movzwl -0x6(%ebx),%edx
80101843:	66 89 50 fa          	mov    %dx,-0x6(%eax)
  dip->size = ip->size;
80101847:	8b 53 fc             	mov    -0x4(%ebx),%edx
8010184a:	89 50 fc             	mov    %edx,-0x4(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010184d:	6a 34                	push   $0x34
8010184f:	53                   	push   %ebx
80101850:	50                   	push   %eax
80101851:	e8 ca 2f 00 00       	call   80104820 <memmove>
  log_write(bp);
80101856:	89 34 24             	mov    %esi,(%esp)
80101859:	e8 02 18 00 00       	call   80103060 <log_write>
  brelse(bp);
8010185e:	89 75 08             	mov    %esi,0x8(%ebp)
80101861:	83 c4 10             	add    $0x10,%esp
}
80101864:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101867:	5b                   	pop    %ebx
80101868:	5e                   	pop    %esi
80101869:	5d                   	pop    %ebp
  brelse(bp);
8010186a:	e9 81 e9 ff ff       	jmp    801001f0 <brelse>
8010186f:	90                   	nop

80101870 <idup>:
{
80101870:	55                   	push   %ebp
80101871:	89 e5                	mov    %esp,%ebp
80101873:	53                   	push   %ebx
80101874:	83 ec 10             	sub    $0x10,%esp
80101877:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
8010187a:	68 a0 f9 10 80       	push   $0x8010f9a0
8010187f:	e8 3c 2e 00 00       	call   801046c0 <acquire>
  ip->ref++;
80101884:	83 43 08 01          	addl   $0x1,0x8(%ebx)
  release(&icache.lock);
80101888:	c7 04 24 a0 f9 10 80 	movl   $0x8010f9a0,(%esp)
8010188f:	e8 cc 2d 00 00       	call   80104660 <release>
}
80101894:	89 d8                	mov    %ebx,%eax
80101896:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101899:	c9                   	leave  
8010189a:	c3                   	ret    
8010189b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010189f:	90                   	nop

801018a0 <ilock>:
{
801018a0:	55                   	push   %ebp
801018a1:	89 e5                	mov    %esp,%ebp
801018a3:	56                   	push   %esi
801018a4:	53                   	push   %ebx
801018a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
801018a8:	85 db                	test   %ebx,%ebx
801018aa:	0f 84 b7 00 00 00    	je     80101967 <ilock+0xc7>
801018b0:	8b 53 08             	mov    0x8(%ebx),%edx
801018b3:	85 d2                	test   %edx,%edx
801018b5:	0f 8e ac 00 00 00    	jle    80101967 <ilock+0xc7>
  acquiresleep(&ip->lock);
801018bb:	83 ec 0c             	sub    $0xc,%esp
801018be:	8d 43 0c             	lea    0xc(%ebx),%eax
801018c1:	50                   	push   %eax
801018c2:	e8 39 2b 00 00       	call   80104400 <acquiresleep>
  if(ip->valid == 0){
801018c7:	8b 43 4c             	mov    0x4c(%ebx),%eax
801018ca:	83 c4 10             	add    $0x10,%esp
801018cd:	85 c0                	test   %eax,%eax
801018cf:	74 0f                	je     801018e0 <ilock+0x40>
}
801018d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
801018d4:	5b                   	pop    %ebx
801018d5:	5e                   	pop    %esi
801018d6:	5d                   	pop    %ebp
801018d7:	c3                   	ret    
801018d8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801018df:	90                   	nop
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801018e0:	8b 43 04             	mov    0x4(%ebx),%eax
801018e3:	83 ec 08             	sub    $0x8,%esp
801018e6:	c1 e8 03             	shr    $0x3,%eax
801018e9:	03 05 08 16 11 80    	add    0x80111608,%eax
801018ef:	50                   	push   %eax
801018f0:	ff 33                	push   (%ebx)
801018f2:	e8 d9 e7 ff ff       	call   801000d0 <bread>
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801018f7:	83 c4 0c             	add    $0xc,%esp
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801018fa:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801018fc:	8b 43 04             	mov    0x4(%ebx),%eax
801018ff:	83 e0 07             	and    $0x7,%eax
80101902:	c1 e0 06             	shl    $0x6,%eax
80101905:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
80101909:	0f b7 10             	movzwl (%eax),%edx
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
8010190c:	83 c0 0c             	add    $0xc,%eax
    ip->type = dip->type;
8010190f:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
80101913:	0f b7 50 f6          	movzwl -0xa(%eax),%edx
80101917:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
8010191b:	0f b7 50 f8          	movzwl -0x8(%eax),%edx
8010191f:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
80101923:	0f b7 50 fa          	movzwl -0x6(%eax),%edx
80101927:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
8010192b:	8b 50 fc             	mov    -0x4(%eax),%edx
8010192e:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101931:	6a 34                	push   $0x34
80101933:	50                   	push   %eax
80101934:	8d 43 5c             	lea    0x5c(%ebx),%eax
80101937:	50                   	push   %eax
80101938:	e8 e3 2e 00 00       	call   80104820 <memmove>
    brelse(bp);
8010193d:	89 34 24             	mov    %esi,(%esp)
80101940:	e8 ab e8 ff ff       	call   801001f0 <brelse>
    if(ip->type == 0)
80101945:	83 c4 10             	add    $0x10,%esp
80101948:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
    ip->valid = 1;
8010194d:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
80101954:	0f 85 77 ff ff ff    	jne    801018d1 <ilock+0x31>
      panic("ilock: no type");
8010195a:	83 ec 0c             	sub    $0xc,%esp
8010195d:	68 34 74 10 80       	push   $0x80107434
80101962:	e8 19 ea ff ff       	call   80100380 <panic>
    panic("ilock");
80101967:	83 ec 0c             	sub    $0xc,%esp
8010196a:	68 2e 74 10 80       	push   $0x8010742e
8010196f:	e8 0c ea ff ff       	call   80100380 <panic>
80101974:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010197b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010197f:	90                   	nop

80101980 <iunlock>:
{
80101980:	55                   	push   %ebp
80101981:	89 e5                	mov    %esp,%ebp
80101983:	56                   	push   %esi
80101984:	53                   	push   %ebx
80101985:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101988:	85 db                	test   %ebx,%ebx
8010198a:	74 28                	je     801019b4 <iunlock+0x34>
8010198c:	83 ec 0c             	sub    $0xc,%esp
8010198f:	8d 73 0c             	lea    0xc(%ebx),%esi
80101992:	56                   	push   %esi
80101993:	e8 08 2b 00 00       	call   801044a0 <holdingsleep>
80101998:	83 c4 10             	add    $0x10,%esp
8010199b:	85 c0                	test   %eax,%eax
8010199d:	74 15                	je     801019b4 <iunlock+0x34>
8010199f:	8b 43 08             	mov    0x8(%ebx),%eax
801019a2:	85 c0                	test   %eax,%eax
801019a4:	7e 0e                	jle    801019b4 <iunlock+0x34>
  releasesleep(&ip->lock);
801019a6:	89 75 08             	mov    %esi,0x8(%ebp)
}
801019a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
801019ac:	5b                   	pop    %ebx
801019ad:	5e                   	pop    %esi
801019ae:	5d                   	pop    %ebp
  releasesleep(&ip->lock);
801019af:	e9 ac 2a 00 00       	jmp    80104460 <releasesleep>
    panic("iunlock");
801019b4:	83 ec 0c             	sub    $0xc,%esp
801019b7:	68 43 74 10 80       	push   $0x80107443
801019bc:	e8 bf e9 ff ff       	call   80100380 <panic>
801019c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801019c8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801019cf:	90                   	nop

801019d0 <iput>:
{
801019d0:	55                   	push   %ebp
801019d1:	89 e5                	mov    %esp,%ebp
801019d3:	57                   	push   %edi
801019d4:	56                   	push   %esi
801019d5:	53                   	push   %ebx
801019d6:	83 ec 28             	sub    $0x28,%esp
801019d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
801019dc:	8d 7b 0c             	lea    0xc(%ebx),%edi
801019df:	57                   	push   %edi
801019e0:	e8 1b 2a 00 00       	call   80104400 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
801019e5:	8b 53 4c             	mov    0x4c(%ebx),%edx
801019e8:	83 c4 10             	add    $0x10,%esp
801019eb:	85 d2                	test   %edx,%edx
801019ed:	74 07                	je     801019f6 <iput+0x26>
801019ef:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801019f4:	74 32                	je     80101a28 <iput+0x58>
  releasesleep(&ip->lock);
801019f6:	83 ec 0c             	sub    $0xc,%esp
801019f9:	57                   	push   %edi
801019fa:	e8 61 2a 00 00       	call   80104460 <releasesleep>
  acquire(&icache.lock);
801019ff:	c7 04 24 a0 f9 10 80 	movl   $0x8010f9a0,(%esp)
80101a06:	e8 b5 2c 00 00       	call   801046c0 <acquire>
  ip->ref--;
80101a0b:	83 6b 08 01          	subl   $0x1,0x8(%ebx)
  release(&icache.lock);
80101a0f:	83 c4 10             	add    $0x10,%esp
80101a12:	c7 45 08 a0 f9 10 80 	movl   $0x8010f9a0,0x8(%ebp)
}
80101a19:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a1c:	5b                   	pop    %ebx
80101a1d:	5e                   	pop    %esi
80101a1e:	5f                   	pop    %edi
80101a1f:	5d                   	pop    %ebp
  release(&icache.lock);
80101a20:	e9 3b 2c 00 00       	jmp    80104660 <release>
80101a25:	8d 76 00             	lea    0x0(%esi),%esi
    acquire(&icache.lock);
80101a28:	83 ec 0c             	sub    $0xc,%esp
80101a2b:	68 a0 f9 10 80       	push   $0x8010f9a0
80101a30:	e8 8b 2c 00 00       	call   801046c0 <acquire>
    int r = ip->ref;
80101a35:	8b 73 08             	mov    0x8(%ebx),%esi
    release(&icache.lock);
80101a38:	c7 04 24 a0 f9 10 80 	movl   $0x8010f9a0,(%esp)
80101a3f:	e8 1c 2c 00 00       	call   80104660 <release>
    if(r == 1){
80101a44:	83 c4 10             	add    $0x10,%esp
80101a47:	83 fe 01             	cmp    $0x1,%esi
80101a4a:	75 aa                	jne    801019f6 <iput+0x26>
80101a4c:	8d 8b 8c 00 00 00    	lea    0x8c(%ebx),%ecx
80101a52:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80101a55:	8d 73 5c             	lea    0x5c(%ebx),%esi
80101a58:	89 cf                	mov    %ecx,%edi
80101a5a:	eb 0b                	jmp    80101a67 <iput+0x97>
80101a5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101a60:	83 c6 04             	add    $0x4,%esi
80101a63:	39 fe                	cmp    %edi,%esi
80101a65:	74 19                	je     80101a80 <iput+0xb0>
    if(ip->addrs[i]){
80101a67:	8b 16                	mov    (%esi),%edx
80101a69:	85 d2                	test   %edx,%edx
80101a6b:	74 f3                	je     80101a60 <iput+0x90>
      bfree(ip->dev, ip->addrs[i]);
80101a6d:	8b 03                	mov    (%ebx),%eax
80101a6f:	e8 6c f8 ff ff       	call   801012e0 <bfree>
      ip->addrs[i] = 0;
80101a74:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80101a7a:	eb e4                	jmp    80101a60 <iput+0x90>
80101a7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    }
  }

  if(ip->addrs[NDIRECT]){
80101a80:	8b 83 8c 00 00 00    	mov    0x8c(%ebx),%eax
80101a86:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80101a89:	85 c0                	test   %eax,%eax
80101a8b:	75 2d                	jne    80101aba <iput+0xea>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
  iupdate(ip);
80101a8d:	83 ec 0c             	sub    $0xc,%esp
  ip->size = 0;
80101a90:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  iupdate(ip);
80101a97:	53                   	push   %ebx
80101a98:	e8 53 fd ff ff       	call   801017f0 <iupdate>
      ip->type = 0;
80101a9d:	31 c0                	xor    %eax,%eax
80101a9f:	66 89 43 50          	mov    %ax,0x50(%ebx)
      iupdate(ip);
80101aa3:	89 1c 24             	mov    %ebx,(%esp)
80101aa6:	e8 45 fd ff ff       	call   801017f0 <iupdate>
      ip->valid = 0;
80101aab:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
80101ab2:	83 c4 10             	add    $0x10,%esp
80101ab5:	e9 3c ff ff ff       	jmp    801019f6 <iput+0x26>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101aba:	83 ec 08             	sub    $0x8,%esp
80101abd:	50                   	push   %eax
80101abe:	ff 33                	push   (%ebx)
80101ac0:	e8 0b e6 ff ff       	call   801000d0 <bread>
80101ac5:	89 7d e0             	mov    %edi,-0x20(%ebp)
80101ac8:	83 c4 10             	add    $0x10,%esp
80101acb:	8d 88 5c 02 00 00    	lea    0x25c(%eax),%ecx
80101ad1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101ad4:	8d 70 5c             	lea    0x5c(%eax),%esi
80101ad7:	89 cf                	mov    %ecx,%edi
80101ad9:	eb 0c                	jmp    80101ae7 <iput+0x117>
80101adb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101adf:	90                   	nop
80101ae0:	83 c6 04             	add    $0x4,%esi
80101ae3:	39 f7                	cmp    %esi,%edi
80101ae5:	74 0f                	je     80101af6 <iput+0x126>
      if(a[j])
80101ae7:	8b 16                	mov    (%esi),%edx
80101ae9:	85 d2                	test   %edx,%edx
80101aeb:	74 f3                	je     80101ae0 <iput+0x110>
        bfree(ip->dev, a[j]);
80101aed:	8b 03                	mov    (%ebx),%eax
80101aef:	e8 ec f7 ff ff       	call   801012e0 <bfree>
80101af4:	eb ea                	jmp    80101ae0 <iput+0x110>
    brelse(bp);
80101af6:	83 ec 0c             	sub    $0xc,%esp
80101af9:	ff 75 e4             	push   -0x1c(%ebp)
80101afc:	8b 7d e0             	mov    -0x20(%ebp),%edi
80101aff:	e8 ec e6 ff ff       	call   801001f0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101b04:	8b 93 8c 00 00 00    	mov    0x8c(%ebx),%edx
80101b0a:	8b 03                	mov    (%ebx),%eax
80101b0c:	e8 cf f7 ff ff       	call   801012e0 <bfree>
    ip->addrs[NDIRECT] = 0;
80101b11:	83 c4 10             	add    $0x10,%esp
80101b14:	c7 83 8c 00 00 00 00 	movl   $0x0,0x8c(%ebx)
80101b1b:	00 00 00 
80101b1e:	e9 6a ff ff ff       	jmp    80101a8d <iput+0xbd>
80101b23:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101b2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101b30 <iunlockput>:
{
80101b30:	55                   	push   %ebp
80101b31:	89 e5                	mov    %esp,%ebp
80101b33:	56                   	push   %esi
80101b34:	53                   	push   %ebx
80101b35:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b38:	85 db                	test   %ebx,%ebx
80101b3a:	74 34                	je     80101b70 <iunlockput+0x40>
80101b3c:	83 ec 0c             	sub    $0xc,%esp
80101b3f:	8d 73 0c             	lea    0xc(%ebx),%esi
80101b42:	56                   	push   %esi
80101b43:	e8 58 29 00 00       	call   801044a0 <holdingsleep>
80101b48:	83 c4 10             	add    $0x10,%esp
80101b4b:	85 c0                	test   %eax,%eax
80101b4d:	74 21                	je     80101b70 <iunlockput+0x40>
80101b4f:	8b 43 08             	mov    0x8(%ebx),%eax
80101b52:	85 c0                	test   %eax,%eax
80101b54:	7e 1a                	jle    80101b70 <iunlockput+0x40>
  releasesleep(&ip->lock);
80101b56:	83 ec 0c             	sub    $0xc,%esp
80101b59:	56                   	push   %esi
80101b5a:	e8 01 29 00 00       	call   80104460 <releasesleep>
  iput(ip);
80101b5f:	89 5d 08             	mov    %ebx,0x8(%ebp)
80101b62:	83 c4 10             	add    $0x10,%esp
}
80101b65:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101b68:	5b                   	pop    %ebx
80101b69:	5e                   	pop    %esi
80101b6a:	5d                   	pop    %ebp
  iput(ip);
80101b6b:	e9 60 fe ff ff       	jmp    801019d0 <iput>
    panic("iunlock");
80101b70:	83 ec 0c             	sub    $0xc,%esp
80101b73:	68 43 74 10 80       	push   $0x80107443
80101b78:	e8 03 e8 ff ff       	call   80100380 <panic>
80101b7d:	8d 76 00             	lea    0x0(%esi),%esi

80101b80 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101b80:	55                   	push   %ebp
80101b81:	89 e5                	mov    %esp,%ebp
80101b83:	8b 55 08             	mov    0x8(%ebp),%edx
80101b86:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
80101b89:	8b 0a                	mov    (%edx),%ecx
80101b8b:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
80101b8e:	8b 4a 04             	mov    0x4(%edx),%ecx
80101b91:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
80101b94:	0f b7 4a 50          	movzwl 0x50(%edx),%ecx
80101b98:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
80101b9b:	0f b7 4a 56          	movzwl 0x56(%edx),%ecx
80101b9f:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
80101ba3:	8b 52 58             	mov    0x58(%edx),%edx
80101ba6:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ba9:	5d                   	pop    %ebp
80101baa:	c3                   	ret    
80101bab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101baf:	90                   	nop

80101bb0 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101bb0:	55                   	push   %ebp
80101bb1:	89 e5                	mov    %esp,%ebp
80101bb3:	57                   	push   %edi
80101bb4:	56                   	push   %esi
80101bb5:	53                   	push   %ebx
80101bb6:	83 ec 1c             	sub    $0x1c,%esp
80101bb9:	8b 7d 0c             	mov    0xc(%ebp),%edi
80101bbc:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbf:	8b 75 10             	mov    0x10(%ebp),%esi
80101bc2:	89 7d e0             	mov    %edi,-0x20(%ebp)
80101bc5:	8b 7d 14             	mov    0x14(%ebp),%edi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101bc8:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
{
80101bcd:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101bd0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  if(ip->type == T_DEV){
80101bd3:	0f 84 a7 00 00 00    	je     80101c80 <readi+0xd0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  }

  if(off > ip->size || off + n < off)
80101bd9:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101bdc:	8b 40 58             	mov    0x58(%eax),%eax
80101bdf:	39 c6                	cmp    %eax,%esi
80101be1:	0f 87 ba 00 00 00    	ja     80101ca1 <readi+0xf1>
80101be7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80101bea:	31 c9                	xor    %ecx,%ecx
80101bec:	89 da                	mov    %ebx,%edx
80101bee:	01 f2                	add    %esi,%edx
80101bf0:	0f 92 c1             	setb   %cl
80101bf3:	89 cf                	mov    %ecx,%edi
80101bf5:	0f 82 a6 00 00 00    	jb     80101ca1 <readi+0xf1>
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;
80101bfb:	89 c1                	mov    %eax,%ecx
80101bfd:	29 f1                	sub    %esi,%ecx
80101bff:	39 d0                	cmp    %edx,%eax
80101c01:	0f 43 cb             	cmovae %ebx,%ecx
80101c04:	89 4d e4             	mov    %ecx,-0x1c(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101c07:	85 c9                	test   %ecx,%ecx
80101c09:	74 67                	je     80101c72 <readi+0xc2>
80101c0b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101c0f:	90                   	nop
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101c10:	8b 5d d8             	mov    -0x28(%ebp),%ebx
80101c13:	89 f2                	mov    %esi,%edx
80101c15:	c1 ea 09             	shr    $0x9,%edx
80101c18:	89 d8                	mov    %ebx,%eax
80101c1a:	e8 51 f9 ff ff       	call   80101570 <bmap>
80101c1f:	83 ec 08             	sub    $0x8,%esp
80101c22:	50                   	push   %eax
80101c23:	ff 33                	push   (%ebx)
80101c25:	e8 a6 e4 ff ff       	call   801000d0 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
80101c2a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80101c2d:	b9 00 02 00 00       	mov    $0x200,%ecx
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101c32:	89 c2                	mov    %eax,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
80101c34:	89 f0                	mov    %esi,%eax
80101c36:	25 ff 01 00 00       	and    $0x1ff,%eax
80101c3b:	29 fb                	sub    %edi,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
80101c3d:	89 55 dc             	mov    %edx,-0x24(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101c40:	29 c1                	sub    %eax,%ecx
    memmove(dst, bp->data + off%BSIZE, m);
80101c42:	8d 44 02 5c          	lea    0x5c(%edx,%eax,1),%eax
    m = min(n - tot, BSIZE - off%BSIZE);
80101c46:	39 d9                	cmp    %ebx,%ecx
80101c48:	0f 46 d9             	cmovbe %ecx,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
80101c4b:	83 c4 0c             	add    $0xc,%esp
80101c4e:	53                   	push   %ebx
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101c4f:	01 df                	add    %ebx,%edi
80101c51:	01 de                	add    %ebx,%esi
    memmove(dst, bp->data + off%BSIZE, m);
80101c53:	50                   	push   %eax
80101c54:	ff 75 e0             	push   -0x20(%ebp)
80101c57:	e8 c4 2b 00 00       	call   80104820 <memmove>
    brelse(bp);
80101c5c:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101c5f:	89 14 24             	mov    %edx,(%esp)
80101c62:	e8 89 e5 ff ff       	call   801001f0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101c67:	01 5d e0             	add    %ebx,-0x20(%ebp)
80101c6a:	83 c4 10             	add    $0x10,%esp
80101c6d:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
80101c70:	77 9e                	ja     80101c10 <readi+0x60>
  }
  return n;
80101c72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
80101c75:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101c78:	5b                   	pop    %ebx
80101c79:	5e                   	pop    %esi
80101c7a:	5f                   	pop    %edi
80101c7b:	5d                   	pop    %ebp
80101c7c:	c3                   	ret    
80101c7d:	8d 76 00             	lea    0x0(%esi),%esi
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101c80:	0f bf 40 52          	movswl 0x52(%eax),%eax
80101c84:	66 83 f8 09          	cmp    $0x9,%ax
80101c88:	77 17                	ja     80101ca1 <readi+0xf1>
80101c8a:	8b 04 c5 40 f9 10 80 	mov    -0x7fef06c0(,%eax,8),%eax
80101c91:	85 c0                	test   %eax,%eax
80101c93:	74 0c                	je     80101ca1 <readi+0xf1>
    return devsw[ip->major].read(ip, dst, n);
80101c95:	89 7d 10             	mov    %edi,0x10(%ebp)
}
80101c98:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101c9b:	5b                   	pop    %ebx
80101c9c:	5e                   	pop    %esi
80101c9d:	5f                   	pop    %edi
80101c9e:	5d                   	pop    %ebp
    return devsw[ip->major].read(ip, dst, n);
80101c9f:	ff e0                	jmp    *%eax
      return -1;
80101ca1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101ca6:	eb cd                	jmp    80101c75 <readi+0xc5>
80101ca8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101caf:	90                   	nop

80101cb0 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101cb0:	55                   	push   %ebp
80101cb1:	89 e5                	mov    %esp,%ebp
80101cb3:	57                   	push   %edi
80101cb4:	56                   	push   %esi
80101cb5:	53                   	push   %ebx
80101cb6:	83 ec 1c             	sub    $0x1c,%esp
80101cb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbc:	8b 75 0c             	mov    0xc(%ebp),%esi
80101cbf:	8b 55 14             	mov    0x14(%ebp),%edx
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101cc2:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
{
80101cc7:	89 75 dc             	mov    %esi,-0x24(%ebp)
80101cca:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101ccd:	8b 75 10             	mov    0x10(%ebp),%esi
80101cd0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  if(ip->type == T_DEV){
80101cd3:	0f 84 b7 00 00 00    	je     80101d90 <writei+0xe0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
  }

  if(off > ip->size || off + n < off)
80101cd9:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101cdc:	3b 70 58             	cmp    0x58(%eax),%esi
80101cdf:	0f 87 e7 00 00 00    	ja     80101dcc <writei+0x11c>
80101ce5:	8b 7d e0             	mov    -0x20(%ebp),%edi
80101ce8:	31 d2                	xor    %edx,%edx
80101cea:	89 f8                	mov    %edi,%eax
80101cec:	01 f0                	add    %esi,%eax
80101cee:	0f 92 c2             	setb   %dl
    return -1;
  if(off + n > MAXFILE*BSIZE)
80101cf1:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101cf6:	0f 87 d0 00 00 00    	ja     80101dcc <writei+0x11c>
80101cfc:	85 d2                	test   %edx,%edx
80101cfe:	0f 85 c8 00 00 00    	jne    80101dcc <writei+0x11c>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101d04:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101d0b:	85 ff                	test   %edi,%edi
80101d0d:	74 72                	je     80101d81 <writei+0xd1>
80101d0f:	90                   	nop
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101d10:	8b 7d d8             	mov    -0x28(%ebp),%edi
80101d13:	89 f2                	mov    %esi,%edx
80101d15:	c1 ea 09             	shr    $0x9,%edx
80101d18:	89 f8                	mov    %edi,%eax
80101d1a:	e8 51 f8 ff ff       	call   80101570 <bmap>
80101d1f:	83 ec 08             	sub    $0x8,%esp
80101d22:	50                   	push   %eax
80101d23:	ff 37                	push   (%edi)
80101d25:	e8 a6 e3 ff ff       	call   801000d0 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
80101d2a:	b9 00 02 00 00       	mov    $0x200,%ecx
80101d2f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
80101d32:	2b 5d e4             	sub    -0x1c(%ebp),%ebx
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101d35:	89 c7                	mov    %eax,%edi
    m = min(n - tot, BSIZE - off%BSIZE);
80101d37:	89 f0                	mov    %esi,%eax
80101d39:	25 ff 01 00 00       	and    $0x1ff,%eax
80101d3e:	29 c1                	sub    %eax,%ecx
    memmove(bp->data + off%BSIZE, src, m);
80101d40:	8d 44 07 5c          	lea    0x5c(%edi,%eax,1),%eax
    m = min(n - tot, BSIZE - off%BSIZE);
80101d44:	39 d9                	cmp    %ebx,%ecx
80101d46:	0f 46 d9             	cmovbe %ecx,%ebx
    memmove(bp->data + off%BSIZE, src, m);
80101d49:	83 c4 0c             	add    $0xc,%esp
80101d4c:	53                   	push   %ebx
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101d4d:	01 de                	add    %ebx,%esi
    memmove(bp->data + off%BSIZE, src, m);
80101d4f:	ff 75 dc             	push   -0x24(%ebp)
80101d52:	50                   	push   %eax
80101d53:	e8 c8 2a 00 00       	call   80104820 <memmove>
    log_write(bp);
80101d58:	89 3c 24             	mov    %edi,(%esp)
80101d5b:	e8 00 13 00 00       	call   80103060 <log_write>
    brelse(bp);
80101d60:	89 3c 24             	mov    %edi,(%esp)
80101d63:	e8 88 e4 ff ff       	call   801001f0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101d68:	01 5d e4             	add    %ebx,-0x1c(%ebp)
80101d6b:	83 c4 10             	add    $0x10,%esp
80101d6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101d71:	01 5d dc             	add    %ebx,-0x24(%ebp)
80101d74:	39 45 e0             	cmp    %eax,-0x20(%ebp)
80101d77:	77 97                	ja     80101d10 <writei+0x60>
  }

  if(n > 0 && off > ip->size){
80101d79:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101d7c:	3b 70 58             	cmp    0x58(%eax),%esi
80101d7f:	77 37                	ja     80101db8 <writei+0x108>
    ip->size = off;
    iupdate(ip);
  }
  return n;
80101d81:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
80101d84:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101d87:	5b                   	pop    %ebx
80101d88:	5e                   	pop    %esi
80101d89:	5f                   	pop    %edi
80101d8a:	5d                   	pop    %ebp
80101d8b:	c3                   	ret    
80101d8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101d90:	0f bf 40 52          	movswl 0x52(%eax),%eax
80101d94:	66 83 f8 09          	cmp    $0x9,%ax
80101d98:	77 32                	ja     80101dcc <writei+0x11c>
80101d9a:	8b 04 c5 44 f9 10 80 	mov    -0x7fef06bc(,%eax,8),%eax
80101da1:	85 c0                	test   %eax,%eax
80101da3:	74 27                	je     80101dcc <writei+0x11c>
    return devsw[ip->major].write(ip, src, n);
80101da5:	89 55 10             	mov    %edx,0x10(%ebp)
}
80101da8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101dab:	5b                   	pop    %ebx
80101dac:	5e                   	pop    %esi
80101dad:	5f                   	pop    %edi
80101dae:	5d                   	pop    %ebp
    return devsw[ip->major].write(ip, src, n);
80101daf:	ff e0                	jmp    *%eax
80101db1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    ip->size = off;
80101db8:	8b 45 d8             	mov    -0x28(%ebp),%eax
    iupdate(ip);
80101dbb:	83 ec 0c             	sub    $0xc,%esp
    ip->size = off;
80101dbe:	89 70 58             	mov    %esi,0x58(%eax)
    iupdate(ip);
80101dc1:	50                   	push   %eax
80101dc2:	e8 29 fa ff ff       	call   801017f0 <iupdate>
80101dc7:	83 c4 10             	add    $0x10,%esp
80101dca:	eb b5                	jmp    80101d81 <writei+0xd1>
      return -1;
80101dcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101dd1:	eb b1                	jmp    80101d84 <writei+0xd4>
80101dd3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101dda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101de0 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80101de0:	55                   	push   %ebp
80101de1:	89 e5                	mov    %esp,%ebp
80101de3:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
80101de6:	6a 0e                	push   $0xe
80101de8:	ff 75 0c             	push   0xc(%ebp)
80101deb:	ff 75 08             	push   0x8(%ebp)
80101dee:	e8 9d 2a 00 00       	call   80104890 <strncmp>
}
80101df3:	c9                   	leave  
80101df4:	c3                   	ret    
80101df5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101dfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101e00 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80101e00:	55                   	push   %ebp
80101e01:	89 e5                	mov    %esp,%ebp
80101e03:	57                   	push   %edi
80101e04:	56                   	push   %esi
80101e05:	53                   	push   %ebx
80101e06:	83 ec 1c             	sub    $0x1c,%esp
80101e09:	8b 5d 08             	mov    0x8(%ebp),%ebx
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80101e0c:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80101e11:	0f 85 85 00 00 00    	jne    80101e9c <dirlookup+0x9c>
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80101e17:	8b 53 58             	mov    0x58(%ebx),%edx
80101e1a:	31 ff                	xor    %edi,%edi
80101e1c:	8d 75 d8             	lea    -0x28(%ebp),%esi
80101e1f:	85 d2                	test   %edx,%edx
80101e21:	74 3e                	je     80101e61 <dirlookup+0x61>
80101e23:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101e27:	90                   	nop
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101e28:	6a 10                	push   $0x10
80101e2a:	57                   	push   %edi
80101e2b:	56                   	push   %esi
80101e2c:	53                   	push   %ebx
80101e2d:	e8 7e fd ff ff       	call   80101bb0 <readi>
80101e32:	83 c4 10             	add    $0x10,%esp
80101e35:	83 f8 10             	cmp    $0x10,%eax
80101e38:	75 55                	jne    80101e8f <dirlookup+0x8f>
      panic("dirlookup read");
    if(de.inum == 0)
80101e3a:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101e3f:	74 18                	je     80101e59 <dirlookup+0x59>
  return strncmp(s, t, DIRSIZ);
80101e41:	83 ec 04             	sub    $0x4,%esp
80101e44:	8d 45 da             	lea    -0x26(%ebp),%eax
80101e47:	6a 0e                	push   $0xe
80101e49:	50                   	push   %eax
80101e4a:	ff 75 0c             	push   0xc(%ebp)
80101e4d:	e8 3e 2a 00 00       	call   80104890 <strncmp>
      continue;
    if(namecmp(name, de.name) == 0){
80101e52:	83 c4 10             	add    $0x10,%esp
80101e55:	85 c0                	test   %eax,%eax
80101e57:	74 17                	je     80101e70 <dirlookup+0x70>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101e59:	83 c7 10             	add    $0x10,%edi
80101e5c:	3b 7b 58             	cmp    0x58(%ebx),%edi
80101e5f:	72 c7                	jb     80101e28 <dirlookup+0x28>
      return iget(dp->dev, inum);
    }
  }

  return 0;
}
80101e61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80101e64:	31 c0                	xor    %eax,%eax
}
80101e66:	5b                   	pop    %ebx
80101e67:	5e                   	pop    %esi
80101e68:	5f                   	pop    %edi
80101e69:	5d                   	pop    %ebp
80101e6a:	c3                   	ret    
80101e6b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101e6f:	90                   	nop
      if(poff)
80101e70:	8b 45 10             	mov    0x10(%ebp),%eax
80101e73:	85 c0                	test   %eax,%eax
80101e75:	74 05                	je     80101e7c <dirlookup+0x7c>
        *poff = off;
80101e77:	8b 45 10             	mov    0x10(%ebp),%eax
80101e7a:	89 38                	mov    %edi,(%eax)
      inum = de.inum;
80101e7c:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101e80:	8b 03                	mov    (%ebx),%eax
80101e82:	e8 e9 f5 ff ff       	call   80101470 <iget>
}
80101e87:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101e8a:	5b                   	pop    %ebx
80101e8b:	5e                   	pop    %esi
80101e8c:	5f                   	pop    %edi
80101e8d:	5d                   	pop    %ebp
80101e8e:	c3                   	ret    
      panic("dirlookup read");
80101e8f:	83 ec 0c             	sub    $0xc,%esp
80101e92:	68 5d 74 10 80       	push   $0x8010745d
80101e97:	e8 e4 e4 ff ff       	call   80100380 <panic>
    panic("dirlookup not DIR");
80101e9c:	83 ec 0c             	sub    $0xc,%esp
80101e9f:	68 4b 74 10 80       	push   $0x8010744b
80101ea4:	e8 d7 e4 ff ff       	call   80100380 <panic>
80101ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101eb0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101eb0:	55                   	push   %ebp
80101eb1:	89 e5                	mov    %esp,%ebp
80101eb3:	57                   	push   %edi
80101eb4:	56                   	push   %esi
80101eb5:	53                   	push   %ebx
80101eb6:	89 c3                	mov    %eax,%ebx
80101eb8:	83 ec 1c             	sub    $0x1c,%esp
  struct inode *ip, *next;

  if(*path == '/')
80101ebb:	80 38 2f             	cmpb   $0x2f,(%eax)
{
80101ebe:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101ec1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  if(*path == '/')
80101ec4:	0f 84 64 01 00 00    	je     8010202e <namex+0x17e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80101eca:	e8 c1 1b 00 00       	call   80103a90 <myproc>
  acquire(&icache.lock);
80101ecf:	83 ec 0c             	sub    $0xc,%esp
    ip = idup(myproc()->cwd);
80101ed2:	8b 70 68             	mov    0x68(%eax),%esi
  acquire(&icache.lock);
80101ed5:	68 a0 f9 10 80       	push   $0x8010f9a0
80101eda:	e8 e1 27 00 00       	call   801046c0 <acquire>
  ip->ref++;
80101edf:	83 46 08 01          	addl   $0x1,0x8(%esi)
  release(&icache.lock);
80101ee3:	c7 04 24 a0 f9 10 80 	movl   $0x8010f9a0,(%esp)
80101eea:	e8 71 27 00 00       	call   80104660 <release>
80101eef:	83 c4 10             	add    $0x10,%esp
80101ef2:	eb 07                	jmp    80101efb <namex+0x4b>
80101ef4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    path++;
80101ef8:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80101efb:	0f b6 03             	movzbl (%ebx),%eax
80101efe:	3c 2f                	cmp    $0x2f,%al
80101f00:	74 f6                	je     80101ef8 <namex+0x48>
  if(*path == 0)
80101f02:	84 c0                	test   %al,%al
80101f04:	0f 84 06 01 00 00    	je     80102010 <namex+0x160>
  while(*path != '/' && *path != 0)
80101f0a:	0f b6 03             	movzbl (%ebx),%eax
80101f0d:	84 c0                	test   %al,%al
80101f0f:	0f 84 10 01 00 00    	je     80102025 <namex+0x175>
80101f15:	89 df                	mov    %ebx,%edi
80101f17:	3c 2f                	cmp    $0x2f,%al
80101f19:	0f 84 06 01 00 00    	je     80102025 <namex+0x175>
80101f1f:	90                   	nop
80101f20:	0f b6 47 01          	movzbl 0x1(%edi),%eax
    path++;
80101f24:	83 c7 01             	add    $0x1,%edi
  while(*path != '/' && *path != 0)
80101f27:	3c 2f                	cmp    $0x2f,%al
80101f29:	74 04                	je     80101f2f <namex+0x7f>
80101f2b:	84 c0                	test   %al,%al
80101f2d:	75 f1                	jne    80101f20 <namex+0x70>
  len = path - s;
80101f2f:	89 f8                	mov    %edi,%eax
80101f31:	29 d8                	sub    %ebx,%eax
  if(len >= DIRSIZ)
80101f33:	83 f8 0d             	cmp    $0xd,%eax
80101f36:	0f 8e ac 00 00 00    	jle    80101fe8 <namex+0x138>
    memmove(name, s, DIRSIZ);
80101f3c:	83 ec 04             	sub    $0x4,%esp
80101f3f:	6a 0e                	push   $0xe
80101f41:	53                   	push   %ebx
    path++;
80101f42:	89 fb                	mov    %edi,%ebx
    memmove(name, s, DIRSIZ);
80101f44:	ff 75 e4             	push   -0x1c(%ebp)
80101f47:	e8 d4 28 00 00       	call   80104820 <memmove>
80101f4c:	83 c4 10             	add    $0x10,%esp
  while(*path == '/')
80101f4f:	80 3f 2f             	cmpb   $0x2f,(%edi)
80101f52:	75 0c                	jne    80101f60 <namex+0xb0>
80101f54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    path++;
80101f58:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80101f5b:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80101f5e:	74 f8                	je     80101f58 <namex+0xa8>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
80101f60:	83 ec 0c             	sub    $0xc,%esp
80101f63:	56                   	push   %esi
80101f64:	e8 37 f9 ff ff       	call   801018a0 <ilock>
    if(ip->type != T_DIR){
80101f69:	83 c4 10             	add    $0x10,%esp
80101f6c:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80101f71:	0f 85 cd 00 00 00    	jne    80102044 <namex+0x194>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
80101f77:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101f7a:	85 c0                	test   %eax,%eax
80101f7c:	74 09                	je     80101f87 <namex+0xd7>
80101f7e:	80 3b 00             	cmpb   $0x0,(%ebx)
80101f81:	0f 84 22 01 00 00    	je     801020a9 <namex+0x1f9>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80101f87:	83 ec 04             	sub    $0x4,%esp
80101f8a:	6a 00                	push   $0x0
80101f8c:	ff 75 e4             	push   -0x1c(%ebp)
80101f8f:	56                   	push   %esi
80101f90:	e8 6b fe ff ff       	call   80101e00 <dirlookup>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101f95:	8d 56 0c             	lea    0xc(%esi),%edx
    if((next = dirlookup(ip, name, 0)) == 0){
80101f98:	83 c4 10             	add    $0x10,%esp
80101f9b:	89 c7                	mov    %eax,%edi
80101f9d:	85 c0                	test   %eax,%eax
80101f9f:	0f 84 e1 00 00 00    	je     80102086 <namex+0x1d6>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101fa5:	83 ec 0c             	sub    $0xc,%esp
80101fa8:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101fab:	52                   	push   %edx
80101fac:	e8 ef 24 00 00       	call   801044a0 <holdingsleep>
80101fb1:	83 c4 10             	add    $0x10,%esp
80101fb4:	85 c0                	test   %eax,%eax
80101fb6:	0f 84 30 01 00 00    	je     801020ec <namex+0x23c>
80101fbc:	8b 56 08             	mov    0x8(%esi),%edx
80101fbf:	85 d2                	test   %edx,%edx
80101fc1:	0f 8e 25 01 00 00    	jle    801020ec <namex+0x23c>
  releasesleep(&ip->lock);
80101fc7:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101fca:	83 ec 0c             	sub    $0xc,%esp
80101fcd:	52                   	push   %edx
80101fce:	e8 8d 24 00 00       	call   80104460 <releasesleep>
  iput(ip);
80101fd3:	89 34 24             	mov    %esi,(%esp)
80101fd6:	89 fe                	mov    %edi,%esi
80101fd8:	e8 f3 f9 ff ff       	call   801019d0 <iput>
80101fdd:	83 c4 10             	add    $0x10,%esp
80101fe0:	e9 16 ff ff ff       	jmp    80101efb <namex+0x4b>
80101fe5:	8d 76 00             	lea    0x0(%esi),%esi
    name[len] = 0;
80101fe8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80101feb:	8d 14 01             	lea    (%ecx,%eax,1),%edx
    memmove(name, s, len);
80101fee:	83 ec 04             	sub    $0x4,%esp
80101ff1:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101ff4:	50                   	push   %eax
80101ff5:	53                   	push   %ebx
    name[len] = 0;
80101ff6:	89 fb                	mov    %edi,%ebx
    memmove(name, s, len);
80101ff8:	ff 75 e4             	push   -0x1c(%ebp)
80101ffb:	e8 20 28 00 00       	call   80104820 <memmove>
    name[len] = 0;
80102000:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102003:	83 c4 10             	add    $0x10,%esp
80102006:	c6 02 00             	movb   $0x0,(%edx)
80102009:	e9 41 ff ff ff       	jmp    80101f4f <namex+0x9f>
8010200e:	66 90                	xchg   %ax,%ax
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102010:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102013:	85 c0                	test   %eax,%eax
80102015:	0f 85 be 00 00 00    	jne    801020d9 <namex+0x229>
    iput(ip);
    return 0;
  }
  return ip;
}
8010201b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010201e:	89 f0                	mov    %esi,%eax
80102020:	5b                   	pop    %ebx
80102021:	5e                   	pop    %esi
80102022:	5f                   	pop    %edi
80102023:	5d                   	pop    %ebp
80102024:	c3                   	ret    
  while(*path != '/' && *path != 0)
80102025:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102028:	89 df                	mov    %ebx,%edi
8010202a:	31 c0                	xor    %eax,%eax
8010202c:	eb c0                	jmp    80101fee <namex+0x13e>
    ip = iget(ROOTDEV, ROOTINO);
8010202e:	ba 01 00 00 00       	mov    $0x1,%edx
80102033:	b8 01 00 00 00       	mov    $0x1,%eax
80102038:	e8 33 f4 ff ff       	call   80101470 <iget>
8010203d:	89 c6                	mov    %eax,%esi
8010203f:	e9 b7 fe ff ff       	jmp    80101efb <namex+0x4b>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80102044:	83 ec 0c             	sub    $0xc,%esp
80102047:	8d 5e 0c             	lea    0xc(%esi),%ebx
8010204a:	53                   	push   %ebx
8010204b:	e8 50 24 00 00       	call   801044a0 <holdingsleep>
80102050:	83 c4 10             	add    $0x10,%esp
80102053:	85 c0                	test   %eax,%eax
80102055:	0f 84 91 00 00 00    	je     801020ec <namex+0x23c>
8010205b:	8b 46 08             	mov    0x8(%esi),%eax
8010205e:	85 c0                	test   %eax,%eax
80102060:	0f 8e 86 00 00 00    	jle    801020ec <namex+0x23c>
  releasesleep(&ip->lock);
80102066:	83 ec 0c             	sub    $0xc,%esp
80102069:	53                   	push   %ebx
8010206a:	e8 f1 23 00 00       	call   80104460 <releasesleep>
  iput(ip);
8010206f:	89 34 24             	mov    %esi,(%esp)
      return 0;
80102072:	31 f6                	xor    %esi,%esi
  iput(ip);
80102074:	e8 57 f9 ff ff       	call   801019d0 <iput>
      return 0;
80102079:	83 c4 10             	add    $0x10,%esp
}
8010207c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010207f:	89 f0                	mov    %esi,%eax
80102081:	5b                   	pop    %ebx
80102082:	5e                   	pop    %esi
80102083:	5f                   	pop    %edi
80102084:	5d                   	pop    %ebp
80102085:	c3                   	ret    
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80102086:	83 ec 0c             	sub    $0xc,%esp
80102089:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010208c:	52                   	push   %edx
8010208d:	e8 0e 24 00 00       	call   801044a0 <holdingsleep>
80102092:	83 c4 10             	add    $0x10,%esp
80102095:	85 c0                	test   %eax,%eax
80102097:	74 53                	je     801020ec <namex+0x23c>
80102099:	8b 4e 08             	mov    0x8(%esi),%ecx
8010209c:	85 c9                	test   %ecx,%ecx
8010209e:	7e 4c                	jle    801020ec <namex+0x23c>
  releasesleep(&ip->lock);
801020a0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801020a3:	83 ec 0c             	sub    $0xc,%esp
801020a6:	52                   	push   %edx
801020a7:	eb c1                	jmp    8010206a <namex+0x1ba>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
801020a9:	83 ec 0c             	sub    $0xc,%esp
801020ac:	8d 5e 0c             	lea    0xc(%esi),%ebx
801020af:	53                   	push   %ebx
801020b0:	e8 eb 23 00 00       	call   801044a0 <holdingsleep>
801020b5:	83 c4 10             	add    $0x10,%esp
801020b8:	85 c0                	test   %eax,%eax
801020ba:	74 30                	je     801020ec <namex+0x23c>
801020bc:	8b 7e 08             	mov    0x8(%esi),%edi
801020bf:	85 ff                	test   %edi,%edi
801020c1:	7e 29                	jle    801020ec <namex+0x23c>
  releasesleep(&ip->lock);
801020c3:	83 ec 0c             	sub    $0xc,%esp
801020c6:	53                   	push   %ebx
801020c7:	e8 94 23 00 00       	call   80104460 <releasesleep>
}
801020cc:	83 c4 10             	add    $0x10,%esp
}
801020cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
801020d2:	89 f0                	mov    %esi,%eax
801020d4:	5b                   	pop    %ebx
801020d5:	5e                   	pop    %esi
801020d6:	5f                   	pop    %edi
801020d7:	5d                   	pop    %ebp
801020d8:	c3                   	ret    
    iput(ip);
801020d9:	83 ec 0c             	sub    $0xc,%esp
801020dc:	56                   	push   %esi
    return 0;
801020dd:	31 f6                	xor    %esi,%esi
    iput(ip);
801020df:	e8 ec f8 ff ff       	call   801019d0 <iput>
    return 0;
801020e4:	83 c4 10             	add    $0x10,%esp
801020e7:	e9 2f ff ff ff       	jmp    8010201b <namex+0x16b>
    panic("iunlock");
801020ec:	83 ec 0c             	sub    $0xc,%esp
801020ef:	68 43 74 10 80       	push   $0x80107443
801020f4:	e8 87 e2 ff ff       	call   80100380 <panic>
801020f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102100 <dirlink>:
{
80102100:	55                   	push   %ebp
80102101:	89 e5                	mov    %esp,%ebp
80102103:	57                   	push   %edi
80102104:	56                   	push   %esi
80102105:	53                   	push   %ebx
80102106:	83 ec 20             	sub    $0x20,%esp
80102109:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((ip = dirlookup(dp, name, 0)) != 0){
8010210c:	6a 00                	push   $0x0
8010210e:	ff 75 0c             	push   0xc(%ebp)
80102111:	53                   	push   %ebx
80102112:	e8 e9 fc ff ff       	call   80101e00 <dirlookup>
80102117:	83 c4 10             	add    $0x10,%esp
8010211a:	85 c0                	test   %eax,%eax
8010211c:	75 67                	jne    80102185 <dirlink+0x85>
  for(off = 0; off < dp->size; off += sizeof(de)){
8010211e:	8b 7b 58             	mov    0x58(%ebx),%edi
80102121:	8d 75 d8             	lea    -0x28(%ebp),%esi
80102124:	85 ff                	test   %edi,%edi
80102126:	74 29                	je     80102151 <dirlink+0x51>
80102128:	31 ff                	xor    %edi,%edi
8010212a:	8d 75 d8             	lea    -0x28(%ebp),%esi
8010212d:	eb 09                	jmp    80102138 <dirlink+0x38>
8010212f:	90                   	nop
80102130:	83 c7 10             	add    $0x10,%edi
80102133:	3b 7b 58             	cmp    0x58(%ebx),%edi
80102136:	73 19                	jae    80102151 <dirlink+0x51>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102138:	6a 10                	push   $0x10
8010213a:	57                   	push   %edi
8010213b:	56                   	push   %esi
8010213c:	53                   	push   %ebx
8010213d:	e8 6e fa ff ff       	call   80101bb0 <readi>
80102142:	83 c4 10             	add    $0x10,%esp
80102145:	83 f8 10             	cmp    $0x10,%eax
80102148:	75 4e                	jne    80102198 <dirlink+0x98>
    if(de.inum == 0)
8010214a:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
8010214f:	75 df                	jne    80102130 <dirlink+0x30>
  strncpy(de.name, name, DIRSIZ);
80102151:	83 ec 04             	sub    $0x4,%esp
80102154:	8d 45 da             	lea    -0x26(%ebp),%eax
80102157:	6a 0e                	push   $0xe
80102159:	ff 75 0c             	push   0xc(%ebp)
8010215c:	50                   	push   %eax
8010215d:	e8 7e 27 00 00       	call   801048e0 <strncpy>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102162:	6a 10                	push   $0x10
  de.inum = inum;
80102164:	8b 45 10             	mov    0x10(%ebp),%eax
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102167:	57                   	push   %edi
80102168:	56                   	push   %esi
80102169:	53                   	push   %ebx
  de.inum = inum;
8010216a:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010216e:	e8 3d fb ff ff       	call   80101cb0 <writei>
80102173:	83 c4 20             	add    $0x20,%esp
80102176:	83 f8 10             	cmp    $0x10,%eax
80102179:	75 2a                	jne    801021a5 <dirlink+0xa5>
  return 0;
8010217b:	31 c0                	xor    %eax,%eax
}
8010217d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102180:	5b                   	pop    %ebx
80102181:	5e                   	pop    %esi
80102182:	5f                   	pop    %edi
80102183:	5d                   	pop    %ebp
80102184:	c3                   	ret    
    iput(ip);
80102185:	83 ec 0c             	sub    $0xc,%esp
80102188:	50                   	push   %eax
80102189:	e8 42 f8 ff ff       	call   801019d0 <iput>
    return -1;
8010218e:	83 c4 10             	add    $0x10,%esp
80102191:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102196:	eb e5                	jmp    8010217d <dirlink+0x7d>
      panic("dirlink read");
80102198:	83 ec 0c             	sub    $0xc,%esp
8010219b:	68 6c 74 10 80       	push   $0x8010746c
801021a0:	e8 db e1 ff ff       	call   80100380 <panic>
    panic("dirlink");
801021a5:	83 ec 0c             	sub    $0xc,%esp
801021a8:	68 42 7a 10 80       	push   $0x80107a42
801021ad:	e8 ce e1 ff ff       	call   80100380 <panic>
801021b2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801021b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801021c0 <namei>:

struct inode*
namei(char *path)
{
801021c0:	55                   	push   %ebp
  char name[DIRSIZ];
  return namex(path, 0, name);
801021c1:	31 d2                	xor    %edx,%edx
{
801021c3:	89 e5                	mov    %esp,%ebp
801021c5:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 0, name);
801021c8:	8b 45 08             	mov    0x8(%ebp),%eax
801021cb:	8d 4d ea             	lea    -0x16(%ebp),%ecx
801021ce:	e8 dd fc ff ff       	call   80101eb0 <namex>
}
801021d3:	c9                   	leave  
801021d4:	c3                   	ret    
801021d5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801021dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801021e0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801021e0:	55                   	push   %ebp
  return namex(path, 1, name);
801021e1:	ba 01 00 00 00       	mov    $0x1,%edx
{
801021e6:	89 e5                	mov    %esp,%ebp
  return namex(path, 1, name);
801021e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801021eb:	8b 45 08             	mov    0x8(%ebp),%eax
}
801021ee:	5d                   	pop    %ebp
  return namex(path, 1, name);
801021ef:	e9 bc fc ff ff       	jmp    80101eb0 <namex>
801021f4:	66 90                	xchg   %ax,%ax
801021f6:	66 90                	xchg   %ax,%ax
801021f8:	66 90                	xchg   %ax,%ax
801021fa:	66 90                	xchg   %ax,%ax
801021fc:	66 90                	xchg   %ax,%ax
801021fe:	66 90                	xchg   %ax,%ax

80102200 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102200:	55                   	push   %ebp
80102201:	89 e5                	mov    %esp,%ebp
80102203:	57                   	push   %edi
80102204:	56                   	push   %esi
80102205:	53                   	push   %ebx
80102206:	83 ec 0c             	sub    $0xc,%esp
  if(b == 0)
80102209:	85 c0                	test   %eax,%eax
8010220b:	0f 84 b4 00 00 00    	je     801022c5 <idestart+0xc5>
    panic("idestart");
  if(b->blockno >= FSSIZE)
80102211:	8b 70 08             	mov    0x8(%eax),%esi
80102214:	89 c3                	mov    %eax,%ebx
80102216:	81 fe e7 03 00 00    	cmp    $0x3e7,%esi
8010221c:	0f 87 96 00 00 00    	ja     801022b8 <idestart+0xb8>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102222:	b9 f7 01 00 00       	mov    $0x1f7,%ecx
80102227:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010222e:	66 90                	xchg   %ax,%ax
80102230:	89 ca                	mov    %ecx,%edx
80102232:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102233:	83 e0 c0             	and    $0xffffffc0,%eax
80102236:	3c 40                	cmp    $0x40,%al
80102238:	75 f6                	jne    80102230 <idestart+0x30>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010223a:	31 ff                	xor    %edi,%edi
8010223c:	ba f6 03 00 00       	mov    $0x3f6,%edx
80102241:	89 f8                	mov    %edi,%eax
80102243:	ee                   	out    %al,(%dx)
80102244:	b8 01 00 00 00       	mov    $0x1,%eax
80102249:	ba f2 01 00 00       	mov    $0x1f2,%edx
8010224e:	ee                   	out    %al,(%dx)
8010224f:	ba f3 01 00 00       	mov    $0x1f3,%edx
80102254:	89 f0                	mov    %esi,%eax
80102256:	ee                   	out    %al,(%dx)

  idewait(0);
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80102257:	89 f0                	mov    %esi,%eax
80102259:	ba f4 01 00 00       	mov    $0x1f4,%edx
8010225e:	c1 f8 08             	sar    $0x8,%eax
80102261:	ee                   	out    %al,(%dx)
80102262:	ba f5 01 00 00       	mov    $0x1f5,%edx
80102267:	89 f8                	mov    %edi,%eax
80102269:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
8010226a:	0f b6 43 04          	movzbl 0x4(%ebx),%eax
8010226e:	ba f6 01 00 00       	mov    $0x1f6,%edx
80102273:	c1 e0 04             	shl    $0x4,%eax
80102276:	83 e0 10             	and    $0x10,%eax
80102279:	83 c8 e0             	or     $0xffffffe0,%eax
8010227c:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
8010227d:	f6 03 04             	testb  $0x4,(%ebx)
80102280:	75 16                	jne    80102298 <idestart+0x98>
80102282:	b8 20 00 00 00       	mov    $0x20,%eax
80102287:	89 ca                	mov    %ecx,%edx
80102289:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
8010228a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010228d:	5b                   	pop    %ebx
8010228e:	5e                   	pop    %esi
8010228f:	5f                   	pop    %edi
80102290:	5d                   	pop    %ebp
80102291:	c3                   	ret    
80102292:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80102298:	b8 30 00 00 00       	mov    $0x30,%eax
8010229d:	89 ca                	mov    %ecx,%edx
8010229f:	ee                   	out    %al,(%dx)
  asm volatile("cld; rep outsl" :
801022a0:	b9 80 00 00 00       	mov    $0x80,%ecx
    outsl(0x1f0, b->data, BSIZE/4);
801022a5:	8d 73 5c             	lea    0x5c(%ebx),%esi
801022a8:	ba f0 01 00 00       	mov    $0x1f0,%edx
801022ad:	fc                   	cld    
801022ae:	f3 6f                	rep outsl %ds:(%esi),(%dx)
}
801022b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801022b3:	5b                   	pop    %ebx
801022b4:	5e                   	pop    %esi
801022b5:	5f                   	pop    %edi
801022b6:	5d                   	pop    %ebp
801022b7:	c3                   	ret    
    panic("incorrect blockno");
801022b8:	83 ec 0c             	sub    $0xc,%esp
801022bb:	68 d8 74 10 80       	push   $0x801074d8
801022c0:	e8 bb e0 ff ff       	call   80100380 <panic>
    panic("idestart");
801022c5:	83 ec 0c             	sub    $0xc,%esp
801022c8:	68 cf 74 10 80       	push   $0x801074cf
801022cd:	e8 ae e0 ff ff       	call   80100380 <panic>
801022d2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801022d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801022e0 <ideinit>:
{
801022e0:	55                   	push   %ebp
801022e1:	89 e5                	mov    %esp,%ebp
801022e3:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
801022e6:	68 ea 74 10 80       	push   $0x801074ea
801022eb:	68 40 16 11 80       	push   $0x80111640
801022f0:	e8 fb 21 00 00       	call   801044f0 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
801022f5:	58                   	pop    %eax
801022f6:	a1 c4 17 11 80       	mov    0x801117c4,%eax
801022fb:	5a                   	pop    %edx
801022fc:	83 e8 01             	sub    $0x1,%eax
801022ff:	50                   	push   %eax
80102300:	6a 0e                	push   $0xe
80102302:	e8 99 02 00 00       	call   801025a0 <ioapicenable>
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102307:	83 c4 10             	add    $0x10,%esp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010230a:	ba f7 01 00 00       	mov    $0x1f7,%edx
8010230f:	90                   	nop
80102310:	ec                   	in     (%dx),%al
80102311:	83 e0 c0             	and    $0xffffffc0,%eax
80102314:	3c 40                	cmp    $0x40,%al
80102316:	75 f8                	jne    80102310 <ideinit+0x30>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102318:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
8010231d:	ba f6 01 00 00       	mov    $0x1f6,%edx
80102322:	ee                   	out    %al,(%dx)
80102323:	b9 e8 03 00 00       	mov    $0x3e8,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102328:	ba f7 01 00 00       	mov    $0x1f7,%edx
8010232d:	eb 06                	jmp    80102335 <ideinit+0x55>
8010232f:	90                   	nop
  for(i=0; i<1000; i++){
80102330:	83 e9 01             	sub    $0x1,%ecx
80102333:	74 0f                	je     80102344 <ideinit+0x64>
80102335:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80102336:	84 c0                	test   %al,%al
80102338:	74 f6                	je     80102330 <ideinit+0x50>
      havedisk1 = 1;
8010233a:	c7 05 20 16 11 80 01 	movl   $0x1,0x80111620
80102341:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102344:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80102349:	ba f6 01 00 00       	mov    $0x1f6,%edx
8010234e:	ee                   	out    %al,(%dx)
}
8010234f:	c9                   	leave  
80102350:	c3                   	ret    
80102351:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102358:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010235f:	90                   	nop

80102360 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102360:	55                   	push   %ebp
80102361:	89 e5                	mov    %esp,%ebp
80102363:	57                   	push   %edi
80102364:	56                   	push   %esi
80102365:	53                   	push   %ebx
80102366:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102369:	68 40 16 11 80       	push   $0x80111640
8010236e:	e8 4d 23 00 00       	call   801046c0 <acquire>

  if((b = idequeue) == 0){
80102373:	8b 1d 24 16 11 80    	mov    0x80111624,%ebx
80102379:	83 c4 10             	add    $0x10,%esp
8010237c:	85 db                	test   %ebx,%ebx
8010237e:	74 63                	je     801023e3 <ideintr+0x83>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80102380:	8b 43 58             	mov    0x58(%ebx),%eax
80102383:	a3 24 16 11 80       	mov    %eax,0x80111624

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102388:	8b 33                	mov    (%ebx),%esi
8010238a:	f7 c6 04 00 00 00    	test   $0x4,%esi
80102390:	75 2f                	jne    801023c1 <ideintr+0x61>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102392:	ba f7 01 00 00       	mov    $0x1f7,%edx
80102397:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010239e:	66 90                	xchg   %ax,%ax
801023a0:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801023a1:	89 c1                	mov    %eax,%ecx
801023a3:	83 e1 c0             	and    $0xffffffc0,%ecx
801023a6:	80 f9 40             	cmp    $0x40,%cl
801023a9:	75 f5                	jne    801023a0 <ideintr+0x40>
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801023ab:	a8 21                	test   $0x21,%al
801023ad:	75 12                	jne    801023c1 <ideintr+0x61>
    insl(0x1f0, b->data, BSIZE/4);
801023af:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
801023b2:	b9 80 00 00 00       	mov    $0x80,%ecx
801023b7:	ba f0 01 00 00       	mov    $0x1f0,%edx
801023bc:	fc                   	cld    
801023bd:	f3 6d                	rep insl (%dx),%es:(%edi)

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801023bf:	8b 33                	mov    (%ebx),%esi
  b->flags &= ~B_DIRTY;
801023c1:	83 e6 fb             	and    $0xfffffffb,%esi
  wakeup(b);
801023c4:	83 ec 0c             	sub    $0xc,%esp
  b->flags &= ~B_DIRTY;
801023c7:	83 ce 02             	or     $0x2,%esi
801023ca:	89 33                	mov    %esi,(%ebx)
  wakeup(b);
801023cc:	53                   	push   %ebx
801023cd:	e8 4e 1e 00 00       	call   80104220 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
801023d2:	a1 24 16 11 80       	mov    0x80111624,%eax
801023d7:	83 c4 10             	add    $0x10,%esp
801023da:	85 c0                	test   %eax,%eax
801023dc:	74 05                	je     801023e3 <ideintr+0x83>
    idestart(idequeue);
801023de:	e8 1d fe ff ff       	call   80102200 <idestart>
    release(&idelock);
801023e3:	83 ec 0c             	sub    $0xc,%esp
801023e6:	68 40 16 11 80       	push   $0x80111640
801023eb:	e8 70 22 00 00       	call   80104660 <release>

  release(&idelock);
}
801023f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801023f3:	5b                   	pop    %ebx
801023f4:	5e                   	pop    %esi
801023f5:	5f                   	pop    %edi
801023f6:	5d                   	pop    %ebp
801023f7:	c3                   	ret    
801023f8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801023ff:	90                   	nop

80102400 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102400:	55                   	push   %ebp
80102401:	89 e5                	mov    %esp,%ebp
80102403:	53                   	push   %ebx
80102404:	83 ec 10             	sub    $0x10,%esp
80102407:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
8010240a:	8d 43 0c             	lea    0xc(%ebx),%eax
8010240d:	50                   	push   %eax
8010240e:	e8 8d 20 00 00       	call   801044a0 <holdingsleep>
80102413:	83 c4 10             	add    $0x10,%esp
80102416:	85 c0                	test   %eax,%eax
80102418:	0f 84 c3 00 00 00    	je     801024e1 <iderw+0xe1>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010241e:	8b 03                	mov    (%ebx),%eax
80102420:	83 e0 06             	and    $0x6,%eax
80102423:	83 f8 02             	cmp    $0x2,%eax
80102426:	0f 84 a8 00 00 00    	je     801024d4 <iderw+0xd4>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
8010242c:	8b 53 04             	mov    0x4(%ebx),%edx
8010242f:	85 d2                	test   %edx,%edx
80102431:	74 0d                	je     80102440 <iderw+0x40>
80102433:	a1 20 16 11 80       	mov    0x80111620,%eax
80102438:	85 c0                	test   %eax,%eax
8010243a:	0f 84 87 00 00 00    	je     801024c7 <iderw+0xc7>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80102440:	83 ec 0c             	sub    $0xc,%esp
80102443:	68 40 16 11 80       	push   $0x80111640
80102448:	e8 73 22 00 00       	call   801046c0 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010244d:	a1 24 16 11 80       	mov    0x80111624,%eax
  b->qnext = 0;
80102452:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102459:	83 c4 10             	add    $0x10,%esp
8010245c:	85 c0                	test   %eax,%eax
8010245e:	74 60                	je     801024c0 <iderw+0xc0>
80102460:	89 c2                	mov    %eax,%edx
80102462:	8b 40 58             	mov    0x58(%eax),%eax
80102465:	85 c0                	test   %eax,%eax
80102467:	75 f7                	jne    80102460 <iderw+0x60>
80102469:	83 c2 58             	add    $0x58,%edx
    ;
  *pp = b;
8010246c:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
8010246e:	39 1d 24 16 11 80    	cmp    %ebx,0x80111624
80102474:	74 3a                	je     801024b0 <iderw+0xb0>
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102476:	8b 03                	mov    (%ebx),%eax
80102478:	83 e0 06             	and    $0x6,%eax
8010247b:	83 f8 02             	cmp    $0x2,%eax
8010247e:	74 1b                	je     8010249b <iderw+0x9b>
    sleep(b, &idelock);
80102480:	83 ec 08             	sub    $0x8,%esp
80102483:	68 40 16 11 80       	push   $0x80111640
80102488:	53                   	push   %ebx
80102489:	e8 d2 1c 00 00       	call   80104160 <sleep>
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010248e:	8b 03                	mov    (%ebx),%eax
80102490:	83 c4 10             	add    $0x10,%esp
80102493:	83 e0 06             	and    $0x6,%eax
80102496:	83 f8 02             	cmp    $0x2,%eax
80102499:	75 e5                	jne    80102480 <iderw+0x80>
  }


  release(&idelock);
8010249b:	c7 45 08 40 16 11 80 	movl   $0x80111640,0x8(%ebp)
}
801024a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801024a5:	c9                   	leave  
  release(&idelock);
801024a6:	e9 b5 21 00 00       	jmp    80104660 <release>
801024ab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801024af:	90                   	nop
    idestart(b);
801024b0:	89 d8                	mov    %ebx,%eax
801024b2:	e8 49 fd ff ff       	call   80102200 <idestart>
801024b7:	eb bd                	jmp    80102476 <iderw+0x76>
801024b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801024c0:	ba 24 16 11 80       	mov    $0x80111624,%edx
801024c5:	eb a5                	jmp    8010246c <iderw+0x6c>
    panic("iderw: ide disk 1 not present");
801024c7:	83 ec 0c             	sub    $0xc,%esp
801024ca:	68 19 75 10 80       	push   $0x80107519
801024cf:	e8 ac de ff ff       	call   80100380 <panic>
    panic("iderw: nothing to do");
801024d4:	83 ec 0c             	sub    $0xc,%esp
801024d7:	68 04 75 10 80       	push   $0x80107504
801024dc:	e8 9f de ff ff       	call   80100380 <panic>
    panic("iderw: buf not locked");
801024e1:	83 ec 0c             	sub    $0xc,%esp
801024e4:	68 ee 74 10 80       	push   $0x801074ee
801024e9:	e8 92 de ff ff       	call   80100380 <panic>
801024ee:	66 90                	xchg   %ax,%ax

801024f0 <ioapicinit>:
  ioapic->data = data;
}

void
ioapicinit(void)
{
801024f0:	55                   	push   %ebp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
801024f1:	c7 05 74 16 11 80 00 	movl   $0xfec00000,0x80111674
801024f8:	00 c0 fe 
{
801024fb:	89 e5                	mov    %esp,%ebp
801024fd:	56                   	push   %esi
801024fe:	53                   	push   %ebx
  ioapic->reg = reg;
801024ff:	c7 05 00 00 c0 fe 01 	movl   $0x1,0xfec00000
80102506:	00 00 00 
  return ioapic->data;
80102509:	8b 15 74 16 11 80    	mov    0x80111674,%edx
8010250f:	8b 72 10             	mov    0x10(%edx),%esi
  ioapic->reg = reg;
80102512:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
  return ioapic->data;
80102518:	8b 0d 74 16 11 80    	mov    0x80111674,%ecx
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
8010251e:	0f b6 15 c0 17 11 80 	movzbl 0x801117c0,%edx
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102525:	c1 ee 10             	shr    $0x10,%esi
80102528:	89 f0                	mov    %esi,%eax
8010252a:	0f b6 f0             	movzbl %al,%esi
  return ioapic->data;
8010252d:	8b 41 10             	mov    0x10(%ecx),%eax
  id = ioapicread(REG_ID) >> 24;
80102530:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80102533:	39 c2                	cmp    %eax,%edx
80102535:	74 16                	je     8010254d <ioapicinit+0x5d>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102537:	83 ec 0c             	sub    $0xc,%esp
8010253a:	68 38 75 10 80       	push   $0x80107538
8010253f:	e8 5c e1 ff ff       	call   801006a0 <cprintf>
  ioapic->reg = reg;
80102544:	8b 0d 74 16 11 80    	mov    0x80111674,%ecx
8010254a:	83 c4 10             	add    $0x10,%esp
8010254d:	83 c6 21             	add    $0x21,%esi
{
80102550:	ba 10 00 00 00       	mov    $0x10,%edx
80102555:	b8 20 00 00 00       	mov    $0x20,%eax
8010255a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  ioapic->reg = reg;
80102560:	89 11                	mov    %edx,(%ecx)

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102562:	89 c3                	mov    %eax,%ebx
  ioapic->data = data;
80102564:	8b 0d 74 16 11 80    	mov    0x80111674,%ecx
  for(i = 0; i <= maxintr; i++){
8010256a:	83 c0 01             	add    $0x1,%eax
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
8010256d:	81 cb 00 00 01 00    	or     $0x10000,%ebx
  ioapic->data = data;
80102573:	89 59 10             	mov    %ebx,0x10(%ecx)
  ioapic->reg = reg;
80102576:	8d 5a 01             	lea    0x1(%edx),%ebx
  for(i = 0; i <= maxintr; i++){
80102579:	83 c2 02             	add    $0x2,%edx
  ioapic->reg = reg;
8010257c:	89 19                	mov    %ebx,(%ecx)
  ioapic->data = data;
8010257e:	8b 0d 74 16 11 80    	mov    0x80111674,%ecx
80102584:	c7 41 10 00 00 00 00 	movl   $0x0,0x10(%ecx)
  for(i = 0; i <= maxintr; i++){
8010258b:	39 f0                	cmp    %esi,%eax
8010258d:	75 d1                	jne    80102560 <ioapicinit+0x70>
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
8010258f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102592:	5b                   	pop    %ebx
80102593:	5e                   	pop    %esi
80102594:	5d                   	pop    %ebp
80102595:	c3                   	ret    
80102596:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010259d:	8d 76 00             	lea    0x0(%esi),%esi

801025a0 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
801025a0:	55                   	push   %ebp
  ioapic->reg = reg;
801025a1:	8b 0d 74 16 11 80    	mov    0x80111674,%ecx
{
801025a7:	89 e5                	mov    %esp,%ebp
801025a9:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
801025ac:	8d 50 20             	lea    0x20(%eax),%edx
801025af:	8d 44 00 10          	lea    0x10(%eax,%eax,1),%eax
  ioapic->reg = reg;
801025b3:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
801025b5:	8b 0d 74 16 11 80    	mov    0x80111674,%ecx
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801025bb:	83 c0 01             	add    $0x1,%eax
  ioapic->data = data;
801025be:	89 51 10             	mov    %edx,0x10(%ecx)
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801025c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  ioapic->reg = reg;
801025c4:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
801025c6:	a1 74 16 11 80       	mov    0x80111674,%eax
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801025cb:	c1 e2 18             	shl    $0x18,%edx
  ioapic->data = data;
801025ce:	89 50 10             	mov    %edx,0x10(%eax)
}
801025d1:	5d                   	pop    %ebp
801025d2:	c3                   	ret    
801025d3:	66 90                	xchg   %ax,%ax
801025d5:	66 90                	xchg   %ax,%ax
801025d7:	66 90                	xchg   %ax,%ax
801025d9:	66 90                	xchg   %ax,%ax
801025db:	66 90                	xchg   %ax,%ax
801025dd:	66 90                	xchg   %ax,%ax
801025df:	90                   	nop

801025e0 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801025e0:	55                   	push   %ebp
801025e1:	89 e5                	mov    %esp,%ebp
801025e3:	53                   	push   %ebx
801025e4:	83 ec 04             	sub    $0x4,%esp
801025e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
801025ea:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
801025f0:	75 76                	jne    80102668 <kfree+0x88>
801025f2:	81 fb 10 55 11 80    	cmp    $0x80115510,%ebx
801025f8:	72 6e                	jb     80102668 <kfree+0x88>
801025fa:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80102600:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102605:	77 61                	ja     80102668 <kfree+0x88>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102607:	83 ec 04             	sub    $0x4,%esp
8010260a:	68 00 10 00 00       	push   $0x1000
8010260f:	6a 01                	push   $0x1
80102611:	53                   	push   %ebx
80102612:	e8 69 21 00 00       	call   80104780 <memset>

  if(kmem.use_lock)
80102617:	8b 15 b4 16 11 80    	mov    0x801116b4,%edx
8010261d:	83 c4 10             	add    $0x10,%esp
80102620:	85 d2                	test   %edx,%edx
80102622:	75 1c                	jne    80102640 <kfree+0x60>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
80102624:	a1 b8 16 11 80       	mov    0x801116b8,%eax
80102629:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
  if(kmem.use_lock)
8010262b:	a1 b4 16 11 80       	mov    0x801116b4,%eax
  kmem.freelist = r;
80102630:	89 1d b8 16 11 80    	mov    %ebx,0x801116b8
  if(kmem.use_lock)
80102636:	85 c0                	test   %eax,%eax
80102638:	75 1e                	jne    80102658 <kfree+0x78>
    release(&kmem.lock);
}
8010263a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010263d:	c9                   	leave  
8010263e:	c3                   	ret    
8010263f:	90                   	nop
    acquire(&kmem.lock);
80102640:	83 ec 0c             	sub    $0xc,%esp
80102643:	68 80 16 11 80       	push   $0x80111680
80102648:	e8 73 20 00 00       	call   801046c0 <acquire>
8010264d:	83 c4 10             	add    $0x10,%esp
80102650:	eb d2                	jmp    80102624 <kfree+0x44>
80102652:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    release(&kmem.lock);
80102658:	c7 45 08 80 16 11 80 	movl   $0x80111680,0x8(%ebp)
}
8010265f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102662:	c9                   	leave  
    release(&kmem.lock);
80102663:	e9 f8 1f 00 00       	jmp    80104660 <release>
    panic("kfree");
80102668:	83 ec 0c             	sub    $0xc,%esp
8010266b:	68 6a 75 10 80       	push   $0x8010756a
80102670:	e8 0b dd ff ff       	call   80100380 <panic>
80102675:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010267c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102680 <freerange>:
{
80102680:	55                   	push   %ebp
80102681:	89 e5                	mov    %esp,%ebp
80102683:	56                   	push   %esi
  p = (char*)PGROUNDUP((uint)vstart);
80102684:	8b 45 08             	mov    0x8(%ebp),%eax
{
80102687:	8b 75 0c             	mov    0xc(%ebp),%esi
8010268a:	53                   	push   %ebx
  p = (char*)PGROUNDUP((uint)vstart);
8010268b:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80102691:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102697:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010269d:	39 de                	cmp    %ebx,%esi
8010269f:	72 23                	jb     801026c4 <freerange+0x44>
801026a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    kfree(p);
801026a8:	83 ec 0c             	sub    $0xc,%esp
801026ab:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026b1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
801026b7:	50                   	push   %eax
801026b8:	e8 23 ff ff ff       	call   801025e0 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026bd:	83 c4 10             	add    $0x10,%esp
801026c0:	39 f3                	cmp    %esi,%ebx
801026c2:	76 e4                	jbe    801026a8 <freerange+0x28>
}
801026c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801026c7:	5b                   	pop    %ebx
801026c8:	5e                   	pop    %esi
801026c9:	5d                   	pop    %ebp
801026ca:	c3                   	ret    
801026cb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801026cf:	90                   	nop

801026d0 <kinit2>:
{
801026d0:	55                   	push   %ebp
801026d1:	89 e5                	mov    %esp,%ebp
801026d3:	56                   	push   %esi
  p = (char*)PGROUNDUP((uint)vstart);
801026d4:	8b 45 08             	mov    0x8(%ebp),%eax
{
801026d7:	8b 75 0c             	mov    0xc(%ebp),%esi
801026da:	53                   	push   %ebx
  p = (char*)PGROUNDUP((uint)vstart);
801026db:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801026e1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026e7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801026ed:	39 de                	cmp    %ebx,%esi
801026ef:	72 23                	jb     80102714 <kinit2+0x44>
801026f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    kfree(p);
801026f8:	83 ec 0c             	sub    $0xc,%esp
801026fb:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102701:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
80102707:	50                   	push   %eax
80102708:	e8 d3 fe ff ff       	call   801025e0 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010270d:	83 c4 10             	add    $0x10,%esp
80102710:	39 de                	cmp    %ebx,%esi
80102712:	73 e4                	jae    801026f8 <kinit2+0x28>
  kmem.use_lock = 1;
80102714:	c7 05 b4 16 11 80 01 	movl   $0x1,0x801116b4
8010271b:	00 00 00 
}
8010271e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102721:	5b                   	pop    %ebx
80102722:	5e                   	pop    %esi
80102723:	5d                   	pop    %ebp
80102724:	c3                   	ret    
80102725:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010272c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102730 <kinit1>:
{
80102730:	55                   	push   %ebp
80102731:	89 e5                	mov    %esp,%ebp
80102733:	56                   	push   %esi
80102734:	53                   	push   %ebx
80102735:	8b 75 0c             	mov    0xc(%ebp),%esi
  initlock(&kmem.lock, "kmem");
80102738:	83 ec 08             	sub    $0x8,%esp
8010273b:	68 70 75 10 80       	push   $0x80107570
80102740:	68 80 16 11 80       	push   $0x80111680
80102745:	e8 a6 1d 00 00       	call   801044f0 <initlock>
  p = (char*)PGROUNDUP((uint)vstart);
8010274a:	8b 45 08             	mov    0x8(%ebp),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010274d:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102750:	c7 05 b4 16 11 80 00 	movl   $0x0,0x801116b4
80102757:	00 00 00 
  p = (char*)PGROUNDUP((uint)vstart);
8010275a:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80102760:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102766:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010276c:	39 de                	cmp    %ebx,%esi
8010276e:	72 1c                	jb     8010278c <kinit1+0x5c>
    kfree(p);
80102770:	83 ec 0c             	sub    $0xc,%esp
80102773:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102779:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
8010277f:	50                   	push   %eax
80102780:	e8 5b fe ff ff       	call   801025e0 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102785:	83 c4 10             	add    $0x10,%esp
80102788:	39 de                	cmp    %ebx,%esi
8010278a:	73 e4                	jae    80102770 <kinit1+0x40>
}
8010278c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010278f:	5b                   	pop    %ebx
80102790:	5e                   	pop    %esi
80102791:	5d                   	pop    %ebp
80102792:	c3                   	ret    
80102793:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010279a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801027a0 <kalloc>:
char*
kalloc(void)
{
  struct run *r;

  if(kmem.use_lock)
801027a0:	a1 b4 16 11 80       	mov    0x801116b4,%eax
801027a5:	85 c0                	test   %eax,%eax
801027a7:	75 1f                	jne    801027c8 <kalloc+0x28>
    acquire(&kmem.lock);
  r = kmem.freelist;
801027a9:	a1 b8 16 11 80       	mov    0x801116b8,%eax
  if(r)
801027ae:	85 c0                	test   %eax,%eax
801027b0:	74 0e                	je     801027c0 <kalloc+0x20>
    kmem.freelist = r->next;
801027b2:	8b 10                	mov    (%eax),%edx
801027b4:	89 15 b8 16 11 80    	mov    %edx,0x801116b8
  if(kmem.use_lock)
801027ba:	c3                   	ret    
801027bb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801027bf:	90                   	nop
    release(&kmem.lock);
  return (char*)r;
}
801027c0:	c3                   	ret    
801027c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
{
801027c8:	55                   	push   %ebp
801027c9:	89 e5                	mov    %esp,%ebp
801027cb:	83 ec 24             	sub    $0x24,%esp
    acquire(&kmem.lock);
801027ce:	68 80 16 11 80       	push   $0x80111680
801027d3:	e8 e8 1e 00 00       	call   801046c0 <acquire>
  r = kmem.freelist;
801027d8:	a1 b8 16 11 80       	mov    0x801116b8,%eax
  if(kmem.use_lock)
801027dd:	8b 15 b4 16 11 80    	mov    0x801116b4,%edx
  if(r)
801027e3:	83 c4 10             	add    $0x10,%esp
801027e6:	85 c0                	test   %eax,%eax
801027e8:	74 08                	je     801027f2 <kalloc+0x52>
    kmem.freelist = r->next;
801027ea:	8b 08                	mov    (%eax),%ecx
801027ec:	89 0d b8 16 11 80    	mov    %ecx,0x801116b8
  if(kmem.use_lock)
801027f2:	85 d2                	test   %edx,%edx
801027f4:	74 16                	je     8010280c <kalloc+0x6c>
    release(&kmem.lock);
801027f6:	83 ec 0c             	sub    $0xc,%esp
801027f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801027fc:	68 80 16 11 80       	push   $0x80111680
80102801:	e8 5a 1e 00 00       	call   80104660 <release>
  return (char*)r;
80102806:	8b 45 f4             	mov    -0xc(%ebp),%eax
    release(&kmem.lock);
80102809:	83 c4 10             	add    $0x10,%esp
}
8010280c:	c9                   	leave  
8010280d:	c3                   	ret    
8010280e:	66 90                	xchg   %ax,%ax

80102810 <kbdgetc>:
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102810:	ba 64 00 00 00       	mov    $0x64,%edx
80102815:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
80102816:	a8 01                	test   $0x1,%al
80102818:	0f 84 c2 00 00 00    	je     801028e0 <kbdgetc+0xd0>
{
8010281e:	55                   	push   %ebp
8010281f:	ba 60 00 00 00       	mov    $0x60,%edx
80102824:	89 e5                	mov    %esp,%ebp
80102826:	53                   	push   %ebx
80102827:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);

  if(data == 0xE0){
    shift |= E0ESC;
80102828:	8b 1d bc 16 11 80    	mov    0x801116bc,%ebx
  data = inb(KBDATAP);
8010282e:	0f b6 c8             	movzbl %al,%ecx
  if(data == 0xE0){
80102831:	3c e0                	cmp    $0xe0,%al
80102833:	74 5b                	je     80102890 <kbdgetc+0x80>
    return 0;
  } else if(data & 0x80){
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102835:	89 da                	mov    %ebx,%edx
80102837:	83 e2 40             	and    $0x40,%edx
  } else if(data & 0x80){
8010283a:	84 c0                	test   %al,%al
8010283c:	78 62                	js     801028a0 <kbdgetc+0x90>
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
8010283e:	85 d2                	test   %edx,%edx
80102840:	74 09                	je     8010284b <kbdgetc+0x3b>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102842:	83 c8 80             	or     $0xffffff80,%eax
    shift &= ~E0ESC;
80102845:	83 e3 bf             	and    $0xffffffbf,%ebx
    data |= 0x80;
80102848:	0f b6 c8             	movzbl %al,%ecx
  }

  shift |= shiftcode[data];
8010284b:	0f b6 91 a0 76 10 80 	movzbl -0x7fef8960(%ecx),%edx
  shift ^= togglecode[data];
80102852:	0f b6 81 a0 75 10 80 	movzbl -0x7fef8a60(%ecx),%eax
  shift |= shiftcode[data];
80102859:	09 da                	or     %ebx,%edx
  shift ^= togglecode[data];
8010285b:	31 c2                	xor    %eax,%edx
  c = charcode[shift & (CTL | SHIFT)][data];
8010285d:	89 d0                	mov    %edx,%eax
  shift ^= togglecode[data];
8010285f:	89 15 bc 16 11 80    	mov    %edx,0x801116bc
  c = charcode[shift & (CTL | SHIFT)][data];
80102865:	83 e0 03             	and    $0x3,%eax
  if(shift & CAPSLOCK){
80102868:	83 e2 08             	and    $0x8,%edx
  c = charcode[shift & (CTL | SHIFT)][data];
8010286b:	8b 04 85 80 75 10 80 	mov    -0x7fef8a80(,%eax,4),%eax
80102872:	0f b6 04 08          	movzbl (%eax,%ecx,1),%eax
  if(shift & CAPSLOCK){
80102876:	74 0b                	je     80102883 <kbdgetc+0x73>
    if('a' <= c && c <= 'z')
80102878:	8d 50 9f             	lea    -0x61(%eax),%edx
8010287b:	83 fa 19             	cmp    $0x19,%edx
8010287e:	77 48                	ja     801028c8 <kbdgetc+0xb8>
      c += 'A' - 'a';
80102880:	83 e8 20             	sub    $0x20,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
80102883:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102886:	c9                   	leave  
80102887:	c3                   	ret    
80102888:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010288f:	90                   	nop
    shift |= E0ESC;
80102890:	83 cb 40             	or     $0x40,%ebx
    return 0;
80102893:	31 c0                	xor    %eax,%eax
    shift |= E0ESC;
80102895:	89 1d bc 16 11 80    	mov    %ebx,0x801116bc
}
8010289b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010289e:	c9                   	leave  
8010289f:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
801028a0:	83 e0 7f             	and    $0x7f,%eax
801028a3:	85 d2                	test   %edx,%edx
801028a5:	0f 44 c8             	cmove  %eax,%ecx
    shift &= ~(shiftcode[data] | E0ESC);
801028a8:	0f b6 81 a0 76 10 80 	movzbl -0x7fef8960(%ecx),%eax
801028af:	83 c8 40             	or     $0x40,%eax
801028b2:	0f b6 c0             	movzbl %al,%eax
801028b5:	f7 d0                	not    %eax
801028b7:	21 d8                	and    %ebx,%eax
}
801028b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    shift &= ~(shiftcode[data] | E0ESC);
801028bc:	a3 bc 16 11 80       	mov    %eax,0x801116bc
    return 0;
801028c1:	31 c0                	xor    %eax,%eax
}
801028c3:	c9                   	leave  
801028c4:	c3                   	ret    
801028c5:	8d 76 00             	lea    0x0(%esi),%esi
    else if('A' <= c && c <= 'Z')
801028c8:	8d 48 bf             	lea    -0x41(%eax),%ecx
      c += 'a' - 'A';
801028cb:	8d 50 20             	lea    0x20(%eax),%edx
}
801028ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801028d1:	c9                   	leave  
      c += 'a' - 'A';
801028d2:	83 f9 1a             	cmp    $0x1a,%ecx
801028d5:	0f 42 c2             	cmovb  %edx,%eax
}
801028d8:	c3                   	ret    
801028d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
801028e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801028e5:	c3                   	ret    
801028e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801028ed:	8d 76 00             	lea    0x0(%esi),%esi

801028f0 <kbdintr>:

void
kbdintr(void)
{
801028f0:	55                   	push   %ebp
801028f1:	89 e5                	mov    %esp,%ebp
801028f3:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
801028f6:	68 10 28 10 80       	push   $0x80102810
801028fb:	e8 80 df ff ff       	call   80100880 <consoleintr>
}
80102900:	83 c4 10             	add    $0x10,%esp
80102903:	c9                   	leave  
80102904:	c3                   	ret    
80102905:	66 90                	xchg   %ax,%ax
80102907:	66 90                	xchg   %ax,%ax
80102909:	66 90                	xchg   %ax,%ax
8010290b:	66 90                	xchg   %ax,%ax
8010290d:	66 90                	xchg   %ax,%ax
8010290f:	90                   	nop

80102910 <lapicinit>:
}

void
lapicinit(void)
{
  if(!lapic)
80102910:	a1 c0 16 11 80       	mov    0x801116c0,%eax
80102915:	85 c0                	test   %eax,%eax
80102917:	0f 84 cb 00 00 00    	je     801029e8 <lapicinit+0xd8>
  lapic[index] = value;
8010291d:	c7 80 f0 00 00 00 3f 	movl   $0x13f,0xf0(%eax)
80102924:	01 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102927:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
8010292a:	c7 80 e0 03 00 00 0b 	movl   $0xb,0x3e0(%eax)
80102931:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102934:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102937:	c7 80 20 03 00 00 20 	movl   $0x20020,0x320(%eax)
8010293e:	00 02 00 
  lapic[ID];  // wait for write to finish, by reading
80102941:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102944:	c7 80 80 03 00 00 80 	movl   $0x989680,0x380(%eax)
8010294b:	96 98 00 
  lapic[ID];  // wait for write to finish, by reading
8010294e:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102951:	c7 80 50 03 00 00 00 	movl   $0x10000,0x350(%eax)
80102958:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
8010295b:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
8010295e:	c7 80 60 03 00 00 00 	movl   $0x10000,0x360(%eax)
80102965:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
80102968:	8b 50 20             	mov    0x20(%eax),%edx
  lapicw(LINT0, MASKED);
  lapicw(LINT1, MASKED);

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010296b:	8b 50 30             	mov    0x30(%eax),%edx
8010296e:	c1 ea 10             	shr    $0x10,%edx
80102971:	81 e2 fc 00 00 00    	and    $0xfc,%edx
80102977:	75 77                	jne    801029f0 <lapicinit+0xe0>
  lapic[index] = value;
80102979:	c7 80 70 03 00 00 33 	movl   $0x33,0x370(%eax)
80102980:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102983:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102986:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
8010298d:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102990:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102993:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
8010299a:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
8010299d:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801029a0:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
801029a7:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801029aa:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801029ad:	c7 80 10 03 00 00 00 	movl   $0x0,0x310(%eax)
801029b4:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801029b7:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801029ba:	c7 80 00 03 00 00 00 	movl   $0x88500,0x300(%eax)
801029c1:	85 08 00 
  lapic[ID];  // wait for write to finish, by reading
801029c4:	8b 50 20             	mov    0x20(%eax),%edx
801029c7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801029ce:	66 90                	xchg   %ax,%ax
  lapicw(EOI, 0);

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
  lapicw(ICRLO, BCAST | INIT | LEVEL);
  while(lapic[ICRLO] & DELIVS)
801029d0:	8b 90 00 03 00 00    	mov    0x300(%eax),%edx
801029d6:	80 e6 10             	and    $0x10,%dh
801029d9:	75 f5                	jne    801029d0 <lapicinit+0xc0>
  lapic[index] = value;
801029db:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
801029e2:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801029e5:	8b 40 20             	mov    0x20(%eax),%eax
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
801029e8:	c3                   	ret    
801029e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  lapic[index] = value;
801029f0:	c7 80 40 03 00 00 00 	movl   $0x10000,0x340(%eax)
801029f7:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
801029fa:	8b 50 20             	mov    0x20(%eax),%edx
}
801029fd:	e9 77 ff ff ff       	jmp    80102979 <lapicinit+0x69>
80102a02:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102a09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102a10 <lapicid>:

int
lapicid(void)
{
  if (!lapic)
80102a10:	a1 c0 16 11 80       	mov    0x801116c0,%eax
80102a15:	85 c0                	test   %eax,%eax
80102a17:	74 07                	je     80102a20 <lapicid+0x10>
    return 0;
  return lapic[ID] >> 24;
80102a19:	8b 40 20             	mov    0x20(%eax),%eax
80102a1c:	c1 e8 18             	shr    $0x18,%eax
80102a1f:	c3                   	ret    
    return 0;
80102a20:	31 c0                	xor    %eax,%eax
}
80102a22:	c3                   	ret    
80102a23:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102a2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80102a30 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
  if(lapic)
80102a30:	a1 c0 16 11 80       	mov    0x801116c0,%eax
80102a35:	85 c0                	test   %eax,%eax
80102a37:	74 0d                	je     80102a46 <lapiceoi+0x16>
  lapic[index] = value;
80102a39:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80102a40:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102a43:	8b 40 20             	mov    0x20(%eax),%eax
    lapicw(EOI, 0);
}
80102a46:	c3                   	ret    
80102a47:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102a4e:	66 90                	xchg   %ax,%ax

80102a50 <microdelay>:
// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
}
80102a50:	c3                   	ret    
80102a51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102a58:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102a5f:	90                   	nop

80102a60 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102a60:	55                   	push   %ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102a61:	b8 0f 00 00 00       	mov    $0xf,%eax
80102a66:	ba 70 00 00 00       	mov    $0x70,%edx
80102a6b:	89 e5                	mov    %esp,%ebp
80102a6d:	53                   	push   %ebx
80102a6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102a71:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102a74:	ee                   	out    %al,(%dx)
80102a75:	b8 0a 00 00 00       	mov    $0xa,%eax
80102a7a:	ba 71 00 00 00       	mov    $0x71,%edx
80102a7f:	ee                   	out    %al,(%dx)
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
  outb(CMOS_PORT+1, 0x0A);
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
  wrv[0] = 0;
80102a80:	31 c0                	xor    %eax,%eax
  wrv[1] = addr >> 4;

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102a82:	c1 e3 18             	shl    $0x18,%ebx
  wrv[0] = 0;
80102a85:	66 a3 67 04 00 80    	mov    %ax,0x80000467
  wrv[1] = addr >> 4;
80102a8b:	89 c8                	mov    %ecx,%eax
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
80102a8d:	c1 e9 0c             	shr    $0xc,%ecx
  lapicw(ICRHI, apicid<<24);
80102a90:	89 da                	mov    %ebx,%edx
  wrv[1] = addr >> 4;
80102a92:	c1 e8 04             	shr    $0x4,%eax
    lapicw(ICRLO, STARTUP | (addr>>12));
80102a95:	80 cd 06             	or     $0x6,%ch
  wrv[1] = addr >> 4;
80102a98:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapic[index] = value;
80102a9e:	a1 c0 16 11 80       	mov    0x801116c0,%eax
80102aa3:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102aa9:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102aac:	c7 80 00 03 00 00 00 	movl   $0xc500,0x300(%eax)
80102ab3:	c5 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102ab6:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102ab9:	c7 80 00 03 00 00 00 	movl   $0x8500,0x300(%eax)
80102ac0:	85 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102ac3:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102ac6:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102acc:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102acf:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102ad5:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102ad8:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102ade:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102ae1:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102ae7:	8b 40 20             	mov    0x20(%eax),%eax
    microdelay(200);
  }
}
80102aea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102aed:	c9                   	leave  
80102aee:	c3                   	ret    
80102aef:	90                   	nop

80102af0 <cmostime>:
}

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
80102af0:	55                   	push   %ebp
80102af1:	b8 0b 00 00 00       	mov    $0xb,%eax
80102af6:	ba 70 00 00 00       	mov    $0x70,%edx
80102afb:	89 e5                	mov    %esp,%ebp
80102afd:	57                   	push   %edi
80102afe:	56                   	push   %esi
80102aff:	53                   	push   %ebx
80102b00:	83 ec 4c             	sub    $0x4c,%esp
80102b03:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b04:	ba 71 00 00 00       	mov    $0x71,%edx
80102b09:	ec                   	in     (%dx),%al
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);

  bcd = (sb & (1 << 2)) == 0;
80102b0a:	83 e0 04             	and    $0x4,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102b0d:	bb 70 00 00 00       	mov    $0x70,%ebx
80102b12:	88 45 b3             	mov    %al,-0x4d(%ebp)
80102b15:	8d 76 00             	lea    0x0(%esi),%esi
80102b18:	31 c0                	xor    %eax,%eax
80102b1a:	89 da                	mov    %ebx,%edx
80102b1c:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b1d:	b9 71 00 00 00       	mov    $0x71,%ecx
80102b22:	89 ca                	mov    %ecx,%edx
80102b24:	ec                   	in     (%dx),%al
80102b25:	88 45 b7             	mov    %al,-0x49(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102b28:	89 da                	mov    %ebx,%edx
80102b2a:	b8 02 00 00 00       	mov    $0x2,%eax
80102b2f:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b30:	89 ca                	mov    %ecx,%edx
80102b32:	ec                   	in     (%dx),%al
80102b33:	88 45 b6             	mov    %al,-0x4a(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102b36:	89 da                	mov    %ebx,%edx
80102b38:	b8 04 00 00 00       	mov    $0x4,%eax
80102b3d:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b3e:	89 ca                	mov    %ecx,%edx
80102b40:	ec                   	in     (%dx),%al
80102b41:	88 45 b5             	mov    %al,-0x4b(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102b44:	89 da                	mov    %ebx,%edx
80102b46:	b8 07 00 00 00       	mov    $0x7,%eax
80102b4b:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b4c:	89 ca                	mov    %ecx,%edx
80102b4e:	ec                   	in     (%dx),%al
80102b4f:	88 45 b4             	mov    %al,-0x4c(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102b52:	89 da                	mov    %ebx,%edx
80102b54:	b8 08 00 00 00       	mov    $0x8,%eax
80102b59:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b5a:	89 ca                	mov    %ecx,%edx
80102b5c:	ec                   	in     (%dx),%al
80102b5d:	89 c7                	mov    %eax,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102b5f:	89 da                	mov    %ebx,%edx
80102b61:	b8 09 00 00 00       	mov    $0x9,%eax
80102b66:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b67:	89 ca                	mov    %ecx,%edx
80102b69:	ec                   	in     (%dx),%al
80102b6a:	89 c6                	mov    %eax,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102b6c:	89 da                	mov    %ebx,%edx
80102b6e:	b8 0a 00 00 00       	mov    $0xa,%eax
80102b73:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b74:	89 ca                	mov    %ecx,%edx
80102b76:	ec                   	in     (%dx),%al

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102b77:	84 c0                	test   %al,%al
80102b79:	78 9d                	js     80102b18 <cmostime+0x28>
  return inb(CMOS_RETURN);
80102b7b:	0f b6 45 b7          	movzbl -0x49(%ebp),%eax
80102b7f:	89 fa                	mov    %edi,%edx
80102b81:	0f b6 fa             	movzbl %dl,%edi
80102b84:	89 f2                	mov    %esi,%edx
80102b86:	89 45 b8             	mov    %eax,-0x48(%ebp)
80102b89:	0f b6 45 b6          	movzbl -0x4a(%ebp),%eax
80102b8d:	0f b6 f2             	movzbl %dl,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102b90:	89 da                	mov    %ebx,%edx
80102b92:	89 7d c8             	mov    %edi,-0x38(%ebp)
80102b95:	89 45 bc             	mov    %eax,-0x44(%ebp)
80102b98:	0f b6 45 b5          	movzbl -0x4b(%ebp),%eax
80102b9c:	89 75 cc             	mov    %esi,-0x34(%ebp)
80102b9f:	89 45 c0             	mov    %eax,-0x40(%ebp)
80102ba2:	0f b6 45 b4          	movzbl -0x4c(%ebp),%eax
80102ba6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
80102ba9:	31 c0                	xor    %eax,%eax
80102bab:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bac:	89 ca                	mov    %ecx,%edx
80102bae:	ec                   	in     (%dx),%al
80102baf:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102bb2:	89 da                	mov    %ebx,%edx
80102bb4:	89 45 d0             	mov    %eax,-0x30(%ebp)
80102bb7:	b8 02 00 00 00       	mov    $0x2,%eax
80102bbc:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bbd:	89 ca                	mov    %ecx,%edx
80102bbf:	ec                   	in     (%dx),%al
80102bc0:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102bc3:	89 da                	mov    %ebx,%edx
80102bc5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80102bc8:	b8 04 00 00 00       	mov    $0x4,%eax
80102bcd:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bce:	89 ca                	mov    %ecx,%edx
80102bd0:	ec                   	in     (%dx),%al
80102bd1:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102bd4:	89 da                	mov    %ebx,%edx
80102bd6:	89 45 d8             	mov    %eax,-0x28(%ebp)
80102bd9:	b8 07 00 00 00       	mov    $0x7,%eax
80102bde:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bdf:	89 ca                	mov    %ecx,%edx
80102be1:	ec                   	in     (%dx),%al
80102be2:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102be5:	89 da                	mov    %ebx,%edx
80102be7:	89 45 dc             	mov    %eax,-0x24(%ebp)
80102bea:	b8 08 00 00 00       	mov    $0x8,%eax
80102bef:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bf0:	89 ca                	mov    %ecx,%edx
80102bf2:	ec                   	in     (%dx),%al
80102bf3:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102bf6:	89 da                	mov    %ebx,%edx
80102bf8:	89 45 e0             	mov    %eax,-0x20(%ebp)
80102bfb:	b8 09 00 00 00       	mov    $0x9,%eax
80102c00:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c01:	89 ca                	mov    %ecx,%edx
80102c03:	ec                   	in     (%dx),%al
80102c04:	0f b6 c0             	movzbl %al,%eax
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102c07:	83 ec 04             	sub    $0x4,%esp
  return inb(CMOS_RETURN);
80102c0a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102c0d:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102c10:	6a 18                	push   $0x18
80102c12:	50                   	push   %eax
80102c13:	8d 45 b8             	lea    -0x48(%ebp),%eax
80102c16:	50                   	push   %eax
80102c17:	e8 b4 1b 00 00       	call   801047d0 <memcmp>
80102c1c:	83 c4 10             	add    $0x10,%esp
80102c1f:	85 c0                	test   %eax,%eax
80102c21:	0f 85 f1 fe ff ff    	jne    80102b18 <cmostime+0x28>
      break;
  }

  // convert
  if(bcd) {
80102c27:	80 7d b3 00          	cmpb   $0x0,-0x4d(%ebp)
80102c2b:	75 78                	jne    80102ca5 <cmostime+0x1b5>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102c2d:	8b 45 b8             	mov    -0x48(%ebp),%eax
80102c30:	89 c2                	mov    %eax,%edx
80102c32:	83 e0 0f             	and    $0xf,%eax
80102c35:	c1 ea 04             	shr    $0x4,%edx
80102c38:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102c3b:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102c3e:	89 45 b8             	mov    %eax,-0x48(%ebp)
    CONV(minute);
80102c41:	8b 45 bc             	mov    -0x44(%ebp),%eax
80102c44:	89 c2                	mov    %eax,%edx
80102c46:	83 e0 0f             	and    $0xf,%eax
80102c49:	c1 ea 04             	shr    $0x4,%edx
80102c4c:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102c4f:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102c52:	89 45 bc             	mov    %eax,-0x44(%ebp)
    CONV(hour  );
80102c55:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102c58:	89 c2                	mov    %eax,%edx
80102c5a:	83 e0 0f             	and    $0xf,%eax
80102c5d:	c1 ea 04             	shr    $0x4,%edx
80102c60:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102c63:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102c66:	89 45 c0             	mov    %eax,-0x40(%ebp)
    CONV(day   );
80102c69:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102c6c:	89 c2                	mov    %eax,%edx
80102c6e:	83 e0 0f             	and    $0xf,%eax
80102c71:	c1 ea 04             	shr    $0x4,%edx
80102c74:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102c77:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102c7a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    CONV(month );
80102c7d:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102c80:	89 c2                	mov    %eax,%edx
80102c82:	83 e0 0f             	and    $0xf,%eax
80102c85:	c1 ea 04             	shr    $0x4,%edx
80102c88:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102c8b:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102c8e:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(year  );
80102c91:	8b 45 cc             	mov    -0x34(%ebp),%eax
80102c94:	89 c2                	mov    %eax,%edx
80102c96:	83 e0 0f             	and    $0xf,%eax
80102c99:	c1 ea 04             	shr    $0x4,%edx
80102c9c:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102c9f:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102ca2:	89 45 cc             	mov    %eax,-0x34(%ebp)
#undef     CONV
  }

  *r = t1;
80102ca5:	8b 75 08             	mov    0x8(%ebp),%esi
80102ca8:	8b 45 b8             	mov    -0x48(%ebp),%eax
80102cab:	89 06                	mov    %eax,(%esi)
80102cad:	8b 45 bc             	mov    -0x44(%ebp),%eax
80102cb0:	89 46 04             	mov    %eax,0x4(%esi)
80102cb3:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102cb6:	89 46 08             	mov    %eax,0x8(%esi)
80102cb9:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102cbc:	89 46 0c             	mov    %eax,0xc(%esi)
80102cbf:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102cc2:	89 46 10             	mov    %eax,0x10(%esi)
80102cc5:	8b 45 cc             	mov    -0x34(%ebp),%eax
80102cc8:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
80102ccb:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
80102cd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102cd5:	5b                   	pop    %ebx
80102cd6:	5e                   	pop    %esi
80102cd7:	5f                   	pop    %edi
80102cd8:	5d                   	pop    %ebp
80102cd9:	c3                   	ret    
80102cda:	66 90                	xchg   %ax,%ax
80102cdc:	66 90                	xchg   %ax,%ax
80102cde:	66 90                	xchg   %ax,%ax

80102ce0 <install_trans>:
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102ce0:	8b 0d 28 17 11 80    	mov    0x80111728,%ecx
80102ce6:	85 c9                	test   %ecx,%ecx
80102ce8:	0f 8e 8a 00 00 00    	jle    80102d78 <install_trans+0x98>
{
80102cee:	55                   	push   %ebp
80102cef:	89 e5                	mov    %esp,%ebp
80102cf1:	57                   	push   %edi
  for (tail = 0; tail < log.lh.n; tail++) {
80102cf2:	31 ff                	xor    %edi,%edi
{
80102cf4:	56                   	push   %esi
80102cf5:	53                   	push   %ebx
80102cf6:	83 ec 0c             	sub    $0xc,%esp
80102cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102d00:	a1 14 17 11 80       	mov    0x80111714,%eax
80102d05:	83 ec 08             	sub    $0x8,%esp
80102d08:	01 f8                	add    %edi,%eax
80102d0a:	83 c0 01             	add    $0x1,%eax
80102d0d:	50                   	push   %eax
80102d0e:	ff 35 24 17 11 80    	push   0x80111724
80102d14:	e8 b7 d3 ff ff       	call   801000d0 <bread>
80102d19:	89 c6                	mov    %eax,%esi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102d1b:	58                   	pop    %eax
80102d1c:	5a                   	pop    %edx
80102d1d:	ff 34 bd 2c 17 11 80 	push   -0x7feee8d4(,%edi,4)
80102d24:	ff 35 24 17 11 80    	push   0x80111724
  for (tail = 0; tail < log.lh.n; tail++) {
80102d2a:	83 c7 01             	add    $0x1,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102d2d:	e8 9e d3 ff ff       	call   801000d0 <bread>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102d32:	83 c4 0c             	add    $0xc,%esp
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102d35:	89 c3                	mov    %eax,%ebx
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102d37:	8d 46 5c             	lea    0x5c(%esi),%eax
80102d3a:	68 00 02 00 00       	push   $0x200
80102d3f:	50                   	push   %eax
80102d40:	8d 43 5c             	lea    0x5c(%ebx),%eax
80102d43:	50                   	push   %eax
80102d44:	e8 d7 1a 00 00       	call   80104820 <memmove>
    bwrite(dbuf);  // write dst to disk
80102d49:	89 1c 24             	mov    %ebx,(%esp)
80102d4c:	e8 5f d4 ff ff       	call   801001b0 <bwrite>
    brelse(lbuf);
80102d51:	89 34 24             	mov    %esi,(%esp)
80102d54:	e8 97 d4 ff ff       	call   801001f0 <brelse>
    brelse(dbuf);
80102d59:	89 1c 24             	mov    %ebx,(%esp)
80102d5c:	e8 8f d4 ff ff       	call   801001f0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102d61:	83 c4 10             	add    $0x10,%esp
80102d64:	39 3d 28 17 11 80    	cmp    %edi,0x80111728
80102d6a:	7f 94                	jg     80102d00 <install_trans+0x20>
  }
}
80102d6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102d6f:	5b                   	pop    %ebx
80102d70:	5e                   	pop    %esi
80102d71:	5f                   	pop    %edi
80102d72:	5d                   	pop    %ebp
80102d73:	c3                   	ret    
80102d74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102d78:	c3                   	ret    
80102d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102d80 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102d80:	55                   	push   %ebp
80102d81:	89 e5                	mov    %esp,%ebp
80102d83:	53                   	push   %ebx
80102d84:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102d87:	ff 35 14 17 11 80    	push   0x80111714
80102d8d:	ff 35 24 17 11 80    	push   0x80111724
80102d93:	e8 38 d3 ff ff       	call   801000d0 <bread>
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80102d98:	83 c4 10             	add    $0x10,%esp
  struct buf *buf = bread(log.dev, log.start);
80102d9b:	89 c3                	mov    %eax,%ebx
  hb->n = log.lh.n;
80102d9d:	a1 28 17 11 80       	mov    0x80111728,%eax
80102da2:	89 43 5c             	mov    %eax,0x5c(%ebx)
  for (i = 0; i < log.lh.n; i++) {
80102da5:	85 c0                	test   %eax,%eax
80102da7:	7e 19                	jle    80102dc2 <write_head+0x42>
80102da9:	31 d2                	xor    %edx,%edx
80102dab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102daf:	90                   	nop
    hb->block[i] = log.lh.block[i];
80102db0:	8b 0c 95 2c 17 11 80 	mov    -0x7feee8d4(,%edx,4),%ecx
80102db7:	89 4c 93 60          	mov    %ecx,0x60(%ebx,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102dbb:	83 c2 01             	add    $0x1,%edx
80102dbe:	39 d0                	cmp    %edx,%eax
80102dc0:	75 ee                	jne    80102db0 <write_head+0x30>
  }
  bwrite(buf);
80102dc2:	83 ec 0c             	sub    $0xc,%esp
80102dc5:	53                   	push   %ebx
80102dc6:	e8 e5 d3 ff ff       	call   801001b0 <bwrite>
  brelse(buf);
80102dcb:	89 1c 24             	mov    %ebx,(%esp)
80102dce:	e8 1d d4 ff ff       	call   801001f0 <brelse>
}
80102dd3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102dd6:	83 c4 10             	add    $0x10,%esp
80102dd9:	c9                   	leave  
80102dda:	c3                   	ret    
80102ddb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102ddf:	90                   	nop

80102de0 <initlog>:
{
80102de0:	55                   	push   %ebp
80102de1:	89 e5                	mov    %esp,%ebp
80102de3:	53                   	push   %ebx
80102de4:	83 ec 2c             	sub    $0x2c,%esp
80102de7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
80102dea:	68 a0 77 10 80       	push   $0x801077a0
80102def:	68 e0 16 11 80       	push   $0x801116e0
80102df4:	e8 f7 16 00 00       	call   801044f0 <initlock>
  readsb(dev, &sb);
80102df9:	58                   	pop    %eax
80102dfa:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102dfd:	5a                   	pop    %edx
80102dfe:	50                   	push   %eax
80102dff:	53                   	push   %ebx
80102e00:	e8 3b e8 ff ff       	call   80101640 <readsb>
  log.start = sb.logstart;
80102e05:	8b 45 ec             	mov    -0x14(%ebp),%eax
  struct buf *buf = bread(log.dev, log.start);
80102e08:	59                   	pop    %ecx
  log.dev = dev;
80102e09:	89 1d 24 17 11 80    	mov    %ebx,0x80111724
  log.size = sb.nlog;
80102e0f:	8b 55 e8             	mov    -0x18(%ebp),%edx
  log.start = sb.logstart;
80102e12:	a3 14 17 11 80       	mov    %eax,0x80111714
  log.size = sb.nlog;
80102e17:	89 15 18 17 11 80    	mov    %edx,0x80111718
  struct buf *buf = bread(log.dev, log.start);
80102e1d:	5a                   	pop    %edx
80102e1e:	50                   	push   %eax
80102e1f:	53                   	push   %ebx
80102e20:	e8 ab d2 ff ff       	call   801000d0 <bread>
  for (i = 0; i < log.lh.n; i++) {
80102e25:	83 c4 10             	add    $0x10,%esp
  log.lh.n = lh->n;
80102e28:	8b 58 5c             	mov    0x5c(%eax),%ebx
80102e2b:	89 1d 28 17 11 80    	mov    %ebx,0x80111728
  for (i = 0; i < log.lh.n; i++) {
80102e31:	85 db                	test   %ebx,%ebx
80102e33:	7e 1d                	jle    80102e52 <initlog+0x72>
80102e35:	31 d2                	xor    %edx,%edx
80102e37:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102e3e:	66 90                	xchg   %ax,%ax
    log.lh.block[i] = lh->block[i];
80102e40:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
80102e44:	89 0c 95 2c 17 11 80 	mov    %ecx,-0x7feee8d4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102e4b:	83 c2 01             	add    $0x1,%edx
80102e4e:	39 d3                	cmp    %edx,%ebx
80102e50:	75 ee                	jne    80102e40 <initlog+0x60>
  brelse(buf);
80102e52:	83 ec 0c             	sub    $0xc,%esp
80102e55:	50                   	push   %eax
80102e56:	e8 95 d3 ff ff       	call   801001f0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
80102e5b:	e8 80 fe ff ff       	call   80102ce0 <install_trans>
  log.lh.n = 0;
80102e60:	c7 05 28 17 11 80 00 	movl   $0x0,0x80111728
80102e67:	00 00 00 
  write_head(); // clear the log
80102e6a:	e8 11 ff ff ff       	call   80102d80 <write_head>
}
80102e6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102e72:	83 c4 10             	add    $0x10,%esp
80102e75:	c9                   	leave  
80102e76:	c3                   	ret    
80102e77:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102e7e:	66 90                	xchg   %ax,%ax

80102e80 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
80102e80:	55                   	push   %ebp
80102e81:	89 e5                	mov    %esp,%ebp
80102e83:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
80102e86:	68 e0 16 11 80       	push   $0x801116e0
80102e8b:	e8 30 18 00 00       	call   801046c0 <acquire>
80102e90:	83 c4 10             	add    $0x10,%esp
80102e93:	eb 18                	jmp    80102ead <begin_op+0x2d>
80102e95:	8d 76 00             	lea    0x0(%esi),%esi
  while(1){
    if(log.committing){
      sleep(&log, &log.lock);
80102e98:	83 ec 08             	sub    $0x8,%esp
80102e9b:	68 e0 16 11 80       	push   $0x801116e0
80102ea0:	68 e0 16 11 80       	push   $0x801116e0
80102ea5:	e8 b6 12 00 00       	call   80104160 <sleep>
80102eaa:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
80102ead:	a1 20 17 11 80       	mov    0x80111720,%eax
80102eb2:	85 c0                	test   %eax,%eax
80102eb4:	75 e2                	jne    80102e98 <begin_op+0x18>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102eb6:	a1 1c 17 11 80       	mov    0x8011171c,%eax
80102ebb:	8b 15 28 17 11 80    	mov    0x80111728,%edx
80102ec1:	83 c0 01             	add    $0x1,%eax
80102ec4:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102ec7:	8d 14 4a             	lea    (%edx,%ecx,2),%edx
80102eca:	83 fa 1e             	cmp    $0x1e,%edx
80102ecd:	7f c9                	jg     80102e98 <begin_op+0x18>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    } else {
      log.outstanding += 1;
      release(&log.lock);
80102ecf:	83 ec 0c             	sub    $0xc,%esp
      log.outstanding += 1;
80102ed2:	a3 1c 17 11 80       	mov    %eax,0x8011171c
      release(&log.lock);
80102ed7:	68 e0 16 11 80       	push   $0x801116e0
80102edc:	e8 7f 17 00 00       	call   80104660 <release>
      break;
    }
  }
}
80102ee1:	83 c4 10             	add    $0x10,%esp
80102ee4:	c9                   	leave  
80102ee5:	c3                   	ret    
80102ee6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102eed:	8d 76 00             	lea    0x0(%esi),%esi

80102ef0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80102ef0:	55                   	push   %ebp
80102ef1:	89 e5                	mov    %esp,%ebp
80102ef3:	57                   	push   %edi
80102ef4:	56                   	push   %esi
80102ef5:	53                   	push   %ebx
80102ef6:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;

  acquire(&log.lock);
80102ef9:	68 e0 16 11 80       	push   $0x801116e0
80102efe:	e8 bd 17 00 00       	call   801046c0 <acquire>
  log.outstanding -= 1;
80102f03:	a1 1c 17 11 80       	mov    0x8011171c,%eax
  if(log.committing)
80102f08:	8b 35 20 17 11 80    	mov    0x80111720,%esi
80102f0e:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80102f11:	8d 58 ff             	lea    -0x1(%eax),%ebx
80102f14:	89 1d 1c 17 11 80    	mov    %ebx,0x8011171c
  if(log.committing)
80102f1a:	85 f6                	test   %esi,%esi
80102f1c:	0f 85 22 01 00 00    	jne    80103044 <end_op+0x154>
    panic("log.committing");
  if(log.outstanding == 0){
80102f22:	85 db                	test   %ebx,%ebx
80102f24:	0f 85 f6 00 00 00    	jne    80103020 <end_op+0x130>
    do_commit = 1;
    log.committing = 1;
80102f2a:	c7 05 20 17 11 80 01 	movl   $0x1,0x80111720
80102f31:	00 00 00 
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
80102f34:	83 ec 0c             	sub    $0xc,%esp
80102f37:	68 e0 16 11 80       	push   $0x801116e0
80102f3c:	e8 1f 17 00 00       	call   80104660 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
80102f41:	8b 0d 28 17 11 80    	mov    0x80111728,%ecx
80102f47:	83 c4 10             	add    $0x10,%esp
80102f4a:	85 c9                	test   %ecx,%ecx
80102f4c:	7f 42                	jg     80102f90 <end_op+0xa0>
    acquire(&log.lock);
80102f4e:	83 ec 0c             	sub    $0xc,%esp
80102f51:	68 e0 16 11 80       	push   $0x801116e0
80102f56:	e8 65 17 00 00       	call   801046c0 <acquire>
    wakeup(&log);
80102f5b:	c7 04 24 e0 16 11 80 	movl   $0x801116e0,(%esp)
    log.committing = 0;
80102f62:	c7 05 20 17 11 80 00 	movl   $0x0,0x80111720
80102f69:	00 00 00 
    wakeup(&log);
80102f6c:	e8 af 12 00 00       	call   80104220 <wakeup>
    release(&log.lock);
80102f71:	c7 04 24 e0 16 11 80 	movl   $0x801116e0,(%esp)
80102f78:	e8 e3 16 00 00       	call   80104660 <release>
80102f7d:	83 c4 10             	add    $0x10,%esp
}
80102f80:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102f83:	5b                   	pop    %ebx
80102f84:	5e                   	pop    %esi
80102f85:	5f                   	pop    %edi
80102f86:	5d                   	pop    %ebp
80102f87:	c3                   	ret    
80102f88:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102f8f:	90                   	nop
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80102f90:	a1 14 17 11 80       	mov    0x80111714,%eax
80102f95:	83 ec 08             	sub    $0x8,%esp
80102f98:	01 d8                	add    %ebx,%eax
80102f9a:	83 c0 01             	add    $0x1,%eax
80102f9d:	50                   	push   %eax
80102f9e:	ff 35 24 17 11 80    	push   0x80111724
80102fa4:	e8 27 d1 ff ff       	call   801000d0 <bread>
80102fa9:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102fab:	58                   	pop    %eax
80102fac:	5a                   	pop    %edx
80102fad:	ff 34 9d 2c 17 11 80 	push   -0x7feee8d4(,%ebx,4)
80102fb4:	ff 35 24 17 11 80    	push   0x80111724
  for (tail = 0; tail < log.lh.n; tail++) {
80102fba:	83 c3 01             	add    $0x1,%ebx
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102fbd:	e8 0e d1 ff ff       	call   801000d0 <bread>
    memmove(to->data, from->data, BSIZE);
80102fc2:	83 c4 0c             	add    $0xc,%esp
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102fc5:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
80102fc7:	8d 40 5c             	lea    0x5c(%eax),%eax
80102fca:	68 00 02 00 00       	push   $0x200
80102fcf:	50                   	push   %eax
80102fd0:	8d 46 5c             	lea    0x5c(%esi),%eax
80102fd3:	50                   	push   %eax
80102fd4:	e8 47 18 00 00       	call   80104820 <memmove>
    bwrite(to);  // write the log
80102fd9:	89 34 24             	mov    %esi,(%esp)
80102fdc:	e8 cf d1 ff ff       	call   801001b0 <bwrite>
    brelse(from);
80102fe1:	89 3c 24             	mov    %edi,(%esp)
80102fe4:	e8 07 d2 ff ff       	call   801001f0 <brelse>
    brelse(to);
80102fe9:	89 34 24             	mov    %esi,(%esp)
80102fec:	e8 ff d1 ff ff       	call   801001f0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102ff1:	83 c4 10             	add    $0x10,%esp
80102ff4:	3b 1d 28 17 11 80    	cmp    0x80111728,%ebx
80102ffa:	7c 94                	jl     80102f90 <end_op+0xa0>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
80102ffc:	e8 7f fd ff ff       	call   80102d80 <write_head>
    install_trans(); // Now install writes to home locations
80103001:	e8 da fc ff ff       	call   80102ce0 <install_trans>
    log.lh.n = 0;
80103006:	c7 05 28 17 11 80 00 	movl   $0x0,0x80111728
8010300d:	00 00 00 
    write_head();    // Erase the transaction from the log
80103010:	e8 6b fd ff ff       	call   80102d80 <write_head>
80103015:	e9 34 ff ff ff       	jmp    80102f4e <end_op+0x5e>
8010301a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    wakeup(&log);
80103020:	83 ec 0c             	sub    $0xc,%esp
80103023:	68 e0 16 11 80       	push   $0x801116e0
80103028:	e8 f3 11 00 00       	call   80104220 <wakeup>
  release(&log.lock);
8010302d:	c7 04 24 e0 16 11 80 	movl   $0x801116e0,(%esp)
80103034:	e8 27 16 00 00       	call   80104660 <release>
80103039:	83 c4 10             	add    $0x10,%esp
}
8010303c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010303f:	5b                   	pop    %ebx
80103040:	5e                   	pop    %esi
80103041:	5f                   	pop    %edi
80103042:	5d                   	pop    %ebp
80103043:	c3                   	ret    
    panic("log.committing");
80103044:	83 ec 0c             	sub    $0xc,%esp
80103047:	68 a4 77 10 80       	push   $0x801077a4
8010304c:	e8 2f d3 ff ff       	call   80100380 <panic>
80103051:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103058:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010305f:	90                   	nop

80103060 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103060:	55                   	push   %ebp
80103061:	89 e5                	mov    %esp,%ebp
80103063:	53                   	push   %ebx
80103064:	83 ec 04             	sub    $0x4,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103067:	8b 15 28 17 11 80    	mov    0x80111728,%edx
{
8010306d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103070:	83 fa 1d             	cmp    $0x1d,%edx
80103073:	0f 8f 85 00 00 00    	jg     801030fe <log_write+0x9e>
80103079:	a1 18 17 11 80       	mov    0x80111718,%eax
8010307e:	83 e8 01             	sub    $0x1,%eax
80103081:	39 c2                	cmp    %eax,%edx
80103083:	7d 79                	jge    801030fe <log_write+0x9e>
    panic("too big a transaction");
  if (log.outstanding < 1)
80103085:	a1 1c 17 11 80       	mov    0x8011171c,%eax
8010308a:	85 c0                	test   %eax,%eax
8010308c:	7e 7d                	jle    8010310b <log_write+0xab>
    panic("log_write outside of trans");

  acquire(&log.lock);
8010308e:	83 ec 0c             	sub    $0xc,%esp
80103091:	68 e0 16 11 80       	push   $0x801116e0
80103096:	e8 25 16 00 00       	call   801046c0 <acquire>
  for (i = 0; i < log.lh.n; i++) {
8010309b:	8b 15 28 17 11 80    	mov    0x80111728,%edx
801030a1:	83 c4 10             	add    $0x10,%esp
801030a4:	85 d2                	test   %edx,%edx
801030a6:	7e 4a                	jle    801030f2 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801030a8:	8b 4b 08             	mov    0x8(%ebx),%ecx
  for (i = 0; i < log.lh.n; i++) {
801030ab:	31 c0                	xor    %eax,%eax
801030ad:	eb 08                	jmp    801030b7 <log_write+0x57>
801030af:	90                   	nop
801030b0:	83 c0 01             	add    $0x1,%eax
801030b3:	39 c2                	cmp    %eax,%edx
801030b5:	74 29                	je     801030e0 <log_write+0x80>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801030b7:	39 0c 85 2c 17 11 80 	cmp    %ecx,-0x7feee8d4(,%eax,4)
801030be:	75 f0                	jne    801030b0 <log_write+0x50>
      break;
  }
  log.lh.block[i] = b->blockno;
801030c0:	89 0c 85 2c 17 11 80 	mov    %ecx,-0x7feee8d4(,%eax,4)
  if (i == log.lh.n)
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
801030c7:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
}
801030ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  release(&log.lock);
801030cd:	c7 45 08 e0 16 11 80 	movl   $0x801116e0,0x8(%ebp)
}
801030d4:	c9                   	leave  
  release(&log.lock);
801030d5:	e9 86 15 00 00       	jmp    80104660 <release>
801030da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  log.lh.block[i] = b->blockno;
801030e0:	89 0c 95 2c 17 11 80 	mov    %ecx,-0x7feee8d4(,%edx,4)
    log.lh.n++;
801030e7:	83 c2 01             	add    $0x1,%edx
801030ea:	89 15 28 17 11 80    	mov    %edx,0x80111728
801030f0:	eb d5                	jmp    801030c7 <log_write+0x67>
  log.lh.block[i] = b->blockno;
801030f2:	8b 43 08             	mov    0x8(%ebx),%eax
801030f5:	a3 2c 17 11 80       	mov    %eax,0x8011172c
  if (i == log.lh.n)
801030fa:	75 cb                	jne    801030c7 <log_write+0x67>
801030fc:	eb e9                	jmp    801030e7 <log_write+0x87>
    panic("too big a transaction");
801030fe:	83 ec 0c             	sub    $0xc,%esp
80103101:	68 b3 77 10 80       	push   $0x801077b3
80103106:	e8 75 d2 ff ff       	call   80100380 <panic>
    panic("log_write outside of trans");
8010310b:	83 ec 0c             	sub    $0xc,%esp
8010310e:	68 c9 77 10 80       	push   $0x801077c9
80103113:	e8 68 d2 ff ff       	call   80100380 <panic>
80103118:	66 90                	xchg   %ax,%ax
8010311a:	66 90                	xchg   %ax,%ax
8010311c:	66 90                	xchg   %ax,%ax
8010311e:	66 90                	xchg   %ax,%ax

80103120 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103120:	55                   	push   %ebp
80103121:	89 e5                	mov    %esp,%ebp
80103123:	53                   	push   %ebx
80103124:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103127:	e8 44 09 00 00       	call   80103a70 <cpuid>
8010312c:	89 c3                	mov    %eax,%ebx
8010312e:	e8 3d 09 00 00       	call   80103a70 <cpuid>
80103133:	83 ec 04             	sub    $0x4,%esp
80103136:	53                   	push   %ebx
80103137:	50                   	push   %eax
80103138:	68 e4 77 10 80       	push   $0x801077e4
8010313d:	e8 5e d5 ff ff       	call   801006a0 <cprintf>
  idtinit();       // load idt register
80103142:	e8 09 29 00 00       	call   80105a50 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103147:	e8 c4 08 00 00       	call   80103a10 <mycpu>
8010314c:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010314e:	b8 01 00 00 00       	mov    $0x1,%eax
80103153:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
8010315a:	e8 f1 0b 00 00       	call   80103d50 <scheduler>
8010315f:	90                   	nop

80103160 <mpenter>:
{
80103160:	55                   	push   %ebp
80103161:	89 e5                	mov    %esp,%ebp
80103163:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103166:	e8 d5 39 00 00       	call   80106b40 <switchkvm>
  seginit();
8010316b:	e8 40 39 00 00       	call   80106ab0 <seginit>
  lapicinit();
80103170:	e8 9b f7 ff ff       	call   80102910 <lapicinit>
  mpmain();
80103175:	e8 a6 ff ff ff       	call   80103120 <mpmain>
8010317a:	66 90                	xchg   %ax,%ax
8010317c:	66 90                	xchg   %ax,%ax
8010317e:	66 90                	xchg   %ax,%ax

80103180 <main>:
{
80103180:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103184:	83 e4 f0             	and    $0xfffffff0,%esp
80103187:	ff 71 fc             	push   -0x4(%ecx)
8010318a:	55                   	push   %ebp
8010318b:	89 e5                	mov    %esp,%ebp
8010318d:	53                   	push   %ebx
8010318e:	51                   	push   %ecx
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010318f:	83 ec 08             	sub    $0x8,%esp
80103192:	68 00 00 40 80       	push   $0x80400000
80103197:	68 10 55 11 80       	push   $0x80115510
8010319c:	e8 8f f5 ff ff       	call   80102730 <kinit1>
  kvmalloc();      // kernel page table
801031a1:	e8 8a 3e 00 00       	call   80107030 <kvmalloc>
  mpinit();        // detect other processors
801031a6:	e8 85 01 00 00       	call   80103330 <mpinit>
  lapicinit();     // interrupt controller
801031ab:	e8 60 f7 ff ff       	call   80102910 <lapicinit>
  seginit();       // segment descriptors
801031b0:	e8 fb 38 00 00       	call   80106ab0 <seginit>
  picinit();       // disable pic
801031b5:	e8 76 03 00 00       	call   80103530 <picinit>
  ioapicinit();    // another interrupt controller
801031ba:	e8 31 f3 ff ff       	call   801024f0 <ioapicinit>
  consoleinit();   // console hardware
801031bf:	e8 9c d8 ff ff       	call   80100a60 <consoleinit>
  uartinit();      // serial port
801031c4:	e8 77 2b 00 00       	call   80105d40 <uartinit>
  pinit();         // process table
801031c9:	e8 22 08 00 00       	call   801039f0 <pinit>
  tvinit();        // trap vectors
801031ce:	e8 fd 27 00 00       	call   801059d0 <tvinit>
  binit();         // buffer cache
801031d3:	e8 68 ce ff ff       	call   80100040 <binit>
  fileinit();      // file table
801031d8:	e8 53 dd ff ff       	call   80100f30 <fileinit>
  ideinit();       // disk 
801031dd:	e8 fe f0 ff ff       	call   801022e0 <ideinit>

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801031e2:	83 c4 0c             	add    $0xc,%esp
801031e5:	68 8a 00 00 00       	push   $0x8a
801031ea:	68 cc a4 10 80       	push   $0x8010a4cc
801031ef:	68 00 70 00 80       	push   $0x80007000
801031f4:	e8 27 16 00 00       	call   80104820 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801031f9:	83 c4 10             	add    $0x10,%esp
801031fc:	69 05 c4 17 11 80 b0 	imul   $0xb0,0x801117c4,%eax
80103203:	00 00 00 
80103206:	05 e0 17 11 80       	add    $0x801117e0,%eax
8010320b:	3d e0 17 11 80       	cmp    $0x801117e0,%eax
80103210:	76 7e                	jbe    80103290 <main+0x110>
80103212:	bb e0 17 11 80       	mov    $0x801117e0,%ebx
80103217:	eb 20                	jmp    80103239 <main+0xb9>
80103219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103220:	69 05 c4 17 11 80 b0 	imul   $0xb0,0x801117c4,%eax
80103227:	00 00 00 
8010322a:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80103230:	05 e0 17 11 80       	add    $0x801117e0,%eax
80103235:	39 c3                	cmp    %eax,%ebx
80103237:	73 57                	jae    80103290 <main+0x110>
    if(c == mycpu())  // We've started already.
80103239:	e8 d2 07 00 00       	call   80103a10 <mycpu>
8010323e:	39 c3                	cmp    %eax,%ebx
80103240:	74 de                	je     80103220 <main+0xa0>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103242:	e8 59 f5 ff ff       	call   801027a0 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
    *(void(**)(void))(code-8) = mpenter;
    *(int**)(code-12) = (void *) V2P(entrypgdir);

    lapicstartap(c->apicid, V2P(code));
80103247:	83 ec 08             	sub    $0x8,%esp
    *(void(**)(void))(code-8) = mpenter;
8010324a:	c7 05 f8 6f 00 80 60 	movl   $0x80103160,0x80006ff8
80103251:	31 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103254:	c7 05 f4 6f 00 80 00 	movl   $0x109000,0x80006ff4
8010325b:	90 10 00 
    *(void**)(code-4) = stack + KSTACKSIZE;
8010325e:	05 00 10 00 00       	add    $0x1000,%eax
80103263:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    lapicstartap(c->apicid, V2P(code));
80103268:	0f b6 03             	movzbl (%ebx),%eax
8010326b:	68 00 70 00 00       	push   $0x7000
80103270:	50                   	push   %eax
80103271:	e8 ea f7 ff ff       	call   80102a60 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103276:	83 c4 10             	add    $0x10,%esp
80103279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103280:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80103286:	85 c0                	test   %eax,%eax
80103288:	74 f6                	je     80103280 <main+0x100>
8010328a:	eb 94                	jmp    80103220 <main+0xa0>
8010328c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103290:	83 ec 08             	sub    $0x8,%esp
80103293:	68 00 00 00 8e       	push   $0x8e000000
80103298:	68 00 00 40 80       	push   $0x80400000
8010329d:	e8 2e f4 ff ff       	call   801026d0 <kinit2>
  userinit();      // first user process
801032a2:	e8 19 08 00 00       	call   80103ac0 <userinit>
  mpmain();        // finish this processor's setup
801032a7:	e8 74 fe ff ff       	call   80103120 <mpmain>
801032ac:	66 90                	xchg   %ax,%ax
801032ae:	66 90                	xchg   %ax,%ax

801032b0 <mpsearch1>:
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
801032b0:	55                   	push   %ebp
801032b1:	89 e5                	mov    %esp,%ebp
801032b3:	57                   	push   %edi
801032b4:	56                   	push   %esi
  uchar *e, *p, *addr;

  addr = P2V(a);
801032b5:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
{
801032bb:	53                   	push   %ebx
  e = addr+len;
801032bc:	8d 1c 16             	lea    (%esi,%edx,1),%ebx
{
801032bf:	83 ec 0c             	sub    $0xc,%esp
  for(p = addr; p < e; p += sizeof(struct mp))
801032c2:	39 de                	cmp    %ebx,%esi
801032c4:	72 10                	jb     801032d6 <mpsearch1+0x26>
801032c6:	eb 50                	jmp    80103318 <mpsearch1+0x68>
801032c8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801032cf:	90                   	nop
801032d0:	89 fe                	mov    %edi,%esi
801032d2:	39 fb                	cmp    %edi,%ebx
801032d4:	76 42                	jbe    80103318 <mpsearch1+0x68>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801032d6:	83 ec 04             	sub    $0x4,%esp
801032d9:	8d 7e 10             	lea    0x10(%esi),%edi
801032dc:	6a 04                	push   $0x4
801032de:	68 f8 77 10 80       	push   $0x801077f8
801032e3:	56                   	push   %esi
801032e4:	e8 e7 14 00 00       	call   801047d0 <memcmp>
801032e9:	83 c4 10             	add    $0x10,%esp
801032ec:	85 c0                	test   %eax,%eax
801032ee:	75 e0                	jne    801032d0 <mpsearch1+0x20>
801032f0:	89 f2                	mov    %esi,%edx
801032f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    sum += addr[i];
801032f8:	0f b6 0a             	movzbl (%edx),%ecx
  for(i=0; i<len; i++)
801032fb:	83 c2 01             	add    $0x1,%edx
    sum += addr[i];
801032fe:	01 c8                	add    %ecx,%eax
  for(i=0; i<len; i++)
80103300:	39 fa                	cmp    %edi,%edx
80103302:	75 f4                	jne    801032f8 <mpsearch1+0x48>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103304:	84 c0                	test   %al,%al
80103306:	75 c8                	jne    801032d0 <mpsearch1+0x20>
      return (struct mp*)p;
  return 0;
}
80103308:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010330b:	89 f0                	mov    %esi,%eax
8010330d:	5b                   	pop    %ebx
8010330e:	5e                   	pop    %esi
8010330f:	5f                   	pop    %edi
80103310:	5d                   	pop    %ebp
80103311:	c3                   	ret    
80103312:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80103318:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
8010331b:	31 f6                	xor    %esi,%esi
}
8010331d:	5b                   	pop    %ebx
8010331e:	89 f0                	mov    %esi,%eax
80103320:	5e                   	pop    %esi
80103321:	5f                   	pop    %edi
80103322:	5d                   	pop    %ebp
80103323:	c3                   	ret    
80103324:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010332b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010332f:	90                   	nop

80103330 <mpinit>:
  return conf;
}

void
mpinit(void)
{
80103330:	55                   	push   %ebp
80103331:	89 e5                	mov    %esp,%ebp
80103333:	57                   	push   %edi
80103334:	56                   	push   %esi
80103335:	53                   	push   %ebx
80103336:	83 ec 1c             	sub    $0x1c,%esp
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103339:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80103340:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80103347:	c1 e0 08             	shl    $0x8,%eax
8010334a:	09 d0                	or     %edx,%eax
8010334c:	c1 e0 04             	shl    $0x4,%eax
8010334f:	75 1b                	jne    8010336c <mpinit+0x3c>
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103351:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80103358:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
8010335f:	c1 e0 08             	shl    $0x8,%eax
80103362:	09 d0                	or     %edx,%eax
80103364:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80103367:	2d 00 04 00 00       	sub    $0x400,%eax
    if((mp = mpsearch1(p, 1024)))
8010336c:	ba 00 04 00 00       	mov    $0x400,%edx
80103371:	e8 3a ff ff ff       	call   801032b0 <mpsearch1>
80103376:	89 c3                	mov    %eax,%ebx
80103378:	85 c0                	test   %eax,%eax
8010337a:	0f 84 40 01 00 00    	je     801034c0 <mpinit+0x190>
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103380:	8b 73 04             	mov    0x4(%ebx),%esi
80103383:	85 f6                	test   %esi,%esi
80103385:	0f 84 25 01 00 00    	je     801034b0 <mpinit+0x180>
  if(memcmp(conf, "PCMP", 4) != 0)
8010338b:	83 ec 04             	sub    $0x4,%esp
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
8010338e:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
  if(memcmp(conf, "PCMP", 4) != 0)
80103394:	6a 04                	push   $0x4
80103396:	68 fd 77 10 80       	push   $0x801077fd
8010339b:	50                   	push   %eax
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
8010339c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
8010339f:	e8 2c 14 00 00       	call   801047d0 <memcmp>
801033a4:	83 c4 10             	add    $0x10,%esp
801033a7:	85 c0                	test   %eax,%eax
801033a9:	0f 85 01 01 00 00    	jne    801034b0 <mpinit+0x180>
  if(conf->version != 1 && conf->version != 4)
801033af:	0f b6 86 06 00 00 80 	movzbl -0x7ffffffa(%esi),%eax
801033b6:	3c 01                	cmp    $0x1,%al
801033b8:	74 08                	je     801033c2 <mpinit+0x92>
801033ba:	3c 04                	cmp    $0x4,%al
801033bc:	0f 85 ee 00 00 00    	jne    801034b0 <mpinit+0x180>
  if(sum((uchar*)conf, conf->length) != 0)
801033c2:	0f b7 96 04 00 00 80 	movzwl -0x7ffffffc(%esi),%edx
  for(i=0; i<len; i++)
801033c9:	66 85 d2             	test   %dx,%dx
801033cc:	74 22                	je     801033f0 <mpinit+0xc0>
801033ce:	8d 3c 32             	lea    (%edx,%esi,1),%edi
801033d1:	89 f0                	mov    %esi,%eax
  sum = 0;
801033d3:	31 d2                	xor    %edx,%edx
801033d5:	8d 76 00             	lea    0x0(%esi),%esi
    sum += addr[i];
801033d8:	0f b6 88 00 00 00 80 	movzbl -0x80000000(%eax),%ecx
  for(i=0; i<len; i++)
801033df:	83 c0 01             	add    $0x1,%eax
    sum += addr[i];
801033e2:	01 ca                	add    %ecx,%edx
  for(i=0; i<len; i++)
801033e4:	39 c7                	cmp    %eax,%edi
801033e6:	75 f0                	jne    801033d8 <mpinit+0xa8>
  if(sum((uchar*)conf, conf->length) != 0)
801033e8:	84 d2                	test   %dl,%dl
801033ea:	0f 85 c0 00 00 00    	jne    801034b0 <mpinit+0x180>
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
801033f0:	8b 86 24 00 00 80    	mov    -0x7fffffdc(%esi),%eax
801033f6:	a3 c0 16 11 80       	mov    %eax,0x801116c0
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801033fb:	0f b7 96 04 00 00 80 	movzwl -0x7ffffffc(%esi),%edx
80103402:	8d 86 2c 00 00 80    	lea    -0x7fffffd4(%esi),%eax
  ismp = 1;
80103408:	be 01 00 00 00       	mov    $0x1,%esi
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010340d:	03 55 e4             	add    -0x1c(%ebp),%edx
80103410:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80103413:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103417:	90                   	nop
80103418:	39 d0                	cmp    %edx,%eax
8010341a:	73 15                	jae    80103431 <mpinit+0x101>
    switch(*p){
8010341c:	0f b6 08             	movzbl (%eax),%ecx
8010341f:	80 f9 02             	cmp    $0x2,%cl
80103422:	74 4c                	je     80103470 <mpinit+0x140>
80103424:	77 3a                	ja     80103460 <mpinit+0x130>
80103426:	84 c9                	test   %cl,%cl
80103428:	74 56                	je     80103480 <mpinit+0x150>
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
8010342a:	83 c0 08             	add    $0x8,%eax
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010342d:	39 d0                	cmp    %edx,%eax
8010342f:	72 eb                	jb     8010341c <mpinit+0xec>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103431:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103434:	85 f6                	test   %esi,%esi
80103436:	0f 84 d9 00 00 00    	je     80103515 <mpinit+0x1e5>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
8010343c:	80 7b 0c 00          	cmpb   $0x0,0xc(%ebx)
80103440:	74 15                	je     80103457 <mpinit+0x127>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103442:	b8 70 00 00 00       	mov    $0x70,%eax
80103447:	ba 22 00 00 00       	mov    $0x22,%edx
8010344c:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010344d:	ba 23 00 00 00       	mov    $0x23,%edx
80103452:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103453:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103456:	ee                   	out    %al,(%dx)
  }
}
80103457:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010345a:	5b                   	pop    %ebx
8010345b:	5e                   	pop    %esi
8010345c:	5f                   	pop    %edi
8010345d:	5d                   	pop    %ebp
8010345e:	c3                   	ret    
8010345f:	90                   	nop
    switch(*p){
80103460:	83 e9 03             	sub    $0x3,%ecx
80103463:	80 f9 01             	cmp    $0x1,%cl
80103466:	76 c2                	jbe    8010342a <mpinit+0xfa>
80103468:	31 f6                	xor    %esi,%esi
8010346a:	eb ac                	jmp    80103418 <mpinit+0xe8>
8010346c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      ioapicid = ioapic->apicno;
80103470:	0f b6 48 01          	movzbl 0x1(%eax),%ecx
      p += sizeof(struct mpioapic);
80103474:	83 c0 08             	add    $0x8,%eax
      ioapicid = ioapic->apicno;
80103477:	88 0d c0 17 11 80    	mov    %cl,0x801117c0
      continue;
8010347d:	eb 99                	jmp    80103418 <mpinit+0xe8>
8010347f:	90                   	nop
      if(ncpu < NCPU) {
80103480:	8b 0d c4 17 11 80    	mov    0x801117c4,%ecx
80103486:	83 f9 07             	cmp    $0x7,%ecx
80103489:	7f 19                	jg     801034a4 <mpinit+0x174>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
8010348b:	69 f9 b0 00 00 00    	imul   $0xb0,%ecx,%edi
80103491:	0f b6 58 01          	movzbl 0x1(%eax),%ebx
        ncpu++;
80103495:	83 c1 01             	add    $0x1,%ecx
80103498:	89 0d c4 17 11 80    	mov    %ecx,0x801117c4
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
8010349e:	88 9f e0 17 11 80    	mov    %bl,-0x7feee820(%edi)
      p += sizeof(struct mpproc);
801034a4:	83 c0 14             	add    $0x14,%eax
      continue;
801034a7:	e9 6c ff ff ff       	jmp    80103418 <mpinit+0xe8>
801034ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    panic("Expect to run on an SMP");
801034b0:	83 ec 0c             	sub    $0xc,%esp
801034b3:	68 02 78 10 80       	push   $0x80107802
801034b8:	e8 c3 ce ff ff       	call   80100380 <panic>
801034bd:	8d 76 00             	lea    0x0(%esi),%esi
{
801034c0:	bb 00 00 0f 80       	mov    $0x800f0000,%ebx
801034c5:	eb 13                	jmp    801034da <mpinit+0x1aa>
801034c7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801034ce:	66 90                	xchg   %ax,%ax
  for(p = addr; p < e; p += sizeof(struct mp))
801034d0:	89 f3                	mov    %esi,%ebx
801034d2:	81 fe 00 00 10 80    	cmp    $0x80100000,%esi
801034d8:	74 d6                	je     801034b0 <mpinit+0x180>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801034da:	83 ec 04             	sub    $0x4,%esp
801034dd:	8d 73 10             	lea    0x10(%ebx),%esi
801034e0:	6a 04                	push   $0x4
801034e2:	68 f8 77 10 80       	push   $0x801077f8
801034e7:	53                   	push   %ebx
801034e8:	e8 e3 12 00 00       	call   801047d0 <memcmp>
801034ed:	83 c4 10             	add    $0x10,%esp
801034f0:	85 c0                	test   %eax,%eax
801034f2:	75 dc                	jne    801034d0 <mpinit+0x1a0>
801034f4:	89 da                	mov    %ebx,%edx
801034f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801034fd:	8d 76 00             	lea    0x0(%esi),%esi
    sum += addr[i];
80103500:	0f b6 0a             	movzbl (%edx),%ecx
  for(i=0; i<len; i++)
80103503:	83 c2 01             	add    $0x1,%edx
    sum += addr[i];
80103506:	01 c8                	add    %ecx,%eax
  for(i=0; i<len; i++)
80103508:	39 d6                	cmp    %edx,%esi
8010350a:	75 f4                	jne    80103500 <mpinit+0x1d0>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
8010350c:	84 c0                	test   %al,%al
8010350e:	75 c0                	jne    801034d0 <mpinit+0x1a0>
80103510:	e9 6b fe ff ff       	jmp    80103380 <mpinit+0x50>
    panic("Didn't find a suitable machine");
80103515:	83 ec 0c             	sub    $0xc,%esp
80103518:	68 1c 78 10 80       	push   $0x8010781c
8010351d:	e8 5e ce ff ff       	call   80100380 <panic>
80103522:	66 90                	xchg   %ax,%ax
80103524:	66 90                	xchg   %ax,%ax
80103526:	66 90                	xchg   %ax,%ax
80103528:	66 90                	xchg   %ax,%ax
8010352a:	66 90                	xchg   %ax,%ax
8010352c:	66 90                	xchg   %ax,%ax
8010352e:	66 90                	xchg   %ax,%ax

80103530 <picinit>:
80103530:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103535:	ba 21 00 00 00       	mov    $0x21,%edx
8010353a:	ee                   	out    %al,(%dx)
8010353b:	ba a1 00 00 00       	mov    $0xa1,%edx
80103540:	ee                   	out    %al,(%dx)
picinit(void)
{
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80103541:	c3                   	ret    
80103542:	66 90                	xchg   %ax,%ax
80103544:	66 90                	xchg   %ax,%ax
80103546:	66 90                	xchg   %ax,%ax
80103548:	66 90                	xchg   %ax,%ax
8010354a:	66 90                	xchg   %ax,%ax
8010354c:	66 90                	xchg   %ax,%ax
8010354e:	66 90                	xchg   %ax,%ax

80103550 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103550:	55                   	push   %ebp
80103551:	89 e5                	mov    %esp,%ebp
80103553:	57                   	push   %edi
80103554:	56                   	push   %esi
80103555:	53                   	push   %ebx
80103556:	83 ec 0c             	sub    $0xc,%esp
80103559:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010355c:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
8010355f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80103565:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010356b:	e8 e0 d9 ff ff       	call   80100f50 <filealloc>
80103570:	89 03                	mov    %eax,(%ebx)
80103572:	85 c0                	test   %eax,%eax
80103574:	0f 84 a8 00 00 00    	je     80103622 <pipealloc+0xd2>
8010357a:	e8 d1 d9 ff ff       	call   80100f50 <filealloc>
8010357f:	89 06                	mov    %eax,(%esi)
80103581:	85 c0                	test   %eax,%eax
80103583:	0f 84 87 00 00 00    	je     80103610 <pipealloc+0xc0>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103589:	e8 12 f2 ff ff       	call   801027a0 <kalloc>
8010358e:	89 c7                	mov    %eax,%edi
80103590:	85 c0                	test   %eax,%eax
80103592:	0f 84 b0 00 00 00    	je     80103648 <pipealloc+0xf8>
    goto bad;
  p->readopen = 1;
80103598:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010359f:	00 00 00 
  p->writeopen = 1;
  p->nwrite = 0;
  p->nread = 0;
  initlock(&p->lock, "pipe");
801035a2:	83 ec 08             	sub    $0x8,%esp
  p->writeopen = 1;
801035a5:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801035ac:	00 00 00 
  p->nwrite = 0;
801035af:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801035b6:	00 00 00 
  p->nread = 0;
801035b9:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801035c0:	00 00 00 
  initlock(&p->lock, "pipe");
801035c3:	68 3b 78 10 80       	push   $0x8010783b
801035c8:	50                   	push   %eax
801035c9:	e8 22 0f 00 00       	call   801044f0 <initlock>
  (*f0)->type = FD_PIPE;
801035ce:	8b 03                	mov    (%ebx),%eax
  (*f0)->pipe = p;
  (*f1)->type = FD_PIPE;
  (*f1)->readable = 0;
  (*f1)->writable = 1;
  (*f1)->pipe = p;
  return 0;
801035d0:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801035d3:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801035d9:	8b 03                	mov    (%ebx),%eax
801035db:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801035df:	8b 03                	mov    (%ebx),%eax
801035e1:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801035e5:	8b 03                	mov    (%ebx),%eax
801035e7:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
801035ea:	8b 06                	mov    (%esi),%eax
801035ec:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801035f2:	8b 06                	mov    (%esi),%eax
801035f4:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801035f8:	8b 06                	mov    (%esi),%eax
801035fa:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801035fe:	8b 06                	mov    (%esi),%eax
80103600:	89 78 0c             	mov    %edi,0xc(%eax)
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
}
80103603:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80103606:	31 c0                	xor    %eax,%eax
}
80103608:	5b                   	pop    %ebx
80103609:	5e                   	pop    %esi
8010360a:	5f                   	pop    %edi
8010360b:	5d                   	pop    %ebp
8010360c:	c3                   	ret    
8010360d:	8d 76 00             	lea    0x0(%esi),%esi
  if(*f0)
80103610:	8b 03                	mov    (%ebx),%eax
80103612:	85 c0                	test   %eax,%eax
80103614:	74 1e                	je     80103634 <pipealloc+0xe4>
    fileclose(*f0);
80103616:	83 ec 0c             	sub    $0xc,%esp
80103619:	50                   	push   %eax
8010361a:	e8 f1 d9 ff ff       	call   80101010 <fileclose>
8010361f:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103622:	8b 06                	mov    (%esi),%eax
80103624:	85 c0                	test   %eax,%eax
80103626:	74 0c                	je     80103634 <pipealloc+0xe4>
    fileclose(*f1);
80103628:	83 ec 0c             	sub    $0xc,%esp
8010362b:	50                   	push   %eax
8010362c:	e8 df d9 ff ff       	call   80101010 <fileclose>
80103631:	83 c4 10             	add    $0x10,%esp
}
80103634:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return -1;
80103637:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010363c:	5b                   	pop    %ebx
8010363d:	5e                   	pop    %esi
8010363e:	5f                   	pop    %edi
8010363f:	5d                   	pop    %ebp
80103640:	c3                   	ret    
80103641:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  if(*f0)
80103648:	8b 03                	mov    (%ebx),%eax
8010364a:	85 c0                	test   %eax,%eax
8010364c:	75 c8                	jne    80103616 <pipealloc+0xc6>
8010364e:	eb d2                	jmp    80103622 <pipealloc+0xd2>

80103650 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103650:	55                   	push   %ebp
80103651:	89 e5                	mov    %esp,%ebp
80103653:	56                   	push   %esi
80103654:	53                   	push   %ebx
80103655:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103658:	8b 75 0c             	mov    0xc(%ebp),%esi
  acquire(&p->lock);
8010365b:	83 ec 0c             	sub    $0xc,%esp
8010365e:	53                   	push   %ebx
8010365f:	e8 5c 10 00 00       	call   801046c0 <acquire>
  if(writable){
80103664:	83 c4 10             	add    $0x10,%esp
80103667:	85 f6                	test   %esi,%esi
80103669:	74 65                	je     801036d0 <pipeclose+0x80>
    p->writeopen = 0;
    wakeup(&p->nread);
8010366b:	83 ec 0c             	sub    $0xc,%esp
8010366e:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
    p->writeopen = 0;
80103674:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
8010367b:	00 00 00 
    wakeup(&p->nread);
8010367e:	50                   	push   %eax
8010367f:	e8 9c 0b 00 00       	call   80104220 <wakeup>
80103684:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103687:	8b 93 3c 02 00 00    	mov    0x23c(%ebx),%edx
8010368d:	85 d2                	test   %edx,%edx
8010368f:	75 0a                	jne    8010369b <pipeclose+0x4b>
80103691:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
80103697:	85 c0                	test   %eax,%eax
80103699:	74 15                	je     801036b0 <pipeclose+0x60>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
8010369b:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
8010369e:	8d 65 f8             	lea    -0x8(%ebp),%esp
801036a1:	5b                   	pop    %ebx
801036a2:	5e                   	pop    %esi
801036a3:	5d                   	pop    %ebp
    release(&p->lock);
801036a4:	e9 b7 0f 00 00       	jmp    80104660 <release>
801036a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    release(&p->lock);
801036b0:	83 ec 0c             	sub    $0xc,%esp
801036b3:	53                   	push   %ebx
801036b4:	e8 a7 0f 00 00       	call   80104660 <release>
    kfree((char*)p);
801036b9:	89 5d 08             	mov    %ebx,0x8(%ebp)
801036bc:	83 c4 10             	add    $0x10,%esp
}
801036bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
801036c2:	5b                   	pop    %ebx
801036c3:	5e                   	pop    %esi
801036c4:	5d                   	pop    %ebp
    kfree((char*)p);
801036c5:	e9 16 ef ff ff       	jmp    801025e0 <kfree>
801036ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    wakeup(&p->nwrite);
801036d0:	83 ec 0c             	sub    $0xc,%esp
801036d3:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
    p->readopen = 0;
801036d9:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
801036e0:	00 00 00 
    wakeup(&p->nwrite);
801036e3:	50                   	push   %eax
801036e4:	e8 37 0b 00 00       	call   80104220 <wakeup>
801036e9:	83 c4 10             	add    $0x10,%esp
801036ec:	eb 99                	jmp    80103687 <pipeclose+0x37>
801036ee:	66 90                	xchg   %ax,%ax

801036f0 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801036f0:	55                   	push   %ebp
801036f1:	89 e5                	mov    %esp,%ebp
801036f3:	57                   	push   %edi
801036f4:	56                   	push   %esi
801036f5:	53                   	push   %ebx
801036f6:	83 ec 28             	sub    $0x28,%esp
801036f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
801036fc:	53                   	push   %ebx
801036fd:	e8 be 0f 00 00       	call   801046c0 <acquire>
  for(i = 0; i < n; i++){
80103702:	8b 45 10             	mov    0x10(%ebp),%eax
80103705:	83 c4 10             	add    $0x10,%esp
80103708:	85 c0                	test   %eax,%eax
8010370a:	0f 8e c0 00 00 00    	jle    801037d0 <pipewrite+0xe0>
80103710:	8b 45 0c             	mov    0xc(%ebp),%eax
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103713:	8b 8b 38 02 00 00    	mov    0x238(%ebx),%ecx
      if(p->readopen == 0 || myproc()->killed){
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
80103719:	8d bb 34 02 00 00    	lea    0x234(%ebx),%edi
8010371f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103722:	03 45 10             	add    0x10(%ebp),%eax
80103725:	89 45 e0             	mov    %eax,-0x20(%ebp)
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103728:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010372e:	8d b3 38 02 00 00    	lea    0x238(%ebx),%esi
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103734:	89 ca                	mov    %ecx,%edx
80103736:	05 00 02 00 00       	add    $0x200,%eax
8010373b:	39 c1                	cmp    %eax,%ecx
8010373d:	74 3f                	je     8010377e <pipewrite+0x8e>
8010373f:	eb 67                	jmp    801037a8 <pipewrite+0xb8>
80103741:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      if(p->readopen == 0 || myproc()->killed){
80103748:	e8 43 03 00 00       	call   80103a90 <myproc>
8010374d:	8b 48 24             	mov    0x24(%eax),%ecx
80103750:	85 c9                	test   %ecx,%ecx
80103752:	75 34                	jne    80103788 <pipewrite+0x98>
      wakeup(&p->nread);
80103754:	83 ec 0c             	sub    $0xc,%esp
80103757:	57                   	push   %edi
80103758:	e8 c3 0a 00 00       	call   80104220 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010375d:	58                   	pop    %eax
8010375e:	5a                   	pop    %edx
8010375f:	53                   	push   %ebx
80103760:	56                   	push   %esi
80103761:	e8 fa 09 00 00       	call   80104160 <sleep>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103766:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
8010376c:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
80103772:	83 c4 10             	add    $0x10,%esp
80103775:	05 00 02 00 00       	add    $0x200,%eax
8010377a:	39 c2                	cmp    %eax,%edx
8010377c:	75 2a                	jne    801037a8 <pipewrite+0xb8>
      if(p->readopen == 0 || myproc()->killed){
8010377e:	8b 83 3c 02 00 00    	mov    0x23c(%ebx),%eax
80103784:	85 c0                	test   %eax,%eax
80103786:	75 c0                	jne    80103748 <pipewrite+0x58>
        release(&p->lock);
80103788:	83 ec 0c             	sub    $0xc,%esp
8010378b:	53                   	push   %ebx
8010378c:	e8 cf 0e 00 00       	call   80104660 <release>
        return -1;
80103791:	83 c4 10             	add    $0x10,%esp
80103794:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
80103799:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010379c:	5b                   	pop    %ebx
8010379d:	5e                   	pop    %esi
8010379e:	5f                   	pop    %edi
8010379f:	5d                   	pop    %ebp
801037a0:	c3                   	ret    
801037a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801037a8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
801037ab:	8d 4a 01             	lea    0x1(%edx),%ecx
801037ae:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
801037b4:	89 8b 38 02 00 00    	mov    %ecx,0x238(%ebx)
801037ba:	0f b6 06             	movzbl (%esi),%eax
  for(i = 0; i < n; i++){
801037bd:	83 c6 01             	add    $0x1,%esi
801037c0:	89 75 e4             	mov    %esi,-0x1c(%ebp)
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801037c3:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
801037c7:	3b 75 e0             	cmp    -0x20(%ebp),%esi
801037ca:	0f 85 58 ff ff ff    	jne    80103728 <pipewrite+0x38>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801037d0:	83 ec 0c             	sub    $0xc,%esp
801037d3:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
801037d9:	50                   	push   %eax
801037da:	e8 41 0a 00 00       	call   80104220 <wakeup>
  release(&p->lock);
801037df:	89 1c 24             	mov    %ebx,(%esp)
801037e2:	e8 79 0e 00 00       	call   80104660 <release>
  return n;
801037e7:	8b 45 10             	mov    0x10(%ebp),%eax
801037ea:	83 c4 10             	add    $0x10,%esp
801037ed:	eb aa                	jmp    80103799 <pipewrite+0xa9>
801037ef:	90                   	nop

801037f0 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801037f0:	55                   	push   %ebp
801037f1:	89 e5                	mov    %esp,%ebp
801037f3:	57                   	push   %edi
801037f4:	56                   	push   %esi
801037f5:	53                   	push   %ebx
801037f6:	83 ec 18             	sub    $0x18,%esp
801037f9:	8b 75 08             	mov    0x8(%ebp),%esi
801037fc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  acquire(&p->lock);
801037ff:	56                   	push   %esi
80103800:	8d 9e 34 02 00 00    	lea    0x234(%esi),%ebx
80103806:	e8 b5 0e 00 00       	call   801046c0 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010380b:	8b 86 34 02 00 00    	mov    0x234(%esi),%eax
80103811:	83 c4 10             	add    $0x10,%esp
80103814:	39 86 38 02 00 00    	cmp    %eax,0x238(%esi)
8010381a:	74 2f                	je     8010384b <piperead+0x5b>
8010381c:	eb 37                	jmp    80103855 <piperead+0x65>
8010381e:	66 90                	xchg   %ax,%ax
    if(myproc()->killed){
80103820:	e8 6b 02 00 00       	call   80103a90 <myproc>
80103825:	8b 48 24             	mov    0x24(%eax),%ecx
80103828:	85 c9                	test   %ecx,%ecx
8010382a:	0f 85 80 00 00 00    	jne    801038b0 <piperead+0xc0>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103830:	83 ec 08             	sub    $0x8,%esp
80103833:	56                   	push   %esi
80103834:	53                   	push   %ebx
80103835:	e8 26 09 00 00       	call   80104160 <sleep>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010383a:	8b 86 38 02 00 00    	mov    0x238(%esi),%eax
80103840:	83 c4 10             	add    $0x10,%esp
80103843:	39 86 34 02 00 00    	cmp    %eax,0x234(%esi)
80103849:	75 0a                	jne    80103855 <piperead+0x65>
8010384b:	8b 86 40 02 00 00    	mov    0x240(%esi),%eax
80103851:	85 c0                	test   %eax,%eax
80103853:	75 cb                	jne    80103820 <piperead+0x30>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103855:	8b 55 10             	mov    0x10(%ebp),%edx
80103858:	31 db                	xor    %ebx,%ebx
8010385a:	85 d2                	test   %edx,%edx
8010385c:	7f 20                	jg     8010387e <piperead+0x8e>
8010385e:	eb 2c                	jmp    8010388c <piperead+0x9c>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103860:	8d 48 01             	lea    0x1(%eax),%ecx
80103863:	25 ff 01 00 00       	and    $0x1ff,%eax
80103868:	89 8e 34 02 00 00    	mov    %ecx,0x234(%esi)
8010386e:	0f b6 44 06 34       	movzbl 0x34(%esi,%eax,1),%eax
80103873:	88 04 1f             	mov    %al,(%edi,%ebx,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103876:	83 c3 01             	add    $0x1,%ebx
80103879:	39 5d 10             	cmp    %ebx,0x10(%ebp)
8010387c:	74 0e                	je     8010388c <piperead+0x9c>
    if(p->nread == p->nwrite)
8010387e:	8b 86 34 02 00 00    	mov    0x234(%esi),%eax
80103884:	3b 86 38 02 00 00    	cmp    0x238(%esi),%eax
8010388a:	75 d4                	jne    80103860 <piperead+0x70>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010388c:	83 ec 0c             	sub    $0xc,%esp
8010388f:	8d 86 38 02 00 00    	lea    0x238(%esi),%eax
80103895:	50                   	push   %eax
80103896:	e8 85 09 00 00       	call   80104220 <wakeup>
  release(&p->lock);
8010389b:	89 34 24             	mov    %esi,(%esp)
8010389e:	e8 bd 0d 00 00       	call   80104660 <release>
  return i;
801038a3:	83 c4 10             	add    $0x10,%esp
}
801038a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801038a9:	89 d8                	mov    %ebx,%eax
801038ab:	5b                   	pop    %ebx
801038ac:	5e                   	pop    %esi
801038ad:	5f                   	pop    %edi
801038ae:	5d                   	pop    %ebp
801038af:	c3                   	ret    
      release(&p->lock);
801038b0:	83 ec 0c             	sub    $0xc,%esp
      return -1;
801038b3:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
      release(&p->lock);
801038b8:	56                   	push   %esi
801038b9:	e8 a2 0d 00 00       	call   80104660 <release>
      return -1;
801038be:	83 c4 10             	add    $0x10,%esp
}
801038c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801038c4:	89 d8                	mov    %ebx,%eax
801038c6:	5b                   	pop    %ebx
801038c7:	5e                   	pop    %esi
801038c8:	5f                   	pop    %edi
801038c9:	5d                   	pop    %ebp
801038ca:	c3                   	ret    
801038cb:	66 90                	xchg   %ax,%ax
801038cd:	66 90                	xchg   %ax,%ax
801038cf:	90                   	nop

801038d0 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801038d0:	55                   	push   %ebp
801038d1:	89 e5                	mov    %esp,%ebp
801038d3:	53                   	push   %ebx
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801038d4:	bb 94 1d 11 80       	mov    $0x80111d94,%ebx
{
801038d9:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
801038dc:	68 60 1d 11 80       	push   $0x80111d60
801038e1:	e8 da 0d 00 00       	call   801046c0 <acquire>
801038e6:	83 c4 10             	add    $0x10,%esp
801038e9:	eb 10                	jmp    801038fb <allocproc+0x2b>
801038eb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801038ef:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801038f0:	83 c3 7c             	add    $0x7c,%ebx
801038f3:	81 fb 94 3c 11 80    	cmp    $0x80113c94,%ebx
801038f9:	74 75                	je     80103970 <allocproc+0xa0>
    if(p->state == UNUSED)
801038fb:	8b 43 0c             	mov    0xc(%ebx),%eax
801038fe:	85 c0                	test   %eax,%eax
80103900:	75 ee                	jne    801038f0 <allocproc+0x20>
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;
80103902:	a1 04 a0 10 80       	mov    0x8010a004,%eax

  release(&ptable.lock);
80103907:	83 ec 0c             	sub    $0xc,%esp
  p->state = EMBRYO;
8010390a:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
80103911:	89 43 10             	mov    %eax,0x10(%ebx)
80103914:	8d 50 01             	lea    0x1(%eax),%edx
  release(&ptable.lock);
80103917:	68 60 1d 11 80       	push   $0x80111d60
  p->pid = nextpid++;
8010391c:	89 15 04 a0 10 80    	mov    %edx,0x8010a004
  release(&ptable.lock);
80103922:	e8 39 0d 00 00       	call   80104660 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103927:	e8 74 ee ff ff       	call   801027a0 <kalloc>
8010392c:	83 c4 10             	add    $0x10,%esp
8010392f:	89 43 08             	mov    %eax,0x8(%ebx)
80103932:	85 c0                	test   %eax,%eax
80103934:	74 53                	je     80103989 <allocproc+0xb9>
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103936:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
8010393c:	83 ec 04             	sub    $0x4,%esp
  sp -= sizeof *p->context;
8010393f:	05 9c 0f 00 00       	add    $0xf9c,%eax
  sp -= sizeof *p->tf;
80103944:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
80103947:	c7 40 14 b7 59 10 80 	movl   $0x801059b7,0x14(%eax)
  p->context = (struct context*)sp;
8010394e:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
80103951:	6a 14                	push   $0x14
80103953:	6a 00                	push   $0x0
80103955:	50                   	push   %eax
80103956:	e8 25 0e 00 00       	call   80104780 <memset>
  p->context->eip = (uint)forkret;
8010395b:	8b 43 1c             	mov    0x1c(%ebx),%eax

  return p;
8010395e:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103961:	c7 40 10 a0 39 10 80 	movl   $0x801039a0,0x10(%eax)
}
80103968:	89 d8                	mov    %ebx,%eax
8010396a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010396d:	c9                   	leave  
8010396e:	c3                   	ret    
8010396f:	90                   	nop
  release(&ptable.lock);
80103970:	83 ec 0c             	sub    $0xc,%esp
  return 0;
80103973:	31 db                	xor    %ebx,%ebx
  release(&ptable.lock);
80103975:	68 60 1d 11 80       	push   $0x80111d60
8010397a:	e8 e1 0c 00 00       	call   80104660 <release>
}
8010397f:	89 d8                	mov    %ebx,%eax
  return 0;
80103981:	83 c4 10             	add    $0x10,%esp
}
80103984:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103987:	c9                   	leave  
80103988:	c3                   	ret    
    p->state = UNUSED;
80103989:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
80103990:	31 db                	xor    %ebx,%ebx
}
80103992:	89 d8                	mov    %ebx,%eax
80103994:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103997:	c9                   	leave  
80103998:	c3                   	ret    
80103999:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801039a0 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801039a0:	55                   	push   %ebp
801039a1:	89 e5                	mov    %esp,%ebp
801039a3:	83 ec 14             	sub    $0x14,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801039a6:	68 60 1d 11 80       	push   $0x80111d60
801039ab:	e8 b0 0c 00 00       	call   80104660 <release>

  if (first) {
801039b0:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801039b5:	83 c4 10             	add    $0x10,%esp
801039b8:	85 c0                	test   %eax,%eax
801039ba:	75 04                	jne    801039c0 <forkret+0x20>
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}
801039bc:	c9                   	leave  
801039bd:	c3                   	ret    
801039be:	66 90                	xchg   %ax,%ax
    first = 0;
801039c0:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
801039c7:	00 00 00 
    iinit(ROOTDEV);
801039ca:	83 ec 0c             	sub    $0xc,%esp
801039cd:	6a 01                	push   $0x1
801039cf:	e8 ac dc ff ff       	call   80101680 <iinit>
    initlog(ROOTDEV);
801039d4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801039db:	e8 00 f4 ff ff       	call   80102de0 <initlog>
}
801039e0:	83 c4 10             	add    $0x10,%esp
801039e3:	c9                   	leave  
801039e4:	c3                   	ret    
801039e5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801039ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801039f0 <pinit>:
{
801039f0:	55                   	push   %ebp
801039f1:	89 e5                	mov    %esp,%ebp
801039f3:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
801039f6:	68 40 78 10 80       	push   $0x80107840
801039fb:	68 60 1d 11 80       	push   $0x80111d60
80103a00:	e8 eb 0a 00 00       	call   801044f0 <initlock>
}
80103a05:	83 c4 10             	add    $0x10,%esp
80103a08:	c9                   	leave  
80103a09:	c3                   	ret    
80103a0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103a10 <mycpu>:
{
80103a10:	55                   	push   %ebp
80103a11:	89 e5                	mov    %esp,%ebp
80103a13:	56                   	push   %esi
80103a14:	53                   	push   %ebx
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103a15:	9c                   	pushf  
80103a16:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103a17:	f6 c4 02             	test   $0x2,%ah
80103a1a:	75 46                	jne    80103a62 <mycpu+0x52>
  apicid = lapicid();
80103a1c:	e8 ef ef ff ff       	call   80102a10 <lapicid>
  for (i = 0; i < ncpu; ++i) {
80103a21:	8b 35 c4 17 11 80    	mov    0x801117c4,%esi
80103a27:	85 f6                	test   %esi,%esi
80103a29:	7e 2a                	jle    80103a55 <mycpu+0x45>
80103a2b:	31 d2                	xor    %edx,%edx
80103a2d:	eb 08                	jmp    80103a37 <mycpu+0x27>
80103a2f:	90                   	nop
80103a30:	83 c2 01             	add    $0x1,%edx
80103a33:	39 f2                	cmp    %esi,%edx
80103a35:	74 1e                	je     80103a55 <mycpu+0x45>
    if (cpus[i].apicid == apicid)
80103a37:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
80103a3d:	0f b6 99 e0 17 11 80 	movzbl -0x7feee820(%ecx),%ebx
80103a44:	39 c3                	cmp    %eax,%ebx
80103a46:	75 e8                	jne    80103a30 <mycpu+0x20>
}
80103a48:	8d 65 f8             	lea    -0x8(%ebp),%esp
      return &cpus[i];
80103a4b:	8d 81 e0 17 11 80    	lea    -0x7feee820(%ecx),%eax
}
80103a51:	5b                   	pop    %ebx
80103a52:	5e                   	pop    %esi
80103a53:	5d                   	pop    %ebp
80103a54:	c3                   	ret    
  panic("unknown apicid\n");
80103a55:	83 ec 0c             	sub    $0xc,%esp
80103a58:	68 47 78 10 80       	push   $0x80107847
80103a5d:	e8 1e c9 ff ff       	call   80100380 <panic>
    panic("mycpu called with interrupts enabled\n");
80103a62:	83 ec 0c             	sub    $0xc,%esp
80103a65:	68 24 79 10 80       	push   $0x80107924
80103a6a:	e8 11 c9 ff ff       	call   80100380 <panic>
80103a6f:	90                   	nop

80103a70 <cpuid>:
cpuid() {
80103a70:	55                   	push   %ebp
80103a71:	89 e5                	mov    %esp,%ebp
80103a73:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103a76:	e8 95 ff ff ff       	call   80103a10 <mycpu>
}
80103a7b:	c9                   	leave  
  return mycpu()-cpus;
80103a7c:	2d e0 17 11 80       	sub    $0x801117e0,%eax
80103a81:	c1 f8 04             	sar    $0x4,%eax
80103a84:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103a8a:	c3                   	ret    
80103a8b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103a8f:	90                   	nop

80103a90 <myproc>:
myproc(void) {
80103a90:	55                   	push   %ebp
80103a91:	89 e5                	mov    %esp,%ebp
80103a93:	53                   	push   %ebx
80103a94:	83 ec 04             	sub    $0x4,%esp
  pushcli();
80103a97:	e8 d4 0a 00 00       	call   80104570 <pushcli>
  c = mycpu();
80103a9c:	e8 6f ff ff ff       	call   80103a10 <mycpu>
  p = c->proc;
80103aa1:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103aa7:	e8 14 0b 00 00       	call   801045c0 <popcli>
}
80103aac:	89 d8                	mov    %ebx,%eax
80103aae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103ab1:	c9                   	leave  
80103ab2:	c3                   	ret    
80103ab3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103aba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103ac0 <userinit>:
{
80103ac0:	55                   	push   %ebp
80103ac1:	89 e5                	mov    %esp,%ebp
80103ac3:	53                   	push   %ebx
80103ac4:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
80103ac7:	e8 04 fe ff ff       	call   801038d0 <allocproc>
80103acc:	89 c3                	mov    %eax,%ebx
  initproc = p;
80103ace:	a3 94 3c 11 80       	mov    %eax,0x80113c94
  if((p->pgdir = setupkvm()) == 0)
80103ad3:	e8 d8 34 00 00       	call   80106fb0 <setupkvm>
80103ad8:	89 43 04             	mov    %eax,0x4(%ebx)
80103adb:	85 c0                	test   %eax,%eax
80103add:	0f 84 bd 00 00 00    	je     80103ba0 <userinit+0xe0>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103ae3:	83 ec 04             	sub    $0x4,%esp
80103ae6:	68 2c 00 00 00       	push   $0x2c
80103aeb:	68 a0 a4 10 80       	push   $0x8010a4a0
80103af0:	50                   	push   %eax
80103af1:	e8 6a 31 00 00       	call   80106c60 <inituvm>
  memset(p->tf, 0, sizeof(*p->tf));
80103af6:	83 c4 0c             	add    $0xc,%esp
  p->sz = PGSIZE;
80103af9:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
80103aff:	6a 4c                	push   $0x4c
80103b01:	6a 00                	push   $0x0
80103b03:	ff 73 18             	push   0x18(%ebx)
80103b06:	e8 75 0c 00 00       	call   80104780 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103b0b:	8b 43 18             	mov    0x18(%ebx),%eax
80103b0e:	ba 1b 00 00 00       	mov    $0x1b,%edx
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103b13:	83 c4 0c             	add    $0xc,%esp
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103b16:	b9 23 00 00 00       	mov    $0x23,%ecx
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103b1b:	66 89 50 3c          	mov    %dx,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103b1f:	8b 43 18             	mov    0x18(%ebx),%eax
80103b22:	66 89 48 2c          	mov    %cx,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103b26:	8b 43 18             	mov    0x18(%ebx),%eax
80103b29:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103b2d:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103b31:	8b 43 18             	mov    0x18(%ebx),%eax
80103b34:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103b38:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103b3c:	8b 43 18             	mov    0x18(%ebx),%eax
80103b3f:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103b46:	8b 43 18             	mov    0x18(%ebx),%eax
80103b49:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103b50:	8b 43 18             	mov    0x18(%ebx),%eax
80103b53:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103b5a:	8d 43 6c             	lea    0x6c(%ebx),%eax
80103b5d:	6a 10                	push   $0x10
80103b5f:	68 70 78 10 80       	push   $0x80107870
80103b64:	50                   	push   %eax
80103b65:	e8 d6 0d 00 00       	call   80104940 <safestrcpy>
  p->cwd = namei("/");
80103b6a:	c7 04 24 79 78 10 80 	movl   $0x80107879,(%esp)
80103b71:	e8 4a e6 ff ff       	call   801021c0 <namei>
80103b76:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
80103b79:	c7 04 24 60 1d 11 80 	movl   $0x80111d60,(%esp)
80103b80:	e8 3b 0b 00 00       	call   801046c0 <acquire>
  p->state = RUNNABLE;
80103b85:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
80103b8c:	c7 04 24 60 1d 11 80 	movl   $0x80111d60,(%esp)
80103b93:	e8 c8 0a 00 00       	call   80104660 <release>
}
80103b98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b9b:	83 c4 10             	add    $0x10,%esp
80103b9e:	c9                   	leave  
80103b9f:	c3                   	ret    
    panic("userinit: out of memory?");
80103ba0:	83 ec 0c             	sub    $0xc,%esp
80103ba3:	68 57 78 10 80       	push   $0x80107857
80103ba8:	e8 d3 c7 ff ff       	call   80100380 <panic>
80103bad:	8d 76 00             	lea    0x0(%esi),%esi

80103bb0 <growproc>:
{
80103bb0:	55                   	push   %ebp
80103bb1:	89 e5                	mov    %esp,%ebp
80103bb3:	56                   	push   %esi
80103bb4:	53                   	push   %ebx
80103bb5:	8b 75 08             	mov    0x8(%ebp),%esi
  pushcli();
80103bb8:	e8 b3 09 00 00       	call   80104570 <pushcli>
  c = mycpu();
80103bbd:	e8 4e fe ff ff       	call   80103a10 <mycpu>
  p = c->proc;
80103bc2:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103bc8:	e8 f3 09 00 00       	call   801045c0 <popcli>
  sz = curproc->sz;
80103bcd:	8b 03                	mov    (%ebx),%eax
  if(n > 0){
80103bcf:	85 f6                	test   %esi,%esi
80103bd1:	7f 1d                	jg     80103bf0 <growproc+0x40>
  } else if(n < 0){
80103bd3:	75 3b                	jne    80103c10 <growproc+0x60>
  switchuvm(curproc);
80103bd5:	83 ec 0c             	sub    $0xc,%esp
  curproc->sz = sz;
80103bd8:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
80103bda:	53                   	push   %ebx
80103bdb:	e8 70 2f 00 00       	call   80106b50 <switchuvm>
  return 0;
80103be0:	83 c4 10             	add    $0x10,%esp
80103be3:	31 c0                	xor    %eax,%eax
}
80103be5:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103be8:	5b                   	pop    %ebx
80103be9:	5e                   	pop    %esi
80103bea:	5d                   	pop    %ebp
80103beb:	c3                   	ret    
80103bec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103bf0:	83 ec 04             	sub    $0x4,%esp
80103bf3:	01 c6                	add    %eax,%esi
80103bf5:	56                   	push   %esi
80103bf6:	50                   	push   %eax
80103bf7:	ff 73 04             	push   0x4(%ebx)
80103bfa:	e8 d1 31 00 00       	call   80106dd0 <allocuvm>
80103bff:	83 c4 10             	add    $0x10,%esp
80103c02:	85 c0                	test   %eax,%eax
80103c04:	75 cf                	jne    80103bd5 <growproc+0x25>
      return -1;
80103c06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103c0b:	eb d8                	jmp    80103be5 <growproc+0x35>
80103c0d:	8d 76 00             	lea    0x0(%esi),%esi
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103c10:	83 ec 04             	sub    $0x4,%esp
80103c13:	01 c6                	add    %eax,%esi
80103c15:	56                   	push   %esi
80103c16:	50                   	push   %eax
80103c17:	ff 73 04             	push   0x4(%ebx)
80103c1a:	e8 e1 32 00 00       	call   80106f00 <deallocuvm>
80103c1f:	83 c4 10             	add    $0x10,%esp
80103c22:	85 c0                	test   %eax,%eax
80103c24:	75 af                	jne    80103bd5 <growproc+0x25>
80103c26:	eb de                	jmp    80103c06 <growproc+0x56>
80103c28:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103c2f:	90                   	nop

80103c30 <fork>:
{
80103c30:	55                   	push   %ebp
80103c31:	89 e5                	mov    %esp,%ebp
80103c33:	57                   	push   %edi
80103c34:	56                   	push   %esi
80103c35:	53                   	push   %ebx
80103c36:	83 ec 1c             	sub    $0x1c,%esp
  pushcli();
80103c39:	e8 32 09 00 00       	call   80104570 <pushcli>
  c = mycpu();
80103c3e:	e8 cd fd ff ff       	call   80103a10 <mycpu>
  p = c->proc;
80103c43:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103c49:	e8 72 09 00 00       	call   801045c0 <popcli>
  if((np = allocproc()) == 0){
80103c4e:	e8 7d fc ff ff       	call   801038d0 <allocproc>
80103c53:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103c56:	85 c0                	test   %eax,%eax
80103c58:	0f 84 b7 00 00 00    	je     80103d15 <fork+0xe5>
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103c5e:	83 ec 08             	sub    $0x8,%esp
80103c61:	ff 33                	push   (%ebx)
80103c63:	89 c7                	mov    %eax,%edi
80103c65:	ff 73 04             	push   0x4(%ebx)
80103c68:	e8 33 34 00 00       	call   801070a0 <copyuvm>
80103c6d:	83 c4 10             	add    $0x10,%esp
80103c70:	89 47 04             	mov    %eax,0x4(%edi)
80103c73:	85 c0                	test   %eax,%eax
80103c75:	0f 84 a1 00 00 00    	je     80103d1c <fork+0xec>
  np->sz = curproc->sz;
80103c7b:	8b 03                	mov    (%ebx),%eax
80103c7d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103c80:	89 01                	mov    %eax,(%ecx)
  *np->tf = *curproc->tf;
80103c82:	8b 79 18             	mov    0x18(%ecx),%edi
  np->parent = curproc;
80103c85:	89 c8                	mov    %ecx,%eax
80103c87:	89 59 14             	mov    %ebx,0x14(%ecx)
  *np->tf = *curproc->tf;
80103c8a:	b9 13 00 00 00       	mov    $0x13,%ecx
80103c8f:	8b 73 18             	mov    0x18(%ebx),%esi
80103c92:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  for(i = 0; i < NOFILE; i++)
80103c94:	31 f6                	xor    %esi,%esi
  np->tf->eax = 0;
80103c96:	8b 40 18             	mov    0x18(%eax),%eax
80103c99:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    if(curproc->ofile[i])
80103ca0:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
80103ca4:	85 c0                	test   %eax,%eax
80103ca6:	74 13                	je     80103cbb <fork+0x8b>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103ca8:	83 ec 0c             	sub    $0xc,%esp
80103cab:	50                   	push   %eax
80103cac:	e8 0f d3 ff ff       	call   80100fc0 <filedup>
80103cb1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103cb4:	83 c4 10             	add    $0x10,%esp
80103cb7:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
  for(i = 0; i < NOFILE; i++)
80103cbb:	83 c6 01             	add    $0x1,%esi
80103cbe:	83 fe 10             	cmp    $0x10,%esi
80103cc1:	75 dd                	jne    80103ca0 <fork+0x70>
  np->cwd = idup(curproc->cwd);
80103cc3:	83 ec 0c             	sub    $0xc,%esp
80103cc6:	ff 73 68             	push   0x68(%ebx)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103cc9:	83 c3 6c             	add    $0x6c,%ebx
  np->cwd = idup(curproc->cwd);
80103ccc:	e8 9f db ff ff       	call   80101870 <idup>
80103cd1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103cd4:	83 c4 0c             	add    $0xc,%esp
  np->cwd = idup(curproc->cwd);
80103cd7:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103cda:	8d 47 6c             	lea    0x6c(%edi),%eax
80103cdd:	6a 10                	push   $0x10
80103cdf:	53                   	push   %ebx
80103ce0:	50                   	push   %eax
80103ce1:	e8 5a 0c 00 00       	call   80104940 <safestrcpy>
  pid = np->pid;
80103ce6:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
80103ce9:	c7 04 24 60 1d 11 80 	movl   $0x80111d60,(%esp)
80103cf0:	e8 cb 09 00 00       	call   801046c0 <acquire>
  np->state = RUNNABLE;
80103cf5:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
80103cfc:	c7 04 24 60 1d 11 80 	movl   $0x80111d60,(%esp)
80103d03:	e8 58 09 00 00       	call   80104660 <release>
  return pid;
80103d08:	83 c4 10             	add    $0x10,%esp
}
80103d0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103d0e:	89 d8                	mov    %ebx,%eax
80103d10:	5b                   	pop    %ebx
80103d11:	5e                   	pop    %esi
80103d12:	5f                   	pop    %edi
80103d13:	5d                   	pop    %ebp
80103d14:	c3                   	ret    
    return -1;
80103d15:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103d1a:	eb ef                	jmp    80103d0b <fork+0xdb>
    kfree(np->kstack);
80103d1c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103d1f:	83 ec 0c             	sub    $0xc,%esp
80103d22:	ff 73 08             	push   0x8(%ebx)
80103d25:	e8 b6 e8 ff ff       	call   801025e0 <kfree>
    np->kstack = 0;
80103d2a:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    return -1;
80103d31:	83 c4 10             	add    $0x10,%esp
    np->state = UNUSED;
80103d34:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
80103d3b:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103d40:	eb c9                	jmp    80103d0b <fork+0xdb>
80103d42:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80103d50 <scheduler>:
{
80103d50:	55                   	push   %ebp
80103d51:	89 e5                	mov    %esp,%ebp
80103d53:	57                   	push   %edi
80103d54:	56                   	push   %esi
80103d55:	53                   	push   %ebx
80103d56:	83 ec 0c             	sub    $0xc,%esp
  struct cpu *c = mycpu();
80103d59:	e8 b2 fc ff ff       	call   80103a10 <mycpu>
  c->proc = 0;
80103d5e:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103d65:	00 00 00 
  struct cpu *c = mycpu();
80103d68:	89 c6                	mov    %eax,%esi
  c->proc = 0;
80103d6a:	8d 78 04             	lea    0x4(%eax),%edi
80103d6d:	8d 76 00             	lea    0x0(%esi),%esi
  asm volatile("sti");
80103d70:	fb                   	sti    
    acquire(&ptable.lock);
80103d71:	83 ec 0c             	sub    $0xc,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103d74:	bb 94 1d 11 80       	mov    $0x80111d94,%ebx
    acquire(&ptable.lock);
80103d79:	68 60 1d 11 80       	push   $0x80111d60
80103d7e:	e8 3d 09 00 00       	call   801046c0 <acquire>
80103d83:	83 c4 10             	add    $0x10,%esp
80103d86:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103d8d:	8d 76 00             	lea    0x0(%esi),%esi
      if(p->state != RUNNABLE)
80103d90:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103d94:	75 33                	jne    80103dc9 <scheduler+0x79>
      switchuvm(p);
80103d96:	83 ec 0c             	sub    $0xc,%esp
      c->proc = p;
80103d99:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
80103d9f:	53                   	push   %ebx
80103da0:	e8 ab 2d 00 00       	call   80106b50 <switchuvm>
      swtch(&(c->scheduler), p->context);
80103da5:	58                   	pop    %eax
80103da6:	5a                   	pop    %edx
80103da7:	ff 73 1c             	push   0x1c(%ebx)
80103daa:	57                   	push   %edi
      p->state = RUNNING;
80103dab:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
80103db2:	e8 e4 0b 00 00       	call   8010499b <swtch>
      switchkvm();
80103db7:	e8 84 2d 00 00       	call   80106b40 <switchkvm>
      c->proc = 0;
80103dbc:	83 c4 10             	add    $0x10,%esp
80103dbf:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80103dc6:	00 00 00 
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103dc9:	83 c3 7c             	add    $0x7c,%ebx
80103dcc:	81 fb 94 3c 11 80    	cmp    $0x80113c94,%ebx
80103dd2:	75 bc                	jne    80103d90 <scheduler+0x40>
    release(&ptable.lock);
80103dd4:	83 ec 0c             	sub    $0xc,%esp
80103dd7:	68 60 1d 11 80       	push   $0x80111d60
80103ddc:	e8 7f 08 00 00       	call   80104660 <release>
    sti();
80103de1:	83 c4 10             	add    $0x10,%esp
80103de4:	eb 8a                	jmp    80103d70 <scheduler+0x20>
80103de6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103ded:	8d 76 00             	lea    0x0(%esi),%esi

80103df0 <sched>:
{
80103df0:	55                   	push   %ebp
80103df1:	89 e5                	mov    %esp,%ebp
80103df3:	56                   	push   %esi
80103df4:	53                   	push   %ebx
  pushcli();
80103df5:	e8 76 07 00 00       	call   80104570 <pushcli>
  c = mycpu();
80103dfa:	e8 11 fc ff ff       	call   80103a10 <mycpu>
  p = c->proc;
80103dff:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103e05:	e8 b6 07 00 00       	call   801045c0 <popcli>
  if(!holding(&ptable.lock))
80103e0a:	83 ec 0c             	sub    $0xc,%esp
80103e0d:	68 60 1d 11 80       	push   $0x80111d60
80103e12:	e8 09 08 00 00       	call   80104620 <holding>
80103e17:	83 c4 10             	add    $0x10,%esp
80103e1a:	85 c0                	test   %eax,%eax
80103e1c:	74 4f                	je     80103e6d <sched+0x7d>
  if(mycpu()->ncli != 1)
80103e1e:	e8 ed fb ff ff       	call   80103a10 <mycpu>
80103e23:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
80103e2a:	75 68                	jne    80103e94 <sched+0xa4>
  if(p->state == RUNNING)
80103e2c:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
80103e30:	74 55                	je     80103e87 <sched+0x97>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103e32:	9c                   	pushf  
80103e33:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103e34:	f6 c4 02             	test   $0x2,%ah
80103e37:	75 41                	jne    80103e7a <sched+0x8a>
  intena = mycpu()->intena;
80103e39:	e8 d2 fb ff ff       	call   80103a10 <mycpu>
  swtch(&p->context, mycpu()->scheduler);
80103e3e:	83 c3 1c             	add    $0x1c,%ebx
  intena = mycpu()->intena;
80103e41:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
80103e47:	e8 c4 fb ff ff       	call   80103a10 <mycpu>
80103e4c:	83 ec 08             	sub    $0x8,%esp
80103e4f:	ff 70 04             	push   0x4(%eax)
80103e52:	53                   	push   %ebx
80103e53:	e8 43 0b 00 00       	call   8010499b <swtch>
  mycpu()->intena = intena;
80103e58:	e8 b3 fb ff ff       	call   80103a10 <mycpu>
}
80103e5d:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80103e60:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
80103e66:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103e69:	5b                   	pop    %ebx
80103e6a:	5e                   	pop    %esi
80103e6b:	5d                   	pop    %ebp
80103e6c:	c3                   	ret    
    panic("sched ptable.lock");
80103e6d:	83 ec 0c             	sub    $0xc,%esp
80103e70:	68 7b 78 10 80       	push   $0x8010787b
80103e75:	e8 06 c5 ff ff       	call   80100380 <panic>
    panic("sched interruptible");
80103e7a:	83 ec 0c             	sub    $0xc,%esp
80103e7d:	68 a7 78 10 80       	push   $0x801078a7
80103e82:	e8 f9 c4 ff ff       	call   80100380 <panic>
    panic("sched running");
80103e87:	83 ec 0c             	sub    $0xc,%esp
80103e8a:	68 99 78 10 80       	push   $0x80107899
80103e8f:	e8 ec c4 ff ff       	call   80100380 <panic>
    panic("sched locks");
80103e94:	83 ec 0c             	sub    $0xc,%esp
80103e97:	68 8d 78 10 80       	push   $0x8010788d
80103e9c:	e8 df c4 ff ff       	call   80100380 <panic>
80103ea1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103ea8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103eaf:	90                   	nop

80103eb0 <exit>:
{
80103eb0:	55                   	push   %ebp
80103eb1:	89 e5                	mov    %esp,%ebp
80103eb3:	57                   	push   %edi
80103eb4:	56                   	push   %esi
80103eb5:	53                   	push   %ebx
80103eb6:	83 ec 0c             	sub    $0xc,%esp
  struct proc *curproc = myproc();
80103eb9:	e8 d2 fb ff ff       	call   80103a90 <myproc>
  if(curproc == initproc)
80103ebe:	39 05 94 3c 11 80    	cmp    %eax,0x80113c94
80103ec4:	0f 84 fd 00 00 00    	je     80103fc7 <exit+0x117>
80103eca:	89 c3                	mov    %eax,%ebx
80103ecc:	8d 70 28             	lea    0x28(%eax),%esi
80103ecf:	8d 78 68             	lea    0x68(%eax),%edi
80103ed2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(curproc->ofile[fd]){
80103ed8:	8b 06                	mov    (%esi),%eax
80103eda:	85 c0                	test   %eax,%eax
80103edc:	74 12                	je     80103ef0 <exit+0x40>
      fileclose(curproc->ofile[fd]);
80103ede:	83 ec 0c             	sub    $0xc,%esp
80103ee1:	50                   	push   %eax
80103ee2:	e8 29 d1 ff ff       	call   80101010 <fileclose>
      curproc->ofile[fd] = 0;
80103ee7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80103eed:	83 c4 10             	add    $0x10,%esp
  for(fd = 0; fd < NOFILE; fd++){
80103ef0:	83 c6 04             	add    $0x4,%esi
80103ef3:	39 f7                	cmp    %esi,%edi
80103ef5:	75 e1                	jne    80103ed8 <exit+0x28>
  begin_op();
80103ef7:	e8 84 ef ff ff       	call   80102e80 <begin_op>
  iput(curproc->cwd);
80103efc:	83 ec 0c             	sub    $0xc,%esp
80103eff:	ff 73 68             	push   0x68(%ebx)
80103f02:	e8 c9 da ff ff       	call   801019d0 <iput>
  end_op();
80103f07:	e8 e4 ef ff ff       	call   80102ef0 <end_op>
  curproc->cwd = 0;
80103f0c:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)
  acquire(&ptable.lock);
80103f13:	c7 04 24 60 1d 11 80 	movl   $0x80111d60,(%esp)
80103f1a:	e8 a1 07 00 00       	call   801046c0 <acquire>
  wakeup1(curproc->parent);
80103f1f:	8b 53 14             	mov    0x14(%ebx),%edx
80103f22:	83 c4 10             	add    $0x10,%esp
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f25:	b8 94 1d 11 80       	mov    $0x80111d94,%eax
80103f2a:	eb 0e                	jmp    80103f3a <exit+0x8a>
80103f2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103f30:	83 c0 7c             	add    $0x7c,%eax
80103f33:	3d 94 3c 11 80       	cmp    $0x80113c94,%eax
80103f38:	74 1c                	je     80103f56 <exit+0xa6>
    if(p->state == SLEEPING && p->chan == chan)
80103f3a:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103f3e:	75 f0                	jne    80103f30 <exit+0x80>
80103f40:	3b 50 20             	cmp    0x20(%eax),%edx
80103f43:	75 eb                	jne    80103f30 <exit+0x80>
      p->state = RUNNABLE;
80103f45:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f4c:	83 c0 7c             	add    $0x7c,%eax
80103f4f:	3d 94 3c 11 80       	cmp    $0x80113c94,%eax
80103f54:	75 e4                	jne    80103f3a <exit+0x8a>
      p->parent = initproc;
80103f56:	8b 0d 94 3c 11 80    	mov    0x80113c94,%ecx
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f5c:	ba 94 1d 11 80       	mov    $0x80111d94,%edx
80103f61:	eb 10                	jmp    80103f73 <exit+0xc3>
80103f63:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103f67:	90                   	nop
80103f68:	83 c2 7c             	add    $0x7c,%edx
80103f6b:	81 fa 94 3c 11 80    	cmp    $0x80113c94,%edx
80103f71:	74 3b                	je     80103fae <exit+0xfe>
    if(p->parent == curproc){
80103f73:	39 5a 14             	cmp    %ebx,0x14(%edx)
80103f76:	75 f0                	jne    80103f68 <exit+0xb8>
      if(p->state == ZOMBIE)
80103f78:	83 7a 0c 05          	cmpl   $0x5,0xc(%edx)
      p->parent = initproc;
80103f7c:	89 4a 14             	mov    %ecx,0x14(%edx)
      if(p->state == ZOMBIE)
80103f7f:	75 e7                	jne    80103f68 <exit+0xb8>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f81:	b8 94 1d 11 80       	mov    $0x80111d94,%eax
80103f86:	eb 12                	jmp    80103f9a <exit+0xea>
80103f88:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103f8f:	90                   	nop
80103f90:	83 c0 7c             	add    $0x7c,%eax
80103f93:	3d 94 3c 11 80       	cmp    $0x80113c94,%eax
80103f98:	74 ce                	je     80103f68 <exit+0xb8>
    if(p->state == SLEEPING && p->chan == chan)
80103f9a:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103f9e:	75 f0                	jne    80103f90 <exit+0xe0>
80103fa0:	3b 48 20             	cmp    0x20(%eax),%ecx
80103fa3:	75 eb                	jne    80103f90 <exit+0xe0>
      p->state = RUNNABLE;
80103fa5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80103fac:	eb e2                	jmp    80103f90 <exit+0xe0>
  curproc->state = ZOMBIE;
80103fae:	c7 43 0c 05 00 00 00 	movl   $0x5,0xc(%ebx)
  sched();
80103fb5:	e8 36 fe ff ff       	call   80103df0 <sched>
  panic("zombie exit");
80103fba:	83 ec 0c             	sub    $0xc,%esp
80103fbd:	68 c8 78 10 80       	push   $0x801078c8
80103fc2:	e8 b9 c3 ff ff       	call   80100380 <panic>
    panic("init exiting");
80103fc7:	83 ec 0c             	sub    $0xc,%esp
80103fca:	68 bb 78 10 80       	push   $0x801078bb
80103fcf:	e8 ac c3 ff ff       	call   80100380 <panic>
80103fd4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103fdb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103fdf:	90                   	nop

80103fe0 <wait>:
{
80103fe0:	55                   	push   %ebp
80103fe1:	89 e5                	mov    %esp,%ebp
80103fe3:	56                   	push   %esi
80103fe4:	53                   	push   %ebx
  pushcli();
80103fe5:	e8 86 05 00 00       	call   80104570 <pushcli>
  c = mycpu();
80103fea:	e8 21 fa ff ff       	call   80103a10 <mycpu>
  p = c->proc;
80103fef:	8b b0 ac 00 00 00    	mov    0xac(%eax),%esi
  popcli();
80103ff5:	e8 c6 05 00 00       	call   801045c0 <popcli>
  acquire(&ptable.lock);
80103ffa:	83 ec 0c             	sub    $0xc,%esp
80103ffd:	68 60 1d 11 80       	push   $0x80111d60
80104002:	e8 b9 06 00 00       	call   801046c0 <acquire>
80104007:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
8010400a:	31 c0                	xor    %eax,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010400c:	bb 94 1d 11 80       	mov    $0x80111d94,%ebx
80104011:	eb 10                	jmp    80104023 <wait+0x43>
80104013:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104017:	90                   	nop
80104018:	83 c3 7c             	add    $0x7c,%ebx
8010401b:	81 fb 94 3c 11 80    	cmp    $0x80113c94,%ebx
80104021:	74 1b                	je     8010403e <wait+0x5e>
      if(p->parent != curproc)
80104023:	39 73 14             	cmp    %esi,0x14(%ebx)
80104026:	75 f0                	jne    80104018 <wait+0x38>
      if(p->state == ZOMBIE){
80104028:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
8010402c:	74 62                	je     80104090 <wait+0xb0>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010402e:	83 c3 7c             	add    $0x7c,%ebx
      havekids = 1;
80104031:	b8 01 00 00 00       	mov    $0x1,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104036:	81 fb 94 3c 11 80    	cmp    $0x80113c94,%ebx
8010403c:	75 e5                	jne    80104023 <wait+0x43>
    if(!havekids || curproc->killed){
8010403e:	85 c0                	test   %eax,%eax
80104040:	0f 84 a0 00 00 00    	je     801040e6 <wait+0x106>
80104046:	8b 46 24             	mov    0x24(%esi),%eax
80104049:	85 c0                	test   %eax,%eax
8010404b:	0f 85 95 00 00 00    	jne    801040e6 <wait+0x106>
  pushcli();
80104051:	e8 1a 05 00 00       	call   80104570 <pushcli>
  c = mycpu();
80104056:	e8 b5 f9 ff ff       	call   80103a10 <mycpu>
  p = c->proc;
8010405b:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80104061:	e8 5a 05 00 00       	call   801045c0 <popcli>
  if(p == 0)
80104066:	85 db                	test   %ebx,%ebx
80104068:	0f 84 8f 00 00 00    	je     801040fd <wait+0x11d>
  p->chan = chan;
8010406e:	89 73 20             	mov    %esi,0x20(%ebx)
  p->state = SLEEPING;
80104071:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
  sched();
80104078:	e8 73 fd ff ff       	call   80103df0 <sched>
  p->chan = 0;
8010407d:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
}
80104084:	eb 84                	jmp    8010400a <wait+0x2a>
80104086:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010408d:	8d 76 00             	lea    0x0(%esi),%esi
        kfree(p->kstack);
80104090:	83 ec 0c             	sub    $0xc,%esp
        pid = p->pid;
80104093:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
80104096:	ff 73 08             	push   0x8(%ebx)
80104099:	e8 42 e5 ff ff       	call   801025e0 <kfree>
        p->kstack = 0;
8010409e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
801040a5:	5a                   	pop    %edx
801040a6:	ff 73 04             	push   0x4(%ebx)
801040a9:	e8 82 2e 00 00       	call   80106f30 <freevm>
        p->pid = 0;
801040ae:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
801040b5:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
801040bc:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
801040c0:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
801040c7:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
801040ce:	c7 04 24 60 1d 11 80 	movl   $0x80111d60,(%esp)
801040d5:	e8 86 05 00 00       	call   80104660 <release>
        return pid;
801040da:	83 c4 10             	add    $0x10,%esp
}
801040dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
801040e0:	89 f0                	mov    %esi,%eax
801040e2:	5b                   	pop    %ebx
801040e3:	5e                   	pop    %esi
801040e4:	5d                   	pop    %ebp
801040e5:	c3                   	ret    
      release(&ptable.lock);
801040e6:	83 ec 0c             	sub    $0xc,%esp
      return -1;
801040e9:	be ff ff ff ff       	mov    $0xffffffff,%esi
      release(&ptable.lock);
801040ee:	68 60 1d 11 80       	push   $0x80111d60
801040f3:	e8 68 05 00 00       	call   80104660 <release>
      return -1;
801040f8:	83 c4 10             	add    $0x10,%esp
801040fb:	eb e0                	jmp    801040dd <wait+0xfd>
    panic("sleep");
801040fd:	83 ec 0c             	sub    $0xc,%esp
80104100:	68 d4 78 10 80       	push   $0x801078d4
80104105:	e8 76 c2 ff ff       	call   80100380 <panic>
8010410a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104110 <yield>:
{
80104110:	55                   	push   %ebp
80104111:	89 e5                	mov    %esp,%ebp
80104113:	53                   	push   %ebx
80104114:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104117:	68 60 1d 11 80       	push   $0x80111d60
8010411c:	e8 9f 05 00 00       	call   801046c0 <acquire>
  pushcli();
80104121:	e8 4a 04 00 00       	call   80104570 <pushcli>
  c = mycpu();
80104126:	e8 e5 f8 ff ff       	call   80103a10 <mycpu>
  p = c->proc;
8010412b:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80104131:	e8 8a 04 00 00       	call   801045c0 <popcli>
  myproc()->state = RUNNABLE;
80104136:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  sched();
8010413d:	e8 ae fc ff ff       	call   80103df0 <sched>
  release(&ptable.lock);
80104142:	c7 04 24 60 1d 11 80 	movl   $0x80111d60,(%esp)
80104149:	e8 12 05 00 00       	call   80104660 <release>
}
8010414e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104151:	83 c4 10             	add    $0x10,%esp
80104154:	c9                   	leave  
80104155:	c3                   	ret    
80104156:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010415d:	8d 76 00             	lea    0x0(%esi),%esi

80104160 <sleep>:
{
80104160:	55                   	push   %ebp
80104161:	89 e5                	mov    %esp,%ebp
80104163:	57                   	push   %edi
80104164:	56                   	push   %esi
80104165:	53                   	push   %ebx
80104166:	83 ec 0c             	sub    $0xc,%esp
80104169:	8b 7d 08             	mov    0x8(%ebp),%edi
8010416c:	8b 75 0c             	mov    0xc(%ebp),%esi
  pushcli();
8010416f:	e8 fc 03 00 00       	call   80104570 <pushcli>
  c = mycpu();
80104174:	e8 97 f8 ff ff       	call   80103a10 <mycpu>
  p = c->proc;
80104179:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
8010417f:	e8 3c 04 00 00       	call   801045c0 <popcli>
  if(p == 0)
80104184:	85 db                	test   %ebx,%ebx
80104186:	0f 84 87 00 00 00    	je     80104213 <sleep+0xb3>
  if(lk == 0)
8010418c:	85 f6                	test   %esi,%esi
8010418e:	74 76                	je     80104206 <sleep+0xa6>
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104190:	81 fe 60 1d 11 80    	cmp    $0x80111d60,%esi
80104196:	74 50                	je     801041e8 <sleep+0x88>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104198:	83 ec 0c             	sub    $0xc,%esp
8010419b:	68 60 1d 11 80       	push   $0x80111d60
801041a0:	e8 1b 05 00 00       	call   801046c0 <acquire>
    release(lk);
801041a5:	89 34 24             	mov    %esi,(%esp)
801041a8:	e8 b3 04 00 00       	call   80104660 <release>
  p->chan = chan;
801041ad:	89 7b 20             	mov    %edi,0x20(%ebx)
  p->state = SLEEPING;
801041b0:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
  sched();
801041b7:	e8 34 fc ff ff       	call   80103df0 <sched>
  p->chan = 0;
801041bc:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
    release(&ptable.lock);
801041c3:	c7 04 24 60 1d 11 80 	movl   $0x80111d60,(%esp)
801041ca:	e8 91 04 00 00       	call   80104660 <release>
    acquire(lk);
801041cf:	89 75 08             	mov    %esi,0x8(%ebp)
801041d2:	83 c4 10             	add    $0x10,%esp
}
801041d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801041d8:	5b                   	pop    %ebx
801041d9:	5e                   	pop    %esi
801041da:	5f                   	pop    %edi
801041db:	5d                   	pop    %ebp
    acquire(lk);
801041dc:	e9 df 04 00 00       	jmp    801046c0 <acquire>
801041e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  p->chan = chan;
801041e8:	89 7b 20             	mov    %edi,0x20(%ebx)
  p->state = SLEEPING;
801041eb:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
  sched();
801041f2:	e8 f9 fb ff ff       	call   80103df0 <sched>
  p->chan = 0;
801041f7:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
}
801041fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104201:	5b                   	pop    %ebx
80104202:	5e                   	pop    %esi
80104203:	5f                   	pop    %edi
80104204:	5d                   	pop    %ebp
80104205:	c3                   	ret    
    panic("sleep without lk");
80104206:	83 ec 0c             	sub    $0xc,%esp
80104209:	68 da 78 10 80       	push   $0x801078da
8010420e:	e8 6d c1 ff ff       	call   80100380 <panic>
    panic("sleep");
80104213:	83 ec 0c             	sub    $0xc,%esp
80104216:	68 d4 78 10 80       	push   $0x801078d4
8010421b:	e8 60 c1 ff ff       	call   80100380 <panic>

80104220 <wakeup>:
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104220:	55                   	push   %ebp
80104221:	89 e5                	mov    %esp,%ebp
80104223:	53                   	push   %ebx
80104224:	83 ec 10             	sub    $0x10,%esp
80104227:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ptable.lock);
8010422a:	68 60 1d 11 80       	push   $0x80111d60
8010422f:	e8 8c 04 00 00       	call   801046c0 <acquire>
80104234:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104237:	b8 94 1d 11 80       	mov    $0x80111d94,%eax
8010423c:	eb 0c                	jmp    8010424a <wakeup+0x2a>
8010423e:	66 90                	xchg   %ax,%ax
80104240:	83 c0 7c             	add    $0x7c,%eax
80104243:	3d 94 3c 11 80       	cmp    $0x80113c94,%eax
80104248:	74 1c                	je     80104266 <wakeup+0x46>
    if(p->state == SLEEPING && p->chan == chan)
8010424a:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
8010424e:	75 f0                	jne    80104240 <wakeup+0x20>
80104250:	3b 58 20             	cmp    0x20(%eax),%ebx
80104253:	75 eb                	jne    80104240 <wakeup+0x20>
      p->state = RUNNABLE;
80104255:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010425c:	83 c0 7c             	add    $0x7c,%eax
8010425f:	3d 94 3c 11 80       	cmp    $0x80113c94,%eax
80104264:	75 e4                	jne    8010424a <wakeup+0x2a>
  wakeup1(chan);
  release(&ptable.lock);
80104266:	c7 45 08 60 1d 11 80 	movl   $0x80111d60,0x8(%ebp)
}
8010426d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104270:	c9                   	leave  
  release(&ptable.lock);
80104271:	e9 ea 03 00 00       	jmp    80104660 <release>
80104276:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010427d:	8d 76 00             	lea    0x0(%esi),%esi

80104280 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104280:	55                   	push   %ebp
80104281:	89 e5                	mov    %esp,%ebp
80104283:	53                   	push   %ebx
80104284:	83 ec 10             	sub    $0x10,%esp
80104287:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
8010428a:	68 60 1d 11 80       	push   $0x80111d60
8010428f:	e8 2c 04 00 00       	call   801046c0 <acquire>
80104294:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104297:	b8 94 1d 11 80       	mov    $0x80111d94,%eax
8010429c:	eb 0c                	jmp    801042aa <kill+0x2a>
8010429e:	66 90                	xchg   %ax,%ax
801042a0:	83 c0 7c             	add    $0x7c,%eax
801042a3:	3d 94 3c 11 80       	cmp    $0x80113c94,%eax
801042a8:	74 36                	je     801042e0 <kill+0x60>
    if(p->pid == pid){
801042aa:	39 58 10             	cmp    %ebx,0x10(%eax)
801042ad:	75 f1                	jne    801042a0 <kill+0x20>
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801042af:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
      p->killed = 1;
801042b3:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      if(p->state == SLEEPING)
801042ba:	75 07                	jne    801042c3 <kill+0x43>
        p->state = RUNNABLE;
801042bc:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801042c3:	83 ec 0c             	sub    $0xc,%esp
801042c6:	68 60 1d 11 80       	push   $0x80111d60
801042cb:	e8 90 03 00 00       	call   80104660 <release>
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}
801042d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
      return 0;
801042d3:	83 c4 10             	add    $0x10,%esp
801042d6:	31 c0                	xor    %eax,%eax
}
801042d8:	c9                   	leave  
801042d9:	c3                   	ret    
801042da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  release(&ptable.lock);
801042e0:	83 ec 0c             	sub    $0xc,%esp
801042e3:	68 60 1d 11 80       	push   $0x80111d60
801042e8:	e8 73 03 00 00       	call   80104660 <release>
}
801042ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  return -1;
801042f0:	83 c4 10             	add    $0x10,%esp
801042f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801042f8:	c9                   	leave  
801042f9:	c3                   	ret    
801042fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104300 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104300:	55                   	push   %ebp
80104301:	89 e5                	mov    %esp,%ebp
80104303:	57                   	push   %edi
80104304:	56                   	push   %esi
80104305:	8d 75 e8             	lea    -0x18(%ebp),%esi
80104308:	53                   	push   %ebx
80104309:	bb 00 1e 11 80       	mov    $0x80111e00,%ebx
8010430e:	83 ec 3c             	sub    $0x3c,%esp
80104311:	eb 24                	jmp    80104337 <procdump+0x37>
80104313:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104317:	90                   	nop
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104318:	83 ec 0c             	sub    $0xc,%esp
8010431b:	68 5b 7c 10 80       	push   $0x80107c5b
80104320:	e8 7b c3 ff ff       	call   801006a0 <cprintf>
80104325:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104328:	83 c3 7c             	add    $0x7c,%ebx
8010432b:	81 fb 00 3d 11 80    	cmp    $0x80113d00,%ebx
80104331:	0f 84 81 00 00 00    	je     801043b8 <procdump+0xb8>
    if(p->state == UNUSED)
80104337:	8b 43 a0             	mov    -0x60(%ebx),%eax
8010433a:	85 c0                	test   %eax,%eax
8010433c:	74 ea                	je     80104328 <procdump+0x28>
      state = "???";
8010433e:	ba eb 78 10 80       	mov    $0x801078eb,%edx
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104343:	83 f8 05             	cmp    $0x5,%eax
80104346:	77 11                	ja     80104359 <procdump+0x59>
80104348:	8b 14 85 4c 79 10 80 	mov    -0x7fef86b4(,%eax,4),%edx
      state = "???";
8010434f:	b8 eb 78 10 80       	mov    $0x801078eb,%eax
80104354:	85 d2                	test   %edx,%edx
80104356:	0f 44 d0             	cmove  %eax,%edx
    cprintf("%d %s %s", p->pid, state, p->name);
80104359:	53                   	push   %ebx
8010435a:	52                   	push   %edx
8010435b:	ff 73 a4             	push   -0x5c(%ebx)
8010435e:	68 ef 78 10 80       	push   $0x801078ef
80104363:	e8 38 c3 ff ff       	call   801006a0 <cprintf>
    if(p->state == SLEEPING){
80104368:	83 c4 10             	add    $0x10,%esp
8010436b:	83 7b a0 02          	cmpl   $0x2,-0x60(%ebx)
8010436f:	75 a7                	jne    80104318 <procdump+0x18>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104371:	83 ec 08             	sub    $0x8,%esp
80104374:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104377:	8d 7d c0             	lea    -0x40(%ebp),%edi
8010437a:	50                   	push   %eax
8010437b:	8b 43 b0             	mov    -0x50(%ebx),%eax
8010437e:	8b 40 0c             	mov    0xc(%eax),%eax
80104381:	83 c0 08             	add    $0x8,%eax
80104384:	50                   	push   %eax
80104385:	e8 86 01 00 00       	call   80104510 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
8010438a:	83 c4 10             	add    $0x10,%esp
8010438d:	8d 76 00             	lea    0x0(%esi),%esi
80104390:	8b 17                	mov    (%edi),%edx
80104392:	85 d2                	test   %edx,%edx
80104394:	74 82                	je     80104318 <procdump+0x18>
        cprintf(" %p", pc[i]);
80104396:	83 ec 08             	sub    $0x8,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104399:	83 c7 04             	add    $0x4,%edi
        cprintf(" %p", pc[i]);
8010439c:	52                   	push   %edx
8010439d:	68 41 73 10 80       	push   $0x80107341
801043a2:	e8 f9 c2 ff ff       	call   801006a0 <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
801043a7:	83 c4 10             	add    $0x10,%esp
801043aa:	39 fe                	cmp    %edi,%esi
801043ac:	75 e2                	jne    80104390 <procdump+0x90>
801043ae:	e9 65 ff ff ff       	jmp    80104318 <procdump+0x18>
801043b3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801043b7:	90                   	nop
  }
}
801043b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801043bb:	5b                   	pop    %ebx
801043bc:	5e                   	pop    %esi
801043bd:	5f                   	pop    %edi
801043be:	5d                   	pop    %ebp
801043bf:	c3                   	ret    

801043c0 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801043c0:	55                   	push   %ebp
801043c1:	89 e5                	mov    %esp,%ebp
801043c3:	53                   	push   %ebx
801043c4:	83 ec 0c             	sub    $0xc,%esp
801043c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
801043ca:	68 64 79 10 80       	push   $0x80107964
801043cf:	8d 43 04             	lea    0x4(%ebx),%eax
801043d2:	50                   	push   %eax
801043d3:	e8 18 01 00 00       	call   801044f0 <initlock>
  lk->name = name;
801043d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  lk->locked = 0;
801043db:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
}
801043e1:	83 c4 10             	add    $0x10,%esp
  lk->pid = 0;
801043e4:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  lk->name = name;
801043eb:	89 43 38             	mov    %eax,0x38(%ebx)
}
801043ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801043f1:	c9                   	leave  
801043f2:	c3                   	ret    
801043f3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801043fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104400 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104400:	55                   	push   %ebp
80104401:	89 e5                	mov    %esp,%ebp
80104403:	56                   	push   %esi
80104404:	53                   	push   %ebx
80104405:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80104408:	8d 73 04             	lea    0x4(%ebx),%esi
8010440b:	83 ec 0c             	sub    $0xc,%esp
8010440e:	56                   	push   %esi
8010440f:	e8 ac 02 00 00       	call   801046c0 <acquire>
  while (lk->locked) {
80104414:	8b 13                	mov    (%ebx),%edx
80104416:	83 c4 10             	add    $0x10,%esp
80104419:	85 d2                	test   %edx,%edx
8010441b:	74 16                	je     80104433 <acquiresleep+0x33>
8010441d:	8d 76 00             	lea    0x0(%esi),%esi
    sleep(lk, &lk->lk);
80104420:	83 ec 08             	sub    $0x8,%esp
80104423:	56                   	push   %esi
80104424:	53                   	push   %ebx
80104425:	e8 36 fd ff ff       	call   80104160 <sleep>
  while (lk->locked) {
8010442a:	8b 03                	mov    (%ebx),%eax
8010442c:	83 c4 10             	add    $0x10,%esp
8010442f:	85 c0                	test   %eax,%eax
80104431:	75 ed                	jne    80104420 <acquiresleep+0x20>
  }
  lk->locked = 1;
80104433:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80104439:	e8 52 f6 ff ff       	call   80103a90 <myproc>
8010443e:	8b 40 10             	mov    0x10(%eax),%eax
80104441:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80104444:	89 75 08             	mov    %esi,0x8(%ebp)
}
80104447:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010444a:	5b                   	pop    %ebx
8010444b:	5e                   	pop    %esi
8010444c:	5d                   	pop    %ebp
  release(&lk->lk);
8010444d:	e9 0e 02 00 00       	jmp    80104660 <release>
80104452:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104459:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104460 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104460:	55                   	push   %ebp
80104461:	89 e5                	mov    %esp,%ebp
80104463:	56                   	push   %esi
80104464:	53                   	push   %ebx
80104465:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80104468:	8d 73 04             	lea    0x4(%ebx),%esi
8010446b:	83 ec 0c             	sub    $0xc,%esp
8010446e:	56                   	push   %esi
8010446f:	e8 4c 02 00 00       	call   801046c0 <acquire>
  lk->locked = 0;
80104474:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
8010447a:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80104481:	89 1c 24             	mov    %ebx,(%esp)
80104484:	e8 97 fd ff ff       	call   80104220 <wakeup>
  release(&lk->lk);
80104489:	89 75 08             	mov    %esi,0x8(%ebp)
8010448c:	83 c4 10             	add    $0x10,%esp
}
8010448f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104492:	5b                   	pop    %ebx
80104493:	5e                   	pop    %esi
80104494:	5d                   	pop    %ebp
  release(&lk->lk);
80104495:	e9 c6 01 00 00       	jmp    80104660 <release>
8010449a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801044a0 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801044a0:	55                   	push   %ebp
801044a1:	89 e5                	mov    %esp,%ebp
801044a3:	57                   	push   %edi
801044a4:	31 ff                	xor    %edi,%edi
801044a6:	56                   	push   %esi
801044a7:	53                   	push   %ebx
801044a8:	83 ec 18             	sub    $0x18,%esp
801044ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
801044ae:	8d 73 04             	lea    0x4(%ebx),%esi
801044b1:	56                   	push   %esi
801044b2:	e8 09 02 00 00       	call   801046c0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
801044b7:	8b 03                	mov    (%ebx),%eax
801044b9:	83 c4 10             	add    $0x10,%esp
801044bc:	85 c0                	test   %eax,%eax
801044be:	75 18                	jne    801044d8 <holdingsleep+0x38>
  release(&lk->lk);
801044c0:	83 ec 0c             	sub    $0xc,%esp
801044c3:	56                   	push   %esi
801044c4:	e8 97 01 00 00       	call   80104660 <release>
  return r;
}
801044c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801044cc:	89 f8                	mov    %edi,%eax
801044ce:	5b                   	pop    %ebx
801044cf:	5e                   	pop    %esi
801044d0:	5f                   	pop    %edi
801044d1:	5d                   	pop    %ebp
801044d2:	c3                   	ret    
801044d3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801044d7:	90                   	nop
  r = lk->locked && (lk->pid == myproc()->pid);
801044d8:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
801044db:	e8 b0 f5 ff ff       	call   80103a90 <myproc>
801044e0:	39 58 10             	cmp    %ebx,0x10(%eax)
801044e3:	0f 94 c0             	sete   %al
801044e6:	0f b6 c0             	movzbl %al,%eax
801044e9:	89 c7                	mov    %eax,%edi
801044eb:	eb d3                	jmp    801044c0 <holdingsleep+0x20>
801044ed:	66 90                	xchg   %ax,%ax
801044ef:	90                   	nop

801044f0 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801044f0:	55                   	push   %ebp
801044f1:	89 e5                	mov    %esp,%ebp
801044f3:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
801044f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  lk->locked = 0;
801044f9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->name = name;
801044ff:	89 50 04             	mov    %edx,0x4(%eax)
  lk->cpu = 0;
80104502:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104509:	5d                   	pop    %ebp
8010450a:	c3                   	ret    
8010450b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010450f:	90                   	nop

80104510 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104510:	55                   	push   %ebp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104511:	31 d2                	xor    %edx,%edx
{
80104513:	89 e5                	mov    %esp,%ebp
80104515:	53                   	push   %ebx
  ebp = (uint*)v - 2;
80104516:	8b 45 08             	mov    0x8(%ebp),%eax
{
80104519:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  ebp = (uint*)v - 2;
8010451c:	83 e8 08             	sub    $0x8,%eax
  for(i = 0; i < 10; i++){
8010451f:	90                   	nop
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104520:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
80104526:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
8010452c:	77 1a                	ja     80104548 <getcallerpcs+0x38>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010452e:	8b 58 04             	mov    0x4(%eax),%ebx
80104531:	89 1c 91             	mov    %ebx,(%ecx,%edx,4)
  for(i = 0; i < 10; i++){
80104534:	83 c2 01             	add    $0x1,%edx
    ebp = (uint*)ebp[0]; // saved %ebp
80104537:	8b 00                	mov    (%eax),%eax
  for(i = 0; i < 10; i++){
80104539:	83 fa 0a             	cmp    $0xa,%edx
8010453c:	75 e2                	jne    80104520 <getcallerpcs+0x10>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
}
8010453e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104541:	c9                   	leave  
80104542:	c3                   	ret    
80104543:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104547:	90                   	nop
  for(; i < 10; i++)
80104548:	8d 04 91             	lea    (%ecx,%edx,4),%eax
8010454b:	8d 51 28             	lea    0x28(%ecx),%edx
8010454e:	66 90                	xchg   %ax,%ax
    pcs[i] = 0;
80104550:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104556:	83 c0 04             	add    $0x4,%eax
80104559:	39 d0                	cmp    %edx,%eax
8010455b:	75 f3                	jne    80104550 <getcallerpcs+0x40>
}
8010455d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104560:	c9                   	leave  
80104561:	c3                   	ret    
80104562:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104569:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104570 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104570:	55                   	push   %ebp
80104571:	89 e5                	mov    %esp,%ebp
80104573:	53                   	push   %ebx
80104574:	83 ec 04             	sub    $0x4,%esp
80104577:	9c                   	pushf  
80104578:	5b                   	pop    %ebx
  asm volatile("cli");
80104579:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
8010457a:	e8 91 f4 ff ff       	call   80103a10 <mycpu>
8010457f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104585:	85 c0                	test   %eax,%eax
80104587:	74 17                	je     801045a0 <pushcli+0x30>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80104589:	e8 82 f4 ff ff       	call   80103a10 <mycpu>
8010458e:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80104595:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104598:	c9                   	leave  
80104599:	c3                   	ret    
8010459a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    mycpu()->intena = eflags & FL_IF;
801045a0:	e8 6b f4 ff ff       	call   80103a10 <mycpu>
801045a5:	81 e3 00 02 00 00    	and    $0x200,%ebx
801045ab:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
801045b1:	eb d6                	jmp    80104589 <pushcli+0x19>
801045b3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801045ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801045c0 <popcli>:

void
popcli(void)
{
801045c0:	55                   	push   %ebp
801045c1:	89 e5                	mov    %esp,%ebp
801045c3:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801045c6:	9c                   	pushf  
801045c7:	58                   	pop    %eax
  if(readeflags()&FL_IF)
801045c8:	f6 c4 02             	test   $0x2,%ah
801045cb:	75 35                	jne    80104602 <popcli+0x42>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
801045cd:	e8 3e f4 ff ff       	call   80103a10 <mycpu>
801045d2:	83 a8 a4 00 00 00 01 	subl   $0x1,0xa4(%eax)
801045d9:	78 34                	js     8010460f <popcli+0x4f>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
801045db:	e8 30 f4 ff ff       	call   80103a10 <mycpu>
801045e0:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801045e6:	85 d2                	test   %edx,%edx
801045e8:	74 06                	je     801045f0 <popcli+0x30>
    sti();
}
801045ea:	c9                   	leave  
801045eb:	c3                   	ret    
801045ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if(mycpu()->ncli == 0 && mycpu()->intena)
801045f0:	e8 1b f4 ff ff       	call   80103a10 <mycpu>
801045f5:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801045fb:	85 c0                	test   %eax,%eax
801045fd:	74 eb                	je     801045ea <popcli+0x2a>
  asm volatile("sti");
801045ff:	fb                   	sti    
}
80104600:	c9                   	leave  
80104601:	c3                   	ret    
    panic("popcli - interruptible");
80104602:	83 ec 0c             	sub    $0xc,%esp
80104605:	68 6f 79 10 80       	push   $0x8010796f
8010460a:	e8 71 bd ff ff       	call   80100380 <panic>
    panic("popcli");
8010460f:	83 ec 0c             	sub    $0xc,%esp
80104612:	68 86 79 10 80       	push   $0x80107986
80104617:	e8 64 bd ff ff       	call   80100380 <panic>
8010461c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104620 <holding>:
{
80104620:	55                   	push   %ebp
80104621:	89 e5                	mov    %esp,%ebp
80104623:	56                   	push   %esi
80104624:	53                   	push   %ebx
80104625:	8b 75 08             	mov    0x8(%ebp),%esi
80104628:	31 db                	xor    %ebx,%ebx
  pushcli();
8010462a:	e8 41 ff ff ff       	call   80104570 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
8010462f:	8b 06                	mov    (%esi),%eax
80104631:	85 c0                	test   %eax,%eax
80104633:	75 0b                	jne    80104640 <holding+0x20>
  popcli();
80104635:	e8 86 ff ff ff       	call   801045c0 <popcli>
}
8010463a:	89 d8                	mov    %ebx,%eax
8010463c:	5b                   	pop    %ebx
8010463d:	5e                   	pop    %esi
8010463e:	5d                   	pop    %ebp
8010463f:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80104640:	8b 5e 08             	mov    0x8(%esi),%ebx
80104643:	e8 c8 f3 ff ff       	call   80103a10 <mycpu>
80104648:	39 c3                	cmp    %eax,%ebx
8010464a:	0f 94 c3             	sete   %bl
  popcli();
8010464d:	e8 6e ff ff ff       	call   801045c0 <popcli>
  r = lock->locked && lock->cpu == mycpu();
80104652:	0f b6 db             	movzbl %bl,%ebx
}
80104655:	89 d8                	mov    %ebx,%eax
80104657:	5b                   	pop    %ebx
80104658:	5e                   	pop    %esi
80104659:	5d                   	pop    %ebp
8010465a:	c3                   	ret    
8010465b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010465f:	90                   	nop

80104660 <release>:
{
80104660:	55                   	push   %ebp
80104661:	89 e5                	mov    %esp,%ebp
80104663:	56                   	push   %esi
80104664:	53                   	push   %ebx
80104665:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80104668:	e8 03 ff ff ff       	call   80104570 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
8010466d:	8b 03                	mov    (%ebx),%eax
8010466f:	85 c0                	test   %eax,%eax
80104671:	75 15                	jne    80104688 <release+0x28>
  popcli();
80104673:	e8 48 ff ff ff       	call   801045c0 <popcli>
    panic("release");
80104678:	83 ec 0c             	sub    $0xc,%esp
8010467b:	68 8d 79 10 80       	push   $0x8010798d
80104680:	e8 fb bc ff ff       	call   80100380 <panic>
80104685:	8d 76 00             	lea    0x0(%esi),%esi
  r = lock->locked && lock->cpu == mycpu();
80104688:	8b 73 08             	mov    0x8(%ebx),%esi
8010468b:	e8 80 f3 ff ff       	call   80103a10 <mycpu>
80104690:	39 c6                	cmp    %eax,%esi
80104692:	75 df                	jne    80104673 <release+0x13>
  popcli();
80104694:	e8 27 ff ff ff       	call   801045c0 <popcli>
  lk->pcs[0] = 0;
80104699:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
801046a0:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
801046a7:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801046ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
}
801046b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
801046b5:	5b                   	pop    %ebx
801046b6:	5e                   	pop    %esi
801046b7:	5d                   	pop    %ebp
  popcli();
801046b8:	e9 03 ff ff ff       	jmp    801045c0 <popcli>
801046bd:	8d 76 00             	lea    0x0(%esi),%esi

801046c0 <acquire>:
{
801046c0:	55                   	push   %ebp
801046c1:	89 e5                	mov    %esp,%ebp
801046c3:	53                   	push   %ebx
801046c4:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801046c7:	e8 a4 fe ff ff       	call   80104570 <pushcli>
  if(holding(lk))
801046cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
801046cf:	e8 9c fe ff ff       	call   80104570 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
801046d4:	8b 03                	mov    (%ebx),%eax
801046d6:	85 c0                	test   %eax,%eax
801046d8:	75 7e                	jne    80104758 <acquire+0x98>
  popcli();
801046da:	e8 e1 fe ff ff       	call   801045c0 <popcli>
  asm volatile("lock; xchgl %0, %1" :
801046df:	b9 01 00 00 00       	mov    $0x1,%ecx
801046e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  while(xchg(&lk->locked, 1) != 0)
801046e8:	8b 55 08             	mov    0x8(%ebp),%edx
801046eb:	89 c8                	mov    %ecx,%eax
801046ed:	f0 87 02             	lock xchg %eax,(%edx)
801046f0:	85 c0                	test   %eax,%eax
801046f2:	75 f4                	jne    801046e8 <acquire+0x28>
  __sync_synchronize();
801046f4:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
801046f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
801046fc:	e8 0f f3 ff ff       	call   80103a10 <mycpu>
  getcallerpcs(&lk, lk->pcs);
80104701:	8b 4d 08             	mov    0x8(%ebp),%ecx
  ebp = (uint*)v - 2;
80104704:	89 ea                	mov    %ebp,%edx
  lk->cpu = mycpu();
80104706:	89 43 08             	mov    %eax,0x8(%ebx)
  for(i = 0; i < 10; i++){
80104709:	31 c0                	xor    %eax,%eax
8010470b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010470f:	90                   	nop
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104710:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80104716:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
8010471c:	77 1a                	ja     80104738 <acquire+0x78>
    pcs[i] = ebp[1];     // saved %eip
8010471e:	8b 5a 04             	mov    0x4(%edx),%ebx
80104721:	89 5c 81 0c          	mov    %ebx,0xc(%ecx,%eax,4)
  for(i = 0; i < 10; i++){
80104725:	83 c0 01             	add    $0x1,%eax
    ebp = (uint*)ebp[0]; // saved %ebp
80104728:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
8010472a:	83 f8 0a             	cmp    $0xa,%eax
8010472d:	75 e1                	jne    80104710 <acquire+0x50>
}
8010472f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104732:	c9                   	leave  
80104733:	c3                   	ret    
80104734:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(; i < 10; i++)
80104738:	8d 44 81 0c          	lea    0xc(%ecx,%eax,4),%eax
8010473c:	8d 51 34             	lea    0x34(%ecx),%edx
8010473f:	90                   	nop
    pcs[i] = 0;
80104740:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104746:	83 c0 04             	add    $0x4,%eax
80104749:	39 c2                	cmp    %eax,%edx
8010474b:	75 f3                	jne    80104740 <acquire+0x80>
}
8010474d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104750:	c9                   	leave  
80104751:	c3                   	ret    
80104752:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  r = lock->locked && lock->cpu == mycpu();
80104758:	8b 5b 08             	mov    0x8(%ebx),%ebx
8010475b:	e8 b0 f2 ff ff       	call   80103a10 <mycpu>
80104760:	39 c3                	cmp    %eax,%ebx
80104762:	0f 85 72 ff ff ff    	jne    801046da <acquire+0x1a>
  popcli();
80104768:	e8 53 fe ff ff       	call   801045c0 <popcli>
    panic("acquire");
8010476d:	83 ec 0c             	sub    $0xc,%esp
80104770:	68 95 79 10 80       	push   $0x80107995
80104775:	e8 06 bc ff ff       	call   80100380 <panic>
8010477a:	66 90                	xchg   %ax,%ax
8010477c:	66 90                	xchg   %ax,%ax
8010477e:	66 90                	xchg   %ax,%ax

80104780 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104780:	55                   	push   %ebp
80104781:	89 e5                	mov    %esp,%ebp
80104783:	57                   	push   %edi
80104784:	8b 55 08             	mov    0x8(%ebp),%edx
80104787:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010478a:	53                   	push   %ebx
8010478b:	8b 45 0c             	mov    0xc(%ebp),%eax
  if ((int)dst%4 == 0 && n%4 == 0){
8010478e:	89 d7                	mov    %edx,%edi
80104790:	09 cf                	or     %ecx,%edi
80104792:	83 e7 03             	and    $0x3,%edi
80104795:	75 29                	jne    801047c0 <memset+0x40>
    c &= 0xFF;
80104797:	0f b6 f8             	movzbl %al,%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010479a:	c1 e0 18             	shl    $0x18,%eax
8010479d:	89 fb                	mov    %edi,%ebx
8010479f:	c1 e9 02             	shr    $0x2,%ecx
801047a2:	c1 e3 10             	shl    $0x10,%ebx
801047a5:	09 d8                	or     %ebx,%eax
801047a7:	09 f8                	or     %edi,%eax
801047a9:	c1 e7 08             	shl    $0x8,%edi
801047ac:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
801047ae:	89 d7                	mov    %edx,%edi
801047b0:	fc                   	cld    
801047b1:	f3 ab                	rep stos %eax,%es:(%edi)
  } else
    stosb(dst, c, n);
  return dst;
}
801047b3:	5b                   	pop    %ebx
801047b4:	89 d0                	mov    %edx,%eax
801047b6:	5f                   	pop    %edi
801047b7:	5d                   	pop    %ebp
801047b8:	c3                   	ret    
801047b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  asm volatile("cld; rep stosb" :
801047c0:	89 d7                	mov    %edx,%edi
801047c2:	fc                   	cld    
801047c3:	f3 aa                	rep stos %al,%es:(%edi)
801047c5:	5b                   	pop    %ebx
801047c6:	89 d0                	mov    %edx,%eax
801047c8:	5f                   	pop    %edi
801047c9:	5d                   	pop    %ebp
801047ca:	c3                   	ret    
801047cb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801047cf:	90                   	nop

801047d0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801047d0:	55                   	push   %ebp
801047d1:	89 e5                	mov    %esp,%ebp
801047d3:	56                   	push   %esi
801047d4:	8b 75 10             	mov    0x10(%ebp),%esi
801047d7:	8b 55 08             	mov    0x8(%ebp),%edx
801047da:	53                   	push   %ebx
801047db:	8b 45 0c             	mov    0xc(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801047de:	85 f6                	test   %esi,%esi
801047e0:	74 2e                	je     80104810 <memcmp+0x40>
801047e2:	01 c6                	add    %eax,%esi
801047e4:	eb 14                	jmp    801047fa <memcmp+0x2a>
801047e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801047ed:	8d 76 00             	lea    0x0(%esi),%esi
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
801047f0:	83 c0 01             	add    $0x1,%eax
801047f3:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
801047f6:	39 f0                	cmp    %esi,%eax
801047f8:	74 16                	je     80104810 <memcmp+0x40>
    if(*s1 != *s2)
801047fa:	0f b6 0a             	movzbl (%edx),%ecx
801047fd:	0f b6 18             	movzbl (%eax),%ebx
80104800:	38 d9                	cmp    %bl,%cl
80104802:	74 ec                	je     801047f0 <memcmp+0x20>
      return *s1 - *s2;
80104804:	0f b6 c1             	movzbl %cl,%eax
80104807:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80104809:	5b                   	pop    %ebx
8010480a:	5e                   	pop    %esi
8010480b:	5d                   	pop    %ebp
8010480c:	c3                   	ret    
8010480d:	8d 76 00             	lea    0x0(%esi),%esi
80104810:	5b                   	pop    %ebx
  return 0;
80104811:	31 c0                	xor    %eax,%eax
}
80104813:	5e                   	pop    %esi
80104814:	5d                   	pop    %ebp
80104815:	c3                   	ret    
80104816:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010481d:	8d 76 00             	lea    0x0(%esi),%esi

80104820 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104820:	55                   	push   %ebp
80104821:	89 e5                	mov    %esp,%ebp
80104823:	57                   	push   %edi
80104824:	8b 55 08             	mov    0x8(%ebp),%edx
80104827:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010482a:	56                   	push   %esi
8010482b:	8b 75 0c             	mov    0xc(%ebp),%esi
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
8010482e:	39 d6                	cmp    %edx,%esi
80104830:	73 26                	jae    80104858 <memmove+0x38>
80104832:	8d 3c 0e             	lea    (%esi,%ecx,1),%edi
80104835:	39 fa                	cmp    %edi,%edx
80104837:	73 1f                	jae    80104858 <memmove+0x38>
80104839:	8d 41 ff             	lea    -0x1(%ecx),%eax
    s += n;
    d += n;
    while(n-- > 0)
8010483c:	85 c9                	test   %ecx,%ecx
8010483e:	74 0c                	je     8010484c <memmove+0x2c>
      *--d = *--s;
80104840:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
80104844:	88 0c 02             	mov    %cl,(%edx,%eax,1)
    while(n-- > 0)
80104847:	83 e8 01             	sub    $0x1,%eax
8010484a:	73 f4                	jae    80104840 <memmove+0x20>
  } else
    while(n-- > 0)
      *d++ = *s++;

  return dst;
}
8010484c:	5e                   	pop    %esi
8010484d:	89 d0                	mov    %edx,%eax
8010484f:	5f                   	pop    %edi
80104850:	5d                   	pop    %ebp
80104851:	c3                   	ret    
80104852:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    while(n-- > 0)
80104858:	8d 04 0e             	lea    (%esi,%ecx,1),%eax
8010485b:	89 d7                	mov    %edx,%edi
8010485d:	85 c9                	test   %ecx,%ecx
8010485f:	74 eb                	je     8010484c <memmove+0x2c>
80104861:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      *d++ = *s++;
80104868:	a4                   	movsb  %ds:(%esi),%es:(%edi)
    while(n-- > 0)
80104869:	39 c6                	cmp    %eax,%esi
8010486b:	75 fb                	jne    80104868 <memmove+0x48>
}
8010486d:	5e                   	pop    %esi
8010486e:	89 d0                	mov    %edx,%eax
80104870:	5f                   	pop    %edi
80104871:	5d                   	pop    %ebp
80104872:	c3                   	ret    
80104873:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010487a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104880 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
  return memmove(dst, src, n);
80104880:	eb 9e                	jmp    80104820 <memmove>
80104882:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104889:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104890 <strncmp>:
}

int
strncmp(const char *p, const char *q, uint n)
{
80104890:	55                   	push   %ebp
80104891:	89 e5                	mov    %esp,%ebp
80104893:	56                   	push   %esi
80104894:	8b 75 10             	mov    0x10(%ebp),%esi
80104897:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010489a:	53                   	push   %ebx
8010489b:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(n > 0 && *p && *p == *q)
8010489e:	85 f6                	test   %esi,%esi
801048a0:	74 2e                	je     801048d0 <strncmp+0x40>
801048a2:	01 d6                	add    %edx,%esi
801048a4:	eb 18                	jmp    801048be <strncmp+0x2e>
801048a6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801048ad:	8d 76 00             	lea    0x0(%esi),%esi
801048b0:	38 d8                	cmp    %bl,%al
801048b2:	75 14                	jne    801048c8 <strncmp+0x38>
    n--, p++, q++;
801048b4:	83 c2 01             	add    $0x1,%edx
801048b7:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
801048ba:	39 f2                	cmp    %esi,%edx
801048bc:	74 12                	je     801048d0 <strncmp+0x40>
801048be:	0f b6 01             	movzbl (%ecx),%eax
801048c1:	0f b6 1a             	movzbl (%edx),%ebx
801048c4:	84 c0                	test   %al,%al
801048c6:	75 e8                	jne    801048b0 <strncmp+0x20>
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
801048c8:	29 d8                	sub    %ebx,%eax
}
801048ca:	5b                   	pop    %ebx
801048cb:	5e                   	pop    %esi
801048cc:	5d                   	pop    %ebp
801048cd:	c3                   	ret    
801048ce:	66 90                	xchg   %ax,%ax
801048d0:	5b                   	pop    %ebx
    return 0;
801048d1:	31 c0                	xor    %eax,%eax
}
801048d3:	5e                   	pop    %esi
801048d4:	5d                   	pop    %ebp
801048d5:	c3                   	ret    
801048d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801048dd:	8d 76 00             	lea    0x0(%esi),%esi

801048e0 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801048e0:	55                   	push   %ebp
801048e1:	89 e5                	mov    %esp,%ebp
801048e3:	57                   	push   %edi
801048e4:	56                   	push   %esi
801048e5:	8b 75 08             	mov    0x8(%ebp),%esi
801048e8:	53                   	push   %ebx
801048e9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
801048ec:	89 f0                	mov    %esi,%eax
801048ee:	eb 15                	jmp    80104905 <strncpy+0x25>
801048f0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
801048f4:	8b 7d 0c             	mov    0xc(%ebp),%edi
801048f7:	83 c0 01             	add    $0x1,%eax
801048fa:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
801048fe:	88 50 ff             	mov    %dl,-0x1(%eax)
80104901:	84 d2                	test   %dl,%dl
80104903:	74 09                	je     8010490e <strncpy+0x2e>
80104905:	89 cb                	mov    %ecx,%ebx
80104907:	83 e9 01             	sub    $0x1,%ecx
8010490a:	85 db                	test   %ebx,%ebx
8010490c:	7f e2                	jg     801048f0 <strncpy+0x10>
    ;
  while(n-- > 0)
8010490e:	89 c2                	mov    %eax,%edx
80104910:	85 c9                	test   %ecx,%ecx
80104912:	7e 17                	jle    8010492b <strncpy+0x4b>
80104914:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    *s++ = 0;
80104918:	83 c2 01             	add    $0x1,%edx
8010491b:	89 c1                	mov    %eax,%ecx
8010491d:	c6 42 ff 00          	movb   $0x0,-0x1(%edx)
  while(n-- > 0)
80104921:	29 d1                	sub    %edx,%ecx
80104923:	8d 4c 0b ff          	lea    -0x1(%ebx,%ecx,1),%ecx
80104927:	85 c9                	test   %ecx,%ecx
80104929:	7f ed                	jg     80104918 <strncpy+0x38>
  return os;
}
8010492b:	5b                   	pop    %ebx
8010492c:	89 f0                	mov    %esi,%eax
8010492e:	5e                   	pop    %esi
8010492f:	5f                   	pop    %edi
80104930:	5d                   	pop    %ebp
80104931:	c3                   	ret    
80104932:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104939:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104940 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104940:	55                   	push   %ebp
80104941:	89 e5                	mov    %esp,%ebp
80104943:	56                   	push   %esi
80104944:	8b 55 10             	mov    0x10(%ebp),%edx
80104947:	8b 75 08             	mov    0x8(%ebp),%esi
8010494a:	53                   	push   %ebx
8010494b:	8b 45 0c             	mov    0xc(%ebp),%eax
  char *os;

  os = s;
  if(n <= 0)
8010494e:	85 d2                	test   %edx,%edx
80104950:	7e 25                	jle    80104977 <safestrcpy+0x37>
80104952:	8d 5c 10 ff          	lea    -0x1(%eax,%edx,1),%ebx
80104956:	89 f2                	mov    %esi,%edx
80104958:	eb 16                	jmp    80104970 <safestrcpy+0x30>
8010495a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80104960:	0f b6 08             	movzbl (%eax),%ecx
80104963:	83 c0 01             	add    $0x1,%eax
80104966:	83 c2 01             	add    $0x1,%edx
80104969:	88 4a ff             	mov    %cl,-0x1(%edx)
8010496c:	84 c9                	test   %cl,%cl
8010496e:	74 04                	je     80104974 <safestrcpy+0x34>
80104970:	39 d8                	cmp    %ebx,%eax
80104972:	75 ec                	jne    80104960 <safestrcpy+0x20>
    ;
  *s = 0;
80104974:	c6 02 00             	movb   $0x0,(%edx)
  return os;
}
80104977:	89 f0                	mov    %esi,%eax
80104979:	5b                   	pop    %ebx
8010497a:	5e                   	pop    %esi
8010497b:	5d                   	pop    %ebp
8010497c:	c3                   	ret    
8010497d:	8d 76 00             	lea    0x0(%esi),%esi

80104980 <strlen>:

int
strlen(const char *s)
{
80104980:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
80104981:	31 c0                	xor    %eax,%eax
{
80104983:	89 e5                	mov    %esp,%ebp
80104985:	8b 55 08             	mov    0x8(%ebp),%edx
  for(n = 0; s[n]; n++)
80104988:	80 3a 00             	cmpb   $0x0,(%edx)
8010498b:	74 0c                	je     80104999 <strlen+0x19>
8010498d:	8d 76 00             	lea    0x0(%esi),%esi
80104990:	83 c0 01             	add    $0x1,%eax
80104993:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80104997:	75 f7                	jne    80104990 <strlen+0x10>
    ;
  return n;
}
80104999:	5d                   	pop    %ebp
8010499a:	c3                   	ret    

8010499b <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010499b:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010499f:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
801049a3:	55                   	push   %ebp
  pushl %ebx
801049a4:	53                   	push   %ebx
  pushl %esi
801049a5:	56                   	push   %esi
  pushl %edi
801049a6:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801049a7:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801049a9:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
801049ab:	5f                   	pop    %edi
  popl %esi
801049ac:	5e                   	pop    %esi
  popl %ebx
801049ad:	5b                   	pop    %ebx
  popl %ebp
801049ae:	5d                   	pop    %ebp
  ret
801049af:	c3                   	ret    

801049b0 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801049b0:	55                   	push   %ebp
801049b1:	89 e5                	mov    %esp,%ebp
801049b3:	53                   	push   %ebx
801049b4:	83 ec 04             	sub    $0x4,%esp
801049b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
801049ba:	e8 d1 f0 ff ff       	call   80103a90 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801049bf:	8b 00                	mov    (%eax),%eax
801049c1:	39 d8                	cmp    %ebx,%eax
801049c3:	76 1b                	jbe    801049e0 <fetchint+0x30>
801049c5:	8d 53 04             	lea    0x4(%ebx),%edx
801049c8:	39 d0                	cmp    %edx,%eax
801049ca:	72 14                	jb     801049e0 <fetchint+0x30>
    return -1;
  *ip = *(int*)(addr);
801049cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801049cf:	8b 13                	mov    (%ebx),%edx
801049d1:	89 10                	mov    %edx,(%eax)
  return 0;
801049d3:	31 c0                	xor    %eax,%eax
}
801049d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801049d8:	c9                   	leave  
801049d9:	c3                   	ret    
801049da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
801049e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049e5:	eb ee                	jmp    801049d5 <fetchint+0x25>
801049e7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801049ee:	66 90                	xchg   %ax,%ax

801049f0 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801049f0:	55                   	push   %ebp
801049f1:	89 e5                	mov    %esp,%ebp
801049f3:	53                   	push   %ebx
801049f4:	83 ec 04             	sub    $0x4,%esp
801049f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
801049fa:	e8 91 f0 ff ff       	call   80103a90 <myproc>

  if(addr >= curproc->sz)
801049ff:	39 18                	cmp    %ebx,(%eax)
80104a01:	76 2d                	jbe    80104a30 <fetchstr+0x40>
    return -1;
  *pp = (char*)addr;
80104a03:	8b 55 0c             	mov    0xc(%ebp),%edx
80104a06:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80104a08:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80104a0a:	39 d3                	cmp    %edx,%ebx
80104a0c:	73 22                	jae    80104a30 <fetchstr+0x40>
80104a0e:	89 d8                	mov    %ebx,%eax
80104a10:	eb 0d                	jmp    80104a1f <fetchstr+0x2f>
80104a12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104a18:	83 c0 01             	add    $0x1,%eax
80104a1b:	39 c2                	cmp    %eax,%edx
80104a1d:	76 11                	jbe    80104a30 <fetchstr+0x40>
    if(*s == 0)
80104a1f:	80 38 00             	cmpb   $0x0,(%eax)
80104a22:	75 f4                	jne    80104a18 <fetchstr+0x28>
      return s - *pp;
80104a24:	29 d8                	sub    %ebx,%eax
  }
  return -1;
}
80104a26:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104a29:	c9                   	leave  
80104a2a:	c3                   	ret    
80104a2b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104a2f:	90                   	nop
80104a30:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    return -1;
80104a33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104a38:	c9                   	leave  
80104a39:	c3                   	ret    
80104a3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104a40 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104a40:	55                   	push   %ebp
80104a41:	89 e5                	mov    %esp,%ebp
80104a43:	56                   	push   %esi
80104a44:	53                   	push   %ebx
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104a45:	e8 46 f0 ff ff       	call   80103a90 <myproc>
80104a4a:	8b 55 08             	mov    0x8(%ebp),%edx
80104a4d:	8b 40 18             	mov    0x18(%eax),%eax
80104a50:	8b 40 44             	mov    0x44(%eax),%eax
80104a53:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
  struct proc *curproc = myproc();
80104a56:	e8 35 f0 ff ff       	call   80103a90 <myproc>
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104a5b:	8d 73 04             	lea    0x4(%ebx),%esi
  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104a5e:	8b 00                	mov    (%eax),%eax
80104a60:	39 c6                	cmp    %eax,%esi
80104a62:	73 1c                	jae    80104a80 <argint+0x40>
80104a64:	8d 53 08             	lea    0x8(%ebx),%edx
80104a67:	39 d0                	cmp    %edx,%eax
80104a69:	72 15                	jb     80104a80 <argint+0x40>
  *ip = *(int*)(addr);
80104a6b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a6e:	8b 53 04             	mov    0x4(%ebx),%edx
80104a71:	89 10                	mov    %edx,(%eax)
  return 0;
80104a73:	31 c0                	xor    %eax,%eax
}
80104a75:	5b                   	pop    %ebx
80104a76:	5e                   	pop    %esi
80104a77:	5d                   	pop    %ebp
80104a78:	c3                   	ret    
80104a79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80104a80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104a85:	eb ee                	jmp    80104a75 <argint+0x35>
80104a87:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104a8e:	66 90                	xchg   %ax,%ax

80104a90 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104a90:	55                   	push   %ebp
80104a91:	89 e5                	mov    %esp,%ebp
80104a93:	57                   	push   %edi
80104a94:	56                   	push   %esi
80104a95:	53                   	push   %ebx
80104a96:	83 ec 0c             	sub    $0xc,%esp
  int i;
  struct proc *curproc = myproc();
80104a99:	e8 f2 ef ff ff       	call   80103a90 <myproc>
80104a9e:	89 c6                	mov    %eax,%esi
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104aa0:	e8 eb ef ff ff       	call   80103a90 <myproc>
80104aa5:	8b 55 08             	mov    0x8(%ebp),%edx
80104aa8:	8b 40 18             	mov    0x18(%eax),%eax
80104aab:	8b 40 44             	mov    0x44(%eax),%eax
80104aae:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
  struct proc *curproc = myproc();
80104ab1:	e8 da ef ff ff       	call   80103a90 <myproc>
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104ab6:	8d 7b 04             	lea    0x4(%ebx),%edi
  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104ab9:	8b 00                	mov    (%eax),%eax
80104abb:	39 c7                	cmp    %eax,%edi
80104abd:	73 31                	jae    80104af0 <argptr+0x60>
80104abf:	8d 4b 08             	lea    0x8(%ebx),%ecx
80104ac2:	39 c8                	cmp    %ecx,%eax
80104ac4:	72 2a                	jb     80104af0 <argptr+0x60>
 
  if(argint(n, &i) < 0)
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104ac6:	8b 55 10             	mov    0x10(%ebp),%edx
  *ip = *(int*)(addr);
80104ac9:	8b 43 04             	mov    0x4(%ebx),%eax
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104acc:	85 d2                	test   %edx,%edx
80104ace:	78 20                	js     80104af0 <argptr+0x60>
80104ad0:	8b 16                	mov    (%esi),%edx
80104ad2:	39 c2                	cmp    %eax,%edx
80104ad4:	76 1a                	jbe    80104af0 <argptr+0x60>
80104ad6:	8b 5d 10             	mov    0x10(%ebp),%ebx
80104ad9:	01 c3                	add    %eax,%ebx
80104adb:	39 da                	cmp    %ebx,%edx
80104add:	72 11                	jb     80104af0 <argptr+0x60>
    return -1;
  *pp = (char*)i;
80104adf:	8b 55 0c             	mov    0xc(%ebp),%edx
80104ae2:	89 02                	mov    %eax,(%edx)
  return 0;
80104ae4:	31 c0                	xor    %eax,%eax
}
80104ae6:	83 c4 0c             	add    $0xc,%esp
80104ae9:	5b                   	pop    %ebx
80104aea:	5e                   	pop    %esi
80104aeb:	5f                   	pop    %edi
80104aec:	5d                   	pop    %ebp
80104aed:	c3                   	ret    
80104aee:	66 90                	xchg   %ax,%ax
    return -1;
80104af0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104af5:	eb ef                	jmp    80104ae6 <argptr+0x56>
80104af7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104afe:	66 90                	xchg   %ax,%ax

80104b00 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104b00:	55                   	push   %ebp
80104b01:	89 e5                	mov    %esp,%ebp
80104b03:	56                   	push   %esi
80104b04:	53                   	push   %ebx
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104b05:	e8 86 ef ff ff       	call   80103a90 <myproc>
80104b0a:	8b 55 08             	mov    0x8(%ebp),%edx
80104b0d:	8b 40 18             	mov    0x18(%eax),%eax
80104b10:	8b 40 44             	mov    0x44(%eax),%eax
80104b13:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
  struct proc *curproc = myproc();
80104b16:	e8 75 ef ff ff       	call   80103a90 <myproc>
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104b1b:	8d 73 04             	lea    0x4(%ebx),%esi
  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104b1e:	8b 00                	mov    (%eax),%eax
80104b20:	39 c6                	cmp    %eax,%esi
80104b22:	73 44                	jae    80104b68 <argstr+0x68>
80104b24:	8d 53 08             	lea    0x8(%ebx),%edx
80104b27:	39 d0                	cmp    %edx,%eax
80104b29:	72 3d                	jb     80104b68 <argstr+0x68>
  *ip = *(int*)(addr);
80104b2b:	8b 5b 04             	mov    0x4(%ebx),%ebx
  struct proc *curproc = myproc();
80104b2e:	e8 5d ef ff ff       	call   80103a90 <myproc>
  if(addr >= curproc->sz)
80104b33:	3b 18                	cmp    (%eax),%ebx
80104b35:	73 31                	jae    80104b68 <argstr+0x68>
  *pp = (char*)addr;
80104b37:	8b 55 0c             	mov    0xc(%ebp),%edx
80104b3a:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80104b3c:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80104b3e:	39 d3                	cmp    %edx,%ebx
80104b40:	73 26                	jae    80104b68 <argstr+0x68>
80104b42:	89 d8                	mov    %ebx,%eax
80104b44:	eb 11                	jmp    80104b57 <argstr+0x57>
80104b46:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104b4d:	8d 76 00             	lea    0x0(%esi),%esi
80104b50:	83 c0 01             	add    $0x1,%eax
80104b53:	39 c2                	cmp    %eax,%edx
80104b55:	76 11                	jbe    80104b68 <argstr+0x68>
    if(*s == 0)
80104b57:	80 38 00             	cmpb   $0x0,(%eax)
80104b5a:	75 f4                	jne    80104b50 <argstr+0x50>
      return s - *pp;
80104b5c:	29 d8                	sub    %ebx,%eax
  int addr;
  if(argint(n, &addr) < 0)
    return -1;
  return fetchstr(addr, pp);
}
80104b5e:	5b                   	pop    %ebx
80104b5f:	5e                   	pop    %esi
80104b60:	5d                   	pop    %ebp
80104b61:	c3                   	ret    
80104b62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104b68:	5b                   	pop    %ebx
    return -1;
80104b69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104b6e:	5e                   	pop    %esi
80104b6f:	5d                   	pop    %ebp
80104b70:	c3                   	ret    
80104b71:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104b78:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104b7f:	90                   	nop

80104b80 <syscall>:
[SYS_getlastcat]   sys_getlastcat,
};

void
syscall(void)
{
80104b80:	55                   	push   %ebp
80104b81:	89 e5                	mov    %esp,%ebp
80104b83:	53                   	push   %ebx
80104b84:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80104b87:	e8 04 ef ff ff       	call   80103a90 <myproc>
80104b8c:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
80104b8e:	8b 40 18             	mov    0x18(%eax),%eax
80104b91:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104b94:	8d 50 ff             	lea    -0x1(%eax),%edx
80104b97:	83 fa 15             	cmp    $0x15,%edx
80104b9a:	77 24                	ja     80104bc0 <syscall+0x40>
80104b9c:	8b 14 85 c0 79 10 80 	mov    -0x7fef8640(,%eax,4),%edx
80104ba3:	85 d2                	test   %edx,%edx
80104ba5:	74 19                	je     80104bc0 <syscall+0x40>
    curproc->tf->eax = syscalls[num]();
80104ba7:	ff d2                	call   *%edx
80104ba9:	89 c2                	mov    %eax,%edx
80104bab:	8b 43 18             	mov    0x18(%ebx),%eax
80104bae:	89 50 1c             	mov    %edx,0x1c(%eax)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
80104bb1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104bb4:	c9                   	leave  
80104bb5:	c3                   	ret    
80104bb6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104bbd:	8d 76 00             	lea    0x0(%esi),%esi
    cprintf("%d %s: unknown sys call %d\n",
80104bc0:	50                   	push   %eax
            curproc->pid, curproc->name, num);
80104bc1:	8d 43 6c             	lea    0x6c(%ebx),%eax
    cprintf("%d %s: unknown sys call %d\n",
80104bc4:	50                   	push   %eax
80104bc5:	ff 73 10             	push   0x10(%ebx)
80104bc8:	68 9d 79 10 80       	push   $0x8010799d
80104bcd:	e8 ce ba ff ff       	call   801006a0 <cprintf>
    curproc->tf->eax = -1;
80104bd2:	8b 43 18             	mov    0x18(%ebx),%eax
80104bd5:	83 c4 10             	add    $0x10,%esp
80104bd8:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
}
80104bdf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104be2:	c9                   	leave  
80104be3:	c3                   	ret    
80104be4:	66 90                	xchg   %ax,%ax
80104be6:	66 90                	xchg   %ax,%ax
80104be8:	66 90                	xchg   %ax,%ax
80104bea:	66 90                	xchg   %ax,%ax
80104bec:	66 90                	xchg   %ax,%ax
80104bee:	66 90                	xchg   %ax,%ax

80104bf0 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104bf0:	55                   	push   %ebp
80104bf1:	89 e5                	mov    %esp,%ebp
80104bf3:	57                   	push   %edi
80104bf4:	56                   	push   %esi
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104bf5:	8d 7d da             	lea    -0x26(%ebp),%edi
{
80104bf8:	53                   	push   %ebx
80104bf9:	83 ec 34             	sub    $0x34,%esp
80104bfc:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80104bff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if((dp = nameiparent(path, name)) == 0)
80104c02:	57                   	push   %edi
80104c03:	50                   	push   %eax
{
80104c04:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80104c07:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  if((dp = nameiparent(path, name)) == 0)
80104c0a:	e8 d1 d5 ff ff       	call   801021e0 <nameiparent>
80104c0f:	83 c4 10             	add    $0x10,%esp
80104c12:	85 c0                	test   %eax,%eax
80104c14:	0f 84 46 01 00 00    	je     80104d60 <create+0x170>
    return 0;
  ilock(dp);
80104c1a:	83 ec 0c             	sub    $0xc,%esp
80104c1d:	89 c3                	mov    %eax,%ebx
80104c1f:	50                   	push   %eax
80104c20:	e8 7b cc ff ff       	call   801018a0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
80104c25:	83 c4 0c             	add    $0xc,%esp
80104c28:	6a 00                	push   $0x0
80104c2a:	57                   	push   %edi
80104c2b:	53                   	push   %ebx
80104c2c:	e8 cf d1 ff ff       	call   80101e00 <dirlookup>
80104c31:	83 c4 10             	add    $0x10,%esp
80104c34:	89 c6                	mov    %eax,%esi
80104c36:	85 c0                	test   %eax,%eax
80104c38:	74 56                	je     80104c90 <create+0xa0>
    iunlockput(dp);
80104c3a:	83 ec 0c             	sub    $0xc,%esp
80104c3d:	53                   	push   %ebx
80104c3e:	e8 ed ce ff ff       	call   80101b30 <iunlockput>
    ilock(ip);
80104c43:	89 34 24             	mov    %esi,(%esp)
80104c46:	e8 55 cc ff ff       	call   801018a0 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80104c4b:	83 c4 10             	add    $0x10,%esp
80104c4e:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80104c53:	75 1b                	jne    80104c70 <create+0x80>
80104c55:	66 83 7e 50 02       	cmpw   $0x2,0x50(%esi)
80104c5a:	75 14                	jne    80104c70 <create+0x80>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
80104c5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104c5f:	89 f0                	mov    %esi,%eax
80104c61:	5b                   	pop    %ebx
80104c62:	5e                   	pop    %esi
80104c63:	5f                   	pop    %edi
80104c64:	5d                   	pop    %ebp
80104c65:	c3                   	ret    
80104c66:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104c6d:	8d 76 00             	lea    0x0(%esi),%esi
    iunlockput(ip);
80104c70:	83 ec 0c             	sub    $0xc,%esp
80104c73:	56                   	push   %esi
    return 0;
80104c74:	31 f6                	xor    %esi,%esi
    iunlockput(ip);
80104c76:	e8 b5 ce ff ff       	call   80101b30 <iunlockput>
    return 0;
80104c7b:	83 c4 10             	add    $0x10,%esp
}
80104c7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104c81:	89 f0                	mov    %esi,%eax
80104c83:	5b                   	pop    %ebx
80104c84:	5e                   	pop    %esi
80104c85:	5f                   	pop    %edi
80104c86:	5d                   	pop    %ebp
80104c87:	c3                   	ret    
80104c88:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104c8f:	90                   	nop
  if((ip = ialloc(dp->dev, type)) == 0)
80104c90:	0f bf 45 d4          	movswl -0x2c(%ebp),%eax
80104c94:	83 ec 08             	sub    $0x8,%esp
80104c97:	50                   	push   %eax
80104c98:	ff 33                	push   (%ebx)
80104c9a:	e8 91 ca ff ff       	call   80101730 <ialloc>
80104c9f:	83 c4 10             	add    $0x10,%esp
80104ca2:	89 c6                	mov    %eax,%esi
80104ca4:	85 c0                	test   %eax,%eax
80104ca6:	0f 84 cd 00 00 00    	je     80104d79 <create+0x189>
  ilock(ip);
80104cac:	83 ec 0c             	sub    $0xc,%esp
80104caf:	50                   	push   %eax
80104cb0:	e8 eb cb ff ff       	call   801018a0 <ilock>
  ip->major = major;
80104cb5:	0f b7 45 d0          	movzwl -0x30(%ebp),%eax
80104cb9:	66 89 46 52          	mov    %ax,0x52(%esi)
  ip->minor = minor;
80104cbd:	0f b7 45 cc          	movzwl -0x34(%ebp),%eax
80104cc1:	66 89 46 54          	mov    %ax,0x54(%esi)
  ip->nlink = 1;
80104cc5:	b8 01 00 00 00       	mov    $0x1,%eax
80104cca:	66 89 46 56          	mov    %ax,0x56(%esi)
  iupdate(ip);
80104cce:	89 34 24             	mov    %esi,(%esp)
80104cd1:	e8 1a cb ff ff       	call   801017f0 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
80104cd6:	83 c4 10             	add    $0x10,%esp
80104cd9:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80104cde:	74 30                	je     80104d10 <create+0x120>
  if(dirlink(dp, name, ip->inum) < 0)
80104ce0:	83 ec 04             	sub    $0x4,%esp
80104ce3:	ff 76 04             	push   0x4(%esi)
80104ce6:	57                   	push   %edi
80104ce7:	53                   	push   %ebx
80104ce8:	e8 13 d4 ff ff       	call   80102100 <dirlink>
80104ced:	83 c4 10             	add    $0x10,%esp
80104cf0:	85 c0                	test   %eax,%eax
80104cf2:	78 78                	js     80104d6c <create+0x17c>
  iunlockput(dp);
80104cf4:	83 ec 0c             	sub    $0xc,%esp
80104cf7:	53                   	push   %ebx
80104cf8:	e8 33 ce ff ff       	call   80101b30 <iunlockput>
  return ip;
80104cfd:	83 c4 10             	add    $0x10,%esp
}
80104d00:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104d03:	89 f0                	mov    %esi,%eax
80104d05:	5b                   	pop    %ebx
80104d06:	5e                   	pop    %esi
80104d07:	5f                   	pop    %edi
80104d08:	5d                   	pop    %ebp
80104d09:	c3                   	ret    
80104d0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    iupdate(dp);
80104d10:	83 ec 0c             	sub    $0xc,%esp
    dp->nlink++;  // for ".."
80104d13:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
    iupdate(dp);
80104d18:	53                   	push   %ebx
80104d19:	e8 d2 ca ff ff       	call   801017f0 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80104d1e:	83 c4 0c             	add    $0xc,%esp
80104d21:	ff 76 04             	push   0x4(%esi)
80104d24:	68 38 7a 10 80       	push   $0x80107a38
80104d29:	56                   	push   %esi
80104d2a:	e8 d1 d3 ff ff       	call   80102100 <dirlink>
80104d2f:	83 c4 10             	add    $0x10,%esp
80104d32:	85 c0                	test   %eax,%eax
80104d34:	78 18                	js     80104d4e <create+0x15e>
80104d36:	83 ec 04             	sub    $0x4,%esp
80104d39:	ff 73 04             	push   0x4(%ebx)
80104d3c:	68 37 7a 10 80       	push   $0x80107a37
80104d41:	56                   	push   %esi
80104d42:	e8 b9 d3 ff ff       	call   80102100 <dirlink>
80104d47:	83 c4 10             	add    $0x10,%esp
80104d4a:	85 c0                	test   %eax,%eax
80104d4c:	79 92                	jns    80104ce0 <create+0xf0>
      panic("create dots");
80104d4e:	83 ec 0c             	sub    $0xc,%esp
80104d51:	68 2b 7a 10 80       	push   $0x80107a2b
80104d56:	e8 25 b6 ff ff       	call   80100380 <panic>
80104d5b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104d5f:	90                   	nop
}
80104d60:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return 0;
80104d63:	31 f6                	xor    %esi,%esi
}
80104d65:	5b                   	pop    %ebx
80104d66:	89 f0                	mov    %esi,%eax
80104d68:	5e                   	pop    %esi
80104d69:	5f                   	pop    %edi
80104d6a:	5d                   	pop    %ebp
80104d6b:	c3                   	ret    
    panic("create: dirlink");
80104d6c:	83 ec 0c             	sub    $0xc,%esp
80104d6f:	68 3a 7a 10 80       	push   $0x80107a3a
80104d74:	e8 07 b6 ff ff       	call   80100380 <panic>
    panic("create: ialloc");
80104d79:	83 ec 0c             	sub    $0xc,%esp
80104d7c:	68 1c 7a 10 80       	push   $0x80107a1c
80104d81:	e8 fa b5 ff ff       	call   80100380 <panic>
80104d86:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104d8d:	8d 76 00             	lea    0x0(%esi),%esi

80104d90 <sys_dup>:
{
80104d90:	55                   	push   %ebp
80104d91:	89 e5                	mov    %esp,%ebp
80104d93:	56                   	push   %esi
80104d94:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80104d95:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80104d98:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
80104d9b:	50                   	push   %eax
80104d9c:	6a 00                	push   $0x0
80104d9e:	e8 9d fc ff ff       	call   80104a40 <argint>
80104da3:	83 c4 10             	add    $0x10,%esp
80104da6:	85 c0                	test   %eax,%eax
80104da8:	78 36                	js     80104de0 <sys_dup+0x50>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104daa:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104dae:	77 30                	ja     80104de0 <sys_dup+0x50>
80104db0:	e8 db ec ff ff       	call   80103a90 <myproc>
80104db5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104db8:	8b 74 90 28          	mov    0x28(%eax,%edx,4),%esi
80104dbc:	85 f6                	test   %esi,%esi
80104dbe:	74 20                	je     80104de0 <sys_dup+0x50>
  struct proc *curproc = myproc();
80104dc0:	e8 cb ec ff ff       	call   80103a90 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
80104dc5:	31 db                	xor    %ebx,%ebx
80104dc7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104dce:	66 90                	xchg   %ax,%ax
    if(curproc->ofile[fd] == 0){
80104dd0:	8b 54 98 28          	mov    0x28(%eax,%ebx,4),%edx
80104dd4:	85 d2                	test   %edx,%edx
80104dd6:	74 18                	je     80104df0 <sys_dup+0x60>
  for(fd = 0; fd < NOFILE; fd++){
80104dd8:	83 c3 01             	add    $0x1,%ebx
80104ddb:	83 fb 10             	cmp    $0x10,%ebx
80104dde:	75 f0                	jne    80104dd0 <sys_dup+0x40>
}
80104de0:	8d 65 f8             	lea    -0x8(%ebp),%esp
    return -1;
80104de3:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
}
80104de8:	89 d8                	mov    %ebx,%eax
80104dea:	5b                   	pop    %ebx
80104deb:	5e                   	pop    %esi
80104dec:	5d                   	pop    %ebp
80104ded:	c3                   	ret    
80104dee:	66 90                	xchg   %ax,%ax
  filedup(f);
80104df0:	83 ec 0c             	sub    $0xc,%esp
      curproc->ofile[fd] = f;
80104df3:	89 74 98 28          	mov    %esi,0x28(%eax,%ebx,4)
  filedup(f);
80104df7:	56                   	push   %esi
80104df8:	e8 c3 c1 ff ff       	call   80100fc0 <filedup>
  return fd;
80104dfd:	83 c4 10             	add    $0x10,%esp
}
80104e00:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104e03:	89 d8                	mov    %ebx,%eax
80104e05:	5b                   	pop    %ebx
80104e06:	5e                   	pop    %esi
80104e07:	5d                   	pop    %ebp
80104e08:	c3                   	ret    
80104e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104e10 <sys_read>:
{
80104e10:	55                   	push   %ebp
80104e11:	89 e5                	mov    %esp,%ebp
80104e13:	56                   	push   %esi
80104e14:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80104e15:	8d 5d f4             	lea    -0xc(%ebp),%ebx
{
80104e18:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
80104e1b:	53                   	push   %ebx
80104e1c:	6a 00                	push   $0x0
80104e1e:	e8 1d fc ff ff       	call   80104a40 <argint>
80104e23:	83 c4 10             	add    $0x10,%esp
80104e26:	85 c0                	test   %eax,%eax
80104e28:	78 5e                	js     80104e88 <sys_read+0x78>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104e2a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104e2e:	77 58                	ja     80104e88 <sys_read+0x78>
80104e30:	e8 5b ec ff ff       	call   80103a90 <myproc>
80104e35:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e38:	8b 74 90 28          	mov    0x28(%eax,%edx,4),%esi
80104e3c:	85 f6                	test   %esi,%esi
80104e3e:	74 48                	je     80104e88 <sys_read+0x78>
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104e40:	83 ec 08             	sub    $0x8,%esp
80104e43:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104e46:	50                   	push   %eax
80104e47:	6a 02                	push   $0x2
80104e49:	e8 f2 fb ff ff       	call   80104a40 <argint>
80104e4e:	83 c4 10             	add    $0x10,%esp
80104e51:	85 c0                	test   %eax,%eax
80104e53:	78 33                	js     80104e88 <sys_read+0x78>
80104e55:	83 ec 04             	sub    $0x4,%esp
80104e58:	ff 75 f0             	push   -0x10(%ebp)
80104e5b:	53                   	push   %ebx
80104e5c:	6a 01                	push   $0x1
80104e5e:	e8 2d fc ff ff       	call   80104a90 <argptr>
80104e63:	83 c4 10             	add    $0x10,%esp
80104e66:	85 c0                	test   %eax,%eax
80104e68:	78 1e                	js     80104e88 <sys_read+0x78>
  return fileread(f, p, n);
80104e6a:	83 ec 04             	sub    $0x4,%esp
80104e6d:	ff 75 f0             	push   -0x10(%ebp)
80104e70:	ff 75 f4             	push   -0xc(%ebp)
80104e73:	56                   	push   %esi
80104e74:	e8 c7 c2 ff ff       	call   80101140 <fileread>
80104e79:	83 c4 10             	add    $0x10,%esp
}
80104e7c:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104e7f:	5b                   	pop    %ebx
80104e80:	5e                   	pop    %esi
80104e81:	5d                   	pop    %ebp
80104e82:	c3                   	ret    
80104e83:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104e87:	90                   	nop
    return -1;
80104e88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e8d:	eb ed                	jmp    80104e7c <sys_read+0x6c>
80104e8f:	90                   	nop

80104e90 <sys_write>:
{
80104e90:	55                   	push   %ebp
80104e91:	89 e5                	mov    %esp,%ebp
80104e93:	56                   	push   %esi
80104e94:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80104e95:	8d 5d f4             	lea    -0xc(%ebp),%ebx
{
80104e98:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
80104e9b:	53                   	push   %ebx
80104e9c:	6a 00                	push   $0x0
80104e9e:	e8 9d fb ff ff       	call   80104a40 <argint>
80104ea3:	83 c4 10             	add    $0x10,%esp
80104ea6:	85 c0                	test   %eax,%eax
80104ea8:	78 5e                	js     80104f08 <sys_write+0x78>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104eaa:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104eae:	77 58                	ja     80104f08 <sys_write+0x78>
80104eb0:	e8 db eb ff ff       	call   80103a90 <myproc>
80104eb5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104eb8:	8b 74 90 28          	mov    0x28(%eax,%edx,4),%esi
80104ebc:	85 f6                	test   %esi,%esi
80104ebe:	74 48                	je     80104f08 <sys_write+0x78>
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104ec0:	83 ec 08             	sub    $0x8,%esp
80104ec3:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104ec6:	50                   	push   %eax
80104ec7:	6a 02                	push   $0x2
80104ec9:	e8 72 fb ff ff       	call   80104a40 <argint>
80104ece:	83 c4 10             	add    $0x10,%esp
80104ed1:	85 c0                	test   %eax,%eax
80104ed3:	78 33                	js     80104f08 <sys_write+0x78>
80104ed5:	83 ec 04             	sub    $0x4,%esp
80104ed8:	ff 75 f0             	push   -0x10(%ebp)
80104edb:	53                   	push   %ebx
80104edc:	6a 01                	push   $0x1
80104ede:	e8 ad fb ff ff       	call   80104a90 <argptr>
80104ee3:	83 c4 10             	add    $0x10,%esp
80104ee6:	85 c0                	test   %eax,%eax
80104ee8:	78 1e                	js     80104f08 <sys_write+0x78>
  return filewrite(f, p, n);
80104eea:	83 ec 04             	sub    $0x4,%esp
80104eed:	ff 75 f0             	push   -0x10(%ebp)
80104ef0:	ff 75 f4             	push   -0xc(%ebp)
80104ef3:	56                   	push   %esi
80104ef4:	e8 d7 c2 ff ff       	call   801011d0 <filewrite>
80104ef9:	83 c4 10             	add    $0x10,%esp
}
80104efc:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104eff:	5b                   	pop    %ebx
80104f00:	5e                   	pop    %esi
80104f01:	5d                   	pop    %ebp
80104f02:	c3                   	ret    
80104f03:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104f07:	90                   	nop
    return -1;
80104f08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f0d:	eb ed                	jmp    80104efc <sys_write+0x6c>
80104f0f:	90                   	nop

80104f10 <sys_close>:
{
80104f10:	55                   	push   %ebp
80104f11:	89 e5                	mov    %esp,%ebp
80104f13:	56                   	push   %esi
80104f14:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80104f15:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80104f18:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
80104f1b:	50                   	push   %eax
80104f1c:	6a 00                	push   $0x0
80104f1e:	e8 1d fb ff ff       	call   80104a40 <argint>
80104f23:	83 c4 10             	add    $0x10,%esp
80104f26:	85 c0                	test   %eax,%eax
80104f28:	78 3e                	js     80104f68 <sys_close+0x58>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104f2a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104f2e:	77 38                	ja     80104f68 <sys_close+0x58>
80104f30:	e8 5b eb ff ff       	call   80103a90 <myproc>
80104f35:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f38:	8d 5a 08             	lea    0x8(%edx),%ebx
80104f3b:	8b 74 98 08          	mov    0x8(%eax,%ebx,4),%esi
80104f3f:	85 f6                	test   %esi,%esi
80104f41:	74 25                	je     80104f68 <sys_close+0x58>
  myproc()->ofile[fd] = 0;
80104f43:	e8 48 eb ff ff       	call   80103a90 <myproc>
  fileclose(f);
80104f48:	83 ec 0c             	sub    $0xc,%esp
  myproc()->ofile[fd] = 0;
80104f4b:	c7 44 98 08 00 00 00 	movl   $0x0,0x8(%eax,%ebx,4)
80104f52:	00 
  fileclose(f);
80104f53:	56                   	push   %esi
80104f54:	e8 b7 c0 ff ff       	call   80101010 <fileclose>
  return 0;
80104f59:	83 c4 10             	add    $0x10,%esp
80104f5c:	31 c0                	xor    %eax,%eax
}
80104f5e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104f61:	5b                   	pop    %ebx
80104f62:	5e                   	pop    %esi
80104f63:	5d                   	pop    %ebp
80104f64:	c3                   	ret    
80104f65:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80104f68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f6d:	eb ef                	jmp    80104f5e <sys_close+0x4e>
80104f6f:	90                   	nop

80104f70 <sys_fstat>:
{
80104f70:	55                   	push   %ebp
80104f71:	89 e5                	mov    %esp,%ebp
80104f73:	56                   	push   %esi
80104f74:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80104f75:	8d 5d f4             	lea    -0xc(%ebp),%ebx
{
80104f78:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
80104f7b:	53                   	push   %ebx
80104f7c:	6a 00                	push   $0x0
80104f7e:	e8 bd fa ff ff       	call   80104a40 <argint>
80104f83:	83 c4 10             	add    $0x10,%esp
80104f86:	85 c0                	test   %eax,%eax
80104f88:	78 46                	js     80104fd0 <sys_fstat+0x60>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104f8a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104f8e:	77 40                	ja     80104fd0 <sys_fstat+0x60>
80104f90:	e8 fb ea ff ff       	call   80103a90 <myproc>
80104f95:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f98:	8b 74 90 28          	mov    0x28(%eax,%edx,4),%esi
80104f9c:	85 f6                	test   %esi,%esi
80104f9e:	74 30                	je     80104fd0 <sys_fstat+0x60>
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80104fa0:	83 ec 04             	sub    $0x4,%esp
80104fa3:	6a 14                	push   $0x14
80104fa5:	53                   	push   %ebx
80104fa6:	6a 01                	push   $0x1
80104fa8:	e8 e3 fa ff ff       	call   80104a90 <argptr>
80104fad:	83 c4 10             	add    $0x10,%esp
80104fb0:	85 c0                	test   %eax,%eax
80104fb2:	78 1c                	js     80104fd0 <sys_fstat+0x60>
  return filestat(f, st);
80104fb4:	83 ec 08             	sub    $0x8,%esp
80104fb7:	ff 75 f4             	push   -0xc(%ebp)
80104fba:	56                   	push   %esi
80104fbb:	e8 30 c1 ff ff       	call   801010f0 <filestat>
80104fc0:	83 c4 10             	add    $0x10,%esp
}
80104fc3:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104fc6:	5b                   	pop    %ebx
80104fc7:	5e                   	pop    %esi
80104fc8:	5d                   	pop    %ebp
80104fc9:	c3                   	ret    
80104fca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
80104fd0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fd5:	eb ec                	jmp    80104fc3 <sys_fstat+0x53>
80104fd7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104fde:	66 90                	xchg   %ax,%ax

80104fe0 <sys_link>:
{
80104fe0:	55                   	push   %ebp
80104fe1:	89 e5                	mov    %esp,%ebp
80104fe3:	57                   	push   %edi
80104fe4:	56                   	push   %esi
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80104fe5:	8d 45 d4             	lea    -0x2c(%ebp),%eax
{
80104fe8:	53                   	push   %ebx
80104fe9:	83 ec 34             	sub    $0x34,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80104fec:	50                   	push   %eax
80104fed:	6a 00                	push   $0x0
80104fef:	e8 0c fb ff ff       	call   80104b00 <argstr>
80104ff4:	83 c4 10             	add    $0x10,%esp
80104ff7:	85 c0                	test   %eax,%eax
80104ff9:	0f 88 fb 00 00 00    	js     801050fa <sys_link+0x11a>
80104fff:	83 ec 08             	sub    $0x8,%esp
80105002:	8d 45 d0             	lea    -0x30(%ebp),%eax
80105005:	50                   	push   %eax
80105006:	6a 01                	push   $0x1
80105008:	e8 f3 fa ff ff       	call   80104b00 <argstr>
8010500d:	83 c4 10             	add    $0x10,%esp
80105010:	85 c0                	test   %eax,%eax
80105012:	0f 88 e2 00 00 00    	js     801050fa <sys_link+0x11a>
  begin_op();
80105018:	e8 63 de ff ff       	call   80102e80 <begin_op>
  if((ip = namei(old)) == 0){
8010501d:	83 ec 0c             	sub    $0xc,%esp
80105020:	ff 75 d4             	push   -0x2c(%ebp)
80105023:	e8 98 d1 ff ff       	call   801021c0 <namei>
80105028:	83 c4 10             	add    $0x10,%esp
8010502b:	89 c3                	mov    %eax,%ebx
8010502d:	85 c0                	test   %eax,%eax
8010502f:	0f 84 e4 00 00 00    	je     80105119 <sys_link+0x139>
  ilock(ip);
80105035:	83 ec 0c             	sub    $0xc,%esp
80105038:	50                   	push   %eax
80105039:	e8 62 c8 ff ff       	call   801018a0 <ilock>
  if(ip->type == T_DIR){
8010503e:	83 c4 10             	add    $0x10,%esp
80105041:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80105046:	0f 84 b5 00 00 00    	je     80105101 <sys_link+0x121>
  iupdate(ip);
8010504c:	83 ec 0c             	sub    $0xc,%esp
  ip->nlink++;
8010504f:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
  if((dp = nameiparent(new, name)) == 0)
80105054:	8d 7d da             	lea    -0x26(%ebp),%edi
  iupdate(ip);
80105057:	53                   	push   %ebx
80105058:	e8 93 c7 ff ff       	call   801017f0 <iupdate>
  iunlock(ip);
8010505d:	89 1c 24             	mov    %ebx,(%esp)
80105060:	e8 1b c9 ff ff       	call   80101980 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
80105065:	58                   	pop    %eax
80105066:	5a                   	pop    %edx
80105067:	57                   	push   %edi
80105068:	ff 75 d0             	push   -0x30(%ebp)
8010506b:	e8 70 d1 ff ff       	call   801021e0 <nameiparent>
80105070:	83 c4 10             	add    $0x10,%esp
80105073:	89 c6                	mov    %eax,%esi
80105075:	85 c0                	test   %eax,%eax
80105077:	74 5b                	je     801050d4 <sys_link+0xf4>
  ilock(dp);
80105079:	83 ec 0c             	sub    $0xc,%esp
8010507c:	50                   	push   %eax
8010507d:	e8 1e c8 ff ff       	call   801018a0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105082:	8b 03                	mov    (%ebx),%eax
80105084:	83 c4 10             	add    $0x10,%esp
80105087:	39 06                	cmp    %eax,(%esi)
80105089:	75 3d                	jne    801050c8 <sys_link+0xe8>
8010508b:	83 ec 04             	sub    $0x4,%esp
8010508e:	ff 73 04             	push   0x4(%ebx)
80105091:	57                   	push   %edi
80105092:	56                   	push   %esi
80105093:	e8 68 d0 ff ff       	call   80102100 <dirlink>
80105098:	83 c4 10             	add    $0x10,%esp
8010509b:	85 c0                	test   %eax,%eax
8010509d:	78 29                	js     801050c8 <sys_link+0xe8>
  iunlockput(dp);
8010509f:	83 ec 0c             	sub    $0xc,%esp
801050a2:	56                   	push   %esi
801050a3:	e8 88 ca ff ff       	call   80101b30 <iunlockput>
  iput(ip);
801050a8:	89 1c 24             	mov    %ebx,(%esp)
801050ab:	e8 20 c9 ff ff       	call   801019d0 <iput>
  end_op();
801050b0:	e8 3b de ff ff       	call   80102ef0 <end_op>
  return 0;
801050b5:	83 c4 10             	add    $0x10,%esp
801050b8:	31 c0                	xor    %eax,%eax
}
801050ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
801050bd:	5b                   	pop    %ebx
801050be:	5e                   	pop    %esi
801050bf:	5f                   	pop    %edi
801050c0:	5d                   	pop    %ebp
801050c1:	c3                   	ret    
801050c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    iunlockput(dp);
801050c8:	83 ec 0c             	sub    $0xc,%esp
801050cb:	56                   	push   %esi
801050cc:	e8 5f ca ff ff       	call   80101b30 <iunlockput>
    goto bad;
801050d1:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
801050d4:	83 ec 0c             	sub    $0xc,%esp
801050d7:	53                   	push   %ebx
801050d8:	e8 c3 c7 ff ff       	call   801018a0 <ilock>
  ip->nlink--;
801050dd:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
801050e2:	89 1c 24             	mov    %ebx,(%esp)
801050e5:	e8 06 c7 ff ff       	call   801017f0 <iupdate>
  iunlockput(ip);
801050ea:	89 1c 24             	mov    %ebx,(%esp)
801050ed:	e8 3e ca ff ff       	call   80101b30 <iunlockput>
  end_op();
801050f2:	e8 f9 dd ff ff       	call   80102ef0 <end_op>
  return -1;
801050f7:	83 c4 10             	add    $0x10,%esp
801050fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050ff:	eb b9                	jmp    801050ba <sys_link+0xda>
    iunlockput(ip);
80105101:	83 ec 0c             	sub    $0xc,%esp
80105104:	53                   	push   %ebx
80105105:	e8 26 ca ff ff       	call   80101b30 <iunlockput>
    end_op();
8010510a:	e8 e1 dd ff ff       	call   80102ef0 <end_op>
    return -1;
8010510f:	83 c4 10             	add    $0x10,%esp
80105112:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105117:	eb a1                	jmp    801050ba <sys_link+0xda>
    end_op();
80105119:	e8 d2 dd ff ff       	call   80102ef0 <end_op>
    return -1;
8010511e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105123:	eb 95                	jmp    801050ba <sys_link+0xda>
80105125:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010512c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105130 <sys_unlink>:
{
80105130:	55                   	push   %ebp
80105131:	89 e5                	mov    %esp,%ebp
80105133:	57                   	push   %edi
80105134:	56                   	push   %esi
  if(argstr(0, &path) < 0)
80105135:	8d 45 c0             	lea    -0x40(%ebp),%eax
{
80105138:	53                   	push   %ebx
80105139:	83 ec 54             	sub    $0x54,%esp
  if(argstr(0, &path) < 0)
8010513c:	50                   	push   %eax
8010513d:	6a 00                	push   $0x0
8010513f:	e8 bc f9 ff ff       	call   80104b00 <argstr>
80105144:	83 c4 10             	add    $0x10,%esp
80105147:	85 c0                	test   %eax,%eax
80105149:	0f 88 7a 01 00 00    	js     801052c9 <sys_unlink+0x199>
  begin_op();
8010514f:	e8 2c dd ff ff       	call   80102e80 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105154:	8d 5d ca             	lea    -0x36(%ebp),%ebx
80105157:	83 ec 08             	sub    $0x8,%esp
8010515a:	53                   	push   %ebx
8010515b:	ff 75 c0             	push   -0x40(%ebp)
8010515e:	e8 7d d0 ff ff       	call   801021e0 <nameiparent>
80105163:	83 c4 10             	add    $0x10,%esp
80105166:	89 45 b4             	mov    %eax,-0x4c(%ebp)
80105169:	85 c0                	test   %eax,%eax
8010516b:	0f 84 62 01 00 00    	je     801052d3 <sys_unlink+0x1a3>
  ilock(dp);
80105171:	8b 7d b4             	mov    -0x4c(%ebp),%edi
80105174:	83 ec 0c             	sub    $0xc,%esp
80105177:	57                   	push   %edi
80105178:	e8 23 c7 ff ff       	call   801018a0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010517d:	58                   	pop    %eax
8010517e:	5a                   	pop    %edx
8010517f:	68 38 7a 10 80       	push   $0x80107a38
80105184:	53                   	push   %ebx
80105185:	e8 56 cc ff ff       	call   80101de0 <namecmp>
8010518a:	83 c4 10             	add    $0x10,%esp
8010518d:	85 c0                	test   %eax,%eax
8010518f:	0f 84 fb 00 00 00    	je     80105290 <sys_unlink+0x160>
80105195:	83 ec 08             	sub    $0x8,%esp
80105198:	68 37 7a 10 80       	push   $0x80107a37
8010519d:	53                   	push   %ebx
8010519e:	e8 3d cc ff ff       	call   80101de0 <namecmp>
801051a3:	83 c4 10             	add    $0x10,%esp
801051a6:	85 c0                	test   %eax,%eax
801051a8:	0f 84 e2 00 00 00    	je     80105290 <sys_unlink+0x160>
  if((ip = dirlookup(dp, name, &off)) == 0)
801051ae:	83 ec 04             	sub    $0x4,%esp
801051b1:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801051b4:	50                   	push   %eax
801051b5:	53                   	push   %ebx
801051b6:	57                   	push   %edi
801051b7:	e8 44 cc ff ff       	call   80101e00 <dirlookup>
801051bc:	83 c4 10             	add    $0x10,%esp
801051bf:	89 c3                	mov    %eax,%ebx
801051c1:	85 c0                	test   %eax,%eax
801051c3:	0f 84 c7 00 00 00    	je     80105290 <sys_unlink+0x160>
  ilock(ip);
801051c9:	83 ec 0c             	sub    $0xc,%esp
801051cc:	50                   	push   %eax
801051cd:	e8 ce c6 ff ff       	call   801018a0 <ilock>
  if(ip->nlink < 1)
801051d2:	83 c4 10             	add    $0x10,%esp
801051d5:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801051da:	0f 8e 1c 01 00 00    	jle    801052fc <sys_unlink+0x1cc>
  if(ip->type == T_DIR && !isdirempty(ip)){
801051e0:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801051e5:	8d 7d d8             	lea    -0x28(%ebp),%edi
801051e8:	74 66                	je     80105250 <sys_unlink+0x120>
  memset(&de, 0, sizeof(de));
801051ea:	83 ec 04             	sub    $0x4,%esp
801051ed:	6a 10                	push   $0x10
801051ef:	6a 00                	push   $0x0
801051f1:	57                   	push   %edi
801051f2:	e8 89 f5 ff ff       	call   80104780 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801051f7:	6a 10                	push   $0x10
801051f9:	ff 75 c4             	push   -0x3c(%ebp)
801051fc:	57                   	push   %edi
801051fd:	ff 75 b4             	push   -0x4c(%ebp)
80105200:	e8 ab ca ff ff       	call   80101cb0 <writei>
80105205:	83 c4 20             	add    $0x20,%esp
80105208:	83 f8 10             	cmp    $0x10,%eax
8010520b:	0f 85 de 00 00 00    	jne    801052ef <sys_unlink+0x1bf>
  if(ip->type == T_DIR){
80105211:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80105216:	0f 84 94 00 00 00    	je     801052b0 <sys_unlink+0x180>
  iunlockput(dp);
8010521c:	83 ec 0c             	sub    $0xc,%esp
8010521f:	ff 75 b4             	push   -0x4c(%ebp)
80105222:	e8 09 c9 ff ff       	call   80101b30 <iunlockput>
  ip->nlink--;
80105227:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
8010522c:	89 1c 24             	mov    %ebx,(%esp)
8010522f:	e8 bc c5 ff ff       	call   801017f0 <iupdate>
  iunlockput(ip);
80105234:	89 1c 24             	mov    %ebx,(%esp)
80105237:	e8 f4 c8 ff ff       	call   80101b30 <iunlockput>
  end_op();
8010523c:	e8 af dc ff ff       	call   80102ef0 <end_op>
  return 0;
80105241:	83 c4 10             	add    $0x10,%esp
80105244:	31 c0                	xor    %eax,%eax
}
80105246:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105249:	5b                   	pop    %ebx
8010524a:	5e                   	pop    %esi
8010524b:	5f                   	pop    %edi
8010524c:	5d                   	pop    %ebp
8010524d:	c3                   	ret    
8010524e:	66 90                	xchg   %ax,%ax
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105250:	83 7b 58 20          	cmpl   $0x20,0x58(%ebx)
80105254:	76 94                	jbe    801051ea <sys_unlink+0xba>
80105256:	be 20 00 00 00       	mov    $0x20,%esi
8010525b:	eb 0b                	jmp    80105268 <sys_unlink+0x138>
8010525d:	8d 76 00             	lea    0x0(%esi),%esi
80105260:	83 c6 10             	add    $0x10,%esi
80105263:	3b 73 58             	cmp    0x58(%ebx),%esi
80105266:	73 82                	jae    801051ea <sys_unlink+0xba>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105268:	6a 10                	push   $0x10
8010526a:	56                   	push   %esi
8010526b:	57                   	push   %edi
8010526c:	53                   	push   %ebx
8010526d:	e8 3e c9 ff ff       	call   80101bb0 <readi>
80105272:	83 c4 10             	add    $0x10,%esp
80105275:	83 f8 10             	cmp    $0x10,%eax
80105278:	75 68                	jne    801052e2 <sys_unlink+0x1b2>
    if(de.inum != 0)
8010527a:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
8010527f:	74 df                	je     80105260 <sys_unlink+0x130>
    iunlockput(ip);
80105281:	83 ec 0c             	sub    $0xc,%esp
80105284:	53                   	push   %ebx
80105285:	e8 a6 c8 ff ff       	call   80101b30 <iunlockput>
    goto bad;
8010528a:	83 c4 10             	add    $0x10,%esp
8010528d:	8d 76 00             	lea    0x0(%esi),%esi
  iunlockput(dp);
80105290:	83 ec 0c             	sub    $0xc,%esp
80105293:	ff 75 b4             	push   -0x4c(%ebp)
80105296:	e8 95 c8 ff ff       	call   80101b30 <iunlockput>
  end_op();
8010529b:	e8 50 dc ff ff       	call   80102ef0 <end_op>
  return -1;
801052a0:	83 c4 10             	add    $0x10,%esp
801052a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052a8:	eb 9c                	jmp    80105246 <sys_unlink+0x116>
801052aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    dp->nlink--;
801052b0:	8b 45 b4             	mov    -0x4c(%ebp),%eax
    iupdate(dp);
801052b3:	83 ec 0c             	sub    $0xc,%esp
    dp->nlink--;
801052b6:	66 83 68 56 01       	subw   $0x1,0x56(%eax)
    iupdate(dp);
801052bb:	50                   	push   %eax
801052bc:	e8 2f c5 ff ff       	call   801017f0 <iupdate>
801052c1:	83 c4 10             	add    $0x10,%esp
801052c4:	e9 53 ff ff ff       	jmp    8010521c <sys_unlink+0xec>
    return -1;
801052c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052ce:	e9 73 ff ff ff       	jmp    80105246 <sys_unlink+0x116>
    end_op();
801052d3:	e8 18 dc ff ff       	call   80102ef0 <end_op>
    return -1;
801052d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052dd:	e9 64 ff ff ff       	jmp    80105246 <sys_unlink+0x116>
      panic("isdirempty: readi");
801052e2:	83 ec 0c             	sub    $0xc,%esp
801052e5:	68 5c 7a 10 80       	push   $0x80107a5c
801052ea:	e8 91 b0 ff ff       	call   80100380 <panic>
    panic("unlink: writei");
801052ef:	83 ec 0c             	sub    $0xc,%esp
801052f2:	68 6e 7a 10 80       	push   $0x80107a6e
801052f7:	e8 84 b0 ff ff       	call   80100380 <panic>
    panic("unlink: nlink < 1");
801052fc:	83 ec 0c             	sub    $0xc,%esp
801052ff:	68 4a 7a 10 80       	push   $0x80107a4a
80105304:	e8 77 b0 ff ff       	call   80100380 <panic>
80105309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105310 <sys_open>:

int
sys_open(void)
{
80105310:	55                   	push   %ebp
80105311:	89 e5                	mov    %esp,%ebp
80105313:	57                   	push   %edi
80105314:	56                   	push   %esi
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105315:	8d 45 e0             	lea    -0x20(%ebp),%eax
{
80105318:	53                   	push   %ebx
80105319:	83 ec 24             	sub    $0x24,%esp
  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010531c:	50                   	push   %eax
8010531d:	6a 00                	push   $0x0
8010531f:	e8 dc f7 ff ff       	call   80104b00 <argstr>
80105324:	83 c4 10             	add    $0x10,%esp
80105327:	85 c0                	test   %eax,%eax
80105329:	0f 88 8e 00 00 00    	js     801053bd <sys_open+0xad>
8010532f:	83 ec 08             	sub    $0x8,%esp
80105332:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105335:	50                   	push   %eax
80105336:	6a 01                	push   $0x1
80105338:	e8 03 f7 ff ff       	call   80104a40 <argint>
8010533d:	83 c4 10             	add    $0x10,%esp
80105340:	85 c0                	test   %eax,%eax
80105342:	78 79                	js     801053bd <sys_open+0xad>
    return -1;

  begin_op();
80105344:	e8 37 db ff ff       	call   80102e80 <begin_op>

  if(omode & O_CREATE){
80105349:	f6 45 e5 02          	testb  $0x2,-0x1b(%ebp)
8010534d:	75 79                	jne    801053c8 <sys_open+0xb8>
    if(ip == 0){
      end_op();
      return -1;
    }
  } else {
    if((ip = namei(path)) == 0){
8010534f:	83 ec 0c             	sub    $0xc,%esp
80105352:	ff 75 e0             	push   -0x20(%ebp)
80105355:	e8 66 ce ff ff       	call   801021c0 <namei>
8010535a:	83 c4 10             	add    $0x10,%esp
8010535d:	89 c6                	mov    %eax,%esi
8010535f:	85 c0                	test   %eax,%eax
80105361:	0f 84 7e 00 00 00    	je     801053e5 <sys_open+0xd5>
      end_op();
      return -1;
    }
    ilock(ip);
80105367:	83 ec 0c             	sub    $0xc,%esp
8010536a:	50                   	push   %eax
8010536b:	e8 30 c5 ff ff       	call   801018a0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80105370:	83 c4 10             	add    $0x10,%esp
80105373:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80105378:	0f 84 c2 00 00 00    	je     80105440 <sys_open+0x130>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010537e:	e8 cd bb ff ff       	call   80100f50 <filealloc>
80105383:	89 c7                	mov    %eax,%edi
80105385:	85 c0                	test   %eax,%eax
80105387:	74 23                	je     801053ac <sys_open+0x9c>
  struct proc *curproc = myproc();
80105389:	e8 02 e7 ff ff       	call   80103a90 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
8010538e:	31 db                	xor    %ebx,%ebx
    if(curproc->ofile[fd] == 0){
80105390:	8b 54 98 28          	mov    0x28(%eax,%ebx,4),%edx
80105394:	85 d2                	test   %edx,%edx
80105396:	74 60                	je     801053f8 <sys_open+0xe8>
  for(fd = 0; fd < NOFILE; fd++){
80105398:	83 c3 01             	add    $0x1,%ebx
8010539b:	83 fb 10             	cmp    $0x10,%ebx
8010539e:	75 f0                	jne    80105390 <sys_open+0x80>
    if(f)
      fileclose(f);
801053a0:	83 ec 0c             	sub    $0xc,%esp
801053a3:	57                   	push   %edi
801053a4:	e8 67 bc ff ff       	call   80101010 <fileclose>
801053a9:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801053ac:	83 ec 0c             	sub    $0xc,%esp
801053af:	56                   	push   %esi
801053b0:	e8 7b c7 ff ff       	call   80101b30 <iunlockput>
    end_op();
801053b5:	e8 36 db ff ff       	call   80102ef0 <end_op>
    return -1;
801053ba:	83 c4 10             	add    $0x10,%esp
801053bd:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801053c2:	eb 6d                	jmp    80105431 <sys_open+0x121>
801053c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    ip = create(path, T_FILE, 0, 0);
801053c8:	83 ec 0c             	sub    $0xc,%esp
801053cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801053ce:	31 c9                	xor    %ecx,%ecx
801053d0:	ba 02 00 00 00       	mov    $0x2,%edx
801053d5:	6a 00                	push   $0x0
801053d7:	e8 14 f8 ff ff       	call   80104bf0 <create>
    if(ip == 0){
801053dc:	83 c4 10             	add    $0x10,%esp
    ip = create(path, T_FILE, 0, 0);
801053df:	89 c6                	mov    %eax,%esi
    if(ip == 0){
801053e1:	85 c0                	test   %eax,%eax
801053e3:	75 99                	jne    8010537e <sys_open+0x6e>
      end_op();
801053e5:	e8 06 db ff ff       	call   80102ef0 <end_op>
      return -1;
801053ea:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801053ef:	eb 40                	jmp    80105431 <sys_open+0x121>
801053f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  }
  iunlock(ip);
801053f8:	83 ec 0c             	sub    $0xc,%esp
      curproc->ofile[fd] = f;
801053fb:	89 7c 98 28          	mov    %edi,0x28(%eax,%ebx,4)
  iunlock(ip);
801053ff:	56                   	push   %esi
80105400:	e8 7b c5 ff ff       	call   80101980 <iunlock>
  end_op();
80105405:	e8 e6 da ff ff       	call   80102ef0 <end_op>

  f->type = FD_INODE;
8010540a:	c7 07 02 00 00 00    	movl   $0x2,(%edi)
  f->ip = ip;
  f->off = 0;
  f->readable = !(omode & O_WRONLY);
80105410:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105413:	83 c4 10             	add    $0x10,%esp
  f->ip = ip;
80105416:	89 77 10             	mov    %esi,0x10(%edi)
  f->readable = !(omode & O_WRONLY);
80105419:	89 d0                	mov    %edx,%eax
  f->off = 0;
8010541b:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)
  f->readable = !(omode & O_WRONLY);
80105422:	f7 d0                	not    %eax
80105424:	83 e0 01             	and    $0x1,%eax
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105427:	83 e2 03             	and    $0x3,%edx
  f->readable = !(omode & O_WRONLY);
8010542a:	88 47 08             	mov    %al,0x8(%edi)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010542d:	0f 95 47 09          	setne  0x9(%edi)
  return fd;
}
80105431:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105434:	89 d8                	mov    %ebx,%eax
80105436:	5b                   	pop    %ebx
80105437:	5e                   	pop    %esi
80105438:	5f                   	pop    %edi
80105439:	5d                   	pop    %ebp
8010543a:	c3                   	ret    
8010543b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010543f:	90                   	nop
    if(ip->type == T_DIR && omode != O_RDONLY){
80105440:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80105443:	85 c9                	test   %ecx,%ecx
80105445:	0f 84 33 ff ff ff    	je     8010537e <sys_open+0x6e>
8010544b:	e9 5c ff ff ff       	jmp    801053ac <sys_open+0x9c>

80105450 <sys_mkdir>:

int
sys_mkdir(void)
{
80105450:	55                   	push   %ebp
80105451:	89 e5                	mov    %esp,%ebp
80105453:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105456:	e8 25 da ff ff       	call   80102e80 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010545b:	83 ec 08             	sub    $0x8,%esp
8010545e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105461:	50                   	push   %eax
80105462:	6a 00                	push   $0x0
80105464:	e8 97 f6 ff ff       	call   80104b00 <argstr>
80105469:	83 c4 10             	add    $0x10,%esp
8010546c:	85 c0                	test   %eax,%eax
8010546e:	78 30                	js     801054a0 <sys_mkdir+0x50>
80105470:	83 ec 0c             	sub    $0xc,%esp
80105473:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105476:	31 c9                	xor    %ecx,%ecx
80105478:	ba 01 00 00 00       	mov    $0x1,%edx
8010547d:	6a 00                	push   $0x0
8010547f:	e8 6c f7 ff ff       	call   80104bf0 <create>
80105484:	83 c4 10             	add    $0x10,%esp
80105487:	85 c0                	test   %eax,%eax
80105489:	74 15                	je     801054a0 <sys_mkdir+0x50>
    end_op();
    return -1;
  }
  iunlockput(ip);
8010548b:	83 ec 0c             	sub    $0xc,%esp
8010548e:	50                   	push   %eax
8010548f:	e8 9c c6 ff ff       	call   80101b30 <iunlockput>
  end_op();
80105494:	e8 57 da ff ff       	call   80102ef0 <end_op>
  return 0;
80105499:	83 c4 10             	add    $0x10,%esp
8010549c:	31 c0                	xor    %eax,%eax
}
8010549e:	c9                   	leave  
8010549f:	c3                   	ret    
    end_op();
801054a0:	e8 4b da ff ff       	call   80102ef0 <end_op>
    return -1;
801054a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801054aa:	c9                   	leave  
801054ab:	c3                   	ret    
801054ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801054b0 <sys_mknod>:

int
sys_mknod(void)
{
801054b0:	55                   	push   %ebp
801054b1:	89 e5                	mov    %esp,%ebp
801054b3:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
801054b6:	e8 c5 d9 ff ff       	call   80102e80 <begin_op>
  if((argstr(0, &path)) < 0 ||
801054bb:	83 ec 08             	sub    $0x8,%esp
801054be:	8d 45 ec             	lea    -0x14(%ebp),%eax
801054c1:	50                   	push   %eax
801054c2:	6a 00                	push   $0x0
801054c4:	e8 37 f6 ff ff       	call   80104b00 <argstr>
801054c9:	83 c4 10             	add    $0x10,%esp
801054cc:	85 c0                	test   %eax,%eax
801054ce:	78 60                	js     80105530 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
801054d0:	83 ec 08             	sub    $0x8,%esp
801054d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054d6:	50                   	push   %eax
801054d7:	6a 01                	push   $0x1
801054d9:	e8 62 f5 ff ff       	call   80104a40 <argint>
  if((argstr(0, &path)) < 0 ||
801054de:	83 c4 10             	add    $0x10,%esp
801054e1:	85 c0                	test   %eax,%eax
801054e3:	78 4b                	js     80105530 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
801054e5:	83 ec 08             	sub    $0x8,%esp
801054e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801054eb:	50                   	push   %eax
801054ec:	6a 02                	push   $0x2
801054ee:	e8 4d f5 ff ff       	call   80104a40 <argint>
     argint(1, &major) < 0 ||
801054f3:	83 c4 10             	add    $0x10,%esp
801054f6:	85 c0                	test   %eax,%eax
801054f8:	78 36                	js     80105530 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
801054fa:	0f bf 45 f4          	movswl -0xc(%ebp),%eax
801054fe:	83 ec 0c             	sub    $0xc,%esp
80105501:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
80105505:	ba 03 00 00 00       	mov    $0x3,%edx
8010550a:	50                   	push   %eax
8010550b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010550e:	e8 dd f6 ff ff       	call   80104bf0 <create>
     argint(2, &minor) < 0 ||
80105513:	83 c4 10             	add    $0x10,%esp
80105516:	85 c0                	test   %eax,%eax
80105518:	74 16                	je     80105530 <sys_mknod+0x80>
    end_op();
    return -1;
  }
  iunlockput(ip);
8010551a:	83 ec 0c             	sub    $0xc,%esp
8010551d:	50                   	push   %eax
8010551e:	e8 0d c6 ff ff       	call   80101b30 <iunlockput>
  end_op();
80105523:	e8 c8 d9 ff ff       	call   80102ef0 <end_op>
  return 0;
80105528:	83 c4 10             	add    $0x10,%esp
8010552b:	31 c0                	xor    %eax,%eax
}
8010552d:	c9                   	leave  
8010552e:	c3                   	ret    
8010552f:	90                   	nop
    end_op();
80105530:	e8 bb d9 ff ff       	call   80102ef0 <end_op>
    return -1;
80105535:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010553a:	c9                   	leave  
8010553b:	c3                   	ret    
8010553c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105540 <sys_chdir>:

int
sys_chdir(void)
{
80105540:	55                   	push   %ebp
80105541:	89 e5                	mov    %esp,%ebp
80105543:	56                   	push   %esi
80105544:	53                   	push   %ebx
80105545:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105548:	e8 43 e5 ff ff       	call   80103a90 <myproc>
8010554d:	89 c6                	mov    %eax,%esi
  
  begin_op();
8010554f:	e8 2c d9 ff ff       	call   80102e80 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105554:	83 ec 08             	sub    $0x8,%esp
80105557:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010555a:	50                   	push   %eax
8010555b:	6a 00                	push   $0x0
8010555d:	e8 9e f5 ff ff       	call   80104b00 <argstr>
80105562:	83 c4 10             	add    $0x10,%esp
80105565:	85 c0                	test   %eax,%eax
80105567:	78 77                	js     801055e0 <sys_chdir+0xa0>
80105569:	83 ec 0c             	sub    $0xc,%esp
8010556c:	ff 75 f4             	push   -0xc(%ebp)
8010556f:	e8 4c cc ff ff       	call   801021c0 <namei>
80105574:	83 c4 10             	add    $0x10,%esp
80105577:	89 c3                	mov    %eax,%ebx
80105579:	85 c0                	test   %eax,%eax
8010557b:	74 63                	je     801055e0 <sys_chdir+0xa0>
    end_op();
    return -1;
  }
  ilock(ip);
8010557d:	83 ec 0c             	sub    $0xc,%esp
80105580:	50                   	push   %eax
80105581:	e8 1a c3 ff ff       	call   801018a0 <ilock>
  if(ip->type != T_DIR){
80105586:	83 c4 10             	add    $0x10,%esp
80105589:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010558e:	75 30                	jne    801055c0 <sys_chdir+0x80>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80105590:	83 ec 0c             	sub    $0xc,%esp
80105593:	53                   	push   %ebx
80105594:	e8 e7 c3 ff ff       	call   80101980 <iunlock>
  iput(curproc->cwd);
80105599:	58                   	pop    %eax
8010559a:	ff 76 68             	push   0x68(%esi)
8010559d:	e8 2e c4 ff ff       	call   801019d0 <iput>
  end_op();
801055a2:	e8 49 d9 ff ff       	call   80102ef0 <end_op>
  curproc->cwd = ip;
801055a7:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
801055aa:	83 c4 10             	add    $0x10,%esp
801055ad:	31 c0                	xor    %eax,%eax
}
801055af:	8d 65 f8             	lea    -0x8(%ebp),%esp
801055b2:	5b                   	pop    %ebx
801055b3:	5e                   	pop    %esi
801055b4:	5d                   	pop    %ebp
801055b5:	c3                   	ret    
801055b6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801055bd:	8d 76 00             	lea    0x0(%esi),%esi
    iunlockput(ip);
801055c0:	83 ec 0c             	sub    $0xc,%esp
801055c3:	53                   	push   %ebx
801055c4:	e8 67 c5 ff ff       	call   80101b30 <iunlockput>
    end_op();
801055c9:	e8 22 d9 ff ff       	call   80102ef0 <end_op>
    return -1;
801055ce:	83 c4 10             	add    $0x10,%esp
801055d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055d6:	eb d7                	jmp    801055af <sys_chdir+0x6f>
801055d8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801055df:	90                   	nop
    end_op();
801055e0:	e8 0b d9 ff ff       	call   80102ef0 <end_op>
    return -1;
801055e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055ea:	eb c3                	jmp    801055af <sys_chdir+0x6f>
801055ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801055f0 <sys_exec>:

int
sys_exec(void)
{
801055f0:	55                   	push   %ebp
801055f1:	89 e5                	mov    %esp,%ebp
801055f3:	57                   	push   %edi
801055f4:	56                   	push   %esi
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801055f5:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
{
801055fb:	53                   	push   %ebx
801055fc:	81 ec a4 00 00 00    	sub    $0xa4,%esp
  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105602:	50                   	push   %eax
80105603:	6a 00                	push   $0x0
80105605:	e8 f6 f4 ff ff       	call   80104b00 <argstr>
8010560a:	83 c4 10             	add    $0x10,%esp
8010560d:	85 c0                	test   %eax,%eax
8010560f:	0f 88 87 00 00 00    	js     8010569c <sys_exec+0xac>
80105615:	83 ec 08             	sub    $0x8,%esp
80105618:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
8010561e:	50                   	push   %eax
8010561f:	6a 01                	push   $0x1
80105621:	e8 1a f4 ff ff       	call   80104a40 <argint>
80105626:	83 c4 10             	add    $0x10,%esp
80105629:	85 c0                	test   %eax,%eax
8010562b:	78 6f                	js     8010569c <sys_exec+0xac>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
8010562d:	83 ec 04             	sub    $0x4,%esp
80105630:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
  for(i=0;; i++){
80105636:	31 db                	xor    %ebx,%ebx
  memset(argv, 0, sizeof(argv));
80105638:	68 80 00 00 00       	push   $0x80
8010563d:	6a 00                	push   $0x0
8010563f:	56                   	push   %esi
80105640:	e8 3b f1 ff ff       	call   80104780 <memset>
80105645:	83 c4 10             	add    $0x10,%esp
80105648:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010564f:	90                   	nop
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105650:	83 ec 08             	sub    $0x8,%esp
80105653:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
80105659:	8d 3c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%edi
80105660:	50                   	push   %eax
80105661:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
80105667:	01 f8                	add    %edi,%eax
80105669:	50                   	push   %eax
8010566a:	e8 41 f3 ff ff       	call   801049b0 <fetchint>
8010566f:	83 c4 10             	add    $0x10,%esp
80105672:	85 c0                	test   %eax,%eax
80105674:	78 26                	js     8010569c <sys_exec+0xac>
      return -1;
    if(uarg == 0){
80105676:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
8010567c:	85 c0                	test   %eax,%eax
8010567e:	74 30                	je     801056b0 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80105680:	83 ec 08             	sub    $0x8,%esp
80105683:	8d 14 3e             	lea    (%esi,%edi,1),%edx
80105686:	52                   	push   %edx
80105687:	50                   	push   %eax
80105688:	e8 63 f3 ff ff       	call   801049f0 <fetchstr>
8010568d:	83 c4 10             	add    $0x10,%esp
80105690:	85 c0                	test   %eax,%eax
80105692:	78 08                	js     8010569c <sys_exec+0xac>
  for(i=0;; i++){
80105694:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80105697:	83 fb 20             	cmp    $0x20,%ebx
8010569a:	75 b4                	jne    80105650 <sys_exec+0x60>
      return -1;
  }
  return exec(path, argv);
}
8010569c:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return -1;
8010569f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801056a4:	5b                   	pop    %ebx
801056a5:	5e                   	pop    %esi
801056a6:	5f                   	pop    %edi
801056a7:	5d                   	pop    %ebp
801056a8:	c3                   	ret    
801056a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      argv[i] = 0;
801056b0:	c7 84 9d 68 ff ff ff 	movl   $0x0,-0x98(%ebp,%ebx,4)
801056b7:	00 00 00 00 
  return exec(path, argv);
801056bb:	83 ec 08             	sub    $0x8,%esp
801056be:	56                   	push   %esi
801056bf:	ff b5 5c ff ff ff    	push   -0xa4(%ebp)
801056c5:	e8 46 b4 ff ff       	call   80100b10 <exec>
801056ca:	83 c4 10             	add    $0x10,%esp
}
801056cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
801056d0:	5b                   	pop    %ebx
801056d1:	5e                   	pop    %esi
801056d2:	5f                   	pop    %edi
801056d3:	5d                   	pop    %ebp
801056d4:	c3                   	ret    
801056d5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801056dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801056e0 <sys_pipe>:

int
sys_pipe(void)
{
801056e0:	55                   	push   %ebp
801056e1:	89 e5                	mov    %esp,%ebp
801056e3:	57                   	push   %edi
801056e4:	56                   	push   %esi
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801056e5:	8d 45 dc             	lea    -0x24(%ebp),%eax
{
801056e8:	53                   	push   %ebx
801056e9:	83 ec 20             	sub    $0x20,%esp
  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801056ec:	6a 08                	push   $0x8
801056ee:	50                   	push   %eax
801056ef:	6a 00                	push   $0x0
801056f1:	e8 9a f3 ff ff       	call   80104a90 <argptr>
801056f6:	83 c4 10             	add    $0x10,%esp
801056f9:	85 c0                	test   %eax,%eax
801056fb:	78 4a                	js     80105747 <sys_pipe+0x67>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
801056fd:	83 ec 08             	sub    $0x8,%esp
80105700:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105703:	50                   	push   %eax
80105704:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105707:	50                   	push   %eax
80105708:	e8 43 de ff ff       	call   80103550 <pipealloc>
8010570d:	83 c4 10             	add    $0x10,%esp
80105710:	85 c0                	test   %eax,%eax
80105712:	78 33                	js     80105747 <sys_pipe+0x67>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105714:	8b 7d e0             	mov    -0x20(%ebp),%edi
  for(fd = 0; fd < NOFILE; fd++){
80105717:	31 db                	xor    %ebx,%ebx
  struct proc *curproc = myproc();
80105719:	e8 72 e3 ff ff       	call   80103a90 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
8010571e:	66 90                	xchg   %ax,%ax
    if(curproc->ofile[fd] == 0){
80105720:	8b 74 98 28          	mov    0x28(%eax,%ebx,4),%esi
80105724:	85 f6                	test   %esi,%esi
80105726:	74 28                	je     80105750 <sys_pipe+0x70>
  for(fd = 0; fd < NOFILE; fd++){
80105728:	83 c3 01             	add    $0x1,%ebx
8010572b:	83 fb 10             	cmp    $0x10,%ebx
8010572e:	75 f0                	jne    80105720 <sys_pipe+0x40>
    if(fd0 >= 0)
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
80105730:	83 ec 0c             	sub    $0xc,%esp
80105733:	ff 75 e0             	push   -0x20(%ebp)
80105736:	e8 d5 b8 ff ff       	call   80101010 <fileclose>
    fileclose(wf);
8010573b:	58                   	pop    %eax
8010573c:	ff 75 e4             	push   -0x1c(%ebp)
8010573f:	e8 cc b8 ff ff       	call   80101010 <fileclose>
    return -1;
80105744:	83 c4 10             	add    $0x10,%esp
80105747:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010574c:	eb 53                	jmp    801057a1 <sys_pipe+0xc1>
8010574e:	66 90                	xchg   %ax,%ax
      curproc->ofile[fd] = f;
80105750:	8d 73 08             	lea    0x8(%ebx),%esi
80105753:	89 7c b0 08          	mov    %edi,0x8(%eax,%esi,4)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105757:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  struct proc *curproc = myproc();
8010575a:	e8 31 e3 ff ff       	call   80103a90 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
8010575f:	31 d2                	xor    %edx,%edx
80105761:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(curproc->ofile[fd] == 0){
80105768:	8b 4c 90 28          	mov    0x28(%eax,%edx,4),%ecx
8010576c:	85 c9                	test   %ecx,%ecx
8010576e:	74 20                	je     80105790 <sys_pipe+0xb0>
  for(fd = 0; fd < NOFILE; fd++){
80105770:	83 c2 01             	add    $0x1,%edx
80105773:	83 fa 10             	cmp    $0x10,%edx
80105776:	75 f0                	jne    80105768 <sys_pipe+0x88>
      myproc()->ofile[fd0] = 0;
80105778:	e8 13 e3 ff ff       	call   80103a90 <myproc>
8010577d:	c7 44 b0 08 00 00 00 	movl   $0x0,0x8(%eax,%esi,4)
80105784:	00 
80105785:	eb a9                	jmp    80105730 <sys_pipe+0x50>
80105787:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010578e:	66 90                	xchg   %ax,%ax
      curproc->ofile[fd] = f;
80105790:	89 7c 90 28          	mov    %edi,0x28(%eax,%edx,4)
  }
  fd[0] = fd0;
80105794:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105797:	89 18                	mov    %ebx,(%eax)
  fd[1] = fd1;
80105799:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010579c:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
8010579f:	31 c0                	xor    %eax,%eax
}
801057a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801057a4:	5b                   	pop    %ebx
801057a5:	5e                   	pop    %esi
801057a6:	5f                   	pop    %edi
801057a7:	5d                   	pop    %ebp
801057a8:	c3                   	ret    
801057a9:	66 90                	xchg   %ax,%ax
801057ab:	66 90                	xchg   %ax,%ax
801057ad:	66 90                	xchg   %ax,%ax
801057af:	90                   	nop

801057b0 <sys_fork>:
#include "proc.h"

int
sys_fork(void)
{
  return fork();
801057b0:	e9 7b e4 ff ff       	jmp    80103c30 <fork>
801057b5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801057bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801057c0 <sys_exit>:
}

int
sys_exit(void)
{
801057c0:	55                   	push   %ebp
801057c1:	89 e5                	mov    %esp,%ebp
801057c3:	83 ec 08             	sub    $0x8,%esp
  exit();
801057c6:	e8 e5 e6 ff ff       	call   80103eb0 <exit>
  return 0;  // not reached
}
801057cb:	31 c0                	xor    %eax,%eax
801057cd:	c9                   	leave  
801057ce:	c3                   	ret    
801057cf:	90                   	nop

801057d0 <sys_wait>:

int
sys_wait(void)
{
  return wait();
801057d0:	e9 0b e8 ff ff       	jmp    80103fe0 <wait>
801057d5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801057dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801057e0 <sys_kill>:
}

int
sys_kill(void)
{
801057e0:	55                   	push   %ebp
801057e1:	89 e5                	mov    %esp,%ebp
801057e3:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
801057e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801057e9:	50                   	push   %eax
801057ea:	6a 00                	push   $0x0
801057ec:	e8 4f f2 ff ff       	call   80104a40 <argint>
801057f1:	83 c4 10             	add    $0x10,%esp
801057f4:	85 c0                	test   %eax,%eax
801057f6:	78 18                	js     80105810 <sys_kill+0x30>
    return -1;
  return kill(pid);
801057f8:	83 ec 0c             	sub    $0xc,%esp
801057fb:	ff 75 f4             	push   -0xc(%ebp)
801057fe:	e8 7d ea ff ff       	call   80104280 <kill>
80105803:	83 c4 10             	add    $0x10,%esp
}
80105806:	c9                   	leave  
80105807:	c3                   	ret    
80105808:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010580f:	90                   	nop
80105810:	c9                   	leave  
    return -1;
80105811:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105816:	c3                   	ret    
80105817:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010581e:	66 90                	xchg   %ax,%ax

80105820 <sys_getpid>:

int
sys_getpid(void)
{
80105820:	55                   	push   %ebp
80105821:	89 e5                	mov    %esp,%ebp
80105823:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105826:	e8 65 e2 ff ff       	call   80103a90 <myproc>
8010582b:	8b 40 10             	mov    0x10(%eax),%eax
}
8010582e:	c9                   	leave  
8010582f:	c3                   	ret    

80105830 <sys_sbrk>:

int
sys_sbrk(void)
{
80105830:	55                   	push   %ebp
80105831:	89 e5                	mov    %esp,%ebp
80105833:	53                   	push   %ebx
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105834:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105837:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
8010583a:	50                   	push   %eax
8010583b:	6a 00                	push   $0x0
8010583d:	e8 fe f1 ff ff       	call   80104a40 <argint>
80105842:	83 c4 10             	add    $0x10,%esp
80105845:	85 c0                	test   %eax,%eax
80105847:	78 27                	js     80105870 <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80105849:	e8 42 e2 ff ff       	call   80103a90 <myproc>
  if(growproc(n) < 0)
8010584e:	83 ec 0c             	sub    $0xc,%esp
  addr = myproc()->sz;
80105851:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80105853:	ff 75 f4             	push   -0xc(%ebp)
80105856:	e8 55 e3 ff ff       	call   80103bb0 <growproc>
8010585b:	83 c4 10             	add    $0x10,%esp
8010585e:	85 c0                	test   %eax,%eax
80105860:	78 0e                	js     80105870 <sys_sbrk+0x40>
    return -1;
  return addr;
}
80105862:	89 d8                	mov    %ebx,%eax
80105864:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105867:	c9                   	leave  
80105868:	c3                   	ret    
80105869:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80105870:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105875:	eb eb                	jmp    80105862 <sys_sbrk+0x32>
80105877:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010587e:	66 90                	xchg   %ax,%ax

80105880 <sys_sleep>:

int
sys_sleep(void)
{
80105880:	55                   	push   %ebp
80105881:	89 e5                	mov    %esp,%ebp
80105883:	53                   	push   %ebx
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105884:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105887:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
8010588a:	50                   	push   %eax
8010588b:	6a 00                	push   $0x0
8010588d:	e8 ae f1 ff ff       	call   80104a40 <argint>
80105892:	83 c4 10             	add    $0x10,%esp
80105895:	85 c0                	test   %eax,%eax
80105897:	0f 88 8a 00 00 00    	js     80105927 <sys_sleep+0xa7>
    return -1;
  acquire(&tickslock);
8010589d:	83 ec 0c             	sub    $0xc,%esp
801058a0:	68 c0 3c 11 80       	push   $0x80113cc0
801058a5:	e8 16 ee ff ff       	call   801046c0 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801058aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  ticks0 = ticks;
801058ad:	8b 1d a0 3c 11 80    	mov    0x80113ca0,%ebx
  while(ticks - ticks0 < n){
801058b3:	83 c4 10             	add    $0x10,%esp
801058b6:	85 d2                	test   %edx,%edx
801058b8:	75 27                	jne    801058e1 <sys_sleep+0x61>
801058ba:	eb 54                	jmp    80105910 <sys_sleep+0x90>
801058bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
801058c0:	83 ec 08             	sub    $0x8,%esp
801058c3:	68 c0 3c 11 80       	push   $0x80113cc0
801058c8:	68 a0 3c 11 80       	push   $0x80113ca0
801058cd:	e8 8e e8 ff ff       	call   80104160 <sleep>
  while(ticks - ticks0 < n){
801058d2:	a1 a0 3c 11 80       	mov    0x80113ca0,%eax
801058d7:	83 c4 10             	add    $0x10,%esp
801058da:	29 d8                	sub    %ebx,%eax
801058dc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801058df:	73 2f                	jae    80105910 <sys_sleep+0x90>
    if(myproc()->killed){
801058e1:	e8 aa e1 ff ff       	call   80103a90 <myproc>
801058e6:	8b 40 24             	mov    0x24(%eax),%eax
801058e9:	85 c0                	test   %eax,%eax
801058eb:	74 d3                	je     801058c0 <sys_sleep+0x40>
      release(&tickslock);
801058ed:	83 ec 0c             	sub    $0xc,%esp
801058f0:	68 c0 3c 11 80       	push   $0x80113cc0
801058f5:	e8 66 ed ff ff       	call   80104660 <release>
  }
  release(&tickslock);
  return 0;
}
801058fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
      return -1;
801058fd:	83 c4 10             	add    $0x10,%esp
80105900:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105905:	c9                   	leave  
80105906:	c3                   	ret    
80105907:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010590e:	66 90                	xchg   %ax,%ax
  release(&tickslock);
80105910:	83 ec 0c             	sub    $0xc,%esp
80105913:	68 c0 3c 11 80       	push   $0x80113cc0
80105918:	e8 43 ed ff ff       	call   80104660 <release>
  return 0;
8010591d:	83 c4 10             	add    $0x10,%esp
80105920:	31 c0                	xor    %eax,%eax
}
80105922:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105925:	c9                   	leave  
80105926:	c3                   	ret    
    return -1;
80105927:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010592c:	eb f4                	jmp    80105922 <sys_sleep+0xa2>
8010592e:	66 90                	xchg   %ax,%ax

80105930 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105930:	55                   	push   %ebp
80105931:	89 e5                	mov    %esp,%ebp
80105933:	53                   	push   %ebx
80105934:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80105937:	68 c0 3c 11 80       	push   $0x80113cc0
8010593c:	e8 7f ed ff ff       	call   801046c0 <acquire>
  xticks = ticks;
80105941:	8b 1d a0 3c 11 80    	mov    0x80113ca0,%ebx
  release(&tickslock);
80105947:	c7 04 24 c0 3c 11 80 	movl   $0x80113cc0,(%esp)
8010594e:	e8 0d ed ff ff       	call   80104660 <release>
  return xticks;
}
80105953:	89 d8                	mov    %ebx,%eax
80105955:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105958:	c9                   	leave  
80105959:	c3                   	ret    
8010595a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80105960 <sys_getlastcat>:

char last_cat_arg[64] = "Cat has not yet been called";

int
sys_getlastcat(void)
{
80105960:	55                   	push   %ebp
80105961:	89 e5                	mov    %esp,%ebp
80105963:	83 ec 20             	sub    $0x20,%esp
  char *buf;
  if(argstr(0, &buf) < 0)
80105966:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105969:	50                   	push   %eax
8010596a:	6a 00                	push   $0x0
8010596c:	e8 8f f1 ff ff       	call   80104b00 <argstr>
80105971:	83 c4 10             	add    $0x10,%esp
80105974:	85 c0                	test   %eax,%eax
80105976:	78 20                	js     80105998 <sys_getlastcat+0x38>
    return -1;
  
  safestrcpy(buf, last_cat_arg, sizeof(last_cat_arg));
80105978:	83 ec 04             	sub    $0x4,%esp
8010597b:	6a 40                	push   $0x40
8010597d:	68 20 a0 10 80       	push   $0x8010a020
80105982:	ff 75 f4             	push   -0xc(%ebp)
80105985:	e8 b6 ef ff ff       	call   80104940 <safestrcpy>
  
  return 0;
8010598a:	83 c4 10             	add    $0x10,%esp
8010598d:	31 c0                	xor    %eax,%eax
}
8010598f:	c9                   	leave  
80105990:	c3                   	ret    
80105991:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105998:	c9                   	leave  
    return -1;
80105999:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010599e:	c3                   	ret    

8010599f <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010599f:	1e                   	push   %ds
  pushl %es
801059a0:	06                   	push   %es
  pushl %fs
801059a1:	0f a0                	push   %fs
  pushl %gs
801059a3:	0f a8                	push   %gs
  pushal
801059a5:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801059a6:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801059aa:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801059ac:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801059ae:	54                   	push   %esp
  call trap
801059af:	e8 cc 00 00 00       	call   80105a80 <trap>
  addl $4, %esp
801059b4:	83 c4 04             	add    $0x4,%esp

801059b7 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801059b7:	61                   	popa   
  popl %gs
801059b8:	0f a9                	pop    %gs
  popl %fs
801059ba:	0f a1                	pop    %fs
  popl %es
801059bc:	07                   	pop    %es
  popl %ds
801059bd:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801059be:	83 c4 08             	add    $0x8,%esp
  iret
801059c1:	cf                   	iret   
801059c2:	66 90                	xchg   %ax,%ax
801059c4:	66 90                	xchg   %ax,%ax
801059c6:	66 90                	xchg   %ax,%ax
801059c8:	66 90                	xchg   %ax,%ax
801059ca:	66 90                	xchg   %ax,%ax
801059cc:	66 90                	xchg   %ax,%ax
801059ce:	66 90                	xchg   %ax,%ax

801059d0 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801059d0:	55                   	push   %ebp
  int i;

  for(i = 0; i < 256; i++)
801059d1:	31 c0                	xor    %eax,%eax
{
801059d3:	89 e5                	mov    %esp,%ebp
801059d5:	83 ec 08             	sub    $0x8,%esp
801059d8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801059df:	90                   	nop
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801059e0:	8b 14 85 60 a0 10 80 	mov    -0x7fef5fa0(,%eax,4),%edx
801059e7:	c7 04 c5 02 3d 11 80 	movl   $0x8e000008,-0x7feec2fe(,%eax,8)
801059ee:	08 00 00 8e 
801059f2:	66 89 14 c5 00 3d 11 	mov    %dx,-0x7feec300(,%eax,8)
801059f9:	80 
801059fa:	c1 ea 10             	shr    $0x10,%edx
801059fd:	66 89 14 c5 06 3d 11 	mov    %dx,-0x7feec2fa(,%eax,8)
80105a04:	80 
  for(i = 0; i < 256; i++)
80105a05:	83 c0 01             	add    $0x1,%eax
80105a08:	3d 00 01 00 00       	cmp    $0x100,%eax
80105a0d:	75 d1                	jne    801059e0 <tvinit+0x10>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);

  initlock(&tickslock, "time");
80105a0f:	83 ec 08             	sub    $0x8,%esp
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105a12:	a1 60 a1 10 80       	mov    0x8010a160,%eax
80105a17:	c7 05 02 3f 11 80 08 	movl   $0xef000008,0x80113f02
80105a1e:	00 00 ef 
  initlock(&tickslock, "time");
80105a21:	68 7d 7a 10 80       	push   $0x80107a7d
80105a26:	68 c0 3c 11 80       	push   $0x80113cc0
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105a2b:	66 a3 00 3f 11 80    	mov    %ax,0x80113f00
80105a31:	c1 e8 10             	shr    $0x10,%eax
80105a34:	66 a3 06 3f 11 80    	mov    %ax,0x80113f06
  initlock(&tickslock, "time");
80105a3a:	e8 b1 ea ff ff       	call   801044f0 <initlock>
}
80105a3f:	83 c4 10             	add    $0x10,%esp
80105a42:	c9                   	leave  
80105a43:	c3                   	ret    
80105a44:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105a4b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105a4f:	90                   	nop

80105a50 <idtinit>:

void
idtinit(void)
{
80105a50:	55                   	push   %ebp
  pd[0] = size-1;
80105a51:	b8 ff 07 00 00       	mov    $0x7ff,%eax
80105a56:	89 e5                	mov    %esp,%ebp
80105a58:	83 ec 10             	sub    $0x10,%esp
80105a5b:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80105a5f:	b8 00 3d 11 80       	mov    $0x80113d00,%eax
80105a64:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105a68:	c1 e8 10             	shr    $0x10,%eax
80105a6b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105a6f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105a72:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80105a75:	c9                   	leave  
80105a76:	c3                   	ret    
80105a77:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105a7e:	66 90                	xchg   %ax,%ax

80105a80 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80105a80:	55                   	push   %ebp
80105a81:	89 e5                	mov    %esp,%ebp
80105a83:	57                   	push   %edi
80105a84:	56                   	push   %esi
80105a85:	53                   	push   %ebx
80105a86:	83 ec 1c             	sub    $0x1c,%esp
80105a89:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80105a8c:	8b 43 30             	mov    0x30(%ebx),%eax
80105a8f:	83 f8 40             	cmp    $0x40,%eax
80105a92:	0f 84 68 01 00 00    	je     80105c00 <trap+0x180>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80105a98:	83 e8 20             	sub    $0x20,%eax
80105a9b:	83 f8 1f             	cmp    $0x1f,%eax
80105a9e:	0f 87 8c 00 00 00    	ja     80105b30 <trap+0xb0>
80105aa4:	ff 24 85 24 7b 10 80 	jmp    *-0x7fef84dc(,%eax,4)
80105aab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105aaf:	90                   	nop
      release(&tickslock);
    }
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80105ab0:	e8 ab c8 ff ff       	call   80102360 <ideintr>
    lapiceoi();
80105ab5:	e8 76 cf ff ff       	call   80102a30 <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105aba:	e8 d1 df ff ff       	call   80103a90 <myproc>
80105abf:	85 c0                	test   %eax,%eax
80105ac1:	74 1d                	je     80105ae0 <trap+0x60>
80105ac3:	e8 c8 df ff ff       	call   80103a90 <myproc>
80105ac8:	8b 50 24             	mov    0x24(%eax),%edx
80105acb:	85 d2                	test   %edx,%edx
80105acd:	74 11                	je     80105ae0 <trap+0x60>
80105acf:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105ad3:	83 e0 03             	and    $0x3,%eax
80105ad6:	66 83 f8 03          	cmp    $0x3,%ax
80105ada:	0f 84 e8 01 00 00    	je     80105cc8 <trap+0x248>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80105ae0:	e8 ab df ff ff       	call   80103a90 <myproc>
80105ae5:	85 c0                	test   %eax,%eax
80105ae7:	74 0f                	je     80105af8 <trap+0x78>
80105ae9:	e8 a2 df ff ff       	call   80103a90 <myproc>
80105aee:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80105af2:	0f 84 b8 00 00 00    	je     80105bb0 <trap+0x130>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105af8:	e8 93 df ff ff       	call   80103a90 <myproc>
80105afd:	85 c0                	test   %eax,%eax
80105aff:	74 1d                	je     80105b1e <trap+0x9e>
80105b01:	e8 8a df ff ff       	call   80103a90 <myproc>
80105b06:	8b 40 24             	mov    0x24(%eax),%eax
80105b09:	85 c0                	test   %eax,%eax
80105b0b:	74 11                	je     80105b1e <trap+0x9e>
80105b0d:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105b11:	83 e0 03             	and    $0x3,%eax
80105b14:	66 83 f8 03          	cmp    $0x3,%ax
80105b18:	0f 84 0f 01 00 00    	je     80105c2d <trap+0x1ad>
    exit();
}
80105b1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105b21:	5b                   	pop    %ebx
80105b22:	5e                   	pop    %esi
80105b23:	5f                   	pop    %edi
80105b24:	5d                   	pop    %ebp
80105b25:	c3                   	ret    
80105b26:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105b2d:	8d 76 00             	lea    0x0(%esi),%esi
    if(myproc() == 0 || (tf->cs&3) == 0){
80105b30:	e8 5b df ff ff       	call   80103a90 <myproc>
80105b35:	8b 7b 38             	mov    0x38(%ebx),%edi
80105b38:	85 c0                	test   %eax,%eax
80105b3a:	0f 84 a2 01 00 00    	je     80105ce2 <trap+0x262>
80105b40:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
80105b44:	0f 84 98 01 00 00    	je     80105ce2 <trap+0x262>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105b4a:	0f 20 d1             	mov    %cr2,%ecx
80105b4d:	89 4d d8             	mov    %ecx,-0x28(%ebp)
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105b50:	e8 1b df ff ff       	call   80103a70 <cpuid>
80105b55:	8b 73 30             	mov    0x30(%ebx),%esi
80105b58:	89 45 dc             	mov    %eax,-0x24(%ebp)
80105b5b:	8b 43 34             	mov    0x34(%ebx),%eax
80105b5e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            myproc()->pid, myproc()->name, tf->trapno,
80105b61:	e8 2a df ff ff       	call   80103a90 <myproc>
80105b66:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105b69:	e8 22 df ff ff       	call   80103a90 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105b6e:	8b 4d d8             	mov    -0x28(%ebp),%ecx
80105b71:	8b 55 dc             	mov    -0x24(%ebp),%edx
80105b74:	51                   	push   %ecx
80105b75:	57                   	push   %edi
80105b76:	52                   	push   %edx
80105b77:	ff 75 e4             	push   -0x1c(%ebp)
80105b7a:	56                   	push   %esi
            myproc()->pid, myproc()->name, tf->trapno,
80105b7b:	8b 75 e0             	mov    -0x20(%ebp),%esi
80105b7e:	83 c6 6c             	add    $0x6c,%esi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105b81:	56                   	push   %esi
80105b82:	ff 70 10             	push   0x10(%eax)
80105b85:	68 e0 7a 10 80       	push   $0x80107ae0
80105b8a:	e8 11 ab ff ff       	call   801006a0 <cprintf>
    myproc()->killed = 1;
80105b8f:	83 c4 20             	add    $0x20,%esp
80105b92:	e8 f9 de ff ff       	call   80103a90 <myproc>
80105b97:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105b9e:	e8 ed de ff ff       	call   80103a90 <myproc>
80105ba3:	85 c0                	test   %eax,%eax
80105ba5:	0f 85 18 ff ff ff    	jne    80105ac3 <trap+0x43>
80105bab:	e9 30 ff ff ff       	jmp    80105ae0 <trap+0x60>
  if(myproc() && myproc()->state == RUNNING &&
80105bb0:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
80105bb4:	0f 85 3e ff ff ff    	jne    80105af8 <trap+0x78>
    yield();
80105bba:	e8 51 e5 ff ff       	call   80104110 <yield>
80105bbf:	e9 34 ff ff ff       	jmp    80105af8 <trap+0x78>
80105bc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105bc8:	8b 7b 38             	mov    0x38(%ebx),%edi
80105bcb:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
80105bcf:	e8 9c de ff ff       	call   80103a70 <cpuid>
80105bd4:	57                   	push   %edi
80105bd5:	56                   	push   %esi
80105bd6:	50                   	push   %eax
80105bd7:	68 88 7a 10 80       	push   $0x80107a88
80105bdc:	e8 bf aa ff ff       	call   801006a0 <cprintf>
    lapiceoi();
80105be1:	e8 4a ce ff ff       	call   80102a30 <lapiceoi>
    break;
80105be6:	83 c4 10             	add    $0x10,%esp
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105be9:	e8 a2 de ff ff       	call   80103a90 <myproc>
80105bee:	85 c0                	test   %eax,%eax
80105bf0:	0f 85 cd fe ff ff    	jne    80105ac3 <trap+0x43>
80105bf6:	e9 e5 fe ff ff       	jmp    80105ae0 <trap+0x60>
80105bfb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105bff:	90                   	nop
    if(myproc()->killed)
80105c00:	e8 8b de ff ff       	call   80103a90 <myproc>
80105c05:	8b 70 24             	mov    0x24(%eax),%esi
80105c08:	85 f6                	test   %esi,%esi
80105c0a:	0f 85 c8 00 00 00    	jne    80105cd8 <trap+0x258>
    myproc()->tf = tf;
80105c10:	e8 7b de ff ff       	call   80103a90 <myproc>
80105c15:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
80105c18:	e8 63 ef ff ff       	call   80104b80 <syscall>
    if(myproc()->killed)
80105c1d:	e8 6e de ff ff       	call   80103a90 <myproc>
80105c22:	8b 48 24             	mov    0x24(%eax),%ecx
80105c25:	85 c9                	test   %ecx,%ecx
80105c27:	0f 84 f1 fe ff ff    	je     80105b1e <trap+0x9e>
}
80105c2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105c30:	5b                   	pop    %ebx
80105c31:	5e                   	pop    %esi
80105c32:	5f                   	pop    %edi
80105c33:	5d                   	pop    %ebp
      exit();
80105c34:	e9 77 e2 ff ff       	jmp    80103eb0 <exit>
80105c39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    uartintr();
80105c40:	e8 3b 02 00 00       	call   80105e80 <uartintr>
    lapiceoi();
80105c45:	e8 e6 cd ff ff       	call   80102a30 <lapiceoi>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105c4a:	e8 41 de ff ff       	call   80103a90 <myproc>
80105c4f:	85 c0                	test   %eax,%eax
80105c51:	0f 85 6c fe ff ff    	jne    80105ac3 <trap+0x43>
80105c57:	e9 84 fe ff ff       	jmp    80105ae0 <trap+0x60>
80105c5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    kbdintr();
80105c60:	e8 8b cc ff ff       	call   801028f0 <kbdintr>
    lapiceoi();
80105c65:	e8 c6 cd ff ff       	call   80102a30 <lapiceoi>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105c6a:	e8 21 de ff ff       	call   80103a90 <myproc>
80105c6f:	85 c0                	test   %eax,%eax
80105c71:	0f 85 4c fe ff ff    	jne    80105ac3 <trap+0x43>
80105c77:	e9 64 fe ff ff       	jmp    80105ae0 <trap+0x60>
80105c7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(cpuid() == 0){
80105c80:	e8 eb dd ff ff       	call   80103a70 <cpuid>
80105c85:	85 c0                	test   %eax,%eax
80105c87:	0f 85 28 fe ff ff    	jne    80105ab5 <trap+0x35>
      acquire(&tickslock);
80105c8d:	83 ec 0c             	sub    $0xc,%esp
80105c90:	68 c0 3c 11 80       	push   $0x80113cc0
80105c95:	e8 26 ea ff ff       	call   801046c0 <acquire>
      wakeup(&ticks);
80105c9a:	c7 04 24 a0 3c 11 80 	movl   $0x80113ca0,(%esp)
      ticks++;
80105ca1:	83 05 a0 3c 11 80 01 	addl   $0x1,0x80113ca0
      wakeup(&ticks);
80105ca8:	e8 73 e5 ff ff       	call   80104220 <wakeup>
      release(&tickslock);
80105cad:	c7 04 24 c0 3c 11 80 	movl   $0x80113cc0,(%esp)
80105cb4:	e8 a7 e9 ff ff       	call   80104660 <release>
80105cb9:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80105cbc:	e9 f4 fd ff ff       	jmp    80105ab5 <trap+0x35>
80105cc1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    exit();
80105cc8:	e8 e3 e1 ff ff       	call   80103eb0 <exit>
80105ccd:	e9 0e fe ff ff       	jmp    80105ae0 <trap+0x60>
80105cd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      exit();
80105cd8:	e8 d3 e1 ff ff       	call   80103eb0 <exit>
80105cdd:	e9 2e ff ff ff       	jmp    80105c10 <trap+0x190>
80105ce2:	0f 20 d6             	mov    %cr2,%esi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80105ce5:	e8 86 dd ff ff       	call   80103a70 <cpuid>
80105cea:	83 ec 0c             	sub    $0xc,%esp
80105ced:	56                   	push   %esi
80105cee:	57                   	push   %edi
80105cef:	50                   	push   %eax
80105cf0:	ff 73 30             	push   0x30(%ebx)
80105cf3:	68 ac 7a 10 80       	push   $0x80107aac
80105cf8:	e8 a3 a9 ff ff       	call   801006a0 <cprintf>
      panic("trap");
80105cfd:	83 c4 14             	add    $0x14,%esp
80105d00:	68 82 7a 10 80       	push   $0x80107a82
80105d05:	e8 76 a6 ff ff       	call   80100380 <panic>
80105d0a:	66 90                	xchg   %ax,%ax
80105d0c:	66 90                	xchg   %ax,%ax
80105d0e:	66 90                	xchg   %ax,%ax

80105d10 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
80105d10:	a1 00 45 11 80       	mov    0x80114500,%eax
80105d15:	85 c0                	test   %eax,%eax
80105d17:	74 17                	je     80105d30 <uartgetc+0x20>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105d19:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105d1e:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
80105d1f:	a8 01                	test   $0x1,%al
80105d21:	74 0d                	je     80105d30 <uartgetc+0x20>
80105d23:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105d28:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
80105d29:	0f b6 c0             	movzbl %al,%eax
80105d2c:	c3                   	ret    
80105d2d:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80105d30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d35:	c3                   	ret    
80105d36:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105d3d:	8d 76 00             	lea    0x0(%esi),%esi

80105d40 <uartinit>:
{
80105d40:	55                   	push   %ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80105d41:	31 c9                	xor    %ecx,%ecx
80105d43:	89 c8                	mov    %ecx,%eax
80105d45:	89 e5                	mov    %esp,%ebp
80105d47:	57                   	push   %edi
80105d48:	bf fa 03 00 00       	mov    $0x3fa,%edi
80105d4d:	56                   	push   %esi
80105d4e:	89 fa                	mov    %edi,%edx
80105d50:	53                   	push   %ebx
80105d51:	83 ec 1c             	sub    $0x1c,%esp
80105d54:	ee                   	out    %al,(%dx)
80105d55:	be fb 03 00 00       	mov    $0x3fb,%esi
80105d5a:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
80105d5f:	89 f2                	mov    %esi,%edx
80105d61:	ee                   	out    %al,(%dx)
80105d62:	b8 0c 00 00 00       	mov    $0xc,%eax
80105d67:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105d6c:	ee                   	out    %al,(%dx)
80105d6d:	bb f9 03 00 00       	mov    $0x3f9,%ebx
80105d72:	89 c8                	mov    %ecx,%eax
80105d74:	89 da                	mov    %ebx,%edx
80105d76:	ee                   	out    %al,(%dx)
80105d77:	b8 03 00 00 00       	mov    $0x3,%eax
80105d7c:	89 f2                	mov    %esi,%edx
80105d7e:	ee                   	out    %al,(%dx)
80105d7f:	ba fc 03 00 00       	mov    $0x3fc,%edx
80105d84:	89 c8                	mov    %ecx,%eax
80105d86:	ee                   	out    %al,(%dx)
80105d87:	b8 01 00 00 00       	mov    $0x1,%eax
80105d8c:	89 da                	mov    %ebx,%edx
80105d8e:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105d8f:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105d94:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
80105d95:	3c ff                	cmp    $0xff,%al
80105d97:	74 78                	je     80105e11 <uartinit+0xd1>
  uart = 1;
80105d99:	c7 05 00 45 11 80 01 	movl   $0x1,0x80114500
80105da0:	00 00 00 
80105da3:	89 fa                	mov    %edi,%edx
80105da5:	ec                   	in     (%dx),%al
80105da6:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105dab:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
80105dac:	83 ec 08             	sub    $0x8,%esp
  for(p="xv6...\n"; *p; p++)
80105daf:	bf a4 7b 10 80       	mov    $0x80107ba4,%edi
80105db4:	be fd 03 00 00       	mov    $0x3fd,%esi
  ioapicenable(IRQ_COM1, 0);
80105db9:	6a 00                	push   $0x0
80105dbb:	6a 04                	push   $0x4
80105dbd:	e8 de c7 ff ff       	call   801025a0 <ioapicenable>
  for(p="xv6...\n"; *p; p++)
80105dc2:	c6 45 e7 78          	movb   $0x78,-0x19(%ebp)
  ioapicenable(IRQ_COM1, 0);
80105dc6:	83 c4 10             	add    $0x10,%esp
80105dc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  if(!uart)
80105dd0:	a1 00 45 11 80       	mov    0x80114500,%eax
80105dd5:	bb 80 00 00 00       	mov    $0x80,%ebx
80105dda:	85 c0                	test   %eax,%eax
80105ddc:	75 14                	jne    80105df2 <uartinit+0xb2>
80105dde:	eb 23                	jmp    80105e03 <uartinit+0xc3>
    microdelay(10);
80105de0:	83 ec 0c             	sub    $0xc,%esp
80105de3:	6a 0a                	push   $0xa
80105de5:	e8 66 cc ff ff       	call   80102a50 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105dea:	83 c4 10             	add    $0x10,%esp
80105ded:	83 eb 01             	sub    $0x1,%ebx
80105df0:	74 07                	je     80105df9 <uartinit+0xb9>
80105df2:	89 f2                	mov    %esi,%edx
80105df4:	ec                   	in     (%dx),%al
80105df5:	a8 20                	test   $0x20,%al
80105df7:	74 e7                	je     80105de0 <uartinit+0xa0>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80105df9:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
80105dfd:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105e02:	ee                   	out    %al,(%dx)
  for(p="xv6...\n"; *p; p++)
80105e03:	0f b6 47 01          	movzbl 0x1(%edi),%eax
80105e07:	83 c7 01             	add    $0x1,%edi
80105e0a:	88 45 e7             	mov    %al,-0x19(%ebp)
80105e0d:	84 c0                	test   %al,%al
80105e0f:	75 bf                	jne    80105dd0 <uartinit+0x90>
}
80105e11:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105e14:	5b                   	pop    %ebx
80105e15:	5e                   	pop    %esi
80105e16:	5f                   	pop    %edi
80105e17:	5d                   	pop    %ebp
80105e18:	c3                   	ret    
80105e19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105e20 <uartputc>:
  if(!uart)
80105e20:	a1 00 45 11 80       	mov    0x80114500,%eax
80105e25:	85 c0                	test   %eax,%eax
80105e27:	74 47                	je     80105e70 <uartputc+0x50>
{
80105e29:	55                   	push   %ebp
80105e2a:	89 e5                	mov    %esp,%ebp
80105e2c:	56                   	push   %esi
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105e2d:	be fd 03 00 00       	mov    $0x3fd,%esi
80105e32:	53                   	push   %ebx
80105e33:	bb 80 00 00 00       	mov    $0x80,%ebx
80105e38:	eb 18                	jmp    80105e52 <uartputc+0x32>
80105e3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    microdelay(10);
80105e40:	83 ec 0c             	sub    $0xc,%esp
80105e43:	6a 0a                	push   $0xa
80105e45:	e8 06 cc ff ff       	call   80102a50 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105e4a:	83 c4 10             	add    $0x10,%esp
80105e4d:	83 eb 01             	sub    $0x1,%ebx
80105e50:	74 07                	je     80105e59 <uartputc+0x39>
80105e52:	89 f2                	mov    %esi,%edx
80105e54:	ec                   	in     (%dx),%al
80105e55:	a8 20                	test   $0x20,%al
80105e57:	74 e7                	je     80105e40 <uartputc+0x20>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80105e59:	8b 45 08             	mov    0x8(%ebp),%eax
80105e5c:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105e61:	ee                   	out    %al,(%dx)
}
80105e62:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105e65:	5b                   	pop    %ebx
80105e66:	5e                   	pop    %esi
80105e67:	5d                   	pop    %ebp
80105e68:	c3                   	ret    
80105e69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105e70:	c3                   	ret    
80105e71:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105e78:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105e7f:	90                   	nop

80105e80 <uartintr>:

void
uartintr(void)
{
80105e80:	55                   	push   %ebp
80105e81:	89 e5                	mov    %esp,%ebp
80105e83:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
80105e86:	68 10 5d 10 80       	push   $0x80105d10
80105e8b:	e8 f0 a9 ff ff       	call   80100880 <consoleintr>
}
80105e90:	83 c4 10             	add    $0x10,%esp
80105e93:	c9                   	leave  
80105e94:	c3                   	ret    

80105e95 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80105e95:	6a 00                	push   $0x0
  pushl $0
80105e97:	6a 00                	push   $0x0
  jmp alltraps
80105e99:	e9 01 fb ff ff       	jmp    8010599f <alltraps>

80105e9e <vector1>:
.globl vector1
vector1:
  pushl $0
80105e9e:	6a 00                	push   $0x0
  pushl $1
80105ea0:	6a 01                	push   $0x1
  jmp alltraps
80105ea2:	e9 f8 fa ff ff       	jmp    8010599f <alltraps>

80105ea7 <vector2>:
.globl vector2
vector2:
  pushl $0
80105ea7:	6a 00                	push   $0x0
  pushl $2
80105ea9:	6a 02                	push   $0x2
  jmp alltraps
80105eab:	e9 ef fa ff ff       	jmp    8010599f <alltraps>

80105eb0 <vector3>:
.globl vector3
vector3:
  pushl $0
80105eb0:	6a 00                	push   $0x0
  pushl $3
80105eb2:	6a 03                	push   $0x3
  jmp alltraps
80105eb4:	e9 e6 fa ff ff       	jmp    8010599f <alltraps>

80105eb9 <vector4>:
.globl vector4
vector4:
  pushl $0
80105eb9:	6a 00                	push   $0x0
  pushl $4
80105ebb:	6a 04                	push   $0x4
  jmp alltraps
80105ebd:	e9 dd fa ff ff       	jmp    8010599f <alltraps>

80105ec2 <vector5>:
.globl vector5
vector5:
  pushl $0
80105ec2:	6a 00                	push   $0x0
  pushl $5
80105ec4:	6a 05                	push   $0x5
  jmp alltraps
80105ec6:	e9 d4 fa ff ff       	jmp    8010599f <alltraps>

80105ecb <vector6>:
.globl vector6
vector6:
  pushl $0
80105ecb:	6a 00                	push   $0x0
  pushl $6
80105ecd:	6a 06                	push   $0x6
  jmp alltraps
80105ecf:	e9 cb fa ff ff       	jmp    8010599f <alltraps>

80105ed4 <vector7>:
.globl vector7
vector7:
  pushl $0
80105ed4:	6a 00                	push   $0x0
  pushl $7
80105ed6:	6a 07                	push   $0x7
  jmp alltraps
80105ed8:	e9 c2 fa ff ff       	jmp    8010599f <alltraps>

80105edd <vector8>:
.globl vector8
vector8:
  pushl $8
80105edd:	6a 08                	push   $0x8
  jmp alltraps
80105edf:	e9 bb fa ff ff       	jmp    8010599f <alltraps>

80105ee4 <vector9>:
.globl vector9
vector9:
  pushl $0
80105ee4:	6a 00                	push   $0x0
  pushl $9
80105ee6:	6a 09                	push   $0x9
  jmp alltraps
80105ee8:	e9 b2 fa ff ff       	jmp    8010599f <alltraps>

80105eed <vector10>:
.globl vector10
vector10:
  pushl $10
80105eed:	6a 0a                	push   $0xa
  jmp alltraps
80105eef:	e9 ab fa ff ff       	jmp    8010599f <alltraps>

80105ef4 <vector11>:
.globl vector11
vector11:
  pushl $11
80105ef4:	6a 0b                	push   $0xb
  jmp alltraps
80105ef6:	e9 a4 fa ff ff       	jmp    8010599f <alltraps>

80105efb <vector12>:
.globl vector12
vector12:
  pushl $12
80105efb:	6a 0c                	push   $0xc
  jmp alltraps
80105efd:	e9 9d fa ff ff       	jmp    8010599f <alltraps>

80105f02 <vector13>:
.globl vector13
vector13:
  pushl $13
80105f02:	6a 0d                	push   $0xd
  jmp alltraps
80105f04:	e9 96 fa ff ff       	jmp    8010599f <alltraps>

80105f09 <vector14>:
.globl vector14
vector14:
  pushl $14
80105f09:	6a 0e                	push   $0xe
  jmp alltraps
80105f0b:	e9 8f fa ff ff       	jmp    8010599f <alltraps>

80105f10 <vector15>:
.globl vector15
vector15:
  pushl $0
80105f10:	6a 00                	push   $0x0
  pushl $15
80105f12:	6a 0f                	push   $0xf
  jmp alltraps
80105f14:	e9 86 fa ff ff       	jmp    8010599f <alltraps>

80105f19 <vector16>:
.globl vector16
vector16:
  pushl $0
80105f19:	6a 00                	push   $0x0
  pushl $16
80105f1b:	6a 10                	push   $0x10
  jmp alltraps
80105f1d:	e9 7d fa ff ff       	jmp    8010599f <alltraps>

80105f22 <vector17>:
.globl vector17
vector17:
  pushl $17
80105f22:	6a 11                	push   $0x11
  jmp alltraps
80105f24:	e9 76 fa ff ff       	jmp    8010599f <alltraps>

80105f29 <vector18>:
.globl vector18
vector18:
  pushl $0
80105f29:	6a 00                	push   $0x0
  pushl $18
80105f2b:	6a 12                	push   $0x12
  jmp alltraps
80105f2d:	e9 6d fa ff ff       	jmp    8010599f <alltraps>

80105f32 <vector19>:
.globl vector19
vector19:
  pushl $0
80105f32:	6a 00                	push   $0x0
  pushl $19
80105f34:	6a 13                	push   $0x13
  jmp alltraps
80105f36:	e9 64 fa ff ff       	jmp    8010599f <alltraps>

80105f3b <vector20>:
.globl vector20
vector20:
  pushl $0
80105f3b:	6a 00                	push   $0x0
  pushl $20
80105f3d:	6a 14                	push   $0x14
  jmp alltraps
80105f3f:	e9 5b fa ff ff       	jmp    8010599f <alltraps>

80105f44 <vector21>:
.globl vector21
vector21:
  pushl $0
80105f44:	6a 00                	push   $0x0
  pushl $21
80105f46:	6a 15                	push   $0x15
  jmp alltraps
80105f48:	e9 52 fa ff ff       	jmp    8010599f <alltraps>

80105f4d <vector22>:
.globl vector22
vector22:
  pushl $0
80105f4d:	6a 00                	push   $0x0
  pushl $22
80105f4f:	6a 16                	push   $0x16
  jmp alltraps
80105f51:	e9 49 fa ff ff       	jmp    8010599f <alltraps>

80105f56 <vector23>:
.globl vector23
vector23:
  pushl $0
80105f56:	6a 00                	push   $0x0
  pushl $23
80105f58:	6a 17                	push   $0x17
  jmp alltraps
80105f5a:	e9 40 fa ff ff       	jmp    8010599f <alltraps>

80105f5f <vector24>:
.globl vector24
vector24:
  pushl $0
80105f5f:	6a 00                	push   $0x0
  pushl $24
80105f61:	6a 18                	push   $0x18
  jmp alltraps
80105f63:	e9 37 fa ff ff       	jmp    8010599f <alltraps>

80105f68 <vector25>:
.globl vector25
vector25:
  pushl $0
80105f68:	6a 00                	push   $0x0
  pushl $25
80105f6a:	6a 19                	push   $0x19
  jmp alltraps
80105f6c:	e9 2e fa ff ff       	jmp    8010599f <alltraps>

80105f71 <vector26>:
.globl vector26
vector26:
  pushl $0
80105f71:	6a 00                	push   $0x0
  pushl $26
80105f73:	6a 1a                	push   $0x1a
  jmp alltraps
80105f75:	e9 25 fa ff ff       	jmp    8010599f <alltraps>

80105f7a <vector27>:
.globl vector27
vector27:
  pushl $0
80105f7a:	6a 00                	push   $0x0
  pushl $27
80105f7c:	6a 1b                	push   $0x1b
  jmp alltraps
80105f7e:	e9 1c fa ff ff       	jmp    8010599f <alltraps>

80105f83 <vector28>:
.globl vector28
vector28:
  pushl $0
80105f83:	6a 00                	push   $0x0
  pushl $28
80105f85:	6a 1c                	push   $0x1c
  jmp alltraps
80105f87:	e9 13 fa ff ff       	jmp    8010599f <alltraps>

80105f8c <vector29>:
.globl vector29
vector29:
  pushl $0
80105f8c:	6a 00                	push   $0x0
  pushl $29
80105f8e:	6a 1d                	push   $0x1d
  jmp alltraps
80105f90:	e9 0a fa ff ff       	jmp    8010599f <alltraps>

80105f95 <vector30>:
.globl vector30
vector30:
  pushl $0
80105f95:	6a 00                	push   $0x0
  pushl $30
80105f97:	6a 1e                	push   $0x1e
  jmp alltraps
80105f99:	e9 01 fa ff ff       	jmp    8010599f <alltraps>

80105f9e <vector31>:
.globl vector31
vector31:
  pushl $0
80105f9e:	6a 00                	push   $0x0
  pushl $31
80105fa0:	6a 1f                	push   $0x1f
  jmp alltraps
80105fa2:	e9 f8 f9 ff ff       	jmp    8010599f <alltraps>

80105fa7 <vector32>:
.globl vector32
vector32:
  pushl $0
80105fa7:	6a 00                	push   $0x0
  pushl $32
80105fa9:	6a 20                	push   $0x20
  jmp alltraps
80105fab:	e9 ef f9 ff ff       	jmp    8010599f <alltraps>

80105fb0 <vector33>:
.globl vector33
vector33:
  pushl $0
80105fb0:	6a 00                	push   $0x0
  pushl $33
80105fb2:	6a 21                	push   $0x21
  jmp alltraps
80105fb4:	e9 e6 f9 ff ff       	jmp    8010599f <alltraps>

80105fb9 <vector34>:
.globl vector34
vector34:
  pushl $0
80105fb9:	6a 00                	push   $0x0
  pushl $34
80105fbb:	6a 22                	push   $0x22
  jmp alltraps
80105fbd:	e9 dd f9 ff ff       	jmp    8010599f <alltraps>

80105fc2 <vector35>:
.globl vector35
vector35:
  pushl $0
80105fc2:	6a 00                	push   $0x0
  pushl $35
80105fc4:	6a 23                	push   $0x23
  jmp alltraps
80105fc6:	e9 d4 f9 ff ff       	jmp    8010599f <alltraps>

80105fcb <vector36>:
.globl vector36
vector36:
  pushl $0
80105fcb:	6a 00                	push   $0x0
  pushl $36
80105fcd:	6a 24                	push   $0x24
  jmp alltraps
80105fcf:	e9 cb f9 ff ff       	jmp    8010599f <alltraps>

80105fd4 <vector37>:
.globl vector37
vector37:
  pushl $0
80105fd4:	6a 00                	push   $0x0
  pushl $37
80105fd6:	6a 25                	push   $0x25
  jmp alltraps
80105fd8:	e9 c2 f9 ff ff       	jmp    8010599f <alltraps>

80105fdd <vector38>:
.globl vector38
vector38:
  pushl $0
80105fdd:	6a 00                	push   $0x0
  pushl $38
80105fdf:	6a 26                	push   $0x26
  jmp alltraps
80105fe1:	e9 b9 f9 ff ff       	jmp    8010599f <alltraps>

80105fe6 <vector39>:
.globl vector39
vector39:
  pushl $0
80105fe6:	6a 00                	push   $0x0
  pushl $39
80105fe8:	6a 27                	push   $0x27
  jmp alltraps
80105fea:	e9 b0 f9 ff ff       	jmp    8010599f <alltraps>

80105fef <vector40>:
.globl vector40
vector40:
  pushl $0
80105fef:	6a 00                	push   $0x0
  pushl $40
80105ff1:	6a 28                	push   $0x28
  jmp alltraps
80105ff3:	e9 a7 f9 ff ff       	jmp    8010599f <alltraps>

80105ff8 <vector41>:
.globl vector41
vector41:
  pushl $0
80105ff8:	6a 00                	push   $0x0
  pushl $41
80105ffa:	6a 29                	push   $0x29
  jmp alltraps
80105ffc:	e9 9e f9 ff ff       	jmp    8010599f <alltraps>

80106001 <vector42>:
.globl vector42
vector42:
  pushl $0
80106001:	6a 00                	push   $0x0
  pushl $42
80106003:	6a 2a                	push   $0x2a
  jmp alltraps
80106005:	e9 95 f9 ff ff       	jmp    8010599f <alltraps>

8010600a <vector43>:
.globl vector43
vector43:
  pushl $0
8010600a:	6a 00                	push   $0x0
  pushl $43
8010600c:	6a 2b                	push   $0x2b
  jmp alltraps
8010600e:	e9 8c f9 ff ff       	jmp    8010599f <alltraps>

80106013 <vector44>:
.globl vector44
vector44:
  pushl $0
80106013:	6a 00                	push   $0x0
  pushl $44
80106015:	6a 2c                	push   $0x2c
  jmp alltraps
80106017:	e9 83 f9 ff ff       	jmp    8010599f <alltraps>

8010601c <vector45>:
.globl vector45
vector45:
  pushl $0
8010601c:	6a 00                	push   $0x0
  pushl $45
8010601e:	6a 2d                	push   $0x2d
  jmp alltraps
80106020:	e9 7a f9 ff ff       	jmp    8010599f <alltraps>

80106025 <vector46>:
.globl vector46
vector46:
  pushl $0
80106025:	6a 00                	push   $0x0
  pushl $46
80106027:	6a 2e                	push   $0x2e
  jmp alltraps
80106029:	e9 71 f9 ff ff       	jmp    8010599f <alltraps>

8010602e <vector47>:
.globl vector47
vector47:
  pushl $0
8010602e:	6a 00                	push   $0x0
  pushl $47
80106030:	6a 2f                	push   $0x2f
  jmp alltraps
80106032:	e9 68 f9 ff ff       	jmp    8010599f <alltraps>

80106037 <vector48>:
.globl vector48
vector48:
  pushl $0
80106037:	6a 00                	push   $0x0
  pushl $48
80106039:	6a 30                	push   $0x30
  jmp alltraps
8010603b:	e9 5f f9 ff ff       	jmp    8010599f <alltraps>

80106040 <vector49>:
.globl vector49
vector49:
  pushl $0
80106040:	6a 00                	push   $0x0
  pushl $49
80106042:	6a 31                	push   $0x31
  jmp alltraps
80106044:	e9 56 f9 ff ff       	jmp    8010599f <alltraps>

80106049 <vector50>:
.globl vector50
vector50:
  pushl $0
80106049:	6a 00                	push   $0x0
  pushl $50
8010604b:	6a 32                	push   $0x32
  jmp alltraps
8010604d:	e9 4d f9 ff ff       	jmp    8010599f <alltraps>

80106052 <vector51>:
.globl vector51
vector51:
  pushl $0
80106052:	6a 00                	push   $0x0
  pushl $51
80106054:	6a 33                	push   $0x33
  jmp alltraps
80106056:	e9 44 f9 ff ff       	jmp    8010599f <alltraps>

8010605b <vector52>:
.globl vector52
vector52:
  pushl $0
8010605b:	6a 00                	push   $0x0
  pushl $52
8010605d:	6a 34                	push   $0x34
  jmp alltraps
8010605f:	e9 3b f9 ff ff       	jmp    8010599f <alltraps>

80106064 <vector53>:
.globl vector53
vector53:
  pushl $0
80106064:	6a 00                	push   $0x0
  pushl $53
80106066:	6a 35                	push   $0x35
  jmp alltraps
80106068:	e9 32 f9 ff ff       	jmp    8010599f <alltraps>

8010606d <vector54>:
.globl vector54
vector54:
  pushl $0
8010606d:	6a 00                	push   $0x0
  pushl $54
8010606f:	6a 36                	push   $0x36
  jmp alltraps
80106071:	e9 29 f9 ff ff       	jmp    8010599f <alltraps>

80106076 <vector55>:
.globl vector55
vector55:
  pushl $0
80106076:	6a 00                	push   $0x0
  pushl $55
80106078:	6a 37                	push   $0x37
  jmp alltraps
8010607a:	e9 20 f9 ff ff       	jmp    8010599f <alltraps>

8010607f <vector56>:
.globl vector56
vector56:
  pushl $0
8010607f:	6a 00                	push   $0x0
  pushl $56
80106081:	6a 38                	push   $0x38
  jmp alltraps
80106083:	e9 17 f9 ff ff       	jmp    8010599f <alltraps>

80106088 <vector57>:
.globl vector57
vector57:
  pushl $0
80106088:	6a 00                	push   $0x0
  pushl $57
8010608a:	6a 39                	push   $0x39
  jmp alltraps
8010608c:	e9 0e f9 ff ff       	jmp    8010599f <alltraps>

80106091 <vector58>:
.globl vector58
vector58:
  pushl $0
80106091:	6a 00                	push   $0x0
  pushl $58
80106093:	6a 3a                	push   $0x3a
  jmp alltraps
80106095:	e9 05 f9 ff ff       	jmp    8010599f <alltraps>

8010609a <vector59>:
.globl vector59
vector59:
  pushl $0
8010609a:	6a 00                	push   $0x0
  pushl $59
8010609c:	6a 3b                	push   $0x3b
  jmp alltraps
8010609e:	e9 fc f8 ff ff       	jmp    8010599f <alltraps>

801060a3 <vector60>:
.globl vector60
vector60:
  pushl $0
801060a3:	6a 00                	push   $0x0
  pushl $60
801060a5:	6a 3c                	push   $0x3c
  jmp alltraps
801060a7:	e9 f3 f8 ff ff       	jmp    8010599f <alltraps>

801060ac <vector61>:
.globl vector61
vector61:
  pushl $0
801060ac:	6a 00                	push   $0x0
  pushl $61
801060ae:	6a 3d                	push   $0x3d
  jmp alltraps
801060b0:	e9 ea f8 ff ff       	jmp    8010599f <alltraps>

801060b5 <vector62>:
.globl vector62
vector62:
  pushl $0
801060b5:	6a 00                	push   $0x0
  pushl $62
801060b7:	6a 3e                	push   $0x3e
  jmp alltraps
801060b9:	e9 e1 f8 ff ff       	jmp    8010599f <alltraps>

801060be <vector63>:
.globl vector63
vector63:
  pushl $0
801060be:	6a 00                	push   $0x0
  pushl $63
801060c0:	6a 3f                	push   $0x3f
  jmp alltraps
801060c2:	e9 d8 f8 ff ff       	jmp    8010599f <alltraps>

801060c7 <vector64>:
.globl vector64
vector64:
  pushl $0
801060c7:	6a 00                	push   $0x0
  pushl $64
801060c9:	6a 40                	push   $0x40
  jmp alltraps
801060cb:	e9 cf f8 ff ff       	jmp    8010599f <alltraps>

801060d0 <vector65>:
.globl vector65
vector65:
  pushl $0
801060d0:	6a 00                	push   $0x0
  pushl $65
801060d2:	6a 41                	push   $0x41
  jmp alltraps
801060d4:	e9 c6 f8 ff ff       	jmp    8010599f <alltraps>

801060d9 <vector66>:
.globl vector66
vector66:
  pushl $0
801060d9:	6a 00                	push   $0x0
  pushl $66
801060db:	6a 42                	push   $0x42
  jmp alltraps
801060dd:	e9 bd f8 ff ff       	jmp    8010599f <alltraps>

801060e2 <vector67>:
.globl vector67
vector67:
  pushl $0
801060e2:	6a 00                	push   $0x0
  pushl $67
801060e4:	6a 43                	push   $0x43
  jmp alltraps
801060e6:	e9 b4 f8 ff ff       	jmp    8010599f <alltraps>

801060eb <vector68>:
.globl vector68
vector68:
  pushl $0
801060eb:	6a 00                	push   $0x0
  pushl $68
801060ed:	6a 44                	push   $0x44
  jmp alltraps
801060ef:	e9 ab f8 ff ff       	jmp    8010599f <alltraps>

801060f4 <vector69>:
.globl vector69
vector69:
  pushl $0
801060f4:	6a 00                	push   $0x0
  pushl $69
801060f6:	6a 45                	push   $0x45
  jmp alltraps
801060f8:	e9 a2 f8 ff ff       	jmp    8010599f <alltraps>

801060fd <vector70>:
.globl vector70
vector70:
  pushl $0
801060fd:	6a 00                	push   $0x0
  pushl $70
801060ff:	6a 46                	push   $0x46
  jmp alltraps
80106101:	e9 99 f8 ff ff       	jmp    8010599f <alltraps>

80106106 <vector71>:
.globl vector71
vector71:
  pushl $0
80106106:	6a 00                	push   $0x0
  pushl $71
80106108:	6a 47                	push   $0x47
  jmp alltraps
8010610a:	e9 90 f8 ff ff       	jmp    8010599f <alltraps>

8010610f <vector72>:
.globl vector72
vector72:
  pushl $0
8010610f:	6a 00                	push   $0x0
  pushl $72
80106111:	6a 48                	push   $0x48
  jmp alltraps
80106113:	e9 87 f8 ff ff       	jmp    8010599f <alltraps>

80106118 <vector73>:
.globl vector73
vector73:
  pushl $0
80106118:	6a 00                	push   $0x0
  pushl $73
8010611a:	6a 49                	push   $0x49
  jmp alltraps
8010611c:	e9 7e f8 ff ff       	jmp    8010599f <alltraps>

80106121 <vector74>:
.globl vector74
vector74:
  pushl $0
80106121:	6a 00                	push   $0x0
  pushl $74
80106123:	6a 4a                	push   $0x4a
  jmp alltraps
80106125:	e9 75 f8 ff ff       	jmp    8010599f <alltraps>

8010612a <vector75>:
.globl vector75
vector75:
  pushl $0
8010612a:	6a 00                	push   $0x0
  pushl $75
8010612c:	6a 4b                	push   $0x4b
  jmp alltraps
8010612e:	e9 6c f8 ff ff       	jmp    8010599f <alltraps>

80106133 <vector76>:
.globl vector76
vector76:
  pushl $0
80106133:	6a 00                	push   $0x0
  pushl $76
80106135:	6a 4c                	push   $0x4c
  jmp alltraps
80106137:	e9 63 f8 ff ff       	jmp    8010599f <alltraps>

8010613c <vector77>:
.globl vector77
vector77:
  pushl $0
8010613c:	6a 00                	push   $0x0
  pushl $77
8010613e:	6a 4d                	push   $0x4d
  jmp alltraps
80106140:	e9 5a f8 ff ff       	jmp    8010599f <alltraps>

80106145 <vector78>:
.globl vector78
vector78:
  pushl $0
80106145:	6a 00                	push   $0x0
  pushl $78
80106147:	6a 4e                	push   $0x4e
  jmp alltraps
80106149:	e9 51 f8 ff ff       	jmp    8010599f <alltraps>

8010614e <vector79>:
.globl vector79
vector79:
  pushl $0
8010614e:	6a 00                	push   $0x0
  pushl $79
80106150:	6a 4f                	push   $0x4f
  jmp alltraps
80106152:	e9 48 f8 ff ff       	jmp    8010599f <alltraps>

80106157 <vector80>:
.globl vector80
vector80:
  pushl $0
80106157:	6a 00                	push   $0x0
  pushl $80
80106159:	6a 50                	push   $0x50
  jmp alltraps
8010615b:	e9 3f f8 ff ff       	jmp    8010599f <alltraps>

80106160 <vector81>:
.globl vector81
vector81:
  pushl $0
80106160:	6a 00                	push   $0x0
  pushl $81
80106162:	6a 51                	push   $0x51
  jmp alltraps
80106164:	e9 36 f8 ff ff       	jmp    8010599f <alltraps>

80106169 <vector82>:
.globl vector82
vector82:
  pushl $0
80106169:	6a 00                	push   $0x0
  pushl $82
8010616b:	6a 52                	push   $0x52
  jmp alltraps
8010616d:	e9 2d f8 ff ff       	jmp    8010599f <alltraps>

80106172 <vector83>:
.globl vector83
vector83:
  pushl $0
80106172:	6a 00                	push   $0x0
  pushl $83
80106174:	6a 53                	push   $0x53
  jmp alltraps
80106176:	e9 24 f8 ff ff       	jmp    8010599f <alltraps>

8010617b <vector84>:
.globl vector84
vector84:
  pushl $0
8010617b:	6a 00                	push   $0x0
  pushl $84
8010617d:	6a 54                	push   $0x54
  jmp alltraps
8010617f:	e9 1b f8 ff ff       	jmp    8010599f <alltraps>

80106184 <vector85>:
.globl vector85
vector85:
  pushl $0
80106184:	6a 00                	push   $0x0
  pushl $85
80106186:	6a 55                	push   $0x55
  jmp alltraps
80106188:	e9 12 f8 ff ff       	jmp    8010599f <alltraps>

8010618d <vector86>:
.globl vector86
vector86:
  pushl $0
8010618d:	6a 00                	push   $0x0
  pushl $86
8010618f:	6a 56                	push   $0x56
  jmp alltraps
80106191:	e9 09 f8 ff ff       	jmp    8010599f <alltraps>

80106196 <vector87>:
.globl vector87
vector87:
  pushl $0
80106196:	6a 00                	push   $0x0
  pushl $87
80106198:	6a 57                	push   $0x57
  jmp alltraps
8010619a:	e9 00 f8 ff ff       	jmp    8010599f <alltraps>

8010619f <vector88>:
.globl vector88
vector88:
  pushl $0
8010619f:	6a 00                	push   $0x0
  pushl $88
801061a1:	6a 58                	push   $0x58
  jmp alltraps
801061a3:	e9 f7 f7 ff ff       	jmp    8010599f <alltraps>

801061a8 <vector89>:
.globl vector89
vector89:
  pushl $0
801061a8:	6a 00                	push   $0x0
  pushl $89
801061aa:	6a 59                	push   $0x59
  jmp alltraps
801061ac:	e9 ee f7 ff ff       	jmp    8010599f <alltraps>

801061b1 <vector90>:
.globl vector90
vector90:
  pushl $0
801061b1:	6a 00                	push   $0x0
  pushl $90
801061b3:	6a 5a                	push   $0x5a
  jmp alltraps
801061b5:	e9 e5 f7 ff ff       	jmp    8010599f <alltraps>

801061ba <vector91>:
.globl vector91
vector91:
  pushl $0
801061ba:	6a 00                	push   $0x0
  pushl $91
801061bc:	6a 5b                	push   $0x5b
  jmp alltraps
801061be:	e9 dc f7 ff ff       	jmp    8010599f <alltraps>

801061c3 <vector92>:
.globl vector92
vector92:
  pushl $0
801061c3:	6a 00                	push   $0x0
  pushl $92
801061c5:	6a 5c                	push   $0x5c
  jmp alltraps
801061c7:	e9 d3 f7 ff ff       	jmp    8010599f <alltraps>

801061cc <vector93>:
.globl vector93
vector93:
  pushl $0
801061cc:	6a 00                	push   $0x0
  pushl $93
801061ce:	6a 5d                	push   $0x5d
  jmp alltraps
801061d0:	e9 ca f7 ff ff       	jmp    8010599f <alltraps>

801061d5 <vector94>:
.globl vector94
vector94:
  pushl $0
801061d5:	6a 00                	push   $0x0
  pushl $94
801061d7:	6a 5e                	push   $0x5e
  jmp alltraps
801061d9:	e9 c1 f7 ff ff       	jmp    8010599f <alltraps>

801061de <vector95>:
.globl vector95
vector95:
  pushl $0
801061de:	6a 00                	push   $0x0
  pushl $95
801061e0:	6a 5f                	push   $0x5f
  jmp alltraps
801061e2:	e9 b8 f7 ff ff       	jmp    8010599f <alltraps>

801061e7 <vector96>:
.globl vector96
vector96:
  pushl $0
801061e7:	6a 00                	push   $0x0
  pushl $96
801061e9:	6a 60                	push   $0x60
  jmp alltraps
801061eb:	e9 af f7 ff ff       	jmp    8010599f <alltraps>

801061f0 <vector97>:
.globl vector97
vector97:
  pushl $0
801061f0:	6a 00                	push   $0x0
  pushl $97
801061f2:	6a 61                	push   $0x61
  jmp alltraps
801061f4:	e9 a6 f7 ff ff       	jmp    8010599f <alltraps>

801061f9 <vector98>:
.globl vector98
vector98:
  pushl $0
801061f9:	6a 00                	push   $0x0
  pushl $98
801061fb:	6a 62                	push   $0x62
  jmp alltraps
801061fd:	e9 9d f7 ff ff       	jmp    8010599f <alltraps>

80106202 <vector99>:
.globl vector99
vector99:
  pushl $0
80106202:	6a 00                	push   $0x0
  pushl $99
80106204:	6a 63                	push   $0x63
  jmp alltraps
80106206:	e9 94 f7 ff ff       	jmp    8010599f <alltraps>

8010620b <vector100>:
.globl vector100
vector100:
  pushl $0
8010620b:	6a 00                	push   $0x0
  pushl $100
8010620d:	6a 64                	push   $0x64
  jmp alltraps
8010620f:	e9 8b f7 ff ff       	jmp    8010599f <alltraps>

80106214 <vector101>:
.globl vector101
vector101:
  pushl $0
80106214:	6a 00                	push   $0x0
  pushl $101
80106216:	6a 65                	push   $0x65
  jmp alltraps
80106218:	e9 82 f7 ff ff       	jmp    8010599f <alltraps>

8010621d <vector102>:
.globl vector102
vector102:
  pushl $0
8010621d:	6a 00                	push   $0x0
  pushl $102
8010621f:	6a 66                	push   $0x66
  jmp alltraps
80106221:	e9 79 f7 ff ff       	jmp    8010599f <alltraps>

80106226 <vector103>:
.globl vector103
vector103:
  pushl $0
80106226:	6a 00                	push   $0x0
  pushl $103
80106228:	6a 67                	push   $0x67
  jmp alltraps
8010622a:	e9 70 f7 ff ff       	jmp    8010599f <alltraps>

8010622f <vector104>:
.globl vector104
vector104:
  pushl $0
8010622f:	6a 00                	push   $0x0
  pushl $104
80106231:	6a 68                	push   $0x68
  jmp alltraps
80106233:	e9 67 f7 ff ff       	jmp    8010599f <alltraps>

80106238 <vector105>:
.globl vector105
vector105:
  pushl $0
80106238:	6a 00                	push   $0x0
  pushl $105
8010623a:	6a 69                	push   $0x69
  jmp alltraps
8010623c:	e9 5e f7 ff ff       	jmp    8010599f <alltraps>

80106241 <vector106>:
.globl vector106
vector106:
  pushl $0
80106241:	6a 00                	push   $0x0
  pushl $106
80106243:	6a 6a                	push   $0x6a
  jmp alltraps
80106245:	e9 55 f7 ff ff       	jmp    8010599f <alltraps>

8010624a <vector107>:
.globl vector107
vector107:
  pushl $0
8010624a:	6a 00                	push   $0x0
  pushl $107
8010624c:	6a 6b                	push   $0x6b
  jmp alltraps
8010624e:	e9 4c f7 ff ff       	jmp    8010599f <alltraps>

80106253 <vector108>:
.globl vector108
vector108:
  pushl $0
80106253:	6a 00                	push   $0x0
  pushl $108
80106255:	6a 6c                	push   $0x6c
  jmp alltraps
80106257:	e9 43 f7 ff ff       	jmp    8010599f <alltraps>

8010625c <vector109>:
.globl vector109
vector109:
  pushl $0
8010625c:	6a 00                	push   $0x0
  pushl $109
8010625e:	6a 6d                	push   $0x6d
  jmp alltraps
80106260:	e9 3a f7 ff ff       	jmp    8010599f <alltraps>

80106265 <vector110>:
.globl vector110
vector110:
  pushl $0
80106265:	6a 00                	push   $0x0
  pushl $110
80106267:	6a 6e                	push   $0x6e
  jmp alltraps
80106269:	e9 31 f7 ff ff       	jmp    8010599f <alltraps>

8010626e <vector111>:
.globl vector111
vector111:
  pushl $0
8010626e:	6a 00                	push   $0x0
  pushl $111
80106270:	6a 6f                	push   $0x6f
  jmp alltraps
80106272:	e9 28 f7 ff ff       	jmp    8010599f <alltraps>

80106277 <vector112>:
.globl vector112
vector112:
  pushl $0
80106277:	6a 00                	push   $0x0
  pushl $112
80106279:	6a 70                	push   $0x70
  jmp alltraps
8010627b:	e9 1f f7 ff ff       	jmp    8010599f <alltraps>

80106280 <vector113>:
.globl vector113
vector113:
  pushl $0
80106280:	6a 00                	push   $0x0
  pushl $113
80106282:	6a 71                	push   $0x71
  jmp alltraps
80106284:	e9 16 f7 ff ff       	jmp    8010599f <alltraps>

80106289 <vector114>:
.globl vector114
vector114:
  pushl $0
80106289:	6a 00                	push   $0x0
  pushl $114
8010628b:	6a 72                	push   $0x72
  jmp alltraps
8010628d:	e9 0d f7 ff ff       	jmp    8010599f <alltraps>

80106292 <vector115>:
.globl vector115
vector115:
  pushl $0
80106292:	6a 00                	push   $0x0
  pushl $115
80106294:	6a 73                	push   $0x73
  jmp alltraps
80106296:	e9 04 f7 ff ff       	jmp    8010599f <alltraps>

8010629b <vector116>:
.globl vector116
vector116:
  pushl $0
8010629b:	6a 00                	push   $0x0
  pushl $116
8010629d:	6a 74                	push   $0x74
  jmp alltraps
8010629f:	e9 fb f6 ff ff       	jmp    8010599f <alltraps>

801062a4 <vector117>:
.globl vector117
vector117:
  pushl $0
801062a4:	6a 00                	push   $0x0
  pushl $117
801062a6:	6a 75                	push   $0x75
  jmp alltraps
801062a8:	e9 f2 f6 ff ff       	jmp    8010599f <alltraps>

801062ad <vector118>:
.globl vector118
vector118:
  pushl $0
801062ad:	6a 00                	push   $0x0
  pushl $118
801062af:	6a 76                	push   $0x76
  jmp alltraps
801062b1:	e9 e9 f6 ff ff       	jmp    8010599f <alltraps>

801062b6 <vector119>:
.globl vector119
vector119:
  pushl $0
801062b6:	6a 00                	push   $0x0
  pushl $119
801062b8:	6a 77                	push   $0x77
  jmp alltraps
801062ba:	e9 e0 f6 ff ff       	jmp    8010599f <alltraps>

801062bf <vector120>:
.globl vector120
vector120:
  pushl $0
801062bf:	6a 00                	push   $0x0
  pushl $120
801062c1:	6a 78                	push   $0x78
  jmp alltraps
801062c3:	e9 d7 f6 ff ff       	jmp    8010599f <alltraps>

801062c8 <vector121>:
.globl vector121
vector121:
  pushl $0
801062c8:	6a 00                	push   $0x0
  pushl $121
801062ca:	6a 79                	push   $0x79
  jmp alltraps
801062cc:	e9 ce f6 ff ff       	jmp    8010599f <alltraps>

801062d1 <vector122>:
.globl vector122
vector122:
  pushl $0
801062d1:	6a 00                	push   $0x0
  pushl $122
801062d3:	6a 7a                	push   $0x7a
  jmp alltraps
801062d5:	e9 c5 f6 ff ff       	jmp    8010599f <alltraps>

801062da <vector123>:
.globl vector123
vector123:
  pushl $0
801062da:	6a 00                	push   $0x0
  pushl $123
801062dc:	6a 7b                	push   $0x7b
  jmp alltraps
801062de:	e9 bc f6 ff ff       	jmp    8010599f <alltraps>

801062e3 <vector124>:
.globl vector124
vector124:
  pushl $0
801062e3:	6a 00                	push   $0x0
  pushl $124
801062e5:	6a 7c                	push   $0x7c
  jmp alltraps
801062e7:	e9 b3 f6 ff ff       	jmp    8010599f <alltraps>

801062ec <vector125>:
.globl vector125
vector125:
  pushl $0
801062ec:	6a 00                	push   $0x0
  pushl $125
801062ee:	6a 7d                	push   $0x7d
  jmp alltraps
801062f0:	e9 aa f6 ff ff       	jmp    8010599f <alltraps>

801062f5 <vector126>:
.globl vector126
vector126:
  pushl $0
801062f5:	6a 00                	push   $0x0
  pushl $126
801062f7:	6a 7e                	push   $0x7e
  jmp alltraps
801062f9:	e9 a1 f6 ff ff       	jmp    8010599f <alltraps>

801062fe <vector127>:
.globl vector127
vector127:
  pushl $0
801062fe:	6a 00                	push   $0x0
  pushl $127
80106300:	6a 7f                	push   $0x7f
  jmp alltraps
80106302:	e9 98 f6 ff ff       	jmp    8010599f <alltraps>

80106307 <vector128>:
.globl vector128
vector128:
  pushl $0
80106307:	6a 00                	push   $0x0
  pushl $128
80106309:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010630e:	e9 8c f6 ff ff       	jmp    8010599f <alltraps>

80106313 <vector129>:
.globl vector129
vector129:
  pushl $0
80106313:	6a 00                	push   $0x0
  pushl $129
80106315:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010631a:	e9 80 f6 ff ff       	jmp    8010599f <alltraps>

8010631f <vector130>:
.globl vector130
vector130:
  pushl $0
8010631f:	6a 00                	push   $0x0
  pushl $130
80106321:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106326:	e9 74 f6 ff ff       	jmp    8010599f <alltraps>

8010632b <vector131>:
.globl vector131
vector131:
  pushl $0
8010632b:	6a 00                	push   $0x0
  pushl $131
8010632d:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106332:	e9 68 f6 ff ff       	jmp    8010599f <alltraps>

80106337 <vector132>:
.globl vector132
vector132:
  pushl $0
80106337:	6a 00                	push   $0x0
  pushl $132
80106339:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010633e:	e9 5c f6 ff ff       	jmp    8010599f <alltraps>

80106343 <vector133>:
.globl vector133
vector133:
  pushl $0
80106343:	6a 00                	push   $0x0
  pushl $133
80106345:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010634a:	e9 50 f6 ff ff       	jmp    8010599f <alltraps>

8010634f <vector134>:
.globl vector134
vector134:
  pushl $0
8010634f:	6a 00                	push   $0x0
  pushl $134
80106351:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106356:	e9 44 f6 ff ff       	jmp    8010599f <alltraps>

8010635b <vector135>:
.globl vector135
vector135:
  pushl $0
8010635b:	6a 00                	push   $0x0
  pushl $135
8010635d:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106362:	e9 38 f6 ff ff       	jmp    8010599f <alltraps>

80106367 <vector136>:
.globl vector136
vector136:
  pushl $0
80106367:	6a 00                	push   $0x0
  pushl $136
80106369:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010636e:	e9 2c f6 ff ff       	jmp    8010599f <alltraps>

80106373 <vector137>:
.globl vector137
vector137:
  pushl $0
80106373:	6a 00                	push   $0x0
  pushl $137
80106375:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010637a:	e9 20 f6 ff ff       	jmp    8010599f <alltraps>

8010637f <vector138>:
.globl vector138
vector138:
  pushl $0
8010637f:	6a 00                	push   $0x0
  pushl $138
80106381:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106386:	e9 14 f6 ff ff       	jmp    8010599f <alltraps>

8010638b <vector139>:
.globl vector139
vector139:
  pushl $0
8010638b:	6a 00                	push   $0x0
  pushl $139
8010638d:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106392:	e9 08 f6 ff ff       	jmp    8010599f <alltraps>

80106397 <vector140>:
.globl vector140
vector140:
  pushl $0
80106397:	6a 00                	push   $0x0
  pushl $140
80106399:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010639e:	e9 fc f5 ff ff       	jmp    8010599f <alltraps>

801063a3 <vector141>:
.globl vector141
vector141:
  pushl $0
801063a3:	6a 00                	push   $0x0
  pushl $141
801063a5:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801063aa:	e9 f0 f5 ff ff       	jmp    8010599f <alltraps>

801063af <vector142>:
.globl vector142
vector142:
  pushl $0
801063af:	6a 00                	push   $0x0
  pushl $142
801063b1:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801063b6:	e9 e4 f5 ff ff       	jmp    8010599f <alltraps>

801063bb <vector143>:
.globl vector143
vector143:
  pushl $0
801063bb:	6a 00                	push   $0x0
  pushl $143
801063bd:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801063c2:	e9 d8 f5 ff ff       	jmp    8010599f <alltraps>

801063c7 <vector144>:
.globl vector144
vector144:
  pushl $0
801063c7:	6a 00                	push   $0x0
  pushl $144
801063c9:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801063ce:	e9 cc f5 ff ff       	jmp    8010599f <alltraps>

801063d3 <vector145>:
.globl vector145
vector145:
  pushl $0
801063d3:	6a 00                	push   $0x0
  pushl $145
801063d5:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801063da:	e9 c0 f5 ff ff       	jmp    8010599f <alltraps>

801063df <vector146>:
.globl vector146
vector146:
  pushl $0
801063df:	6a 00                	push   $0x0
  pushl $146
801063e1:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801063e6:	e9 b4 f5 ff ff       	jmp    8010599f <alltraps>

801063eb <vector147>:
.globl vector147
vector147:
  pushl $0
801063eb:	6a 00                	push   $0x0
  pushl $147
801063ed:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801063f2:	e9 a8 f5 ff ff       	jmp    8010599f <alltraps>

801063f7 <vector148>:
.globl vector148
vector148:
  pushl $0
801063f7:	6a 00                	push   $0x0
  pushl $148
801063f9:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801063fe:	e9 9c f5 ff ff       	jmp    8010599f <alltraps>

80106403 <vector149>:
.globl vector149
vector149:
  pushl $0
80106403:	6a 00                	push   $0x0
  pushl $149
80106405:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010640a:	e9 90 f5 ff ff       	jmp    8010599f <alltraps>

8010640f <vector150>:
.globl vector150
vector150:
  pushl $0
8010640f:	6a 00                	push   $0x0
  pushl $150
80106411:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106416:	e9 84 f5 ff ff       	jmp    8010599f <alltraps>

8010641b <vector151>:
.globl vector151
vector151:
  pushl $0
8010641b:	6a 00                	push   $0x0
  pushl $151
8010641d:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106422:	e9 78 f5 ff ff       	jmp    8010599f <alltraps>

80106427 <vector152>:
.globl vector152
vector152:
  pushl $0
80106427:	6a 00                	push   $0x0
  pushl $152
80106429:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010642e:	e9 6c f5 ff ff       	jmp    8010599f <alltraps>

80106433 <vector153>:
.globl vector153
vector153:
  pushl $0
80106433:	6a 00                	push   $0x0
  pushl $153
80106435:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010643a:	e9 60 f5 ff ff       	jmp    8010599f <alltraps>

8010643f <vector154>:
.globl vector154
vector154:
  pushl $0
8010643f:	6a 00                	push   $0x0
  pushl $154
80106441:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106446:	e9 54 f5 ff ff       	jmp    8010599f <alltraps>

8010644b <vector155>:
.globl vector155
vector155:
  pushl $0
8010644b:	6a 00                	push   $0x0
  pushl $155
8010644d:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106452:	e9 48 f5 ff ff       	jmp    8010599f <alltraps>

80106457 <vector156>:
.globl vector156
vector156:
  pushl $0
80106457:	6a 00                	push   $0x0
  pushl $156
80106459:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010645e:	e9 3c f5 ff ff       	jmp    8010599f <alltraps>

80106463 <vector157>:
.globl vector157
vector157:
  pushl $0
80106463:	6a 00                	push   $0x0
  pushl $157
80106465:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010646a:	e9 30 f5 ff ff       	jmp    8010599f <alltraps>

8010646f <vector158>:
.globl vector158
vector158:
  pushl $0
8010646f:	6a 00                	push   $0x0
  pushl $158
80106471:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106476:	e9 24 f5 ff ff       	jmp    8010599f <alltraps>

8010647b <vector159>:
.globl vector159
vector159:
  pushl $0
8010647b:	6a 00                	push   $0x0
  pushl $159
8010647d:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106482:	e9 18 f5 ff ff       	jmp    8010599f <alltraps>

80106487 <vector160>:
.globl vector160
vector160:
  pushl $0
80106487:	6a 00                	push   $0x0
  pushl $160
80106489:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010648e:	e9 0c f5 ff ff       	jmp    8010599f <alltraps>

80106493 <vector161>:
.globl vector161
vector161:
  pushl $0
80106493:	6a 00                	push   $0x0
  pushl $161
80106495:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010649a:	e9 00 f5 ff ff       	jmp    8010599f <alltraps>

8010649f <vector162>:
.globl vector162
vector162:
  pushl $0
8010649f:	6a 00                	push   $0x0
  pushl $162
801064a1:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801064a6:	e9 f4 f4 ff ff       	jmp    8010599f <alltraps>

801064ab <vector163>:
.globl vector163
vector163:
  pushl $0
801064ab:	6a 00                	push   $0x0
  pushl $163
801064ad:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801064b2:	e9 e8 f4 ff ff       	jmp    8010599f <alltraps>

801064b7 <vector164>:
.globl vector164
vector164:
  pushl $0
801064b7:	6a 00                	push   $0x0
  pushl $164
801064b9:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801064be:	e9 dc f4 ff ff       	jmp    8010599f <alltraps>

801064c3 <vector165>:
.globl vector165
vector165:
  pushl $0
801064c3:	6a 00                	push   $0x0
  pushl $165
801064c5:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801064ca:	e9 d0 f4 ff ff       	jmp    8010599f <alltraps>

801064cf <vector166>:
.globl vector166
vector166:
  pushl $0
801064cf:	6a 00                	push   $0x0
  pushl $166
801064d1:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801064d6:	e9 c4 f4 ff ff       	jmp    8010599f <alltraps>

801064db <vector167>:
.globl vector167
vector167:
  pushl $0
801064db:	6a 00                	push   $0x0
  pushl $167
801064dd:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801064e2:	e9 b8 f4 ff ff       	jmp    8010599f <alltraps>

801064e7 <vector168>:
.globl vector168
vector168:
  pushl $0
801064e7:	6a 00                	push   $0x0
  pushl $168
801064e9:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801064ee:	e9 ac f4 ff ff       	jmp    8010599f <alltraps>

801064f3 <vector169>:
.globl vector169
vector169:
  pushl $0
801064f3:	6a 00                	push   $0x0
  pushl $169
801064f5:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801064fa:	e9 a0 f4 ff ff       	jmp    8010599f <alltraps>

801064ff <vector170>:
.globl vector170
vector170:
  pushl $0
801064ff:	6a 00                	push   $0x0
  pushl $170
80106501:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106506:	e9 94 f4 ff ff       	jmp    8010599f <alltraps>

8010650b <vector171>:
.globl vector171
vector171:
  pushl $0
8010650b:	6a 00                	push   $0x0
  pushl $171
8010650d:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106512:	e9 88 f4 ff ff       	jmp    8010599f <alltraps>

80106517 <vector172>:
.globl vector172
vector172:
  pushl $0
80106517:	6a 00                	push   $0x0
  pushl $172
80106519:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010651e:	e9 7c f4 ff ff       	jmp    8010599f <alltraps>

80106523 <vector173>:
.globl vector173
vector173:
  pushl $0
80106523:	6a 00                	push   $0x0
  pushl $173
80106525:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010652a:	e9 70 f4 ff ff       	jmp    8010599f <alltraps>

8010652f <vector174>:
.globl vector174
vector174:
  pushl $0
8010652f:	6a 00                	push   $0x0
  pushl $174
80106531:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106536:	e9 64 f4 ff ff       	jmp    8010599f <alltraps>

8010653b <vector175>:
.globl vector175
vector175:
  pushl $0
8010653b:	6a 00                	push   $0x0
  pushl $175
8010653d:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106542:	e9 58 f4 ff ff       	jmp    8010599f <alltraps>

80106547 <vector176>:
.globl vector176
vector176:
  pushl $0
80106547:	6a 00                	push   $0x0
  pushl $176
80106549:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010654e:	e9 4c f4 ff ff       	jmp    8010599f <alltraps>

80106553 <vector177>:
.globl vector177
vector177:
  pushl $0
80106553:	6a 00                	push   $0x0
  pushl $177
80106555:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010655a:	e9 40 f4 ff ff       	jmp    8010599f <alltraps>

8010655f <vector178>:
.globl vector178
vector178:
  pushl $0
8010655f:	6a 00                	push   $0x0
  pushl $178
80106561:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106566:	e9 34 f4 ff ff       	jmp    8010599f <alltraps>

8010656b <vector179>:
.globl vector179
vector179:
  pushl $0
8010656b:	6a 00                	push   $0x0
  pushl $179
8010656d:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106572:	e9 28 f4 ff ff       	jmp    8010599f <alltraps>

80106577 <vector180>:
.globl vector180
vector180:
  pushl $0
80106577:	6a 00                	push   $0x0
  pushl $180
80106579:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010657e:	e9 1c f4 ff ff       	jmp    8010599f <alltraps>

80106583 <vector181>:
.globl vector181
vector181:
  pushl $0
80106583:	6a 00                	push   $0x0
  pushl $181
80106585:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010658a:	e9 10 f4 ff ff       	jmp    8010599f <alltraps>

8010658f <vector182>:
.globl vector182
vector182:
  pushl $0
8010658f:	6a 00                	push   $0x0
  pushl $182
80106591:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106596:	e9 04 f4 ff ff       	jmp    8010599f <alltraps>

8010659b <vector183>:
.globl vector183
vector183:
  pushl $0
8010659b:	6a 00                	push   $0x0
  pushl $183
8010659d:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801065a2:	e9 f8 f3 ff ff       	jmp    8010599f <alltraps>

801065a7 <vector184>:
.globl vector184
vector184:
  pushl $0
801065a7:	6a 00                	push   $0x0
  pushl $184
801065a9:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801065ae:	e9 ec f3 ff ff       	jmp    8010599f <alltraps>

801065b3 <vector185>:
.globl vector185
vector185:
  pushl $0
801065b3:	6a 00                	push   $0x0
  pushl $185
801065b5:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801065ba:	e9 e0 f3 ff ff       	jmp    8010599f <alltraps>

801065bf <vector186>:
.globl vector186
vector186:
  pushl $0
801065bf:	6a 00                	push   $0x0
  pushl $186
801065c1:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801065c6:	e9 d4 f3 ff ff       	jmp    8010599f <alltraps>

801065cb <vector187>:
.globl vector187
vector187:
  pushl $0
801065cb:	6a 00                	push   $0x0
  pushl $187
801065cd:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801065d2:	e9 c8 f3 ff ff       	jmp    8010599f <alltraps>

801065d7 <vector188>:
.globl vector188
vector188:
  pushl $0
801065d7:	6a 00                	push   $0x0
  pushl $188
801065d9:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801065de:	e9 bc f3 ff ff       	jmp    8010599f <alltraps>

801065e3 <vector189>:
.globl vector189
vector189:
  pushl $0
801065e3:	6a 00                	push   $0x0
  pushl $189
801065e5:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801065ea:	e9 b0 f3 ff ff       	jmp    8010599f <alltraps>

801065ef <vector190>:
.globl vector190
vector190:
  pushl $0
801065ef:	6a 00                	push   $0x0
  pushl $190
801065f1:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801065f6:	e9 a4 f3 ff ff       	jmp    8010599f <alltraps>

801065fb <vector191>:
.globl vector191
vector191:
  pushl $0
801065fb:	6a 00                	push   $0x0
  pushl $191
801065fd:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106602:	e9 98 f3 ff ff       	jmp    8010599f <alltraps>

80106607 <vector192>:
.globl vector192
vector192:
  pushl $0
80106607:	6a 00                	push   $0x0
  pushl $192
80106609:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010660e:	e9 8c f3 ff ff       	jmp    8010599f <alltraps>

80106613 <vector193>:
.globl vector193
vector193:
  pushl $0
80106613:	6a 00                	push   $0x0
  pushl $193
80106615:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010661a:	e9 80 f3 ff ff       	jmp    8010599f <alltraps>

8010661f <vector194>:
.globl vector194
vector194:
  pushl $0
8010661f:	6a 00                	push   $0x0
  pushl $194
80106621:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106626:	e9 74 f3 ff ff       	jmp    8010599f <alltraps>

8010662b <vector195>:
.globl vector195
vector195:
  pushl $0
8010662b:	6a 00                	push   $0x0
  pushl $195
8010662d:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106632:	e9 68 f3 ff ff       	jmp    8010599f <alltraps>

80106637 <vector196>:
.globl vector196
vector196:
  pushl $0
80106637:	6a 00                	push   $0x0
  pushl $196
80106639:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010663e:	e9 5c f3 ff ff       	jmp    8010599f <alltraps>

80106643 <vector197>:
.globl vector197
vector197:
  pushl $0
80106643:	6a 00                	push   $0x0
  pushl $197
80106645:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010664a:	e9 50 f3 ff ff       	jmp    8010599f <alltraps>

8010664f <vector198>:
.globl vector198
vector198:
  pushl $0
8010664f:	6a 00                	push   $0x0
  pushl $198
80106651:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106656:	e9 44 f3 ff ff       	jmp    8010599f <alltraps>

8010665b <vector199>:
.globl vector199
vector199:
  pushl $0
8010665b:	6a 00                	push   $0x0
  pushl $199
8010665d:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106662:	e9 38 f3 ff ff       	jmp    8010599f <alltraps>

80106667 <vector200>:
.globl vector200
vector200:
  pushl $0
80106667:	6a 00                	push   $0x0
  pushl $200
80106669:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010666e:	e9 2c f3 ff ff       	jmp    8010599f <alltraps>

80106673 <vector201>:
.globl vector201
vector201:
  pushl $0
80106673:	6a 00                	push   $0x0
  pushl $201
80106675:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010667a:	e9 20 f3 ff ff       	jmp    8010599f <alltraps>

8010667f <vector202>:
.globl vector202
vector202:
  pushl $0
8010667f:	6a 00                	push   $0x0
  pushl $202
80106681:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106686:	e9 14 f3 ff ff       	jmp    8010599f <alltraps>

8010668b <vector203>:
.globl vector203
vector203:
  pushl $0
8010668b:	6a 00                	push   $0x0
  pushl $203
8010668d:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106692:	e9 08 f3 ff ff       	jmp    8010599f <alltraps>

80106697 <vector204>:
.globl vector204
vector204:
  pushl $0
80106697:	6a 00                	push   $0x0
  pushl $204
80106699:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010669e:	e9 fc f2 ff ff       	jmp    8010599f <alltraps>

801066a3 <vector205>:
.globl vector205
vector205:
  pushl $0
801066a3:	6a 00                	push   $0x0
  pushl $205
801066a5:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801066aa:	e9 f0 f2 ff ff       	jmp    8010599f <alltraps>

801066af <vector206>:
.globl vector206
vector206:
  pushl $0
801066af:	6a 00                	push   $0x0
  pushl $206
801066b1:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801066b6:	e9 e4 f2 ff ff       	jmp    8010599f <alltraps>

801066bb <vector207>:
.globl vector207
vector207:
  pushl $0
801066bb:	6a 00                	push   $0x0
  pushl $207
801066bd:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801066c2:	e9 d8 f2 ff ff       	jmp    8010599f <alltraps>

801066c7 <vector208>:
.globl vector208
vector208:
  pushl $0
801066c7:	6a 00                	push   $0x0
  pushl $208
801066c9:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801066ce:	e9 cc f2 ff ff       	jmp    8010599f <alltraps>

801066d3 <vector209>:
.globl vector209
vector209:
  pushl $0
801066d3:	6a 00                	push   $0x0
  pushl $209
801066d5:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801066da:	e9 c0 f2 ff ff       	jmp    8010599f <alltraps>

801066df <vector210>:
.globl vector210
vector210:
  pushl $0
801066df:	6a 00                	push   $0x0
  pushl $210
801066e1:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801066e6:	e9 b4 f2 ff ff       	jmp    8010599f <alltraps>

801066eb <vector211>:
.globl vector211
vector211:
  pushl $0
801066eb:	6a 00                	push   $0x0
  pushl $211
801066ed:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801066f2:	e9 a8 f2 ff ff       	jmp    8010599f <alltraps>

801066f7 <vector212>:
.globl vector212
vector212:
  pushl $0
801066f7:	6a 00                	push   $0x0
  pushl $212
801066f9:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801066fe:	e9 9c f2 ff ff       	jmp    8010599f <alltraps>

80106703 <vector213>:
.globl vector213
vector213:
  pushl $0
80106703:	6a 00                	push   $0x0
  pushl $213
80106705:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010670a:	e9 90 f2 ff ff       	jmp    8010599f <alltraps>

8010670f <vector214>:
.globl vector214
vector214:
  pushl $0
8010670f:	6a 00                	push   $0x0
  pushl $214
80106711:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106716:	e9 84 f2 ff ff       	jmp    8010599f <alltraps>

8010671b <vector215>:
.globl vector215
vector215:
  pushl $0
8010671b:	6a 00                	push   $0x0
  pushl $215
8010671d:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106722:	e9 78 f2 ff ff       	jmp    8010599f <alltraps>

80106727 <vector216>:
.globl vector216
vector216:
  pushl $0
80106727:	6a 00                	push   $0x0
  pushl $216
80106729:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010672e:	e9 6c f2 ff ff       	jmp    8010599f <alltraps>

80106733 <vector217>:
.globl vector217
vector217:
  pushl $0
80106733:	6a 00                	push   $0x0
  pushl $217
80106735:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010673a:	e9 60 f2 ff ff       	jmp    8010599f <alltraps>

8010673f <vector218>:
.globl vector218
vector218:
  pushl $0
8010673f:	6a 00                	push   $0x0
  pushl $218
80106741:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106746:	e9 54 f2 ff ff       	jmp    8010599f <alltraps>

8010674b <vector219>:
.globl vector219
vector219:
  pushl $0
8010674b:	6a 00                	push   $0x0
  pushl $219
8010674d:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106752:	e9 48 f2 ff ff       	jmp    8010599f <alltraps>

80106757 <vector220>:
.globl vector220
vector220:
  pushl $0
80106757:	6a 00                	push   $0x0
  pushl $220
80106759:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010675e:	e9 3c f2 ff ff       	jmp    8010599f <alltraps>

80106763 <vector221>:
.globl vector221
vector221:
  pushl $0
80106763:	6a 00                	push   $0x0
  pushl $221
80106765:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010676a:	e9 30 f2 ff ff       	jmp    8010599f <alltraps>

8010676f <vector222>:
.globl vector222
vector222:
  pushl $0
8010676f:	6a 00                	push   $0x0
  pushl $222
80106771:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106776:	e9 24 f2 ff ff       	jmp    8010599f <alltraps>

8010677b <vector223>:
.globl vector223
vector223:
  pushl $0
8010677b:	6a 00                	push   $0x0
  pushl $223
8010677d:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106782:	e9 18 f2 ff ff       	jmp    8010599f <alltraps>

80106787 <vector224>:
.globl vector224
vector224:
  pushl $0
80106787:	6a 00                	push   $0x0
  pushl $224
80106789:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010678e:	e9 0c f2 ff ff       	jmp    8010599f <alltraps>

80106793 <vector225>:
.globl vector225
vector225:
  pushl $0
80106793:	6a 00                	push   $0x0
  pushl $225
80106795:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010679a:	e9 00 f2 ff ff       	jmp    8010599f <alltraps>

8010679f <vector226>:
.globl vector226
vector226:
  pushl $0
8010679f:	6a 00                	push   $0x0
  pushl $226
801067a1:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801067a6:	e9 f4 f1 ff ff       	jmp    8010599f <alltraps>

801067ab <vector227>:
.globl vector227
vector227:
  pushl $0
801067ab:	6a 00                	push   $0x0
  pushl $227
801067ad:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801067b2:	e9 e8 f1 ff ff       	jmp    8010599f <alltraps>

801067b7 <vector228>:
.globl vector228
vector228:
  pushl $0
801067b7:	6a 00                	push   $0x0
  pushl $228
801067b9:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801067be:	e9 dc f1 ff ff       	jmp    8010599f <alltraps>

801067c3 <vector229>:
.globl vector229
vector229:
  pushl $0
801067c3:	6a 00                	push   $0x0
  pushl $229
801067c5:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801067ca:	e9 d0 f1 ff ff       	jmp    8010599f <alltraps>

801067cf <vector230>:
.globl vector230
vector230:
  pushl $0
801067cf:	6a 00                	push   $0x0
  pushl $230
801067d1:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801067d6:	e9 c4 f1 ff ff       	jmp    8010599f <alltraps>

801067db <vector231>:
.globl vector231
vector231:
  pushl $0
801067db:	6a 00                	push   $0x0
  pushl $231
801067dd:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801067e2:	e9 b8 f1 ff ff       	jmp    8010599f <alltraps>

801067e7 <vector232>:
.globl vector232
vector232:
  pushl $0
801067e7:	6a 00                	push   $0x0
  pushl $232
801067e9:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801067ee:	e9 ac f1 ff ff       	jmp    8010599f <alltraps>

801067f3 <vector233>:
.globl vector233
vector233:
  pushl $0
801067f3:	6a 00                	push   $0x0
  pushl $233
801067f5:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801067fa:	e9 a0 f1 ff ff       	jmp    8010599f <alltraps>

801067ff <vector234>:
.globl vector234
vector234:
  pushl $0
801067ff:	6a 00                	push   $0x0
  pushl $234
80106801:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106806:	e9 94 f1 ff ff       	jmp    8010599f <alltraps>

8010680b <vector235>:
.globl vector235
vector235:
  pushl $0
8010680b:	6a 00                	push   $0x0
  pushl $235
8010680d:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106812:	e9 88 f1 ff ff       	jmp    8010599f <alltraps>

80106817 <vector236>:
.globl vector236
vector236:
  pushl $0
80106817:	6a 00                	push   $0x0
  pushl $236
80106819:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010681e:	e9 7c f1 ff ff       	jmp    8010599f <alltraps>

80106823 <vector237>:
.globl vector237
vector237:
  pushl $0
80106823:	6a 00                	push   $0x0
  pushl $237
80106825:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010682a:	e9 70 f1 ff ff       	jmp    8010599f <alltraps>

8010682f <vector238>:
.globl vector238
vector238:
  pushl $0
8010682f:	6a 00                	push   $0x0
  pushl $238
80106831:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80106836:	e9 64 f1 ff ff       	jmp    8010599f <alltraps>

8010683b <vector239>:
.globl vector239
vector239:
  pushl $0
8010683b:	6a 00                	push   $0x0
  pushl $239
8010683d:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106842:	e9 58 f1 ff ff       	jmp    8010599f <alltraps>

80106847 <vector240>:
.globl vector240
vector240:
  pushl $0
80106847:	6a 00                	push   $0x0
  pushl $240
80106849:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010684e:	e9 4c f1 ff ff       	jmp    8010599f <alltraps>

80106853 <vector241>:
.globl vector241
vector241:
  pushl $0
80106853:	6a 00                	push   $0x0
  pushl $241
80106855:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010685a:	e9 40 f1 ff ff       	jmp    8010599f <alltraps>

8010685f <vector242>:
.globl vector242
vector242:
  pushl $0
8010685f:	6a 00                	push   $0x0
  pushl $242
80106861:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106866:	e9 34 f1 ff ff       	jmp    8010599f <alltraps>

8010686b <vector243>:
.globl vector243
vector243:
  pushl $0
8010686b:	6a 00                	push   $0x0
  pushl $243
8010686d:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80106872:	e9 28 f1 ff ff       	jmp    8010599f <alltraps>

80106877 <vector244>:
.globl vector244
vector244:
  pushl $0
80106877:	6a 00                	push   $0x0
  pushl $244
80106879:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010687e:	e9 1c f1 ff ff       	jmp    8010599f <alltraps>

80106883 <vector245>:
.globl vector245
vector245:
  pushl $0
80106883:	6a 00                	push   $0x0
  pushl $245
80106885:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010688a:	e9 10 f1 ff ff       	jmp    8010599f <alltraps>

8010688f <vector246>:
.globl vector246
vector246:
  pushl $0
8010688f:	6a 00                	push   $0x0
  pushl $246
80106891:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106896:	e9 04 f1 ff ff       	jmp    8010599f <alltraps>

8010689b <vector247>:
.globl vector247
vector247:
  pushl $0
8010689b:	6a 00                	push   $0x0
  pushl $247
8010689d:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801068a2:	e9 f8 f0 ff ff       	jmp    8010599f <alltraps>

801068a7 <vector248>:
.globl vector248
vector248:
  pushl $0
801068a7:	6a 00                	push   $0x0
  pushl $248
801068a9:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801068ae:	e9 ec f0 ff ff       	jmp    8010599f <alltraps>

801068b3 <vector249>:
.globl vector249
vector249:
  pushl $0
801068b3:	6a 00                	push   $0x0
  pushl $249
801068b5:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801068ba:	e9 e0 f0 ff ff       	jmp    8010599f <alltraps>

801068bf <vector250>:
.globl vector250
vector250:
  pushl $0
801068bf:	6a 00                	push   $0x0
  pushl $250
801068c1:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801068c6:	e9 d4 f0 ff ff       	jmp    8010599f <alltraps>

801068cb <vector251>:
.globl vector251
vector251:
  pushl $0
801068cb:	6a 00                	push   $0x0
  pushl $251
801068cd:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801068d2:	e9 c8 f0 ff ff       	jmp    8010599f <alltraps>

801068d7 <vector252>:
.globl vector252
vector252:
  pushl $0
801068d7:	6a 00                	push   $0x0
  pushl $252
801068d9:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801068de:	e9 bc f0 ff ff       	jmp    8010599f <alltraps>

801068e3 <vector253>:
.globl vector253
vector253:
  pushl $0
801068e3:	6a 00                	push   $0x0
  pushl $253
801068e5:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801068ea:	e9 b0 f0 ff ff       	jmp    8010599f <alltraps>

801068ef <vector254>:
.globl vector254
vector254:
  pushl $0
801068ef:	6a 00                	push   $0x0
  pushl $254
801068f1:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801068f6:	e9 a4 f0 ff ff       	jmp    8010599f <alltraps>

801068fb <vector255>:
.globl vector255
vector255:
  pushl $0
801068fb:	6a 00                	push   $0x0
  pushl $255
801068fd:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80106902:	e9 98 f0 ff ff       	jmp    8010599f <alltraps>
80106907:	66 90                	xchg   %ax,%ax
80106909:	66 90                	xchg   %ax,%ax
8010690b:	66 90                	xchg   %ax,%ax
8010690d:	66 90                	xchg   %ax,%ax
8010690f:	90                   	nop

80106910 <deallocuvm.part.0>:
// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80106910:	55                   	push   %ebp
80106911:	89 e5                	mov    %esp,%ebp
80106913:	57                   	push   %edi
80106914:	56                   	push   %esi
80106915:	53                   	push   %ebx
  uint a, pa;

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
80106916:	8d 99 ff 0f 00 00    	lea    0xfff(%ecx),%ebx
8010691c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80106922:	83 ec 1c             	sub    $0x1c,%esp
80106925:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80106928:	39 d3                	cmp    %edx,%ebx
8010692a:	73 49                	jae    80106975 <deallocuvm.part.0+0x65>
8010692c:	89 c7                	mov    %eax,%edi
8010692e:	eb 0c                	jmp    8010693c <deallocuvm.part.0+0x2c>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80106930:	83 c0 01             	add    $0x1,%eax
80106933:	c1 e0 16             	shl    $0x16,%eax
80106936:	89 c3                	mov    %eax,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106938:	39 da                	cmp    %ebx,%edx
8010693a:	76 39                	jbe    80106975 <deallocuvm.part.0+0x65>
  pde = &pgdir[PDX(va)];
8010693c:	89 d8                	mov    %ebx,%eax
8010693e:	c1 e8 16             	shr    $0x16,%eax
  if(*pde & PTE_P){
80106941:	8b 0c 87             	mov    (%edi,%eax,4),%ecx
80106944:	f6 c1 01             	test   $0x1,%cl
80106947:	74 e7                	je     80106930 <deallocuvm.part.0+0x20>
  return &pgtab[PTX(va)];
80106949:	89 de                	mov    %ebx,%esi
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
8010694b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
  return &pgtab[PTX(va)];
80106951:	c1 ee 0a             	shr    $0xa,%esi
80106954:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
8010695a:	8d b4 31 00 00 00 80 	lea    -0x80000000(%ecx,%esi,1),%esi
    if(!pte)
80106961:	85 f6                	test   %esi,%esi
80106963:	74 cb                	je     80106930 <deallocuvm.part.0+0x20>
    else if((*pte & PTE_P) != 0){
80106965:	8b 06                	mov    (%esi),%eax
80106967:	a8 01                	test   $0x1,%al
80106969:	75 15                	jne    80106980 <deallocuvm.part.0+0x70>
  for(; a  < oldsz; a += PGSIZE){
8010696b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106971:	39 da                	cmp    %ebx,%edx
80106973:	77 c7                	ja     8010693c <deallocuvm.part.0+0x2c>
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
}
80106975:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106978:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010697b:	5b                   	pop    %ebx
8010697c:	5e                   	pop    %esi
8010697d:	5f                   	pop    %edi
8010697e:	5d                   	pop    %ebp
8010697f:	c3                   	ret    
      if(pa == 0)
80106980:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106985:	74 25                	je     801069ac <deallocuvm.part.0+0x9c>
      kfree(v);
80106987:	83 ec 0c             	sub    $0xc,%esp
      char *v = P2V(pa);
8010698a:	05 00 00 00 80       	add    $0x80000000,%eax
8010698f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80106992:	81 c3 00 10 00 00    	add    $0x1000,%ebx
      kfree(v);
80106998:	50                   	push   %eax
80106999:	e8 42 bc ff ff       	call   801025e0 <kfree>
      *pte = 0;
8010699e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  for(; a  < oldsz; a += PGSIZE){
801069a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801069a7:	83 c4 10             	add    $0x10,%esp
801069aa:	eb 8c                	jmp    80106938 <deallocuvm.part.0+0x28>
        panic("kfree");
801069ac:	83 ec 0c             	sub    $0xc,%esp
801069af:	68 6a 75 10 80       	push   $0x8010756a
801069b4:	e8 c7 99 ff ff       	call   80100380 <panic>
801069b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801069c0 <mappages>:
{
801069c0:	55                   	push   %ebp
801069c1:	89 e5                	mov    %esp,%ebp
801069c3:	57                   	push   %edi
801069c4:	56                   	push   %esi
801069c5:	53                   	push   %ebx
  a = (char*)PGROUNDDOWN((uint)va);
801069c6:	89 d3                	mov    %edx,%ebx
801069c8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
{
801069ce:	83 ec 1c             	sub    $0x1c,%esp
801069d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801069d4:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
801069d8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801069dd:	89 45 dc             	mov    %eax,-0x24(%ebp)
801069e0:	8b 45 08             	mov    0x8(%ebp),%eax
801069e3:	29 d8                	sub    %ebx,%eax
801069e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
801069e8:	eb 3d                	jmp    80106a27 <mappages+0x67>
801069ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  return &pgtab[PTX(va)];
801069f0:	89 da                	mov    %ebx,%edx
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801069f2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  return &pgtab[PTX(va)];
801069f7:	c1 ea 0a             	shr    $0xa,%edx
801069fa:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
80106a00:	8d 84 10 00 00 00 80 	lea    -0x80000000(%eax,%edx,1),%eax
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80106a07:	85 c0                	test   %eax,%eax
80106a09:	74 75                	je     80106a80 <mappages+0xc0>
    if(*pte & PTE_P)
80106a0b:	f6 00 01             	testb  $0x1,(%eax)
80106a0e:	0f 85 86 00 00 00    	jne    80106a9a <mappages+0xda>
    *pte = pa | perm | PTE_P;
80106a14:	0b 75 0c             	or     0xc(%ebp),%esi
80106a17:	83 ce 01             	or     $0x1,%esi
80106a1a:	89 30                	mov    %esi,(%eax)
    if(a == last)
80106a1c:	3b 5d dc             	cmp    -0x24(%ebp),%ebx
80106a1f:	74 6f                	je     80106a90 <mappages+0xd0>
    a += PGSIZE;
80106a21:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  for(;;){
80106a27:	8b 45 e0             	mov    -0x20(%ebp),%eax
  pde = &pgdir[PDX(va)];
80106a2a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80106a2d:	8d 34 18             	lea    (%eax,%ebx,1),%esi
80106a30:	89 d8                	mov    %ebx,%eax
80106a32:	c1 e8 16             	shr    $0x16,%eax
80106a35:	8d 3c 81             	lea    (%ecx,%eax,4),%edi
  if(*pde & PTE_P){
80106a38:	8b 07                	mov    (%edi),%eax
80106a3a:	a8 01                	test   $0x1,%al
80106a3c:	75 b2                	jne    801069f0 <mappages+0x30>
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80106a3e:	e8 5d bd ff ff       	call   801027a0 <kalloc>
80106a43:	85 c0                	test   %eax,%eax
80106a45:	74 39                	je     80106a80 <mappages+0xc0>
    memset(pgtab, 0, PGSIZE);
80106a47:	83 ec 04             	sub    $0x4,%esp
80106a4a:	89 45 d8             	mov    %eax,-0x28(%ebp)
80106a4d:	68 00 10 00 00       	push   $0x1000
80106a52:	6a 00                	push   $0x0
80106a54:	50                   	push   %eax
80106a55:	e8 26 dd ff ff       	call   80104780 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80106a5a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  return &pgtab[PTX(va)];
80106a5d:	83 c4 10             	add    $0x10,%esp
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80106a60:	8d 82 00 00 00 80    	lea    -0x80000000(%edx),%eax
80106a66:	83 c8 07             	or     $0x7,%eax
80106a69:	89 07                	mov    %eax,(%edi)
  return &pgtab[PTX(va)];
80106a6b:	89 d8                	mov    %ebx,%eax
80106a6d:	c1 e8 0a             	shr    $0xa,%eax
80106a70:	25 fc 0f 00 00       	and    $0xffc,%eax
80106a75:	01 d0                	add    %edx,%eax
80106a77:	eb 92                	jmp    80106a0b <mappages+0x4b>
80106a79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
}
80106a80:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80106a83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106a88:	5b                   	pop    %ebx
80106a89:	5e                   	pop    %esi
80106a8a:	5f                   	pop    %edi
80106a8b:	5d                   	pop    %ebp
80106a8c:	c3                   	ret    
80106a8d:	8d 76 00             	lea    0x0(%esi),%esi
80106a90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80106a93:	31 c0                	xor    %eax,%eax
}
80106a95:	5b                   	pop    %ebx
80106a96:	5e                   	pop    %esi
80106a97:	5f                   	pop    %edi
80106a98:	5d                   	pop    %ebp
80106a99:	c3                   	ret    
      panic("remap");
80106a9a:	83 ec 0c             	sub    $0xc,%esp
80106a9d:	68 ac 7b 10 80       	push   $0x80107bac
80106aa2:	e8 d9 98 ff ff       	call   80100380 <panic>
80106aa7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106aae:	66 90                	xchg   %ax,%ax

80106ab0 <seginit>:
{
80106ab0:	55                   	push   %ebp
80106ab1:	89 e5                	mov    %esp,%ebp
80106ab3:	83 ec 18             	sub    $0x18,%esp
  c = &cpus[cpuid()];
80106ab6:	e8 b5 cf ff ff       	call   80103a70 <cpuid>
  pd[0] = size-1;
80106abb:	ba 2f 00 00 00       	mov    $0x2f,%edx
80106ac0:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80106ac6:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80106aca:	c7 80 58 18 11 80 ff 	movl   $0xffff,-0x7feee7a8(%eax)
80106ad1:	ff 00 00 
80106ad4:	c7 80 5c 18 11 80 00 	movl   $0xcf9a00,-0x7feee7a4(%eax)
80106adb:	9a cf 00 
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80106ade:	c7 80 60 18 11 80 ff 	movl   $0xffff,-0x7feee7a0(%eax)
80106ae5:	ff 00 00 
80106ae8:	c7 80 64 18 11 80 00 	movl   $0xcf9200,-0x7feee79c(%eax)
80106aef:	92 cf 00 
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80106af2:	c7 80 68 18 11 80 ff 	movl   $0xffff,-0x7feee798(%eax)
80106af9:	ff 00 00 
80106afc:	c7 80 6c 18 11 80 00 	movl   $0xcffa00,-0x7feee794(%eax)
80106b03:	fa cf 00 
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80106b06:	c7 80 70 18 11 80 ff 	movl   $0xffff,-0x7feee790(%eax)
80106b0d:	ff 00 00 
80106b10:	c7 80 74 18 11 80 00 	movl   $0xcff200,-0x7feee78c(%eax)
80106b17:	f2 cf 00 
  lgdt(c->gdt, sizeof(c->gdt));
80106b1a:	05 50 18 11 80       	add    $0x80111850,%eax
  pd[1] = (uint)p;
80106b1f:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80106b23:	c1 e8 10             	shr    $0x10,%eax
80106b26:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80106b2a:	8d 45 f2             	lea    -0xe(%ebp),%eax
80106b2d:	0f 01 10             	lgdtl  (%eax)
}
80106b30:	c9                   	leave  
80106b31:	c3                   	ret    
80106b32:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106b39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80106b40 <switchkvm>:
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80106b40:	a1 04 45 11 80       	mov    0x80114504,%eax
80106b45:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106b4a:	0f 22 d8             	mov    %eax,%cr3
}
80106b4d:	c3                   	ret    
80106b4e:	66 90                	xchg   %ax,%ax

80106b50 <switchuvm>:
{
80106b50:	55                   	push   %ebp
80106b51:	89 e5                	mov    %esp,%ebp
80106b53:	57                   	push   %edi
80106b54:	56                   	push   %esi
80106b55:	53                   	push   %ebx
80106b56:	83 ec 1c             	sub    $0x1c,%esp
80106b59:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80106b5c:	85 f6                	test   %esi,%esi
80106b5e:	0f 84 cb 00 00 00    	je     80106c2f <switchuvm+0xdf>
  if(p->kstack == 0)
80106b64:	8b 46 08             	mov    0x8(%esi),%eax
80106b67:	85 c0                	test   %eax,%eax
80106b69:	0f 84 da 00 00 00    	je     80106c49 <switchuvm+0xf9>
  if(p->pgdir == 0)
80106b6f:	8b 46 04             	mov    0x4(%esi),%eax
80106b72:	85 c0                	test   %eax,%eax
80106b74:	0f 84 c2 00 00 00    	je     80106c3c <switchuvm+0xec>
  pushcli();
80106b7a:	e8 f1 d9 ff ff       	call   80104570 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80106b7f:	e8 8c ce ff ff       	call   80103a10 <mycpu>
80106b84:	89 c3                	mov    %eax,%ebx
80106b86:	e8 85 ce ff ff       	call   80103a10 <mycpu>
80106b8b:	89 c7                	mov    %eax,%edi
80106b8d:	e8 7e ce ff ff       	call   80103a10 <mycpu>
80106b92:	83 c7 08             	add    $0x8,%edi
80106b95:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106b98:	e8 73 ce ff ff       	call   80103a10 <mycpu>
80106b9d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80106ba0:	ba 67 00 00 00       	mov    $0x67,%edx
80106ba5:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80106bac:	83 c0 08             	add    $0x8,%eax
80106baf:	66 89 93 98 00 00 00 	mov    %dx,0x98(%ebx)
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80106bb6:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80106bbb:	83 c1 08             	add    $0x8,%ecx
80106bbe:	c1 e8 18             	shr    $0x18,%eax
80106bc1:	c1 e9 10             	shr    $0x10,%ecx
80106bc4:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
80106bca:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80106bd0:	b9 99 40 00 00       	mov    $0x4099,%ecx
80106bd5:	66 89 8b 9d 00 00 00 	mov    %cx,0x9d(%ebx)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80106bdc:	bb 10 00 00 00       	mov    $0x10,%ebx
  mycpu()->gdt[SEG_TSS].s = 0;
80106be1:	e8 2a ce ff ff       	call   80103a10 <mycpu>
80106be6:	80 a0 9d 00 00 00 ef 	andb   $0xef,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80106bed:	e8 1e ce ff ff       	call   80103a10 <mycpu>
80106bf2:	66 89 58 10          	mov    %bx,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80106bf6:	8b 5e 08             	mov    0x8(%esi),%ebx
80106bf9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106bff:	e8 0c ce ff ff       	call   80103a10 <mycpu>
80106c04:	89 58 0c             	mov    %ebx,0xc(%eax)
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80106c07:	e8 04 ce ff ff       	call   80103a10 <mycpu>
80106c0c:	66 89 78 6e          	mov    %di,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80106c10:	b8 28 00 00 00       	mov    $0x28,%eax
80106c15:	0f 00 d8             	ltr    %ax
  lcr3(V2P(p->pgdir));  // switch to process's address space
80106c18:	8b 46 04             	mov    0x4(%esi),%eax
80106c1b:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106c20:	0f 22 d8             	mov    %eax,%cr3
}
80106c23:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106c26:	5b                   	pop    %ebx
80106c27:	5e                   	pop    %esi
80106c28:	5f                   	pop    %edi
80106c29:	5d                   	pop    %ebp
  popcli();
80106c2a:	e9 91 d9 ff ff       	jmp    801045c0 <popcli>
    panic("switchuvm: no process");
80106c2f:	83 ec 0c             	sub    $0xc,%esp
80106c32:	68 b2 7b 10 80       	push   $0x80107bb2
80106c37:	e8 44 97 ff ff       	call   80100380 <panic>
    panic("switchuvm: no pgdir");
80106c3c:	83 ec 0c             	sub    $0xc,%esp
80106c3f:	68 dd 7b 10 80       	push   $0x80107bdd
80106c44:	e8 37 97 ff ff       	call   80100380 <panic>
    panic("switchuvm: no kstack");
80106c49:	83 ec 0c             	sub    $0xc,%esp
80106c4c:	68 c8 7b 10 80       	push   $0x80107bc8
80106c51:	e8 2a 97 ff ff       	call   80100380 <panic>
80106c56:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106c5d:	8d 76 00             	lea    0x0(%esi),%esi

80106c60 <inituvm>:
{
80106c60:	55                   	push   %ebp
80106c61:	89 e5                	mov    %esp,%ebp
80106c63:	57                   	push   %edi
80106c64:	56                   	push   %esi
80106c65:	53                   	push   %ebx
80106c66:	83 ec 1c             	sub    $0x1c,%esp
80106c69:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c6c:	8b 75 10             	mov    0x10(%ebp),%esi
80106c6f:	8b 7d 08             	mov    0x8(%ebp),%edi
80106c72:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(sz >= PGSIZE)
80106c75:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106c7b:	77 4b                	ja     80106cc8 <inituvm+0x68>
  mem = kalloc();
80106c7d:	e8 1e bb ff ff       	call   801027a0 <kalloc>
  memset(mem, 0, PGSIZE);
80106c82:	83 ec 04             	sub    $0x4,%esp
80106c85:	68 00 10 00 00       	push   $0x1000
  mem = kalloc();
80106c8a:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80106c8c:	6a 00                	push   $0x0
80106c8e:	50                   	push   %eax
80106c8f:	e8 ec da ff ff       	call   80104780 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80106c94:	58                   	pop    %eax
80106c95:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106c9b:	5a                   	pop    %edx
80106c9c:	6a 06                	push   $0x6
80106c9e:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106ca3:	31 d2                	xor    %edx,%edx
80106ca5:	50                   	push   %eax
80106ca6:	89 f8                	mov    %edi,%eax
80106ca8:	e8 13 fd ff ff       	call   801069c0 <mappages>
  memmove(mem, init, sz);
80106cad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106cb0:	89 75 10             	mov    %esi,0x10(%ebp)
80106cb3:	83 c4 10             	add    $0x10,%esp
80106cb6:	89 5d 08             	mov    %ebx,0x8(%ebp)
80106cb9:	89 45 0c             	mov    %eax,0xc(%ebp)
}
80106cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106cbf:	5b                   	pop    %ebx
80106cc0:	5e                   	pop    %esi
80106cc1:	5f                   	pop    %edi
80106cc2:	5d                   	pop    %ebp
  memmove(mem, init, sz);
80106cc3:	e9 58 db ff ff       	jmp    80104820 <memmove>
    panic("inituvm: more than a page");
80106cc8:	83 ec 0c             	sub    $0xc,%esp
80106ccb:	68 f1 7b 10 80       	push   $0x80107bf1
80106cd0:	e8 ab 96 ff ff       	call   80100380 <panic>
80106cd5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106cdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80106ce0 <loaduvm>:
{
80106ce0:	55                   	push   %ebp
80106ce1:	89 e5                	mov    %esp,%ebp
80106ce3:	57                   	push   %edi
80106ce4:	56                   	push   %esi
80106ce5:	53                   	push   %ebx
80106ce6:	83 ec 1c             	sub    $0x1c,%esp
80106ce9:	8b 45 0c             	mov    0xc(%ebp),%eax
80106cec:	8b 75 18             	mov    0x18(%ebp),%esi
  if((uint) addr % PGSIZE != 0)
80106cef:	a9 ff 0f 00 00       	test   $0xfff,%eax
80106cf4:	0f 85 bb 00 00 00    	jne    80106db5 <loaduvm+0xd5>
  for(i = 0; i < sz; i += PGSIZE){
80106cfa:	01 f0                	add    %esi,%eax
80106cfc:	89 f3                	mov    %esi,%ebx
80106cfe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106d01:	8b 45 14             	mov    0x14(%ebp),%eax
80106d04:	01 f0                	add    %esi,%eax
80106d06:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(i = 0; i < sz; i += PGSIZE){
80106d09:	85 f6                	test   %esi,%esi
80106d0b:	0f 84 87 00 00 00    	je     80106d98 <loaduvm+0xb8>
80106d11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  pde = &pgdir[PDX(va)];
80106d18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  if(*pde & PTE_P){
80106d1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106d1e:	29 d8                	sub    %ebx,%eax
  pde = &pgdir[PDX(va)];
80106d20:	89 c2                	mov    %eax,%edx
80106d22:	c1 ea 16             	shr    $0x16,%edx
  if(*pde & PTE_P){
80106d25:	8b 14 91             	mov    (%ecx,%edx,4),%edx
80106d28:	f6 c2 01             	test   $0x1,%dl
80106d2b:	75 13                	jne    80106d40 <loaduvm+0x60>
      panic("loaduvm: address should exist");
80106d2d:	83 ec 0c             	sub    $0xc,%esp
80106d30:	68 0b 7c 10 80       	push   $0x80107c0b
80106d35:	e8 46 96 ff ff       	call   80100380 <panic>
80106d3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  return &pgtab[PTX(va)];
80106d40:	c1 e8 0a             	shr    $0xa,%eax
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80106d43:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  return &pgtab[PTX(va)];
80106d49:	25 fc 0f 00 00       	and    $0xffc,%eax
80106d4e:	8d 84 02 00 00 00 80 	lea    -0x80000000(%edx,%eax,1),%eax
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80106d55:	85 c0                	test   %eax,%eax
80106d57:	74 d4                	je     80106d2d <loaduvm+0x4d>
    pa = PTE_ADDR(*pte);
80106d59:	8b 00                	mov    (%eax),%eax
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106d5b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
    if(sz - i < PGSIZE)
80106d5e:	bf 00 10 00 00       	mov    $0x1000,%edi
    pa = PTE_ADDR(*pte);
80106d63:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
80106d68:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
80106d6e:	0f 46 fb             	cmovbe %ebx,%edi
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106d71:	29 d9                	sub    %ebx,%ecx
80106d73:	05 00 00 00 80       	add    $0x80000000,%eax
80106d78:	57                   	push   %edi
80106d79:	51                   	push   %ecx
80106d7a:	50                   	push   %eax
80106d7b:	ff 75 10             	push   0x10(%ebp)
80106d7e:	e8 2d ae ff ff       	call   80101bb0 <readi>
80106d83:	83 c4 10             	add    $0x10,%esp
80106d86:	39 f8                	cmp    %edi,%eax
80106d88:	75 1e                	jne    80106da8 <loaduvm+0xc8>
  for(i = 0; i < sz; i += PGSIZE){
80106d8a:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
80106d90:	89 f0                	mov    %esi,%eax
80106d92:	29 d8                	sub    %ebx,%eax
80106d94:	39 c6                	cmp    %eax,%esi
80106d96:	77 80                	ja     80106d18 <loaduvm+0x38>
}
80106d98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80106d9b:	31 c0                	xor    %eax,%eax
}
80106d9d:	5b                   	pop    %ebx
80106d9e:	5e                   	pop    %esi
80106d9f:	5f                   	pop    %edi
80106da0:	5d                   	pop    %ebp
80106da1:	c3                   	ret    
80106da2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80106da8:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80106dab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106db0:	5b                   	pop    %ebx
80106db1:	5e                   	pop    %esi
80106db2:	5f                   	pop    %edi
80106db3:	5d                   	pop    %ebp
80106db4:	c3                   	ret    
    panic("loaduvm: addr must be page aligned");
80106db5:	83 ec 0c             	sub    $0xc,%esp
80106db8:	68 ac 7c 10 80       	push   $0x80107cac
80106dbd:	e8 be 95 ff ff       	call   80100380 <panic>
80106dc2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106dc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80106dd0 <allocuvm>:
{
80106dd0:	55                   	push   %ebp
80106dd1:	89 e5                	mov    %esp,%ebp
80106dd3:	57                   	push   %edi
80106dd4:	56                   	push   %esi
80106dd5:	53                   	push   %ebx
80106dd6:	83 ec 1c             	sub    $0x1c,%esp
  if(newsz >= KERNBASE)
80106dd9:	8b 45 10             	mov    0x10(%ebp),%eax
{
80106ddc:	8b 7d 08             	mov    0x8(%ebp),%edi
  if(newsz >= KERNBASE)
80106ddf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106de2:	85 c0                	test   %eax,%eax
80106de4:	0f 88 b6 00 00 00    	js     80106ea0 <allocuvm+0xd0>
  if(newsz < oldsz)
80106dea:	3b 45 0c             	cmp    0xc(%ebp),%eax
    return oldsz;
80106ded:	8b 45 0c             	mov    0xc(%ebp),%eax
  if(newsz < oldsz)
80106df0:	0f 82 9a 00 00 00    	jb     80106e90 <allocuvm+0xc0>
  a = PGROUNDUP(oldsz);
80106df6:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
80106dfc:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
80106e02:	39 75 10             	cmp    %esi,0x10(%ebp)
80106e05:	77 44                	ja     80106e4b <allocuvm+0x7b>
80106e07:	e9 87 00 00 00       	jmp    80106e93 <allocuvm+0xc3>
80106e0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    memset(mem, 0, PGSIZE);
80106e10:	83 ec 04             	sub    $0x4,%esp
80106e13:	68 00 10 00 00       	push   $0x1000
80106e18:	6a 00                	push   $0x0
80106e1a:	50                   	push   %eax
80106e1b:	e8 60 d9 ff ff       	call   80104780 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80106e20:	58                   	pop    %eax
80106e21:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106e27:	5a                   	pop    %edx
80106e28:	6a 06                	push   $0x6
80106e2a:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106e2f:	89 f2                	mov    %esi,%edx
80106e31:	50                   	push   %eax
80106e32:	89 f8                	mov    %edi,%eax
80106e34:	e8 87 fb ff ff       	call   801069c0 <mappages>
80106e39:	83 c4 10             	add    $0x10,%esp
80106e3c:	85 c0                	test   %eax,%eax
80106e3e:	78 78                	js     80106eb8 <allocuvm+0xe8>
  for(; a < newsz; a += PGSIZE){
80106e40:	81 c6 00 10 00 00    	add    $0x1000,%esi
80106e46:	39 75 10             	cmp    %esi,0x10(%ebp)
80106e49:	76 48                	jbe    80106e93 <allocuvm+0xc3>
    mem = kalloc();
80106e4b:	e8 50 b9 ff ff       	call   801027a0 <kalloc>
80106e50:	89 c3                	mov    %eax,%ebx
    if(mem == 0){
80106e52:	85 c0                	test   %eax,%eax
80106e54:	75 ba                	jne    80106e10 <allocuvm+0x40>
      cprintf("allocuvm out of memory\n");
80106e56:	83 ec 0c             	sub    $0xc,%esp
80106e59:	68 29 7c 10 80       	push   $0x80107c29
80106e5e:	e8 3d 98 ff ff       	call   801006a0 <cprintf>
  if(newsz >= oldsz)
80106e63:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e66:	83 c4 10             	add    $0x10,%esp
80106e69:	39 45 10             	cmp    %eax,0x10(%ebp)
80106e6c:	74 32                	je     80106ea0 <allocuvm+0xd0>
80106e6e:	8b 55 10             	mov    0x10(%ebp),%edx
80106e71:	89 c1                	mov    %eax,%ecx
80106e73:	89 f8                	mov    %edi,%eax
80106e75:	e8 96 fa ff ff       	call   80106910 <deallocuvm.part.0>
      return 0;
80106e7a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
80106e81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106e84:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106e87:	5b                   	pop    %ebx
80106e88:	5e                   	pop    %esi
80106e89:	5f                   	pop    %edi
80106e8a:	5d                   	pop    %ebp
80106e8b:	c3                   	ret    
80106e8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return oldsz;
80106e90:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}
80106e93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106e96:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106e99:	5b                   	pop    %ebx
80106e9a:	5e                   	pop    %esi
80106e9b:	5f                   	pop    %edi
80106e9c:	5d                   	pop    %ebp
80106e9d:	c3                   	ret    
80106e9e:	66 90                	xchg   %ax,%ax
    return 0;
80106ea0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
80106ea7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106eaa:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106ead:	5b                   	pop    %ebx
80106eae:	5e                   	pop    %esi
80106eaf:	5f                   	pop    %edi
80106eb0:	5d                   	pop    %ebp
80106eb1:	c3                   	ret    
80106eb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      cprintf("allocuvm out of memory (2)\n");
80106eb8:	83 ec 0c             	sub    $0xc,%esp
80106ebb:	68 41 7c 10 80       	push   $0x80107c41
80106ec0:	e8 db 97 ff ff       	call   801006a0 <cprintf>
  if(newsz >= oldsz)
80106ec5:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ec8:	83 c4 10             	add    $0x10,%esp
80106ecb:	39 45 10             	cmp    %eax,0x10(%ebp)
80106ece:	74 0c                	je     80106edc <allocuvm+0x10c>
80106ed0:	8b 55 10             	mov    0x10(%ebp),%edx
80106ed3:	89 c1                	mov    %eax,%ecx
80106ed5:	89 f8                	mov    %edi,%eax
80106ed7:	e8 34 fa ff ff       	call   80106910 <deallocuvm.part.0>
      kfree(mem);
80106edc:	83 ec 0c             	sub    $0xc,%esp
80106edf:	53                   	push   %ebx
80106ee0:	e8 fb b6 ff ff       	call   801025e0 <kfree>
      return 0;
80106ee5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106eec:	83 c4 10             	add    $0x10,%esp
}
80106eef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106ef2:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106ef5:	5b                   	pop    %ebx
80106ef6:	5e                   	pop    %esi
80106ef7:	5f                   	pop    %edi
80106ef8:	5d                   	pop    %ebp
80106ef9:	c3                   	ret    
80106efa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80106f00 <deallocuvm>:
{
80106f00:	55                   	push   %ebp
80106f01:	89 e5                	mov    %esp,%ebp
80106f03:	8b 55 0c             	mov    0xc(%ebp),%edx
80106f06:	8b 4d 10             	mov    0x10(%ebp),%ecx
80106f09:	8b 45 08             	mov    0x8(%ebp),%eax
  if(newsz >= oldsz)
80106f0c:	39 d1                	cmp    %edx,%ecx
80106f0e:	73 10                	jae    80106f20 <deallocuvm+0x20>
}
80106f10:	5d                   	pop    %ebp
80106f11:	e9 fa f9 ff ff       	jmp    80106910 <deallocuvm.part.0>
80106f16:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106f1d:	8d 76 00             	lea    0x0(%esi),%esi
80106f20:	89 d0                	mov    %edx,%eax
80106f22:	5d                   	pop    %ebp
80106f23:	c3                   	ret    
80106f24:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106f2b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80106f2f:	90                   	nop

80106f30 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80106f30:	55                   	push   %ebp
80106f31:	89 e5                	mov    %esp,%ebp
80106f33:	57                   	push   %edi
80106f34:	56                   	push   %esi
80106f35:	53                   	push   %ebx
80106f36:	83 ec 0c             	sub    $0xc,%esp
80106f39:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
80106f3c:	85 f6                	test   %esi,%esi
80106f3e:	74 59                	je     80106f99 <freevm+0x69>
  if(newsz >= oldsz)
80106f40:	31 c9                	xor    %ecx,%ecx
80106f42:	ba 00 00 00 80       	mov    $0x80000000,%edx
80106f47:	89 f0                	mov    %esi,%eax
80106f49:	89 f3                	mov    %esi,%ebx
80106f4b:	e8 c0 f9 ff ff       	call   80106910 <deallocuvm.part.0>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80106f50:	8d be 00 10 00 00    	lea    0x1000(%esi),%edi
80106f56:	eb 0f                	jmp    80106f67 <freevm+0x37>
80106f58:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106f5f:	90                   	nop
80106f60:	83 c3 04             	add    $0x4,%ebx
80106f63:	39 df                	cmp    %ebx,%edi
80106f65:	74 23                	je     80106f8a <freevm+0x5a>
    if(pgdir[i] & PTE_P){
80106f67:	8b 03                	mov    (%ebx),%eax
80106f69:	a8 01                	test   $0x1,%al
80106f6b:	74 f3                	je     80106f60 <freevm+0x30>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80106f6d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
      kfree(v);
80106f72:	83 ec 0c             	sub    $0xc,%esp
  for(i = 0; i < NPDENTRIES; i++){
80106f75:	83 c3 04             	add    $0x4,%ebx
      char * v = P2V(PTE_ADDR(pgdir[i]));
80106f78:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
80106f7d:	50                   	push   %eax
80106f7e:	e8 5d b6 ff ff       	call   801025e0 <kfree>
80106f83:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80106f86:	39 df                	cmp    %ebx,%edi
80106f88:	75 dd                	jne    80106f67 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80106f8a:	89 75 08             	mov    %esi,0x8(%ebp)
}
80106f8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106f90:	5b                   	pop    %ebx
80106f91:	5e                   	pop    %esi
80106f92:	5f                   	pop    %edi
80106f93:	5d                   	pop    %ebp
  kfree((char*)pgdir);
80106f94:	e9 47 b6 ff ff       	jmp    801025e0 <kfree>
    panic("freevm: no pgdir");
80106f99:	83 ec 0c             	sub    $0xc,%esp
80106f9c:	68 5d 7c 10 80       	push   $0x80107c5d
80106fa1:	e8 da 93 ff ff       	call   80100380 <panic>
80106fa6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106fad:	8d 76 00             	lea    0x0(%esi),%esi

80106fb0 <setupkvm>:
{
80106fb0:	55                   	push   %ebp
80106fb1:	89 e5                	mov    %esp,%ebp
80106fb3:	56                   	push   %esi
80106fb4:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
80106fb5:	e8 e6 b7 ff ff       	call   801027a0 <kalloc>
80106fba:	89 c6                	mov    %eax,%esi
80106fbc:	85 c0                	test   %eax,%eax
80106fbe:	74 42                	je     80107002 <setupkvm+0x52>
  memset(pgdir, 0, PGSIZE);
80106fc0:	83 ec 04             	sub    $0x4,%esp
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106fc3:	bb 60 a4 10 80       	mov    $0x8010a460,%ebx
  memset(pgdir, 0, PGSIZE);
80106fc8:	68 00 10 00 00       	push   $0x1000
80106fcd:	6a 00                	push   $0x0
80106fcf:	50                   	push   %eax
80106fd0:	e8 ab d7 ff ff       	call   80104780 <memset>
80106fd5:	83 c4 10             	add    $0x10,%esp
                (uint)k->phys_start, k->perm) < 0) {
80106fd8:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80106fdb:	83 ec 08             	sub    $0x8,%esp
80106fde:	8b 4b 08             	mov    0x8(%ebx),%ecx
80106fe1:	ff 73 0c             	push   0xc(%ebx)
80106fe4:	8b 13                	mov    (%ebx),%edx
80106fe6:	50                   	push   %eax
80106fe7:	29 c1                	sub    %eax,%ecx
80106fe9:	89 f0                	mov    %esi,%eax
80106feb:	e8 d0 f9 ff ff       	call   801069c0 <mappages>
80106ff0:	83 c4 10             	add    $0x10,%esp
80106ff3:	85 c0                	test   %eax,%eax
80106ff5:	78 19                	js     80107010 <setupkvm+0x60>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106ff7:	83 c3 10             	add    $0x10,%ebx
80106ffa:	81 fb a0 a4 10 80    	cmp    $0x8010a4a0,%ebx
80107000:	75 d6                	jne    80106fd8 <setupkvm+0x28>
}
80107002:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107005:	89 f0                	mov    %esi,%eax
80107007:	5b                   	pop    %ebx
80107008:	5e                   	pop    %esi
80107009:	5d                   	pop    %ebp
8010700a:	c3                   	ret    
8010700b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010700f:	90                   	nop
      freevm(pgdir);
80107010:	83 ec 0c             	sub    $0xc,%esp
80107013:	56                   	push   %esi
      return 0;
80107014:	31 f6                	xor    %esi,%esi
      freevm(pgdir);
80107016:	e8 15 ff ff ff       	call   80106f30 <freevm>
      return 0;
8010701b:	83 c4 10             	add    $0x10,%esp
}
8010701e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107021:	89 f0                	mov    %esi,%eax
80107023:	5b                   	pop    %ebx
80107024:	5e                   	pop    %esi
80107025:	5d                   	pop    %ebp
80107026:	c3                   	ret    
80107027:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010702e:	66 90                	xchg   %ax,%ax

80107030 <kvmalloc>:
{
80107030:	55                   	push   %ebp
80107031:	89 e5                	mov    %esp,%ebp
80107033:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107036:	e8 75 ff ff ff       	call   80106fb0 <setupkvm>
8010703b:	a3 04 45 11 80       	mov    %eax,0x80114504
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107040:	05 00 00 00 80       	add    $0x80000000,%eax
80107045:	0f 22 d8             	mov    %eax,%cr3
}
80107048:	c9                   	leave  
80107049:	c3                   	ret    
8010704a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80107050 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107050:	55                   	push   %ebp
80107051:	89 e5                	mov    %esp,%ebp
80107053:	83 ec 08             	sub    $0x8,%esp
80107056:	8b 45 0c             	mov    0xc(%ebp),%eax
  if(*pde & PTE_P){
80107059:	8b 55 08             	mov    0x8(%ebp),%edx
  pde = &pgdir[PDX(va)];
8010705c:	89 c1                	mov    %eax,%ecx
8010705e:	c1 e9 16             	shr    $0x16,%ecx
  if(*pde & PTE_P){
80107061:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
80107064:	f6 c2 01             	test   $0x1,%dl
80107067:	75 17                	jne    80107080 <clearpteu+0x30>
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  if(pte == 0)
    panic("clearpteu");
80107069:	83 ec 0c             	sub    $0xc,%esp
8010706c:	68 6e 7c 10 80       	push   $0x80107c6e
80107071:	e8 0a 93 ff ff       	call   80100380 <panic>
80107076:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010707d:	8d 76 00             	lea    0x0(%esi),%esi
  return &pgtab[PTX(va)];
80107080:	c1 e8 0a             	shr    $0xa,%eax
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107083:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  return &pgtab[PTX(va)];
80107089:	25 fc 0f 00 00       	and    $0xffc,%eax
8010708e:	8d 84 02 00 00 00 80 	lea    -0x80000000(%edx,%eax,1),%eax
  if(pte == 0)
80107095:	85 c0                	test   %eax,%eax
80107097:	74 d0                	je     80107069 <clearpteu+0x19>
  *pte &= ~PTE_U;
80107099:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
8010709c:	c9                   	leave  
8010709d:	c3                   	ret    
8010709e:	66 90                	xchg   %ax,%ax

801070a0 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801070a0:	55                   	push   %ebp
801070a1:	89 e5                	mov    %esp,%ebp
801070a3:	57                   	push   %edi
801070a4:	56                   	push   %esi
801070a5:	53                   	push   %ebx
801070a6:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801070a9:	e8 02 ff ff ff       	call   80106fb0 <setupkvm>
801070ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
801070b1:	85 c0                	test   %eax,%eax
801070b3:	0f 84 bd 00 00 00    	je     80107176 <copyuvm+0xd6>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801070b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801070bc:	85 c9                	test   %ecx,%ecx
801070be:	0f 84 b2 00 00 00    	je     80107176 <copyuvm+0xd6>
801070c4:	31 f6                	xor    %esi,%esi
801070c6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801070cd:	8d 76 00             	lea    0x0(%esi),%esi
  if(*pde & PTE_P){
801070d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  pde = &pgdir[PDX(va)];
801070d3:	89 f0                	mov    %esi,%eax
801070d5:	c1 e8 16             	shr    $0x16,%eax
  if(*pde & PTE_P){
801070d8:	8b 04 81             	mov    (%ecx,%eax,4),%eax
801070db:	a8 01                	test   $0x1,%al
801070dd:	75 11                	jne    801070f0 <copyuvm+0x50>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
801070df:	83 ec 0c             	sub    $0xc,%esp
801070e2:	68 78 7c 10 80       	push   $0x80107c78
801070e7:	e8 94 92 ff ff       	call   80100380 <panic>
801070ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  return &pgtab[PTX(va)];
801070f0:	89 f2                	mov    %esi,%edx
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801070f2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  return &pgtab[PTX(va)];
801070f7:	c1 ea 0a             	shr    $0xa,%edx
801070fa:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
80107100:	8d 84 10 00 00 00 80 	lea    -0x80000000(%eax,%edx,1),%eax
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107107:	85 c0                	test   %eax,%eax
80107109:	74 d4                	je     801070df <copyuvm+0x3f>
    if(!(*pte & PTE_P))
8010710b:	8b 00                	mov    (%eax),%eax
8010710d:	a8 01                	test   $0x1,%al
8010710f:	0f 84 9f 00 00 00    	je     801071b4 <copyuvm+0x114>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
80107115:	89 c7                	mov    %eax,%edi
    flags = PTE_FLAGS(*pte);
80107117:	25 ff 0f 00 00       	and    $0xfff,%eax
8010711c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    pa = PTE_ADDR(*pte);
8010711f:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    if((mem = kalloc()) == 0)
80107125:	e8 76 b6 ff ff       	call   801027a0 <kalloc>
8010712a:	89 c3                	mov    %eax,%ebx
8010712c:	85 c0                	test   %eax,%eax
8010712e:	74 64                	je     80107194 <copyuvm+0xf4>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107130:	83 ec 04             	sub    $0x4,%esp
80107133:	81 c7 00 00 00 80    	add    $0x80000000,%edi
80107139:	68 00 10 00 00       	push   $0x1000
8010713e:	57                   	push   %edi
8010713f:	50                   	push   %eax
80107140:	e8 db d6 ff ff       	call   80104820 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
80107145:	58                   	pop    %eax
80107146:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
8010714c:	5a                   	pop    %edx
8010714d:	ff 75 e4             	push   -0x1c(%ebp)
80107150:	b9 00 10 00 00       	mov    $0x1000,%ecx
80107155:	89 f2                	mov    %esi,%edx
80107157:	50                   	push   %eax
80107158:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010715b:	e8 60 f8 ff ff       	call   801069c0 <mappages>
80107160:	83 c4 10             	add    $0x10,%esp
80107163:	85 c0                	test   %eax,%eax
80107165:	78 21                	js     80107188 <copyuvm+0xe8>
  for(i = 0; i < sz; i += PGSIZE){
80107167:	81 c6 00 10 00 00    	add    $0x1000,%esi
8010716d:	39 75 0c             	cmp    %esi,0xc(%ebp)
80107170:	0f 87 5a ff ff ff    	ja     801070d0 <copyuvm+0x30>
  return d;

bad:
  freevm(d);
  return 0;
}
80107176:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107179:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010717c:	5b                   	pop    %ebx
8010717d:	5e                   	pop    %esi
8010717e:	5f                   	pop    %edi
8010717f:	5d                   	pop    %ebp
80107180:	c3                   	ret    
80107181:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      kfree(mem);
80107188:	83 ec 0c             	sub    $0xc,%esp
8010718b:	53                   	push   %ebx
8010718c:	e8 4f b4 ff ff       	call   801025e0 <kfree>
      goto bad;
80107191:	83 c4 10             	add    $0x10,%esp
  freevm(d);
80107194:	83 ec 0c             	sub    $0xc,%esp
80107197:	ff 75 e0             	push   -0x20(%ebp)
8010719a:	e8 91 fd ff ff       	call   80106f30 <freevm>
  return 0;
8010719f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801071a6:	83 c4 10             	add    $0x10,%esp
}
801071a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801071ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
801071af:	5b                   	pop    %ebx
801071b0:	5e                   	pop    %esi
801071b1:	5f                   	pop    %edi
801071b2:	5d                   	pop    %ebp
801071b3:	c3                   	ret    
      panic("copyuvm: page not present");
801071b4:	83 ec 0c             	sub    $0xc,%esp
801071b7:	68 92 7c 10 80       	push   $0x80107c92
801071bc:	e8 bf 91 ff ff       	call   80100380 <panic>
801071c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801071c8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801071cf:	90                   	nop

801071d0 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801071d0:	55                   	push   %ebp
801071d1:	89 e5                	mov    %esp,%ebp
801071d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  if(*pde & PTE_P){
801071d6:	8b 55 08             	mov    0x8(%ebp),%edx
  pde = &pgdir[PDX(va)];
801071d9:	89 c1                	mov    %eax,%ecx
801071db:	c1 e9 16             	shr    $0x16,%ecx
  if(*pde & PTE_P){
801071de:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
801071e1:	f6 c2 01             	test   $0x1,%dl
801071e4:	0f 84 00 01 00 00    	je     801072ea <uva2ka.cold>
  return &pgtab[PTX(va)];
801071ea:	c1 e8 0c             	shr    $0xc,%eax
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801071ed:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  if((*pte & PTE_P) == 0)
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
}
801071f3:	5d                   	pop    %ebp
  return &pgtab[PTX(va)];
801071f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  if((*pte & PTE_P) == 0)
801071f9:	8b 84 82 00 00 00 80 	mov    -0x80000000(%edx,%eax,4),%eax
  if((*pte & PTE_U) == 0)
80107200:	89 c2                	mov    %eax,%edx
  return (char*)P2V(PTE_ADDR(*pte));
80107202:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((*pte & PTE_U) == 0)
80107207:	83 e2 05             	and    $0x5,%edx
  return (char*)P2V(PTE_ADDR(*pte));
8010720a:	05 00 00 00 80       	add    $0x80000000,%eax
8010720f:	83 fa 05             	cmp    $0x5,%edx
80107212:	ba 00 00 00 00       	mov    $0x0,%edx
80107217:	0f 45 c2             	cmovne %edx,%eax
}
8010721a:	c3                   	ret    
8010721b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010721f:	90                   	nop

80107220 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107220:	55                   	push   %ebp
80107221:	89 e5                	mov    %esp,%ebp
80107223:	57                   	push   %edi
80107224:	56                   	push   %esi
80107225:	53                   	push   %ebx
80107226:	83 ec 0c             	sub    $0xc,%esp
80107229:	8b 75 14             	mov    0x14(%ebp),%esi
8010722c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010722f:	8b 55 10             	mov    0x10(%ebp),%edx
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80107232:	85 f6                	test   %esi,%esi
80107234:	75 51                	jne    80107287 <copyout+0x67>
80107236:	e9 a5 00 00 00       	jmp    801072e0 <copyout+0xc0>
8010723b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010723f:	90                   	nop
  return (char*)P2V(PTE_ADDR(*pte));
80107240:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80107246:	8d 8b 00 00 00 80    	lea    -0x80000000(%ebx),%ecx
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char*)va0);
    if(pa0 == 0)
8010724c:	81 fb 00 00 00 80    	cmp    $0x80000000,%ebx
80107252:	74 75                	je     801072c9 <copyout+0xa9>
      return -1;
    n = PGSIZE - (va - va0);
80107254:	89 fb                	mov    %edi,%ebx
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
80107256:	89 55 10             	mov    %edx,0x10(%ebp)
    n = PGSIZE - (va - va0);
80107259:	29 c3                	sub    %eax,%ebx
8010725b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80107261:	39 f3                	cmp    %esi,%ebx
80107263:	0f 47 de             	cmova  %esi,%ebx
    memmove(pa0 + (va - va0), buf, n);
80107266:	29 f8                	sub    %edi,%eax
80107268:	83 ec 04             	sub    $0x4,%esp
8010726b:	01 c1                	add    %eax,%ecx
8010726d:	53                   	push   %ebx
8010726e:	52                   	push   %edx
8010726f:	51                   	push   %ecx
80107270:	e8 ab d5 ff ff       	call   80104820 <memmove>
    len -= n;
    buf += n;
80107275:	8b 55 10             	mov    0x10(%ebp),%edx
    va = va0 + PGSIZE;
80107278:	8d 87 00 10 00 00    	lea    0x1000(%edi),%eax
  while(len > 0){
8010727e:	83 c4 10             	add    $0x10,%esp
    buf += n;
80107281:	01 da                	add    %ebx,%edx
  while(len > 0){
80107283:	29 de                	sub    %ebx,%esi
80107285:	74 59                	je     801072e0 <copyout+0xc0>
  if(*pde & PTE_P){
80107287:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pde = &pgdir[PDX(va)];
8010728a:	89 c1                	mov    %eax,%ecx
    va0 = (uint)PGROUNDDOWN(va);
8010728c:	89 c7                	mov    %eax,%edi
  pde = &pgdir[PDX(va)];
8010728e:	c1 e9 16             	shr    $0x16,%ecx
    va0 = (uint)PGROUNDDOWN(va);
80107291:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  if(*pde & PTE_P){
80107297:	8b 0c 8b             	mov    (%ebx,%ecx,4),%ecx
8010729a:	f6 c1 01             	test   $0x1,%cl
8010729d:	0f 84 4e 00 00 00    	je     801072f1 <copyout.cold>
  return &pgtab[PTX(va)];
801072a3:	89 fb                	mov    %edi,%ebx
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801072a5:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
  return &pgtab[PTX(va)];
801072ab:	c1 eb 0c             	shr    $0xc,%ebx
801072ae:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  if((*pte & PTE_P) == 0)
801072b4:	8b 9c 99 00 00 00 80 	mov    -0x80000000(%ecx,%ebx,4),%ebx
  if((*pte & PTE_U) == 0)
801072bb:	89 d9                	mov    %ebx,%ecx
801072bd:	83 e1 05             	and    $0x5,%ecx
801072c0:	83 f9 05             	cmp    $0x5,%ecx
801072c3:	0f 84 77 ff ff ff    	je     80107240 <copyout+0x20>
  }
  return 0;
}
801072c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
801072cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801072d1:	5b                   	pop    %ebx
801072d2:	5e                   	pop    %esi
801072d3:	5f                   	pop    %edi
801072d4:	5d                   	pop    %ebp
801072d5:	c3                   	ret    
801072d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801072dd:	8d 76 00             	lea    0x0(%esi),%esi
801072e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
801072e3:	31 c0                	xor    %eax,%eax
}
801072e5:	5b                   	pop    %ebx
801072e6:	5e                   	pop    %esi
801072e7:	5f                   	pop    %edi
801072e8:	5d                   	pop    %ebp
801072e9:	c3                   	ret    

801072ea <uva2ka.cold>:
  if((*pte & PTE_P) == 0)
801072ea:	a1 00 00 00 00       	mov    0x0,%eax
801072ef:	0f 0b                	ud2    

801072f1 <copyout.cold>:
801072f1:	a1 00 00 00 00       	mov    0x0,%eax
801072f6:	0f 0b                	ud2    
