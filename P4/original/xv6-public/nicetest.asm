
_nicetest:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"
#include "param.h"

int
main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 14             	sub    $0x14,%esp
  int pid;
  int x = 0;
  11:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  pid = fork();
  18:	e8 22 03 00 00       	call   33f <fork>
  1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pid < 0) {
  20:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  24:	79 17                	jns    3d <main+0x3d>
    printf(2, "Error in fork\n");
  26:	83 ec 08             	sub    $0x8,%esp
  29:	68 7c 08 00 00       	push   $0x87c
  2e:	6a 02                	push   $0x2
  30:	e8 8e 04 00 00       	call   4c3 <printf>
  35:	83 c4 10             	add    $0x10,%esp
    exit();
  38:	e8 0a 03 00 00       	call   347 <exit>
  }

  if(pid == 0) {
  3d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  41:	75 5d                	jne    a0 <main+0xa0>
    printf(1, "Child process, setting nice value to 10\n");
  43:	83 ec 08             	sub    $0x8,%esp
  46:	68 8c 08 00 00       	push   $0x88c
  4b:	6a 01                	push   $0x1
  4d:	e8 71 04 00 00       	call   4c3 <printf>
  52:	83 c4 10             	add    $0x10,%esp
    nice(10); // Assuming nice() works as expected, this should lower the priority of this process
  55:	83 ec 0c             	sub    $0xc,%esp
  58:	6a 0a                	push   $0xa
  5a:	e8 88 03 00 00       	call   3e7 <nice>
  5f:	83 c4 10             	add    $0x10,%esp
    for(;;) {
      x++;  // Dummy computation
  62:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      if(x % 10000000 == 0) {
  66:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  69:	ba 6b ca 5f 6b       	mov    $0x6b5fca6b,%edx
  6e:	89 c8                	mov    %ecx,%eax
  70:	f7 ea                	imul   %edx
  72:	89 d0                	mov    %edx,%eax
  74:	c1 f8 16             	sar    $0x16,%eax
  77:	89 ca                	mov    %ecx,%edx
  79:	c1 fa 1f             	sar    $0x1f,%edx
  7c:	29 d0                	sub    %edx,%eax
  7e:	69 d0 80 96 98 00    	imul   $0x989680,%eax,%edx
  84:	89 c8                	mov    %ecx,%eax
  86:	29 d0                	sub    %edx,%eax
  88:	85 c0                	test   %eax,%eax
  8a:	75 d6                	jne    62 <main+0x62>
        printf(1, "Child process is running\n");
  8c:	83 ec 08             	sub    $0x8,%esp
  8f:	68 b5 08 00 00       	push   $0x8b5
  94:	6a 01                	push   $0x1
  96:	e8 28 04 00 00       	call   4c3 <printf>
  9b:	83 c4 10             	add    $0x10,%esp
      x++;  // Dummy computation
  9e:	eb c2                	jmp    62 <main+0x62>
      }
    }
  } else {
    printf(1, "Parent process, keeping default nice value\n");
  a0:	83 ec 08             	sub    $0x8,%esp
  a3:	68 d0 08 00 00       	push   $0x8d0
  a8:	6a 01                	push   $0x1
  aa:	e8 14 04 00 00       	call   4c3 <printf>
  af:	83 c4 10             	add    $0x10,%esp
    for(;;) {
      x++;  // Dummy computation
  b2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      if(x % 10000000 == 0) {
  b6:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  b9:	ba 6b ca 5f 6b       	mov    $0x6b5fca6b,%edx
  be:	89 c8                	mov    %ecx,%eax
  c0:	f7 ea                	imul   %edx
  c2:	89 d0                	mov    %edx,%eax
  c4:	c1 f8 16             	sar    $0x16,%eax
  c7:	89 ca                	mov    %ecx,%edx
  c9:	c1 fa 1f             	sar    $0x1f,%edx
  cc:	29 d0                	sub    %edx,%eax
  ce:	69 d0 80 96 98 00    	imul   $0x989680,%eax,%edx
  d4:	89 c8                	mov    %ecx,%eax
  d6:	29 d0                	sub    %edx,%eax
  d8:	85 c0                	test   %eax,%eax
  da:	75 d6                	jne    b2 <main+0xb2>
        printf(1, "Parent process is running\n");
  dc:	83 ec 08             	sub    $0x8,%esp
  df:	68 fc 08 00 00       	push   $0x8fc
  e4:	6a 01                	push   $0x1
  e6:	e8 d8 03 00 00       	call   4c3 <printf>
  eb:	83 c4 10             	add    $0x10,%esp
      x++;  // Dummy computation
  ee:	eb c2                	jmp    b2 <main+0xb2>

000000f0 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  f0:	55                   	push   %ebp
  f1:	89 e5                	mov    %esp,%ebp
  f3:	57                   	push   %edi
  f4:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  f8:	8b 55 10             	mov    0x10(%ebp),%edx
  fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  fe:	89 cb                	mov    %ecx,%ebx
 100:	89 df                	mov    %ebx,%edi
 102:	89 d1                	mov    %edx,%ecx
 104:	fc                   	cld    
 105:	f3 aa                	rep stos %al,%es:(%edi)
 107:	89 ca                	mov    %ecx,%edx
 109:	89 fb                	mov    %edi,%ebx
 10b:	89 5d 08             	mov    %ebx,0x8(%ebp)
 10e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 111:	90                   	nop
 112:	5b                   	pop    %ebx
 113:	5f                   	pop    %edi
 114:	5d                   	pop    %ebp
 115:	c3                   	ret    

00000116 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 116:	55                   	push   %ebp
 117:	89 e5                	mov    %esp,%ebp
 119:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 11c:	8b 45 08             	mov    0x8(%ebp),%eax
 11f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 122:	90                   	nop
 123:	8b 55 0c             	mov    0xc(%ebp),%edx
 126:	8d 42 01             	lea    0x1(%edx),%eax
 129:	89 45 0c             	mov    %eax,0xc(%ebp)
 12c:	8b 45 08             	mov    0x8(%ebp),%eax
 12f:	8d 48 01             	lea    0x1(%eax),%ecx
 132:	89 4d 08             	mov    %ecx,0x8(%ebp)
 135:	0f b6 12             	movzbl (%edx),%edx
 138:	88 10                	mov    %dl,(%eax)
 13a:	0f b6 00             	movzbl (%eax),%eax
 13d:	84 c0                	test   %al,%al
 13f:	75 e2                	jne    123 <strcpy+0xd>
    ;
  return os;
 141:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 144:	c9                   	leave  
 145:	c3                   	ret    

00000146 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 146:	55                   	push   %ebp
 147:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 149:	eb 08                	jmp    153 <strcmp+0xd>
    p++, q++;
 14b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 14f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 153:	8b 45 08             	mov    0x8(%ebp),%eax
 156:	0f b6 00             	movzbl (%eax),%eax
 159:	84 c0                	test   %al,%al
 15b:	74 10                	je     16d <strcmp+0x27>
 15d:	8b 45 08             	mov    0x8(%ebp),%eax
 160:	0f b6 10             	movzbl (%eax),%edx
 163:	8b 45 0c             	mov    0xc(%ebp),%eax
 166:	0f b6 00             	movzbl (%eax),%eax
 169:	38 c2                	cmp    %al,%dl
 16b:	74 de                	je     14b <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 16d:	8b 45 08             	mov    0x8(%ebp),%eax
 170:	0f b6 00             	movzbl (%eax),%eax
 173:	0f b6 d0             	movzbl %al,%edx
 176:	8b 45 0c             	mov    0xc(%ebp),%eax
 179:	0f b6 00             	movzbl (%eax),%eax
 17c:	0f b6 c8             	movzbl %al,%ecx
 17f:	89 d0                	mov    %edx,%eax
 181:	29 c8                	sub    %ecx,%eax
}
 183:	5d                   	pop    %ebp
 184:	c3                   	ret    

00000185 <strlen>:

uint
strlen(const char *s)
{
 185:	55                   	push   %ebp
 186:	89 e5                	mov    %esp,%ebp
 188:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 18b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 192:	eb 04                	jmp    198 <strlen+0x13>
 194:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 198:	8b 55 fc             	mov    -0x4(%ebp),%edx
 19b:	8b 45 08             	mov    0x8(%ebp),%eax
 19e:	01 d0                	add    %edx,%eax
 1a0:	0f b6 00             	movzbl (%eax),%eax
 1a3:	84 c0                	test   %al,%al
 1a5:	75 ed                	jne    194 <strlen+0xf>
    ;
  return n;
 1a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1aa:	c9                   	leave  
 1ab:	c3                   	ret    

000001ac <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ac:	55                   	push   %ebp
 1ad:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 1af:	8b 45 10             	mov    0x10(%ebp),%eax
 1b2:	50                   	push   %eax
 1b3:	ff 75 0c             	push   0xc(%ebp)
 1b6:	ff 75 08             	push   0x8(%ebp)
 1b9:	e8 32 ff ff ff       	call   f0 <stosb>
 1be:	83 c4 0c             	add    $0xc,%esp
  return dst;
 1c1:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1c4:	c9                   	leave  
 1c5:	c3                   	ret    

000001c6 <strchr>:

char*
strchr(const char *s, char c)
{
 1c6:	55                   	push   %ebp
 1c7:	89 e5                	mov    %esp,%ebp
 1c9:	83 ec 04             	sub    $0x4,%esp
 1cc:	8b 45 0c             	mov    0xc(%ebp),%eax
 1cf:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1d2:	eb 14                	jmp    1e8 <strchr+0x22>
    if(*s == c)
 1d4:	8b 45 08             	mov    0x8(%ebp),%eax
 1d7:	0f b6 00             	movzbl (%eax),%eax
 1da:	38 45 fc             	cmp    %al,-0x4(%ebp)
 1dd:	75 05                	jne    1e4 <strchr+0x1e>
      return (char*)s;
 1df:	8b 45 08             	mov    0x8(%ebp),%eax
 1e2:	eb 13                	jmp    1f7 <strchr+0x31>
  for(; *s; s++)
 1e4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1e8:	8b 45 08             	mov    0x8(%ebp),%eax
 1eb:	0f b6 00             	movzbl (%eax),%eax
 1ee:	84 c0                	test   %al,%al
 1f0:	75 e2                	jne    1d4 <strchr+0xe>
  return 0;
 1f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1f7:	c9                   	leave  
 1f8:	c3                   	ret    

000001f9 <gets>:

char*
gets(char *buf, int max)
{
 1f9:	55                   	push   %ebp
 1fa:	89 e5                	mov    %esp,%ebp
 1fc:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 206:	eb 42                	jmp    24a <gets+0x51>
    cc = read(0, &c, 1);
 208:	83 ec 04             	sub    $0x4,%esp
 20b:	6a 01                	push   $0x1
 20d:	8d 45 ef             	lea    -0x11(%ebp),%eax
 210:	50                   	push   %eax
 211:	6a 00                	push   $0x0
 213:	e8 47 01 00 00       	call   35f <read>
 218:	83 c4 10             	add    $0x10,%esp
 21b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 21e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 222:	7e 33                	jle    257 <gets+0x5e>
      break;
    buf[i++] = c;
 224:	8b 45 f4             	mov    -0xc(%ebp),%eax
 227:	8d 50 01             	lea    0x1(%eax),%edx
 22a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 22d:	89 c2                	mov    %eax,%edx
 22f:	8b 45 08             	mov    0x8(%ebp),%eax
 232:	01 c2                	add    %eax,%edx
 234:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 238:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 23a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 23e:	3c 0a                	cmp    $0xa,%al
 240:	74 16                	je     258 <gets+0x5f>
 242:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 246:	3c 0d                	cmp    $0xd,%al
 248:	74 0e                	je     258 <gets+0x5f>
  for(i=0; i+1 < max; ){
 24a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 24d:	83 c0 01             	add    $0x1,%eax
 250:	39 45 0c             	cmp    %eax,0xc(%ebp)
 253:	7f b3                	jg     208 <gets+0xf>
 255:	eb 01                	jmp    258 <gets+0x5f>
      break;
 257:	90                   	nop
      break;
  }
  buf[i] = '\0';
 258:	8b 55 f4             	mov    -0xc(%ebp),%edx
 25b:	8b 45 08             	mov    0x8(%ebp),%eax
 25e:	01 d0                	add    %edx,%eax
 260:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 263:	8b 45 08             	mov    0x8(%ebp),%eax
}
 266:	c9                   	leave  
 267:	c3                   	ret    

00000268 <stat>:

int
stat(const char *n, struct stat *st)
{
 268:	55                   	push   %ebp
 269:	89 e5                	mov    %esp,%ebp
 26b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 26e:	83 ec 08             	sub    $0x8,%esp
 271:	6a 00                	push   $0x0
 273:	ff 75 08             	push   0x8(%ebp)
 276:	e8 0c 01 00 00       	call   387 <open>
 27b:	83 c4 10             	add    $0x10,%esp
 27e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 281:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 285:	79 07                	jns    28e <stat+0x26>
    return -1;
 287:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 28c:	eb 25                	jmp    2b3 <stat+0x4b>
  r = fstat(fd, st);
 28e:	83 ec 08             	sub    $0x8,%esp
 291:	ff 75 0c             	push   0xc(%ebp)
 294:	ff 75 f4             	push   -0xc(%ebp)
 297:	e8 03 01 00 00       	call   39f <fstat>
 29c:	83 c4 10             	add    $0x10,%esp
 29f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2a2:	83 ec 0c             	sub    $0xc,%esp
 2a5:	ff 75 f4             	push   -0xc(%ebp)
 2a8:	e8 c2 00 00 00       	call   36f <close>
 2ad:	83 c4 10             	add    $0x10,%esp
  return r;
 2b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2b3:	c9                   	leave  
 2b4:	c3                   	ret    

000002b5 <atoi>:

int
atoi(const char *s)
{
 2b5:	55                   	push   %ebp
 2b6:	89 e5                	mov    %esp,%ebp
 2b8:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2bb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2c2:	eb 25                	jmp    2e9 <atoi+0x34>
    n = n*10 + *s++ - '0';
 2c4:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2c7:	89 d0                	mov    %edx,%eax
 2c9:	c1 e0 02             	shl    $0x2,%eax
 2cc:	01 d0                	add    %edx,%eax
 2ce:	01 c0                	add    %eax,%eax
 2d0:	89 c1                	mov    %eax,%ecx
 2d2:	8b 45 08             	mov    0x8(%ebp),%eax
 2d5:	8d 50 01             	lea    0x1(%eax),%edx
 2d8:	89 55 08             	mov    %edx,0x8(%ebp)
 2db:	0f b6 00             	movzbl (%eax),%eax
 2de:	0f be c0             	movsbl %al,%eax
 2e1:	01 c8                	add    %ecx,%eax
 2e3:	83 e8 30             	sub    $0x30,%eax
 2e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2e9:	8b 45 08             	mov    0x8(%ebp),%eax
 2ec:	0f b6 00             	movzbl (%eax),%eax
 2ef:	3c 2f                	cmp    $0x2f,%al
 2f1:	7e 0a                	jle    2fd <atoi+0x48>
 2f3:	8b 45 08             	mov    0x8(%ebp),%eax
 2f6:	0f b6 00             	movzbl (%eax),%eax
 2f9:	3c 39                	cmp    $0x39,%al
 2fb:	7e c7                	jle    2c4 <atoi+0xf>
  return n;
 2fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 300:	c9                   	leave  
 301:	c3                   	ret    

00000302 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 302:	55                   	push   %ebp
 303:	89 e5                	mov    %esp,%ebp
 305:	83 ec 10             	sub    $0x10,%esp
  char *dst;
  const char *src;

  dst = vdst;
 308:	8b 45 08             	mov    0x8(%ebp),%eax
 30b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 30e:	8b 45 0c             	mov    0xc(%ebp),%eax
 311:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 314:	eb 17                	jmp    32d <memmove+0x2b>
    *dst++ = *src++;
 316:	8b 55 f8             	mov    -0x8(%ebp),%edx
 319:	8d 42 01             	lea    0x1(%edx),%eax
 31c:	89 45 f8             	mov    %eax,-0x8(%ebp)
 31f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 322:	8d 48 01             	lea    0x1(%eax),%ecx
 325:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 328:	0f b6 12             	movzbl (%edx),%edx
 32b:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 32d:	8b 45 10             	mov    0x10(%ebp),%eax
 330:	8d 50 ff             	lea    -0x1(%eax),%edx
 333:	89 55 10             	mov    %edx,0x10(%ebp)
 336:	85 c0                	test   %eax,%eax
 338:	7f dc                	jg     316 <memmove+0x14>
  return vdst;
 33a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 33d:	c9                   	leave  
 33e:	c3                   	ret    

0000033f <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 33f:	b8 01 00 00 00       	mov    $0x1,%eax
 344:	cd 40                	int    $0x40
 346:	c3                   	ret    

00000347 <exit>:
SYSCALL(exit)
 347:	b8 02 00 00 00       	mov    $0x2,%eax
 34c:	cd 40                	int    $0x40
 34e:	c3                   	ret    

0000034f <wait>:
SYSCALL(wait)
 34f:	b8 03 00 00 00       	mov    $0x3,%eax
 354:	cd 40                	int    $0x40
 356:	c3                   	ret    

00000357 <pipe>:
SYSCALL(pipe)
 357:	b8 04 00 00 00       	mov    $0x4,%eax
 35c:	cd 40                	int    $0x40
 35e:	c3                   	ret    

0000035f <read>:
SYSCALL(read)
 35f:	b8 05 00 00 00       	mov    $0x5,%eax
 364:	cd 40                	int    $0x40
 366:	c3                   	ret    

00000367 <write>:
SYSCALL(write)
 367:	b8 10 00 00 00       	mov    $0x10,%eax
 36c:	cd 40                	int    $0x40
 36e:	c3                   	ret    

0000036f <close>:
SYSCALL(close)
 36f:	b8 15 00 00 00       	mov    $0x15,%eax
 374:	cd 40                	int    $0x40
 376:	c3                   	ret    

00000377 <kill>:
SYSCALL(kill)
 377:	b8 06 00 00 00       	mov    $0x6,%eax
 37c:	cd 40                	int    $0x40
 37e:	c3                   	ret    

0000037f <exec>:
SYSCALL(exec)
 37f:	b8 07 00 00 00       	mov    $0x7,%eax
 384:	cd 40                	int    $0x40
 386:	c3                   	ret    

00000387 <open>:
SYSCALL(open)
 387:	b8 0f 00 00 00       	mov    $0xf,%eax
 38c:	cd 40                	int    $0x40
 38e:	c3                   	ret    

0000038f <mknod>:
SYSCALL(mknod)
 38f:	b8 11 00 00 00       	mov    $0x11,%eax
 394:	cd 40                	int    $0x40
 396:	c3                   	ret    

00000397 <unlink>:
SYSCALL(unlink)
 397:	b8 12 00 00 00       	mov    $0x12,%eax
 39c:	cd 40                	int    $0x40
 39e:	c3                   	ret    

0000039f <fstat>:
SYSCALL(fstat)
 39f:	b8 08 00 00 00       	mov    $0x8,%eax
 3a4:	cd 40                	int    $0x40
 3a6:	c3                   	ret    

000003a7 <link>:
SYSCALL(link)
 3a7:	b8 13 00 00 00       	mov    $0x13,%eax
 3ac:	cd 40                	int    $0x40
 3ae:	c3                   	ret    

000003af <mkdir>:
SYSCALL(mkdir)
 3af:	b8 14 00 00 00       	mov    $0x14,%eax
 3b4:	cd 40                	int    $0x40
 3b6:	c3                   	ret    

000003b7 <chdir>:
SYSCALL(chdir)
 3b7:	b8 09 00 00 00       	mov    $0x9,%eax
 3bc:	cd 40                	int    $0x40
 3be:	c3                   	ret    

000003bf <dup>:
SYSCALL(dup)
 3bf:	b8 0a 00 00 00       	mov    $0xa,%eax
 3c4:	cd 40                	int    $0x40
 3c6:	c3                   	ret    

000003c7 <getpid>:
SYSCALL(getpid)
 3c7:	b8 0b 00 00 00       	mov    $0xb,%eax
 3cc:	cd 40                	int    $0x40
 3ce:	c3                   	ret    

000003cf <sbrk>:
SYSCALL(sbrk)
 3cf:	b8 0c 00 00 00       	mov    $0xc,%eax
 3d4:	cd 40                	int    $0x40
 3d6:	c3                   	ret    

000003d7 <sleep>:
SYSCALL(sleep)
 3d7:	b8 0d 00 00 00       	mov    $0xd,%eax
 3dc:	cd 40                	int    $0x40
 3de:	c3                   	ret    

000003df <uptime>:
SYSCALL(uptime)
 3df:	b8 0e 00 00 00       	mov    $0xe,%eax
 3e4:	cd 40                	int    $0x40
 3e6:	c3                   	ret    

000003e7 <nice>:
 3e7:	b8 16 00 00 00       	mov    $0x16,%eax
 3ec:	cd 40                	int    $0x40
 3ee:	c3                   	ret    

000003ef <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3ef:	55                   	push   %ebp
 3f0:	89 e5                	mov    %esp,%ebp
 3f2:	83 ec 18             	sub    $0x18,%esp
 3f5:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f8:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3fb:	83 ec 04             	sub    $0x4,%esp
 3fe:	6a 01                	push   $0x1
 400:	8d 45 f4             	lea    -0xc(%ebp),%eax
 403:	50                   	push   %eax
 404:	ff 75 08             	push   0x8(%ebp)
 407:	e8 5b ff ff ff       	call   367 <write>
 40c:	83 c4 10             	add    $0x10,%esp
}
 40f:	90                   	nop
 410:	c9                   	leave  
 411:	c3                   	ret    

00000412 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 412:	55                   	push   %ebp
 413:	89 e5                	mov    %esp,%ebp
 415:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 418:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 41f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 423:	74 17                	je     43c <printint+0x2a>
 425:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 429:	79 11                	jns    43c <printint+0x2a>
    neg = 1;
 42b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 432:	8b 45 0c             	mov    0xc(%ebp),%eax
 435:	f7 d8                	neg    %eax
 437:	89 45 ec             	mov    %eax,-0x14(%ebp)
 43a:	eb 06                	jmp    442 <printint+0x30>
  } else {
    x = xx;
 43c:	8b 45 0c             	mov    0xc(%ebp),%eax
 43f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 442:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 449:	8b 4d 10             	mov    0x10(%ebp),%ecx
 44c:	8b 45 ec             	mov    -0x14(%ebp),%eax
 44f:	ba 00 00 00 00       	mov    $0x0,%edx
 454:	f7 f1                	div    %ecx
 456:	89 d1                	mov    %edx,%ecx
 458:	8b 45 f4             	mov    -0xc(%ebp),%eax
 45b:	8d 50 01             	lea    0x1(%eax),%edx
 45e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 461:	0f b6 91 64 0b 00 00 	movzbl 0xb64(%ecx),%edx
 468:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 46c:	8b 4d 10             	mov    0x10(%ebp),%ecx
 46f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 472:	ba 00 00 00 00       	mov    $0x0,%edx
 477:	f7 f1                	div    %ecx
 479:	89 45 ec             	mov    %eax,-0x14(%ebp)
 47c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 480:	75 c7                	jne    449 <printint+0x37>
  if(neg)
 482:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 486:	74 2d                	je     4b5 <printint+0xa3>
    buf[i++] = '-';
 488:	8b 45 f4             	mov    -0xc(%ebp),%eax
 48b:	8d 50 01             	lea    0x1(%eax),%edx
 48e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 491:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 496:	eb 1d                	jmp    4b5 <printint+0xa3>
    putc(fd, buf[i]);
 498:	8d 55 dc             	lea    -0x24(%ebp),%edx
 49b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 49e:	01 d0                	add    %edx,%eax
 4a0:	0f b6 00             	movzbl (%eax),%eax
 4a3:	0f be c0             	movsbl %al,%eax
 4a6:	83 ec 08             	sub    $0x8,%esp
 4a9:	50                   	push   %eax
 4aa:	ff 75 08             	push   0x8(%ebp)
 4ad:	e8 3d ff ff ff       	call   3ef <putc>
 4b2:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 4b5:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4bd:	79 d9                	jns    498 <printint+0x86>
}
 4bf:	90                   	nop
 4c0:	90                   	nop
 4c1:	c9                   	leave  
 4c2:	c3                   	ret    

000004c3 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 4c3:	55                   	push   %ebp
 4c4:	89 e5                	mov    %esp,%ebp
 4c6:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4c9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4d0:	8d 45 0c             	lea    0xc(%ebp),%eax
 4d3:	83 c0 04             	add    $0x4,%eax
 4d6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4d9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4e0:	e9 59 01 00 00       	jmp    63e <printf+0x17b>
    c = fmt[i] & 0xff;
 4e5:	8b 55 0c             	mov    0xc(%ebp),%edx
 4e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4eb:	01 d0                	add    %edx,%eax
 4ed:	0f b6 00             	movzbl (%eax),%eax
 4f0:	0f be c0             	movsbl %al,%eax
 4f3:	25 ff 00 00 00       	and    $0xff,%eax
 4f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4fb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4ff:	75 2c                	jne    52d <printf+0x6a>
      if(c == '%'){
 501:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 505:	75 0c                	jne    513 <printf+0x50>
        state = '%';
 507:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 50e:	e9 27 01 00 00       	jmp    63a <printf+0x177>
      } else {
        putc(fd, c);
 513:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 516:	0f be c0             	movsbl %al,%eax
 519:	83 ec 08             	sub    $0x8,%esp
 51c:	50                   	push   %eax
 51d:	ff 75 08             	push   0x8(%ebp)
 520:	e8 ca fe ff ff       	call   3ef <putc>
 525:	83 c4 10             	add    $0x10,%esp
 528:	e9 0d 01 00 00       	jmp    63a <printf+0x177>
      }
    } else if(state == '%'){
 52d:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 531:	0f 85 03 01 00 00    	jne    63a <printf+0x177>
      if(c == 'd'){
 537:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 53b:	75 1e                	jne    55b <printf+0x98>
        printint(fd, *ap, 10, 1);
 53d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 540:	8b 00                	mov    (%eax),%eax
 542:	6a 01                	push   $0x1
 544:	6a 0a                	push   $0xa
 546:	50                   	push   %eax
 547:	ff 75 08             	push   0x8(%ebp)
 54a:	e8 c3 fe ff ff       	call   412 <printint>
 54f:	83 c4 10             	add    $0x10,%esp
        ap++;
 552:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 556:	e9 d8 00 00 00       	jmp    633 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 55b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 55f:	74 06                	je     567 <printf+0xa4>
 561:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 565:	75 1e                	jne    585 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 567:	8b 45 e8             	mov    -0x18(%ebp),%eax
 56a:	8b 00                	mov    (%eax),%eax
 56c:	6a 00                	push   $0x0
 56e:	6a 10                	push   $0x10
 570:	50                   	push   %eax
 571:	ff 75 08             	push   0x8(%ebp)
 574:	e8 99 fe ff ff       	call   412 <printint>
 579:	83 c4 10             	add    $0x10,%esp
        ap++;
 57c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 580:	e9 ae 00 00 00       	jmp    633 <printf+0x170>
      } else if(c == 's'){
 585:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 589:	75 43                	jne    5ce <printf+0x10b>
        s = (char*)*ap;
 58b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 58e:	8b 00                	mov    (%eax),%eax
 590:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 593:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 597:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 59b:	75 25                	jne    5c2 <printf+0xff>
          s = "(null)";
 59d:	c7 45 f4 17 09 00 00 	movl   $0x917,-0xc(%ebp)
        while(*s != 0){
 5a4:	eb 1c                	jmp    5c2 <printf+0xff>
          putc(fd, *s);
 5a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5a9:	0f b6 00             	movzbl (%eax),%eax
 5ac:	0f be c0             	movsbl %al,%eax
 5af:	83 ec 08             	sub    $0x8,%esp
 5b2:	50                   	push   %eax
 5b3:	ff 75 08             	push   0x8(%ebp)
 5b6:	e8 34 fe ff ff       	call   3ef <putc>
 5bb:	83 c4 10             	add    $0x10,%esp
          s++;
 5be:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 5c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5c5:	0f b6 00             	movzbl (%eax),%eax
 5c8:	84 c0                	test   %al,%al
 5ca:	75 da                	jne    5a6 <printf+0xe3>
 5cc:	eb 65                	jmp    633 <printf+0x170>
        }
      } else if(c == 'c'){
 5ce:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5d2:	75 1d                	jne    5f1 <printf+0x12e>
        putc(fd, *ap);
 5d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5d7:	8b 00                	mov    (%eax),%eax
 5d9:	0f be c0             	movsbl %al,%eax
 5dc:	83 ec 08             	sub    $0x8,%esp
 5df:	50                   	push   %eax
 5e0:	ff 75 08             	push   0x8(%ebp)
 5e3:	e8 07 fe ff ff       	call   3ef <putc>
 5e8:	83 c4 10             	add    $0x10,%esp
        ap++;
 5eb:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5ef:	eb 42                	jmp    633 <printf+0x170>
      } else if(c == '%'){
 5f1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5f5:	75 17                	jne    60e <printf+0x14b>
        putc(fd, c);
 5f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5fa:	0f be c0             	movsbl %al,%eax
 5fd:	83 ec 08             	sub    $0x8,%esp
 600:	50                   	push   %eax
 601:	ff 75 08             	push   0x8(%ebp)
 604:	e8 e6 fd ff ff       	call   3ef <putc>
 609:	83 c4 10             	add    $0x10,%esp
 60c:	eb 25                	jmp    633 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 60e:	83 ec 08             	sub    $0x8,%esp
 611:	6a 25                	push   $0x25
 613:	ff 75 08             	push   0x8(%ebp)
 616:	e8 d4 fd ff ff       	call   3ef <putc>
 61b:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 61e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 621:	0f be c0             	movsbl %al,%eax
 624:	83 ec 08             	sub    $0x8,%esp
 627:	50                   	push   %eax
 628:	ff 75 08             	push   0x8(%ebp)
 62b:	e8 bf fd ff ff       	call   3ef <putc>
 630:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 633:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 63a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 63e:	8b 55 0c             	mov    0xc(%ebp),%edx
 641:	8b 45 f0             	mov    -0x10(%ebp),%eax
 644:	01 d0                	add    %edx,%eax
 646:	0f b6 00             	movzbl (%eax),%eax
 649:	84 c0                	test   %al,%al
 64b:	0f 85 94 fe ff ff    	jne    4e5 <printf+0x22>
    }
  }
}
 651:	90                   	nop
 652:	90                   	nop
 653:	c9                   	leave  
 654:	c3                   	ret    

00000655 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 655:	55                   	push   %ebp
 656:	89 e5                	mov    %esp,%ebp
 658:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 65b:	8b 45 08             	mov    0x8(%ebp),%eax
 65e:	83 e8 08             	sub    $0x8,%eax
 661:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 664:	a1 80 0b 00 00       	mov    0xb80,%eax
 669:	89 45 fc             	mov    %eax,-0x4(%ebp)
 66c:	eb 24                	jmp    692 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 66e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 671:	8b 00                	mov    (%eax),%eax
 673:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 676:	72 12                	jb     68a <free+0x35>
 678:	8b 45 f8             	mov    -0x8(%ebp),%eax
 67b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 67e:	77 24                	ja     6a4 <free+0x4f>
 680:	8b 45 fc             	mov    -0x4(%ebp),%eax
 683:	8b 00                	mov    (%eax),%eax
 685:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 688:	72 1a                	jb     6a4 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 68a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68d:	8b 00                	mov    (%eax),%eax
 68f:	89 45 fc             	mov    %eax,-0x4(%ebp)
 692:	8b 45 f8             	mov    -0x8(%ebp),%eax
 695:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 698:	76 d4                	jbe    66e <free+0x19>
 69a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69d:	8b 00                	mov    (%eax),%eax
 69f:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6a2:	73 ca                	jae    66e <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 6a4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a7:	8b 40 04             	mov    0x4(%eax),%eax
 6aa:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b4:	01 c2                	add    %eax,%edx
 6b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b9:	8b 00                	mov    (%eax),%eax
 6bb:	39 c2                	cmp    %eax,%edx
 6bd:	75 24                	jne    6e3 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 6bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c2:	8b 50 04             	mov    0x4(%eax),%edx
 6c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c8:	8b 00                	mov    (%eax),%eax
 6ca:	8b 40 04             	mov    0x4(%eax),%eax
 6cd:	01 c2                	add    %eax,%edx
 6cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d2:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d8:	8b 00                	mov    (%eax),%eax
 6da:	8b 10                	mov    (%eax),%edx
 6dc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6df:	89 10                	mov    %edx,(%eax)
 6e1:	eb 0a                	jmp    6ed <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 6e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e6:	8b 10                	mov    (%eax),%edx
 6e8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6eb:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f0:	8b 40 04             	mov    0x4(%eax),%eax
 6f3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6fd:	01 d0                	add    %edx,%eax
 6ff:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 702:	75 20                	jne    724 <free+0xcf>
    p->s.size += bp->s.size;
 704:	8b 45 fc             	mov    -0x4(%ebp),%eax
 707:	8b 50 04             	mov    0x4(%eax),%edx
 70a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 70d:	8b 40 04             	mov    0x4(%eax),%eax
 710:	01 c2                	add    %eax,%edx
 712:	8b 45 fc             	mov    -0x4(%ebp),%eax
 715:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 718:	8b 45 f8             	mov    -0x8(%ebp),%eax
 71b:	8b 10                	mov    (%eax),%edx
 71d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 720:	89 10                	mov    %edx,(%eax)
 722:	eb 08                	jmp    72c <free+0xd7>
  } else
    p->s.ptr = bp;
 724:	8b 45 fc             	mov    -0x4(%ebp),%eax
 727:	8b 55 f8             	mov    -0x8(%ebp),%edx
 72a:	89 10                	mov    %edx,(%eax)
  freep = p;
 72c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72f:	a3 80 0b 00 00       	mov    %eax,0xb80
}
 734:	90                   	nop
 735:	c9                   	leave  
 736:	c3                   	ret    

