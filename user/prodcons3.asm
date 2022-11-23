
user/_prodcons3:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <producer>:
} buffer_t;

buffer_t *buffer;

void *producer()
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    while(1) {
        if (buffer->num_produced >= MAX) {
   8:	00001717          	auipc	a4,0x1
   c:	9d073703          	ld	a4,-1584(a4) # 9d8 <buffer>
  10:	6789                	lui	a5,0x2
  12:	97ba                	add	a5,a5,a4
  14:	479c                	lw	a5,8(a5)
  16:	7ff00693          	li	a3,2047
  1a:	04f6c763          	blt	a3,a5,68 <producer+0x68>
	    exit(0);
	}
	buffer->num_produced++;
  1e:	6589                	lui	a1,0x2
	buffer->buf[buffer->nextin++] = 1;
  20:	4885                	li	a7,1
	buffer->nextin %= BSIZE;
  22:	00001817          	auipc	a6,0x1
  26:	9b680813          	addi	a6,a6,-1610 # 9d8 <buffer>
        if (buffer->num_produced >= MAX) {
  2a:	7ff00513          	li	a0,2047
	buffer->num_produced++;
  2e:	00b706b3          	add	a3,a4,a1
  32:	2785                	addiw	a5,a5,1 # 2001 <__global_pointer$+0xe30>
  34:	c69c                	sw	a5,8(a3)
	buffer->buf[buffer->nextin++] = 1;
  36:	429c                	lw	a5,0(a3)
  38:	0017861b          	addiw	a2,a5,1
  3c:	c290                	sw	a2,0(a3)
  3e:	078a                	slli	a5,a5,0x2
  40:	973e                	add	a4,a4,a5
  42:	01172023          	sw	a7,0(a4)
	buffer->nextin %= BSIZE;
  46:	00083703          	ld	a4,0(a6)
  4a:	00b70633          	add	a2,a4,a1
  4e:	421c                	lw	a5,0(a2)
  50:	41f7d69b          	sraiw	a3,a5,0x1f
  54:	0156d69b          	srliw	a3,a3,0x15
  58:	9fb5                	addw	a5,a5,a3
  5a:	7ff7f793          	andi	a5,a5,2047
  5e:	9f95                	subw	a5,a5,a3
  60:	c21c                	sw	a5,0(a2)
        if (buffer->num_produced >= MAX) {
  62:	461c                	lw	a5,8(a2)
  64:	fcf555e3          	bge	a0,a5,2e <producer+0x2e>
	    exit(0);
  68:	4501                	li	a0,0
  6a:	00000097          	auipc	ra,0x0
  6e:	380080e7          	jalr	896(ra) # 3ea <exit>

0000000000000072 <consumer>:
    }
}

void *consumer()
{
  72:	1141                	addi	sp,sp,-16
  74:	e406                	sd	ra,8(sp)
  76:	e022                	sd	s0,0(sp)
  78:	0800                	addi	s0,sp,16
    while(1) {
        if (buffer->num_consumed >= MAX) {
  7a:	00001597          	auipc	a1,0x1
  7e:	95e5b583          	ld	a1,-1698(a1) # 9d8 <buffer>
  82:	6789                	lui	a5,0x2
  84:	97ae                	add	a5,a5,a1
  86:	47d4                	lw	a3,12(a5)
  88:	7ff00793          	li	a5,2047
  8c:	04d7c363          	blt	a5,a3,d2 <consumer+0x60>
  90:	6709                	lui	a4,0x2
  92:	972e                	add	a4,a4,a1
  94:	435c                	lw	a5,4(a4)
  96:	4b10                	lw	a2,16(a4)
  98:	2685                	addiw	a3,a3,1
  9a:	6505                	lui	a0,0x1
  9c:	80150513          	addi	a0,a0,-2047 # 801 <free+0x1f>
	    exit(0);
	}
	buffer->total += buffer->buf[buffer->nextout++];
  a0:	00279713          	slli	a4,a5,0x2
  a4:	972e                	add	a4,a4,a1
  a6:	4318                	lw	a4,0(a4)
  a8:	9e39                	addw	a2,a2,a4
  aa:	2785                	addiw	a5,a5,1 # 2001 <__global_pointer$+0xe30>
	buffer->nextout %= BSIZE;
  ac:	41f7d71b          	sraiw	a4,a5,0x1f
  b0:	0157571b          	srliw	a4,a4,0x15
  b4:	9fb9                	addw	a5,a5,a4
  b6:	7ff7f793          	andi	a5,a5,2047
  ba:	9f99                	subw	a5,a5,a4
        if (buffer->num_consumed >= MAX) {
  bc:	2685                	addiw	a3,a3,1
  be:	fea691e3          	bne	a3,a0,a0 <consumer+0x2e>
  c2:	6709                	lui	a4,0x2
  c4:	95ba                	add	a1,a1,a4
  c6:	c990                	sw	a2,16(a1)
  c8:	c1dc                	sw	a5,4(a1)
  ca:	6785                	lui	a5,0x1
  cc:	80078793          	addi	a5,a5,-2048 # 800 <free+0x1e>
  d0:	c5dc                	sw	a5,12(a1)
	    exit(0);
  d2:	4501                	li	a0,0
  d4:	00000097          	auipc	ra,0x0
  d8:	316080e7          	jalr	790(ra) # 3ea <exit>

00000000000000dc <main>:
	buffer->num_consumed++;
    }
}

int main(int argc, char *argv[])
{
  dc:	1101                	addi	sp,sp,-32
  de:	ec06                	sd	ra,24(sp)
  e0:	e822                	sd	s0,16(sp)
  e2:	e426                	sd	s1,8(sp)
  e4:	1000                	addi	s0,sp,32
    buffer = (buffer_t *) mmap(NULL, sizeof(buffer_t),
  e6:	4781                	li	a5,0
  e8:	577d                	li	a4,-1
  ea:	02100693          	li	a3,33
  ee:	4619                	li	a2,6
  f0:	6489                	lui	s1,0x2
  f2:	01448593          	addi	a1,s1,20 # 2014 <__global_pointer$+0xe43>
  f6:	4501                	li	a0,0
  f8:	00000097          	auipc	ra,0x0
  fc:	3aa080e7          	jalr	938(ra) # 4a2 <mmap>
 100:	00001797          	auipc	a5,0x1
 104:	8ca7bc23          	sd	a0,-1832(a5) # 9d8 <buffer>
		               PROT_READ | PROT_WRITE,
			       MAP_ANONYMOUS | MAP_SHARED, -1, 0);
    buffer->nextin = 0;
 108:	9526                	add	a0,a0,s1
 10a:	00052023          	sw	zero,0(a0)
    buffer->nextout = 0;
 10e:	00052223          	sw	zero,4(a0)
    buffer->num_produced = 0;
 112:	00052423          	sw	zero,8(a0)
    buffer->num_consumed = 0;
 116:	00052623          	sw	zero,12(a0)
    buffer->total = 0;
 11a:	00052823          	sw	zero,16(a0)
    if (!fork())
 11e:	00000097          	auipc	ra,0x0
 122:	2c4080e7          	jalr	708(ra) # 3e2 <fork>
 126:	e509                	bnez	a0,130 <main+0x54>
        producer();
 128:	00000097          	auipc	ra,0x0
 12c:	ed8080e7          	jalr	-296(ra) # 0 <producer>
    else
	wait(0);
 130:	4501                	li	a0,0
 132:	00000097          	auipc	ra,0x0
 136:	2c0080e7          	jalr	704(ra) # 3f2 <wait>
    if (!fork())
 13a:	00000097          	auipc	ra,0x0
 13e:	2a8080e7          	jalr	680(ra) # 3e2 <fork>
 142:	e509                	bnez	a0,14c <main+0x70>
        consumer();
 144:	00000097          	auipc	ra,0x0
 148:	f2e080e7          	jalr	-210(ra) # 72 <consumer>
    else
	wait(0);
 14c:	4501                	li	a0,0
 14e:	00000097          	auipc	ra,0x0
 152:	2a4080e7          	jalr	676(ra) # 3f2 <wait>
    printf("total = %d\n", buffer->total);
 156:	00001797          	auipc	a5,0x1
 15a:	8827b783          	ld	a5,-1918(a5) # 9d8 <buffer>
 15e:	6709                	lui	a4,0x2
 160:	97ba                	add	a5,a5,a4
 162:	4b8c                	lw	a1,16(a5)
 164:	00000517          	auipc	a0,0x0
 168:	7ec50513          	addi	a0,a0,2028 # 950 <malloc+0xec>
 16c:	00000097          	auipc	ra,0x0
 170:	640080e7          	jalr	1600(ra) # 7ac <printf>
    exit(0);
 174:	4501                	li	a0,0
 176:	00000097          	auipc	ra,0x0
 17a:	274080e7          	jalr	628(ra) # 3ea <exit>

000000000000017e <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 17e:	1141                	addi	sp,sp,-16
 180:	e422                	sd	s0,8(sp)
 182:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 184:	87aa                	mv	a5,a0
 186:	0585                	addi	a1,a1,1
 188:	0785                	addi	a5,a5,1
 18a:	fff5c703          	lbu	a4,-1(a1)
 18e:	fee78fa3          	sb	a4,-1(a5)
 192:	fb75                	bnez	a4,186 <strcpy+0x8>
    ;
  return os;
}
 194:	6422                	ld	s0,8(sp)
 196:	0141                	addi	sp,sp,16
 198:	8082                	ret

000000000000019a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 19a:	1141                	addi	sp,sp,-16
 19c:	e422                	sd	s0,8(sp)
 19e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1a0:	00054783          	lbu	a5,0(a0)
 1a4:	cb91                	beqz	a5,1b8 <strcmp+0x1e>
 1a6:	0005c703          	lbu	a4,0(a1)
 1aa:	00f71763          	bne	a4,a5,1b8 <strcmp+0x1e>
    p++, q++;
 1ae:	0505                	addi	a0,a0,1
 1b0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1b2:	00054783          	lbu	a5,0(a0)
 1b6:	fbe5                	bnez	a5,1a6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1b8:	0005c503          	lbu	a0,0(a1)
}
 1bc:	40a7853b          	subw	a0,a5,a0
 1c0:	6422                	ld	s0,8(sp)
 1c2:	0141                	addi	sp,sp,16
 1c4:	8082                	ret

00000000000001c6 <strlen>:

uint
strlen(const char *s)
{
 1c6:	1141                	addi	sp,sp,-16
 1c8:	e422                	sd	s0,8(sp)
 1ca:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1cc:	00054783          	lbu	a5,0(a0)
 1d0:	cf91                	beqz	a5,1ec <strlen+0x26>
 1d2:	0505                	addi	a0,a0,1
 1d4:	87aa                	mv	a5,a0
 1d6:	4685                	li	a3,1
 1d8:	9e89                	subw	a3,a3,a0
 1da:	00f6853b          	addw	a0,a3,a5
 1de:	0785                	addi	a5,a5,1
 1e0:	fff7c703          	lbu	a4,-1(a5)
 1e4:	fb7d                	bnez	a4,1da <strlen+0x14>
    ;
  return n;
}
 1e6:	6422                	ld	s0,8(sp)
 1e8:	0141                	addi	sp,sp,16
 1ea:	8082                	ret
  for(n = 0; s[n]; n++)
 1ec:	4501                	li	a0,0
 1ee:	bfe5                	j	1e6 <strlen+0x20>

00000000000001f0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1f0:	1141                	addi	sp,sp,-16
 1f2:	e422                	sd	s0,8(sp)
 1f4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1f6:	ca19                	beqz	a2,20c <memset+0x1c>
 1f8:	87aa                	mv	a5,a0
 1fa:	1602                	slli	a2,a2,0x20
 1fc:	9201                	srli	a2,a2,0x20
 1fe:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 202:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 206:	0785                	addi	a5,a5,1
 208:	fee79de3          	bne	a5,a4,202 <memset+0x12>
  }
  return dst;
}
 20c:	6422                	ld	s0,8(sp)
 20e:	0141                	addi	sp,sp,16
 210:	8082                	ret

