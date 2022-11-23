
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	93013103          	ld	sp,-1744(sp) # 80009930 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	0000a717          	auipc	a4,0xa
    80000054:	ff070713          	addi	a4,a4,-16 # 8000a040 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00007797          	auipc	a5,0x7
    80000066:	d1e78793          	addi	a5,a5,-738 # 80006d80 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffc67ff>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	e0e78793          	addi	a5,a5,-498 # 80000eba <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	482080e7          	jalr	1154(ra) # 800025ac <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	77e080e7          	jalr	1918(ra) # 800008b8 <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00012517          	auipc	a0,0x12
    8000018e:	ff650513          	addi	a0,a0,-10 # 80012180 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a86080e7          	jalr	-1402(ra) # 80000c18 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00012497          	auipc	s1,0x12
    8000019e:	fe648493          	addi	s1,s1,-26 # 80012180 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00012917          	auipc	s2,0x12
    800001a6:	07690913          	addi	s2,s2,118 # 80012218 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ae:	4ca9                	li	s9,10
  while(n > 0){
    800001b0:	07305863          	blez	s3,80000220 <consoleread+0xbc>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71463          	bne	a4,a5,800001e4 <consoleread+0x80>
      if(myproc()->killed){
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	bfc080e7          	jalr	-1028(ra) # 80001dbc <myproc>
    800001c8:	551c                	lw	a5,40(a0)
    800001ca:	e7b5                	bnez	a5,80000236 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001cc:	85a6                	mv	a1,s1
    800001ce:	854a                	mv	a0,s2
    800001d0:	00002097          	auipc	ra,0x2
    800001d4:	054080e7          	jalr	84(ra) # 80002224 <sleep>
    while(cons.r == cons.w){
    800001d8:	0984a783          	lw	a5,152(s1)
    800001dc:	09c4a703          	lw	a4,156(s1)
    800001e0:	fef700e3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001e4:	0017871b          	addiw	a4,a5,1
    800001e8:	08e4ac23          	sw	a4,152(s1)
    800001ec:	07f7f713          	andi	a4,a5,127
    800001f0:	9726                	add	a4,a4,s1
    800001f2:	01874703          	lbu	a4,24(a4)
    800001f6:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800001fa:	077d0563          	beq	s10,s7,80000264 <consoleread+0x100>
    cbuf = c;
    800001fe:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000202:	4685                	li	a3,1
    80000204:	f9f40613          	addi	a2,s0,-97
    80000208:	85d2                	mv	a1,s4
    8000020a:	8556                	mv	a0,s5
    8000020c:	00002097          	auipc	ra,0x2
    80000210:	34a080e7          	jalr	842(ra) # 80002556 <either_copyout>
    80000214:	01850663          	beq	a0,s8,80000220 <consoleread+0xbc>
    dst++;
    80000218:	0a05                	addi	s4,s4,1
    --n;
    8000021a:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    8000021c:	f99d1ae3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000220:	00012517          	auipc	a0,0x12
    80000224:	f6050513          	addi	a0,a0,-160 # 80012180 <cons>
    80000228:	00001097          	auipc	ra,0x1
    8000022c:	aa4080e7          	jalr	-1372(ra) # 80000ccc <release>

  return target - n;
    80000230:	413b053b          	subw	a0,s6,s3
    80000234:	a811                	j	80000248 <consoleread+0xe4>
        release(&cons.lock);
    80000236:	00012517          	auipc	a0,0x12
    8000023a:	f4a50513          	addi	a0,a0,-182 # 80012180 <cons>
    8000023e:	00001097          	auipc	ra,0x1
    80000242:	a8e080e7          	jalr	-1394(ra) # 80000ccc <release>
        return -1;
    80000246:	557d                	li	a0,-1
}
    80000248:	70a6                	ld	ra,104(sp)
    8000024a:	7406                	ld	s0,96(sp)
    8000024c:	64e6                	ld	s1,88(sp)
    8000024e:	6946                	ld	s2,80(sp)
    80000250:	69a6                	ld	s3,72(sp)
    80000252:	6a06                	ld	s4,64(sp)
    80000254:	7ae2                	ld	s5,56(sp)
    80000256:	7b42                	ld	s6,48(sp)
    80000258:	7ba2                	ld	s7,40(sp)
    8000025a:	7c02                	ld	s8,32(sp)
    8000025c:	6ce2                	ld	s9,24(sp)
    8000025e:	6d42                	ld	s10,16(sp)
    80000260:	6165                	addi	sp,sp,112
    80000262:	8082                	ret
      if(n < target){
    80000264:	0009871b          	sext.w	a4,s3
    80000268:	fb677ce3          	bgeu	a4,s6,80000220 <consoleread+0xbc>
        cons.r--;
    8000026c:	00012717          	auipc	a4,0x12
    80000270:	faf72623          	sw	a5,-84(a4) # 80012218 <cons+0x98>
    80000274:	b775                	j	80000220 <consoleread+0xbc>

0000000080000276 <consputc>:
{
    80000276:	1141                	addi	sp,sp,-16
    80000278:	e406                	sd	ra,8(sp)
    8000027a:	e022                	sd	s0,0(sp)
    8000027c:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000027e:	10000793          	li	a5,256
    80000282:	00f50a63          	beq	a0,a5,80000296 <consputc+0x20>
    uartputc_sync(c);
    80000286:	00000097          	auipc	ra,0x0
    8000028a:	560080e7          	jalr	1376(ra) # 800007e6 <uartputc_sync>
}
    8000028e:	60a2                	ld	ra,8(sp)
    80000290:	6402                	ld	s0,0(sp)
    80000292:	0141                	addi	sp,sp,16
    80000294:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000296:	4521                	li	a0,8
    80000298:	00000097          	auipc	ra,0x0
    8000029c:	54e080e7          	jalr	1358(ra) # 800007e6 <uartputc_sync>
    800002a0:	02000513          	li	a0,32
    800002a4:	00000097          	auipc	ra,0x0
    800002a8:	542080e7          	jalr	1346(ra) # 800007e6 <uartputc_sync>
    800002ac:	4521                	li	a0,8
    800002ae:	00000097          	auipc	ra,0x0
    800002b2:	538080e7          	jalr	1336(ra) # 800007e6 <uartputc_sync>
    800002b6:	bfe1                	j	8000028e <consputc+0x18>

00000000800002b8 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002b8:	1101                	addi	sp,sp,-32
    800002ba:	ec06                	sd	ra,24(sp)
    800002bc:	e822                	sd	s0,16(sp)
    800002be:	e426                	sd	s1,8(sp)
    800002c0:	e04a                	sd	s2,0(sp)
    800002c2:	1000                	addi	s0,sp,32
    800002c4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c6:	00012517          	auipc	a0,0x12
    800002ca:	eba50513          	addi	a0,a0,-326 # 80012180 <cons>
    800002ce:	00001097          	auipc	ra,0x1
    800002d2:	94a080e7          	jalr	-1718(ra) # 80000c18 <acquire>

  switch(c){
    800002d6:	47d5                	li	a5,21
    800002d8:	0af48663          	beq	s1,a5,80000384 <consoleintr+0xcc>
    800002dc:	0297ca63          	blt	a5,s1,80000310 <consoleintr+0x58>
    800002e0:	47a1                	li	a5,8
    800002e2:	0ef48763          	beq	s1,a5,800003d0 <consoleintr+0x118>
    800002e6:	47c1                	li	a5,16
    800002e8:	10f49a63          	bne	s1,a5,800003fc <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002ec:	00002097          	auipc	ra,0x2
    800002f0:	316080e7          	jalr	790(ra) # 80002602 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f4:	00012517          	auipc	a0,0x12
    800002f8:	e8c50513          	addi	a0,a0,-372 # 80012180 <cons>
    800002fc:	00001097          	auipc	ra,0x1
    80000300:	9d0080e7          	jalr	-1584(ra) # 80000ccc <release>
}
    80000304:	60e2                	ld	ra,24(sp)
    80000306:	6442                	ld	s0,16(sp)
    80000308:	64a2                	ld	s1,8(sp)
    8000030a:	6902                	ld	s2,0(sp)
    8000030c:	6105                	addi	sp,sp,32
    8000030e:	8082                	ret
  switch(c){
    80000310:	07f00793          	li	a5,127
    80000314:	0af48e63          	beq	s1,a5,800003d0 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000318:	00012717          	auipc	a4,0x12
    8000031c:	e6870713          	addi	a4,a4,-408 # 80012180 <cons>
    80000320:	0a072783          	lw	a5,160(a4)
    80000324:	09872703          	lw	a4,152(a4)
    80000328:	9f99                	subw	a5,a5,a4
    8000032a:	07f00713          	li	a4,127
    8000032e:	fcf763e3          	bltu	a4,a5,800002f4 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000332:	47b5                	li	a5,13
    80000334:	0cf48763          	beq	s1,a5,80000402 <consoleintr+0x14a>
      consputc(c);
    80000338:	8526                	mv	a0,s1
    8000033a:	00000097          	auipc	ra,0x0
    8000033e:	f3c080e7          	jalr	-196(ra) # 80000276 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000342:	00012797          	auipc	a5,0x12
    80000346:	e3e78793          	addi	a5,a5,-450 # 80012180 <cons>
    8000034a:	0a07a703          	lw	a4,160(a5)
    8000034e:	0017069b          	addiw	a3,a4,1
    80000352:	0006861b          	sext.w	a2,a3
    80000356:	0ad7a023          	sw	a3,160(a5)
    8000035a:	07f77713          	andi	a4,a4,127
    8000035e:	97ba                	add	a5,a5,a4
    80000360:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000364:	47a9                	li	a5,10
    80000366:	0cf48563          	beq	s1,a5,80000430 <consoleintr+0x178>
    8000036a:	4791                	li	a5,4
    8000036c:	0cf48263          	beq	s1,a5,80000430 <consoleintr+0x178>
    80000370:	00012797          	auipc	a5,0x12
    80000374:	ea87a783          	lw	a5,-344(a5) # 80012218 <cons+0x98>
    80000378:	0807879b          	addiw	a5,a5,128
    8000037c:	f6f61ce3          	bne	a2,a5,800002f4 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000380:	863e                	mv	a2,a5
    80000382:	a07d                	j	80000430 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000384:	00012717          	auipc	a4,0x12
    80000388:	dfc70713          	addi	a4,a4,-516 # 80012180 <cons>
    8000038c:	0a072783          	lw	a5,160(a4)
    80000390:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000394:	00012497          	auipc	s1,0x12
    80000398:	dec48493          	addi	s1,s1,-532 # 80012180 <cons>
    while(cons.e != cons.w &&
    8000039c:	4929                	li	s2,10
    8000039e:	f4f70be3          	beq	a4,a5,800002f4 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a2:	37fd                	addiw	a5,a5,-1
    800003a4:	07f7f713          	andi	a4,a5,127
    800003a8:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003aa:	01874703          	lbu	a4,24(a4)
    800003ae:	f52703e3          	beq	a4,s2,800002f4 <consoleintr+0x3c>
      cons.e--;
    800003b2:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003b6:	10000513          	li	a0,256
    800003ba:	00000097          	auipc	ra,0x0
    800003be:	ebc080e7          	jalr	-324(ra) # 80000276 <consputc>
    while(cons.e != cons.w &&
    800003c2:	0a04a783          	lw	a5,160(s1)
    800003c6:	09c4a703          	lw	a4,156(s1)
    800003ca:	fcf71ce3          	bne	a4,a5,800003a2 <consoleintr+0xea>
    800003ce:	b71d                	j	800002f4 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d0:	00012717          	auipc	a4,0x12
    800003d4:	db070713          	addi	a4,a4,-592 # 80012180 <cons>
    800003d8:	0a072783          	lw	a5,160(a4)
    800003dc:	09c72703          	lw	a4,156(a4)
    800003e0:	f0f70ae3          	beq	a4,a5,800002f4 <consoleintr+0x3c>
      cons.e--;
    800003e4:	37fd                	addiw	a5,a5,-1
    800003e6:	00012717          	auipc	a4,0x12
    800003ea:	e2f72d23          	sw	a5,-454(a4) # 80012220 <cons+0xa0>
      consputc(BACKSPACE);
    800003ee:	10000513          	li	a0,256
    800003f2:	00000097          	auipc	ra,0x0
    800003f6:	e84080e7          	jalr	-380(ra) # 80000276 <consputc>
    800003fa:	bded                	j	800002f4 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    800003fc:	ee048ce3          	beqz	s1,800002f4 <consoleintr+0x3c>
    80000400:	bf21                	j	80000318 <consoleintr+0x60>
      consputc(c);
    80000402:	4529                	li	a0,10
    80000404:	00000097          	auipc	ra,0x0
    80000408:	e72080e7          	jalr	-398(ra) # 80000276 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000040c:	00012797          	auipc	a5,0x12
    80000410:	d7478793          	addi	a5,a5,-652 # 80012180 <cons>
    80000414:	0a07a703          	lw	a4,160(a5)
    80000418:	0017069b          	addiw	a3,a4,1
    8000041c:	0006861b          	sext.w	a2,a3
    80000420:	0ad7a023          	sw	a3,160(a5)
    80000424:	07f77713          	andi	a4,a4,127
    80000428:	97ba                	add	a5,a5,a4
    8000042a:	4729                	li	a4,10
    8000042c:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000430:	00012797          	auipc	a5,0x12
    80000434:	dec7a623          	sw	a2,-532(a5) # 8001221c <cons+0x9c>
        wakeup(&cons.r);
    80000438:	00012517          	auipc	a0,0x12
    8000043c:	de050513          	addi	a0,a0,-544 # 80012218 <cons+0x98>
    80000440:	00002097          	auipc	ra,0x2
    80000444:	e48080e7          	jalr	-440(ra) # 80002288 <wakeup>
    80000448:	b575                	j	800002f4 <consoleintr+0x3c>

000000008000044a <consoleinit>:

void
consoleinit(void)
{
    8000044a:	1141                	addi	sp,sp,-16
    8000044c:	e406                	sd	ra,8(sp)
    8000044e:	e022                	sd	s0,0(sp)
    80000450:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000452:	00009597          	auipc	a1,0x9
    80000456:	bbe58593          	addi	a1,a1,-1090 # 80009010 <etext+0x10>
    8000045a:	00012517          	auipc	a0,0x12
    8000045e:	d2650513          	addi	a0,a0,-730 # 80012180 <cons>
    80000462:	00000097          	auipc	ra,0x0
    80000466:	726080e7          	jalr	1830(ra) # 80000b88 <initlock>

  uartinit();
    8000046a:	00000097          	auipc	ra,0x0
    8000046e:	32c080e7          	jalr	812(ra) # 80000796 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000472:	00033797          	auipc	a5,0x33
    80000476:	d4e78793          	addi	a5,a5,-690 # 800331c0 <devsw>
    8000047a:	00000717          	auipc	a4,0x0
    8000047e:	cea70713          	addi	a4,a4,-790 # 80000164 <consoleread>
    80000482:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000484:	00000717          	auipc	a4,0x0
    80000488:	c7c70713          	addi	a4,a4,-900 # 80000100 <consolewrite>
    8000048c:	ef98                	sd	a4,24(a5)
}
    8000048e:	60a2                	ld	ra,8(sp)
    80000490:	6402                	ld	s0,0(sp)
    80000492:	0141                	addi	sp,sp,16
    80000494:	8082                	ret

0000000080000496 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000496:	7179                	addi	sp,sp,-48
    80000498:	f406                	sd	ra,40(sp)
    8000049a:	f022                	sd	s0,32(sp)
    8000049c:	ec26                	sd	s1,24(sp)
    8000049e:	e84a                	sd	s2,16(sp)
    800004a0:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a2:	c219                	beqz	a2,800004a8 <printint+0x12>
    800004a4:	08054763          	bltz	a0,80000532 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004a8:	2501                	sext.w	a0,a0
    800004aa:	4881                	li	a7,0
    800004ac:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b0:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b2:	2581                	sext.w	a1,a1
    800004b4:	00009617          	auipc	a2,0x9
    800004b8:	b8c60613          	addi	a2,a2,-1140 # 80009040 <digits>
    800004bc:	883a                	mv	a6,a4
    800004be:	2705                	addiw	a4,a4,1
    800004c0:	02b577bb          	remuw	a5,a0,a1
    800004c4:	1782                	slli	a5,a5,0x20
    800004c6:	9381                	srli	a5,a5,0x20
    800004c8:	97b2                	add	a5,a5,a2
    800004ca:	0007c783          	lbu	a5,0(a5)
    800004ce:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d2:	0005079b          	sext.w	a5,a0
    800004d6:	02b5553b          	divuw	a0,a0,a1
    800004da:	0685                	addi	a3,a3,1
    800004dc:	feb7f0e3          	bgeu	a5,a1,800004bc <printint+0x26>

  if(sign)
    800004e0:	00088c63          	beqz	a7,800004f8 <printint+0x62>
    buf[i++] = '-';
    800004e4:	fe070793          	addi	a5,a4,-32
    800004e8:	00878733          	add	a4,a5,s0
    800004ec:	02d00793          	li	a5,45
    800004f0:	fef70823          	sb	a5,-16(a4)
    800004f4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004f8:	02e05763          	blez	a4,80000526 <printint+0x90>
    800004fc:	fd040793          	addi	a5,s0,-48
    80000500:	00e784b3          	add	s1,a5,a4
    80000504:	fff78913          	addi	s2,a5,-1
    80000508:	993a                	add	s2,s2,a4
    8000050a:	377d                	addiw	a4,a4,-1
    8000050c:	1702                	slli	a4,a4,0x20
    8000050e:	9301                	srli	a4,a4,0x20
    80000510:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000514:	fff4c503          	lbu	a0,-1(s1)
    80000518:	00000097          	auipc	ra,0x0
    8000051c:	d5e080e7          	jalr	-674(ra) # 80000276 <consputc>
  while(--i >= 0)
    80000520:	14fd                	addi	s1,s1,-1
    80000522:	ff2499e3          	bne	s1,s2,80000514 <printint+0x7e>
}
    80000526:	70a2                	ld	ra,40(sp)
    80000528:	7402                	ld	s0,32(sp)
    8000052a:	64e2                	ld	s1,24(sp)
    8000052c:	6942                	ld	s2,16(sp)
    8000052e:	6145                	addi	sp,sp,48
    80000530:	8082                	ret
    x = -xx;
    80000532:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000536:	4885                	li	a7,1
    x = -xx;
    80000538:	bf95                	j	800004ac <printint+0x16>

000000008000053a <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053a:	1101                	addi	sp,sp,-32
    8000053c:	ec06                	sd	ra,24(sp)
    8000053e:	e822                	sd	s0,16(sp)
    80000540:	e426                	sd	s1,8(sp)
    80000542:	1000                	addi	s0,sp,32
    80000544:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000546:	00012797          	auipc	a5,0x12
    8000054a:	ce07ad23          	sw	zero,-774(a5) # 80012240 <pr+0x18>
  printf("panic: ");
    8000054e:	00009517          	auipc	a0,0x9
    80000552:	aca50513          	addi	a0,a0,-1334 # 80009018 <etext+0x18>
    80000556:	00000097          	auipc	ra,0x0
    8000055a:	02e080e7          	jalr	46(ra) # 80000584 <printf>
  printf(s);
    8000055e:	8526                	mv	a0,s1
    80000560:	00000097          	auipc	ra,0x0
    80000564:	024080e7          	jalr	36(ra) # 80000584 <printf>
  printf("\n");
    80000568:	00009517          	auipc	a0,0x9
    8000056c:	b6050513          	addi	a0,a0,-1184 # 800090c8 <digits+0x88>
    80000570:	00000097          	auipc	ra,0x0
    80000574:	014080e7          	jalr	20(ra) # 80000584 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000578:	4785                	li	a5,1
    8000057a:	0000a717          	auipc	a4,0xa
    8000057e:	a8f72323          	sw	a5,-1402(a4) # 8000a000 <panicked>
  for(;;)
    80000582:	a001                	j	80000582 <panic+0x48>

0000000080000584 <printf>:
{
    80000584:	7131                	addi	sp,sp,-192
    80000586:	fc86                	sd	ra,120(sp)
    80000588:	f8a2                	sd	s0,112(sp)
    8000058a:	f4a6                	sd	s1,104(sp)
    8000058c:	f0ca                	sd	s2,96(sp)
    8000058e:	ecce                	sd	s3,88(sp)
    80000590:	e8d2                	sd	s4,80(sp)
    80000592:	e4d6                	sd	s5,72(sp)
    80000594:	e0da                	sd	s6,64(sp)
    80000596:	fc5e                	sd	s7,56(sp)
    80000598:	f862                	sd	s8,48(sp)
    8000059a:	f466                	sd	s9,40(sp)
    8000059c:	f06a                	sd	s10,32(sp)
    8000059e:	ec6e                	sd	s11,24(sp)
    800005a0:	0100                	addi	s0,sp,128
    800005a2:	8a2a                	mv	s4,a0
    800005a4:	e40c                	sd	a1,8(s0)
    800005a6:	e810                	sd	a2,16(s0)
    800005a8:	ec14                	sd	a3,24(s0)
    800005aa:	f018                	sd	a4,32(s0)
    800005ac:	f41c                	sd	a5,40(s0)
    800005ae:	03043823          	sd	a6,48(s0)
    800005b2:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005b6:	00012d97          	auipc	s11,0x12
    800005ba:	c8adad83          	lw	s11,-886(s11) # 80012240 <pr+0x18>
  if(locking)
    800005be:	020d9b63          	bnez	s11,800005f4 <printf+0x70>
  if (fmt == 0)
    800005c2:	040a0263          	beqz	s4,80000606 <printf+0x82>
  va_start(ap, fmt);
    800005c6:	00840793          	addi	a5,s0,8
    800005ca:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005ce:	000a4503          	lbu	a0,0(s4)
    800005d2:	14050f63          	beqz	a0,80000730 <printf+0x1ac>
    800005d6:	4981                	li	s3,0
    if(c != '%'){
    800005d8:	02500a93          	li	s5,37
    switch(c){
    800005dc:	07000b93          	li	s7,112
  consputc('x');
    800005e0:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e2:	00009b17          	auipc	s6,0x9
    800005e6:	a5eb0b13          	addi	s6,s6,-1442 # 80009040 <digits>
    switch(c){
    800005ea:	07300c93          	li	s9,115
    800005ee:	06400c13          	li	s8,100
    800005f2:	a82d                	j	8000062c <printf+0xa8>
    acquire(&pr.lock);
    800005f4:	00012517          	auipc	a0,0x12
    800005f8:	c3450513          	addi	a0,a0,-972 # 80012228 <pr>
    800005fc:	00000097          	auipc	ra,0x0
    80000600:	61c080e7          	jalr	1564(ra) # 80000c18 <acquire>
    80000604:	bf7d                	j	800005c2 <printf+0x3e>
    panic("null fmt");
    80000606:	00009517          	auipc	a0,0x9
    8000060a:	a2250513          	addi	a0,a0,-1502 # 80009028 <etext+0x28>
    8000060e:	00000097          	auipc	ra,0x0
    80000612:	f2c080e7          	jalr	-212(ra) # 8000053a <panic>
      consputc(c);
    80000616:	00000097          	auipc	ra,0x0
    8000061a:	c60080e7          	jalr	-928(ra) # 80000276 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000061e:	2985                	addiw	s3,s3,1
    80000620:	013a07b3          	add	a5,s4,s3
    80000624:	0007c503          	lbu	a0,0(a5)
    80000628:	10050463          	beqz	a0,80000730 <printf+0x1ac>
    if(c != '%'){
    8000062c:	ff5515e3          	bne	a0,s5,80000616 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000630:	2985                	addiw	s3,s3,1
    80000632:	013a07b3          	add	a5,s4,s3
    80000636:	0007c783          	lbu	a5,0(a5)
    8000063a:	0007849b          	sext.w	s1,a5
    if(c == 0)
    8000063e:	cbed                	beqz	a5,80000730 <printf+0x1ac>
    switch(c){
    80000640:	05778a63          	beq	a5,s7,80000694 <printf+0x110>
    80000644:	02fbf663          	bgeu	s7,a5,80000670 <printf+0xec>
    80000648:	09978863          	beq	a5,s9,800006d8 <printf+0x154>
    8000064c:	07800713          	li	a4,120
    80000650:	0ce79563          	bne	a5,a4,8000071a <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000654:	f8843783          	ld	a5,-120(s0)
    80000658:	00878713          	addi	a4,a5,8
    8000065c:	f8e43423          	sd	a4,-120(s0)
    80000660:	4605                	li	a2,1
    80000662:	85ea                	mv	a1,s10
    80000664:	4388                	lw	a0,0(a5)
    80000666:	00000097          	auipc	ra,0x0
    8000066a:	e30080e7          	jalr	-464(ra) # 80000496 <printint>
      break;
    8000066e:	bf45                	j	8000061e <printf+0x9a>
    switch(c){
    80000670:	09578f63          	beq	a5,s5,8000070e <printf+0x18a>
    80000674:	0b879363          	bne	a5,s8,8000071a <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	4605                	li	a2,1
    80000686:	45a9                	li	a1,10
    80000688:	4388                	lw	a0,0(a5)
    8000068a:	00000097          	auipc	ra,0x0
    8000068e:	e0c080e7          	jalr	-500(ra) # 80000496 <printint>
      break;
    80000692:	b771                	j	8000061e <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000694:	f8843783          	ld	a5,-120(s0)
    80000698:	00878713          	addi	a4,a5,8
    8000069c:	f8e43423          	sd	a4,-120(s0)
    800006a0:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a4:	03000513          	li	a0,48
    800006a8:	00000097          	auipc	ra,0x0
    800006ac:	bce080e7          	jalr	-1074(ra) # 80000276 <consputc>
  consputc('x');
    800006b0:	07800513          	li	a0,120
    800006b4:	00000097          	auipc	ra,0x0
    800006b8:	bc2080e7          	jalr	-1086(ra) # 80000276 <consputc>
    800006bc:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006be:	03c95793          	srli	a5,s2,0x3c
    800006c2:	97da                	add	a5,a5,s6
    800006c4:	0007c503          	lbu	a0,0(a5)
    800006c8:	00000097          	auipc	ra,0x0
    800006cc:	bae080e7          	jalr	-1106(ra) # 80000276 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d0:	0912                	slli	s2,s2,0x4
    800006d2:	34fd                	addiw	s1,s1,-1
    800006d4:	f4ed                	bnez	s1,800006be <printf+0x13a>
    800006d6:	b7a1                	j	8000061e <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006d8:	f8843783          	ld	a5,-120(s0)
    800006dc:	00878713          	addi	a4,a5,8
    800006e0:	f8e43423          	sd	a4,-120(s0)
    800006e4:	6384                	ld	s1,0(a5)
    800006e6:	cc89                	beqz	s1,80000700 <printf+0x17c>
      for(; *s; s++)
    800006e8:	0004c503          	lbu	a0,0(s1)
    800006ec:	d90d                	beqz	a0,8000061e <printf+0x9a>
        consputc(*s);
    800006ee:	00000097          	auipc	ra,0x0
    800006f2:	b88080e7          	jalr	-1144(ra) # 80000276 <consputc>
      for(; *s; s++)
    800006f6:	0485                	addi	s1,s1,1
    800006f8:	0004c503          	lbu	a0,0(s1)
    800006fc:	f96d                	bnez	a0,800006ee <printf+0x16a>
    800006fe:	b705                	j	8000061e <printf+0x9a>
        s = "(null)";
    80000700:	00009497          	auipc	s1,0x9
    80000704:	92048493          	addi	s1,s1,-1760 # 80009020 <etext+0x20>
      for(; *s; s++)
    80000708:	02800513          	li	a0,40
    8000070c:	b7cd                	j	800006ee <printf+0x16a>
      consputc('%');
    8000070e:	8556                	mv	a0,s5
    80000710:	00000097          	auipc	ra,0x0
    80000714:	b66080e7          	jalr	-1178(ra) # 80000276 <consputc>
      break;
    80000718:	b719                	j	8000061e <printf+0x9a>
      consputc('%');
    8000071a:	8556                	mv	a0,s5
    8000071c:	00000097          	auipc	ra,0x0
    80000720:	b5a080e7          	jalr	-1190(ra) # 80000276 <consputc>
      consputc(c);
    80000724:	8526                	mv	a0,s1
    80000726:	00000097          	auipc	ra,0x0
    8000072a:	b50080e7          	jalr	-1200(ra) # 80000276 <consputc>
      break;
    8000072e:	bdc5                	j	8000061e <printf+0x9a>
  if(locking)
    80000730:	020d9163          	bnez	s11,80000752 <printf+0x1ce>
}
    80000734:	70e6                	ld	ra,120(sp)
    80000736:	7446                	ld	s0,112(sp)
    80000738:	74a6                	ld	s1,104(sp)
    8000073a:	7906                	ld	s2,96(sp)
    8000073c:	69e6                	ld	s3,88(sp)
    8000073e:	6a46                	ld	s4,80(sp)
    80000740:	6aa6                	ld	s5,72(sp)
    80000742:	6b06                	ld	s6,64(sp)
    80000744:	7be2                	ld	s7,56(sp)
    80000746:	7c42                	ld	s8,48(sp)
    80000748:	7ca2                	ld	s9,40(sp)
    8000074a:	7d02                	ld	s10,32(sp)
    8000074c:	6de2                	ld	s11,24(sp)
    8000074e:	6129                	addi	sp,sp,192
    80000750:	8082                	ret
    release(&pr.lock);
    80000752:	00012517          	auipc	a0,0x12
    80000756:	ad650513          	addi	a0,a0,-1322 # 80012228 <pr>
    8000075a:	00000097          	auipc	ra,0x0
    8000075e:	572080e7          	jalr	1394(ra) # 80000ccc <release>
}
    80000762:	bfc9                	j	80000734 <printf+0x1b0>

0000000080000764 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000764:	1101                	addi	sp,sp,-32
    80000766:	ec06                	sd	ra,24(sp)
    80000768:	e822                	sd	s0,16(sp)
    8000076a:	e426                	sd	s1,8(sp)
    8000076c:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000076e:	00012497          	auipc	s1,0x12
    80000772:	aba48493          	addi	s1,s1,-1350 # 80012228 <pr>
    80000776:	00009597          	auipc	a1,0x9
    8000077a:	8c258593          	addi	a1,a1,-1854 # 80009038 <etext+0x38>
    8000077e:	8526                	mv	a0,s1
    80000780:	00000097          	auipc	ra,0x0
    80000784:	408080e7          	jalr	1032(ra) # 80000b88 <initlock>
  pr.locking = 1;
    80000788:	4785                	li	a5,1
    8000078a:	cc9c                	sw	a5,24(s1)
}
    8000078c:	60e2                	ld	ra,24(sp)
    8000078e:	6442                	ld	s0,16(sp)
    80000790:	64a2                	ld	s1,8(sp)
    80000792:	6105                	addi	sp,sp,32
    80000794:	8082                	ret

0000000080000796 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000796:	1141                	addi	sp,sp,-16
    80000798:	e406                	sd	ra,8(sp)
    8000079a:	e022                	sd	s0,0(sp)
    8000079c:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000079e:	100007b7          	lui	a5,0x10000
    800007a2:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007a6:	f8000713          	li	a4,-128
    800007aa:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007ae:	470d                	li	a4,3
    800007b0:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b4:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007b8:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007bc:	469d                	li	a3,7
    800007be:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c2:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007c6:	00009597          	auipc	a1,0x9
    800007ca:	89258593          	addi	a1,a1,-1902 # 80009058 <digits+0x18>
    800007ce:	00012517          	auipc	a0,0x12
    800007d2:	a7a50513          	addi	a0,a0,-1414 # 80012248 <uart_tx_lock>
    800007d6:	00000097          	auipc	ra,0x0
    800007da:	3b2080e7          	jalr	946(ra) # 80000b88 <initlock>
}
    800007de:	60a2                	ld	ra,8(sp)
    800007e0:	6402                	ld	s0,0(sp)
    800007e2:	0141                	addi	sp,sp,16
    800007e4:	8082                	ret

00000000800007e6 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007e6:	1101                	addi	sp,sp,-32
    800007e8:	ec06                	sd	ra,24(sp)
    800007ea:	e822                	sd	s0,16(sp)
    800007ec:	e426                	sd	s1,8(sp)
    800007ee:	1000                	addi	s0,sp,32
    800007f0:	84aa                	mv	s1,a0
  push_off();
    800007f2:	00000097          	auipc	ra,0x0
    800007f6:	3da080e7          	jalr	986(ra) # 80000bcc <push_off>

  if(panicked){
    800007fa:	0000a797          	auipc	a5,0xa
    800007fe:	8067a783          	lw	a5,-2042(a5) # 8000a000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000802:	10000737          	lui	a4,0x10000
  if(panicked){
    80000806:	c391                	beqz	a5,8000080a <uartputc_sync+0x24>
    for(;;)
    80000808:	a001                	j	80000808 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080a:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000080e:	0207f793          	andi	a5,a5,32
    80000812:	dfe5                	beqz	a5,8000080a <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000814:	0ff4f513          	zext.b	a0,s1
    80000818:	100007b7          	lui	a5,0x10000
    8000081c:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000820:	00000097          	auipc	ra,0x0
    80000824:	44c080e7          	jalr	1100(ra) # 80000c6c <pop_off>
}
    80000828:	60e2                	ld	ra,24(sp)
    8000082a:	6442                	ld	s0,16(sp)
    8000082c:	64a2                	ld	s1,8(sp)
    8000082e:	6105                	addi	sp,sp,32
    80000830:	8082                	ret

0000000080000832 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000832:	00009797          	auipc	a5,0x9
    80000836:	7d67b783          	ld	a5,2006(a5) # 8000a008 <uart_tx_r>
    8000083a:	00009717          	auipc	a4,0x9
    8000083e:	7d673703          	ld	a4,2006(a4) # 8000a010 <uart_tx_w>
    80000842:	06f70a63          	beq	a4,a5,800008b6 <uartstart+0x84>
{
    80000846:	7139                	addi	sp,sp,-64
    80000848:	fc06                	sd	ra,56(sp)
    8000084a:	f822                	sd	s0,48(sp)
    8000084c:	f426                	sd	s1,40(sp)
    8000084e:	f04a                	sd	s2,32(sp)
    80000850:	ec4e                	sd	s3,24(sp)
    80000852:	e852                	sd	s4,16(sp)
    80000854:	e456                	sd	s5,8(sp)
    80000856:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000858:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000085c:	00012a17          	auipc	s4,0x12
    80000860:	9eca0a13          	addi	s4,s4,-1556 # 80012248 <uart_tx_lock>
    uart_tx_r += 1;
    80000864:	00009497          	auipc	s1,0x9
    80000868:	7a448493          	addi	s1,s1,1956 # 8000a008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086c:	00009997          	auipc	s3,0x9
    80000870:	7a498993          	addi	s3,s3,1956 # 8000a010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000874:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000878:	02077713          	andi	a4,a4,32
    8000087c:	c705                	beqz	a4,800008a4 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000087e:	01f7f713          	andi	a4,a5,31
    80000882:	9752                	add	a4,a4,s4
    80000884:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    80000888:	0785                	addi	a5,a5,1
    8000088a:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000088c:	8526                	mv	a0,s1
    8000088e:	00002097          	auipc	ra,0x2
    80000892:	9fa080e7          	jalr	-1542(ra) # 80002288 <wakeup>
    
    WriteReg(THR, c);
    80000896:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089a:	609c                	ld	a5,0(s1)
    8000089c:	0009b703          	ld	a4,0(s3)
    800008a0:	fcf71ae3          	bne	a4,a5,80000874 <uartstart+0x42>
  }
}
    800008a4:	70e2                	ld	ra,56(sp)
    800008a6:	7442                	ld	s0,48(sp)
    800008a8:	74a2                	ld	s1,40(sp)
    800008aa:	7902                	ld	s2,32(sp)
    800008ac:	69e2                	ld	s3,24(sp)
    800008ae:	6a42                	ld	s4,16(sp)
    800008b0:	6aa2                	ld	s5,8(sp)
    800008b2:	6121                	addi	sp,sp,64
    800008b4:	8082                	ret
    800008b6:	8082                	ret

00000000800008b8 <uartputc>:
{
    800008b8:	7179                	addi	sp,sp,-48
    800008ba:	f406                	sd	ra,40(sp)
    800008bc:	f022                	sd	s0,32(sp)
    800008be:	ec26                	sd	s1,24(sp)
    800008c0:	e84a                	sd	s2,16(sp)
    800008c2:	e44e                	sd	s3,8(sp)
    800008c4:	e052                	sd	s4,0(sp)
    800008c6:	1800                	addi	s0,sp,48
    800008c8:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008ca:	00012517          	auipc	a0,0x12
    800008ce:	97e50513          	addi	a0,a0,-1666 # 80012248 <uart_tx_lock>
    800008d2:	00000097          	auipc	ra,0x0
    800008d6:	346080e7          	jalr	838(ra) # 80000c18 <acquire>
  if(panicked){
    800008da:	00009797          	auipc	a5,0x9
    800008de:	7267a783          	lw	a5,1830(a5) # 8000a000 <panicked>
    800008e2:	c391                	beqz	a5,800008e6 <uartputc+0x2e>
    for(;;)
    800008e4:	a001                	j	800008e4 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e6:	00009717          	auipc	a4,0x9
    800008ea:	72a73703          	ld	a4,1834(a4) # 8000a010 <uart_tx_w>
    800008ee:	00009797          	auipc	a5,0x9
    800008f2:	71a7b783          	ld	a5,1818(a5) # 8000a008 <uart_tx_r>
    800008f6:	02078793          	addi	a5,a5,32
    800008fa:	02e79b63          	bne	a5,a4,80000930 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    800008fe:	00012997          	auipc	s3,0x12
    80000902:	94a98993          	addi	s3,s3,-1718 # 80012248 <uart_tx_lock>
    80000906:	00009497          	auipc	s1,0x9
    8000090a:	70248493          	addi	s1,s1,1794 # 8000a008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090e:	00009917          	auipc	s2,0x9
    80000912:	70290913          	addi	s2,s2,1794 # 8000a010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000916:	85ce                	mv	a1,s3
    80000918:	8526                	mv	a0,s1
    8000091a:	00002097          	auipc	ra,0x2
    8000091e:	90a080e7          	jalr	-1782(ra) # 80002224 <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000922:	00093703          	ld	a4,0(s2)
    80000926:	609c                	ld	a5,0(s1)
    80000928:	02078793          	addi	a5,a5,32
    8000092c:	fee785e3          	beq	a5,a4,80000916 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000930:	00012497          	auipc	s1,0x12
    80000934:	91848493          	addi	s1,s1,-1768 # 80012248 <uart_tx_lock>
    80000938:	01f77793          	andi	a5,a4,31
    8000093c:	97a6                	add	a5,a5,s1
    8000093e:	01478c23          	sb	s4,24(a5)
      uart_tx_w += 1;
    80000942:	0705                	addi	a4,a4,1
    80000944:	00009797          	auipc	a5,0x9
    80000948:	6ce7b623          	sd	a4,1740(a5) # 8000a010 <uart_tx_w>
      uartstart();
    8000094c:	00000097          	auipc	ra,0x0
    80000950:	ee6080e7          	jalr	-282(ra) # 80000832 <uartstart>
      release(&uart_tx_lock);
    80000954:	8526                	mv	a0,s1
    80000956:	00000097          	auipc	ra,0x0
    8000095a:	376080e7          	jalr	886(ra) # 80000ccc <release>
}
    8000095e:	70a2                	ld	ra,40(sp)
    80000960:	7402                	ld	s0,32(sp)
    80000962:	64e2                	ld	s1,24(sp)
    80000964:	6942                	ld	s2,16(sp)
    80000966:	69a2                	ld	s3,8(sp)
    80000968:	6a02                	ld	s4,0(sp)
    8000096a:	6145                	addi	sp,sp,48
    8000096c:	8082                	ret

000000008000096e <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000096e:	1141                	addi	sp,sp,-16
    80000970:	e422                	sd	s0,8(sp)
    80000972:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000974:	100007b7          	lui	a5,0x10000
    80000978:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000097c:	8b85                	andi	a5,a5,1
    8000097e:	cb81                	beqz	a5,8000098e <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000980:	100007b7          	lui	a5,0x10000
    80000984:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    80000988:	6422                	ld	s0,8(sp)
    8000098a:	0141                	addi	sp,sp,16
    8000098c:	8082                	ret
    return -1;
    8000098e:	557d                	li	a0,-1
    80000990:	bfe5                	j	80000988 <uartgetc+0x1a>

0000000080000992 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    80000992:	1101                	addi	sp,sp,-32
    80000994:	ec06                	sd	ra,24(sp)
    80000996:	e822                	sd	s0,16(sp)
    80000998:	e426                	sd	s1,8(sp)
    8000099a:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000099c:	54fd                	li	s1,-1
    8000099e:	a029                	j	800009a8 <uartintr+0x16>
      break;
    consoleintr(c);
    800009a0:	00000097          	auipc	ra,0x0
    800009a4:	918080e7          	jalr	-1768(ra) # 800002b8 <consoleintr>
    int c = uartgetc();
    800009a8:	00000097          	auipc	ra,0x0
    800009ac:	fc6080e7          	jalr	-58(ra) # 8000096e <uartgetc>
    if(c == -1)
    800009b0:	fe9518e3          	bne	a0,s1,800009a0 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009b4:	00012497          	auipc	s1,0x12
    800009b8:	89448493          	addi	s1,s1,-1900 # 80012248 <uart_tx_lock>
    800009bc:	8526                	mv	a0,s1
    800009be:	00000097          	auipc	ra,0x0
    800009c2:	25a080e7          	jalr	602(ra) # 80000c18 <acquire>
  uartstart();
    800009c6:	00000097          	auipc	ra,0x0
    800009ca:	e6c080e7          	jalr	-404(ra) # 80000832 <uartstart>
  release(&uart_tx_lock);
    800009ce:	8526                	mv	a0,s1
    800009d0:	00000097          	auipc	ra,0x0
    800009d4:	2fc080e7          	jalr	764(ra) # 80000ccc <release>
}
    800009d8:	60e2                	ld	ra,24(sp)
    800009da:	6442                	ld	s0,16(sp)
    800009dc:	64a2                	ld	s1,8(sp)
    800009de:	6105                	addi	sp,sp,32
    800009e0:	8082                	ret

00000000800009e2 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e2:	1101                	addi	sp,sp,-32
    800009e4:	ec06                	sd	ra,24(sp)
    800009e6:	e822                	sd	s0,16(sp)
    800009e8:	e426                	sd	s1,8(sp)
    800009ea:	e04a                	sd	s2,0(sp)
    800009ec:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009ee:	03451793          	slli	a5,a0,0x34
    800009f2:	ebb9                	bnez	a5,80000a48 <kfree+0x66>
    800009f4:	84aa                	mv	s1,a0
    800009f6:	00037797          	auipc	a5,0x37
    800009fa:	60a78793          	addi	a5,a5,1546 # 80038000 <end>
    800009fe:	04f56563          	bltu	a0,a5,80000a48 <kfree+0x66>
    80000a02:	47c5                	li	a5,17
    80000a04:	07ee                	slli	a5,a5,0x1b
    80000a06:	04f57163          	bgeu	a0,a5,80000a48 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a0a:	6605                	lui	a2,0x1
    80000a0c:	4585                	li	a1,1
    80000a0e:	00000097          	auipc	ra,0x0
    80000a12:	306080e7          	jalr	774(ra) # 80000d14 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a16:	00012917          	auipc	s2,0x12
    80000a1a:	86a90913          	addi	s2,s2,-1942 # 80012280 <kmem>
    80000a1e:	854a                	mv	a0,s2
    80000a20:	00000097          	auipc	ra,0x0
    80000a24:	1f8080e7          	jalr	504(ra) # 80000c18 <acquire>
  r->next = kmem.freelist;
    80000a28:	01893783          	ld	a5,24(s2)
    80000a2c:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a2e:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a32:	854a                	mv	a0,s2
    80000a34:	00000097          	auipc	ra,0x0
    80000a38:	298080e7          	jalr	664(ra) # 80000ccc <release>
}
    80000a3c:	60e2                	ld	ra,24(sp)
    80000a3e:	6442                	ld	s0,16(sp)
    80000a40:	64a2                	ld	s1,8(sp)
    80000a42:	6902                	ld	s2,0(sp)
    80000a44:	6105                	addi	sp,sp,32
    80000a46:	8082                	ret
    panic("kfree");
    80000a48:	00008517          	auipc	a0,0x8
    80000a4c:	61850513          	addi	a0,a0,1560 # 80009060 <digits+0x20>
    80000a50:	00000097          	auipc	ra,0x0
    80000a54:	aea080e7          	jalr	-1302(ra) # 8000053a <panic>

0000000080000a58 <freerange>:
{
    80000a58:	7179                	addi	sp,sp,-48
    80000a5a:	f406                	sd	ra,40(sp)
    80000a5c:	f022                	sd	s0,32(sp)
    80000a5e:	ec26                	sd	s1,24(sp)
    80000a60:	e84a                	sd	s2,16(sp)
    80000a62:	e44e                	sd	s3,8(sp)
    80000a64:	e052                	sd	s4,0(sp)
    80000a66:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a68:	6785                	lui	a5,0x1
    80000a6a:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a6e:	00e504b3          	add	s1,a0,a4
    80000a72:	777d                	lui	a4,0xfffff
    80000a74:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a76:	94be                	add	s1,s1,a5
    80000a78:	0095ee63          	bltu	a1,s1,80000a94 <freerange+0x3c>
    80000a7c:	892e                	mv	s2,a1
    kfree(p);
    80000a7e:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a80:	6985                	lui	s3,0x1
    kfree(p);
    80000a82:	01448533          	add	a0,s1,s4
    80000a86:	00000097          	auipc	ra,0x0
    80000a8a:	f5c080e7          	jalr	-164(ra) # 800009e2 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a8e:	94ce                	add	s1,s1,s3
    80000a90:	fe9979e3          	bgeu	s2,s1,80000a82 <freerange+0x2a>
}
    80000a94:	70a2                	ld	ra,40(sp)
    80000a96:	7402                	ld	s0,32(sp)
    80000a98:	64e2                	ld	s1,24(sp)
    80000a9a:	6942                	ld	s2,16(sp)
    80000a9c:	69a2                	ld	s3,8(sp)
    80000a9e:	6a02                	ld	s4,0(sp)
    80000aa0:	6145                	addi	sp,sp,48
    80000aa2:	8082                	ret

0000000080000aa4 <kinit>:
{
    80000aa4:	1141                	addi	sp,sp,-16
    80000aa6:	e406                	sd	ra,8(sp)
    80000aa8:	e022                	sd	s0,0(sp)
    80000aaa:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aac:	00008597          	auipc	a1,0x8
    80000ab0:	5bc58593          	addi	a1,a1,1468 # 80009068 <digits+0x28>
    80000ab4:	00011517          	auipc	a0,0x11
    80000ab8:	7cc50513          	addi	a0,a0,1996 # 80012280 <kmem>
    80000abc:	00000097          	auipc	ra,0x0
    80000ac0:	0cc080e7          	jalr	204(ra) # 80000b88 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac4:	45c5                	li	a1,17
    80000ac6:	05ee                	slli	a1,a1,0x1b
    80000ac8:	00037517          	auipc	a0,0x37
    80000acc:	53850513          	addi	a0,a0,1336 # 80038000 <end>
    80000ad0:	00000097          	auipc	ra,0x0
    80000ad4:	f88080e7          	jalr	-120(ra) # 80000a58 <freerange>
}
    80000ad8:	60a2                	ld	ra,8(sp)
    80000ada:	6402                	ld	s0,0(sp)
    80000adc:	0141                	addi	sp,sp,16
    80000ade:	8082                	ret

0000000080000ae0 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae0:	1101                	addi	sp,sp,-32
    80000ae2:	ec06                	sd	ra,24(sp)
    80000ae4:	e822                	sd	s0,16(sp)
    80000ae6:	e426                	sd	s1,8(sp)
    80000ae8:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000aea:	00011497          	auipc	s1,0x11
    80000aee:	79648493          	addi	s1,s1,1942 # 80012280 <kmem>
    80000af2:	8526                	mv	a0,s1
    80000af4:	00000097          	auipc	ra,0x0
    80000af8:	124080e7          	jalr	292(ra) # 80000c18 <acquire>
  r = kmem.freelist;
    80000afc:	6c84                	ld	s1,24(s1)
  if(r)
    80000afe:	c885                	beqz	s1,80000b2e <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b00:	609c                	ld	a5,0(s1)
    80000b02:	00011517          	auipc	a0,0x11
    80000b06:	77e50513          	addi	a0,a0,1918 # 80012280 <kmem>
    80000b0a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b0c:	00000097          	auipc	ra,0x0
    80000b10:	1c0080e7          	jalr	448(ra) # 80000ccc <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b14:	6605                	lui	a2,0x1
    80000b16:	4595                	li	a1,5
    80000b18:	8526                	mv	a0,s1
    80000b1a:	00000097          	auipc	ra,0x0
    80000b1e:	1fa080e7          	jalr	506(ra) # 80000d14 <memset>
  return (void*)r;
}
    80000b22:	8526                	mv	a0,s1
    80000b24:	60e2                	ld	ra,24(sp)
    80000b26:	6442                	ld	s0,16(sp)
    80000b28:	64a2                	ld	s1,8(sp)
    80000b2a:	6105                	addi	sp,sp,32
    80000b2c:	8082                	ret
  release(&kmem.lock);
    80000b2e:	00011517          	auipc	a0,0x11
    80000b32:	75250513          	addi	a0,a0,1874 # 80012280 <kmem>
    80000b36:	00000097          	auipc	ra,0x0
    80000b3a:	196080e7          	jalr	406(ra) # 80000ccc <release>
  if(r)
    80000b3e:	b7d5                	j	80000b22 <kalloc+0x42>

0000000080000b40 <kfreepagecount>:

//Added for lab 3
//Acquires kmem lock and then counts how many free pages there are
uint64 kfreepagecount(void) 
{
    80000b40:	1101                	addi	sp,sp,-32
    80000b42:	ec06                	sd	ra,24(sp)
    80000b44:	e822                	sd	s0,16(sp)
    80000b46:	e426                	sd	s1,8(sp)
    80000b48:	1000                	addi	s0,sp,32
  int count = 0;
  struct run *r;
  acquire(&kmem.lock);
    80000b4a:	00011497          	auipc	s1,0x11
    80000b4e:	73648493          	addi	s1,s1,1846 # 80012280 <kmem>
    80000b52:	8526                	mv	a0,s1
    80000b54:	00000097          	auipc	ra,0x0
    80000b58:	0c4080e7          	jalr	196(ra) # 80000c18 <acquire>
  r = kmem.freelist;
    80000b5c:	6c9c                	ld	a5,24(s1)

  //Traverses the free list and adds to count if page is free
  while(r){
    80000b5e:	c39d                	beqz	a5,80000b84 <kfreepagecount+0x44>
  int count = 0;
    80000b60:	4481                	li	s1,0
    count++;
    80000b62:	2485                	addiw	s1,s1,1
    r = r->next;
    80000b64:	639c                	ld	a5,0(a5)
  while(r){
    80000b66:	fff5                	bnez	a5,80000b62 <kfreepagecount+0x22>
  }
  release(&kmem.lock);
    80000b68:	00011517          	auipc	a0,0x11
    80000b6c:	71850513          	addi	a0,a0,1816 # 80012280 <kmem>
    80000b70:	00000097          	auipc	ra,0x0
    80000b74:	15c080e7          	jalr	348(ra) # 80000ccc <release>
  return count;

}
    80000b78:	8526                	mv	a0,s1
    80000b7a:	60e2                	ld	ra,24(sp)
    80000b7c:	6442                	ld	s0,16(sp)
    80000b7e:	64a2                	ld	s1,8(sp)
    80000b80:	6105                	addi	sp,sp,32
    80000b82:	8082                	ret
  int count = 0;
    80000b84:	4481                	li	s1,0
    80000b86:	b7cd                	j	80000b68 <kfreepagecount+0x28>

0000000080000b88 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b88:	1141                	addi	sp,sp,-16
    80000b8a:	e422                	sd	s0,8(sp)
    80000b8c:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b8e:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b90:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b94:	00053823          	sd	zero,16(a0)
}
    80000b98:	6422                	ld	s0,8(sp)
    80000b9a:	0141                	addi	sp,sp,16
    80000b9c:	8082                	ret

0000000080000b9e <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b9e:	411c                	lw	a5,0(a0)
    80000ba0:	e399                	bnez	a5,80000ba6 <holding+0x8>
    80000ba2:	4501                	li	a0,0
  return r;
}
    80000ba4:	8082                	ret
{
    80000ba6:	1101                	addi	sp,sp,-32
    80000ba8:	ec06                	sd	ra,24(sp)
    80000baa:	e822                	sd	s0,16(sp)
    80000bac:	e426                	sd	s1,8(sp)
    80000bae:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bb0:	6904                	ld	s1,16(a0)
    80000bb2:	00001097          	auipc	ra,0x1
    80000bb6:	1ee080e7          	jalr	494(ra) # 80001da0 <mycpu>
    80000bba:	40a48533          	sub	a0,s1,a0
    80000bbe:	00153513          	seqz	a0,a0
}
    80000bc2:	60e2                	ld	ra,24(sp)
    80000bc4:	6442                	ld	s0,16(sp)
    80000bc6:	64a2                	ld	s1,8(sp)
    80000bc8:	6105                	addi	sp,sp,32
    80000bca:	8082                	ret

0000000080000bcc <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bcc:	1101                	addi	sp,sp,-32
    80000bce:	ec06                	sd	ra,24(sp)
    80000bd0:	e822                	sd	s0,16(sp)
    80000bd2:	e426                	sd	s1,8(sp)
    80000bd4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bd6:	100024f3          	csrr	s1,sstatus
    80000bda:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bde:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000be0:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000be4:	00001097          	auipc	ra,0x1
    80000be8:	1bc080e7          	jalr	444(ra) # 80001da0 <mycpu>
    80000bec:	5d3c                	lw	a5,120(a0)
    80000bee:	cf89                	beqz	a5,80000c08 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bf0:	00001097          	auipc	ra,0x1
    80000bf4:	1b0080e7          	jalr	432(ra) # 80001da0 <mycpu>
    80000bf8:	5d3c                	lw	a5,120(a0)
    80000bfa:	2785                	addiw	a5,a5,1
    80000bfc:	dd3c                	sw	a5,120(a0)
}
    80000bfe:	60e2                	ld	ra,24(sp)
    80000c00:	6442                	ld	s0,16(sp)
    80000c02:	64a2                	ld	s1,8(sp)
    80000c04:	6105                	addi	sp,sp,32
    80000c06:	8082                	ret
    mycpu()->intena = old;
    80000c08:	00001097          	auipc	ra,0x1
    80000c0c:	198080e7          	jalr	408(ra) # 80001da0 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c10:	8085                	srli	s1,s1,0x1
    80000c12:	8885                	andi	s1,s1,1
    80000c14:	dd64                	sw	s1,124(a0)
    80000c16:	bfe9                	j	80000bf0 <push_off+0x24>

0000000080000c18 <acquire>:
{
    80000c18:	1101                	addi	sp,sp,-32
    80000c1a:	ec06                	sd	ra,24(sp)
    80000c1c:	e822                	sd	s0,16(sp)
    80000c1e:	e426                	sd	s1,8(sp)
    80000c20:	1000                	addi	s0,sp,32
    80000c22:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c24:	00000097          	auipc	ra,0x0
    80000c28:	fa8080e7          	jalr	-88(ra) # 80000bcc <push_off>
  if(holding(lk))
    80000c2c:	8526                	mv	a0,s1
    80000c2e:	00000097          	auipc	ra,0x0
    80000c32:	f70080e7          	jalr	-144(ra) # 80000b9e <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c36:	4705                	li	a4,1
  if(holding(lk))
    80000c38:	e115                	bnez	a0,80000c5c <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c3a:	87ba                	mv	a5,a4
    80000c3c:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c40:	2781                	sext.w	a5,a5
    80000c42:	ffe5                	bnez	a5,80000c3a <acquire+0x22>
  __sync_synchronize();
    80000c44:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c48:	00001097          	auipc	ra,0x1
    80000c4c:	158080e7          	jalr	344(ra) # 80001da0 <mycpu>
    80000c50:	e888                	sd	a0,16(s1)
}
    80000c52:	60e2                	ld	ra,24(sp)
    80000c54:	6442                	ld	s0,16(sp)
    80000c56:	64a2                	ld	s1,8(sp)
    80000c58:	6105                	addi	sp,sp,32
    80000c5a:	8082                	ret
    panic("acquire");
    80000c5c:	00008517          	auipc	a0,0x8
    80000c60:	41450513          	addi	a0,a0,1044 # 80009070 <digits+0x30>
    80000c64:	00000097          	auipc	ra,0x0
    80000c68:	8d6080e7          	jalr	-1834(ra) # 8000053a <panic>

0000000080000c6c <pop_off>:

void
pop_off(void)
{
    80000c6c:	1141                	addi	sp,sp,-16
    80000c6e:	e406                	sd	ra,8(sp)
    80000c70:	e022                	sd	s0,0(sp)
    80000c72:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c74:	00001097          	auipc	ra,0x1
    80000c78:	12c080e7          	jalr	300(ra) # 80001da0 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c7c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c80:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c82:	e78d                	bnez	a5,80000cac <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c84:	5d3c                	lw	a5,120(a0)
    80000c86:	02f05b63          	blez	a5,80000cbc <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c8a:	37fd                	addiw	a5,a5,-1
    80000c8c:	0007871b          	sext.w	a4,a5
    80000c90:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c92:	eb09                	bnez	a4,80000ca4 <pop_off+0x38>
    80000c94:	5d7c                	lw	a5,124(a0)
    80000c96:	c799                	beqz	a5,80000ca4 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c9c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000ca0:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000ca4:	60a2                	ld	ra,8(sp)
    80000ca6:	6402                	ld	s0,0(sp)
    80000ca8:	0141                	addi	sp,sp,16
    80000caa:	8082                	ret
    panic("pop_off - interruptible");
    80000cac:	00008517          	auipc	a0,0x8
    80000cb0:	3cc50513          	addi	a0,a0,972 # 80009078 <digits+0x38>
    80000cb4:	00000097          	auipc	ra,0x0
    80000cb8:	886080e7          	jalr	-1914(ra) # 8000053a <panic>
    panic("pop_off");
    80000cbc:	00008517          	auipc	a0,0x8
    80000cc0:	3d450513          	addi	a0,a0,980 # 80009090 <digits+0x50>
    80000cc4:	00000097          	auipc	ra,0x0
    80000cc8:	876080e7          	jalr	-1930(ra) # 8000053a <panic>

0000000080000ccc <release>:
{
    80000ccc:	1101                	addi	sp,sp,-32
    80000cce:	ec06                	sd	ra,24(sp)
    80000cd0:	e822                	sd	s0,16(sp)
    80000cd2:	e426                	sd	s1,8(sp)
    80000cd4:	1000                	addi	s0,sp,32
    80000cd6:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cd8:	00000097          	auipc	ra,0x0
    80000cdc:	ec6080e7          	jalr	-314(ra) # 80000b9e <holding>
    80000ce0:	c115                	beqz	a0,80000d04 <release+0x38>
  lk->cpu = 0;
    80000ce2:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ce6:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000cea:	0f50000f          	fence	iorw,ow
    80000cee:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cf2:	00000097          	auipc	ra,0x0
    80000cf6:	f7a080e7          	jalr	-134(ra) # 80000c6c <pop_off>
}
    80000cfa:	60e2                	ld	ra,24(sp)
    80000cfc:	6442                	ld	s0,16(sp)
    80000cfe:	64a2                	ld	s1,8(sp)
    80000d00:	6105                	addi	sp,sp,32
    80000d02:	8082                	ret
    panic("release");
    80000d04:	00008517          	auipc	a0,0x8
    80000d08:	39450513          	addi	a0,a0,916 # 80009098 <digits+0x58>
    80000d0c:	00000097          	auipc	ra,0x0
    80000d10:	82e080e7          	jalr	-2002(ra) # 8000053a <panic>

0000000080000d14 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d14:	1141                	addi	sp,sp,-16
    80000d16:	e422                	sd	s0,8(sp)
    80000d18:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d1a:	ca19                	beqz	a2,80000d30 <memset+0x1c>
    80000d1c:	87aa                	mv	a5,a0
    80000d1e:	1602                	slli	a2,a2,0x20
    80000d20:	9201                	srli	a2,a2,0x20
    80000d22:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d26:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d2a:	0785                	addi	a5,a5,1
    80000d2c:	fee79de3          	bne	a5,a4,80000d26 <memset+0x12>
  }
  return dst;
}
    80000d30:	6422                	ld	s0,8(sp)
    80000d32:	0141                	addi	sp,sp,16
    80000d34:	8082                	ret

0000000080000d36 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d36:	1141                	addi	sp,sp,-16
    80000d38:	e422                	sd	s0,8(sp)
    80000d3a:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d3c:	ca05                	beqz	a2,80000d6c <memcmp+0x36>
    80000d3e:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d42:	1682                	slli	a3,a3,0x20
    80000d44:	9281                	srli	a3,a3,0x20
    80000d46:	0685                	addi	a3,a3,1
    80000d48:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d4a:	00054783          	lbu	a5,0(a0)
    80000d4e:	0005c703          	lbu	a4,0(a1)
    80000d52:	00e79863          	bne	a5,a4,80000d62 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d56:	0505                	addi	a0,a0,1
    80000d58:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d5a:	fed518e3          	bne	a0,a3,80000d4a <memcmp+0x14>
  }

  return 0;
    80000d5e:	4501                	li	a0,0
    80000d60:	a019                	j	80000d66 <memcmp+0x30>
      return *s1 - *s2;
    80000d62:	40e7853b          	subw	a0,a5,a4
}
    80000d66:	6422                	ld	s0,8(sp)
    80000d68:	0141                	addi	sp,sp,16
    80000d6a:	8082                	ret
  return 0;
    80000d6c:	4501                	li	a0,0
    80000d6e:	bfe5                	j	80000d66 <memcmp+0x30>

0000000080000d70 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d70:	1141                	addi	sp,sp,-16
    80000d72:	e422                	sd	s0,8(sp)
    80000d74:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d76:	c205                	beqz	a2,80000d96 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d78:	02a5e263          	bltu	a1,a0,80000d9c <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d7c:	1602                	slli	a2,a2,0x20
    80000d7e:	9201                	srli	a2,a2,0x20
    80000d80:	00c587b3          	add	a5,a1,a2
{
    80000d84:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d86:	0585                	addi	a1,a1,1
    80000d88:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffc7001>
    80000d8a:	fff5c683          	lbu	a3,-1(a1)
    80000d8e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d92:	fef59ae3          	bne	a1,a5,80000d86 <memmove+0x16>

  return dst;
}
    80000d96:	6422                	ld	s0,8(sp)
    80000d98:	0141                	addi	sp,sp,16
    80000d9a:	8082                	ret
  if(s < d && s + n > d){
    80000d9c:	02061693          	slli	a3,a2,0x20
    80000da0:	9281                	srli	a3,a3,0x20
    80000da2:	00d58733          	add	a4,a1,a3
    80000da6:	fce57be3          	bgeu	a0,a4,80000d7c <memmove+0xc>
    d += n;
    80000daa:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000dac:	fff6079b          	addiw	a5,a2,-1
    80000db0:	1782                	slli	a5,a5,0x20
    80000db2:	9381                	srli	a5,a5,0x20
    80000db4:	fff7c793          	not	a5,a5
    80000db8:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000dba:	177d                	addi	a4,a4,-1
    80000dbc:	16fd                	addi	a3,a3,-1
    80000dbe:	00074603          	lbu	a2,0(a4)
    80000dc2:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000dc6:	fee79ae3          	bne	a5,a4,80000dba <memmove+0x4a>
    80000dca:	b7f1                	j	80000d96 <memmove+0x26>

0000000080000dcc <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000dcc:	1141                	addi	sp,sp,-16
    80000dce:	e406                	sd	ra,8(sp)
    80000dd0:	e022                	sd	s0,0(sp)
    80000dd2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000dd4:	00000097          	auipc	ra,0x0
    80000dd8:	f9c080e7          	jalr	-100(ra) # 80000d70 <memmove>
}
    80000ddc:	60a2                	ld	ra,8(sp)
    80000dde:	6402                	ld	s0,0(sp)
    80000de0:	0141                	addi	sp,sp,16
    80000de2:	8082                	ret

0000000080000de4 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000de4:	1141                	addi	sp,sp,-16
    80000de6:	e422                	sd	s0,8(sp)
    80000de8:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dea:	ce11                	beqz	a2,80000e06 <strncmp+0x22>
    80000dec:	00054783          	lbu	a5,0(a0)
    80000df0:	cf89                	beqz	a5,80000e0a <strncmp+0x26>
    80000df2:	0005c703          	lbu	a4,0(a1)
    80000df6:	00f71a63          	bne	a4,a5,80000e0a <strncmp+0x26>
    n--, p++, q++;
    80000dfa:	367d                	addiw	a2,a2,-1
    80000dfc:	0505                	addi	a0,a0,1
    80000dfe:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e00:	f675                	bnez	a2,80000dec <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e02:	4501                	li	a0,0
    80000e04:	a809                	j	80000e16 <strncmp+0x32>
    80000e06:	4501                	li	a0,0
    80000e08:	a039                	j	80000e16 <strncmp+0x32>
  if(n == 0)
    80000e0a:	ca09                	beqz	a2,80000e1c <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e0c:	00054503          	lbu	a0,0(a0)
    80000e10:	0005c783          	lbu	a5,0(a1)
    80000e14:	9d1d                	subw	a0,a0,a5
}
    80000e16:	6422                	ld	s0,8(sp)
    80000e18:	0141                	addi	sp,sp,16
    80000e1a:	8082                	ret
    return 0;
    80000e1c:	4501                	li	a0,0
    80000e1e:	bfe5                	j	80000e16 <strncmp+0x32>

0000000080000e20 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e20:	1141                	addi	sp,sp,-16
    80000e22:	e422                	sd	s0,8(sp)
    80000e24:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e26:	872a                	mv	a4,a0
    80000e28:	8832                	mv	a6,a2
    80000e2a:	367d                	addiw	a2,a2,-1
    80000e2c:	01005963          	blez	a6,80000e3e <strncpy+0x1e>
    80000e30:	0705                	addi	a4,a4,1
    80000e32:	0005c783          	lbu	a5,0(a1)
    80000e36:	fef70fa3          	sb	a5,-1(a4)
    80000e3a:	0585                	addi	a1,a1,1
    80000e3c:	f7f5                	bnez	a5,80000e28 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e3e:	86ba                	mv	a3,a4
    80000e40:	00c05c63          	blez	a2,80000e58 <strncpy+0x38>
    *s++ = 0;
    80000e44:	0685                	addi	a3,a3,1
    80000e46:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e4a:	40d707bb          	subw	a5,a4,a3
    80000e4e:	37fd                	addiw	a5,a5,-1
    80000e50:	010787bb          	addw	a5,a5,a6
    80000e54:	fef048e3          	bgtz	a5,80000e44 <strncpy+0x24>
  return os;
}
    80000e58:	6422                	ld	s0,8(sp)
    80000e5a:	0141                	addi	sp,sp,16
    80000e5c:	8082                	ret

0000000080000e5e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e5e:	1141                	addi	sp,sp,-16
    80000e60:	e422                	sd	s0,8(sp)
    80000e62:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e64:	02c05363          	blez	a2,80000e8a <safestrcpy+0x2c>
    80000e68:	fff6069b          	addiw	a3,a2,-1
    80000e6c:	1682                	slli	a3,a3,0x20
    80000e6e:	9281                	srli	a3,a3,0x20
    80000e70:	96ae                	add	a3,a3,a1
    80000e72:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e74:	00d58963          	beq	a1,a3,80000e86 <safestrcpy+0x28>
    80000e78:	0585                	addi	a1,a1,1
    80000e7a:	0785                	addi	a5,a5,1
    80000e7c:	fff5c703          	lbu	a4,-1(a1)
    80000e80:	fee78fa3          	sb	a4,-1(a5)
    80000e84:	fb65                	bnez	a4,80000e74 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e86:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e8a:	6422                	ld	s0,8(sp)
    80000e8c:	0141                	addi	sp,sp,16
    80000e8e:	8082                	ret

0000000080000e90 <strlen>:

int
strlen(const char *s)
{
    80000e90:	1141                	addi	sp,sp,-16
    80000e92:	e422                	sd	s0,8(sp)
    80000e94:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e96:	00054783          	lbu	a5,0(a0)
    80000e9a:	cf91                	beqz	a5,80000eb6 <strlen+0x26>
    80000e9c:	0505                	addi	a0,a0,1
    80000e9e:	87aa                	mv	a5,a0
    80000ea0:	4685                	li	a3,1
    80000ea2:	9e89                	subw	a3,a3,a0
    80000ea4:	00f6853b          	addw	a0,a3,a5
    80000ea8:	0785                	addi	a5,a5,1
    80000eaa:	fff7c703          	lbu	a4,-1(a5)
    80000eae:	fb7d                	bnez	a4,80000ea4 <strlen+0x14>
    ;
  return n;
}
    80000eb0:	6422                	ld	s0,8(sp)
    80000eb2:	0141                	addi	sp,sp,16
    80000eb4:	8082                	ret
  for(n = 0; s[n]; n++)
    80000eb6:	4501                	li	a0,0
    80000eb8:	bfe5                	j	80000eb0 <strlen+0x20>

0000000080000eba <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000eba:	1141                	addi	sp,sp,-16
    80000ebc:	e406                	sd	ra,8(sp)
    80000ebe:	e022                	sd	s0,0(sp)
    80000ec0:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000ec2:	00001097          	auipc	ra,0x1
    80000ec6:	ece080e7          	jalr	-306(ra) # 80001d90 <cpuid>
    mmrlistinit();  // init the memory list
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000eca:	00009717          	auipc	a4,0x9
    80000ece:	14e70713          	addi	a4,a4,334 # 8000a018 <started>
  if(cpuid() == 0){
    80000ed2:	c139                	beqz	a0,80000f18 <main+0x5e>
    while(started == 0)
    80000ed4:	431c                	lw	a5,0(a4)
    80000ed6:	2781                	sext.w	a5,a5
    80000ed8:	dff5                	beqz	a5,80000ed4 <main+0x1a>
      ;
    __sync_synchronize();
    80000eda:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000ede:	00001097          	auipc	ra,0x1
    80000ee2:	eb2080e7          	jalr	-334(ra) # 80001d90 <cpuid>
    80000ee6:	85aa                	mv	a1,a0
    80000ee8:	00008517          	auipc	a0,0x8
    80000eec:	1d050513          	addi	a0,a0,464 # 800090b8 <digits+0x78>
    80000ef0:	fffff097          	auipc	ra,0xfffff
    80000ef4:	694080e7          	jalr	1684(ra) # 80000584 <printf>
    kvminithart();    // turn on paging
    80000ef8:	00000097          	auipc	ra,0x0
    80000efc:	0e0080e7          	jalr	224(ra) # 80000fd8 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f00:	00002097          	auipc	ra,0x2
    80000f04:	29a080e7          	jalr	666(ra) # 8000319a <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f08:	00006097          	auipc	ra,0x6
    80000f0c:	eb8080e7          	jalr	-328(ra) # 80006dc0 <plicinithart>
  }

  scheduler();        
    80000f10:	00001097          	auipc	ra,0x1
    80000f14:	0d6080e7          	jalr	214(ra) # 80001fe6 <scheduler>
    consoleinit();
    80000f18:	fffff097          	auipc	ra,0xfffff
    80000f1c:	532080e7          	jalr	1330(ra) # 8000044a <consoleinit>
    printfinit();
    80000f20:	00000097          	auipc	ra,0x0
    80000f24:	844080e7          	jalr	-1980(ra) # 80000764 <printfinit>
    printf("\n");
    80000f28:	00008517          	auipc	a0,0x8
    80000f2c:	1a050513          	addi	a0,a0,416 # 800090c8 <digits+0x88>
    80000f30:	fffff097          	auipc	ra,0xfffff
    80000f34:	654080e7          	jalr	1620(ra) # 80000584 <printf>
    printf("xv6 kernel is booting\n");
    80000f38:	00008517          	auipc	a0,0x8
    80000f3c:	16850513          	addi	a0,a0,360 # 800090a0 <digits+0x60>
    80000f40:	fffff097          	auipc	ra,0xfffff
    80000f44:	644080e7          	jalr	1604(ra) # 80000584 <printf>
    printf("\n");
    80000f48:	00008517          	auipc	a0,0x8
    80000f4c:	18050513          	addi	a0,a0,384 # 800090c8 <digits+0x88>
    80000f50:	fffff097          	auipc	ra,0xfffff
    80000f54:	634080e7          	jalr	1588(ra) # 80000584 <printf>
    kinit();         // physical page allocator
    80000f58:	00000097          	auipc	ra,0x0
    80000f5c:	b4c080e7          	jalr	-1204(ra) # 80000aa4 <kinit>
    kvminit();       // create kernel page table
    80000f60:	00000097          	auipc	ra,0x0
    80000f64:	32a080e7          	jalr	810(ra) # 8000128a <kvminit>
    kvminithart();   // turn on paging
    80000f68:	00000097          	auipc	ra,0x0
    80000f6c:	070080e7          	jalr	112(ra) # 80000fd8 <kvminithart>
    procinit();      // process table
    80000f70:	00001097          	auipc	ra,0x1
    80000f74:	d68080e7          	jalr	-664(ra) # 80001cd8 <procinit>
    trapinit();      // trap vectors
    80000f78:	00002097          	auipc	ra,0x2
    80000f7c:	1fa080e7          	jalr	506(ra) # 80003172 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f80:	00002097          	auipc	ra,0x2
    80000f84:	21a080e7          	jalr	538(ra) # 8000319a <trapinithart>
    plicinit();      // set up interrupt controller
    80000f88:	00006097          	auipc	ra,0x6
    80000f8c:	e22080e7          	jalr	-478(ra) # 80006daa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f90:	00006097          	auipc	ra,0x6
    80000f94:	e30080e7          	jalr	-464(ra) # 80006dc0 <plicinithart>
    binit();         // buffer cache
    80000f98:	00003097          	auipc	ra,0x3
    80000f9c:	d22080e7          	jalr	-734(ra) # 80003cba <binit>
    iinit();         // inode table
    80000fa0:	00003097          	auipc	ra,0x3
    80000fa4:	3b0080e7          	jalr	944(ra) # 80004350 <iinit>
    fileinit();      // file table
    80000fa8:	00004097          	auipc	ra,0x4
    80000fac:	362080e7          	jalr	866(ra) # 8000530a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fb0:	00006097          	auipc	ra,0x6
    80000fb4:	f30080e7          	jalr	-208(ra) # 80006ee0 <virtio_disk_init>
    mmrlistinit();  // init the memory list
    80000fb8:	00001097          	auipc	ra,0x1
    80000fbc:	7c0080e7          	jalr	1984(ra) # 80002778 <mmrlistinit>
    userinit();      // first user process
    80000fc0:	00002097          	auipc	ra,0x2
    80000fc4:	b0a080e7          	jalr	-1270(ra) # 80002aca <userinit>
    __sync_synchronize();
    80000fc8:	0ff0000f          	fence
    started = 1;
    80000fcc:	4785                	li	a5,1
    80000fce:	00009717          	auipc	a4,0x9
    80000fd2:	04f72523          	sw	a5,74(a4) # 8000a018 <started>
    80000fd6:	bf2d                	j	80000f10 <main+0x56>

0000000080000fd8 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fd8:	1141                	addi	sp,sp,-16
    80000fda:	e422                	sd	s0,8(sp)
    80000fdc:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000fde:	00009797          	auipc	a5,0x9
    80000fe2:	0427b783          	ld	a5,66(a5) # 8000a020 <kernel_pagetable>
    80000fe6:	83b1                	srli	a5,a5,0xc
    80000fe8:	577d                	li	a4,-1
    80000fea:	177e                	slli	a4,a4,0x3f
    80000fec:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fee:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000ff2:	12000073          	sfence.vma
  sfence_vma();
}
    80000ff6:	6422                	ld	s0,8(sp)
    80000ff8:	0141                	addi	sp,sp,16
    80000ffa:	8082                	ret

0000000080000ffc <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000ffc:	7139                	addi	sp,sp,-64
    80000ffe:	fc06                	sd	ra,56(sp)
    80001000:	f822                	sd	s0,48(sp)
    80001002:	f426                	sd	s1,40(sp)
    80001004:	f04a                	sd	s2,32(sp)
    80001006:	ec4e                	sd	s3,24(sp)
    80001008:	e852                	sd	s4,16(sp)
    8000100a:	e456                	sd	s5,8(sp)
    8000100c:	e05a                	sd	s6,0(sp)
    8000100e:	0080                	addi	s0,sp,64
    80001010:	84aa                	mv	s1,a0
    80001012:	89ae                	mv	s3,a1
    80001014:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001016:	57fd                	li	a5,-1
    80001018:	83e9                	srli	a5,a5,0x1a
    8000101a:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000101c:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000101e:	04b7f263          	bgeu	a5,a1,80001062 <walk+0x66>
    panic("walk");
    80001022:	00008517          	auipc	a0,0x8
    80001026:	0ae50513          	addi	a0,a0,174 # 800090d0 <digits+0x90>
    8000102a:	fffff097          	auipc	ra,0xfffff
    8000102e:	510080e7          	jalr	1296(ra) # 8000053a <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001032:	060a8663          	beqz	s5,8000109e <walk+0xa2>
    80001036:	00000097          	auipc	ra,0x0
    8000103a:	aaa080e7          	jalr	-1366(ra) # 80000ae0 <kalloc>
    8000103e:	84aa                	mv	s1,a0
    80001040:	c529                	beqz	a0,8000108a <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001042:	6605                	lui	a2,0x1
    80001044:	4581                	li	a1,0
    80001046:	00000097          	auipc	ra,0x0
    8000104a:	cce080e7          	jalr	-818(ra) # 80000d14 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000104e:	00c4d793          	srli	a5,s1,0xc
    80001052:	07aa                	slli	a5,a5,0xa
    80001054:	0017e793          	ori	a5,a5,1
    80001058:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000105c:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffc6ff7>
    8000105e:	036a0063          	beq	s4,s6,8000107e <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001062:	0149d933          	srl	s2,s3,s4
    80001066:	1ff97913          	andi	s2,s2,511
    8000106a:	090e                	slli	s2,s2,0x3
    8000106c:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000106e:	00093483          	ld	s1,0(s2)
    80001072:	0014f793          	andi	a5,s1,1
    80001076:	dfd5                	beqz	a5,80001032 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001078:	80a9                	srli	s1,s1,0xa
    8000107a:	04b2                	slli	s1,s1,0xc
    8000107c:	b7c5                	j	8000105c <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000107e:	00c9d513          	srli	a0,s3,0xc
    80001082:	1ff57513          	andi	a0,a0,511
    80001086:	050e                	slli	a0,a0,0x3
    80001088:	9526                	add	a0,a0,s1
}
    8000108a:	70e2                	ld	ra,56(sp)
    8000108c:	7442                	ld	s0,48(sp)
    8000108e:	74a2                	ld	s1,40(sp)
    80001090:	7902                	ld	s2,32(sp)
    80001092:	69e2                	ld	s3,24(sp)
    80001094:	6a42                	ld	s4,16(sp)
    80001096:	6aa2                	ld	s5,8(sp)
    80001098:	6b02                	ld	s6,0(sp)
    8000109a:	6121                	addi	sp,sp,64
    8000109c:	8082                	ret
        return 0;
    8000109e:	4501                	li	a0,0
    800010a0:	b7ed                	j	8000108a <walk+0x8e>

00000000800010a2 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010a2:	57fd                	li	a5,-1
    800010a4:	83e9                	srli	a5,a5,0x1a
    800010a6:	00b7f463          	bgeu	a5,a1,800010ae <walkaddr+0xc>
    return 0;
    800010aa:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010ac:	8082                	ret
{
    800010ae:	1141                	addi	sp,sp,-16
    800010b0:	e406                	sd	ra,8(sp)
    800010b2:	e022                	sd	s0,0(sp)
    800010b4:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010b6:	4601                	li	a2,0
    800010b8:	00000097          	auipc	ra,0x0
    800010bc:	f44080e7          	jalr	-188(ra) # 80000ffc <walk>
  if(pte == 0)
    800010c0:	c105                	beqz	a0,800010e0 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010c2:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010c4:	0117f693          	andi	a3,a5,17
    800010c8:	4745                	li	a4,17
    return 0;
    800010ca:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010cc:	00e68663          	beq	a3,a4,800010d8 <walkaddr+0x36>
}
    800010d0:	60a2                	ld	ra,8(sp)
    800010d2:	6402                	ld	s0,0(sp)
    800010d4:	0141                	addi	sp,sp,16
    800010d6:	8082                	ret
  pa = PTE2PA(*pte);
    800010d8:	83a9                	srli	a5,a5,0xa
    800010da:	00c79513          	slli	a0,a5,0xc
  return pa;
    800010de:	bfcd                	j	800010d0 <walkaddr+0x2e>
    return 0;
    800010e0:	4501                	li	a0,0
    800010e2:	b7fd                	j	800010d0 <walkaddr+0x2e>

00000000800010e4 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010e4:	715d                	addi	sp,sp,-80
    800010e6:	e486                	sd	ra,72(sp)
    800010e8:	e0a2                	sd	s0,64(sp)
    800010ea:	fc26                	sd	s1,56(sp)
    800010ec:	f84a                	sd	s2,48(sp)
    800010ee:	f44e                	sd	s3,40(sp)
    800010f0:	f052                	sd	s4,32(sp)
    800010f2:	ec56                	sd	s5,24(sp)
    800010f4:	e85a                	sd	s6,16(sp)
    800010f6:	e45e                	sd	s7,8(sp)
    800010f8:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010fa:	c639                	beqz	a2,80001148 <mappages+0x64>
    800010fc:	8aaa                	mv	s5,a0
    800010fe:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    80001100:	777d                	lui	a4,0xfffff
    80001102:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001106:	fff58993          	addi	s3,a1,-1
    8000110a:	99b2                	add	s3,s3,a2
    8000110c:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001110:	893e                	mv	s2,a5
    80001112:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001116:	6b85                	lui	s7,0x1
    80001118:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000111c:	4605                	li	a2,1
    8000111e:	85ca                	mv	a1,s2
    80001120:	8556                	mv	a0,s5
    80001122:	00000097          	auipc	ra,0x0
    80001126:	eda080e7          	jalr	-294(ra) # 80000ffc <walk>
    8000112a:	cd1d                	beqz	a0,80001168 <mappages+0x84>
    if(*pte & PTE_V)
    8000112c:	611c                	ld	a5,0(a0)
    8000112e:	8b85                	andi	a5,a5,1
    80001130:	e785                	bnez	a5,80001158 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001132:	80b1                	srli	s1,s1,0xc
    80001134:	04aa                	slli	s1,s1,0xa
    80001136:	0164e4b3          	or	s1,s1,s6
    8000113a:	0014e493          	ori	s1,s1,1
    8000113e:	e104                	sd	s1,0(a0)
    if(a == last)
    80001140:	05390063          	beq	s2,s3,80001180 <mappages+0x9c>
    a += PGSIZE;
    80001144:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001146:	bfc9                	j	80001118 <mappages+0x34>
    panic("mappages: size");
    80001148:	00008517          	auipc	a0,0x8
    8000114c:	f9050513          	addi	a0,a0,-112 # 800090d8 <digits+0x98>
    80001150:	fffff097          	auipc	ra,0xfffff
    80001154:	3ea080e7          	jalr	1002(ra) # 8000053a <panic>
      panic("mappages: remap");
    80001158:	00008517          	auipc	a0,0x8
    8000115c:	f9050513          	addi	a0,a0,-112 # 800090e8 <digits+0xa8>
    80001160:	fffff097          	auipc	ra,0xfffff
    80001164:	3da080e7          	jalr	986(ra) # 8000053a <panic>
      return -1;
    80001168:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000116a:	60a6                	ld	ra,72(sp)
    8000116c:	6406                	ld	s0,64(sp)
    8000116e:	74e2                	ld	s1,56(sp)
    80001170:	7942                	ld	s2,48(sp)
    80001172:	79a2                	ld	s3,40(sp)
    80001174:	7a02                	ld	s4,32(sp)
    80001176:	6ae2                	ld	s5,24(sp)
    80001178:	6b42                	ld	s6,16(sp)
    8000117a:	6ba2                	ld	s7,8(sp)
    8000117c:	6161                	addi	sp,sp,80
    8000117e:	8082                	ret
  return 0;
    80001180:	4501                	li	a0,0
    80001182:	b7e5                	j	8000116a <mappages+0x86>

0000000080001184 <kvmmap>:
{
    80001184:	1141                	addi	sp,sp,-16
    80001186:	e406                	sd	ra,8(sp)
    80001188:	e022                	sd	s0,0(sp)
    8000118a:	0800                	addi	s0,sp,16
    8000118c:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000118e:	86b2                	mv	a3,a2
    80001190:	863e                	mv	a2,a5
    80001192:	00000097          	auipc	ra,0x0
    80001196:	f52080e7          	jalr	-174(ra) # 800010e4 <mappages>
    8000119a:	e509                	bnez	a0,800011a4 <kvmmap+0x20>
}
    8000119c:	60a2                	ld	ra,8(sp)
    8000119e:	6402                	ld	s0,0(sp)
    800011a0:	0141                	addi	sp,sp,16
    800011a2:	8082                	ret
    panic("kvmmap");
    800011a4:	00008517          	auipc	a0,0x8
    800011a8:	f5450513          	addi	a0,a0,-172 # 800090f8 <digits+0xb8>
    800011ac:	fffff097          	auipc	ra,0xfffff
    800011b0:	38e080e7          	jalr	910(ra) # 8000053a <panic>

00000000800011b4 <kvmmake>:
{
    800011b4:	1101                	addi	sp,sp,-32
    800011b6:	ec06                	sd	ra,24(sp)
    800011b8:	e822                	sd	s0,16(sp)
    800011ba:	e426                	sd	s1,8(sp)
    800011bc:	e04a                	sd	s2,0(sp)
    800011be:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800011c0:	00000097          	auipc	ra,0x0
    800011c4:	920080e7          	jalr	-1760(ra) # 80000ae0 <kalloc>
    800011c8:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011ca:	6605                	lui	a2,0x1
    800011cc:	4581                	li	a1,0
    800011ce:	00000097          	auipc	ra,0x0
    800011d2:	b46080e7          	jalr	-1210(ra) # 80000d14 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011d6:	4719                	li	a4,6
    800011d8:	6685                	lui	a3,0x1
    800011da:	10000637          	lui	a2,0x10000
    800011de:	100005b7          	lui	a1,0x10000
    800011e2:	8526                	mv	a0,s1
    800011e4:	00000097          	auipc	ra,0x0
    800011e8:	fa0080e7          	jalr	-96(ra) # 80001184 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011ec:	4719                	li	a4,6
    800011ee:	6685                	lui	a3,0x1
    800011f0:	10001637          	lui	a2,0x10001
    800011f4:	100015b7          	lui	a1,0x10001
    800011f8:	8526                	mv	a0,s1
    800011fa:	00000097          	auipc	ra,0x0
    800011fe:	f8a080e7          	jalr	-118(ra) # 80001184 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001202:	4719                	li	a4,6
    80001204:	004006b7          	lui	a3,0x400
    80001208:	0c000637          	lui	a2,0xc000
    8000120c:	0c0005b7          	lui	a1,0xc000
    80001210:	8526                	mv	a0,s1
    80001212:	00000097          	auipc	ra,0x0
    80001216:	f72080e7          	jalr	-142(ra) # 80001184 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000121a:	00008917          	auipc	s2,0x8
    8000121e:	de690913          	addi	s2,s2,-538 # 80009000 <etext>
    80001222:	4729                	li	a4,10
    80001224:	80008697          	auipc	a3,0x80008
    80001228:	ddc68693          	addi	a3,a3,-548 # 9000 <_entry-0x7fff7000>
    8000122c:	4605                	li	a2,1
    8000122e:	067e                	slli	a2,a2,0x1f
    80001230:	85b2                	mv	a1,a2
    80001232:	8526                	mv	a0,s1
    80001234:	00000097          	auipc	ra,0x0
    80001238:	f50080e7          	jalr	-176(ra) # 80001184 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000123c:	4719                	li	a4,6
    8000123e:	46c5                	li	a3,17
    80001240:	06ee                	slli	a3,a3,0x1b
    80001242:	412686b3          	sub	a3,a3,s2
    80001246:	864a                	mv	a2,s2
    80001248:	85ca                	mv	a1,s2
    8000124a:	8526                	mv	a0,s1
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	f38080e7          	jalr	-200(ra) # 80001184 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001254:	4729                	li	a4,10
    80001256:	6685                	lui	a3,0x1
    80001258:	00007617          	auipc	a2,0x7
    8000125c:	da860613          	addi	a2,a2,-600 # 80008000 <_trampoline>
    80001260:	040005b7          	lui	a1,0x4000
    80001264:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001266:	05b2                	slli	a1,a1,0xc
    80001268:	8526                	mv	a0,s1
    8000126a:	00000097          	auipc	ra,0x0
    8000126e:	f1a080e7          	jalr	-230(ra) # 80001184 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001272:	8526                	mv	a0,s1
    80001274:	00001097          	auipc	ra,0x1
    80001278:	9ce080e7          	jalr	-1586(ra) # 80001c42 <proc_mapstacks>
}
    8000127c:	8526                	mv	a0,s1
    8000127e:	60e2                	ld	ra,24(sp)
    80001280:	6442                	ld	s0,16(sp)
    80001282:	64a2                	ld	s1,8(sp)
    80001284:	6902                	ld	s2,0(sp)
    80001286:	6105                	addi	sp,sp,32
    80001288:	8082                	ret

000000008000128a <kvminit>:
{
    8000128a:	1141                	addi	sp,sp,-16
    8000128c:	e406                	sd	ra,8(sp)
    8000128e:	e022                	sd	s0,0(sp)
    80001290:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001292:	00000097          	auipc	ra,0x0
    80001296:	f22080e7          	jalr	-222(ra) # 800011b4 <kvmmake>
    8000129a:	00009797          	auipc	a5,0x9
    8000129e:	d8a7b323          	sd	a0,-634(a5) # 8000a020 <kernel_pagetable>
}
    800012a2:	60a2                	ld	ra,8(sp)
    800012a4:	6402                	ld	s0,0(sp)
    800012a6:	0141                	addi	sp,sp,16
    800012a8:	8082                	ret

00000000800012aa <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012aa:	715d                	addi	sp,sp,-80
    800012ac:	e486                	sd	ra,72(sp)
    800012ae:	e0a2                	sd	s0,64(sp)
    800012b0:	fc26                	sd	s1,56(sp)
    800012b2:	f84a                	sd	s2,48(sp)
    800012b4:	f44e                	sd	s3,40(sp)
    800012b6:	f052                	sd	s4,32(sp)
    800012b8:	ec56                	sd	s5,24(sp)
    800012ba:	e85a                	sd	s6,16(sp)
    800012bc:	e45e                	sd	s7,8(sp)
    800012be:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012c0:	03459793          	slli	a5,a1,0x34
    800012c4:	e795                	bnez	a5,800012f0 <uvmunmap+0x46>
    800012c6:	8a2a                	mv	s4,a0
    800012c8:	892e                	mv	s2,a1
    800012ca:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012cc:	0632                	slli	a2,a2,0xc
    800012ce:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012d2:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012d4:	6b05                	lui	s6,0x1
    800012d6:	0735e263          	bltu	a1,s3,8000133a <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012da:	60a6                	ld	ra,72(sp)
    800012dc:	6406                	ld	s0,64(sp)
    800012de:	74e2                	ld	s1,56(sp)
    800012e0:	7942                	ld	s2,48(sp)
    800012e2:	79a2                	ld	s3,40(sp)
    800012e4:	7a02                	ld	s4,32(sp)
    800012e6:	6ae2                	ld	s5,24(sp)
    800012e8:	6b42                	ld	s6,16(sp)
    800012ea:	6ba2                	ld	s7,8(sp)
    800012ec:	6161                	addi	sp,sp,80
    800012ee:	8082                	ret
    panic("uvmunmap: not aligned");
    800012f0:	00008517          	auipc	a0,0x8
    800012f4:	e1050513          	addi	a0,a0,-496 # 80009100 <digits+0xc0>
    800012f8:	fffff097          	auipc	ra,0xfffff
    800012fc:	242080e7          	jalr	578(ra) # 8000053a <panic>
      panic("uvmunmap: walk");
    80001300:	00008517          	auipc	a0,0x8
    80001304:	e1850513          	addi	a0,a0,-488 # 80009118 <digits+0xd8>
    80001308:	fffff097          	auipc	ra,0xfffff
    8000130c:	232080e7          	jalr	562(ra) # 8000053a <panic>
      panic("uvmunmap: not mapped");
    80001310:	00008517          	auipc	a0,0x8
    80001314:	e1850513          	addi	a0,a0,-488 # 80009128 <digits+0xe8>
    80001318:	fffff097          	auipc	ra,0xfffff
    8000131c:	222080e7          	jalr	546(ra) # 8000053a <panic>
      panic("uvmunmap: not a leaf");
    80001320:	00008517          	auipc	a0,0x8
    80001324:	e2050513          	addi	a0,a0,-480 # 80009140 <digits+0x100>
    80001328:	fffff097          	auipc	ra,0xfffff
    8000132c:	212080e7          	jalr	530(ra) # 8000053a <panic>
    *pte = 0;
    80001330:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001334:	995a                	add	s2,s2,s6
    80001336:	fb3972e3          	bgeu	s2,s3,800012da <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    8000133a:	4601                	li	a2,0
    8000133c:	85ca                	mv	a1,s2
    8000133e:	8552                	mv	a0,s4
    80001340:	00000097          	auipc	ra,0x0
    80001344:	cbc080e7          	jalr	-836(ra) # 80000ffc <walk>
    80001348:	84aa                	mv	s1,a0
    8000134a:	d95d                	beqz	a0,80001300 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    8000134c:	6108                	ld	a0,0(a0)
    8000134e:	00157793          	andi	a5,a0,1
    80001352:	dfdd                	beqz	a5,80001310 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001354:	3ff57793          	andi	a5,a0,1023
    80001358:	fd7784e3          	beq	a5,s7,80001320 <uvmunmap+0x76>
    if(do_free){
    8000135c:	fc0a8ae3          	beqz	s5,80001330 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001360:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001362:	0532                	slli	a0,a0,0xc
    80001364:	fffff097          	auipc	ra,0xfffff
    80001368:	67e080e7          	jalr	1662(ra) # 800009e2 <kfree>
    8000136c:	b7d1                	j	80001330 <uvmunmap+0x86>

000000008000136e <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000136e:	1101                	addi	sp,sp,-32
    80001370:	ec06                	sd	ra,24(sp)
    80001372:	e822                	sd	s0,16(sp)
    80001374:	e426                	sd	s1,8(sp)
    80001376:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001378:	fffff097          	auipc	ra,0xfffff
    8000137c:	768080e7          	jalr	1896(ra) # 80000ae0 <kalloc>
    80001380:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001382:	c519                	beqz	a0,80001390 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001384:	6605                	lui	a2,0x1
    80001386:	4581                	li	a1,0
    80001388:	00000097          	auipc	ra,0x0
    8000138c:	98c080e7          	jalr	-1652(ra) # 80000d14 <memset>
  return pagetable;
}
    80001390:	8526                	mv	a0,s1
    80001392:	60e2                	ld	ra,24(sp)
    80001394:	6442                	ld	s0,16(sp)
    80001396:	64a2                	ld	s1,8(sp)
    80001398:	6105                	addi	sp,sp,32
    8000139a:	8082                	ret

000000008000139c <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    8000139c:	7179                	addi	sp,sp,-48
    8000139e:	f406                	sd	ra,40(sp)
    800013a0:	f022                	sd	s0,32(sp)
    800013a2:	ec26                	sd	s1,24(sp)
    800013a4:	e84a                	sd	s2,16(sp)
    800013a6:	e44e                	sd	s3,8(sp)
    800013a8:	e052                	sd	s4,0(sp)
    800013aa:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800013ac:	6785                	lui	a5,0x1
    800013ae:	04f67863          	bgeu	a2,a5,800013fe <uvminit+0x62>
    800013b2:	8a2a                	mv	s4,a0
    800013b4:	89ae                	mv	s3,a1
    800013b6:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    800013b8:	fffff097          	auipc	ra,0xfffff
    800013bc:	728080e7          	jalr	1832(ra) # 80000ae0 <kalloc>
    800013c0:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800013c2:	6605                	lui	a2,0x1
    800013c4:	4581                	li	a1,0
    800013c6:	00000097          	auipc	ra,0x0
    800013ca:	94e080e7          	jalr	-1714(ra) # 80000d14 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013ce:	4779                	li	a4,30
    800013d0:	86ca                	mv	a3,s2
    800013d2:	6605                	lui	a2,0x1
    800013d4:	4581                	li	a1,0
    800013d6:	8552                	mv	a0,s4
    800013d8:	00000097          	auipc	ra,0x0
    800013dc:	d0c080e7          	jalr	-756(ra) # 800010e4 <mappages>
  memmove(mem, src, sz);
    800013e0:	8626                	mv	a2,s1
    800013e2:	85ce                	mv	a1,s3
    800013e4:	854a                	mv	a0,s2
    800013e6:	00000097          	auipc	ra,0x0
    800013ea:	98a080e7          	jalr	-1654(ra) # 80000d70 <memmove>
}
    800013ee:	70a2                	ld	ra,40(sp)
    800013f0:	7402                	ld	s0,32(sp)
    800013f2:	64e2                	ld	s1,24(sp)
    800013f4:	6942                	ld	s2,16(sp)
    800013f6:	69a2                	ld	s3,8(sp)
    800013f8:	6a02                	ld	s4,0(sp)
    800013fa:	6145                	addi	sp,sp,48
    800013fc:	8082                	ret
    panic("inituvm: more than a page");
    800013fe:	00008517          	auipc	a0,0x8
    80001402:	d5a50513          	addi	a0,a0,-678 # 80009158 <digits+0x118>
    80001406:	fffff097          	auipc	ra,0xfffff
    8000140a:	134080e7          	jalr	308(ra) # 8000053a <panic>

000000008000140e <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000140e:	1101                	addi	sp,sp,-32
    80001410:	ec06                	sd	ra,24(sp)
    80001412:	e822                	sd	s0,16(sp)
    80001414:	e426                	sd	s1,8(sp)
    80001416:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001418:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000141a:	00b67d63          	bgeu	a2,a1,80001434 <uvmdealloc+0x26>
    8000141e:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001420:	6785                	lui	a5,0x1
    80001422:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001424:	00f60733          	add	a4,a2,a5
    80001428:	76fd                	lui	a3,0xfffff
    8000142a:	8f75                	and	a4,a4,a3
    8000142c:	97ae                	add	a5,a5,a1
    8000142e:	8ff5                	and	a5,a5,a3
    80001430:	00f76863          	bltu	a4,a5,80001440 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001434:	8526                	mv	a0,s1
    80001436:	60e2                	ld	ra,24(sp)
    80001438:	6442                	ld	s0,16(sp)
    8000143a:	64a2                	ld	s1,8(sp)
    8000143c:	6105                	addi	sp,sp,32
    8000143e:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001440:	8f99                	sub	a5,a5,a4
    80001442:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001444:	4685                	li	a3,1
    80001446:	0007861b          	sext.w	a2,a5
    8000144a:	85ba                	mv	a1,a4
    8000144c:	00000097          	auipc	ra,0x0
    80001450:	e5e080e7          	jalr	-418(ra) # 800012aa <uvmunmap>
    80001454:	b7c5                	j	80001434 <uvmdealloc+0x26>

0000000080001456 <uvmalloc>:
  if(newsz < oldsz)
    80001456:	0ab66163          	bltu	a2,a1,800014f8 <uvmalloc+0xa2>
{
    8000145a:	7139                	addi	sp,sp,-64
    8000145c:	fc06                	sd	ra,56(sp)
    8000145e:	f822                	sd	s0,48(sp)
    80001460:	f426                	sd	s1,40(sp)
    80001462:	f04a                	sd	s2,32(sp)
    80001464:	ec4e                	sd	s3,24(sp)
    80001466:	e852                	sd	s4,16(sp)
    80001468:	e456                	sd	s5,8(sp)
    8000146a:	0080                	addi	s0,sp,64
    8000146c:	8aaa                	mv	s5,a0
    8000146e:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001470:	6785                	lui	a5,0x1
    80001472:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001474:	95be                	add	a1,a1,a5
    80001476:	77fd                	lui	a5,0xfffff
    80001478:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000147c:	08c9f063          	bgeu	s3,a2,800014fc <uvmalloc+0xa6>
    80001480:	894e                	mv	s2,s3
    mem = kalloc();
    80001482:	fffff097          	auipc	ra,0xfffff
    80001486:	65e080e7          	jalr	1630(ra) # 80000ae0 <kalloc>
    8000148a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000148c:	c51d                	beqz	a0,800014ba <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000148e:	6605                	lui	a2,0x1
    80001490:	4581                	li	a1,0
    80001492:	00000097          	auipc	ra,0x0
    80001496:	882080e7          	jalr	-1918(ra) # 80000d14 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    8000149a:	4779                	li	a4,30
    8000149c:	86a6                	mv	a3,s1
    8000149e:	6605                	lui	a2,0x1
    800014a0:	85ca                	mv	a1,s2
    800014a2:	8556                	mv	a0,s5
    800014a4:	00000097          	auipc	ra,0x0
    800014a8:	c40080e7          	jalr	-960(ra) # 800010e4 <mappages>
    800014ac:	e905                	bnez	a0,800014dc <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014ae:	6785                	lui	a5,0x1
    800014b0:	993e                	add	s2,s2,a5
    800014b2:	fd4968e3          	bltu	s2,s4,80001482 <uvmalloc+0x2c>
  return newsz;
    800014b6:	8552                	mv	a0,s4
    800014b8:	a809                	j	800014ca <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800014ba:	864e                	mv	a2,s3
    800014bc:	85ca                	mv	a1,s2
    800014be:	8556                	mv	a0,s5
    800014c0:	00000097          	auipc	ra,0x0
    800014c4:	f4e080e7          	jalr	-178(ra) # 8000140e <uvmdealloc>
      return 0;
    800014c8:	4501                	li	a0,0
}
    800014ca:	70e2                	ld	ra,56(sp)
    800014cc:	7442                	ld	s0,48(sp)
    800014ce:	74a2                	ld	s1,40(sp)
    800014d0:	7902                	ld	s2,32(sp)
    800014d2:	69e2                	ld	s3,24(sp)
    800014d4:	6a42                	ld	s4,16(sp)
    800014d6:	6aa2                	ld	s5,8(sp)
    800014d8:	6121                	addi	sp,sp,64
    800014da:	8082                	ret
      kfree(mem);
    800014dc:	8526                	mv	a0,s1
    800014de:	fffff097          	auipc	ra,0xfffff
    800014e2:	504080e7          	jalr	1284(ra) # 800009e2 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014e6:	864e                	mv	a2,s3
    800014e8:	85ca                	mv	a1,s2
    800014ea:	8556                	mv	a0,s5
    800014ec:	00000097          	auipc	ra,0x0
    800014f0:	f22080e7          	jalr	-222(ra) # 8000140e <uvmdealloc>
      return 0;
    800014f4:	4501                	li	a0,0
    800014f6:	bfd1                	j	800014ca <uvmalloc+0x74>
    return oldsz;
    800014f8:	852e                	mv	a0,a1
}
    800014fa:	8082                	ret
  return newsz;
    800014fc:	8532                	mv	a0,a2
    800014fe:	b7f1                	j	800014ca <uvmalloc+0x74>

0000000080001500 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001500:	7179                	addi	sp,sp,-48
    80001502:	f406                	sd	ra,40(sp)
    80001504:	f022                	sd	s0,32(sp)
    80001506:	ec26                	sd	s1,24(sp)
    80001508:	e84a                	sd	s2,16(sp)
    8000150a:	e44e                	sd	s3,8(sp)
    8000150c:	e052                	sd	s4,0(sp)
    8000150e:	1800                	addi	s0,sp,48
    80001510:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001512:	84aa                	mv	s1,a0
    80001514:	6905                	lui	s2,0x1
    80001516:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001518:	4985                	li	s3,1
    8000151a:	a829                	j	80001534 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000151c:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    8000151e:	00c79513          	slli	a0,a5,0xc
    80001522:	00000097          	auipc	ra,0x0
    80001526:	fde080e7          	jalr	-34(ra) # 80001500 <freewalk>
      pagetable[i] = 0;
    8000152a:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000152e:	04a1                	addi	s1,s1,8
    80001530:	03248163          	beq	s1,s2,80001552 <freewalk+0x52>
    pte_t pte = pagetable[i];
    80001534:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001536:	00f7f713          	andi	a4,a5,15
    8000153a:	ff3701e3          	beq	a4,s3,8000151c <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000153e:	8b85                	andi	a5,a5,1
    80001540:	d7fd                	beqz	a5,8000152e <freewalk+0x2e>
      panic("freewalk: leaf");
    80001542:	00008517          	auipc	a0,0x8
    80001546:	c3650513          	addi	a0,a0,-970 # 80009178 <digits+0x138>
    8000154a:	fffff097          	auipc	ra,0xfffff
    8000154e:	ff0080e7          	jalr	-16(ra) # 8000053a <panic>
    }
  }
  kfree((void*)pagetable);
    80001552:	8552                	mv	a0,s4
    80001554:	fffff097          	auipc	ra,0xfffff
    80001558:	48e080e7          	jalr	1166(ra) # 800009e2 <kfree>
}
    8000155c:	70a2                	ld	ra,40(sp)
    8000155e:	7402                	ld	s0,32(sp)
    80001560:	64e2                	ld	s1,24(sp)
    80001562:	6942                	ld	s2,16(sp)
    80001564:	69a2                	ld	s3,8(sp)
    80001566:	6a02                	ld	s4,0(sp)
    80001568:	6145                	addi	sp,sp,48
    8000156a:	8082                	ret

000000008000156c <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000156c:	1101                	addi	sp,sp,-32
    8000156e:	ec06                	sd	ra,24(sp)
    80001570:	e822                	sd	s0,16(sp)
    80001572:	e426                	sd	s1,8(sp)
    80001574:	1000                	addi	s0,sp,32
    80001576:	84aa                	mv	s1,a0
  if(sz > 0)
    80001578:	e999                	bnez	a1,8000158e <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000157a:	8526                	mv	a0,s1
    8000157c:	00000097          	auipc	ra,0x0
    80001580:	f84080e7          	jalr	-124(ra) # 80001500 <freewalk>
}
    80001584:	60e2                	ld	ra,24(sp)
    80001586:	6442                	ld	s0,16(sp)
    80001588:	64a2                	ld	s1,8(sp)
    8000158a:	6105                	addi	sp,sp,32
    8000158c:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000158e:	6785                	lui	a5,0x1
    80001590:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001592:	95be                	add	a1,a1,a5
    80001594:	4685                	li	a3,1
    80001596:	00c5d613          	srli	a2,a1,0xc
    8000159a:	4581                	li	a1,0
    8000159c:	00000097          	auipc	ra,0x0
    800015a0:	d0e080e7          	jalr	-754(ra) # 800012aa <uvmunmap>
    800015a4:	bfd9                	j	8000157a <uvmfree+0xe>

00000000800015a6 <uvmcopy>:
//   return -1;
// }

int
uvmcopy(pagetable_t old, pagetable_t new, uint64 start, uint64 end)
{
    800015a6:	715d                	addi	sp,sp,-80
    800015a8:	e486                	sd	ra,72(sp)
    800015aa:	e0a2                	sd	s0,64(sp)
    800015ac:	fc26                	sd	s1,56(sp)
    800015ae:	f84a                	sd	s2,48(sp)
    800015b0:	f44e                	sd	s3,40(sp)
    800015b2:	f052                	sd	s4,32(sp)
    800015b4:	ec56                	sd	s5,24(sp)
    800015b6:	e85a                	sd	s6,16(sp)
    800015b8:	e45e                	sd	s7,8(sp)
    800015ba:	0880                	addi	s0,sp,80
    800015bc:	8b2a                	mv	s6,a0
    800015be:	8aae                	mv	s5,a1
    800015c0:	89b2                	mv	s3,a2
    800015c2:	8a36                	mv	s4,a3
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;
  for(i = start; i < end; i += PGSIZE){
    800015c4:	0ad67963          	bgeu	a2,a3,80001676 <uvmcopy+0xd0>
    if((pte = walk(old, i, 0)) == 0)
    800015c8:	4601                	li	a2,0
    800015ca:	85ce                	mv	a1,s3
    800015cc:	855a                	mv	a0,s6
    800015ce:	00000097          	auipc	ra,0x0
    800015d2:	a2e080e7          	jalr	-1490(ra) # 80000ffc <walk>
    800015d6:	c531                	beqz	a0,80001622 <uvmcopy+0x7c>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800015d8:	6118                	ld	a4,0(a0)
    800015da:	00177793          	andi	a5,a4,1
    800015de:	cbb1                	beqz	a5,80001632 <uvmcopy+0x8c>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015e0:	00a75593          	srli	a1,a4,0xa
    800015e4:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015e8:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015ec:	fffff097          	auipc	ra,0xfffff
    800015f0:	4f4080e7          	jalr	1268(ra) # 80000ae0 <kalloc>
    800015f4:	892a                	mv	s2,a0
    800015f6:	c939                	beqz	a0,8000164c <uvmcopy+0xa6>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015f8:	6605                	lui	a2,0x1
    800015fa:	85de                	mv	a1,s7
    800015fc:	fffff097          	auipc	ra,0xfffff
    80001600:	774080e7          	jalr	1908(ra) # 80000d70 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001604:	8726                	mv	a4,s1
    80001606:	86ca                	mv	a3,s2
    80001608:	6605                	lui	a2,0x1
    8000160a:	85ce                	mv	a1,s3
    8000160c:	8556                	mv	a0,s5
    8000160e:	00000097          	auipc	ra,0x0
    80001612:	ad6080e7          	jalr	-1322(ra) # 800010e4 <mappages>
    80001616:	e515                	bnez	a0,80001642 <uvmcopy+0x9c>
  for(i = start; i < end; i += PGSIZE){
    80001618:	6785                	lui	a5,0x1
    8000161a:	99be                	add	s3,s3,a5
    8000161c:	fb49e6e3          	bltu	s3,s4,800015c8 <uvmcopy+0x22>
    80001620:	a081                	j	80001660 <uvmcopy+0xba>
      panic("uvmcopy: pte should exist");
    80001622:	00008517          	auipc	a0,0x8
    80001626:	b6650513          	addi	a0,a0,-1178 # 80009188 <digits+0x148>
    8000162a:	fffff097          	auipc	ra,0xfffff
    8000162e:	f10080e7          	jalr	-240(ra) # 8000053a <panic>
      panic("uvmcopy: page not present");
    80001632:	00008517          	auipc	a0,0x8
    80001636:	b7650513          	addi	a0,a0,-1162 # 800091a8 <digits+0x168>
    8000163a:	fffff097          	auipc	ra,0xfffff
    8000163e:	f00080e7          	jalr	-256(ra) # 8000053a <panic>
      kfree(mem);
    80001642:	854a                	mv	a0,s2
    80001644:	fffff097          	auipc	ra,0xfffff
    80001648:	39e080e7          	jalr	926(ra) # 800009e2 <kfree>
      goto err;
    }
  }
  return 0;
  err:
    uvmunmap(new, 0, i / PGSIZE, 1);
    8000164c:	4685                	li	a3,1
    8000164e:	00c9d613          	srli	a2,s3,0xc
    80001652:	4581                	li	a1,0
    80001654:	8556                	mv	a0,s5
    80001656:	00000097          	auipc	ra,0x0
    8000165a:	c54080e7          	jalr	-940(ra) # 800012aa <uvmunmap>
    return -1;
    8000165e:	557d                	li	a0,-1
}
    80001660:	60a6                	ld	ra,72(sp)
    80001662:	6406                	ld	s0,64(sp)
    80001664:	74e2                	ld	s1,56(sp)
    80001666:	7942                	ld	s2,48(sp)
    80001668:	79a2                	ld	s3,40(sp)
    8000166a:	7a02                	ld	s4,32(sp)
    8000166c:	6ae2                	ld	s5,24(sp)
    8000166e:	6b42                	ld	s6,16(sp)
    80001670:	6ba2                	ld	s7,8(sp)
    80001672:	6161                	addi	sp,sp,80
    80001674:	8082                	ret
  return 0;
    80001676:	4501                	li	a0,0
    80001678:	b7e5                	j	80001660 <uvmcopy+0xba>

000000008000167a <uvmcopyshared>:

int
uvmcopyshared(pagetable_t old, pagetable_t new, uint64 start, uint64 end)
{
    8000167a:	7179                	addi	sp,sp,-48
    8000167c:	f406                	sd	ra,40(sp)
    8000167e:	f022                	sd	s0,32(sp)
    80001680:	ec26                	sd	s1,24(sp)
    80001682:	e84a                	sd	s2,16(sp)
    80001684:	e44e                	sd	s3,8(sp)
    80001686:	e052                	sd	s4,0(sp)
    80001688:	1800                	addi	s0,sp,48
    8000168a:	8a2a                	mv	s4,a0
    8000168c:	89ae                	mv	s3,a1
    8000168e:	84b2                	mv	s1,a2
    80001690:	8936                	mv	s2,a3
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  for(i = start; i < end; i += PGSIZE){
    80001692:	08d67263          	bgeu	a2,a3,80001716 <uvmcopyshared+0x9c>
    if((pte = walk(old, i, 0)) == 0)
    80001696:	4601                	li	a2,0
    80001698:	85a6                	mv	a1,s1
    8000169a:	8552                	mv	a0,s4
    8000169c:	00000097          	auipc	ra,0x0
    800016a0:	960080e7          	jalr	-1696(ra) # 80000ffc <walk>
    800016a4:	c51d                	beqz	a0,800016d2 <uvmcopyshared+0x58>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800016a6:	6118                	ld	a4,0(a0)
    800016a8:	00177793          	andi	a5,a4,1
    800016ac:	cb9d                	beqz	a5,800016e2 <uvmcopyshared+0x68>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800016ae:	00a75693          	srli	a3,a4,0xa
    flags = PTE_FLAGS(*pte);
    if(mappages(new, i, PGSIZE, (uint64)pa, flags) != 0){
    800016b2:	3ff77713          	andi	a4,a4,1023
    800016b6:	06b2                	slli	a3,a3,0xc
    800016b8:	6605                	lui	a2,0x1
    800016ba:	85a6                	mv	a1,s1
    800016bc:	854e                	mv	a0,s3
    800016be:	00000097          	auipc	ra,0x0
    800016c2:	a26080e7          	jalr	-1498(ra) # 800010e4 <mappages>
    800016c6:	e515                	bnez	a0,800016f2 <uvmcopyshared+0x78>
  for(i = start; i < end; i += PGSIZE){
    800016c8:	6785                	lui	a5,0x1
    800016ca:	94be                	add	s1,s1,a5
    800016cc:	fd24e5e3          	bltu	s1,s2,80001696 <uvmcopyshared+0x1c>
    800016d0:	a81d                	j	80001706 <uvmcopyshared+0x8c>
      panic("uvmcopy: pte should exist");
    800016d2:	00008517          	auipc	a0,0x8
    800016d6:	ab650513          	addi	a0,a0,-1354 # 80009188 <digits+0x148>
    800016da:	fffff097          	auipc	ra,0xfffff
    800016de:	e60080e7          	jalr	-416(ra) # 8000053a <panic>
      panic("uvmcopy: page not present");
    800016e2:	00008517          	auipc	a0,0x8
    800016e6:	ac650513          	addi	a0,a0,-1338 # 800091a8 <digits+0x168>
    800016ea:	fffff097          	auipc	ra,0xfffff
    800016ee:	e50080e7          	jalr	-432(ra) # 8000053a <panic>
      goto err;
    }
  }
  return 0;
  err:
    uvmunmap(new, 0, i / PGSIZE, 1);
    800016f2:	4685                	li	a3,1
    800016f4:	00c4d613          	srli	a2,s1,0xc
    800016f8:	4581                	li	a1,0
    800016fa:	854e                	mv	a0,s3
    800016fc:	00000097          	auipc	ra,0x0
    80001700:	bae080e7          	jalr	-1106(ra) # 800012aa <uvmunmap>
    return -1;
    80001704:	557d                	li	a0,-1
} 
    80001706:	70a2                	ld	ra,40(sp)
    80001708:	7402                	ld	s0,32(sp)
    8000170a:	64e2                	ld	s1,24(sp)
    8000170c:	6942                	ld	s2,16(sp)
    8000170e:	69a2                	ld	s3,8(sp)
    80001710:	6a02                	ld	s4,0(sp)
    80001712:	6145                	addi	sp,sp,48
    80001714:	8082                	ret
  return 0;
    80001716:	4501                	li	a0,0
    80001718:	b7fd                	j	80001706 <uvmcopyshared+0x8c>

000000008000171a <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000171a:	1141                	addi	sp,sp,-16
    8000171c:	e406                	sd	ra,8(sp)
    8000171e:	e022                	sd	s0,0(sp)
    80001720:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001722:	4601                	li	a2,0
    80001724:	00000097          	auipc	ra,0x0
    80001728:	8d8080e7          	jalr	-1832(ra) # 80000ffc <walk>
  if(pte == 0)
    8000172c:	c901                	beqz	a0,8000173c <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000172e:	611c                	ld	a5,0(a0)
    80001730:	9bbd                	andi	a5,a5,-17
    80001732:	e11c                	sd	a5,0(a0)
}
    80001734:	60a2                	ld	ra,8(sp)
    80001736:	6402                	ld	s0,0(sp)
    80001738:	0141                	addi	sp,sp,16
    8000173a:	8082                	ret
    panic("uvmclear");
    8000173c:	00008517          	auipc	a0,0x8
    80001740:	a8c50513          	addi	a0,a0,-1396 # 800091c8 <digits+0x188>
    80001744:	fffff097          	auipc	ra,0xfffff
    80001748:	df6080e7          	jalr	-522(ra) # 8000053a <panic>

000000008000174c <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000174c:	c6bd                	beqz	a3,800017ba <copyout+0x6e>
{
    8000174e:	715d                	addi	sp,sp,-80
    80001750:	e486                	sd	ra,72(sp)
    80001752:	e0a2                	sd	s0,64(sp)
    80001754:	fc26                	sd	s1,56(sp)
    80001756:	f84a                	sd	s2,48(sp)
    80001758:	f44e                	sd	s3,40(sp)
    8000175a:	f052                	sd	s4,32(sp)
    8000175c:	ec56                	sd	s5,24(sp)
    8000175e:	e85a                	sd	s6,16(sp)
    80001760:	e45e                	sd	s7,8(sp)
    80001762:	e062                	sd	s8,0(sp)
    80001764:	0880                	addi	s0,sp,80
    80001766:	8b2a                	mv	s6,a0
    80001768:	8c2e                	mv	s8,a1
    8000176a:	8a32                	mv	s4,a2
    8000176c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000176e:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001770:	6a85                	lui	s5,0x1
    80001772:	a015                	j	80001796 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001774:	9562                	add	a0,a0,s8
    80001776:	0004861b          	sext.w	a2,s1
    8000177a:	85d2                	mv	a1,s4
    8000177c:	41250533          	sub	a0,a0,s2
    80001780:	fffff097          	auipc	ra,0xfffff
    80001784:	5f0080e7          	jalr	1520(ra) # 80000d70 <memmove>

    len -= n;
    80001788:	409989b3          	sub	s3,s3,s1
    src += n;
    8000178c:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    8000178e:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001792:	02098263          	beqz	s3,800017b6 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001796:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000179a:	85ca                	mv	a1,s2
    8000179c:	855a                	mv	a0,s6
    8000179e:	00000097          	auipc	ra,0x0
    800017a2:	904080e7          	jalr	-1788(ra) # 800010a2 <walkaddr>
    if(pa0 == 0)
    800017a6:	cd01                	beqz	a0,800017be <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800017a8:	418904b3          	sub	s1,s2,s8
    800017ac:	94d6                	add	s1,s1,s5
    800017ae:	fc99f3e3          	bgeu	s3,s1,80001774 <copyout+0x28>
    800017b2:	84ce                	mv	s1,s3
    800017b4:	b7c1                	j	80001774 <copyout+0x28>
  }
  return 0;
    800017b6:	4501                	li	a0,0
    800017b8:	a021                	j	800017c0 <copyout+0x74>
    800017ba:	4501                	li	a0,0
}
    800017bc:	8082                	ret
      return -1;
    800017be:	557d                	li	a0,-1
}
    800017c0:	60a6                	ld	ra,72(sp)
    800017c2:	6406                	ld	s0,64(sp)
    800017c4:	74e2                	ld	s1,56(sp)
    800017c6:	7942                	ld	s2,48(sp)
    800017c8:	79a2                	ld	s3,40(sp)
    800017ca:	7a02                	ld	s4,32(sp)
    800017cc:	6ae2                	ld	s5,24(sp)
    800017ce:	6b42                	ld	s6,16(sp)
    800017d0:	6ba2                	ld	s7,8(sp)
    800017d2:	6c02                	ld	s8,0(sp)
    800017d4:	6161                	addi	sp,sp,80
    800017d6:	8082                	ret

00000000800017d8 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800017d8:	caa5                	beqz	a3,80001848 <copyin+0x70>
{
    800017da:	715d                	addi	sp,sp,-80
    800017dc:	e486                	sd	ra,72(sp)
    800017de:	e0a2                	sd	s0,64(sp)
    800017e0:	fc26                	sd	s1,56(sp)
    800017e2:	f84a                	sd	s2,48(sp)
    800017e4:	f44e                	sd	s3,40(sp)
    800017e6:	f052                	sd	s4,32(sp)
    800017e8:	ec56                	sd	s5,24(sp)
    800017ea:	e85a                	sd	s6,16(sp)
    800017ec:	e45e                	sd	s7,8(sp)
    800017ee:	e062                	sd	s8,0(sp)
    800017f0:	0880                	addi	s0,sp,80
    800017f2:	8b2a                	mv	s6,a0
    800017f4:	8a2e                	mv	s4,a1
    800017f6:	8c32                	mv	s8,a2
    800017f8:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800017fa:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017fc:	6a85                	lui	s5,0x1
    800017fe:	a01d                	j	80001824 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001800:	018505b3          	add	a1,a0,s8
    80001804:	0004861b          	sext.w	a2,s1
    80001808:	412585b3          	sub	a1,a1,s2
    8000180c:	8552                	mv	a0,s4
    8000180e:	fffff097          	auipc	ra,0xfffff
    80001812:	562080e7          	jalr	1378(ra) # 80000d70 <memmove>

    len -= n;
    80001816:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000181a:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000181c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001820:	02098263          	beqz	s3,80001844 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001824:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001828:	85ca                	mv	a1,s2
    8000182a:	855a                	mv	a0,s6
    8000182c:	00000097          	auipc	ra,0x0
    80001830:	876080e7          	jalr	-1930(ra) # 800010a2 <walkaddr>
    if(pa0 == 0)
    80001834:	cd01                	beqz	a0,8000184c <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001836:	418904b3          	sub	s1,s2,s8
    8000183a:	94d6                	add	s1,s1,s5
    8000183c:	fc99f2e3          	bgeu	s3,s1,80001800 <copyin+0x28>
    80001840:	84ce                	mv	s1,s3
    80001842:	bf7d                	j	80001800 <copyin+0x28>
  }
  return 0;
    80001844:	4501                	li	a0,0
    80001846:	a021                	j	8000184e <copyin+0x76>
    80001848:	4501                	li	a0,0
}
    8000184a:	8082                	ret
      return -1;
    8000184c:	557d                	li	a0,-1
}
    8000184e:	60a6                	ld	ra,72(sp)
    80001850:	6406                	ld	s0,64(sp)
    80001852:	74e2                	ld	s1,56(sp)
    80001854:	7942                	ld	s2,48(sp)
    80001856:	79a2                	ld	s3,40(sp)
    80001858:	7a02                	ld	s4,32(sp)
    8000185a:	6ae2                	ld	s5,24(sp)
    8000185c:	6b42                	ld	s6,16(sp)
    8000185e:	6ba2                	ld	s7,8(sp)
    80001860:	6c02                	ld	s8,0(sp)
    80001862:	6161                	addi	sp,sp,80
    80001864:	8082                	ret

0000000080001866 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001866:	c2dd                	beqz	a3,8000190c <copyinstr+0xa6>
{
    80001868:	715d                	addi	sp,sp,-80
    8000186a:	e486                	sd	ra,72(sp)
    8000186c:	e0a2                	sd	s0,64(sp)
    8000186e:	fc26                	sd	s1,56(sp)
    80001870:	f84a                	sd	s2,48(sp)
    80001872:	f44e                	sd	s3,40(sp)
    80001874:	f052                	sd	s4,32(sp)
    80001876:	ec56                	sd	s5,24(sp)
    80001878:	e85a                	sd	s6,16(sp)
    8000187a:	e45e                	sd	s7,8(sp)
    8000187c:	0880                	addi	s0,sp,80
    8000187e:	8a2a                	mv	s4,a0
    80001880:	8b2e                	mv	s6,a1
    80001882:	8bb2                	mv	s7,a2
    80001884:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001886:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001888:	6985                	lui	s3,0x1
    8000188a:	a02d                	j	800018b4 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000188c:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001890:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001892:	37fd                	addiw	a5,a5,-1
    80001894:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001898:	60a6                	ld	ra,72(sp)
    8000189a:	6406                	ld	s0,64(sp)
    8000189c:	74e2                	ld	s1,56(sp)
    8000189e:	7942                	ld	s2,48(sp)
    800018a0:	79a2                	ld	s3,40(sp)
    800018a2:	7a02                	ld	s4,32(sp)
    800018a4:	6ae2                	ld	s5,24(sp)
    800018a6:	6b42                	ld	s6,16(sp)
    800018a8:	6ba2                	ld	s7,8(sp)
    800018aa:	6161                	addi	sp,sp,80
    800018ac:	8082                	ret
    srcva = va0 + PGSIZE;
    800018ae:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800018b2:	c8a9                	beqz	s1,80001904 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800018b4:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800018b8:	85ca                	mv	a1,s2
    800018ba:	8552                	mv	a0,s4
    800018bc:	fffff097          	auipc	ra,0xfffff
    800018c0:	7e6080e7          	jalr	2022(ra) # 800010a2 <walkaddr>
    if(pa0 == 0)
    800018c4:	c131                	beqz	a0,80001908 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800018c6:	417906b3          	sub	a3,s2,s7
    800018ca:	96ce                	add	a3,a3,s3
    800018cc:	00d4f363          	bgeu	s1,a3,800018d2 <copyinstr+0x6c>
    800018d0:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800018d2:	955e                	add	a0,a0,s7
    800018d4:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800018d8:	daf9                	beqz	a3,800018ae <copyinstr+0x48>
    800018da:	87da                	mv	a5,s6
      if(*p == '\0'){
    800018dc:	41650633          	sub	a2,a0,s6
    800018e0:	fff48593          	addi	a1,s1,-1
    800018e4:	95da                	add	a1,a1,s6
    while(n > 0){
    800018e6:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    800018e8:	00f60733          	add	a4,a2,a5
    800018ec:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffc7000>
    800018f0:	df51                	beqz	a4,8000188c <copyinstr+0x26>
        *dst = *p;
    800018f2:	00e78023          	sb	a4,0(a5)
      --max;
    800018f6:	40f584b3          	sub	s1,a1,a5
      dst++;
    800018fa:	0785                	addi	a5,a5,1
    while(n > 0){
    800018fc:	fed796e3          	bne	a5,a3,800018e8 <copyinstr+0x82>
      dst++;
    80001900:	8b3e                	mv	s6,a5
    80001902:	b775                	j	800018ae <copyinstr+0x48>
    80001904:	4781                	li	a5,0
    80001906:	b771                	j	80001892 <copyinstr+0x2c>
      return -1;
    80001908:	557d                	li	a0,-1
    8000190a:	b779                	j	80001898 <copyinstr+0x32>
  int got_null = 0;
    8000190c:	4781                	li	a5,0
  if(got_null){
    8000190e:	37fd                	addiw	a5,a5,-1
    80001910:	0007851b          	sext.w	a0,a5
}
    80001914:	8082                	ret

0000000080001916 <mapvpages>:
//Added for lab 3

// Allocate page table pages for PTEs if needed but leave valid bits unchanged
int
mapvpages(pagetable_t pagetable, uint64 va, uint64 size)
{
    80001916:	7179                	addi	sp,sp,-48
    80001918:	f406                	sd	ra,40(sp)
    8000191a:	f022                	sd	s0,32(sp)
    8000191c:	ec26                	sd	s1,24(sp)
    8000191e:	e84a                	sd	s2,16(sp)
    80001920:	e44e                	sd	s3,8(sp)
    80001922:	e052                	sd	s4,0(sp)
    80001924:	1800                	addi	s0,sp,48
  uint64 a, last;
  pte_t *pte;
  if(size == 0)
    80001926:	ca15                	beqz	a2,8000195a <mapvpages+0x44>
    80001928:	89aa                	mv	s3,a0
    panic("mappages: size");
  a = PGROUNDDOWN(va);
    8000192a:	77fd                	lui	a5,0xfffff
    8000192c:	00f5f4b3          	and	s1,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    80001930:	fff58913          	addi	s2,a1,-1
    80001934:	9932                	add	s2,s2,a2
    80001936:	00f97933          	and	s2,s2,a5
      return -1;
    if(*pte & PTE_V)
      panic("mappages: remap");
    if(a == last)
      break;
    a += PGSIZE;
    8000193a:	6a05                	lui	s4,0x1
    if((pte = walk(pagetable, a, 1)) == 0)
    8000193c:	4605                	li	a2,1
    8000193e:	85a6                	mv	a1,s1
    80001940:	854e                	mv	a0,s3
    80001942:	fffff097          	auipc	ra,0xfffff
    80001946:	6ba080e7          	jalr	1722(ra) # 80000ffc <walk>
    8000194a:	c905                	beqz	a0,8000197a <mapvpages+0x64>
    if(*pte & PTE_V)
    8000194c:	611c                	ld	a5,0(a0)
    8000194e:	8b85                	andi	a5,a5,1
    80001950:	ef89                	bnez	a5,8000196a <mapvpages+0x54>
    if(a == last)
    80001952:	03248d63          	beq	s1,s2,8000198c <mapvpages+0x76>
    a += PGSIZE;
    80001956:	94d2                	add	s1,s1,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001958:	b7d5                	j	8000193c <mapvpages+0x26>
    panic("mappages: size");
    8000195a:	00007517          	auipc	a0,0x7
    8000195e:	77e50513          	addi	a0,a0,1918 # 800090d8 <digits+0x98>
    80001962:	fffff097          	auipc	ra,0xfffff
    80001966:	bd8080e7          	jalr	-1064(ra) # 8000053a <panic>
      panic("mappages: remap");
    8000196a:	00007517          	auipc	a0,0x7
    8000196e:	77e50513          	addi	a0,a0,1918 # 800090e8 <digits+0xa8>
    80001972:	fffff097          	auipc	ra,0xfffff
    80001976:	bc8080e7          	jalr	-1080(ra) # 8000053a <panic>
      return -1;
    8000197a:	557d                	li	a0,-1
  }
  return 0;
    8000197c:	70a2                	ld	ra,40(sp)
    8000197e:	7402                	ld	s0,32(sp)
    80001980:	64e2                	ld	s1,24(sp)
    80001982:	6942                	ld	s2,16(sp)
    80001984:	69a2                	ld	s3,8(sp)
    80001986:	6a02                	ld	s4,0(sp)
    80001988:	6145                	addi	sp,sp,48
    8000198a:	8082                	ret
  return 0;
    8000198c:	4501                	li	a0,0
    8000198e:	b7fd                	j	8000197c <mapvpages+0x66>

0000000080001990 <enqueue_at_tail>:
  return(0);
}

static int
enqueue_at_tail(struct proc *p, int priority)
{
    80001990:	7179                	addi	sp,sp,-48
    80001992:	f406                	sd	ra,40(sp)
    80001994:	f022                	sd	s0,32(sp)
    80001996:	ec26                	sd	s1,24(sp)
    80001998:	e84a                	sd	s2,16(sp)
    8000199a:	e44e                	sd	s3,8(sp)
    8000199c:	1800                	addi	s0,sp,48
  if(!(p >= proc && p < &proc[NPROC]))
    8000199e:	00011797          	auipc	a5,0x11
    800019a2:	dda78793          	addi	a5,a5,-550 # 80012778 <proc>
    800019a6:	08f56263          	bltu	a0,a5,80001a2a <enqueue_at_tail+0x9a>
    800019aa:	892a                	mv	s2,a0
    800019ac:	84ae                	mv	s1,a1
    800019ae:	00022797          	auipc	a5,0x22
    800019b2:	5ca78793          	addi	a5,a5,1482 # 80023f78 <mmr_list>
    800019b6:	06f57a63          	bgeu	a0,a5,80001a2a <enqueue_at_tail+0x9a>
    panic("enqueue_at_tail");
  if(!(priority >= 0) && (priority < NQUEUE))
    800019ba:	0805c063          	bltz	a1,80001a3a <enqueue_at_tail+0xaa>
    panic("enqueue_at_tail");
  acquire(&queue[priority].lock);
    800019be:	00159793          	slli	a5,a1,0x1
    800019c2:	97ae                	add	a5,a5,a1
    800019c4:	0792                	slli	a5,a5,0x4
    800019c6:	00011997          	auipc	s3,0x11
    800019ca:	8da98993          	addi	s3,s3,-1830 # 800122a0 <queue>
    800019ce:	99be                	add	s3,s3,a5
    800019d0:	854e                	mv	a0,s3
    800019d2:	fffff097          	auipc	ra,0xfffff
    800019d6:	246080e7          	jalr	582(ra) # 80000c18 <acquire>

  if((queue[priority].head == 0) && (queue[priority].tail == 0)){
    800019da:	0209b783          	ld	a5,32(s3)
    800019de:	c7b5                	beqz	a5,80001a4a <enqueue_at_tail+0xba>
    queue[priority].tail = p;
    release(&queue[priority].lock);
    return(0);
  }

  if(queue[priority].tail == 0){
    800019e0:	00149793          	slli	a5,s1,0x1
    800019e4:	97a6                	add	a5,a5,s1
    800019e6:	0792                	slli	a5,a5,0x4
    800019e8:	00011717          	auipc	a4,0x11
    800019ec:	8b870713          	addi	a4,a4,-1864 # 800122a0 <queue>
    800019f0:	97ba                	add	a5,a5,a4
    800019f2:	779c                	ld	a5,40(a5)
    800019f4:	cba5                	beqz	a5,80001a64 <enqueue_at_tail+0xd4>
    release(&queue[priority].lock);
    panic("enqueue_at_tail");
  }

  queue[priority].tail->next = p;
    800019f6:	0527b823          	sd	s2,80(a5)
  queue[priority].tail = p;
    800019fa:	00149793          	slli	a5,s1,0x1
    800019fe:	97a6                	add	a5,a5,s1
    80001a00:	0792                	slli	a5,a5,0x4
    80001a02:	00011717          	auipc	a4,0x11
    80001a06:	89e70713          	addi	a4,a4,-1890 # 800122a0 <queue>
    80001a0a:	97ba                	add	a5,a5,a4
    80001a0c:	0327b423          	sd	s2,40(a5)

  release(&queue[priority].lock);
    80001a10:	854e                	mv	a0,s3
    80001a12:	fffff097          	auipc	ra,0xfffff
    80001a16:	2ba080e7          	jalr	698(ra) # 80000ccc <release>
  return(0);
}
    80001a1a:	4501                	li	a0,0
    80001a1c:	70a2                	ld	ra,40(sp)
    80001a1e:	7402                	ld	s0,32(sp)
    80001a20:	64e2                	ld	s1,24(sp)
    80001a22:	6942                	ld	s2,16(sp)
    80001a24:	69a2                	ld	s3,8(sp)
    80001a26:	6145                	addi	sp,sp,48
    80001a28:	8082                	ret
    panic("enqueue_at_tail");
    80001a2a:	00007517          	auipc	a0,0x7
    80001a2e:	7ae50513          	addi	a0,a0,1966 # 800091d8 <digits+0x198>
    80001a32:	fffff097          	auipc	ra,0xfffff
    80001a36:	b08080e7          	jalr	-1272(ra) # 8000053a <panic>
    panic("enqueue_at_tail");
    80001a3a:	00007517          	auipc	a0,0x7
    80001a3e:	79e50513          	addi	a0,a0,1950 # 800091d8 <digits+0x198>
    80001a42:	fffff097          	auipc	ra,0xfffff
    80001a46:	af8080e7          	jalr	-1288(ra) # 8000053a <panic>
  if((queue[priority].head == 0) && (queue[priority].tail == 0)){
    80001a4a:	0289b783          	ld	a5,40(s3)
    80001a4e:	f7c5                	bnez	a5,800019f6 <enqueue_at_tail+0x66>
    queue[priority].head = p;
    80001a50:	0329b023          	sd	s2,32(s3)
    queue[priority].tail = p;
    80001a54:	0329b423          	sd	s2,40(s3)
    release(&queue[priority].lock);
    80001a58:	854e                	mv	a0,s3
    80001a5a:	fffff097          	auipc	ra,0xfffff
    80001a5e:	272080e7          	jalr	626(ra) # 80000ccc <release>
    return(0);
    80001a62:	bf65                	j	80001a1a <enqueue_at_tail+0x8a>
    release(&queue[priority].lock);
    80001a64:	854e                	mv	a0,s3
    80001a66:	fffff097          	auipc	ra,0xfffff
    80001a6a:	266080e7          	jalr	614(ra) # 80000ccc <release>
    panic("enqueue_at_tail");
    80001a6e:	00007517          	auipc	a0,0x7
    80001a72:	76a50513          	addi	a0,a0,1898 # 800091d8 <digits+0x198>
    80001a76:	fffff097          	auipc	ra,0xfffff
    80001a7a:	ac4080e7          	jalr	-1340(ra) # 8000053a <panic>

0000000080001a7e <dequeue>:
  return(0);
} 

static struct proc*
dequeue(int priority)
{
    80001a7e:	7179                	addi	sp,sp,-48
    80001a80:	f406                	sd	ra,40(sp)
    80001a82:	f022                	sd	s0,32(sp)
    80001a84:	ec26                	sd	s1,24(sp)
    80001a86:	e84a                	sd	s2,16(sp)
    80001a88:	e44e                	sd	s3,8(sp)
    80001a8a:	e052                	sd	s4,0(sp)
    80001a8c:	1800                	addi	s0,sp,48
    80001a8e:	84aa                	mv	s1,a0
  struct proc *p;
  if (!(priority >= 0) && (priority < NQUEUE)) {
    80001a90:	06054e63          	bltz	a0,80001b0c <dequeue+0x8e>
    printf("dequeue: invalid argument %d\n", priority);
    return(0);
  }
  acquire(&queue[priority].lock);
    80001a94:	00151793          	slli	a5,a0,0x1
    80001a98:	97aa                	add	a5,a5,a0
    80001a9a:	0792                	slli	a5,a5,0x4
    80001a9c:	00011997          	auipc	s3,0x11
    80001aa0:	80498993          	addi	s3,s3,-2044 # 800122a0 <queue>
    80001aa4:	99be                	add	s3,s3,a5
    80001aa6:	854e                	mv	a0,s3
    80001aa8:	fffff097          	auipc	ra,0xfffff
    80001aac:	170080e7          	jalr	368(ra) # 80000c18 <acquire>
  if ((queue[priority].head == 0) && (queue[priority].tail == 0)) {
    80001ab0:	0209b903          	ld	s2,32(s3)
    80001ab4:	06090763          	beqz	s2,80001b22 <dequeue+0xa4>
  if (queue[priority].head == 0) {
    release(&queue[priority].lock);
    panic("dequeue");
  }
  p = queue[priority].head;
  acquire(&p->lock);
    80001ab8:	854a                	mv	a0,s2
    80001aba:	fffff097          	auipc	ra,0xfffff
    80001abe:	15e080e7          	jalr	350(ra) # 80000c18 <acquire>
  queue[priority].head = p->next;
    80001ac2:	05093703          	ld	a4,80(s2) # 1050 <_entry-0x7fffefb0>
    80001ac6:	00149793          	slli	a5,s1,0x1
    80001aca:	97a6                	add	a5,a5,s1
    80001acc:	0792                	slli	a5,a5,0x4
    80001ace:	00010a17          	auipc	s4,0x10
    80001ad2:	7d2a0a13          	addi	s4,s4,2002 # 800122a0 <queue>
    80001ad6:	9a3e                	add	s4,s4,a5
    80001ad8:	02ea3023          	sd	a4,32(s4)
  p->next = 0;
    80001adc:	04093823          	sd	zero,80(s2)
  release(&p->lock);
    80001ae0:	854a                	mv	a0,s2
    80001ae2:	fffff097          	auipc	ra,0xfffff
    80001ae6:	1ea080e7          	jalr	490(ra) # 80000ccc <release>
  if (!queue[priority].head)
    80001aea:	020a3783          	ld	a5,32(s4)
    80001aee:	c3ad                	beqz	a5,80001b50 <dequeue+0xd2>
  queue[priority].tail = 0;
  release(&queue[priority].lock);
    80001af0:	854e                	mv	a0,s3
    80001af2:	fffff097          	auipc	ra,0xfffff
    80001af6:	1da080e7          	jalr	474(ra) # 80000ccc <release>
  return(p);
}
    80001afa:	854a                	mv	a0,s2
    80001afc:	70a2                	ld	ra,40(sp)
    80001afe:	7402                	ld	s0,32(sp)
    80001b00:	64e2                	ld	s1,24(sp)
    80001b02:	6942                	ld	s2,16(sp)
    80001b04:	69a2                	ld	s3,8(sp)
    80001b06:	6a02                	ld	s4,0(sp)
    80001b08:	6145                	addi	sp,sp,48
    80001b0a:	8082                	ret
    printf("dequeue: invalid argument %d\n", priority);
    80001b0c:	85aa                	mv	a1,a0
    80001b0e:	00007517          	auipc	a0,0x7
    80001b12:	6da50513          	addi	a0,a0,1754 # 800091e8 <digits+0x1a8>
    80001b16:	fffff097          	auipc	ra,0xfffff
    80001b1a:	a6e080e7          	jalr	-1426(ra) # 80000584 <printf>
    return(0);
    80001b1e:	4901                	li	s2,0
    80001b20:	bfe9                	j	80001afa <dequeue+0x7c>
  if ((queue[priority].head == 0) && (queue[priority].tail == 0)) {
    80001b22:	0289b903          	ld	s2,40(s3)
    80001b26:	00090f63          	beqz	s2,80001b44 <dequeue+0xc6>
    release(&queue[priority].lock);
    80001b2a:	854e                	mv	a0,s3
    80001b2c:	fffff097          	auipc	ra,0xfffff
    80001b30:	1a0080e7          	jalr	416(ra) # 80000ccc <release>
    panic("dequeue");
    80001b34:	00007517          	auipc	a0,0x7
    80001b38:	6d450513          	addi	a0,a0,1748 # 80009208 <digits+0x1c8>
    80001b3c:	fffff097          	auipc	ra,0xfffff
    80001b40:	9fe080e7          	jalr	-1538(ra) # 8000053a <panic>
    release(&queue[priority].lock);
    80001b44:	854e                	mv	a0,s3
    80001b46:	fffff097          	auipc	ra,0xfffff
    80001b4a:	186080e7          	jalr	390(ra) # 80000ccc <release>
    return(0);
    80001b4e:	b775                	j	80001afa <dequeue+0x7c>
  queue[priority].tail = 0;
    80001b50:	020a3423          	sd	zero,40(s4)
    80001b54:	bf71                	j	80001af0 <dequeue+0x72>

0000000080001b56 <queueinit>:
{
    80001b56:	1101                	addi	sp,sp,-32
    80001b58:	ec06                	sd	ra,24(sp)
    80001b5a:	e822                	sd	s0,16(sp)
    80001b5c:	e426                	sd	s1,8(sp)
    80001b5e:	1000                	addi	s0,sp,32
    initlock(&q->lock, "queue");
    80001b60:	00010497          	auipc	s1,0x10
    80001b64:	74048493          	addi	s1,s1,1856 # 800122a0 <queue>
    80001b68:	00007597          	auipc	a1,0x7
    80001b6c:	6a858593          	addi	a1,a1,1704 # 80009210 <digits+0x1d0>
    80001b70:	8526                	mv	a0,s1
    80001b72:	fffff097          	auipc	ra,0xfffff
    80001b76:	016080e7          	jalr	22(ra) # 80000b88 <initlock>
      q->timeslice = TSTICKSHIGH;
    80001b7a:	4785                	li	a5,1
    80001b7c:	cc9c                	sw	a5,24(s1)
    q->head = 0;
    80001b7e:	0204b023          	sd	zero,32(s1)
    q->tail = 0;
    80001b82:	0204b423          	sd	zero,40(s1)
    initlock(&q->lock, "queue");
    80001b86:	00007597          	auipc	a1,0x7
    80001b8a:	68a58593          	addi	a1,a1,1674 # 80009210 <digits+0x1d0>
    80001b8e:	00010517          	auipc	a0,0x10
    80001b92:	74250513          	addi	a0,a0,1858 # 800122d0 <queue+0x30>
    80001b96:	fffff097          	auipc	ra,0xfffff
    80001b9a:	ff2080e7          	jalr	-14(ra) # 80000b88 <initlock>
      q->timeslice = TSTICKSHIGH;
    80001b9e:	03200793          	li	a5,50
    80001ba2:	c4bc                	sw	a5,72(s1)
    q->head = 0;
    80001ba4:	0404b823          	sd	zero,80(s1)
    q->tail = 0;
    80001ba8:	0404bc23          	sd	zero,88(s1)
    initlock(&q->lock, "queue");
    80001bac:	00007597          	auipc	a1,0x7
    80001bb0:	66458593          	addi	a1,a1,1636 # 80009210 <digits+0x1d0>
    80001bb4:	00010517          	auipc	a0,0x10
    80001bb8:	74c50513          	addi	a0,a0,1868 # 80012300 <queue+0x60>
    80001bbc:	fffff097          	auipc	ra,0xfffff
    80001bc0:	fcc080e7          	jalr	-52(ra) # 80000b88 <initlock>
      q->timeslice = TSTICKSHIGH;
    80001bc4:	0c800793          	li	a5,200
    80001bc8:	dcbc                	sw	a5,120(s1)
    q->head = 0;
    80001bca:	0804b023          	sd	zero,128(s1)
    q->tail = 0;
    80001bce:	0804b423          	sd	zero,136(s1)
} 
    80001bd2:	60e2                	ld	ra,24(sp)
    80001bd4:	6442                	ld	s0,16(sp)
    80001bd6:	64a2                	ld	s1,8(sp)
    80001bd8:	6105                	addi	sp,sp,32
    80001bda:	8082                	ret

0000000080001bdc <timeslice>:
  if(priority == HIGH)
    80001bdc:	cd05                	beqz	a0,80001c14 <timeslice+0x38>
    80001bde:	85aa                	mv	a1,a0
  else if(priority == MEDIUM)
    80001be0:	4785                	li	a5,1
    80001be2:	02f50b63          	beq	a0,a5,80001c18 <timeslice+0x3c>
  else if(priority == LOW)
    80001be6:	4789                	li	a5,2
    return(TSTICKSLOW);
    80001be8:	0c800513          	li	a0,200
  else if(priority == LOW)
    80001bec:	00f59363          	bne	a1,a5,80001bf2 <timeslice+0x16>
}
    80001bf0:	8082                	ret
{
    80001bf2:	1141                	addi	sp,sp,-16
    80001bf4:	e406                	sd	ra,8(sp)
    80001bf6:	e022                	sd	s0,0(sp)
    80001bf8:	0800                	addi	s0,sp,16
    printf("timeslive: invalid priority %d\n", priority);
    80001bfa:	00007517          	auipc	a0,0x7
    80001bfe:	61e50513          	addi	a0,a0,1566 # 80009218 <digits+0x1d8>
    80001c02:	fffff097          	auipc	ra,0xfffff
    80001c06:	982080e7          	jalr	-1662(ra) # 80000584 <printf>
    return -1;
    80001c0a:	557d                	li	a0,-1
}
    80001c0c:	60a2                	ld	ra,8(sp)
    80001c0e:	6402                	ld	s0,0(sp)
    80001c10:	0141                	addi	sp,sp,16
    80001c12:	8082                	ret
    return(TSTICKSHIGH);
    80001c14:	4505                	li	a0,1
    80001c16:	8082                	ret
    return(TSTICKSMEDIUM);
    80001c18:	03200513          	li	a0,50
    80001c1c:	8082                	ret

0000000080001c1e <queue_empty>:
{
    80001c1e:	1141                	addi	sp,sp,-16
    80001c20:	e422                	sd	s0,8(sp)
    80001c22:	0800                	addi	s0,sp,16
  if (!queue[priority].head)
    80001c24:	00151793          	slli	a5,a0,0x1
    80001c28:	97aa                	add	a5,a5,a0
    80001c2a:	0792                	slli	a5,a5,0x4
    80001c2c:	00010717          	auipc	a4,0x10
    80001c30:	67470713          	addi	a4,a4,1652 # 800122a0 <queue>
    80001c34:	97ba                	add	a5,a5,a4
    80001c36:	7388                	ld	a0,32(a5)
}
    80001c38:	00153513          	seqz	a0,a0
    80001c3c:	6422                	ld	s0,8(sp)
    80001c3e:	0141                	addi	sp,sp,16
    80001c40:	8082                	ret

0000000080001c42 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    80001c42:	7139                	addi	sp,sp,-64
    80001c44:	fc06                	sd	ra,56(sp)
    80001c46:	f822                	sd	s0,48(sp)
    80001c48:	f426                	sd	s1,40(sp)
    80001c4a:	f04a                	sd	s2,32(sp)
    80001c4c:	ec4e                	sd	s3,24(sp)
    80001c4e:	e852                	sd	s4,16(sp)
    80001c50:	e456                	sd	s5,8(sp)
    80001c52:	e05a                	sd	s6,0(sp)
    80001c54:	0080                	addi	s0,sp,64
    80001c56:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c58:	00011497          	auipc	s1,0x11
    80001c5c:	b2048493          	addi	s1,s1,-1248 # 80012778 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001c60:	8b26                	mv	s6,s1
    80001c62:	00007a97          	auipc	s5,0x7
    80001c66:	39ea8a93          	addi	s5,s5,926 # 80009000 <etext>
    80001c6a:	04000937          	lui	s2,0x4000
    80001c6e:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001c70:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c72:	00022a17          	auipc	s4,0x22
    80001c76:	306a0a13          	addi	s4,s4,774 # 80023f78 <mmr_list>
    char *pa = kalloc();
    80001c7a:	fffff097          	auipc	ra,0xfffff
    80001c7e:	e66080e7          	jalr	-410(ra) # 80000ae0 <kalloc>
    80001c82:	862a                	mv	a2,a0
    if(pa == 0)
    80001c84:	c131                	beqz	a0,80001cc8 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001c86:	416485b3          	sub	a1,s1,s6
    80001c8a:	8595                	srai	a1,a1,0x5
    80001c8c:	000ab783          	ld	a5,0(s5)
    80001c90:	02f585b3          	mul	a1,a1,a5
    80001c94:	2585                	addiw	a1,a1,1
    80001c96:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001c9a:	4719                	li	a4,6
    80001c9c:	6685                	lui	a3,0x1
    80001c9e:	40b905b3          	sub	a1,s2,a1
    80001ca2:	854e                	mv	a0,s3
    80001ca4:	fffff097          	auipc	ra,0xfffff
    80001ca8:	4e0080e7          	jalr	1248(ra) # 80001184 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cac:	46048493          	addi	s1,s1,1120
    80001cb0:	fd4495e3          	bne	s1,s4,80001c7a <proc_mapstacks+0x38>
  }
}
    80001cb4:	70e2                	ld	ra,56(sp)
    80001cb6:	7442                	ld	s0,48(sp)
    80001cb8:	74a2                	ld	s1,40(sp)
    80001cba:	7902                	ld	s2,32(sp)
    80001cbc:	69e2                	ld	s3,24(sp)
    80001cbe:	6a42                	ld	s4,16(sp)
    80001cc0:	6aa2                	ld	s5,8(sp)
    80001cc2:	6b02                	ld	s6,0(sp)
    80001cc4:	6121                	addi	sp,sp,64
    80001cc6:	8082                	ret
      panic("kalloc");
    80001cc8:	00007517          	auipc	a0,0x7
    80001ccc:	57050513          	addi	a0,a0,1392 # 80009238 <digits+0x1f8>
    80001cd0:	fffff097          	auipc	ra,0xfffff
    80001cd4:	86a080e7          	jalr	-1942(ra) # 8000053a <panic>

0000000080001cd8 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    80001cd8:	7139                	addi	sp,sp,-64
    80001cda:	fc06                	sd	ra,56(sp)
    80001cdc:	f822                	sd	s0,48(sp)
    80001cde:	f426                	sd	s1,40(sp)
    80001ce0:	f04a                	sd	s2,32(sp)
    80001ce2:	ec4e                	sd	s3,24(sp)
    80001ce4:	e852                	sd	s4,16(sp)
    80001ce6:	e456                	sd	s5,8(sp)
    80001ce8:	e05a                	sd	s6,0(sp)
    80001cea:	0080                	addi	s0,sp,64
  struct proc *p;
  
  //Initializes the queue at startup
  queueinit();
    80001cec:	00000097          	auipc	ra,0x0
    80001cf0:	e6a080e7          	jalr	-406(ra) # 80001b56 <queueinit>

  initlock(&pid_lock, "nextpid");
    80001cf4:	00007597          	auipc	a1,0x7
    80001cf8:	54c58593          	addi	a1,a1,1356 # 80009240 <digits+0x200>
    80001cfc:	00010517          	auipc	a0,0x10
    80001d00:	63450513          	addi	a0,a0,1588 # 80012330 <pid_lock>
    80001d04:	fffff097          	auipc	ra,0xfffff
    80001d08:	e84080e7          	jalr	-380(ra) # 80000b88 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001d0c:	00007597          	auipc	a1,0x7
    80001d10:	53c58593          	addi	a1,a1,1340 # 80009248 <digits+0x208>
    80001d14:	00010517          	auipc	a0,0x10
    80001d18:	63450513          	addi	a0,a0,1588 # 80012348 <wait_lock>
    80001d1c:	fffff097          	auipc	ra,0xfffff
    80001d20:	e6c080e7          	jalr	-404(ra) # 80000b88 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d24:	00011497          	auipc	s1,0x11
    80001d28:	a5448493          	addi	s1,s1,-1452 # 80012778 <proc>
      initlock(&p->lock, "proc");
    80001d2c:	00007b17          	auipc	s6,0x7
    80001d30:	52cb0b13          	addi	s6,s6,1324 # 80009258 <digits+0x218>
      p->kstack = KSTACK((int) (p - proc));
    80001d34:	8aa6                	mv	s5,s1
    80001d36:	00007a17          	auipc	s4,0x7
    80001d3a:	2caa0a13          	addi	s4,s4,714 # 80009000 <etext>
    80001d3e:	04000937          	lui	s2,0x4000
    80001d42:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001d44:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d46:	00022997          	auipc	s3,0x22
    80001d4a:	23298993          	addi	s3,s3,562 # 80023f78 <mmr_list>
      initlock(&p->lock, "proc");
    80001d4e:	85da                	mv	a1,s6
    80001d50:	8526                	mv	a0,s1
    80001d52:	fffff097          	auipc	ra,0xfffff
    80001d56:	e36080e7          	jalr	-458(ra) # 80000b88 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80001d5a:	415487b3          	sub	a5,s1,s5
    80001d5e:	8795                	srai	a5,a5,0x5
    80001d60:	000a3703          	ld	a4,0(s4)
    80001d64:	02e787b3          	mul	a5,a5,a4
    80001d68:	2785                	addiw	a5,a5,1
    80001d6a:	00d7979b          	slliw	a5,a5,0xd
    80001d6e:	40f907b3          	sub	a5,s2,a5
    80001d72:	f0bc                	sd	a5,96(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d74:	46048493          	addi	s1,s1,1120
    80001d78:	fd349be3          	bne	s1,s3,80001d4e <procinit+0x76>
  }
}
    80001d7c:	70e2                	ld	ra,56(sp)
    80001d7e:	7442                	ld	s0,48(sp)
    80001d80:	74a2                	ld	s1,40(sp)
    80001d82:	7902                	ld	s2,32(sp)
    80001d84:	69e2                	ld	s3,24(sp)
    80001d86:	6a42                	ld	s4,16(sp)
    80001d88:	6aa2                	ld	s5,8(sp)
    80001d8a:	6b02                	ld	s6,0(sp)
    80001d8c:	6121                	addi	sp,sp,64
    80001d8e:	8082                	ret

0000000080001d90 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001d90:	1141                	addi	sp,sp,-16
    80001d92:	e422                	sd	s0,8(sp)
    80001d94:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001d96:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001d98:	2501                	sext.w	a0,a0
    80001d9a:	6422                	ld	s0,8(sp)
    80001d9c:	0141                	addi	sp,sp,16
    80001d9e:	8082                	ret

0000000080001da0 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001da0:	1141                	addi	sp,sp,-16
    80001da2:	e422                	sd	s0,8(sp)
    80001da4:	0800                	addi	s0,sp,16
    80001da6:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001da8:	2781                	sext.w	a5,a5
    80001daa:	079e                	slli	a5,a5,0x7
  return c;
}
    80001dac:	00010517          	auipc	a0,0x10
    80001db0:	5b450513          	addi	a0,a0,1460 # 80012360 <cpus>
    80001db4:	953e                	add	a0,a0,a5
    80001db6:	6422                	ld	s0,8(sp)
    80001db8:	0141                	addi	sp,sp,16
    80001dba:	8082                	ret

0000000080001dbc <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001dbc:	1101                	addi	sp,sp,-32
    80001dbe:	ec06                	sd	ra,24(sp)
    80001dc0:	e822                	sd	s0,16(sp)
    80001dc2:	e426                	sd	s1,8(sp)
    80001dc4:	1000                	addi	s0,sp,32
  push_off();
    80001dc6:	fffff097          	auipc	ra,0xfffff
    80001dca:	e06080e7          	jalr	-506(ra) # 80000bcc <push_off>
    80001dce:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001dd0:	2781                	sext.w	a5,a5
    80001dd2:	079e                	slli	a5,a5,0x7
    80001dd4:	00010717          	auipc	a4,0x10
    80001dd8:	4cc70713          	addi	a4,a4,1228 # 800122a0 <queue>
    80001ddc:	97ba                	add	a5,a5,a4
    80001dde:	63e4                	ld	s1,192(a5)
  pop_off();
    80001de0:	fffff097          	auipc	ra,0xfffff
    80001de4:	e8c080e7          	jalr	-372(ra) # 80000c6c <pop_off>
  return p;
}
    80001de8:	8526                	mv	a0,s1
    80001dea:	60e2                	ld	ra,24(sp)
    80001dec:	6442                	ld	s0,16(sp)
    80001dee:	64a2                	ld	s1,8(sp)
    80001df0:	6105                	addi	sp,sp,32
    80001df2:	8082                	ret

0000000080001df4 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001df4:	1141                	addi	sp,sp,-16
    80001df6:	e406                	sd	ra,8(sp)
    80001df8:	e022                	sd	s0,0(sp)
    80001dfa:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001dfc:	00000097          	auipc	ra,0x0
    80001e00:	fc0080e7          	jalr	-64(ra) # 80001dbc <myproc>
    80001e04:	fffff097          	auipc	ra,0xfffff
    80001e08:	ec8080e7          	jalr	-312(ra) # 80000ccc <release>

  if (first) {
    80001e0c:	00008797          	auipc	a5,0x8
    80001e10:	ad47a783          	lw	a5,-1324(a5) # 800098e0 <first.1>
    80001e14:	eb89                	bnez	a5,80001e26 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001e16:	00001097          	auipc	ra,0x1
    80001e1a:	39c080e7          	jalr	924(ra) # 800031b2 <usertrapret>
}
    80001e1e:	60a2                	ld	ra,8(sp)
    80001e20:	6402                	ld	s0,0(sp)
    80001e22:	0141                	addi	sp,sp,16
    80001e24:	8082                	ret
    first = 0;
    80001e26:	00008797          	auipc	a5,0x8
    80001e2a:	aa07ad23          	sw	zero,-1350(a5) # 800098e0 <first.1>
    fsinit(ROOTDEV);
    80001e2e:	4505                	li	a0,1
    80001e30:	00002097          	auipc	ra,0x2
    80001e34:	4a0080e7          	jalr	1184(ra) # 800042d0 <fsinit>
    80001e38:	bff9                	j	80001e16 <forkret+0x22>

0000000080001e3a <allocpid>:
allocpid() {
    80001e3a:	1101                	addi	sp,sp,-32
    80001e3c:	ec06                	sd	ra,24(sp)
    80001e3e:	e822                	sd	s0,16(sp)
    80001e40:	e426                	sd	s1,8(sp)
    80001e42:	e04a                	sd	s2,0(sp)
    80001e44:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001e46:	00010917          	auipc	s2,0x10
    80001e4a:	4ea90913          	addi	s2,s2,1258 # 80012330 <pid_lock>
    80001e4e:	854a                	mv	a0,s2
    80001e50:	fffff097          	auipc	ra,0xfffff
    80001e54:	dc8080e7          	jalr	-568(ra) # 80000c18 <acquire>
  pid = nextpid;
    80001e58:	00008797          	auipc	a5,0x8
    80001e5c:	a8c78793          	addi	a5,a5,-1396 # 800098e4 <nextpid>
    80001e60:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001e62:	0014871b          	addiw	a4,s1,1
    80001e66:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001e68:	854a                	mv	a0,s2
    80001e6a:	fffff097          	auipc	ra,0xfffff
    80001e6e:	e62080e7          	jalr	-414(ra) # 80000ccc <release>
}
    80001e72:	8526                	mv	a0,s1
    80001e74:	60e2                	ld	ra,24(sp)
    80001e76:	6442                	ld	s0,16(sp)
    80001e78:	64a2                	ld	s1,8(sp)
    80001e7a:	6902                	ld	s2,0(sp)
    80001e7c:	6105                	addi	sp,sp,32
    80001e7e:	8082                	ret

0000000080001e80 <proc_pagetable>:
{
    80001e80:	1101                	addi	sp,sp,-32
    80001e82:	ec06                	sd	ra,24(sp)
    80001e84:	e822                	sd	s0,16(sp)
    80001e86:	e426                	sd	s1,8(sp)
    80001e88:	e04a                	sd	s2,0(sp)
    80001e8a:	1000                	addi	s0,sp,32
    80001e8c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001e8e:	fffff097          	auipc	ra,0xfffff
    80001e92:	4e0080e7          	jalr	1248(ra) # 8000136e <uvmcreate>
    80001e96:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001e98:	c121                	beqz	a0,80001ed8 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001e9a:	4729                	li	a4,10
    80001e9c:	00006697          	auipc	a3,0x6
    80001ea0:	16468693          	addi	a3,a3,356 # 80008000 <_trampoline>
    80001ea4:	6605                	lui	a2,0x1
    80001ea6:	040005b7          	lui	a1,0x4000
    80001eaa:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001eac:	05b2                	slli	a1,a1,0xc
    80001eae:	fffff097          	auipc	ra,0xfffff
    80001eb2:	236080e7          	jalr	566(ra) # 800010e4 <mappages>
    80001eb6:	02054863          	bltz	a0,80001ee6 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001eba:	4719                	li	a4,6
    80001ebc:	07893683          	ld	a3,120(s2)
    80001ec0:	6605                	lui	a2,0x1
    80001ec2:	020005b7          	lui	a1,0x2000
    80001ec6:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ec8:	05b6                	slli	a1,a1,0xd
    80001eca:	8526                	mv	a0,s1
    80001ecc:	fffff097          	auipc	ra,0xfffff
    80001ed0:	218080e7          	jalr	536(ra) # 800010e4 <mappages>
    80001ed4:	02054163          	bltz	a0,80001ef6 <proc_pagetable+0x76>
}
    80001ed8:	8526                	mv	a0,s1
    80001eda:	60e2                	ld	ra,24(sp)
    80001edc:	6442                	ld	s0,16(sp)
    80001ede:	64a2                	ld	s1,8(sp)
    80001ee0:	6902                	ld	s2,0(sp)
    80001ee2:	6105                	addi	sp,sp,32
    80001ee4:	8082                	ret
    uvmfree(pagetable, 0);
    80001ee6:	4581                	li	a1,0
    80001ee8:	8526                	mv	a0,s1
    80001eea:	fffff097          	auipc	ra,0xfffff
    80001eee:	682080e7          	jalr	1666(ra) # 8000156c <uvmfree>
    return 0;
    80001ef2:	4481                	li	s1,0
    80001ef4:	b7d5                	j	80001ed8 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ef6:	4681                	li	a3,0
    80001ef8:	4605                	li	a2,1
    80001efa:	040005b7          	lui	a1,0x4000
    80001efe:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001f00:	05b2                	slli	a1,a1,0xc
    80001f02:	8526                	mv	a0,s1
    80001f04:	fffff097          	auipc	ra,0xfffff
    80001f08:	3a6080e7          	jalr	934(ra) # 800012aa <uvmunmap>
    uvmfree(pagetable, 0);
    80001f0c:	4581                	li	a1,0
    80001f0e:	8526                	mv	a0,s1
    80001f10:	fffff097          	auipc	ra,0xfffff
    80001f14:	65c080e7          	jalr	1628(ra) # 8000156c <uvmfree>
    return 0;
    80001f18:	4481                	li	s1,0
    80001f1a:	bf7d                	j	80001ed8 <proc_pagetable+0x58>

0000000080001f1c <proc_freepagetable>:
{
    80001f1c:	1101                	addi	sp,sp,-32
    80001f1e:	ec06                	sd	ra,24(sp)
    80001f20:	e822                	sd	s0,16(sp)
    80001f22:	e426                	sd	s1,8(sp)
    80001f24:	e04a                	sd	s2,0(sp)
    80001f26:	1000                	addi	s0,sp,32
    80001f28:	84aa                	mv	s1,a0
    80001f2a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001f2c:	4681                	li	a3,0
    80001f2e:	4605                	li	a2,1
    80001f30:	040005b7          	lui	a1,0x4000
    80001f34:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001f36:	05b2                	slli	a1,a1,0xc
    80001f38:	fffff097          	auipc	ra,0xfffff
    80001f3c:	372080e7          	jalr	882(ra) # 800012aa <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001f40:	4681                	li	a3,0
    80001f42:	4605                	li	a2,1
    80001f44:	020005b7          	lui	a1,0x2000
    80001f48:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001f4a:	05b6                	slli	a1,a1,0xd
    80001f4c:	8526                	mv	a0,s1
    80001f4e:	fffff097          	auipc	ra,0xfffff
    80001f52:	35c080e7          	jalr	860(ra) # 800012aa <uvmunmap>
  uvmfree(pagetable, sz);
    80001f56:	85ca                	mv	a1,s2
    80001f58:	8526                	mv	a0,s1
    80001f5a:	fffff097          	auipc	ra,0xfffff
    80001f5e:	612080e7          	jalr	1554(ra) # 8000156c <uvmfree>
}
    80001f62:	60e2                	ld	ra,24(sp)
    80001f64:	6442                	ld	s0,16(sp)
    80001f66:	64a2                	ld	s1,8(sp)
    80001f68:	6902                	ld	s2,0(sp)
    80001f6a:	6105                	addi	sp,sp,32
    80001f6c:	8082                	ret

0000000080001f6e <growproc>:
{
    80001f6e:	1101                	addi	sp,sp,-32
    80001f70:	ec06                	sd	ra,24(sp)
    80001f72:	e822                	sd	s0,16(sp)
    80001f74:	e426                	sd	s1,8(sp)
    80001f76:	e04a                	sd	s2,0(sp)
    80001f78:	1000                	addi	s0,sp,32
    80001f7a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001f7c:	00000097          	auipc	ra,0x0
    80001f80:	e40080e7          	jalr	-448(ra) # 80001dbc <myproc>
    80001f84:	892a                	mv	s2,a0
  sz = p->sz;
    80001f86:	752c                	ld	a1,104(a0)
    80001f88:	0005879b          	sext.w	a5,a1
  if(n > 0){
    80001f8c:	00904f63          	bgtz	s1,80001faa <growproc+0x3c>
  } else if(n < 0){
    80001f90:	0204cd63          	bltz	s1,80001fca <growproc+0x5c>
  p->sz = sz;
    80001f94:	1782                	slli	a5,a5,0x20
    80001f96:	9381                	srli	a5,a5,0x20
    80001f98:	06f93423          	sd	a5,104(s2)
  return 0;
    80001f9c:	4501                	li	a0,0
}
    80001f9e:	60e2                	ld	ra,24(sp)
    80001fa0:	6442                	ld	s0,16(sp)
    80001fa2:	64a2                	ld	s1,8(sp)
    80001fa4:	6902                	ld	s2,0(sp)
    80001fa6:	6105                	addi	sp,sp,32
    80001fa8:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001faa:	00f4863b          	addw	a2,s1,a5
    80001fae:	1602                	slli	a2,a2,0x20
    80001fb0:	9201                	srli	a2,a2,0x20
    80001fb2:	1582                	slli	a1,a1,0x20
    80001fb4:	9181                	srli	a1,a1,0x20
    80001fb6:	7928                	ld	a0,112(a0)
    80001fb8:	fffff097          	auipc	ra,0xfffff
    80001fbc:	49e080e7          	jalr	1182(ra) # 80001456 <uvmalloc>
    80001fc0:	0005079b          	sext.w	a5,a0
    80001fc4:	fbe1                	bnez	a5,80001f94 <growproc+0x26>
      return -1;
    80001fc6:	557d                	li	a0,-1
    80001fc8:	bfd9                	j	80001f9e <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001fca:	00f4863b          	addw	a2,s1,a5
    80001fce:	1602                	slli	a2,a2,0x20
    80001fd0:	9201                	srli	a2,a2,0x20
    80001fd2:	1582                	slli	a1,a1,0x20
    80001fd4:	9181                	srli	a1,a1,0x20
    80001fd6:	7928                	ld	a0,112(a0)
    80001fd8:	fffff097          	auipc	ra,0xfffff
    80001fdc:	436080e7          	jalr	1078(ra) # 8000140e <uvmdealloc>
    80001fe0:	0005079b          	sext.w	a5,a0
    80001fe4:	bf45                	j	80001f94 <growproc+0x26>

0000000080001fe6 <scheduler>:
{
    80001fe6:	715d                	addi	sp,sp,-80
    80001fe8:	e486                	sd	ra,72(sp)
    80001fea:	e0a2                	sd	s0,64(sp)
    80001fec:	fc26                	sd	s1,56(sp)
    80001fee:	f84a                	sd	s2,48(sp)
    80001ff0:	f44e                	sd	s3,40(sp)
    80001ff2:	f052                	sd	s4,32(sp)
    80001ff4:	ec56                	sd	s5,24(sp)
    80001ff6:	e85a                	sd	s6,16(sp)
    80001ff8:	e45e                	sd	s7,8(sp)
    80001ffa:	0880                	addi	s0,sp,80
    80001ffc:	8792                	mv	a5,tp
  int id = r_tp();
    80001ffe:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002000:	00779a93          	slli	s5,a5,0x7
    80002004:	00010717          	auipc	a4,0x10
    80002008:	29c70713          	addi	a4,a4,668 # 800122a0 <queue>
    8000200c:	9756                	add	a4,a4,s5
    8000200e:	0c073023          	sd	zero,192(a4)
          swtch(&c->context, &p->context);
    80002012:	00010717          	auipc	a4,0x10
    80002016:	35670713          	addi	a4,a4,854 # 80012368 <cpus+0x8>
    8000201a:	9aba                	add	s5,s5,a4
    if(sched_policy == RR) {
    8000201c:	00008b97          	auipc	s7,0x8
    80002020:	014b8b93          	addi	s7,s7,20 # 8000a030 <sched_policy>
          p->state = RUNNING;
    80002024:	4b11                	li	s6,4
          c->proc = p;
    80002026:	079e                	slli	a5,a5,0x7
    80002028:	00010a17          	auipc	s4,0x10
    8000202c:	278a0a13          	addi	s4,s4,632 # 800122a0 <queue>
    80002030:	9a3e                	add	s4,s4,a5
      for(p = proc; p < &proc[NPROC]; p++) {
    80002032:	00022997          	auipc	s3,0x22
    80002036:	f4698993          	addi	s3,s3,-186 # 80023f78 <mmr_list>
    8000203a:	a099                	j	80002080 <scheduler+0x9a>
        release(&p->lock);
    8000203c:	8526                	mv	a0,s1
    8000203e:	fffff097          	auipc	ra,0xfffff
    80002042:	c8e080e7          	jalr	-882(ra) # 80000ccc <release>
      for(p = proc; p < &proc[NPROC]; p++) {
    80002046:	46048493          	addi	s1,s1,1120
    8000204a:	03348b63          	beq	s1,s3,80002080 <scheduler+0x9a>
        acquire(&p->lock);
    8000204e:	8526                	mv	a0,s1
    80002050:	fffff097          	auipc	ra,0xfffff
    80002054:	bc8080e7          	jalr	-1080(ra) # 80000c18 <acquire>
        if(p->state == RUNNABLE) {
    80002058:	4c9c                	lw	a5,24(s1)
    8000205a:	ff2791e3          	bne	a5,s2,8000203c <scheduler+0x56>
          p->state = RUNNING;
    8000205e:	0164ac23          	sw	s6,24(s1)
          c->proc = p;
    80002062:	0c9a3023          	sd	s1,192(s4)
          swtch(&c->context, &p->context);
    80002066:	08048593          	addi	a1,s1,128
    8000206a:	8556                	mv	a0,s5
    8000206c:	00001097          	auipc	ra,0x1
    80002070:	09c080e7          	jalr	156(ra) # 80003108 <swtch>
          c->proc = 0;
    80002074:	0c0a3023          	sd	zero,192(s4)
    80002078:	b7d1                	j	8000203c <scheduler+0x56>
    } else if(sched_policy == MLFQ) {
    8000207a:	4705                	li	a4,1
    8000207c:	02e78163          	beq	a5,a4,8000209e <scheduler+0xb8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002080:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002084:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002088:	10079073          	csrw	sstatus,a5
    if(sched_policy == RR) {
    8000208c:	000ba783          	lw	a5,0(s7)
    80002090:	f7ed                	bnez	a5,8000207a <scheduler+0x94>
      for(p = proc; p < &proc[NPROC]; p++) {
    80002092:	00010497          	auipc	s1,0x10
    80002096:	6e648493          	addi	s1,s1,1766 # 80012778 <proc>
        if(p->state == RUNNABLE) {
    8000209a:	490d                	li	s2,3
    8000209c:	bf4d                	j	8000204e <scheduler+0x68>
      p = dequeue(HIGH);
    8000209e:	4501                	li	a0,0
    800020a0:	00000097          	auipc	ra,0x0
    800020a4:	9de080e7          	jalr	-1570(ra) # 80001a7e <dequeue>
    800020a8:	84aa                	mv	s1,a0
      if(!p)
    800020aa:	c10d                	beqz	a0,800020cc <scheduler+0xe6>
        acquire(&p->lock);
    800020ac:	8926                	mv	s2,s1
    800020ae:	8526                	mv	a0,s1
    800020b0:	fffff097          	auipc	ra,0xfffff
    800020b4:	b68080e7          	jalr	-1176(ra) # 80000c18 <acquire>
        if(p->state == RUNNABLE){;
    800020b8:	4c98                	lw	a4,24(s1)
    800020ba:	478d                	li	a5,3
    800020bc:	02f70763          	beq	a4,a5,800020ea <scheduler+0x104>
        release(&p->lock);
    800020c0:	854a                	mv	a0,s2
    800020c2:	fffff097          	auipc	ra,0xfffff
    800020c6:	c0a080e7          	jalr	-1014(ra) # 80000ccc <release>
    800020ca:	bf5d                	j	80002080 <scheduler+0x9a>
        p = dequeue(MEDIUM);
    800020cc:	4505                	li	a0,1
    800020ce:	00000097          	auipc	ra,0x0
    800020d2:	9b0080e7          	jalr	-1616(ra) # 80001a7e <dequeue>
    800020d6:	84aa                	mv	s1,a0
      if(!p)
    800020d8:	f971                	bnez	a0,800020ac <scheduler+0xc6>
        p = dequeue(LOW);
    800020da:	4509                	li	a0,2
    800020dc:	00000097          	auipc	ra,0x0
    800020e0:	9a2080e7          	jalr	-1630(ra) # 80001a7e <dequeue>
    800020e4:	84aa                	mv	s1,a0
      if(p){
    800020e6:	dd49                	beqz	a0,80002080 <scheduler+0x9a>
    800020e8:	b7d1                	j	800020ac <scheduler+0xc6>
          p->state = RUNNING;
    800020ea:	0164ac23          	sw	s6,24(s1)
          c->proc = p;
    800020ee:	0c9a3023          	sd	s1,192(s4)
          swtch(&c->context, &p->context);
    800020f2:	08048593          	addi	a1,s1,128
    800020f6:	8556                	mv	a0,s5
    800020f8:	00001097          	auipc	ra,0x1
    800020fc:	010080e7          	jalr	16(ra) # 80003108 <swtch>
          c->proc = 0;
    80002100:	0c0a3023          	sd	zero,192(s4)
    80002104:	bf75                	j	800020c0 <scheduler+0xda>

0000000080002106 <sched>:
{
    80002106:	7179                	addi	sp,sp,-48
    80002108:	f406                	sd	ra,40(sp)
    8000210a:	f022                	sd	s0,32(sp)
    8000210c:	ec26                	sd	s1,24(sp)
    8000210e:	e84a                	sd	s2,16(sp)
    80002110:	e44e                	sd	s3,8(sp)
    80002112:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002114:	00000097          	auipc	ra,0x0
    80002118:	ca8080e7          	jalr	-856(ra) # 80001dbc <myproc>
    8000211c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000211e:	fffff097          	auipc	ra,0xfffff
    80002122:	a80080e7          	jalr	-1408(ra) # 80000b9e <holding>
    80002126:	c93d                	beqz	a0,8000219c <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002128:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000212a:	2781                	sext.w	a5,a5
    8000212c:	079e                	slli	a5,a5,0x7
    8000212e:	00010717          	auipc	a4,0x10
    80002132:	17270713          	addi	a4,a4,370 # 800122a0 <queue>
    80002136:	97ba                	add	a5,a5,a4
    80002138:	1387a703          	lw	a4,312(a5)
    8000213c:	4785                	li	a5,1
    8000213e:	06f71763          	bne	a4,a5,800021ac <sched+0xa6>
  if(p->state == RUNNING)
    80002142:	4c98                	lw	a4,24(s1)
    80002144:	4791                	li	a5,4
    80002146:	06f70b63          	beq	a4,a5,800021bc <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000214a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000214e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002150:	efb5                	bnez	a5,800021cc <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002152:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002154:	00010917          	auipc	s2,0x10
    80002158:	14c90913          	addi	s2,s2,332 # 800122a0 <queue>
    8000215c:	2781                	sext.w	a5,a5
    8000215e:	079e                	slli	a5,a5,0x7
    80002160:	97ca                	add	a5,a5,s2
    80002162:	13c7a983          	lw	s3,316(a5)
    80002166:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002168:	2781                	sext.w	a5,a5
    8000216a:	079e                	slli	a5,a5,0x7
    8000216c:	00010597          	auipc	a1,0x10
    80002170:	1fc58593          	addi	a1,a1,508 # 80012368 <cpus+0x8>
    80002174:	95be                	add	a1,a1,a5
    80002176:	08048513          	addi	a0,s1,128
    8000217a:	00001097          	auipc	ra,0x1
    8000217e:	f8e080e7          	jalr	-114(ra) # 80003108 <swtch>
    80002182:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002184:	2781                	sext.w	a5,a5
    80002186:	079e                	slli	a5,a5,0x7
    80002188:	993e                	add	s2,s2,a5
    8000218a:	13392e23          	sw	s3,316(s2)
}
    8000218e:	70a2                	ld	ra,40(sp)
    80002190:	7402                	ld	s0,32(sp)
    80002192:	64e2                	ld	s1,24(sp)
    80002194:	6942                	ld	s2,16(sp)
    80002196:	69a2                	ld	s3,8(sp)
    80002198:	6145                	addi	sp,sp,48
    8000219a:	8082                	ret
    panic("sched p->lock");
    8000219c:	00007517          	auipc	a0,0x7
    800021a0:	0c450513          	addi	a0,a0,196 # 80009260 <digits+0x220>
    800021a4:	ffffe097          	auipc	ra,0xffffe
    800021a8:	396080e7          	jalr	918(ra) # 8000053a <panic>
    panic("sched locks");
    800021ac:	00007517          	auipc	a0,0x7
    800021b0:	0c450513          	addi	a0,a0,196 # 80009270 <digits+0x230>
    800021b4:	ffffe097          	auipc	ra,0xffffe
    800021b8:	386080e7          	jalr	902(ra) # 8000053a <panic>
    panic("sched running");
    800021bc:	00007517          	auipc	a0,0x7
    800021c0:	0c450513          	addi	a0,a0,196 # 80009280 <digits+0x240>
    800021c4:	ffffe097          	auipc	ra,0xffffe
    800021c8:	376080e7          	jalr	886(ra) # 8000053a <panic>
    panic("sched interruptible");
    800021cc:	00007517          	auipc	a0,0x7
    800021d0:	0c450513          	addi	a0,a0,196 # 80009290 <digits+0x250>
    800021d4:	ffffe097          	auipc	ra,0xffffe
    800021d8:	366080e7          	jalr	870(ra) # 8000053a <panic>

00000000800021dc <yield>:
{
    800021dc:	1101                	addi	sp,sp,-32
    800021de:	ec06                	sd	ra,24(sp)
    800021e0:	e822                	sd	s0,16(sp)
    800021e2:	e426                	sd	s1,8(sp)
    800021e4:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800021e6:	00000097          	auipc	ra,0x0
    800021ea:	bd6080e7          	jalr	-1066(ra) # 80001dbc <myproc>
    800021ee:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021f0:	fffff097          	auipc	ra,0xfffff
    800021f4:	a28080e7          	jalr	-1496(ra) # 80000c18 <acquire>
  p->state = RUNNABLE;
    800021f8:	478d                	li	a5,3
    800021fa:	cc9c                	sw	a5,24(s1)
  enqueue_at_tail(p, p->priority);
    800021fc:	40ec                	lw	a1,68(s1)
    800021fe:	8526                	mv	a0,s1
    80002200:	fffff097          	auipc	ra,0xfffff
    80002204:	790080e7          	jalr	1936(ra) # 80001990 <enqueue_at_tail>
  sched();
    80002208:	00000097          	auipc	ra,0x0
    8000220c:	efe080e7          	jalr	-258(ra) # 80002106 <sched>
  release(&p->lock);
    80002210:	8526                	mv	a0,s1
    80002212:	fffff097          	auipc	ra,0xfffff
    80002216:	aba080e7          	jalr	-1350(ra) # 80000ccc <release>
}
    8000221a:	60e2                	ld	ra,24(sp)
    8000221c:	6442                	ld	s0,16(sp)
    8000221e:	64a2                	ld	s1,8(sp)
    80002220:	6105                	addi	sp,sp,32
    80002222:	8082                	ret

0000000080002224 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002224:	7179                	addi	sp,sp,-48
    80002226:	f406                	sd	ra,40(sp)
    80002228:	f022                	sd	s0,32(sp)
    8000222a:	ec26                	sd	s1,24(sp)
    8000222c:	e84a                	sd	s2,16(sp)
    8000222e:	e44e                	sd	s3,8(sp)
    80002230:	1800                	addi	s0,sp,48
    80002232:	89aa                	mv	s3,a0
    80002234:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002236:	00000097          	auipc	ra,0x0
    8000223a:	b86080e7          	jalr	-1146(ra) # 80001dbc <myproc>
    8000223e:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002240:	fffff097          	auipc	ra,0xfffff
    80002244:	9d8080e7          	jalr	-1576(ra) # 80000c18 <acquire>
  release(lk);
    80002248:	854a                	mv	a0,s2
    8000224a:	fffff097          	auipc	ra,0xfffff
    8000224e:	a82080e7          	jalr	-1406(ra) # 80000ccc <release>

  // Go to sleep.
  p->chan = chan;
    80002252:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002256:	4789                	li	a5,2
    80002258:	cc9c                	sw	a5,24(s1)

  sched();
    8000225a:	00000097          	auipc	ra,0x0
    8000225e:	eac080e7          	jalr	-340(ra) # 80002106 <sched>

  // Tidy up.
  p->chan = 0;
    80002262:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002266:	8526                	mv	a0,s1
    80002268:	fffff097          	auipc	ra,0xfffff
    8000226c:	a64080e7          	jalr	-1436(ra) # 80000ccc <release>
  acquire(lk);
    80002270:	854a                	mv	a0,s2
    80002272:	fffff097          	auipc	ra,0xfffff
    80002276:	9a6080e7          	jalr	-1626(ra) # 80000c18 <acquire>
}
    8000227a:	70a2                	ld	ra,40(sp)
    8000227c:	7402                	ld	s0,32(sp)
    8000227e:	64e2                	ld	s1,24(sp)
    80002280:	6942                	ld	s2,16(sp)
    80002282:	69a2                	ld	s3,8(sp)
    80002284:	6145                	addi	sp,sp,48
    80002286:	8082                	ret

0000000080002288 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002288:	711d                	addi	sp,sp,-96
    8000228a:	ec86                	sd	ra,88(sp)
    8000228c:	e8a2                	sd	s0,80(sp)
    8000228e:	e4a6                	sd	s1,72(sp)
    80002290:	e0ca                	sd	s2,64(sp)
    80002292:	fc4e                	sd	s3,56(sp)
    80002294:	f852                	sd	s4,48(sp)
    80002296:	f456                	sd	s5,40(sp)
    80002298:	f05a                	sd	s6,32(sp)
    8000229a:	ec5e                	sd	s7,24(sp)
    8000229c:	e862                	sd	s8,16(sp)
    8000229e:	e466                	sd	s9,8(sp)
    800022a0:	1080                	addi	s0,sp,96
    800022a2:	8aaa                	mv	s5,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800022a4:	00010497          	auipc	s1,0x10
    800022a8:	4d448493          	addi	s1,s1,1236 # 80012778 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800022ac:	4989                	li	s3,2
        p->state = RUNNABLE;
    800022ae:	4c0d                	li	s8,3
  if (!(p >= proc && p < &proc[NPROC]))
    800022b0:	8ba6                	mv	s7,s1
  acquire(&queue[priority].lock);
    800022b2:	00010b17          	auipc	s6,0x10
    800022b6:	feeb0b13          	addi	s6,s6,-18 # 800122a0 <queue>
  for(p = proc; p < &proc[NPROC]; p++) {
    800022ba:	00022917          	auipc	s2,0x22
    800022be:	cbe90913          	addi	s2,s2,-834 # 80023f78 <mmr_list>
    800022c2:	a085                	j	80002322 <wakeup+0x9a>
    panic("enqueue_at_head");
    800022c4:	00007517          	auipc	a0,0x7
    800022c8:	fe450513          	addi	a0,a0,-28 # 800092a8 <digits+0x268>
    800022cc:	ffffe097          	auipc	ra,0xffffe
    800022d0:	26e080e7          	jalr	622(ra) # 8000053a <panic>
    panic("enqueue_at_head");
    800022d4:	00007517          	auipc	a0,0x7
    800022d8:	fd450513          	addi	a0,a0,-44 # 800092a8 <digits+0x268>
    800022dc:	ffffe097          	auipc	ra,0xffffe
    800022e0:	25e080e7          	jalr	606(ra) # 8000053a <panic>
    queue[priority].head = p;
    800022e4:	029a3023          	sd	s1,32(s4)
    queue[priority].tail = p;
    800022e8:	029a3423          	sd	s1,40(s4)
    release(&queue[priority].lock);
    800022ec:	8552                	mv	a0,s4
    800022ee:	fffff097          	auipc	ra,0xfffff
    800022f2:	9de080e7          	jalr	-1570(ra) # 80000ccc <release>
    return(0);
    800022f6:	a829                	j	80002310 <wakeup+0x88>
  p->next = queue[priority].head;
    800022f8:	e8bc                	sd	a5,80(s1)
  queue[priority].head = p;
    800022fa:	001c9793          	slli	a5,s9,0x1
    800022fe:	97e6                	add	a5,a5,s9
    80002300:	0792                	slli	a5,a5,0x4
    80002302:	97da                	add	a5,a5,s6
    80002304:	f384                	sd	s1,32(a5)
  release(&queue[priority].lock);
    80002306:	8552                	mv	a0,s4
    80002308:	fffff097          	auipc	ra,0xfffff
    8000230c:	9c4080e7          	jalr	-1596(ra) # 80000ccc <release>
        //Determine if this is the correct behavior
        enqueue_at_head(p, p->priority);
      }
      release(&p->lock);
    80002310:	8526                	mv	a0,s1
    80002312:	fffff097          	auipc	ra,0xfffff
    80002316:	9ba080e7          	jalr	-1606(ra) # 80000ccc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000231a:	46048493          	addi	s1,s1,1120
    8000231e:	07248863          	beq	s1,s2,8000238e <wakeup+0x106>
    if(p != myproc()){
    80002322:	00000097          	auipc	ra,0x0
    80002326:	a9a080e7          	jalr	-1382(ra) # 80001dbc <myproc>
    8000232a:	fea488e3          	beq	s1,a0,8000231a <wakeup+0x92>
      acquire(&p->lock);
    8000232e:	8526                	mv	a0,s1
    80002330:	fffff097          	auipc	ra,0xfffff
    80002334:	8e8080e7          	jalr	-1816(ra) # 80000c18 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002338:	4c9c                	lw	a5,24(s1)
    8000233a:	fd379be3          	bne	a5,s3,80002310 <wakeup+0x88>
    8000233e:	709c                	ld	a5,32(s1)
    80002340:	fd5798e3          	bne	a5,s5,80002310 <wakeup+0x88>
        p->state = RUNNABLE;
    80002344:	0184ac23          	sw	s8,24(s1)
        enqueue_at_head(p, p->priority);
    80002348:	0444ac83          	lw	s9,68(s1)
  if (!(p >= proc && p < &proc[NPROC]))
    8000234c:	f774ece3          	bltu	s1,s7,800022c4 <wakeup+0x3c>
  if (!(priority >= 0) && (priority < NQUEUE))
    80002350:	f80cc2e3          	bltz	s9,800022d4 <wakeup+0x4c>
  acquire(&queue[priority].lock);
    80002354:	001c9a13          	slli	s4,s9,0x1
    80002358:	9a66                	add	s4,s4,s9
    8000235a:	0a12                	slli	s4,s4,0x4
    8000235c:	9a5a                	add	s4,s4,s6
    8000235e:	8552                	mv	a0,s4
    80002360:	fffff097          	auipc	ra,0xfffff
    80002364:	8b8080e7          	jalr	-1864(ra) # 80000c18 <acquire>
  if ((queue[priority].head == 0) && (queue[priority].tail == 0)) {
    80002368:	020a3783          	ld	a5,32(s4)
    8000236c:	f7d1                	bnez	a5,800022f8 <wakeup+0x70>
    8000236e:	028a3783          	ld	a5,40(s4)
    80002372:	dbad                	beqz	a5,800022e4 <wakeup+0x5c>
    release(&queue[priority].lock);
    80002374:	8552                	mv	a0,s4
    80002376:	fffff097          	auipc	ra,0xfffff
    8000237a:	956080e7          	jalr	-1706(ra) # 80000ccc <release>
    panic("enqueue_at_head");
    8000237e:	00007517          	auipc	a0,0x7
    80002382:	f2a50513          	addi	a0,a0,-214 # 800092a8 <digits+0x268>
    80002386:	ffffe097          	auipc	ra,0xffffe
    8000238a:	1b4080e7          	jalr	436(ra) # 8000053a <panic>
    }
  }
}
    8000238e:	60e6                	ld	ra,88(sp)
    80002390:	6446                	ld	s0,80(sp)
    80002392:	64a6                	ld	s1,72(sp)
    80002394:	6906                	ld	s2,64(sp)
    80002396:	79e2                	ld	s3,56(sp)
    80002398:	7a42                	ld	s4,48(sp)
    8000239a:	7aa2                	ld	s5,40(sp)
    8000239c:	7b02                	ld	s6,32(sp)
    8000239e:	6be2                	ld	s7,24(sp)
    800023a0:	6c42                	ld	s8,16(sp)
    800023a2:	6ca2                	ld	s9,8(sp)
    800023a4:	6125                	addi	sp,sp,96
    800023a6:	8082                	ret

00000000800023a8 <reparent>:
{
    800023a8:	7179                	addi	sp,sp,-48
    800023aa:	f406                	sd	ra,40(sp)
    800023ac:	f022                	sd	s0,32(sp)
    800023ae:	ec26                	sd	s1,24(sp)
    800023b0:	e84a                	sd	s2,16(sp)
    800023b2:	e44e                	sd	s3,8(sp)
    800023b4:	e052                	sd	s4,0(sp)
    800023b6:	1800                	addi	s0,sp,48
    800023b8:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800023ba:	00010497          	auipc	s1,0x10
    800023be:	3be48493          	addi	s1,s1,958 # 80012778 <proc>
      pp->parent = initproc;
    800023c2:	00008a17          	auipc	s4,0x8
    800023c6:	c66a0a13          	addi	s4,s4,-922 # 8000a028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800023ca:	00022997          	auipc	s3,0x22
    800023ce:	bae98993          	addi	s3,s3,-1106 # 80023f78 <mmr_list>
    800023d2:	a029                	j	800023dc <reparent+0x34>
    800023d4:	46048493          	addi	s1,s1,1120
    800023d8:	01348d63          	beq	s1,s3,800023f2 <reparent+0x4a>
    if(pp->parent == p){
    800023dc:	6cbc                	ld	a5,88(s1)
    800023de:	ff279be3          	bne	a5,s2,800023d4 <reparent+0x2c>
      pp->parent = initproc;
    800023e2:	000a3503          	ld	a0,0(s4)
    800023e6:	eca8                	sd	a0,88(s1)
      wakeup(initproc);
    800023e8:	00000097          	auipc	ra,0x0
    800023ec:	ea0080e7          	jalr	-352(ra) # 80002288 <wakeup>
    800023f0:	b7d5                	j	800023d4 <reparent+0x2c>
}
    800023f2:	70a2                	ld	ra,40(sp)
    800023f4:	7402                	ld	s0,32(sp)
    800023f6:	64e2                	ld	s1,24(sp)
    800023f8:	6942                	ld	s2,16(sp)
    800023fa:	69a2                	ld	s3,8(sp)
    800023fc:	6a02                	ld	s4,0(sp)
    800023fe:	6145                	addi	sp,sp,48
    80002400:	8082                	ret

0000000080002402 <exit>:
{
    80002402:	7179                	addi	sp,sp,-48
    80002404:	f406                	sd	ra,40(sp)
    80002406:	f022                	sd	s0,32(sp)
    80002408:	ec26                	sd	s1,24(sp)
    8000240a:	e84a                	sd	s2,16(sp)
    8000240c:	e44e                	sd	s3,8(sp)
    8000240e:	e052                	sd	s4,0(sp)
    80002410:	1800                	addi	s0,sp,48
    80002412:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002414:	00000097          	auipc	ra,0x0
    80002418:	9a8080e7          	jalr	-1624(ra) # 80001dbc <myproc>
    8000241c:	89aa                	mv	s3,a0
  if(p == initproc)
    8000241e:	00008797          	auipc	a5,0x8
    80002422:	c0a7b783          	ld	a5,-1014(a5) # 8000a028 <initproc>
    80002426:	0f050493          	addi	s1,a0,240
    8000242a:	17050913          	addi	s2,a0,368
    8000242e:	02a79363          	bne	a5,a0,80002454 <exit+0x52>
    panic("init exiting");
    80002432:	00007517          	auipc	a0,0x7
    80002436:	e8650513          	addi	a0,a0,-378 # 800092b8 <digits+0x278>
    8000243a:	ffffe097          	auipc	ra,0xffffe
    8000243e:	100080e7          	jalr	256(ra) # 8000053a <panic>
      fileclose(f);
    80002442:	00003097          	auipc	ra,0x3
    80002446:	fac080e7          	jalr	-84(ra) # 800053ee <fileclose>
      p->ofile[fd] = 0;
    8000244a:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000244e:	04a1                	addi	s1,s1,8
    80002450:	01248563          	beq	s1,s2,8000245a <exit+0x58>
    if(p->ofile[fd]){
    80002454:	6088                	ld	a0,0(s1)
    80002456:	f575                	bnez	a0,80002442 <exit+0x40>
    80002458:	bfdd                	j	8000244e <exit+0x4c>
  begin_op();
    8000245a:	00003097          	auipc	ra,0x3
    8000245e:	acc080e7          	jalr	-1332(ra) # 80004f26 <begin_op>
  iput(p->cwd);
    80002462:	1709b503          	ld	a0,368(s3)
    80002466:	00002097          	auipc	ra,0x2
    8000246a:	29e080e7          	jalr	670(ra) # 80004704 <iput>
  end_op();
    8000246e:	00003097          	auipc	ra,0x3
    80002472:	b36080e7          	jalr	-1226(ra) # 80004fa4 <end_op>
  p->cwd = 0;
    80002476:	1609b823          	sd	zero,368(s3)
  acquire(&wait_lock);
    8000247a:	00010497          	auipc	s1,0x10
    8000247e:	ece48493          	addi	s1,s1,-306 # 80012348 <wait_lock>
    80002482:	8526                	mv	a0,s1
    80002484:	ffffe097          	auipc	ra,0xffffe
    80002488:	794080e7          	jalr	1940(ra) # 80000c18 <acquire>
  reparent(p);
    8000248c:	854e                	mv	a0,s3
    8000248e:	00000097          	auipc	ra,0x0
    80002492:	f1a080e7          	jalr	-230(ra) # 800023a8 <reparent>
  wakeup(p->parent);
    80002496:	0589b503          	ld	a0,88(s3)
    8000249a:	00000097          	auipc	ra,0x0
    8000249e:	dee080e7          	jalr	-530(ra) # 80002288 <wakeup>
  acquire(&p->lock);
    800024a2:	854e                	mv	a0,s3
    800024a4:	ffffe097          	auipc	ra,0xffffe
    800024a8:	774080e7          	jalr	1908(ra) # 80000c18 <acquire>
  p->xstate = status;
    800024ac:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800024b0:	4795                	li	a5,5
    800024b2:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800024b6:	8526                	mv	a0,s1
    800024b8:	fffff097          	auipc	ra,0xfffff
    800024bc:	814080e7          	jalr	-2028(ra) # 80000ccc <release>
  sched();
    800024c0:	00000097          	auipc	ra,0x0
    800024c4:	c46080e7          	jalr	-954(ra) # 80002106 <sched>
  panic("zombie exit");
    800024c8:	00007517          	auipc	a0,0x7
    800024cc:	e0050513          	addi	a0,a0,-512 # 800092c8 <digits+0x288>
    800024d0:	ffffe097          	auipc	ra,0xffffe
    800024d4:	06a080e7          	jalr	106(ra) # 8000053a <panic>

00000000800024d8 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800024d8:	7179                	addi	sp,sp,-48
    800024da:	f406                	sd	ra,40(sp)
    800024dc:	f022                	sd	s0,32(sp)
    800024de:	ec26                	sd	s1,24(sp)
    800024e0:	e84a                	sd	s2,16(sp)
    800024e2:	e44e                	sd	s3,8(sp)
    800024e4:	1800                	addi	s0,sp,48
    800024e6:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800024e8:	00010497          	auipc	s1,0x10
    800024ec:	29048493          	addi	s1,s1,656 # 80012778 <proc>
    800024f0:	00022997          	auipc	s3,0x22
    800024f4:	a8898993          	addi	s3,s3,-1400 # 80023f78 <mmr_list>
    acquire(&p->lock);
    800024f8:	8526                	mv	a0,s1
    800024fa:	ffffe097          	auipc	ra,0xffffe
    800024fe:	71e080e7          	jalr	1822(ra) # 80000c18 <acquire>
    if(p->pid == pid){
    80002502:	589c                	lw	a5,48(s1)
    80002504:	01278d63          	beq	a5,s2,8000251e <kill+0x46>
        
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002508:	8526                	mv	a0,s1
    8000250a:	ffffe097          	auipc	ra,0xffffe
    8000250e:	7c2080e7          	jalr	1986(ra) # 80000ccc <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002512:	46048493          	addi	s1,s1,1120
    80002516:	ff3491e3          	bne	s1,s3,800024f8 <kill+0x20>
  }
  return -1;
    8000251a:	557d                	li	a0,-1
    8000251c:	a829                	j	80002536 <kill+0x5e>
      p->killed = 1;
    8000251e:	4785                	li	a5,1
    80002520:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002522:	4c98                	lw	a4,24(s1)
    80002524:	4789                	li	a5,2
    80002526:	00f70f63          	beq	a4,a5,80002544 <kill+0x6c>
      release(&p->lock);
    8000252a:	8526                	mv	a0,s1
    8000252c:	ffffe097          	auipc	ra,0xffffe
    80002530:	7a0080e7          	jalr	1952(ra) # 80000ccc <release>
      return 0;
    80002534:	4501                	li	a0,0
}
    80002536:	70a2                	ld	ra,40(sp)
    80002538:	7402                	ld	s0,32(sp)
    8000253a:	64e2                	ld	s1,24(sp)
    8000253c:	6942                	ld	s2,16(sp)
    8000253e:	69a2                	ld	s3,8(sp)
    80002540:	6145                	addi	sp,sp,48
    80002542:	8082                	ret
        p->state = RUNNABLE;
    80002544:	478d                	li	a5,3
    80002546:	cc9c                	sw	a5,24(s1)
        enqueue_at_tail(p, p->priority);
    80002548:	40ec                	lw	a1,68(s1)
    8000254a:	8526                	mv	a0,s1
    8000254c:	fffff097          	auipc	ra,0xfffff
    80002550:	444080e7          	jalr	1092(ra) # 80001990 <enqueue_at_tail>
    80002554:	bfd9                	j	8000252a <kill+0x52>

0000000080002556 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002556:	7179                	addi	sp,sp,-48
    80002558:	f406                	sd	ra,40(sp)
    8000255a:	f022                	sd	s0,32(sp)
    8000255c:	ec26                	sd	s1,24(sp)
    8000255e:	e84a                	sd	s2,16(sp)
    80002560:	e44e                	sd	s3,8(sp)
    80002562:	e052                	sd	s4,0(sp)
    80002564:	1800                	addi	s0,sp,48
    80002566:	84aa                	mv	s1,a0
    80002568:	892e                	mv	s2,a1
    8000256a:	89b2                	mv	s3,a2
    8000256c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000256e:	00000097          	auipc	ra,0x0
    80002572:	84e080e7          	jalr	-1970(ra) # 80001dbc <myproc>
  if(user_dst){
    80002576:	c08d                	beqz	s1,80002598 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002578:	86d2                	mv	a3,s4
    8000257a:	864e                	mv	a2,s3
    8000257c:	85ca                	mv	a1,s2
    8000257e:	7928                	ld	a0,112(a0)
    80002580:	fffff097          	auipc	ra,0xfffff
    80002584:	1cc080e7          	jalr	460(ra) # 8000174c <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002588:	70a2                	ld	ra,40(sp)
    8000258a:	7402                	ld	s0,32(sp)
    8000258c:	64e2                	ld	s1,24(sp)
    8000258e:	6942                	ld	s2,16(sp)
    80002590:	69a2                	ld	s3,8(sp)
    80002592:	6a02                	ld	s4,0(sp)
    80002594:	6145                	addi	sp,sp,48
    80002596:	8082                	ret
    memmove((char *)dst, src, len);
    80002598:	000a061b          	sext.w	a2,s4
    8000259c:	85ce                	mv	a1,s3
    8000259e:	854a                	mv	a0,s2
    800025a0:	ffffe097          	auipc	ra,0xffffe
    800025a4:	7d0080e7          	jalr	2000(ra) # 80000d70 <memmove>
    return 0;
    800025a8:	8526                	mv	a0,s1
    800025aa:	bff9                	j	80002588 <either_copyout+0x32>

00000000800025ac <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800025ac:	7179                	addi	sp,sp,-48
    800025ae:	f406                	sd	ra,40(sp)
    800025b0:	f022                	sd	s0,32(sp)
    800025b2:	ec26                	sd	s1,24(sp)
    800025b4:	e84a                	sd	s2,16(sp)
    800025b6:	e44e                	sd	s3,8(sp)
    800025b8:	e052                	sd	s4,0(sp)
    800025ba:	1800                	addi	s0,sp,48
    800025bc:	892a                	mv	s2,a0
    800025be:	84ae                	mv	s1,a1
    800025c0:	89b2                	mv	s3,a2
    800025c2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025c4:	fffff097          	auipc	ra,0xfffff
    800025c8:	7f8080e7          	jalr	2040(ra) # 80001dbc <myproc>
  if(user_src){
    800025cc:	c08d                	beqz	s1,800025ee <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800025ce:	86d2                	mv	a3,s4
    800025d0:	864e                	mv	a2,s3
    800025d2:	85ca                	mv	a1,s2
    800025d4:	7928                	ld	a0,112(a0)
    800025d6:	fffff097          	auipc	ra,0xfffff
    800025da:	202080e7          	jalr	514(ra) # 800017d8 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800025de:	70a2                	ld	ra,40(sp)
    800025e0:	7402                	ld	s0,32(sp)
    800025e2:	64e2                	ld	s1,24(sp)
    800025e4:	6942                	ld	s2,16(sp)
    800025e6:	69a2                	ld	s3,8(sp)
    800025e8:	6a02                	ld	s4,0(sp)
    800025ea:	6145                	addi	sp,sp,48
    800025ec:	8082                	ret
    memmove(dst, (char*)src, len);
    800025ee:	000a061b          	sext.w	a2,s4
    800025f2:	85ce                	mv	a1,s3
    800025f4:	854a                	mv	a0,s2
    800025f6:	ffffe097          	auipc	ra,0xffffe
    800025fa:	77a080e7          	jalr	1914(ra) # 80000d70 <memmove>
    return 0;
    800025fe:	8526                	mv	a0,s1
    80002600:	bff9                	j	800025de <either_copyin+0x32>

0000000080002602 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002602:	715d                	addi	sp,sp,-80
    80002604:	e486                	sd	ra,72(sp)
    80002606:	e0a2                	sd	s0,64(sp)
    80002608:	fc26                	sd	s1,56(sp)
    8000260a:	f84a                	sd	s2,48(sp)
    8000260c:	f44e                	sd	s3,40(sp)
    8000260e:	f052                	sd	s4,32(sp)
    80002610:	ec56                	sd	s5,24(sp)
    80002612:	e85a                	sd	s6,16(sp)
    80002614:	e45e                	sd	s7,8(sp)
    80002616:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002618:	00007517          	auipc	a0,0x7
    8000261c:	ab050513          	addi	a0,a0,-1360 # 800090c8 <digits+0x88>
    80002620:	ffffe097          	auipc	ra,0xffffe
    80002624:	f64080e7          	jalr	-156(ra) # 80000584 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002628:	00010497          	auipc	s1,0x10
    8000262c:	2c848493          	addi	s1,s1,712 # 800128f0 <proc+0x178>
    80002630:	00022917          	auipc	s2,0x22
    80002634:	ac090913          	addi	s2,s2,-1344 # 800240f0 <mmr_list+0x178>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002638:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000263a:	00007997          	auipc	s3,0x7
    8000263e:	c9e98993          	addi	s3,s3,-866 # 800092d8 <digits+0x298>
    printf("%d %s %s", p->pid, state, p->name);
    80002642:	00007a97          	auipc	s5,0x7
    80002646:	c9ea8a93          	addi	s5,s5,-866 # 800092e0 <digits+0x2a0>
    printf("\n");
    8000264a:	00007a17          	auipc	s4,0x7
    8000264e:	a7ea0a13          	addi	s4,s4,-1410 # 800090c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002652:	00007b97          	auipc	s7,0x7
    80002656:	ceeb8b93          	addi	s7,s7,-786 # 80009340 <states.0>
    8000265a:	a00d                	j	8000267c <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000265c:	eb86a583          	lw	a1,-328(a3)
    80002660:	8556                	mv	a0,s5
    80002662:	ffffe097          	auipc	ra,0xffffe
    80002666:	f22080e7          	jalr	-222(ra) # 80000584 <printf>
    printf("\n");
    8000266a:	8552                	mv	a0,s4
    8000266c:	ffffe097          	auipc	ra,0xffffe
    80002670:	f18080e7          	jalr	-232(ra) # 80000584 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002674:	46048493          	addi	s1,s1,1120
    80002678:	03248263          	beq	s1,s2,8000269c <procdump+0x9a>
    if(p->state == UNUSED)
    8000267c:	86a6                	mv	a3,s1
    8000267e:	ea04a783          	lw	a5,-352(s1)
    80002682:	dbed                	beqz	a5,80002674 <procdump+0x72>
      state = "???";
    80002684:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002686:	fcfb6be3          	bltu	s6,a5,8000265c <procdump+0x5a>
    8000268a:	02079713          	slli	a4,a5,0x20
    8000268e:	01d75793          	srli	a5,a4,0x1d
    80002692:	97de                	add	a5,a5,s7
    80002694:	6390                	ld	a2,0(a5)
    80002696:	f279                	bnez	a2,8000265c <procdump+0x5a>
      state = "???";
    80002698:	864e                	mv	a2,s3
    8000269a:	b7c9                	j	8000265c <procdump+0x5a>
  }
}
    8000269c:	60a6                	ld	ra,72(sp)
    8000269e:	6406                	ld	s0,64(sp)
    800026a0:	74e2                	ld	s1,56(sp)
    800026a2:	7942                	ld	s2,48(sp)
    800026a4:	79a2                	ld	s3,40(sp)
    800026a6:	7a02                	ld	s4,32(sp)
    800026a8:	6ae2                	ld	s5,24(sp)
    800026aa:	6b42                	ld	s6,16(sp)
    800026ac:	6ba2                	ld	s7,8(sp)
    800026ae:	6161                	addi	sp,sp,80
    800026b0:	8082                	ret

00000000800026b2 <procinfo>:

// Fill in user-provided array with info for current processes
// Return the number of processes found
int
procinfo(uint64 addr)
{
    800026b2:	7175                	addi	sp,sp,-144
    800026b4:	e506                	sd	ra,136(sp)
    800026b6:	e122                	sd	s0,128(sp)
    800026b8:	fca6                	sd	s1,120(sp)
    800026ba:	f8ca                	sd	s2,112(sp)
    800026bc:	f4ce                	sd	s3,104(sp)
    800026be:	f0d2                	sd	s4,96(sp)
    800026c0:	ecd6                	sd	s5,88(sp)
    800026c2:	e8da                	sd	s6,80(sp)
    800026c4:	e4de                	sd	s7,72(sp)
    800026c6:	0900                	addi	s0,sp,144
    800026c8:	89aa                	mv	s3,a0
  struct proc *p;
  struct proc *thisproc = myproc();
    800026ca:	fffff097          	auipc	ra,0xfffff
    800026ce:	6f2080e7          	jalr	1778(ra) # 80001dbc <myproc>
    800026d2:	8b2a                	mv	s6,a0
  struct pstat procinfo;
  int nprocs = 0;
  for(p = proc; p < &proc[NPROC]; p++){ 
    800026d4:	00010917          	auipc	s2,0x10
    800026d8:	21c90913          	addi	s2,s2,540 # 800128f0 <proc+0x178>
    800026dc:	00022a17          	auipc	s4,0x22
    800026e0:	a14a0a13          	addi	s4,s4,-1516 # 800240f0 <mmr_list+0x178>
  int nprocs = 0;
    800026e4:	4a81                	li	s5,0
    procinfo.size = p->sz;
    procinfo.cputime = p->cputime;
    if (p->parent)
      procinfo.ppid = (p->parent)->pid;
    else
      procinfo.ppid = 0;
    800026e6:	4b81                	li	s7,0
    800026e8:	f9c40493          	addi	s1,s0,-100
    800026ec:	a089                	j	8000272e <procinfo+0x7c>
    800026ee:	f8f42423          	sw	a5,-120(s0)
    for (int i=0; i<16; i++)
    800026f2:	f8c40793          	addi	a5,s0,-116
      procinfo.ppid = 0;
    800026f6:	874a                	mv	a4,s2
      procinfo.name[i] = p->name[i];
    800026f8:	00074683          	lbu	a3,0(a4)
    800026fc:	00d78023          	sb	a3,0(a5)
    for (int i=0; i<16; i++)
    80002700:	0705                	addi	a4,a4,1
    80002702:	0785                	addi	a5,a5,1
    80002704:	fe979ae3          	bne	a5,s1,800026f8 <procinfo+0x46>
   if (copyout(thisproc->pagetable, addr, (char *)&procinfo, sizeof(procinfo)) < 0)
    80002708:	03800693          	li	a3,56
    8000270c:	f7840613          	addi	a2,s0,-136
    80002710:	85ce                	mv	a1,s3
    80002712:	070b3503          	ld	a0,112(s6)
    80002716:	fffff097          	auipc	ra,0xfffff
    8000271a:	036080e7          	jalr	54(ra) # 8000174c <copyout>
    8000271e:	04054063          	bltz	a0,8000275e <procinfo+0xac>
      return -1;
    addr += sizeof(procinfo);
    80002722:	03898993          	addi	s3,s3,56
  for(p = proc; p < &proc[NPROC]; p++){ 
    80002726:	46090913          	addi	s2,s2,1120
    8000272a:	03490b63          	beq	s2,s4,80002760 <procinfo+0xae>
    if(p->state == UNUSED)
    8000272e:	ea092783          	lw	a5,-352(s2)
    80002732:	dbf5                	beqz	a5,80002726 <procinfo+0x74>
    nprocs++;
    80002734:	2a85                	addiw	s5,s5,1
    procinfo.pid = p->pid;
    80002736:	eb892703          	lw	a4,-328(s2)
    8000273a:	f6e42c23          	sw	a4,-136(s0)
    procinfo.state = p->state;
    8000273e:	f6f42e23          	sw	a5,-132(s0)
    procinfo.size = p->sz;
    80002742:	ef093783          	ld	a5,-272(s2)
    80002746:	f8f43023          	sd	a5,-128(s0)
    procinfo.cputime = p->cputime;
    8000274a:	ec093783          	ld	a5,-320(s2)
    8000274e:	faf43023          	sd	a5,-96(s0)
    if (p->parent)
    80002752:	ee093703          	ld	a4,-288(s2)
      procinfo.ppid = 0;
    80002756:	87de                	mv	a5,s7
    if (p->parent)
    80002758:	db59                	beqz	a4,800026ee <procinfo+0x3c>
      procinfo.ppid = (p->parent)->pid;
    8000275a:	5b1c                	lw	a5,48(a4)
    8000275c:	bf49                	j	800026ee <procinfo+0x3c>
      return -1;
    8000275e:	5afd                	li	s5,-1
  }
  return nprocs;
}
    80002760:	8556                	mv	a0,s5
    80002762:	60aa                	ld	ra,136(sp)
    80002764:	640a                	ld	s0,128(sp)
    80002766:	74e6                	ld	s1,120(sp)
    80002768:	7946                	ld	s2,112(sp)
    8000276a:	79a6                	ld	s3,104(sp)
    8000276c:	7a06                	ld	s4,96(sp)
    8000276e:	6ae6                	ld	s5,88(sp)
    80002770:	6b46                	ld	s6,80(sp)
    80002772:	6ba6                	ld	s7,72(sp)
    80002774:	6149                	addi	sp,sp,144
    80002776:	8082                	ret

0000000080002778 <mmrlistinit>:

//Added for lab3
// Initialize mmr_list
void
mmrlistinit(void)
{
    80002778:	7179                	addi	sp,sp,-48
    8000277a:	f406                	sd	ra,40(sp)
    8000277c:	f022                	sd	s0,32(sp)
    8000277e:	ec26                	sd	s1,24(sp)
    80002780:	e84a                	sd	s2,16(sp)
    80002782:	e44e                	sd	s3,8(sp)
    80002784:	1800                	addi	s0,sp,48
  struct mmr_list *pmmrlist;
  initlock(&listid_lock,"listid");
    80002786:	00007597          	auipc	a1,0x7
    8000278a:	b6a58593          	addi	a1,a1,-1174 # 800092f0 <digits+0x2b0>
    8000278e:	00010517          	auipc	a0,0x10
    80002792:	fd250513          	addi	a0,a0,-46 # 80012760 <listid_lock>
    80002796:	ffffe097          	auipc	ra,0xffffe
    8000279a:	3f2080e7          	jalr	1010(ra) # 80000b88 <initlock>
  for (pmmrlist = mmr_list; pmmrlist < &mmr_list[NPROC*MAX_MMR]; pmmrlist++) {
    8000279e:	00021497          	auipc	s1,0x21
    800027a2:	7da48493          	addi	s1,s1,2010 # 80023f78 <mmr_list>
    initlock(&pmmrlist->lock, "mmrlist");
    800027a6:	00007997          	auipc	s3,0x7
    800027aa:	b5298993          	addi	s3,s3,-1198 # 800092f8 <digits+0x2b8>
  for (pmmrlist = mmr_list; pmmrlist < &mmr_list[NPROC*MAX_MMR]; pmmrlist++) {
    800027ae:	00026917          	auipc	s2,0x26
    800027b2:	7ca90913          	addi	s2,s2,1994 # 80028f78 <tickslock>
    initlock(&pmmrlist->lock, "mmrlist");
    800027b6:	85ce                	mv	a1,s3
    800027b8:	8526                	mv	a0,s1
    800027ba:	ffffe097          	auipc	ra,0xffffe
    800027be:	3ce080e7          	jalr	974(ra) # 80000b88 <initlock>
    pmmrlist->valid = 0;
    800027c2:	0004ac23          	sw	zero,24(s1)
  for (pmmrlist = mmr_list; pmmrlist < &mmr_list[NPROC*MAX_MMR]; pmmrlist++) {
    800027c6:	02048493          	addi	s1,s1,32
    800027ca:	ff2496e3          	bne	s1,s2,800027b6 <mmrlistinit+0x3e>
  }
}
    800027ce:	70a2                	ld	ra,40(sp)
    800027d0:	7402                	ld	s0,32(sp)
    800027d2:	64e2                	ld	s1,24(sp)
    800027d4:	6942                	ld	s2,16(sp)
    800027d6:	69a2                	ld	s3,8(sp)
    800027d8:	6145                	addi	sp,sp,48
    800027da:	8082                	ret

00000000800027dc <get_mmr_list>:

// find the mmr_list for a given listid
struct mmr_list*
get_mmr_list(int listid) {
    800027dc:	1101                	addi	sp,sp,-32
    800027de:	ec06                	sd	ra,24(sp)
    800027e0:	e822                	sd	s0,16(sp)
    800027e2:	e426                	sd	s1,8(sp)
    800027e4:	1000                	addi	s0,sp,32
    800027e6:	84aa                	mv	s1,a0
  acquire(&listid_lock);
    800027e8:	00010517          	auipc	a0,0x10
    800027ec:	f7850513          	addi	a0,a0,-136 # 80012760 <listid_lock>
    800027f0:	ffffe097          	auipc	ra,0xffffe
    800027f4:	428080e7          	jalr	1064(ra) # 80000c18 <acquire>
  if (listid >=0 && listid < NPROC*MAX_MMR && mmr_list[listid].valid) {
    800027f8:	0004871b          	sext.w	a4,s1
    800027fc:	27f00793          	li	a5,639
    80002800:	02e7eb63          	bltu	a5,a4,80002836 <get_mmr_list+0x5a>
    80002804:	00549713          	slli	a4,s1,0x5
    80002808:	00021797          	auipc	a5,0x21
    8000280c:	77078793          	addi	a5,a5,1904 # 80023f78 <mmr_list>
    80002810:	97ba                	add	a5,a5,a4
    80002812:	4f9c                	lw	a5,24(a5)
    80002814:	c38d                	beqz	a5,80002836 <get_mmr_list+0x5a>
    release(&listid_lock);
    80002816:	00010517          	auipc	a0,0x10
    8000281a:	f4a50513          	addi	a0,a0,-182 # 80012760 <listid_lock>
    8000281e:	ffffe097          	auipc	ra,0xffffe
    80002822:	4ae080e7          	jalr	1198(ra) # 80000ccc <release>
    return(&mmr_list[listid]);
    80002826:	00549513          	slli	a0,s1,0x5
    8000282a:	00021797          	auipc	a5,0x21
    8000282e:	74e78793          	addi	a5,a5,1870 # 80023f78 <mmr_list>
    80002832:	953e                	add	a0,a0,a5
    80002834:	a811                	j	80002848 <get_mmr_list+0x6c>
  }
  else {
    release(&listid_lock);
    80002836:	00010517          	auipc	a0,0x10
    8000283a:	f2a50513          	addi	a0,a0,-214 # 80012760 <listid_lock>
    8000283e:	ffffe097          	auipc	ra,0xffffe
    80002842:	48e080e7          	jalr	1166(ra) # 80000ccc <release>
    return 0;
    80002846:	4501                	li	a0,0
  }
}
    80002848:	60e2                	ld	ra,24(sp)
    8000284a:	6442                	ld	s0,16(sp)
    8000284c:	64a2                	ld	s1,8(sp)
    8000284e:	6105                	addi	sp,sp,32
    80002850:	8082                	ret

0000000080002852 <dealloc_mmr_listid>:

// free up entry in mmr_list array
void
dealloc_mmr_listid(int listid) {
    80002852:	1101                	addi	sp,sp,-32
    80002854:	ec06                	sd	ra,24(sp)
    80002856:	e822                	sd	s0,16(sp)
    80002858:	e426                	sd	s1,8(sp)
    8000285a:	e04a                	sd	s2,0(sp)
    8000285c:	1000                	addi	s0,sp,32
    8000285e:	84aa                	mv	s1,a0
  acquire(&listid_lock);
    80002860:	00010917          	auipc	s2,0x10
    80002864:	f0090913          	addi	s2,s2,-256 # 80012760 <listid_lock>
    80002868:	854a                	mv	a0,s2
    8000286a:	ffffe097          	auipc	ra,0xffffe
    8000286e:	3ae080e7          	jalr	942(ra) # 80000c18 <acquire>
  mmr_list[listid].valid = 0;
    80002872:	0496                	slli	s1,s1,0x5
    80002874:	00021797          	auipc	a5,0x21
    80002878:	70478793          	addi	a5,a5,1796 # 80023f78 <mmr_list>
    8000287c:	97a6                	add	a5,a5,s1
    8000287e:	0007ac23          	sw	zero,24(a5)
  release(&listid_lock);
    80002882:	854a                	mv	a0,s2
    80002884:	ffffe097          	auipc	ra,0xffffe
    80002888:	448080e7          	jalr	1096(ra) # 80000ccc <release>
}
    8000288c:	60e2                	ld	ra,24(sp)
    8000288e:	6442                	ld	s0,16(sp)
    80002890:	64a2                	ld	s1,8(sp)
    80002892:	6902                	ld	s2,0(sp)
    80002894:	6105                	addi	sp,sp,32
    80002896:	8082                	ret

0000000080002898 <freeproc>:
{
    80002898:	711d                	addi	sp,sp,-96
    8000289a:	ec86                	sd	ra,88(sp)
    8000289c:	e8a2                	sd	s0,80(sp)
    8000289e:	e4a6                	sd	s1,72(sp)
    800028a0:	e0ca                	sd	s2,64(sp)
    800028a2:	fc4e                	sd	s3,56(sp)
    800028a4:	f852                	sd	s4,48(sp)
    800028a6:	f456                	sd	s5,40(sp)
    800028a8:	f05a                	sd	s6,32(sp)
    800028aa:	ec5e                	sd	s7,24(sp)
    800028ac:	e862                	sd	s8,16(sp)
    800028ae:	e466                	sd	s9,8(sp)
    800028b0:	e06a                	sd	s10,0(sp)
    800028b2:	1080                	addi	s0,sp,96
    800028b4:	8a2a                	mv	s4,a0
  if(p->trapframe){
    800028b6:	7d28                	ld	a0,120(a0)
    800028b8:	c509                	beqz	a0,800028c2 <freeproc+0x2a>
    kfree((void*)p->trapframe);
    800028ba:	ffffe097          	auipc	ra,0xffffe
    800028be:	128080e7          	jalr	296(ra) # 800009e2 <kfree>
  p->trapframe = 0;
    800028c2:	060a3c23          	sd	zero,120(s4)
  for (int i = 0; i < MAX_MMR; i++) {
    800028c6:	1b0a0913          	addi	s2,s4,432
    800028ca:	480a0b93          	addi	s7,s4,1152
    if (p->mmr[i].valid == 1) {
    800028ce:	4a85                	li	s5,1
      for (uint64 addr = p->mmr[i].addr; addr < p->mmr[i].addr + p->mmr[i].length; addr += PGSIZE){
    800028d0:	6b05                	lui	s6,0x1
        acquire(&mmr_list[p->mmr[i].mmr_family.listid].lock);
    800028d2:	00021c97          	auipc	s9,0x21
    800028d6:	6a6c8c93          	addi	s9,s9,1702 # 80023f78 <mmr_list>
    dofree = 0;
    800028da:	4d01                	li	s10,0
    800028dc:	a851                	j	80002970 <freeproc+0xd8>
        acquire(&mmr_list[p->mmr[i].mmr_family.listid].lock);
    800028de:	00092503          	lw	a0,0(s2)
    800028e2:	0516                	slli	a0,a0,0x5
    800028e4:	9566                	add	a0,a0,s9
    800028e6:	ffffe097          	auipc	ra,0xffffe
    800028ea:	332080e7          	jalr	818(ra) # 80000c18 <acquire>
        if (p->mmr[i].mmr_family.next == &(p->mmr[i].mmr_family)) { // no other family members
    800028ee:	01093783          	ld	a5,16(s2)
    800028f2:	03278263          	beq	a5,s2,80002916 <freeproc+0x7e>
          (p->mmr[i].mmr_family.next)->prev = p->mmr[i].mmr_family.prev;
    800028f6:	01893703          	ld	a4,24(s2)
    800028fa:	ef98                	sd	a4,24(a5)
          (p->mmr[i].mmr_family.prev)->next = p->mmr[i].mmr_family.next;
    800028fc:	01093783          	ld	a5,16(s2)
    80002900:	eb1c                	sd	a5,16(a4)
          release(&mmr_list[p->mmr[i].mmr_family.listid].lock);
    80002902:	00092503          	lw	a0,0(s2)
    80002906:	0516                	slli	a0,a0,0x5
    80002908:	9566                	add	a0,a0,s9
    8000290a:	ffffe097          	auipc	ra,0xffffe
    8000290e:	3c2080e7          	jalr	962(ra) # 80000ccc <release>
    dofree = 0;
    80002912:	8c6a                	mv	s8,s10
    80002914:	a885                	j	80002984 <freeproc+0xec>
          release(&mmr_list[p->mmr[i].mmr_family.listid].lock);
    80002916:	00092503          	lw	a0,0(s2)
    8000291a:	0516                	slli	a0,a0,0x5
    8000291c:	9566                	add	a0,a0,s9
    8000291e:	ffffe097          	auipc	ra,0xffffe
    80002922:	3ae080e7          	jalr	942(ra) # 80000ccc <release>
          dealloc_mmr_listid(p->mmr[i].mmr_family.listid);
    80002926:	00092503          	lw	a0,0(s2)
    8000292a:	00000097          	auipc	ra,0x0
    8000292e:	f28080e7          	jalr	-216(ra) # 80002852 <dealloc_mmr_listid>
    80002932:	a889                	j	80002984 <freeproc+0xec>
      for (uint64 addr = p->mmr[i].addr; addr < p->mmr[i].addr + p->mmr[i].length; addr += PGSIZE){
    80002934:	94da                	add	s1,s1,s6
    80002936:	fe09a783          	lw	a5,-32(s3)
    8000293a:	fd89b703          	ld	a4,-40(s3)
    8000293e:	97ba                	add	a5,a5,a4
    80002940:	02f4f463          	bgeu	s1,a5,80002968 <freeproc+0xd0>
        if (walkaddr(p->pagetable, addr)){
    80002944:	85a6                	mv	a1,s1
    80002946:	070a3503          	ld	a0,112(s4)
    8000294a:	ffffe097          	auipc	ra,0xffffe
    8000294e:	758080e7          	jalr	1880(ra) # 800010a2 <walkaddr>
    80002952:	d16d                	beqz	a0,80002934 <freeproc+0x9c>
          uvmunmap(p->pagetable, addr, 1, dofree);
    80002954:	86e2                	mv	a3,s8
    80002956:	8656                	mv	a2,s5
    80002958:	85a6                	mv	a1,s1
    8000295a:	070a3503          	ld	a0,112(s4)
    8000295e:	fffff097          	auipc	ra,0xfffff
    80002962:	94c080e7          	jalr	-1716(ra) # 800012aa <uvmunmap>
    80002966:	b7f9                	j	80002934 <freeproc+0x9c>
  for (int i = 0; i < MAX_MMR; i++) {
    80002968:	04890913          	addi	s2,s2,72
    8000296c:	03790563          	beq	s2,s7,80002996 <freeproc+0xfe>
    if (p->mmr[i].valid == 1) {
    80002970:	89ca                	mv	s3,s2
    80002972:	fec92783          	lw	a5,-20(s2)
    80002976:	ff5799e3          	bne	a5,s5,80002968 <freeproc+0xd0>
      if (p->mmr[i].flags & MAP_PRIVATE){
    8000297a:	fe892783          	lw	a5,-24(s2)
    8000297e:	8b89                	andi	a5,a5,2
        dofree = 1;
    80002980:	8c56                	mv	s8,s5
      if (p->mmr[i].flags & MAP_PRIVATE){
    80002982:	dfb1                	beqz	a5,800028de <freeproc+0x46>
      for (uint64 addr = p->mmr[i].addr; addr < p->mmr[i].addr + p->mmr[i].length; addr += PGSIZE){
    80002984:	fd89b483          	ld	s1,-40(s3)
    80002988:	fe09a783          	lw	a5,-32(s3)
    8000298c:	97a6                	add	a5,a5,s1
    8000298e:	fcf4fde3          	bgeu	s1,a5,80002968 <freeproc+0xd0>
          uvmunmap(p->pagetable, addr, 1, dofree);
    80002992:	2c01                	sext.w	s8,s8
    80002994:	bf45                	j	80002944 <freeproc+0xac>
  if(p->pagetable){
    80002996:	070a3503          	ld	a0,112(s4)
    8000299a:	c519                	beqz	a0,800029a8 <freeproc+0x110>
    proc_freepagetable(p->pagetable, p->sz);
    8000299c:	068a3583          	ld	a1,104(s4)
    800029a0:	fffff097          	auipc	ra,0xfffff
    800029a4:	57c080e7          	jalr	1404(ra) # 80001f1c <proc_freepagetable>
  p->pagetable = 0;
    800029a8:	060a3823          	sd	zero,112(s4)
  p->sz = 0;
    800029ac:	060a3423          	sd	zero,104(s4)
  p->pid = 0;
    800029b0:	020a2823          	sw	zero,48(s4)
  p->parent = 0;
    800029b4:	040a3c23          	sd	zero,88(s4)
  p->name[0] = 0;
    800029b8:	160a0c23          	sb	zero,376(s4)
  p->chan = 0;
    800029bc:	020a3023          	sd	zero,32(s4)
  p->killed = 0;
    800029c0:	020a2423          	sw	zero,40(s4)
  p->xstate = 0;
    800029c4:	020a2623          	sw	zero,44(s4)
  p->state = UNUSED;
    800029c8:	000a2c23          	sw	zero,24(s4)
}
    800029cc:	60e6                	ld	ra,88(sp)
    800029ce:	6446                	ld	s0,80(sp)
    800029d0:	64a6                	ld	s1,72(sp)
    800029d2:	6906                	ld	s2,64(sp)
    800029d4:	79e2                	ld	s3,56(sp)
    800029d6:	7a42                	ld	s4,48(sp)
    800029d8:	7aa2                	ld	s5,40(sp)
    800029da:	7b02                	ld	s6,32(sp)
    800029dc:	6be2                	ld	s7,24(sp)
    800029de:	6c42                	ld	s8,16(sp)
    800029e0:	6ca2                	ld	s9,8(sp)
    800029e2:	6d02                	ld	s10,0(sp)
    800029e4:	6125                	addi	sp,sp,96
    800029e6:	8082                	ret

00000000800029e8 <allocproc>:
{
    800029e8:	1101                	addi	sp,sp,-32
    800029ea:	ec06                	sd	ra,24(sp)
    800029ec:	e822                	sd	s0,16(sp)
    800029ee:	e426                	sd	s1,8(sp)
    800029f0:	e04a                	sd	s2,0(sp)
    800029f2:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    800029f4:	00010497          	auipc	s1,0x10
    800029f8:	d8448493          	addi	s1,s1,-636 # 80012778 <proc>
    800029fc:	00021917          	auipc	s2,0x21
    80002a00:	57c90913          	addi	s2,s2,1404 # 80023f78 <mmr_list>
    acquire(&p->lock);
    80002a04:	8526                	mv	a0,s1
    80002a06:	ffffe097          	auipc	ra,0xffffe
    80002a0a:	212080e7          	jalr	530(ra) # 80000c18 <acquire>
    if(p->state == UNUSED) {
    80002a0e:	4c9c                	lw	a5,24(s1)
    80002a10:	cf81                	beqz	a5,80002a28 <allocproc+0x40>
      release(&p->lock);
    80002a12:	8526                	mv	a0,s1
    80002a14:	ffffe097          	auipc	ra,0xffffe
    80002a18:	2b8080e7          	jalr	696(ra) # 80000ccc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002a1c:	46048493          	addi	s1,s1,1120
    80002a20:	ff2492e3          	bne	s1,s2,80002a04 <allocproc+0x1c>
  return 0;
    80002a24:	4481                	li	s1,0
    80002a26:	a09d                	j	80002a8c <allocproc+0xa4>
  p->pid = allocpid();
    80002a28:	fffff097          	auipc	ra,0xfffff
    80002a2c:	412080e7          	jalr	1042(ra) # 80001e3a <allocpid>
    80002a30:	d888                	sw	a0,48(s1)
  p->state = USED;
    80002a32:	4785                	li	a5,1
    80002a34:	cc9c                	sw	a5,24(s1)
  p->cputime = 0;
    80002a36:	0204bc23          	sd	zero,56(s1)
  p->priority = HIGH;
    80002a3a:	0404a223          	sw	zero,68(s1)
  p->timeslice = TSTICKSHIGH;
    80002a3e:	c4bc                	sw	a5,72(s1)
  p->tsticks = TSTICKSHIGH;
    80002a40:	c0bc                	sw	a5,64(s1)
  p->yielded = 0;
    80002a42:	0404a623          	sw	zero,76(s1)
  p->next = 0;
    80002a46:	0404b823          	sd	zero,80(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80002a4a:	ffffe097          	auipc	ra,0xffffe
    80002a4e:	096080e7          	jalr	150(ra) # 80000ae0 <kalloc>
    80002a52:	892a                	mv	s2,a0
    80002a54:	fca8                	sd	a0,120(s1)
    80002a56:	c131                	beqz	a0,80002a9a <allocproc+0xb2>
  p->pagetable = proc_pagetable(p);
    80002a58:	8526                	mv	a0,s1
    80002a5a:	fffff097          	auipc	ra,0xfffff
    80002a5e:	426080e7          	jalr	1062(ra) # 80001e80 <proc_pagetable>
    80002a62:	892a                	mv	s2,a0
    80002a64:	f8a8                	sd	a0,112(s1)
  if(p->pagetable == 0){
    80002a66:	c531                	beqz	a0,80002ab2 <allocproc+0xca>
  memset(&p->context, 0, sizeof(p->context));
    80002a68:	07000613          	li	a2,112
    80002a6c:	4581                	li	a1,0
    80002a6e:	08048513          	addi	a0,s1,128
    80002a72:	ffffe097          	auipc	ra,0xffffe
    80002a76:	2a2080e7          	jalr	674(ra) # 80000d14 <memset>
  p->context.ra = (uint64)forkret;
    80002a7a:	fffff797          	auipc	a5,0xfffff
    80002a7e:	37a78793          	addi	a5,a5,890 # 80001df4 <forkret>
    80002a82:	e0dc                	sd	a5,128(s1)
  p->context.sp = p->kstack + PGSIZE;
    80002a84:	70bc                	ld	a5,96(s1)
    80002a86:	6705                	lui	a4,0x1
    80002a88:	97ba                	add	a5,a5,a4
    80002a8a:	e4dc                	sd	a5,136(s1)
}
    80002a8c:	8526                	mv	a0,s1
    80002a8e:	60e2                	ld	ra,24(sp)
    80002a90:	6442                	ld	s0,16(sp)
    80002a92:	64a2                	ld	s1,8(sp)
    80002a94:	6902                	ld	s2,0(sp)
    80002a96:	6105                	addi	sp,sp,32
    80002a98:	8082                	ret
    freeproc(p);
    80002a9a:	8526                	mv	a0,s1
    80002a9c:	00000097          	auipc	ra,0x0
    80002aa0:	dfc080e7          	jalr	-516(ra) # 80002898 <freeproc>
    release(&p->lock);
    80002aa4:	8526                	mv	a0,s1
    80002aa6:	ffffe097          	auipc	ra,0xffffe
    80002aaa:	226080e7          	jalr	550(ra) # 80000ccc <release>
    return 0;
    80002aae:	84ca                	mv	s1,s2
    80002ab0:	bff1                	j	80002a8c <allocproc+0xa4>
    freeproc(p);
    80002ab2:	8526                	mv	a0,s1
    80002ab4:	00000097          	auipc	ra,0x0
    80002ab8:	de4080e7          	jalr	-540(ra) # 80002898 <freeproc>
    release(&p->lock);
    80002abc:	8526                	mv	a0,s1
    80002abe:	ffffe097          	auipc	ra,0xffffe
    80002ac2:	20e080e7          	jalr	526(ra) # 80000ccc <release>
    return 0;
    80002ac6:	84ca                	mv	s1,s2
    80002ac8:	b7d1                	j	80002a8c <allocproc+0xa4>

0000000080002aca <userinit>:
{
    80002aca:	1101                	addi	sp,sp,-32
    80002acc:	ec06                	sd	ra,24(sp)
    80002ace:	e822                	sd	s0,16(sp)
    80002ad0:	e426                	sd	s1,8(sp)
    80002ad2:	1000                	addi	s0,sp,32
  p = allocproc();
    80002ad4:	00000097          	auipc	ra,0x0
    80002ad8:	f14080e7          	jalr	-236(ra) # 800029e8 <allocproc>
    80002adc:	84aa                	mv	s1,a0
  initproc = p;
    80002ade:	00007797          	auipc	a5,0x7
    80002ae2:	54a7b523          	sd	a0,1354(a5) # 8000a028 <initproc>
  p->cur_max = MAXVA - 2*PGSIZE;
    80002ae6:	020007b7          	lui	a5,0x2000
    80002aea:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80002aec:	07b6                	slli	a5,a5,0xd
    80002aee:	44f53c23          	sd	a5,1112(a0)
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80002af2:	03400613          	li	a2,52
    80002af6:	00007597          	auipc	a1,0x7
    80002afa:	dfa58593          	addi	a1,a1,-518 # 800098f0 <initcode>
    80002afe:	7928                	ld	a0,112(a0)
    80002b00:	fffff097          	auipc	ra,0xfffff
    80002b04:	89c080e7          	jalr	-1892(ra) # 8000139c <uvminit>
  p->sz = PGSIZE;
    80002b08:	6785                	lui	a5,0x1
    80002b0a:	f4bc                	sd	a5,104(s1)
  p->trapframe->epc = 0;      // user program counter
    80002b0c:	7cb8                	ld	a4,120(s1)
    80002b0e:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80002b12:	7cb8                	ld	a4,120(s1)
    80002b14:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80002b16:	4641                	li	a2,16
    80002b18:	00006597          	auipc	a1,0x6
    80002b1c:	7e858593          	addi	a1,a1,2024 # 80009300 <digits+0x2c0>
    80002b20:	17848513          	addi	a0,s1,376
    80002b24:	ffffe097          	auipc	ra,0xffffe
    80002b28:	33a080e7          	jalr	826(ra) # 80000e5e <safestrcpy>
  p->cwd = namei("/");
    80002b2c:	00006517          	auipc	a0,0x6
    80002b30:	7e450513          	addi	a0,a0,2020 # 80009310 <digits+0x2d0>
    80002b34:	00002097          	auipc	ra,0x2
    80002b38:	1d2080e7          	jalr	466(ra) # 80004d06 <namei>
    80002b3c:	16a4b823          	sd	a0,368(s1)
  p->state = RUNNABLE;
    80002b40:	478d                	li	a5,3
    80002b42:	cc9c                	sw	a5,24(s1)
  enqueue_at_tail(p, p->priority);
    80002b44:	40ec                	lw	a1,68(s1)
    80002b46:	8526                	mv	a0,s1
    80002b48:	fffff097          	auipc	ra,0xfffff
    80002b4c:	e48080e7          	jalr	-440(ra) # 80001990 <enqueue_at_tail>
  release(&p->lock);
    80002b50:	8526                	mv	a0,s1
    80002b52:	ffffe097          	auipc	ra,0xffffe
    80002b56:	17a080e7          	jalr	378(ra) # 80000ccc <release>
}
    80002b5a:	60e2                	ld	ra,24(sp)
    80002b5c:	6442                	ld	s0,16(sp)
    80002b5e:	64a2                	ld	s1,8(sp)
    80002b60:	6105                	addi	sp,sp,32
    80002b62:	8082                	ret

0000000080002b64 <fork>:
{
    80002b64:	7159                	addi	sp,sp,-112
    80002b66:	f486                	sd	ra,104(sp)
    80002b68:	f0a2                	sd	s0,96(sp)
    80002b6a:	eca6                	sd	s1,88(sp)
    80002b6c:	e8ca                	sd	s2,80(sp)
    80002b6e:	e4ce                	sd	s3,72(sp)
    80002b70:	e0d2                	sd	s4,64(sp)
    80002b72:	fc56                	sd	s5,56(sp)
    80002b74:	f85a                	sd	s6,48(sp)
    80002b76:	f45e                	sd	s7,40(sp)
    80002b78:	f062                	sd	s8,32(sp)
    80002b7a:	ec66                	sd	s9,24(sp)
    80002b7c:	e86a                	sd	s10,16(sp)
    80002b7e:	e46e                	sd	s11,8(sp)
    80002b80:	1880                	addi	s0,sp,112
  struct proc *p = myproc();
    80002b82:	fffff097          	auipc	ra,0xfffff
    80002b86:	23a080e7          	jalr	570(ra) # 80001dbc <myproc>
    80002b8a:	89aa                	mv	s3,a0
  if((np = allocproc()) == 0){
    80002b8c:	00000097          	auipc	ra,0x0
    80002b90:	e5c080e7          	jalr	-420(ra) # 800029e8 <allocproc>
    80002b94:	28050e63          	beqz	a0,80002e30 <fork+0x2cc>
    80002b98:	8aaa                	mv	s5,a0
  if(uvmcopy(p->pagetable, np->pagetable, 0, p->sz) < 0){
    80002b9a:	0689b683          	ld	a3,104(s3)
    80002b9e:	4601                	li	a2,0
    80002ba0:	792c                	ld	a1,112(a0)
    80002ba2:	0709b503          	ld	a0,112(s3)
    80002ba6:	fffff097          	auipc	ra,0xfffff
    80002baa:	a00080e7          	jalr	-1536(ra) # 800015a6 <uvmcopy>
    80002bae:	04054c63          	bltz	a0,80002c06 <fork+0xa2>
  np->sz = p->sz;
    80002bb2:	0689b783          	ld	a5,104(s3)
    80002bb6:	06fab423          	sd	a5,104(s5)
  np->cur_max = p->cur_max;
    80002bba:	4589b783          	ld	a5,1112(s3)
    80002bbe:	44fabc23          	sd	a5,1112(s5)
  *(np->trapframe) = *(p->trapframe);
    80002bc2:	0789b683          	ld	a3,120(s3)
    80002bc6:	87b6                	mv	a5,a3
    80002bc8:	078ab703          	ld	a4,120(s5)
    80002bcc:	12068693          	addi	a3,a3,288
    80002bd0:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80002bd4:	6788                	ld	a0,8(a5)
    80002bd6:	6b8c                	ld	a1,16(a5)
    80002bd8:	6f90                	ld	a2,24(a5)
    80002bda:	01073023          	sd	a6,0(a4)
    80002bde:	e708                	sd	a0,8(a4)
    80002be0:	eb0c                	sd	a1,16(a4)
    80002be2:	ef10                	sd	a2,24(a4)
    80002be4:	02078793          	addi	a5,a5,32
    80002be8:	02070713          	addi	a4,a4,32
    80002bec:	fed792e3          	bne	a5,a3,80002bd0 <fork+0x6c>
  np->trapframe->a0 = 0;
    80002bf0:	078ab783          	ld	a5,120(s5)
    80002bf4:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80002bf8:	0f098493          	addi	s1,s3,240
    80002bfc:	0f0a8913          	addi	s2,s5,240
    80002c00:	17098a13          	addi	s4,s3,368
    80002c04:	a00d                	j	80002c26 <fork+0xc2>
    freeproc(np);
    80002c06:	8556                	mv	a0,s5
    80002c08:	00000097          	auipc	ra,0x0
    80002c0c:	c90080e7          	jalr	-880(ra) # 80002898 <freeproc>
    release(&np->lock);
    80002c10:	8556                	mv	a0,s5
    80002c12:	ffffe097          	auipc	ra,0xffffe
    80002c16:	0ba080e7          	jalr	186(ra) # 80000ccc <release>
    return -1;
    80002c1a:	5d7d                	li	s10,-1
    80002c1c:	aad5                	j	80002e10 <fork+0x2ac>
  for(i = 0; i < NOFILE; i++)
    80002c1e:	04a1                	addi	s1,s1,8
    80002c20:	0921                	addi	s2,s2,8
    80002c22:	01448b63          	beq	s1,s4,80002c38 <fork+0xd4>
    if(p->ofile[i])
    80002c26:	6088                	ld	a0,0(s1)
    80002c28:	d97d                	beqz	a0,80002c1e <fork+0xba>
      np->ofile[i] = filedup(p->ofile[i]);
    80002c2a:	00002097          	auipc	ra,0x2
    80002c2e:	772080e7          	jalr	1906(ra) # 8000539c <filedup>
    80002c32:	00a93023          	sd	a0,0(s2)
    80002c36:	b7e5                	j	80002c1e <fork+0xba>
  np->cwd = idup(p->cwd);
    80002c38:	1709b503          	ld	a0,368(s3)
    80002c3c:	00002097          	auipc	ra,0x2
    80002c40:	8d0080e7          	jalr	-1840(ra) # 8000450c <idup>
    80002c44:	16aab823          	sd	a0,368(s5)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002c48:	4641                	li	a2,16
    80002c4a:	17898593          	addi	a1,s3,376
    80002c4e:	178a8513          	addi	a0,s5,376
    80002c52:	ffffe097          	auipc	ra,0xffffe
    80002c56:	20c080e7          	jalr	524(ra) # 80000e5e <safestrcpy>
  pid = np->pid;
    80002c5a:	030aad03          	lw	s10,48(s5)
  memmove((char *)np->mmr, (char *)p->mmr, MAX_MMR * sizeof(struct mmr));
    80002c5e:	2d000613          	li	a2,720
    80002c62:	18898593          	addi	a1,s3,392
    80002c66:	188a8513          	addi	a0,s5,392
    80002c6a:	ffffe097          	auipc	ra,0xffffe
    80002c6e:	106080e7          	jalr	262(ra) # 80000d70 <memmove>
  for (int i = 0; i < MAX_MMR; i++)
    80002c72:	1b0a8b93          	addi	s7,s5,432
    80002c76:	1b098b13          	addi	s6,s3,432
    80002c7a:	48098c93          	addi	s9,s3,1152
    if (p->mmr[i].valid == 1)
    80002c7e:	4c05                	li	s8,1
            if (uvmcopyshared(p->pagetable, np->pagetable, addr, addr + PGSIZE) < 0)
    80002c80:	6a05                	lui	s4,0x1
        acquire(&mmr_list[p->mmr[i].mmr_family.listid].lock);
    80002c82:	00021d97          	auipc	s11,0x21
    80002c86:	2f6d8d93          	addi	s11,s11,758 # 80023f78 <mmr_list>
    80002c8a:	a88d                	j	80002cfc <fork+0x198>
        for (uint64 addr = p->mmr[i].addr; addr < p->mmr[i].addr + p->mmr[i].length; addr += PGSIZE)
    80002c8c:	9952                	add	s2,s2,s4
    80002c8e:	fe04a783          	lw	a5,-32(s1)
    80002c92:	fd84b703          	ld	a4,-40(s1)
    80002c96:	97ba                	add	a5,a5,a4
    80002c98:	04f97363          	bgeu	s2,a5,80002cde <fork+0x17a>
          if (walkaddr(p->pagetable, addr))
    80002c9c:	85ca                	mv	a1,s2
    80002c9e:	0709b503          	ld	a0,112(s3)
    80002ca2:	ffffe097          	auipc	ra,0xffffe
    80002ca6:	400080e7          	jalr	1024(ra) # 800010a2 <walkaddr>
    80002caa:	d16d                	beqz	a0,80002c8c <fork+0x128>
            if (uvmcopy(p->pagetable, np->pagetable, addr, addr + PGSIZE) < 0)
    80002cac:	014906b3          	add	a3,s2,s4
    80002cb0:	864a                	mv	a2,s2
    80002cb2:	070ab583          	ld	a1,112(s5)
    80002cb6:	0709b503          	ld	a0,112(s3)
    80002cba:	fffff097          	auipc	ra,0xfffff
    80002cbe:	8ec080e7          	jalr	-1812(ra) # 800015a6 <uvmcopy>
    80002cc2:	fc0555e3          	bgez	a0,80002c8c <fork+0x128>
              freeproc(np);
    80002cc6:	8556                	mv	a0,s5
    80002cc8:	00000097          	auipc	ra,0x0
    80002ccc:	bd0080e7          	jalr	-1072(ra) # 80002898 <freeproc>
              release(&np->lock);
    80002cd0:	8556                	mv	a0,s5
    80002cd2:	ffffe097          	auipc	ra,0xffffe
    80002cd6:	ffa080e7          	jalr	-6(ra) # 80000ccc <release>
              return -1;
    80002cda:	5d7d                	li	s10,-1
    80002cdc:	aa15                	j	80002e10 <fork+0x2ac>
        np->mmr[i].mmr_family.proc = np;
    80002cde:	015bb423          	sd	s5,8(s7)
        np->mmr[i].mmr_family.listid = -1;
    80002ce2:	57fd                	li	a5,-1
    80002ce4:	00fba023          	sw	a5,0(s7)
        np->mmr[i].mmr_family.next = &(np->mmr[i].mmr_family);
    80002ce8:	017bb823          	sd	s7,16(s7)
        np->mmr[i].mmr_family.prev = &(np->mmr[i].mmr_family);
    80002cec:	017bbc23          	sd	s7,24(s7)
  for (int i = 0; i < MAX_MMR; i++)
    80002cf0:	048b8b93          	addi	s7,s7,72
    80002cf4:	048b0b13          	addi	s6,s6,72 # 1048 <_entry-0x7fffefb8>
    80002cf8:	0d9b0363          	beq	s6,s9,80002dbe <fork+0x25a>
    if (p->mmr[i].valid == 1)
    80002cfc:	84da                	mv	s1,s6
    80002cfe:	fecb2783          	lw	a5,-20(s6)
    80002d02:	ff8797e3          	bne	a5,s8,80002cf0 <fork+0x18c>
      if (p->mmr[i].flags & MAP_PRIVATE)
    80002d06:	fe8b2783          	lw	a5,-24(s6)
    80002d0a:	8b89                	andi	a5,a5,2
    80002d0c:	cb89                	beqz	a5,80002d1e <fork+0x1ba>
        for (uint64 addr = p->mmr[i].addr; addr < p->mmr[i].addr + p->mmr[i].length; addr += PGSIZE)
    80002d0e:	fd8b3903          	ld	s2,-40(s6)
    80002d12:	fe0b2783          	lw	a5,-32(s6)
    80002d16:	97ca                	add	a5,a5,s2
    80002d18:	f8f962e3          	bltu	s2,a5,80002c9c <fork+0x138>
    80002d1c:	b7c9                	j	80002cde <fork+0x17a>
        for (uint64 addr = p->mmr[i].addr; addr < p->mmr[i].addr + p->mmr[i].length; addr += PGSIZE)
    80002d1e:	fd8b3903          	ld	s2,-40(s6)
    80002d22:	fe0b2783          	lw	a5,-32(s6)
    80002d26:	97ca                	add	a5,a5,s2
    80002d28:	04f96763          	bltu	s2,a5,80002d76 <fork+0x212>
        np->mmr[i].mmr_family.proc = np;
    80002d2c:	015bb423          	sd	s5,8(s7)
        np->mmr[i].mmr_family.listid = p->mmr[i].mmr_family.listid;
    80002d30:	4088                	lw	a0,0(s1)
    80002d32:	00aba023          	sw	a0,0(s7)
        acquire(&mmr_list[p->mmr[i].mmr_family.listid].lock);
    80002d36:	0516                	slli	a0,a0,0x5
    80002d38:	956e                	add	a0,a0,s11
    80002d3a:	ffffe097          	auipc	ra,0xffffe
    80002d3e:	ede080e7          	jalr	-290(ra) # 80000c18 <acquire>
        np->mmr[i].mmr_family.next = p->mmr[i].mmr_family.next;
    80002d42:	689c                	ld	a5,16(s1)
    80002d44:	00fbb823          	sd	a5,16(s7)
        p->mmr[i].mmr_family.next = &(np->mmr[i].mmr_family);
    80002d48:	0174b823          	sd	s7,16(s1)
        np->mmr[i].mmr_family.prev = &(p->mmr[i].mmr_family);
    80002d4c:	009bbc23          	sd	s1,24(s7)
        if (p->mmr[i].mmr_family.prev == &(p->mmr[i].mmr_family))
    80002d50:	6c9c                	ld	a5,24(s1)
    80002d52:	06978363          	beq	a5,s1,80002db8 <fork+0x254>
        release(&mmr_list[p->mmr[i].mmr_family.listid].lock);
    80002d56:	4088                	lw	a0,0(s1)
    80002d58:	0516                	slli	a0,a0,0x5
    80002d5a:	956e                	add	a0,a0,s11
    80002d5c:	ffffe097          	auipc	ra,0xffffe
    80002d60:	f70080e7          	jalr	-144(ra) # 80000ccc <release>
    80002d64:	b771                	j	80002cf0 <fork+0x18c>
        for (uint64 addr = p->mmr[i].addr; addr < p->mmr[i].addr + p->mmr[i].length; addr += PGSIZE)
    80002d66:	9952                	add	s2,s2,s4
    80002d68:	fe04a783          	lw	a5,-32(s1)
    80002d6c:	fd84b703          	ld	a4,-40(s1)
    80002d70:	97ba                	add	a5,a5,a4
    80002d72:	faf97de3          	bgeu	s2,a5,80002d2c <fork+0x1c8>
          if (walkaddr(p->pagetable, addr))
    80002d76:	85ca                	mv	a1,s2
    80002d78:	0709b503          	ld	a0,112(s3)
    80002d7c:	ffffe097          	auipc	ra,0xffffe
    80002d80:	326080e7          	jalr	806(ra) # 800010a2 <walkaddr>
    80002d84:	d16d                	beqz	a0,80002d66 <fork+0x202>
            if (uvmcopyshared(p->pagetable, np->pagetable, addr, addr + PGSIZE) < 0)
    80002d86:	014906b3          	add	a3,s2,s4
    80002d8a:	864a                	mv	a2,s2
    80002d8c:	070ab583          	ld	a1,112(s5)
    80002d90:	0709b503          	ld	a0,112(s3)
    80002d94:	fffff097          	auipc	ra,0xfffff
    80002d98:	8e6080e7          	jalr	-1818(ra) # 8000167a <uvmcopyshared>
    80002d9c:	fc0555e3          	bgez	a0,80002d66 <fork+0x202>
              freeproc(np);
    80002da0:	8556                	mv	a0,s5
    80002da2:	00000097          	auipc	ra,0x0
    80002da6:	af6080e7          	jalr	-1290(ra) # 80002898 <freeproc>
              release(&np->lock);
    80002daa:	8556                	mv	a0,s5
    80002dac:	ffffe097          	auipc	ra,0xffffe
    80002db0:	f20080e7          	jalr	-224(ra) # 80000ccc <release>
             return -1;
    80002db4:	5d7d                	li	s10,-1
    80002db6:	a8a9                	j	80002e10 <fork+0x2ac>
          p->mmr[i].mmr_family.prev = &(np->mmr[i].mmr_family);
    80002db8:	0174bc23          	sd	s7,24(s1)
    80002dbc:	bf69                	j	80002d56 <fork+0x1f2>
  release(&np->lock);
    80002dbe:	8556                	mv	a0,s5
    80002dc0:	ffffe097          	auipc	ra,0xffffe
    80002dc4:	f0c080e7          	jalr	-244(ra) # 80000ccc <release>
  acquire(&wait_lock);
    80002dc8:	0000f497          	auipc	s1,0xf
    80002dcc:	58048493          	addi	s1,s1,1408 # 80012348 <wait_lock>
    80002dd0:	8526                	mv	a0,s1
    80002dd2:	ffffe097          	auipc	ra,0xffffe
    80002dd6:	e46080e7          	jalr	-442(ra) # 80000c18 <acquire>
  np->parent = p;
    80002dda:	053abc23          	sd	s3,88(s5)
  release(&wait_lock);
    80002dde:	8526                	mv	a0,s1
    80002de0:	ffffe097          	auipc	ra,0xffffe
    80002de4:	eec080e7          	jalr	-276(ra) # 80000ccc <release>
  acquire(&np->lock);
    80002de8:	8556                	mv	a0,s5
    80002dea:	ffffe097          	auipc	ra,0xffffe
    80002dee:	e2e080e7          	jalr	-466(ra) # 80000c18 <acquire>
  np->state = RUNNABLE;
    80002df2:	478d                	li	a5,3
    80002df4:	00faac23          	sw	a5,24(s5)
  enqueue_at_tail(np, np->priority);
    80002df8:	044aa583          	lw	a1,68(s5)
    80002dfc:	8556                	mv	a0,s5
    80002dfe:	fffff097          	auipc	ra,0xfffff
    80002e02:	b92080e7          	jalr	-1134(ra) # 80001990 <enqueue_at_tail>
  release(&np->lock);
    80002e06:	8556                	mv	a0,s5
    80002e08:	ffffe097          	auipc	ra,0xffffe
    80002e0c:	ec4080e7          	jalr	-316(ra) # 80000ccc <release>
}
    80002e10:	856a                	mv	a0,s10
    80002e12:	70a6                	ld	ra,104(sp)
    80002e14:	7406                	ld	s0,96(sp)
    80002e16:	64e6                	ld	s1,88(sp)
    80002e18:	6946                	ld	s2,80(sp)
    80002e1a:	69a6                	ld	s3,72(sp)
    80002e1c:	6a06                	ld	s4,64(sp)
    80002e1e:	7ae2                	ld	s5,56(sp)
    80002e20:	7b42                	ld	s6,48(sp)
    80002e22:	7ba2                	ld	s7,40(sp)
    80002e24:	7c02                	ld	s8,32(sp)
    80002e26:	6ce2                	ld	s9,24(sp)
    80002e28:	6d42                	ld	s10,16(sp)
    80002e2a:	6da2                	ld	s11,8(sp)
    80002e2c:	6165                	addi	sp,sp,112
    80002e2e:	8082                	ret
    return -1;
    80002e30:	5d7d                	li	s10,-1
    80002e32:	bff9                	j	80002e10 <fork+0x2ac>

0000000080002e34 <wait>:
{
    80002e34:	715d                	addi	sp,sp,-80
    80002e36:	e486                	sd	ra,72(sp)
    80002e38:	e0a2                	sd	s0,64(sp)
    80002e3a:	fc26                	sd	s1,56(sp)
    80002e3c:	f84a                	sd	s2,48(sp)
    80002e3e:	f44e                	sd	s3,40(sp)
    80002e40:	f052                	sd	s4,32(sp)
    80002e42:	ec56                	sd	s5,24(sp)
    80002e44:	e85a                	sd	s6,16(sp)
    80002e46:	e45e                	sd	s7,8(sp)
    80002e48:	e062                	sd	s8,0(sp)
    80002e4a:	0880                	addi	s0,sp,80
    80002e4c:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002e4e:	fffff097          	auipc	ra,0xfffff
    80002e52:	f6e080e7          	jalr	-146(ra) # 80001dbc <myproc>
    80002e56:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002e58:	0000f517          	auipc	a0,0xf
    80002e5c:	4f050513          	addi	a0,a0,1264 # 80012348 <wait_lock>
    80002e60:	ffffe097          	auipc	ra,0xffffe
    80002e64:	db8080e7          	jalr	-584(ra) # 80000c18 <acquire>
    havekids = 0;
    80002e68:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002e6a:	4a15                	li	s4,5
        havekids = 1;
    80002e6c:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002e6e:	00021997          	auipc	s3,0x21
    80002e72:	10a98993          	addi	s3,s3,266 # 80023f78 <mmr_list>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002e76:	0000fc17          	auipc	s8,0xf
    80002e7a:	4d2c0c13          	addi	s8,s8,1234 # 80012348 <wait_lock>
    havekids = 0;
    80002e7e:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002e80:	00010497          	auipc	s1,0x10
    80002e84:	8f848493          	addi	s1,s1,-1800 # 80012778 <proc>
    80002e88:	a0bd                	j	80002ef6 <wait+0xc2>
          pid = np->pid;
    80002e8a:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002e8e:	000b0e63          	beqz	s6,80002eaa <wait+0x76>
    80002e92:	4691                	li	a3,4
    80002e94:	02c48613          	addi	a2,s1,44
    80002e98:	85da                	mv	a1,s6
    80002e9a:	07093503          	ld	a0,112(s2)
    80002e9e:	fffff097          	auipc	ra,0xfffff
    80002ea2:	8ae080e7          	jalr	-1874(ra) # 8000174c <copyout>
    80002ea6:	02054563          	bltz	a0,80002ed0 <wait+0x9c>
          freeproc(np);
    80002eaa:	8526                	mv	a0,s1
    80002eac:	00000097          	auipc	ra,0x0
    80002eb0:	9ec080e7          	jalr	-1556(ra) # 80002898 <freeproc>
          release(&np->lock);
    80002eb4:	8526                	mv	a0,s1
    80002eb6:	ffffe097          	auipc	ra,0xffffe
    80002eba:	e16080e7          	jalr	-490(ra) # 80000ccc <release>
          release(&wait_lock);
    80002ebe:	0000f517          	auipc	a0,0xf
    80002ec2:	48a50513          	addi	a0,a0,1162 # 80012348 <wait_lock>
    80002ec6:	ffffe097          	auipc	ra,0xffffe
    80002eca:	e06080e7          	jalr	-506(ra) # 80000ccc <release>
          return pid;
    80002ece:	a09d                	j	80002f34 <wait+0x100>
            release(&np->lock);
    80002ed0:	8526                	mv	a0,s1
    80002ed2:	ffffe097          	auipc	ra,0xffffe
    80002ed6:	dfa080e7          	jalr	-518(ra) # 80000ccc <release>
            release(&wait_lock);
    80002eda:	0000f517          	auipc	a0,0xf
    80002ede:	46e50513          	addi	a0,a0,1134 # 80012348 <wait_lock>
    80002ee2:	ffffe097          	auipc	ra,0xffffe
    80002ee6:	dea080e7          	jalr	-534(ra) # 80000ccc <release>
            return -1;
    80002eea:	59fd                	li	s3,-1
    80002eec:	a0a1                	j	80002f34 <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    80002eee:	46048493          	addi	s1,s1,1120
    80002ef2:	03348463          	beq	s1,s3,80002f1a <wait+0xe6>
      if(np->parent == p){
    80002ef6:	6cbc                	ld	a5,88(s1)
    80002ef8:	ff279be3          	bne	a5,s2,80002eee <wait+0xba>
        acquire(&np->lock);
    80002efc:	8526                	mv	a0,s1
    80002efe:	ffffe097          	auipc	ra,0xffffe
    80002f02:	d1a080e7          	jalr	-742(ra) # 80000c18 <acquire>
        if(np->state == ZOMBIE){
    80002f06:	4c9c                	lw	a5,24(s1)
    80002f08:	f94781e3          	beq	a5,s4,80002e8a <wait+0x56>
        release(&np->lock);
    80002f0c:	8526                	mv	a0,s1
    80002f0e:	ffffe097          	auipc	ra,0xffffe
    80002f12:	dbe080e7          	jalr	-578(ra) # 80000ccc <release>
        havekids = 1;
    80002f16:	8756                	mv	a4,s5
    80002f18:	bfd9                	j	80002eee <wait+0xba>
    if(!havekids || p->killed){
    80002f1a:	c701                	beqz	a4,80002f22 <wait+0xee>
    80002f1c:	02892783          	lw	a5,40(s2)
    80002f20:	c79d                	beqz	a5,80002f4e <wait+0x11a>
      release(&wait_lock);
    80002f22:	0000f517          	auipc	a0,0xf
    80002f26:	42650513          	addi	a0,a0,1062 # 80012348 <wait_lock>
    80002f2a:	ffffe097          	auipc	ra,0xffffe
    80002f2e:	da2080e7          	jalr	-606(ra) # 80000ccc <release>
      return -1;
    80002f32:	59fd                	li	s3,-1
}
    80002f34:	854e                	mv	a0,s3
    80002f36:	60a6                	ld	ra,72(sp)
    80002f38:	6406                	ld	s0,64(sp)
    80002f3a:	74e2                	ld	s1,56(sp)
    80002f3c:	7942                	ld	s2,48(sp)
    80002f3e:	79a2                	ld	s3,40(sp)
    80002f40:	7a02                	ld	s4,32(sp)
    80002f42:	6ae2                	ld	s5,24(sp)
    80002f44:	6b42                	ld	s6,16(sp)
    80002f46:	6ba2                	ld	s7,8(sp)
    80002f48:	6c02                	ld	s8,0(sp)
    80002f4a:	6161                	addi	sp,sp,80
    80002f4c:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002f4e:	85e2                	mv	a1,s8
    80002f50:	854a                	mv	a0,s2
    80002f52:	fffff097          	auipc	ra,0xfffff
    80002f56:	2d2080e7          	jalr	722(ra) # 80002224 <sleep>
    havekids = 0;
    80002f5a:	b715                	j	80002e7e <wait+0x4a>

0000000080002f5c <wait2>:
{
    80002f5c:	7159                	addi	sp,sp,-112
    80002f5e:	f486                	sd	ra,104(sp)
    80002f60:	f0a2                	sd	s0,96(sp)
    80002f62:	eca6                	sd	s1,88(sp)
    80002f64:	e8ca                	sd	s2,80(sp)
    80002f66:	e4ce                	sd	s3,72(sp)
    80002f68:	e0d2                	sd	s4,64(sp)
    80002f6a:	fc56                	sd	s5,56(sp)
    80002f6c:	f85a                	sd	s6,48(sp)
    80002f6e:	f45e                	sd	s7,40(sp)
    80002f70:	f062                	sd	s8,32(sp)
    80002f72:	ec66                	sd	s9,24(sp)
    80002f74:	1880                	addi	s0,sp,112
    80002f76:	8b2a                	mv	s6,a0
    80002f78:	8bae                	mv	s7,a1
  struct proc *p = myproc();
    80002f7a:	fffff097          	auipc	ra,0xfffff
    80002f7e:	e42080e7          	jalr	-446(ra) # 80001dbc <myproc>
    80002f82:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002f84:	0000f517          	auipc	a0,0xf
    80002f88:	3c450513          	addi	a0,a0,964 # 80012348 <wait_lock>
    80002f8c:	ffffe097          	auipc	ra,0xffffe
    80002f90:	c8c080e7          	jalr	-884(ra) # 80000c18 <acquire>
    havekids = 0;
    80002f94:	4c01                	li	s8,0
        if(np->state == ZOMBIE){
    80002f96:	4a15                	li	s4,5
        havekids = 1;
    80002f98:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002f9a:	00021997          	auipc	s3,0x21
    80002f9e:	fde98993          	addi	s3,s3,-34 # 80023f78 <mmr_list>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002fa2:	0000fc97          	auipc	s9,0xf
    80002fa6:	3a6c8c93          	addi	s9,s9,934 # 80012348 <wait_lock>
    havekids = 0;
    80002faa:	8762                	mv	a4,s8
    for(np = proc; np < &proc[NPROC]; np++){
    80002fac:	0000f497          	auipc	s1,0xf
    80002fb0:	7cc48493          	addi	s1,s1,1996 # 80012778 <proc>
    80002fb4:	a051                	j	80003038 <wait2+0xdc>
          use.cputime = np->cputime;
    80002fb6:	7c9c                	ld	a5,56(s1)
    80002fb8:	f8f43c23          	sd	a5,-104(s0)
          copyout(p->pagetable, raddr, (char *)&use.cputime, sizeof(use.cputime));
    80002fbc:	46a1                	li	a3,8
    80002fbe:	f9840613          	addi	a2,s0,-104
    80002fc2:	85de                	mv	a1,s7
    80002fc4:	07093503          	ld	a0,112(s2)
    80002fc8:	ffffe097          	auipc	ra,0xffffe
    80002fcc:	784080e7          	jalr	1924(ra) # 8000174c <copyout>
          pid = np->pid;
    80002fd0:	0304a983          	lw	s3,48(s1)
          if(copyout(p->pagetable, addr, (char *)&np->xstate, sizeof(np->xstate)) < 0) {
    80002fd4:	4691                	li	a3,4
    80002fd6:	02c48613          	addi	a2,s1,44
    80002fda:	85da                	mv	a1,s6
    80002fdc:	07093503          	ld	a0,112(s2)
    80002fe0:	ffffe097          	auipc	ra,0xffffe
    80002fe4:	76c080e7          	jalr	1900(ra) # 8000174c <copyout>
    80002fe8:	02054563          	bltz	a0,80003012 <wait2+0xb6>
          freeproc(np);
    80002fec:	8526                	mv	a0,s1
    80002fee:	00000097          	auipc	ra,0x0
    80002ff2:	8aa080e7          	jalr	-1878(ra) # 80002898 <freeproc>
          release(&np->lock);
    80002ff6:	8526                	mv	a0,s1
    80002ff8:	ffffe097          	auipc	ra,0xffffe
    80002ffc:	cd4080e7          	jalr	-812(ra) # 80000ccc <release>
          release(&wait_lock);
    80003000:	0000f517          	auipc	a0,0xf
    80003004:	34850513          	addi	a0,a0,840 # 80012348 <wait_lock>
    80003008:	ffffe097          	auipc	ra,0xffffe
    8000300c:	cc4080e7          	jalr	-828(ra) # 80000ccc <release>
          return pid;
    80003010:	a09d                	j	80003076 <wait2+0x11a>
            release(&np->lock);
    80003012:	8526                	mv	a0,s1
    80003014:	ffffe097          	auipc	ra,0xffffe
    80003018:	cb8080e7          	jalr	-840(ra) # 80000ccc <release>
            release(&wait_lock);
    8000301c:	0000f517          	auipc	a0,0xf
    80003020:	32c50513          	addi	a0,a0,812 # 80012348 <wait_lock>
    80003024:	ffffe097          	auipc	ra,0xffffe
    80003028:	ca8080e7          	jalr	-856(ra) # 80000ccc <release>
            return -1;
    8000302c:	59fd                	li	s3,-1
    8000302e:	a0a1                	j	80003076 <wait2+0x11a>
    for(np = proc; np < &proc[NPROC]; np++){
    80003030:	46048493          	addi	s1,s1,1120
    80003034:	03348463          	beq	s1,s3,8000305c <wait2+0x100>
      if(np->parent == p){
    80003038:	6cbc                	ld	a5,88(s1)
    8000303a:	ff279be3          	bne	a5,s2,80003030 <wait2+0xd4>
        acquire(&np->lock);
    8000303e:	8526                	mv	a0,s1
    80003040:	ffffe097          	auipc	ra,0xffffe
    80003044:	bd8080e7          	jalr	-1064(ra) # 80000c18 <acquire>
        if(np->state == ZOMBIE){
    80003048:	4c9c                	lw	a5,24(s1)
    8000304a:	f74786e3          	beq	a5,s4,80002fb6 <wait2+0x5a>
        release(&np->lock);
    8000304e:	8526                	mv	a0,s1
    80003050:	ffffe097          	auipc	ra,0xffffe
    80003054:	c7c080e7          	jalr	-900(ra) # 80000ccc <release>
        havekids = 1;
    80003058:	8756                	mv	a4,s5
    8000305a:	bfd9                	j	80003030 <wait2+0xd4>
    if(!havekids || p->killed){
    8000305c:	c701                	beqz	a4,80003064 <wait2+0x108>
    8000305e:	02892783          	lw	a5,40(s2)
    80003062:	cb85                	beqz	a5,80003092 <wait2+0x136>
      release(&wait_lock);
    80003064:	0000f517          	auipc	a0,0xf
    80003068:	2e450513          	addi	a0,a0,740 # 80012348 <wait_lock>
    8000306c:	ffffe097          	auipc	ra,0xffffe
    80003070:	c60080e7          	jalr	-928(ra) # 80000ccc <release>
      return -1;
    80003074:	59fd                	li	s3,-1
}
    80003076:	854e                	mv	a0,s3
    80003078:	70a6                	ld	ra,104(sp)
    8000307a:	7406                	ld	s0,96(sp)
    8000307c:	64e6                	ld	s1,88(sp)
    8000307e:	6946                	ld	s2,80(sp)
    80003080:	69a6                	ld	s3,72(sp)
    80003082:	6a06                	ld	s4,64(sp)
    80003084:	7ae2                	ld	s5,56(sp)
    80003086:	7b42                	ld	s6,48(sp)
    80003088:	7ba2                	ld	s7,40(sp)
    8000308a:	7c02                	ld	s8,32(sp)
    8000308c:	6ce2                	ld	s9,24(sp)
    8000308e:	6165                	addi	sp,sp,112
    80003090:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80003092:	85e6                	mv	a1,s9
    80003094:	854a                	mv	a0,s2
    80003096:	fffff097          	auipc	ra,0xfffff
    8000309a:	18e080e7          	jalr	398(ra) # 80002224 <sleep>
    havekids = 0;
    8000309e:	b731                	j	80002faa <wait2+0x4e>

00000000800030a0 <alloc_mmr_listid>:

// find an unused entry in the mmr_list array
int
alloc_mmr_listid() {
    800030a0:	1101                	addi	sp,sp,-32
    800030a2:	ec06                	sd	ra,24(sp)
    800030a4:	e822                	sd	s0,16(sp)
    800030a6:	e426                	sd	s1,8(sp)
    800030a8:	1000                	addi	s0,sp,32
  acquire(&listid_lock);
    800030aa:	0000f517          	auipc	a0,0xf
    800030ae:	6b650513          	addi	a0,a0,1718 # 80012760 <listid_lock>
    800030b2:	ffffe097          	auipc	ra,0xffffe
    800030b6:	b66080e7          	jalr	-1178(ra) # 80000c18 <acquire>
  int listid = -1;
  for (int i = 0; i < NPROC*MAX_MMR; i++) {
    800030ba:	00021797          	auipc	a5,0x21
    800030be:	ed678793          	addi	a5,a5,-298 # 80023f90 <mmr_list+0x18>
    800030c2:	4481                	li	s1,0
    800030c4:	28000693          	li	a3,640
    if (mmr_list[i].valid == 0) {
    800030c8:	4398                	lw	a4,0(a5)
    800030ca:	cb01                	beqz	a4,800030da <alloc_mmr_listid+0x3a>
  for (int i = 0; i < NPROC*MAX_MMR; i++) {
    800030cc:	2485                	addiw	s1,s1,1
    800030ce:	02078793          	addi	a5,a5,32
    800030d2:	fed49be3          	bne	s1,a3,800030c8 <alloc_mmr_listid+0x28>
  int listid = -1;
    800030d6:	54fd                	li	s1,-1
    800030d8:	a811                	j	800030ec <alloc_mmr_listid+0x4c>
      mmr_list[i].valid = 1;
    800030da:	00549713          	slli	a4,s1,0x5
    800030de:	00021797          	auipc	a5,0x21
    800030e2:	e9a78793          	addi	a5,a5,-358 # 80023f78 <mmr_list>
    800030e6:	97ba                	add	a5,a5,a4
    800030e8:	4705                	li	a4,1
    800030ea:	cf98                	sw	a4,24(a5)
      listid = i;
      break;
    }
  }
  release(&listid_lock);
    800030ec:	0000f517          	auipc	a0,0xf
    800030f0:	67450513          	addi	a0,a0,1652 # 80012760 <listid_lock>
    800030f4:	ffffe097          	auipc	ra,0xffffe
    800030f8:	bd8080e7          	jalr	-1064(ra) # 80000ccc <release>
  return(listid);
}
    800030fc:	8526                	mv	a0,s1
    800030fe:	60e2                	ld	ra,24(sp)
    80003100:	6442                	ld	s0,16(sp)
    80003102:	64a2                	ld	s1,8(sp)
    80003104:	6105                	addi	sp,sp,32
    80003106:	8082                	ret

0000000080003108 <swtch>:
    80003108:	00153023          	sd	ra,0(a0)
    8000310c:	00253423          	sd	sp,8(a0)
    80003110:	e900                	sd	s0,16(a0)
    80003112:	ed04                	sd	s1,24(a0)
    80003114:	03253023          	sd	s2,32(a0)
    80003118:	03353423          	sd	s3,40(a0)
    8000311c:	03453823          	sd	s4,48(a0)
    80003120:	03553c23          	sd	s5,56(a0)
    80003124:	05653023          	sd	s6,64(a0)
    80003128:	05753423          	sd	s7,72(a0)
    8000312c:	05853823          	sd	s8,80(a0)
    80003130:	05953c23          	sd	s9,88(a0)
    80003134:	07a53023          	sd	s10,96(a0)
    80003138:	07b53423          	sd	s11,104(a0)
    8000313c:	0005b083          	ld	ra,0(a1)
    80003140:	0085b103          	ld	sp,8(a1)
    80003144:	6980                	ld	s0,16(a1)
    80003146:	6d84                	ld	s1,24(a1)
    80003148:	0205b903          	ld	s2,32(a1)
    8000314c:	0285b983          	ld	s3,40(a1)
    80003150:	0305ba03          	ld	s4,48(a1)
    80003154:	0385ba83          	ld	s5,56(a1)
    80003158:	0405bb03          	ld	s6,64(a1)
    8000315c:	0485bb83          	ld	s7,72(a1)
    80003160:	0505bc03          	ld	s8,80(a1)
    80003164:	0585bc83          	ld	s9,88(a1)
    80003168:	0605bd03          	ld	s10,96(a1)
    8000316c:	0685bd83          	ld	s11,104(a1)
    80003170:	8082                	ret

0000000080003172 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80003172:	1141                	addi	sp,sp,-16
    80003174:	e406                	sd	ra,8(sp)
    80003176:	e022                	sd	s0,0(sp)
    80003178:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000317a:	00006597          	auipc	a1,0x6
    8000317e:	1f658593          	addi	a1,a1,502 # 80009370 <states.0+0x30>
    80003182:	00026517          	auipc	a0,0x26
    80003186:	df650513          	addi	a0,a0,-522 # 80028f78 <tickslock>
    8000318a:	ffffe097          	auipc	ra,0xffffe
    8000318e:	9fe080e7          	jalr	-1538(ra) # 80000b88 <initlock>
}
    80003192:	60a2                	ld	ra,8(sp)
    80003194:	6402                	ld	s0,0(sp)
    80003196:	0141                	addi	sp,sp,16
    80003198:	8082                	ret

000000008000319a <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000319a:	1141                	addi	sp,sp,-16
    8000319c:	e422                	sd	s0,8(sp)
    8000319e:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800031a0:	00004797          	auipc	a5,0x4
    800031a4:	b5078793          	addi	a5,a5,-1200 # 80006cf0 <kernelvec>
    800031a8:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800031ac:	6422                	ld	s0,8(sp)
    800031ae:	0141                	addi	sp,sp,16
    800031b0:	8082                	ret

00000000800031b2 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800031b2:	1141                	addi	sp,sp,-16
    800031b4:	e406                	sd	ra,8(sp)
    800031b6:	e022                	sd	s0,0(sp)
    800031b8:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800031ba:	fffff097          	auipc	ra,0xfffff
    800031be:	c02080e7          	jalr	-1022(ra) # 80001dbc <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800031c2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800031c6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800031c8:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800031cc:	00005697          	auipc	a3,0x5
    800031d0:	e3468693          	addi	a3,a3,-460 # 80008000 <_trampoline>
    800031d4:	00005717          	auipc	a4,0x5
    800031d8:	e2c70713          	addi	a4,a4,-468 # 80008000 <_trampoline>
    800031dc:	8f15                	sub	a4,a4,a3
    800031de:	040007b7          	lui	a5,0x4000
    800031e2:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800031e4:	07b2                	slli	a5,a5,0xc
    800031e6:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800031e8:	10571073          	csrw	stvec,a4

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800031ec:	7d38                	ld	a4,120(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800031ee:	18002673          	csrr	a2,satp
    800031f2:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800031f4:	7d30                	ld	a2,120(a0)
    800031f6:	7138                	ld	a4,96(a0)
    800031f8:	6585                	lui	a1,0x1
    800031fa:	972e                	add	a4,a4,a1
    800031fc:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800031fe:	7d38                	ld	a4,120(a0)
    80003200:	00000617          	auipc	a2,0x0
    80003204:	13860613          	addi	a2,a2,312 # 80003338 <usertrap>
    80003208:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000320a:	7d38                	ld	a4,120(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000320c:	8612                	mv	a2,tp
    8000320e:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003210:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80003214:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80003218:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000321c:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80003220:	7d38                	ld	a4,120(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003222:	6f18                	ld	a4,24(a4)
    80003224:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80003228:	792c                	ld	a1,112(a0)
    8000322a:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    8000322c:	00005717          	auipc	a4,0x5
    80003230:	e6470713          	addi	a4,a4,-412 # 80008090 <userret>
    80003234:	8f15                	sub	a4,a4,a3
    80003236:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80003238:	577d                	li	a4,-1
    8000323a:	177e                	slli	a4,a4,0x3f
    8000323c:	8dd9                	or	a1,a1,a4
    8000323e:	02000537          	lui	a0,0x2000
    80003242:	157d                	addi	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    80003244:	0536                	slli	a0,a0,0xd
    80003246:	9782                	jalr	a5
}
    80003248:	60a2                	ld	ra,8(sp)
    8000324a:	6402                	ld	s0,0(sp)
    8000324c:	0141                	addi	sp,sp,16
    8000324e:	8082                	ret

0000000080003250 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80003250:	1101                	addi	sp,sp,-32
    80003252:	ec06                	sd	ra,24(sp)
    80003254:	e822                	sd	s0,16(sp)
    80003256:	e426                	sd	s1,8(sp)
    80003258:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000325a:	00026497          	auipc	s1,0x26
    8000325e:	d1e48493          	addi	s1,s1,-738 # 80028f78 <tickslock>
    80003262:	8526                	mv	a0,s1
    80003264:	ffffe097          	auipc	ra,0xffffe
    80003268:	9b4080e7          	jalr	-1612(ra) # 80000c18 <acquire>
  ticks++;
    8000326c:	00007517          	auipc	a0,0x7
    80003270:	dd050513          	addi	a0,a0,-560 # 8000a03c <ticks>
    80003274:	411c                	lw	a5,0(a0)
    80003276:	2785                	addiw	a5,a5,1
    80003278:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000327a:	fffff097          	auipc	ra,0xfffff
    8000327e:	00e080e7          	jalr	14(ra) # 80002288 <wakeup>
  release(&tickslock);
    80003282:	8526                	mv	a0,s1
    80003284:	ffffe097          	auipc	ra,0xffffe
    80003288:	a48080e7          	jalr	-1464(ra) # 80000ccc <release>
}
    8000328c:	60e2                	ld	ra,24(sp)
    8000328e:	6442                	ld	s0,16(sp)
    80003290:	64a2                	ld	s1,8(sp)
    80003292:	6105                	addi	sp,sp,32
    80003294:	8082                	ret

0000000080003296 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80003296:	1101                	addi	sp,sp,-32
    80003298:	ec06                	sd	ra,24(sp)
    8000329a:	e822                	sd	s0,16(sp)
    8000329c:	e426                	sd	s1,8(sp)
    8000329e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800032a0:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800032a4:	00074d63          	bltz	a4,800032be <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800032a8:	57fd                	li	a5,-1
    800032aa:	17fe                	slli	a5,a5,0x3f
    800032ac:	0785                	addi	a5,a5,1
  // } else if (scause == 13 || scause == 15){
  //   printf("page trap!");
  //   return 4;
  //Catch page trap
  } else {
    return 0;
    800032ae:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800032b0:	06f70363          	beq	a4,a5,80003316 <devintr+0x80>
  }
}
    800032b4:	60e2                	ld	ra,24(sp)
    800032b6:	6442                	ld	s0,16(sp)
    800032b8:	64a2                	ld	s1,8(sp)
    800032ba:	6105                	addi	sp,sp,32
    800032bc:	8082                	ret
     (scause & 0xff) == 9){
    800032be:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    800032c2:	46a5                	li	a3,9
    800032c4:	fed792e3          	bne	a5,a3,800032a8 <devintr+0x12>
    int irq = plic_claim();
    800032c8:	00004097          	auipc	ra,0x4
    800032cc:	b30080e7          	jalr	-1232(ra) # 80006df8 <plic_claim>
    800032d0:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800032d2:	47a9                	li	a5,10
    800032d4:	02f50763          	beq	a0,a5,80003302 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800032d8:	4785                	li	a5,1
    800032da:	02f50963          	beq	a0,a5,8000330c <devintr+0x76>
    return 1;
    800032de:	4505                	li	a0,1
    } else if(irq){
    800032e0:	d8f1                	beqz	s1,800032b4 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800032e2:	85a6                	mv	a1,s1
    800032e4:	00006517          	auipc	a0,0x6
    800032e8:	09450513          	addi	a0,a0,148 # 80009378 <states.0+0x38>
    800032ec:	ffffd097          	auipc	ra,0xffffd
    800032f0:	298080e7          	jalr	664(ra) # 80000584 <printf>
      plic_complete(irq);
    800032f4:	8526                	mv	a0,s1
    800032f6:	00004097          	auipc	ra,0x4
    800032fa:	b26080e7          	jalr	-1242(ra) # 80006e1c <plic_complete>
    return 1;
    800032fe:	4505                	li	a0,1
    80003300:	bf55                	j	800032b4 <devintr+0x1e>
      uartintr();
    80003302:	ffffd097          	auipc	ra,0xffffd
    80003306:	690080e7          	jalr	1680(ra) # 80000992 <uartintr>
    8000330a:	b7ed                	j	800032f4 <devintr+0x5e>
      virtio_disk_intr();
    8000330c:	00004097          	auipc	ra,0x4
    80003310:	f9c080e7          	jalr	-100(ra) # 800072a8 <virtio_disk_intr>
    80003314:	b7c5                	j	800032f4 <devintr+0x5e>
    if(cpuid() == 0){
    80003316:	fffff097          	auipc	ra,0xfffff
    8000331a:	a7a080e7          	jalr	-1414(ra) # 80001d90 <cpuid>
    8000331e:	c901                	beqz	a0,8000332e <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80003320:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80003324:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80003326:	14479073          	csrw	sip,a5
    return 2;
    8000332a:	4509                	li	a0,2
    8000332c:	b761                	j	800032b4 <devintr+0x1e>
      clockintr();
    8000332e:	00000097          	auipc	ra,0x0
    80003332:	f22080e7          	jalr	-222(ra) # 80003250 <clockintr>
    80003336:	b7ed                	j	80003320 <devintr+0x8a>

0000000080003338 <usertrap>:
{
    80003338:	715d                	addi	sp,sp,-80
    8000333a:	e486                	sd	ra,72(sp)
    8000333c:	e0a2                	sd	s0,64(sp)
    8000333e:	fc26                	sd	s1,56(sp)
    80003340:	f84a                	sd	s2,48(sp)
    80003342:	f44e                	sd	s3,40(sp)
    80003344:	f052                	sd	s4,32(sp)
    80003346:	ec56                	sd	s5,24(sp)
    80003348:	e85a                	sd	s6,16(sp)
    8000334a:	e45e                	sd	s7,8(sp)
    8000334c:	e062                	sd	s8,0(sp)
    8000334e:	0880                	addi	s0,sp,80
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003350:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80003354:	1007f793          	andi	a5,a5,256
    80003358:	ebb5                	bnez	a5,800033cc <usertrap+0x94>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000335a:	00004797          	auipc	a5,0x4
    8000335e:	99678793          	addi	a5,a5,-1642 # 80006cf0 <kernelvec>
    80003362:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80003366:	fffff097          	auipc	ra,0xfffff
    8000336a:	a56080e7          	jalr	-1450(ra) # 80001dbc <myproc>
    8000336e:	892a                	mv	s2,a0
  p->trapframe->epc = r_sepc();
    80003370:	7d3c                	ld	a5,120(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003372:	14102773          	csrr	a4,sepc
    80003376:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003378:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000337c:	47a1                	li	a5,8
    8000337e:	06f71563          	bne	a4,a5,800033e8 <usertrap+0xb0>
    if(p->killed)
    80003382:	551c                	lw	a5,40(a0)
    80003384:	efa1                	bnez	a5,800033dc <usertrap+0xa4>
    p->trapframe->epc += 4;
    80003386:	07893703          	ld	a4,120(s2)
    8000338a:	6f1c                	ld	a5,24(a4)
    8000338c:	0791                	addi	a5,a5,4
    8000338e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003390:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80003394:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003398:	10079073          	csrw	sstatus,a5
    syscall();
    8000339c:	00000097          	auipc	ra,0x0
    800033a0:	5e2080e7          	jalr	1506(ra) # 8000397e <syscall>
  if(p->killed)
    800033a4:	02892783          	lw	a5,40(s2)
    800033a8:	12079c63          	bnez	a5,800034e0 <usertrap+0x1a8>
  usertrapret();
    800033ac:	00000097          	auipc	ra,0x0
    800033b0:	e06080e7          	jalr	-506(ra) # 800031b2 <usertrapret>
}
    800033b4:	60a6                	ld	ra,72(sp)
    800033b6:	6406                	ld	s0,64(sp)
    800033b8:	74e2                	ld	s1,56(sp)
    800033ba:	7942                	ld	s2,48(sp)
    800033bc:	79a2                	ld	s3,40(sp)
    800033be:	7a02                	ld	s4,32(sp)
    800033c0:	6ae2                	ld	s5,24(sp)
    800033c2:	6b42                	ld	s6,16(sp)
    800033c4:	6ba2                	ld	s7,8(sp)
    800033c6:	6c02                	ld	s8,0(sp)
    800033c8:	6161                	addi	sp,sp,80
    800033ca:	8082                	ret
    panic("usertrap: not from user mode");
    800033cc:	00006517          	auipc	a0,0x6
    800033d0:	fcc50513          	addi	a0,a0,-52 # 80009398 <states.0+0x58>
    800033d4:	ffffd097          	auipc	ra,0xffffd
    800033d8:	166080e7          	jalr	358(ra) # 8000053a <panic>
      exit(-1);
    800033dc:	557d                	li	a0,-1
    800033de:	fffff097          	auipc	ra,0xfffff
    800033e2:	024080e7          	jalr	36(ra) # 80002402 <exit>
    800033e6:	b745                	j	80003386 <usertrap+0x4e>
  } else if((which_dev = devintr()) != 0){
    800033e8:	00000097          	auipc	ra,0x0
    800033ec:	eae080e7          	jalr	-338(ra) # 80003296 <devintr>
    800033f0:	84aa                	mv	s1,a0
    800033f2:	e17d                	bnez	a0,800034d8 <usertrap+0x1a0>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800033f4:	14202773          	csrr	a4,scause
  } else if(r_scause() == 13 || r_scause() == 15) {
    800033f8:	47b5                	li	a5,13
    800033fa:	00f70763          	beq	a4,a5,80003408 <usertrap+0xd0>
    800033fe:	14202773          	csrr	a4,scause
    80003402:	47bd                	li	a5,15
    80003404:	08f71e63          	bne	a4,a5,800034a0 <usertrap+0x168>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003408:	143029f3          	csrr	s3,stval
    for(int i = 0; i < MAX_MMR; i++){
    8000340c:	18890493          	addi	s1,s2,392
    80003410:	45890a93          	addi	s5,s2,1112
        if(r_scause() == 13 && (p->mmr[i].prot & PTE_R)){
    80003414:	4c35                	li	s8,13
        if(r_scause() == 15 && (p->mmr[i].prot & PTE_W)) {
    80003416:	4bbd                	li	s7,15
          uint64 start_addr = PGROUNDDOWN(faultAddress);
    80003418:	7b7d                	lui	s6,0xfffff
    8000341a:	0169fb33          	and	s6,s3,s6
    8000341e:	a80d                	j	80003450 <usertrap+0x118>
        if(r_scause() == 13 && (p->mmr[i].prot & PTE_R)){
    80003420:	44dc                	lw	a5,12(s1)
    80003422:	8b89                	andi	a5,a5,2
    80003424:	c7a1                	beqz	a5,8000346c <usertrap+0x134>
          uint64 physAddress = (uint64)kalloc();
    80003426:	ffffd097          	auipc	ra,0xffffd
    8000342a:	6ba080e7          	jalr	1722(ra) # 80000ae0 <kalloc>
    8000342e:	86aa                	mv	a3,a0
          mappages(p->pagetable, start_addr, PGSIZE, physAddress,p->mmr[i].prot | PTE_U);
    80003430:	44d8                	lw	a4,12(s1)
    80003432:	01076713          	ori	a4,a4,16
    80003436:	6605                	lui	a2,0x1
    80003438:	85da                	mv	a1,s6
    8000343a:	07093503          	ld	a0,112(s2)
    8000343e:	ffffe097          	auipc	ra,0xffffe
    80003442:	ca6080e7          	jalr	-858(ra) # 800010e4 <mappages>
    80003446:	a01d                	j	8000346c <usertrap+0x134>
    for(int i = 0; i < MAX_MMR; i++){
    80003448:	04848493          	addi	s1,s1,72
    8000344c:	f5548ce3          	beq	s1,s5,800033a4 <usertrap+0x6c>
      if(faultAddress >= p->mmr[i].addr && faultAddress < (p->mmr[i].addr + p->mmr[i].length) && p->mmr[i].valid){
    80003450:	8a26                	mv	s4,s1
    80003452:	609c                	ld	a5,0(s1)
    80003454:	fef9eae3          	bltu	s3,a5,80003448 <usertrap+0x110>
    80003458:	4498                	lw	a4,8(s1)
    8000345a:	97ba                	add	a5,a5,a4
    8000345c:	fef9f6e3          	bgeu	s3,a5,80003448 <usertrap+0x110>
    80003460:	48dc                	lw	a5,20(s1)
    80003462:	d3fd                	beqz	a5,80003448 <usertrap+0x110>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003464:	142027f3          	csrr	a5,scause
        if(r_scause() == 13 && (p->mmr[i].prot & PTE_R)){
    80003468:	fb878ce3          	beq	a5,s8,80003420 <usertrap+0xe8>
    8000346c:	142027f3          	csrr	a5,scause
        if(r_scause() == 15 && (p->mmr[i].prot & PTE_W)) {
    80003470:	fd779ce3          	bne	a5,s7,80003448 <usertrap+0x110>
    80003474:	00ca2783          	lw	a5,12(s4) # 100c <_entry-0x7fffeff4>
    80003478:	8b91                	andi	a5,a5,4
    8000347a:	d7f9                	beqz	a5,80003448 <usertrap+0x110>
          uint64 physAddress = (uint64)kalloc();
    8000347c:	ffffd097          	auipc	ra,0xffffd
    80003480:	664080e7          	jalr	1636(ra) # 80000ae0 <kalloc>
    80003484:	86aa                	mv	a3,a0
          mappages(p->pagetable, start_addr, PGSIZE, physAddress,p->mmr[i].prot | PTE_U);
    80003486:	00ca2703          	lw	a4,12(s4)
    8000348a:	01076713          	ori	a4,a4,16
    8000348e:	6605                	lui	a2,0x1
    80003490:	85da                	mv	a1,s6
    80003492:	07093503          	ld	a0,112(s2)
    80003496:	ffffe097          	auipc	ra,0xffffe
    8000349a:	c4e080e7          	jalr	-946(ra) # 800010e4 <mappages>
    8000349e:	b76d                	j	80003448 <usertrap+0x110>
    800034a0:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800034a4:	03092603          	lw	a2,48(s2)
    800034a8:	00006517          	auipc	a0,0x6
    800034ac:	f1050513          	addi	a0,a0,-240 # 800093b8 <states.0+0x78>
    800034b0:	ffffd097          	auipc	ra,0xffffd
    800034b4:	0d4080e7          	jalr	212(ra) # 80000584 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800034b8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800034bc:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800034c0:	00006517          	auipc	a0,0x6
    800034c4:	f2850513          	addi	a0,a0,-216 # 800093e8 <states.0+0xa8>
    800034c8:	ffffd097          	auipc	ra,0xffffd
    800034cc:	0bc080e7          	jalr	188(ra) # 80000584 <printf>
    p->killed = 1;
    800034d0:	4785                	li	a5,1
    800034d2:	02f92423          	sw	a5,40(s2)
  if(p->killed)
    800034d6:	a031                	j	800034e2 <usertrap+0x1aa>
    800034d8:	02892783          	lw	a5,40(s2)
    800034dc:	cb81                	beqz	a5,800034ec <usertrap+0x1b4>
    800034de:	a011                	j	800034e2 <usertrap+0x1aa>
    800034e0:	4481                	li	s1,0
    exit(-1);
    800034e2:	557d                	li	a0,-1
    800034e4:	fffff097          	auipc	ra,0xfffff
    800034e8:	f1e080e7          	jalr	-226(ra) # 80002402 <exit>
  if(which_dev == 2){
    800034ec:	4789                	li	a5,2
    800034ee:	eaf49fe3          	bne	s1,a5,800033ac <usertrap+0x74>
    if(sched_policy_trap == MLFQ && --(p->tsticks) <= 0){
    800034f2:	00007797          	auipc	a5,0x7
    800034f6:	b427a783          	lw	a5,-1214(a5) # 8000a034 <sched_policy_trap>
    800034fa:	4705                	li	a4,1
    800034fc:	00e78d63          	beq	a5,a4,80003516 <usertrap+0x1de>
    if(sched_policy_trap == RR){
    80003500:	e791                	bnez	a5,8000350c <usertrap+0x1d4>
      p->cputime++;
    80003502:	03893783          	ld	a5,56(s2)
    80003506:	0785                	addi	a5,a5,1
    80003508:	02f93c23          	sd	a5,56(s2)
    yield();
    8000350c:	fffff097          	auipc	ra,0xfffff
    80003510:	cd0080e7          	jalr	-816(ra) # 800021dc <yield>
    80003514:	bd61                	j	800033ac <usertrap+0x74>
    if(sched_policy_trap == MLFQ && --(p->tsticks) <= 0){
    80003516:	04092783          	lw	a5,64(s2)
    8000351a:	37fd                	addiw	a5,a5,-1
    8000351c:	0007871b          	sext.w	a4,a5
    80003520:	04f92023          	sw	a5,64(s2)
    80003524:	f765                	bnez	a4,8000350c <usertrap+0x1d4>
      if(p->priority == LOW){
    80003526:	04492783          	lw	a5,68(s2)
    8000352a:	4709                	li	a4,2
    8000352c:	00e78b63          	beq	a5,a4,80003542 <usertrap+0x20a>
      } else if (p->priority == MEDIUM){
    80003530:	4705                	li	a4,1
    80003532:	02e78763          	beq	a5,a4,80003560 <usertrap+0x228>
      } else if (p->priority == HIGH){
    80003536:	ef85                	bnez	a5,8000356e <usertrap+0x236>
        p->cputime = p->cputime + TSTICKSHIGH;
    80003538:	03893783          	ld	a5,56(s2)
    8000353c:	0785                	addi	a5,a5,1
    8000353e:	4705                	li	a4,1
    80003540:	a039                	j	8000354e <usertrap+0x216>
        p->cputime = p->cputime + TSTICKSLOW;
    80003542:	03893783          	ld	a5,56(s2)
    80003546:	0c878793          	addi	a5,a5,200
        p->tsticks = TSTICKSLOW;
    8000354a:	0c800713          	li	a4,200
        p->cputime = p->cputime + TSTICKSHIGH;
    8000354e:	02f93c23          	sd	a5,56(s2)
        tempsticks = TSTICKSHIGH;
    80003552:	00007797          	auipc	a5,0x7
    80003556:	aee7a323          	sw	a4,-1306(a5) # 8000a038 <tempsticks>
        p->tsticks = TSTICKSHIGH;
    8000355a:	04e92023          	sw	a4,64(s2)
      if(p->priority > LOW) {
    8000355e:	b77d                	j	8000350c <usertrap+0x1d4>
        p->cputime = p->cputime + TSTICKSMEDIUM;
    80003560:	03893783          	ld	a5,56(s2)
    80003564:	03278793          	addi	a5,a5,50
        p->tsticks = TSTICKSMEDIUM;
    80003568:	03200713          	li	a4,50
    8000356c:	b7cd                	j	8000354e <usertrap+0x216>
      if(p->priority > LOW) {
    8000356e:	4709                	li	a4,2
    80003570:	f8f75ee3          	bge	a4,a5,8000350c <usertrap+0x1d4>
        p->priority = p->priority - 1;
    80003574:	37fd                	addiw	a5,a5,-1
    80003576:	0007871b          	sext.w	a4,a5
    8000357a:	04f92223          	sw	a5,68(s2)
        if(p->priority == LOW){
    8000357e:	4789                	li	a5,2
    80003580:	f8f716e3          	bne	a4,a5,8000350c <usertrap+0x1d4>
          p->timeslice = TSTICKSLOW;
    80003584:	0c800793          	li	a5,200
    80003588:	04f92423          	sw	a5,72(s2)
          p->tsticks = TSTICKSLOW;
    8000358c:	04f92023          	sw	a5,64(s2)
          tempsticks = TSTICKSLOW;
    80003590:	00007717          	auipc	a4,0x7
    80003594:	aaf72423          	sw	a5,-1368(a4) # 8000a038 <tempsticks>
    80003598:	bf95                	j	8000350c <usertrap+0x1d4>

000000008000359a <kerneltrap>:
{
    8000359a:	7179                	addi	sp,sp,-48
    8000359c:	f406                	sd	ra,40(sp)
    8000359e:	f022                	sd	s0,32(sp)
    800035a0:	ec26                	sd	s1,24(sp)
    800035a2:	e84a                	sd	s2,16(sp)
    800035a4:	e44e                	sd	s3,8(sp)
    800035a6:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800035a8:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800035ac:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800035b0:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800035b4:	1004f793          	andi	a5,s1,256
    800035b8:	cb85                	beqz	a5,800035e8 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800035ba:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800035be:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800035c0:	ef85                	bnez	a5,800035f8 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800035c2:	00000097          	auipc	ra,0x0
    800035c6:	cd4080e7          	jalr	-812(ra) # 80003296 <devintr>
    800035ca:	cd1d                	beqz	a0,80003608 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING){
    800035cc:	4789                	li	a5,2
    800035ce:	06f50a63          	beq	a0,a5,80003642 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800035d2:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800035d6:	10049073          	csrw	sstatus,s1
}
    800035da:	70a2                	ld	ra,40(sp)
    800035dc:	7402                	ld	s0,32(sp)
    800035de:	64e2                	ld	s1,24(sp)
    800035e0:	6942                	ld	s2,16(sp)
    800035e2:	69a2                	ld	s3,8(sp)
    800035e4:	6145                	addi	sp,sp,48
    800035e6:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800035e8:	00006517          	auipc	a0,0x6
    800035ec:	e2050513          	addi	a0,a0,-480 # 80009408 <states.0+0xc8>
    800035f0:	ffffd097          	auipc	ra,0xffffd
    800035f4:	f4a080e7          	jalr	-182(ra) # 8000053a <panic>
    panic("kerneltrap: interrupts enabled");
    800035f8:	00006517          	auipc	a0,0x6
    800035fc:	e3850513          	addi	a0,a0,-456 # 80009430 <states.0+0xf0>
    80003600:	ffffd097          	auipc	ra,0xffffd
    80003604:	f3a080e7          	jalr	-198(ra) # 8000053a <panic>
    printf("scause %p\n", scause);
    80003608:	85ce                	mv	a1,s3
    8000360a:	00006517          	auipc	a0,0x6
    8000360e:	e4650513          	addi	a0,a0,-442 # 80009450 <states.0+0x110>
    80003612:	ffffd097          	auipc	ra,0xffffd
    80003616:	f72080e7          	jalr	-142(ra) # 80000584 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000361a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000361e:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003622:	00006517          	auipc	a0,0x6
    80003626:	e3e50513          	addi	a0,a0,-450 # 80009460 <states.0+0x120>
    8000362a:	ffffd097          	auipc	ra,0xffffd
    8000362e:	f5a080e7          	jalr	-166(ra) # 80000584 <printf>
    panic("kerneltrap");
    80003632:	00006517          	auipc	a0,0x6
    80003636:	e4650513          	addi	a0,a0,-442 # 80009478 <states.0+0x138>
    8000363a:	ffffd097          	auipc	ra,0xffffd
    8000363e:	f00080e7          	jalr	-256(ra) # 8000053a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING){
    80003642:	ffffe097          	auipc	ra,0xffffe
    80003646:	77a080e7          	jalr	1914(ra) # 80001dbc <myproc>
    8000364a:	d541                	beqz	a0,800035d2 <kerneltrap+0x38>
    8000364c:	ffffe097          	auipc	ra,0xffffe
    80003650:	770080e7          	jalr	1904(ra) # 80001dbc <myproc>
    80003654:	4d18                	lw	a4,24(a0)
    80003656:	4791                	li	a5,4
    80003658:	f6f71de3          	bne	a4,a5,800035d2 <kerneltrap+0x38>
    if(sched_policy_trap == MLFQ && --(myproc()->tsticks) <= 0){
    8000365c:	00007717          	auipc	a4,0x7
    80003660:	9d872703          	lw	a4,-1576(a4) # 8000a034 <sched_policy_trap>
    80003664:	4785                	li	a5,1
    80003666:	00f70d63          	beq	a4,a5,80003680 <kerneltrap+0xe6>
    if(sched_policy_trap == RR){
    8000366a:	00007797          	auipc	a5,0x7
    8000366e:	9ca7a783          	lw	a5,-1590(a5) # 8000a034 <sched_policy_trap>
    80003672:	18078363          	beqz	a5,800037f8 <kerneltrap+0x25e>
    yield();
    80003676:	fffff097          	auipc	ra,0xfffff
    8000367a:	b66080e7          	jalr	-1178(ra) # 800021dc <yield>
    8000367e:	bf91                	j	800035d2 <kerneltrap+0x38>
    if(sched_policy_trap == MLFQ && --(myproc()->tsticks) <= 0){
    80003680:	ffffe097          	auipc	ra,0xffffe
    80003684:	73c080e7          	jalr	1852(ra) # 80001dbc <myproc>
    80003688:	413c                	lw	a5,64(a0)
    8000368a:	37fd                	addiw	a5,a5,-1
    8000368c:	0007871b          	sext.w	a4,a5
    80003690:	c13c                	sw	a5,64(a0)
    80003692:	ff61                	bnez	a4,8000366a <kerneltrap+0xd0>
      if(myproc()->priority == LOW){
    80003694:	ffffe097          	auipc	ra,0xffffe
    80003698:	728080e7          	jalr	1832(ra) # 80001dbc <myproc>
    8000369c:	4178                	lw	a4,68(a0)
    8000369e:	4789                	li	a5,2
    800036a0:	04f70a63          	beq	a4,a5,800036f4 <kerneltrap+0x15a>
      } else if (myproc()->priority == MEDIUM){
    800036a4:	ffffe097          	auipc	ra,0xffffe
    800036a8:	718080e7          	jalr	1816(ra) # 80001dbc <myproc>
    800036ac:	4178                	lw	a4,68(a0)
    800036ae:	4785                	li	a5,1
    800036b0:	0ef70663          	beq	a4,a5,8000379c <kerneltrap+0x202>
      } else if (myproc()->priority == HIGH){
    800036b4:	ffffe097          	auipc	ra,0xffffe
    800036b8:	708080e7          	jalr	1800(ra) # 80001dbc <myproc>
    800036bc:	417c                	lw	a5,68(a0)
    800036be:	e7a5                	bnez	a5,80003726 <kerneltrap+0x18c>
        myproc()->cputime = myproc()->cputime + TSTICKSHIGH;
    800036c0:	ffffe097          	auipc	ra,0xffffe
    800036c4:	6fc080e7          	jalr	1788(ra) # 80001dbc <myproc>
    800036c8:	03853983          	ld	s3,56(a0)
    800036cc:	ffffe097          	auipc	ra,0xffffe
    800036d0:	6f0080e7          	jalr	1776(ra) # 80001dbc <myproc>
    800036d4:	0985                	addi	s3,s3,1
    800036d6:	03353c23          	sd	s3,56(a0)
        tempsticks = TSTICKSLOW;
    800036da:	0c800793          	li	a5,200
    800036de:	00007717          	auipc	a4,0x7
    800036e2:	94f72d23          	sw	a5,-1702(a4) # 8000a038 <tempsticks>
        myproc()->tsticks = HIGH;
    800036e6:	ffffe097          	auipc	ra,0xffffe
    800036ea:	6d6080e7          	jalr	1750(ra) # 80001dbc <myproc>
    800036ee:	04052023          	sw	zero,64(a0)
    800036f2:	a815                	j	80003726 <kerneltrap+0x18c>
        myproc()->cputime = myproc()->cputime + TSTICKSLOW;
    800036f4:	ffffe097          	auipc	ra,0xffffe
    800036f8:	6c8080e7          	jalr	1736(ra) # 80001dbc <myproc>
    800036fc:	03853983          	ld	s3,56(a0)
    80003700:	ffffe097          	auipc	ra,0xffffe
    80003704:	6bc080e7          	jalr	1724(ra) # 80001dbc <myproc>
    80003708:	0c898993          	addi	s3,s3,200
    8000370c:	03353c23          	sd	s3,56(a0)
        myproc()->tsticks = TSTICKSLOW;
    80003710:	ffffe097          	auipc	ra,0xffffe
    80003714:	6ac080e7          	jalr	1708(ra) # 80001dbc <myproc>
    80003718:	0c800793          	li	a5,200
    8000371c:	c13c                	sw	a5,64(a0)
        tempsticks = TSTICKSLOW;
    8000371e:	00007717          	auipc	a4,0x7
    80003722:	90f72d23          	sw	a5,-1766(a4) # 8000a038 <tempsticks>
      tempsticks = myproc()->tsticks;
    80003726:	ffffe097          	auipc	ra,0xffffe
    8000372a:	696080e7          	jalr	1686(ra) # 80001dbc <myproc>
    8000372e:	413c                	lw	a5,64(a0)
    80003730:	00007717          	auipc	a4,0x7
    80003734:	90f72423          	sw	a5,-1784(a4) # 8000a038 <tempsticks>
      if(myproc()->priority > LOW){
    80003738:	ffffe097          	auipc	ra,0xffffe
    8000373c:	684080e7          	jalr	1668(ra) # 80001dbc <myproc>
    80003740:	4178                	lw	a4,68(a0)
    80003742:	4789                	li	a5,2
    80003744:	f2e7d3e3          	bge	a5,a4,8000366a <kerneltrap+0xd0>
        myproc()->priority--;
    80003748:	ffffe097          	auipc	ra,0xffffe
    8000374c:	674080e7          	jalr	1652(ra) # 80001dbc <myproc>
    80003750:	4178                	lw	a4,68(a0)
    80003752:	377d                	addiw	a4,a4,-1
    80003754:	c178                	sw	a4,68(a0)
        if(myproc()->priority == MEDIUM){
    80003756:	ffffe097          	auipc	ra,0xffffe
    8000375a:	666080e7          	jalr	1638(ra) # 80001dbc <myproc>
    8000375e:	4178                	lw	a4,68(a0)
    80003760:	4785                	li	a5,1
    80003762:	06f70863          	beq	a4,a5,800037d2 <kerneltrap+0x238>
        if(myproc()->priority == LOW){
    80003766:	ffffe097          	auipc	ra,0xffffe
    8000376a:	656080e7          	jalr	1622(ra) # 80001dbc <myproc>
    8000376e:	4178                	lw	a4,68(a0)
    80003770:	4789                	li	a5,2
    80003772:	eef71ce3          	bne	a4,a5,8000366a <kerneltrap+0xd0>
          myproc()->timeslice = TSTICKSLOW;
    80003776:	ffffe097          	auipc	ra,0xffffe
    8000377a:	646080e7          	jalr	1606(ra) # 80001dbc <myproc>
    8000377e:	0c800993          	li	s3,200
    80003782:	05352423          	sw	s3,72(a0)
          myproc()->tsticks = TSTICKSLOW;
    80003786:	ffffe097          	auipc	ra,0xffffe
    8000378a:	636080e7          	jalr	1590(ra) # 80001dbc <myproc>
    8000378e:	05352023          	sw	s3,64(a0)
          tempsticks = TSTICKSLOW;
    80003792:	00007797          	auipc	a5,0x7
    80003796:	8b37a323          	sw	s3,-1882(a5) # 8000a038 <tempsticks>
    8000379a:	bdc1                	j	8000366a <kerneltrap+0xd0>
        myproc()->cputime = myproc()->cputime + TSTICKSMEDIUM;
    8000379c:	ffffe097          	auipc	ra,0xffffe
    800037a0:	620080e7          	jalr	1568(ra) # 80001dbc <myproc>
    800037a4:	03853983          	ld	s3,56(a0)
    800037a8:	ffffe097          	auipc	ra,0xffffe
    800037ac:	614080e7          	jalr	1556(ra) # 80001dbc <myproc>
    800037b0:	03298993          	addi	s3,s3,50
    800037b4:	03353c23          	sd	s3,56(a0)
        tempsticks = TSTICKSMEDIUM;
    800037b8:	03200993          	li	s3,50
    800037bc:	00007797          	auipc	a5,0x7
    800037c0:	8737ae23          	sw	s3,-1924(a5) # 8000a038 <tempsticks>
        myproc()->tsticks = TSTICKSMEDIUM;
    800037c4:	ffffe097          	auipc	ra,0xffffe
    800037c8:	5f8080e7          	jalr	1528(ra) # 80001dbc <myproc>
    800037cc:	05352023          	sw	s3,64(a0)
    800037d0:	bf99                	j	80003726 <kerneltrap+0x18c>
          myproc()->timeslice = TSTICKSMEDIUM;
    800037d2:	ffffe097          	auipc	ra,0xffffe
    800037d6:	5ea080e7          	jalr	1514(ra) # 80001dbc <myproc>
    800037da:	03200993          	li	s3,50
    800037de:	05352423          	sw	s3,72(a0)
          myproc()->tsticks = TSTICKSMEDIUM;
    800037e2:	ffffe097          	auipc	ra,0xffffe
    800037e6:	5da080e7          	jalr	1498(ra) # 80001dbc <myproc>
    800037ea:	05352023          	sw	s3,64(a0)
          tempsticks = TSTICKSMEDIUM;
    800037ee:	00007797          	auipc	a5,0x7
    800037f2:	8537a523          	sw	s3,-1974(a5) # 8000a038 <tempsticks>
    800037f6:	bf85                	j	80003766 <kerneltrap+0x1cc>
      myproc()->cputime++;
    800037f8:	ffffe097          	auipc	ra,0xffffe
    800037fc:	5c4080e7          	jalr	1476(ra) # 80001dbc <myproc>
    80003800:	7d1c                	ld	a5,56(a0)
    80003802:	0785                	addi	a5,a5,1
    80003804:	fd1c                	sd	a5,56(a0)
    80003806:	bd85                	j	80003676 <kerneltrap+0xdc>

0000000080003808 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003808:	1101                	addi	sp,sp,-32
    8000380a:	ec06                	sd	ra,24(sp)
    8000380c:	e822                	sd	s0,16(sp)
    8000380e:	e426                	sd	s1,8(sp)
    80003810:	1000                	addi	s0,sp,32
    80003812:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80003814:	ffffe097          	auipc	ra,0xffffe
    80003818:	5a8080e7          	jalr	1448(ra) # 80001dbc <myproc>
  switch (n) {
    8000381c:	4795                	li	a5,5
    8000381e:	0497e163          	bltu	a5,s1,80003860 <argraw+0x58>
    80003822:	048a                	slli	s1,s1,0x2
    80003824:	00006717          	auipc	a4,0x6
    80003828:	c8c70713          	addi	a4,a4,-884 # 800094b0 <states.0+0x170>
    8000382c:	94ba                	add	s1,s1,a4
    8000382e:	409c                	lw	a5,0(s1)
    80003830:	97ba                	add	a5,a5,a4
    80003832:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80003834:	7d3c                	ld	a5,120(a0)
    80003836:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003838:	60e2                	ld	ra,24(sp)
    8000383a:	6442                	ld	s0,16(sp)
    8000383c:	64a2                	ld	s1,8(sp)
    8000383e:	6105                	addi	sp,sp,32
    80003840:	8082                	ret
    return p->trapframe->a1;
    80003842:	7d3c                	ld	a5,120(a0)
    80003844:	7fa8                	ld	a0,120(a5)
    80003846:	bfcd                	j	80003838 <argraw+0x30>
    return p->trapframe->a2;
    80003848:	7d3c                	ld	a5,120(a0)
    8000384a:	63c8                	ld	a0,128(a5)
    8000384c:	b7f5                	j	80003838 <argraw+0x30>
    return p->trapframe->a3;
    8000384e:	7d3c                	ld	a5,120(a0)
    80003850:	67c8                	ld	a0,136(a5)
    80003852:	b7dd                	j	80003838 <argraw+0x30>
    return p->trapframe->a4;
    80003854:	7d3c                	ld	a5,120(a0)
    80003856:	6bc8                	ld	a0,144(a5)
    80003858:	b7c5                	j	80003838 <argraw+0x30>
    return p->trapframe->a5;
    8000385a:	7d3c                	ld	a5,120(a0)
    8000385c:	6fc8                	ld	a0,152(a5)
    8000385e:	bfe9                	j	80003838 <argraw+0x30>
  panic("argraw");
    80003860:	00006517          	auipc	a0,0x6
    80003864:	c2850513          	addi	a0,a0,-984 # 80009488 <states.0+0x148>
    80003868:	ffffd097          	auipc	ra,0xffffd
    8000386c:	cd2080e7          	jalr	-814(ra) # 8000053a <panic>

0000000080003870 <fetchaddr>:
{
    80003870:	1101                	addi	sp,sp,-32
    80003872:	ec06                	sd	ra,24(sp)
    80003874:	e822                	sd	s0,16(sp)
    80003876:	e426                	sd	s1,8(sp)
    80003878:	e04a                	sd	s2,0(sp)
    8000387a:	1000                	addi	s0,sp,32
    8000387c:	84aa                	mv	s1,a0
    8000387e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003880:	ffffe097          	auipc	ra,0xffffe
    80003884:	53c080e7          	jalr	1340(ra) # 80001dbc <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80003888:	753c                	ld	a5,104(a0)
    8000388a:	02f4f863          	bgeu	s1,a5,800038ba <fetchaddr+0x4a>
    8000388e:	00848713          	addi	a4,s1,8
    80003892:	02e7e663          	bltu	a5,a4,800038be <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003896:	46a1                	li	a3,8
    80003898:	8626                	mv	a2,s1
    8000389a:	85ca                	mv	a1,s2
    8000389c:	7928                	ld	a0,112(a0)
    8000389e:	ffffe097          	auipc	ra,0xffffe
    800038a2:	f3a080e7          	jalr	-198(ra) # 800017d8 <copyin>
    800038a6:	00a03533          	snez	a0,a0
    800038aa:	40a00533          	neg	a0,a0
}
    800038ae:	60e2                	ld	ra,24(sp)
    800038b0:	6442                	ld	s0,16(sp)
    800038b2:	64a2                	ld	s1,8(sp)
    800038b4:	6902                	ld	s2,0(sp)
    800038b6:	6105                	addi	sp,sp,32
    800038b8:	8082                	ret
    return -1;
    800038ba:	557d                	li	a0,-1
    800038bc:	bfcd                	j	800038ae <fetchaddr+0x3e>
    800038be:	557d                	li	a0,-1
    800038c0:	b7fd                	j	800038ae <fetchaddr+0x3e>

00000000800038c2 <fetchstr>:
{
    800038c2:	7179                	addi	sp,sp,-48
    800038c4:	f406                	sd	ra,40(sp)
    800038c6:	f022                	sd	s0,32(sp)
    800038c8:	ec26                	sd	s1,24(sp)
    800038ca:	e84a                	sd	s2,16(sp)
    800038cc:	e44e                	sd	s3,8(sp)
    800038ce:	1800                	addi	s0,sp,48
    800038d0:	892a                	mv	s2,a0
    800038d2:	84ae                	mv	s1,a1
    800038d4:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800038d6:	ffffe097          	auipc	ra,0xffffe
    800038da:	4e6080e7          	jalr	1254(ra) # 80001dbc <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    800038de:	86ce                	mv	a3,s3
    800038e0:	864a                	mv	a2,s2
    800038e2:	85a6                	mv	a1,s1
    800038e4:	7928                	ld	a0,112(a0)
    800038e6:	ffffe097          	auipc	ra,0xffffe
    800038ea:	f80080e7          	jalr	-128(ra) # 80001866 <copyinstr>
  if(err < 0)
    800038ee:	00054763          	bltz	a0,800038fc <fetchstr+0x3a>
  return strlen(buf);
    800038f2:	8526                	mv	a0,s1
    800038f4:	ffffd097          	auipc	ra,0xffffd
    800038f8:	59c080e7          	jalr	1436(ra) # 80000e90 <strlen>
}
    800038fc:	70a2                	ld	ra,40(sp)
    800038fe:	7402                	ld	s0,32(sp)
    80003900:	64e2                	ld	s1,24(sp)
    80003902:	6942                	ld	s2,16(sp)
    80003904:	69a2                	ld	s3,8(sp)
    80003906:	6145                	addi	sp,sp,48
    80003908:	8082                	ret

000000008000390a <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    8000390a:	1101                	addi	sp,sp,-32
    8000390c:	ec06                	sd	ra,24(sp)
    8000390e:	e822                	sd	s0,16(sp)
    80003910:	e426                	sd	s1,8(sp)
    80003912:	1000                	addi	s0,sp,32
    80003914:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003916:	00000097          	auipc	ra,0x0
    8000391a:	ef2080e7          	jalr	-270(ra) # 80003808 <argraw>
    8000391e:	c088                	sw	a0,0(s1)
  return 0;
}
    80003920:	4501                	li	a0,0
    80003922:	60e2                	ld	ra,24(sp)
    80003924:	6442                	ld	s0,16(sp)
    80003926:	64a2                	ld	s1,8(sp)
    80003928:	6105                	addi	sp,sp,32
    8000392a:	8082                	ret

000000008000392c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    8000392c:	1101                	addi	sp,sp,-32
    8000392e:	ec06                	sd	ra,24(sp)
    80003930:	e822                	sd	s0,16(sp)
    80003932:	e426                	sd	s1,8(sp)
    80003934:	1000                	addi	s0,sp,32
    80003936:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003938:	00000097          	auipc	ra,0x0
    8000393c:	ed0080e7          	jalr	-304(ra) # 80003808 <argraw>
    80003940:	e088                	sd	a0,0(s1)
  return 0;
}
    80003942:	4501                	li	a0,0
    80003944:	60e2                	ld	ra,24(sp)
    80003946:	6442                	ld	s0,16(sp)
    80003948:	64a2                	ld	s1,8(sp)
    8000394a:	6105                	addi	sp,sp,32
    8000394c:	8082                	ret

000000008000394e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000394e:	1101                	addi	sp,sp,-32
    80003950:	ec06                	sd	ra,24(sp)
    80003952:	e822                	sd	s0,16(sp)
    80003954:	e426                	sd	s1,8(sp)
    80003956:	e04a                	sd	s2,0(sp)
    80003958:	1000                	addi	s0,sp,32
    8000395a:	84ae                	mv	s1,a1
    8000395c:	8932                	mv	s2,a2
  *ip = argraw(n);
    8000395e:	00000097          	auipc	ra,0x0
    80003962:	eaa080e7          	jalr	-342(ra) # 80003808 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80003966:	864a                	mv	a2,s2
    80003968:	85a6                	mv	a1,s1
    8000396a:	00000097          	auipc	ra,0x0
    8000396e:	f58080e7          	jalr	-168(ra) # 800038c2 <fetchstr>
}
    80003972:	60e2                	ld	ra,24(sp)
    80003974:	6442                	ld	s0,16(sp)
    80003976:	64a2                	ld	s1,8(sp)
    80003978:	6902                	ld	s2,0(sp)
    8000397a:	6105                	addi	sp,sp,32
    8000397c:	8082                	ret

000000008000397e <syscall>:
[SYS_sem_post] sys_sem_post,
};

void
syscall(void)
{
    8000397e:	1101                	addi	sp,sp,-32
    80003980:	ec06                	sd	ra,24(sp)
    80003982:	e822                	sd	s0,16(sp)
    80003984:	e426                	sd	s1,8(sp)
    80003986:	e04a                	sd	s2,0(sp)
    80003988:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    8000398a:	ffffe097          	auipc	ra,0xffffe
    8000398e:	432080e7          	jalr	1074(ra) # 80001dbc <myproc>
    80003992:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80003994:	07853903          	ld	s2,120(a0)
    80003998:	0a893783          	ld	a5,168(s2)
    8000399c:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800039a0:	37fd                	addiw	a5,a5,-1
    800039a2:	4775                	li	a4,29
    800039a4:	00f76f63          	bltu	a4,a5,800039c2 <syscall+0x44>
    800039a8:	00369713          	slli	a4,a3,0x3
    800039ac:	00006797          	auipc	a5,0x6
    800039b0:	b1c78793          	addi	a5,a5,-1252 # 800094c8 <syscalls>
    800039b4:	97ba                	add	a5,a5,a4
    800039b6:	639c                	ld	a5,0(a5)
    800039b8:	c789                	beqz	a5,800039c2 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    800039ba:	9782                	jalr	a5
    800039bc:	06a93823          	sd	a0,112(s2)
    800039c0:	a839                	j	800039de <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800039c2:	17848613          	addi	a2,s1,376
    800039c6:	588c                	lw	a1,48(s1)
    800039c8:	00006517          	auipc	a0,0x6
    800039cc:	ac850513          	addi	a0,a0,-1336 # 80009490 <states.0+0x150>
    800039d0:	ffffd097          	auipc	ra,0xffffd
    800039d4:	bb4080e7          	jalr	-1100(ra) # 80000584 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800039d8:	7cbc                	ld	a5,120(s1)
    800039da:	577d                	li	a4,-1
    800039dc:	fbb8                	sd	a4,112(a5)
  }
}
    800039de:	60e2                	ld	ra,24(sp)
    800039e0:	6442                	ld	s0,16(sp)
    800039e2:	64a2                	ld	s1,8(sp)
    800039e4:	6902                	ld	s2,0(sp)
    800039e6:	6105                	addi	sp,sp,32
    800039e8:	8082                	ret

00000000800039ea <sys_exit>:
#include "proc.h"


uint64
sys_exit(void)
{
    800039ea:	1101                	addi	sp,sp,-32
    800039ec:	ec06                	sd	ra,24(sp)
    800039ee:	e822                	sd	s0,16(sp)
    800039f0:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    800039f2:	fec40593          	addi	a1,s0,-20
    800039f6:	4501                	li	a0,0
    800039f8:	00000097          	auipc	ra,0x0
    800039fc:	f12080e7          	jalr	-238(ra) # 8000390a <argint>
    return -1;
    80003a00:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003a02:	00054963          	bltz	a0,80003a14 <sys_exit+0x2a>
  exit(n);
    80003a06:	fec42503          	lw	a0,-20(s0)
    80003a0a:	fffff097          	auipc	ra,0xfffff
    80003a0e:	9f8080e7          	jalr	-1544(ra) # 80002402 <exit>
  return 0;  // not reached
    80003a12:	4781                	li	a5,0
}
    80003a14:	853e                	mv	a0,a5
    80003a16:	60e2                	ld	ra,24(sp)
    80003a18:	6442                	ld	s0,16(sp)
    80003a1a:	6105                	addi	sp,sp,32
    80003a1c:	8082                	ret

0000000080003a1e <sys_getpid>:

uint64
sys_getpid(void)
{
    80003a1e:	1141                	addi	sp,sp,-16
    80003a20:	e406                	sd	ra,8(sp)
    80003a22:	e022                	sd	s0,0(sp)
    80003a24:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003a26:	ffffe097          	auipc	ra,0xffffe
    80003a2a:	396080e7          	jalr	918(ra) # 80001dbc <myproc>
}
    80003a2e:	5908                	lw	a0,48(a0)
    80003a30:	60a2                	ld	ra,8(sp)
    80003a32:	6402                	ld	s0,0(sp)
    80003a34:	0141                	addi	sp,sp,16
    80003a36:	8082                	ret

0000000080003a38 <sys_fork>:

uint64
sys_fork(void)
{
    80003a38:	1141                	addi	sp,sp,-16
    80003a3a:	e406                	sd	ra,8(sp)
    80003a3c:	e022                	sd	s0,0(sp)
    80003a3e:	0800                	addi	s0,sp,16
  return fork();
    80003a40:	fffff097          	auipc	ra,0xfffff
    80003a44:	124080e7          	jalr	292(ra) # 80002b64 <fork>
}
    80003a48:	60a2                	ld	ra,8(sp)
    80003a4a:	6402                	ld	s0,0(sp)
    80003a4c:	0141                	addi	sp,sp,16
    80003a4e:	8082                	ret

0000000080003a50 <sys_wait>:

uint64
sys_wait(void)
{
    80003a50:	1101                	addi	sp,sp,-32
    80003a52:	ec06                	sd	ra,24(sp)
    80003a54:	e822                	sd	s0,16(sp)
    80003a56:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003a58:	fe840593          	addi	a1,s0,-24
    80003a5c:	4501                	li	a0,0
    80003a5e:	00000097          	auipc	ra,0x0
    80003a62:	ece080e7          	jalr	-306(ra) # 8000392c <argaddr>
    80003a66:	87aa                	mv	a5,a0
    return -1;
    80003a68:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003a6a:	0007c863          	bltz	a5,80003a7a <sys_wait+0x2a>
  return wait(p);
    80003a6e:	fe843503          	ld	a0,-24(s0)
    80003a72:	fffff097          	auipc	ra,0xfffff
    80003a76:	3c2080e7          	jalr	962(ra) # 80002e34 <wait>
}
    80003a7a:	60e2                	ld	ra,24(sp)
    80003a7c:	6442                	ld	s0,16(sp)
    80003a7e:	6105                	addi	sp,sp,32
    80003a80:	8082                	ret

0000000080003a82 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003a82:	7179                	addi	sp,sp,-48
    80003a84:	f406                	sd	ra,40(sp)
    80003a86:	f022                	sd	s0,32(sp)
    80003a88:	ec26                	sd	s1,24(sp)
    80003a8a:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003a8c:	fdc40593          	addi	a1,s0,-36
    80003a90:	4501                	li	a0,0
    80003a92:	00000097          	auipc	ra,0x0
    80003a96:	e78080e7          	jalr	-392(ra) # 8000390a <argint>
    80003a9a:	87aa                	mv	a5,a0
    return -1;
    80003a9c:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80003a9e:	0207c063          	bltz	a5,80003abe <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80003aa2:	ffffe097          	auipc	ra,0xffffe
    80003aa6:	31a080e7          	jalr	794(ra) # 80001dbc <myproc>
    80003aaa:	5524                	lw	s1,104(a0)
  if(growproc(n) < 0)
    80003aac:	fdc42503          	lw	a0,-36(s0)
    80003ab0:	ffffe097          	auipc	ra,0xffffe
    80003ab4:	4be080e7          	jalr	1214(ra) # 80001f6e <growproc>
    80003ab8:	00054863          	bltz	a0,80003ac8 <sys_sbrk+0x46>
    return -1;
  return addr;
    80003abc:	8526                	mv	a0,s1
}
    80003abe:	70a2                	ld	ra,40(sp)
    80003ac0:	7402                	ld	s0,32(sp)
    80003ac2:	64e2                	ld	s1,24(sp)
    80003ac4:	6145                	addi	sp,sp,48
    80003ac6:	8082                	ret
    return -1;
    80003ac8:	557d                	li	a0,-1
    80003aca:	bfd5                	j	80003abe <sys_sbrk+0x3c>

0000000080003acc <sys_sleep>:

uint64
sys_sleep(void)
{
    80003acc:	7139                	addi	sp,sp,-64
    80003ace:	fc06                	sd	ra,56(sp)
    80003ad0:	f822                	sd	s0,48(sp)
    80003ad2:	f426                	sd	s1,40(sp)
    80003ad4:	f04a                	sd	s2,32(sp)
    80003ad6:	ec4e                	sd	s3,24(sp)
    80003ad8:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003ada:	fcc40593          	addi	a1,s0,-52
    80003ade:	4501                	li	a0,0
    80003ae0:	00000097          	auipc	ra,0x0
    80003ae4:	e2a080e7          	jalr	-470(ra) # 8000390a <argint>
    return -1;
    80003ae8:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003aea:	06054563          	bltz	a0,80003b54 <sys_sleep+0x88>
  acquire(&tickslock);
    80003aee:	00025517          	auipc	a0,0x25
    80003af2:	48a50513          	addi	a0,a0,1162 # 80028f78 <tickslock>
    80003af6:	ffffd097          	auipc	ra,0xffffd
    80003afa:	122080e7          	jalr	290(ra) # 80000c18 <acquire>
  ticks0 = ticks;
    80003afe:	00006917          	auipc	s2,0x6
    80003b02:	53e92903          	lw	s2,1342(s2) # 8000a03c <ticks>
  while(ticks - ticks0 < n){
    80003b06:	fcc42783          	lw	a5,-52(s0)
    80003b0a:	cf85                	beqz	a5,80003b42 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003b0c:	00025997          	auipc	s3,0x25
    80003b10:	46c98993          	addi	s3,s3,1132 # 80028f78 <tickslock>
    80003b14:	00006497          	auipc	s1,0x6
    80003b18:	52848493          	addi	s1,s1,1320 # 8000a03c <ticks>
    if(myproc()->killed){
    80003b1c:	ffffe097          	auipc	ra,0xffffe
    80003b20:	2a0080e7          	jalr	672(ra) # 80001dbc <myproc>
    80003b24:	551c                	lw	a5,40(a0)
    80003b26:	ef9d                	bnez	a5,80003b64 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80003b28:	85ce                	mv	a1,s3
    80003b2a:	8526                	mv	a0,s1
    80003b2c:	ffffe097          	auipc	ra,0xffffe
    80003b30:	6f8080e7          	jalr	1784(ra) # 80002224 <sleep>
  while(ticks - ticks0 < n){
    80003b34:	409c                	lw	a5,0(s1)
    80003b36:	412787bb          	subw	a5,a5,s2
    80003b3a:	fcc42703          	lw	a4,-52(s0)
    80003b3e:	fce7efe3          	bltu	a5,a4,80003b1c <sys_sleep+0x50>
  }
  release(&tickslock);
    80003b42:	00025517          	auipc	a0,0x25
    80003b46:	43650513          	addi	a0,a0,1078 # 80028f78 <tickslock>
    80003b4a:	ffffd097          	auipc	ra,0xffffd
    80003b4e:	182080e7          	jalr	386(ra) # 80000ccc <release>
  return 0;
    80003b52:	4781                	li	a5,0
}
    80003b54:	853e                	mv	a0,a5
    80003b56:	70e2                	ld	ra,56(sp)
    80003b58:	7442                	ld	s0,48(sp)
    80003b5a:	74a2                	ld	s1,40(sp)
    80003b5c:	7902                	ld	s2,32(sp)
    80003b5e:	69e2                	ld	s3,24(sp)
    80003b60:	6121                	addi	sp,sp,64
    80003b62:	8082                	ret
      release(&tickslock);
    80003b64:	00025517          	auipc	a0,0x25
    80003b68:	41450513          	addi	a0,a0,1044 # 80028f78 <tickslock>
    80003b6c:	ffffd097          	auipc	ra,0xffffd
    80003b70:	160080e7          	jalr	352(ra) # 80000ccc <release>
      return -1;
    80003b74:	57fd                	li	a5,-1
    80003b76:	bff9                	j	80003b54 <sys_sleep+0x88>

0000000080003b78 <sys_kill>:

uint64
sys_kill(void)
{
    80003b78:	1101                	addi	sp,sp,-32
    80003b7a:	ec06                	sd	ra,24(sp)
    80003b7c:	e822                	sd	s0,16(sp)
    80003b7e:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80003b80:	fec40593          	addi	a1,s0,-20
    80003b84:	4501                	li	a0,0
    80003b86:	00000097          	auipc	ra,0x0
    80003b8a:	d84080e7          	jalr	-636(ra) # 8000390a <argint>
    80003b8e:	87aa                	mv	a5,a0
    return -1;
    80003b90:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003b92:	0007c863          	bltz	a5,80003ba2 <sys_kill+0x2a>
  return kill(pid);
    80003b96:	fec42503          	lw	a0,-20(s0)
    80003b9a:	fffff097          	auipc	ra,0xfffff
    80003b9e:	93e080e7          	jalr	-1730(ra) # 800024d8 <kill>
}
    80003ba2:	60e2                	ld	ra,24(sp)
    80003ba4:	6442                	ld	s0,16(sp)
    80003ba6:	6105                	addi	sp,sp,32
    80003ba8:	8082                	ret

0000000080003baa <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003baa:	1101                	addi	sp,sp,-32
    80003bac:	ec06                	sd	ra,24(sp)
    80003bae:	e822                	sd	s0,16(sp)
    80003bb0:	e426                	sd	s1,8(sp)
    80003bb2:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003bb4:	00025517          	auipc	a0,0x25
    80003bb8:	3c450513          	addi	a0,a0,964 # 80028f78 <tickslock>
    80003bbc:	ffffd097          	auipc	ra,0xffffd
    80003bc0:	05c080e7          	jalr	92(ra) # 80000c18 <acquire>
  xticks = ticks;
    80003bc4:	00006497          	auipc	s1,0x6
    80003bc8:	4784a483          	lw	s1,1144(s1) # 8000a03c <ticks>
  release(&tickslock);
    80003bcc:	00025517          	auipc	a0,0x25
    80003bd0:	3ac50513          	addi	a0,a0,940 # 80028f78 <tickslock>
    80003bd4:	ffffd097          	auipc	ra,0xffffd
    80003bd8:	0f8080e7          	jalr	248(ra) # 80000ccc <release>
  return xticks;
}
    80003bdc:	02049513          	slli	a0,s1,0x20
    80003be0:	9101                	srli	a0,a0,0x20
    80003be2:	60e2                	ld	ra,24(sp)
    80003be4:	6442                	ld	s0,16(sp)
    80003be6:	64a2                	ld	s1,8(sp)
    80003be8:	6105                	addi	sp,sp,32
    80003bea:	8082                	ret

0000000080003bec <sys_getprocs>:

// return the number of active processes in the system
// fill in user-provided data structure with pid,state,sz,ppid,name
uint64
sys_getprocs(void)
{
    80003bec:	1101                	addi	sp,sp,-32
    80003bee:	ec06                	sd	ra,24(sp)
    80003bf0:	e822                	sd	s0,16(sp)
    80003bf2:	1000                	addi	s0,sp,32
  uint64 addr;  // user pointer to struct pstat

  if (argaddr(0, &addr) < 0)
    80003bf4:	fe840593          	addi	a1,s0,-24
    80003bf8:	4501                	li	a0,0
    80003bfa:	00000097          	auipc	ra,0x0
    80003bfe:	d32080e7          	jalr	-718(ra) # 8000392c <argaddr>
    80003c02:	87aa                	mv	a5,a0
    return -1;
    80003c04:	557d                	li	a0,-1
  if (argaddr(0, &addr) < 0)
    80003c06:	0007c863          	bltz	a5,80003c16 <sys_getprocs+0x2a>
  return(procinfo(addr));
    80003c0a:	fe843503          	ld	a0,-24(s0)
    80003c0e:	fffff097          	auipc	ra,0xfffff
    80003c12:	aa4080e7          	jalr	-1372(ra) # 800026b2 <procinfo>
}
    80003c16:	60e2                	ld	ra,24(sp)
    80003c18:	6442                	ld	s0,16(sp)
    80003c1a:	6105                	addi	sp,sp,32
    80003c1c:	8082                	ret

0000000080003c1e <sys_wait2>:

uint64
sys_wait2(void)
{
    80003c1e:	1101                	addi	sp,sp,-32
    80003c20:	ec06                	sd	ra,24(sp)
    80003c22:	e822                	sd	s0,16(sp)
    80003c24:	1000                	addi	s0,sp,32
  uint64 p1, p2;

  if(argaddr(0, &p1) < 0 || argaddr(1, &p2) < 0)  
    80003c26:	fe840593          	addi	a1,s0,-24
    80003c2a:	4501                	li	a0,0
    80003c2c:	00000097          	auipc	ra,0x0
    80003c30:	d00080e7          	jalr	-768(ra) # 8000392c <argaddr>
    return -1;
    80003c34:	57fd                	li	a5,-1
  if(argaddr(0, &p1) < 0 || argaddr(1, &p2) < 0)  
    80003c36:	02054563          	bltz	a0,80003c60 <sys_wait2+0x42>
    80003c3a:	fe040593          	addi	a1,s0,-32
    80003c3e:	4505                	li	a0,1
    80003c40:	00000097          	auipc	ra,0x0
    80003c44:	cec080e7          	jalr	-788(ra) # 8000392c <argaddr>
    return -1;
    80003c48:	57fd                	li	a5,-1
  if(argaddr(0, &p1) < 0 || argaddr(1, &p2) < 0)  
    80003c4a:	00054b63          	bltz	a0,80003c60 <sys_wait2+0x42>
  return(wait2(p1, p2));
    80003c4e:	fe043583          	ld	a1,-32(s0)
    80003c52:	fe843503          	ld	a0,-24(s0)
    80003c56:	fffff097          	auipc	ra,0xfffff
    80003c5a:	306080e7          	jalr	774(ra) # 80002f5c <wait2>
    80003c5e:	87aa                	mv	a5,a0
}
    80003c60:	853e                	mv	a0,a5
    80003c62:	60e2                	ld	ra,24(sp)
    80003c64:	6442                	ld	s0,16(sp)
    80003c66:	6105                	addi	sp,sp,32
    80003c68:	8082                	ret

0000000080003c6a <sys_freepmem>:

uint64
sys_freepmem()
{
    80003c6a:	1141                	addi	sp,sp,-16
    80003c6c:	e406                	sd	ra,8(sp)
    80003c6e:	e022                	sd	s0,0(sp)
    80003c70:	0800                	addi	s0,sp,16
  return kfreepagecount();
    80003c72:	ffffd097          	auipc	ra,0xffffd
    80003c76:	ece080e7          	jalr	-306(ra) # 80000b40 <kfreepagecount>
}
    80003c7a:	60a2                	ld	ra,8(sp)
    80003c7c:	6402                	ld	s0,0(sp)
    80003c7e:	0141                	addi	sp,sp,16
    80003c80:	8082                	ret

0000000080003c82 <sys_sem_init>:

uint64
sys_sem_init(){
    80003c82:	1141                	addi	sp,sp,-16
    80003c84:	e422                	sd	s0,8(sp)
    80003c86:	0800                	addi	s0,sp,16
  return 1;
}
    80003c88:	4505                	li	a0,1
    80003c8a:	6422                	ld	s0,8(sp)
    80003c8c:	0141                	addi	sp,sp,16
    80003c8e:	8082                	ret

0000000080003c90 <sys_sem_destroy>:

uint64
sys_sem_destroy(){
    80003c90:	1141                	addi	sp,sp,-16
    80003c92:	e422                	sd	s0,8(sp)
    80003c94:	0800                	addi	s0,sp,16
  return 1;
}
    80003c96:	4505                	li	a0,1
    80003c98:	6422                	ld	s0,8(sp)
    80003c9a:	0141                	addi	sp,sp,16
    80003c9c:	8082                	ret

0000000080003c9e <sys_sem_wait>:

uint64
sys_sem_wait(){
    80003c9e:	1141                	addi	sp,sp,-16
    80003ca0:	e422                	sd	s0,8(sp)
    80003ca2:	0800                	addi	s0,sp,16
  return 1;
}
    80003ca4:	4505                	li	a0,1
    80003ca6:	6422                	ld	s0,8(sp)
    80003ca8:	0141                	addi	sp,sp,16
    80003caa:	8082                	ret

0000000080003cac <sys_sem_post>:

uint64
sys_sem_post(){
    80003cac:	1141                	addi	sp,sp,-16
    80003cae:	e422                	sd	s0,8(sp)
    80003cb0:	0800                	addi	s0,sp,16
  return 1;
    80003cb2:	4505                	li	a0,1
    80003cb4:	6422                	ld	s0,8(sp)
    80003cb6:	0141                	addi	sp,sp,16
    80003cb8:	8082                	ret

0000000080003cba <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003cba:	7179                	addi	sp,sp,-48
    80003cbc:	f406                	sd	ra,40(sp)
    80003cbe:	f022                	sd	s0,32(sp)
    80003cc0:	ec26                	sd	s1,24(sp)
    80003cc2:	e84a                	sd	s2,16(sp)
    80003cc4:	e44e                	sd	s3,8(sp)
    80003cc6:	e052                	sd	s4,0(sp)
    80003cc8:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003cca:	00006597          	auipc	a1,0x6
    80003cce:	8f658593          	addi	a1,a1,-1802 # 800095c0 <syscalls+0xf8>
    80003cd2:	00025517          	auipc	a0,0x25
    80003cd6:	2be50513          	addi	a0,a0,702 # 80028f90 <bcache>
    80003cda:	ffffd097          	auipc	ra,0xffffd
    80003cde:	eae080e7          	jalr	-338(ra) # 80000b88 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003ce2:	0002d797          	auipc	a5,0x2d
    80003ce6:	2ae78793          	addi	a5,a5,686 # 80030f90 <bcache+0x8000>
    80003cea:	0002d717          	auipc	a4,0x2d
    80003cee:	50e70713          	addi	a4,a4,1294 # 800311f8 <bcache+0x8268>
    80003cf2:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003cf6:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003cfa:	00025497          	auipc	s1,0x25
    80003cfe:	2ae48493          	addi	s1,s1,686 # 80028fa8 <bcache+0x18>
    b->next = bcache.head.next;
    80003d02:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003d04:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003d06:	00006a17          	auipc	s4,0x6
    80003d0a:	8c2a0a13          	addi	s4,s4,-1854 # 800095c8 <syscalls+0x100>
    b->next = bcache.head.next;
    80003d0e:	2b893783          	ld	a5,696(s2)
    80003d12:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003d14:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003d18:	85d2                	mv	a1,s4
    80003d1a:	01048513          	addi	a0,s1,16
    80003d1e:	00001097          	auipc	ra,0x1
    80003d22:	4c2080e7          	jalr	1218(ra) # 800051e0 <initsleeplock>
    bcache.head.next->prev = b;
    80003d26:	2b893783          	ld	a5,696(s2)
    80003d2a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003d2c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003d30:	45848493          	addi	s1,s1,1112
    80003d34:	fd349de3          	bne	s1,s3,80003d0e <binit+0x54>
  }
}
    80003d38:	70a2                	ld	ra,40(sp)
    80003d3a:	7402                	ld	s0,32(sp)
    80003d3c:	64e2                	ld	s1,24(sp)
    80003d3e:	6942                	ld	s2,16(sp)
    80003d40:	69a2                	ld	s3,8(sp)
    80003d42:	6a02                	ld	s4,0(sp)
    80003d44:	6145                	addi	sp,sp,48
    80003d46:	8082                	ret

0000000080003d48 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003d48:	7179                	addi	sp,sp,-48
    80003d4a:	f406                	sd	ra,40(sp)
    80003d4c:	f022                	sd	s0,32(sp)
    80003d4e:	ec26                	sd	s1,24(sp)
    80003d50:	e84a                	sd	s2,16(sp)
    80003d52:	e44e                	sd	s3,8(sp)
    80003d54:	1800                	addi	s0,sp,48
    80003d56:	892a                	mv	s2,a0
    80003d58:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003d5a:	00025517          	auipc	a0,0x25
    80003d5e:	23650513          	addi	a0,a0,566 # 80028f90 <bcache>
    80003d62:	ffffd097          	auipc	ra,0xffffd
    80003d66:	eb6080e7          	jalr	-330(ra) # 80000c18 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003d6a:	0002d497          	auipc	s1,0x2d
    80003d6e:	4de4b483          	ld	s1,1246(s1) # 80031248 <bcache+0x82b8>
    80003d72:	0002d797          	auipc	a5,0x2d
    80003d76:	48678793          	addi	a5,a5,1158 # 800311f8 <bcache+0x8268>
    80003d7a:	02f48f63          	beq	s1,a5,80003db8 <bread+0x70>
    80003d7e:	873e                	mv	a4,a5
    80003d80:	a021                	j	80003d88 <bread+0x40>
    80003d82:	68a4                	ld	s1,80(s1)
    80003d84:	02e48a63          	beq	s1,a4,80003db8 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003d88:	449c                	lw	a5,8(s1)
    80003d8a:	ff279ce3          	bne	a5,s2,80003d82 <bread+0x3a>
    80003d8e:	44dc                	lw	a5,12(s1)
    80003d90:	ff3799e3          	bne	a5,s3,80003d82 <bread+0x3a>
      b->refcnt++;
    80003d94:	40bc                	lw	a5,64(s1)
    80003d96:	2785                	addiw	a5,a5,1
    80003d98:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003d9a:	00025517          	auipc	a0,0x25
    80003d9e:	1f650513          	addi	a0,a0,502 # 80028f90 <bcache>
    80003da2:	ffffd097          	auipc	ra,0xffffd
    80003da6:	f2a080e7          	jalr	-214(ra) # 80000ccc <release>
      acquiresleep(&b->lock);
    80003daa:	01048513          	addi	a0,s1,16
    80003dae:	00001097          	auipc	ra,0x1
    80003db2:	46c080e7          	jalr	1132(ra) # 8000521a <acquiresleep>
      return b;
    80003db6:	a8b9                	j	80003e14 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003db8:	0002d497          	auipc	s1,0x2d
    80003dbc:	4884b483          	ld	s1,1160(s1) # 80031240 <bcache+0x82b0>
    80003dc0:	0002d797          	auipc	a5,0x2d
    80003dc4:	43878793          	addi	a5,a5,1080 # 800311f8 <bcache+0x8268>
    80003dc8:	00f48863          	beq	s1,a5,80003dd8 <bread+0x90>
    80003dcc:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003dce:	40bc                	lw	a5,64(s1)
    80003dd0:	cf81                	beqz	a5,80003de8 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003dd2:	64a4                	ld	s1,72(s1)
    80003dd4:	fee49de3          	bne	s1,a4,80003dce <bread+0x86>
  panic("bget: no buffers");
    80003dd8:	00005517          	auipc	a0,0x5
    80003ddc:	7f850513          	addi	a0,a0,2040 # 800095d0 <syscalls+0x108>
    80003de0:	ffffc097          	auipc	ra,0xffffc
    80003de4:	75a080e7          	jalr	1882(ra) # 8000053a <panic>
      b->dev = dev;
    80003de8:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003dec:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003df0:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003df4:	4785                	li	a5,1
    80003df6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003df8:	00025517          	auipc	a0,0x25
    80003dfc:	19850513          	addi	a0,a0,408 # 80028f90 <bcache>
    80003e00:	ffffd097          	auipc	ra,0xffffd
    80003e04:	ecc080e7          	jalr	-308(ra) # 80000ccc <release>
      acquiresleep(&b->lock);
    80003e08:	01048513          	addi	a0,s1,16
    80003e0c:	00001097          	auipc	ra,0x1
    80003e10:	40e080e7          	jalr	1038(ra) # 8000521a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003e14:	409c                	lw	a5,0(s1)
    80003e16:	cb89                	beqz	a5,80003e28 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003e18:	8526                	mv	a0,s1
    80003e1a:	70a2                	ld	ra,40(sp)
    80003e1c:	7402                	ld	s0,32(sp)
    80003e1e:	64e2                	ld	s1,24(sp)
    80003e20:	6942                	ld	s2,16(sp)
    80003e22:	69a2                	ld	s3,8(sp)
    80003e24:	6145                	addi	sp,sp,48
    80003e26:	8082                	ret
    virtio_disk_rw(b, 0);
    80003e28:	4581                	li	a1,0
    80003e2a:	8526                	mv	a0,s1
    80003e2c:	00003097          	auipc	ra,0x3
    80003e30:	1f6080e7          	jalr	502(ra) # 80007022 <virtio_disk_rw>
    b->valid = 1;
    80003e34:	4785                	li	a5,1
    80003e36:	c09c                	sw	a5,0(s1)
  return b;
    80003e38:	b7c5                	j	80003e18 <bread+0xd0>

0000000080003e3a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003e3a:	1101                	addi	sp,sp,-32
    80003e3c:	ec06                	sd	ra,24(sp)
    80003e3e:	e822                	sd	s0,16(sp)
    80003e40:	e426                	sd	s1,8(sp)
    80003e42:	1000                	addi	s0,sp,32
    80003e44:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003e46:	0541                	addi	a0,a0,16
    80003e48:	00001097          	auipc	ra,0x1
    80003e4c:	46c080e7          	jalr	1132(ra) # 800052b4 <holdingsleep>
    80003e50:	cd01                	beqz	a0,80003e68 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003e52:	4585                	li	a1,1
    80003e54:	8526                	mv	a0,s1
    80003e56:	00003097          	auipc	ra,0x3
    80003e5a:	1cc080e7          	jalr	460(ra) # 80007022 <virtio_disk_rw>
}
    80003e5e:	60e2                	ld	ra,24(sp)
    80003e60:	6442                	ld	s0,16(sp)
    80003e62:	64a2                	ld	s1,8(sp)
    80003e64:	6105                	addi	sp,sp,32
    80003e66:	8082                	ret
    panic("bwrite");
    80003e68:	00005517          	auipc	a0,0x5
    80003e6c:	78050513          	addi	a0,a0,1920 # 800095e8 <syscalls+0x120>
    80003e70:	ffffc097          	auipc	ra,0xffffc
    80003e74:	6ca080e7          	jalr	1738(ra) # 8000053a <panic>

0000000080003e78 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003e78:	1101                	addi	sp,sp,-32
    80003e7a:	ec06                	sd	ra,24(sp)
    80003e7c:	e822                	sd	s0,16(sp)
    80003e7e:	e426                	sd	s1,8(sp)
    80003e80:	e04a                	sd	s2,0(sp)
    80003e82:	1000                	addi	s0,sp,32
    80003e84:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003e86:	01050913          	addi	s2,a0,16
    80003e8a:	854a                	mv	a0,s2
    80003e8c:	00001097          	auipc	ra,0x1
    80003e90:	428080e7          	jalr	1064(ra) # 800052b4 <holdingsleep>
    80003e94:	c92d                	beqz	a0,80003f06 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003e96:	854a                	mv	a0,s2
    80003e98:	00001097          	auipc	ra,0x1
    80003e9c:	3d8080e7          	jalr	984(ra) # 80005270 <releasesleep>

  acquire(&bcache.lock);
    80003ea0:	00025517          	auipc	a0,0x25
    80003ea4:	0f050513          	addi	a0,a0,240 # 80028f90 <bcache>
    80003ea8:	ffffd097          	auipc	ra,0xffffd
    80003eac:	d70080e7          	jalr	-656(ra) # 80000c18 <acquire>
  b->refcnt--;
    80003eb0:	40bc                	lw	a5,64(s1)
    80003eb2:	37fd                	addiw	a5,a5,-1
    80003eb4:	0007871b          	sext.w	a4,a5
    80003eb8:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003eba:	eb05                	bnez	a4,80003eea <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003ebc:	68bc                	ld	a5,80(s1)
    80003ebe:	64b8                	ld	a4,72(s1)
    80003ec0:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003ec2:	64bc                	ld	a5,72(s1)
    80003ec4:	68b8                	ld	a4,80(s1)
    80003ec6:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003ec8:	0002d797          	auipc	a5,0x2d
    80003ecc:	0c878793          	addi	a5,a5,200 # 80030f90 <bcache+0x8000>
    80003ed0:	2b87b703          	ld	a4,696(a5)
    80003ed4:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003ed6:	0002d717          	auipc	a4,0x2d
    80003eda:	32270713          	addi	a4,a4,802 # 800311f8 <bcache+0x8268>
    80003ede:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003ee0:	2b87b703          	ld	a4,696(a5)
    80003ee4:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003ee6:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003eea:	00025517          	auipc	a0,0x25
    80003eee:	0a650513          	addi	a0,a0,166 # 80028f90 <bcache>
    80003ef2:	ffffd097          	auipc	ra,0xffffd
    80003ef6:	dda080e7          	jalr	-550(ra) # 80000ccc <release>
}
    80003efa:	60e2                	ld	ra,24(sp)
    80003efc:	6442                	ld	s0,16(sp)
    80003efe:	64a2                	ld	s1,8(sp)
    80003f00:	6902                	ld	s2,0(sp)
    80003f02:	6105                	addi	sp,sp,32
    80003f04:	8082                	ret
    panic("brelse");
    80003f06:	00005517          	auipc	a0,0x5
    80003f0a:	6ea50513          	addi	a0,a0,1770 # 800095f0 <syscalls+0x128>
    80003f0e:	ffffc097          	auipc	ra,0xffffc
    80003f12:	62c080e7          	jalr	1580(ra) # 8000053a <panic>

0000000080003f16 <bpin>:

void
bpin(struct buf *b) {
    80003f16:	1101                	addi	sp,sp,-32
    80003f18:	ec06                	sd	ra,24(sp)
    80003f1a:	e822                	sd	s0,16(sp)
    80003f1c:	e426                	sd	s1,8(sp)
    80003f1e:	1000                	addi	s0,sp,32
    80003f20:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003f22:	00025517          	auipc	a0,0x25
    80003f26:	06e50513          	addi	a0,a0,110 # 80028f90 <bcache>
    80003f2a:	ffffd097          	auipc	ra,0xffffd
    80003f2e:	cee080e7          	jalr	-786(ra) # 80000c18 <acquire>
  b->refcnt++;
    80003f32:	40bc                	lw	a5,64(s1)
    80003f34:	2785                	addiw	a5,a5,1
    80003f36:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003f38:	00025517          	auipc	a0,0x25
    80003f3c:	05850513          	addi	a0,a0,88 # 80028f90 <bcache>
    80003f40:	ffffd097          	auipc	ra,0xffffd
    80003f44:	d8c080e7          	jalr	-628(ra) # 80000ccc <release>
}
    80003f48:	60e2                	ld	ra,24(sp)
    80003f4a:	6442                	ld	s0,16(sp)
    80003f4c:	64a2                	ld	s1,8(sp)
    80003f4e:	6105                	addi	sp,sp,32
    80003f50:	8082                	ret

0000000080003f52 <bunpin>:

void
bunpin(struct buf *b) {
    80003f52:	1101                	addi	sp,sp,-32
    80003f54:	ec06                	sd	ra,24(sp)
    80003f56:	e822                	sd	s0,16(sp)
    80003f58:	e426                	sd	s1,8(sp)
    80003f5a:	1000                	addi	s0,sp,32
    80003f5c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003f5e:	00025517          	auipc	a0,0x25
    80003f62:	03250513          	addi	a0,a0,50 # 80028f90 <bcache>
    80003f66:	ffffd097          	auipc	ra,0xffffd
    80003f6a:	cb2080e7          	jalr	-846(ra) # 80000c18 <acquire>
  b->refcnt--;
    80003f6e:	40bc                	lw	a5,64(s1)
    80003f70:	37fd                	addiw	a5,a5,-1
    80003f72:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003f74:	00025517          	auipc	a0,0x25
    80003f78:	01c50513          	addi	a0,a0,28 # 80028f90 <bcache>
    80003f7c:	ffffd097          	auipc	ra,0xffffd
    80003f80:	d50080e7          	jalr	-688(ra) # 80000ccc <release>
}
    80003f84:	60e2                	ld	ra,24(sp)
    80003f86:	6442                	ld	s0,16(sp)
    80003f88:	64a2                	ld	s1,8(sp)
    80003f8a:	6105                	addi	sp,sp,32
    80003f8c:	8082                	ret

0000000080003f8e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003f8e:	1101                	addi	sp,sp,-32
    80003f90:	ec06                	sd	ra,24(sp)
    80003f92:	e822                	sd	s0,16(sp)
    80003f94:	e426                	sd	s1,8(sp)
    80003f96:	e04a                	sd	s2,0(sp)
    80003f98:	1000                	addi	s0,sp,32
    80003f9a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003f9c:	00d5d59b          	srliw	a1,a1,0xd
    80003fa0:	0002d797          	auipc	a5,0x2d
    80003fa4:	6cc7a783          	lw	a5,1740(a5) # 8003166c <sb+0x1c>
    80003fa8:	9dbd                	addw	a1,a1,a5
    80003faa:	00000097          	auipc	ra,0x0
    80003fae:	d9e080e7          	jalr	-610(ra) # 80003d48 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003fb2:	0074f713          	andi	a4,s1,7
    80003fb6:	4785                	li	a5,1
    80003fb8:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003fbc:	14ce                	slli	s1,s1,0x33
    80003fbe:	90d9                	srli	s1,s1,0x36
    80003fc0:	00950733          	add	a4,a0,s1
    80003fc4:	05874703          	lbu	a4,88(a4)
    80003fc8:	00e7f6b3          	and	a3,a5,a4
    80003fcc:	c69d                	beqz	a3,80003ffa <bfree+0x6c>
    80003fce:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003fd0:	94aa                	add	s1,s1,a0
    80003fd2:	fff7c793          	not	a5,a5
    80003fd6:	8f7d                	and	a4,a4,a5
    80003fd8:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003fdc:	00001097          	auipc	ra,0x1
    80003fe0:	120080e7          	jalr	288(ra) # 800050fc <log_write>
  brelse(bp);
    80003fe4:	854a                	mv	a0,s2
    80003fe6:	00000097          	auipc	ra,0x0
    80003fea:	e92080e7          	jalr	-366(ra) # 80003e78 <brelse>
}
    80003fee:	60e2                	ld	ra,24(sp)
    80003ff0:	6442                	ld	s0,16(sp)
    80003ff2:	64a2                	ld	s1,8(sp)
    80003ff4:	6902                	ld	s2,0(sp)
    80003ff6:	6105                	addi	sp,sp,32
    80003ff8:	8082                	ret
    panic("freeing free block");
    80003ffa:	00005517          	auipc	a0,0x5
    80003ffe:	5fe50513          	addi	a0,a0,1534 # 800095f8 <syscalls+0x130>
    80004002:	ffffc097          	auipc	ra,0xffffc
    80004006:	538080e7          	jalr	1336(ra) # 8000053a <panic>

000000008000400a <balloc>:
{
    8000400a:	711d                	addi	sp,sp,-96
    8000400c:	ec86                	sd	ra,88(sp)
    8000400e:	e8a2                	sd	s0,80(sp)
    80004010:	e4a6                	sd	s1,72(sp)
    80004012:	e0ca                	sd	s2,64(sp)
    80004014:	fc4e                	sd	s3,56(sp)
    80004016:	f852                	sd	s4,48(sp)
    80004018:	f456                	sd	s5,40(sp)
    8000401a:	f05a                	sd	s6,32(sp)
    8000401c:	ec5e                	sd	s7,24(sp)
    8000401e:	e862                	sd	s8,16(sp)
    80004020:	e466                	sd	s9,8(sp)
    80004022:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80004024:	0002d797          	auipc	a5,0x2d
    80004028:	6307a783          	lw	a5,1584(a5) # 80031654 <sb+0x4>
    8000402c:	cbc1                	beqz	a5,800040bc <balloc+0xb2>
    8000402e:	8baa                	mv	s7,a0
    80004030:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80004032:	0002db17          	auipc	s6,0x2d
    80004036:	61eb0b13          	addi	s6,s6,1566 # 80031650 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000403a:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000403c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000403e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80004040:	6c89                	lui	s9,0x2
    80004042:	a831                	j	8000405e <balloc+0x54>
    brelse(bp);
    80004044:	854a                	mv	a0,s2
    80004046:	00000097          	auipc	ra,0x0
    8000404a:	e32080e7          	jalr	-462(ra) # 80003e78 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000404e:	015c87bb          	addw	a5,s9,s5
    80004052:	00078a9b          	sext.w	s5,a5
    80004056:	004b2703          	lw	a4,4(s6)
    8000405a:	06eaf163          	bgeu	s5,a4,800040bc <balloc+0xb2>
    bp = bread(dev, BBLOCK(b, sb));
    8000405e:	41fad79b          	sraiw	a5,s5,0x1f
    80004062:	0137d79b          	srliw	a5,a5,0x13
    80004066:	015787bb          	addw	a5,a5,s5
    8000406a:	40d7d79b          	sraiw	a5,a5,0xd
    8000406e:	01cb2583          	lw	a1,28(s6)
    80004072:	9dbd                	addw	a1,a1,a5
    80004074:	855e                	mv	a0,s7
    80004076:	00000097          	auipc	ra,0x0
    8000407a:	cd2080e7          	jalr	-814(ra) # 80003d48 <bread>
    8000407e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004080:	004b2503          	lw	a0,4(s6)
    80004084:	000a849b          	sext.w	s1,s5
    80004088:	8762                	mv	a4,s8
    8000408a:	faa4fde3          	bgeu	s1,a0,80004044 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000408e:	00777693          	andi	a3,a4,7
    80004092:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80004096:	41f7579b          	sraiw	a5,a4,0x1f
    8000409a:	01d7d79b          	srliw	a5,a5,0x1d
    8000409e:	9fb9                	addw	a5,a5,a4
    800040a0:	4037d79b          	sraiw	a5,a5,0x3
    800040a4:	00f90633          	add	a2,s2,a5
    800040a8:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    800040ac:	00c6f5b3          	and	a1,a3,a2
    800040b0:	cd91                	beqz	a1,800040cc <balloc+0xc2>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800040b2:	2705                	addiw	a4,a4,1
    800040b4:	2485                	addiw	s1,s1,1
    800040b6:	fd471ae3          	bne	a4,s4,8000408a <balloc+0x80>
    800040ba:	b769                	j	80004044 <balloc+0x3a>
  panic("balloc: out of blocks");
    800040bc:	00005517          	auipc	a0,0x5
    800040c0:	55450513          	addi	a0,a0,1364 # 80009610 <syscalls+0x148>
    800040c4:	ffffc097          	auipc	ra,0xffffc
    800040c8:	476080e7          	jalr	1142(ra) # 8000053a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800040cc:	97ca                	add	a5,a5,s2
    800040ce:	8e55                	or	a2,a2,a3
    800040d0:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800040d4:	854a                	mv	a0,s2
    800040d6:	00001097          	auipc	ra,0x1
    800040da:	026080e7          	jalr	38(ra) # 800050fc <log_write>
        brelse(bp);
    800040de:	854a                	mv	a0,s2
    800040e0:	00000097          	auipc	ra,0x0
    800040e4:	d98080e7          	jalr	-616(ra) # 80003e78 <brelse>
  bp = bread(dev, bno);
    800040e8:	85a6                	mv	a1,s1
    800040ea:	855e                	mv	a0,s7
    800040ec:	00000097          	auipc	ra,0x0
    800040f0:	c5c080e7          	jalr	-932(ra) # 80003d48 <bread>
    800040f4:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800040f6:	40000613          	li	a2,1024
    800040fa:	4581                	li	a1,0
    800040fc:	05850513          	addi	a0,a0,88
    80004100:	ffffd097          	auipc	ra,0xffffd
    80004104:	c14080e7          	jalr	-1004(ra) # 80000d14 <memset>
  log_write(bp);
    80004108:	854a                	mv	a0,s2
    8000410a:	00001097          	auipc	ra,0x1
    8000410e:	ff2080e7          	jalr	-14(ra) # 800050fc <log_write>
  brelse(bp);
    80004112:	854a                	mv	a0,s2
    80004114:	00000097          	auipc	ra,0x0
    80004118:	d64080e7          	jalr	-668(ra) # 80003e78 <brelse>
}
    8000411c:	8526                	mv	a0,s1
    8000411e:	60e6                	ld	ra,88(sp)
    80004120:	6446                	ld	s0,80(sp)
    80004122:	64a6                	ld	s1,72(sp)
    80004124:	6906                	ld	s2,64(sp)
    80004126:	79e2                	ld	s3,56(sp)
    80004128:	7a42                	ld	s4,48(sp)
    8000412a:	7aa2                	ld	s5,40(sp)
    8000412c:	7b02                	ld	s6,32(sp)
    8000412e:	6be2                	ld	s7,24(sp)
    80004130:	6c42                	ld	s8,16(sp)
    80004132:	6ca2                	ld	s9,8(sp)
    80004134:	6125                	addi	sp,sp,96
    80004136:	8082                	ret

0000000080004138 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80004138:	7179                	addi	sp,sp,-48
    8000413a:	f406                	sd	ra,40(sp)
    8000413c:	f022                	sd	s0,32(sp)
    8000413e:	ec26                	sd	s1,24(sp)
    80004140:	e84a                	sd	s2,16(sp)
    80004142:	e44e                	sd	s3,8(sp)
    80004144:	e052                	sd	s4,0(sp)
    80004146:	1800                	addi	s0,sp,48
    80004148:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000414a:	47ad                	li	a5,11
    8000414c:	04b7fe63          	bgeu	a5,a1,800041a8 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80004150:	ff45849b          	addiw	s1,a1,-12
    80004154:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80004158:	0ff00793          	li	a5,255
    8000415c:	0ae7e463          	bltu	a5,a4,80004204 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80004160:	08052583          	lw	a1,128(a0)
    80004164:	c5b5                	beqz	a1,800041d0 <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80004166:	00092503          	lw	a0,0(s2)
    8000416a:	00000097          	auipc	ra,0x0
    8000416e:	bde080e7          	jalr	-1058(ra) # 80003d48 <bread>
    80004172:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80004174:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80004178:	02049713          	slli	a4,s1,0x20
    8000417c:	01e75593          	srli	a1,a4,0x1e
    80004180:	00b784b3          	add	s1,a5,a1
    80004184:	0004a983          	lw	s3,0(s1)
    80004188:	04098e63          	beqz	s3,800041e4 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    8000418c:	8552                	mv	a0,s4
    8000418e:	00000097          	auipc	ra,0x0
    80004192:	cea080e7          	jalr	-790(ra) # 80003e78 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80004196:	854e                	mv	a0,s3
    80004198:	70a2                	ld	ra,40(sp)
    8000419a:	7402                	ld	s0,32(sp)
    8000419c:	64e2                	ld	s1,24(sp)
    8000419e:	6942                	ld	s2,16(sp)
    800041a0:	69a2                	ld	s3,8(sp)
    800041a2:	6a02                	ld	s4,0(sp)
    800041a4:	6145                	addi	sp,sp,48
    800041a6:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800041a8:	02059793          	slli	a5,a1,0x20
    800041ac:	01e7d593          	srli	a1,a5,0x1e
    800041b0:	00b504b3          	add	s1,a0,a1
    800041b4:	0504a983          	lw	s3,80(s1)
    800041b8:	fc099fe3          	bnez	s3,80004196 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800041bc:	4108                	lw	a0,0(a0)
    800041be:	00000097          	auipc	ra,0x0
    800041c2:	e4c080e7          	jalr	-436(ra) # 8000400a <balloc>
    800041c6:	0005099b          	sext.w	s3,a0
    800041ca:	0534a823          	sw	s3,80(s1)
    800041ce:	b7e1                	j	80004196 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800041d0:	4108                	lw	a0,0(a0)
    800041d2:	00000097          	auipc	ra,0x0
    800041d6:	e38080e7          	jalr	-456(ra) # 8000400a <balloc>
    800041da:	0005059b          	sext.w	a1,a0
    800041de:	08b92023          	sw	a1,128(s2)
    800041e2:	b751                	j	80004166 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800041e4:	00092503          	lw	a0,0(s2)
    800041e8:	00000097          	auipc	ra,0x0
    800041ec:	e22080e7          	jalr	-478(ra) # 8000400a <balloc>
    800041f0:	0005099b          	sext.w	s3,a0
    800041f4:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800041f8:	8552                	mv	a0,s4
    800041fa:	00001097          	auipc	ra,0x1
    800041fe:	f02080e7          	jalr	-254(ra) # 800050fc <log_write>
    80004202:	b769                	j	8000418c <bmap+0x54>
  panic("bmap: out of range");
    80004204:	00005517          	auipc	a0,0x5
    80004208:	42450513          	addi	a0,a0,1060 # 80009628 <syscalls+0x160>
    8000420c:	ffffc097          	auipc	ra,0xffffc
    80004210:	32e080e7          	jalr	814(ra) # 8000053a <panic>

0000000080004214 <iget>:
{
    80004214:	7179                	addi	sp,sp,-48
    80004216:	f406                	sd	ra,40(sp)
    80004218:	f022                	sd	s0,32(sp)
    8000421a:	ec26                	sd	s1,24(sp)
    8000421c:	e84a                	sd	s2,16(sp)
    8000421e:	e44e                	sd	s3,8(sp)
    80004220:	e052                	sd	s4,0(sp)
    80004222:	1800                	addi	s0,sp,48
    80004224:	89aa                	mv	s3,a0
    80004226:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80004228:	0002d517          	auipc	a0,0x2d
    8000422c:	44850513          	addi	a0,a0,1096 # 80031670 <itable>
    80004230:	ffffd097          	auipc	ra,0xffffd
    80004234:	9e8080e7          	jalr	-1560(ra) # 80000c18 <acquire>
  empty = 0;
    80004238:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000423a:	0002d497          	auipc	s1,0x2d
    8000423e:	44e48493          	addi	s1,s1,1102 # 80031688 <itable+0x18>
    80004242:	0002f697          	auipc	a3,0x2f
    80004246:	ed668693          	addi	a3,a3,-298 # 80033118 <log>
    8000424a:	a039                	j	80004258 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000424c:	02090b63          	beqz	s2,80004282 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80004250:	08848493          	addi	s1,s1,136
    80004254:	02d48a63          	beq	s1,a3,80004288 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80004258:	449c                	lw	a5,8(s1)
    8000425a:	fef059e3          	blez	a5,8000424c <iget+0x38>
    8000425e:	4098                	lw	a4,0(s1)
    80004260:	ff3716e3          	bne	a4,s3,8000424c <iget+0x38>
    80004264:	40d8                	lw	a4,4(s1)
    80004266:	ff4713e3          	bne	a4,s4,8000424c <iget+0x38>
      ip->ref++;
    8000426a:	2785                	addiw	a5,a5,1
    8000426c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000426e:	0002d517          	auipc	a0,0x2d
    80004272:	40250513          	addi	a0,a0,1026 # 80031670 <itable>
    80004276:	ffffd097          	auipc	ra,0xffffd
    8000427a:	a56080e7          	jalr	-1450(ra) # 80000ccc <release>
      return ip;
    8000427e:	8926                	mv	s2,s1
    80004280:	a03d                	j	800042ae <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80004282:	f7f9                	bnez	a5,80004250 <iget+0x3c>
    80004284:	8926                	mv	s2,s1
    80004286:	b7e9                	j	80004250 <iget+0x3c>
  if(empty == 0)
    80004288:	02090c63          	beqz	s2,800042c0 <iget+0xac>
  ip->dev = dev;
    8000428c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80004290:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80004294:	4785                	li	a5,1
    80004296:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000429a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000429e:	0002d517          	auipc	a0,0x2d
    800042a2:	3d250513          	addi	a0,a0,978 # 80031670 <itable>
    800042a6:	ffffd097          	auipc	ra,0xffffd
    800042aa:	a26080e7          	jalr	-1498(ra) # 80000ccc <release>
}
    800042ae:	854a                	mv	a0,s2
    800042b0:	70a2                	ld	ra,40(sp)
    800042b2:	7402                	ld	s0,32(sp)
    800042b4:	64e2                	ld	s1,24(sp)
    800042b6:	6942                	ld	s2,16(sp)
    800042b8:	69a2                	ld	s3,8(sp)
    800042ba:	6a02                	ld	s4,0(sp)
    800042bc:	6145                	addi	sp,sp,48
    800042be:	8082                	ret
    panic("iget: no inodes");
    800042c0:	00005517          	auipc	a0,0x5
    800042c4:	38050513          	addi	a0,a0,896 # 80009640 <syscalls+0x178>
    800042c8:	ffffc097          	auipc	ra,0xffffc
    800042cc:	272080e7          	jalr	626(ra) # 8000053a <panic>

00000000800042d0 <fsinit>:
fsinit(int dev) {
    800042d0:	7179                	addi	sp,sp,-48
    800042d2:	f406                	sd	ra,40(sp)
    800042d4:	f022                	sd	s0,32(sp)
    800042d6:	ec26                	sd	s1,24(sp)
    800042d8:	e84a                	sd	s2,16(sp)
    800042da:	e44e                	sd	s3,8(sp)
    800042dc:	1800                	addi	s0,sp,48
    800042de:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800042e0:	4585                	li	a1,1
    800042e2:	00000097          	auipc	ra,0x0
    800042e6:	a66080e7          	jalr	-1434(ra) # 80003d48 <bread>
    800042ea:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800042ec:	0002d997          	auipc	s3,0x2d
    800042f0:	36498993          	addi	s3,s3,868 # 80031650 <sb>
    800042f4:	02000613          	li	a2,32
    800042f8:	05850593          	addi	a1,a0,88
    800042fc:	854e                	mv	a0,s3
    800042fe:	ffffd097          	auipc	ra,0xffffd
    80004302:	a72080e7          	jalr	-1422(ra) # 80000d70 <memmove>
  brelse(bp);
    80004306:	8526                	mv	a0,s1
    80004308:	00000097          	auipc	ra,0x0
    8000430c:	b70080e7          	jalr	-1168(ra) # 80003e78 <brelse>
  if(sb.magic != FSMAGIC)
    80004310:	0009a703          	lw	a4,0(s3)
    80004314:	102037b7          	lui	a5,0x10203
    80004318:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000431c:	02f71263          	bne	a4,a5,80004340 <fsinit+0x70>
  initlog(dev, &sb);
    80004320:	0002d597          	auipc	a1,0x2d
    80004324:	33058593          	addi	a1,a1,816 # 80031650 <sb>
    80004328:	854a                	mv	a0,s2
    8000432a:	00001097          	auipc	ra,0x1
    8000432e:	b56080e7          	jalr	-1194(ra) # 80004e80 <initlog>
}
    80004332:	70a2                	ld	ra,40(sp)
    80004334:	7402                	ld	s0,32(sp)
    80004336:	64e2                	ld	s1,24(sp)
    80004338:	6942                	ld	s2,16(sp)
    8000433a:	69a2                	ld	s3,8(sp)
    8000433c:	6145                	addi	sp,sp,48
    8000433e:	8082                	ret
    panic("invalid file system");
    80004340:	00005517          	auipc	a0,0x5
    80004344:	31050513          	addi	a0,a0,784 # 80009650 <syscalls+0x188>
    80004348:	ffffc097          	auipc	ra,0xffffc
    8000434c:	1f2080e7          	jalr	498(ra) # 8000053a <panic>

0000000080004350 <iinit>:
{
    80004350:	7179                	addi	sp,sp,-48
    80004352:	f406                	sd	ra,40(sp)
    80004354:	f022                	sd	s0,32(sp)
    80004356:	ec26                	sd	s1,24(sp)
    80004358:	e84a                	sd	s2,16(sp)
    8000435a:	e44e                	sd	s3,8(sp)
    8000435c:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000435e:	00005597          	auipc	a1,0x5
    80004362:	30a58593          	addi	a1,a1,778 # 80009668 <syscalls+0x1a0>
    80004366:	0002d517          	auipc	a0,0x2d
    8000436a:	30a50513          	addi	a0,a0,778 # 80031670 <itable>
    8000436e:	ffffd097          	auipc	ra,0xffffd
    80004372:	81a080e7          	jalr	-2022(ra) # 80000b88 <initlock>
  for(i = 0; i < NINODE; i++) {
    80004376:	0002d497          	auipc	s1,0x2d
    8000437a:	32248493          	addi	s1,s1,802 # 80031698 <itable+0x28>
    8000437e:	0002f997          	auipc	s3,0x2f
    80004382:	daa98993          	addi	s3,s3,-598 # 80033128 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80004386:	00005917          	auipc	s2,0x5
    8000438a:	2ea90913          	addi	s2,s2,746 # 80009670 <syscalls+0x1a8>
    8000438e:	85ca                	mv	a1,s2
    80004390:	8526                	mv	a0,s1
    80004392:	00001097          	auipc	ra,0x1
    80004396:	e4e080e7          	jalr	-434(ra) # 800051e0 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000439a:	08848493          	addi	s1,s1,136
    8000439e:	ff3498e3          	bne	s1,s3,8000438e <iinit+0x3e>
}
    800043a2:	70a2                	ld	ra,40(sp)
    800043a4:	7402                	ld	s0,32(sp)
    800043a6:	64e2                	ld	s1,24(sp)
    800043a8:	6942                	ld	s2,16(sp)
    800043aa:	69a2                	ld	s3,8(sp)
    800043ac:	6145                	addi	sp,sp,48
    800043ae:	8082                	ret

00000000800043b0 <ialloc>:
{
    800043b0:	715d                	addi	sp,sp,-80
    800043b2:	e486                	sd	ra,72(sp)
    800043b4:	e0a2                	sd	s0,64(sp)
    800043b6:	fc26                	sd	s1,56(sp)
    800043b8:	f84a                	sd	s2,48(sp)
    800043ba:	f44e                	sd	s3,40(sp)
    800043bc:	f052                	sd	s4,32(sp)
    800043be:	ec56                	sd	s5,24(sp)
    800043c0:	e85a                	sd	s6,16(sp)
    800043c2:	e45e                	sd	s7,8(sp)
    800043c4:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800043c6:	0002d717          	auipc	a4,0x2d
    800043ca:	29672703          	lw	a4,662(a4) # 8003165c <sb+0xc>
    800043ce:	4785                	li	a5,1
    800043d0:	04e7fa63          	bgeu	a5,a4,80004424 <ialloc+0x74>
    800043d4:	8aaa                	mv	s5,a0
    800043d6:	8bae                	mv	s7,a1
    800043d8:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800043da:	0002da17          	auipc	s4,0x2d
    800043de:	276a0a13          	addi	s4,s4,630 # 80031650 <sb>
    800043e2:	00048b1b          	sext.w	s6,s1
    800043e6:	0044d593          	srli	a1,s1,0x4
    800043ea:	018a2783          	lw	a5,24(s4)
    800043ee:	9dbd                	addw	a1,a1,a5
    800043f0:	8556                	mv	a0,s5
    800043f2:	00000097          	auipc	ra,0x0
    800043f6:	956080e7          	jalr	-1706(ra) # 80003d48 <bread>
    800043fa:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800043fc:	05850993          	addi	s3,a0,88
    80004400:	00f4f793          	andi	a5,s1,15
    80004404:	079a                	slli	a5,a5,0x6
    80004406:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80004408:	00099783          	lh	a5,0(s3)
    8000440c:	c785                	beqz	a5,80004434 <ialloc+0x84>
    brelse(bp);
    8000440e:	00000097          	auipc	ra,0x0
    80004412:	a6a080e7          	jalr	-1430(ra) # 80003e78 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80004416:	0485                	addi	s1,s1,1
    80004418:	00ca2703          	lw	a4,12(s4)
    8000441c:	0004879b          	sext.w	a5,s1
    80004420:	fce7e1e3          	bltu	a5,a4,800043e2 <ialloc+0x32>
  panic("ialloc: no inodes");
    80004424:	00005517          	auipc	a0,0x5
    80004428:	25450513          	addi	a0,a0,596 # 80009678 <syscalls+0x1b0>
    8000442c:	ffffc097          	auipc	ra,0xffffc
    80004430:	10e080e7          	jalr	270(ra) # 8000053a <panic>
      memset(dip, 0, sizeof(*dip));
    80004434:	04000613          	li	a2,64
    80004438:	4581                	li	a1,0
    8000443a:	854e                	mv	a0,s3
    8000443c:	ffffd097          	auipc	ra,0xffffd
    80004440:	8d8080e7          	jalr	-1832(ra) # 80000d14 <memset>
      dip->type = type;
    80004444:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80004448:	854a                	mv	a0,s2
    8000444a:	00001097          	auipc	ra,0x1
    8000444e:	cb2080e7          	jalr	-846(ra) # 800050fc <log_write>
      brelse(bp);
    80004452:	854a                	mv	a0,s2
    80004454:	00000097          	auipc	ra,0x0
    80004458:	a24080e7          	jalr	-1500(ra) # 80003e78 <brelse>
      return iget(dev, inum);
    8000445c:	85da                	mv	a1,s6
    8000445e:	8556                	mv	a0,s5
    80004460:	00000097          	auipc	ra,0x0
    80004464:	db4080e7          	jalr	-588(ra) # 80004214 <iget>
}
    80004468:	60a6                	ld	ra,72(sp)
    8000446a:	6406                	ld	s0,64(sp)
    8000446c:	74e2                	ld	s1,56(sp)
    8000446e:	7942                	ld	s2,48(sp)
    80004470:	79a2                	ld	s3,40(sp)
    80004472:	7a02                	ld	s4,32(sp)
    80004474:	6ae2                	ld	s5,24(sp)
    80004476:	6b42                	ld	s6,16(sp)
    80004478:	6ba2                	ld	s7,8(sp)
    8000447a:	6161                	addi	sp,sp,80
    8000447c:	8082                	ret

000000008000447e <iupdate>:
{
    8000447e:	1101                	addi	sp,sp,-32
    80004480:	ec06                	sd	ra,24(sp)
    80004482:	e822                	sd	s0,16(sp)
    80004484:	e426                	sd	s1,8(sp)
    80004486:	e04a                	sd	s2,0(sp)
    80004488:	1000                	addi	s0,sp,32
    8000448a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000448c:	415c                	lw	a5,4(a0)
    8000448e:	0047d79b          	srliw	a5,a5,0x4
    80004492:	0002d597          	auipc	a1,0x2d
    80004496:	1d65a583          	lw	a1,470(a1) # 80031668 <sb+0x18>
    8000449a:	9dbd                	addw	a1,a1,a5
    8000449c:	4108                	lw	a0,0(a0)
    8000449e:	00000097          	auipc	ra,0x0
    800044a2:	8aa080e7          	jalr	-1878(ra) # 80003d48 <bread>
    800044a6:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800044a8:	05850793          	addi	a5,a0,88
    800044ac:	40d8                	lw	a4,4(s1)
    800044ae:	8b3d                	andi	a4,a4,15
    800044b0:	071a                	slli	a4,a4,0x6
    800044b2:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800044b4:	04449703          	lh	a4,68(s1)
    800044b8:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800044bc:	04649703          	lh	a4,70(s1)
    800044c0:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800044c4:	04849703          	lh	a4,72(s1)
    800044c8:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800044cc:	04a49703          	lh	a4,74(s1)
    800044d0:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800044d4:	44f8                	lw	a4,76(s1)
    800044d6:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800044d8:	03400613          	li	a2,52
    800044dc:	05048593          	addi	a1,s1,80
    800044e0:	00c78513          	addi	a0,a5,12
    800044e4:	ffffd097          	auipc	ra,0xffffd
    800044e8:	88c080e7          	jalr	-1908(ra) # 80000d70 <memmove>
  log_write(bp);
    800044ec:	854a                	mv	a0,s2
    800044ee:	00001097          	auipc	ra,0x1
    800044f2:	c0e080e7          	jalr	-1010(ra) # 800050fc <log_write>
  brelse(bp);
    800044f6:	854a                	mv	a0,s2
    800044f8:	00000097          	auipc	ra,0x0
    800044fc:	980080e7          	jalr	-1664(ra) # 80003e78 <brelse>
}
    80004500:	60e2                	ld	ra,24(sp)
    80004502:	6442                	ld	s0,16(sp)
    80004504:	64a2                	ld	s1,8(sp)
    80004506:	6902                	ld	s2,0(sp)
    80004508:	6105                	addi	sp,sp,32
    8000450a:	8082                	ret

000000008000450c <idup>:
{
    8000450c:	1101                	addi	sp,sp,-32
    8000450e:	ec06                	sd	ra,24(sp)
    80004510:	e822                	sd	s0,16(sp)
    80004512:	e426                	sd	s1,8(sp)
    80004514:	1000                	addi	s0,sp,32
    80004516:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004518:	0002d517          	auipc	a0,0x2d
    8000451c:	15850513          	addi	a0,a0,344 # 80031670 <itable>
    80004520:	ffffc097          	auipc	ra,0xffffc
    80004524:	6f8080e7          	jalr	1784(ra) # 80000c18 <acquire>
  ip->ref++;
    80004528:	449c                	lw	a5,8(s1)
    8000452a:	2785                	addiw	a5,a5,1
    8000452c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000452e:	0002d517          	auipc	a0,0x2d
    80004532:	14250513          	addi	a0,a0,322 # 80031670 <itable>
    80004536:	ffffc097          	auipc	ra,0xffffc
    8000453a:	796080e7          	jalr	1942(ra) # 80000ccc <release>
}
    8000453e:	8526                	mv	a0,s1
    80004540:	60e2                	ld	ra,24(sp)
    80004542:	6442                	ld	s0,16(sp)
    80004544:	64a2                	ld	s1,8(sp)
    80004546:	6105                	addi	sp,sp,32
    80004548:	8082                	ret

000000008000454a <ilock>:
{
    8000454a:	1101                	addi	sp,sp,-32
    8000454c:	ec06                	sd	ra,24(sp)
    8000454e:	e822                	sd	s0,16(sp)
    80004550:	e426                	sd	s1,8(sp)
    80004552:	e04a                	sd	s2,0(sp)
    80004554:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80004556:	c115                	beqz	a0,8000457a <ilock+0x30>
    80004558:	84aa                	mv	s1,a0
    8000455a:	451c                	lw	a5,8(a0)
    8000455c:	00f05f63          	blez	a5,8000457a <ilock+0x30>
  acquiresleep(&ip->lock);
    80004560:	0541                	addi	a0,a0,16
    80004562:	00001097          	auipc	ra,0x1
    80004566:	cb8080e7          	jalr	-840(ra) # 8000521a <acquiresleep>
  if(ip->valid == 0){
    8000456a:	40bc                	lw	a5,64(s1)
    8000456c:	cf99                	beqz	a5,8000458a <ilock+0x40>
}
    8000456e:	60e2                	ld	ra,24(sp)
    80004570:	6442                	ld	s0,16(sp)
    80004572:	64a2                	ld	s1,8(sp)
    80004574:	6902                	ld	s2,0(sp)
    80004576:	6105                	addi	sp,sp,32
    80004578:	8082                	ret
    panic("ilock");
    8000457a:	00005517          	auipc	a0,0x5
    8000457e:	11650513          	addi	a0,a0,278 # 80009690 <syscalls+0x1c8>
    80004582:	ffffc097          	auipc	ra,0xffffc
    80004586:	fb8080e7          	jalr	-72(ra) # 8000053a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000458a:	40dc                	lw	a5,4(s1)
    8000458c:	0047d79b          	srliw	a5,a5,0x4
    80004590:	0002d597          	auipc	a1,0x2d
    80004594:	0d85a583          	lw	a1,216(a1) # 80031668 <sb+0x18>
    80004598:	9dbd                	addw	a1,a1,a5
    8000459a:	4088                	lw	a0,0(s1)
    8000459c:	fffff097          	auipc	ra,0xfffff
    800045a0:	7ac080e7          	jalr	1964(ra) # 80003d48 <bread>
    800045a4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800045a6:	05850593          	addi	a1,a0,88
    800045aa:	40dc                	lw	a5,4(s1)
    800045ac:	8bbd                	andi	a5,a5,15
    800045ae:	079a                	slli	a5,a5,0x6
    800045b0:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800045b2:	00059783          	lh	a5,0(a1)
    800045b6:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800045ba:	00259783          	lh	a5,2(a1)
    800045be:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800045c2:	00459783          	lh	a5,4(a1)
    800045c6:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800045ca:	00659783          	lh	a5,6(a1)
    800045ce:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800045d2:	459c                	lw	a5,8(a1)
    800045d4:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800045d6:	03400613          	li	a2,52
    800045da:	05b1                	addi	a1,a1,12
    800045dc:	05048513          	addi	a0,s1,80
    800045e0:	ffffc097          	auipc	ra,0xffffc
    800045e4:	790080e7          	jalr	1936(ra) # 80000d70 <memmove>
    brelse(bp);
    800045e8:	854a                	mv	a0,s2
    800045ea:	00000097          	auipc	ra,0x0
    800045ee:	88e080e7          	jalr	-1906(ra) # 80003e78 <brelse>
    ip->valid = 1;
    800045f2:	4785                	li	a5,1
    800045f4:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800045f6:	04449783          	lh	a5,68(s1)
    800045fa:	fbb5                	bnez	a5,8000456e <ilock+0x24>
      panic("ilock: no type");
    800045fc:	00005517          	auipc	a0,0x5
    80004600:	09c50513          	addi	a0,a0,156 # 80009698 <syscalls+0x1d0>
    80004604:	ffffc097          	auipc	ra,0xffffc
    80004608:	f36080e7          	jalr	-202(ra) # 8000053a <panic>

000000008000460c <iunlock>:
{
    8000460c:	1101                	addi	sp,sp,-32
    8000460e:	ec06                	sd	ra,24(sp)
    80004610:	e822                	sd	s0,16(sp)
    80004612:	e426                	sd	s1,8(sp)
    80004614:	e04a                	sd	s2,0(sp)
    80004616:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80004618:	c905                	beqz	a0,80004648 <iunlock+0x3c>
    8000461a:	84aa                	mv	s1,a0
    8000461c:	01050913          	addi	s2,a0,16
    80004620:	854a                	mv	a0,s2
    80004622:	00001097          	auipc	ra,0x1
    80004626:	c92080e7          	jalr	-878(ra) # 800052b4 <holdingsleep>
    8000462a:	cd19                	beqz	a0,80004648 <iunlock+0x3c>
    8000462c:	449c                	lw	a5,8(s1)
    8000462e:	00f05d63          	blez	a5,80004648 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80004632:	854a                	mv	a0,s2
    80004634:	00001097          	auipc	ra,0x1
    80004638:	c3c080e7          	jalr	-964(ra) # 80005270 <releasesleep>
}
    8000463c:	60e2                	ld	ra,24(sp)
    8000463e:	6442                	ld	s0,16(sp)
    80004640:	64a2                	ld	s1,8(sp)
    80004642:	6902                	ld	s2,0(sp)
    80004644:	6105                	addi	sp,sp,32
    80004646:	8082                	ret
    panic("iunlock");
    80004648:	00005517          	auipc	a0,0x5
    8000464c:	06050513          	addi	a0,a0,96 # 800096a8 <syscalls+0x1e0>
    80004650:	ffffc097          	auipc	ra,0xffffc
    80004654:	eea080e7          	jalr	-278(ra) # 8000053a <panic>

0000000080004658 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80004658:	7179                	addi	sp,sp,-48
    8000465a:	f406                	sd	ra,40(sp)
    8000465c:	f022                	sd	s0,32(sp)
    8000465e:	ec26                	sd	s1,24(sp)
    80004660:	e84a                	sd	s2,16(sp)
    80004662:	e44e                	sd	s3,8(sp)
    80004664:	e052                	sd	s4,0(sp)
    80004666:	1800                	addi	s0,sp,48
    80004668:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000466a:	05050493          	addi	s1,a0,80
    8000466e:	08050913          	addi	s2,a0,128
    80004672:	a021                	j	8000467a <itrunc+0x22>
    80004674:	0491                	addi	s1,s1,4
    80004676:	01248d63          	beq	s1,s2,80004690 <itrunc+0x38>
    if(ip->addrs[i]){
    8000467a:	408c                	lw	a1,0(s1)
    8000467c:	dde5                	beqz	a1,80004674 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    8000467e:	0009a503          	lw	a0,0(s3)
    80004682:	00000097          	auipc	ra,0x0
    80004686:	90c080e7          	jalr	-1780(ra) # 80003f8e <bfree>
      ip->addrs[i] = 0;
    8000468a:	0004a023          	sw	zero,0(s1)
    8000468e:	b7dd                	j	80004674 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80004690:	0809a583          	lw	a1,128(s3)
    80004694:	e185                	bnez	a1,800046b4 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80004696:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000469a:	854e                	mv	a0,s3
    8000469c:	00000097          	auipc	ra,0x0
    800046a0:	de2080e7          	jalr	-542(ra) # 8000447e <iupdate>
}
    800046a4:	70a2                	ld	ra,40(sp)
    800046a6:	7402                	ld	s0,32(sp)
    800046a8:	64e2                	ld	s1,24(sp)
    800046aa:	6942                	ld	s2,16(sp)
    800046ac:	69a2                	ld	s3,8(sp)
    800046ae:	6a02                	ld	s4,0(sp)
    800046b0:	6145                	addi	sp,sp,48
    800046b2:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800046b4:	0009a503          	lw	a0,0(s3)
    800046b8:	fffff097          	auipc	ra,0xfffff
    800046bc:	690080e7          	jalr	1680(ra) # 80003d48 <bread>
    800046c0:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800046c2:	05850493          	addi	s1,a0,88
    800046c6:	45850913          	addi	s2,a0,1112
    800046ca:	a021                	j	800046d2 <itrunc+0x7a>
    800046cc:	0491                	addi	s1,s1,4
    800046ce:	01248b63          	beq	s1,s2,800046e4 <itrunc+0x8c>
      if(a[j])
    800046d2:	408c                	lw	a1,0(s1)
    800046d4:	dde5                	beqz	a1,800046cc <itrunc+0x74>
        bfree(ip->dev, a[j]);
    800046d6:	0009a503          	lw	a0,0(s3)
    800046da:	00000097          	auipc	ra,0x0
    800046de:	8b4080e7          	jalr	-1868(ra) # 80003f8e <bfree>
    800046e2:	b7ed                	j	800046cc <itrunc+0x74>
    brelse(bp);
    800046e4:	8552                	mv	a0,s4
    800046e6:	fffff097          	auipc	ra,0xfffff
    800046ea:	792080e7          	jalr	1938(ra) # 80003e78 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800046ee:	0809a583          	lw	a1,128(s3)
    800046f2:	0009a503          	lw	a0,0(s3)
    800046f6:	00000097          	auipc	ra,0x0
    800046fa:	898080e7          	jalr	-1896(ra) # 80003f8e <bfree>
    ip->addrs[NDIRECT] = 0;
    800046fe:	0809a023          	sw	zero,128(s3)
    80004702:	bf51                	j	80004696 <itrunc+0x3e>

0000000080004704 <iput>:
{
    80004704:	1101                	addi	sp,sp,-32
    80004706:	ec06                	sd	ra,24(sp)
    80004708:	e822                	sd	s0,16(sp)
    8000470a:	e426                	sd	s1,8(sp)
    8000470c:	e04a                	sd	s2,0(sp)
    8000470e:	1000                	addi	s0,sp,32
    80004710:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004712:	0002d517          	auipc	a0,0x2d
    80004716:	f5e50513          	addi	a0,a0,-162 # 80031670 <itable>
    8000471a:	ffffc097          	auipc	ra,0xffffc
    8000471e:	4fe080e7          	jalr	1278(ra) # 80000c18 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004722:	4498                	lw	a4,8(s1)
    80004724:	4785                	li	a5,1
    80004726:	02f70363          	beq	a4,a5,8000474c <iput+0x48>
  ip->ref--;
    8000472a:	449c                	lw	a5,8(s1)
    8000472c:	37fd                	addiw	a5,a5,-1
    8000472e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004730:	0002d517          	auipc	a0,0x2d
    80004734:	f4050513          	addi	a0,a0,-192 # 80031670 <itable>
    80004738:	ffffc097          	auipc	ra,0xffffc
    8000473c:	594080e7          	jalr	1428(ra) # 80000ccc <release>
}
    80004740:	60e2                	ld	ra,24(sp)
    80004742:	6442                	ld	s0,16(sp)
    80004744:	64a2                	ld	s1,8(sp)
    80004746:	6902                	ld	s2,0(sp)
    80004748:	6105                	addi	sp,sp,32
    8000474a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000474c:	40bc                	lw	a5,64(s1)
    8000474e:	dff1                	beqz	a5,8000472a <iput+0x26>
    80004750:	04a49783          	lh	a5,74(s1)
    80004754:	fbf9                	bnez	a5,8000472a <iput+0x26>
    acquiresleep(&ip->lock);
    80004756:	01048913          	addi	s2,s1,16
    8000475a:	854a                	mv	a0,s2
    8000475c:	00001097          	auipc	ra,0x1
    80004760:	abe080e7          	jalr	-1346(ra) # 8000521a <acquiresleep>
    release(&itable.lock);
    80004764:	0002d517          	auipc	a0,0x2d
    80004768:	f0c50513          	addi	a0,a0,-244 # 80031670 <itable>
    8000476c:	ffffc097          	auipc	ra,0xffffc
    80004770:	560080e7          	jalr	1376(ra) # 80000ccc <release>
    itrunc(ip);
    80004774:	8526                	mv	a0,s1
    80004776:	00000097          	auipc	ra,0x0
    8000477a:	ee2080e7          	jalr	-286(ra) # 80004658 <itrunc>
    ip->type = 0;
    8000477e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80004782:	8526                	mv	a0,s1
    80004784:	00000097          	auipc	ra,0x0
    80004788:	cfa080e7          	jalr	-774(ra) # 8000447e <iupdate>
    ip->valid = 0;
    8000478c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004790:	854a                	mv	a0,s2
    80004792:	00001097          	auipc	ra,0x1
    80004796:	ade080e7          	jalr	-1314(ra) # 80005270 <releasesleep>
    acquire(&itable.lock);
    8000479a:	0002d517          	auipc	a0,0x2d
    8000479e:	ed650513          	addi	a0,a0,-298 # 80031670 <itable>
    800047a2:	ffffc097          	auipc	ra,0xffffc
    800047a6:	476080e7          	jalr	1142(ra) # 80000c18 <acquire>
    800047aa:	b741                	j	8000472a <iput+0x26>

00000000800047ac <iunlockput>:
{
    800047ac:	1101                	addi	sp,sp,-32
    800047ae:	ec06                	sd	ra,24(sp)
    800047b0:	e822                	sd	s0,16(sp)
    800047b2:	e426                	sd	s1,8(sp)
    800047b4:	1000                	addi	s0,sp,32
    800047b6:	84aa                	mv	s1,a0
  iunlock(ip);
    800047b8:	00000097          	auipc	ra,0x0
    800047bc:	e54080e7          	jalr	-428(ra) # 8000460c <iunlock>
  iput(ip);
    800047c0:	8526                	mv	a0,s1
    800047c2:	00000097          	auipc	ra,0x0
    800047c6:	f42080e7          	jalr	-190(ra) # 80004704 <iput>
}
    800047ca:	60e2                	ld	ra,24(sp)
    800047cc:	6442                	ld	s0,16(sp)
    800047ce:	64a2                	ld	s1,8(sp)
    800047d0:	6105                	addi	sp,sp,32
    800047d2:	8082                	ret

00000000800047d4 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800047d4:	1141                	addi	sp,sp,-16
    800047d6:	e422                	sd	s0,8(sp)
    800047d8:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800047da:	411c                	lw	a5,0(a0)
    800047dc:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800047de:	415c                	lw	a5,4(a0)
    800047e0:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800047e2:	04451783          	lh	a5,68(a0)
    800047e6:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800047ea:	04a51783          	lh	a5,74(a0)
    800047ee:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800047f2:	04c56783          	lwu	a5,76(a0)
    800047f6:	e99c                	sd	a5,16(a1)
}
    800047f8:	6422                	ld	s0,8(sp)
    800047fa:	0141                	addi	sp,sp,16
    800047fc:	8082                	ret

00000000800047fe <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800047fe:	457c                	lw	a5,76(a0)
    80004800:	0ed7e963          	bltu	a5,a3,800048f2 <readi+0xf4>
{
    80004804:	7159                	addi	sp,sp,-112
    80004806:	f486                	sd	ra,104(sp)
    80004808:	f0a2                	sd	s0,96(sp)
    8000480a:	eca6                	sd	s1,88(sp)
    8000480c:	e8ca                	sd	s2,80(sp)
    8000480e:	e4ce                	sd	s3,72(sp)
    80004810:	e0d2                	sd	s4,64(sp)
    80004812:	fc56                	sd	s5,56(sp)
    80004814:	f85a                	sd	s6,48(sp)
    80004816:	f45e                	sd	s7,40(sp)
    80004818:	f062                	sd	s8,32(sp)
    8000481a:	ec66                	sd	s9,24(sp)
    8000481c:	e86a                	sd	s10,16(sp)
    8000481e:	e46e                	sd	s11,8(sp)
    80004820:	1880                	addi	s0,sp,112
    80004822:	8baa                	mv	s7,a0
    80004824:	8c2e                	mv	s8,a1
    80004826:	8ab2                	mv	s5,a2
    80004828:	84b6                	mv	s1,a3
    8000482a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000482c:	9f35                	addw	a4,a4,a3
    return 0;
    8000482e:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004830:	0ad76063          	bltu	a4,a3,800048d0 <readi+0xd2>
  if(off + n > ip->size)
    80004834:	00e7f463          	bgeu	a5,a4,8000483c <readi+0x3e>
    n = ip->size - off;
    80004838:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000483c:	0a0b0963          	beqz	s6,800048ee <readi+0xf0>
    80004840:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004842:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004846:	5cfd                	li	s9,-1
    80004848:	a82d                	j	80004882 <readi+0x84>
    8000484a:	020a1d93          	slli	s11,s4,0x20
    8000484e:	020ddd93          	srli	s11,s11,0x20
    80004852:	05890613          	addi	a2,s2,88
    80004856:	86ee                	mv	a3,s11
    80004858:	963a                	add	a2,a2,a4
    8000485a:	85d6                	mv	a1,s5
    8000485c:	8562                	mv	a0,s8
    8000485e:	ffffe097          	auipc	ra,0xffffe
    80004862:	cf8080e7          	jalr	-776(ra) # 80002556 <either_copyout>
    80004866:	05950d63          	beq	a0,s9,800048c0 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000486a:	854a                	mv	a0,s2
    8000486c:	fffff097          	auipc	ra,0xfffff
    80004870:	60c080e7          	jalr	1548(ra) # 80003e78 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004874:	013a09bb          	addw	s3,s4,s3
    80004878:	009a04bb          	addw	s1,s4,s1
    8000487c:	9aee                	add	s5,s5,s11
    8000487e:	0569f763          	bgeu	s3,s6,800048cc <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004882:	000ba903          	lw	s2,0(s7)
    80004886:	00a4d59b          	srliw	a1,s1,0xa
    8000488a:	855e                	mv	a0,s7
    8000488c:	00000097          	auipc	ra,0x0
    80004890:	8ac080e7          	jalr	-1876(ra) # 80004138 <bmap>
    80004894:	0005059b          	sext.w	a1,a0
    80004898:	854a                	mv	a0,s2
    8000489a:	fffff097          	auipc	ra,0xfffff
    8000489e:	4ae080e7          	jalr	1198(ra) # 80003d48 <bread>
    800048a2:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800048a4:	3ff4f713          	andi	a4,s1,1023
    800048a8:	40ed07bb          	subw	a5,s10,a4
    800048ac:	413b06bb          	subw	a3,s6,s3
    800048b0:	8a3e                	mv	s4,a5
    800048b2:	2781                	sext.w	a5,a5
    800048b4:	0006861b          	sext.w	a2,a3
    800048b8:	f8f679e3          	bgeu	a2,a5,8000484a <readi+0x4c>
    800048bc:	8a36                	mv	s4,a3
    800048be:	b771                	j	8000484a <readi+0x4c>
      brelse(bp);
    800048c0:	854a                	mv	a0,s2
    800048c2:	fffff097          	auipc	ra,0xfffff
    800048c6:	5b6080e7          	jalr	1462(ra) # 80003e78 <brelse>
      tot = -1;
    800048ca:	59fd                	li	s3,-1
  }
  return tot;
    800048cc:	0009851b          	sext.w	a0,s3
}
    800048d0:	70a6                	ld	ra,104(sp)
    800048d2:	7406                	ld	s0,96(sp)
    800048d4:	64e6                	ld	s1,88(sp)
    800048d6:	6946                	ld	s2,80(sp)
    800048d8:	69a6                	ld	s3,72(sp)
    800048da:	6a06                	ld	s4,64(sp)
    800048dc:	7ae2                	ld	s5,56(sp)
    800048de:	7b42                	ld	s6,48(sp)
    800048e0:	7ba2                	ld	s7,40(sp)
    800048e2:	7c02                	ld	s8,32(sp)
    800048e4:	6ce2                	ld	s9,24(sp)
    800048e6:	6d42                	ld	s10,16(sp)
    800048e8:	6da2                	ld	s11,8(sp)
    800048ea:	6165                	addi	sp,sp,112
    800048ec:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800048ee:	89da                	mv	s3,s6
    800048f0:	bff1                	j	800048cc <readi+0xce>
    return 0;
    800048f2:	4501                	li	a0,0
}
    800048f4:	8082                	ret

00000000800048f6 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800048f6:	457c                	lw	a5,76(a0)
    800048f8:	10d7e863          	bltu	a5,a3,80004a08 <writei+0x112>
{
    800048fc:	7159                	addi	sp,sp,-112
    800048fe:	f486                	sd	ra,104(sp)
    80004900:	f0a2                	sd	s0,96(sp)
    80004902:	eca6                	sd	s1,88(sp)
    80004904:	e8ca                	sd	s2,80(sp)
    80004906:	e4ce                	sd	s3,72(sp)
    80004908:	e0d2                	sd	s4,64(sp)
    8000490a:	fc56                	sd	s5,56(sp)
    8000490c:	f85a                	sd	s6,48(sp)
    8000490e:	f45e                	sd	s7,40(sp)
    80004910:	f062                	sd	s8,32(sp)
    80004912:	ec66                	sd	s9,24(sp)
    80004914:	e86a                	sd	s10,16(sp)
    80004916:	e46e                	sd	s11,8(sp)
    80004918:	1880                	addi	s0,sp,112
    8000491a:	8b2a                	mv	s6,a0
    8000491c:	8c2e                	mv	s8,a1
    8000491e:	8ab2                	mv	s5,a2
    80004920:	8936                	mv	s2,a3
    80004922:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80004924:	00e687bb          	addw	a5,a3,a4
    80004928:	0ed7e263          	bltu	a5,a3,80004a0c <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000492c:	00043737          	lui	a4,0x43
    80004930:	0ef76063          	bltu	a4,a5,80004a10 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004934:	0c0b8863          	beqz	s7,80004a04 <writei+0x10e>
    80004938:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    8000493a:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000493e:	5cfd                	li	s9,-1
    80004940:	a091                	j	80004984 <writei+0x8e>
    80004942:	02099d93          	slli	s11,s3,0x20
    80004946:	020ddd93          	srli	s11,s11,0x20
    8000494a:	05848513          	addi	a0,s1,88
    8000494e:	86ee                	mv	a3,s11
    80004950:	8656                	mv	a2,s5
    80004952:	85e2                	mv	a1,s8
    80004954:	953a                	add	a0,a0,a4
    80004956:	ffffe097          	auipc	ra,0xffffe
    8000495a:	c56080e7          	jalr	-938(ra) # 800025ac <either_copyin>
    8000495e:	07950263          	beq	a0,s9,800049c2 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004962:	8526                	mv	a0,s1
    80004964:	00000097          	auipc	ra,0x0
    80004968:	798080e7          	jalr	1944(ra) # 800050fc <log_write>
    brelse(bp);
    8000496c:	8526                	mv	a0,s1
    8000496e:	fffff097          	auipc	ra,0xfffff
    80004972:	50a080e7          	jalr	1290(ra) # 80003e78 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004976:	01498a3b          	addw	s4,s3,s4
    8000497a:	0129893b          	addw	s2,s3,s2
    8000497e:	9aee                	add	s5,s5,s11
    80004980:	057a7663          	bgeu	s4,s7,800049cc <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004984:	000b2483          	lw	s1,0(s6)
    80004988:	00a9559b          	srliw	a1,s2,0xa
    8000498c:	855a                	mv	a0,s6
    8000498e:	fffff097          	auipc	ra,0xfffff
    80004992:	7aa080e7          	jalr	1962(ra) # 80004138 <bmap>
    80004996:	0005059b          	sext.w	a1,a0
    8000499a:	8526                	mv	a0,s1
    8000499c:	fffff097          	auipc	ra,0xfffff
    800049a0:	3ac080e7          	jalr	940(ra) # 80003d48 <bread>
    800049a4:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800049a6:	3ff97713          	andi	a4,s2,1023
    800049aa:	40ed07bb          	subw	a5,s10,a4
    800049ae:	414b86bb          	subw	a3,s7,s4
    800049b2:	89be                	mv	s3,a5
    800049b4:	2781                	sext.w	a5,a5
    800049b6:	0006861b          	sext.w	a2,a3
    800049ba:	f8f674e3          	bgeu	a2,a5,80004942 <writei+0x4c>
    800049be:	89b6                	mv	s3,a3
    800049c0:	b749                	j	80004942 <writei+0x4c>
      brelse(bp);
    800049c2:	8526                	mv	a0,s1
    800049c4:	fffff097          	auipc	ra,0xfffff
    800049c8:	4b4080e7          	jalr	1204(ra) # 80003e78 <brelse>
  }

  if(off > ip->size)
    800049cc:	04cb2783          	lw	a5,76(s6)
    800049d0:	0127f463          	bgeu	a5,s2,800049d8 <writei+0xe2>
    ip->size = off;
    800049d4:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800049d8:	855a                	mv	a0,s6
    800049da:	00000097          	auipc	ra,0x0
    800049de:	aa4080e7          	jalr	-1372(ra) # 8000447e <iupdate>

  return tot;
    800049e2:	000a051b          	sext.w	a0,s4
}
    800049e6:	70a6                	ld	ra,104(sp)
    800049e8:	7406                	ld	s0,96(sp)
    800049ea:	64e6                	ld	s1,88(sp)
    800049ec:	6946                	ld	s2,80(sp)
    800049ee:	69a6                	ld	s3,72(sp)
    800049f0:	6a06                	ld	s4,64(sp)
    800049f2:	7ae2                	ld	s5,56(sp)
    800049f4:	7b42                	ld	s6,48(sp)
    800049f6:	7ba2                	ld	s7,40(sp)
    800049f8:	7c02                	ld	s8,32(sp)
    800049fa:	6ce2                	ld	s9,24(sp)
    800049fc:	6d42                	ld	s10,16(sp)
    800049fe:	6da2                	ld	s11,8(sp)
    80004a00:	6165                	addi	sp,sp,112
    80004a02:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004a04:	8a5e                	mv	s4,s7
    80004a06:	bfc9                	j	800049d8 <writei+0xe2>
    return -1;
    80004a08:	557d                	li	a0,-1
}
    80004a0a:	8082                	ret
    return -1;
    80004a0c:	557d                	li	a0,-1
    80004a0e:	bfe1                	j	800049e6 <writei+0xf0>
    return -1;
    80004a10:	557d                	li	a0,-1
    80004a12:	bfd1                	j	800049e6 <writei+0xf0>

0000000080004a14 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004a14:	1141                	addi	sp,sp,-16
    80004a16:	e406                	sd	ra,8(sp)
    80004a18:	e022                	sd	s0,0(sp)
    80004a1a:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004a1c:	4639                	li	a2,14
    80004a1e:	ffffc097          	auipc	ra,0xffffc
    80004a22:	3c6080e7          	jalr	966(ra) # 80000de4 <strncmp>
}
    80004a26:	60a2                	ld	ra,8(sp)
    80004a28:	6402                	ld	s0,0(sp)
    80004a2a:	0141                	addi	sp,sp,16
    80004a2c:	8082                	ret

0000000080004a2e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004a2e:	7139                	addi	sp,sp,-64
    80004a30:	fc06                	sd	ra,56(sp)
    80004a32:	f822                	sd	s0,48(sp)
    80004a34:	f426                	sd	s1,40(sp)
    80004a36:	f04a                	sd	s2,32(sp)
    80004a38:	ec4e                	sd	s3,24(sp)
    80004a3a:	e852                	sd	s4,16(sp)
    80004a3c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004a3e:	04451703          	lh	a4,68(a0)
    80004a42:	4785                	li	a5,1
    80004a44:	00f71a63          	bne	a4,a5,80004a58 <dirlookup+0x2a>
    80004a48:	892a                	mv	s2,a0
    80004a4a:	89ae                	mv	s3,a1
    80004a4c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004a4e:	457c                	lw	a5,76(a0)
    80004a50:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004a52:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004a54:	e79d                	bnez	a5,80004a82 <dirlookup+0x54>
    80004a56:	a8a5                	j	80004ace <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004a58:	00005517          	auipc	a0,0x5
    80004a5c:	c5850513          	addi	a0,a0,-936 # 800096b0 <syscalls+0x1e8>
    80004a60:	ffffc097          	auipc	ra,0xffffc
    80004a64:	ada080e7          	jalr	-1318(ra) # 8000053a <panic>
      panic("dirlookup read");
    80004a68:	00005517          	auipc	a0,0x5
    80004a6c:	c6050513          	addi	a0,a0,-928 # 800096c8 <syscalls+0x200>
    80004a70:	ffffc097          	auipc	ra,0xffffc
    80004a74:	aca080e7          	jalr	-1334(ra) # 8000053a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004a78:	24c1                	addiw	s1,s1,16
    80004a7a:	04c92783          	lw	a5,76(s2)
    80004a7e:	04f4f763          	bgeu	s1,a5,80004acc <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004a82:	4741                	li	a4,16
    80004a84:	86a6                	mv	a3,s1
    80004a86:	fc040613          	addi	a2,s0,-64
    80004a8a:	4581                	li	a1,0
    80004a8c:	854a                	mv	a0,s2
    80004a8e:	00000097          	auipc	ra,0x0
    80004a92:	d70080e7          	jalr	-656(ra) # 800047fe <readi>
    80004a96:	47c1                	li	a5,16
    80004a98:	fcf518e3          	bne	a0,a5,80004a68 <dirlookup+0x3a>
    if(de.inum == 0)
    80004a9c:	fc045783          	lhu	a5,-64(s0)
    80004aa0:	dfe1                	beqz	a5,80004a78 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004aa2:	fc240593          	addi	a1,s0,-62
    80004aa6:	854e                	mv	a0,s3
    80004aa8:	00000097          	auipc	ra,0x0
    80004aac:	f6c080e7          	jalr	-148(ra) # 80004a14 <namecmp>
    80004ab0:	f561                	bnez	a0,80004a78 <dirlookup+0x4a>
      if(poff)
    80004ab2:	000a0463          	beqz	s4,80004aba <dirlookup+0x8c>
        *poff = off;
    80004ab6:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004aba:	fc045583          	lhu	a1,-64(s0)
    80004abe:	00092503          	lw	a0,0(s2)
    80004ac2:	fffff097          	auipc	ra,0xfffff
    80004ac6:	752080e7          	jalr	1874(ra) # 80004214 <iget>
    80004aca:	a011                	j	80004ace <dirlookup+0xa0>
  return 0;
    80004acc:	4501                	li	a0,0
}
    80004ace:	70e2                	ld	ra,56(sp)
    80004ad0:	7442                	ld	s0,48(sp)
    80004ad2:	74a2                	ld	s1,40(sp)
    80004ad4:	7902                	ld	s2,32(sp)
    80004ad6:	69e2                	ld	s3,24(sp)
    80004ad8:	6a42                	ld	s4,16(sp)
    80004ada:	6121                	addi	sp,sp,64
    80004adc:	8082                	ret

0000000080004ade <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004ade:	711d                	addi	sp,sp,-96
    80004ae0:	ec86                	sd	ra,88(sp)
    80004ae2:	e8a2                	sd	s0,80(sp)
    80004ae4:	e4a6                	sd	s1,72(sp)
    80004ae6:	e0ca                	sd	s2,64(sp)
    80004ae8:	fc4e                	sd	s3,56(sp)
    80004aea:	f852                	sd	s4,48(sp)
    80004aec:	f456                	sd	s5,40(sp)
    80004aee:	f05a                	sd	s6,32(sp)
    80004af0:	ec5e                	sd	s7,24(sp)
    80004af2:	e862                	sd	s8,16(sp)
    80004af4:	e466                	sd	s9,8(sp)
    80004af6:	e06a                	sd	s10,0(sp)
    80004af8:	1080                	addi	s0,sp,96
    80004afa:	84aa                	mv	s1,a0
    80004afc:	8b2e                	mv	s6,a1
    80004afe:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004b00:	00054703          	lbu	a4,0(a0)
    80004b04:	02f00793          	li	a5,47
    80004b08:	02f70363          	beq	a4,a5,80004b2e <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004b0c:	ffffd097          	auipc	ra,0xffffd
    80004b10:	2b0080e7          	jalr	688(ra) # 80001dbc <myproc>
    80004b14:	17053503          	ld	a0,368(a0)
    80004b18:	00000097          	auipc	ra,0x0
    80004b1c:	9f4080e7          	jalr	-1548(ra) # 8000450c <idup>
    80004b20:	8a2a                	mv	s4,a0
  while(*path == '/')
    80004b22:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80004b26:	4cb5                	li	s9,13
  len = path - s;
    80004b28:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004b2a:	4c05                	li	s8,1
    80004b2c:	a87d                	j	80004bea <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80004b2e:	4585                	li	a1,1
    80004b30:	4505                	li	a0,1
    80004b32:	fffff097          	auipc	ra,0xfffff
    80004b36:	6e2080e7          	jalr	1762(ra) # 80004214 <iget>
    80004b3a:	8a2a                	mv	s4,a0
    80004b3c:	b7dd                	j	80004b22 <namex+0x44>
      iunlockput(ip);
    80004b3e:	8552                	mv	a0,s4
    80004b40:	00000097          	auipc	ra,0x0
    80004b44:	c6c080e7          	jalr	-916(ra) # 800047ac <iunlockput>
      return 0;
    80004b48:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004b4a:	8552                	mv	a0,s4
    80004b4c:	60e6                	ld	ra,88(sp)
    80004b4e:	6446                	ld	s0,80(sp)
    80004b50:	64a6                	ld	s1,72(sp)
    80004b52:	6906                	ld	s2,64(sp)
    80004b54:	79e2                	ld	s3,56(sp)
    80004b56:	7a42                	ld	s4,48(sp)
    80004b58:	7aa2                	ld	s5,40(sp)
    80004b5a:	7b02                	ld	s6,32(sp)
    80004b5c:	6be2                	ld	s7,24(sp)
    80004b5e:	6c42                	ld	s8,16(sp)
    80004b60:	6ca2                	ld	s9,8(sp)
    80004b62:	6d02                	ld	s10,0(sp)
    80004b64:	6125                	addi	sp,sp,96
    80004b66:	8082                	ret
      iunlock(ip);
    80004b68:	8552                	mv	a0,s4
    80004b6a:	00000097          	auipc	ra,0x0
    80004b6e:	aa2080e7          	jalr	-1374(ra) # 8000460c <iunlock>
      return ip;
    80004b72:	bfe1                	j	80004b4a <namex+0x6c>
      iunlockput(ip);
    80004b74:	8552                	mv	a0,s4
    80004b76:	00000097          	auipc	ra,0x0
    80004b7a:	c36080e7          	jalr	-970(ra) # 800047ac <iunlockput>
      return 0;
    80004b7e:	8a4e                	mv	s4,s3
    80004b80:	b7e9                	j	80004b4a <namex+0x6c>
  len = path - s;
    80004b82:	40998633          	sub	a2,s3,s1
    80004b86:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80004b8a:	09acd863          	bge	s9,s10,80004c1a <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80004b8e:	4639                	li	a2,14
    80004b90:	85a6                	mv	a1,s1
    80004b92:	8556                	mv	a0,s5
    80004b94:	ffffc097          	auipc	ra,0xffffc
    80004b98:	1dc080e7          	jalr	476(ra) # 80000d70 <memmove>
    80004b9c:	84ce                	mv	s1,s3
  while(*path == '/')
    80004b9e:	0004c783          	lbu	a5,0(s1)
    80004ba2:	01279763          	bne	a5,s2,80004bb0 <namex+0xd2>
    path++;
    80004ba6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004ba8:	0004c783          	lbu	a5,0(s1)
    80004bac:	ff278de3          	beq	a5,s2,80004ba6 <namex+0xc8>
    ilock(ip);
    80004bb0:	8552                	mv	a0,s4
    80004bb2:	00000097          	auipc	ra,0x0
    80004bb6:	998080e7          	jalr	-1640(ra) # 8000454a <ilock>
    if(ip->type != T_DIR){
    80004bba:	044a1783          	lh	a5,68(s4)
    80004bbe:	f98790e3          	bne	a5,s8,80004b3e <namex+0x60>
    if(nameiparent && *path == '\0'){
    80004bc2:	000b0563          	beqz	s6,80004bcc <namex+0xee>
    80004bc6:	0004c783          	lbu	a5,0(s1)
    80004bca:	dfd9                	beqz	a5,80004b68 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004bcc:	865e                	mv	a2,s7
    80004bce:	85d6                	mv	a1,s5
    80004bd0:	8552                	mv	a0,s4
    80004bd2:	00000097          	auipc	ra,0x0
    80004bd6:	e5c080e7          	jalr	-420(ra) # 80004a2e <dirlookup>
    80004bda:	89aa                	mv	s3,a0
    80004bdc:	dd41                	beqz	a0,80004b74 <namex+0x96>
    iunlockput(ip);
    80004bde:	8552                	mv	a0,s4
    80004be0:	00000097          	auipc	ra,0x0
    80004be4:	bcc080e7          	jalr	-1076(ra) # 800047ac <iunlockput>
    ip = next;
    80004be8:	8a4e                	mv	s4,s3
  while(*path == '/')
    80004bea:	0004c783          	lbu	a5,0(s1)
    80004bee:	01279763          	bne	a5,s2,80004bfc <namex+0x11e>
    path++;
    80004bf2:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004bf4:	0004c783          	lbu	a5,0(s1)
    80004bf8:	ff278de3          	beq	a5,s2,80004bf2 <namex+0x114>
  if(*path == 0)
    80004bfc:	cb9d                	beqz	a5,80004c32 <namex+0x154>
  while(*path != '/' && *path != 0)
    80004bfe:	0004c783          	lbu	a5,0(s1)
    80004c02:	89a6                	mv	s3,s1
  len = path - s;
    80004c04:	8d5e                	mv	s10,s7
    80004c06:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80004c08:	01278963          	beq	a5,s2,80004c1a <namex+0x13c>
    80004c0c:	dbbd                	beqz	a5,80004b82 <namex+0xa4>
    path++;
    80004c0e:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80004c10:	0009c783          	lbu	a5,0(s3)
    80004c14:	ff279ce3          	bne	a5,s2,80004c0c <namex+0x12e>
    80004c18:	b7ad                	j	80004b82 <namex+0xa4>
    memmove(name, s, len);
    80004c1a:	2601                	sext.w	a2,a2
    80004c1c:	85a6                	mv	a1,s1
    80004c1e:	8556                	mv	a0,s5
    80004c20:	ffffc097          	auipc	ra,0xffffc
    80004c24:	150080e7          	jalr	336(ra) # 80000d70 <memmove>
    name[len] = 0;
    80004c28:	9d56                	add	s10,s10,s5
    80004c2a:	000d0023          	sb	zero,0(s10)
    80004c2e:	84ce                	mv	s1,s3
    80004c30:	b7bd                	j	80004b9e <namex+0xc0>
  if(nameiparent){
    80004c32:	f00b0ce3          	beqz	s6,80004b4a <namex+0x6c>
    iput(ip);
    80004c36:	8552                	mv	a0,s4
    80004c38:	00000097          	auipc	ra,0x0
    80004c3c:	acc080e7          	jalr	-1332(ra) # 80004704 <iput>
    return 0;
    80004c40:	4a01                	li	s4,0
    80004c42:	b721                	j	80004b4a <namex+0x6c>

0000000080004c44 <dirlink>:
{
    80004c44:	7139                	addi	sp,sp,-64
    80004c46:	fc06                	sd	ra,56(sp)
    80004c48:	f822                	sd	s0,48(sp)
    80004c4a:	f426                	sd	s1,40(sp)
    80004c4c:	f04a                	sd	s2,32(sp)
    80004c4e:	ec4e                	sd	s3,24(sp)
    80004c50:	e852                	sd	s4,16(sp)
    80004c52:	0080                	addi	s0,sp,64
    80004c54:	892a                	mv	s2,a0
    80004c56:	8a2e                	mv	s4,a1
    80004c58:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004c5a:	4601                	li	a2,0
    80004c5c:	00000097          	auipc	ra,0x0
    80004c60:	dd2080e7          	jalr	-558(ra) # 80004a2e <dirlookup>
    80004c64:	e93d                	bnez	a0,80004cda <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004c66:	04c92483          	lw	s1,76(s2)
    80004c6a:	c49d                	beqz	s1,80004c98 <dirlink+0x54>
    80004c6c:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004c6e:	4741                	li	a4,16
    80004c70:	86a6                	mv	a3,s1
    80004c72:	fc040613          	addi	a2,s0,-64
    80004c76:	4581                	li	a1,0
    80004c78:	854a                	mv	a0,s2
    80004c7a:	00000097          	auipc	ra,0x0
    80004c7e:	b84080e7          	jalr	-1148(ra) # 800047fe <readi>
    80004c82:	47c1                	li	a5,16
    80004c84:	06f51163          	bne	a0,a5,80004ce6 <dirlink+0xa2>
    if(de.inum == 0)
    80004c88:	fc045783          	lhu	a5,-64(s0)
    80004c8c:	c791                	beqz	a5,80004c98 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004c8e:	24c1                	addiw	s1,s1,16
    80004c90:	04c92783          	lw	a5,76(s2)
    80004c94:	fcf4ede3          	bltu	s1,a5,80004c6e <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004c98:	4639                	li	a2,14
    80004c9a:	85d2                	mv	a1,s4
    80004c9c:	fc240513          	addi	a0,s0,-62
    80004ca0:	ffffc097          	auipc	ra,0xffffc
    80004ca4:	180080e7          	jalr	384(ra) # 80000e20 <strncpy>
  de.inum = inum;
    80004ca8:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004cac:	4741                	li	a4,16
    80004cae:	86a6                	mv	a3,s1
    80004cb0:	fc040613          	addi	a2,s0,-64
    80004cb4:	4581                	li	a1,0
    80004cb6:	854a                	mv	a0,s2
    80004cb8:	00000097          	auipc	ra,0x0
    80004cbc:	c3e080e7          	jalr	-962(ra) # 800048f6 <writei>
    80004cc0:	872a                	mv	a4,a0
    80004cc2:	47c1                	li	a5,16
  return 0;
    80004cc4:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004cc6:	02f71863          	bne	a4,a5,80004cf6 <dirlink+0xb2>
}
    80004cca:	70e2                	ld	ra,56(sp)
    80004ccc:	7442                	ld	s0,48(sp)
    80004cce:	74a2                	ld	s1,40(sp)
    80004cd0:	7902                	ld	s2,32(sp)
    80004cd2:	69e2                	ld	s3,24(sp)
    80004cd4:	6a42                	ld	s4,16(sp)
    80004cd6:	6121                	addi	sp,sp,64
    80004cd8:	8082                	ret
    iput(ip);
    80004cda:	00000097          	auipc	ra,0x0
    80004cde:	a2a080e7          	jalr	-1494(ra) # 80004704 <iput>
    return -1;
    80004ce2:	557d                	li	a0,-1
    80004ce4:	b7dd                	j	80004cca <dirlink+0x86>
      panic("dirlink read");
    80004ce6:	00005517          	auipc	a0,0x5
    80004cea:	9f250513          	addi	a0,a0,-1550 # 800096d8 <syscalls+0x210>
    80004cee:	ffffc097          	auipc	ra,0xffffc
    80004cf2:	84c080e7          	jalr	-1972(ra) # 8000053a <panic>
    panic("dirlink");
    80004cf6:	00005517          	auipc	a0,0x5
    80004cfa:	af250513          	addi	a0,a0,-1294 # 800097e8 <syscalls+0x320>
    80004cfe:	ffffc097          	auipc	ra,0xffffc
    80004d02:	83c080e7          	jalr	-1988(ra) # 8000053a <panic>

0000000080004d06 <namei>:

struct inode*
namei(char *path)
{
    80004d06:	1101                	addi	sp,sp,-32
    80004d08:	ec06                	sd	ra,24(sp)
    80004d0a:	e822                	sd	s0,16(sp)
    80004d0c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004d0e:	fe040613          	addi	a2,s0,-32
    80004d12:	4581                	li	a1,0
    80004d14:	00000097          	auipc	ra,0x0
    80004d18:	dca080e7          	jalr	-566(ra) # 80004ade <namex>
}
    80004d1c:	60e2                	ld	ra,24(sp)
    80004d1e:	6442                	ld	s0,16(sp)
    80004d20:	6105                	addi	sp,sp,32
    80004d22:	8082                	ret

0000000080004d24 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004d24:	1141                	addi	sp,sp,-16
    80004d26:	e406                	sd	ra,8(sp)
    80004d28:	e022                	sd	s0,0(sp)
    80004d2a:	0800                	addi	s0,sp,16
    80004d2c:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004d2e:	4585                	li	a1,1
    80004d30:	00000097          	auipc	ra,0x0
    80004d34:	dae080e7          	jalr	-594(ra) # 80004ade <namex>
}
    80004d38:	60a2                	ld	ra,8(sp)
    80004d3a:	6402                	ld	s0,0(sp)
    80004d3c:	0141                	addi	sp,sp,16
    80004d3e:	8082                	ret

0000000080004d40 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004d40:	1101                	addi	sp,sp,-32
    80004d42:	ec06                	sd	ra,24(sp)
    80004d44:	e822                	sd	s0,16(sp)
    80004d46:	e426                	sd	s1,8(sp)
    80004d48:	e04a                	sd	s2,0(sp)
    80004d4a:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004d4c:	0002e917          	auipc	s2,0x2e
    80004d50:	3cc90913          	addi	s2,s2,972 # 80033118 <log>
    80004d54:	01892583          	lw	a1,24(s2)
    80004d58:	02892503          	lw	a0,40(s2)
    80004d5c:	fffff097          	auipc	ra,0xfffff
    80004d60:	fec080e7          	jalr	-20(ra) # 80003d48 <bread>
    80004d64:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004d66:	02c92683          	lw	a3,44(s2)
    80004d6a:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004d6c:	02d05863          	blez	a3,80004d9c <write_head+0x5c>
    80004d70:	0002e797          	auipc	a5,0x2e
    80004d74:	3d878793          	addi	a5,a5,984 # 80033148 <log+0x30>
    80004d78:	05c50713          	addi	a4,a0,92
    80004d7c:	36fd                	addiw	a3,a3,-1
    80004d7e:	02069613          	slli	a2,a3,0x20
    80004d82:	01e65693          	srli	a3,a2,0x1e
    80004d86:	0002e617          	auipc	a2,0x2e
    80004d8a:	3c660613          	addi	a2,a2,966 # 8003314c <log+0x34>
    80004d8e:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004d90:	4390                	lw	a2,0(a5)
    80004d92:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004d94:	0791                	addi	a5,a5,4
    80004d96:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80004d98:	fed79ce3          	bne	a5,a3,80004d90 <write_head+0x50>
  }
  bwrite(buf);
    80004d9c:	8526                	mv	a0,s1
    80004d9e:	fffff097          	auipc	ra,0xfffff
    80004da2:	09c080e7          	jalr	156(ra) # 80003e3a <bwrite>
  brelse(buf);
    80004da6:	8526                	mv	a0,s1
    80004da8:	fffff097          	auipc	ra,0xfffff
    80004dac:	0d0080e7          	jalr	208(ra) # 80003e78 <brelse>
}
    80004db0:	60e2                	ld	ra,24(sp)
    80004db2:	6442                	ld	s0,16(sp)
    80004db4:	64a2                	ld	s1,8(sp)
    80004db6:	6902                	ld	s2,0(sp)
    80004db8:	6105                	addi	sp,sp,32
    80004dba:	8082                	ret

0000000080004dbc <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004dbc:	0002e797          	auipc	a5,0x2e
    80004dc0:	3887a783          	lw	a5,904(a5) # 80033144 <log+0x2c>
    80004dc4:	0af05d63          	blez	a5,80004e7e <install_trans+0xc2>
{
    80004dc8:	7139                	addi	sp,sp,-64
    80004dca:	fc06                	sd	ra,56(sp)
    80004dcc:	f822                	sd	s0,48(sp)
    80004dce:	f426                	sd	s1,40(sp)
    80004dd0:	f04a                	sd	s2,32(sp)
    80004dd2:	ec4e                	sd	s3,24(sp)
    80004dd4:	e852                	sd	s4,16(sp)
    80004dd6:	e456                	sd	s5,8(sp)
    80004dd8:	e05a                	sd	s6,0(sp)
    80004dda:	0080                	addi	s0,sp,64
    80004ddc:	8b2a                	mv	s6,a0
    80004dde:	0002ea97          	auipc	s5,0x2e
    80004de2:	36aa8a93          	addi	s5,s5,874 # 80033148 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004de6:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004de8:	0002e997          	auipc	s3,0x2e
    80004dec:	33098993          	addi	s3,s3,816 # 80033118 <log>
    80004df0:	a00d                	j	80004e12 <install_trans+0x56>
    brelse(lbuf);
    80004df2:	854a                	mv	a0,s2
    80004df4:	fffff097          	auipc	ra,0xfffff
    80004df8:	084080e7          	jalr	132(ra) # 80003e78 <brelse>
    brelse(dbuf);
    80004dfc:	8526                	mv	a0,s1
    80004dfe:	fffff097          	auipc	ra,0xfffff
    80004e02:	07a080e7          	jalr	122(ra) # 80003e78 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004e06:	2a05                	addiw	s4,s4,1
    80004e08:	0a91                	addi	s5,s5,4
    80004e0a:	02c9a783          	lw	a5,44(s3)
    80004e0e:	04fa5e63          	bge	s4,a5,80004e6a <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004e12:	0189a583          	lw	a1,24(s3)
    80004e16:	014585bb          	addw	a1,a1,s4
    80004e1a:	2585                	addiw	a1,a1,1
    80004e1c:	0289a503          	lw	a0,40(s3)
    80004e20:	fffff097          	auipc	ra,0xfffff
    80004e24:	f28080e7          	jalr	-216(ra) # 80003d48 <bread>
    80004e28:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004e2a:	000aa583          	lw	a1,0(s5)
    80004e2e:	0289a503          	lw	a0,40(s3)
    80004e32:	fffff097          	auipc	ra,0xfffff
    80004e36:	f16080e7          	jalr	-234(ra) # 80003d48 <bread>
    80004e3a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004e3c:	40000613          	li	a2,1024
    80004e40:	05890593          	addi	a1,s2,88
    80004e44:	05850513          	addi	a0,a0,88
    80004e48:	ffffc097          	auipc	ra,0xffffc
    80004e4c:	f28080e7          	jalr	-216(ra) # 80000d70 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004e50:	8526                	mv	a0,s1
    80004e52:	fffff097          	auipc	ra,0xfffff
    80004e56:	fe8080e7          	jalr	-24(ra) # 80003e3a <bwrite>
    if(recovering == 0)
    80004e5a:	f80b1ce3          	bnez	s6,80004df2 <install_trans+0x36>
      bunpin(dbuf);
    80004e5e:	8526                	mv	a0,s1
    80004e60:	fffff097          	auipc	ra,0xfffff
    80004e64:	0f2080e7          	jalr	242(ra) # 80003f52 <bunpin>
    80004e68:	b769                	j	80004df2 <install_trans+0x36>
}
    80004e6a:	70e2                	ld	ra,56(sp)
    80004e6c:	7442                	ld	s0,48(sp)
    80004e6e:	74a2                	ld	s1,40(sp)
    80004e70:	7902                	ld	s2,32(sp)
    80004e72:	69e2                	ld	s3,24(sp)
    80004e74:	6a42                	ld	s4,16(sp)
    80004e76:	6aa2                	ld	s5,8(sp)
    80004e78:	6b02                	ld	s6,0(sp)
    80004e7a:	6121                	addi	sp,sp,64
    80004e7c:	8082                	ret
    80004e7e:	8082                	ret

0000000080004e80 <initlog>:
{
    80004e80:	7179                	addi	sp,sp,-48
    80004e82:	f406                	sd	ra,40(sp)
    80004e84:	f022                	sd	s0,32(sp)
    80004e86:	ec26                	sd	s1,24(sp)
    80004e88:	e84a                	sd	s2,16(sp)
    80004e8a:	e44e                	sd	s3,8(sp)
    80004e8c:	1800                	addi	s0,sp,48
    80004e8e:	892a                	mv	s2,a0
    80004e90:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004e92:	0002e497          	auipc	s1,0x2e
    80004e96:	28648493          	addi	s1,s1,646 # 80033118 <log>
    80004e9a:	00005597          	auipc	a1,0x5
    80004e9e:	84e58593          	addi	a1,a1,-1970 # 800096e8 <syscalls+0x220>
    80004ea2:	8526                	mv	a0,s1
    80004ea4:	ffffc097          	auipc	ra,0xffffc
    80004ea8:	ce4080e7          	jalr	-796(ra) # 80000b88 <initlock>
  log.start = sb->logstart;
    80004eac:	0149a583          	lw	a1,20(s3)
    80004eb0:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004eb2:	0109a783          	lw	a5,16(s3)
    80004eb6:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004eb8:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004ebc:	854a                	mv	a0,s2
    80004ebe:	fffff097          	auipc	ra,0xfffff
    80004ec2:	e8a080e7          	jalr	-374(ra) # 80003d48 <bread>
  log.lh.n = lh->n;
    80004ec6:	4d34                	lw	a3,88(a0)
    80004ec8:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004eca:	02d05663          	blez	a3,80004ef6 <initlog+0x76>
    80004ece:	05c50793          	addi	a5,a0,92
    80004ed2:	0002e717          	auipc	a4,0x2e
    80004ed6:	27670713          	addi	a4,a4,630 # 80033148 <log+0x30>
    80004eda:	36fd                	addiw	a3,a3,-1
    80004edc:	02069613          	slli	a2,a3,0x20
    80004ee0:	01e65693          	srli	a3,a2,0x1e
    80004ee4:	06050613          	addi	a2,a0,96
    80004ee8:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004eea:	4390                	lw	a2,0(a5)
    80004eec:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004eee:	0791                	addi	a5,a5,4
    80004ef0:	0711                	addi	a4,a4,4
    80004ef2:	fed79ce3          	bne	a5,a3,80004eea <initlog+0x6a>
  brelse(buf);
    80004ef6:	fffff097          	auipc	ra,0xfffff
    80004efa:	f82080e7          	jalr	-126(ra) # 80003e78 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004efe:	4505                	li	a0,1
    80004f00:	00000097          	auipc	ra,0x0
    80004f04:	ebc080e7          	jalr	-324(ra) # 80004dbc <install_trans>
  log.lh.n = 0;
    80004f08:	0002e797          	auipc	a5,0x2e
    80004f0c:	2207ae23          	sw	zero,572(a5) # 80033144 <log+0x2c>
  write_head(); // clear the log
    80004f10:	00000097          	auipc	ra,0x0
    80004f14:	e30080e7          	jalr	-464(ra) # 80004d40 <write_head>
}
    80004f18:	70a2                	ld	ra,40(sp)
    80004f1a:	7402                	ld	s0,32(sp)
    80004f1c:	64e2                	ld	s1,24(sp)
    80004f1e:	6942                	ld	s2,16(sp)
    80004f20:	69a2                	ld	s3,8(sp)
    80004f22:	6145                	addi	sp,sp,48
    80004f24:	8082                	ret

0000000080004f26 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004f26:	1101                	addi	sp,sp,-32
    80004f28:	ec06                	sd	ra,24(sp)
    80004f2a:	e822                	sd	s0,16(sp)
    80004f2c:	e426                	sd	s1,8(sp)
    80004f2e:	e04a                	sd	s2,0(sp)
    80004f30:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004f32:	0002e517          	auipc	a0,0x2e
    80004f36:	1e650513          	addi	a0,a0,486 # 80033118 <log>
    80004f3a:	ffffc097          	auipc	ra,0xffffc
    80004f3e:	cde080e7          	jalr	-802(ra) # 80000c18 <acquire>
  while(1){
    if(log.committing){
    80004f42:	0002e497          	auipc	s1,0x2e
    80004f46:	1d648493          	addi	s1,s1,470 # 80033118 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004f4a:	4979                	li	s2,30
    80004f4c:	a039                	j	80004f5a <begin_op+0x34>
      sleep(&log, &log.lock);
    80004f4e:	85a6                	mv	a1,s1
    80004f50:	8526                	mv	a0,s1
    80004f52:	ffffd097          	auipc	ra,0xffffd
    80004f56:	2d2080e7          	jalr	722(ra) # 80002224 <sleep>
    if(log.committing){
    80004f5a:	50dc                	lw	a5,36(s1)
    80004f5c:	fbed                	bnez	a5,80004f4e <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004f5e:	5098                	lw	a4,32(s1)
    80004f60:	2705                	addiw	a4,a4,1
    80004f62:	0007069b          	sext.w	a3,a4
    80004f66:	0027179b          	slliw	a5,a4,0x2
    80004f6a:	9fb9                	addw	a5,a5,a4
    80004f6c:	0017979b          	slliw	a5,a5,0x1
    80004f70:	54d8                	lw	a4,44(s1)
    80004f72:	9fb9                	addw	a5,a5,a4
    80004f74:	00f95963          	bge	s2,a5,80004f86 <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004f78:	85a6                	mv	a1,s1
    80004f7a:	8526                	mv	a0,s1
    80004f7c:	ffffd097          	auipc	ra,0xffffd
    80004f80:	2a8080e7          	jalr	680(ra) # 80002224 <sleep>
    80004f84:	bfd9                	j	80004f5a <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004f86:	0002e517          	auipc	a0,0x2e
    80004f8a:	19250513          	addi	a0,a0,402 # 80033118 <log>
    80004f8e:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004f90:	ffffc097          	auipc	ra,0xffffc
    80004f94:	d3c080e7          	jalr	-708(ra) # 80000ccc <release>
      break;
    }
  }
}
    80004f98:	60e2                	ld	ra,24(sp)
    80004f9a:	6442                	ld	s0,16(sp)
    80004f9c:	64a2                	ld	s1,8(sp)
    80004f9e:	6902                	ld	s2,0(sp)
    80004fa0:	6105                	addi	sp,sp,32
    80004fa2:	8082                	ret

0000000080004fa4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004fa4:	7139                	addi	sp,sp,-64
    80004fa6:	fc06                	sd	ra,56(sp)
    80004fa8:	f822                	sd	s0,48(sp)
    80004faa:	f426                	sd	s1,40(sp)
    80004fac:	f04a                	sd	s2,32(sp)
    80004fae:	ec4e                	sd	s3,24(sp)
    80004fb0:	e852                	sd	s4,16(sp)
    80004fb2:	e456                	sd	s5,8(sp)
    80004fb4:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004fb6:	0002e497          	auipc	s1,0x2e
    80004fba:	16248493          	addi	s1,s1,354 # 80033118 <log>
    80004fbe:	8526                	mv	a0,s1
    80004fc0:	ffffc097          	auipc	ra,0xffffc
    80004fc4:	c58080e7          	jalr	-936(ra) # 80000c18 <acquire>
  log.outstanding -= 1;
    80004fc8:	509c                	lw	a5,32(s1)
    80004fca:	37fd                	addiw	a5,a5,-1
    80004fcc:	0007891b          	sext.w	s2,a5
    80004fd0:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004fd2:	50dc                	lw	a5,36(s1)
    80004fd4:	e7b9                	bnez	a5,80005022 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004fd6:	04091e63          	bnez	s2,80005032 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004fda:	0002e497          	auipc	s1,0x2e
    80004fde:	13e48493          	addi	s1,s1,318 # 80033118 <log>
    80004fe2:	4785                	li	a5,1
    80004fe4:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004fe6:	8526                	mv	a0,s1
    80004fe8:	ffffc097          	auipc	ra,0xffffc
    80004fec:	ce4080e7          	jalr	-796(ra) # 80000ccc <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004ff0:	54dc                	lw	a5,44(s1)
    80004ff2:	06f04763          	bgtz	a5,80005060 <end_op+0xbc>
    acquire(&log.lock);
    80004ff6:	0002e497          	auipc	s1,0x2e
    80004ffa:	12248493          	addi	s1,s1,290 # 80033118 <log>
    80004ffe:	8526                	mv	a0,s1
    80005000:	ffffc097          	auipc	ra,0xffffc
    80005004:	c18080e7          	jalr	-1000(ra) # 80000c18 <acquire>
    log.committing = 0;
    80005008:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000500c:	8526                	mv	a0,s1
    8000500e:	ffffd097          	auipc	ra,0xffffd
    80005012:	27a080e7          	jalr	634(ra) # 80002288 <wakeup>
    release(&log.lock);
    80005016:	8526                	mv	a0,s1
    80005018:	ffffc097          	auipc	ra,0xffffc
    8000501c:	cb4080e7          	jalr	-844(ra) # 80000ccc <release>
}
    80005020:	a03d                	j	8000504e <end_op+0xaa>
    panic("log.committing");
    80005022:	00004517          	auipc	a0,0x4
    80005026:	6ce50513          	addi	a0,a0,1742 # 800096f0 <syscalls+0x228>
    8000502a:	ffffb097          	auipc	ra,0xffffb
    8000502e:	510080e7          	jalr	1296(ra) # 8000053a <panic>
    wakeup(&log);
    80005032:	0002e497          	auipc	s1,0x2e
    80005036:	0e648493          	addi	s1,s1,230 # 80033118 <log>
    8000503a:	8526                	mv	a0,s1
    8000503c:	ffffd097          	auipc	ra,0xffffd
    80005040:	24c080e7          	jalr	588(ra) # 80002288 <wakeup>
  release(&log.lock);
    80005044:	8526                	mv	a0,s1
    80005046:	ffffc097          	auipc	ra,0xffffc
    8000504a:	c86080e7          	jalr	-890(ra) # 80000ccc <release>
}
    8000504e:	70e2                	ld	ra,56(sp)
    80005050:	7442                	ld	s0,48(sp)
    80005052:	74a2                	ld	s1,40(sp)
    80005054:	7902                	ld	s2,32(sp)
    80005056:	69e2                	ld	s3,24(sp)
    80005058:	6a42                	ld	s4,16(sp)
    8000505a:	6aa2                	ld	s5,8(sp)
    8000505c:	6121                	addi	sp,sp,64
    8000505e:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80005060:	0002ea97          	auipc	s5,0x2e
    80005064:	0e8a8a93          	addi	s5,s5,232 # 80033148 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80005068:	0002ea17          	auipc	s4,0x2e
    8000506c:	0b0a0a13          	addi	s4,s4,176 # 80033118 <log>
    80005070:	018a2583          	lw	a1,24(s4)
    80005074:	012585bb          	addw	a1,a1,s2
    80005078:	2585                	addiw	a1,a1,1
    8000507a:	028a2503          	lw	a0,40(s4)
    8000507e:	fffff097          	auipc	ra,0xfffff
    80005082:	cca080e7          	jalr	-822(ra) # 80003d48 <bread>
    80005086:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80005088:	000aa583          	lw	a1,0(s5)
    8000508c:	028a2503          	lw	a0,40(s4)
    80005090:	fffff097          	auipc	ra,0xfffff
    80005094:	cb8080e7          	jalr	-840(ra) # 80003d48 <bread>
    80005098:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000509a:	40000613          	li	a2,1024
    8000509e:	05850593          	addi	a1,a0,88
    800050a2:	05848513          	addi	a0,s1,88
    800050a6:	ffffc097          	auipc	ra,0xffffc
    800050aa:	cca080e7          	jalr	-822(ra) # 80000d70 <memmove>
    bwrite(to);  // write the log
    800050ae:	8526                	mv	a0,s1
    800050b0:	fffff097          	auipc	ra,0xfffff
    800050b4:	d8a080e7          	jalr	-630(ra) # 80003e3a <bwrite>
    brelse(from);
    800050b8:	854e                	mv	a0,s3
    800050ba:	fffff097          	auipc	ra,0xfffff
    800050be:	dbe080e7          	jalr	-578(ra) # 80003e78 <brelse>
    brelse(to);
    800050c2:	8526                	mv	a0,s1
    800050c4:	fffff097          	auipc	ra,0xfffff
    800050c8:	db4080e7          	jalr	-588(ra) # 80003e78 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800050cc:	2905                	addiw	s2,s2,1
    800050ce:	0a91                	addi	s5,s5,4
    800050d0:	02ca2783          	lw	a5,44(s4)
    800050d4:	f8f94ee3          	blt	s2,a5,80005070 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800050d8:	00000097          	auipc	ra,0x0
    800050dc:	c68080e7          	jalr	-920(ra) # 80004d40 <write_head>
    install_trans(0); // Now install writes to home locations
    800050e0:	4501                	li	a0,0
    800050e2:	00000097          	auipc	ra,0x0
    800050e6:	cda080e7          	jalr	-806(ra) # 80004dbc <install_trans>
    log.lh.n = 0;
    800050ea:	0002e797          	auipc	a5,0x2e
    800050ee:	0407ad23          	sw	zero,90(a5) # 80033144 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800050f2:	00000097          	auipc	ra,0x0
    800050f6:	c4e080e7          	jalr	-946(ra) # 80004d40 <write_head>
    800050fa:	bdf5                	j	80004ff6 <end_op+0x52>

00000000800050fc <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800050fc:	1101                	addi	sp,sp,-32
    800050fe:	ec06                	sd	ra,24(sp)
    80005100:	e822                	sd	s0,16(sp)
    80005102:	e426                	sd	s1,8(sp)
    80005104:	e04a                	sd	s2,0(sp)
    80005106:	1000                	addi	s0,sp,32
    80005108:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000510a:	0002e917          	auipc	s2,0x2e
    8000510e:	00e90913          	addi	s2,s2,14 # 80033118 <log>
    80005112:	854a                	mv	a0,s2
    80005114:	ffffc097          	auipc	ra,0xffffc
    80005118:	b04080e7          	jalr	-1276(ra) # 80000c18 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000511c:	02c92603          	lw	a2,44(s2)
    80005120:	47f5                	li	a5,29
    80005122:	06c7c563          	blt	a5,a2,8000518c <log_write+0x90>
    80005126:	0002e797          	auipc	a5,0x2e
    8000512a:	00e7a783          	lw	a5,14(a5) # 80033134 <log+0x1c>
    8000512e:	37fd                	addiw	a5,a5,-1
    80005130:	04f65e63          	bge	a2,a5,8000518c <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80005134:	0002e797          	auipc	a5,0x2e
    80005138:	0047a783          	lw	a5,4(a5) # 80033138 <log+0x20>
    8000513c:	06f05063          	blez	a5,8000519c <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80005140:	4781                	li	a5,0
    80005142:	06c05563          	blez	a2,800051ac <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80005146:	44cc                	lw	a1,12(s1)
    80005148:	0002e717          	auipc	a4,0x2e
    8000514c:	00070713          	mv	a4,a4
  for (i = 0; i < log.lh.n; i++) {
    80005150:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80005152:	4314                	lw	a3,0(a4)
    80005154:	04b68c63          	beq	a3,a1,800051ac <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80005158:	2785                	addiw	a5,a5,1
    8000515a:	0711                	addi	a4,a4,4 # 8003314c <log+0x34>
    8000515c:	fef61be3          	bne	a2,a5,80005152 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80005160:	0621                	addi	a2,a2,8
    80005162:	060a                	slli	a2,a2,0x2
    80005164:	0002e797          	auipc	a5,0x2e
    80005168:	fb478793          	addi	a5,a5,-76 # 80033118 <log>
    8000516c:	97b2                	add	a5,a5,a2
    8000516e:	44d8                	lw	a4,12(s1)
    80005170:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80005172:	8526                	mv	a0,s1
    80005174:	fffff097          	auipc	ra,0xfffff
    80005178:	da2080e7          	jalr	-606(ra) # 80003f16 <bpin>
    log.lh.n++;
    8000517c:	0002e717          	auipc	a4,0x2e
    80005180:	f9c70713          	addi	a4,a4,-100 # 80033118 <log>
    80005184:	575c                	lw	a5,44(a4)
    80005186:	2785                	addiw	a5,a5,1
    80005188:	d75c                	sw	a5,44(a4)
    8000518a:	a82d                	j	800051c4 <log_write+0xc8>
    panic("too big a transaction");
    8000518c:	00004517          	auipc	a0,0x4
    80005190:	57450513          	addi	a0,a0,1396 # 80009700 <syscalls+0x238>
    80005194:	ffffb097          	auipc	ra,0xffffb
    80005198:	3a6080e7          	jalr	934(ra) # 8000053a <panic>
    panic("log_write outside of trans");
    8000519c:	00004517          	auipc	a0,0x4
    800051a0:	57c50513          	addi	a0,a0,1404 # 80009718 <syscalls+0x250>
    800051a4:	ffffb097          	auipc	ra,0xffffb
    800051a8:	396080e7          	jalr	918(ra) # 8000053a <panic>
  log.lh.block[i] = b->blockno;
    800051ac:	00878693          	addi	a3,a5,8
    800051b0:	068a                	slli	a3,a3,0x2
    800051b2:	0002e717          	auipc	a4,0x2e
    800051b6:	f6670713          	addi	a4,a4,-154 # 80033118 <log>
    800051ba:	9736                	add	a4,a4,a3
    800051bc:	44d4                	lw	a3,12(s1)
    800051be:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800051c0:	faf609e3          	beq	a2,a5,80005172 <log_write+0x76>
  }
  release(&log.lock);
    800051c4:	0002e517          	auipc	a0,0x2e
    800051c8:	f5450513          	addi	a0,a0,-172 # 80033118 <log>
    800051cc:	ffffc097          	auipc	ra,0xffffc
    800051d0:	b00080e7          	jalr	-1280(ra) # 80000ccc <release>
}
    800051d4:	60e2                	ld	ra,24(sp)
    800051d6:	6442                	ld	s0,16(sp)
    800051d8:	64a2                	ld	s1,8(sp)
    800051da:	6902                	ld	s2,0(sp)
    800051dc:	6105                	addi	sp,sp,32
    800051de:	8082                	ret

00000000800051e0 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800051e0:	1101                	addi	sp,sp,-32
    800051e2:	ec06                	sd	ra,24(sp)
    800051e4:	e822                	sd	s0,16(sp)
    800051e6:	e426                	sd	s1,8(sp)
    800051e8:	e04a                	sd	s2,0(sp)
    800051ea:	1000                	addi	s0,sp,32
    800051ec:	84aa                	mv	s1,a0
    800051ee:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800051f0:	00004597          	auipc	a1,0x4
    800051f4:	54858593          	addi	a1,a1,1352 # 80009738 <syscalls+0x270>
    800051f8:	0521                	addi	a0,a0,8
    800051fa:	ffffc097          	auipc	ra,0xffffc
    800051fe:	98e080e7          	jalr	-1650(ra) # 80000b88 <initlock>
  lk->name = name;
    80005202:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80005206:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000520a:	0204a423          	sw	zero,40(s1)
}
    8000520e:	60e2                	ld	ra,24(sp)
    80005210:	6442                	ld	s0,16(sp)
    80005212:	64a2                	ld	s1,8(sp)
    80005214:	6902                	ld	s2,0(sp)
    80005216:	6105                	addi	sp,sp,32
    80005218:	8082                	ret

000000008000521a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000521a:	1101                	addi	sp,sp,-32
    8000521c:	ec06                	sd	ra,24(sp)
    8000521e:	e822                	sd	s0,16(sp)
    80005220:	e426                	sd	s1,8(sp)
    80005222:	e04a                	sd	s2,0(sp)
    80005224:	1000                	addi	s0,sp,32
    80005226:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005228:	00850913          	addi	s2,a0,8
    8000522c:	854a                	mv	a0,s2
    8000522e:	ffffc097          	auipc	ra,0xffffc
    80005232:	9ea080e7          	jalr	-1558(ra) # 80000c18 <acquire>
  while (lk->locked) {
    80005236:	409c                	lw	a5,0(s1)
    80005238:	cb89                	beqz	a5,8000524a <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000523a:	85ca                	mv	a1,s2
    8000523c:	8526                	mv	a0,s1
    8000523e:	ffffd097          	auipc	ra,0xffffd
    80005242:	fe6080e7          	jalr	-26(ra) # 80002224 <sleep>
  while (lk->locked) {
    80005246:	409c                	lw	a5,0(s1)
    80005248:	fbed                	bnez	a5,8000523a <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000524a:	4785                	li	a5,1
    8000524c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000524e:	ffffd097          	auipc	ra,0xffffd
    80005252:	b6e080e7          	jalr	-1170(ra) # 80001dbc <myproc>
    80005256:	591c                	lw	a5,48(a0)
    80005258:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000525a:	854a                	mv	a0,s2
    8000525c:	ffffc097          	auipc	ra,0xffffc
    80005260:	a70080e7          	jalr	-1424(ra) # 80000ccc <release>
}
    80005264:	60e2                	ld	ra,24(sp)
    80005266:	6442                	ld	s0,16(sp)
    80005268:	64a2                	ld	s1,8(sp)
    8000526a:	6902                	ld	s2,0(sp)
    8000526c:	6105                	addi	sp,sp,32
    8000526e:	8082                	ret

0000000080005270 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80005270:	1101                	addi	sp,sp,-32
    80005272:	ec06                	sd	ra,24(sp)
    80005274:	e822                	sd	s0,16(sp)
    80005276:	e426                	sd	s1,8(sp)
    80005278:	e04a                	sd	s2,0(sp)
    8000527a:	1000                	addi	s0,sp,32
    8000527c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000527e:	00850913          	addi	s2,a0,8
    80005282:	854a                	mv	a0,s2
    80005284:	ffffc097          	auipc	ra,0xffffc
    80005288:	994080e7          	jalr	-1644(ra) # 80000c18 <acquire>
  lk->locked = 0;
    8000528c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80005290:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80005294:	8526                	mv	a0,s1
    80005296:	ffffd097          	auipc	ra,0xffffd
    8000529a:	ff2080e7          	jalr	-14(ra) # 80002288 <wakeup>
  release(&lk->lk);
    8000529e:	854a                	mv	a0,s2
    800052a0:	ffffc097          	auipc	ra,0xffffc
    800052a4:	a2c080e7          	jalr	-1492(ra) # 80000ccc <release>
}
    800052a8:	60e2                	ld	ra,24(sp)
    800052aa:	6442                	ld	s0,16(sp)
    800052ac:	64a2                	ld	s1,8(sp)
    800052ae:	6902                	ld	s2,0(sp)
    800052b0:	6105                	addi	sp,sp,32
    800052b2:	8082                	ret

00000000800052b4 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800052b4:	7179                	addi	sp,sp,-48
    800052b6:	f406                	sd	ra,40(sp)
    800052b8:	f022                	sd	s0,32(sp)
    800052ba:	ec26                	sd	s1,24(sp)
    800052bc:	e84a                	sd	s2,16(sp)
    800052be:	e44e                	sd	s3,8(sp)
    800052c0:	1800                	addi	s0,sp,48
    800052c2:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800052c4:	00850913          	addi	s2,a0,8
    800052c8:	854a                	mv	a0,s2
    800052ca:	ffffc097          	auipc	ra,0xffffc
    800052ce:	94e080e7          	jalr	-1714(ra) # 80000c18 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800052d2:	409c                	lw	a5,0(s1)
    800052d4:	ef99                	bnez	a5,800052f2 <holdingsleep+0x3e>
    800052d6:	4481                	li	s1,0
  release(&lk->lk);
    800052d8:	854a                	mv	a0,s2
    800052da:	ffffc097          	auipc	ra,0xffffc
    800052de:	9f2080e7          	jalr	-1550(ra) # 80000ccc <release>
  return r;
}
    800052e2:	8526                	mv	a0,s1
    800052e4:	70a2                	ld	ra,40(sp)
    800052e6:	7402                	ld	s0,32(sp)
    800052e8:	64e2                	ld	s1,24(sp)
    800052ea:	6942                	ld	s2,16(sp)
    800052ec:	69a2                	ld	s3,8(sp)
    800052ee:	6145                	addi	sp,sp,48
    800052f0:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800052f2:	0284a983          	lw	s3,40(s1)
    800052f6:	ffffd097          	auipc	ra,0xffffd
    800052fa:	ac6080e7          	jalr	-1338(ra) # 80001dbc <myproc>
    800052fe:	5904                	lw	s1,48(a0)
    80005300:	413484b3          	sub	s1,s1,s3
    80005304:	0014b493          	seqz	s1,s1
    80005308:	bfc1                	j	800052d8 <holdingsleep+0x24>

000000008000530a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000530a:	1141                	addi	sp,sp,-16
    8000530c:	e406                	sd	ra,8(sp)
    8000530e:	e022                	sd	s0,0(sp)
    80005310:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80005312:	00004597          	auipc	a1,0x4
    80005316:	43658593          	addi	a1,a1,1078 # 80009748 <syscalls+0x280>
    8000531a:	0002e517          	auipc	a0,0x2e
    8000531e:	f4650513          	addi	a0,a0,-186 # 80033260 <ftable>
    80005322:	ffffc097          	auipc	ra,0xffffc
    80005326:	866080e7          	jalr	-1946(ra) # 80000b88 <initlock>
}
    8000532a:	60a2                	ld	ra,8(sp)
    8000532c:	6402                	ld	s0,0(sp)
    8000532e:	0141                	addi	sp,sp,16
    80005330:	8082                	ret

0000000080005332 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80005332:	1101                	addi	sp,sp,-32
    80005334:	ec06                	sd	ra,24(sp)
    80005336:	e822                	sd	s0,16(sp)
    80005338:	e426                	sd	s1,8(sp)
    8000533a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000533c:	0002e517          	auipc	a0,0x2e
    80005340:	f2450513          	addi	a0,a0,-220 # 80033260 <ftable>
    80005344:	ffffc097          	auipc	ra,0xffffc
    80005348:	8d4080e7          	jalr	-1836(ra) # 80000c18 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000534c:	0002e497          	auipc	s1,0x2e
    80005350:	f2c48493          	addi	s1,s1,-212 # 80033278 <ftable+0x18>
    80005354:	0002f717          	auipc	a4,0x2f
    80005358:	ec470713          	addi	a4,a4,-316 # 80034218 <ftable+0xfb8>
    if(f->ref == 0){
    8000535c:	40dc                	lw	a5,4(s1)
    8000535e:	cf99                	beqz	a5,8000537c <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80005360:	02848493          	addi	s1,s1,40
    80005364:	fee49ce3          	bne	s1,a4,8000535c <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80005368:	0002e517          	auipc	a0,0x2e
    8000536c:	ef850513          	addi	a0,a0,-264 # 80033260 <ftable>
    80005370:	ffffc097          	auipc	ra,0xffffc
    80005374:	95c080e7          	jalr	-1700(ra) # 80000ccc <release>
  return 0;
    80005378:	4481                	li	s1,0
    8000537a:	a819                	j	80005390 <filealloc+0x5e>
      f->ref = 1;
    8000537c:	4785                	li	a5,1
    8000537e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80005380:	0002e517          	auipc	a0,0x2e
    80005384:	ee050513          	addi	a0,a0,-288 # 80033260 <ftable>
    80005388:	ffffc097          	auipc	ra,0xffffc
    8000538c:	944080e7          	jalr	-1724(ra) # 80000ccc <release>
}
    80005390:	8526                	mv	a0,s1
    80005392:	60e2                	ld	ra,24(sp)
    80005394:	6442                	ld	s0,16(sp)
    80005396:	64a2                	ld	s1,8(sp)
    80005398:	6105                	addi	sp,sp,32
    8000539a:	8082                	ret

000000008000539c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000539c:	1101                	addi	sp,sp,-32
    8000539e:	ec06                	sd	ra,24(sp)
    800053a0:	e822                	sd	s0,16(sp)
    800053a2:	e426                	sd	s1,8(sp)
    800053a4:	1000                	addi	s0,sp,32
    800053a6:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800053a8:	0002e517          	auipc	a0,0x2e
    800053ac:	eb850513          	addi	a0,a0,-328 # 80033260 <ftable>
    800053b0:	ffffc097          	auipc	ra,0xffffc
    800053b4:	868080e7          	jalr	-1944(ra) # 80000c18 <acquire>
  if(f->ref < 1)
    800053b8:	40dc                	lw	a5,4(s1)
    800053ba:	02f05263          	blez	a5,800053de <filedup+0x42>
    panic("filedup");
  f->ref++;
    800053be:	2785                	addiw	a5,a5,1
    800053c0:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800053c2:	0002e517          	auipc	a0,0x2e
    800053c6:	e9e50513          	addi	a0,a0,-354 # 80033260 <ftable>
    800053ca:	ffffc097          	auipc	ra,0xffffc
    800053ce:	902080e7          	jalr	-1790(ra) # 80000ccc <release>
  return f;
}
    800053d2:	8526                	mv	a0,s1
    800053d4:	60e2                	ld	ra,24(sp)
    800053d6:	6442                	ld	s0,16(sp)
    800053d8:	64a2                	ld	s1,8(sp)
    800053da:	6105                	addi	sp,sp,32
    800053dc:	8082                	ret
    panic("filedup");
    800053de:	00004517          	auipc	a0,0x4
    800053e2:	37250513          	addi	a0,a0,882 # 80009750 <syscalls+0x288>
    800053e6:	ffffb097          	auipc	ra,0xffffb
    800053ea:	154080e7          	jalr	340(ra) # 8000053a <panic>

00000000800053ee <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800053ee:	7139                	addi	sp,sp,-64
    800053f0:	fc06                	sd	ra,56(sp)
    800053f2:	f822                	sd	s0,48(sp)
    800053f4:	f426                	sd	s1,40(sp)
    800053f6:	f04a                	sd	s2,32(sp)
    800053f8:	ec4e                	sd	s3,24(sp)
    800053fa:	e852                	sd	s4,16(sp)
    800053fc:	e456                	sd	s5,8(sp)
    800053fe:	0080                	addi	s0,sp,64
    80005400:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80005402:	0002e517          	auipc	a0,0x2e
    80005406:	e5e50513          	addi	a0,a0,-418 # 80033260 <ftable>
    8000540a:	ffffc097          	auipc	ra,0xffffc
    8000540e:	80e080e7          	jalr	-2034(ra) # 80000c18 <acquire>
  if(f->ref < 1)
    80005412:	40dc                	lw	a5,4(s1)
    80005414:	06f05163          	blez	a5,80005476 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80005418:	37fd                	addiw	a5,a5,-1
    8000541a:	0007871b          	sext.w	a4,a5
    8000541e:	c0dc                	sw	a5,4(s1)
    80005420:	06e04363          	bgtz	a4,80005486 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80005424:	0004a903          	lw	s2,0(s1)
    80005428:	0094ca83          	lbu	s5,9(s1)
    8000542c:	0104ba03          	ld	s4,16(s1)
    80005430:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80005434:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80005438:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000543c:	0002e517          	auipc	a0,0x2e
    80005440:	e2450513          	addi	a0,a0,-476 # 80033260 <ftable>
    80005444:	ffffc097          	auipc	ra,0xffffc
    80005448:	888080e7          	jalr	-1912(ra) # 80000ccc <release>

  if(ff.type == FD_PIPE){
    8000544c:	4785                	li	a5,1
    8000544e:	04f90d63          	beq	s2,a5,800054a8 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80005452:	3979                	addiw	s2,s2,-2
    80005454:	4785                	li	a5,1
    80005456:	0527e063          	bltu	a5,s2,80005496 <fileclose+0xa8>
    begin_op();
    8000545a:	00000097          	auipc	ra,0x0
    8000545e:	acc080e7          	jalr	-1332(ra) # 80004f26 <begin_op>
    iput(ff.ip);
    80005462:	854e                	mv	a0,s3
    80005464:	fffff097          	auipc	ra,0xfffff
    80005468:	2a0080e7          	jalr	672(ra) # 80004704 <iput>
    end_op();
    8000546c:	00000097          	auipc	ra,0x0
    80005470:	b38080e7          	jalr	-1224(ra) # 80004fa4 <end_op>
    80005474:	a00d                	j	80005496 <fileclose+0xa8>
    panic("fileclose");
    80005476:	00004517          	auipc	a0,0x4
    8000547a:	2e250513          	addi	a0,a0,738 # 80009758 <syscalls+0x290>
    8000547e:	ffffb097          	auipc	ra,0xffffb
    80005482:	0bc080e7          	jalr	188(ra) # 8000053a <panic>
    release(&ftable.lock);
    80005486:	0002e517          	auipc	a0,0x2e
    8000548a:	dda50513          	addi	a0,a0,-550 # 80033260 <ftable>
    8000548e:	ffffc097          	auipc	ra,0xffffc
    80005492:	83e080e7          	jalr	-1986(ra) # 80000ccc <release>
  }
}
    80005496:	70e2                	ld	ra,56(sp)
    80005498:	7442                	ld	s0,48(sp)
    8000549a:	74a2                	ld	s1,40(sp)
    8000549c:	7902                	ld	s2,32(sp)
    8000549e:	69e2                	ld	s3,24(sp)
    800054a0:	6a42                	ld	s4,16(sp)
    800054a2:	6aa2                	ld	s5,8(sp)
    800054a4:	6121                	addi	sp,sp,64
    800054a6:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800054a8:	85d6                	mv	a1,s5
    800054aa:	8552                	mv	a0,s4
    800054ac:	00000097          	auipc	ra,0x0
    800054b0:	34c080e7          	jalr	844(ra) # 800057f8 <pipeclose>
    800054b4:	b7cd                	j	80005496 <fileclose+0xa8>

00000000800054b6 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800054b6:	715d                	addi	sp,sp,-80
    800054b8:	e486                	sd	ra,72(sp)
    800054ba:	e0a2                	sd	s0,64(sp)
    800054bc:	fc26                	sd	s1,56(sp)
    800054be:	f84a                	sd	s2,48(sp)
    800054c0:	f44e                	sd	s3,40(sp)
    800054c2:	0880                	addi	s0,sp,80
    800054c4:	84aa                	mv	s1,a0
    800054c6:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800054c8:	ffffd097          	auipc	ra,0xffffd
    800054cc:	8f4080e7          	jalr	-1804(ra) # 80001dbc <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800054d0:	409c                	lw	a5,0(s1)
    800054d2:	37f9                	addiw	a5,a5,-2
    800054d4:	4705                	li	a4,1
    800054d6:	04f76763          	bltu	a4,a5,80005524 <filestat+0x6e>
    800054da:	892a                	mv	s2,a0
    ilock(f->ip);
    800054dc:	6c88                	ld	a0,24(s1)
    800054de:	fffff097          	auipc	ra,0xfffff
    800054e2:	06c080e7          	jalr	108(ra) # 8000454a <ilock>
    stati(f->ip, &st);
    800054e6:	fb840593          	addi	a1,s0,-72
    800054ea:	6c88                	ld	a0,24(s1)
    800054ec:	fffff097          	auipc	ra,0xfffff
    800054f0:	2e8080e7          	jalr	744(ra) # 800047d4 <stati>
    iunlock(f->ip);
    800054f4:	6c88                	ld	a0,24(s1)
    800054f6:	fffff097          	auipc	ra,0xfffff
    800054fa:	116080e7          	jalr	278(ra) # 8000460c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800054fe:	46e1                	li	a3,24
    80005500:	fb840613          	addi	a2,s0,-72
    80005504:	85ce                	mv	a1,s3
    80005506:	07093503          	ld	a0,112(s2)
    8000550a:	ffffc097          	auipc	ra,0xffffc
    8000550e:	242080e7          	jalr	578(ra) # 8000174c <copyout>
    80005512:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80005516:	60a6                	ld	ra,72(sp)
    80005518:	6406                	ld	s0,64(sp)
    8000551a:	74e2                	ld	s1,56(sp)
    8000551c:	7942                	ld	s2,48(sp)
    8000551e:	79a2                	ld	s3,40(sp)
    80005520:	6161                	addi	sp,sp,80
    80005522:	8082                	ret
  return -1;
    80005524:	557d                	li	a0,-1
    80005526:	bfc5                	j	80005516 <filestat+0x60>

0000000080005528 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80005528:	7179                	addi	sp,sp,-48
    8000552a:	f406                	sd	ra,40(sp)
    8000552c:	f022                	sd	s0,32(sp)
    8000552e:	ec26                	sd	s1,24(sp)
    80005530:	e84a                	sd	s2,16(sp)
    80005532:	e44e                	sd	s3,8(sp)
    80005534:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80005536:	00854783          	lbu	a5,8(a0)
    8000553a:	c3d5                	beqz	a5,800055de <fileread+0xb6>
    8000553c:	84aa                	mv	s1,a0
    8000553e:	89ae                	mv	s3,a1
    80005540:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80005542:	411c                	lw	a5,0(a0)
    80005544:	4705                	li	a4,1
    80005546:	04e78963          	beq	a5,a4,80005598 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000554a:	470d                	li	a4,3
    8000554c:	04e78d63          	beq	a5,a4,800055a6 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80005550:	4709                	li	a4,2
    80005552:	06e79e63          	bne	a5,a4,800055ce <fileread+0xa6>
    ilock(f->ip);
    80005556:	6d08                	ld	a0,24(a0)
    80005558:	fffff097          	auipc	ra,0xfffff
    8000555c:	ff2080e7          	jalr	-14(ra) # 8000454a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80005560:	874a                	mv	a4,s2
    80005562:	5094                	lw	a3,32(s1)
    80005564:	864e                	mv	a2,s3
    80005566:	4585                	li	a1,1
    80005568:	6c88                	ld	a0,24(s1)
    8000556a:	fffff097          	auipc	ra,0xfffff
    8000556e:	294080e7          	jalr	660(ra) # 800047fe <readi>
    80005572:	892a                	mv	s2,a0
    80005574:	00a05563          	blez	a0,8000557e <fileread+0x56>
      f->off += r;
    80005578:	509c                	lw	a5,32(s1)
    8000557a:	9fa9                	addw	a5,a5,a0
    8000557c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000557e:	6c88                	ld	a0,24(s1)
    80005580:	fffff097          	auipc	ra,0xfffff
    80005584:	08c080e7          	jalr	140(ra) # 8000460c <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80005588:	854a                	mv	a0,s2
    8000558a:	70a2                	ld	ra,40(sp)
    8000558c:	7402                	ld	s0,32(sp)
    8000558e:	64e2                	ld	s1,24(sp)
    80005590:	6942                	ld	s2,16(sp)
    80005592:	69a2                	ld	s3,8(sp)
    80005594:	6145                	addi	sp,sp,48
    80005596:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80005598:	6908                	ld	a0,16(a0)
    8000559a:	00000097          	auipc	ra,0x0
    8000559e:	3c0080e7          	jalr	960(ra) # 8000595a <piperead>
    800055a2:	892a                	mv	s2,a0
    800055a4:	b7d5                	j	80005588 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800055a6:	02451783          	lh	a5,36(a0)
    800055aa:	03079693          	slli	a3,a5,0x30
    800055ae:	92c1                	srli	a3,a3,0x30
    800055b0:	4725                	li	a4,9
    800055b2:	02d76863          	bltu	a4,a3,800055e2 <fileread+0xba>
    800055b6:	0792                	slli	a5,a5,0x4
    800055b8:	0002e717          	auipc	a4,0x2e
    800055bc:	c0870713          	addi	a4,a4,-1016 # 800331c0 <devsw>
    800055c0:	97ba                	add	a5,a5,a4
    800055c2:	639c                	ld	a5,0(a5)
    800055c4:	c38d                	beqz	a5,800055e6 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800055c6:	4505                	li	a0,1
    800055c8:	9782                	jalr	a5
    800055ca:	892a                	mv	s2,a0
    800055cc:	bf75                	j	80005588 <fileread+0x60>
    panic("fileread");
    800055ce:	00004517          	auipc	a0,0x4
    800055d2:	19a50513          	addi	a0,a0,410 # 80009768 <syscalls+0x2a0>
    800055d6:	ffffb097          	auipc	ra,0xffffb
    800055da:	f64080e7          	jalr	-156(ra) # 8000053a <panic>
    return -1;
    800055de:	597d                	li	s2,-1
    800055e0:	b765                	j	80005588 <fileread+0x60>
      return -1;
    800055e2:	597d                	li	s2,-1
    800055e4:	b755                	j	80005588 <fileread+0x60>
    800055e6:	597d                	li	s2,-1
    800055e8:	b745                	j	80005588 <fileread+0x60>

00000000800055ea <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800055ea:	715d                	addi	sp,sp,-80
    800055ec:	e486                	sd	ra,72(sp)
    800055ee:	e0a2                	sd	s0,64(sp)
    800055f0:	fc26                	sd	s1,56(sp)
    800055f2:	f84a                	sd	s2,48(sp)
    800055f4:	f44e                	sd	s3,40(sp)
    800055f6:	f052                	sd	s4,32(sp)
    800055f8:	ec56                	sd	s5,24(sp)
    800055fa:	e85a                	sd	s6,16(sp)
    800055fc:	e45e                	sd	s7,8(sp)
    800055fe:	e062                	sd	s8,0(sp)
    80005600:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80005602:	00954783          	lbu	a5,9(a0)
    80005606:	10078663          	beqz	a5,80005712 <filewrite+0x128>
    8000560a:	892a                	mv	s2,a0
    8000560c:	8b2e                	mv	s6,a1
    8000560e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80005610:	411c                	lw	a5,0(a0)
    80005612:	4705                	li	a4,1
    80005614:	02e78263          	beq	a5,a4,80005638 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005618:	470d                	li	a4,3
    8000561a:	02e78663          	beq	a5,a4,80005646 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000561e:	4709                	li	a4,2
    80005620:	0ee79163          	bne	a5,a4,80005702 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80005624:	0ac05d63          	blez	a2,800056de <filewrite+0xf4>
    int i = 0;
    80005628:	4981                	li	s3,0
    8000562a:	6b85                	lui	s7,0x1
    8000562c:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80005630:	6c05                	lui	s8,0x1
    80005632:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80005636:	a861                	j	800056ce <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80005638:	6908                	ld	a0,16(a0)
    8000563a:	00000097          	auipc	ra,0x0
    8000563e:	22e080e7          	jalr	558(ra) # 80005868 <pipewrite>
    80005642:	8a2a                	mv	s4,a0
    80005644:	a045                	j	800056e4 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005646:	02451783          	lh	a5,36(a0)
    8000564a:	03079693          	slli	a3,a5,0x30
    8000564e:	92c1                	srli	a3,a3,0x30
    80005650:	4725                	li	a4,9
    80005652:	0cd76263          	bltu	a4,a3,80005716 <filewrite+0x12c>
    80005656:	0792                	slli	a5,a5,0x4
    80005658:	0002e717          	auipc	a4,0x2e
    8000565c:	b6870713          	addi	a4,a4,-1176 # 800331c0 <devsw>
    80005660:	97ba                	add	a5,a5,a4
    80005662:	679c                	ld	a5,8(a5)
    80005664:	cbdd                	beqz	a5,8000571a <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80005666:	4505                	li	a0,1
    80005668:	9782                	jalr	a5
    8000566a:	8a2a                	mv	s4,a0
    8000566c:	a8a5                	j	800056e4 <filewrite+0xfa>
    8000566e:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80005672:	00000097          	auipc	ra,0x0
    80005676:	8b4080e7          	jalr	-1868(ra) # 80004f26 <begin_op>
      ilock(f->ip);
    8000567a:	01893503          	ld	a0,24(s2)
    8000567e:	fffff097          	auipc	ra,0xfffff
    80005682:	ecc080e7          	jalr	-308(ra) # 8000454a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80005686:	8756                	mv	a4,s5
    80005688:	02092683          	lw	a3,32(s2)
    8000568c:	01698633          	add	a2,s3,s6
    80005690:	4585                	li	a1,1
    80005692:	01893503          	ld	a0,24(s2)
    80005696:	fffff097          	auipc	ra,0xfffff
    8000569a:	260080e7          	jalr	608(ra) # 800048f6 <writei>
    8000569e:	84aa                	mv	s1,a0
    800056a0:	00a05763          	blez	a0,800056ae <filewrite+0xc4>
        f->off += r;
    800056a4:	02092783          	lw	a5,32(s2)
    800056a8:	9fa9                	addw	a5,a5,a0
    800056aa:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800056ae:	01893503          	ld	a0,24(s2)
    800056b2:	fffff097          	auipc	ra,0xfffff
    800056b6:	f5a080e7          	jalr	-166(ra) # 8000460c <iunlock>
      end_op();
    800056ba:	00000097          	auipc	ra,0x0
    800056be:	8ea080e7          	jalr	-1814(ra) # 80004fa4 <end_op>

      if(r != n1){
    800056c2:	009a9f63          	bne	s5,s1,800056e0 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    800056c6:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800056ca:	0149db63          	bge	s3,s4,800056e0 <filewrite+0xf6>
      int n1 = n - i;
    800056ce:	413a04bb          	subw	s1,s4,s3
    800056d2:	0004879b          	sext.w	a5,s1
    800056d6:	f8fbdce3          	bge	s7,a5,8000566e <filewrite+0x84>
    800056da:	84e2                	mv	s1,s8
    800056dc:	bf49                	j	8000566e <filewrite+0x84>
    int i = 0;
    800056de:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800056e0:	013a1f63          	bne	s4,s3,800056fe <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800056e4:	8552                	mv	a0,s4
    800056e6:	60a6                	ld	ra,72(sp)
    800056e8:	6406                	ld	s0,64(sp)
    800056ea:	74e2                	ld	s1,56(sp)
    800056ec:	7942                	ld	s2,48(sp)
    800056ee:	79a2                	ld	s3,40(sp)
    800056f0:	7a02                	ld	s4,32(sp)
    800056f2:	6ae2                	ld	s5,24(sp)
    800056f4:	6b42                	ld	s6,16(sp)
    800056f6:	6ba2                	ld	s7,8(sp)
    800056f8:	6c02                	ld	s8,0(sp)
    800056fa:	6161                	addi	sp,sp,80
    800056fc:	8082                	ret
    ret = (i == n ? n : -1);
    800056fe:	5a7d                	li	s4,-1
    80005700:	b7d5                	j	800056e4 <filewrite+0xfa>
    panic("filewrite");
    80005702:	00004517          	auipc	a0,0x4
    80005706:	07650513          	addi	a0,a0,118 # 80009778 <syscalls+0x2b0>
    8000570a:	ffffb097          	auipc	ra,0xffffb
    8000570e:	e30080e7          	jalr	-464(ra) # 8000053a <panic>
    return -1;
    80005712:	5a7d                	li	s4,-1
    80005714:	bfc1                	j	800056e4 <filewrite+0xfa>
      return -1;
    80005716:	5a7d                	li	s4,-1
    80005718:	b7f1                	j	800056e4 <filewrite+0xfa>
    8000571a:	5a7d                	li	s4,-1
    8000571c:	b7e1                	j	800056e4 <filewrite+0xfa>

000000008000571e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000571e:	7179                	addi	sp,sp,-48
    80005720:	f406                	sd	ra,40(sp)
    80005722:	f022                	sd	s0,32(sp)
    80005724:	ec26                	sd	s1,24(sp)
    80005726:	e84a                	sd	s2,16(sp)
    80005728:	e44e                	sd	s3,8(sp)
    8000572a:	e052                	sd	s4,0(sp)
    8000572c:	1800                	addi	s0,sp,48
    8000572e:	84aa                	mv	s1,a0
    80005730:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005732:	0005b023          	sd	zero,0(a1)
    80005736:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000573a:	00000097          	auipc	ra,0x0
    8000573e:	bf8080e7          	jalr	-1032(ra) # 80005332 <filealloc>
    80005742:	e088                	sd	a0,0(s1)
    80005744:	c551                	beqz	a0,800057d0 <pipealloc+0xb2>
    80005746:	00000097          	auipc	ra,0x0
    8000574a:	bec080e7          	jalr	-1044(ra) # 80005332 <filealloc>
    8000574e:	00aa3023          	sd	a0,0(s4)
    80005752:	c92d                	beqz	a0,800057c4 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80005754:	ffffb097          	auipc	ra,0xffffb
    80005758:	38c080e7          	jalr	908(ra) # 80000ae0 <kalloc>
    8000575c:	892a                	mv	s2,a0
    8000575e:	c125                	beqz	a0,800057be <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80005760:	4985                	li	s3,1
    80005762:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80005766:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000576a:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000576e:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80005772:	00004597          	auipc	a1,0x4
    80005776:	01658593          	addi	a1,a1,22 # 80009788 <syscalls+0x2c0>
    8000577a:	ffffb097          	auipc	ra,0xffffb
    8000577e:	40e080e7          	jalr	1038(ra) # 80000b88 <initlock>
  (*f0)->type = FD_PIPE;
    80005782:	609c                	ld	a5,0(s1)
    80005784:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005788:	609c                	ld	a5,0(s1)
    8000578a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000578e:	609c                	ld	a5,0(s1)
    80005790:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005794:	609c                	ld	a5,0(s1)
    80005796:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000579a:	000a3783          	ld	a5,0(s4)
    8000579e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800057a2:	000a3783          	ld	a5,0(s4)
    800057a6:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800057aa:	000a3783          	ld	a5,0(s4)
    800057ae:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800057b2:	000a3783          	ld	a5,0(s4)
    800057b6:	0127b823          	sd	s2,16(a5)
  return 0;
    800057ba:	4501                	li	a0,0
    800057bc:	a025                	j	800057e4 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800057be:	6088                	ld	a0,0(s1)
    800057c0:	e501                	bnez	a0,800057c8 <pipealloc+0xaa>
    800057c2:	a039                	j	800057d0 <pipealloc+0xb2>
    800057c4:	6088                	ld	a0,0(s1)
    800057c6:	c51d                	beqz	a0,800057f4 <pipealloc+0xd6>
    fileclose(*f0);
    800057c8:	00000097          	auipc	ra,0x0
    800057cc:	c26080e7          	jalr	-986(ra) # 800053ee <fileclose>
  if(*f1)
    800057d0:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800057d4:	557d                	li	a0,-1
  if(*f1)
    800057d6:	c799                	beqz	a5,800057e4 <pipealloc+0xc6>
    fileclose(*f1);
    800057d8:	853e                	mv	a0,a5
    800057da:	00000097          	auipc	ra,0x0
    800057de:	c14080e7          	jalr	-1004(ra) # 800053ee <fileclose>
  return -1;
    800057e2:	557d                	li	a0,-1
}
    800057e4:	70a2                	ld	ra,40(sp)
    800057e6:	7402                	ld	s0,32(sp)
    800057e8:	64e2                	ld	s1,24(sp)
    800057ea:	6942                	ld	s2,16(sp)
    800057ec:	69a2                	ld	s3,8(sp)
    800057ee:	6a02                	ld	s4,0(sp)
    800057f0:	6145                	addi	sp,sp,48
    800057f2:	8082                	ret
  return -1;
    800057f4:	557d                	li	a0,-1
    800057f6:	b7fd                	j	800057e4 <pipealloc+0xc6>

00000000800057f8 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800057f8:	1101                	addi	sp,sp,-32
    800057fa:	ec06                	sd	ra,24(sp)
    800057fc:	e822                	sd	s0,16(sp)
    800057fe:	e426                	sd	s1,8(sp)
    80005800:	e04a                	sd	s2,0(sp)
    80005802:	1000                	addi	s0,sp,32
    80005804:	84aa                	mv	s1,a0
    80005806:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005808:	ffffb097          	auipc	ra,0xffffb
    8000580c:	410080e7          	jalr	1040(ra) # 80000c18 <acquire>
  if(writable){
    80005810:	02090d63          	beqz	s2,8000584a <pipeclose+0x52>
    pi->writeopen = 0;
    80005814:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005818:	21848513          	addi	a0,s1,536
    8000581c:	ffffd097          	auipc	ra,0xffffd
    80005820:	a6c080e7          	jalr	-1428(ra) # 80002288 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005824:	2204b783          	ld	a5,544(s1)
    80005828:	eb95                	bnez	a5,8000585c <pipeclose+0x64>
    release(&pi->lock);
    8000582a:	8526                	mv	a0,s1
    8000582c:	ffffb097          	auipc	ra,0xffffb
    80005830:	4a0080e7          	jalr	1184(ra) # 80000ccc <release>
    kfree((char*)pi);
    80005834:	8526                	mv	a0,s1
    80005836:	ffffb097          	auipc	ra,0xffffb
    8000583a:	1ac080e7          	jalr	428(ra) # 800009e2 <kfree>
  } else
    release(&pi->lock);
}
    8000583e:	60e2                	ld	ra,24(sp)
    80005840:	6442                	ld	s0,16(sp)
    80005842:	64a2                	ld	s1,8(sp)
    80005844:	6902                	ld	s2,0(sp)
    80005846:	6105                	addi	sp,sp,32
    80005848:	8082                	ret
    pi->readopen = 0;
    8000584a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000584e:	21c48513          	addi	a0,s1,540
    80005852:	ffffd097          	auipc	ra,0xffffd
    80005856:	a36080e7          	jalr	-1482(ra) # 80002288 <wakeup>
    8000585a:	b7e9                	j	80005824 <pipeclose+0x2c>
    release(&pi->lock);
    8000585c:	8526                	mv	a0,s1
    8000585e:	ffffb097          	auipc	ra,0xffffb
    80005862:	46e080e7          	jalr	1134(ra) # 80000ccc <release>
}
    80005866:	bfe1                	j	8000583e <pipeclose+0x46>

0000000080005868 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005868:	711d                	addi	sp,sp,-96
    8000586a:	ec86                	sd	ra,88(sp)
    8000586c:	e8a2                	sd	s0,80(sp)
    8000586e:	e4a6                	sd	s1,72(sp)
    80005870:	e0ca                	sd	s2,64(sp)
    80005872:	fc4e                	sd	s3,56(sp)
    80005874:	f852                	sd	s4,48(sp)
    80005876:	f456                	sd	s5,40(sp)
    80005878:	f05a                	sd	s6,32(sp)
    8000587a:	ec5e                	sd	s7,24(sp)
    8000587c:	e862                	sd	s8,16(sp)
    8000587e:	1080                	addi	s0,sp,96
    80005880:	84aa                	mv	s1,a0
    80005882:	8aae                	mv	s5,a1
    80005884:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80005886:	ffffc097          	auipc	ra,0xffffc
    8000588a:	536080e7          	jalr	1334(ra) # 80001dbc <myproc>
    8000588e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005890:	8526                	mv	a0,s1
    80005892:	ffffb097          	auipc	ra,0xffffb
    80005896:	386080e7          	jalr	902(ra) # 80000c18 <acquire>
  while(i < n){
    8000589a:	0b405363          	blez	s4,80005940 <pipewrite+0xd8>
  int i = 0;
    8000589e:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800058a0:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800058a2:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800058a6:	21c48b93          	addi	s7,s1,540
    800058aa:	a089                	j	800058ec <pipewrite+0x84>
      release(&pi->lock);
    800058ac:	8526                	mv	a0,s1
    800058ae:	ffffb097          	auipc	ra,0xffffb
    800058b2:	41e080e7          	jalr	1054(ra) # 80000ccc <release>
      return -1;
    800058b6:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800058b8:	854a                	mv	a0,s2
    800058ba:	60e6                	ld	ra,88(sp)
    800058bc:	6446                	ld	s0,80(sp)
    800058be:	64a6                	ld	s1,72(sp)
    800058c0:	6906                	ld	s2,64(sp)
    800058c2:	79e2                	ld	s3,56(sp)
    800058c4:	7a42                	ld	s4,48(sp)
    800058c6:	7aa2                	ld	s5,40(sp)
    800058c8:	7b02                	ld	s6,32(sp)
    800058ca:	6be2                	ld	s7,24(sp)
    800058cc:	6c42                	ld	s8,16(sp)
    800058ce:	6125                	addi	sp,sp,96
    800058d0:	8082                	ret
      wakeup(&pi->nread);
    800058d2:	8562                	mv	a0,s8
    800058d4:	ffffd097          	auipc	ra,0xffffd
    800058d8:	9b4080e7          	jalr	-1612(ra) # 80002288 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800058dc:	85a6                	mv	a1,s1
    800058de:	855e                	mv	a0,s7
    800058e0:	ffffd097          	auipc	ra,0xffffd
    800058e4:	944080e7          	jalr	-1724(ra) # 80002224 <sleep>
  while(i < n){
    800058e8:	05495d63          	bge	s2,s4,80005942 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    800058ec:	2204a783          	lw	a5,544(s1)
    800058f0:	dfd5                	beqz	a5,800058ac <pipewrite+0x44>
    800058f2:	0289a783          	lw	a5,40(s3)
    800058f6:	fbdd                	bnez	a5,800058ac <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800058f8:	2184a783          	lw	a5,536(s1)
    800058fc:	21c4a703          	lw	a4,540(s1)
    80005900:	2007879b          	addiw	a5,a5,512
    80005904:	fcf707e3          	beq	a4,a5,800058d2 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005908:	4685                	li	a3,1
    8000590a:	01590633          	add	a2,s2,s5
    8000590e:	faf40593          	addi	a1,s0,-81
    80005912:	0709b503          	ld	a0,112(s3)
    80005916:	ffffc097          	auipc	ra,0xffffc
    8000591a:	ec2080e7          	jalr	-318(ra) # 800017d8 <copyin>
    8000591e:	03650263          	beq	a0,s6,80005942 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005922:	21c4a783          	lw	a5,540(s1)
    80005926:	0017871b          	addiw	a4,a5,1
    8000592a:	20e4ae23          	sw	a4,540(s1)
    8000592e:	1ff7f793          	andi	a5,a5,511
    80005932:	97a6                	add	a5,a5,s1
    80005934:	faf44703          	lbu	a4,-81(s0)
    80005938:	00e78c23          	sb	a4,24(a5)
      i++;
    8000593c:	2905                	addiw	s2,s2,1
    8000593e:	b76d                	j	800058e8 <pipewrite+0x80>
  int i = 0;
    80005940:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005942:	21848513          	addi	a0,s1,536
    80005946:	ffffd097          	auipc	ra,0xffffd
    8000594a:	942080e7          	jalr	-1726(ra) # 80002288 <wakeup>
  release(&pi->lock);
    8000594e:	8526                	mv	a0,s1
    80005950:	ffffb097          	auipc	ra,0xffffb
    80005954:	37c080e7          	jalr	892(ra) # 80000ccc <release>
  return i;
    80005958:	b785                	j	800058b8 <pipewrite+0x50>

000000008000595a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000595a:	715d                	addi	sp,sp,-80
    8000595c:	e486                	sd	ra,72(sp)
    8000595e:	e0a2                	sd	s0,64(sp)
    80005960:	fc26                	sd	s1,56(sp)
    80005962:	f84a                	sd	s2,48(sp)
    80005964:	f44e                	sd	s3,40(sp)
    80005966:	f052                	sd	s4,32(sp)
    80005968:	ec56                	sd	s5,24(sp)
    8000596a:	e85a                	sd	s6,16(sp)
    8000596c:	0880                	addi	s0,sp,80
    8000596e:	84aa                	mv	s1,a0
    80005970:	892e                	mv	s2,a1
    80005972:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005974:	ffffc097          	auipc	ra,0xffffc
    80005978:	448080e7          	jalr	1096(ra) # 80001dbc <myproc>
    8000597c:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000597e:	8526                	mv	a0,s1
    80005980:	ffffb097          	auipc	ra,0xffffb
    80005984:	298080e7          	jalr	664(ra) # 80000c18 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005988:	2184a703          	lw	a4,536(s1)
    8000598c:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005990:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005994:	02f71463          	bne	a4,a5,800059bc <piperead+0x62>
    80005998:	2244a783          	lw	a5,548(s1)
    8000599c:	c385                	beqz	a5,800059bc <piperead+0x62>
    if(pr->killed){
    8000599e:	028a2783          	lw	a5,40(s4)
    800059a2:	ebc9                	bnez	a5,80005a34 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800059a4:	85a6                	mv	a1,s1
    800059a6:	854e                	mv	a0,s3
    800059a8:	ffffd097          	auipc	ra,0xffffd
    800059ac:	87c080e7          	jalr	-1924(ra) # 80002224 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800059b0:	2184a703          	lw	a4,536(s1)
    800059b4:	21c4a783          	lw	a5,540(s1)
    800059b8:	fef700e3          	beq	a4,a5,80005998 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800059bc:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800059be:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800059c0:	05505463          	blez	s5,80005a08 <piperead+0xae>
    if(pi->nread == pi->nwrite)
    800059c4:	2184a783          	lw	a5,536(s1)
    800059c8:	21c4a703          	lw	a4,540(s1)
    800059cc:	02f70e63          	beq	a4,a5,80005a08 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800059d0:	0017871b          	addiw	a4,a5,1
    800059d4:	20e4ac23          	sw	a4,536(s1)
    800059d8:	1ff7f793          	andi	a5,a5,511
    800059dc:	97a6                	add	a5,a5,s1
    800059de:	0187c783          	lbu	a5,24(a5)
    800059e2:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800059e6:	4685                	li	a3,1
    800059e8:	fbf40613          	addi	a2,s0,-65
    800059ec:	85ca                	mv	a1,s2
    800059ee:	070a3503          	ld	a0,112(s4)
    800059f2:	ffffc097          	auipc	ra,0xffffc
    800059f6:	d5a080e7          	jalr	-678(ra) # 8000174c <copyout>
    800059fa:	01650763          	beq	a0,s6,80005a08 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800059fe:	2985                	addiw	s3,s3,1
    80005a00:	0905                	addi	s2,s2,1
    80005a02:	fd3a91e3          	bne	s5,s3,800059c4 <piperead+0x6a>
    80005a06:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005a08:	21c48513          	addi	a0,s1,540
    80005a0c:	ffffd097          	auipc	ra,0xffffd
    80005a10:	87c080e7          	jalr	-1924(ra) # 80002288 <wakeup>
  release(&pi->lock);
    80005a14:	8526                	mv	a0,s1
    80005a16:	ffffb097          	auipc	ra,0xffffb
    80005a1a:	2b6080e7          	jalr	694(ra) # 80000ccc <release>
  return i;
}
    80005a1e:	854e                	mv	a0,s3
    80005a20:	60a6                	ld	ra,72(sp)
    80005a22:	6406                	ld	s0,64(sp)
    80005a24:	74e2                	ld	s1,56(sp)
    80005a26:	7942                	ld	s2,48(sp)
    80005a28:	79a2                	ld	s3,40(sp)
    80005a2a:	7a02                	ld	s4,32(sp)
    80005a2c:	6ae2                	ld	s5,24(sp)
    80005a2e:	6b42                	ld	s6,16(sp)
    80005a30:	6161                	addi	sp,sp,80
    80005a32:	8082                	ret
      release(&pi->lock);
    80005a34:	8526                	mv	a0,s1
    80005a36:	ffffb097          	auipc	ra,0xffffb
    80005a3a:	296080e7          	jalr	662(ra) # 80000ccc <release>
      return -1;
    80005a3e:	59fd                	li	s3,-1
    80005a40:	bff9                	j	80005a1e <piperead+0xc4>

0000000080005a42 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80005a42:	de010113          	addi	sp,sp,-544
    80005a46:	20113c23          	sd	ra,536(sp)
    80005a4a:	20813823          	sd	s0,528(sp)
    80005a4e:	20913423          	sd	s1,520(sp)
    80005a52:	21213023          	sd	s2,512(sp)
    80005a56:	ffce                	sd	s3,504(sp)
    80005a58:	fbd2                	sd	s4,496(sp)
    80005a5a:	f7d6                	sd	s5,488(sp)
    80005a5c:	f3da                	sd	s6,480(sp)
    80005a5e:	efde                	sd	s7,472(sp)
    80005a60:	ebe2                	sd	s8,464(sp)
    80005a62:	e7e6                	sd	s9,456(sp)
    80005a64:	e3ea                	sd	s10,448(sp)
    80005a66:	ff6e                	sd	s11,440(sp)
    80005a68:	1400                	addi	s0,sp,544
    80005a6a:	892a                	mv	s2,a0
    80005a6c:	dea43423          	sd	a0,-536(s0)
    80005a70:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005a74:	ffffc097          	auipc	ra,0xffffc
    80005a78:	348080e7          	jalr	840(ra) # 80001dbc <myproc>
    80005a7c:	84aa                	mv	s1,a0

  begin_op();
    80005a7e:	fffff097          	auipc	ra,0xfffff
    80005a82:	4a8080e7          	jalr	1192(ra) # 80004f26 <begin_op>

  if((ip = namei(path)) == 0){
    80005a86:	854a                	mv	a0,s2
    80005a88:	fffff097          	auipc	ra,0xfffff
    80005a8c:	27e080e7          	jalr	638(ra) # 80004d06 <namei>
    80005a90:	c93d                	beqz	a0,80005b06 <exec+0xc4>
    80005a92:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005a94:	fffff097          	auipc	ra,0xfffff
    80005a98:	ab6080e7          	jalr	-1354(ra) # 8000454a <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005a9c:	04000713          	li	a4,64
    80005aa0:	4681                	li	a3,0
    80005aa2:	e5040613          	addi	a2,s0,-432
    80005aa6:	4581                	li	a1,0
    80005aa8:	8556                	mv	a0,s5
    80005aaa:	fffff097          	auipc	ra,0xfffff
    80005aae:	d54080e7          	jalr	-684(ra) # 800047fe <readi>
    80005ab2:	04000793          	li	a5,64
    80005ab6:	00f51a63          	bne	a0,a5,80005aca <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80005aba:	e5042703          	lw	a4,-432(s0)
    80005abe:	464c47b7          	lui	a5,0x464c4
    80005ac2:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005ac6:	04f70663          	beq	a4,a5,80005b12 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005aca:	8556                	mv	a0,s5
    80005acc:	fffff097          	auipc	ra,0xfffff
    80005ad0:	ce0080e7          	jalr	-800(ra) # 800047ac <iunlockput>
    end_op();
    80005ad4:	fffff097          	auipc	ra,0xfffff
    80005ad8:	4d0080e7          	jalr	1232(ra) # 80004fa4 <end_op>
  }
  return -1;
    80005adc:	557d                	li	a0,-1
}
    80005ade:	21813083          	ld	ra,536(sp)
    80005ae2:	21013403          	ld	s0,528(sp)
    80005ae6:	20813483          	ld	s1,520(sp)
    80005aea:	20013903          	ld	s2,512(sp)
    80005aee:	79fe                	ld	s3,504(sp)
    80005af0:	7a5e                	ld	s4,496(sp)
    80005af2:	7abe                	ld	s5,488(sp)
    80005af4:	7b1e                	ld	s6,480(sp)
    80005af6:	6bfe                	ld	s7,472(sp)
    80005af8:	6c5e                	ld	s8,464(sp)
    80005afa:	6cbe                	ld	s9,456(sp)
    80005afc:	6d1e                	ld	s10,448(sp)
    80005afe:	7dfa                	ld	s11,440(sp)
    80005b00:	22010113          	addi	sp,sp,544
    80005b04:	8082                	ret
    end_op();
    80005b06:	fffff097          	auipc	ra,0xfffff
    80005b0a:	49e080e7          	jalr	1182(ra) # 80004fa4 <end_op>
    return -1;
    80005b0e:	557d                	li	a0,-1
    80005b10:	b7f9                	j	80005ade <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80005b12:	8526                	mv	a0,s1
    80005b14:	ffffc097          	auipc	ra,0xffffc
    80005b18:	36c080e7          	jalr	876(ra) # 80001e80 <proc_pagetable>
    80005b1c:	8b2a                	mv	s6,a0
    80005b1e:	d555                	beqz	a0,80005aca <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005b20:	e7042783          	lw	a5,-400(s0)
    80005b24:	e8845703          	lhu	a4,-376(s0)
    80005b28:	c735                	beqz	a4,80005b94 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005b2a:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005b2c:	e0043423          	sd	zero,-504(s0)
    if((ph.vaddr % PGSIZE) != 0)
    80005b30:	6a05                	lui	s4,0x1
    80005b32:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005b36:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80005b3a:	6d85                	lui	s11,0x1
    80005b3c:	7d7d                	lui	s10,0xfffff
    80005b3e:	ac1d                	j	80005d74 <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005b40:	00004517          	auipc	a0,0x4
    80005b44:	c5050513          	addi	a0,a0,-944 # 80009790 <syscalls+0x2c8>
    80005b48:	ffffb097          	auipc	ra,0xffffb
    80005b4c:	9f2080e7          	jalr	-1550(ra) # 8000053a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005b50:	874a                	mv	a4,s2
    80005b52:	009c86bb          	addw	a3,s9,s1
    80005b56:	4581                	li	a1,0
    80005b58:	8556                	mv	a0,s5
    80005b5a:	fffff097          	auipc	ra,0xfffff
    80005b5e:	ca4080e7          	jalr	-860(ra) # 800047fe <readi>
    80005b62:	2501                	sext.w	a0,a0
    80005b64:	1aa91863          	bne	s2,a0,80005d14 <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80005b68:	009d84bb          	addw	s1,s11,s1
    80005b6c:	013d09bb          	addw	s3,s10,s3
    80005b70:	1f74f263          	bgeu	s1,s7,80005d54 <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80005b74:	02049593          	slli	a1,s1,0x20
    80005b78:	9181                	srli	a1,a1,0x20
    80005b7a:	95e2                	add	a1,a1,s8
    80005b7c:	855a                	mv	a0,s6
    80005b7e:	ffffb097          	auipc	ra,0xffffb
    80005b82:	524080e7          	jalr	1316(ra) # 800010a2 <walkaddr>
    80005b86:	862a                	mv	a2,a0
    if(pa == 0)
    80005b88:	dd45                	beqz	a0,80005b40 <exec+0xfe>
      n = PGSIZE;
    80005b8a:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005b8c:	fd49f2e3          	bgeu	s3,s4,80005b50 <exec+0x10e>
      n = sz - i;
    80005b90:	894e                	mv	s2,s3
    80005b92:	bf7d                	j	80005b50 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005b94:	4481                	li	s1,0
  iunlockput(ip);
    80005b96:	8556                	mv	a0,s5
    80005b98:	fffff097          	auipc	ra,0xfffff
    80005b9c:	c14080e7          	jalr	-1004(ra) # 800047ac <iunlockput>
  end_op();
    80005ba0:	fffff097          	auipc	ra,0xfffff
    80005ba4:	404080e7          	jalr	1028(ra) # 80004fa4 <end_op>
  p = myproc();
    80005ba8:	ffffc097          	auipc	ra,0xffffc
    80005bac:	214080e7          	jalr	532(ra) # 80001dbc <myproc>
    80005bb0:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005bb2:	06853d03          	ld	s10,104(a0)
  sz = PGROUNDUP(sz);
    80005bb6:	6785                	lui	a5,0x1
    80005bb8:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80005bba:	97a6                	add	a5,a5,s1
    80005bbc:	777d                	lui	a4,0xfffff
    80005bbe:	8ff9                	and	a5,a5,a4
    80005bc0:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005bc4:	6609                	lui	a2,0x2
    80005bc6:	963e                	add	a2,a2,a5
    80005bc8:	85be                	mv	a1,a5
    80005bca:	855a                	mv	a0,s6
    80005bcc:	ffffc097          	auipc	ra,0xffffc
    80005bd0:	88a080e7          	jalr	-1910(ra) # 80001456 <uvmalloc>
    80005bd4:	8c2a                	mv	s8,a0
  ip = 0;
    80005bd6:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005bd8:	12050e63          	beqz	a0,80005d14 <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005bdc:	75f9                	lui	a1,0xffffe
    80005bde:	95aa                	add	a1,a1,a0
    80005be0:	855a                	mv	a0,s6
    80005be2:	ffffc097          	auipc	ra,0xffffc
    80005be6:	b38080e7          	jalr	-1224(ra) # 8000171a <uvmclear>
  stackbase = sp - PGSIZE;
    80005bea:	7afd                	lui	s5,0xfffff
    80005bec:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005bee:	df043783          	ld	a5,-528(s0)
    80005bf2:	6388                	ld	a0,0(a5)
    80005bf4:	c925                	beqz	a0,80005c64 <exec+0x222>
    80005bf6:	e9040993          	addi	s3,s0,-368
    80005bfa:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80005bfe:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005c00:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005c02:	ffffb097          	auipc	ra,0xffffb
    80005c06:	28e080e7          	jalr	654(ra) # 80000e90 <strlen>
    80005c0a:	0015079b          	addiw	a5,a0,1
    80005c0e:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005c12:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80005c16:	13596363          	bltu	s2,s5,80005d3c <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005c1a:	df043d83          	ld	s11,-528(s0)
    80005c1e:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005c22:	8552                	mv	a0,s4
    80005c24:	ffffb097          	auipc	ra,0xffffb
    80005c28:	26c080e7          	jalr	620(ra) # 80000e90 <strlen>
    80005c2c:	0015069b          	addiw	a3,a0,1
    80005c30:	8652                	mv	a2,s4
    80005c32:	85ca                	mv	a1,s2
    80005c34:	855a                	mv	a0,s6
    80005c36:	ffffc097          	auipc	ra,0xffffc
    80005c3a:	b16080e7          	jalr	-1258(ra) # 8000174c <copyout>
    80005c3e:	10054363          	bltz	a0,80005d44 <exec+0x302>
    ustack[argc] = sp;
    80005c42:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005c46:	0485                	addi	s1,s1,1
    80005c48:	008d8793          	addi	a5,s11,8
    80005c4c:	def43823          	sd	a5,-528(s0)
    80005c50:	008db503          	ld	a0,8(s11)
    80005c54:	c911                	beqz	a0,80005c68 <exec+0x226>
    if(argc >= MAXARG)
    80005c56:	09a1                	addi	s3,s3,8
    80005c58:	fb3c95e3          	bne	s9,s3,80005c02 <exec+0x1c0>
  sz = sz1;
    80005c5c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005c60:	4a81                	li	s5,0
    80005c62:	a84d                	j	80005d14 <exec+0x2d2>
  sp = sz;
    80005c64:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005c66:	4481                	li	s1,0
  ustack[argc] = 0;
    80005c68:	00349793          	slli	a5,s1,0x3
    80005c6c:	f9078793          	addi	a5,a5,-112
    80005c70:	97a2                	add	a5,a5,s0
    80005c72:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005c76:	00148693          	addi	a3,s1,1
    80005c7a:	068e                	slli	a3,a3,0x3
    80005c7c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005c80:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005c84:	01597663          	bgeu	s2,s5,80005c90 <exec+0x24e>
  sz = sz1;
    80005c88:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005c8c:	4a81                	li	s5,0
    80005c8e:	a059                	j	80005d14 <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005c90:	e9040613          	addi	a2,s0,-368
    80005c94:	85ca                	mv	a1,s2
    80005c96:	855a                	mv	a0,s6
    80005c98:	ffffc097          	auipc	ra,0xffffc
    80005c9c:	ab4080e7          	jalr	-1356(ra) # 8000174c <copyout>
    80005ca0:	0a054663          	bltz	a0,80005d4c <exec+0x30a>
  p->trapframe->a1 = sp;
    80005ca4:	078bb783          	ld	a5,120(s7)
    80005ca8:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005cac:	de843783          	ld	a5,-536(s0)
    80005cb0:	0007c703          	lbu	a4,0(a5)
    80005cb4:	cf11                	beqz	a4,80005cd0 <exec+0x28e>
    80005cb6:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005cb8:	02f00693          	li	a3,47
    80005cbc:	a039                	j	80005cca <exec+0x288>
      last = s+1;
    80005cbe:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005cc2:	0785                	addi	a5,a5,1
    80005cc4:	fff7c703          	lbu	a4,-1(a5)
    80005cc8:	c701                	beqz	a4,80005cd0 <exec+0x28e>
    if(*s == '/')
    80005cca:	fed71ce3          	bne	a4,a3,80005cc2 <exec+0x280>
    80005cce:	bfc5                	j	80005cbe <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    80005cd0:	4641                	li	a2,16
    80005cd2:	de843583          	ld	a1,-536(s0)
    80005cd6:	178b8513          	addi	a0,s7,376
    80005cda:	ffffb097          	auipc	ra,0xffffb
    80005cde:	184080e7          	jalr	388(ra) # 80000e5e <safestrcpy>
  oldpagetable = p->pagetable;
    80005ce2:	070bb503          	ld	a0,112(s7)
  p->pagetable = pagetable;
    80005ce6:	076bb823          	sd	s6,112(s7)
  p->sz = sz;
    80005cea:	078bb423          	sd	s8,104(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005cee:	078bb783          	ld	a5,120(s7)
    80005cf2:	e6843703          	ld	a4,-408(s0)
    80005cf6:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005cf8:	078bb783          	ld	a5,120(s7)
    80005cfc:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005d00:	85ea                	mv	a1,s10
    80005d02:	ffffc097          	auipc	ra,0xffffc
    80005d06:	21a080e7          	jalr	538(ra) # 80001f1c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005d0a:	0004851b          	sext.w	a0,s1
    80005d0e:	bbc1                	j	80005ade <exec+0x9c>
    80005d10:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005d14:	df843583          	ld	a1,-520(s0)
    80005d18:	855a                	mv	a0,s6
    80005d1a:	ffffc097          	auipc	ra,0xffffc
    80005d1e:	202080e7          	jalr	514(ra) # 80001f1c <proc_freepagetable>
  if(ip){
    80005d22:	da0a94e3          	bnez	s5,80005aca <exec+0x88>
  return -1;
    80005d26:	557d                	li	a0,-1
    80005d28:	bb5d                	j	80005ade <exec+0x9c>
    80005d2a:	de943c23          	sd	s1,-520(s0)
    80005d2e:	b7dd                	j	80005d14 <exec+0x2d2>
    80005d30:	de943c23          	sd	s1,-520(s0)
    80005d34:	b7c5                	j	80005d14 <exec+0x2d2>
    80005d36:	de943c23          	sd	s1,-520(s0)
    80005d3a:	bfe9                	j	80005d14 <exec+0x2d2>
  sz = sz1;
    80005d3c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005d40:	4a81                	li	s5,0
    80005d42:	bfc9                	j	80005d14 <exec+0x2d2>
  sz = sz1;
    80005d44:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005d48:	4a81                	li	s5,0
    80005d4a:	b7e9                	j	80005d14 <exec+0x2d2>
  sz = sz1;
    80005d4c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005d50:	4a81                	li	s5,0
    80005d52:	b7c9                	j	80005d14 <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005d54:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005d58:	e0843783          	ld	a5,-504(s0)
    80005d5c:	0017869b          	addiw	a3,a5,1
    80005d60:	e0d43423          	sd	a3,-504(s0)
    80005d64:	e0043783          	ld	a5,-512(s0)
    80005d68:	0387879b          	addiw	a5,a5,56
    80005d6c:	e8845703          	lhu	a4,-376(s0)
    80005d70:	e2e6d3e3          	bge	a3,a4,80005b96 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005d74:	2781                	sext.w	a5,a5
    80005d76:	e0f43023          	sd	a5,-512(s0)
    80005d7a:	03800713          	li	a4,56
    80005d7e:	86be                	mv	a3,a5
    80005d80:	e1840613          	addi	a2,s0,-488
    80005d84:	4581                	li	a1,0
    80005d86:	8556                	mv	a0,s5
    80005d88:	fffff097          	auipc	ra,0xfffff
    80005d8c:	a76080e7          	jalr	-1418(ra) # 800047fe <readi>
    80005d90:	03800793          	li	a5,56
    80005d94:	f6f51ee3          	bne	a0,a5,80005d10 <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    80005d98:	e1842783          	lw	a5,-488(s0)
    80005d9c:	4705                	li	a4,1
    80005d9e:	fae79de3          	bne	a5,a4,80005d58 <exec+0x316>
    if(ph.memsz < ph.filesz)
    80005da2:	e4043603          	ld	a2,-448(s0)
    80005da6:	e3843783          	ld	a5,-456(s0)
    80005daa:	f8f660e3          	bltu	a2,a5,80005d2a <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005dae:	e2843783          	ld	a5,-472(s0)
    80005db2:	963e                	add	a2,a2,a5
    80005db4:	f6f66ee3          	bltu	a2,a5,80005d30 <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005db8:	85a6                	mv	a1,s1
    80005dba:	855a                	mv	a0,s6
    80005dbc:	ffffb097          	auipc	ra,0xffffb
    80005dc0:	69a080e7          	jalr	1690(ra) # 80001456 <uvmalloc>
    80005dc4:	dea43c23          	sd	a0,-520(s0)
    80005dc8:	d53d                	beqz	a0,80005d36 <exec+0x2f4>
    if((ph.vaddr % PGSIZE) != 0)
    80005dca:	e2843c03          	ld	s8,-472(s0)
    80005dce:	de043783          	ld	a5,-544(s0)
    80005dd2:	00fc77b3          	and	a5,s8,a5
    80005dd6:	ff9d                	bnez	a5,80005d14 <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005dd8:	e2042c83          	lw	s9,-480(s0)
    80005ddc:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005de0:	f60b8ae3          	beqz	s7,80005d54 <exec+0x312>
    80005de4:	89de                	mv	s3,s7
    80005de6:	4481                	li	s1,0
    80005de8:	b371                	j	80005b74 <exec+0x132>

0000000080005dea <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005dea:	7179                	addi	sp,sp,-48
    80005dec:	f406                	sd	ra,40(sp)
    80005dee:	f022                	sd	s0,32(sp)
    80005df0:	ec26                	sd	s1,24(sp)
    80005df2:	e84a                	sd	s2,16(sp)
    80005df4:	1800                	addi	s0,sp,48
    80005df6:	892e                	mv	s2,a1
    80005df8:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005dfa:	fdc40593          	addi	a1,s0,-36
    80005dfe:	ffffe097          	auipc	ra,0xffffe
    80005e02:	b0c080e7          	jalr	-1268(ra) # 8000390a <argint>
    80005e06:	04054063          	bltz	a0,80005e46 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005e0a:	fdc42703          	lw	a4,-36(s0)
    80005e0e:	47bd                	li	a5,15
    80005e10:	02e7ed63          	bltu	a5,a4,80005e4a <argfd+0x60>
    80005e14:	ffffc097          	auipc	ra,0xffffc
    80005e18:	fa8080e7          	jalr	-88(ra) # 80001dbc <myproc>
    80005e1c:	fdc42703          	lw	a4,-36(s0)
    80005e20:	01e70793          	addi	a5,a4,30 # fffffffffffff01e <end+0xffffffff7ffc701e>
    80005e24:	078e                	slli	a5,a5,0x3
    80005e26:	953e                	add	a0,a0,a5
    80005e28:	611c                	ld	a5,0(a0)
    80005e2a:	c395                	beqz	a5,80005e4e <argfd+0x64>
    return -1;
  if(pfd)
    80005e2c:	00090463          	beqz	s2,80005e34 <argfd+0x4a>
    *pfd = fd;
    80005e30:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005e34:	4501                	li	a0,0
  if(pf)
    80005e36:	c091                	beqz	s1,80005e3a <argfd+0x50>
    *pf = f;
    80005e38:	e09c                	sd	a5,0(s1)
}
    80005e3a:	70a2                	ld	ra,40(sp)
    80005e3c:	7402                	ld	s0,32(sp)
    80005e3e:	64e2                	ld	s1,24(sp)
    80005e40:	6942                	ld	s2,16(sp)
    80005e42:	6145                	addi	sp,sp,48
    80005e44:	8082                	ret
    return -1;
    80005e46:	557d                	li	a0,-1
    80005e48:	bfcd                	j	80005e3a <argfd+0x50>
    return -1;
    80005e4a:	557d                	li	a0,-1
    80005e4c:	b7fd                	j	80005e3a <argfd+0x50>
    80005e4e:	557d                	li	a0,-1
    80005e50:	b7ed                	j	80005e3a <argfd+0x50>

0000000080005e52 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005e52:	1101                	addi	sp,sp,-32
    80005e54:	ec06                	sd	ra,24(sp)
    80005e56:	e822                	sd	s0,16(sp)
    80005e58:	e426                	sd	s1,8(sp)
    80005e5a:	1000                	addi	s0,sp,32
    80005e5c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005e5e:	ffffc097          	auipc	ra,0xffffc
    80005e62:	f5e080e7          	jalr	-162(ra) # 80001dbc <myproc>
    80005e66:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005e68:	0f050793          	addi	a5,a0,240
    80005e6c:	4501                	li	a0,0
    80005e6e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005e70:	6398                	ld	a4,0(a5)
    80005e72:	cb19                	beqz	a4,80005e88 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005e74:	2505                	addiw	a0,a0,1
    80005e76:	07a1                	addi	a5,a5,8
    80005e78:	fed51ce3          	bne	a0,a3,80005e70 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005e7c:	557d                	li	a0,-1
}
    80005e7e:	60e2                	ld	ra,24(sp)
    80005e80:	6442                	ld	s0,16(sp)
    80005e82:	64a2                	ld	s1,8(sp)
    80005e84:	6105                	addi	sp,sp,32
    80005e86:	8082                	ret
      p->ofile[fd] = f;
    80005e88:	01e50793          	addi	a5,a0,30
    80005e8c:	078e                	slli	a5,a5,0x3
    80005e8e:	963e                	add	a2,a2,a5
    80005e90:	e204                	sd	s1,0(a2)
      return fd;
    80005e92:	b7f5                	j	80005e7e <fdalloc+0x2c>

0000000080005e94 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005e94:	715d                	addi	sp,sp,-80
    80005e96:	e486                	sd	ra,72(sp)
    80005e98:	e0a2                	sd	s0,64(sp)
    80005e9a:	fc26                	sd	s1,56(sp)
    80005e9c:	f84a                	sd	s2,48(sp)
    80005e9e:	f44e                	sd	s3,40(sp)
    80005ea0:	f052                	sd	s4,32(sp)
    80005ea2:	ec56                	sd	s5,24(sp)
    80005ea4:	0880                	addi	s0,sp,80
    80005ea6:	89ae                	mv	s3,a1
    80005ea8:	8ab2                	mv	s5,a2
    80005eaa:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005eac:	fb040593          	addi	a1,s0,-80
    80005eb0:	fffff097          	auipc	ra,0xfffff
    80005eb4:	e74080e7          	jalr	-396(ra) # 80004d24 <nameiparent>
    80005eb8:	892a                	mv	s2,a0
    80005eba:	12050e63          	beqz	a0,80005ff6 <create+0x162>
    return 0;

  ilock(dp);
    80005ebe:	ffffe097          	auipc	ra,0xffffe
    80005ec2:	68c080e7          	jalr	1676(ra) # 8000454a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005ec6:	4601                	li	a2,0
    80005ec8:	fb040593          	addi	a1,s0,-80
    80005ecc:	854a                	mv	a0,s2
    80005ece:	fffff097          	auipc	ra,0xfffff
    80005ed2:	b60080e7          	jalr	-1184(ra) # 80004a2e <dirlookup>
    80005ed6:	84aa                	mv	s1,a0
    80005ed8:	c921                	beqz	a0,80005f28 <create+0x94>
    iunlockput(dp);
    80005eda:	854a                	mv	a0,s2
    80005edc:	fffff097          	auipc	ra,0xfffff
    80005ee0:	8d0080e7          	jalr	-1840(ra) # 800047ac <iunlockput>
    ilock(ip);
    80005ee4:	8526                	mv	a0,s1
    80005ee6:	ffffe097          	auipc	ra,0xffffe
    80005eea:	664080e7          	jalr	1636(ra) # 8000454a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005eee:	2981                	sext.w	s3,s3
    80005ef0:	4789                	li	a5,2
    80005ef2:	02f99463          	bne	s3,a5,80005f1a <create+0x86>
    80005ef6:	0444d783          	lhu	a5,68(s1)
    80005efa:	37f9                	addiw	a5,a5,-2
    80005efc:	17c2                	slli	a5,a5,0x30
    80005efe:	93c1                	srli	a5,a5,0x30
    80005f00:	4705                	li	a4,1
    80005f02:	00f76c63          	bltu	a4,a5,80005f1a <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005f06:	8526                	mv	a0,s1
    80005f08:	60a6                	ld	ra,72(sp)
    80005f0a:	6406                	ld	s0,64(sp)
    80005f0c:	74e2                	ld	s1,56(sp)
    80005f0e:	7942                	ld	s2,48(sp)
    80005f10:	79a2                	ld	s3,40(sp)
    80005f12:	7a02                	ld	s4,32(sp)
    80005f14:	6ae2                	ld	s5,24(sp)
    80005f16:	6161                	addi	sp,sp,80
    80005f18:	8082                	ret
    iunlockput(ip);
    80005f1a:	8526                	mv	a0,s1
    80005f1c:	fffff097          	auipc	ra,0xfffff
    80005f20:	890080e7          	jalr	-1904(ra) # 800047ac <iunlockput>
    return 0;
    80005f24:	4481                	li	s1,0
    80005f26:	b7c5                	j	80005f06 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005f28:	85ce                	mv	a1,s3
    80005f2a:	00092503          	lw	a0,0(s2)
    80005f2e:	ffffe097          	auipc	ra,0xffffe
    80005f32:	482080e7          	jalr	1154(ra) # 800043b0 <ialloc>
    80005f36:	84aa                	mv	s1,a0
    80005f38:	c521                	beqz	a0,80005f80 <create+0xec>
  ilock(ip);
    80005f3a:	ffffe097          	auipc	ra,0xffffe
    80005f3e:	610080e7          	jalr	1552(ra) # 8000454a <ilock>
  ip->major = major;
    80005f42:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005f46:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005f4a:	4a05                	li	s4,1
    80005f4c:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80005f50:	8526                	mv	a0,s1
    80005f52:	ffffe097          	auipc	ra,0xffffe
    80005f56:	52c080e7          	jalr	1324(ra) # 8000447e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005f5a:	2981                	sext.w	s3,s3
    80005f5c:	03498a63          	beq	s3,s4,80005f90 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005f60:	40d0                	lw	a2,4(s1)
    80005f62:	fb040593          	addi	a1,s0,-80
    80005f66:	854a                	mv	a0,s2
    80005f68:	fffff097          	auipc	ra,0xfffff
    80005f6c:	cdc080e7          	jalr	-804(ra) # 80004c44 <dirlink>
    80005f70:	06054b63          	bltz	a0,80005fe6 <create+0x152>
  iunlockput(dp);
    80005f74:	854a                	mv	a0,s2
    80005f76:	fffff097          	auipc	ra,0xfffff
    80005f7a:	836080e7          	jalr	-1994(ra) # 800047ac <iunlockput>
  return ip;
    80005f7e:	b761                	j	80005f06 <create+0x72>
    panic("create: ialloc");
    80005f80:	00004517          	auipc	a0,0x4
    80005f84:	83050513          	addi	a0,a0,-2000 # 800097b0 <syscalls+0x2e8>
    80005f88:	ffffa097          	auipc	ra,0xffffa
    80005f8c:	5b2080e7          	jalr	1458(ra) # 8000053a <panic>
    dp->nlink++;  // for ".."
    80005f90:	04a95783          	lhu	a5,74(s2)
    80005f94:	2785                	addiw	a5,a5,1
    80005f96:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005f9a:	854a                	mv	a0,s2
    80005f9c:	ffffe097          	auipc	ra,0xffffe
    80005fa0:	4e2080e7          	jalr	1250(ra) # 8000447e <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005fa4:	40d0                	lw	a2,4(s1)
    80005fa6:	00004597          	auipc	a1,0x4
    80005faa:	81a58593          	addi	a1,a1,-2022 # 800097c0 <syscalls+0x2f8>
    80005fae:	8526                	mv	a0,s1
    80005fb0:	fffff097          	auipc	ra,0xfffff
    80005fb4:	c94080e7          	jalr	-876(ra) # 80004c44 <dirlink>
    80005fb8:	00054f63          	bltz	a0,80005fd6 <create+0x142>
    80005fbc:	00492603          	lw	a2,4(s2)
    80005fc0:	00004597          	auipc	a1,0x4
    80005fc4:	80858593          	addi	a1,a1,-2040 # 800097c8 <syscalls+0x300>
    80005fc8:	8526                	mv	a0,s1
    80005fca:	fffff097          	auipc	ra,0xfffff
    80005fce:	c7a080e7          	jalr	-902(ra) # 80004c44 <dirlink>
    80005fd2:	f80557e3          	bgez	a0,80005f60 <create+0xcc>
      panic("create dots");
    80005fd6:	00003517          	auipc	a0,0x3
    80005fda:	7fa50513          	addi	a0,a0,2042 # 800097d0 <syscalls+0x308>
    80005fde:	ffffa097          	auipc	ra,0xffffa
    80005fe2:	55c080e7          	jalr	1372(ra) # 8000053a <panic>
    panic("create: dirlink");
    80005fe6:	00003517          	auipc	a0,0x3
    80005fea:	7fa50513          	addi	a0,a0,2042 # 800097e0 <syscalls+0x318>
    80005fee:	ffffa097          	auipc	ra,0xffffa
    80005ff2:	54c080e7          	jalr	1356(ra) # 8000053a <panic>
    return 0;
    80005ff6:	84aa                	mv	s1,a0
    80005ff8:	b739                	j	80005f06 <create+0x72>

0000000080005ffa <sys_dup>:
{
    80005ffa:	7179                	addi	sp,sp,-48
    80005ffc:	f406                	sd	ra,40(sp)
    80005ffe:	f022                	sd	s0,32(sp)
    80006000:	ec26                	sd	s1,24(sp)
    80006002:	e84a                	sd	s2,16(sp)
    80006004:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80006006:	fd840613          	addi	a2,s0,-40
    8000600a:	4581                	li	a1,0
    8000600c:	4501                	li	a0,0
    8000600e:	00000097          	auipc	ra,0x0
    80006012:	ddc080e7          	jalr	-548(ra) # 80005dea <argfd>
    return -1;
    80006016:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80006018:	02054363          	bltz	a0,8000603e <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    8000601c:	fd843903          	ld	s2,-40(s0)
    80006020:	854a                	mv	a0,s2
    80006022:	00000097          	auipc	ra,0x0
    80006026:	e30080e7          	jalr	-464(ra) # 80005e52 <fdalloc>
    8000602a:	84aa                	mv	s1,a0
    return -1;
    8000602c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000602e:	00054863          	bltz	a0,8000603e <sys_dup+0x44>
  filedup(f);
    80006032:	854a                	mv	a0,s2
    80006034:	fffff097          	auipc	ra,0xfffff
    80006038:	368080e7          	jalr	872(ra) # 8000539c <filedup>
  return fd;
    8000603c:	87a6                	mv	a5,s1
}
    8000603e:	853e                	mv	a0,a5
    80006040:	70a2                	ld	ra,40(sp)
    80006042:	7402                	ld	s0,32(sp)
    80006044:	64e2                	ld	s1,24(sp)
    80006046:	6942                	ld	s2,16(sp)
    80006048:	6145                	addi	sp,sp,48
    8000604a:	8082                	ret

000000008000604c <sys_read>:
{
    8000604c:	7179                	addi	sp,sp,-48
    8000604e:	f406                	sd	ra,40(sp)
    80006050:	f022                	sd	s0,32(sp)
    80006052:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006054:	fe840613          	addi	a2,s0,-24
    80006058:	4581                	li	a1,0
    8000605a:	4501                	li	a0,0
    8000605c:	00000097          	auipc	ra,0x0
    80006060:	d8e080e7          	jalr	-626(ra) # 80005dea <argfd>
    return -1;
    80006064:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006066:	04054163          	bltz	a0,800060a8 <sys_read+0x5c>
    8000606a:	fe440593          	addi	a1,s0,-28
    8000606e:	4509                	li	a0,2
    80006070:	ffffe097          	auipc	ra,0xffffe
    80006074:	89a080e7          	jalr	-1894(ra) # 8000390a <argint>
    return -1;
    80006078:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000607a:	02054763          	bltz	a0,800060a8 <sys_read+0x5c>
    8000607e:	fd840593          	addi	a1,s0,-40
    80006082:	4505                	li	a0,1
    80006084:	ffffe097          	auipc	ra,0xffffe
    80006088:	8a8080e7          	jalr	-1880(ra) # 8000392c <argaddr>
    return -1;
    8000608c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000608e:	00054d63          	bltz	a0,800060a8 <sys_read+0x5c>
  return fileread(f, p, n);
    80006092:	fe442603          	lw	a2,-28(s0)
    80006096:	fd843583          	ld	a1,-40(s0)
    8000609a:	fe843503          	ld	a0,-24(s0)
    8000609e:	fffff097          	auipc	ra,0xfffff
    800060a2:	48a080e7          	jalr	1162(ra) # 80005528 <fileread>
    800060a6:	87aa                	mv	a5,a0
}
    800060a8:	853e                	mv	a0,a5
    800060aa:	70a2                	ld	ra,40(sp)
    800060ac:	7402                	ld	s0,32(sp)
    800060ae:	6145                	addi	sp,sp,48
    800060b0:	8082                	ret

00000000800060b2 <sys_write>:
{
    800060b2:	7179                	addi	sp,sp,-48
    800060b4:	f406                	sd	ra,40(sp)
    800060b6:	f022                	sd	s0,32(sp)
    800060b8:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800060ba:	fe840613          	addi	a2,s0,-24
    800060be:	4581                	li	a1,0
    800060c0:	4501                	li	a0,0
    800060c2:	00000097          	auipc	ra,0x0
    800060c6:	d28080e7          	jalr	-728(ra) # 80005dea <argfd>
    return -1;
    800060ca:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800060cc:	04054163          	bltz	a0,8000610e <sys_write+0x5c>
    800060d0:	fe440593          	addi	a1,s0,-28
    800060d4:	4509                	li	a0,2
    800060d6:	ffffe097          	auipc	ra,0xffffe
    800060da:	834080e7          	jalr	-1996(ra) # 8000390a <argint>
    return -1;
    800060de:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800060e0:	02054763          	bltz	a0,8000610e <sys_write+0x5c>
    800060e4:	fd840593          	addi	a1,s0,-40
    800060e8:	4505                	li	a0,1
    800060ea:	ffffe097          	auipc	ra,0xffffe
    800060ee:	842080e7          	jalr	-1982(ra) # 8000392c <argaddr>
    return -1;
    800060f2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800060f4:	00054d63          	bltz	a0,8000610e <sys_write+0x5c>
  return filewrite(f, p, n);
    800060f8:	fe442603          	lw	a2,-28(s0)
    800060fc:	fd843583          	ld	a1,-40(s0)
    80006100:	fe843503          	ld	a0,-24(s0)
    80006104:	fffff097          	auipc	ra,0xfffff
    80006108:	4e6080e7          	jalr	1254(ra) # 800055ea <filewrite>
    8000610c:	87aa                	mv	a5,a0
}
    8000610e:	853e                	mv	a0,a5
    80006110:	70a2                	ld	ra,40(sp)
    80006112:	7402                	ld	s0,32(sp)
    80006114:	6145                	addi	sp,sp,48
    80006116:	8082                	ret

0000000080006118 <sys_close>:
{
    80006118:	1101                	addi	sp,sp,-32
    8000611a:	ec06                	sd	ra,24(sp)
    8000611c:	e822                	sd	s0,16(sp)
    8000611e:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80006120:	fe040613          	addi	a2,s0,-32
    80006124:	fec40593          	addi	a1,s0,-20
    80006128:	4501                	li	a0,0
    8000612a:	00000097          	auipc	ra,0x0
    8000612e:	cc0080e7          	jalr	-832(ra) # 80005dea <argfd>
    return -1;
    80006132:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80006134:	02054463          	bltz	a0,8000615c <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80006138:	ffffc097          	auipc	ra,0xffffc
    8000613c:	c84080e7          	jalr	-892(ra) # 80001dbc <myproc>
    80006140:	fec42783          	lw	a5,-20(s0)
    80006144:	07f9                	addi	a5,a5,30
    80006146:	078e                	slli	a5,a5,0x3
    80006148:	953e                	add	a0,a0,a5
    8000614a:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000614e:	fe043503          	ld	a0,-32(s0)
    80006152:	fffff097          	auipc	ra,0xfffff
    80006156:	29c080e7          	jalr	668(ra) # 800053ee <fileclose>
  return 0;
    8000615a:	4781                	li	a5,0
}
    8000615c:	853e                	mv	a0,a5
    8000615e:	60e2                	ld	ra,24(sp)
    80006160:	6442                	ld	s0,16(sp)
    80006162:	6105                	addi	sp,sp,32
    80006164:	8082                	ret

0000000080006166 <sys_fstat>:
{
    80006166:	1101                	addi	sp,sp,-32
    80006168:	ec06                	sd	ra,24(sp)
    8000616a:	e822                	sd	s0,16(sp)
    8000616c:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000616e:	fe840613          	addi	a2,s0,-24
    80006172:	4581                	li	a1,0
    80006174:	4501                	li	a0,0
    80006176:	00000097          	auipc	ra,0x0
    8000617a:	c74080e7          	jalr	-908(ra) # 80005dea <argfd>
    return -1;
    8000617e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006180:	02054563          	bltz	a0,800061aa <sys_fstat+0x44>
    80006184:	fe040593          	addi	a1,s0,-32
    80006188:	4505                	li	a0,1
    8000618a:	ffffd097          	auipc	ra,0xffffd
    8000618e:	7a2080e7          	jalr	1954(ra) # 8000392c <argaddr>
    return -1;
    80006192:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006194:	00054b63          	bltz	a0,800061aa <sys_fstat+0x44>
  return filestat(f, st);
    80006198:	fe043583          	ld	a1,-32(s0)
    8000619c:	fe843503          	ld	a0,-24(s0)
    800061a0:	fffff097          	auipc	ra,0xfffff
    800061a4:	316080e7          	jalr	790(ra) # 800054b6 <filestat>
    800061a8:	87aa                	mv	a5,a0
}
    800061aa:	853e                	mv	a0,a5
    800061ac:	60e2                	ld	ra,24(sp)
    800061ae:	6442                	ld	s0,16(sp)
    800061b0:	6105                	addi	sp,sp,32
    800061b2:	8082                	ret

00000000800061b4 <sys_link>:
{
    800061b4:	7169                	addi	sp,sp,-304
    800061b6:	f606                	sd	ra,296(sp)
    800061b8:	f222                	sd	s0,288(sp)
    800061ba:	ee26                	sd	s1,280(sp)
    800061bc:	ea4a                	sd	s2,272(sp)
    800061be:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800061c0:	08000613          	li	a2,128
    800061c4:	ed040593          	addi	a1,s0,-304
    800061c8:	4501                	li	a0,0
    800061ca:	ffffd097          	auipc	ra,0xffffd
    800061ce:	784080e7          	jalr	1924(ra) # 8000394e <argstr>
    return -1;
    800061d2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800061d4:	10054e63          	bltz	a0,800062f0 <sys_link+0x13c>
    800061d8:	08000613          	li	a2,128
    800061dc:	f5040593          	addi	a1,s0,-176
    800061e0:	4505                	li	a0,1
    800061e2:	ffffd097          	auipc	ra,0xffffd
    800061e6:	76c080e7          	jalr	1900(ra) # 8000394e <argstr>
    return -1;
    800061ea:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800061ec:	10054263          	bltz	a0,800062f0 <sys_link+0x13c>
  begin_op();
    800061f0:	fffff097          	auipc	ra,0xfffff
    800061f4:	d36080e7          	jalr	-714(ra) # 80004f26 <begin_op>
  if((ip = namei(old)) == 0){
    800061f8:	ed040513          	addi	a0,s0,-304
    800061fc:	fffff097          	auipc	ra,0xfffff
    80006200:	b0a080e7          	jalr	-1270(ra) # 80004d06 <namei>
    80006204:	84aa                	mv	s1,a0
    80006206:	c551                	beqz	a0,80006292 <sys_link+0xde>
  ilock(ip);
    80006208:	ffffe097          	auipc	ra,0xffffe
    8000620c:	342080e7          	jalr	834(ra) # 8000454a <ilock>
  if(ip->type == T_DIR){
    80006210:	04449703          	lh	a4,68(s1)
    80006214:	4785                	li	a5,1
    80006216:	08f70463          	beq	a4,a5,8000629e <sys_link+0xea>
  ip->nlink++;
    8000621a:	04a4d783          	lhu	a5,74(s1)
    8000621e:	2785                	addiw	a5,a5,1
    80006220:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80006224:	8526                	mv	a0,s1
    80006226:	ffffe097          	auipc	ra,0xffffe
    8000622a:	258080e7          	jalr	600(ra) # 8000447e <iupdate>
  iunlock(ip);
    8000622e:	8526                	mv	a0,s1
    80006230:	ffffe097          	auipc	ra,0xffffe
    80006234:	3dc080e7          	jalr	988(ra) # 8000460c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80006238:	fd040593          	addi	a1,s0,-48
    8000623c:	f5040513          	addi	a0,s0,-176
    80006240:	fffff097          	auipc	ra,0xfffff
    80006244:	ae4080e7          	jalr	-1308(ra) # 80004d24 <nameiparent>
    80006248:	892a                	mv	s2,a0
    8000624a:	c935                	beqz	a0,800062be <sys_link+0x10a>
  ilock(dp);
    8000624c:	ffffe097          	auipc	ra,0xffffe
    80006250:	2fe080e7          	jalr	766(ra) # 8000454a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80006254:	00092703          	lw	a4,0(s2)
    80006258:	409c                	lw	a5,0(s1)
    8000625a:	04f71d63          	bne	a4,a5,800062b4 <sys_link+0x100>
    8000625e:	40d0                	lw	a2,4(s1)
    80006260:	fd040593          	addi	a1,s0,-48
    80006264:	854a                	mv	a0,s2
    80006266:	fffff097          	auipc	ra,0xfffff
    8000626a:	9de080e7          	jalr	-1570(ra) # 80004c44 <dirlink>
    8000626e:	04054363          	bltz	a0,800062b4 <sys_link+0x100>
  iunlockput(dp);
    80006272:	854a                	mv	a0,s2
    80006274:	ffffe097          	auipc	ra,0xffffe
    80006278:	538080e7          	jalr	1336(ra) # 800047ac <iunlockput>
  iput(ip);
    8000627c:	8526                	mv	a0,s1
    8000627e:	ffffe097          	auipc	ra,0xffffe
    80006282:	486080e7          	jalr	1158(ra) # 80004704 <iput>
  end_op();
    80006286:	fffff097          	auipc	ra,0xfffff
    8000628a:	d1e080e7          	jalr	-738(ra) # 80004fa4 <end_op>
  return 0;
    8000628e:	4781                	li	a5,0
    80006290:	a085                	j	800062f0 <sys_link+0x13c>
    end_op();
    80006292:	fffff097          	auipc	ra,0xfffff
    80006296:	d12080e7          	jalr	-750(ra) # 80004fa4 <end_op>
    return -1;
    8000629a:	57fd                	li	a5,-1
    8000629c:	a891                	j	800062f0 <sys_link+0x13c>
    iunlockput(ip);
    8000629e:	8526                	mv	a0,s1
    800062a0:	ffffe097          	auipc	ra,0xffffe
    800062a4:	50c080e7          	jalr	1292(ra) # 800047ac <iunlockput>
    end_op();
    800062a8:	fffff097          	auipc	ra,0xfffff
    800062ac:	cfc080e7          	jalr	-772(ra) # 80004fa4 <end_op>
    return -1;
    800062b0:	57fd                	li	a5,-1
    800062b2:	a83d                	j	800062f0 <sys_link+0x13c>
    iunlockput(dp);
    800062b4:	854a                	mv	a0,s2
    800062b6:	ffffe097          	auipc	ra,0xffffe
    800062ba:	4f6080e7          	jalr	1270(ra) # 800047ac <iunlockput>
  ilock(ip);
    800062be:	8526                	mv	a0,s1
    800062c0:	ffffe097          	auipc	ra,0xffffe
    800062c4:	28a080e7          	jalr	650(ra) # 8000454a <ilock>
  ip->nlink--;
    800062c8:	04a4d783          	lhu	a5,74(s1)
    800062cc:	37fd                	addiw	a5,a5,-1
    800062ce:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800062d2:	8526                	mv	a0,s1
    800062d4:	ffffe097          	auipc	ra,0xffffe
    800062d8:	1aa080e7          	jalr	426(ra) # 8000447e <iupdate>
  iunlockput(ip);
    800062dc:	8526                	mv	a0,s1
    800062de:	ffffe097          	auipc	ra,0xffffe
    800062e2:	4ce080e7          	jalr	1230(ra) # 800047ac <iunlockput>
  end_op();
    800062e6:	fffff097          	auipc	ra,0xfffff
    800062ea:	cbe080e7          	jalr	-834(ra) # 80004fa4 <end_op>
  return -1;
    800062ee:	57fd                	li	a5,-1
}
    800062f0:	853e                	mv	a0,a5
    800062f2:	70b2                	ld	ra,296(sp)
    800062f4:	7412                	ld	s0,288(sp)
    800062f6:	64f2                	ld	s1,280(sp)
    800062f8:	6952                	ld	s2,272(sp)
    800062fa:	6155                	addi	sp,sp,304
    800062fc:	8082                	ret

00000000800062fe <sys_unlink>:
{
    800062fe:	7151                	addi	sp,sp,-240
    80006300:	f586                	sd	ra,232(sp)
    80006302:	f1a2                	sd	s0,224(sp)
    80006304:	eda6                	sd	s1,216(sp)
    80006306:	e9ca                	sd	s2,208(sp)
    80006308:	e5ce                	sd	s3,200(sp)
    8000630a:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000630c:	08000613          	li	a2,128
    80006310:	f3040593          	addi	a1,s0,-208
    80006314:	4501                	li	a0,0
    80006316:	ffffd097          	auipc	ra,0xffffd
    8000631a:	638080e7          	jalr	1592(ra) # 8000394e <argstr>
    8000631e:	18054163          	bltz	a0,800064a0 <sys_unlink+0x1a2>
  begin_op();
    80006322:	fffff097          	auipc	ra,0xfffff
    80006326:	c04080e7          	jalr	-1020(ra) # 80004f26 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000632a:	fb040593          	addi	a1,s0,-80
    8000632e:	f3040513          	addi	a0,s0,-208
    80006332:	fffff097          	auipc	ra,0xfffff
    80006336:	9f2080e7          	jalr	-1550(ra) # 80004d24 <nameiparent>
    8000633a:	84aa                	mv	s1,a0
    8000633c:	c979                	beqz	a0,80006412 <sys_unlink+0x114>
  ilock(dp);
    8000633e:	ffffe097          	auipc	ra,0xffffe
    80006342:	20c080e7          	jalr	524(ra) # 8000454a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80006346:	00003597          	auipc	a1,0x3
    8000634a:	47a58593          	addi	a1,a1,1146 # 800097c0 <syscalls+0x2f8>
    8000634e:	fb040513          	addi	a0,s0,-80
    80006352:	ffffe097          	auipc	ra,0xffffe
    80006356:	6c2080e7          	jalr	1730(ra) # 80004a14 <namecmp>
    8000635a:	14050a63          	beqz	a0,800064ae <sys_unlink+0x1b0>
    8000635e:	00003597          	auipc	a1,0x3
    80006362:	46a58593          	addi	a1,a1,1130 # 800097c8 <syscalls+0x300>
    80006366:	fb040513          	addi	a0,s0,-80
    8000636a:	ffffe097          	auipc	ra,0xffffe
    8000636e:	6aa080e7          	jalr	1706(ra) # 80004a14 <namecmp>
    80006372:	12050e63          	beqz	a0,800064ae <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80006376:	f2c40613          	addi	a2,s0,-212
    8000637a:	fb040593          	addi	a1,s0,-80
    8000637e:	8526                	mv	a0,s1
    80006380:	ffffe097          	auipc	ra,0xffffe
    80006384:	6ae080e7          	jalr	1710(ra) # 80004a2e <dirlookup>
    80006388:	892a                	mv	s2,a0
    8000638a:	12050263          	beqz	a0,800064ae <sys_unlink+0x1b0>
  ilock(ip);
    8000638e:	ffffe097          	auipc	ra,0xffffe
    80006392:	1bc080e7          	jalr	444(ra) # 8000454a <ilock>
  if(ip->nlink < 1)
    80006396:	04a91783          	lh	a5,74(s2)
    8000639a:	08f05263          	blez	a5,8000641e <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000639e:	04491703          	lh	a4,68(s2)
    800063a2:	4785                	li	a5,1
    800063a4:	08f70563          	beq	a4,a5,8000642e <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800063a8:	4641                	li	a2,16
    800063aa:	4581                	li	a1,0
    800063ac:	fc040513          	addi	a0,s0,-64
    800063b0:	ffffb097          	auipc	ra,0xffffb
    800063b4:	964080e7          	jalr	-1692(ra) # 80000d14 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800063b8:	4741                	li	a4,16
    800063ba:	f2c42683          	lw	a3,-212(s0)
    800063be:	fc040613          	addi	a2,s0,-64
    800063c2:	4581                	li	a1,0
    800063c4:	8526                	mv	a0,s1
    800063c6:	ffffe097          	auipc	ra,0xffffe
    800063ca:	530080e7          	jalr	1328(ra) # 800048f6 <writei>
    800063ce:	47c1                	li	a5,16
    800063d0:	0af51563          	bne	a0,a5,8000647a <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800063d4:	04491703          	lh	a4,68(s2)
    800063d8:	4785                	li	a5,1
    800063da:	0af70863          	beq	a4,a5,8000648a <sys_unlink+0x18c>
  iunlockput(dp);
    800063de:	8526                	mv	a0,s1
    800063e0:	ffffe097          	auipc	ra,0xffffe
    800063e4:	3cc080e7          	jalr	972(ra) # 800047ac <iunlockput>
  ip->nlink--;
    800063e8:	04a95783          	lhu	a5,74(s2)
    800063ec:	37fd                	addiw	a5,a5,-1
    800063ee:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800063f2:	854a                	mv	a0,s2
    800063f4:	ffffe097          	auipc	ra,0xffffe
    800063f8:	08a080e7          	jalr	138(ra) # 8000447e <iupdate>
  iunlockput(ip);
    800063fc:	854a                	mv	a0,s2
    800063fe:	ffffe097          	auipc	ra,0xffffe
    80006402:	3ae080e7          	jalr	942(ra) # 800047ac <iunlockput>
  end_op();
    80006406:	fffff097          	auipc	ra,0xfffff
    8000640a:	b9e080e7          	jalr	-1122(ra) # 80004fa4 <end_op>
  return 0;
    8000640e:	4501                	li	a0,0
    80006410:	a84d                	j	800064c2 <sys_unlink+0x1c4>
    end_op();
    80006412:	fffff097          	auipc	ra,0xfffff
    80006416:	b92080e7          	jalr	-1134(ra) # 80004fa4 <end_op>
    return -1;
    8000641a:	557d                	li	a0,-1
    8000641c:	a05d                	j	800064c2 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000641e:	00003517          	auipc	a0,0x3
    80006422:	3d250513          	addi	a0,a0,978 # 800097f0 <syscalls+0x328>
    80006426:	ffffa097          	auipc	ra,0xffffa
    8000642a:	114080e7          	jalr	276(ra) # 8000053a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000642e:	04c92703          	lw	a4,76(s2)
    80006432:	02000793          	li	a5,32
    80006436:	f6e7f9e3          	bgeu	a5,a4,800063a8 <sys_unlink+0xaa>
    8000643a:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000643e:	4741                	li	a4,16
    80006440:	86ce                	mv	a3,s3
    80006442:	f1840613          	addi	a2,s0,-232
    80006446:	4581                	li	a1,0
    80006448:	854a                	mv	a0,s2
    8000644a:	ffffe097          	auipc	ra,0xffffe
    8000644e:	3b4080e7          	jalr	948(ra) # 800047fe <readi>
    80006452:	47c1                	li	a5,16
    80006454:	00f51b63          	bne	a0,a5,8000646a <sys_unlink+0x16c>
    if(de.inum != 0)
    80006458:	f1845783          	lhu	a5,-232(s0)
    8000645c:	e7a1                	bnez	a5,800064a4 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000645e:	29c1                	addiw	s3,s3,16
    80006460:	04c92783          	lw	a5,76(s2)
    80006464:	fcf9ede3          	bltu	s3,a5,8000643e <sys_unlink+0x140>
    80006468:	b781                	j	800063a8 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    8000646a:	00003517          	auipc	a0,0x3
    8000646e:	39e50513          	addi	a0,a0,926 # 80009808 <syscalls+0x340>
    80006472:	ffffa097          	auipc	ra,0xffffa
    80006476:	0c8080e7          	jalr	200(ra) # 8000053a <panic>
    panic("unlink: writei");
    8000647a:	00003517          	auipc	a0,0x3
    8000647e:	3a650513          	addi	a0,a0,934 # 80009820 <syscalls+0x358>
    80006482:	ffffa097          	auipc	ra,0xffffa
    80006486:	0b8080e7          	jalr	184(ra) # 8000053a <panic>
    dp->nlink--;
    8000648a:	04a4d783          	lhu	a5,74(s1)
    8000648e:	37fd                	addiw	a5,a5,-1
    80006490:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80006494:	8526                	mv	a0,s1
    80006496:	ffffe097          	auipc	ra,0xffffe
    8000649a:	fe8080e7          	jalr	-24(ra) # 8000447e <iupdate>
    8000649e:	b781                	j	800063de <sys_unlink+0xe0>
    return -1;
    800064a0:	557d                	li	a0,-1
    800064a2:	a005                	j	800064c2 <sys_unlink+0x1c4>
    iunlockput(ip);
    800064a4:	854a                	mv	a0,s2
    800064a6:	ffffe097          	auipc	ra,0xffffe
    800064aa:	306080e7          	jalr	774(ra) # 800047ac <iunlockput>
  iunlockput(dp);
    800064ae:	8526                	mv	a0,s1
    800064b0:	ffffe097          	auipc	ra,0xffffe
    800064b4:	2fc080e7          	jalr	764(ra) # 800047ac <iunlockput>
  end_op();
    800064b8:	fffff097          	auipc	ra,0xfffff
    800064bc:	aec080e7          	jalr	-1300(ra) # 80004fa4 <end_op>
  return -1;
    800064c0:	557d                	li	a0,-1
}
    800064c2:	70ae                	ld	ra,232(sp)
    800064c4:	740e                	ld	s0,224(sp)
    800064c6:	64ee                	ld	s1,216(sp)
    800064c8:	694e                	ld	s2,208(sp)
    800064ca:	69ae                	ld	s3,200(sp)
    800064cc:	616d                	addi	sp,sp,240
    800064ce:	8082                	ret

00000000800064d0 <sys_open>:

uint64
sys_open(void)
{
    800064d0:	7131                	addi	sp,sp,-192
    800064d2:	fd06                	sd	ra,184(sp)
    800064d4:	f922                	sd	s0,176(sp)
    800064d6:	f526                	sd	s1,168(sp)
    800064d8:	f14a                	sd	s2,160(sp)
    800064da:	ed4e                	sd	s3,152(sp)
    800064dc:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800064de:	08000613          	li	a2,128
    800064e2:	f5040593          	addi	a1,s0,-176
    800064e6:	4501                	li	a0,0
    800064e8:	ffffd097          	auipc	ra,0xffffd
    800064ec:	466080e7          	jalr	1126(ra) # 8000394e <argstr>
    return -1;
    800064f0:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800064f2:	0c054163          	bltz	a0,800065b4 <sys_open+0xe4>
    800064f6:	f4c40593          	addi	a1,s0,-180
    800064fa:	4505                	li	a0,1
    800064fc:	ffffd097          	auipc	ra,0xffffd
    80006500:	40e080e7          	jalr	1038(ra) # 8000390a <argint>
    80006504:	0a054863          	bltz	a0,800065b4 <sys_open+0xe4>

  begin_op();
    80006508:	fffff097          	auipc	ra,0xfffff
    8000650c:	a1e080e7          	jalr	-1506(ra) # 80004f26 <begin_op>

  if(omode & O_CREATE){
    80006510:	f4c42783          	lw	a5,-180(s0)
    80006514:	2007f793          	andi	a5,a5,512
    80006518:	cbdd                	beqz	a5,800065ce <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000651a:	4681                	li	a3,0
    8000651c:	4601                	li	a2,0
    8000651e:	4589                	li	a1,2
    80006520:	f5040513          	addi	a0,s0,-176
    80006524:	00000097          	auipc	ra,0x0
    80006528:	970080e7          	jalr	-1680(ra) # 80005e94 <create>
    8000652c:	892a                	mv	s2,a0
    if(ip == 0){
    8000652e:	c959                	beqz	a0,800065c4 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80006530:	04491703          	lh	a4,68(s2)
    80006534:	478d                	li	a5,3
    80006536:	00f71763          	bne	a4,a5,80006544 <sys_open+0x74>
    8000653a:	04695703          	lhu	a4,70(s2)
    8000653e:	47a5                	li	a5,9
    80006540:	0ce7ec63          	bltu	a5,a4,80006618 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80006544:	fffff097          	auipc	ra,0xfffff
    80006548:	dee080e7          	jalr	-530(ra) # 80005332 <filealloc>
    8000654c:	89aa                	mv	s3,a0
    8000654e:	10050263          	beqz	a0,80006652 <sys_open+0x182>
    80006552:	00000097          	auipc	ra,0x0
    80006556:	900080e7          	jalr	-1792(ra) # 80005e52 <fdalloc>
    8000655a:	84aa                	mv	s1,a0
    8000655c:	0e054663          	bltz	a0,80006648 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80006560:	04491703          	lh	a4,68(s2)
    80006564:	478d                	li	a5,3
    80006566:	0cf70463          	beq	a4,a5,8000662e <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000656a:	4789                	li	a5,2
    8000656c:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80006570:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80006574:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80006578:	f4c42783          	lw	a5,-180(s0)
    8000657c:	0017c713          	xori	a4,a5,1
    80006580:	8b05                	andi	a4,a4,1
    80006582:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80006586:	0037f713          	andi	a4,a5,3
    8000658a:	00e03733          	snez	a4,a4
    8000658e:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80006592:	4007f793          	andi	a5,a5,1024
    80006596:	c791                	beqz	a5,800065a2 <sys_open+0xd2>
    80006598:	04491703          	lh	a4,68(s2)
    8000659c:	4789                	li	a5,2
    8000659e:	08f70f63          	beq	a4,a5,8000663c <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800065a2:	854a                	mv	a0,s2
    800065a4:	ffffe097          	auipc	ra,0xffffe
    800065a8:	068080e7          	jalr	104(ra) # 8000460c <iunlock>
  end_op();
    800065ac:	fffff097          	auipc	ra,0xfffff
    800065b0:	9f8080e7          	jalr	-1544(ra) # 80004fa4 <end_op>

  return fd;
}
    800065b4:	8526                	mv	a0,s1
    800065b6:	70ea                	ld	ra,184(sp)
    800065b8:	744a                	ld	s0,176(sp)
    800065ba:	74aa                	ld	s1,168(sp)
    800065bc:	790a                	ld	s2,160(sp)
    800065be:	69ea                	ld	s3,152(sp)
    800065c0:	6129                	addi	sp,sp,192
    800065c2:	8082                	ret
      end_op();
    800065c4:	fffff097          	auipc	ra,0xfffff
    800065c8:	9e0080e7          	jalr	-1568(ra) # 80004fa4 <end_op>
      return -1;
    800065cc:	b7e5                	j	800065b4 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800065ce:	f5040513          	addi	a0,s0,-176
    800065d2:	ffffe097          	auipc	ra,0xffffe
    800065d6:	734080e7          	jalr	1844(ra) # 80004d06 <namei>
    800065da:	892a                	mv	s2,a0
    800065dc:	c905                	beqz	a0,8000660c <sys_open+0x13c>
    ilock(ip);
    800065de:	ffffe097          	auipc	ra,0xffffe
    800065e2:	f6c080e7          	jalr	-148(ra) # 8000454a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800065e6:	04491703          	lh	a4,68(s2)
    800065ea:	4785                	li	a5,1
    800065ec:	f4f712e3          	bne	a4,a5,80006530 <sys_open+0x60>
    800065f0:	f4c42783          	lw	a5,-180(s0)
    800065f4:	dba1                	beqz	a5,80006544 <sys_open+0x74>
      iunlockput(ip);
    800065f6:	854a                	mv	a0,s2
    800065f8:	ffffe097          	auipc	ra,0xffffe
    800065fc:	1b4080e7          	jalr	436(ra) # 800047ac <iunlockput>
      end_op();
    80006600:	fffff097          	auipc	ra,0xfffff
    80006604:	9a4080e7          	jalr	-1628(ra) # 80004fa4 <end_op>
      return -1;
    80006608:	54fd                	li	s1,-1
    8000660a:	b76d                	j	800065b4 <sys_open+0xe4>
      end_op();
    8000660c:	fffff097          	auipc	ra,0xfffff
    80006610:	998080e7          	jalr	-1640(ra) # 80004fa4 <end_op>
      return -1;
    80006614:	54fd                	li	s1,-1
    80006616:	bf79                	j	800065b4 <sys_open+0xe4>
    iunlockput(ip);
    80006618:	854a                	mv	a0,s2
    8000661a:	ffffe097          	auipc	ra,0xffffe
    8000661e:	192080e7          	jalr	402(ra) # 800047ac <iunlockput>
    end_op();
    80006622:	fffff097          	auipc	ra,0xfffff
    80006626:	982080e7          	jalr	-1662(ra) # 80004fa4 <end_op>
    return -1;
    8000662a:	54fd                	li	s1,-1
    8000662c:	b761                	j	800065b4 <sys_open+0xe4>
    f->type = FD_DEVICE;
    8000662e:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80006632:	04691783          	lh	a5,70(s2)
    80006636:	02f99223          	sh	a5,36(s3)
    8000663a:	bf2d                	j	80006574 <sys_open+0xa4>
    itrunc(ip);
    8000663c:	854a                	mv	a0,s2
    8000663e:	ffffe097          	auipc	ra,0xffffe
    80006642:	01a080e7          	jalr	26(ra) # 80004658 <itrunc>
    80006646:	bfb1                	j	800065a2 <sys_open+0xd2>
      fileclose(f);
    80006648:	854e                	mv	a0,s3
    8000664a:	fffff097          	auipc	ra,0xfffff
    8000664e:	da4080e7          	jalr	-604(ra) # 800053ee <fileclose>
    iunlockput(ip);
    80006652:	854a                	mv	a0,s2
    80006654:	ffffe097          	auipc	ra,0xffffe
    80006658:	158080e7          	jalr	344(ra) # 800047ac <iunlockput>
    end_op();
    8000665c:	fffff097          	auipc	ra,0xfffff
    80006660:	948080e7          	jalr	-1720(ra) # 80004fa4 <end_op>
    return -1;
    80006664:	54fd                	li	s1,-1
    80006666:	b7b9                	j	800065b4 <sys_open+0xe4>

0000000080006668 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80006668:	7175                	addi	sp,sp,-144
    8000666a:	e506                	sd	ra,136(sp)
    8000666c:	e122                	sd	s0,128(sp)
    8000666e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80006670:	fffff097          	auipc	ra,0xfffff
    80006674:	8b6080e7          	jalr	-1866(ra) # 80004f26 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80006678:	08000613          	li	a2,128
    8000667c:	f7040593          	addi	a1,s0,-144
    80006680:	4501                	li	a0,0
    80006682:	ffffd097          	auipc	ra,0xffffd
    80006686:	2cc080e7          	jalr	716(ra) # 8000394e <argstr>
    8000668a:	02054963          	bltz	a0,800066bc <sys_mkdir+0x54>
    8000668e:	4681                	li	a3,0
    80006690:	4601                	li	a2,0
    80006692:	4585                	li	a1,1
    80006694:	f7040513          	addi	a0,s0,-144
    80006698:	fffff097          	auipc	ra,0xfffff
    8000669c:	7fc080e7          	jalr	2044(ra) # 80005e94 <create>
    800066a0:	cd11                	beqz	a0,800066bc <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800066a2:	ffffe097          	auipc	ra,0xffffe
    800066a6:	10a080e7          	jalr	266(ra) # 800047ac <iunlockput>
  end_op();
    800066aa:	fffff097          	auipc	ra,0xfffff
    800066ae:	8fa080e7          	jalr	-1798(ra) # 80004fa4 <end_op>
  return 0;
    800066b2:	4501                	li	a0,0
}
    800066b4:	60aa                	ld	ra,136(sp)
    800066b6:	640a                	ld	s0,128(sp)
    800066b8:	6149                	addi	sp,sp,144
    800066ba:	8082                	ret
    end_op();
    800066bc:	fffff097          	auipc	ra,0xfffff
    800066c0:	8e8080e7          	jalr	-1816(ra) # 80004fa4 <end_op>
    return -1;
    800066c4:	557d                	li	a0,-1
    800066c6:	b7fd                	j	800066b4 <sys_mkdir+0x4c>

00000000800066c8 <sys_mknod>:

uint64
sys_mknod(void)
{
    800066c8:	7135                	addi	sp,sp,-160
    800066ca:	ed06                	sd	ra,152(sp)
    800066cc:	e922                	sd	s0,144(sp)
    800066ce:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800066d0:	fffff097          	auipc	ra,0xfffff
    800066d4:	856080e7          	jalr	-1962(ra) # 80004f26 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800066d8:	08000613          	li	a2,128
    800066dc:	f7040593          	addi	a1,s0,-144
    800066e0:	4501                	li	a0,0
    800066e2:	ffffd097          	auipc	ra,0xffffd
    800066e6:	26c080e7          	jalr	620(ra) # 8000394e <argstr>
    800066ea:	04054a63          	bltz	a0,8000673e <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    800066ee:	f6c40593          	addi	a1,s0,-148
    800066f2:	4505                	li	a0,1
    800066f4:	ffffd097          	auipc	ra,0xffffd
    800066f8:	216080e7          	jalr	534(ra) # 8000390a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800066fc:	04054163          	bltz	a0,8000673e <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80006700:	f6840593          	addi	a1,s0,-152
    80006704:	4509                	li	a0,2
    80006706:	ffffd097          	auipc	ra,0xffffd
    8000670a:	204080e7          	jalr	516(ra) # 8000390a <argint>
     argint(1, &major) < 0 ||
    8000670e:	02054863          	bltz	a0,8000673e <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80006712:	f6841683          	lh	a3,-152(s0)
    80006716:	f6c41603          	lh	a2,-148(s0)
    8000671a:	458d                	li	a1,3
    8000671c:	f7040513          	addi	a0,s0,-144
    80006720:	fffff097          	auipc	ra,0xfffff
    80006724:	774080e7          	jalr	1908(ra) # 80005e94 <create>
     argint(2, &minor) < 0 ||
    80006728:	c919                	beqz	a0,8000673e <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000672a:	ffffe097          	auipc	ra,0xffffe
    8000672e:	082080e7          	jalr	130(ra) # 800047ac <iunlockput>
  end_op();
    80006732:	fffff097          	auipc	ra,0xfffff
    80006736:	872080e7          	jalr	-1934(ra) # 80004fa4 <end_op>
  return 0;
    8000673a:	4501                	li	a0,0
    8000673c:	a031                	j	80006748 <sys_mknod+0x80>
    end_op();
    8000673e:	fffff097          	auipc	ra,0xfffff
    80006742:	866080e7          	jalr	-1946(ra) # 80004fa4 <end_op>
    return -1;
    80006746:	557d                	li	a0,-1
}
    80006748:	60ea                	ld	ra,152(sp)
    8000674a:	644a                	ld	s0,144(sp)
    8000674c:	610d                	addi	sp,sp,160
    8000674e:	8082                	ret

0000000080006750 <sys_chdir>:

uint64
sys_chdir(void)
{
    80006750:	7135                	addi	sp,sp,-160
    80006752:	ed06                	sd	ra,152(sp)
    80006754:	e922                	sd	s0,144(sp)
    80006756:	e526                	sd	s1,136(sp)
    80006758:	e14a                	sd	s2,128(sp)
    8000675a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000675c:	ffffb097          	auipc	ra,0xffffb
    80006760:	660080e7          	jalr	1632(ra) # 80001dbc <myproc>
    80006764:	892a                	mv	s2,a0
  
  begin_op();
    80006766:	ffffe097          	auipc	ra,0xffffe
    8000676a:	7c0080e7          	jalr	1984(ra) # 80004f26 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000676e:	08000613          	li	a2,128
    80006772:	f6040593          	addi	a1,s0,-160
    80006776:	4501                	li	a0,0
    80006778:	ffffd097          	auipc	ra,0xffffd
    8000677c:	1d6080e7          	jalr	470(ra) # 8000394e <argstr>
    80006780:	04054b63          	bltz	a0,800067d6 <sys_chdir+0x86>
    80006784:	f6040513          	addi	a0,s0,-160
    80006788:	ffffe097          	auipc	ra,0xffffe
    8000678c:	57e080e7          	jalr	1406(ra) # 80004d06 <namei>
    80006790:	84aa                	mv	s1,a0
    80006792:	c131                	beqz	a0,800067d6 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006794:	ffffe097          	auipc	ra,0xffffe
    80006798:	db6080e7          	jalr	-586(ra) # 8000454a <ilock>
  if(ip->type != T_DIR){
    8000679c:	04449703          	lh	a4,68(s1)
    800067a0:	4785                	li	a5,1
    800067a2:	04f71063          	bne	a4,a5,800067e2 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800067a6:	8526                	mv	a0,s1
    800067a8:	ffffe097          	auipc	ra,0xffffe
    800067ac:	e64080e7          	jalr	-412(ra) # 8000460c <iunlock>
  iput(p->cwd);
    800067b0:	17093503          	ld	a0,368(s2)
    800067b4:	ffffe097          	auipc	ra,0xffffe
    800067b8:	f50080e7          	jalr	-176(ra) # 80004704 <iput>
  end_op();
    800067bc:	ffffe097          	auipc	ra,0xffffe
    800067c0:	7e8080e7          	jalr	2024(ra) # 80004fa4 <end_op>
  p->cwd = ip;
    800067c4:	16993823          	sd	s1,368(s2)
  return 0;
    800067c8:	4501                	li	a0,0
}
    800067ca:	60ea                	ld	ra,152(sp)
    800067cc:	644a                	ld	s0,144(sp)
    800067ce:	64aa                	ld	s1,136(sp)
    800067d0:	690a                	ld	s2,128(sp)
    800067d2:	610d                	addi	sp,sp,160
    800067d4:	8082                	ret
    end_op();
    800067d6:	ffffe097          	auipc	ra,0xffffe
    800067da:	7ce080e7          	jalr	1998(ra) # 80004fa4 <end_op>
    return -1;
    800067de:	557d                	li	a0,-1
    800067e0:	b7ed                	j	800067ca <sys_chdir+0x7a>
    iunlockput(ip);
    800067e2:	8526                	mv	a0,s1
    800067e4:	ffffe097          	auipc	ra,0xffffe
    800067e8:	fc8080e7          	jalr	-56(ra) # 800047ac <iunlockput>
    end_op();
    800067ec:	ffffe097          	auipc	ra,0xffffe
    800067f0:	7b8080e7          	jalr	1976(ra) # 80004fa4 <end_op>
    return -1;
    800067f4:	557d                	li	a0,-1
    800067f6:	bfd1                	j	800067ca <sys_chdir+0x7a>

00000000800067f8 <sys_exec>:

uint64
sys_exec(void)
{
    800067f8:	7145                	addi	sp,sp,-464
    800067fa:	e786                	sd	ra,456(sp)
    800067fc:	e3a2                	sd	s0,448(sp)
    800067fe:	ff26                	sd	s1,440(sp)
    80006800:	fb4a                	sd	s2,432(sp)
    80006802:	f74e                	sd	s3,424(sp)
    80006804:	f352                	sd	s4,416(sp)
    80006806:	ef56                	sd	s5,408(sp)
    80006808:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    8000680a:	08000613          	li	a2,128
    8000680e:	f4040593          	addi	a1,s0,-192
    80006812:	4501                	li	a0,0
    80006814:	ffffd097          	auipc	ra,0xffffd
    80006818:	13a080e7          	jalr	314(ra) # 8000394e <argstr>
    return -1;
    8000681c:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    8000681e:	0c054b63          	bltz	a0,800068f4 <sys_exec+0xfc>
    80006822:	e3840593          	addi	a1,s0,-456
    80006826:	4505                	li	a0,1
    80006828:	ffffd097          	auipc	ra,0xffffd
    8000682c:	104080e7          	jalr	260(ra) # 8000392c <argaddr>
    80006830:	0c054263          	bltz	a0,800068f4 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80006834:	10000613          	li	a2,256
    80006838:	4581                	li	a1,0
    8000683a:	e4040513          	addi	a0,s0,-448
    8000683e:	ffffa097          	auipc	ra,0xffffa
    80006842:	4d6080e7          	jalr	1238(ra) # 80000d14 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006846:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    8000684a:	89a6                	mv	s3,s1
    8000684c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000684e:	02000a13          	li	s4,32
    80006852:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006856:	00391513          	slli	a0,s2,0x3
    8000685a:	e3040593          	addi	a1,s0,-464
    8000685e:	e3843783          	ld	a5,-456(s0)
    80006862:	953e                	add	a0,a0,a5
    80006864:	ffffd097          	auipc	ra,0xffffd
    80006868:	00c080e7          	jalr	12(ra) # 80003870 <fetchaddr>
    8000686c:	02054a63          	bltz	a0,800068a0 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80006870:	e3043783          	ld	a5,-464(s0)
    80006874:	c3b9                	beqz	a5,800068ba <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006876:	ffffa097          	auipc	ra,0xffffa
    8000687a:	26a080e7          	jalr	618(ra) # 80000ae0 <kalloc>
    8000687e:	85aa                	mv	a1,a0
    80006880:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006884:	cd11                	beqz	a0,800068a0 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006886:	6605                	lui	a2,0x1
    80006888:	e3043503          	ld	a0,-464(s0)
    8000688c:	ffffd097          	auipc	ra,0xffffd
    80006890:	036080e7          	jalr	54(ra) # 800038c2 <fetchstr>
    80006894:	00054663          	bltz	a0,800068a0 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80006898:	0905                	addi	s2,s2,1
    8000689a:	09a1                	addi	s3,s3,8
    8000689c:	fb491be3          	bne	s2,s4,80006852 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800068a0:	f4040913          	addi	s2,s0,-192
    800068a4:	6088                	ld	a0,0(s1)
    800068a6:	c531                	beqz	a0,800068f2 <sys_exec+0xfa>
    kfree(argv[i]);
    800068a8:	ffffa097          	auipc	ra,0xffffa
    800068ac:	13a080e7          	jalr	314(ra) # 800009e2 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800068b0:	04a1                	addi	s1,s1,8
    800068b2:	ff2499e3          	bne	s1,s2,800068a4 <sys_exec+0xac>
  return -1;
    800068b6:	597d                	li	s2,-1
    800068b8:	a835                	j	800068f4 <sys_exec+0xfc>
      argv[i] = 0;
    800068ba:	0a8e                	slli	s5,s5,0x3
    800068bc:	fc0a8793          	addi	a5,s5,-64 # ffffffffffffefc0 <end+0xffffffff7ffc6fc0>
    800068c0:	00878ab3          	add	s5,a5,s0
    800068c4:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    800068c8:	e4040593          	addi	a1,s0,-448
    800068cc:	f4040513          	addi	a0,s0,-192
    800068d0:	fffff097          	auipc	ra,0xfffff
    800068d4:	172080e7          	jalr	370(ra) # 80005a42 <exec>
    800068d8:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800068da:	f4040993          	addi	s3,s0,-192
    800068de:	6088                	ld	a0,0(s1)
    800068e0:	c911                	beqz	a0,800068f4 <sys_exec+0xfc>
    kfree(argv[i]);
    800068e2:	ffffa097          	auipc	ra,0xffffa
    800068e6:	100080e7          	jalr	256(ra) # 800009e2 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800068ea:	04a1                	addi	s1,s1,8
    800068ec:	ff3499e3          	bne	s1,s3,800068de <sys_exec+0xe6>
    800068f0:	a011                	j	800068f4 <sys_exec+0xfc>
  return -1;
    800068f2:	597d                	li	s2,-1
}
    800068f4:	854a                	mv	a0,s2
    800068f6:	60be                	ld	ra,456(sp)
    800068f8:	641e                	ld	s0,448(sp)
    800068fa:	74fa                	ld	s1,440(sp)
    800068fc:	795a                	ld	s2,432(sp)
    800068fe:	79ba                	ld	s3,424(sp)
    80006900:	7a1a                	ld	s4,416(sp)
    80006902:	6afa                	ld	s5,408(sp)
    80006904:	6179                	addi	sp,sp,464
    80006906:	8082                	ret

0000000080006908 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006908:	7139                	addi	sp,sp,-64
    8000690a:	fc06                	sd	ra,56(sp)
    8000690c:	f822                	sd	s0,48(sp)
    8000690e:	f426                	sd	s1,40(sp)
    80006910:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006912:	ffffb097          	auipc	ra,0xffffb
    80006916:	4aa080e7          	jalr	1194(ra) # 80001dbc <myproc>
    8000691a:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    8000691c:	fd840593          	addi	a1,s0,-40
    80006920:	4501                	li	a0,0
    80006922:	ffffd097          	auipc	ra,0xffffd
    80006926:	00a080e7          	jalr	10(ra) # 8000392c <argaddr>
    return -1;
    8000692a:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    8000692c:	0e054063          	bltz	a0,80006a0c <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80006930:	fc840593          	addi	a1,s0,-56
    80006934:	fd040513          	addi	a0,s0,-48
    80006938:	fffff097          	auipc	ra,0xfffff
    8000693c:	de6080e7          	jalr	-538(ra) # 8000571e <pipealloc>
    return -1;
    80006940:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006942:	0c054563          	bltz	a0,80006a0c <sys_pipe+0x104>
  fd0 = -1;
    80006946:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000694a:	fd043503          	ld	a0,-48(s0)
    8000694e:	fffff097          	auipc	ra,0xfffff
    80006952:	504080e7          	jalr	1284(ra) # 80005e52 <fdalloc>
    80006956:	fca42223          	sw	a0,-60(s0)
    8000695a:	08054c63          	bltz	a0,800069f2 <sys_pipe+0xea>
    8000695e:	fc843503          	ld	a0,-56(s0)
    80006962:	fffff097          	auipc	ra,0xfffff
    80006966:	4f0080e7          	jalr	1264(ra) # 80005e52 <fdalloc>
    8000696a:	fca42023          	sw	a0,-64(s0)
    8000696e:	06054963          	bltz	a0,800069e0 <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006972:	4691                	li	a3,4
    80006974:	fc440613          	addi	a2,s0,-60
    80006978:	fd843583          	ld	a1,-40(s0)
    8000697c:	78a8                	ld	a0,112(s1)
    8000697e:	ffffb097          	auipc	ra,0xffffb
    80006982:	dce080e7          	jalr	-562(ra) # 8000174c <copyout>
    80006986:	02054063          	bltz	a0,800069a6 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000698a:	4691                	li	a3,4
    8000698c:	fc040613          	addi	a2,s0,-64
    80006990:	fd843583          	ld	a1,-40(s0)
    80006994:	0591                	addi	a1,a1,4
    80006996:	78a8                	ld	a0,112(s1)
    80006998:	ffffb097          	auipc	ra,0xffffb
    8000699c:	db4080e7          	jalr	-588(ra) # 8000174c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800069a0:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800069a2:	06055563          	bgez	a0,80006a0c <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    800069a6:	fc442783          	lw	a5,-60(s0)
    800069aa:	07f9                	addi	a5,a5,30
    800069ac:	078e                	slli	a5,a5,0x3
    800069ae:	97a6                	add	a5,a5,s1
    800069b0:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800069b4:	fc042783          	lw	a5,-64(s0)
    800069b8:	07f9                	addi	a5,a5,30
    800069ba:	078e                	slli	a5,a5,0x3
    800069bc:	00f48533          	add	a0,s1,a5
    800069c0:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    800069c4:	fd043503          	ld	a0,-48(s0)
    800069c8:	fffff097          	auipc	ra,0xfffff
    800069cc:	a26080e7          	jalr	-1498(ra) # 800053ee <fileclose>
    fileclose(wf);
    800069d0:	fc843503          	ld	a0,-56(s0)
    800069d4:	fffff097          	auipc	ra,0xfffff
    800069d8:	a1a080e7          	jalr	-1510(ra) # 800053ee <fileclose>
    return -1;
    800069dc:	57fd                	li	a5,-1
    800069de:	a03d                	j	80006a0c <sys_pipe+0x104>
    if(fd0 >= 0)
    800069e0:	fc442783          	lw	a5,-60(s0)
    800069e4:	0007c763          	bltz	a5,800069f2 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    800069e8:	07f9                	addi	a5,a5,30
    800069ea:	078e                	slli	a5,a5,0x3
    800069ec:	97a6                	add	a5,a5,s1
    800069ee:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800069f2:	fd043503          	ld	a0,-48(s0)
    800069f6:	fffff097          	auipc	ra,0xfffff
    800069fa:	9f8080e7          	jalr	-1544(ra) # 800053ee <fileclose>
    fileclose(wf);
    800069fe:	fc843503          	ld	a0,-56(s0)
    80006a02:	fffff097          	auipc	ra,0xfffff
    80006a06:	9ec080e7          	jalr	-1556(ra) # 800053ee <fileclose>
    return -1;
    80006a0a:	57fd                	li	a5,-1
}
    80006a0c:	853e                	mv	a0,a5
    80006a0e:	70e2                	ld	ra,56(sp)
    80006a10:	7442                	ld	s0,48(sp)
    80006a12:	74a2                	ld	s1,40(sp)
    80006a14:	6121                	addi	sp,sp,64
    80006a16:	8082                	ret

0000000080006a18 <sys_mmap>:
//Added for lab 3

// Create a new mapped memory region
uint64
sys_mmap()
{
    80006a18:	7139                	addi	sp,sp,-64
    80006a1a:	fc06                	sd	ra,56(sp)
    80006a1c:	f822                	sd	s0,48(sp)
    80006a1e:	f426                	sd	s1,40(sp)
    80006a20:	f04a                	sd	s2,32(sp)
    80006a22:	ec4e                	sd	s3,24(sp)
    80006a24:	0080                	addi	s0,sp,64
  uint64 length;
  int prot;
  int flags;
  struct proc *p = myproc();
    80006a26:	ffffb097          	auipc	ra,0xffffb
    80006a2a:	396080e7          	jalr	918(ra) # 80001dbc <myproc>
    80006a2e:	89aa                	mv	s3,a0
  struct mmr *newmmr = 0;
  uint64 start_addr;

  /* Add error checking for length, prot, and flags arguments */
  
  if (argaddr(1, &length) < 0)
    80006a30:	fc840593          	addi	a1,s0,-56
    80006a34:	4505                	li	a0,1
    80006a36:	ffffd097          	auipc	ra,0xffffd
    80006a3a:	ef6080e7          	jalr	-266(ra) # 8000392c <argaddr>
  return -1;
    80006a3e:	597d                	li	s2,-1
  if (argaddr(1, &length) < 0)
    80006a40:	0a054c63          	bltz	a0,80006af8 <sys_mmap+0xe0>
  if (argint(2, &prot) < 0)
    80006a44:	fc440593          	addi	a1,s0,-60
    80006a48:	4509                	li	a0,2
    80006a4a:	ffffd097          	auipc	ra,0xffffd
    80006a4e:	ec0080e7          	jalr	-320(ra) # 8000390a <argint>
    80006a52:	0a054363          	bltz	a0,80006af8 <sys_mmap+0xe0>
  return -1;
  if (argint(3, &flags) <0)
    80006a56:	fc040593          	addi	a1,s0,-64
    80006a5a:	450d                	li	a0,3
    80006a5c:	ffffd097          	auipc	ra,0xffffd
    80006a60:	eae080e7          	jalr	-338(ra) # 8000390a <argint>
    80006a64:	0c054763          	bltz	a0,80006b32 <sys_mmap+0x11a>
    80006a68:	19c98793          	addi	a5,s3,412
  return -1;
  // Search p->mmr[] for unused location
  for (int i = 0; i < MAX_MMR; i++) {
    80006a6c:	4481                	li	s1,0
    80006a6e:	46a9                	li	a3,10
    if (p->mmr[i].valid == 0) {
    80006a70:	4398                	lw	a4,0(a5)
    80006a72:	cb01                	beqz	a4,80006a82 <sys_mmap+0x6a>
  for (int i = 0; i < MAX_MMR; i++) {
    80006a74:	2485                	addiw	s1,s1,1
    80006a76:	04878793          	addi	a5,a5,72
    80006a7a:	fed49be3          	bne	s1,a3,80006a70 <sys_mmap+0x58>
      newmmr->mmr_family.listid = alloc_mmr_listid();

    p->cur_max = start_addr;
    return start_addr;
  } else {
    return -1;
    80006a7e:	597d                	li	s2,-1
    80006a80:	a8a5                	j	80006af8 <sys_mmap+0xe0>
    start_addr = PGROUNDDOWN(p->cur_max - length);
    80006a82:	4589b603          	ld	a2,1112(s3)
    80006a86:	fc843903          	ld	s2,-56(s0)
    80006a8a:	41260933          	sub	s2,a2,s2
    80006a8e:	77fd                	lui	a5,0xfffff
    80006a90:	00f97933          	and	s2,s2,a5
    newmmr->valid = 1;
    80006a94:	00349713          	slli	a4,s1,0x3
    80006a98:	009707b3          	add	a5,a4,s1
    80006a9c:	078e                	slli	a5,a5,0x3
    80006a9e:	97ce                	add	a5,a5,s3
    80006aa0:	4685                	li	a3,1
    80006aa2:	18d7ae23          	sw	a3,412(a5) # fffffffffffff19c <end+0xffffffff7ffc719c>
    newmmr->addr = start_addr;
    80006aa6:	1927b423          	sd	s2,392(a5)
    newmmr->length = p->cur_max - start_addr;
    80006aaa:	4126063b          	subw	a2,a2,s2
    80006aae:	18c7a823          	sw	a2,400(a5)
    newmmr->prot = prot;
    80006ab2:	fc442683          	lw	a3,-60(s0)
    80006ab6:	18d7aa23          	sw	a3,404(a5)
    newmmr->flags = flags;
    80006aba:	fc042683          	lw	a3,-64(s0)
    80006abe:	18d7ac23          	sw	a3,408(a5)
    newmmr->mmr_family.proc = p;
    80006ac2:	1b37bc23          	sd	s3,440(a5)
    newmmr->mmr_family.next = &(newmmr->mmr_family); // next points to its own mmr_node
    80006ac6:	9726                	add	a4,a4,s1
    80006ac8:	070e                	slli	a4,a4,0x3
    80006aca:	1b070713          	addi	a4,a4,432
    80006ace:	974e                	add	a4,a4,s3
    80006ad0:	1ce7b023          	sd	a4,448(a5)
    newmmr->mmr_family.prev = &(newmmr->mmr_family); // prev points to its own mmr_node
    80006ad4:	1ce7b423          	sd	a4,456(a5)
    if (mapvpages(p->pagetable, newmmr->addr, newmmr->length) < 0) {
    80006ad8:	2601                	sext.w	a2,a2
    80006ada:	85ca                	mv	a1,s2
    80006adc:	0709b503          	ld	a0,112(s3)
    80006ae0:	ffffb097          	auipc	ra,0xffffb
    80006ae4:	e36080e7          	jalr	-458(ra) # 80001916 <mapvpages>
    80006ae8:	02054063          	bltz	a0,80006b08 <sys_mmap+0xf0>
    if (flags & MAP_SHARED) // start an mmr_list if region is shared
    80006aec:	fc042783          	lw	a5,-64(s0)
    80006af0:	8b85                	andi	a5,a5,1
    80006af2:	e785                	bnez	a5,80006b1a <sys_mmap+0x102>
    p->cur_max = start_addr;
    80006af4:	4529bc23          	sd	s2,1112(s3)
  }
}
    80006af8:	854a                	mv	a0,s2
    80006afa:	70e2                	ld	ra,56(sp)
    80006afc:	7442                	ld	s0,48(sp)
    80006afe:	74a2                	ld	s1,40(sp)
    80006b00:	7902                	ld	s2,32(sp)
    80006b02:	69e2                	ld	s3,24(sp)
    80006b04:	6121                	addi	sp,sp,64
    80006b06:	8082                	ret
      newmmr->valid = 0;
    80006b08:	00349793          	slli	a5,s1,0x3
    80006b0c:	97a6                	add	a5,a5,s1
    80006b0e:	078e                	slli	a5,a5,0x3
    80006b10:	97ce                	add	a5,a5,s3
    80006b12:	1807ae23          	sw	zero,412(a5)
      return -1;
    80006b16:	597d                	li	s2,-1
    80006b18:	b7c5                	j	80006af8 <sys_mmap+0xe0>
      newmmr->mmr_family.listid = alloc_mmr_listid();
    80006b1a:	ffffc097          	auipc	ra,0xffffc
    80006b1e:	586080e7          	jalr	1414(ra) # 800030a0 <alloc_mmr_listid>
    80006b22:	00349793          	slli	a5,s1,0x3
    80006b26:	97a6                	add	a5,a5,s1
    80006b28:	078e                	slli	a5,a5,0x3
    80006b2a:	97ce                	add	a5,a5,s3
    80006b2c:	1aa7a823          	sw	a0,432(a5)
    80006b30:	b7d1                	j	80006af4 <sys_mmap+0xdc>
  return -1;
    80006b32:	597d                	li	s2,-1
    80006b34:	b7d1                	j	80006af8 <sys_mmap+0xe0>

0000000080006b36 <munmap>:
// Unmap memory region if it exists

// Free physical memory if no other process has the region mapped
int
munmap(uint64 addr, uint64 length)
{
    80006b36:	715d                	addi	sp,sp,-80
    80006b38:	e486                	sd	ra,72(sp)
    80006b3a:	e0a2                	sd	s0,64(sp)
    80006b3c:	fc26                	sd	s1,56(sp)
    80006b3e:	f84a                	sd	s2,48(sp)
    80006b40:	f44e                	sd	s3,40(sp)
    80006b42:	f052                	sd	s4,32(sp)
    80006b44:	ec56                	sd	s5,24(sp)
    80006b46:	e85a                	sd	s6,16(sp)
    80006b48:	e45e                	sd	s7,8(sp)
    80006b4a:	e062                	sd	s8,0(sp)
    80006b4c:	0880                	addi	s0,sp,80
    80006b4e:	84aa                	mv	s1,a0
    80006b50:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80006b52:	ffffb097          	auipc	ra,0xffffb
    80006b56:	26a080e7          	jalr	618(ra) # 80001dbc <myproc>
    80006b5a:	8a2a                	mv	s4,a0
  struct mmr *mmr = 0;
  int dofree = 0;
  int i;
  // Search proc->mmr for addr
  for (i = 0; i < MAX_MMR; i++){
    80006b5c:	18850793          	addi	a5,a0,392
    80006b60:	4901                	li	s2,0
    if ((p->mmr[i].valid == 1) && (addr == p->mmr[i].addr) &&
    80006b62:	4685                	li	a3,1
    (PGROUNDUP(length) == p->mmr[i].length)) {
    80006b64:	6705                	lui	a4,0x1
    80006b66:	177d                	addi	a4,a4,-1 # fff <_entry-0x7ffff001>
    80006b68:	00e985b3          	add	a1,s3,a4
    80006b6c:	777d                	lui	a4,0xfffff
    80006b6e:	8df9                	and	a1,a1,a4
  for (i = 0; i < MAX_MMR; i++){
    80006b70:	4629                	li	a2,10
    80006b72:	a031                	j	80006b7e <munmap+0x48>
    80006b74:	2905                	addiw	s2,s2,1
    80006b76:	04878793          	addi	a5,a5,72
    80006b7a:	04c90c63          	beq	s2,a2,80006bd2 <munmap+0x9c>
    if ((p->mmr[i].valid == 1) && (addr == p->mmr[i].addr) &&
    80006b7e:	0147a983          	lw	s3,20(a5)
    80006b82:	fed999e3          	bne	s3,a3,80006b74 <munmap+0x3e>
    80006b86:	6388                	ld	a0,0(a5)
    80006b88:	fe9516e3          	bne	a0,s1,80006b74 <munmap+0x3e>
    (PGROUNDUP(length) == p->mmr[i].length)) {
    80006b8c:	4798                	lw	a4,8(a5)
    if ((p->mmr[i].valid == 1) && (addr == p->mmr[i].addr) &&
    80006b8e:	fee593e3          	bne	a1,a4,80006b74 <munmap+0x3e>

  if (!mmr) {
    return -1;
  }

  mmr->valid = 0;
    80006b92:	00391793          	slli	a5,s2,0x3
    80006b96:	97ca                	add	a5,a5,s2
    80006b98:	078e                	slli	a5,a5,0x3
    80006b9a:	97d2                	add	a5,a5,s4
    80006b9c:	1807ae23          	sw	zero,412(a5)

  if (mmr->flags & MAP_PRIVATE)
    80006ba0:	1987aa83          	lw	s5,408(a5)
    80006ba4:	002afa93          	andi	s5,s5,2
    80006ba8:	020a8763          	beqz	s5,80006bd6 <munmap+0xa0>
      release(&pmmrlist->lock);
    }
  }
  // Remove mappings from page table
  // Also free physical memory if no other process has this region mapped
  for (uint64 pageaddr = addr; pageaddr < p->mmr[i].addr+p->mmr[i].length; pageaddr += PGSIZE) {
    80006bac:	00391793          	slli	a5,s2,0x3
    80006bb0:	97ca                	add	a5,a5,s2
    80006bb2:	078e                	slli	a5,a5,0x3
    80006bb4:	97d2                	add	a5,a5,s4
    80006bb6:	1907a703          	lw	a4,400(a5)
    80006bba:	1887b783          	ld	a5,392(a5)
    80006bbe:	97ba                	add	a5,a5,a4
    80006bc0:	0cf4fb63          	bgeu	s1,a5,80006c96 <munmap+0x160>
    80006bc4:	6a85                	lui	s5,0x1
    80006bc6:	00391793          	slli	a5,s2,0x3
    80006bca:	993e                	add	s2,s2,a5
    80006bcc:	090e                	slli	s2,s2,0x3
    80006bce:	9952                	add	s2,s2,s4
    80006bd0:	a061                	j	80006c58 <munmap+0x122>
    return -1;
    80006bd2:	557d                	li	a0,-1
    80006bd4:	a06d                	j	80006c7e <munmap+0x148>
    struct mmr_list *pmmrlist = get_mmr_list(mmr->mmr_family.listid);
    80006bd6:	00391b13          	slli	s6,s2,0x3
    80006bda:	012b0c33          	add	s8,s6,s2
    80006bde:	0c0e                	slli	s8,s8,0x3
    80006be0:	9c52                	add	s8,s8,s4
    80006be2:	1b0c2503          	lw	a0,432(s8)
    80006be6:	ffffc097          	auipc	ra,0xffffc
    80006bea:	bf6080e7          	jalr	-1034(ra) # 800027dc <get_mmr_list>
    80006bee:	8baa                	mv	s7,a0
    acquire(&pmmrlist->lock);
    80006bf0:	ffffa097          	auipc	ra,0xffffa
    80006bf4:	028080e7          	jalr	40(ra) # 80000c18 <acquire>
    if (mmr->mmr_family.next == &(mmr->mmr_family)) { // no other family members
    80006bf8:	1c0c3703          	ld	a4,448(s8)
    80006bfc:	012b07b3          	add	a5,s6,s2
    80006c00:	078e                	slli	a5,a5,0x3
    80006c02:	1b078793          	addi	a5,a5,432
    80006c06:	97d2                	add	a5,a5,s4
    80006c08:	02f70463          	beq	a4,a5,80006c30 <munmap+0xfa>
      (mmr->mmr_family.next)->prev = mmr->mmr_family.prev;
    80006c0c:	00391793          	slli	a5,s2,0x3
    80006c10:	97ca                	add	a5,a5,s2
    80006c12:	078e                	slli	a5,a5,0x3
    80006c14:	97d2                	add	a5,a5,s4
    80006c16:	1c87b683          	ld	a3,456(a5)
    80006c1a:	ef14                	sd	a3,24(a4)
      (mmr->mmr_family.prev)->next = mmr->mmr_family.next;
    80006c1c:	1c07b783          	ld	a5,448(a5)
    80006c20:	ea9c                	sd	a5,16(a3)
      release(&pmmrlist->lock);
    80006c22:	855e                	mv	a0,s7
    80006c24:	ffffa097          	auipc	ra,0xffffa
    80006c28:	0a8080e7          	jalr	168(ra) # 80000ccc <release>
  int dofree = 0;
    80006c2c:	89d6                	mv	s3,s5
    80006c2e:	bfbd                	j	80006bac <munmap+0x76>
      release(&pmmrlist->lock);
    80006c30:	855e                	mv	a0,s7
    80006c32:	ffffa097          	auipc	ra,0xffffa
    80006c36:	09a080e7          	jalr	154(ra) # 80000ccc <release>
      dealloc_mmr_listid(mmr->mmr_family.listid);
    80006c3a:	1b0c2503          	lw	a0,432(s8)
    80006c3e:	ffffc097          	auipc	ra,0xffffc
    80006c42:	c14080e7          	jalr	-1004(ra) # 80002852 <dealloc_mmr_listid>
    80006c46:	b79d                	j	80006bac <munmap+0x76>
  for (uint64 pageaddr = addr; pageaddr < p->mmr[i].addr+p->mmr[i].length; pageaddr += PGSIZE) {
    80006c48:	94d6                	add	s1,s1,s5
    80006c4a:	19092783          	lw	a5,400(s2)
    80006c4e:	18893703          	ld	a4,392(s2)
    80006c52:	97ba                	add	a5,a5,a4
    80006c54:	02f4f463          	bgeu	s1,a5,80006c7c <munmap+0x146>
    if (walkaddr(p->pagetable, pageaddr)) {
    80006c58:	85a6                	mv	a1,s1
    80006c5a:	070a3503          	ld	a0,112(s4)
    80006c5e:	ffffa097          	auipc	ra,0xffffa
    80006c62:	444080e7          	jalr	1092(ra) # 800010a2 <walkaddr>
    80006c66:	d16d                	beqz	a0,80006c48 <munmap+0x112>
      uvmunmap(p->pagetable, pageaddr, 1, dofree);
    80006c68:	86ce                	mv	a3,s3
    80006c6a:	4605                	li	a2,1
    80006c6c:	85a6                	mv	a1,s1
    80006c6e:	070a3503          	ld	a0,112(s4)
    80006c72:	ffffa097          	auipc	ra,0xffffa
    80006c76:	638080e7          	jalr	1592(ra) # 800012aa <uvmunmap>
    80006c7a:	b7f9                	j	80006c48 <munmap+0x112>
    }
  }
  return 0;
    80006c7c:	4501                	li	a0,0
}
    80006c7e:	60a6                	ld	ra,72(sp)
    80006c80:	6406                	ld	s0,64(sp)
    80006c82:	74e2                	ld	s1,56(sp)
    80006c84:	7942                	ld	s2,48(sp)
    80006c86:	79a2                	ld	s3,40(sp)
    80006c88:	7a02                	ld	s4,32(sp)
    80006c8a:	6ae2                	ld	s5,24(sp)
    80006c8c:	6b42                	ld	s6,16(sp)
    80006c8e:	6ba2                	ld	s7,8(sp)
    80006c90:	6c02                	ld	s8,0(sp)
    80006c92:	6161                	addi	sp,sp,80
    80006c94:	8082                	ret
  return 0;
    80006c96:	4501                	li	a0,0
    80006c98:	b7dd                	j	80006c7e <munmap+0x148>

0000000080006c9a <sys_munmap>:

// Get argument and call munmap() helper function
uint64
sys_munmap(void)
{
    80006c9a:	1101                	addi	sp,sp,-32
    80006c9c:	ec06                	sd	ra,24(sp)
    80006c9e:	e822                	sd	s0,16(sp)
    80006ca0:	1000                	addi	s0,sp,32
  uint64 addr;
  uint64 length;
  if (argaddr(0, &addr) < 0)
    80006ca2:	fe840593          	addi	a1,s0,-24
    80006ca6:	4501                	li	a0,0
    80006ca8:	ffffd097          	auipc	ra,0xffffd
    80006cac:	c84080e7          	jalr	-892(ra) # 8000392c <argaddr>
    return -1;
    80006cb0:	57fd                	li	a5,-1
  if (argaddr(0, &addr) < 0)
    80006cb2:	02054563          	bltz	a0,80006cdc <sys_munmap+0x42>
  if (argaddr(1, &length) < 0)
    80006cb6:	fe040593          	addi	a1,s0,-32
    80006cba:	4505                	li	a0,1
    80006cbc:	ffffd097          	auipc	ra,0xffffd
    80006cc0:	c70080e7          	jalr	-912(ra) # 8000392c <argaddr>
    return -1;
    80006cc4:	57fd                	li	a5,-1
  if (argaddr(1, &length) < 0)
    80006cc6:	00054b63          	bltz	a0,80006cdc <sys_munmap+0x42>
  return (munmap(addr, length));
    80006cca:	fe043583          	ld	a1,-32(s0)
    80006cce:	fe843503          	ld	a0,-24(s0)
    80006cd2:	00000097          	auipc	ra,0x0
    80006cd6:	e64080e7          	jalr	-412(ra) # 80006b36 <munmap>
    80006cda:	87aa                	mv	a5,a0
} 
    80006cdc:	853e                	mv	a0,a5
    80006cde:	60e2                	ld	ra,24(sp)
    80006ce0:	6442                	ld	s0,16(sp)
    80006ce2:	6105                	addi	sp,sp,32
    80006ce4:	8082                	ret
	...

0000000080006cf0 <kernelvec>:
    80006cf0:	7111                	addi	sp,sp,-256
    80006cf2:	e006                	sd	ra,0(sp)
    80006cf4:	e40a                	sd	sp,8(sp)
    80006cf6:	e80e                	sd	gp,16(sp)
    80006cf8:	ec12                	sd	tp,24(sp)
    80006cfa:	f016                	sd	t0,32(sp)
    80006cfc:	f41a                	sd	t1,40(sp)
    80006cfe:	f81e                	sd	t2,48(sp)
    80006d00:	fc22                	sd	s0,56(sp)
    80006d02:	e0a6                	sd	s1,64(sp)
    80006d04:	e4aa                	sd	a0,72(sp)
    80006d06:	e8ae                	sd	a1,80(sp)
    80006d08:	ecb2                	sd	a2,88(sp)
    80006d0a:	f0b6                	sd	a3,96(sp)
    80006d0c:	f4ba                	sd	a4,104(sp)
    80006d0e:	f8be                	sd	a5,112(sp)
    80006d10:	fcc2                	sd	a6,120(sp)
    80006d12:	e146                	sd	a7,128(sp)
    80006d14:	e54a                	sd	s2,136(sp)
    80006d16:	e94e                	sd	s3,144(sp)
    80006d18:	ed52                	sd	s4,152(sp)
    80006d1a:	f156                	sd	s5,160(sp)
    80006d1c:	f55a                	sd	s6,168(sp)
    80006d1e:	f95e                	sd	s7,176(sp)
    80006d20:	fd62                	sd	s8,184(sp)
    80006d22:	e1e6                	sd	s9,192(sp)
    80006d24:	e5ea                	sd	s10,200(sp)
    80006d26:	e9ee                	sd	s11,208(sp)
    80006d28:	edf2                	sd	t3,216(sp)
    80006d2a:	f1f6                	sd	t4,224(sp)
    80006d2c:	f5fa                	sd	t5,232(sp)
    80006d2e:	f9fe                	sd	t6,240(sp)
    80006d30:	86bfc0ef          	jal	ra,8000359a <kerneltrap>
    80006d34:	6082                	ld	ra,0(sp)
    80006d36:	6122                	ld	sp,8(sp)
    80006d38:	61c2                	ld	gp,16(sp)
    80006d3a:	7282                	ld	t0,32(sp)
    80006d3c:	7322                	ld	t1,40(sp)
    80006d3e:	73c2                	ld	t2,48(sp)
    80006d40:	7462                	ld	s0,56(sp)
    80006d42:	6486                	ld	s1,64(sp)
    80006d44:	6526                	ld	a0,72(sp)
    80006d46:	65c6                	ld	a1,80(sp)
    80006d48:	6666                	ld	a2,88(sp)
    80006d4a:	7686                	ld	a3,96(sp)
    80006d4c:	7726                	ld	a4,104(sp)
    80006d4e:	77c6                	ld	a5,112(sp)
    80006d50:	7866                	ld	a6,120(sp)
    80006d52:	688a                	ld	a7,128(sp)
    80006d54:	692a                	ld	s2,136(sp)
    80006d56:	69ca                	ld	s3,144(sp)
    80006d58:	6a6a                	ld	s4,152(sp)
    80006d5a:	7a8a                	ld	s5,160(sp)
    80006d5c:	7b2a                	ld	s6,168(sp)
    80006d5e:	7bca                	ld	s7,176(sp)
    80006d60:	7c6a                	ld	s8,184(sp)
    80006d62:	6c8e                	ld	s9,192(sp)
    80006d64:	6d2e                	ld	s10,200(sp)
    80006d66:	6dce                	ld	s11,208(sp)
    80006d68:	6e6e                	ld	t3,216(sp)
    80006d6a:	7e8e                	ld	t4,224(sp)
    80006d6c:	7f2e                	ld	t5,232(sp)
    80006d6e:	7fce                	ld	t6,240(sp)
    80006d70:	6111                	addi	sp,sp,256
    80006d72:	10200073          	sret
    80006d76:	00000013          	nop
    80006d7a:	00000013          	nop
    80006d7e:	0001                	nop

0000000080006d80 <timervec>:
    80006d80:	34051573          	csrrw	a0,mscratch,a0
    80006d84:	e10c                	sd	a1,0(a0)
    80006d86:	e510                	sd	a2,8(a0)
    80006d88:	e914                	sd	a3,16(a0)
    80006d8a:	6d0c                	ld	a1,24(a0)
    80006d8c:	7110                	ld	a2,32(a0)
    80006d8e:	6194                	ld	a3,0(a1)
    80006d90:	96b2                	add	a3,a3,a2
    80006d92:	e194                	sd	a3,0(a1)
    80006d94:	4589                	li	a1,2
    80006d96:	14459073          	csrw	sip,a1
    80006d9a:	6914                	ld	a3,16(a0)
    80006d9c:	6510                	ld	a2,8(a0)
    80006d9e:	610c                	ld	a1,0(a0)
    80006da0:	34051573          	csrrw	a0,mscratch,a0
    80006da4:	30200073          	mret
	...

0000000080006daa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80006daa:	1141                	addi	sp,sp,-16
    80006dac:	e422                	sd	s0,8(sp)
    80006dae:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006db0:	0c0007b7          	lui	a5,0xc000
    80006db4:	4705                	li	a4,1
    80006db6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006db8:	c3d8                	sw	a4,4(a5)
}
    80006dba:	6422                	ld	s0,8(sp)
    80006dbc:	0141                	addi	sp,sp,16
    80006dbe:	8082                	ret

0000000080006dc0 <plicinithart>:

void
plicinithart(void)
{
    80006dc0:	1141                	addi	sp,sp,-16
    80006dc2:	e406                	sd	ra,8(sp)
    80006dc4:	e022                	sd	s0,0(sp)
    80006dc6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006dc8:	ffffb097          	auipc	ra,0xffffb
    80006dcc:	fc8080e7          	jalr	-56(ra) # 80001d90 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006dd0:	0085171b          	slliw	a4,a0,0x8
    80006dd4:	0c0027b7          	lui	a5,0xc002
    80006dd8:	97ba                	add	a5,a5,a4
    80006dda:	40200713          	li	a4,1026
    80006dde:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006de2:	00d5151b          	slliw	a0,a0,0xd
    80006de6:	0c2017b7          	lui	a5,0xc201
    80006dea:	97aa                	add	a5,a5,a0
    80006dec:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006df0:	60a2                	ld	ra,8(sp)
    80006df2:	6402                	ld	s0,0(sp)
    80006df4:	0141                	addi	sp,sp,16
    80006df6:	8082                	ret

0000000080006df8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006df8:	1141                	addi	sp,sp,-16
    80006dfa:	e406                	sd	ra,8(sp)
    80006dfc:	e022                	sd	s0,0(sp)
    80006dfe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006e00:	ffffb097          	auipc	ra,0xffffb
    80006e04:	f90080e7          	jalr	-112(ra) # 80001d90 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006e08:	00d5151b          	slliw	a0,a0,0xd
    80006e0c:	0c2017b7          	lui	a5,0xc201
    80006e10:	97aa                	add	a5,a5,a0
  return irq;
}
    80006e12:	43c8                	lw	a0,4(a5)
    80006e14:	60a2                	ld	ra,8(sp)
    80006e16:	6402                	ld	s0,0(sp)
    80006e18:	0141                	addi	sp,sp,16
    80006e1a:	8082                	ret

0000000080006e1c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006e1c:	1101                	addi	sp,sp,-32
    80006e1e:	ec06                	sd	ra,24(sp)
    80006e20:	e822                	sd	s0,16(sp)
    80006e22:	e426                	sd	s1,8(sp)
    80006e24:	1000                	addi	s0,sp,32
    80006e26:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006e28:	ffffb097          	auipc	ra,0xffffb
    80006e2c:	f68080e7          	jalr	-152(ra) # 80001d90 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006e30:	00d5151b          	slliw	a0,a0,0xd
    80006e34:	0c2017b7          	lui	a5,0xc201
    80006e38:	97aa                	add	a5,a5,a0
    80006e3a:	c3c4                	sw	s1,4(a5)
}
    80006e3c:	60e2                	ld	ra,24(sp)
    80006e3e:	6442                	ld	s0,16(sp)
    80006e40:	64a2                	ld	s1,8(sp)
    80006e42:	6105                	addi	sp,sp,32
    80006e44:	8082                	ret

0000000080006e46 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006e46:	1141                	addi	sp,sp,-16
    80006e48:	e406                	sd	ra,8(sp)
    80006e4a:	e022                	sd	s0,0(sp)
    80006e4c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006e4e:	479d                	li	a5,7
    80006e50:	06a7c863          	blt	a5,a0,80006ec0 <free_desc+0x7a>
    panic("free_desc 1");
  if(disk.free[i])
    80006e54:	0002e717          	auipc	a4,0x2e
    80006e58:	1ac70713          	addi	a4,a4,428 # 80035000 <disk>
    80006e5c:	972a                	add	a4,a4,a0
    80006e5e:	6789                	lui	a5,0x2
    80006e60:	97ba                	add	a5,a5,a4
    80006e62:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006e66:	e7ad                	bnez	a5,80006ed0 <free_desc+0x8a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006e68:	00451793          	slli	a5,a0,0x4
    80006e6c:	00030717          	auipc	a4,0x30
    80006e70:	19470713          	addi	a4,a4,404 # 80037000 <disk+0x2000>
    80006e74:	6314                	ld	a3,0(a4)
    80006e76:	96be                	add	a3,a3,a5
    80006e78:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006e7c:	6314                	ld	a3,0(a4)
    80006e7e:	96be                	add	a3,a3,a5
    80006e80:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006e84:	6314                	ld	a3,0(a4)
    80006e86:	96be                	add	a3,a3,a5
    80006e88:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80006e8c:	6318                	ld	a4,0(a4)
    80006e8e:	97ba                	add	a5,a5,a4
    80006e90:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006e94:	0002e717          	auipc	a4,0x2e
    80006e98:	16c70713          	addi	a4,a4,364 # 80035000 <disk>
    80006e9c:	972a                	add	a4,a4,a0
    80006e9e:	6789                	lui	a5,0x2
    80006ea0:	97ba                	add	a5,a5,a4
    80006ea2:	4705                	li	a4,1
    80006ea4:	00e78c23          	sb	a4,24(a5) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80006ea8:	00030517          	auipc	a0,0x30
    80006eac:	17050513          	addi	a0,a0,368 # 80037018 <disk+0x2018>
    80006eb0:	ffffb097          	auipc	ra,0xffffb
    80006eb4:	3d8080e7          	jalr	984(ra) # 80002288 <wakeup>
}
    80006eb8:	60a2                	ld	ra,8(sp)
    80006eba:	6402                	ld	s0,0(sp)
    80006ebc:	0141                	addi	sp,sp,16
    80006ebe:	8082                	ret
    panic("free_desc 1");
    80006ec0:	00003517          	auipc	a0,0x3
    80006ec4:	97050513          	addi	a0,a0,-1680 # 80009830 <syscalls+0x368>
    80006ec8:	ffff9097          	auipc	ra,0xffff9
    80006ecc:	672080e7          	jalr	1650(ra) # 8000053a <panic>
    panic("free_desc 2");
    80006ed0:	00003517          	auipc	a0,0x3
    80006ed4:	97050513          	addi	a0,a0,-1680 # 80009840 <syscalls+0x378>
    80006ed8:	ffff9097          	auipc	ra,0xffff9
    80006edc:	662080e7          	jalr	1634(ra) # 8000053a <panic>

0000000080006ee0 <virtio_disk_init>:
{
    80006ee0:	1101                	addi	sp,sp,-32
    80006ee2:	ec06                	sd	ra,24(sp)
    80006ee4:	e822                	sd	s0,16(sp)
    80006ee6:	e426                	sd	s1,8(sp)
    80006ee8:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006eea:	00003597          	auipc	a1,0x3
    80006eee:	96658593          	addi	a1,a1,-1690 # 80009850 <syscalls+0x388>
    80006ef2:	00030517          	auipc	a0,0x30
    80006ef6:	23650513          	addi	a0,a0,566 # 80037128 <disk+0x2128>
    80006efa:	ffffa097          	auipc	ra,0xffffa
    80006efe:	c8e080e7          	jalr	-882(ra) # 80000b88 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006f02:	100017b7          	lui	a5,0x10001
    80006f06:	4398                	lw	a4,0(a5)
    80006f08:	2701                	sext.w	a4,a4
    80006f0a:	747277b7          	lui	a5,0x74727
    80006f0e:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006f12:	0ef71063          	bne	a4,a5,80006ff2 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006f16:	100017b7          	lui	a5,0x10001
    80006f1a:	43dc                	lw	a5,4(a5)
    80006f1c:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006f1e:	4705                	li	a4,1
    80006f20:	0ce79963          	bne	a5,a4,80006ff2 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006f24:	100017b7          	lui	a5,0x10001
    80006f28:	479c                	lw	a5,8(a5)
    80006f2a:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006f2c:	4709                	li	a4,2
    80006f2e:	0ce79263          	bne	a5,a4,80006ff2 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006f32:	100017b7          	lui	a5,0x10001
    80006f36:	47d8                	lw	a4,12(a5)
    80006f38:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006f3a:	554d47b7          	lui	a5,0x554d4
    80006f3e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006f42:	0af71863          	bne	a4,a5,80006ff2 <virtio_disk_init+0x112>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006f46:	100017b7          	lui	a5,0x10001
    80006f4a:	4705                	li	a4,1
    80006f4c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006f4e:	470d                	li	a4,3
    80006f50:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006f52:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006f54:	c7ffe6b7          	lui	a3,0xc7ffe
    80006f58:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fc675f>
    80006f5c:	8f75                	and	a4,a4,a3
    80006f5e:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006f60:	472d                	li	a4,11
    80006f62:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006f64:	473d                	li	a4,15
    80006f66:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006f68:	6705                	lui	a4,0x1
    80006f6a:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006f6c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006f70:	5bdc                	lw	a5,52(a5)
    80006f72:	2781                	sext.w	a5,a5
  if(max == 0)
    80006f74:	c7d9                	beqz	a5,80007002 <virtio_disk_init+0x122>
  if(max < NUM)
    80006f76:	471d                	li	a4,7
    80006f78:	08f77d63          	bgeu	a4,a5,80007012 <virtio_disk_init+0x132>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006f7c:	100014b7          	lui	s1,0x10001
    80006f80:	47a1                	li	a5,8
    80006f82:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006f84:	6609                	lui	a2,0x2
    80006f86:	4581                	li	a1,0
    80006f88:	0002e517          	auipc	a0,0x2e
    80006f8c:	07850513          	addi	a0,a0,120 # 80035000 <disk>
    80006f90:	ffffa097          	auipc	ra,0xffffa
    80006f94:	d84080e7          	jalr	-636(ra) # 80000d14 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006f98:	0002e717          	auipc	a4,0x2e
    80006f9c:	06870713          	addi	a4,a4,104 # 80035000 <disk>
    80006fa0:	00c75793          	srli	a5,a4,0xc
    80006fa4:	2781                	sext.w	a5,a5
    80006fa6:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80006fa8:	00030797          	auipc	a5,0x30
    80006fac:	05878793          	addi	a5,a5,88 # 80037000 <disk+0x2000>
    80006fb0:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006fb2:	0002e717          	auipc	a4,0x2e
    80006fb6:	0ce70713          	addi	a4,a4,206 # 80035080 <disk+0x80>
    80006fba:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006fbc:	0002f717          	auipc	a4,0x2f
    80006fc0:	04470713          	addi	a4,a4,68 # 80036000 <disk+0x1000>
    80006fc4:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006fc6:	4705                	li	a4,1
    80006fc8:	00e78c23          	sb	a4,24(a5)
    80006fcc:	00e78ca3          	sb	a4,25(a5)
    80006fd0:	00e78d23          	sb	a4,26(a5)
    80006fd4:	00e78da3          	sb	a4,27(a5)
    80006fd8:	00e78e23          	sb	a4,28(a5)
    80006fdc:	00e78ea3          	sb	a4,29(a5)
    80006fe0:	00e78f23          	sb	a4,30(a5)
    80006fe4:	00e78fa3          	sb	a4,31(a5)
}
    80006fe8:	60e2                	ld	ra,24(sp)
    80006fea:	6442                	ld	s0,16(sp)
    80006fec:	64a2                	ld	s1,8(sp)
    80006fee:	6105                	addi	sp,sp,32
    80006ff0:	8082                	ret
    panic("could not find virtio disk");
    80006ff2:	00003517          	auipc	a0,0x3
    80006ff6:	86e50513          	addi	a0,a0,-1938 # 80009860 <syscalls+0x398>
    80006ffa:	ffff9097          	auipc	ra,0xffff9
    80006ffe:	540080e7          	jalr	1344(ra) # 8000053a <panic>
    panic("virtio disk has no queue 0");
    80007002:	00003517          	auipc	a0,0x3
    80007006:	87e50513          	addi	a0,a0,-1922 # 80009880 <syscalls+0x3b8>
    8000700a:	ffff9097          	auipc	ra,0xffff9
    8000700e:	530080e7          	jalr	1328(ra) # 8000053a <panic>
    panic("virtio disk max queue too short");
    80007012:	00003517          	auipc	a0,0x3
    80007016:	88e50513          	addi	a0,a0,-1906 # 800098a0 <syscalls+0x3d8>
    8000701a:	ffff9097          	auipc	ra,0xffff9
    8000701e:	520080e7          	jalr	1312(ra) # 8000053a <panic>

0000000080007022 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80007022:	7119                	addi	sp,sp,-128
    80007024:	fc86                	sd	ra,120(sp)
    80007026:	f8a2                	sd	s0,112(sp)
    80007028:	f4a6                	sd	s1,104(sp)
    8000702a:	f0ca                	sd	s2,96(sp)
    8000702c:	ecce                	sd	s3,88(sp)
    8000702e:	e8d2                	sd	s4,80(sp)
    80007030:	e4d6                	sd	s5,72(sp)
    80007032:	e0da                	sd	s6,64(sp)
    80007034:	fc5e                	sd	s7,56(sp)
    80007036:	f862                	sd	s8,48(sp)
    80007038:	f466                	sd	s9,40(sp)
    8000703a:	f06a                	sd	s10,32(sp)
    8000703c:	ec6e                	sd	s11,24(sp)
    8000703e:	0100                	addi	s0,sp,128
    80007040:	8aaa                	mv	s5,a0
    80007042:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80007044:	00c52c83          	lw	s9,12(a0)
    80007048:	001c9c9b          	slliw	s9,s9,0x1
    8000704c:	1c82                	slli	s9,s9,0x20
    8000704e:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80007052:	00030517          	auipc	a0,0x30
    80007056:	0d650513          	addi	a0,a0,214 # 80037128 <disk+0x2128>
    8000705a:	ffffa097          	auipc	ra,0xffffa
    8000705e:	bbe080e7          	jalr	-1090(ra) # 80000c18 <acquire>
  for(int i = 0; i < 3; i++){
    80007062:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80007064:	44a1                	li	s1,8
      disk.free[i] = 0;
    80007066:	0002ec17          	auipc	s8,0x2e
    8000706a:	f9ac0c13          	addi	s8,s8,-102 # 80035000 <disk>
    8000706e:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80007070:	4b0d                	li	s6,3
    80007072:	a0ad                	j	800070dc <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80007074:	00fc0733          	add	a4,s8,a5
    80007078:	975e                	add	a4,a4,s7
    8000707a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    8000707e:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80007080:	0207c563          	bltz	a5,800070aa <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80007084:	2905                	addiw	s2,s2,1
    80007086:	0611                	addi	a2,a2,4 # 2004 <_entry-0x7fffdffc>
    80007088:	19690c63          	beq	s2,s6,80007220 <virtio_disk_rw+0x1fe>
    idx[i] = alloc_desc();
    8000708c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    8000708e:	00030717          	auipc	a4,0x30
    80007092:	f8a70713          	addi	a4,a4,-118 # 80037018 <disk+0x2018>
    80007096:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80007098:	00074683          	lbu	a3,0(a4)
    8000709c:	fee1                	bnez	a3,80007074 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    8000709e:	2785                	addiw	a5,a5,1
    800070a0:	0705                	addi	a4,a4,1
    800070a2:	fe979be3          	bne	a5,s1,80007098 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    800070a6:	57fd                	li	a5,-1
    800070a8:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800070aa:	01205d63          	blez	s2,800070c4 <virtio_disk_rw+0xa2>
    800070ae:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800070b0:	000a2503          	lw	a0,0(s4)
    800070b4:	00000097          	auipc	ra,0x0
    800070b8:	d92080e7          	jalr	-622(ra) # 80006e46 <free_desc>
      for(int j = 0; j < i; j++)
    800070bc:	2d85                	addiw	s11,s11,1
    800070be:	0a11                	addi	s4,s4,4
    800070c0:	ff2d98e3          	bne	s11,s2,800070b0 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800070c4:	00030597          	auipc	a1,0x30
    800070c8:	06458593          	addi	a1,a1,100 # 80037128 <disk+0x2128>
    800070cc:	00030517          	auipc	a0,0x30
    800070d0:	f4c50513          	addi	a0,a0,-180 # 80037018 <disk+0x2018>
    800070d4:	ffffb097          	auipc	ra,0xffffb
    800070d8:	150080e7          	jalr	336(ra) # 80002224 <sleep>
  for(int i = 0; i < 3; i++){
    800070dc:	f8040a13          	addi	s4,s0,-128
{
    800070e0:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800070e2:	894e                	mv	s2,s3
    800070e4:	b765                	j	8000708c <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800070e6:	00030697          	auipc	a3,0x30
    800070ea:	f1a6b683          	ld	a3,-230(a3) # 80037000 <disk+0x2000>
    800070ee:	96ba                	add	a3,a3,a4
    800070f0:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800070f4:	0002e817          	auipc	a6,0x2e
    800070f8:	f0c80813          	addi	a6,a6,-244 # 80035000 <disk>
    800070fc:	00030697          	auipc	a3,0x30
    80007100:	f0468693          	addi	a3,a3,-252 # 80037000 <disk+0x2000>
    80007104:	6290                	ld	a2,0(a3)
    80007106:	963a                	add	a2,a2,a4
    80007108:	00c65583          	lhu	a1,12(a2)
    8000710c:	0015e593          	ori	a1,a1,1
    80007110:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80007114:	f8842603          	lw	a2,-120(s0)
    80007118:	628c                	ld	a1,0(a3)
    8000711a:	972e                	add	a4,a4,a1
    8000711c:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80007120:	20050593          	addi	a1,a0,512
    80007124:	0592                	slli	a1,a1,0x4
    80007126:	95c2                	add	a1,a1,a6
    80007128:	577d                	li	a4,-1
    8000712a:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000712e:	00461713          	slli	a4,a2,0x4
    80007132:	6290                	ld	a2,0(a3)
    80007134:	963a                	add	a2,a2,a4
    80007136:	03078793          	addi	a5,a5,48
    8000713a:	97c2                	add	a5,a5,a6
    8000713c:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    8000713e:	629c                	ld	a5,0(a3)
    80007140:	97ba                	add	a5,a5,a4
    80007142:	4605                	li	a2,1
    80007144:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80007146:	629c                	ld	a5,0(a3)
    80007148:	97ba                	add	a5,a5,a4
    8000714a:	4809                	li	a6,2
    8000714c:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80007150:	629c                	ld	a5,0(a3)
    80007152:	97ba                	add	a5,a5,a4
    80007154:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80007158:	00caa223          	sw	a2,4(s5) # 1004 <_entry-0x7fffeffc>
  disk.info[idx[0]].b = b;
    8000715c:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80007160:	6698                	ld	a4,8(a3)
    80007162:	00275783          	lhu	a5,2(a4)
    80007166:	8b9d                	andi	a5,a5,7
    80007168:	0786                	slli	a5,a5,0x1
    8000716a:	973e                	add	a4,a4,a5
    8000716c:	00a71223          	sh	a0,4(a4)

  __sync_synchronize();
    80007170:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80007174:	6698                	ld	a4,8(a3)
    80007176:	00275783          	lhu	a5,2(a4)
    8000717a:	2785                	addiw	a5,a5,1
    8000717c:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80007180:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80007184:	100017b7          	lui	a5,0x10001
    80007188:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000718c:	004aa783          	lw	a5,4(s5)
    80007190:	02c79163          	bne	a5,a2,800071b2 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80007194:	00030917          	auipc	s2,0x30
    80007198:	f9490913          	addi	s2,s2,-108 # 80037128 <disk+0x2128>
  while(b->disk == 1) {
    8000719c:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000719e:	85ca                	mv	a1,s2
    800071a0:	8556                	mv	a0,s5
    800071a2:	ffffb097          	auipc	ra,0xffffb
    800071a6:	082080e7          	jalr	130(ra) # 80002224 <sleep>
  while(b->disk == 1) {
    800071aa:	004aa783          	lw	a5,4(s5)
    800071ae:	fe9788e3          	beq	a5,s1,8000719e <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    800071b2:	f8042903          	lw	s2,-128(s0)
    800071b6:	20090713          	addi	a4,s2,512
    800071ba:	0712                	slli	a4,a4,0x4
    800071bc:	0002e797          	auipc	a5,0x2e
    800071c0:	e4478793          	addi	a5,a5,-444 # 80035000 <disk>
    800071c4:	97ba                	add	a5,a5,a4
    800071c6:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    800071ca:	00030997          	auipc	s3,0x30
    800071ce:	e3698993          	addi	s3,s3,-458 # 80037000 <disk+0x2000>
    800071d2:	00491713          	slli	a4,s2,0x4
    800071d6:	0009b783          	ld	a5,0(s3)
    800071da:	97ba                	add	a5,a5,a4
    800071dc:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800071e0:	854a                	mv	a0,s2
    800071e2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800071e6:	00000097          	auipc	ra,0x0
    800071ea:	c60080e7          	jalr	-928(ra) # 80006e46 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800071ee:	8885                	andi	s1,s1,1
    800071f0:	f0ed                	bnez	s1,800071d2 <virtio_disk_rw+0x1b0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800071f2:	00030517          	auipc	a0,0x30
    800071f6:	f3650513          	addi	a0,a0,-202 # 80037128 <disk+0x2128>
    800071fa:	ffffa097          	auipc	ra,0xffffa
    800071fe:	ad2080e7          	jalr	-1326(ra) # 80000ccc <release>
}
    80007202:	70e6                	ld	ra,120(sp)
    80007204:	7446                	ld	s0,112(sp)
    80007206:	74a6                	ld	s1,104(sp)
    80007208:	7906                	ld	s2,96(sp)
    8000720a:	69e6                	ld	s3,88(sp)
    8000720c:	6a46                	ld	s4,80(sp)
    8000720e:	6aa6                	ld	s5,72(sp)
    80007210:	6b06                	ld	s6,64(sp)
    80007212:	7be2                	ld	s7,56(sp)
    80007214:	7c42                	ld	s8,48(sp)
    80007216:	7ca2                	ld	s9,40(sp)
    80007218:	7d02                	ld	s10,32(sp)
    8000721a:	6de2                	ld	s11,24(sp)
    8000721c:	6109                	addi	sp,sp,128
    8000721e:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80007220:	f8042503          	lw	a0,-128(s0)
    80007224:	20050793          	addi	a5,a0,512
    80007228:	0792                	slli	a5,a5,0x4
  if(write)
    8000722a:	0002e817          	auipc	a6,0x2e
    8000722e:	dd680813          	addi	a6,a6,-554 # 80035000 <disk>
    80007232:	00f80733          	add	a4,a6,a5
    80007236:	01a036b3          	snez	a3,s10
    8000723a:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    8000723e:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80007242:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    80007246:	7679                	lui	a2,0xffffe
    80007248:	963e                	add	a2,a2,a5
    8000724a:	00030697          	auipc	a3,0x30
    8000724e:	db668693          	addi	a3,a3,-586 # 80037000 <disk+0x2000>
    80007252:	6298                	ld	a4,0(a3)
    80007254:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80007256:	0a878593          	addi	a1,a5,168
    8000725a:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000725c:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000725e:	6298                	ld	a4,0(a3)
    80007260:	9732                	add	a4,a4,a2
    80007262:	45c1                	li	a1,16
    80007264:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80007266:	6298                	ld	a4,0(a3)
    80007268:	9732                	add	a4,a4,a2
    8000726a:	4585                	li	a1,1
    8000726c:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80007270:	f8442703          	lw	a4,-124(s0)
    80007274:	628c                	ld	a1,0(a3)
    80007276:	962e                	add	a2,a2,a1
    80007278:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffc600e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    8000727c:	0712                	slli	a4,a4,0x4
    8000727e:	6290                	ld	a2,0(a3)
    80007280:	963a                	add	a2,a2,a4
    80007282:	058a8593          	addi	a1,s5,88
    80007286:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80007288:	6294                	ld	a3,0(a3)
    8000728a:	96ba                	add	a3,a3,a4
    8000728c:	40000613          	li	a2,1024
    80007290:	c690                	sw	a2,8(a3)
  if(write)
    80007292:	e40d1ae3          	bnez	s10,800070e6 <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80007296:	00030697          	auipc	a3,0x30
    8000729a:	d6a6b683          	ld	a3,-662(a3) # 80037000 <disk+0x2000>
    8000729e:	96ba                	add	a3,a3,a4
    800072a0:	4609                	li	a2,2
    800072a2:	00c69623          	sh	a2,12(a3)
    800072a6:	b5b9                	j	800070f4 <virtio_disk_rw+0xd2>

00000000800072a8 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800072a8:	1101                	addi	sp,sp,-32
    800072aa:	ec06                	sd	ra,24(sp)
    800072ac:	e822                	sd	s0,16(sp)
    800072ae:	e426                	sd	s1,8(sp)
    800072b0:	e04a                	sd	s2,0(sp)
    800072b2:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800072b4:	00030517          	auipc	a0,0x30
    800072b8:	e7450513          	addi	a0,a0,-396 # 80037128 <disk+0x2128>
    800072bc:	ffffa097          	auipc	ra,0xffffa
    800072c0:	95c080e7          	jalr	-1700(ra) # 80000c18 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800072c4:	10001737          	lui	a4,0x10001
    800072c8:	533c                	lw	a5,96(a4)
    800072ca:	8b8d                	andi	a5,a5,3
    800072cc:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800072ce:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800072d2:	00030797          	auipc	a5,0x30
    800072d6:	d2e78793          	addi	a5,a5,-722 # 80037000 <disk+0x2000>
    800072da:	6b94                	ld	a3,16(a5)
    800072dc:	0207d703          	lhu	a4,32(a5)
    800072e0:	0026d783          	lhu	a5,2(a3)
    800072e4:	06f70163          	beq	a4,a5,80007346 <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800072e8:	0002e917          	auipc	s2,0x2e
    800072ec:	d1890913          	addi	s2,s2,-744 # 80035000 <disk>
    800072f0:	00030497          	auipc	s1,0x30
    800072f4:	d1048493          	addi	s1,s1,-752 # 80037000 <disk+0x2000>
    __sync_synchronize();
    800072f8:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800072fc:	6898                	ld	a4,16(s1)
    800072fe:	0204d783          	lhu	a5,32(s1)
    80007302:	8b9d                	andi	a5,a5,7
    80007304:	078e                	slli	a5,a5,0x3
    80007306:	97ba                	add	a5,a5,a4
    80007308:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000730a:	20078713          	addi	a4,a5,512
    8000730e:	0712                	slli	a4,a4,0x4
    80007310:	974a                	add	a4,a4,s2
    80007312:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    80007316:	e731                	bnez	a4,80007362 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80007318:	20078793          	addi	a5,a5,512
    8000731c:	0792                	slli	a5,a5,0x4
    8000731e:	97ca                	add	a5,a5,s2
    80007320:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80007322:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80007326:	ffffb097          	auipc	ra,0xffffb
    8000732a:	f62080e7          	jalr	-158(ra) # 80002288 <wakeup>

    disk.used_idx += 1;
    8000732e:	0204d783          	lhu	a5,32(s1)
    80007332:	2785                	addiw	a5,a5,1
    80007334:	17c2                	slli	a5,a5,0x30
    80007336:	93c1                	srli	a5,a5,0x30
    80007338:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000733c:	6898                	ld	a4,16(s1)
    8000733e:	00275703          	lhu	a4,2(a4)
    80007342:	faf71be3          	bne	a4,a5,800072f8 <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    80007346:	00030517          	auipc	a0,0x30
    8000734a:	de250513          	addi	a0,a0,-542 # 80037128 <disk+0x2128>
    8000734e:	ffffa097          	auipc	ra,0xffffa
    80007352:	97e080e7          	jalr	-1666(ra) # 80000ccc <release>
}
    80007356:	60e2                	ld	ra,24(sp)
    80007358:	6442                	ld	s0,16(sp)
    8000735a:	64a2                	ld	s1,8(sp)
    8000735c:	6902                	ld	s2,0(sp)
    8000735e:	6105                	addi	sp,sp,32
    80007360:	8082                	ret
      panic("virtio_disk_intr status");
    80007362:	00002517          	auipc	a0,0x2
    80007366:	55e50513          	addi	a0,a0,1374 # 800098c0 <syscalls+0x3f8>
    8000736a:	ffff9097          	auipc	ra,0xffff9
    8000736e:	1d0080e7          	jalr	464(ra) # 8000053a <panic>
	...

0000000080008000 <_trampoline>:
    80008000:	14051573          	csrrw	a0,sscratch,a0
    80008004:	02153423          	sd	ra,40(a0)
    80008008:	02253823          	sd	sp,48(a0)
    8000800c:	02353c23          	sd	gp,56(a0)
    80008010:	04453023          	sd	tp,64(a0)
    80008014:	04553423          	sd	t0,72(a0)
    80008018:	04653823          	sd	t1,80(a0)
    8000801c:	04753c23          	sd	t2,88(a0)
    80008020:	f120                	sd	s0,96(a0)
    80008022:	f524                	sd	s1,104(a0)
    80008024:	fd2c                	sd	a1,120(a0)
    80008026:	e150                	sd	a2,128(a0)
    80008028:	e554                	sd	a3,136(a0)
    8000802a:	e958                	sd	a4,144(a0)
    8000802c:	ed5c                	sd	a5,152(a0)
    8000802e:	0b053023          	sd	a6,160(a0)
    80008032:	0b153423          	sd	a7,168(a0)
    80008036:	0b253823          	sd	s2,176(a0)
    8000803a:	0b353c23          	sd	s3,184(a0)
    8000803e:	0d453023          	sd	s4,192(a0)
    80008042:	0d553423          	sd	s5,200(a0)
    80008046:	0d653823          	sd	s6,208(a0)
    8000804a:	0d753c23          	sd	s7,216(a0)
    8000804e:	0f853023          	sd	s8,224(a0)
    80008052:	0f953423          	sd	s9,232(a0)
    80008056:	0fa53823          	sd	s10,240(a0)
    8000805a:	0fb53c23          	sd	s11,248(a0)
    8000805e:	11c53023          	sd	t3,256(a0)
    80008062:	11d53423          	sd	t4,264(a0)
    80008066:	11e53823          	sd	t5,272(a0)
    8000806a:	11f53c23          	sd	t6,280(a0)
    8000806e:	140022f3          	csrr	t0,sscratch
    80008072:	06553823          	sd	t0,112(a0)
    80008076:	00853103          	ld	sp,8(a0)
    8000807a:	02053203          	ld	tp,32(a0)
    8000807e:	01053283          	ld	t0,16(a0)
    80008082:	00053303          	ld	t1,0(a0)
    80008086:	18031073          	csrw	satp,t1
    8000808a:	12000073          	sfence.vma
    8000808e:	8282                	jr	t0

0000000080008090 <userret>:
    80008090:	18059073          	csrw	satp,a1
    80008094:	12000073          	sfence.vma
    80008098:	07053283          	ld	t0,112(a0)
    8000809c:	14029073          	csrw	sscratch,t0
    800080a0:	02853083          	ld	ra,40(a0)
    800080a4:	03053103          	ld	sp,48(a0)
    800080a8:	03853183          	ld	gp,56(a0)
    800080ac:	04053203          	ld	tp,64(a0)
    800080b0:	04853283          	ld	t0,72(a0)
    800080b4:	05053303          	ld	t1,80(a0)
    800080b8:	05853383          	ld	t2,88(a0)
    800080bc:	7120                	ld	s0,96(a0)
    800080be:	7524                	ld	s1,104(a0)
    800080c0:	7d2c                	ld	a1,120(a0)
    800080c2:	6150                	ld	a2,128(a0)
    800080c4:	6554                	ld	a3,136(a0)
    800080c6:	6958                	ld	a4,144(a0)
    800080c8:	6d5c                	ld	a5,152(a0)
    800080ca:	0a053803          	ld	a6,160(a0)
    800080ce:	0a853883          	ld	a7,168(a0)
    800080d2:	0b053903          	ld	s2,176(a0)
    800080d6:	0b853983          	ld	s3,184(a0)
    800080da:	0c053a03          	ld	s4,192(a0)
    800080de:	0c853a83          	ld	s5,200(a0)
    800080e2:	0d053b03          	ld	s6,208(a0)
    800080e6:	0d853b83          	ld	s7,216(a0)
    800080ea:	0e053c03          	ld	s8,224(a0)
    800080ee:	0e853c83          	ld	s9,232(a0)
    800080f2:	0f053d03          	ld	s10,240(a0)
    800080f6:	0f853d83          	ld	s11,248(a0)
    800080fa:	10053e03          	ld	t3,256(a0)
    800080fe:	10853e83          	ld	t4,264(a0)
    80008102:	11053f03          	ld	t5,272(a0)
    80008106:	11853f83          	ld	t6,280(a0)
    8000810a:	14051573          	csrrw	a0,sscratch,a0
    8000810e:	10200073          	sret
	...