00000737 <morecore>:

static Header*
morecore(uint nu)
{
 737:	55                   	push   %ebp
 738:	89 e5                	mov    %esp,%ebp
 73a:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 73d:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 744:	77 07                	ja     74d <morecore+0x16>
    nu = 4096;
 746:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 74d:	8b 45 08             	mov    0x8(%ebp),%eax
 750:	c1 e0 03             	shl    $0x3,%eax
 753:	83 ec 0c             	sub    $0xc,%esp
 756:	50                   	push   %eax
 757:	e8 73 fc ff ff       	call   3cf <sbrk>
 75c:	83 c4 10             	add    $0x10,%esp
 75f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 762:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 766:	75 07                	jne    76f <morecore+0x38>
    return 0;
 768:	b8 00 00 00 00       	mov    $0x0,%eax
 76d:	eb 26                	jmp    795 <morecore+0x5e>
  hp = (Header*)p;
 76f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 772:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 775:	8b 45 f0             	mov    -0x10(%ebp),%eax
 778:	8b 55 08             	mov    0x8(%ebp),%edx
 77b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 77e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 781:	83 c0 08             	add    $0x8,%eax
 784:	83 ec 0c             	sub    $0xc,%esp
 787:	50                   	push   %eax
 788:	e8 c8 fe ff ff       	call   655 <free>
 78d:	83 c4 10             	add    $0x10,%esp
  return freep;
 790:	a1 80 0b 00 00       	mov    0xb80,%eax
}
 795:	c9                   	leave  
 796:	c3                   	ret    