0000000000000212 <strchr>:

char*
strchr(const char *s, char c)
{
 212:	1141                	addi	sp,sp,-16
 214:	e422                	sd	s0,8(sp)
 216:	0800                	addi	s0,sp,16
  for(; *s; s++)
 218:	00054783          	lbu	a5,0(a0)
 21c:	cb99                	beqz	a5,232 <strchr+0x20>
    if(*s == c)
 21e:	00f58763          	beq	a1,a5,22c <strchr+0x1a>
  for(; *s; s++)
 222:	0505                	addi	a0,a0,1
 224:	00054783          	lbu	a5,0(a0)
 228:	fbfd                	bnez	a5,21e <strchr+0xc>
      return (char*)s;
  return 0;
 22a:	4501                	li	a0,0
}
 22c:	6422                	ld	s0,8(sp)
 22e:	0141                	addi	sp,sp,16
 230:	8082                	ret
  return 0;
 232:	4501                	li	a0,0
 234:	bfe5                	j	22c <strchr+0x1a>

0000000000000236 <gets>:

char*
gets(char *buf, int max)
{
 236:	711d                	addi	sp,sp,-96
 238:	ec86                	sd	ra,88(sp)
 23a:	e8a2                	sd	s0,80(sp)
 23c:	e4a6                	sd	s1,72(sp)
 23e:	e0ca                	sd	s2,64(sp)
 240:	fc4e                	sd	s3,56(sp)
 242:	f852                	sd	s4,48(sp)
 244:	f456                	sd	s5,40(sp)
 246:	f05a                	sd	s6,32(sp)
 248:	ec5e                	sd	s7,24(sp)
 24a:	1080                	addi	s0,sp,96
 24c:	8baa                	mv	s7,a0
 24e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 250:	892a                	mv	s2,a0
 252:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 254:	4aa9                	li	s5,10
 256:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 258:	89a6                	mv	s3,s1
 25a:	2485                	addiw	s1,s1,1
 25c:	0344d863          	bge	s1,s4,28c <gets+0x56>
    cc = read(0, &c, 1);
 260:	4605                	li	a2,1
 262:	faf40593          	addi	a1,s0,-81
 266:	4501                	li	a0,0
 268:	00000097          	auipc	ra,0x0
 26c:	19a080e7          	jalr	410(ra) # 402 <read>
    if(cc < 1)
 270:	00a05e63          	blez	a0,28c <gets+0x56>
    buf[i++] = c;
 274:	faf44783          	lbu	a5,-81(s0)
 278:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 27c:	01578763          	beq	a5,s5,28a <gets+0x54>
 280:	0905                	addi	s2,s2,1
 282:	fd679be3          	bne	a5,s6,258 <gets+0x22>
  for(i=0; i+1 < max; ){
 286:	89a6                	mv	s3,s1
 288:	a011                	j	28c <gets+0x56>
 28a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 28c:	99de                	add	s3,s3,s7
 28e:	00098023          	sb	zero,0(s3)
  return buf;
}
 292:	855e                	mv	a0,s7
 294:	60e6                	ld	ra,88(sp)
 296:	6446                	ld	s0,80(sp)
 298:	64a6                	ld	s1,72(sp)
 29a:	6906                	ld	s2,64(sp)
 29c:	79e2                	ld	s3,56(sp)
 29e:	7a42                	ld	s4,48(sp)
 2a0:	7aa2                	ld	s5,40(sp)
 2a2:	7b02                	ld	s6,32(sp)
 2a4:	6be2                	ld	s7,24(sp)
 2a6:	6125                	addi	sp,sp,96
 2a8:	8082                	ret

00000000000002aa <stat>:

int
stat(const char *n, struct stat *st)
{
 2aa:	1101                	addi	sp,sp,-32
 2ac:	ec06                	sd	ra,24(sp)
 2ae:	e822                	sd	s0,16(sp)
 2b0:	e426                	sd	s1,8(sp)
 2b2:	e04a                	sd	s2,0(sp)
 2b4:	1000                	addi	s0,sp,32
 2b6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2b8:	4581                	li	a1,0
 2ba:	00000097          	auipc	ra,0x0
 2be:	170080e7          	jalr	368(ra) # 42a <open>
  if(fd < 0)
 2c2:	02054563          	bltz	a0,2ec <stat+0x42>
 2c6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2c8:	85ca                	mv	a1,s2
 2ca:	00000097          	auipc	ra,0x0
 2ce:	178080e7          	jalr	376(ra) # 442 <fstat>
 2d2:	892a                	mv	s2,a0
  close(fd);
 2d4:	8526                	mv	a0,s1
 2d6:	00000097          	auipc	ra,0x0
 2da:	13c080e7          	jalr	316(ra) # 412 <close>
  return r;
}
 2de:	854a                	mv	a0,s2
 2e0:	60e2                	ld	ra,24(sp)
 2e2:	6442                	ld	s0,16(sp)
 2e4:	64a2                	ld	s1,8(sp)
 2e6:	6902                	ld	s2,0(sp)
 2e8:	6105                	addi	sp,sp,32
 2ea:	8082                	ret
    return -1;
 2ec:	597d                	li	s2,-1
 2ee:	bfc5                	j	2de <stat+0x34>

00000000000002f0 <atoi>:

int
atoi(const char *s)
{
 2f0:	1141                	addi	sp,sp,-16
 2f2:	e422                	sd	s0,8(sp)
 2f4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2f6:	00054683          	lbu	a3,0(a0)
 2fa:	fd06879b          	addiw	a5,a3,-48
 2fe:	0ff7f793          	zext.b	a5,a5
 302:	4625                	li	a2,9
 304:	02f66863          	bltu	a2,a5,334 <atoi+0x44>
 308:	872a                	mv	a4,a0
  n = 0;
 30a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 30c:	0705                	addi	a4,a4,1 # 2001 <__global_pointer$+0xe30>
 30e:	0025179b          	slliw	a5,a0,0x2
 312:	9fa9                	addw	a5,a5,a0
 314:	0017979b          	slliw	a5,a5,0x1
 318:	9fb5                	addw	a5,a5,a3
 31a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 31e:	00074683          	lbu	a3,0(a4)
 322:	fd06879b          	addiw	a5,a3,-48
 326:	0ff7f793          	zext.b	a5,a5
 32a:	fef671e3          	bgeu	a2,a5,30c <atoi+0x1c>
  return n;
}
 32e:	6422                	ld	s0,8(sp)
 330:	0141                	addi	sp,sp,16
 332:	8082                	ret
  n = 0;
 334:	4501                	li	a0,0
 336:	bfe5                	j	32e <atoi+0x3e>

0000000000000338 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 338:	1141                	addi	sp,sp,-16
 33a:	e422                	sd	s0,8(sp)
 33c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 33e:	02b57463          	bgeu	a0,a1,366 <memmove+0x2e>
    while(n-- > 0)
 342:	00c05f63          	blez	a2,360 <memmove+0x28>
 346:	1602                	slli	a2,a2,0x20
 348:	9201                	srli	a2,a2,0x20
 34a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 34e:	872a                	mv	a4,a0
      *dst++ = *src++;
 350:	0585                	addi	a1,a1,1
 352:	0705                	addi	a4,a4,1
 354:	fff5c683          	lbu	a3,-1(a1)
 358:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 35c:	fee79ae3          	bne	a5,a4,350 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 360:	6422                	ld	s0,8(sp)
 362:	0141                	addi	sp,sp,16
 364:	8082                	ret
    dst += n;
 366:	00c50733          	add	a4,a0,a2
    src += n;
 36a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 36c:	fec05ae3          	blez	a2,360 <memmove+0x28>
 370:	fff6079b          	addiw	a5,a2,-1
 374:	1782                	slli	a5,a5,0x20
 376:	9381                	srli	a5,a5,0x20
 378:	fff7c793          	not	a5,a5
 37c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 37e:	15fd                	addi	a1,a1,-1
 380:	177d                	addi	a4,a4,-1
 382:	0005c683          	lbu	a3,0(a1)
 386:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 38a:	fee79ae3          	bne	a5,a4,37e <memmove+0x46>
 38e:	bfc9                	j	360 <memmove+0x28>

0000000000000390 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 390:	1141                	addi	sp,sp,-16
 392:	e422                	sd	s0,8(sp)
 394:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 396:	ca05                	beqz	a2,3c6 <memcmp+0x36>
 398:	fff6069b          	addiw	a3,a2,-1
 39c:	1682                	slli	a3,a3,0x20
 39e:	9281                	srli	a3,a3,0x20
 3a0:	0685                	addi	a3,a3,1
 3a2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3a4:	00054783          	lbu	a5,0(a0)
 3a8:	0005c703          	lbu	a4,0(a1)
 3ac:	00e79863          	bne	a5,a4,3bc <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3b0:	0505                	addi	a0,a0,1
    p2++;
 3b2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3b4:	fed518e3          	bne	a0,a3,3a4 <memcmp+0x14>
  }
  return 0;
 3b8:	4501                	li	a0,0
 3ba:	a019                	j	3c0 <memcmp+0x30>
      return *p1 - *p2;
 3bc:	40e7853b          	subw	a0,a5,a4
}
 3c0:	6422                	ld	s0,8(sp)
 3c2:	0141                	addi	sp,sp,16
 3c4:	8082                	ret
  return 0;
 3c6:	4501                	li	a0,0
 3c8:	bfe5                	j	3c0 <memcmp+0x30>

