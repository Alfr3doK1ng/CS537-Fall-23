
_test_6:     file format elf32-i386


Disassembly of section .text:

00000000 <getpriority>:
#include "types.h"
#include "stat.h"
#include "user.h"
#include "psched.h"

int getpriority(int pid) {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	81 ec 18 05 00 00    	sub    $0x518,%esp
    struct pschedinfo st;
    
    if (getschedstate(&st) == 0) {
   9:	83 ec 0c             	sub    $0xc,%esp
   c:	8d 85 f4 fa ff ff    	lea    -0x50c(%ebp),%eax
  12:	50                   	push   %eax
  13:	e8 99 05 00 00       	call   5b1 <getschedstate>
  18:	83 c4 10             	add    $0x10,%esp
  1b:	85 c0                	test   %eax,%eax
  1d:	75 46                	jne    65 <getpriority+0x65>
        for (int i = 0; i < NPROC; i++) {
  1f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  26:	eb 35                	jmp    5d <getpriority+0x5d>
            if (st.inuse[i] && st.pid[i] == pid) {
  28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  2b:	8b 84 85 f4 fa ff ff 	mov    -0x50c(%ebp,%eax,4),%eax
  32:	85 c0                	test   %eax,%eax
  34:	74 23                	je     59 <getpriority+0x59>
  36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  39:	05 c0 00 00 00       	add    $0xc0,%eax
  3e:	8b 84 85 f4 fa ff ff 	mov    -0x50c(%ebp,%eax,4),%eax
  45:	39 45 08             	cmp    %eax,0x8(%ebp)
  48:	75 0f                	jne    59 <getpriority+0x59>
                return st.priority[i];
  4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  4d:	83 c0 40             	add    $0x40,%eax
  50:	8b 84 85 f4 fa ff ff 	mov    -0x50c(%ebp,%eax,4),%eax
  57:	eb 18                	jmp    71 <getpriority+0x71>
        for (int i = 0; i < NPROC; i++) {
  59:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  5d:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
  61:	7e c5                	jle    28 <getpriority+0x28>
  63:	eb 07                	jmp    6c <getpriority+0x6c>
            }
        }
    } else {
        return -1;
  65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  6a:	eb 05                	jmp    71 <getpriority+0x71>
    }
    return -1;
  6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  71:	c9                   	leave  
  72:	c3                   	ret    

00000073 <getcputicks>:

int getcputicks(int pid) {
  73:	55                   	push   %ebp
  74:	89 e5                	mov    %esp,%ebp
  76:	81 ec 18 05 00 00    	sub    $0x518,%esp
    struct pschedinfo st;
    
    if (getschedstate(&st) == 0) {
  7c:	83 ec 0c             	sub    $0xc,%esp
  7f:	8d 85 f4 fa ff ff    	lea    -0x50c(%ebp),%eax
  85:	50                   	push   %eax
  86:	e8 26 05 00 00       	call   5b1 <getschedstate>
  8b:	83 c4 10             	add    $0x10,%esp
  8e:	85 c0                	test   %eax,%eax
  90:	75 48                	jne    da <getcputicks+0x67>
        for (int i = 0; i < NPROC; i++) {
  92:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  99:	eb 37                	jmp    d2 <getcputicks+0x5f>
            if (st.inuse[i] && st.pid[i] == pid) {
  9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  9e:	8b 84 85 f4 fa ff ff 	mov    -0x50c(%ebp,%eax,4),%eax
  a5:	85 c0                	test   %eax,%eax
  a7:	74 25                	je     ce <getcputicks+0x5b>
  a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  ac:	05 c0 00 00 00       	add    $0xc0,%eax
  b1:	8b 84 85 f4 fa ff ff 	mov    -0x50c(%ebp,%eax,4),%eax
  b8:	39 45 08             	cmp    %eax,0x8(%ebp)
  bb:	75 11                	jne    ce <getcputicks+0x5b>
                return st.ticks[i];
  bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  c0:	05 00 01 00 00       	add    $0x100,%eax
  c5:	8b 84 85 f4 fa ff ff 	mov    -0x50c(%ebp,%eax,4),%eax
  cc:	eb 18                	jmp    e6 <getcputicks+0x73>
        for (int i = 0; i < NPROC; i++) {
  ce:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  d2:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
  d6:	7e c3                	jle    9b <getcputicks+0x28>
  d8:	eb 07                	jmp    e1 <getcputicks+0x6e>
            }
        }
    } else {
        return -1;
  da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  df:	eb 05                	jmp    e6 <getcputicks+0x73>
    }
    return -1;
  e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  e6:	c9                   	leave  
  e7:	c3                   	ret    

000000e8 <spin>:

void spin() {
  e8:	55                   	push   %ebp
  e9:	89 e5                	mov    %esp,%ebp
  eb:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; i < 100000000; i++) {
  ee:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  f5:	eb 25                	jmp    11c <spin+0x34>
        if (i % 10000000 == 0) {
  f7:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  fa:	ba 6b ca 5f 6b       	mov    $0x6b5fca6b,%edx
  ff:	89 c8                	mov    %ecx,%eax
 101:	f7 ea                	imul   %edx
 103:	89 d0                	mov    %edx,%eax
 105:	c1 f8 16             	sar    $0x16,%eax
 108:	89 ca                	mov    %ecx,%edx
 10a:	c1 fa 1f             	sar    $0x1f,%edx
 10d:	29 d0                	sub    %edx,%eax
 10f:	69 d0 80 96 98 00    	imul   $0x989680,%eax,%edx
 115:	29 d1                	sub    %edx,%ecx
            // int priority = getpriority(getpid());
            // int ticks = getcputicks(getpid());
            // printf(1, "cpu_ticks is %d\n", ticks); 
            // printf(1, "priority is %d\n", priority); 
        }
        asm("nop");
 117:	90                   	nop
    for (i = 0; i < 100000000; i++) {
 118:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 11c:	81 7d fc ff e0 f5 05 	cmpl   $0x5f5e0ff,-0x4(%ebp)
 123:	7e d2                	jle    f7 <spin+0xf>
    }
}
 125:	90                   	nop
 126:	90                   	nop
 127:	c9                   	leave  
 128:	c3                   	ret    

00000129 <main>:

int
main(int argc, char *argv[])
{
 129:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 12d:	83 e4 f0             	and    $0xfffffff0,%esp
 130:	ff 71 fc             	push   -0x4(%ecx)
 133:	55                   	push   %ebp
 134:	89 e5                	mov    %esp,%ebp
 136:	51                   	push   %ecx
 137:	83 ec 14             	sub    $0x14,%esp
    int pid = getpid();
 13a:	e8 4a 04 00 00       	call   589 <getpid>
 13f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (getpriority(pid) != 0) {
 142:	83 ec 0c             	sub    $0xc,%esp
 145:	ff 75 f4             	push   -0xc(%ebp)
 148:	e8 b3 fe ff ff       	call   0 <getpriority>
 14d:	83 c4 10             	add    $0x10,%esp
 150:	85 c0                	test   %eax,%eax
 152:	74 29                	je     17d <main+0x54>
        printf(1, "initial priority was non-zero\n");
 154:	83 ec 08             	sub    $0x8,%esp
 157:	68 44 0a 00 00       	push   $0xa44
 15c:	6a 01                	push   $0x1
 15e:	e8 2a 05 00 00       	call   68d <printf>
 163:	83 c4 10             	add    $0x10,%esp
        printf(1, "XV6_SCHEDULER\t FAILED\n");
 166:	83 ec 08             	sub    $0x8,%esp
 169:	68 63 0a 00 00       	push   $0xa63
 16e:	6a 01                	push   $0x1
 170:	e8 18 05 00 00       	call   68d <printf>
 175:	83 c4 10             	add    $0x10,%esp
        exit();
 178:	e8 8c 03 00 00       	call   509 <exit>
    }

    spin();
 17d:	e8 66 ff ff ff       	call   e8 <spin>
    printf(1, "ticks after spin is %d\n", getcputicks(pid));
 182:	83 ec 0c             	sub    $0xc,%esp
 185:	ff 75 f4             	push   -0xc(%ebp)
 188:	e8 e6 fe ff ff       	call   73 <getcputicks>
 18d:	83 c4 10             	add    $0x10,%esp
 190:	83 ec 04             	sub    $0x4,%esp
 193:	50                   	push   %eax
 194:	68 7a 0a 00 00       	push   $0xa7a
 199:	6a 01                	push   $0x1
 19b:	e8 ed 04 00 00       	call   68d <printf>
 1a0:	83 c4 10             	add    $0x10,%esp
    printf(1, "priority after spin is %d\n", getpriority(pid));
 1a3:	83 ec 0c             	sub    $0xc,%esp
 1a6:	ff 75 f4             	push   -0xc(%ebp)
 1a9:	e8 52 fe ff ff       	call   0 <getpriority>
 1ae:	83 c4 10             	add    $0x10,%esp
 1b1:	83 ec 04             	sub    $0x4,%esp
 1b4:	50                   	push   %eax
 1b5:	68 92 0a 00 00       	push   $0xa92
 1ba:	6a 01                	push   $0x1
 1bc:	e8 cc 04 00 00       	call   68d <printf>
 1c1:	83 c4 10             	add    $0x10,%esp
    printf(1, "uptime before sleep is %d\n", uptime());
 1c4:	e8 d8 03 00 00       	call   5a1 <uptime>
 1c9:	83 ec 04             	sub    $0x4,%esp
 1cc:	50                   	push   %eax
 1cd:	68 ad 0a 00 00       	push   $0xaad
 1d2:	6a 01                	push   $0x1
 1d4:	e8 b4 04 00 00       	call   68d <printf>
 1d9:	83 c4 10             	add    $0x10,%esp
    sleep(120);
 1dc:	83 ec 0c             	sub    $0xc,%esp
 1df:	6a 78                	push   $0x78
 1e1:	e8 b3 03 00 00       	call   599 <sleep>
 1e6:	83 c4 10             	add    $0x10,%esp
    printf(1, "ticks after sleep is %d\n", getcputicks(pid));
 1e9:	83 ec 0c             	sub    $0xc,%esp
 1ec:	ff 75 f4             	push   -0xc(%ebp)
 1ef:	e8 7f fe ff ff       	call   73 <getcputicks>
 1f4:	83 c4 10             	add    $0x10,%esp
 1f7:	83 ec 04             	sub    $0x4,%esp
 1fa:	50                   	push   %eax
 1fb:	68 c8 0a 00 00       	push   $0xac8
 200:	6a 01                	push   $0x1
 202:	e8 86 04 00 00       	call   68d <printf>
 207:	83 c4 10             	add    $0x10,%esp
    printf(1, "priority after sleep is %d\n", getpriority(pid));
 20a:	83 ec 0c             	sub    $0xc,%esp
 20d:	ff 75 f4             	push   -0xc(%ebp)
 210:	e8 eb fd ff ff       	call   0 <getpriority>
 215:	83 c4 10             	add    $0x10,%esp
 218:	83 ec 04             	sub    $0x4,%esp
 21b:	50                   	push   %eax
 21c:	68 e1 0a 00 00       	push   $0xae1
 221:	6a 01                	push   $0x1
 223:	e8 65 04 00 00       	call   68d <printf>
 228:	83 c4 10             	add    $0x10,%esp
    printf(1, "uptime after sleep is %d\n", uptime());
 22b:	e8 71 03 00 00       	call   5a1 <uptime>
 230:	83 ec 04             	sub    $0x4,%esp
 233:	50                   	push   %eax
 234:	68 fd 0a 00 00       	push   $0xafd
 239:	6a 01                	push   $0x1
 23b:	e8 4d 04 00 00       	call   68d <printf>
 240:	83 c4 10             	add    $0x10,%esp



    int priority;
    if ((priority = getpriority(pid)) == 0) {
 243:	83 ec 0c             	sub    $0xc,%esp
 246:	ff 75 f4             	push   -0xc(%ebp)
 249:	e8 b2 fd ff ff       	call   0 <getpriority>
 24e:	83 c4 10             	add    $0x10,%esp
 251:	89 45 f0             	mov    %eax,-0x10(%ebp)
 254:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 258:	75 2c                	jne    286 <main+0x15d>
        printf(1, "priority was %d\n", priority);
 25a:	83 ec 04             	sub    $0x4,%esp
 25d:	ff 75 f0             	push   -0x10(%ebp)
 260:	68 17 0b 00 00       	push   $0xb17
 265:	6a 01                	push   $0x1
 267:	e8 21 04 00 00       	call   68d <printf>
 26c:	83 c4 10             	add    $0x10,%esp
        printf(1, "XV6_SCHEDULER\t FAILED\n");
 26f:	83 ec 08             	sub    $0x8,%esp
 272:	68 63 0a 00 00       	push   $0xa63
 277:	6a 01                	push   $0x1
 279:	e8 0f 04 00 00       	call   68d <printf>
 27e:	83 c4 10             	add    $0x10,%esp
        exit();
 281:	e8 83 02 00 00       	call   509 <exit>
    }

    printf(1, "priority of %d is %d", pid, priority);
 286:	ff 75 f0             	push   -0x10(%ebp)
 289:	ff 75 f4             	push   -0xc(%ebp)
 28c:	68 28 0b 00 00       	push   $0xb28
 291:	6a 01                	push   $0x1
 293:	e8 f5 03 00 00       	call   68d <printf>
 298:	83 c4 10             	add    $0x10,%esp
    printf(1, "XV6_SCHEDULER\t SUCCESS\n");
 29b:	83 ec 08             	sub    $0x8,%esp
 29e:	68 3d 0b 00 00       	push   $0xb3d
 2a3:	6a 01                	push   $0x1
 2a5:	e8 e3 03 00 00       	call   68d <printf>
 2aa:	83 c4 10             	add    $0x10,%esp
    exit();
 2ad:	e8 57 02 00 00       	call   509 <exit>

000002b2 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 2b2:	55                   	push   %ebp
 2b3:	89 e5                	mov    %esp,%ebp
 2b5:	57                   	push   %edi
 2b6:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 2b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2ba:	8b 55 10             	mov    0x10(%ebp),%edx
 2bd:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c0:	89 cb                	mov    %ecx,%ebx
 2c2:	89 df                	mov    %ebx,%edi
 2c4:	89 d1                	mov    %edx,%ecx
 2c6:	fc                   	cld    
 2c7:	f3 aa                	rep stos %al,%es:(%edi)
 2c9:	89 ca                	mov    %ecx,%edx
 2cb:	89 fb                	mov    %edi,%ebx
 2cd:	89 5d 08             	mov    %ebx,0x8(%ebp)
 2d0:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 2d3:	90                   	nop
 2d4:	5b                   	pop    %ebx
 2d5:	5f                   	pop    %edi
 2d6:	5d                   	pop    %ebp
 2d7:	c3                   	ret    

000002d8 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 2d8:	55                   	push   %ebp
 2d9:	89 e5                	mov    %esp,%ebp
 2db:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 2de:	8b 45 08             	mov    0x8(%ebp),%eax
 2e1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 2e4:	90                   	nop
 2e5:	8b 55 0c             	mov    0xc(%ebp),%edx
 2e8:	8d 42 01             	lea    0x1(%edx),%eax
 2eb:	89 45 0c             	mov    %eax,0xc(%ebp)
 2ee:	8b 45 08             	mov    0x8(%ebp),%eax
 2f1:	8d 48 01             	lea    0x1(%eax),%ecx
 2f4:	89 4d 08             	mov    %ecx,0x8(%ebp)
 2f7:	0f b6 12             	movzbl (%edx),%edx
 2fa:	88 10                	mov    %dl,(%eax)
 2fc:	0f b6 00             	movzbl (%eax),%eax
 2ff:	84 c0                	test   %al,%al
 301:	75 e2                	jne    2e5 <strcpy+0xd>
    ;
  return os;
 303:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 306:	c9                   	leave  
 307:	c3                   	ret    

00000308 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 308:	55                   	push   %ebp
 309:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 30b:	eb 08                	jmp    315 <strcmp+0xd>
    p++, q++;
 30d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 311:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 315:	8b 45 08             	mov    0x8(%ebp),%eax
 318:	0f b6 00             	movzbl (%eax),%eax
 31b:	84 c0                	test   %al,%al
 31d:	74 10                	je     32f <strcmp+0x27>
 31f:	8b 45 08             	mov    0x8(%ebp),%eax
 322:	0f b6 10             	movzbl (%eax),%edx
 325:	8b 45 0c             	mov    0xc(%ebp),%eax
 328:	0f b6 00             	movzbl (%eax),%eax
 32b:	38 c2                	cmp    %al,%dl
 32d:	74 de                	je     30d <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 32f:	8b 45 08             	mov    0x8(%ebp),%eax
 332:	0f b6 00             	movzbl (%eax),%eax
 335:	0f b6 d0             	movzbl %al,%edx
 338:	8b 45 0c             	mov    0xc(%ebp),%eax
 33b:	0f b6 00             	movzbl (%eax),%eax
 33e:	0f b6 c8             	movzbl %al,%ecx
 341:	89 d0                	mov    %edx,%eax
 343:	29 c8                	sub    %ecx,%eax
}
 345:	5d                   	pop    %ebp
 346:	c3                   	ret    

00000347 <strlen>:

uint
strlen(const char *s)
{
 347:	55                   	push   %ebp
 348:	89 e5                	mov    %esp,%ebp
 34a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 34d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 354:	eb 04                	jmp    35a <strlen+0x13>
 356:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 35a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 35d:	8b 45 08             	mov    0x8(%ebp),%eax
 360:	01 d0                	add    %edx,%eax
 362:	0f b6 00             	movzbl (%eax),%eax
 365:	84 c0                	test   %al,%al
 367:	75 ed                	jne    356 <strlen+0xf>
    ;
  return n;
 369:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 36c:	c9                   	leave  
 36d:	c3                   	ret    

0000036e <memset>:

void*
memset(void *dst, int c, uint n)
{
 36e:	55                   	push   %ebp
 36f:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 371:	8b 45 10             	mov    0x10(%ebp),%eax
 374:	50                   	push   %eax
 375:	ff 75 0c             	push   0xc(%ebp)
 378:	ff 75 08             	push   0x8(%ebp)
 37b:	e8 32 ff ff ff       	call   2b2 <stosb>
 380:	83 c4 0c             	add    $0xc,%esp
  return dst;
 383:	8b 45 08             	mov    0x8(%ebp),%eax
}
 386:	c9                   	leave  
 387:	c3                   	ret    

00000388 <strchr>:

char*
strchr(const char *s, char c)
{
 388:	55                   	push   %ebp
 389:	89 e5                	mov    %esp,%ebp
 38b:	83 ec 04             	sub    $0x4,%esp
 38e:	8b 45 0c             	mov    0xc(%ebp),%eax
 391:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 394:	eb 14                	jmp    3aa <strchr+0x22>
    if(*s == c)
 396:	8b 45 08             	mov    0x8(%ebp),%eax
 399:	0f b6 00             	movzbl (%eax),%eax
 39c:	38 45 fc             	cmp    %al,-0x4(%ebp)
 39f:	75 05                	jne    3a6 <strchr+0x1e>
      return (char*)s;
 3a1:	8b 45 08             	mov    0x8(%ebp),%eax
 3a4:	eb 13                	jmp    3b9 <strchr+0x31>
  for(; *s; s++)
 3a6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3aa:	8b 45 08             	mov    0x8(%ebp),%eax
 3ad:	0f b6 00             	movzbl (%eax),%eax
 3b0:	84 c0                	test   %al,%al
 3b2:	75 e2                	jne    396 <strchr+0xe>
  return 0;
 3b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3b9:	c9                   	leave  
 3ba:	c3                   	ret    

000003bb <gets>:

char*
gets(char *buf, int max)
{
 3bb:	55                   	push   %ebp
 3bc:	89 e5                	mov    %esp,%ebp
 3be:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3c8:	eb 42                	jmp    40c <gets+0x51>
    cc = read(0, &c, 1);
 3ca:	83 ec 04             	sub    $0x4,%esp
 3cd:	6a 01                	push   $0x1
 3cf:	8d 45 ef             	lea    -0x11(%ebp),%eax
 3d2:	50                   	push   %eax
 3d3:	6a 00                	push   $0x0
 3d5:	e8 47 01 00 00       	call   521 <read>
 3da:	83 c4 10             	add    $0x10,%esp
 3dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 3e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3e4:	7e 33                	jle    419 <gets+0x5e>
      break;
    buf[i++] = c;
 3e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3e9:	8d 50 01             	lea    0x1(%eax),%edx
 3ec:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3ef:	89 c2                	mov    %eax,%edx
 3f1:	8b 45 08             	mov    0x8(%ebp),%eax
 3f4:	01 c2                	add    %eax,%edx
 3f6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3fa:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 3fc:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 400:	3c 0a                	cmp    $0xa,%al
 402:	74 16                	je     41a <gets+0x5f>
 404:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 408:	3c 0d                	cmp    $0xd,%al
 40a:	74 0e                	je     41a <gets+0x5f>
  for(i=0; i+1 < max; ){
 40c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 40f:	83 c0 01             	add    $0x1,%eax
 412:	39 45 0c             	cmp    %eax,0xc(%ebp)
 415:	7f b3                	jg     3ca <gets+0xf>
 417:	eb 01                	jmp    41a <gets+0x5f>
      break;
 419:	90                   	nop
      break;
  }
  buf[i] = '\0';
 41a:	8b 55 f4             	mov    -0xc(%ebp),%edx
 41d:	8b 45 08             	mov    0x8(%ebp),%eax
 420:	01 d0                	add    %edx,%eax
 422:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 425:	8b 45 08             	mov    0x8(%ebp),%eax
}
 428:	c9                   	leave  
 429:	c3                   	ret    

0000042a <stat>:

int
stat(const char *n, struct stat *st)
{
 42a:	55                   	push   %ebp
 42b:	89 e5                	mov    %esp,%ebp
 42d:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 430:	83 ec 08             	sub    $0x8,%esp
 433:	6a 00                	push   $0x0
 435:	ff 75 08             	push   0x8(%ebp)
 438:	e8 0c 01 00 00       	call   549 <open>
 43d:	83 c4 10             	add    $0x10,%esp
 440:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 443:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 447:	79 07                	jns    450 <stat+0x26>
    return -1;
 449:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 44e:	eb 25                	jmp    475 <stat+0x4b>
  r = fstat(fd, st);
 450:	83 ec 08             	sub    $0x8,%esp
 453:	ff 75 0c             	push   0xc(%ebp)
 456:	ff 75 f4             	push   -0xc(%ebp)
 459:	e8 03 01 00 00       	call   561 <fstat>
 45e:	83 c4 10             	add    $0x10,%esp
 461:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 464:	83 ec 0c             	sub    $0xc,%esp
 467:	ff 75 f4             	push   -0xc(%ebp)
 46a:	e8 c2 00 00 00       	call   531 <close>
 46f:	83 c4 10             	add    $0x10,%esp
  return r;
 472:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 475:	c9                   	leave  
 476:	c3                   	ret    

00000477 <atoi>:

int
atoi(const char *s)
{
 477:	55                   	push   %ebp
 478:	89 e5                	mov    %esp,%ebp
 47a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 47d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 484:	eb 25                	jmp    4ab <atoi+0x34>
    n = n*10 + *s++ - '0';
 486:	8b 55 fc             	mov    -0x4(%ebp),%edx
 489:	89 d0                	mov    %edx,%eax
 48b:	c1 e0 02             	shl    $0x2,%eax
 48e:	01 d0                	add    %edx,%eax
 490:	01 c0                	add    %eax,%eax
 492:	89 c1                	mov    %eax,%ecx
 494:	8b 45 08             	mov    0x8(%ebp),%eax
 497:	8d 50 01             	lea    0x1(%eax),%edx
 49a:	89 55 08             	mov    %edx,0x8(%ebp)
 49d:	0f b6 00             	movzbl (%eax),%eax
 4a0:	0f be c0             	movsbl %al,%eax
 4a3:	01 c8                	add    %ecx,%eax
 4a5:	83 e8 30             	sub    $0x30,%eax
 4a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4ab:	8b 45 08             	mov    0x8(%ebp),%eax
 4ae:	0f b6 00             	movzbl (%eax),%eax
 4b1:	3c 2f                	cmp    $0x2f,%al
 4b3:	7e 0a                	jle    4bf <atoi+0x48>
 4b5:	8b 45 08             	mov    0x8(%ebp),%eax
 4b8:	0f b6 00             	movzbl (%eax),%eax
 4bb:	3c 39                	cmp    $0x39,%al
 4bd:	7e c7                	jle    486 <atoi+0xf>
  return n;
 4bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4c2:	c9                   	leave  
 4c3:	c3                   	ret    

000004c4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4c4:	55                   	push   %ebp
 4c5:	89 e5                	mov    %esp,%ebp
 4c7:	83 ec 10             	sub    $0x10,%esp
  char *dst;
  const char *src;

  dst = vdst;
 4ca:	8b 45 08             	mov    0x8(%ebp),%eax
 4cd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 4d0:	8b 45 0c             	mov    0xc(%ebp),%eax
 4d3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 4d6:	eb 17                	jmp    4ef <memmove+0x2b>
    *dst++ = *src++;
 4d8:	8b 55 f8             	mov    -0x8(%ebp),%edx
 4db:	8d 42 01             	lea    0x1(%edx),%eax
 4de:	89 45 f8             	mov    %eax,-0x8(%ebp)
 4e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4e4:	8d 48 01             	lea    0x1(%eax),%ecx
 4e7:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 4ea:	0f b6 12             	movzbl (%edx),%edx
 4ed:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 4ef:	8b 45 10             	mov    0x10(%ebp),%eax
 4f2:	8d 50 ff             	lea    -0x1(%eax),%edx
 4f5:	89 55 10             	mov    %edx,0x10(%ebp)
 4f8:	85 c0                	test   %eax,%eax
 4fa:	7f dc                	jg     4d8 <memmove+0x14>
  return vdst;
 4fc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4ff:	c9                   	leave  
 500:	c3                   	ret    

00000501 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 501:	b8 01 00 00 00       	mov    $0x1,%eax
 506:	cd 40                	int    $0x40
 508:	c3                   	ret    

00000509 <exit>:
SYSCALL(exit)
 509:	b8 02 00 00 00       	mov    $0x2,%eax
 50e:	cd 40                	int    $0x40
 510:	c3                   	ret    

00000511 <wait>:
SYSCALL(wait)
 511:	b8 03 00 00 00       	mov    $0x3,%eax
 516:	cd 40                	int    $0x40
 518:	c3                   	ret    

00000519 <pipe>:
SYSCALL(pipe)
 519:	b8 04 00 00 00       	mov    $0x4,%eax
 51e:	cd 40                	int    $0x40
 520:	c3                   	ret    

00000521 <read>:
SYSCALL(read)
 521:	b8 05 00 00 00       	mov    $0x5,%eax
 526:	cd 40                	int    $0x40
 528:	c3                   	ret    

00000529 <write>:
SYSCALL(write)
 529:	b8 10 00 00 00       	mov    $0x10,%eax
 52e:	cd 40                	int    $0x40
 530:	c3                   	ret    

00000531 <close>:
SYSCALL(close)
 531:	b8 15 00 00 00       	mov    $0x15,%eax
 536:	cd 40                	int    $0x40
 538:	c3                   	ret    

00000539 <kill>:
SYSCALL(kill)
 539:	b8 06 00 00 00       	mov    $0x6,%eax
 53e:	cd 40                	int    $0x40
 540:	c3                   	ret    

00000541 <exec>:
SYSCALL(exec)
 541:	b8 07 00 00 00       	mov    $0x7,%eax
 546:	cd 40                	int    $0x40
 548:	c3                   	ret    

00000549 <open>:
SYSCALL(open)
 549:	b8 0f 00 00 00       	mov    $0xf,%eax
 54e:	cd 40                	int    $0x40
 550:	c3                   	ret    

00000551 <mknod>:
SYSCALL(mknod)
 551:	b8 11 00 00 00       	mov    $0x11,%eax
 556:	cd 40                	int    $0x40
 558:	c3                   	ret    

00000559 <unlink>:
SYSCALL(unlink)
 559:	b8 12 00 00 00       	mov    $0x12,%eax
 55e:	cd 40                	int    $0x40
 560:	c3                   	ret    

00000561 <fstat>:
SYSCALL(fstat)
 561:	b8 08 00 00 00       	mov    $0x8,%eax
 566:	cd 40                	int    $0x40
 568:	c3                   	ret    

00000569 <link>:
SYSCALL(link)
 569:	b8 13 00 00 00       	mov    $0x13,%eax
 56e:	cd 40                	int    $0x40
 570:	c3                   	ret    

00000571 <mkdir>:
SYSCALL(mkdir)
 571:	b8 14 00 00 00       	mov    $0x14,%eax
 576:	cd 40                	int    $0x40
 578:	c3                   	ret    

00000579 <chdir>:
SYSCALL(chdir)
 579:	b8 09 00 00 00       	mov    $0x9,%eax
 57e:	cd 40                	int    $0x40
 580:	c3                   	ret    

00000581 <dup>:
SYSCALL(dup)
 581:	b8 0a 00 00 00       	mov    $0xa,%eax
 586:	cd 40                	int    $0x40
 588:	c3                   	ret    

00000589 <getpid>:
SYSCALL(getpid)
 589:	b8 0b 00 00 00       	mov    $0xb,%eax
 58e:	cd 40                	int    $0x40
 590:	c3                   	ret    

00000591 <sbrk>:
SYSCALL(sbrk)
 591:	b8 0c 00 00 00       	mov    $0xc,%eax
 596:	cd 40                	int    $0x40
 598:	c3                   	ret    

00000599 <sleep>:
SYSCALL(sleep)
 599:	b8 0d 00 00 00       	mov    $0xd,%eax
 59e:	cd 40                	int    $0x40
 5a0:	c3                   	ret    

000005a1 <uptime>:
SYSCALL(uptime)
 5a1:	b8 0e 00 00 00       	mov    $0xe,%eax
 5a6:	cd 40                	int    $0x40
 5a8:	c3                   	ret    

000005a9 <nice>:
SYSCALL(nice)
 5a9:	b8 16 00 00 00       	mov    $0x16,%eax
 5ae:	cd 40                	int    $0x40
 5b0:	c3                   	ret    

000005b1 <getschedstate>:
 5b1:	b8 17 00 00 00       	mov    $0x17,%eax
 5b6:	cd 40                	int    $0x40
 5b8:	c3                   	ret    

000005b9 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5b9:	55                   	push   %ebp
 5ba:	89 e5                	mov    %esp,%ebp
 5bc:	83 ec 18             	sub    $0x18,%esp
 5bf:	8b 45 0c             	mov    0xc(%ebp),%eax
 5c2:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5c5:	83 ec 04             	sub    $0x4,%esp
 5c8:	6a 01                	push   $0x1
 5ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5cd:	50                   	push   %eax
 5ce:	ff 75 08             	push   0x8(%ebp)
 5d1:	e8 53 ff ff ff       	call   529 <write>
 5d6:	83 c4 10             	add    $0x10,%esp
}
 5d9:	90                   	nop
 5da:	c9                   	leave  
 5db:	c3                   	ret    

000005dc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5dc:	55                   	push   %ebp
 5dd:	89 e5                	mov    %esp,%ebp
 5df:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5e2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5e9:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5ed:	74 17                	je     606 <printint+0x2a>
 5ef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5f3:	79 11                	jns    606 <printint+0x2a>
    neg = 1;
 5f5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5fc:	8b 45 0c             	mov    0xc(%ebp),%eax
 5ff:	f7 d8                	neg    %eax
 601:	89 45 ec             	mov    %eax,-0x14(%ebp)
 604:	eb 06                	jmp    60c <printint+0x30>
  } else {
    x = xx;
 606:	8b 45 0c             	mov    0xc(%ebp),%eax
 609:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 60c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 613:	8b 4d 10             	mov    0x10(%ebp),%ecx
 616:	8b 45 ec             	mov    -0x14(%ebp),%eax
 619:	ba 00 00 00 00       	mov    $0x0,%edx
 61e:	f7 f1                	div    %ecx
 620:	89 d1                	mov    %edx,%ecx
 622:	8b 45 f4             	mov    -0xc(%ebp),%eax
 625:	8d 50 01             	lea    0x1(%eax),%edx
 628:	89 55 f4             	mov    %edx,-0xc(%ebp)
 62b:	0f b6 91 00 0e 00 00 	movzbl 0xe00(%ecx),%edx
 632:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 636:	8b 4d 10             	mov    0x10(%ebp),%ecx
 639:	8b 45 ec             	mov    -0x14(%ebp),%eax
 63c:	ba 00 00 00 00       	mov    $0x0,%edx
 641:	f7 f1                	div    %ecx
 643:	89 45 ec             	mov    %eax,-0x14(%ebp)
 646:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 64a:	75 c7                	jne    613 <printint+0x37>
  if(neg)
 64c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 650:	74 2d                	je     67f <printint+0xa3>
    buf[i++] = '-';
 652:	8b 45 f4             	mov    -0xc(%ebp),%eax
 655:	8d 50 01             	lea    0x1(%eax),%edx
 658:	89 55 f4             	mov    %edx,-0xc(%ebp)
 65b:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 660:	eb 1d                	jmp    67f <printint+0xa3>
    putc(fd, buf[i]);
 662:	8d 55 dc             	lea    -0x24(%ebp),%edx
 665:	8b 45 f4             	mov    -0xc(%ebp),%eax
 668:	01 d0                	add    %edx,%eax
 66a:	0f b6 00             	movzbl (%eax),%eax
 66d:	0f be c0             	movsbl %al,%eax
 670:	83 ec 08             	sub    $0x8,%esp
 673:	50                   	push   %eax
 674:	ff 75 08             	push   0x8(%ebp)
 677:	e8 3d ff ff ff       	call   5b9 <putc>
 67c:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 67f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 683:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 687:	79 d9                	jns    662 <printint+0x86>
}
 689:	90                   	nop
 68a:	90                   	nop
 68b:	c9                   	leave  
 68c:	c3                   	ret    

0000068d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 68d:	55                   	push   %ebp
 68e:	89 e5                	mov    %esp,%ebp
 690:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 693:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 69a:	8d 45 0c             	lea    0xc(%ebp),%eax
 69d:	83 c0 04             	add    $0x4,%eax
 6a0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6a3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6aa:	e9 59 01 00 00       	jmp    808 <printf+0x17b>
    c = fmt[i] & 0xff;
 6af:	8b 55 0c             	mov    0xc(%ebp),%edx
 6b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6b5:	01 d0                	add    %edx,%eax
 6b7:	0f b6 00             	movzbl (%eax),%eax
 6ba:	0f be c0             	movsbl %al,%eax
 6bd:	25 ff 00 00 00       	and    $0xff,%eax
 6c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6c5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6c9:	75 2c                	jne    6f7 <printf+0x6a>
      if(c == '%'){
 6cb:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6cf:	75 0c                	jne    6dd <printf+0x50>
        state = '%';
 6d1:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6d8:	e9 27 01 00 00       	jmp    804 <printf+0x177>
      } else {
        putc(fd, c);
 6dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6e0:	0f be c0             	movsbl %al,%eax
 6e3:	83 ec 08             	sub    $0x8,%esp
 6e6:	50                   	push   %eax
 6e7:	ff 75 08             	push   0x8(%ebp)
 6ea:	e8 ca fe ff ff       	call   5b9 <putc>
 6ef:	83 c4 10             	add    $0x10,%esp
 6f2:	e9 0d 01 00 00       	jmp    804 <printf+0x177>
      }
    } else if(state == '%'){
 6f7:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6fb:	0f 85 03 01 00 00    	jne    804 <printf+0x177>
      if(c == 'd'){
 701:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 705:	75 1e                	jne    725 <printf+0x98>
        printint(fd, *ap, 10, 1);
 707:	8b 45 e8             	mov    -0x18(%ebp),%eax
 70a:	8b 00                	mov    (%eax),%eax
 70c:	6a 01                	push   $0x1
 70e:	6a 0a                	push   $0xa
 710:	50                   	push   %eax
 711:	ff 75 08             	push   0x8(%ebp)
 714:	e8 c3 fe ff ff       	call   5dc <printint>
 719:	83 c4 10             	add    $0x10,%esp
        ap++;
 71c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 720:	e9 d8 00 00 00       	jmp    7fd <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 725:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 729:	74 06                	je     731 <printf+0xa4>
 72b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 72f:	75 1e                	jne    74f <printf+0xc2>
        printint(fd, *ap, 16, 0);
 731:	8b 45 e8             	mov    -0x18(%ebp),%eax
 734:	8b 00                	mov    (%eax),%eax
 736:	6a 00                	push   $0x0
 738:	6a 10                	push   $0x10
 73a:	50                   	push   %eax
 73b:	ff 75 08             	push   0x8(%ebp)
 73e:	e8 99 fe ff ff       	call   5dc <printint>
 743:	83 c4 10             	add    $0x10,%esp
        ap++;
 746:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 74a:	e9 ae 00 00 00       	jmp    7fd <printf+0x170>
      } else if(c == 's'){
 74f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 753:	75 43                	jne    798 <printf+0x10b>
        s = (char*)*ap;
 755:	8b 45 e8             	mov    -0x18(%ebp),%eax
 758:	8b 00                	mov    (%eax),%eax
 75a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 75d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 761:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 765:	75 25                	jne    78c <printf+0xff>
          s = "(null)";
 767:	c7 45 f4 55 0b 00 00 	movl   $0xb55,-0xc(%ebp)
        while(*s != 0){
 76e:	eb 1c                	jmp    78c <printf+0xff>
          putc(fd, *s);
 770:	8b 45 f4             	mov    -0xc(%ebp),%eax
 773:	0f b6 00             	movzbl (%eax),%eax
 776:	0f be c0             	movsbl %al,%eax
 779:	83 ec 08             	sub    $0x8,%esp
 77c:	50                   	push   %eax
 77d:	ff 75 08             	push   0x8(%ebp)
 780:	e8 34 fe ff ff       	call   5b9 <putc>
 785:	83 c4 10             	add    $0x10,%esp
          s++;
 788:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 78c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78f:	0f b6 00             	movzbl (%eax),%eax
 792:	84 c0                	test   %al,%al
 794:	75 da                	jne    770 <printf+0xe3>
 796:	eb 65                	jmp    7fd <printf+0x170>
        }
      } else if(c == 'c'){
 798:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 79c:	75 1d                	jne    7bb <printf+0x12e>
        putc(fd, *ap);
 79e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7a1:	8b 00                	mov    (%eax),%eax
 7a3:	0f be c0             	movsbl %al,%eax
 7a6:	83 ec 08             	sub    $0x8,%esp
 7a9:	50                   	push   %eax
 7aa:	ff 75 08             	push   0x8(%ebp)
 7ad:	e8 07 fe ff ff       	call   5b9 <putc>
 7b2:	83 c4 10             	add    $0x10,%esp
        ap++;
 7b5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7b9:	eb 42                	jmp    7fd <printf+0x170>
      } else if(c == '%'){
 7bb:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7bf:	75 17                	jne    7d8 <printf+0x14b>
        putc(fd, c);
 7c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7c4:	0f be c0             	movsbl %al,%eax
 7c7:	83 ec 08             	sub    $0x8,%esp
 7ca:	50                   	push   %eax
 7cb:	ff 75 08             	push   0x8(%ebp)
 7ce:	e8 e6 fd ff ff       	call   5b9 <putc>
 7d3:	83 c4 10             	add    $0x10,%esp
 7d6:	eb 25                	jmp    7fd <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7d8:	83 ec 08             	sub    $0x8,%esp
 7db:	6a 25                	push   $0x25
 7dd:	ff 75 08             	push   0x8(%ebp)
 7e0:	e8 d4 fd ff ff       	call   5b9 <putc>
 7e5:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 7e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7eb:	0f be c0             	movsbl %al,%eax
 7ee:	83 ec 08             	sub    $0x8,%esp
 7f1:	50                   	push   %eax
 7f2:	ff 75 08             	push   0x8(%ebp)
 7f5:	e8 bf fd ff ff       	call   5b9 <putc>
 7fa:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 7fd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 804:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 808:	8b 55 0c             	mov    0xc(%ebp),%edx
 80b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 80e:	01 d0                	add    %edx,%eax
 810:	0f b6 00             	movzbl (%eax),%eax
 813:	84 c0                	test   %al,%al
 815:	0f 85 94 fe ff ff    	jne    6af <printf+0x22>
    }
  }
}
 81b:	90                   	nop
 81c:	90                   	nop
 81d:	c9                   	leave  
 81e:	c3                   	ret    

0000081f <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 81f:	55                   	push   %ebp
 820:	89 e5                	mov    %esp,%ebp
 822:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 825:	8b 45 08             	mov    0x8(%ebp),%eax
 828:	83 e8 08             	sub    $0x8,%eax
 82b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 82e:	a1 1c 0e 00 00       	mov    0xe1c,%eax
 833:	89 45 fc             	mov    %eax,-0x4(%ebp)
 836:	eb 24                	jmp    85c <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 838:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83b:	8b 00                	mov    (%eax),%eax
 83d:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 840:	72 12                	jb     854 <free+0x35>
 842:	8b 45 f8             	mov    -0x8(%ebp),%eax
 845:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 848:	77 24                	ja     86e <free+0x4f>
 84a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84d:	8b 00                	mov    (%eax),%eax
 84f:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 852:	72 1a                	jb     86e <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 854:	8b 45 fc             	mov    -0x4(%ebp),%eax
 857:	8b 00                	mov    (%eax),%eax
 859:	89 45 fc             	mov    %eax,-0x4(%ebp)
 85c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 85f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 862:	76 d4                	jbe    838 <free+0x19>
 864:	8b 45 fc             	mov    -0x4(%ebp),%eax
 867:	8b 00                	mov    (%eax),%eax
 869:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 86c:	73 ca                	jae    838 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 86e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 871:	8b 40 04             	mov    0x4(%eax),%eax
 874:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 87b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87e:	01 c2                	add    %eax,%edx
 880:	8b 45 fc             	mov    -0x4(%ebp),%eax
 883:	8b 00                	mov    (%eax),%eax
 885:	39 c2                	cmp    %eax,%edx
 887:	75 24                	jne    8ad <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 889:	8b 45 f8             	mov    -0x8(%ebp),%eax
 88c:	8b 50 04             	mov    0x4(%eax),%edx
 88f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 892:	8b 00                	mov    (%eax),%eax
 894:	8b 40 04             	mov    0x4(%eax),%eax
 897:	01 c2                	add    %eax,%edx
 899:	8b 45 f8             	mov    -0x8(%ebp),%eax
 89c:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 89f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a2:	8b 00                	mov    (%eax),%eax
 8a4:	8b 10                	mov    (%eax),%edx
 8a6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a9:	89 10                	mov    %edx,(%eax)
 8ab:	eb 0a                	jmp    8b7 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 8ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b0:	8b 10                	mov    (%eax),%edx
 8b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b5:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ba:	8b 40 04             	mov    0x4(%eax),%eax
 8bd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c7:	01 d0                	add    %edx,%eax
 8c9:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8cc:	75 20                	jne    8ee <free+0xcf>
    p->s.size += bp->s.size;
 8ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d1:	8b 50 04             	mov    0x4(%eax),%edx
 8d4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d7:	8b 40 04             	mov    0x4(%eax),%eax
 8da:	01 c2                	add    %eax,%edx
 8dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8df:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e5:	8b 10                	mov    (%eax),%edx
 8e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ea:	89 10                	mov    %edx,(%eax)
 8ec:	eb 08                	jmp    8f6 <free+0xd7>
  } else
    p->s.ptr = bp;
 8ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f1:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8f4:	89 10                	mov    %edx,(%eax)
  freep = p;
 8f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f9:	a3 1c 0e 00 00       	mov    %eax,0xe1c
}
 8fe:	90                   	nop
 8ff:	c9                   	leave  
 900:	c3                   	ret    

00000901 <morecore>:

static Header*
morecore(uint nu)
{
 901:	55                   	push   %ebp
 902:	89 e5                	mov    %esp,%ebp
 904:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 907:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 90e:	77 07                	ja     917 <morecore+0x16>
    nu = 4096;
 910:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 917:	8b 45 08             	mov    0x8(%ebp),%eax
 91a:	c1 e0 03             	shl    $0x3,%eax
 91d:	83 ec 0c             	sub    $0xc,%esp
 920:	50                   	push   %eax
 921:	e8 6b fc ff ff       	call   591 <sbrk>
 926:	83 c4 10             	add    $0x10,%esp
 929:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 92c:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 930:	75 07                	jne    939 <morecore+0x38>
    return 0;
 932:	b8 00 00 00 00       	mov    $0x0,%eax
 937:	eb 26                	jmp    95f <morecore+0x5e>
  hp = (Header*)p;
 939:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 93f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 942:	8b 55 08             	mov    0x8(%ebp),%edx
 945:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 948:	8b 45 f0             	mov    -0x10(%ebp),%eax
 94b:	83 c0 08             	add    $0x8,%eax
 94e:	83 ec 0c             	sub    $0xc,%esp
 951:	50                   	push   %eax
 952:	e8 c8 fe ff ff       	call   81f <free>
 957:	83 c4 10             	add    $0x10,%esp
  return freep;
 95a:	a1 1c 0e 00 00       	mov    0xe1c,%eax
}
 95f:	c9                   	leave  
 960:	c3                   	ret    

00000961 <malloc>:

void*
malloc(uint nbytes)
{
 961:	55                   	push   %ebp
 962:	89 e5                	mov    %esp,%ebp
 964:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 967:	8b 45 08             	mov    0x8(%ebp),%eax
 96a:	83 c0 07             	add    $0x7,%eax
 96d:	c1 e8 03             	shr    $0x3,%eax
 970:	83 c0 01             	add    $0x1,%eax
 973:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 976:	a1 1c 0e 00 00       	mov    0xe1c,%eax
 97b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 97e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 982:	75 23                	jne    9a7 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 984:	c7 45 f0 14 0e 00 00 	movl   $0xe14,-0x10(%ebp)
 98b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 98e:	a3 1c 0e 00 00       	mov    %eax,0xe1c
 993:	a1 1c 0e 00 00       	mov    0xe1c,%eax
 998:	a3 14 0e 00 00       	mov    %eax,0xe14
    base.s.size = 0;
 99d:	c7 05 18 0e 00 00 00 	movl   $0x0,0xe18
 9a4:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9aa:	8b 00                	mov    (%eax),%eax
 9ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b2:	8b 40 04             	mov    0x4(%eax),%eax
 9b5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9b8:	77 4d                	ja     a07 <malloc+0xa6>
      if(p->s.size == nunits)
 9ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9bd:	8b 40 04             	mov    0x4(%eax),%eax
 9c0:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9c3:	75 0c                	jne    9d1 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c8:	8b 10                	mov    (%eax),%edx
 9ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9cd:	89 10                	mov    %edx,(%eax)
 9cf:	eb 26                	jmp    9f7 <malloc+0x96>
      else {
        p->s.size -= nunits;
 9d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d4:	8b 40 04             	mov    0x4(%eax),%eax
 9d7:	2b 45 ec             	sub    -0x14(%ebp),%eax
 9da:	89 c2                	mov    %eax,%edx
 9dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9df:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e5:	8b 40 04             	mov    0x4(%eax),%eax
 9e8:	c1 e0 03             	shl    $0x3,%eax
 9eb:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f1:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9f4:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9fa:	a3 1c 0e 00 00       	mov    %eax,0xe1c
      return (void*)(p + 1);
 9ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a02:	83 c0 08             	add    $0x8,%eax
 a05:	eb 3b                	jmp    a42 <malloc+0xe1>
    }
    if(p == freep)
 a07:	a1 1c 0e 00 00       	mov    0xe1c,%eax
 a0c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a0f:	75 1e                	jne    a2f <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 a11:	83 ec 0c             	sub    $0xc,%esp
 a14:	ff 75 ec             	push   -0x14(%ebp)
 a17:	e8 e5 fe ff ff       	call   901 <morecore>
 a1c:	83 c4 10             	add    $0x10,%esp
 a1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a22:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a26:	75 07                	jne    a2f <malloc+0xce>
        return 0;
 a28:	b8 00 00 00 00       	mov    $0x0,%eax
 a2d:	eb 13                	jmp    a42 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a32:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a38:	8b 00                	mov    (%eax),%eax
 a3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a3d:	e9 6d ff ff ff       	jmp    9af <malloc+0x4e>
  }
}
 a42:	c9                   	leave  
 a43:	c3                   	ret    
