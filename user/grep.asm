
user/_grep:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <matchstar>:
  return 0;
}

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  10:	892a                	mv	s2,a0
  12:	89ae                	mv	s3,a1
  14:	84b2                	mv	s1,a2
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
      return 1;
  }while(*text!='\0' && (*text++==c || c=='.'));
  16:	02e00a13          	li	s4,46
    if(matchhere(re, text))
  1a:	85a6                	mv	a1,s1
  1c:	854e                	mv	a0,s3
  1e:	00000097          	auipc	ra,0x0
  22:	030080e7          	jalr	48(ra) # 4e <matchhere>
  26:	e919                	bnez	a0,3c <matchstar+0x3c>
  }while(*text!='\0' && (*text++==c || c=='.'));
  28:	0004c783          	lbu	a5,0(s1)
  2c:	cb89                	beqz	a5,3e <matchstar+0x3e>
  2e:	0485                	addi	s1,s1,1
  30:	2781                	sext.w	a5,a5
  32:	ff2784e3          	beq	a5,s2,1a <matchstar+0x1a>
  36:	ff4902e3          	beq	s2,s4,1a <matchstar+0x1a>
  3a:	a011                	j	3e <matchstar+0x3e>
      return 1;
  3c:	4505                	li	a0,1
  return 0;
}
  3e:	70a2                	ld	ra,40(sp)
  40:	7402                	ld	s0,32(sp)
  42:	64e2                	ld	s1,24(sp)
  44:	6942                	ld	s2,16(sp)
  46:	69a2                	ld	s3,8(sp)
  48:	6a02                	ld	s4,0(sp)
  4a:	6145                	addi	sp,sp,48
  4c:	8082                	ret

000000000000004e <matchhere>:
  if(re[0] == '\0')
  4e:	00054703          	lbu	a4,0(a0)
  52:	cb3d                	beqz	a4,c8 <matchhere+0x7a>
{
  54:	1141                	addi	sp,sp,-16
  56:	e406                	sd	ra,8(sp)
  58:	e022                	sd	s0,0(sp)
  5a:	0800                	addi	s0,sp,16
  5c:	87aa                	mv	a5,a0
  if(re[1] == '*')
  5e:	00154683          	lbu	a3,1(a0)
  62:	02a00613          	li	a2,42
  66:	02c68563          	beq	a3,a2,90 <matchhere+0x42>
  if(re[0] == '$' && re[1] == '\0')
  6a:	02400613          	li	a2,36
  6e:	02c70a63          	beq	a4,a2,a2 <matchhere+0x54>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  72:	0005c683          	lbu	a3,0(a1)
  return 0;
  76:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  78:	ca81                	beqz	a3,88 <matchhere+0x3a>
  7a:	02e00613          	li	a2,46
  7e:	02c70d63          	beq	a4,a2,b8 <matchhere+0x6a>
  return 0;
  82:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  84:	02d70a63          	beq	a4,a3,b8 <matchhere+0x6a>
}
  88:	60a2                	ld	ra,8(sp)
  8a:	6402                	ld	s0,0(sp)
  8c:	0141                	addi	sp,sp,16
  8e:	8082                	ret
    return matchstar(re[0], re+2, text);
  90:	862e                	mv	a2,a1
  92:	00250593          	addi	a1,a0,2
  96:	853a                	mv	a0,a4
  98:	00000097          	auipc	ra,0x0
  9c:	f68080e7          	jalr	-152(ra) # 0 <matchstar>
  a0:	b7e5                	j	88 <matchhere+0x3a>
  if(re[0] == '$' && re[1] == '\0')
  a2:	c691                	beqz	a3,ae <matchhere+0x60>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  a4:	0005c683          	lbu	a3,0(a1)
  a8:	fee9                	bnez	a3,82 <matchhere+0x34>
  return 0;
  aa:	4501                	li	a0,0
  ac:	bff1                	j	88 <matchhere+0x3a>
    return *text == '\0';
  ae:	0005c503          	lbu	a0,0(a1)
  b2:	00153513          	seqz	a0,a0
  b6:	bfc9                	j	88 <matchhere+0x3a>
    return matchhere(re+1, text+1);
  b8:	0585                	addi	a1,a1,1
  ba:	00178513          	addi	a0,a5,1
  be:	00000097          	auipc	ra,0x0
  c2:	f90080e7          	jalr	-112(ra) # 4e <matchhere>
  c6:	b7c9                	j	88 <matchhere+0x3a>
    return 1;
  c8:	4505                	li	a0,1
}
  ca:	8082                	ret

00000000000000cc <match>:
{
  cc:	1101                	addi	sp,sp,-32
  ce:	ec06                	sd	ra,24(sp)
  d0:	e822                	sd	s0,16(sp)
  d2:	e426                	sd	s1,8(sp)
  d4:	e04a                	sd	s2,0(sp)
  d6:	1000                	addi	s0,sp,32
  d8:	892a                	mv	s2,a0
  da:	84ae                	mv	s1,a1
  if(re[0] == '^')
  dc:	00054703          	lbu	a4,0(a0)
  e0:	05e00793          	li	a5,94
  e4:	00f70e63          	beq	a4,a5,100 <match+0x34>
    if(matchhere(re, text))
  e8:	85a6                	mv	a1,s1
  ea:	854a                	mv	a0,s2
  ec:	00000097          	auipc	ra,0x0
  f0:	f62080e7          	jalr	-158(ra) # 4e <matchhere>
  f4:	ed01                	bnez	a0,10c <match+0x40>
  }while(*text++ != '\0');
  f6:	0485                	addi	s1,s1,1
  f8:	fff4c783          	lbu	a5,-1(s1)
  fc:	f7f5                	bnez	a5,e8 <match+0x1c>
  fe:	a801                	j	10e <match+0x42>
    return matchhere(re+1, text);
 100:	0505                	addi	a0,a0,1
 102:	00000097          	auipc	ra,0x0
 106:	f4c080e7          	jalr	-180(ra) # 4e <matchhere>
 10a:	a011                	j	10e <match+0x42>
      return 1;
 10c:	4505                	li	a0,1
}
 10e:	60e2                	ld	ra,24(sp)
 110:	6442                	ld	s0,16(sp)
 112:	64a2                	ld	s1,8(sp)
 114:	6902                	ld	s2,0(sp)
 116:	6105                	addi	sp,sp,32
 118:	8082                	ret