00000000000003ca <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3ca:	1141                	addi	sp,sp,-16
 3cc:	e406                	sd	ra,8(sp)
 3ce:	e022                	sd	s0,0(sp)
 3d0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3d2:	00000097          	auipc	ra,0x0
 3d6:	f66080e7          	jalr	-154(ra) # 338 <memmove>
}
 3da:	60a2                	ld	ra,8(sp)
 3dc:	6402                	ld	s0,0(sp)
 3de:	0141                	addi	sp,sp,16
 3e0:	8082                	ret

00000000000003e2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3e2:	4885                	li	a7,1
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <exit>:
.global exit
exit:
 li a7, SYS_exit
 3ea:	4889                	li	a7,2
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3f2:	488d                	li	a7,3
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3fa:	4891                	li	a7,4
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <read>:
.global read
read:
 li a7, SYS_read
 402:	4895                	li	a7,5
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <write>:
.global write
write:
 li a7, SYS_write
 40a:	48c1                	li	a7,16
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <close>:
.global close
close:
 li a7, SYS_close
 412:	48d5                	li	a7,21
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <kill>:
.global kill
kill:
 li a7, SYS_kill
 41a:	4899                	li	a7,6
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <exec>:
.global exec
exec:
 li a7, SYS_exec
 422:	489d                	li	a7,7
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <open>:
.global open
open:
 li a7, SYS_open
 42a:	48bd                	li	a7,15
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 432:	48c5                	li	a7,17
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 43a:	48c9                	li	a7,18
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 442:	48a1                	li	a7,8
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <link>:
.global link
link:
 li a7, SYS_link
 44a:	48cd                	li	a7,19
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 452:	48d1                	li	a7,20
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 45a:	48a5                	li	a7,9
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <dup>:
.global dup
dup:
 li a7, SYS_dup
 462:	48a9                	li	a7,10
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 46a:	48ad                	li	a7,11
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 472:	48b1                	li	a7,12
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 47a:	48b5                	li	a7,13
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 482:	48b9                	li	a7,14
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <getprocs>:
.global getprocs
getprocs:
 li a7, SYS_getprocs
 48a:	48d9                	li	a7,22
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <wait2>:
.global wait2
wait2:
 li a7, SYS_wait2
 492:	48dd                	li	a7,23
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <freepmem>:
.global freepmem
freepmem:
 li a7, SYS_freepmem
 49a:	48e1                	li	a7,24
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 4a2:	48e5                	li	a7,25
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 4aa:	48e9                	li	a7,26
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <sem_init>:
.global sem_init
sem_init:
 li a7, SYS_sem_init
 4b2:	48ed                	li	a7,27
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <sem_destroy>:
.global sem_destroy
sem_destroy:
 li a7, SYS_sem_destroy
 4ba:	48f1                	li	a7,28
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <sem_wait>:
.global sem_wait
sem_wait:
 li a7, SYS_sem_wait
 4c2:	48f5                	li	a7,29
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <sem_post>:
.global sem_post
sem_post:
 li a7, SYS_sem_post
 4ca:	48f9                	li	a7,30
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4d2:	1101                	addi	sp,sp,-32
 4d4:	ec06                	sd	ra,24(sp)
 4d6:	e822                	sd	s0,16(sp)
 4d8:	1000                	addi	s0,sp,32
 4da:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4de:	4605                	li	a2,1
 4e0:	fef40593          	addi	a1,s0,-17
 4e4:	00000097          	auipc	ra,0x0
 4e8:	f26080e7          	jalr	-218(ra) # 40a <write>
}
 4ec:	60e2                	ld	ra,24(sp)
 4ee:	6442                	ld	s0,16(sp)
 4f0:	6105                	addi	sp,sp,32
 4f2:	8082                	ret