00000797 <malloc>:

void*
malloc(uint nbytes)
{
 797:	55                   	push   %ebp
 798:	89 e5                	mov    %esp,%ebp
 79a:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 79d:	8b 45 08             	mov    0x8(%ebp),%eax
 7a0:	83 c0 07             	add    $0x7,%eax
 7a3:	c1 e8 03             	shr    $0x3,%eax
 7a6:	83 c0 01             	add    $0x1,%eax
 7a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7ac:	a1 80 0b 00 00       	mov    0xb80,%eax
 7b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7b4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7b8:	75 23                	jne    7dd <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 7ba:	c7 45 f0 78 0b 00 00 	movl   $0xb78,-0x10(%ebp)
 7c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7c4:	a3 80 0b 00 00       	mov    %eax,0xb80
 7c9:	a1 80 0b 00 00       	mov    0xb80,%eax
 7ce:	a3 78 0b 00 00       	mov    %eax,0xb78
    base.s.size = 0;
 7d3:	c7 05 7c 0b 00 00 00 	movl   $0x0,0xb7c
 7da:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e0:	8b 00                	mov    (%eax),%eax
 7e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e8:	8b 40 04             	mov    0x4(%eax),%eax
 7eb:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7ee:	77 4d                	ja     83d <malloc+0xa6>
      if(p->s.size == nunits)
 7f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f3:	8b 40 04             	mov    0x4(%eax),%eax
 7f6:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7f9:	75 0c                	jne    807 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7fe:	8b 10                	mov    (%eax),%edx
 800:	8b 45 f0             	mov    -0x10(%ebp),%eax
 803:	89 10                	mov    %edx,(%eax)
 805:	eb 26                	jmp    82d <malloc+0x96>
      else {
        p->s.size -= nunits;
 807:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80a:	8b 40 04             	mov    0x4(%eax),%eax
 80d:	2b 45 ec             	sub    -0x14(%ebp),%eax
 810:	89 c2                	mov    %eax,%edx
 812:	8b 45 f4             	mov    -0xc(%ebp),%eax
 815:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 818:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81b:	8b 40 04             	mov    0x4(%eax),%eax
 81e:	c1 e0 03             	shl    $0x3,%eax
 821:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 824:	8b 45 f4             	mov    -0xc(%ebp),%eax
 827:	8b 55 ec             	mov    -0x14(%ebp),%edx
 82a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 82d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 830:	a3 80 0b 00 00       	mov    %eax,0xb80
      return (void*)(p + 1);
 835:	8b 45 f4             	mov    -0xc(%ebp),%eax
 838:	83 c0 08             	add    $0x8,%eax
 83b:	eb 3b                	jmp    878 <malloc+0xe1>
    }
    if(p == freep)
 83d:	a1 80 0b 00 00       	mov    0xb80,%eax
 842:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 845:	75 1e                	jne    865 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 847:	83 ec 0c             	sub    $0xc,%esp
 84a:	ff 75 ec             	push   -0x14(%ebp)
 84d:	e8 e5 fe ff ff       	call   737 <morecore>
 852:	83 c4 10             	add    $0x10,%esp
 855:	89 45 f4             	mov    %eax,-0xc(%ebp)
 858:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 85c:	75 07                	jne    865 <malloc+0xce>
        return 0;
 85e:	b8 00 00 00 00       	mov    $0x0,%eax
 863:	eb 13                	jmp    878 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 865:	8b 45 f4             	mov    -0xc(%ebp),%eax
 868:	89 45 f0             	mov    %eax,-0x10(%ebp)
 86b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86e:	8b 00                	mov    (%eax),%eax
 870:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 873:	e9 6d ff ff ff       	jmp    7e5 <malloc+0x4e>
  }
}
 878:	c9                   	leave  
 879:	c3                   	ret    