000000000000011a <grep>:
{
 11a:	715d                	addi	sp,sp,-80
 11c:	e486                	sd	ra,72(sp)
 11e:	e0a2                	sd	s0,64(sp)
 120:	fc26                	sd	s1,56(sp)
 122:	f84a                	sd	s2,48(sp)
 124:	f44e                	sd	s3,40(sp)
 126:	f052                	sd	s4,32(sp)
 128:	ec56                	sd	s5,24(sp)
 12a:	e85a                	sd	s6,16(sp)
 12c:	e45e                	sd	s7,8(sp)
 12e:	0880                	addi	s0,sp,80
 130:	89aa                	mv	s3,a0
 132:	8b2e                	mv	s6,a1
  m = 0;
 134:	4a01                	li	s4,0
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 136:	3ff00b93          	li	s7,1023
 13a:	00001a97          	auipc	s5,0x1
 13e:	9eea8a93          	addi	s5,s5,-1554 # b28 <buf>
 142:	a0a1                	j	18a <grep+0x70>
      p = q+1;
 144:	00148913          	addi	s2,s1,1
    while((q = strchr(p, '\n')) != 0){
 148:	45a9                	li	a1,10
 14a:	854a                	mv	a0,s2
 14c:	00000097          	auipc	ra,0x0
 150:	1e6080e7          	jalr	486(ra) # 332 <strchr>
 154:	84aa                	mv	s1,a0
 156:	c905                	beqz	a0,186 <grep+0x6c>
      *q = 0;
 158:	00048023          	sb	zero,0(s1)
      if(match(pattern, p)){
 15c:	85ca                	mv	a1,s2
 15e:	854e                	mv	a0,s3
 160:	00000097          	auipc	ra,0x0
 164:	f6c080e7          	jalr	-148(ra) # cc <match>
 168:	dd71                	beqz	a0,144 <grep+0x2a>
        *q = '\n';
 16a:	47a9                	li	a5,10
 16c:	00f48023          	sb	a5,0(s1)
        write(1, p, q+1 - p);
 170:	00148613          	addi	a2,s1,1
 174:	4126063b          	subw	a2,a2,s2
 178:	85ca                	mv	a1,s2
 17a:	4505                	li	a0,1
 17c:	00000097          	auipc	ra,0x0
 180:	3ae080e7          	jalr	942(ra) # 52a <write>
 184:	b7c1                	j	144 <grep+0x2a>
    if(m > 0){
 186:	03404563          	bgtz	s4,1b0 <grep+0x96>
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 18a:	414b863b          	subw	a2,s7,s4
 18e:	014a85b3          	add	a1,s5,s4
 192:	855a                	mv	a0,s6
 194:	00000097          	auipc	ra,0x0
 198:	38e080e7          	jalr	910(ra) # 522 <read>
 19c:	02a05663          	blez	a0,1c8 <grep+0xae>
    m += n;
 1a0:	00aa0a3b          	addw	s4,s4,a0
    buf[m] = '\0';
 1a4:	014a87b3          	add	a5,s5,s4
 1a8:	00078023          	sb	zero,0(a5)
    p = buf;
 1ac:	8956                	mv	s2,s5
    while((q = strchr(p, '\n')) != 0){
 1ae:	bf69                	j	148 <grep+0x2e>
      m -= p - buf;
 1b0:	415907b3          	sub	a5,s2,s5
 1b4:	40fa0a3b          	subw	s4,s4,a5
      memmove(buf, p, m);
 1b8:	8652                	mv	a2,s4
 1ba:	85ca                	mv	a1,s2
 1bc:	8556                	mv	a0,s5
 1be:	00000097          	auipc	ra,0x0
 1c2:	29a080e7          	jalr	666(ra) # 458 <memmove>
 1c6:	b7d1                	j	18a <grep+0x70>
}
 1c8:	60a6                	ld	ra,72(sp)
 1ca:	6406                	ld	s0,64(sp)
 1cc:	74e2                	ld	s1,56(sp)
 1ce:	7942                	ld	s2,48(sp)
 1d0:	79a2                	ld	s3,40(sp)
 1d2:	7a02                	ld	s4,32(sp)
 1d4:	6ae2                	ld	s5,24(sp)
 1d6:	6b42                	ld	s6,16(sp)
 1d8:	6ba2                	ld	s7,8(sp)
 1da:	6161                	addi	sp,sp,80
 1dc:	8082                	ret

00000000000001de <main>:
{
 1de:	7139                	addi	sp,sp,-64
 1e0:	fc06                	sd	ra,56(sp)
 1e2:	f822                	sd	s0,48(sp)
 1e4:	f426                	sd	s1,40(sp)
 1e6:	f04a                	sd	s2,32(sp)
 1e8:	ec4e                	sd	s3,24(sp)
 1ea:	e852                	sd	s4,16(sp)
 1ec:	e456                	sd	s5,8(sp)
 1ee:	0080                	addi	s0,sp,64
  if(argc <= 1){
 1f0:	4785                	li	a5,1
 1f2:	04a7de63          	bge	a5,a0,24e <main+0x70>
  pattern = argv[1];
 1f6:	0085ba03          	ld	s4,8(a1)
  if(argc <= 2){
 1fa:	4789                	li	a5,2
 1fc:	06a7d763          	bge	a5,a0,26a <main+0x8c>
 200:	01058913          	addi	s2,a1,16
 204:	ffd5099b          	addiw	s3,a0,-3
 208:	02099793          	slli	a5,s3,0x20
 20c:	01d7d993          	srli	s3,a5,0x1d
 210:	05e1                	addi	a1,a1,24
 212:	99ae                	add	s3,s3,a1
    if((fd = open(argv[i], 0)) < 0){
 214:	4581                	li	a1,0
 216:	00093503          	ld	a0,0(s2)
 21a:	00000097          	auipc	ra,0x0
 21e:	330080e7          	jalr	816(ra) # 54a <open>
 222:	84aa                	mv	s1,a0
 224:	04054e63          	bltz	a0,280 <main+0xa2>
    grep(pattern, fd);
 228:	85aa                	mv	a1,a0
 22a:	8552                	mv	a0,s4
 22c:	00000097          	auipc	ra,0x0
 230:	eee080e7          	jalr	-274(ra) # 11a <grep>
    close(fd);
 234:	8526                	mv	a0,s1
 236:	00000097          	auipc	ra,0x0
 23a:	2fc080e7          	jalr	764(ra) # 532 <close>
  for(i = 2; i < argc; i++){
 23e:	0921                	addi	s2,s2,8
 240:	fd391ae3          	bne	s2,s3,214 <main+0x36>
  exit(0);
 244:	4501                	li	a0,0
 246:	00000097          	auipc	ra,0x0
 24a:	2c4080e7          	jalr	708(ra) # 50a <exit>
    fprintf(2, "usage: grep pattern [file ...]\n");
 24e:	00001597          	auipc	a1,0x1
 252:	82258593          	addi	a1,a1,-2014 # a70 <malloc+0xec>
 256:	4509                	li	a0,2
 258:	00000097          	auipc	ra,0x0
 25c:	646080e7          	jalr	1606(ra) # 89e <fprintf>
    exit(1);
 260:	4505                	li	a0,1
 262:	00000097          	auipc	ra,0x0
 266:	2a8080e7          	jalr	680(ra) # 50a <exit>
    grep(pattern, 0);
 26a:	4581                	li	a1,0
 26c:	8552                	mv	a0,s4
 26e:	00000097          	auipc	ra,0x0
 272:	eac080e7          	jalr	-340(ra) # 11a <grep>
    exit(0);
 276:	4501                	li	a0,0
 278:	00000097          	auipc	ra,0x0
 27c:	292080e7          	jalr	658(ra) # 50a <exit>
      printf("grep: cannot open %s\n", argv[i]);
 280:	00093583          	ld	a1,0(s2)
 284:	00001517          	auipc	a0,0x1
 288:	80c50513          	addi	a0,a0,-2036 # a90 <malloc+0x10c>
 28c:	00000097          	auipc	ra,0x0
 290:	640080e7          	jalr	1600(ra) # 8cc <printf>
      exit(1);
 294:	4505                	li	a0,1
 296:	00000097          	auipc	ra,0x0
 29a:	274080e7          	jalr	628(ra) # 50a <exit>

000000000000029e <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 29e:	1141                	addi	sp,sp,-16
 2a0:	e422                	sd	s0,8(sp)
 2a2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2a4:	87aa                	mv	a5,a0
 2a6:	0585                	addi	a1,a1,1
 2a8:	0785                	addi	a5,a5,1
 2aa:	fff5c703          	lbu	a4,-1(a1)
 2ae:	fee78fa3          	sb	a4,-1(a5)
 2b2:	fb75                	bnez	a4,2a6 <strcpy+0x8>
    ;
  return os;
}
 2b4:	6422                	ld	s0,8(sp)
 2b6:	0141                	addi	sp,sp,16
 2b8:	8082                	ret

00000000000002ba <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2ba:	1141                	addi	sp,sp,-16
 2bc:	e422                	sd	s0,8(sp)
 2be:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2c0:	00054783          	lbu	a5,0(a0)
 2c4:	cb91                	beqz	a5,2d8 <strcmp+0x1e>
 2c6:	0005c703          	lbu	a4,0(a1)
 2ca:	00f71763          	bne	a4,a5,2d8 <strcmp+0x1e>
    p++, q++;
 2ce:	0505                	addi	a0,a0,1
 2d0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2d2:	00054783          	lbu	a5,0(a0)
 2d6:	fbe5                	bnez	a5,2c6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2d8:	0005c503          	lbu	a0,0(a1)
}
 2dc:	40a7853b          	subw	a0,a5,a0
 2e0:	6422                	ld	s0,8(sp)
 2e2:	0141                	addi	sp,sp,16
 2e4:	8082                	ret

00000000000002e6 <strlen>:

uint
strlen(const char *s)
{
 2e6:	1141                	addi	sp,sp,-16
 2e8:	e422                	sd	s0,8(sp)
 2ea:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2ec:	00054783          	lbu	a5,0(a0)
 2f0:	cf91                	beqz	a5,30c <strlen+0x26>
 2f2:	0505                	addi	a0,a0,1
 2f4:	87aa                	mv	a5,a0
 2f6:	4685                	li	a3,1
 2f8:	9e89                	subw	a3,a3,a0
 2fa:	00f6853b          	addw	a0,a3,a5
 2fe:	0785                	addi	a5,a5,1
 300:	fff7c703          	lbu	a4,-1(a5)
 304:	fb7d                	bnez	a4,2fa <strlen+0x14>
    ;
  return n;
}
 306:	6422                	ld	s0,8(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret
  for(n = 0; s[n]; n++)
 30c:	4501                	li	a0,0
 30e:	bfe5                	j	306 <strlen+0x20>

0000000000000310 <memset>:

void*
memset(void *dst, int c, uint n)
{
 310:	1141                	addi	sp,sp,-16
 312:	e422                	sd	s0,8(sp)
 314:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 316:	ca19                	beqz	a2,32c <memset+0x1c>
 318:	87aa                	mv	a5,a0
 31a:	1602                	slli	a2,a2,0x20
 31c:	9201                	srli	a2,a2,0x20
 31e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 322:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 326:	0785                	addi	a5,a5,1
 328:	fee79de3          	bne	a5,a4,322 <memset+0x12>
  }
  return dst;
}
 32c:	6422                	ld	s0,8(sp)
 32e:	0141                	addi	sp,sp,16
 330:	8082                	ret

0000000000000332 <strchr>:

char*
strchr(const char *s, char c)
{
 332:	1141                	addi	sp,sp,-16
 334:	e422                	sd	s0,8(sp)
 336:	0800                	addi	s0,sp,16
  for(; *s; s++)
 338:	00054783          	lbu	a5,0(a0)
 33c:	cb99                	beqz	a5,352 <strchr+0x20>
    if(*s == c)
 33e:	00f58763          	beq	a1,a5,34c <strchr+0x1a>
  for(; *s; s++)
 342:	0505                	addi	a0,a0,1
 344:	00054783          	lbu	a5,0(a0)
 348:	fbfd                	bnez	a5,33e <strchr+0xc>
      return (char*)s;
  return 0;
 34a:	4501                	li	a0,0
}
 34c:	6422                	ld	s0,8(sp)
 34e:	0141                	addi	sp,sp,16
 350:	8082                	ret
  return 0;
 352:	4501                	li	a0,0
 354:	bfe5                	j	34c <strchr+0x1a>

0000000000000356 <gets>:

char*
gets(char *buf, int max)
{
 356:	711d                	addi	sp,sp,-96
 358:	ec86                	sd	ra,88(sp)
 35a:	e8a2                	sd	s0,80(sp)
 35c:	e4a6                	sd	s1,72(sp)
 35e:	e0ca                	sd	s2,64(sp)
 360:	fc4e                	sd	s3,56(sp)
 362:	f852                	sd	s4,48(sp)
 364:	f456                	sd	s5,40(sp)
 366:	f05a                	sd	s6,32(sp)
 368:	ec5e                	sd	s7,24(sp)
 36a:	1080                	addi	s0,sp,96
 36c:	8baa                	mv	s7,a0
 36e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 370:	892a                	mv	s2,a0
 372:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 374:	4aa9                	li	s5,10
 376:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 378:	89a6                	mv	s3,s1
 37a:	2485                	addiw	s1,s1,1
 37c:	0344d863          	bge	s1,s4,3ac <gets+0x56>
    cc = read(0, &c, 1);
 380:	4605                	li	a2,1
 382:	faf40593          	addi	a1,s0,-81
 386:	4501                	li	a0,0
 388:	00000097          	auipc	ra,0x0
 38c:	19a080e7          	jalr	410(ra) # 522 <read>
    if(cc < 1)
 390:	00a05e63          	blez	a0,3ac <gets+0x56>
    buf[i++] = c;
 394:	faf44783          	lbu	a5,-81(s0)
 398:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 39c:	01578763          	beq	a5,s5,3aa <gets+0x54>
 3a0:	0905                	addi	s2,s2,1
 3a2:	fd679be3          	bne	a5,s6,378 <gets+0x22>
  for(i=0; i+1 < max; ){
 3a6:	89a6                	mv	s3,s1
 3a8:	a011                	j	3ac <gets+0x56>
 3aa:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 3ac:	99de                	add	s3,s3,s7
 3ae:	00098023          	sb	zero,0(s3)
  return buf;
}
 3b2:	855e                	mv	a0,s7
 3b4:	60e6                	ld	ra,88(sp)
 3b6:	6446                	ld	s0,80(sp)
 3b8:	64a6                	ld	s1,72(sp)
 3ba:	6906                	ld	s2,64(sp)
 3bc:	79e2                	ld	s3,56(sp)
 3be:	7a42                	ld	s4,48(sp)
 3c0:	7aa2                	ld	s5,40(sp)
 3c2:	7b02                	ld	s6,32(sp)
 3c4:	6be2                	ld	s7,24(sp)
 3c6:	6125                	addi	sp,sp,96
 3c8:	8082                	ret

00000000000003ca <stat>:

int
stat(const char *n, struct stat *st)
{
 3ca:	1101                	addi	sp,sp,-32
 3cc:	ec06                	sd	ra,24(sp)
 3ce:	e822                	sd	s0,16(sp)
 3d0:	e426                	sd	s1,8(sp)
 3d2:	e04a                	sd	s2,0(sp)
 3d4:	1000                	addi	s0,sp,32
 3d6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3d8:	4581                	li	a1,0
 3da:	00000097          	auipc	ra,0x0
 3de:	170080e7          	jalr	368(ra) # 54a <open>
  if(fd < 0)
 3e2:	02054563          	bltz	a0,40c <stat+0x42>
 3e6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3e8:	85ca                	mv	a1,s2
 3ea:	00000097          	auipc	ra,0x0
 3ee:	178080e7          	jalr	376(ra) # 562 <fstat>
 3f2:	892a                	mv	s2,a0
  close(fd);
 3f4:	8526                	mv	a0,s1
 3f6:	00000097          	auipc	ra,0x0
 3fa:	13c080e7          	jalr	316(ra) # 532 <close>
  return r;
}
 3fe:	854a                	mv	a0,s2
 400:	60e2                	ld	ra,24(sp)
 402:	6442                	ld	s0,16(sp)
 404:	64a2                	ld	s1,8(sp)
 406:	6902                	ld	s2,0(sp)
 408:	6105                	addi	sp,sp,32
 40a:	8082                	ret
    return -1;
 40c:	597d                	li	s2,-1
 40e:	bfc5                	j	3fe <stat+0x34>

0000000000000410 <atoi>:

int
atoi(const char *s)
{
 410:	1141                	addi	sp,sp,-16
 412:	e422                	sd	s0,8(sp)
 414:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 416:	00054683          	lbu	a3,0(a0)
 41a:	fd06879b          	addiw	a5,a3,-48
 41e:	0ff7f793          	zext.b	a5,a5
 422:	4625                	li	a2,9
 424:	02f66863          	bltu	a2,a5,454 <atoi+0x44>
 428:	872a                	mv	a4,a0
  n = 0;
 42a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 42c:	0705                	addi	a4,a4,1
 42e:	0025179b          	slliw	a5,a0,0x2
 432:	9fa9                	addw	a5,a5,a0
 434:	0017979b          	slliw	a5,a5,0x1
 438:	9fb5                	addw	a5,a5,a3
 43a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 43e:	00074683          	lbu	a3,0(a4)
 442:	fd06879b          	addiw	a5,a3,-48
 446:	0ff7f793          	zext.b	a5,a5
 44a:	fef671e3          	bgeu	a2,a5,42c <atoi+0x1c>
  return n;
}
 44e:	6422                	ld	s0,8(sp)
 450:	0141                	addi	sp,sp,16
 452:	8082                	ret
  n = 0;
 454:	4501                	li	a0,0
 456:	bfe5                	j	44e <atoi+0x3e>

0000000000000458 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 458:	1141                	addi	sp,sp,-16
 45a:	e422                	sd	s0,8(sp)
 45c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 45e:	02b57463          	bgeu	a0,a1,486 <memmove+0x2e>
    while(n-- > 0)
 462:	00c05f63          	blez	a2,480 <memmove+0x28>
 466:	1602                	slli	a2,a2,0x20
 468:	9201                	srli	a2,a2,0x20
 46a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 46e:	872a                	mv	a4,a0
      *dst++ = *src++;
 470:	0585                	addi	a1,a1,1
 472:	0705                	addi	a4,a4,1
 474:	fff5c683          	lbu	a3,-1(a1)
 478:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 47c:	fee79ae3          	bne	a5,a4,470 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 480:	6422                	ld	s0,8(sp)
 482:	0141                	addi	sp,sp,16
 484:	8082                	ret
    dst += n;
 486:	00c50733          	add	a4,a0,a2
    src += n;
 48a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 48c:	fec05ae3          	blez	a2,480 <memmove+0x28>
 490:	fff6079b          	addiw	a5,a2,-1
 494:	1782                	slli	a5,a5,0x20
 496:	9381                	srli	a5,a5,0x20
 498:	fff7c793          	not	a5,a5
 49c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 49e:	15fd                	addi	a1,a1,-1
 4a0:	177d                	addi	a4,a4,-1
 4a2:	0005c683          	lbu	a3,0(a1)
 4a6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 4aa:	fee79ae3          	bne	a5,a4,49e <memmove+0x46>
 4ae:	bfc9                	j	480 <memmove+0x28>

00000000000004b0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4b0:	1141                	addi	sp,sp,-16
 4b2:	e422                	sd	s0,8(sp)
 4b4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 4b6:	ca05                	beqz	a2,4e6 <memcmp+0x36>
 4b8:	fff6069b          	addiw	a3,a2,-1
 4bc:	1682                	slli	a3,a3,0x20
 4be:	9281                	srli	a3,a3,0x20
 4c0:	0685                	addi	a3,a3,1
 4c2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 4c4:	00054783          	lbu	a5,0(a0)
 4c8:	0005c703          	lbu	a4,0(a1)
 4cc:	00e79863          	bne	a5,a4,4dc <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 4d0:	0505                	addi	a0,a0,1
    p2++;
 4d2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4d4:	fed518e3          	bne	a0,a3,4c4 <memcmp+0x14>
  }
  return 0;
 4d8:	4501                	li	a0,0
 4da:	a019                	j	4e0 <memcmp+0x30>
      return *p1 - *p2;
 4dc:	40e7853b          	subw	a0,a5,a4
}
 4e0:	6422                	ld	s0,8(sp)
 4e2:	0141                	addi	sp,sp,16
 4e4:	8082                	ret
  return 0;
 4e6:	4501                	li	a0,0
 4e8:	bfe5                	j	4e0 <memcmp+0x30>

00000000000004ea <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4ea:	1141                	addi	sp,sp,-16
 4ec:	e406                	sd	ra,8(sp)
 4ee:	e022                	sd	s0,0(sp)
 4f0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4f2:	00000097          	auipc	ra,0x0
 4f6:	f66080e7          	jalr	-154(ra) # 458 <memmove>
}
 4fa:	60a2                	ld	ra,8(sp)
 4fc:	6402                	ld	s0,0(sp)
 4fe:	0141                	addi	sp,sp,16
 500:	8082                	ret

0000000000000502 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 502:	4885                	li	a7,1
 ecall
 504:	00000073          	ecall
 ret
 508:	8082                	ret

000000000000050a <exit>:
.global exit
exit:
 li a7, SYS_exit
 50a:	4889                	li	a7,2
 ecall
 50c:	00000073          	ecall
 ret
 510:	8082                	ret

0000000000000512 <wait>:
.global wait
wait:
 li a7, SYS_wait
 512:	488d                	li	a7,3
 ecall
 514:	00000073          	ecall
 ret
 518:	8082                	ret

000000000000051a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 51a:	4891                	li	a7,4
 ecall
 51c:	00000073          	ecall
 ret
 520:	8082                	ret

0000000000000522 <read>:
.global read
read:
 li a7, SYS_read
 522:	4895                	li	a7,5
 ecall
 524:	00000073          	ecall
 ret
 528:	8082                	ret

000000000000052a <write>:
.global write
write:
 li a7, SYS_write
 52a:	48c1                	li	a7,16
 ecall
 52c:	00000073          	ecall
 ret
 530:	8082                	ret

0000000000000532 <close>:
.global close
close:
 li a7, SYS_close
 532:	48d5                	li	a7,21
 ecall
 534:	00000073          	ecall
 ret
 538:	8082                	ret

000000000000053a <kill>:
.global kill
kill:
 li a7, SYS_kill
 53a:	4899                	li	a7,6
 ecall
 53c:	00000073          	ecall
 ret
 540:	8082                	ret

0000000000000542 <exec>:
.global exec
exec:
 li a7, SYS_exec
 542:	489d                	li	a7,7
 ecall
 544:	00000073          	ecall
 ret
 548:	8082                	ret

000000000000054a <open>:
.global open
open:
 li a7, SYS_open
 54a:	48bd                	li	a7,15
 ecall
 54c:	00000073          	ecall
 ret
 550:	8082                	ret

0000000000000552 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 552:	48c5                	li	a7,17
 ecall
 554:	00000073          	ecall
 ret
 558:	8082                	ret

000000000000055a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 55a:	48c9                	li	a7,18
 ecall
 55c:	00000073          	ecall
 ret
 560:	8082                	ret

0000000000000562 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 562:	48a1                	li	a7,8
 ecall
 564:	00000073          	ecall
 ret
 568:	8082                	ret

000000000000056a <link>:
.global link
link:
 li a7, SYS_link
 56a:	48cd                	li	a7,19
 ecall
 56c:	00000073          	ecall
 ret
 570:	8082                	ret

0000000000000572 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 572:	48d1                	li	a7,20
 ecall
 574:	00000073          	ecall
 ret
 578:	8082                	ret

000000000000057a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 57a:	48a5                	li	a7,9
 ecall
 57c:	00000073          	ecall
 ret
 580:	8082                	ret

0000000000000582 <dup>:
.global dup
dup:
 li a7, SYS_dup
 582:	48a9                	li	a7,10
 ecall
 584:	00000073          	ecall
 ret
 588:	8082                	ret

000000000000058a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 58a:	48ad                	li	a7,11
 ecall
 58c:	00000073          	ecall
 ret
 590:	8082                	ret

0000000000000592 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 592:	48b1                	li	a7,12
 ecall
 594:	00000073          	ecall
 ret
 598:	8082                	ret

000000000000059a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 59a:	48b5                	li	a7,13
 ecall
 59c:	00000073          	ecall
 ret
 5a0:	8082                	ret

00000000000005a2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5a2:	48b9                	li	a7,14
 ecall
 5a4:	00000073          	ecall
 ret
 5a8:	8082                	ret

00000000000005aa <getprocs>:
.global getprocs
getprocs:
 li a7, SYS_getprocs
 5aa:	48d9                	li	a7,22
 ecall
 5ac:	00000073          	ecall
 ret
 5b0:	8082                	ret

00000000000005b2 <wait2>:
.global wait2
wait2:
 li a7, SYS_wait2
 5b2:	48dd                	li	a7,23
 ecall
 5b4:	00000073          	ecall
 ret
 5b8:	8082                	ret

00000000000005ba <freepmem>:
.global freepmem
freepmem:
 li a7, SYS_freepmem
 5ba:	48e1                	li	a7,24
 ecall
 5bc:	00000073          	ecall
 ret
 5c0:	8082                	ret

00000000000005c2 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 5c2:	48e5                	li	a7,25
 ecall
 5c4:	00000073          	ecall
 ret
 5c8:	8082                	ret

00000000000005ca <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 5ca:	48e9                	li	a7,26
 ecall
 5cc:	00000073          	ecall
 ret
 5d0:	8082                	ret

00000000000005d2 <sem_init>:
.global sem_init
sem_init:
 li a7, SYS_sem_init
 5d2:	48ed                	li	a7,27
 ecall
 5d4:	00000073          	ecall
 ret
 5d8:	8082                	ret

00000000000005da <sem_destroy>:
.global sem_destroy
sem_destroy:
 li a7, SYS_sem_destroy
 5da:	48f1                	li	a7,28
 ecall
 5dc:	00000073          	ecall
 ret
 5e0:	8082                	ret

00000000000005e2 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 5e2:	48f5                	li	a7,29
 ecall
 5e4:	00000073          	ecall
 ret
 5e8:	8082                	ret

00000000000005ea <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 5ea:	48f9                	li	a7,30
 ecall
 5ec:	00000073          	ecall
 ret
 5f0:	8082                	ret

00000000000005f2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5f2:	1101                	addi	sp,sp,-32
 5f4:	ec06                	sd	ra,24(sp)
 5f6:	e822                	sd	s0,16(sp)
 5f8:	1000                	addi	s0,sp,32
 5fa:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5fe:	4605                	li	a2,1
 600:	fef40593          	addi	a1,s0,-17
 604:	00000097          	auipc	ra,0x0
 608:	f26080e7          	jalr	-218(ra) # 52a <write>
}
 60c:	60e2                	ld	ra,24(sp)
 60e:	6442                	ld	s0,16(sp)
 610:	6105                	addi	sp,sp,32
 612:	8082                	ret

0000000000000614 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 614:	7139                	addi	sp,sp,-64
 616:	fc06                	sd	ra,56(sp)
 618:	f822                	sd	s0,48(sp)
 61a:	f426                	sd	s1,40(sp)
 61c:	f04a                	sd	s2,32(sp)
 61e:	ec4e                	sd	s3,24(sp)
 620:	0080                	addi	s0,sp,64
 622:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 624:	c299                	beqz	a3,62a <printint+0x16>
 626:	0805c963          	bltz	a1,6b8 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 62a:	2581                	sext.w	a1,a1
  neg = 0;
 62c:	4881                	li	a7,0
 62e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 632:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 634:	2601                	sext.w	a2,a2
 636:	00000517          	auipc	a0,0x0
 63a:	4d250513          	addi	a0,a0,1234 # b08 <digits>
 63e:	883a                	mv	a6,a4
 640:	2705                	addiw	a4,a4,1
 642:	02c5f7bb          	remuw	a5,a1,a2
 646:	1782                	slli	a5,a5,0x20
 648:	9381                	srli	a5,a5,0x20
 64a:	97aa                	add	a5,a5,a0
 64c:	0007c783          	lbu	a5,0(a5)
 650:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 654:	0005879b          	sext.w	a5,a1
 658:	02c5d5bb          	divuw	a1,a1,a2
 65c:	0685                	addi	a3,a3,1
 65e:	fec7f0e3          	bgeu	a5,a2,63e <printint+0x2a>
  if(neg)
 662:	00088c63          	beqz	a7,67a <printint+0x66>
    buf[i++] = '-';
 666:	fd070793          	addi	a5,a4,-48
 66a:	00878733          	add	a4,a5,s0
 66e:	02d00793          	li	a5,45
 672:	fef70823          	sb	a5,-16(a4)
 676:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 67a:	02e05863          	blez	a4,6aa <printint+0x96>
 67e:	fc040793          	addi	a5,s0,-64
 682:	00e78933          	add	s2,a5,a4
 686:	fff78993          	addi	s3,a5,-1
 68a:	99ba                	add	s3,s3,a4
 68c:	377d                	addiw	a4,a4,-1
 68e:	1702                	slli	a4,a4,0x20
 690:	9301                	srli	a4,a4,0x20
 692:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 696:	fff94583          	lbu	a1,-1(s2)
 69a:	8526                	mv	a0,s1
 69c:	00000097          	auipc	ra,0x0
 6a0:	f56080e7          	jalr	-170(ra) # 5f2 <putc>
  while(--i >= 0)
 6a4:	197d                	addi	s2,s2,-1
 6a6:	ff3918e3          	bne	s2,s3,696 <printint+0x82>
}
 6aa:	70e2                	ld	ra,56(sp)
 6ac:	7442                	ld	s0,48(sp)
 6ae:	74a2                	ld	s1,40(sp)
 6b0:	7902                	ld	s2,32(sp)
 6b2:	69e2                	ld	s3,24(sp)
 6b4:	6121                	addi	sp,sp,64
 6b6:	8082                	ret
    x = -xx;
 6b8:	40b005bb          	negw	a1,a1
    neg = 1;
 6bc:	4885                	li	a7,1
    x = -xx;
 6be:	bf85                	j	62e <printint+0x1a>

00000000000006c0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6c0:	7119                	addi	sp,sp,-128
 6c2:	fc86                	sd	ra,120(sp)
 6c4:	f8a2                	sd	s0,112(sp)
 6c6:	f4a6                	sd	s1,104(sp)
 6c8:	f0ca                	sd	s2,96(sp)
 6ca:	ecce                	sd	s3,88(sp)
 6cc:	e8d2                	sd	s4,80(sp)
 6ce:	e4d6                	sd	s5,72(sp)
 6d0:	e0da                	sd	s6,64(sp)
 6d2:	fc5e                	sd	s7,56(sp)
 6d4:	f862                	sd	s8,48(sp)
 6d6:	f466                	sd	s9,40(sp)
 6d8:	f06a                	sd	s10,32(sp)
 6da:	ec6e                	sd	s11,24(sp)
 6dc:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6de:	0005c903          	lbu	s2,0(a1)
 6e2:	18090f63          	beqz	s2,880 <vprintf+0x1c0>
 6e6:	8aaa                	mv	s5,a0
 6e8:	8b32                	mv	s6,a2
 6ea:	00158493          	addi	s1,a1,1
  state = 0;
 6ee:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 6f0:	02500a13          	li	s4,37
 6f4:	4c55                	li	s8,21
 6f6:	00000c97          	auipc	s9,0x0
 6fa:	3bac8c93          	addi	s9,s9,954 # ab0 <malloc+0x12c>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6fe:	02800d93          	li	s11,40
  putc(fd, 'x');
 702:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 704:	00000b97          	auipc	s7,0x0
 708:	404b8b93          	addi	s7,s7,1028 # b08 <digits>
 70c:	a839                	j	72a <vprintf+0x6a>
        putc(fd, c);
 70e:	85ca                	mv	a1,s2
 710:	8556                	mv	a0,s5
 712:	00000097          	auipc	ra,0x0
 716:	ee0080e7          	jalr	-288(ra) # 5f2 <putc>
 71a:	a019                	j	720 <vprintf+0x60>
    } else if(state == '%'){
 71c:	01498d63          	beq	s3,s4,736 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 720:	0485                	addi	s1,s1,1
 722:	fff4c903          	lbu	s2,-1(s1)
 726:	14090d63          	beqz	s2,880 <vprintf+0x1c0>
    if(state == 0){
 72a:	fe0999e3          	bnez	s3,71c <vprintf+0x5c>
      if(c == '%'){
 72e:	ff4910e3          	bne	s2,s4,70e <vprintf+0x4e>
        state = '%';
 732:	89d2                	mv	s3,s4
 734:	b7f5                	j	720 <vprintf+0x60>
      if(c == 'd'){
 736:	11490c63          	beq	s2,s4,84e <vprintf+0x18e>
 73a:	f9d9079b          	addiw	a5,s2,-99
 73e:	0ff7f793          	zext.b	a5,a5
 742:	10fc6e63          	bltu	s8,a5,85e <vprintf+0x19e>
 746:	f9d9079b          	addiw	a5,s2,-99
 74a:	0ff7f713          	zext.b	a4,a5
 74e:	10ec6863          	bltu	s8,a4,85e <vprintf+0x19e>
 752:	00271793          	slli	a5,a4,0x2
 756:	97e6                	add	a5,a5,s9
 758:	439c                	lw	a5,0(a5)
 75a:	97e6                	add	a5,a5,s9
 75c:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 75e:	008b0913          	addi	s2,s6,8
 762:	4685                	li	a3,1
 764:	4629                	li	a2,10
 766:	000b2583          	lw	a1,0(s6)
 76a:	8556                	mv	a0,s5
 76c:	00000097          	auipc	ra,0x0
 770:	ea8080e7          	jalr	-344(ra) # 614 <printint>
 774:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 776:	4981                	li	s3,0
 778:	b765                	j	720 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 77a:	008b0913          	addi	s2,s6,8
 77e:	4681                	li	a3,0
 780:	4629                	li	a2,10
 782:	000b2583          	lw	a1,0(s6)
 786:	8556                	mv	a0,s5
 788:	00000097          	auipc	ra,0x0
 78c:	e8c080e7          	jalr	-372(ra) # 614 <printint>
 790:	8b4a                	mv	s6,s2
      state = 0;
 792:	4981                	li	s3,0
 794:	b771                	j	720 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 796:	008b0913          	addi	s2,s6,8
 79a:	4681                	li	a3,0
 79c:	866a                	mv	a2,s10
 79e:	000b2583          	lw	a1,0(s6)
 7a2:	8556                	mv	a0,s5
 7a4:	00000097          	auipc	ra,0x0
 7a8:	e70080e7          	jalr	-400(ra) # 614 <printint>
 7ac:	8b4a                	mv	s6,s2
      state = 0;
 7ae:	4981                	li	s3,0
 7b0:	bf85                	j	720 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 7b2:	008b0793          	addi	a5,s6,8
 7b6:	f8f43423          	sd	a5,-120(s0)
 7ba:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 7be:	03000593          	li	a1,48
 7c2:	8556                	mv	a0,s5
 7c4:	00000097          	auipc	ra,0x0
 7c8:	e2e080e7          	jalr	-466(ra) # 5f2 <putc>
  putc(fd, 'x');
 7cc:	07800593          	li	a1,120
 7d0:	8556                	mv	a0,s5
 7d2:	00000097          	auipc	ra,0x0
 7d6:	e20080e7          	jalr	-480(ra) # 5f2 <putc>
 7da:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7dc:	03c9d793          	srli	a5,s3,0x3c
 7e0:	97de                	add	a5,a5,s7
 7e2:	0007c583          	lbu	a1,0(a5)
 7e6:	8556                	mv	a0,s5
 7e8:	00000097          	auipc	ra,0x0
 7ec:	e0a080e7          	jalr	-502(ra) # 5f2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7f0:	0992                	slli	s3,s3,0x4
 7f2:	397d                	addiw	s2,s2,-1
 7f4:	fe0914e3          	bnez	s2,7dc <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 7f8:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 7fc:	4981                	li	s3,0
 7fe:	b70d                	j	720 <vprintf+0x60>
        s = va_arg(ap, char*);
 800:	008b0913          	addi	s2,s6,8
 804:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 808:	02098163          	beqz	s3,82a <vprintf+0x16a>
        while(*s != 0){
 80c:	0009c583          	lbu	a1,0(s3)
 810:	c5ad                	beqz	a1,87a <vprintf+0x1ba>
          putc(fd, *s);
 812:	8556                	mv	a0,s5
 814:	00000097          	auipc	ra,0x0
 818:	dde080e7          	jalr	-546(ra) # 5f2 <putc>
          s++;
 81c:	0985                	addi	s3,s3,1
        while(*s != 0){
 81e:	0009c583          	lbu	a1,0(s3)
 822:	f9e5                	bnez	a1,812 <vprintf+0x152>
        s = va_arg(ap, char*);
 824:	8b4a                	mv	s6,s2
      state = 0;
 826:	4981                	li	s3,0
 828:	bde5                	j	720 <vprintf+0x60>
          s = "(null)";
 82a:	00000997          	auipc	s3,0x0
 82e:	27e98993          	addi	s3,s3,638 # aa8 <malloc+0x124>
        while(*s != 0){
 832:	85ee                	mv	a1,s11
 834:	bff9                	j	812 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 836:	008b0913          	addi	s2,s6,8
 83a:	000b4583          	lbu	a1,0(s6)
 83e:	8556                	mv	a0,s5
 840:	00000097          	auipc	ra,0x0
 844:	db2080e7          	jalr	-590(ra) # 5f2 <putc>
 848:	8b4a                	mv	s6,s2
      state = 0;
 84a:	4981                	li	s3,0
 84c:	bdd1                	j	720 <vprintf+0x60>
        putc(fd, c);
 84e:	85d2                	mv	a1,s4
 850:	8556                	mv	a0,s5
 852:	00000097          	auipc	ra,0x0
 856:	da0080e7          	jalr	-608(ra) # 5f2 <putc>
      state = 0;
 85a:	4981                	li	s3,0
 85c:	b5d1                	j	720 <vprintf+0x60>
        putc(fd, '%');
 85e:	85d2                	mv	a1,s4
 860:	8556                	mv	a0,s5
 862:	00000097          	auipc	ra,0x0
 866:	d90080e7          	jalr	-624(ra) # 5f2 <putc>
        putc(fd, c);
 86a:	85ca                	mv	a1,s2
 86c:	8556                	mv	a0,s5
 86e:	00000097          	auipc	ra,0x0
 872:	d84080e7          	jalr	-636(ra) # 5f2 <putc>
      state = 0;
 876:	4981                	li	s3,0
 878:	b565                	j	720 <vprintf+0x60>
        s = va_arg(ap, char*);
 87a:	8b4a                	mv	s6,s2
      state = 0;
 87c:	4981                	li	s3,0
 87e:	b54d                	j	720 <vprintf+0x60>
    }
  }
}
 880:	70e6                	ld	ra,120(sp)
 882:	7446                	ld	s0,112(sp)
 884:	74a6                	ld	s1,104(sp)
 886:	7906                	ld	s2,96(sp)
 888:	69e6                	ld	s3,88(sp)
 88a:	6a46                	ld	s4,80(sp)
 88c:	6aa6                	ld	s5,72(sp)
 88e:	6b06                	ld	s6,64(sp)
 890:	7be2                	ld	s7,56(sp)
 892:	7c42                	ld	s8,48(sp)
 894:	7ca2                	ld	s9,40(sp)
 896:	7d02                	ld	s10,32(sp)
 898:	6de2                	ld	s11,24(sp)
 89a:	6109                	addi	sp,sp,128
 89c:	8082                	ret

000000000000089e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 89e:	715d                	addi	sp,sp,-80
 8a0:	ec06                	sd	ra,24(sp)
 8a2:	e822                	sd	s0,16(sp)
 8a4:	1000                	addi	s0,sp,32
 8a6:	e010                	sd	a2,0(s0)
 8a8:	e414                	sd	a3,8(s0)
 8aa:	e818                	sd	a4,16(s0)
 8ac:	ec1c                	sd	a5,24(s0)
 8ae:	03043023          	sd	a6,32(s0)
 8b2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8b6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8ba:	8622                	mv	a2,s0
 8bc:	00000097          	auipc	ra,0x0
 8c0:	e04080e7          	jalr	-508(ra) # 6c0 <vprintf>
}
 8c4:	60e2                	ld	ra,24(sp)
 8c6:	6442                	ld	s0,16(sp)
 8c8:	6161                	addi	sp,sp,80
 8ca:	8082                	ret

00000000000008cc <printf>:

void
printf(const char *fmt, ...)
{
 8cc:	711d                	addi	sp,sp,-96
 8ce:	ec06                	sd	ra,24(sp)
 8d0:	e822                	sd	s0,16(sp)
 8d2:	1000                	addi	s0,sp,32
 8d4:	e40c                	sd	a1,8(s0)
 8d6:	e810                	sd	a2,16(s0)
 8d8:	ec14                	sd	a3,24(s0)
 8da:	f018                	sd	a4,32(s0)
 8dc:	f41c                	sd	a5,40(s0)
 8de:	03043823          	sd	a6,48(s0)
 8e2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8e6:	00840613          	addi	a2,s0,8
 8ea:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8ee:	85aa                	mv	a1,a0
 8f0:	4505                	li	a0,1
 8f2:	00000097          	auipc	ra,0x0
 8f6:	dce080e7          	jalr	-562(ra) # 6c0 <vprintf>
}
 8fa:	60e2                	ld	ra,24(sp)
 8fc:	6442                	ld	s0,16(sp)
 8fe:	6125                	addi	sp,sp,96
 900:	8082                	ret

0000000000000902 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 902:	1141                	addi	sp,sp,-16
 904:	e422                	sd	s0,8(sp)
 906:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 908:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 90c:	00000797          	auipc	a5,0x0
 910:	2147b783          	ld	a5,532(a5) # b20 <freep>
 914:	a02d                	j	93e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 916:	4618                	lw	a4,8(a2)
 918:	9f2d                	addw	a4,a4,a1
 91a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 91e:	6398                	ld	a4,0(a5)
 920:	6310                	ld	a2,0(a4)
 922:	a83d                	j	960 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 924:	ff852703          	lw	a4,-8(a0)
 928:	9f31                	addw	a4,a4,a2
 92a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 92c:	ff053683          	ld	a3,-16(a0)
 930:	a091                	j	974 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 932:	6398                	ld	a4,0(a5)
 934:	00e7e463          	bltu	a5,a4,93c <free+0x3a>
 938:	00e6ea63          	bltu	a3,a4,94c <free+0x4a>
{
 93c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 93e:	fed7fae3          	bgeu	a5,a3,932 <free+0x30>
 942:	6398                	ld	a4,0(a5)
 944:	00e6e463          	bltu	a3,a4,94c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 948:	fee7eae3          	bltu	a5,a4,93c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 94c:	ff852583          	lw	a1,-8(a0)
 950:	6390                	ld	a2,0(a5)
 952:	02059813          	slli	a6,a1,0x20
 956:	01c85713          	srli	a4,a6,0x1c
 95a:	9736                	add	a4,a4,a3
 95c:	fae60de3          	beq	a2,a4,916 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 960:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 964:	4790                	lw	a2,8(a5)
 966:	02061593          	slli	a1,a2,0x20
 96a:	01c5d713          	srli	a4,a1,0x1c
 96e:	973e                	add	a4,a4,a5
 970:	fae68ae3          	beq	a3,a4,924 <free+0x22>
    p->s.ptr = bp->s.ptr;
 974:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 976:	00000717          	auipc	a4,0x0
 97a:	1af73523          	sd	a5,426(a4) # b20 <freep>
}
 97e:	6422                	ld	s0,8(sp)
 980:	0141                	addi	sp,sp,16
 982:	8082                	ret

0000000000000984 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 984:	7139                	addi	sp,sp,-64
 986:	fc06                	sd	ra,56(sp)
 988:	f822                	sd	s0,48(sp)
 98a:	f426                	sd	s1,40(sp)
 98c:	f04a                	sd	s2,32(sp)
 98e:	ec4e                	sd	s3,24(sp)
 990:	e852                	sd	s4,16(sp)
 992:	e456                	sd	s5,8(sp)
 994:	e05a                	sd	s6,0(sp)
 996:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 998:	02051493          	slli	s1,a0,0x20
 99c:	9081                	srli	s1,s1,0x20
 99e:	04bd                	addi	s1,s1,15
 9a0:	8091                	srli	s1,s1,0x4
 9a2:	0014899b          	addiw	s3,s1,1
 9a6:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9a8:	00000517          	auipc	a0,0x0
 9ac:	17853503          	ld	a0,376(a0) # b20 <freep>
 9b0:	c515                	beqz	a0,9dc <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9b2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9b4:	4798                	lw	a4,8(a5)
 9b6:	02977f63          	bgeu	a4,s1,9f4 <malloc+0x70>
 9ba:	8a4e                	mv	s4,s3
 9bc:	0009871b          	sext.w	a4,s3
 9c0:	6685                	lui	a3,0x1
 9c2:	00d77363          	bgeu	a4,a3,9c8 <malloc+0x44>
 9c6:	6a05                	lui	s4,0x1
 9c8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9cc:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9d0:	00000917          	auipc	s2,0x0
 9d4:	15090913          	addi	s2,s2,336 # b20 <freep>
  if(p == (char*)-1)
 9d8:	5afd                	li	s5,-1
 9da:	a895                	j	a4e <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 9dc:	00000797          	auipc	a5,0x0
 9e0:	54c78793          	addi	a5,a5,1356 # f28 <base>
 9e4:	00000717          	auipc	a4,0x0
 9e8:	12f73e23          	sd	a5,316(a4) # b20 <freep>
 9ec:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9ee:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9f2:	b7e1                	j	9ba <malloc+0x36>
      if(p->s.size == nunits)
 9f4:	02e48c63          	beq	s1,a4,a2c <malloc+0xa8>
        p->s.size -= nunits;
 9f8:	4137073b          	subw	a4,a4,s3
 9fc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9fe:	02071693          	slli	a3,a4,0x20
 a02:	01c6d713          	srli	a4,a3,0x1c
 a06:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a08:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a0c:	00000717          	auipc	a4,0x0
 a10:	10a73a23          	sd	a0,276(a4) # b20 <freep>
      return (void*)(p + 1);
 a14:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a18:	70e2                	ld	ra,56(sp)
 a1a:	7442                	ld	s0,48(sp)
 a1c:	74a2                	ld	s1,40(sp)
 a1e:	7902                	ld	s2,32(sp)
 a20:	69e2                	ld	s3,24(sp)
 a22:	6a42                	ld	s4,16(sp)
 a24:	6aa2                	ld	s5,8(sp)
 a26:	6b02                	ld	s6,0(sp)
 a28:	6121                	addi	sp,sp,64
 a2a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a2c:	6398                	ld	a4,0(a5)
 a2e:	e118                	sd	a4,0(a0)
 a30:	bff1                	j	a0c <malloc+0x88>
  hp->s.size = nu;
 a32:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a36:	0541                	addi	a0,a0,16
 a38:	00000097          	auipc	ra,0x0
 a3c:	eca080e7          	jalr	-310(ra) # 902 <free>
  return freep;
 a40:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a44:	d971                	beqz	a0,a18 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a46:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a48:	4798                	lw	a4,8(a5)
 a4a:	fa9775e3          	bgeu	a4,s1,9f4 <malloc+0x70>
    if(p == freep)
 a4e:	00093703          	ld	a4,0(s2)
 a52:	853e                	mv	a0,a5
 a54:	fef719e3          	bne	a4,a5,a46 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 a58:	8552                	mv	a0,s4
 a5a:	00000097          	auipc	ra,0x0
 a5e:	b38080e7          	jalr	-1224(ra) # 592 <sbrk>
  if(p == (char*)-1)
 a62:	fd5518e3          	bne	a0,s5,a32 <malloc+0xae>
        return 0;
 a66:	4501                	li	a0,0
 a68:	bf45                	j	a18 <malloc+0x94>