00000000000004f4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4f4:	7139                	addi	sp,sp,-64
 4f6:	fc06                	sd	ra,56(sp)
 4f8:	f822                	sd	s0,48(sp)
 4fa:	f426                	sd	s1,40(sp)
 4fc:	f04a                	sd	s2,32(sp)
 4fe:	ec4e                	sd	s3,24(sp)
 500:	0080                	addi	s0,sp,64
 502:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 504:	c299                	beqz	a3,50a <printint+0x16>
 506:	0805c963          	bltz	a1,598 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 50a:	2581                	sext.w	a1,a1
  neg = 0;
 50c:	4881                	li	a7,0
 50e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 512:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 514:	2601                	sext.w	a2,a2
 516:	00000517          	auipc	a0,0x0
 51a:	4aa50513          	addi	a0,a0,1194 # 9c0 <digits>
 51e:	883a                	mv	a6,a4
 520:	2705                	addiw	a4,a4,1
 522:	02c5f7bb          	remuw	a5,a1,a2
 526:	1782                	slli	a5,a5,0x20
 528:	9381                	srli	a5,a5,0x20
 52a:	97aa                	add	a5,a5,a0
 52c:	0007c783          	lbu	a5,0(a5)
 530:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 534:	0005879b          	sext.w	a5,a1
 538:	02c5d5bb          	divuw	a1,a1,a2
 53c:	0685                	addi	a3,a3,1
 53e:	fec7f0e3          	bgeu	a5,a2,51e <printint+0x2a>
  if(neg)
 542:	00088c63          	beqz	a7,55a <printint+0x66>
    buf[i++] = '-';
 546:	fd070793          	addi	a5,a4,-48
 54a:	00878733          	add	a4,a5,s0
 54e:	02d00793          	li	a5,45
 552:	fef70823          	sb	a5,-16(a4)
 556:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 55a:	02e05863          	blez	a4,58a <printint+0x96>
 55e:	fc040793          	addi	a5,s0,-64
 562:	00e78933          	add	s2,a5,a4
 566:	fff78993          	addi	s3,a5,-1
 56a:	99ba                	add	s3,s3,a4
 56c:	377d                	addiw	a4,a4,-1
 56e:	1702                	slli	a4,a4,0x20
 570:	9301                	srli	a4,a4,0x20
 572:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 576:	fff94583          	lbu	a1,-1(s2)
 57a:	8526                	mv	a0,s1
 57c:	00000097          	auipc	ra,0x0
 580:	f56080e7          	jalr	-170(ra) # 4d2 <putc>
  while(--i >= 0)
 584:	197d                	addi	s2,s2,-1
 586:	ff3918e3          	bne	s2,s3,576 <printint+0x82>
}
 58a:	70e2                	ld	ra,56(sp)
 58c:	7442                	ld	s0,48(sp)
 58e:	74a2                	ld	s1,40(sp)
 590:	7902                	ld	s2,32(sp)
 592:	69e2                	ld	s3,24(sp)
 594:	6121                	addi	sp,sp,64
 596:	8082                	ret
    x = -xx;
 598:	40b005bb          	negw	a1,a1
    neg = 1;
 59c:	4885                	li	a7,1
    x = -xx;
 59e:	bf85                	j	50e <printint+0x1a>

