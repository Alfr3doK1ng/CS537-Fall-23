
_test_3:     file format elf32-i386


Disassembly of section .text:

00000000 <getnice>:
#include "types.h"
#include "stat.h"
#include "user.h"
#include "psched.h"

int getnice(int pid) {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	81 ec 18 05 00 00    	sub    $0x518,%esp
    struct pschedinfo st;
    
    if (getschedstate(&st) == 0) {
   9:	83 ec 0c             	sub    $0xc,%esp
   c:	8d 85 f4 fa ff ff    	lea    -0x50c(%ebp),%eax
  12:	50                   	push   %eax
  13:	e8 2c 04 00 00       	call   444 <getschedstate>
  18:	83 c4 10             	add    $0x10,%esp
  1b:	85 c0                	test   %eax,%eax
  1d:	75 46                	jne    65 <getnice+0x65>
        for (int i = 0; i < NPROC; i++) {
  1f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  26:	eb 35                	jmp    5d <getnice+0x5d>
            if (st.inuse[i] && st.pid[i] == pid) {
  28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  2b:	8b 84 85 f4 fa ff ff 	mov    -0x50c(%ebp,%eax,4),%eax
  32:	85 c0                	test   %eax,%eax
  34:	74 23                	je     59 <getnice+0x59>
  36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  39:	05 c0 00 00 00       	add    $0xc0,%eax
  3e:	8b 84 85 f4 fa ff ff 	mov    -0x50c(%ebp,%eax,4),%eax
  45:	39 45 08             	cmp    %eax,0x8(%ebp)
  48:	75 0f                	jne    59 <getnice+0x59>
                return st.nice[i];
  4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  4d:	83 e8 80             	sub    $0xffffff80,%eax
  50:	8b 84 85 f4 fa ff ff 	mov    -0x50c(%ebp,%eax,4),%eax
  57:	eb 18                	jmp    71 <getnice+0x71>
        for (int i = 0; i < NPROC; i++) {
  59:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  5d:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
  61:	7e c5                	jle    28 <getnice+0x28>
  63:	eb 07                	jmp    6c <getnice+0x6c>
            }
        }
    } else {
        return -1;
  65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  6a:	eb 05                	jmp    71 <getnice+0x71>
    }
    return -1;
  6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  71:	c9                   	leave  
  72:	c3                   	ret    

00000073 <main>:

int main(int argc, char *argv[])
{
  73:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  77:	83 e4 f0             	and    $0xfffffff0,%esp
  7a:	ff 71 fc             	push   -0x4(%ecx)
  7d:	55                   	push   %ebp
  7e:	89 e5                	mov    %esp,%ebp
  80:	51                   	push   %ecx
  81:	83 ec 04             	sub    $0x4,%esp
    if (nice(10) != 0) {
  84:	83 ec 0c             	sub    $0xc,%esp
  87:	6a 0a                	push   $0xa
  89:	e8 ae 03 00 00       	call   43c <nice>
  8e:	83 c4 10             	add    $0x10,%esp
  91:	85 c0                	test   %eax,%eax
  93:	74 17                	je     ac <main+0x39>
        printf(1, "XV6_SCHEDULER\t FAILED 0\n");
  95:	83 ec 08             	sub    $0x8,%esp
  98:	68 d7 08 00 00       	push   $0x8d7
  9d:	6a 01                	push   $0x1
  9f:	e8 7c 04 00 00       	call   520 <printf>
  a4:	83 c4 10             	add    $0x10,%esp
        exit();
  a7:	e8 f0 02 00 00       	call   39c <exit>
    }

    if (getnice(getpid()) != 10) {
  ac:	e8 6b 03 00 00       	call   41c <getpid>
  b1:	83 ec 0c             	sub    $0xc,%esp
  b4:	50                   	push   %eax
  b5:	e8 46 ff ff ff       	call   0 <getnice>
  ba:	83 c4 10             	add    $0x10,%esp
  bd:	83 f8 0a             	cmp    $0xa,%eax
  c0:	74 17                	je     d9 <main+0x66>
        printf(1, "XV6_SCHEDULER\t FAILED 1\n");
  c2:	83 ec 08             	sub    $0x8,%esp
  c5:	68 f0 08 00 00       	push   $0x8f0
  ca:	6a 01                	push   $0x1
  cc:	e8 4f 04 00 00       	call   520 <printf>
  d1:	83 c4 10             	add    $0x10,%esp
        exit();
  d4:	e8 c3 02 00 00       	call   39c <exit>
    }
 
    if (nice(0) != 10) {
  d9:	83 ec 0c             	sub    $0xc,%esp
  dc:	6a 00                	push   $0x0
  de:	e8 59 03 00 00       	call   43c <nice>
  e3:	83 c4 10             	add    $0x10,%esp
  e6:	83 f8 0a             	cmp    $0xa,%eax
  e9:	74 17                	je     102 <main+0x8f>
        printf(1, "XV6_SCHEDULER\t FAILED 2\n");
  eb:	83 ec 08             	sub    $0x8,%esp
  ee:	68 09 09 00 00       	push   $0x909
  f3:	6a 01                	push   $0x1
  f5:	e8 26 04 00 00       	call   520 <printf>
  fa:	83 c4 10             	add    $0x10,%esp
        exit();
  fd:	e8 9a 02 00 00       	call   39c <exit>
    }

    if (getnice(getpid()) != 0) {
 102:	e8 15 03 00 00       	call   41c <getpid>
 107:	83 ec 0c             	sub    $0xc,%esp
 10a:	50                   	push   %eax
 10b:	e8 f0 fe ff ff       	call   0 <getnice>
 110:	83 c4 10             	add    $0x10,%esp
 113:	85 c0                	test   %eax,%eax
 115:	74 17                	je     12e <main+0xbb>
        printf(1, "XV6_SCHEDULER\t FAILED 3\n");
 117:	83 ec 08             	sub    $0x8,%esp
 11a:	68 22 09 00 00       	push   $0x922
 11f:	6a 01                	push   $0x1
 121:	e8 fa 03 00 00       	call   520 <printf>
 126:	83 c4 10             	add    $0x10,%esp
        exit();
 129:	e8 6e 02 00 00       	call   39c <exit>
    }
    
    printf(1, "XV6_SCHEDULER\t SUCCESS\n");
 12e:	83 ec 08             	sub    $0x8,%esp
 131:	68 3b 09 00 00       	push   $0x93b
 136:	6a 01                	push   $0x1
 138:	e8 e3 03 00 00       	call   520 <printf>
 13d:	83 c4 10             	add    $0x10,%esp
    exit();
 140:	e8 57 02 00 00       	call   39c <exit>

00000145 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 145:	55                   	push   %ebp
 146:	89 e5                	mov    %esp,%ebp
 148:	57                   	push   %edi
 149:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 14a:	8b 4d 08             	mov    0x8(%ebp),%ecx
 14d:	8b 55 10             	mov    0x10(%ebp),%edx
 150:	8b 45 0c             	mov    0xc(%ebp),%eax
 153:	89 cb                	mov    %ecx,%ebx
 155:	89 df                	mov    %ebx,%edi
 157:	89 d1                	mov    %edx,%ecx
 159:	fc                   	cld    
 15a:	f3 aa                	rep stos %al,%es:(%edi)
 15c:	89 ca                	mov    %ecx,%edx
 15e:	89 fb                	mov    %edi,%ebx
 160:	89 5d 08             	mov    %ebx,0x8(%ebp)
 163:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 166:	90                   	nop
 167:	5b                   	pop    %ebx
 168:	5f                   	pop    %edi
 169:	5d                   	pop    %ebp
 16a:	c3                   	ret    

0000016b <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 16b:	55                   	push   %ebp
 16c:	89 e5                	mov    %esp,%ebp
 16e:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 171:	8b 45 08             	mov    0x8(%ebp),%eax
 174:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 177:	90                   	nop
 178:	8b 55 0c             	mov    0xc(%ebp),%edx
 17b:	8d 42 01             	lea    0x1(%edx),%eax
 17e:	89 45 0c             	mov    %eax,0xc(%ebp)
 181:	8b 45 08             	mov    0x8(%ebp),%eax
 184:	8d 48 01             	lea    0x1(%eax),%ecx
 187:	89 4d 08             	mov    %ecx,0x8(%ebp)
 18a:	0f b6 12             	movzbl (%edx),%edx
 18d:	88 10                	mov    %dl,(%eax)
 18f:	0f b6 00             	movzbl (%eax),%eax
 192:	84 c0                	test   %al,%al
 194:	75 e2                	jne    178 <strcpy+0xd>
    ;
  return os;
 196:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 199:	c9                   	leave  
 19a:	c3                   	ret    

0000019b <strcmp>:

int
strcmp(const char *p, const char *q)
{
 19b:	55                   	push   %ebp
 19c:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 19e:	eb 08                	jmp    1a8 <strcmp+0xd>
    p++, q++;
 1a0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1a4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 1a8:	8b 45 08             	mov    0x8(%ebp),%eax
 1ab:	0f b6 00             	movzbl (%eax),%eax
 1ae:	84 c0                	test   %al,%al
 1b0:	74 10                	je     1c2 <strcmp+0x27>
 1b2:	8b 45 08             	mov    0x8(%ebp),%eax
 1b5:	0f b6 10             	movzbl (%eax),%edx
 1b8:	8b 45 0c             	mov    0xc(%ebp),%eax
 1bb:	0f b6 00             	movzbl (%eax),%eax
 1be:	38 c2                	cmp    %al,%dl
 1c0:	74 de                	je     1a0 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 1c2:	8b 45 08             	mov    0x8(%ebp),%eax
 1c5:	0f b6 00             	movzbl (%eax),%eax
 1c8:	0f b6 d0             	movzbl %al,%edx
 1cb:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ce:	0f b6 00             	movzbl (%eax),%eax
 1d1:	0f b6 c8             	movzbl %al,%ecx
 1d4:	89 d0                	mov    %edx,%eax
 1d6:	29 c8                	sub    %ecx,%eax
}
 1d8:	5d                   	pop    %ebp
 1d9:	c3                   	ret    

000001da <strlen>:

uint
strlen(const char *s)
{
 1da:	55                   	push   %ebp
 1db:	89 e5                	mov    %esp,%ebp
 1dd:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1e0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1e7:	eb 04                	jmp    1ed <strlen+0x13>
 1e9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1ed:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1f0:	8b 45 08             	mov    0x8(%ebp),%eax
 1f3:	01 d0                	add    %edx,%eax
 1f5:	0f b6 00             	movzbl (%eax),%eax
 1f8:	84 c0                	test   %al,%al
 1fa:	75 ed                	jne    1e9 <strlen+0xf>
    ;
  return n;
 1fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1ff:	c9                   	leave  
 200:	c3                   	ret    

00000201 <memset>:

void*
memset(void *dst, int c, uint n)
{
 201:	55                   	push   %ebp
 202:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 204:	8b 45 10             	mov    0x10(%ebp),%eax
 207:	50                   	push   %eax
 208:	ff 75 0c             	push   0xc(%ebp)
 20b:	ff 75 08             	push   0x8(%ebp)
 20e:	e8 32 ff ff ff       	call   145 <stosb>
 213:	83 c4 0c             	add    $0xc,%esp
  return dst;
 216:	8b 45 08             	mov    0x8(%ebp),%eax
}
 219:	c9                   	leave  
 21a:	c3                   	ret    

0000021b <strchr>:

char*
strchr(const char *s, char c)
{
 21b:	55                   	push   %ebp
 21c:	89 e5                	mov    %esp,%ebp
 21e:	83 ec 04             	sub    $0x4,%esp
 221:	8b 45 0c             	mov    0xc(%ebp),%eax
 224:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 227:	eb 14                	jmp    23d <strchr+0x22>
    if(*s == c)
 229:	8b 45 08             	mov    0x8(%ebp),%eax
 22c:	0f b6 00             	movzbl (%eax),%eax
 22f:	38 45 fc             	cmp    %al,-0x4(%ebp)
 232:	75 05                	jne    239 <strchr+0x1e>
      return (char*)s;
 234:	8b 45 08             	mov    0x8(%ebp),%eax
 237:	eb 13                	jmp    24c <strchr+0x31>
  for(; *s; s++)
 239:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 23d:	8b 45 08             	mov    0x8(%ebp),%eax
 240:	0f b6 00             	movzbl (%eax),%eax
 243:	84 c0                	test   %al,%al
 245:	75 e2                	jne    229 <strchr+0xe>
  return 0;
 247:	b8 00 00 00 00       	mov    $0x0,%eax
}
 24c:	c9                   	leave  
 24d:	c3                   	ret    

0000024e <gets>:

char*
gets(char *buf, int max)
{
 24e:	55                   	push   %ebp
 24f:	89 e5                	mov    %esp,%ebp
 251:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 254:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 25b:	eb 42                	jmp    29f <gets+0x51>
    cc = read(0, &c, 1);
 25d:	83 ec 04             	sub    $0x4,%esp
 260:	6a 01                	push   $0x1
 262:	8d 45 ef             	lea    -0x11(%ebp),%eax
 265:	50                   	push   %eax
 266:	6a 00                	push   $0x0
 268:	e8 47 01 00 00       	call   3b4 <read>
 26d:	83 c4 10             	add    $0x10,%esp
 270:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 273:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 277:	7e 33                	jle    2ac <gets+0x5e>
      break;
    buf[i++] = c;
 279:	8b 45 f4             	mov    -0xc(%ebp),%eax
 27c:	8d 50 01             	lea    0x1(%eax),%edx
 27f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 282:	89 c2                	mov    %eax,%edx
 284:	8b 45 08             	mov    0x8(%ebp),%eax
 287:	01 c2                	add    %eax,%edx
 289:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 28d:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 28f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 293:	3c 0a                	cmp    $0xa,%al
 295:	74 16                	je     2ad <gets+0x5f>
 297:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 29b:	3c 0d                	cmp    $0xd,%al
 29d:	74 0e                	je     2ad <gets+0x5f>
  for(i=0; i+1 < max; ){
 29f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2a2:	83 c0 01             	add    $0x1,%eax
 2a5:	39 45 0c             	cmp    %eax,0xc(%ebp)
 2a8:	7f b3                	jg     25d <gets+0xf>
 2aa:	eb 01                	jmp    2ad <gets+0x5f>
      break;
 2ac:	90                   	nop
      break;
  }
  buf[i] = '\0';
 2ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2b0:	8b 45 08             	mov    0x8(%ebp),%eax
 2b3:	01 d0                	add    %edx,%eax
 2b5:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2b8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2bb:	c9                   	leave  
 2bc:	c3                   	ret    

000002bd <stat>:

int
stat(const char *n, struct stat *st)
{
 2bd:	55                   	push   %ebp
 2be:	89 e5                	mov    %esp,%ebp
 2c0:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2c3:	83 ec 08             	sub    $0x8,%esp
 2c6:	6a 00                	push   $0x0
 2c8:	ff 75 08             	push   0x8(%ebp)
 2cb:	e8 0c 01 00 00       	call   3dc <open>
 2d0:	83 c4 10             	add    $0x10,%esp
 2d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2d6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2da:	79 07                	jns    2e3 <stat+0x26>
    return -1;
 2dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2e1:	eb 25                	jmp    308 <stat+0x4b>
  r = fstat(fd, st);
 2e3:	83 ec 08             	sub    $0x8,%esp
 2e6:	ff 75 0c             	push   0xc(%ebp)
 2e9:	ff 75 f4             	push   -0xc(%ebp)
 2ec:	e8 03 01 00 00       	call   3f4 <fstat>
 2f1:	83 c4 10             	add    $0x10,%esp
 2f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2f7:	83 ec 0c             	sub    $0xc,%esp
 2fa:	ff 75 f4             	push   -0xc(%ebp)
 2fd:	e8 c2 00 00 00       	call   3c4 <close>
 302:	83 c4 10             	add    $0x10,%esp
  return r;
 305:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 308:	c9                   	leave  
 309:	c3                   	ret    

0000030a <atoi>:

int
atoi(const char *s)
{
 30a:	55                   	push   %ebp
 30b:	89 e5                	mov    %esp,%ebp
 30d:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 310:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 317:	eb 25                	jmp    33e <atoi+0x34>
    n = n*10 + *s++ - '0';
 319:	8b 55 fc             	mov    -0x4(%ebp),%edx
 31c:	89 d0                	mov    %edx,%eax
 31e:	c1 e0 02             	shl    $0x2,%eax
 321:	01 d0                	add    %edx,%eax
 323:	01 c0                	add    %eax,%eax
 325:	89 c1                	mov    %eax,%ecx
 327:	8b 45 08             	mov    0x8(%ebp),%eax
 32a:	8d 50 01             	lea    0x1(%eax),%edx
 32d:	89 55 08             	mov    %edx,0x8(%ebp)
 330:	0f b6 00             	movzbl (%eax),%eax
 333:	0f be c0             	movsbl %al,%eax
 336:	01 c8                	add    %ecx,%eax
 338:	83 e8 30             	sub    $0x30,%eax
 33b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 33e:	8b 45 08             	mov    0x8(%ebp),%eax
 341:	0f b6 00             	movzbl (%eax),%eax
 344:	3c 2f                	cmp    $0x2f,%al
 346:	7e 0a                	jle    352 <atoi+0x48>
 348:	8b 45 08             	mov    0x8(%ebp),%eax
 34b:	0f b6 00             	movzbl (%eax),%eax
 34e:	3c 39                	cmp    $0x39,%al
 350:	7e c7                	jle    319 <atoi+0xf>
  return n;
 352:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 355:	c9                   	leave  
 356:	c3                   	ret    

00000357 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 357:	55                   	push   %ebp
 358:	89 e5                	mov    %esp,%ebp
 35a:	83 ec 10             	sub    $0x10,%esp
  char *dst;
  const char *src;

  dst = vdst;
 35d:	8b 45 08             	mov    0x8(%ebp),%eax
 360:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 363:	8b 45 0c             	mov    0xc(%ebp),%eax
 366:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 369:	eb 17                	jmp    382 <memmove+0x2b>
    *dst++ = *src++;
 36b:	8b 55 f8             	mov    -0x8(%ebp),%edx
 36e:	8d 42 01             	lea    0x1(%edx),%eax
 371:	89 45 f8             	mov    %eax,-0x8(%ebp)
 374:	8b 45 fc             	mov    -0x4(%ebp),%eax
 377:	8d 48 01             	lea    0x1(%eax),%ecx
 37a:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 37d:	0f b6 12             	movzbl (%edx),%edx
 380:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 382:	8b 45 10             	mov    0x10(%ebp),%eax
 385:	8d 50 ff             	lea    -0x1(%eax),%edx
 388:	89 55 10             	mov    %edx,0x10(%ebp)
 38b:	85 c0                	test   %eax,%eax
 38d:	7f dc                	jg     36b <memmove+0x14>
  return vdst;
 38f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 392:	c9                   	leave  
 393:	c3                   	ret    

00000394 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 394:	b8 01 00 00 00       	mov    $0x1,%eax
 399:	cd 40                	int    $0x40
 39b:	c3                   	ret    

0000039c <exit>:
SYSCALL(exit)
 39c:	b8 02 00 00 00       	mov    $0x2,%eax
 3a1:	cd 40                	int    $0x40
 3a3:	c3                   	ret    

000003a4 <wait>:
SYSCALL(wait)
 3a4:	b8 03 00 00 00       	mov    $0x3,%eax
 3a9:	cd 40                	int    $0x40
 3ab:	c3                   	ret    

000003ac <pipe>:
SYSCALL(pipe)
 3ac:	b8 04 00 00 00       	mov    $0x4,%eax
 3b1:	cd 40                	int    $0x40
 3b3:	c3                   	ret    

000003b4 <read>:
SYSCALL(read)
 3b4:	b8 05 00 00 00       	mov    $0x5,%eax
 3b9:	cd 40                	int    $0x40
 3bb:	c3                   	ret    

000003bc <write>:
SYSCALL(write)
 3bc:	b8 10 00 00 00       	mov    $0x10,%eax
 3c1:	cd 40                	int    $0x40
 3c3:	c3                   	ret    

000003c4 <close>:
SYSCALL(close)
 3c4:	b8 15 00 00 00       	mov    $0x15,%eax
 3c9:	cd 40                	int    $0x40
 3cb:	c3                   	ret    

000003cc <kill>:
SYSCALL(kill)
 3cc:	b8 06 00 00 00       	mov    $0x6,%eax
 3d1:	cd 40                	int    $0x40
 3d3:	c3                   	ret    

000003d4 <exec>:
SYSCALL(exec)
 3d4:	b8 07 00 00 00       	mov    $0x7,%eax
 3d9:	cd 40                	int    $0x40
 3db:	c3                   	ret    

000003dc <open>:
SYSCALL(open)
 3dc:	b8 0f 00 00 00       	mov    $0xf,%eax
 3e1:	cd 40                	int    $0x40
 3e3:	c3                   	ret    

000003e4 <mknod>:
SYSCALL(mknod)
 3e4:	b8 11 00 00 00       	mov    $0x11,%eax
 3e9:	cd 40                	int    $0x40
 3eb:	c3                   	ret    

000003ec <unlink>:
SYSCALL(unlink)
 3ec:	b8 12 00 00 00       	mov    $0x12,%eax
 3f1:	cd 40                	int    $0x40
 3f3:	c3                   	ret    

000003f4 <fstat>:
SYSCALL(fstat)
 3f4:	b8 08 00 00 00       	mov    $0x8,%eax
 3f9:	cd 40                	int    $0x40
 3fb:	c3                   	ret    

000003fc <link>:
SYSCALL(link)
 3fc:	b8 13 00 00 00       	mov    $0x13,%eax
 401:	cd 40                	int    $0x40
 403:	c3                   	ret    

00000404 <mkdir>:
SYSCALL(mkdir)
 404:	b8 14 00 00 00       	mov    $0x14,%eax
 409:	cd 40                	int    $0x40
 40b:	c3                   	ret    

0000040c <chdir>:
SYSCALL(chdir)
 40c:	b8 09 00 00 00       	mov    $0x9,%eax
 411:	cd 40                	int    $0x40
 413:	c3                   	ret    

00000414 <dup>:
SYSCALL(dup)
 414:	b8 0a 00 00 00       	mov    $0xa,%eax
 419:	cd 40                	int    $0x40
 41b:	c3                   	ret    

0000041c <getpid>:
SYSCALL(getpid)
 41c:	b8 0b 00 00 00       	mov    $0xb,%eax
 421:	cd 40                	int    $0x40
 423:	c3                   	ret    

00000424 <sbrk>:
SYSCALL(sbrk)
 424:	b8 0c 00 00 00       	mov    $0xc,%eax
 429:	cd 40                	int    $0x40
 42b:	c3                   	ret    

0000042c <sleep>:
SYSCALL(sleep)
 42c:	b8 0d 00 00 00       	mov    $0xd,%eax
 431:	cd 40                	int    $0x40
 433:	c3                   	ret    

00000434 <uptime>:
SYSCALL(uptime)
 434:	b8 0e 00 00 00       	mov    $0xe,%eax
 439:	cd 40                	int    $0x40
 43b:	c3                   	ret    

0000043c <nice>:
SYSCALL(nice)
 43c:	b8 16 00 00 00       	mov    $0x16,%eax
 441:	cd 40                	int    $0x40
 443:	c3                   	ret    

00000444 <getschedstate>:
 444:	b8 17 00 00 00       	mov    $0x17,%eax
 449:	cd 40                	int    $0x40
 44b:	c3                   	ret    

0000044c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 44c:	55                   	push   %ebp
 44d:	89 e5                	mov    %esp,%ebp
 44f:	83 ec 18             	sub    $0x18,%esp
 452:	8b 45 0c             	mov    0xc(%ebp),%eax
 455:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 458:	83 ec 04             	sub    $0x4,%esp
 45b:	6a 01                	push   $0x1
 45d:	8d 45 f4             	lea    -0xc(%ebp),%eax
 460:	50                   	push   %eax
 461:	ff 75 08             	push   0x8(%ebp)
 464:	e8 53 ff ff ff       	call   3bc <write>
 469:	83 c4 10             	add    $0x10,%esp
}
 46c:	90                   	nop
 46d:	c9                   	leave  
 46e:	c3                   	ret    

0000046f <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 46f:	55                   	push   %ebp
 470:	89 e5                	mov    %esp,%ebp
 472:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 475:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 47c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 480:	74 17                	je     499 <printint+0x2a>
 482:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 486:	79 11                	jns    499 <printint+0x2a>
    neg = 1;
 488:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 48f:	8b 45 0c             	mov    0xc(%ebp),%eax
 492:	f7 d8                	neg    %eax
 494:	89 45 ec             	mov    %eax,-0x14(%ebp)
 497:	eb 06                	jmp    49f <printint+0x30>
  } else {
    x = xx;
 499:	8b 45 0c             	mov    0xc(%ebp),%eax
 49c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 49f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
 4a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4ac:	ba 00 00 00 00       	mov    $0x0,%edx
 4b1:	f7 f1                	div    %ecx
 4b3:	89 d1                	mov    %edx,%ecx
 4b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4b8:	8d 50 01             	lea    0x1(%eax),%edx
 4bb:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4be:	0f b6 91 c0 0b 00 00 	movzbl 0xbc0(%ecx),%edx
 4c5:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 4c9:	8b 4d 10             	mov    0x10(%ebp),%ecx
 4cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4cf:	ba 00 00 00 00       	mov    $0x0,%edx
 4d4:	f7 f1                	div    %ecx
 4d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4d9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4dd:	75 c7                	jne    4a6 <printint+0x37>
  if(neg)
 4df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4e3:	74 2d                	je     512 <printint+0xa3>
    buf[i++] = '-';
 4e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4e8:	8d 50 01             	lea    0x1(%eax),%edx
 4eb:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4ee:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4f3:	eb 1d                	jmp    512 <printint+0xa3>
    putc(fd, buf[i]);
 4f5:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4fb:	01 d0                	add    %edx,%eax
 4fd:	0f b6 00             	movzbl (%eax),%eax
 500:	0f be c0             	movsbl %al,%eax
 503:	83 ec 08             	sub    $0x8,%esp
 506:	50                   	push   %eax
 507:	ff 75 08             	push   0x8(%ebp)
 50a:	e8 3d ff ff ff       	call   44c <putc>
 50f:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 512:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 516:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 51a:	79 d9                	jns    4f5 <printint+0x86>
}
 51c:	90                   	nop
 51d:	90                   	nop
 51e:	c9                   	leave  
 51f:	c3                   	ret    

00000520 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 520:	55                   	push   %ebp
 521:	89 e5                	mov    %esp,%ebp
 523:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 526:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 52d:	8d 45 0c             	lea    0xc(%ebp),%eax
 530:	83 c0 04             	add    $0x4,%eax
 533:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 536:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 53d:	e9 59 01 00 00       	jmp    69b <printf+0x17b>
    c = fmt[i] & 0xff;
 542:	8b 55 0c             	mov    0xc(%ebp),%edx
 545:	8b 45 f0             	mov    -0x10(%ebp),%eax
 548:	01 d0                	add    %edx,%eax
 54a:	0f b6 00             	movzbl (%eax),%eax
 54d:	0f be c0             	movsbl %al,%eax
 550:	25 ff 00 00 00       	and    $0xff,%eax
 555:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 558:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 55c:	75 2c                	jne    58a <printf+0x6a>
      if(c == '%'){
 55e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 562:	75 0c                	jne    570 <printf+0x50>
        state = '%';
 564:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 56b:	e9 27 01 00 00       	jmp    697 <printf+0x177>
      } else {
        putc(fd, c);
 570:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 573:	0f be c0             	movsbl %al,%eax
 576:	83 ec 08             	sub    $0x8,%esp
 579:	50                   	push   %eax
 57a:	ff 75 08             	push   0x8(%ebp)
 57d:	e8 ca fe ff ff       	call   44c <putc>
 582:	83 c4 10             	add    $0x10,%esp
 585:	e9 0d 01 00 00       	jmp    697 <printf+0x177>
      }
    } else if(state == '%'){
 58a:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 58e:	0f 85 03 01 00 00    	jne    697 <printf+0x177>
      if(c == 'd'){
 594:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 598:	75 1e                	jne    5b8 <printf+0x98>
        printint(fd, *ap, 10, 1);
 59a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 59d:	8b 00                	mov    (%eax),%eax
 59f:	6a 01                	push   $0x1
 5a1:	6a 0a                	push   $0xa
 5a3:	50                   	push   %eax
 5a4:	ff 75 08             	push   0x8(%ebp)
 5a7:	e8 c3 fe ff ff       	call   46f <printint>
 5ac:	83 c4 10             	add    $0x10,%esp
        ap++;
 5af:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5b3:	e9 d8 00 00 00       	jmp    690 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 5b8:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5bc:	74 06                	je     5c4 <printf+0xa4>
 5be:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5c2:	75 1e                	jne    5e2 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 5c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5c7:	8b 00                	mov    (%eax),%eax
 5c9:	6a 00                	push   $0x0
 5cb:	6a 10                	push   $0x10
 5cd:	50                   	push   %eax
 5ce:	ff 75 08             	push   0x8(%ebp)
 5d1:	e8 99 fe ff ff       	call   46f <printint>
 5d6:	83 c4 10             	add    $0x10,%esp
        ap++;
 5d9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5dd:	e9 ae 00 00 00       	jmp    690 <printf+0x170>
      } else if(c == 's'){
 5e2:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5e6:	75 43                	jne    62b <printf+0x10b>
        s = (char*)*ap;
 5e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5eb:	8b 00                	mov    (%eax),%eax
 5ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5f0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5f8:	75 25                	jne    61f <printf+0xff>
          s = "(null)";
 5fa:	c7 45 f4 53 09 00 00 	movl   $0x953,-0xc(%ebp)
        while(*s != 0){
 601:	eb 1c                	jmp    61f <printf+0xff>
          putc(fd, *s);
 603:	8b 45 f4             	mov    -0xc(%ebp),%eax
 606:	0f b6 00             	movzbl (%eax),%eax
 609:	0f be c0             	movsbl %al,%eax
 60c:	83 ec 08             	sub    $0x8,%esp
 60f:	50                   	push   %eax
 610:	ff 75 08             	push   0x8(%ebp)
 613:	e8 34 fe ff ff       	call   44c <putc>
 618:	83 c4 10             	add    $0x10,%esp
          s++;
 61b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 61f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 622:	0f b6 00             	movzbl (%eax),%eax
 625:	84 c0                	test   %al,%al
 627:	75 da                	jne    603 <printf+0xe3>
 629:	eb 65                	jmp    690 <printf+0x170>
        }
      } else if(c == 'c'){
 62b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 62f:	75 1d                	jne    64e <printf+0x12e>
        putc(fd, *ap);
 631:	8b 45 e8             	mov    -0x18(%ebp),%eax
 634:	8b 00                	mov    (%eax),%eax
 636:	0f be c0             	movsbl %al,%eax
 639:	83 ec 08             	sub    $0x8,%esp
 63c:	50                   	push   %eax
 63d:	ff 75 08             	push   0x8(%ebp)
 640:	e8 07 fe ff ff       	call   44c <putc>
 645:	83 c4 10             	add    $0x10,%esp
        ap++;
 648:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 64c:	eb 42                	jmp    690 <printf+0x170>
      } else if(c == '%'){
 64e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 652:	75 17                	jne    66b <printf+0x14b>
        putc(fd, c);
 654:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 657:	0f be c0             	movsbl %al,%eax
 65a:	83 ec 08             	sub    $0x8,%esp
 65d:	50                   	push   %eax
 65e:	ff 75 08             	push   0x8(%ebp)
 661:	e8 e6 fd ff ff       	call   44c <putc>
 666:	83 c4 10             	add    $0x10,%esp
 669:	eb 25                	jmp    690 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 66b:	83 ec 08             	sub    $0x8,%esp
 66e:	6a 25                	push   $0x25
 670:	ff 75 08             	push   0x8(%ebp)
 673:	e8 d4 fd ff ff       	call   44c <putc>
 678:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 67b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 67e:	0f be c0             	movsbl %al,%eax
 681:	83 ec 08             	sub    $0x8,%esp
 684:	50                   	push   %eax
 685:	ff 75 08             	push   0x8(%ebp)
 688:	e8 bf fd ff ff       	call   44c <putc>
 68d:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 690:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 697:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 69b:	8b 55 0c             	mov    0xc(%ebp),%edx
 69e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6a1:	01 d0                	add    %edx,%eax
 6a3:	0f b6 00             	movzbl (%eax),%eax
 6a6:	84 c0                	test   %al,%al
 6a8:	0f 85 94 fe ff ff    	jne    542 <printf+0x22>
    }
  }
}
 6ae:	90                   	nop
 6af:	90                   	nop
 6b0:	c9                   	leave  
 6b1:	c3                   	ret    

000006b2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6b2:	55                   	push   %ebp
 6b3:	89 e5                	mov    %esp,%ebp
 6b5:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6b8:	8b 45 08             	mov    0x8(%ebp),%eax
 6bb:	83 e8 08             	sub    $0x8,%eax
 6be:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c1:	a1 dc 0b 00 00       	mov    0xbdc,%eax
 6c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6c9:	eb 24                	jmp    6ef <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ce:	8b 00                	mov    (%eax),%eax
 6d0:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 6d3:	72 12                	jb     6e7 <free+0x35>
 6d5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6db:	77 24                	ja     701 <free+0x4f>
 6dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e0:	8b 00                	mov    (%eax),%eax
 6e2:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6e5:	72 1a                	jb     701 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ea:	8b 00                	mov    (%eax),%eax
 6ec:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6ef:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6f5:	76 d4                	jbe    6cb <free+0x19>
 6f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6fa:	8b 00                	mov    (%eax),%eax
 6fc:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6ff:	73 ca                	jae    6cb <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 701:	8b 45 f8             	mov    -0x8(%ebp),%eax
 704:	8b 40 04             	mov    0x4(%eax),%eax
 707:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 70e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 711:	01 c2                	add    %eax,%edx
 713:	8b 45 fc             	mov    -0x4(%ebp),%eax
 716:	8b 00                	mov    (%eax),%eax
 718:	39 c2                	cmp    %eax,%edx
 71a:	75 24                	jne    740 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 71c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 71f:	8b 50 04             	mov    0x4(%eax),%edx
 722:	8b 45 fc             	mov    -0x4(%ebp),%eax
 725:	8b 00                	mov    (%eax),%eax
 727:	8b 40 04             	mov    0x4(%eax),%eax
 72a:	01 c2                	add    %eax,%edx
 72c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 72f:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 732:	8b 45 fc             	mov    -0x4(%ebp),%eax
 735:	8b 00                	mov    (%eax),%eax
 737:	8b 10                	mov    (%eax),%edx
 739:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73c:	89 10                	mov    %edx,(%eax)
 73e:	eb 0a                	jmp    74a <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 740:	8b 45 fc             	mov    -0x4(%ebp),%eax
 743:	8b 10                	mov    (%eax),%edx
 745:	8b 45 f8             	mov    -0x8(%ebp),%eax
 748:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 74a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74d:	8b 40 04             	mov    0x4(%eax),%eax
 750:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 757:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75a:	01 d0                	add    %edx,%eax
 75c:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 75f:	75 20                	jne    781 <free+0xcf>
    p->s.size += bp->s.size;
 761:	8b 45 fc             	mov    -0x4(%ebp),%eax
 764:	8b 50 04             	mov    0x4(%eax),%edx
 767:	8b 45 f8             	mov    -0x8(%ebp),%eax
 76a:	8b 40 04             	mov    0x4(%eax),%eax
 76d:	01 c2                	add    %eax,%edx
 76f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 772:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 775:	8b 45 f8             	mov    -0x8(%ebp),%eax
 778:	8b 10                	mov    (%eax),%edx
 77a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77d:	89 10                	mov    %edx,(%eax)
 77f:	eb 08                	jmp    789 <free+0xd7>
  } else
    p->s.ptr = bp;
 781:	8b 45 fc             	mov    -0x4(%ebp),%eax
 784:	8b 55 f8             	mov    -0x8(%ebp),%edx
 787:	89 10                	mov    %edx,(%eax)
  freep = p;
 789:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78c:	a3 dc 0b 00 00       	mov    %eax,0xbdc
}
 791:	90                   	nop
 792:	c9                   	leave  
 793:	c3                   	ret    

00000794 <morecore>:

static Header*
morecore(uint nu)
{
 794:	55                   	push   %ebp
 795:	89 e5                	mov    %esp,%ebp
 797:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 79a:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7a1:	77 07                	ja     7aa <morecore+0x16>
    nu = 4096;
 7a3:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7aa:	8b 45 08             	mov    0x8(%ebp),%eax
 7ad:	c1 e0 03             	shl    $0x3,%eax
 7b0:	83 ec 0c             	sub    $0xc,%esp
 7b3:	50                   	push   %eax
 7b4:	e8 6b fc ff ff       	call   424 <sbrk>
 7b9:	83 c4 10             	add    $0x10,%esp
 7bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7bf:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7c3:	75 07                	jne    7cc <morecore+0x38>
    return 0;
 7c5:	b8 00 00 00 00       	mov    $0x0,%eax
 7ca:	eb 26                	jmp    7f2 <morecore+0x5e>
  hp = (Header*)p;
 7cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d5:	8b 55 08             	mov    0x8(%ebp),%edx
 7d8:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7db:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7de:	83 c0 08             	add    $0x8,%eax
 7e1:	83 ec 0c             	sub    $0xc,%esp
 7e4:	50                   	push   %eax
 7e5:	e8 c8 fe ff ff       	call   6b2 <free>
 7ea:	83 c4 10             	add    $0x10,%esp
  return freep;
 7ed:	a1 dc 0b 00 00       	mov    0xbdc,%eax
}
 7f2:	c9                   	leave  
 7f3:	c3                   	ret    

000007f4 <malloc>:

void*
malloc(uint nbytes)
{
 7f4:	55                   	push   %ebp
 7f5:	89 e5                	mov    %esp,%ebp
 7f7:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7fa:	8b 45 08             	mov    0x8(%ebp),%eax
 7fd:	83 c0 07             	add    $0x7,%eax
 800:	c1 e8 03             	shr    $0x3,%eax
 803:	83 c0 01             	add    $0x1,%eax
 806:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 809:	a1 dc 0b 00 00       	mov    0xbdc,%eax
 80e:	89 45 f0             	mov    %eax,-0x10(%ebp)
 811:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 815:	75 23                	jne    83a <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 817:	c7 45 f0 d4 0b 00 00 	movl   $0xbd4,-0x10(%ebp)
 81e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 821:	a3 dc 0b 00 00       	mov    %eax,0xbdc
 826:	a1 dc 0b 00 00       	mov    0xbdc,%eax
 82b:	a3 d4 0b 00 00       	mov    %eax,0xbd4
    base.s.size = 0;
 830:	c7 05 d8 0b 00 00 00 	movl   $0x0,0xbd8
 837:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 83a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 83d:	8b 00                	mov    (%eax),%eax
 83f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 842:	8b 45 f4             	mov    -0xc(%ebp),%eax
 845:	8b 40 04             	mov    0x4(%eax),%eax
 848:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 84b:	77 4d                	ja     89a <malloc+0xa6>
      if(p->s.size == nunits)
 84d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 850:	8b 40 04             	mov    0x4(%eax),%eax
 853:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 856:	75 0c                	jne    864 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 858:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85b:	8b 10                	mov    (%eax),%edx
 85d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 860:	89 10                	mov    %edx,(%eax)
 862:	eb 26                	jmp    88a <malloc+0x96>
      else {
        p->s.size -= nunits;
 864:	8b 45 f4             	mov    -0xc(%ebp),%eax
 867:	8b 40 04             	mov    0x4(%eax),%eax
 86a:	2b 45 ec             	sub    -0x14(%ebp),%eax
 86d:	89 c2                	mov    %eax,%edx
 86f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 872:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 875:	8b 45 f4             	mov    -0xc(%ebp),%eax
 878:	8b 40 04             	mov    0x4(%eax),%eax
 87b:	c1 e0 03             	shl    $0x3,%eax
 87e:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 881:	8b 45 f4             	mov    -0xc(%ebp),%eax
 884:	8b 55 ec             	mov    -0x14(%ebp),%edx
 887:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 88a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 88d:	a3 dc 0b 00 00       	mov    %eax,0xbdc
      return (void*)(p + 1);
 892:	8b 45 f4             	mov    -0xc(%ebp),%eax
 895:	83 c0 08             	add    $0x8,%eax
 898:	eb 3b                	jmp    8d5 <malloc+0xe1>
    }
    if(p == freep)
 89a:	a1 dc 0b 00 00       	mov    0xbdc,%eax
 89f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8a2:	75 1e                	jne    8c2 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 8a4:	83 ec 0c             	sub    $0xc,%esp
 8a7:	ff 75 ec             	push   -0x14(%ebp)
 8aa:	e8 e5 fe ff ff       	call   794 <morecore>
 8af:	83 c4 10             	add    $0x10,%esp
 8b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8b9:	75 07                	jne    8c2 <malloc+0xce>
        return 0;
 8bb:	b8 00 00 00 00       	mov    $0x0,%eax
 8c0:	eb 13                	jmp    8d5 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8cb:	8b 00                	mov    (%eax),%eax
 8cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8d0:	e9 6d ff ff ff       	jmp    842 <malloc+0x4e>
  }
}
 8d5:	c9                   	leave  
 8d6:	c3                   	ret    