00000000000005a0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5a0:	7119                	addi	sp,sp,-128
 5a2:	fc86                	sd	ra,120(sp)
 5a4:	f8a2                	sd	s0,112(sp)
 5a6:	f4a6                	sd	s1,104(sp)
 5a8:	f0ca                	sd	s2,96(sp)
 5aa:	ecce                	sd	s3,88(sp)
 5ac:	e8d2                	sd	s4,80(sp)
 5ae:	e4d6                	sd	s5,72(sp)
 5b0:	e0da                	sd	s6,64(sp)
 5b2:	fc5e                	sd	s7,56(sp)
 5b4:	f862                	sd	s8,48(sp)
 5b6:	f466                	sd	s9,40(sp)
 5b8:	f06a                	sd	s10,32(sp)
 5ba:	ec6e                	sd	s11,24(sp)
 5bc:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5be:	0005c903          	lbu	s2,0(a1)
 5c2:	18090f63          	beqz	s2,760 <vprintf+0x1c0>
 5c6:	8aaa                	mv	s5,a0
 5c8:	8b32                	mv	s6,a2
 5ca:	00158493          	addi	s1,a1,1
  state = 0;
 5ce:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5d0:	02500a13          	li	s4,37
 5d4:	4c55                	li	s8,21
 5d6:	00000c97          	auipc	s9,0x0
 5da:	392c8c93          	addi	s9,s9,914 # 968 <malloc+0x104>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5de:	02800d93          	li	s11,40
  putc(fd, 'x');
 5e2:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5e4:	00000b97          	auipc	s7,0x0
 5e8:	3dcb8b93          	addi	s7,s7,988 # 9c0 <digits>
 5ec:	a839                	j	60a <vprintf+0x6a>
        putc(fd, c);
 5ee:	85ca                	mv	a1,s2
 5f0:	8556                	mv	a0,s5
 5f2:	00000097          	auipc	ra,0x0
 5f6:	ee0080e7          	jalr	-288(ra) # 4d2 <putc>
 5fa:	a019                	j	600 <vprintf+0x60>
    } else if(state == '%'){
 5fc:	01498d63          	beq	s3,s4,616 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 600:	0485                	addi	s1,s1,1
 602:	fff4c903          	lbu	s2,-1(s1)
 606:	14090d63          	beqz	s2,760 <vprintf+0x1c0>
    if(state == 0){
 60a:	fe0999e3          	bnez	s3,5fc <vprintf+0x5c>
      if(c == '%'){
 60e:	ff4910e3          	bne	s2,s4,5ee <vprintf+0x4e>
        state = '%';
 612:	89d2                	mv	s3,s4
 614:	b7f5                	j	600 <vprintf+0x60>
      if(c == 'd'){
 616:	11490c63          	beq	s2,s4,72e <vprintf+0x18e>
 61a:	f9d9079b          	addiw	a5,s2,-99
 61e:	0ff7f793          	zext.b	a5,a5
 622:	10fc6e63          	bltu	s8,a5,73e <vprintf+0x19e>
 626:	f9d9079b          	addiw	a5,s2,-99
 62a:	0ff7f713          	zext.b	a4,a5
 62e:	10ec6863          	bltu	s8,a4,73e <vprintf+0x19e>
 632:	00271793          	slli	a5,a4,0x2
 636:	97e6                	add	a5,a5,s9
 638:	439c                	lw	a5,0(a5)
 63a:	97e6                	add	a5,a5,s9
 63c:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 63e:	008b0913          	addi	s2,s6,8
 642:	4685                	li	a3,1
 644:	4629                	li	a2,10
 646:	000b2583          	lw	a1,0(s6)
 64a:	8556                	mv	a0,s5
 64c:	00000097          	auipc	ra,0x0
 650:	ea8080e7          	jalr	-344(ra) # 4f4 <printint>
 654:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 656:	4981                	li	s3,0
 658:	b765                	j	600 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 65a:	008b0913          	addi	s2,s6,8
 65e:	4681                	li	a3,0
 660:	4629                	li	a2,10
 662:	000b2583          	lw	a1,0(s6)
 666:	8556                	mv	a0,s5
 668:	00000097          	auipc	ra,0x0
 66c:	e8c080e7          	jalr	-372(ra) # 4f4 <printint>
 670:	8b4a                	mv	s6,s2
      state = 0;
 672:	4981                	li	s3,0
 674:	b771                	j	600 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 676:	008b0913          	addi	s2,s6,8
 67a:	4681                	li	a3,0
 67c:	866a                	mv	a2,s10
 67e:	000b2583          	lw	a1,0(s6)
 682:	8556                	mv	a0,s5
 684:	00000097          	auipc	ra,0x0
 688:	e70080e7          	jalr	-400(ra) # 4f4 <printint>
 68c:	8b4a                	mv	s6,s2
      state = 0;
 68e:	4981                	li	s3,0
 690:	bf85                	j	600 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 692:	008b0793          	addi	a5,s6,8
 696:	f8f43423          	sd	a5,-120(s0)
 69a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 69e:	03000593          	li	a1,48
 6a2:	8556                	mv	a0,s5
 6a4:	00000097          	auipc	ra,0x0
 6a8:	e2e080e7          	jalr	-466(ra) # 4d2 <putc>
  putc(fd, 'x');
 6ac:	07800593          	li	a1,120
 6b0:	8556                	mv	a0,s5
 6b2:	00000097          	auipc	ra,0x0
 6b6:	e20080e7          	jalr	-480(ra) # 4d2 <putc>
 6ba:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6bc:	03c9d793          	srli	a5,s3,0x3c
 6c0:	97de                	add	a5,a5,s7
 6c2:	0007c583          	lbu	a1,0(a5)
 6c6:	8556                	mv	a0,s5
 6c8:	00000097          	auipc	ra,0x0
 6cc:	e0a080e7          	jalr	-502(ra) # 4d2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6d0:	0992                	slli	s3,s3,0x4
 6d2:	397d                	addiw	s2,s2,-1
 6d4:	fe0914e3          	bnez	s2,6bc <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 6d8:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6dc:	4981                	li	s3,0
 6de:	b70d                	j	600 <vprintf+0x60>
        s = va_arg(ap, char*);
 6e0:	008b0913          	addi	s2,s6,8
 6e4:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 6e8:	02098163          	beqz	s3,70a <vprintf+0x16a>
        while(*s != 0){
 6ec:	0009c583          	lbu	a1,0(s3)
 6f0:	c5ad                	beqz	a1,75a <vprintf+0x1ba>
          putc(fd, *s);
 6f2:	8556                	mv	a0,s5
 6f4:	00000097          	auipc	ra,0x0
 6f8:	dde080e7          	jalr	-546(ra) # 4d2 <putc>
          s++;
 6fc:	0985                	addi	s3,s3,1
        while(*s != 0){
 6fe:	0009c583          	lbu	a1,0(s3)
 702:	f9e5                	bnez	a1,6f2 <vprintf+0x152>
        s = va_arg(ap, char*);
 704:	8b4a                	mv	s6,s2
      state = 0;
 706:	4981                	li	s3,0
 708:	bde5                	j	600 <vprintf+0x60>
          s = "(null)";
 70a:	00000997          	auipc	s3,0x0
 70e:	25698993          	addi	s3,s3,598 # 960 <malloc+0xfc>
        while(*s != 0){
 712:	85ee                	mv	a1,s11
 714:	bff9                	j	6f2 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 716:	008b0913          	addi	s2,s6,8
 71a:	000b4583          	lbu	a1,0(s6)
 71e:	8556                	mv	a0,s5
 720:	00000097          	auipc	ra,0x0
 724:	db2080e7          	jalr	-590(ra) # 4d2 <putc>
 728:	8b4a                	mv	s6,s2
      state = 0;
 72a:	4981                	li	s3,0
 72c:	bdd1                	j	600 <vprintf+0x60>
        putc(fd, c);
 72e:	85d2                	mv	a1,s4
 730:	8556                	mv	a0,s5
 732:	00000097          	auipc	ra,0x0
 736:	da0080e7          	jalr	-608(ra) # 4d2 <putc>
      state = 0;
 73a:	4981                	li	s3,0
 73c:	b5d1                	j	600 <vprintf+0x60>
        putc(fd, '%');
 73e:	85d2                	mv	a1,s4
 740:	8556                	mv	a0,s5
 742:	00000097          	auipc	ra,0x0
 746:	d90080e7          	jalr	-624(ra) # 4d2 <putc>
        putc(fd, c);
 74a:	85ca                	mv	a1,s2
 74c:	8556                	mv	a0,s5
 74e:	00000097          	auipc	ra,0x0
 752:	d84080e7          	jalr	-636(ra) # 4d2 <putc>
      state = 0;
 756:	4981                	li	s3,0
 758:	b565                	j	600 <vprintf+0x60>
        s = va_arg(ap, char*);
 75a:	8b4a                	mv	s6,s2
      state = 0;
 75c:	4981                	li	s3,0
 75e:	b54d                	j	600 <vprintf+0x60>
    }
  }
}
 760:	70e6                	ld	ra,120(sp)
 762:	7446                	ld	s0,112(sp)
 764:	74a6                	ld	s1,104(sp)
 766:	7906                	ld	s2,96(sp)
 768:	69e6                	ld	s3,88(sp)
 76a:	6a46                	ld	s4,80(sp)
 76c:	6aa6                	ld	s5,72(sp)
 76e:	6b06                	ld	s6,64(sp)
 770:	7be2                	ld	s7,56(sp)
 772:	7c42                	ld	s8,48(sp)
 774:	7ca2                	ld	s9,40(sp)
 776:	7d02                	ld	s10,32(sp)
 778:	6de2                	ld	s11,24(sp)
 77a:	6109                	addi	sp,sp,128
 77c:	8082                	ret

000000000000077e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 77e:	715d                	addi	sp,sp,-80
 780:	ec06                	sd	ra,24(sp)
 782:	e822                	sd	s0,16(sp)
 784:	1000                	addi	s0,sp,32
 786:	e010                	sd	a2,0(s0)
 788:	e414                	sd	a3,8(s0)
 78a:	e818                	sd	a4,16(s0)
 78c:	ec1c                	sd	a5,24(s0)
 78e:	03043023          	sd	a6,32(s0)
 792:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 796:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 79a:	8622                	mv	a2,s0
 79c:	00000097          	auipc	ra,0x0
 7a0:	e04080e7          	jalr	-508(ra) # 5a0 <vprintf>
}
 7a4:	60e2                	ld	ra,24(sp)
 7a6:	6442                	ld	s0,16(sp)
 7a8:	6161                	addi	sp,sp,80
 7aa:	8082                	ret

00000000000007ac <printf>:

void
printf(const char *fmt, ...)
{
 7ac:	711d                	addi	sp,sp,-96
 7ae:	ec06                	sd	ra,24(sp)
 7b0:	e822                	sd	s0,16(sp)
 7b2:	1000                	addi	s0,sp,32
 7b4:	e40c                	sd	a1,8(s0)
 7b6:	e810                	sd	a2,16(s0)
 7b8:	ec14                	sd	a3,24(s0)
 7ba:	f018                	sd	a4,32(s0)
 7bc:	f41c                	sd	a5,40(s0)
 7be:	03043823          	sd	a6,48(s0)
 7c2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7c6:	00840613          	addi	a2,s0,8
 7ca:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7ce:	85aa                	mv	a1,a0
 7d0:	4505                	li	a0,1
 7d2:	00000097          	auipc	ra,0x0
 7d6:	dce080e7          	jalr	-562(ra) # 5a0 <vprintf>
}
 7da:	60e2                	ld	ra,24(sp)
 7dc:	6442                	ld	s0,16(sp)
 7de:	6125                	addi	sp,sp,96
 7e0:	8082                	ret

00000000000007e2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7e2:	1141                	addi	sp,sp,-16
 7e4:	e422                	sd	s0,8(sp)
 7e6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7e8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ec:	00000797          	auipc	a5,0x0
 7f0:	1f47b783          	ld	a5,500(a5) # 9e0 <freep>
 7f4:	a02d                	j	81e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7f6:	4618                	lw	a4,8(a2)
 7f8:	9f2d                	addw	a4,a4,a1
 7fa:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7fe:	6398                	ld	a4,0(a5)
 800:	6310                	ld	a2,0(a4)
 802:	a83d                	j	840 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 804:	ff852703          	lw	a4,-8(a0)
 808:	9f31                	addw	a4,a4,a2
 80a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 80c:	ff053683          	ld	a3,-16(a0)
 810:	a091                	j	854 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 812:	6398                	ld	a4,0(a5)
 814:	00e7e463          	bltu	a5,a4,81c <free+0x3a>
 818:	00e6ea63          	bltu	a3,a4,82c <free+0x4a>
{
 81c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 81e:	fed7fae3          	bgeu	a5,a3,812 <free+0x30>
 822:	6398                	ld	a4,0(a5)
 824:	00e6e463          	bltu	a3,a4,82c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 828:	fee7eae3          	bltu	a5,a4,81c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 82c:	ff852583          	lw	a1,-8(a0)
 830:	6390                	ld	a2,0(a5)
 832:	02059813          	slli	a6,a1,0x20
 836:	01c85713          	srli	a4,a6,0x1c
 83a:	9736                	add	a4,a4,a3
 83c:	fae60de3          	beq	a2,a4,7f6 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 840:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 844:	4790                	lw	a2,8(a5)
 846:	02061593          	slli	a1,a2,0x20
 84a:	01c5d713          	srli	a4,a1,0x1c
 84e:	973e                	add	a4,a4,a5
 850:	fae68ae3          	beq	a3,a4,804 <free+0x22>
    p->s.ptr = bp->s.ptr;
 854:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 856:	00000717          	auipc	a4,0x0
 85a:	18f73523          	sd	a5,394(a4) # 9e0 <freep>
}
 85e:	6422                	ld	s0,8(sp)
 860:	0141                	addi	sp,sp,16
 862:	8082                	ret

0000000000000864 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 864:	7139                	addi	sp,sp,-64
 866:	fc06                	sd	ra,56(sp)
 868:	f822                	sd	s0,48(sp)
 86a:	f426                	sd	s1,40(sp)
 86c:	f04a                	sd	s2,32(sp)
 86e:	ec4e                	sd	s3,24(sp)
 870:	e852                	sd	s4,16(sp)
 872:	e456                	sd	s5,8(sp)
 874:	e05a                	sd	s6,0(sp)
 876:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 878:	02051493          	slli	s1,a0,0x20
 87c:	9081                	srli	s1,s1,0x20
 87e:	04bd                	addi	s1,s1,15
 880:	8091                	srli	s1,s1,0x4
 882:	0014899b          	addiw	s3,s1,1
 886:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 888:	00000517          	auipc	a0,0x0
 88c:	15853503          	ld	a0,344(a0) # 9e0 <freep>
 890:	c515                	beqz	a0,8bc <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 892:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 894:	4798                	lw	a4,8(a5)
 896:	02977f63          	bgeu	a4,s1,8d4 <malloc+0x70>
 89a:	8a4e                	mv	s4,s3
 89c:	0009871b          	sext.w	a4,s3
 8a0:	6685                	lui	a3,0x1
 8a2:	00d77363          	bgeu	a4,a3,8a8 <malloc+0x44>
 8a6:	6a05                	lui	s4,0x1
 8a8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8ac:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8b0:	00000917          	auipc	s2,0x0
 8b4:	13090913          	addi	s2,s2,304 # 9e0 <freep>
  if(p == (char*)-1)
 8b8:	5afd                	li	s5,-1
 8ba:	a895                	j	92e <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 8bc:	00000797          	auipc	a5,0x0
 8c0:	12c78793          	addi	a5,a5,300 # 9e8 <base>
 8c4:	00000717          	auipc	a4,0x0
 8c8:	10f73e23          	sd	a5,284(a4) # 9e0 <freep>
 8cc:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8ce:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8d2:	b7e1                	j	89a <malloc+0x36>
      if(p->s.size == nunits)
 8d4:	02e48c63          	beq	s1,a4,90c <malloc+0xa8>
        p->s.size -= nunits;
 8d8:	4137073b          	subw	a4,a4,s3
 8dc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8de:	02071693          	slli	a3,a4,0x20
 8e2:	01c6d713          	srli	a4,a3,0x1c
 8e6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8e8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8ec:	00000717          	auipc	a4,0x0
 8f0:	0ea73a23          	sd	a0,244(a4) # 9e0 <freep>
      return (void*)(p + 1);
 8f4:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8f8:	70e2                	ld	ra,56(sp)
 8fa:	7442                	ld	s0,48(sp)
 8fc:	74a2                	ld	s1,40(sp)
 8fe:	7902                	ld	s2,32(sp)
 900:	69e2                	ld	s3,24(sp)
 902:	6a42                	ld	s4,16(sp)
 904:	6aa2                	ld	s5,8(sp)
 906:	6b02                	ld	s6,0(sp)
 908:	6121                	addi	sp,sp,64
 90a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 90c:	6398                	ld	a4,0(a5)
 90e:	e118                	sd	a4,0(a0)
 910:	bff1                	j	8ec <malloc+0x88>
  hp->s.size = nu;
 912:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 916:	0541                	addi	a0,a0,16
 918:	00000097          	auipc	ra,0x0
 91c:	eca080e7          	jalr	-310(ra) # 7e2 <free>
  return freep;
 920:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 924:	d971                	beqz	a0,8f8 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 926:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 928:	4798                	lw	a4,8(a5)
 92a:	fa9775e3          	bgeu	a4,s1,8d4 <malloc+0x70>
    if(p == freep)
 92e:	00093703          	ld	a4,0(s2)
 932:	853e                	mv	a0,a5
 934:	fef719e3          	bne	a4,a5,926 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 938:	8552                	mv	a0,s4
 93a:	00000097          	auipc	ra,0x0
 93e:	b38080e7          	jalr	-1224(ra) # 472 <sbrk>
  if(p == (char*)-1)
 942:	fd5518e3          	bne	a0,s5,912 <malloc+0xae>
        return 0;
 946:	4501                	li	a0,0
 948:	bf45                	j	8f8 <malloc+0x94>
