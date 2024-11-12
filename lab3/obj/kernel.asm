
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	0000a517          	auipc	a0,0xa
ffffffffc0200036:	00e50513          	addi	a0,a0,14 # ffffffffc020a040 <ide>
ffffffffc020003a:	00011617          	auipc	a2,0x11
ffffffffc020003e:	53660613          	addi	a2,a2,1334 # ffffffffc0211570 <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	6cf030ef          	jal	ra,ffffffffc0203f18 <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020004e:	00004597          	auipc	a1,0x4
ffffffffc0200052:	39a58593          	addi	a1,a1,922 # ffffffffc02043e8 <etext+0x4>
ffffffffc0200056:	00004517          	auipc	a0,0x4
ffffffffc020005a:	3b250513          	addi	a0,a0,946 # ffffffffc0204408 <etext+0x24>
ffffffffc020005e:	05c000ef          	jal	ra,ffffffffc02000ba <cprintf>

    print_kerninfo();
ffffffffc0200062:	0fc000ef          	jal	ra,ffffffffc020015e <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc0200066:	667020ef          	jal	ra,ffffffffc0202ecc <pmm_init>
    // 我们加入了多级页表的接口和测试

    idt_init();                 // init interrupt descriptor table
ffffffffc020006a:	4fa000ef          	jal	ra,ffffffffc0200564 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020006e:	7a3000ef          	jal	ra,ffffffffc0201010 <vmm_init>
    // 新增函数, 初始化虚拟内存管理并测试

    ide_init();                 // init ide devices初始化“硬盘”
ffffffffc0200072:	35e000ef          	jal	ra,ffffffffc02003d0 <ide_init>
    swap_init();                // init swap
ffffffffc0200076:	640010ef          	jal	ra,ffffffffc02016b6 <swap_init>
    //新增函数, 初始化页面置换机制并测试

    clock_init();               // init clock interrupt
ffffffffc020007a:	3ac000ef          	jal	ra,ffffffffc0200426 <clock_init>
    // intr_enable();              // enable irq interrupt



    /* do nothing */
    while (1);
ffffffffc020007e:	a001                	j	ffffffffc020007e <kern_init+0x4c>

ffffffffc0200080 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200080:	1141                	addi	sp,sp,-16
ffffffffc0200082:	e022                	sd	s0,0(sp)
ffffffffc0200084:	e406                	sd	ra,8(sp)
ffffffffc0200086:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200088:	3f0000ef          	jal	ra,ffffffffc0200478 <cons_putc>
    (*cnt) ++;
ffffffffc020008c:	401c                	lw	a5,0(s0)
}
ffffffffc020008e:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200090:	2785                	addiw	a5,a5,1
ffffffffc0200092:	c01c                	sw	a5,0(s0)
}
ffffffffc0200094:	6402                	ld	s0,0(sp)
ffffffffc0200096:	0141                	addi	sp,sp,16
ffffffffc0200098:	8082                	ret

ffffffffc020009a <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009a:	1101                	addi	sp,sp,-32
ffffffffc020009c:	862a                	mv	a2,a0
ffffffffc020009e:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	00000517          	auipc	a0,0x0
ffffffffc02000a4:	fe050513          	addi	a0,a0,-32 # ffffffffc0200080 <cputch>
ffffffffc02000a8:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000aa:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000ac:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ae:	701030ef          	jal	ra,ffffffffc0203fae <vprintfmt>
    return cnt;
}
ffffffffc02000b2:	60e2                	ld	ra,24(sp)
ffffffffc02000b4:	4532                	lw	a0,12(sp)
ffffffffc02000b6:	6105                	addi	sp,sp,32
ffffffffc02000b8:	8082                	ret

ffffffffc02000ba <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000ba:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000bc:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000c0:	8e2a                	mv	t3,a0
ffffffffc02000c2:	f42e                	sd	a1,40(sp)
ffffffffc02000c4:	f832                	sd	a2,48(sp)
ffffffffc02000c6:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c8:	00000517          	auipc	a0,0x0
ffffffffc02000cc:	fb850513          	addi	a0,a0,-72 # ffffffffc0200080 <cputch>
ffffffffc02000d0:	004c                	addi	a1,sp,4
ffffffffc02000d2:	869a                	mv	a3,t1
ffffffffc02000d4:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000d6:	ec06                	sd	ra,24(sp)
ffffffffc02000d8:	e0ba                	sd	a4,64(sp)
ffffffffc02000da:	e4be                	sd	a5,72(sp)
ffffffffc02000dc:	e8c2                	sd	a6,80(sp)
ffffffffc02000de:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000e0:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e2:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e4:	6cb030ef          	jal	ra,ffffffffc0203fae <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e8:	60e2                	ld	ra,24(sp)
ffffffffc02000ea:	4512                	lw	a0,4(sp)
ffffffffc02000ec:	6125                	addi	sp,sp,96
ffffffffc02000ee:	8082                	ret

ffffffffc02000f0 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000f0:	a661                	j	ffffffffc0200478 <cons_putc>

ffffffffc02000f2 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02000f2:	1141                	addi	sp,sp,-16
ffffffffc02000f4:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02000f6:	3b6000ef          	jal	ra,ffffffffc02004ac <cons_getc>
ffffffffc02000fa:	dd75                	beqz	a0,ffffffffc02000f6 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02000fc:	60a2                	ld	ra,8(sp)
ffffffffc02000fe:	0141                	addi	sp,sp,16
ffffffffc0200100:	8082                	ret

ffffffffc0200102 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200102:	00011317          	auipc	t1,0x11
ffffffffc0200106:	3f630313          	addi	t1,t1,1014 # ffffffffc02114f8 <is_panic>
ffffffffc020010a:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020010e:	715d                	addi	sp,sp,-80
ffffffffc0200110:	ec06                	sd	ra,24(sp)
ffffffffc0200112:	e822                	sd	s0,16(sp)
ffffffffc0200114:	f436                	sd	a3,40(sp)
ffffffffc0200116:	f83a                	sd	a4,48(sp)
ffffffffc0200118:	fc3e                	sd	a5,56(sp)
ffffffffc020011a:	e0c2                	sd	a6,64(sp)
ffffffffc020011c:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020011e:	020e1a63          	bnez	t3,ffffffffc0200152 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200122:	4785                	li	a5,1
ffffffffc0200124:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200128:	8432                	mv	s0,a2
ffffffffc020012a:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020012c:	862e                	mv	a2,a1
ffffffffc020012e:	85aa                	mv	a1,a0
ffffffffc0200130:	00004517          	auipc	a0,0x4
ffffffffc0200134:	2e050513          	addi	a0,a0,736 # ffffffffc0204410 <etext+0x2c>
    va_start(ap, fmt);
ffffffffc0200138:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020013a:	f81ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    vcprintf(fmt, ap);
ffffffffc020013e:	65a2                	ld	a1,8(sp)
ffffffffc0200140:	8522                	mv	a0,s0
ffffffffc0200142:	f59ff0ef          	jal	ra,ffffffffc020009a <vcprintf>
    cprintf("\n");
ffffffffc0200146:	00006517          	auipc	a0,0x6
ffffffffc020014a:	c2a50513          	addi	a0,a0,-982 # ffffffffc0205d70 <default_pmm_manager+0x420>
ffffffffc020014e:	f6dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200152:	39c000ef          	jal	ra,ffffffffc02004ee <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200156:	4501                	li	a0,0
ffffffffc0200158:	130000ef          	jal	ra,ffffffffc0200288 <kmonitor>
    while (1) {
ffffffffc020015c:	bfed                	j	ffffffffc0200156 <__panic+0x54>

ffffffffc020015e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020015e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200160:	00004517          	auipc	a0,0x4
ffffffffc0200164:	2d050513          	addi	a0,a0,720 # ffffffffc0204430 <etext+0x4c>
void print_kerninfo(void) {
ffffffffc0200168:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020016a:	f51ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc020016e:	00000597          	auipc	a1,0x0
ffffffffc0200172:	ec458593          	addi	a1,a1,-316 # ffffffffc0200032 <kern_init>
ffffffffc0200176:	00004517          	auipc	a0,0x4
ffffffffc020017a:	2da50513          	addi	a0,a0,730 # ffffffffc0204450 <etext+0x6c>
ffffffffc020017e:	f3dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200182:	00004597          	auipc	a1,0x4
ffffffffc0200186:	26258593          	addi	a1,a1,610 # ffffffffc02043e4 <etext>
ffffffffc020018a:	00004517          	auipc	a0,0x4
ffffffffc020018e:	2e650513          	addi	a0,a0,742 # ffffffffc0204470 <etext+0x8c>
ffffffffc0200192:	f29ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200196:	0000a597          	auipc	a1,0xa
ffffffffc020019a:	eaa58593          	addi	a1,a1,-342 # ffffffffc020a040 <ide>
ffffffffc020019e:	00004517          	auipc	a0,0x4
ffffffffc02001a2:	2f250513          	addi	a0,a0,754 # ffffffffc0204490 <etext+0xac>
ffffffffc02001a6:	f15ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc02001aa:	00011597          	auipc	a1,0x11
ffffffffc02001ae:	3c658593          	addi	a1,a1,966 # ffffffffc0211570 <end>
ffffffffc02001b2:	00004517          	auipc	a0,0x4
ffffffffc02001b6:	2fe50513          	addi	a0,a0,766 # ffffffffc02044b0 <etext+0xcc>
ffffffffc02001ba:	f01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001be:	00011597          	auipc	a1,0x11
ffffffffc02001c2:	7b158593          	addi	a1,a1,1969 # ffffffffc021196f <end+0x3ff>
ffffffffc02001c6:	00000797          	auipc	a5,0x0
ffffffffc02001ca:	e6c78793          	addi	a5,a5,-404 # ffffffffc0200032 <kern_init>
ffffffffc02001ce:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001d2:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001d6:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001d8:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001dc:	95be                	add	a1,a1,a5
ffffffffc02001de:	85a9                	srai	a1,a1,0xa
ffffffffc02001e0:	00004517          	auipc	a0,0x4
ffffffffc02001e4:	2f050513          	addi	a0,a0,752 # ffffffffc02044d0 <etext+0xec>
}
ffffffffc02001e8:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ea:	bdc1                	j	ffffffffc02000ba <cprintf>

ffffffffc02001ec <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001ec:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001ee:	00004617          	auipc	a2,0x4
ffffffffc02001f2:	31260613          	addi	a2,a2,786 # ffffffffc0204500 <etext+0x11c>
ffffffffc02001f6:	04e00593          	li	a1,78
ffffffffc02001fa:	00004517          	auipc	a0,0x4
ffffffffc02001fe:	31e50513          	addi	a0,a0,798 # ffffffffc0204518 <etext+0x134>
void print_stackframe(void) {
ffffffffc0200202:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200204:	effff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200208 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200208:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020020a:	00004617          	auipc	a2,0x4
ffffffffc020020e:	32660613          	addi	a2,a2,806 # ffffffffc0204530 <etext+0x14c>
ffffffffc0200212:	00004597          	auipc	a1,0x4
ffffffffc0200216:	33e58593          	addi	a1,a1,830 # ffffffffc0204550 <etext+0x16c>
ffffffffc020021a:	00004517          	auipc	a0,0x4
ffffffffc020021e:	33e50513          	addi	a0,a0,830 # ffffffffc0204558 <etext+0x174>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200222:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200224:	e97ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200228:	00004617          	auipc	a2,0x4
ffffffffc020022c:	34060613          	addi	a2,a2,832 # ffffffffc0204568 <etext+0x184>
ffffffffc0200230:	00004597          	auipc	a1,0x4
ffffffffc0200234:	36058593          	addi	a1,a1,864 # ffffffffc0204590 <etext+0x1ac>
ffffffffc0200238:	00004517          	auipc	a0,0x4
ffffffffc020023c:	32050513          	addi	a0,a0,800 # ffffffffc0204558 <etext+0x174>
ffffffffc0200240:	e7bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200244:	00004617          	auipc	a2,0x4
ffffffffc0200248:	35c60613          	addi	a2,a2,860 # ffffffffc02045a0 <etext+0x1bc>
ffffffffc020024c:	00004597          	auipc	a1,0x4
ffffffffc0200250:	37458593          	addi	a1,a1,884 # ffffffffc02045c0 <etext+0x1dc>
ffffffffc0200254:	00004517          	auipc	a0,0x4
ffffffffc0200258:	30450513          	addi	a0,a0,772 # ffffffffc0204558 <etext+0x174>
ffffffffc020025c:	e5fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    }
    return 0;
}
ffffffffc0200260:	60a2                	ld	ra,8(sp)
ffffffffc0200262:	4501                	li	a0,0
ffffffffc0200264:	0141                	addi	sp,sp,16
ffffffffc0200266:	8082                	ret

ffffffffc0200268 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200268:	1141                	addi	sp,sp,-16
ffffffffc020026a:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020026c:	ef3ff0ef          	jal	ra,ffffffffc020015e <print_kerninfo>
    return 0;
}
ffffffffc0200270:	60a2                	ld	ra,8(sp)
ffffffffc0200272:	4501                	li	a0,0
ffffffffc0200274:	0141                	addi	sp,sp,16
ffffffffc0200276:	8082                	ret

ffffffffc0200278 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200278:	1141                	addi	sp,sp,-16
ffffffffc020027a:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020027c:	f71ff0ef          	jal	ra,ffffffffc02001ec <print_stackframe>
    return 0;
}
ffffffffc0200280:	60a2                	ld	ra,8(sp)
ffffffffc0200282:	4501                	li	a0,0
ffffffffc0200284:	0141                	addi	sp,sp,16
ffffffffc0200286:	8082                	ret

ffffffffc0200288 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200288:	7115                	addi	sp,sp,-224
ffffffffc020028a:	ed5e                	sd	s7,152(sp)
ffffffffc020028c:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020028e:	00004517          	auipc	a0,0x4
ffffffffc0200292:	34250513          	addi	a0,a0,834 # ffffffffc02045d0 <etext+0x1ec>
kmonitor(struct trapframe *tf) {
ffffffffc0200296:	ed86                	sd	ra,216(sp)
ffffffffc0200298:	e9a2                	sd	s0,208(sp)
ffffffffc020029a:	e5a6                	sd	s1,200(sp)
ffffffffc020029c:	e1ca                	sd	s2,192(sp)
ffffffffc020029e:	fd4e                	sd	s3,184(sp)
ffffffffc02002a0:	f952                	sd	s4,176(sp)
ffffffffc02002a2:	f556                	sd	s5,168(sp)
ffffffffc02002a4:	f15a                	sd	s6,160(sp)
ffffffffc02002a6:	e962                	sd	s8,144(sp)
ffffffffc02002a8:	e566                	sd	s9,136(sp)
ffffffffc02002aa:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002ac:	e0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02002b0:	00004517          	auipc	a0,0x4
ffffffffc02002b4:	34850513          	addi	a0,a0,840 # ffffffffc02045f8 <etext+0x214>
ffffffffc02002b8:	e03ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    if (tf != NULL) {
ffffffffc02002bc:	000b8563          	beqz	s7,ffffffffc02002c6 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002c0:	855e                	mv	a0,s7
ffffffffc02002c2:	48c000ef          	jal	ra,ffffffffc020074e <print_trapframe>
ffffffffc02002c6:	00004c17          	auipc	s8,0x4
ffffffffc02002ca:	39ac0c13          	addi	s8,s8,922 # ffffffffc0204660 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc02002ce:	00005917          	auipc	s2,0x5
ffffffffc02002d2:	22290913          	addi	s2,s2,546 # ffffffffc02054f0 <commands+0xe90>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d6:	00004497          	auipc	s1,0x4
ffffffffc02002da:	34a48493          	addi	s1,s1,842 # ffffffffc0204620 <etext+0x23c>
        if (argc == MAXARGS - 1) {
ffffffffc02002de:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002e0:	00004b17          	auipc	s6,0x4
ffffffffc02002e4:	348b0b13          	addi	s6,s6,840 # ffffffffc0204628 <etext+0x244>
        argv[argc ++] = buf;
ffffffffc02002e8:	00004a17          	auipc	s4,0x4
ffffffffc02002ec:	268a0a13          	addi	s4,s4,616 # ffffffffc0204550 <etext+0x16c>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4a8d                	li	s5,3
        if ((buf = readline("")) != NULL) {
ffffffffc02002f2:	854a                	mv	a0,s2
ffffffffc02002f4:	03c040ef          	jal	ra,ffffffffc0204330 <readline>
ffffffffc02002f8:	842a                	mv	s0,a0
ffffffffc02002fa:	dd65                	beqz	a0,ffffffffc02002f2 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002fc:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200300:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200302:	e1bd                	bnez	a1,ffffffffc0200368 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc0200304:	fe0c87e3          	beqz	s9,ffffffffc02002f2 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200308:	6582                	ld	a1,0(sp)
ffffffffc020030a:	00004d17          	auipc	s10,0x4
ffffffffc020030e:	356d0d13          	addi	s10,s10,854 # ffffffffc0204660 <commands>
        argv[argc ++] = buf;
ffffffffc0200312:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200314:	4401                	li	s0,0
ffffffffc0200316:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200318:	3cd030ef          	jal	ra,ffffffffc0203ee4 <strcmp>
ffffffffc020031c:	c919                	beqz	a0,ffffffffc0200332 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020031e:	2405                	addiw	s0,s0,1
ffffffffc0200320:	0b540063          	beq	s0,s5,ffffffffc02003c0 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200324:	000d3503          	ld	a0,0(s10)
ffffffffc0200328:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020032a:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020032c:	3b9030ef          	jal	ra,ffffffffc0203ee4 <strcmp>
ffffffffc0200330:	f57d                	bnez	a0,ffffffffc020031e <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200332:	00141793          	slli	a5,s0,0x1
ffffffffc0200336:	97a2                	add	a5,a5,s0
ffffffffc0200338:	078e                	slli	a5,a5,0x3
ffffffffc020033a:	97e2                	add	a5,a5,s8
ffffffffc020033c:	6b9c                	ld	a5,16(a5)
ffffffffc020033e:	865e                	mv	a2,s7
ffffffffc0200340:	002c                	addi	a1,sp,8
ffffffffc0200342:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200346:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200348:	fa0555e3          	bgez	a0,ffffffffc02002f2 <kmonitor+0x6a>
}
ffffffffc020034c:	60ee                	ld	ra,216(sp)
ffffffffc020034e:	644e                	ld	s0,208(sp)
ffffffffc0200350:	64ae                	ld	s1,200(sp)
ffffffffc0200352:	690e                	ld	s2,192(sp)
ffffffffc0200354:	79ea                	ld	s3,184(sp)
ffffffffc0200356:	7a4a                	ld	s4,176(sp)
ffffffffc0200358:	7aaa                	ld	s5,168(sp)
ffffffffc020035a:	7b0a                	ld	s6,160(sp)
ffffffffc020035c:	6bea                	ld	s7,152(sp)
ffffffffc020035e:	6c4a                	ld	s8,144(sp)
ffffffffc0200360:	6caa                	ld	s9,136(sp)
ffffffffc0200362:	6d0a                	ld	s10,128(sp)
ffffffffc0200364:	612d                	addi	sp,sp,224
ffffffffc0200366:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200368:	8526                	mv	a0,s1
ffffffffc020036a:	399030ef          	jal	ra,ffffffffc0203f02 <strchr>
ffffffffc020036e:	c901                	beqz	a0,ffffffffc020037e <kmonitor+0xf6>
ffffffffc0200370:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200374:	00040023          	sb	zero,0(s0)
ffffffffc0200378:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020037a:	d5c9                	beqz	a1,ffffffffc0200304 <kmonitor+0x7c>
ffffffffc020037c:	b7f5                	j	ffffffffc0200368 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc020037e:	00044783          	lbu	a5,0(s0)
ffffffffc0200382:	d3c9                	beqz	a5,ffffffffc0200304 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200384:	033c8963          	beq	s9,s3,ffffffffc02003b6 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200388:	003c9793          	slli	a5,s9,0x3
ffffffffc020038c:	0118                	addi	a4,sp,128
ffffffffc020038e:	97ba                	add	a5,a5,a4
ffffffffc0200390:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200394:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200398:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020039a:	e591                	bnez	a1,ffffffffc02003a6 <kmonitor+0x11e>
ffffffffc020039c:	b7b5                	j	ffffffffc0200308 <kmonitor+0x80>
ffffffffc020039e:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc02003a2:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003a4:	d1a5                	beqz	a1,ffffffffc0200304 <kmonitor+0x7c>
ffffffffc02003a6:	8526                	mv	a0,s1
ffffffffc02003a8:	35b030ef          	jal	ra,ffffffffc0203f02 <strchr>
ffffffffc02003ac:	d96d                	beqz	a0,ffffffffc020039e <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003ae:	00044583          	lbu	a1,0(s0)
ffffffffc02003b2:	d9a9                	beqz	a1,ffffffffc0200304 <kmonitor+0x7c>
ffffffffc02003b4:	bf55                	j	ffffffffc0200368 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003b6:	45c1                	li	a1,16
ffffffffc02003b8:	855a                	mv	a0,s6
ffffffffc02003ba:	d01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02003be:	b7e9                	j	ffffffffc0200388 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003c0:	6582                	ld	a1,0(sp)
ffffffffc02003c2:	00004517          	auipc	a0,0x4
ffffffffc02003c6:	28650513          	addi	a0,a0,646 # ffffffffc0204648 <etext+0x264>
ffffffffc02003ca:	cf1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    return 0;
ffffffffc02003ce:	b715                	j	ffffffffc02002f2 <kmonitor+0x6a>

ffffffffc02003d0 <ide_init>:
#include <trap.h>
#include <riscv.h>
//IDE设备 是一种硬盘和光驱等存储设备的接口标准

//初始化IDE设备
void ide_init(void) {}
ffffffffc02003d0:	8082                	ret

ffffffffc02003d2 <ide_device_valid>:
#define MAX_IDE 2
//每个IDE设备的最大磁盘扇区数
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02003d2:	00253513          	sltiu	a0,a0,2
ffffffffc02003d6:	8082                	ret

ffffffffc02003d8 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02003d8:	03800513          	li	a0,56
ffffffffc02003dc:	8082                	ret

ffffffffc02003de <ide_read_secs>:
//dst：目标内存地址，用于存储读取到的数据。
//nsecs：要读取的扇区数
int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003de:	0000a797          	auipc	a5,0xa
ffffffffc02003e2:	c6278793          	addi	a5,a5,-926 # ffffffffc020a040 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc02003e6:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02003ea:	1141                	addi	sp,sp,-16
ffffffffc02003ec:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003ee:	95be                	add	a1,a1,a5
ffffffffc02003f0:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02003f4:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003f6:	335030ef          	jal	ra,ffffffffc0203f2a <memcpy>
    return 0;
}
ffffffffc02003fa:	60a2                	ld	ra,8(sp)
ffffffffc02003fc:	4501                	li	a0,0
ffffffffc02003fe:	0141                	addi	sp,sp,16
ffffffffc0200400:	8082                	ret

ffffffffc0200402 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc0200402:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200406:	0000a517          	auipc	a0,0xa
ffffffffc020040a:	c3a50513          	addi	a0,a0,-966 # ffffffffc020a040 <ide>
                   size_t nsecs) {
ffffffffc020040e:	1141                	addi	sp,sp,-16
ffffffffc0200410:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200412:	953e                	add	a0,a0,a5
ffffffffc0200414:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc0200418:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020041a:	311030ef          	jal	ra,ffffffffc0203f2a <memcpy>
    return 0;
}
ffffffffc020041e:	60a2                	ld	ra,8(sp)
ffffffffc0200420:	4501                	li	a0,0
ffffffffc0200422:	0141                	addi	sp,sp,16
ffffffffc0200424:	8082                	ret

ffffffffc0200426 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200426:	67e1                	lui	a5,0x18
ffffffffc0200428:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020042c:	00011717          	auipc	a4,0x11
ffffffffc0200430:	0cf73e23          	sd	a5,220(a4) # ffffffffc0211508 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200434:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200438:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043a:	953e                	add	a0,a0,a5
ffffffffc020043c:	4601                	li	a2,0
ffffffffc020043e:	4881                	li	a7,0
ffffffffc0200440:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200444:	02000793          	li	a5,32
ffffffffc0200448:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc020044c:	00004517          	auipc	a0,0x4
ffffffffc0200450:	25c50513          	addi	a0,a0,604 # ffffffffc02046a8 <commands+0x48>
    ticks = 0;
ffffffffc0200454:	00011797          	auipc	a5,0x11
ffffffffc0200458:	0a07b623          	sd	zero,172(a5) # ffffffffc0211500 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020045c:	b9b9                	j	ffffffffc02000ba <cprintf>

ffffffffc020045e <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020045e:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200462:	00011797          	auipc	a5,0x11
ffffffffc0200466:	0a67b783          	ld	a5,166(a5) # ffffffffc0211508 <timebase>
ffffffffc020046a:	953e                	add	a0,a0,a5
ffffffffc020046c:	4581                	li	a1,0
ffffffffc020046e:	4601                	li	a2,0
ffffffffc0200470:	4881                	li	a7,0
ffffffffc0200472:	00000073          	ecall
ffffffffc0200476:	8082                	ret

ffffffffc0200478 <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200478:	100027f3          	csrr	a5,sstatus
ffffffffc020047c:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc020047e:	0ff57513          	zext.b	a0,a0
ffffffffc0200482:	e799                	bnez	a5,ffffffffc0200490 <cons_putc+0x18>
ffffffffc0200484:	4581                	li	a1,0
ffffffffc0200486:	4601                	li	a2,0
ffffffffc0200488:	4885                	li	a7,1
ffffffffc020048a:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020048e:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200490:	1101                	addi	sp,sp,-32
ffffffffc0200492:	ec06                	sd	ra,24(sp)
ffffffffc0200494:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200496:	058000ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc020049a:	6522                	ld	a0,8(sp)
ffffffffc020049c:	4581                	li	a1,0
ffffffffc020049e:	4601                	li	a2,0
ffffffffc02004a0:	4885                	li	a7,1
ffffffffc02004a2:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02004a6:	60e2                	ld	ra,24(sp)
ffffffffc02004a8:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02004aa:	a83d                	j	ffffffffc02004e8 <intr_enable>

ffffffffc02004ac <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02004ac:	100027f3          	csrr	a5,sstatus
ffffffffc02004b0:	8b89                	andi	a5,a5,2
ffffffffc02004b2:	eb89                	bnez	a5,ffffffffc02004c4 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02004b4:	4501                	li	a0,0
ffffffffc02004b6:	4581                	li	a1,0
ffffffffc02004b8:	4601                	li	a2,0
ffffffffc02004ba:	4889                	li	a7,2
ffffffffc02004bc:	00000073          	ecall
ffffffffc02004c0:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02004c2:	8082                	ret
int cons_getc(void) {
ffffffffc02004c4:	1101                	addi	sp,sp,-32
ffffffffc02004c6:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02004c8:	026000ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02004cc:	4501                	li	a0,0
ffffffffc02004ce:	4581                	li	a1,0
ffffffffc02004d0:	4601                	li	a2,0
ffffffffc02004d2:	4889                	li	a7,2
ffffffffc02004d4:	00000073          	ecall
ffffffffc02004d8:	2501                	sext.w	a0,a0
ffffffffc02004da:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02004dc:	00c000ef          	jal	ra,ffffffffc02004e8 <intr_enable>
}
ffffffffc02004e0:	60e2                	ld	ra,24(sp)
ffffffffc02004e2:	6522                	ld	a0,8(sp)
ffffffffc02004e4:	6105                	addi	sp,sp,32
ffffffffc02004e6:	8082                	ret

ffffffffc02004e8 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004e8:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004ec:	8082                	ret

ffffffffc02004ee <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004ee:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004f4:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004f8:	1141                	addi	sp,sp,-16
ffffffffc02004fa:	e022                	sd	s0,0(sp)
ffffffffc02004fc:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004fe:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200502:	11053583          	ld	a1,272(a0)
static int pgfault_handler(struct trapframe *tf) {
ffffffffc0200506:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200508:	05500613          	li	a2,85
ffffffffc020050c:	c399                	beqz	a5,ffffffffc0200512 <pgfault_handler+0x1e>
ffffffffc020050e:	04b00613          	li	a2,75
ffffffffc0200512:	11843703          	ld	a4,280(s0)
ffffffffc0200516:	47bd                	li	a5,15
ffffffffc0200518:	05700693          	li	a3,87
ffffffffc020051c:	00f70463          	beq	a4,a5,ffffffffc0200524 <pgfault_handler+0x30>
ffffffffc0200520:	05200693          	li	a3,82
ffffffffc0200524:	00004517          	auipc	a0,0x4
ffffffffc0200528:	1a450513          	addi	a0,a0,420 # ffffffffc02046c8 <commands+0x68>
ffffffffc020052c:	b8fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200530:	00011517          	auipc	a0,0x11
ffffffffc0200534:	fe853503          	ld	a0,-24(a0) # ffffffffc0211518 <check_mm_struct>
ffffffffc0200538:	c911                	beqz	a0,ffffffffc020054c <pgfault_handler+0x58>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020053a:	11043603          	ld	a2,272(s0)
ffffffffc020053e:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200542:	6402                	ld	s0,0(sp)
ffffffffc0200544:	60a2                	ld	ra,8(sp)
ffffffffc0200546:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200548:	0a00106f          	j	ffffffffc02015e8 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020054c:	00004617          	auipc	a2,0x4
ffffffffc0200550:	19c60613          	addi	a2,a2,412 # ffffffffc02046e8 <commands+0x88>
ffffffffc0200554:	07800593          	li	a1,120
ffffffffc0200558:	00004517          	auipc	a0,0x4
ffffffffc020055c:	1a850513          	addi	a0,a0,424 # ffffffffc0204700 <commands+0xa0>
ffffffffc0200560:	ba3ff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200564 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200564:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200568:	00000797          	auipc	a5,0x0
ffffffffc020056c:	48878793          	addi	a5,a5,1160 # ffffffffc02009f0 <__alltraps>
ffffffffc0200570:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200574:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200578:	000407b7          	lui	a5,0x40
ffffffffc020057c:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200580:	8082                	ret

ffffffffc0200582 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200582:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200584:	1141                	addi	sp,sp,-16
ffffffffc0200586:	e022                	sd	s0,0(sp)
ffffffffc0200588:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020058a:	00004517          	auipc	a0,0x4
ffffffffc020058e:	18e50513          	addi	a0,a0,398 # ffffffffc0204718 <commands+0xb8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200592:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200594:	b27ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200598:	640c                	ld	a1,8(s0)
ffffffffc020059a:	00004517          	auipc	a0,0x4
ffffffffc020059e:	19650513          	addi	a0,a0,406 # ffffffffc0204730 <commands+0xd0>
ffffffffc02005a2:	b19ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005a6:	680c                	ld	a1,16(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	1a050513          	addi	a0,a0,416 # ffffffffc0204748 <commands+0xe8>
ffffffffc02005b0:	b0bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005b4:	6c0c                	ld	a1,24(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	1aa50513          	addi	a0,a0,426 # ffffffffc0204760 <commands+0x100>
ffffffffc02005be:	afdff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005c2:	700c                	ld	a1,32(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	1b450513          	addi	a0,a0,436 # ffffffffc0204778 <commands+0x118>
ffffffffc02005cc:	aefff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005d0:	740c                	ld	a1,40(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	1be50513          	addi	a0,a0,446 # ffffffffc0204790 <commands+0x130>
ffffffffc02005da:	ae1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005de:	780c                	ld	a1,48(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	1c850513          	addi	a0,a0,456 # ffffffffc02047a8 <commands+0x148>
ffffffffc02005e8:	ad3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005ec:	7c0c                	ld	a1,56(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	1d250513          	addi	a0,a0,466 # ffffffffc02047c0 <commands+0x160>
ffffffffc02005f6:	ac5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02005fa:	602c                	ld	a1,64(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	1dc50513          	addi	a0,a0,476 # ffffffffc02047d8 <commands+0x178>
ffffffffc0200604:	ab7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200608:	642c                	ld	a1,72(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	1e650513          	addi	a0,a0,486 # ffffffffc02047f0 <commands+0x190>
ffffffffc0200612:	aa9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200616:	682c                	ld	a1,80(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	1f050513          	addi	a0,a0,496 # ffffffffc0204808 <commands+0x1a8>
ffffffffc0200620:	a9bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200624:	6c2c                	ld	a1,88(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	1fa50513          	addi	a0,a0,506 # ffffffffc0204820 <commands+0x1c0>
ffffffffc020062e:	a8dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200632:	702c                	ld	a1,96(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	20450513          	addi	a0,a0,516 # ffffffffc0204838 <commands+0x1d8>
ffffffffc020063c:	a7fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200640:	742c                	ld	a1,104(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	20e50513          	addi	a0,a0,526 # ffffffffc0204850 <commands+0x1f0>
ffffffffc020064a:	a71ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020064e:	782c                	ld	a1,112(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	21850513          	addi	a0,a0,536 # ffffffffc0204868 <commands+0x208>
ffffffffc0200658:	a63ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020065c:	7c2c                	ld	a1,120(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	22250513          	addi	a0,a0,546 # ffffffffc0204880 <commands+0x220>
ffffffffc0200666:	a55ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020066a:	604c                	ld	a1,128(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	22c50513          	addi	a0,a0,556 # ffffffffc0204898 <commands+0x238>
ffffffffc0200674:	a47ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200678:	644c                	ld	a1,136(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	23650513          	addi	a0,a0,566 # ffffffffc02048b0 <commands+0x250>
ffffffffc0200682:	a39ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200686:	684c                	ld	a1,144(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	24050513          	addi	a0,a0,576 # ffffffffc02048c8 <commands+0x268>
ffffffffc0200690:	a2bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200694:	6c4c                	ld	a1,152(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	24a50513          	addi	a0,a0,586 # ffffffffc02048e0 <commands+0x280>
ffffffffc020069e:	a1dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006a2:	704c                	ld	a1,160(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	25450513          	addi	a0,a0,596 # ffffffffc02048f8 <commands+0x298>
ffffffffc02006ac:	a0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006b0:	744c                	ld	a1,168(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	25e50513          	addi	a0,a0,606 # ffffffffc0204910 <commands+0x2b0>
ffffffffc02006ba:	a01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006be:	784c                	ld	a1,176(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	26850513          	addi	a0,a0,616 # ffffffffc0204928 <commands+0x2c8>
ffffffffc02006c8:	9f3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006cc:	7c4c                	ld	a1,184(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	27250513          	addi	a0,a0,626 # ffffffffc0204940 <commands+0x2e0>
ffffffffc02006d6:	9e5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006da:	606c                	ld	a1,192(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	27c50513          	addi	a0,a0,636 # ffffffffc0204958 <commands+0x2f8>
ffffffffc02006e4:	9d7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006e8:	646c                	ld	a1,200(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	28650513          	addi	a0,a0,646 # ffffffffc0204970 <commands+0x310>
ffffffffc02006f2:	9c9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006f6:	686c                	ld	a1,208(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	29050513          	addi	a0,a0,656 # ffffffffc0204988 <commands+0x328>
ffffffffc0200700:	9bbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200704:	6c6c                	ld	a1,216(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	29a50513          	addi	a0,a0,666 # ffffffffc02049a0 <commands+0x340>
ffffffffc020070e:	9adff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200712:	706c                	ld	a1,224(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	2a450513          	addi	a0,a0,676 # ffffffffc02049b8 <commands+0x358>
ffffffffc020071c:	99fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200720:	746c                	ld	a1,232(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	2ae50513          	addi	a0,a0,686 # ffffffffc02049d0 <commands+0x370>
ffffffffc020072a:	991ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020072e:	786c                	ld	a1,240(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	2b850513          	addi	a0,a0,696 # ffffffffc02049e8 <commands+0x388>
ffffffffc0200738:	983ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020073c:	7c6c                	ld	a1,248(s0)
}
ffffffffc020073e:	6402                	ld	s0,0(sp)
ffffffffc0200740:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200742:	00004517          	auipc	a0,0x4
ffffffffc0200746:	2be50513          	addi	a0,a0,702 # ffffffffc0204a00 <commands+0x3a0>
}
ffffffffc020074a:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020074c:	b2bd                	j	ffffffffc02000ba <cprintf>

ffffffffc020074e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020074e:	1141                	addi	sp,sp,-16
ffffffffc0200750:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200752:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200754:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200756:	00004517          	auipc	a0,0x4
ffffffffc020075a:	2c250513          	addi	a0,a0,706 # ffffffffc0204a18 <commands+0x3b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020075e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200760:	95bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200764:	8522                	mv	a0,s0
ffffffffc0200766:	e1dff0ef          	jal	ra,ffffffffc0200582 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020076a:	10043583          	ld	a1,256(s0)
ffffffffc020076e:	00004517          	auipc	a0,0x4
ffffffffc0200772:	2c250513          	addi	a0,a0,706 # ffffffffc0204a30 <commands+0x3d0>
ffffffffc0200776:	945ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020077a:	10843583          	ld	a1,264(s0)
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	2ca50513          	addi	a0,a0,714 # ffffffffc0204a48 <commands+0x3e8>
ffffffffc0200786:	935ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020078a:	11043583          	ld	a1,272(s0)
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	2d250513          	addi	a0,a0,722 # ffffffffc0204a60 <commands+0x400>
ffffffffc0200796:	925ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020079a:	11843583          	ld	a1,280(s0)
}
ffffffffc020079e:	6402                	ld	s0,0(sp)
ffffffffc02007a0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007a2:	00004517          	auipc	a0,0x4
ffffffffc02007a6:	2d650513          	addi	a0,a0,726 # ffffffffc0204a78 <commands+0x418>
}
ffffffffc02007aa:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007ac:	90fff06f          	j	ffffffffc02000ba <cprintf>

ffffffffc02007b0 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007b0:	11853783          	ld	a5,280(a0)
ffffffffc02007b4:	472d                	li	a4,11
ffffffffc02007b6:	0786                	slli	a5,a5,0x1
ffffffffc02007b8:	8385                	srli	a5,a5,0x1
ffffffffc02007ba:	06f76c63          	bltu	a4,a5,ffffffffc0200832 <interrupt_handler+0x82>
ffffffffc02007be:	00004717          	auipc	a4,0x4
ffffffffc02007c2:	38270713          	addi	a4,a4,898 # ffffffffc0204b40 <commands+0x4e0>
ffffffffc02007c6:	078a                	slli	a5,a5,0x2
ffffffffc02007c8:	97ba                	add	a5,a5,a4
ffffffffc02007ca:	439c                	lw	a5,0(a5)
ffffffffc02007cc:	97ba                	add	a5,a5,a4
ffffffffc02007ce:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007d0:	00004517          	auipc	a0,0x4
ffffffffc02007d4:	32050513          	addi	a0,a0,800 # ffffffffc0204af0 <commands+0x490>
ffffffffc02007d8:	8e3ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007dc:	00004517          	auipc	a0,0x4
ffffffffc02007e0:	2f450513          	addi	a0,a0,756 # ffffffffc0204ad0 <commands+0x470>
ffffffffc02007e4:	8d7ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007e8:	00004517          	auipc	a0,0x4
ffffffffc02007ec:	2a850513          	addi	a0,a0,680 # ffffffffc0204a90 <commands+0x430>
ffffffffc02007f0:	8cbff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007f4:	00004517          	auipc	a0,0x4
ffffffffc02007f8:	2bc50513          	addi	a0,a0,700 # ffffffffc0204ab0 <commands+0x450>
ffffffffc02007fc:	8bfff06f          	j	ffffffffc02000ba <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200800:	1141                	addi	sp,sp,-16
ffffffffc0200802:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200804:	c5bff0ef          	jal	ra,ffffffffc020045e <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200808:	00011697          	auipc	a3,0x11
ffffffffc020080c:	cf868693          	addi	a3,a3,-776 # ffffffffc0211500 <ticks>
ffffffffc0200810:	629c                	ld	a5,0(a3)
ffffffffc0200812:	06400713          	li	a4,100
ffffffffc0200816:	0785                	addi	a5,a5,1
ffffffffc0200818:	02e7f733          	remu	a4,a5,a4
ffffffffc020081c:	e29c                	sd	a5,0(a3)
ffffffffc020081e:	cb19                	beqz	a4,ffffffffc0200834 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200820:	60a2                	ld	ra,8(sp)
ffffffffc0200822:	0141                	addi	sp,sp,16
ffffffffc0200824:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200826:	00004517          	auipc	a0,0x4
ffffffffc020082a:	2fa50513          	addi	a0,a0,762 # ffffffffc0204b20 <commands+0x4c0>
ffffffffc020082e:	88dff06f          	j	ffffffffc02000ba <cprintf>
            print_trapframe(tf);
ffffffffc0200832:	bf31                	j	ffffffffc020074e <print_trapframe>
}
ffffffffc0200834:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200836:	06400593          	li	a1,100
ffffffffc020083a:	00004517          	auipc	a0,0x4
ffffffffc020083e:	2d650513          	addi	a0,a0,726 # ffffffffc0204b10 <commands+0x4b0>
}
ffffffffc0200842:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200844:	877ff06f          	j	ffffffffc02000ba <cprintf>

ffffffffc0200848 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200848:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc020084c:	1101                	addi	sp,sp,-32
ffffffffc020084e:	e822                	sd	s0,16(sp)
ffffffffc0200850:	ec06                	sd	ra,24(sp)
ffffffffc0200852:	e426                	sd	s1,8(sp)
ffffffffc0200854:	473d                	li	a4,15
ffffffffc0200856:	842a                	mv	s0,a0
ffffffffc0200858:	14f76a63          	bltu	a4,a5,ffffffffc02009ac <exception_handler+0x164>
ffffffffc020085c:	00004717          	auipc	a4,0x4
ffffffffc0200860:	4cc70713          	addi	a4,a4,1228 # ffffffffc0204d28 <commands+0x6c8>
ffffffffc0200864:	078a                	slli	a5,a5,0x2
ffffffffc0200866:	97ba                	add	a5,a5,a4
ffffffffc0200868:	439c                	lw	a5,0(a5)
ffffffffc020086a:	97ba                	add	a5,a5,a4
ffffffffc020086c:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc020086e:	00004517          	auipc	a0,0x4
ffffffffc0200872:	4a250513          	addi	a0,a0,1186 # ffffffffc0204d10 <commands+0x6b0>
ffffffffc0200876:	845ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020087a:	8522                	mv	a0,s0
ffffffffc020087c:	c79ff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc0200880:	84aa                	mv	s1,a0
ffffffffc0200882:	12051b63          	bnez	a0,ffffffffc02009b8 <exception_handler+0x170>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200886:	60e2                	ld	ra,24(sp)
ffffffffc0200888:	6442                	ld	s0,16(sp)
ffffffffc020088a:	64a2                	ld	s1,8(sp)
ffffffffc020088c:	6105                	addi	sp,sp,32
ffffffffc020088e:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc0200890:	00004517          	auipc	a0,0x4
ffffffffc0200894:	2e050513          	addi	a0,a0,736 # ffffffffc0204b70 <commands+0x510>
}
ffffffffc0200898:	6442                	ld	s0,16(sp)
ffffffffc020089a:	60e2                	ld	ra,24(sp)
ffffffffc020089c:	64a2                	ld	s1,8(sp)
ffffffffc020089e:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008a0:	81bff06f          	j	ffffffffc02000ba <cprintf>
ffffffffc02008a4:	00004517          	auipc	a0,0x4
ffffffffc02008a8:	2ec50513          	addi	a0,a0,748 # ffffffffc0204b90 <commands+0x530>
ffffffffc02008ac:	b7f5                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02008ae:	00004517          	auipc	a0,0x4
ffffffffc02008b2:	30250513          	addi	a0,a0,770 # ffffffffc0204bb0 <commands+0x550>
ffffffffc02008b6:	b7cd                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02008b8:	00004517          	auipc	a0,0x4
ffffffffc02008bc:	31050513          	addi	a0,a0,784 # ffffffffc0204bc8 <commands+0x568>
ffffffffc02008c0:	bfe1                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02008c2:	00004517          	auipc	a0,0x4
ffffffffc02008c6:	31650513          	addi	a0,a0,790 # ffffffffc0204bd8 <commands+0x578>
ffffffffc02008ca:	b7f9                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02008cc:	00004517          	auipc	a0,0x4
ffffffffc02008d0:	32c50513          	addi	a0,a0,812 # ffffffffc0204bf8 <commands+0x598>
ffffffffc02008d4:	fe6ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008d8:	8522                	mv	a0,s0
ffffffffc02008da:	c1bff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc02008de:	84aa                	mv	s1,a0
ffffffffc02008e0:	d15d                	beqz	a0,ffffffffc0200886 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02008e2:	8522                	mv	a0,s0
ffffffffc02008e4:	e6bff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02008e8:	86a6                	mv	a3,s1
ffffffffc02008ea:	00004617          	auipc	a2,0x4
ffffffffc02008ee:	32660613          	addi	a2,a2,806 # ffffffffc0204c10 <commands+0x5b0>
ffffffffc02008f2:	0ca00593          	li	a1,202
ffffffffc02008f6:	00004517          	auipc	a0,0x4
ffffffffc02008fa:	e0a50513          	addi	a0,a0,-502 # ffffffffc0204700 <commands+0xa0>
ffffffffc02008fe:	805ff0ef          	jal	ra,ffffffffc0200102 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc0200902:	00004517          	auipc	a0,0x4
ffffffffc0200906:	32e50513          	addi	a0,a0,814 # ffffffffc0204c30 <commands+0x5d0>
ffffffffc020090a:	b779                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc020090c:	00004517          	auipc	a0,0x4
ffffffffc0200910:	33c50513          	addi	a0,a0,828 # ffffffffc0204c48 <commands+0x5e8>
ffffffffc0200914:	fa6ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200918:	8522                	mv	a0,s0
ffffffffc020091a:	bdbff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc020091e:	84aa                	mv	s1,a0
ffffffffc0200920:	d13d                	beqz	a0,ffffffffc0200886 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200922:	8522                	mv	a0,s0
ffffffffc0200924:	e2bff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200928:	86a6                	mv	a3,s1
ffffffffc020092a:	00004617          	auipc	a2,0x4
ffffffffc020092e:	2e660613          	addi	a2,a2,742 # ffffffffc0204c10 <commands+0x5b0>
ffffffffc0200932:	0d400593          	li	a1,212
ffffffffc0200936:	00004517          	auipc	a0,0x4
ffffffffc020093a:	dca50513          	addi	a0,a0,-566 # ffffffffc0204700 <commands+0xa0>
ffffffffc020093e:	fc4ff0ef          	jal	ra,ffffffffc0200102 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200942:	00004517          	auipc	a0,0x4
ffffffffc0200946:	31e50513          	addi	a0,a0,798 # ffffffffc0204c60 <commands+0x600>
ffffffffc020094a:	b7b9                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc020094c:	00004517          	auipc	a0,0x4
ffffffffc0200950:	33450513          	addi	a0,a0,820 # ffffffffc0204c80 <commands+0x620>
ffffffffc0200954:	b791                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200956:	00004517          	auipc	a0,0x4
ffffffffc020095a:	34a50513          	addi	a0,a0,842 # ffffffffc0204ca0 <commands+0x640>
ffffffffc020095e:	bf2d                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200960:	00004517          	auipc	a0,0x4
ffffffffc0200964:	36050513          	addi	a0,a0,864 # ffffffffc0204cc0 <commands+0x660>
ffffffffc0200968:	bf05                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc020096a:	00004517          	auipc	a0,0x4
ffffffffc020096e:	37650513          	addi	a0,a0,886 # ffffffffc0204ce0 <commands+0x680>
ffffffffc0200972:	b71d                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200974:	00004517          	auipc	a0,0x4
ffffffffc0200978:	38450513          	addi	a0,a0,900 # ffffffffc0204cf8 <commands+0x698>
ffffffffc020097c:	f3eff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200980:	8522                	mv	a0,s0
ffffffffc0200982:	b73ff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc0200986:	84aa                	mv	s1,a0
ffffffffc0200988:	ee050fe3          	beqz	a0,ffffffffc0200886 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020098c:	8522                	mv	a0,s0
ffffffffc020098e:	dc1ff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200992:	86a6                	mv	a3,s1
ffffffffc0200994:	00004617          	auipc	a2,0x4
ffffffffc0200998:	27c60613          	addi	a2,a2,636 # ffffffffc0204c10 <commands+0x5b0>
ffffffffc020099c:	0ea00593          	li	a1,234
ffffffffc02009a0:	00004517          	auipc	a0,0x4
ffffffffc02009a4:	d6050513          	addi	a0,a0,-672 # ffffffffc0204700 <commands+0xa0>
ffffffffc02009a8:	f5aff0ef          	jal	ra,ffffffffc0200102 <__panic>
            print_trapframe(tf);
ffffffffc02009ac:	8522                	mv	a0,s0
}
ffffffffc02009ae:	6442                	ld	s0,16(sp)
ffffffffc02009b0:	60e2                	ld	ra,24(sp)
ffffffffc02009b2:	64a2                	ld	s1,8(sp)
ffffffffc02009b4:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc02009b6:	bb61                	j	ffffffffc020074e <print_trapframe>
                print_trapframe(tf);
ffffffffc02009b8:	8522                	mv	a0,s0
ffffffffc02009ba:	d95ff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009be:	86a6                	mv	a3,s1
ffffffffc02009c0:	00004617          	auipc	a2,0x4
ffffffffc02009c4:	25060613          	addi	a2,a2,592 # ffffffffc0204c10 <commands+0x5b0>
ffffffffc02009c8:	0f100593          	li	a1,241
ffffffffc02009cc:	00004517          	auipc	a0,0x4
ffffffffc02009d0:	d3450513          	addi	a0,a0,-716 # ffffffffc0204700 <commands+0xa0>
ffffffffc02009d4:	f2eff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02009d8 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc02009d8:	11853783          	ld	a5,280(a0)
ffffffffc02009dc:	0007c363          	bltz	a5,ffffffffc02009e2 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02009e0:	b5a5                	j	ffffffffc0200848 <exception_handler>
        interrupt_handler(tf);
ffffffffc02009e2:	b3f9                	j	ffffffffc02007b0 <interrupt_handler>
	...

ffffffffc02009f0 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc02009f0:	14011073          	csrw	sscratch,sp
ffffffffc02009f4:	712d                	addi	sp,sp,-288
ffffffffc02009f6:	e406                	sd	ra,8(sp)
ffffffffc02009f8:	ec0e                	sd	gp,24(sp)
ffffffffc02009fa:	f012                	sd	tp,32(sp)
ffffffffc02009fc:	f416                	sd	t0,40(sp)
ffffffffc02009fe:	f81a                	sd	t1,48(sp)
ffffffffc0200a00:	fc1e                	sd	t2,56(sp)
ffffffffc0200a02:	e0a2                	sd	s0,64(sp)
ffffffffc0200a04:	e4a6                	sd	s1,72(sp)
ffffffffc0200a06:	e8aa                	sd	a0,80(sp)
ffffffffc0200a08:	ecae                	sd	a1,88(sp)
ffffffffc0200a0a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a0c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a0e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a10:	fcbe                	sd	a5,120(sp)
ffffffffc0200a12:	e142                	sd	a6,128(sp)
ffffffffc0200a14:	e546                	sd	a7,136(sp)
ffffffffc0200a16:	e94a                	sd	s2,144(sp)
ffffffffc0200a18:	ed4e                	sd	s3,152(sp)
ffffffffc0200a1a:	f152                	sd	s4,160(sp)
ffffffffc0200a1c:	f556                	sd	s5,168(sp)
ffffffffc0200a1e:	f95a                	sd	s6,176(sp)
ffffffffc0200a20:	fd5e                	sd	s7,184(sp)
ffffffffc0200a22:	e1e2                	sd	s8,192(sp)
ffffffffc0200a24:	e5e6                	sd	s9,200(sp)
ffffffffc0200a26:	e9ea                	sd	s10,208(sp)
ffffffffc0200a28:	edee                	sd	s11,216(sp)
ffffffffc0200a2a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a2c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a2e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a30:	fdfe                	sd	t6,248(sp)
ffffffffc0200a32:	14002473          	csrr	s0,sscratch
ffffffffc0200a36:	100024f3          	csrr	s1,sstatus
ffffffffc0200a3a:	14102973          	csrr	s2,sepc
ffffffffc0200a3e:	143029f3          	csrr	s3,stval
ffffffffc0200a42:	14202a73          	csrr	s4,scause
ffffffffc0200a46:	e822                	sd	s0,16(sp)
ffffffffc0200a48:	e226                	sd	s1,256(sp)
ffffffffc0200a4a:	e64a                	sd	s2,264(sp)
ffffffffc0200a4c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a4e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200a50:	850a                	mv	a0,sp
    jal trap
ffffffffc0200a52:	f87ff0ef          	jal	ra,ffffffffc02009d8 <trap>

ffffffffc0200a56 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200a56:	6492                	ld	s1,256(sp)
ffffffffc0200a58:	6932                	ld	s2,264(sp)
ffffffffc0200a5a:	10049073          	csrw	sstatus,s1
ffffffffc0200a5e:	14191073          	csrw	sepc,s2
ffffffffc0200a62:	60a2                	ld	ra,8(sp)
ffffffffc0200a64:	61e2                	ld	gp,24(sp)
ffffffffc0200a66:	7202                	ld	tp,32(sp)
ffffffffc0200a68:	72a2                	ld	t0,40(sp)
ffffffffc0200a6a:	7342                	ld	t1,48(sp)
ffffffffc0200a6c:	73e2                	ld	t2,56(sp)
ffffffffc0200a6e:	6406                	ld	s0,64(sp)
ffffffffc0200a70:	64a6                	ld	s1,72(sp)
ffffffffc0200a72:	6546                	ld	a0,80(sp)
ffffffffc0200a74:	65e6                	ld	a1,88(sp)
ffffffffc0200a76:	7606                	ld	a2,96(sp)
ffffffffc0200a78:	76a6                	ld	a3,104(sp)
ffffffffc0200a7a:	7746                	ld	a4,112(sp)
ffffffffc0200a7c:	77e6                	ld	a5,120(sp)
ffffffffc0200a7e:	680a                	ld	a6,128(sp)
ffffffffc0200a80:	68aa                	ld	a7,136(sp)
ffffffffc0200a82:	694a                	ld	s2,144(sp)
ffffffffc0200a84:	69ea                	ld	s3,152(sp)
ffffffffc0200a86:	7a0a                	ld	s4,160(sp)
ffffffffc0200a88:	7aaa                	ld	s5,168(sp)
ffffffffc0200a8a:	7b4a                	ld	s6,176(sp)
ffffffffc0200a8c:	7bea                	ld	s7,184(sp)
ffffffffc0200a8e:	6c0e                	ld	s8,192(sp)
ffffffffc0200a90:	6cae                	ld	s9,200(sp)
ffffffffc0200a92:	6d4e                	ld	s10,208(sp)
ffffffffc0200a94:	6dee                	ld	s11,216(sp)
ffffffffc0200a96:	7e0e                	ld	t3,224(sp)
ffffffffc0200a98:	7eae                	ld	t4,232(sp)
ffffffffc0200a9a:	7f4e                	ld	t5,240(sp)
ffffffffc0200a9c:	7fee                	ld	t6,248(sp)
ffffffffc0200a9e:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200aa0:	10200073          	sret
	...

ffffffffc0200ab0 <_lru_init>:
 * (5) _lru_init: 初始化LRU算法结构（可选）
 */
static int
_lru_init(void) {
    return 0;
}
ffffffffc0200ab0:	4501                	li	a0,0
ffffffffc0200ab2:	8082                	ret

ffffffffc0200ab4 <_lru_set_unswappable>:
 * (6) _lru_set_unswappable: 将页面设置为不可交换
 */
static int
_lru_set_unswappable(struct mm_struct *mm, uintptr_t addr) {
    return 0;
}
ffffffffc0200ab4:	4501                	li	a0,0
ffffffffc0200ab6:	8082                	ret

ffffffffc0200ab8 <_lru_tick_event>:
 * (7) _lru_tick_event: 处理周期性事件（可选）
 */
static int
_lru_tick_event(struct mm_struct *mm) {
    return 0;
}
ffffffffc0200ab8:	4501                	li	a0,0
ffffffffc0200aba:	8082                	ret

ffffffffc0200abc <_lru_check_swap>:
_lru_check_swap(void) {
ffffffffc0200abc:	1141                	addi	sp,sp,-16
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0200abe:	4731                	li	a4,12
_lru_check_swap(void) {
ffffffffc0200ac0:	e406                	sd	ra,8(sp)
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0200ac2:	678d                	lui	a5,0x3
ffffffffc0200ac4:	00e78023          	sb	a4,0(a5) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num == 4);
ffffffffc0200ac8:	00011697          	auipc	a3,0x11
ffffffffc0200acc:	a586a683          	lw	a3,-1448(a3) # ffffffffc0211520 <pgfault_num>
ffffffffc0200ad0:	4711                	li	a4,4
ffffffffc0200ad2:	0ae69363          	bne	a3,a4,ffffffffc0200b78 <_lru_check_swap+0xbc>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0200ad6:	6705                	lui	a4,0x1
ffffffffc0200ad8:	4629                	li	a2,10
ffffffffc0200ada:	00011797          	auipc	a5,0x11
ffffffffc0200ade:	a4678793          	addi	a5,a5,-1466 # ffffffffc0211520 <pgfault_num>
ffffffffc0200ae2:	00c70023          	sb	a2,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
    assert(pgfault_num == 4);
ffffffffc0200ae6:	4398                	lw	a4,0(a5)
ffffffffc0200ae8:	2701                	sext.w	a4,a4
ffffffffc0200aea:	20d71763          	bne	a4,a3,ffffffffc0200cf8 <_lru_check_swap+0x23c>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0200aee:	6691                	lui	a3,0x4
ffffffffc0200af0:	4635                	li	a2,13
ffffffffc0200af2:	00c68023          	sb	a2,0(a3) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num == 4);
ffffffffc0200af6:	4394                	lw	a3,0(a5)
ffffffffc0200af8:	2681                	sext.w	a3,a3
ffffffffc0200afa:	1ce69f63          	bne	a3,a4,ffffffffc0200cd8 <_lru_check_swap+0x21c>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0200afe:	6709                	lui	a4,0x2
ffffffffc0200b00:	462d                	li	a2,11
ffffffffc0200b02:	00c70023          	sb	a2,0(a4) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num == 4);
ffffffffc0200b06:	4398                	lw	a4,0(a5)
ffffffffc0200b08:	2701                	sext.w	a4,a4
ffffffffc0200b0a:	1ad71763          	bne	a4,a3,ffffffffc0200cb8 <_lru_check_swap+0x1fc>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0200b0e:	6715                	lui	a4,0x5
ffffffffc0200b10:	46b9                	li	a3,14
ffffffffc0200b12:	00d70023          	sb	a3,0(a4) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num == 5);
ffffffffc0200b16:	4398                	lw	a4,0(a5)
ffffffffc0200b18:	4695                	li	a3,5
ffffffffc0200b1a:	2701                	sext.w	a4,a4
ffffffffc0200b1c:	16d71e63          	bne	a4,a3,ffffffffc0200c98 <_lru_check_swap+0x1dc>
    assert(pgfault_num == 5);
ffffffffc0200b20:	4394                	lw	a3,0(a5)
ffffffffc0200b22:	2681                	sext.w	a3,a3
ffffffffc0200b24:	14e69a63          	bne	a3,a4,ffffffffc0200c78 <_lru_check_swap+0x1bc>
    assert(pgfault_num == 5);
ffffffffc0200b28:	4398                	lw	a4,0(a5)
ffffffffc0200b2a:	2701                	sext.w	a4,a4
ffffffffc0200b2c:	12d71663          	bne	a4,a3,ffffffffc0200c58 <_lru_check_swap+0x19c>
    assert(pgfault_num == 5);
ffffffffc0200b30:	4394                	lw	a3,0(a5)
ffffffffc0200b32:	2681                	sext.w	a3,a3
ffffffffc0200b34:	10e69263          	bne	a3,a4,ffffffffc0200c38 <_lru_check_swap+0x17c>
    assert(pgfault_num == 5);
ffffffffc0200b38:	4398                	lw	a4,0(a5)
ffffffffc0200b3a:	2701                	sext.w	a4,a4
ffffffffc0200b3c:	0cd71e63          	bne	a4,a3,ffffffffc0200c18 <_lru_check_swap+0x15c>
    assert(pgfault_num == 5);
ffffffffc0200b40:	4394                	lw	a3,0(a5)
ffffffffc0200b42:	2681                	sext.w	a3,a3
ffffffffc0200b44:	0ae69a63          	bne	a3,a4,ffffffffc0200bf8 <_lru_check_swap+0x13c>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0200b48:	6715                	lui	a4,0x5
ffffffffc0200b4a:	46b9                	li	a3,14
ffffffffc0200b4c:	00d70023          	sb	a3,0(a4) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num == 5);
ffffffffc0200b50:	4398                	lw	a4,0(a5)
ffffffffc0200b52:	4695                	li	a3,5
ffffffffc0200b54:	2701                	sext.w	a4,a4
ffffffffc0200b56:	08d71163          	bne	a4,a3,ffffffffc0200bd8 <_lru_check_swap+0x11c>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0200b5a:	6705                	lui	a4,0x1
ffffffffc0200b5c:	00074683          	lbu	a3,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0200b60:	4729                	li	a4,10
ffffffffc0200b62:	04e69b63          	bne	a3,a4,ffffffffc0200bb8 <_lru_check_swap+0xfc>
    assert(pgfault_num == 6);
ffffffffc0200b66:	439c                	lw	a5,0(a5)
ffffffffc0200b68:	4719                	li	a4,6
ffffffffc0200b6a:	2781                	sext.w	a5,a5
ffffffffc0200b6c:	02e79663          	bne	a5,a4,ffffffffc0200b98 <_lru_check_swap+0xdc>
}
ffffffffc0200b70:	60a2                	ld	ra,8(sp)
ffffffffc0200b72:	4501                	li	a0,0
ffffffffc0200b74:	0141                	addi	sp,sp,16
ffffffffc0200b76:	8082                	ret
    assert(pgfault_num == 4);
ffffffffc0200b78:	00004697          	auipc	a3,0x4
ffffffffc0200b7c:	1f068693          	addi	a3,a3,496 # ffffffffc0204d68 <commands+0x708>
ffffffffc0200b80:	00004617          	auipc	a2,0x4
ffffffffc0200b84:	20060613          	addi	a2,a2,512 # ffffffffc0204d80 <commands+0x720>
ffffffffc0200b88:	06f00593          	li	a1,111
ffffffffc0200b8c:	00004517          	auipc	a0,0x4
ffffffffc0200b90:	20c50513          	addi	a0,a0,524 # ffffffffc0204d98 <commands+0x738>
ffffffffc0200b94:	d6eff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num == 6);
ffffffffc0200b98:	00004697          	auipc	a3,0x4
ffffffffc0200b9c:	25868693          	addi	a3,a3,600 # ffffffffc0204df0 <commands+0x790>
ffffffffc0200ba0:	00004617          	auipc	a2,0x4
ffffffffc0200ba4:	1e060613          	addi	a2,a2,480 # ffffffffc0204d80 <commands+0x720>
ffffffffc0200ba8:	08600593          	li	a1,134
ffffffffc0200bac:	00004517          	auipc	a0,0x4
ffffffffc0200bb0:	1ec50513          	addi	a0,a0,492 # ffffffffc0204d98 <commands+0x738>
ffffffffc0200bb4:	d4eff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0200bb8:	00004697          	auipc	a3,0x4
ffffffffc0200bbc:	21068693          	addi	a3,a3,528 # ffffffffc0204dc8 <commands+0x768>
ffffffffc0200bc0:	00004617          	auipc	a2,0x4
ffffffffc0200bc4:	1c060613          	addi	a2,a2,448 # ffffffffc0204d80 <commands+0x720>
ffffffffc0200bc8:	08400593          	li	a1,132
ffffffffc0200bcc:	00004517          	auipc	a0,0x4
ffffffffc0200bd0:	1cc50513          	addi	a0,a0,460 # ffffffffc0204d98 <commands+0x738>
ffffffffc0200bd4:	d2eff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num == 5);
ffffffffc0200bd8:	00004697          	auipc	a3,0x4
ffffffffc0200bdc:	1d868693          	addi	a3,a3,472 # ffffffffc0204db0 <commands+0x750>
ffffffffc0200be0:	00004617          	auipc	a2,0x4
ffffffffc0200be4:	1a060613          	addi	a2,a2,416 # ffffffffc0204d80 <commands+0x720>
ffffffffc0200be8:	08300593          	li	a1,131
ffffffffc0200bec:	00004517          	auipc	a0,0x4
ffffffffc0200bf0:	1ac50513          	addi	a0,a0,428 # ffffffffc0204d98 <commands+0x738>
ffffffffc0200bf4:	d0eff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num == 5);
ffffffffc0200bf8:	00004697          	auipc	a3,0x4
ffffffffc0200bfc:	1b868693          	addi	a3,a3,440 # ffffffffc0204db0 <commands+0x750>
ffffffffc0200c00:	00004617          	auipc	a2,0x4
ffffffffc0200c04:	18060613          	addi	a2,a2,384 # ffffffffc0204d80 <commands+0x720>
ffffffffc0200c08:	08100593          	li	a1,129
ffffffffc0200c0c:	00004517          	auipc	a0,0x4
ffffffffc0200c10:	18c50513          	addi	a0,a0,396 # ffffffffc0204d98 <commands+0x738>
ffffffffc0200c14:	ceeff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num == 5);
ffffffffc0200c18:	00004697          	auipc	a3,0x4
ffffffffc0200c1c:	19868693          	addi	a3,a3,408 # ffffffffc0204db0 <commands+0x750>
ffffffffc0200c20:	00004617          	auipc	a2,0x4
ffffffffc0200c24:	16060613          	addi	a2,a2,352 # ffffffffc0204d80 <commands+0x720>
ffffffffc0200c28:	07f00593          	li	a1,127
ffffffffc0200c2c:	00004517          	auipc	a0,0x4
ffffffffc0200c30:	16c50513          	addi	a0,a0,364 # ffffffffc0204d98 <commands+0x738>
ffffffffc0200c34:	cceff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num == 5);
ffffffffc0200c38:	00004697          	auipc	a3,0x4
ffffffffc0200c3c:	17868693          	addi	a3,a3,376 # ffffffffc0204db0 <commands+0x750>
ffffffffc0200c40:	00004617          	auipc	a2,0x4
ffffffffc0200c44:	14060613          	addi	a2,a2,320 # ffffffffc0204d80 <commands+0x720>
ffffffffc0200c48:	07d00593          	li	a1,125
ffffffffc0200c4c:	00004517          	auipc	a0,0x4
ffffffffc0200c50:	14c50513          	addi	a0,a0,332 # ffffffffc0204d98 <commands+0x738>
ffffffffc0200c54:	caeff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num == 5);
ffffffffc0200c58:	00004697          	auipc	a3,0x4
ffffffffc0200c5c:	15868693          	addi	a3,a3,344 # ffffffffc0204db0 <commands+0x750>
ffffffffc0200c60:	00004617          	auipc	a2,0x4
ffffffffc0200c64:	12060613          	addi	a2,a2,288 # ffffffffc0204d80 <commands+0x720>
ffffffffc0200c68:	07b00593          	li	a1,123
ffffffffc0200c6c:	00004517          	auipc	a0,0x4
ffffffffc0200c70:	12c50513          	addi	a0,a0,300 # ffffffffc0204d98 <commands+0x738>
ffffffffc0200c74:	c8eff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num == 5);
ffffffffc0200c78:	00004697          	auipc	a3,0x4
ffffffffc0200c7c:	13868693          	addi	a3,a3,312 # ffffffffc0204db0 <commands+0x750>
ffffffffc0200c80:	00004617          	auipc	a2,0x4
ffffffffc0200c84:	10060613          	addi	a2,a2,256 # ffffffffc0204d80 <commands+0x720>
ffffffffc0200c88:	07900593          	li	a1,121
ffffffffc0200c8c:	00004517          	auipc	a0,0x4
ffffffffc0200c90:	10c50513          	addi	a0,a0,268 # ffffffffc0204d98 <commands+0x738>
ffffffffc0200c94:	c6eff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num == 5);
ffffffffc0200c98:	00004697          	auipc	a3,0x4
ffffffffc0200c9c:	11868693          	addi	a3,a3,280 # ffffffffc0204db0 <commands+0x750>
ffffffffc0200ca0:	00004617          	auipc	a2,0x4
ffffffffc0200ca4:	0e060613          	addi	a2,a2,224 # ffffffffc0204d80 <commands+0x720>
ffffffffc0200ca8:	07700593          	li	a1,119
ffffffffc0200cac:	00004517          	auipc	a0,0x4
ffffffffc0200cb0:	0ec50513          	addi	a0,a0,236 # ffffffffc0204d98 <commands+0x738>
ffffffffc0200cb4:	c4eff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num == 4);
ffffffffc0200cb8:	00004697          	auipc	a3,0x4
ffffffffc0200cbc:	0b068693          	addi	a3,a3,176 # ffffffffc0204d68 <commands+0x708>
ffffffffc0200cc0:	00004617          	auipc	a2,0x4
ffffffffc0200cc4:	0c060613          	addi	a2,a2,192 # ffffffffc0204d80 <commands+0x720>
ffffffffc0200cc8:	07500593          	li	a1,117
ffffffffc0200ccc:	00004517          	auipc	a0,0x4
ffffffffc0200cd0:	0cc50513          	addi	a0,a0,204 # ffffffffc0204d98 <commands+0x738>
ffffffffc0200cd4:	c2eff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num == 4);
ffffffffc0200cd8:	00004697          	auipc	a3,0x4
ffffffffc0200cdc:	09068693          	addi	a3,a3,144 # ffffffffc0204d68 <commands+0x708>
ffffffffc0200ce0:	00004617          	auipc	a2,0x4
ffffffffc0200ce4:	0a060613          	addi	a2,a2,160 # ffffffffc0204d80 <commands+0x720>
ffffffffc0200ce8:	07300593          	li	a1,115
ffffffffc0200cec:	00004517          	auipc	a0,0x4
ffffffffc0200cf0:	0ac50513          	addi	a0,a0,172 # ffffffffc0204d98 <commands+0x738>
ffffffffc0200cf4:	c0eff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num == 4);
ffffffffc0200cf8:	00004697          	auipc	a3,0x4
ffffffffc0200cfc:	07068693          	addi	a3,a3,112 # ffffffffc0204d68 <commands+0x708>
ffffffffc0200d00:	00004617          	auipc	a2,0x4
ffffffffc0200d04:	08060613          	addi	a2,a2,128 # ffffffffc0204d80 <commands+0x720>
ffffffffc0200d08:	07100593          	li	a1,113
ffffffffc0200d0c:	00004517          	auipc	a0,0x4
ffffffffc0200d10:	08c50513          	addi	a0,a0,140 # ffffffffc0204d98 <commands+0x738>
ffffffffc0200d14:	beeff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200d18 <_lru_init_mm>:
_lru_init_mm(struct mm_struct *mm) {
ffffffffc0200d18:	1141                	addi	sp,sp,-16
ffffffffc0200d1a:	e406                	sd	ra,8(sp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200d1c:	00010597          	auipc	a1,0x10
ffffffffc0200d20:	32458593          	addi	a1,a1,804 # ffffffffc0211040 <pra_list_head>
    mm->sm_priv = &pra_list_head;  // 将mm的私有字段指向LRU链表头
ffffffffc0200d24:	f50c                	sd	a1,40(a0)
    cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
ffffffffc0200d26:	00004517          	auipc	a0,0x4
ffffffffc0200d2a:	0e250513          	addi	a0,a0,226 # ffffffffc0204e08 <commands+0x7a8>
ffffffffc0200d2e:	e58c                	sd	a1,8(a1)
ffffffffc0200d30:	e18c                	sd	a1,0(a1)
    curr_ptr = &pra_list_head;  // curr_ptr跟踪当前页面替换位置
ffffffffc0200d32:	00010797          	auipc	a5,0x10
ffffffffc0200d36:	7cb7bf23          	sd	a1,2014(a5) # ffffffffc0211510 <curr_ptr>
    cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
ffffffffc0200d3a:	b80ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0200d3e:	60a2                	ld	ra,8(sp)
ffffffffc0200d40:	4501                	li	a0,0
ffffffffc0200d42:	0141                	addi	sp,sp,16
ffffffffc0200d44:	8082                	ret

ffffffffc0200d46 <_lru_map_swappable>:
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0200d46:	00010797          	auipc	a5,0x10
ffffffffc0200d4a:	7ca7b783          	ld	a5,1994(a5) # ffffffffc0211510 <curr_ptr>
ffffffffc0200d4e:	c3b1                	beqz	a5,ffffffffc0200d92 <_lru_map_swappable+0x4c>
    list_entry_t *head = (list_entry_t*) mm->sm_priv;
ffffffffc0200d50:	7518                	ld	a4,40(a0)
ffffffffc0200d52:	03060693          	addi	a3,a2,48
    list_entry_t *temp = head->next;
ffffffffc0200d56:	670c                	ld	a1,8(a4)
    while(temp != head) //
ffffffffc0200d58:	00b70b63          	beq	a4,a1,ffffffffc0200d6e <_lru_map_swappable+0x28>
        if(entry == temp)
ffffffffc0200d5c:	00b68f63          	beq	a3,a1,ffffffffc0200d7a <_lru_map_swappable+0x34>
ffffffffc0200d60:	87ae                	mv	a5,a1
ffffffffc0200d62:	a019                	j	ffffffffc0200d68 <_lru_map_swappable+0x22>
ffffffffc0200d64:	00f68c63          	beq	a3,a5,ffffffffc0200d7c <_lru_map_swappable+0x36>
        temp = temp->next;
ffffffffc0200d68:	679c                	ld	a5,8(a5)
    while(temp != head) //
ffffffffc0200d6a:	fef71de3          	bne	a4,a5,ffffffffc0200d64 <_lru_map_swappable+0x1e>
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200d6e:	e194                	sd	a3,0(a1)
ffffffffc0200d70:	e714                	sd	a3,8(a4)
    elm->next = next;
ffffffffc0200d72:	fe0c                	sd	a1,56(a2)
    elm->prev = prev;
ffffffffc0200d74:	fa18                	sd	a4,48(a2)
}
ffffffffc0200d76:	4501                	li	a0,0
ffffffffc0200d78:	8082                	ret
        if(entry == temp)
ffffffffc0200d7a:	87b6                	mv	a5,a3
    __list_del(listelm->prev, listelm->next);
ffffffffc0200d7c:	6388                	ld	a0,0(a5)
ffffffffc0200d7e:	679c                	ld	a5,8(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200d80:	e51c                	sd	a5,8(a0)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200d82:	670c                	ld	a1,8(a4)
    next->prev = prev;
ffffffffc0200d84:	e388                	sd	a0,0(a5)
}
ffffffffc0200d86:	4501                	li	a0,0
    prev->next = next->prev = elm;
ffffffffc0200d88:	e194                	sd	a3,0(a1)
ffffffffc0200d8a:	e714                	sd	a3,8(a4)
    elm->next = next;
ffffffffc0200d8c:	fe0c                	sd	a1,56(a2)
    elm->prev = prev;
ffffffffc0200d8e:	fa18                	sd	a4,48(a2)
ffffffffc0200d90:	8082                	ret
_lru_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in) {
ffffffffc0200d92:	1141                	addi	sp,sp,-16
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0200d94:	00004697          	auipc	a3,0x4
ffffffffc0200d98:	09c68693          	addi	a3,a3,156 # ffffffffc0204e30 <commands+0x7d0>
ffffffffc0200d9c:	00004617          	auipc	a2,0x4
ffffffffc0200da0:	fe460613          	addi	a2,a2,-28 # ffffffffc0204d80 <commands+0x720>
ffffffffc0200da4:	02000593          	li	a1,32
ffffffffc0200da8:	00004517          	auipc	a0,0x4
ffffffffc0200dac:	ff050513          	addi	a0,a0,-16 # ffffffffc0204d98 <commands+0x738>
_lru_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in) {
ffffffffc0200db0:	e406                	sd	ra,8(sp)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0200db2:	b50ff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200db6 <_lru_swap_out_victim>:
    list_entry_t *head = (list_entry_t*) mm->sm_priv;
ffffffffc0200db6:	751c                	ld	a5,40(a0)
_lru_swap_out_victim(struct mm_struct *mm, struct Page **ptr_page, int in_tick) {
ffffffffc0200db8:	1101                	addi	sp,sp,-32
ffffffffc0200dba:	ec06                	sd	ra,24(sp)
ffffffffc0200dbc:	e822                	sd	s0,16(sp)
ffffffffc0200dbe:	e426                	sd	s1,8(sp)
    assert(head != NULL);
ffffffffc0200dc0:	cb85                	beqz	a5,ffffffffc0200df0 <_lru_swap_out_victim+0x3a>
    assert(in_tick == 0);
ffffffffc0200dc2:	e639                	bnez	a2,ffffffffc0200e10 <_lru_swap_out_victim+0x5a>
    return listelm->prev;
ffffffffc0200dc4:	6380                	ld	s0,0(a5)
ffffffffc0200dc6:	84ae                	mv	s1,a1
    cprintf("curr_ptr %p\n", victim_entry);
ffffffffc0200dc8:	00004517          	auipc	a0,0x4
ffffffffc0200dcc:	0b050513          	addi	a0,a0,176 # ffffffffc0204e78 <commands+0x818>
ffffffffc0200dd0:	85a2                	mv	a1,s0
ffffffffc0200dd2:	ae8ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200dd6:	6018                	ld	a4,0(s0)
ffffffffc0200dd8:	641c                	ld	a5,8(s0)
    struct Page *victim_page = le2page(victim_entry, pra_page_link);
ffffffffc0200dda:	fd040413          	addi	s0,s0,-48
}
ffffffffc0200dde:	60e2                	ld	ra,24(sp)
    prev->next = next;
ffffffffc0200de0:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200de2:	e398                	sd	a4,0(a5)
    *ptr_page = victim_page;
ffffffffc0200de4:	e080                	sd	s0,0(s1)
}
ffffffffc0200de6:	6442                	ld	s0,16(sp)
ffffffffc0200de8:	64a2                	ld	s1,8(sp)
ffffffffc0200dea:	4501                	li	a0,0
ffffffffc0200dec:	6105                	addi	sp,sp,32
ffffffffc0200dee:	8082                	ret
    assert(head != NULL);
ffffffffc0200df0:	00004697          	auipc	a3,0x4
ffffffffc0200df4:	06868693          	addi	a3,a3,104 # ffffffffc0204e58 <commands+0x7f8>
ffffffffc0200df8:	00004617          	auipc	a2,0x4
ffffffffc0200dfc:	f8860613          	addi	a2,a2,-120 # ffffffffc0204d80 <commands+0x720>
ffffffffc0200e00:	03900593          	li	a1,57
ffffffffc0200e04:	00004517          	auipc	a0,0x4
ffffffffc0200e08:	f9450513          	addi	a0,a0,-108 # ffffffffc0204d98 <commands+0x738>
ffffffffc0200e0c:	af6ff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(in_tick == 0);
ffffffffc0200e10:	00004697          	auipc	a3,0x4
ffffffffc0200e14:	05868693          	addi	a3,a3,88 # ffffffffc0204e68 <commands+0x808>
ffffffffc0200e18:	00004617          	auipc	a2,0x4
ffffffffc0200e1c:	f6860613          	addi	a2,a2,-152 # ffffffffc0204d80 <commands+0x720>
ffffffffc0200e20:	03a00593          	li	a1,58
ffffffffc0200e24:	00004517          	auipc	a0,0x4
ffffffffc0200e28:	f7450513          	addi	a0,a0,-140 # ffffffffc0204d98 <commands+0x738>
ffffffffc0200e2c:	ad6ff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200e30 <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200e30:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0200e32:	00004697          	auipc	a3,0x4
ffffffffc0200e36:	06e68693          	addi	a3,a3,110 # ffffffffc0204ea0 <commands+0x840>
ffffffffc0200e3a:	00004617          	auipc	a2,0x4
ffffffffc0200e3e:	f4660613          	addi	a2,a2,-186 # ffffffffc0204d80 <commands+0x720>
ffffffffc0200e42:	07d00593          	li	a1,125
ffffffffc0200e46:	00004517          	auipc	a0,0x4
ffffffffc0200e4a:	07a50513          	addi	a0,a0,122 # ffffffffc0204ec0 <commands+0x860>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200e4e:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0200e50:	ab2ff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200e54 <mm_create>:
mm_create(void) {
ffffffffc0200e54:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200e56:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0200e5a:	e022                	sd	s0,0(sp)
ffffffffc0200e5c:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200e5e:	531020ef          	jal	ra,ffffffffc0203b8e <kmalloc>
ffffffffc0200e62:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200e64:	c105                	beqz	a0,ffffffffc0200e84 <mm_create+0x30>
    elm->prev = elm->next = elm;
ffffffffc0200e66:	e408                	sd	a0,8(s0)
ffffffffc0200e68:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0200e6a:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200e6e:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200e72:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200e76:	00010797          	auipc	a5,0x10
ffffffffc0200e7a:	6c27a783          	lw	a5,1730(a5) # ffffffffc0211538 <swap_init_ok>
ffffffffc0200e7e:	eb81                	bnez	a5,ffffffffc0200e8e <mm_create+0x3a>
        else mm->sm_priv = NULL;
ffffffffc0200e80:	02053423          	sd	zero,40(a0)
}
ffffffffc0200e84:	60a2                	ld	ra,8(sp)
ffffffffc0200e86:	8522                	mv	a0,s0
ffffffffc0200e88:	6402                	ld	s0,0(sp)
ffffffffc0200e8a:	0141                	addi	sp,sp,16
ffffffffc0200e8c:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200e8e:	693000ef          	jal	ra,ffffffffc0201d20 <swap_init_mm>
}
ffffffffc0200e92:	60a2                	ld	ra,8(sp)
ffffffffc0200e94:	8522                	mv	a0,s0
ffffffffc0200e96:	6402                	ld	s0,0(sp)
ffffffffc0200e98:	0141                	addi	sp,sp,16
ffffffffc0200e9a:	8082                	ret

ffffffffc0200e9c <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0200e9c:	1101                	addi	sp,sp,-32
ffffffffc0200e9e:	e04a                	sd	s2,0(sp)
ffffffffc0200ea0:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200ea2:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0200ea6:	e822                	sd	s0,16(sp)
ffffffffc0200ea8:	e426                	sd	s1,8(sp)
ffffffffc0200eaa:	ec06                	sd	ra,24(sp)
ffffffffc0200eac:	84ae                	mv	s1,a1
ffffffffc0200eae:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200eb0:	4df020ef          	jal	ra,ffffffffc0203b8e <kmalloc>
    if (vma != NULL) {
ffffffffc0200eb4:	c509                	beqz	a0,ffffffffc0200ebe <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0200eb6:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200eba:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200ebc:	ed00                	sd	s0,24(a0)
}
ffffffffc0200ebe:	60e2                	ld	ra,24(sp)
ffffffffc0200ec0:	6442                	ld	s0,16(sp)
ffffffffc0200ec2:	64a2                	ld	s1,8(sp)
ffffffffc0200ec4:	6902                	ld	s2,0(sp)
ffffffffc0200ec6:	6105                	addi	sp,sp,32
ffffffffc0200ec8:	8082                	ret

ffffffffc0200eca <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0200eca:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0200ecc:	c505                	beqz	a0,ffffffffc0200ef4 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0200ece:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200ed0:	c501                	beqz	a0,ffffffffc0200ed8 <find_vma+0xe>
ffffffffc0200ed2:	651c                	ld	a5,8(a0)
ffffffffc0200ed4:	02f5f263          	bgeu	a1,a5,ffffffffc0200ef8 <find_vma+0x2e>
    return listelm->next;
ffffffffc0200ed8:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0200eda:	00f68d63          	beq	a3,a5,ffffffffc0200ef4 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0200ede:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200ee2:	00e5e663          	bltu	a1,a4,ffffffffc0200eee <find_vma+0x24>
ffffffffc0200ee6:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200eea:	00e5ec63          	bltu	a1,a4,ffffffffc0200f02 <find_vma+0x38>
ffffffffc0200eee:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0200ef0:	fef697e3          	bne	a3,a5,ffffffffc0200ede <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0200ef4:	4501                	li	a0,0
}
ffffffffc0200ef6:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200ef8:	691c                	ld	a5,16(a0)
ffffffffc0200efa:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0200ed8 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0200efe:	ea88                	sd	a0,16(a3)
ffffffffc0200f00:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0200f02:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0200f06:	ea88                	sd	a0,16(a3)
ffffffffc0200f08:	8082                	ret

ffffffffc0200f0a <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200f0a:	6590                	ld	a2,8(a1)
ffffffffc0200f0c:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0200f10:	1141                	addi	sp,sp,-16
ffffffffc0200f12:	e406                	sd	ra,8(sp)
ffffffffc0200f14:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200f16:	01066763          	bltu	a2,a6,ffffffffc0200f24 <insert_vma_struct+0x1a>
ffffffffc0200f1a:	a085                	j	ffffffffc0200f7a <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200f1c:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200f20:	04e66863          	bltu	a2,a4,ffffffffc0200f70 <insert_vma_struct+0x66>
ffffffffc0200f24:	86be                	mv	a3,a5
ffffffffc0200f26:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0200f28:	fef51ae3          	bne	a0,a5,ffffffffc0200f1c <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0200f2c:	02a68463          	beq	a3,a0,ffffffffc0200f54 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0200f30:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200f34:	fe86b883          	ld	a7,-24(a3)
ffffffffc0200f38:	08e8f163          	bgeu	a7,a4,ffffffffc0200fba <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200f3c:	04e66f63          	bltu	a2,a4,ffffffffc0200f9a <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc0200f40:	00f50a63          	beq	a0,a5,ffffffffc0200f54 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200f44:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200f48:	05076963          	bltu	a4,a6,ffffffffc0200f9a <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0200f4c:	ff07b603          	ld	a2,-16(a5)
ffffffffc0200f50:	02c77363          	bgeu	a4,a2,ffffffffc0200f76 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0200f54:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0200f56:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0200f58:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0200f5c:	e390                	sd	a2,0(a5)
ffffffffc0200f5e:	e690                	sd	a2,8(a3)
}
ffffffffc0200f60:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0200f62:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0200f64:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0200f66:	0017079b          	addiw	a5,a4,1
ffffffffc0200f6a:	d11c                	sw	a5,32(a0)
}
ffffffffc0200f6c:	0141                	addi	sp,sp,16
ffffffffc0200f6e:	8082                	ret
    if (le_prev != list) {
ffffffffc0200f70:	fca690e3          	bne	a3,a0,ffffffffc0200f30 <insert_vma_struct+0x26>
ffffffffc0200f74:	bfd1                	j	ffffffffc0200f48 <insert_vma_struct+0x3e>
ffffffffc0200f76:	ebbff0ef          	jal	ra,ffffffffc0200e30 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200f7a:	00004697          	auipc	a3,0x4
ffffffffc0200f7e:	f5668693          	addi	a3,a3,-170 # ffffffffc0204ed0 <commands+0x870>
ffffffffc0200f82:	00004617          	auipc	a2,0x4
ffffffffc0200f86:	dfe60613          	addi	a2,a2,-514 # ffffffffc0204d80 <commands+0x720>
ffffffffc0200f8a:	08400593          	li	a1,132
ffffffffc0200f8e:	00004517          	auipc	a0,0x4
ffffffffc0200f92:	f3250513          	addi	a0,a0,-206 # ffffffffc0204ec0 <commands+0x860>
ffffffffc0200f96:	96cff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200f9a:	00004697          	auipc	a3,0x4
ffffffffc0200f9e:	f7668693          	addi	a3,a3,-138 # ffffffffc0204f10 <commands+0x8b0>
ffffffffc0200fa2:	00004617          	auipc	a2,0x4
ffffffffc0200fa6:	dde60613          	addi	a2,a2,-546 # ffffffffc0204d80 <commands+0x720>
ffffffffc0200faa:	07c00593          	li	a1,124
ffffffffc0200fae:	00004517          	auipc	a0,0x4
ffffffffc0200fb2:	f1250513          	addi	a0,a0,-238 # ffffffffc0204ec0 <commands+0x860>
ffffffffc0200fb6:	94cff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200fba:	00004697          	auipc	a3,0x4
ffffffffc0200fbe:	f3668693          	addi	a3,a3,-202 # ffffffffc0204ef0 <commands+0x890>
ffffffffc0200fc2:	00004617          	auipc	a2,0x4
ffffffffc0200fc6:	dbe60613          	addi	a2,a2,-578 # ffffffffc0204d80 <commands+0x720>
ffffffffc0200fca:	07b00593          	li	a1,123
ffffffffc0200fce:	00004517          	auipc	a0,0x4
ffffffffc0200fd2:	ef250513          	addi	a0,a0,-270 # ffffffffc0204ec0 <commands+0x860>
ffffffffc0200fd6:	92cff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200fda <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0200fda:	1141                	addi	sp,sp,-16
ffffffffc0200fdc:	e022                	sd	s0,0(sp)
ffffffffc0200fde:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0200fe0:	6508                	ld	a0,8(a0)
ffffffffc0200fe2:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0200fe4:	00a40e63          	beq	s0,a0,ffffffffc0201000 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200fe8:	6118                	ld	a4,0(a0)
ffffffffc0200fea:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0200fec:	03000593          	li	a1,48
ffffffffc0200ff0:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0200ff2:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200ff4:	e398                	sd	a4,0(a5)
ffffffffc0200ff6:	453020ef          	jal	ra,ffffffffc0203c48 <kfree>
    return listelm->next;
ffffffffc0200ffa:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0200ffc:	fea416e3          	bne	s0,a0,ffffffffc0200fe8 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0201000:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0201002:	6402                	ld	s0,0(sp)
ffffffffc0201004:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0201006:	03000593          	li	a1,48
}
ffffffffc020100a:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc020100c:	43d0206f          	j	ffffffffc0203c48 <kfree>

ffffffffc0201010 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0201010:	715d                	addi	sp,sp,-80
ffffffffc0201012:	e486                	sd	ra,72(sp)
ffffffffc0201014:	f44e                	sd	s3,40(sp)
ffffffffc0201016:	f052                	sd	s4,32(sp)
ffffffffc0201018:	e0a2                	sd	s0,64(sp)
ffffffffc020101a:	fc26                	sd	s1,56(sp)
ffffffffc020101c:	f84a                	sd	s2,48(sp)
ffffffffc020101e:	ec56                	sd	s5,24(sp)
ffffffffc0201020:	e85a                	sd	s6,16(sp)
ffffffffc0201022:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0201024:	285010ef          	jal	ra,ffffffffc0202aa8 <nr_free_pages>
ffffffffc0201028:	89aa                	mv	s3,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020102a:	27f010ef          	jal	ra,ffffffffc0202aa8 <nr_free_pages>
ffffffffc020102e:	8a2a                	mv	s4,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201030:	03000513          	li	a0,48
ffffffffc0201034:	35b020ef          	jal	ra,ffffffffc0203b8e <kmalloc>
    if (mm != NULL) {
ffffffffc0201038:	56050863          	beqz	a0,ffffffffc02015a8 <vmm_init+0x598>
    elm->prev = elm->next = elm;
ffffffffc020103c:	e508                	sd	a0,8(a0)
ffffffffc020103e:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0201040:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0201044:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0201048:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020104c:	00010797          	auipc	a5,0x10
ffffffffc0201050:	4ec7a783          	lw	a5,1260(a5) # ffffffffc0211538 <swap_init_ok>
ffffffffc0201054:	84aa                	mv	s1,a0
ffffffffc0201056:	e7b9                	bnez	a5,ffffffffc02010a4 <vmm_init+0x94>
        else mm->sm_priv = NULL;
ffffffffc0201058:	02053423          	sd	zero,40(a0)
vmm_init(void) {
ffffffffc020105c:	03200413          	li	s0,50
ffffffffc0201060:	a811                	j	ffffffffc0201074 <vmm_init+0x64>
        vma->vm_start = vm_start;
ffffffffc0201062:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201064:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201066:	00053c23          	sd	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc020106a:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020106c:	8526                	mv	a0,s1
ffffffffc020106e:	e9dff0ef          	jal	ra,ffffffffc0200f0a <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0201072:	cc05                	beqz	s0,ffffffffc02010aa <vmm_init+0x9a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201074:	03000513          	li	a0,48
ffffffffc0201078:	317020ef          	jal	ra,ffffffffc0203b8e <kmalloc>
ffffffffc020107c:	85aa                	mv	a1,a0
ffffffffc020107e:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0201082:	f165                	bnez	a0,ffffffffc0201062 <vmm_init+0x52>
        assert(vma != NULL);
ffffffffc0201084:	00004697          	auipc	a3,0x4
ffffffffc0201088:	0dc68693          	addi	a3,a3,220 # ffffffffc0205160 <commands+0xb00>
ffffffffc020108c:	00004617          	auipc	a2,0x4
ffffffffc0201090:	cf460613          	addi	a2,a2,-780 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201094:	0ce00593          	li	a1,206
ffffffffc0201098:	00004517          	auipc	a0,0x4
ffffffffc020109c:	e2850513          	addi	a0,a0,-472 # ffffffffc0204ec0 <commands+0x860>
ffffffffc02010a0:	862ff0ef          	jal	ra,ffffffffc0200102 <__panic>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02010a4:	47d000ef          	jal	ra,ffffffffc0201d20 <swap_init_mm>
ffffffffc02010a8:	bf55                	j	ffffffffc020105c <vmm_init+0x4c>
ffffffffc02010aa:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02010ae:	1f900913          	li	s2,505
ffffffffc02010b2:	a819                	j	ffffffffc02010c8 <vmm_init+0xb8>
        vma->vm_start = vm_start;
ffffffffc02010b4:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02010b6:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02010b8:	00053c23          	sd	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02010bc:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02010be:	8526                	mv	a0,s1
ffffffffc02010c0:	e4bff0ef          	jal	ra,ffffffffc0200f0a <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02010c4:	03240a63          	beq	s0,s2,ffffffffc02010f8 <vmm_init+0xe8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02010c8:	03000513          	li	a0,48
ffffffffc02010cc:	2c3020ef          	jal	ra,ffffffffc0203b8e <kmalloc>
ffffffffc02010d0:	85aa                	mv	a1,a0
ffffffffc02010d2:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc02010d6:	fd79                	bnez	a0,ffffffffc02010b4 <vmm_init+0xa4>
        assert(vma != NULL);
ffffffffc02010d8:	00004697          	auipc	a3,0x4
ffffffffc02010dc:	08868693          	addi	a3,a3,136 # ffffffffc0205160 <commands+0xb00>
ffffffffc02010e0:	00004617          	auipc	a2,0x4
ffffffffc02010e4:	ca060613          	addi	a2,a2,-864 # ffffffffc0204d80 <commands+0x720>
ffffffffc02010e8:	0d400593          	li	a1,212
ffffffffc02010ec:	00004517          	auipc	a0,0x4
ffffffffc02010f0:	dd450513          	addi	a0,a0,-556 # ffffffffc0204ec0 <commands+0x860>
ffffffffc02010f4:	80eff0ef          	jal	ra,ffffffffc0200102 <__panic>
    return listelm->next;
ffffffffc02010f8:	649c                	ld	a5,8(s1)
ffffffffc02010fa:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc02010fc:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0201100:	2ef48463          	beq	s1,a5,ffffffffc02013e8 <vmm_init+0x3d8>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0201104:	fe87b603          	ld	a2,-24(a5)
ffffffffc0201108:	ffe70693          	addi	a3,a4,-2
ffffffffc020110c:	26d61e63          	bne	a2,a3,ffffffffc0201388 <vmm_init+0x378>
ffffffffc0201110:	ff07b683          	ld	a3,-16(a5)
ffffffffc0201114:	26e69a63          	bne	a3,a4,ffffffffc0201388 <vmm_init+0x378>
    for (i = 1; i <= step2; i ++) {
ffffffffc0201118:	0715                	addi	a4,a4,5
ffffffffc020111a:	679c                	ld	a5,8(a5)
ffffffffc020111c:	feb712e3          	bne	a4,a1,ffffffffc0201100 <vmm_init+0xf0>
ffffffffc0201120:	4b1d                	li	s6,7
ffffffffc0201122:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0201124:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0201128:	85a2                	mv	a1,s0
ffffffffc020112a:	8526                	mv	a0,s1
ffffffffc020112c:	d9fff0ef          	jal	ra,ffffffffc0200eca <find_vma>
ffffffffc0201130:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0201132:	2c050b63          	beqz	a0,ffffffffc0201408 <vmm_init+0x3f8>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0201136:	00140593          	addi	a1,s0,1
ffffffffc020113a:	8526                	mv	a0,s1
ffffffffc020113c:	d8fff0ef          	jal	ra,ffffffffc0200eca <find_vma>
ffffffffc0201140:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc0201142:	2e050363          	beqz	a0,ffffffffc0201428 <vmm_init+0x418>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0201146:	85da                	mv	a1,s6
ffffffffc0201148:	8526                	mv	a0,s1
ffffffffc020114a:	d81ff0ef          	jal	ra,ffffffffc0200eca <find_vma>
        assert(vma3 == NULL);
ffffffffc020114e:	2e051d63          	bnez	a0,ffffffffc0201448 <vmm_init+0x438>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0201152:	00340593          	addi	a1,s0,3
ffffffffc0201156:	8526                	mv	a0,s1
ffffffffc0201158:	d73ff0ef          	jal	ra,ffffffffc0200eca <find_vma>
        assert(vma4 == NULL);
ffffffffc020115c:	30051663          	bnez	a0,ffffffffc0201468 <vmm_init+0x458>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0201160:	00440593          	addi	a1,s0,4
ffffffffc0201164:	8526                	mv	a0,s1
ffffffffc0201166:	d65ff0ef          	jal	ra,ffffffffc0200eca <find_vma>
        assert(vma5 == NULL);
ffffffffc020116a:	30051f63          	bnez	a0,ffffffffc0201488 <vmm_init+0x478>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020116e:	00893783          	ld	a5,8(s2)
ffffffffc0201172:	24879b63          	bne	a5,s0,ffffffffc02013c8 <vmm_init+0x3b8>
ffffffffc0201176:	01093783          	ld	a5,16(s2)
ffffffffc020117a:	25679763          	bne	a5,s6,ffffffffc02013c8 <vmm_init+0x3b8>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020117e:	008ab783          	ld	a5,8(s5)
ffffffffc0201182:	22879363          	bne	a5,s0,ffffffffc02013a8 <vmm_init+0x398>
ffffffffc0201186:	010ab783          	ld	a5,16(s5)
ffffffffc020118a:	21679f63          	bne	a5,s6,ffffffffc02013a8 <vmm_init+0x398>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020118e:	0415                	addi	s0,s0,5
ffffffffc0201190:	0b15                	addi	s6,s6,5
ffffffffc0201192:	f9741be3          	bne	s0,s7,ffffffffc0201128 <vmm_init+0x118>
ffffffffc0201196:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0201198:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc020119a:	85a2                	mv	a1,s0
ffffffffc020119c:	8526                	mv	a0,s1
ffffffffc020119e:	d2dff0ef          	jal	ra,ffffffffc0200eca <find_vma>
ffffffffc02011a2:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc02011a6:	c90d                	beqz	a0,ffffffffc02011d8 <vmm_init+0x1c8>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc02011a8:	6914                	ld	a3,16(a0)
ffffffffc02011aa:	6510                	ld	a2,8(a0)
ffffffffc02011ac:	00004517          	auipc	a0,0x4
ffffffffc02011b0:	e8450513          	addi	a0,a0,-380 # ffffffffc0205030 <commands+0x9d0>
ffffffffc02011b4:	f07fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02011b8:	00004697          	auipc	a3,0x4
ffffffffc02011bc:	ea068693          	addi	a3,a3,-352 # ffffffffc0205058 <commands+0x9f8>
ffffffffc02011c0:	00004617          	auipc	a2,0x4
ffffffffc02011c4:	bc060613          	addi	a2,a2,-1088 # ffffffffc0204d80 <commands+0x720>
ffffffffc02011c8:	0f600593          	li	a1,246
ffffffffc02011cc:	00004517          	auipc	a0,0x4
ffffffffc02011d0:	cf450513          	addi	a0,a0,-780 # ffffffffc0204ec0 <commands+0x860>
ffffffffc02011d4:	f2ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc02011d8:	147d                	addi	s0,s0,-1
ffffffffc02011da:	fd2410e3          	bne	s0,s2,ffffffffc020119a <vmm_init+0x18a>
ffffffffc02011de:	a811                	j	ffffffffc02011f2 <vmm_init+0x1e2>
    __list_del(listelm->prev, listelm->next);
ffffffffc02011e0:	6118                	ld	a4,0(a0)
ffffffffc02011e2:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc02011e4:	03000593          	li	a1,48
ffffffffc02011e8:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02011ea:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02011ec:	e398                	sd	a4,0(a5)
ffffffffc02011ee:	25b020ef          	jal	ra,ffffffffc0203c48 <kfree>
    return listelm->next;
ffffffffc02011f2:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list) {
ffffffffc02011f4:	fea496e3          	bne	s1,a0,ffffffffc02011e0 <vmm_init+0x1d0>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc02011f8:	03000593          	li	a1,48
ffffffffc02011fc:	8526                	mv	a0,s1
ffffffffc02011fe:	24b020ef          	jal	ra,ffffffffc0203c48 <kfree>
    }

    mm_destroy(mm);

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201202:	0a7010ef          	jal	ra,ffffffffc0202aa8 <nr_free_pages>
ffffffffc0201206:	3caa1163          	bne	s4,a0,ffffffffc02015c8 <vmm_init+0x5b8>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc020120a:	00004517          	auipc	a0,0x4
ffffffffc020120e:	e8e50513          	addi	a0,a0,-370 # ffffffffc0205098 <commands+0xa38>
ffffffffc0201212:	ea9fe0ef          	jal	ra,ffffffffc02000ba <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0201216:	093010ef          	jal	ra,ffffffffc0202aa8 <nr_free_pages>
ffffffffc020121a:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020121c:	03000513          	li	a0,48
ffffffffc0201220:	16f020ef          	jal	ra,ffffffffc0203b8e <kmalloc>
ffffffffc0201224:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0201226:	2a050163          	beqz	a0,ffffffffc02014c8 <vmm_init+0x4b8>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020122a:	00010797          	auipc	a5,0x10
ffffffffc020122e:	30e7a783          	lw	a5,782(a5) # ffffffffc0211538 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc0201232:	e508                	sd	a0,8(a0)
ffffffffc0201234:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0201236:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc020123a:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020123e:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201242:	14079063          	bnez	a5,ffffffffc0201382 <vmm_init+0x372>
        else mm->sm_priv = NULL;
ffffffffc0201246:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();

    assert(check_mm_struct != NULL);
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020124a:	00010917          	auipc	s2,0x10
ffffffffc020124e:	2fe93903          	ld	s2,766(s2) # ffffffffc0211548 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0201252:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc0201256:	00010717          	auipc	a4,0x10
ffffffffc020125a:	2c873123          	sd	s0,706(a4) # ffffffffc0211518 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020125e:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc0201262:	24079363          	bnez	a5,ffffffffc02014a8 <vmm_init+0x498>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201266:	03000513          	li	a0,48
ffffffffc020126a:	125020ef          	jal	ra,ffffffffc0203b8e <kmalloc>
ffffffffc020126e:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc0201270:	28050063          	beqz	a0,ffffffffc02014f0 <vmm_init+0x4e0>
        vma->vm_end = vm_end;
ffffffffc0201274:	002007b7          	lui	a5,0x200
ffffffffc0201278:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc020127c:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc020127e:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0201280:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc0201284:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0201286:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc020128a:	c81ff0ef          	jal	ra,ffffffffc0200f0a <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc020128e:	10000593          	li	a1,256
ffffffffc0201292:	8522                	mv	a0,s0
ffffffffc0201294:	c37ff0ef          	jal	ra,ffffffffc0200eca <find_vma>
ffffffffc0201298:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc020129c:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc02012a0:	26aa1863          	bne	s4,a0,ffffffffc0201510 <vmm_init+0x500>
        *(char *)(addr + i) = i;
ffffffffc02012a4:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i ++) {
ffffffffc02012a8:	0785                	addi	a5,a5,1
ffffffffc02012aa:	fee79de3          	bne	a5,a4,ffffffffc02012a4 <vmm_init+0x294>
        sum += i;
ffffffffc02012ae:	6705                	lui	a4,0x1
ffffffffc02012b0:	10000793          	li	a5,256
ffffffffc02012b4:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc02012b8:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc02012bc:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc02012c0:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc02012c2:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc02012c4:	fec79ce3          	bne	a5,a2,ffffffffc02012bc <vmm_init+0x2ac>
    }
    assert(sum == 0);
ffffffffc02012c8:	26071463          	bnez	a4,ffffffffc0201530 <vmm_init+0x520>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02012cc:	4581                	li	a1,0
ffffffffc02012ce:	854a                	mv	a0,s2
ffffffffc02012d0:	263010ef          	jal	ra,ffffffffc0202d32 <page_remove>
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
ffffffffc02012d4:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02012d8:	00010717          	auipc	a4,0x10
ffffffffc02012dc:	27873703          	ld	a4,632(a4) # ffffffffc0211550 <npage>
    return pa2page(PDE_ADDR(pde));
ffffffffc02012e0:	078a                	slli	a5,a5,0x2
ffffffffc02012e2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02012e4:	26e7f663          	bgeu	a5,a4,ffffffffc0201550 <vmm_init+0x540>
    return &pages[PPN(pa) - nbase];
ffffffffc02012e8:	00005717          	auipc	a4,0x5
ffffffffc02012ec:	f4073703          	ld	a4,-192(a4) # ffffffffc0206228 <nbase>
ffffffffc02012f0:	8f99                	sub	a5,a5,a4
ffffffffc02012f2:	00379713          	slli	a4,a5,0x3
ffffffffc02012f6:	97ba                	add	a5,a5,a4
ffffffffc02012f8:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc02012fa:	00010517          	auipc	a0,0x10
ffffffffc02012fe:	25e53503          	ld	a0,606(a0) # ffffffffc0211558 <pages>
ffffffffc0201302:	953e                	add	a0,a0,a5
ffffffffc0201304:	4585                	li	a1,1
ffffffffc0201306:	762010ef          	jal	ra,ffffffffc0202a68 <free_pages>
    return listelm->next;
ffffffffc020130a:	6408                	ld	a0,8(s0)

    pgdir[0] = 0;
ffffffffc020130c:	00093023          	sd	zero,0(s2)

    mm->pgdir = NULL;
ffffffffc0201310:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0201314:	00a40e63          	beq	s0,a0,ffffffffc0201330 <vmm_init+0x320>
    __list_del(listelm->prev, listelm->next);
ffffffffc0201318:	6118                	ld	a4,0(a0)
ffffffffc020131a:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc020131c:	03000593          	li	a1,48
ffffffffc0201320:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0201322:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201324:	e398                	sd	a4,0(a5)
ffffffffc0201326:	123020ef          	jal	ra,ffffffffc0203c48 <kfree>
    return listelm->next;
ffffffffc020132a:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020132c:	fea416e3          	bne	s0,a0,ffffffffc0201318 <vmm_init+0x308>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0201330:	03000593          	li	a1,48
ffffffffc0201334:	8522                	mv	a0,s0
ffffffffc0201336:	113020ef          	jal	ra,ffffffffc0203c48 <kfree>
    mm_destroy(mm);

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc020133a:	14fd                	addi	s1,s1,-1
    check_mm_struct = NULL;
ffffffffc020133c:	00010797          	auipc	a5,0x10
ffffffffc0201340:	1c07be23          	sd	zero,476(a5) # ffffffffc0211518 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201344:	764010ef          	jal	ra,ffffffffc0202aa8 <nr_free_pages>
ffffffffc0201348:	22a49063          	bne	s1,a0,ffffffffc0201568 <vmm_init+0x558>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc020134c:	00004517          	auipc	a0,0x4
ffffffffc0201350:	ddc50513          	addi	a0,a0,-548 # ffffffffc0205128 <commands+0xac8>
ffffffffc0201354:	d67fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201358:	750010ef          	jal	ra,ffffffffc0202aa8 <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc020135c:	19fd                	addi	s3,s3,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020135e:	22a99563          	bne	s3,a0,ffffffffc0201588 <vmm_init+0x578>
}
ffffffffc0201362:	6406                	ld	s0,64(sp)
ffffffffc0201364:	60a6                	ld	ra,72(sp)
ffffffffc0201366:	74e2                	ld	s1,56(sp)
ffffffffc0201368:	7942                	ld	s2,48(sp)
ffffffffc020136a:	79a2                	ld	s3,40(sp)
ffffffffc020136c:	7a02                	ld	s4,32(sp)
ffffffffc020136e:	6ae2                	ld	s5,24(sp)
ffffffffc0201370:	6b42                	ld	s6,16(sp)
ffffffffc0201372:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0201374:	00004517          	auipc	a0,0x4
ffffffffc0201378:	dd450513          	addi	a0,a0,-556 # ffffffffc0205148 <commands+0xae8>
}
ffffffffc020137c:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc020137e:	d3dfe06f          	j	ffffffffc02000ba <cprintf>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201382:	19f000ef          	jal	ra,ffffffffc0201d20 <swap_init_mm>
ffffffffc0201386:	b5d1                	j	ffffffffc020124a <vmm_init+0x23a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0201388:	00004697          	auipc	a3,0x4
ffffffffc020138c:	bc068693          	addi	a3,a3,-1088 # ffffffffc0204f48 <commands+0x8e8>
ffffffffc0201390:	00004617          	auipc	a2,0x4
ffffffffc0201394:	9f060613          	addi	a2,a2,-1552 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201398:	0dd00593          	li	a1,221
ffffffffc020139c:	00004517          	auipc	a0,0x4
ffffffffc02013a0:	b2450513          	addi	a0,a0,-1244 # ffffffffc0204ec0 <commands+0x860>
ffffffffc02013a4:	d5ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02013a8:	00004697          	auipc	a3,0x4
ffffffffc02013ac:	c5868693          	addi	a3,a3,-936 # ffffffffc0205000 <commands+0x9a0>
ffffffffc02013b0:	00004617          	auipc	a2,0x4
ffffffffc02013b4:	9d060613          	addi	a2,a2,-1584 # ffffffffc0204d80 <commands+0x720>
ffffffffc02013b8:	0ee00593          	li	a1,238
ffffffffc02013bc:	00004517          	auipc	a0,0x4
ffffffffc02013c0:	b0450513          	addi	a0,a0,-1276 # ffffffffc0204ec0 <commands+0x860>
ffffffffc02013c4:	d3ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02013c8:	00004697          	auipc	a3,0x4
ffffffffc02013cc:	c0868693          	addi	a3,a3,-1016 # ffffffffc0204fd0 <commands+0x970>
ffffffffc02013d0:	00004617          	auipc	a2,0x4
ffffffffc02013d4:	9b060613          	addi	a2,a2,-1616 # ffffffffc0204d80 <commands+0x720>
ffffffffc02013d8:	0ed00593          	li	a1,237
ffffffffc02013dc:	00004517          	auipc	a0,0x4
ffffffffc02013e0:	ae450513          	addi	a0,a0,-1308 # ffffffffc0204ec0 <commands+0x860>
ffffffffc02013e4:	d1ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02013e8:	00004697          	auipc	a3,0x4
ffffffffc02013ec:	b4868693          	addi	a3,a3,-1208 # ffffffffc0204f30 <commands+0x8d0>
ffffffffc02013f0:	00004617          	auipc	a2,0x4
ffffffffc02013f4:	99060613          	addi	a2,a2,-1648 # ffffffffc0204d80 <commands+0x720>
ffffffffc02013f8:	0db00593          	li	a1,219
ffffffffc02013fc:	00004517          	auipc	a0,0x4
ffffffffc0201400:	ac450513          	addi	a0,a0,-1340 # ffffffffc0204ec0 <commands+0x860>
ffffffffc0201404:	cfffe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma1 != NULL);
ffffffffc0201408:	00004697          	auipc	a3,0x4
ffffffffc020140c:	b7868693          	addi	a3,a3,-1160 # ffffffffc0204f80 <commands+0x920>
ffffffffc0201410:	00004617          	auipc	a2,0x4
ffffffffc0201414:	97060613          	addi	a2,a2,-1680 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201418:	0e300593          	li	a1,227
ffffffffc020141c:	00004517          	auipc	a0,0x4
ffffffffc0201420:	aa450513          	addi	a0,a0,-1372 # ffffffffc0204ec0 <commands+0x860>
ffffffffc0201424:	cdffe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma2 != NULL);
ffffffffc0201428:	00004697          	auipc	a3,0x4
ffffffffc020142c:	b6868693          	addi	a3,a3,-1176 # ffffffffc0204f90 <commands+0x930>
ffffffffc0201430:	00004617          	auipc	a2,0x4
ffffffffc0201434:	95060613          	addi	a2,a2,-1712 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201438:	0e500593          	li	a1,229
ffffffffc020143c:	00004517          	auipc	a0,0x4
ffffffffc0201440:	a8450513          	addi	a0,a0,-1404 # ffffffffc0204ec0 <commands+0x860>
ffffffffc0201444:	cbffe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma3 == NULL);
ffffffffc0201448:	00004697          	auipc	a3,0x4
ffffffffc020144c:	b5868693          	addi	a3,a3,-1192 # ffffffffc0204fa0 <commands+0x940>
ffffffffc0201450:	00004617          	auipc	a2,0x4
ffffffffc0201454:	93060613          	addi	a2,a2,-1744 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201458:	0e700593          	li	a1,231
ffffffffc020145c:	00004517          	auipc	a0,0x4
ffffffffc0201460:	a6450513          	addi	a0,a0,-1436 # ffffffffc0204ec0 <commands+0x860>
ffffffffc0201464:	c9ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma4 == NULL);
ffffffffc0201468:	00004697          	auipc	a3,0x4
ffffffffc020146c:	b4868693          	addi	a3,a3,-1208 # ffffffffc0204fb0 <commands+0x950>
ffffffffc0201470:	00004617          	auipc	a2,0x4
ffffffffc0201474:	91060613          	addi	a2,a2,-1776 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201478:	0e900593          	li	a1,233
ffffffffc020147c:	00004517          	auipc	a0,0x4
ffffffffc0201480:	a4450513          	addi	a0,a0,-1468 # ffffffffc0204ec0 <commands+0x860>
ffffffffc0201484:	c7ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma5 == NULL);
ffffffffc0201488:	00004697          	auipc	a3,0x4
ffffffffc020148c:	b3868693          	addi	a3,a3,-1224 # ffffffffc0204fc0 <commands+0x960>
ffffffffc0201490:	00004617          	auipc	a2,0x4
ffffffffc0201494:	8f060613          	addi	a2,a2,-1808 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201498:	0eb00593          	li	a1,235
ffffffffc020149c:	00004517          	auipc	a0,0x4
ffffffffc02014a0:	a2450513          	addi	a0,a0,-1500 # ffffffffc0204ec0 <commands+0x860>
ffffffffc02014a4:	c5ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02014a8:	00004697          	auipc	a3,0x4
ffffffffc02014ac:	c1068693          	addi	a3,a3,-1008 # ffffffffc02050b8 <commands+0xa58>
ffffffffc02014b0:	00004617          	auipc	a2,0x4
ffffffffc02014b4:	8d060613          	addi	a2,a2,-1840 # ffffffffc0204d80 <commands+0x720>
ffffffffc02014b8:	10d00593          	li	a1,269
ffffffffc02014bc:	00004517          	auipc	a0,0x4
ffffffffc02014c0:	a0450513          	addi	a0,a0,-1532 # ffffffffc0204ec0 <commands+0x860>
ffffffffc02014c4:	c3ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc02014c8:	00004697          	auipc	a3,0x4
ffffffffc02014cc:	ca868693          	addi	a3,a3,-856 # ffffffffc0205170 <commands+0xb10>
ffffffffc02014d0:	00004617          	auipc	a2,0x4
ffffffffc02014d4:	8b060613          	addi	a2,a2,-1872 # ffffffffc0204d80 <commands+0x720>
ffffffffc02014d8:	10a00593          	li	a1,266
ffffffffc02014dc:	00004517          	auipc	a0,0x4
ffffffffc02014e0:	9e450513          	addi	a0,a0,-1564 # ffffffffc0204ec0 <commands+0x860>
    check_mm_struct = mm_create();
ffffffffc02014e4:	00010797          	auipc	a5,0x10
ffffffffc02014e8:	0207ba23          	sd	zero,52(a5) # ffffffffc0211518 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc02014ec:	c17fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(vma != NULL);
ffffffffc02014f0:	00004697          	auipc	a3,0x4
ffffffffc02014f4:	c7068693          	addi	a3,a3,-912 # ffffffffc0205160 <commands+0xb00>
ffffffffc02014f8:	00004617          	auipc	a2,0x4
ffffffffc02014fc:	88860613          	addi	a2,a2,-1912 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201500:	11100593          	li	a1,273
ffffffffc0201504:	00004517          	auipc	a0,0x4
ffffffffc0201508:	9bc50513          	addi	a0,a0,-1604 # ffffffffc0204ec0 <commands+0x860>
ffffffffc020150c:	bf7fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0201510:	00004697          	auipc	a3,0x4
ffffffffc0201514:	bb868693          	addi	a3,a3,-1096 # ffffffffc02050c8 <commands+0xa68>
ffffffffc0201518:	00004617          	auipc	a2,0x4
ffffffffc020151c:	86860613          	addi	a2,a2,-1944 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201520:	11600593          	li	a1,278
ffffffffc0201524:	00004517          	auipc	a0,0x4
ffffffffc0201528:	99c50513          	addi	a0,a0,-1636 # ffffffffc0204ec0 <commands+0x860>
ffffffffc020152c:	bd7fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(sum == 0);
ffffffffc0201530:	00004697          	auipc	a3,0x4
ffffffffc0201534:	bb868693          	addi	a3,a3,-1096 # ffffffffc02050e8 <commands+0xa88>
ffffffffc0201538:	00004617          	auipc	a2,0x4
ffffffffc020153c:	84860613          	addi	a2,a2,-1976 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201540:	12000593          	li	a1,288
ffffffffc0201544:	00004517          	auipc	a0,0x4
ffffffffc0201548:	97c50513          	addi	a0,a0,-1668 # ffffffffc0204ec0 <commands+0x860>
ffffffffc020154c:	bb7fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201550:	00004617          	auipc	a2,0x4
ffffffffc0201554:	ba860613          	addi	a2,a2,-1112 # ffffffffc02050f8 <commands+0xa98>
ffffffffc0201558:	06500593          	li	a1,101
ffffffffc020155c:	00004517          	auipc	a0,0x4
ffffffffc0201560:	bbc50513          	addi	a0,a0,-1092 # ffffffffc0205118 <commands+0xab8>
ffffffffc0201564:	b9ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201568:	00004697          	auipc	a3,0x4
ffffffffc020156c:	b0868693          	addi	a3,a3,-1272 # ffffffffc0205070 <commands+0xa10>
ffffffffc0201570:	00004617          	auipc	a2,0x4
ffffffffc0201574:	81060613          	addi	a2,a2,-2032 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201578:	12e00593          	li	a1,302
ffffffffc020157c:	00004517          	auipc	a0,0x4
ffffffffc0201580:	94450513          	addi	a0,a0,-1724 # ffffffffc0204ec0 <commands+0x860>
ffffffffc0201584:	b7ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201588:	00004697          	auipc	a3,0x4
ffffffffc020158c:	ae868693          	addi	a3,a3,-1304 # ffffffffc0205070 <commands+0xa10>
ffffffffc0201590:	00003617          	auipc	a2,0x3
ffffffffc0201594:	7f060613          	addi	a2,a2,2032 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201598:	0bd00593          	li	a1,189
ffffffffc020159c:	00004517          	auipc	a0,0x4
ffffffffc02015a0:	92450513          	addi	a0,a0,-1756 # ffffffffc0204ec0 <commands+0x860>
ffffffffc02015a4:	b5ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(mm != NULL);
ffffffffc02015a8:	00004697          	auipc	a3,0x4
ffffffffc02015ac:	be068693          	addi	a3,a3,-1056 # ffffffffc0205188 <commands+0xb28>
ffffffffc02015b0:	00003617          	auipc	a2,0x3
ffffffffc02015b4:	7d060613          	addi	a2,a2,2000 # ffffffffc0204d80 <commands+0x720>
ffffffffc02015b8:	0c700593          	li	a1,199
ffffffffc02015bc:	00004517          	auipc	a0,0x4
ffffffffc02015c0:	90450513          	addi	a0,a0,-1788 # ffffffffc0204ec0 <commands+0x860>
ffffffffc02015c4:	b3ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02015c8:	00004697          	auipc	a3,0x4
ffffffffc02015cc:	aa868693          	addi	a3,a3,-1368 # ffffffffc0205070 <commands+0xa10>
ffffffffc02015d0:	00003617          	auipc	a2,0x3
ffffffffc02015d4:	7b060613          	addi	a2,a2,1968 # ffffffffc0204d80 <commands+0x720>
ffffffffc02015d8:	0fb00593          	li	a1,251
ffffffffc02015dc:	00004517          	auipc	a0,0x4
ffffffffc02015e0:	8e450513          	addi	a0,a0,-1820 # ffffffffc0204ec0 <commands+0x860>
ffffffffc02015e4:	b1ffe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02015e8 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02015e8:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02015ea:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02015ec:	f022                	sd	s0,32(sp)
ffffffffc02015ee:	ec26                	sd	s1,24(sp)
ffffffffc02015f0:	f406                	sd	ra,40(sp)
ffffffffc02015f2:	e84a                	sd	s2,16(sp)
ffffffffc02015f4:	8432                	mv	s0,a2
ffffffffc02015f6:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02015f8:	8d3ff0ef          	jal	ra,ffffffffc0200eca <find_vma>

    pgfault_num++;
ffffffffc02015fc:	00010797          	auipc	a5,0x10
ffffffffc0201600:	f247a783          	lw	a5,-220(a5) # ffffffffc0211520 <pgfault_num>
ffffffffc0201604:	2785                	addiw	a5,a5,1
ffffffffc0201606:	00010717          	auipc	a4,0x10
ffffffffc020160a:	f0f72d23          	sw	a5,-230(a4) # ffffffffc0211520 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc020160e:	c159                	beqz	a0,ffffffffc0201694 <do_pgfault+0xac>
ffffffffc0201610:	651c                	ld	a5,8(a0)
ffffffffc0201612:	08f46163          	bltu	s0,a5,ffffffffc0201694 <do_pgfault+0xac>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0201616:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0201618:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020161a:	8b89                	andi	a5,a5,2
ffffffffc020161c:	ebb1                	bnez	a5,ffffffffc0201670 <do_pgfault+0x88>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc020161e:	75fd                	lui	a1,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0201620:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0201622:	8c6d                	and	s0,s0,a1
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0201624:	85a2                	mv	a1,s0
ffffffffc0201626:	4605                	li	a2,1
ffffffffc0201628:	4ba010ef          	jal	ra,ffffffffc0202ae2 <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc020162c:	610c                	ld	a1,0(a0)
ffffffffc020162e:	c1b9                	beqz	a1,ffffffffc0201674 <do_pgfault+0x8c>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0201630:	00010797          	auipc	a5,0x10
ffffffffc0201634:	f087a783          	lw	a5,-248(a5) # ffffffffc0211538 <swap_init_ok>
ffffffffc0201638:	c7bd                	beqz	a5,ffffffffc02016a6 <do_pgfault+0xbe>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            swap_in(mm, addr, &page);
ffffffffc020163a:	85a2                	mv	a1,s0
ffffffffc020163c:	0030                	addi	a2,sp,8
ffffffffc020163e:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0201640:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);
ffffffffc0201642:	00b000ef          	jal	ra,ffffffffc0201e4c <swap_in>
            page_insert(mm->pgdir, page, addr, perm); //更新页表，插入新的页表项
ffffffffc0201646:	65a2                	ld	a1,8(sp)
ffffffffc0201648:	6c88                	ld	a0,24(s1)
ffffffffc020164a:	86ca                	mv	a3,s2
ffffffffc020164c:	8622                	mv	a2,s0
ffffffffc020164e:	77e010ef          	jal	ra,ffffffffc0202dcc <page_insert>
            swap_map_swappable(mm, addr, page, 1); 
ffffffffc0201652:	6622                	ld	a2,8(sp)
ffffffffc0201654:	4685                	li	a3,1
ffffffffc0201656:	85a2                	mv	a1,s0
ffffffffc0201658:	8526                	mv	a0,s1
ffffffffc020165a:	6d2000ef          	jal	ra,ffffffffc0201d2c <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc020165e:	67a2                	ld	a5,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0201660:	4501                	li	a0,0
            page->pra_vaddr = addr;
ffffffffc0201662:	e3a0                	sd	s0,64(a5)
failed:
    return ret;
}
ffffffffc0201664:	70a2                	ld	ra,40(sp)
ffffffffc0201666:	7402                	ld	s0,32(sp)
ffffffffc0201668:	64e2                	ld	s1,24(sp)
ffffffffc020166a:	6942                	ld	s2,16(sp)
ffffffffc020166c:	6145                	addi	sp,sp,48
ffffffffc020166e:	8082                	ret
        perm |= (PTE_R | PTE_W);
ffffffffc0201670:	4959                	li	s2,22
ffffffffc0201672:	b775                	j	ffffffffc020161e <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0201674:	6c88                	ld	a0,24(s1)
ffffffffc0201676:	864a                	mv	a2,s2
ffffffffc0201678:	85a2                	mv	a1,s0
ffffffffc020167a:	45c020ef          	jal	ra,ffffffffc0203ad6 <pgdir_alloc_page>
ffffffffc020167e:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc0201680:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0201682:	f3ed                	bnez	a5,ffffffffc0201664 <do_pgfault+0x7c>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0201684:	00004517          	auipc	a0,0x4
ffffffffc0201688:	b4450513          	addi	a0,a0,-1212 # ffffffffc02051c8 <commands+0xb68>
ffffffffc020168c:	a2ffe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0201690:	5571                	li	a0,-4
            goto failed;
ffffffffc0201692:	bfc9                	j	ffffffffc0201664 <do_pgfault+0x7c>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0201694:	85a2                	mv	a1,s0
ffffffffc0201696:	00004517          	auipc	a0,0x4
ffffffffc020169a:	b0250513          	addi	a0,a0,-1278 # ffffffffc0205198 <commands+0xb38>
ffffffffc020169e:	a1dfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = -E_INVAL;
ffffffffc02016a2:	5575                	li	a0,-3
        goto failed;
ffffffffc02016a4:	b7c1                	j	ffffffffc0201664 <do_pgfault+0x7c>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc02016a6:	00004517          	auipc	a0,0x4
ffffffffc02016aa:	b4a50513          	addi	a0,a0,-1206 # ffffffffc02051f0 <commands+0xb90>
ffffffffc02016ae:	a0dfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc02016b2:	5571                	li	a0,-4
            goto failed;
ffffffffc02016b4:	bf45                	j	ffffffffc0201664 <do_pgfault+0x7c>

ffffffffc02016b6 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc02016b6:	7135                	addi	sp,sp,-160
ffffffffc02016b8:	ed06                	sd	ra,152(sp)
ffffffffc02016ba:	e922                	sd	s0,144(sp)
ffffffffc02016bc:	e526                	sd	s1,136(sp)
ffffffffc02016be:	e14a                	sd	s2,128(sp)
ffffffffc02016c0:	fcce                	sd	s3,120(sp)
ffffffffc02016c2:	f8d2                	sd	s4,112(sp)
ffffffffc02016c4:	f4d6                	sd	s5,104(sp)
ffffffffc02016c6:	f0da                	sd	s6,96(sp)
ffffffffc02016c8:	ecde                	sd	s7,88(sp)
ffffffffc02016ca:	e8e2                	sd	s8,80(sp)
ffffffffc02016cc:	e4e6                	sd	s9,72(sp)
ffffffffc02016ce:	e0ea                	sd	s10,64(sp)
ffffffffc02016d0:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc02016d2:	65e020ef          	jal	ra,ffffffffc0203d30 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc02016d6:	00010697          	auipc	a3,0x10
ffffffffc02016da:	e526b683          	ld	a3,-430(a3) # ffffffffc0211528 <max_swap_offset>
ffffffffc02016de:	010007b7          	lui	a5,0x1000
ffffffffc02016e2:	ff968713          	addi	a4,a3,-7
ffffffffc02016e6:	17e1                	addi	a5,a5,-8
ffffffffc02016e8:	3ee7e063          	bltu	a5,a4,ffffffffc0201ac8 <swap_init+0x412>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm=&swap_manager_lru;
ffffffffc02016ec:	00009797          	auipc	a5,0x9
ffffffffc02016f0:	91478793          	addi	a5,a5,-1772 # ffffffffc020a000 <swap_manager_lru>
     //sm=&swap_manager_fifo;
     //sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
     int r = sm->init();
ffffffffc02016f4:	6798                	ld	a4,8(a5)
     sm=&swap_manager_lru;
ffffffffc02016f6:	00010b17          	auipc	s6,0x10
ffffffffc02016fa:	e3ab0b13          	addi	s6,s6,-454 # ffffffffc0211530 <sm>
ffffffffc02016fe:	00fb3023          	sd	a5,0(s6)
     int r = sm->init();
ffffffffc0201702:	9702                	jalr	a4
ffffffffc0201704:	89aa                	mv	s3,a0
     
     if (r == 0)
ffffffffc0201706:	c10d                	beqz	a0,ffffffffc0201728 <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0201708:	60ea                	ld	ra,152(sp)
ffffffffc020170a:	644a                	ld	s0,144(sp)
ffffffffc020170c:	64aa                	ld	s1,136(sp)
ffffffffc020170e:	690a                	ld	s2,128(sp)
ffffffffc0201710:	7a46                	ld	s4,112(sp)
ffffffffc0201712:	7aa6                	ld	s5,104(sp)
ffffffffc0201714:	7b06                	ld	s6,96(sp)
ffffffffc0201716:	6be6                	ld	s7,88(sp)
ffffffffc0201718:	6c46                	ld	s8,80(sp)
ffffffffc020171a:	6ca6                	ld	s9,72(sp)
ffffffffc020171c:	6d06                	ld	s10,64(sp)
ffffffffc020171e:	7de2                	ld	s11,56(sp)
ffffffffc0201720:	854e                	mv	a0,s3
ffffffffc0201722:	79e6                	ld	s3,120(sp)
ffffffffc0201724:	610d                	addi	sp,sp,160
ffffffffc0201726:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0201728:	000b3783          	ld	a5,0(s6)
ffffffffc020172c:	00004517          	auipc	a0,0x4
ffffffffc0201730:	b1c50513          	addi	a0,a0,-1252 # ffffffffc0205248 <commands+0xbe8>
ffffffffc0201734:	00010497          	auipc	s1,0x10
ffffffffc0201738:	9ac48493          	addi	s1,s1,-1620 # ffffffffc02110e0 <free_area>
ffffffffc020173c:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc020173e:	4785                	li	a5,1
ffffffffc0201740:	00010717          	auipc	a4,0x10
ffffffffc0201744:	def72c23          	sw	a5,-520(a4) # ffffffffc0211538 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0201748:	973fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020174c:	649c                	ld	a5,8(s1)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc020174e:	4401                	li	s0,0
ffffffffc0201750:	4d01                	li	s10,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201752:	2c978163          	beq	a5,s1,ffffffffc0201a14 <swap_init+0x35e>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201756:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020175a:	8b09                	andi	a4,a4,2
ffffffffc020175c:	2a070e63          	beqz	a4,ffffffffc0201a18 <swap_init+0x362>
        count ++, total += p->property;
ffffffffc0201760:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201764:	679c                	ld	a5,8(a5)
ffffffffc0201766:	2d05                	addiw	s10,s10,1
ffffffffc0201768:	9c39                	addw	s0,s0,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc020176a:	fe9796e3          	bne	a5,s1,ffffffffc0201756 <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc020176e:	8922                	mv	s2,s0
ffffffffc0201770:	338010ef          	jal	ra,ffffffffc0202aa8 <nr_free_pages>
ffffffffc0201774:	47251663          	bne	a0,s2,ffffffffc0201be0 <swap_init+0x52a>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0201778:	8622                	mv	a2,s0
ffffffffc020177a:	85ea                	mv	a1,s10
ffffffffc020177c:	00004517          	auipc	a0,0x4
ffffffffc0201780:	b1450513          	addi	a0,a0,-1260 # ffffffffc0205290 <commands+0xc30>
ffffffffc0201784:	937fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0201788:	eccff0ef          	jal	ra,ffffffffc0200e54 <mm_create>
ffffffffc020178c:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc020178e:	52050963          	beqz	a0,ffffffffc0201cc0 <swap_init+0x60a>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0201792:	00010797          	auipc	a5,0x10
ffffffffc0201796:	d8678793          	addi	a5,a5,-634 # ffffffffc0211518 <check_mm_struct>
ffffffffc020179a:	6398                	ld	a4,0(a5)
ffffffffc020179c:	54071263          	bnez	a4,ffffffffc0201ce0 <swap_init+0x62a>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02017a0:	00010b97          	auipc	s7,0x10
ffffffffc02017a4:	da8bbb83          	ld	s7,-600(s7) # ffffffffc0211548 <boot_pgdir>
     assert(pgdir[0] == 0);
ffffffffc02017a8:	000bb703          	ld	a4,0(s7)
     check_mm_struct = mm;
ffffffffc02017ac:	e388                	sd	a0,0(a5)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02017ae:	01753c23          	sd	s7,24(a0)
     assert(pgdir[0] == 0);
ffffffffc02017b2:	3c071763          	bnez	a4,ffffffffc0201b80 <swap_init+0x4ca>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc02017b6:	6599                	lui	a1,0x6
ffffffffc02017b8:	460d                	li	a2,3
ffffffffc02017ba:	6505                	lui	a0,0x1
ffffffffc02017bc:	ee0ff0ef          	jal	ra,ffffffffc0200e9c <vma_create>
ffffffffc02017c0:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02017c2:	3c050f63          	beqz	a0,ffffffffc0201ba0 <swap_init+0x4ea>

     insert_vma_struct(mm, vma);
ffffffffc02017c6:	8556                	mv	a0,s5
ffffffffc02017c8:	f42ff0ef          	jal	ra,ffffffffc0200f0a <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02017cc:	00004517          	auipc	a0,0x4
ffffffffc02017d0:	b0450513          	addi	a0,a0,-1276 # ffffffffc02052d0 <commands+0xc70>
ffffffffc02017d4:	8e7fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02017d8:	018ab503          	ld	a0,24(s5)
ffffffffc02017dc:	4605                	li	a2,1
ffffffffc02017de:	6585                	lui	a1,0x1
ffffffffc02017e0:	302010ef          	jal	ra,ffffffffc0202ae2 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02017e4:	3c050e63          	beqz	a0,ffffffffc0201bc0 <swap_init+0x50a>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02017e8:	00004517          	auipc	a0,0x4
ffffffffc02017ec:	b3850513          	addi	a0,a0,-1224 # ffffffffc0205320 <commands+0xcc0>
ffffffffc02017f0:	00010917          	auipc	s2,0x10
ffffffffc02017f4:	88090913          	addi	s2,s2,-1920 # ffffffffc0211070 <check_rp>
ffffffffc02017f8:	8c3fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02017fc:	00010a17          	auipc	s4,0x10
ffffffffc0201800:	894a0a13          	addi	s4,s4,-1900 # ffffffffc0211090 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0201804:	8c4a                	mv	s8,s2
          check_rp[i] = alloc_page();
ffffffffc0201806:	4505                	li	a0,1
ffffffffc0201808:	1ce010ef          	jal	ra,ffffffffc02029d6 <alloc_pages>
ffffffffc020180c:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc0201810:	28050c63          	beqz	a0,ffffffffc0201aa8 <swap_init+0x3f2>
ffffffffc0201814:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0201816:	8b89                	andi	a5,a5,2
ffffffffc0201818:	26079863          	bnez	a5,ffffffffc0201a88 <swap_init+0x3d2>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020181c:	0c21                	addi	s8,s8,8
ffffffffc020181e:	ff4c14e3          	bne	s8,s4,ffffffffc0201806 <swap_init+0x150>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0201822:	609c                	ld	a5,0(s1)
ffffffffc0201824:	0084bd83          	ld	s11,8(s1)
    elm->prev = elm->next = elm;
ffffffffc0201828:	e084                	sd	s1,0(s1)
ffffffffc020182a:	f03e                	sd	a5,32(sp)
     list_init(&free_list);
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
ffffffffc020182c:	489c                	lw	a5,16(s1)
ffffffffc020182e:	e484                	sd	s1,8(s1)
     nr_free = 0;
ffffffffc0201830:	00010c17          	auipc	s8,0x10
ffffffffc0201834:	840c0c13          	addi	s8,s8,-1984 # ffffffffc0211070 <check_rp>
     unsigned int nr_free_store = nr_free;
ffffffffc0201838:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc020183a:	00010797          	auipc	a5,0x10
ffffffffc020183e:	8a07ab23          	sw	zero,-1866(a5) # ffffffffc02110f0 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0201842:	000c3503          	ld	a0,0(s8)
ffffffffc0201846:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201848:	0c21                	addi	s8,s8,8
        free_pages(check_rp[i],1);
ffffffffc020184a:	21e010ef          	jal	ra,ffffffffc0202a68 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020184e:	ff4c1ae3          	bne	s8,s4,ffffffffc0201842 <swap_init+0x18c>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0201852:	0104ac03          	lw	s8,16(s1)
ffffffffc0201856:	4791                	li	a5,4
ffffffffc0201858:	4afc1463          	bne	s8,a5,ffffffffc0201d00 <swap_init+0x64a>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc020185c:	00004517          	auipc	a0,0x4
ffffffffc0201860:	b4c50513          	addi	a0,a0,-1204 # ffffffffc02053a8 <commands+0xd48>
ffffffffc0201864:	857fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201868:	6605                	lui	a2,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc020186a:	00010797          	auipc	a5,0x10
ffffffffc020186e:	ca07ab23          	sw	zero,-842(a5) # ffffffffc0211520 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201872:	4529                	li	a0,10
ffffffffc0201874:	00a60023          	sb	a0,0(a2) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0201878:	00010597          	auipc	a1,0x10
ffffffffc020187c:	ca85a583          	lw	a1,-856(a1) # ffffffffc0211520 <pgfault_num>
ffffffffc0201880:	4805                	li	a6,1
ffffffffc0201882:	00010797          	auipc	a5,0x10
ffffffffc0201886:	c9e78793          	addi	a5,a5,-866 # ffffffffc0211520 <pgfault_num>
ffffffffc020188a:	3f059b63          	bne	a1,a6,ffffffffc0201c80 <swap_init+0x5ca>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc020188e:	00a60823          	sb	a0,16(a2)
     assert(pgfault_num==1);
ffffffffc0201892:	4390                	lw	a2,0(a5)
ffffffffc0201894:	2601                	sext.w	a2,a2
ffffffffc0201896:	40b61563          	bne	a2,a1,ffffffffc0201ca0 <swap_init+0x5ea>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc020189a:	6589                	lui	a1,0x2
ffffffffc020189c:	452d                	li	a0,11
ffffffffc020189e:	00a58023          	sb	a0,0(a1) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc02018a2:	4390                	lw	a2,0(a5)
ffffffffc02018a4:	4809                	li	a6,2
ffffffffc02018a6:	2601                	sext.w	a2,a2
ffffffffc02018a8:	35061c63          	bne	a2,a6,ffffffffc0201c00 <swap_init+0x54a>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc02018ac:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==2);
ffffffffc02018b0:	438c                	lw	a1,0(a5)
ffffffffc02018b2:	2581                	sext.w	a1,a1
ffffffffc02018b4:	36c59663          	bne	a1,a2,ffffffffc0201c20 <swap_init+0x56a>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc02018b8:	658d                	lui	a1,0x3
ffffffffc02018ba:	4531                	li	a0,12
ffffffffc02018bc:	00a58023          	sb	a0,0(a1) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc02018c0:	4390                	lw	a2,0(a5)
ffffffffc02018c2:	480d                	li	a6,3
ffffffffc02018c4:	2601                	sext.w	a2,a2
ffffffffc02018c6:	37061d63          	bne	a2,a6,ffffffffc0201c40 <swap_init+0x58a>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc02018ca:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==3);
ffffffffc02018ce:	438c                	lw	a1,0(a5)
ffffffffc02018d0:	2581                	sext.w	a1,a1
ffffffffc02018d2:	38c59763          	bne	a1,a2,ffffffffc0201c60 <swap_init+0x5aa>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc02018d6:	6591                	lui	a1,0x4
ffffffffc02018d8:	4535                	li	a0,13
ffffffffc02018da:	00a58023          	sb	a0,0(a1) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc02018de:	4390                	lw	a2,0(a5)
ffffffffc02018e0:	2601                	sext.w	a2,a2
ffffffffc02018e2:	21861f63          	bne	a2,s8,ffffffffc0201b00 <swap_init+0x44a>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc02018e6:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==4);
ffffffffc02018ea:	439c                	lw	a5,0(a5)
ffffffffc02018ec:	2781                	sext.w	a5,a5
ffffffffc02018ee:	22c79963          	bne	a5,a2,ffffffffc0201b20 <swap_init+0x46a>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc02018f2:	489c                	lw	a5,16(s1)
ffffffffc02018f4:	24079663          	bnez	a5,ffffffffc0201b40 <swap_init+0x48a>
ffffffffc02018f8:	0000f797          	auipc	a5,0xf
ffffffffc02018fc:	79878793          	addi	a5,a5,1944 # ffffffffc0211090 <swap_in_seq_no>
ffffffffc0201900:	0000f617          	auipc	a2,0xf
ffffffffc0201904:	7b860613          	addi	a2,a2,1976 # ffffffffc02110b8 <swap_out_seq_no>
ffffffffc0201908:	0000f517          	auipc	a0,0xf
ffffffffc020190c:	7b050513          	addi	a0,a0,1968 # ffffffffc02110b8 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0201910:	55fd                	li	a1,-1
ffffffffc0201912:	c38c                	sw	a1,0(a5)
ffffffffc0201914:	c20c                	sw	a1,0(a2)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0201916:	0791                	addi	a5,a5,4
ffffffffc0201918:	0611                	addi	a2,a2,4
ffffffffc020191a:	fef51ce3          	bne	a0,a5,ffffffffc0201912 <swap_init+0x25c>
ffffffffc020191e:	0000f817          	auipc	a6,0xf
ffffffffc0201922:	73280813          	addi	a6,a6,1842 # ffffffffc0211050 <check_ptep>
ffffffffc0201926:	0000f897          	auipc	a7,0xf
ffffffffc020192a:	74a88893          	addi	a7,a7,1866 # ffffffffc0211070 <check_rp>
ffffffffc020192e:	6585                	lui	a1,0x1
    return &pages[PPN(pa) - nbase];
ffffffffc0201930:	00010c97          	auipc	s9,0x10
ffffffffc0201934:	c28c8c93          	addi	s9,s9,-984 # ffffffffc0211558 <pages>
ffffffffc0201938:	00005c17          	auipc	s8,0x5
ffffffffc020193c:	8f0c0c13          	addi	s8,s8,-1808 # ffffffffc0206228 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0201940:	00083023          	sd	zero,0(a6)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201944:	4601                	li	a2,0
ffffffffc0201946:	855e                	mv	a0,s7
ffffffffc0201948:	ec46                	sd	a7,24(sp)
ffffffffc020194a:	e82e                	sd	a1,16(sp)
         check_ptep[i]=0;
ffffffffc020194c:	e442                	sd	a6,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020194e:	194010ef          	jal	ra,ffffffffc0202ae2 <get_pte>
ffffffffc0201952:	6822                	ld	a6,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0201954:	65c2                	ld	a1,16(sp)
ffffffffc0201956:	68e2                	ld	a7,24(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201958:	00a83023          	sd	a0,0(a6)
         assert(check_ptep[i] != NULL);
ffffffffc020195c:	00010317          	auipc	t1,0x10
ffffffffc0201960:	bf430313          	addi	t1,t1,-1036 # ffffffffc0211550 <npage>
ffffffffc0201964:	16050e63          	beqz	a0,ffffffffc0201ae0 <swap_init+0x42a>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0201968:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020196a:	0017f613          	andi	a2,a5,1
ffffffffc020196e:	0e060563          	beqz	a2,ffffffffc0201a58 <swap_init+0x3a2>
    if (PPN(pa) >= npage) {
ffffffffc0201972:	00033603          	ld	a2,0(t1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201976:	078a                	slli	a5,a5,0x2
ffffffffc0201978:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020197a:	0ec7fb63          	bgeu	a5,a2,ffffffffc0201a70 <swap_init+0x3ba>
    return &pages[PPN(pa) - nbase];
ffffffffc020197e:	000c3603          	ld	a2,0(s8)
ffffffffc0201982:	000cb503          	ld	a0,0(s9)
ffffffffc0201986:	0008bf03          	ld	t5,0(a7)
ffffffffc020198a:	8f91                	sub	a5,a5,a2
ffffffffc020198c:	00379613          	slli	a2,a5,0x3
ffffffffc0201990:	97b2                	add	a5,a5,a2
ffffffffc0201992:	078e                	slli	a5,a5,0x3
ffffffffc0201994:	97aa                	add	a5,a5,a0
ffffffffc0201996:	0aff1163          	bne	t5,a5,ffffffffc0201a38 <swap_init+0x382>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020199a:	6785                	lui	a5,0x1
ffffffffc020199c:	95be                	add	a1,a1,a5
ffffffffc020199e:	6795                	lui	a5,0x5
ffffffffc02019a0:	0821                	addi	a6,a6,8
ffffffffc02019a2:	08a1                	addi	a7,a7,8
ffffffffc02019a4:	f8f59ee3          	bne	a1,a5,ffffffffc0201940 <swap_init+0x28a>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc02019a8:	00004517          	auipc	a0,0x4
ffffffffc02019ac:	ae050513          	addi	a0,a0,-1312 # ffffffffc0205488 <commands+0xe28>
ffffffffc02019b0:	f0afe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = sm->check_swap();
ffffffffc02019b4:	000b3783          	ld	a5,0(s6)
ffffffffc02019b8:	7f9c                	ld	a5,56(a5)
ffffffffc02019ba:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc02019bc:	1a051263          	bnez	a0,ffffffffc0201b60 <swap_init+0x4aa>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc02019c0:	00093503          	ld	a0,0(s2)
ffffffffc02019c4:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02019c6:	0921                	addi	s2,s2,8
         free_pages(check_rp[i],1);
ffffffffc02019c8:	0a0010ef          	jal	ra,ffffffffc0202a68 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02019cc:	ff491ae3          	bne	s2,s4,ffffffffc02019c0 <swap_init+0x30a>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc02019d0:	8556                	mv	a0,s5
ffffffffc02019d2:	e08ff0ef          	jal	ra,ffffffffc0200fda <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc02019d6:	77a2                	ld	a5,40(sp)
     free_list = free_list_store;
ffffffffc02019d8:	01b4b423          	sd	s11,8(s1)
     nr_free = nr_free_store;
ffffffffc02019dc:	c89c                	sw	a5,16(s1)
     free_list = free_list_store;
ffffffffc02019de:	7782                	ld	a5,32(sp)
ffffffffc02019e0:	e09c                	sd	a5,0(s1)

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02019e2:	009d8a63          	beq	s11,s1,ffffffffc02019f6 <swap_init+0x340>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc02019e6:	ff8da783          	lw	a5,-8(s11)
    return listelm->next;
ffffffffc02019ea:	008dbd83          	ld	s11,8(s11)
ffffffffc02019ee:	3d7d                	addiw	s10,s10,-1
ffffffffc02019f0:	9c1d                	subw	s0,s0,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc02019f2:	fe9d9ae3          	bne	s11,s1,ffffffffc02019e6 <swap_init+0x330>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc02019f6:	8622                	mv	a2,s0
ffffffffc02019f8:	85ea                	mv	a1,s10
ffffffffc02019fa:	00004517          	auipc	a0,0x4
ffffffffc02019fe:	abe50513          	addi	a0,a0,-1346 # ffffffffc02054b8 <commands+0xe58>
ffffffffc0201a02:	eb8fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0201a06:	00004517          	auipc	a0,0x4
ffffffffc0201a0a:	ad250513          	addi	a0,a0,-1326 # ffffffffc02054d8 <commands+0xe78>
ffffffffc0201a0e:	eacfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0201a12:	b9dd                	j	ffffffffc0201708 <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201a14:	4901                	li	s2,0
ffffffffc0201a16:	bba9                	j	ffffffffc0201770 <swap_init+0xba>
        assert(PageProperty(p));
ffffffffc0201a18:	00004697          	auipc	a3,0x4
ffffffffc0201a1c:	84868693          	addi	a3,a3,-1976 # ffffffffc0205260 <commands+0xc00>
ffffffffc0201a20:	00003617          	auipc	a2,0x3
ffffffffc0201a24:	36060613          	addi	a2,a2,864 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201a28:	0bd00593          	li	a1,189
ffffffffc0201a2c:	00004517          	auipc	a0,0x4
ffffffffc0201a30:	80c50513          	addi	a0,a0,-2036 # ffffffffc0205238 <commands+0xbd8>
ffffffffc0201a34:	ecefe0ef          	jal	ra,ffffffffc0200102 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0201a38:	00004697          	auipc	a3,0x4
ffffffffc0201a3c:	a2868693          	addi	a3,a3,-1496 # ffffffffc0205460 <commands+0xe00>
ffffffffc0201a40:	00003617          	auipc	a2,0x3
ffffffffc0201a44:	34060613          	addi	a2,a2,832 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201a48:	0fd00593          	li	a1,253
ffffffffc0201a4c:	00003517          	auipc	a0,0x3
ffffffffc0201a50:	7ec50513          	addi	a0,a0,2028 # ffffffffc0205238 <commands+0xbd8>
ffffffffc0201a54:	eaefe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0201a58:	00004617          	auipc	a2,0x4
ffffffffc0201a5c:	9e060613          	addi	a2,a2,-1568 # ffffffffc0205438 <commands+0xdd8>
ffffffffc0201a60:	07000593          	li	a1,112
ffffffffc0201a64:	00003517          	auipc	a0,0x3
ffffffffc0201a68:	6b450513          	addi	a0,a0,1716 # ffffffffc0205118 <commands+0xab8>
ffffffffc0201a6c:	e96fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201a70:	00003617          	auipc	a2,0x3
ffffffffc0201a74:	68860613          	addi	a2,a2,1672 # ffffffffc02050f8 <commands+0xa98>
ffffffffc0201a78:	06500593          	li	a1,101
ffffffffc0201a7c:	00003517          	auipc	a0,0x3
ffffffffc0201a80:	69c50513          	addi	a0,a0,1692 # ffffffffc0205118 <commands+0xab8>
ffffffffc0201a84:	e7efe0ef          	jal	ra,ffffffffc0200102 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0201a88:	00004697          	auipc	a3,0x4
ffffffffc0201a8c:	8d868693          	addi	a3,a3,-1832 # ffffffffc0205360 <commands+0xd00>
ffffffffc0201a90:	00003617          	auipc	a2,0x3
ffffffffc0201a94:	2f060613          	addi	a2,a2,752 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201a98:	0de00593          	li	a1,222
ffffffffc0201a9c:	00003517          	auipc	a0,0x3
ffffffffc0201aa0:	79c50513          	addi	a0,a0,1948 # ffffffffc0205238 <commands+0xbd8>
ffffffffc0201aa4:	e5efe0ef          	jal	ra,ffffffffc0200102 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0201aa8:	00004697          	auipc	a3,0x4
ffffffffc0201aac:	8a068693          	addi	a3,a3,-1888 # ffffffffc0205348 <commands+0xce8>
ffffffffc0201ab0:	00003617          	auipc	a2,0x3
ffffffffc0201ab4:	2d060613          	addi	a2,a2,720 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201ab8:	0dd00593          	li	a1,221
ffffffffc0201abc:	00003517          	auipc	a0,0x3
ffffffffc0201ac0:	77c50513          	addi	a0,a0,1916 # ffffffffc0205238 <commands+0xbd8>
ffffffffc0201ac4:	e3efe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0201ac8:	00003617          	auipc	a2,0x3
ffffffffc0201acc:	75060613          	addi	a2,a2,1872 # ffffffffc0205218 <commands+0xbb8>
ffffffffc0201ad0:	02800593          	li	a1,40
ffffffffc0201ad4:	00003517          	auipc	a0,0x3
ffffffffc0201ad8:	76450513          	addi	a0,a0,1892 # ffffffffc0205238 <commands+0xbd8>
ffffffffc0201adc:	e26fe0ef          	jal	ra,ffffffffc0200102 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0201ae0:	00004697          	auipc	a3,0x4
ffffffffc0201ae4:	94068693          	addi	a3,a3,-1728 # ffffffffc0205420 <commands+0xdc0>
ffffffffc0201ae8:	00003617          	auipc	a2,0x3
ffffffffc0201aec:	29860613          	addi	a2,a2,664 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201af0:	0fc00593          	li	a1,252
ffffffffc0201af4:	00003517          	auipc	a0,0x3
ffffffffc0201af8:	74450513          	addi	a0,a0,1860 # ffffffffc0205238 <commands+0xbd8>
ffffffffc0201afc:	e06fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==4);
ffffffffc0201b00:	00004697          	auipc	a3,0x4
ffffffffc0201b04:	90068693          	addi	a3,a3,-1792 # ffffffffc0205400 <commands+0xda0>
ffffffffc0201b08:	00003617          	auipc	a2,0x3
ffffffffc0201b0c:	27860613          	addi	a2,a2,632 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201b10:	0a000593          	li	a1,160
ffffffffc0201b14:	00003517          	auipc	a0,0x3
ffffffffc0201b18:	72450513          	addi	a0,a0,1828 # ffffffffc0205238 <commands+0xbd8>
ffffffffc0201b1c:	de6fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==4);
ffffffffc0201b20:	00004697          	auipc	a3,0x4
ffffffffc0201b24:	8e068693          	addi	a3,a3,-1824 # ffffffffc0205400 <commands+0xda0>
ffffffffc0201b28:	00003617          	auipc	a2,0x3
ffffffffc0201b2c:	25860613          	addi	a2,a2,600 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201b30:	0a200593          	li	a1,162
ffffffffc0201b34:	00003517          	auipc	a0,0x3
ffffffffc0201b38:	70450513          	addi	a0,a0,1796 # ffffffffc0205238 <commands+0xbd8>
ffffffffc0201b3c:	dc6fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert( nr_free == 0);         
ffffffffc0201b40:	00004697          	auipc	a3,0x4
ffffffffc0201b44:	8d068693          	addi	a3,a3,-1840 # ffffffffc0205410 <commands+0xdb0>
ffffffffc0201b48:	00003617          	auipc	a2,0x3
ffffffffc0201b4c:	23860613          	addi	a2,a2,568 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201b50:	0f400593          	li	a1,244
ffffffffc0201b54:	00003517          	auipc	a0,0x3
ffffffffc0201b58:	6e450513          	addi	a0,a0,1764 # ffffffffc0205238 <commands+0xbd8>
ffffffffc0201b5c:	da6fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(ret==0);
ffffffffc0201b60:	00004697          	auipc	a3,0x4
ffffffffc0201b64:	95068693          	addi	a3,a3,-1712 # ffffffffc02054b0 <commands+0xe50>
ffffffffc0201b68:	00003617          	auipc	a2,0x3
ffffffffc0201b6c:	21860613          	addi	a2,a2,536 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201b70:	10300593          	li	a1,259
ffffffffc0201b74:	00003517          	auipc	a0,0x3
ffffffffc0201b78:	6c450513          	addi	a0,a0,1732 # ffffffffc0205238 <commands+0xbd8>
ffffffffc0201b7c:	d86fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0201b80:	00003697          	auipc	a3,0x3
ffffffffc0201b84:	53868693          	addi	a3,a3,1336 # ffffffffc02050b8 <commands+0xa58>
ffffffffc0201b88:	00003617          	auipc	a2,0x3
ffffffffc0201b8c:	1f860613          	addi	a2,a2,504 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201b90:	0cd00593          	li	a1,205
ffffffffc0201b94:	00003517          	auipc	a0,0x3
ffffffffc0201b98:	6a450513          	addi	a0,a0,1700 # ffffffffc0205238 <commands+0xbd8>
ffffffffc0201b9c:	d66fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(vma != NULL);
ffffffffc0201ba0:	00003697          	auipc	a3,0x3
ffffffffc0201ba4:	5c068693          	addi	a3,a3,1472 # ffffffffc0205160 <commands+0xb00>
ffffffffc0201ba8:	00003617          	auipc	a2,0x3
ffffffffc0201bac:	1d860613          	addi	a2,a2,472 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201bb0:	0d000593          	li	a1,208
ffffffffc0201bb4:	00003517          	auipc	a0,0x3
ffffffffc0201bb8:	68450513          	addi	a0,a0,1668 # ffffffffc0205238 <commands+0xbd8>
ffffffffc0201bbc:	d46fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0201bc0:	00003697          	auipc	a3,0x3
ffffffffc0201bc4:	74868693          	addi	a3,a3,1864 # ffffffffc0205308 <commands+0xca8>
ffffffffc0201bc8:	00003617          	auipc	a2,0x3
ffffffffc0201bcc:	1b860613          	addi	a2,a2,440 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201bd0:	0d800593          	li	a1,216
ffffffffc0201bd4:	00003517          	auipc	a0,0x3
ffffffffc0201bd8:	66450513          	addi	a0,a0,1636 # ffffffffc0205238 <commands+0xbd8>
ffffffffc0201bdc:	d26fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(total == nr_free_pages());
ffffffffc0201be0:	00003697          	auipc	a3,0x3
ffffffffc0201be4:	69068693          	addi	a3,a3,1680 # ffffffffc0205270 <commands+0xc10>
ffffffffc0201be8:	00003617          	auipc	a2,0x3
ffffffffc0201bec:	19860613          	addi	a2,a2,408 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201bf0:	0c000593          	li	a1,192
ffffffffc0201bf4:	00003517          	auipc	a0,0x3
ffffffffc0201bf8:	64450513          	addi	a0,a0,1604 # ffffffffc0205238 <commands+0xbd8>
ffffffffc0201bfc:	d06fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==2);
ffffffffc0201c00:	00003697          	auipc	a3,0x3
ffffffffc0201c04:	7e068693          	addi	a3,a3,2016 # ffffffffc02053e0 <commands+0xd80>
ffffffffc0201c08:	00003617          	auipc	a2,0x3
ffffffffc0201c0c:	17860613          	addi	a2,a2,376 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201c10:	09800593          	li	a1,152
ffffffffc0201c14:	00003517          	auipc	a0,0x3
ffffffffc0201c18:	62450513          	addi	a0,a0,1572 # ffffffffc0205238 <commands+0xbd8>
ffffffffc0201c1c:	ce6fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==2);
ffffffffc0201c20:	00003697          	auipc	a3,0x3
ffffffffc0201c24:	7c068693          	addi	a3,a3,1984 # ffffffffc02053e0 <commands+0xd80>
ffffffffc0201c28:	00003617          	auipc	a2,0x3
ffffffffc0201c2c:	15860613          	addi	a2,a2,344 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201c30:	09a00593          	li	a1,154
ffffffffc0201c34:	00003517          	auipc	a0,0x3
ffffffffc0201c38:	60450513          	addi	a0,a0,1540 # ffffffffc0205238 <commands+0xbd8>
ffffffffc0201c3c:	cc6fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==3);
ffffffffc0201c40:	00003697          	auipc	a3,0x3
ffffffffc0201c44:	7b068693          	addi	a3,a3,1968 # ffffffffc02053f0 <commands+0xd90>
ffffffffc0201c48:	00003617          	auipc	a2,0x3
ffffffffc0201c4c:	13860613          	addi	a2,a2,312 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201c50:	09c00593          	li	a1,156
ffffffffc0201c54:	00003517          	auipc	a0,0x3
ffffffffc0201c58:	5e450513          	addi	a0,a0,1508 # ffffffffc0205238 <commands+0xbd8>
ffffffffc0201c5c:	ca6fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==3);
ffffffffc0201c60:	00003697          	auipc	a3,0x3
ffffffffc0201c64:	79068693          	addi	a3,a3,1936 # ffffffffc02053f0 <commands+0xd90>
ffffffffc0201c68:	00003617          	auipc	a2,0x3
ffffffffc0201c6c:	11860613          	addi	a2,a2,280 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201c70:	09e00593          	li	a1,158
ffffffffc0201c74:	00003517          	auipc	a0,0x3
ffffffffc0201c78:	5c450513          	addi	a0,a0,1476 # ffffffffc0205238 <commands+0xbd8>
ffffffffc0201c7c:	c86fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==1);
ffffffffc0201c80:	00003697          	auipc	a3,0x3
ffffffffc0201c84:	75068693          	addi	a3,a3,1872 # ffffffffc02053d0 <commands+0xd70>
ffffffffc0201c88:	00003617          	auipc	a2,0x3
ffffffffc0201c8c:	0f860613          	addi	a2,a2,248 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201c90:	09400593          	li	a1,148
ffffffffc0201c94:	00003517          	auipc	a0,0x3
ffffffffc0201c98:	5a450513          	addi	a0,a0,1444 # ffffffffc0205238 <commands+0xbd8>
ffffffffc0201c9c:	c66fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==1);
ffffffffc0201ca0:	00003697          	auipc	a3,0x3
ffffffffc0201ca4:	73068693          	addi	a3,a3,1840 # ffffffffc02053d0 <commands+0xd70>
ffffffffc0201ca8:	00003617          	auipc	a2,0x3
ffffffffc0201cac:	0d860613          	addi	a2,a2,216 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201cb0:	09600593          	li	a1,150
ffffffffc0201cb4:	00003517          	auipc	a0,0x3
ffffffffc0201cb8:	58450513          	addi	a0,a0,1412 # ffffffffc0205238 <commands+0xbd8>
ffffffffc0201cbc:	c46fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(mm != NULL);
ffffffffc0201cc0:	00003697          	auipc	a3,0x3
ffffffffc0201cc4:	4c868693          	addi	a3,a3,1224 # ffffffffc0205188 <commands+0xb28>
ffffffffc0201cc8:	00003617          	auipc	a2,0x3
ffffffffc0201ccc:	0b860613          	addi	a2,a2,184 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201cd0:	0c500593          	li	a1,197
ffffffffc0201cd4:	00003517          	auipc	a0,0x3
ffffffffc0201cd8:	56450513          	addi	a0,a0,1380 # ffffffffc0205238 <commands+0xbd8>
ffffffffc0201cdc:	c26fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0201ce0:	00003697          	auipc	a3,0x3
ffffffffc0201ce4:	5d868693          	addi	a3,a3,1496 # ffffffffc02052b8 <commands+0xc58>
ffffffffc0201ce8:	00003617          	auipc	a2,0x3
ffffffffc0201cec:	09860613          	addi	a2,a2,152 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201cf0:	0c800593          	li	a1,200
ffffffffc0201cf4:	00003517          	auipc	a0,0x3
ffffffffc0201cf8:	54450513          	addi	a0,a0,1348 # ffffffffc0205238 <commands+0xbd8>
ffffffffc0201cfc:	c06fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0201d00:	00003697          	auipc	a3,0x3
ffffffffc0201d04:	68068693          	addi	a3,a3,1664 # ffffffffc0205380 <commands+0xd20>
ffffffffc0201d08:	00003617          	auipc	a2,0x3
ffffffffc0201d0c:	07860613          	addi	a2,a2,120 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201d10:	0eb00593          	li	a1,235
ffffffffc0201d14:	00003517          	auipc	a0,0x3
ffffffffc0201d18:	52450513          	addi	a0,a0,1316 # ffffffffc0205238 <commands+0xbd8>
ffffffffc0201d1c:	be6fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201d20 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0201d20:	00010797          	auipc	a5,0x10
ffffffffc0201d24:	8107b783          	ld	a5,-2032(a5) # ffffffffc0211530 <sm>
ffffffffc0201d28:	6b9c                	ld	a5,16(a5)
ffffffffc0201d2a:	8782                	jr	a5

ffffffffc0201d2c <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0201d2c:	00010797          	auipc	a5,0x10
ffffffffc0201d30:	8047b783          	ld	a5,-2044(a5) # ffffffffc0211530 <sm>
ffffffffc0201d34:	739c                	ld	a5,32(a5)
ffffffffc0201d36:	8782                	jr	a5

ffffffffc0201d38 <swap_out>:
{
ffffffffc0201d38:	711d                	addi	sp,sp,-96
ffffffffc0201d3a:	ec86                	sd	ra,88(sp)
ffffffffc0201d3c:	e8a2                	sd	s0,80(sp)
ffffffffc0201d3e:	e4a6                	sd	s1,72(sp)
ffffffffc0201d40:	e0ca                	sd	s2,64(sp)
ffffffffc0201d42:	fc4e                	sd	s3,56(sp)
ffffffffc0201d44:	f852                	sd	s4,48(sp)
ffffffffc0201d46:	f456                	sd	s5,40(sp)
ffffffffc0201d48:	f05a                	sd	s6,32(sp)
ffffffffc0201d4a:	ec5e                	sd	s7,24(sp)
ffffffffc0201d4c:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0201d4e:	cde9                	beqz	a1,ffffffffc0201e28 <swap_out+0xf0>
ffffffffc0201d50:	8a2e                	mv	s4,a1
ffffffffc0201d52:	892a                	mv	s2,a0
ffffffffc0201d54:	8ab2                	mv	s5,a2
ffffffffc0201d56:	4401                	li	s0,0
ffffffffc0201d58:	0000f997          	auipc	s3,0xf
ffffffffc0201d5c:	7d898993          	addi	s3,s3,2008 # ffffffffc0211530 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0201d60:	00003b17          	auipc	s6,0x3
ffffffffc0201d64:	7f8b0b13          	addi	s6,s6,2040 # ffffffffc0205558 <commands+0xef8>
                    cprintf("SWAP: failed to save\n");
ffffffffc0201d68:	00003b97          	auipc	s7,0x3
ffffffffc0201d6c:	7d8b8b93          	addi	s7,s7,2008 # ffffffffc0205540 <commands+0xee0>
ffffffffc0201d70:	a825                	j	ffffffffc0201da8 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0201d72:	67a2                	ld	a5,8(sp)
ffffffffc0201d74:	8626                	mv	a2,s1
ffffffffc0201d76:	85a2                	mv	a1,s0
ffffffffc0201d78:	63b4                	ld	a3,64(a5)
ffffffffc0201d7a:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0201d7c:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0201d7e:	82b1                	srli	a3,a3,0xc
ffffffffc0201d80:	0685                	addi	a3,a3,1
ffffffffc0201d82:	b38fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0201d86:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0201d88:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0201d8a:	613c                	ld	a5,64(a0)
ffffffffc0201d8c:	83b1                	srli	a5,a5,0xc
ffffffffc0201d8e:	0785                	addi	a5,a5,1
ffffffffc0201d90:	07a2                	slli	a5,a5,0x8
ffffffffc0201d92:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0201d96:	4d3000ef          	jal	ra,ffffffffc0202a68 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0201d9a:	01893503          	ld	a0,24(s2)
ffffffffc0201d9e:	85a6                	mv	a1,s1
ffffffffc0201da0:	531010ef          	jal	ra,ffffffffc0203ad0 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0201da4:	048a0d63          	beq	s4,s0,ffffffffc0201dfe <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0201da8:	0009b783          	ld	a5,0(s3)
ffffffffc0201dac:	8656                	mv	a2,s5
ffffffffc0201dae:	002c                	addi	a1,sp,8
ffffffffc0201db0:	7b9c                	ld	a5,48(a5)
ffffffffc0201db2:	854a                	mv	a0,s2
ffffffffc0201db4:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0201db6:	e12d                	bnez	a0,ffffffffc0201e18 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0201db8:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201dba:	01893503          	ld	a0,24(s2)
ffffffffc0201dbe:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0201dc0:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201dc2:	85a6                	mv	a1,s1
ffffffffc0201dc4:	51f000ef          	jal	ra,ffffffffc0202ae2 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0201dc8:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201dca:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0201dcc:	8b85                	andi	a5,a5,1
ffffffffc0201dce:	cfb9                	beqz	a5,ffffffffc0201e2c <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0201dd0:	65a2                	ld	a1,8(sp)
ffffffffc0201dd2:	61bc                	ld	a5,64(a1)
ffffffffc0201dd4:	83b1                	srli	a5,a5,0xc
ffffffffc0201dd6:	0785                	addi	a5,a5,1
ffffffffc0201dd8:	00879513          	slli	a0,a5,0x8
ffffffffc0201ddc:	026020ef          	jal	ra,ffffffffc0203e02 <swapfs_write>
ffffffffc0201de0:	d949                	beqz	a0,ffffffffc0201d72 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0201de2:	855e                	mv	a0,s7
ffffffffc0201de4:	ad6fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0201de8:	0009b783          	ld	a5,0(s3)
ffffffffc0201dec:	6622                	ld	a2,8(sp)
ffffffffc0201dee:	4681                	li	a3,0
ffffffffc0201df0:	739c                	ld	a5,32(a5)
ffffffffc0201df2:	85a6                	mv	a1,s1
ffffffffc0201df4:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0201df6:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0201df8:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0201dfa:	fa8a17e3          	bne	s4,s0,ffffffffc0201da8 <swap_out+0x70>
}
ffffffffc0201dfe:	60e6                	ld	ra,88(sp)
ffffffffc0201e00:	8522                	mv	a0,s0
ffffffffc0201e02:	6446                	ld	s0,80(sp)
ffffffffc0201e04:	64a6                	ld	s1,72(sp)
ffffffffc0201e06:	6906                	ld	s2,64(sp)
ffffffffc0201e08:	79e2                	ld	s3,56(sp)
ffffffffc0201e0a:	7a42                	ld	s4,48(sp)
ffffffffc0201e0c:	7aa2                	ld	s5,40(sp)
ffffffffc0201e0e:	7b02                	ld	s6,32(sp)
ffffffffc0201e10:	6be2                	ld	s7,24(sp)
ffffffffc0201e12:	6c42                	ld	s8,16(sp)
ffffffffc0201e14:	6125                	addi	sp,sp,96
ffffffffc0201e16:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0201e18:	85a2                	mv	a1,s0
ffffffffc0201e1a:	00003517          	auipc	a0,0x3
ffffffffc0201e1e:	6de50513          	addi	a0,a0,1758 # ffffffffc02054f8 <commands+0xe98>
ffffffffc0201e22:	a98fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
                  break;
ffffffffc0201e26:	bfe1                	j	ffffffffc0201dfe <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0201e28:	4401                	li	s0,0
ffffffffc0201e2a:	bfd1                	j	ffffffffc0201dfe <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0201e2c:	00003697          	auipc	a3,0x3
ffffffffc0201e30:	6fc68693          	addi	a3,a3,1788 # ffffffffc0205528 <commands+0xec8>
ffffffffc0201e34:	00003617          	auipc	a2,0x3
ffffffffc0201e38:	f4c60613          	addi	a2,a2,-180 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201e3c:	06900593          	li	a1,105
ffffffffc0201e40:	00003517          	auipc	a0,0x3
ffffffffc0201e44:	3f850513          	addi	a0,a0,1016 # ffffffffc0205238 <commands+0xbd8>
ffffffffc0201e48:	abafe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201e4c <swap_in>:
{
ffffffffc0201e4c:	7179                	addi	sp,sp,-48
ffffffffc0201e4e:	e84a                	sd	s2,16(sp)
ffffffffc0201e50:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0201e52:	4505                	li	a0,1
{
ffffffffc0201e54:	ec26                	sd	s1,24(sp)
ffffffffc0201e56:	e44e                	sd	s3,8(sp)
ffffffffc0201e58:	f406                	sd	ra,40(sp)
ffffffffc0201e5a:	f022                	sd	s0,32(sp)
ffffffffc0201e5c:	84ae                	mv	s1,a1
ffffffffc0201e5e:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0201e60:	377000ef          	jal	ra,ffffffffc02029d6 <alloc_pages>
     assert(result!=NULL);
ffffffffc0201e64:	c129                	beqz	a0,ffffffffc0201ea6 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0201e66:	842a                	mv	s0,a0
ffffffffc0201e68:	01893503          	ld	a0,24(s2)
ffffffffc0201e6c:	4601                	li	a2,0
ffffffffc0201e6e:	85a6                	mv	a1,s1
ffffffffc0201e70:	473000ef          	jal	ra,ffffffffc0202ae2 <get_pte>
ffffffffc0201e74:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0201e76:	6108                	ld	a0,0(a0)
ffffffffc0201e78:	85a2                	mv	a1,s0
ffffffffc0201e7a:	6ef010ef          	jal	ra,ffffffffc0203d68 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0201e7e:	00093583          	ld	a1,0(s2)
ffffffffc0201e82:	8626                	mv	a2,s1
ffffffffc0201e84:	00003517          	auipc	a0,0x3
ffffffffc0201e88:	72450513          	addi	a0,a0,1828 # ffffffffc02055a8 <commands+0xf48>
ffffffffc0201e8c:	81a1                	srli	a1,a1,0x8
ffffffffc0201e8e:	a2cfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0201e92:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0201e94:	0089b023          	sd	s0,0(s3)
}
ffffffffc0201e98:	7402                	ld	s0,32(sp)
ffffffffc0201e9a:	64e2                	ld	s1,24(sp)
ffffffffc0201e9c:	6942                	ld	s2,16(sp)
ffffffffc0201e9e:	69a2                	ld	s3,8(sp)
ffffffffc0201ea0:	4501                	li	a0,0
ffffffffc0201ea2:	6145                	addi	sp,sp,48
ffffffffc0201ea4:	8082                	ret
     assert(result!=NULL);
ffffffffc0201ea6:	00003697          	auipc	a3,0x3
ffffffffc0201eaa:	6f268693          	addi	a3,a3,1778 # ffffffffc0205598 <commands+0xf38>
ffffffffc0201eae:	00003617          	auipc	a2,0x3
ffffffffc0201eb2:	ed260613          	addi	a2,a2,-302 # ffffffffc0204d80 <commands+0x720>
ffffffffc0201eb6:	07f00593          	li	a1,127
ffffffffc0201eba:	00003517          	auipc	a0,0x3
ffffffffc0201ebe:	37e50513          	addi	a0,a0,894 # ffffffffc0205238 <commands+0xbd8>
ffffffffc0201ec2:	a40fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201ec6 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0201ec6:	0000f797          	auipc	a5,0xf
ffffffffc0201eca:	21a78793          	addi	a5,a5,538 # ffffffffc02110e0 <free_area>
ffffffffc0201ece:	e79c                	sd	a5,8(a5)
ffffffffc0201ed0:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0201ed2:	0007a823          	sw	zero,16(a5)
}
ffffffffc0201ed6:	8082                	ret

ffffffffc0201ed8 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0201ed8:	0000f517          	auipc	a0,0xf
ffffffffc0201edc:	21856503          	lwu	a0,536(a0) # ffffffffc02110f0 <free_area+0x10>
ffffffffc0201ee0:	8082                	ret

ffffffffc0201ee2 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0201ee2:	715d                	addi	sp,sp,-80
ffffffffc0201ee4:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0201ee6:	0000f417          	auipc	s0,0xf
ffffffffc0201eea:	1fa40413          	addi	s0,s0,506 # ffffffffc02110e0 <free_area>
ffffffffc0201eee:	641c                	ld	a5,8(s0)
ffffffffc0201ef0:	e486                	sd	ra,72(sp)
ffffffffc0201ef2:	fc26                	sd	s1,56(sp)
ffffffffc0201ef4:	f84a                	sd	s2,48(sp)
ffffffffc0201ef6:	f44e                	sd	s3,40(sp)
ffffffffc0201ef8:	f052                	sd	s4,32(sp)
ffffffffc0201efa:	ec56                	sd	s5,24(sp)
ffffffffc0201efc:	e85a                	sd	s6,16(sp)
ffffffffc0201efe:	e45e                	sd	s7,8(sp)
ffffffffc0201f00:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201f02:	2c878763          	beq	a5,s0,ffffffffc02021d0 <default_check+0x2ee>
    int count = 0, total = 0;
ffffffffc0201f06:	4481                	li	s1,0
ffffffffc0201f08:	4901                	li	s2,0
ffffffffc0201f0a:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0201f0e:	8b09                	andi	a4,a4,2
ffffffffc0201f10:	2c070463          	beqz	a4,ffffffffc02021d8 <default_check+0x2f6>
        count ++, total += p->property;
ffffffffc0201f14:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201f18:	679c                	ld	a5,8(a5)
ffffffffc0201f1a:	2905                	addiw	s2,s2,1
ffffffffc0201f1c:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201f1e:	fe8796e3          	bne	a5,s0,ffffffffc0201f0a <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0201f22:	89a6                	mv	s3,s1
ffffffffc0201f24:	385000ef          	jal	ra,ffffffffc0202aa8 <nr_free_pages>
ffffffffc0201f28:	71351863          	bne	a0,s3,ffffffffc0202638 <default_check+0x756>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201f2c:	4505                	li	a0,1
ffffffffc0201f2e:	2a9000ef          	jal	ra,ffffffffc02029d6 <alloc_pages>
ffffffffc0201f32:	8a2a                	mv	s4,a0
ffffffffc0201f34:	44050263          	beqz	a0,ffffffffc0202378 <default_check+0x496>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201f38:	4505                	li	a0,1
ffffffffc0201f3a:	29d000ef          	jal	ra,ffffffffc02029d6 <alloc_pages>
ffffffffc0201f3e:	89aa                	mv	s3,a0
ffffffffc0201f40:	70050c63          	beqz	a0,ffffffffc0202658 <default_check+0x776>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201f44:	4505                	li	a0,1
ffffffffc0201f46:	291000ef          	jal	ra,ffffffffc02029d6 <alloc_pages>
ffffffffc0201f4a:	8aaa                	mv	s5,a0
ffffffffc0201f4c:	4a050663          	beqz	a0,ffffffffc02023f8 <default_check+0x516>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201f50:	2b3a0463          	beq	s4,s3,ffffffffc02021f8 <default_check+0x316>
ffffffffc0201f54:	2aaa0263          	beq	s4,a0,ffffffffc02021f8 <default_check+0x316>
ffffffffc0201f58:	2aa98063          	beq	s3,a0,ffffffffc02021f8 <default_check+0x316>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201f5c:	000a2783          	lw	a5,0(s4)
ffffffffc0201f60:	2a079c63          	bnez	a5,ffffffffc0202218 <default_check+0x336>
ffffffffc0201f64:	0009a783          	lw	a5,0(s3)
ffffffffc0201f68:	2a079863          	bnez	a5,ffffffffc0202218 <default_check+0x336>
ffffffffc0201f6c:	411c                	lw	a5,0(a0)
ffffffffc0201f6e:	2a079563          	bnez	a5,ffffffffc0202218 <default_check+0x336>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201f72:	0000f797          	auipc	a5,0xf
ffffffffc0201f76:	5e67b783          	ld	a5,1510(a5) # ffffffffc0211558 <pages>
ffffffffc0201f7a:	40fa0733          	sub	a4,s4,a5
ffffffffc0201f7e:	870d                	srai	a4,a4,0x3
ffffffffc0201f80:	00004597          	auipc	a1,0x4
ffffffffc0201f84:	2a05b583          	ld	a1,672(a1) # ffffffffc0206220 <error_string+0x38>
ffffffffc0201f88:	02b70733          	mul	a4,a4,a1
ffffffffc0201f8c:	00004617          	auipc	a2,0x4
ffffffffc0201f90:	29c63603          	ld	a2,668(a2) # ffffffffc0206228 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201f94:	0000f697          	auipc	a3,0xf
ffffffffc0201f98:	5bc6b683          	ld	a3,1468(a3) # ffffffffc0211550 <npage>
ffffffffc0201f9c:	06b2                	slli	a3,a3,0xc
ffffffffc0201f9e:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fa0:	0732                	slli	a4,a4,0xc
ffffffffc0201fa2:	28d77b63          	bgeu	a4,a3,ffffffffc0202238 <default_check+0x356>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fa6:	40f98733          	sub	a4,s3,a5
ffffffffc0201faa:	870d                	srai	a4,a4,0x3
ffffffffc0201fac:	02b70733          	mul	a4,a4,a1
ffffffffc0201fb0:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fb2:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201fb4:	4cd77263          	bgeu	a4,a3,ffffffffc0202478 <default_check+0x596>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fb8:	40f507b3          	sub	a5,a0,a5
ffffffffc0201fbc:	878d                	srai	a5,a5,0x3
ffffffffc0201fbe:	02b787b3          	mul	a5,a5,a1
ffffffffc0201fc2:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fc4:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201fc6:	30d7f963          	bgeu	a5,a3,ffffffffc02022d8 <default_check+0x3f6>
    assert(alloc_page() == NULL);
ffffffffc0201fca:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201fcc:	00043c03          	ld	s8,0(s0)
ffffffffc0201fd0:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0201fd4:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0201fd8:	e400                	sd	s0,8(s0)
ffffffffc0201fda:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0201fdc:	0000f797          	auipc	a5,0xf
ffffffffc0201fe0:	1007aa23          	sw	zero,276(a5) # ffffffffc02110f0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0201fe4:	1f3000ef          	jal	ra,ffffffffc02029d6 <alloc_pages>
ffffffffc0201fe8:	2c051863          	bnez	a0,ffffffffc02022b8 <default_check+0x3d6>
    free_page(p0);
ffffffffc0201fec:	4585                	li	a1,1
ffffffffc0201fee:	8552                	mv	a0,s4
ffffffffc0201ff0:	279000ef          	jal	ra,ffffffffc0202a68 <free_pages>
    free_page(p1);
ffffffffc0201ff4:	4585                	li	a1,1
ffffffffc0201ff6:	854e                	mv	a0,s3
ffffffffc0201ff8:	271000ef          	jal	ra,ffffffffc0202a68 <free_pages>
    free_page(p2);
ffffffffc0201ffc:	4585                	li	a1,1
ffffffffc0201ffe:	8556                	mv	a0,s5
ffffffffc0202000:	269000ef          	jal	ra,ffffffffc0202a68 <free_pages>
    assert(nr_free == 3);
ffffffffc0202004:	4818                	lw	a4,16(s0)
ffffffffc0202006:	478d                	li	a5,3
ffffffffc0202008:	28f71863          	bne	a4,a5,ffffffffc0202298 <default_check+0x3b6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020200c:	4505                	li	a0,1
ffffffffc020200e:	1c9000ef          	jal	ra,ffffffffc02029d6 <alloc_pages>
ffffffffc0202012:	89aa                	mv	s3,a0
ffffffffc0202014:	26050263          	beqz	a0,ffffffffc0202278 <default_check+0x396>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202018:	4505                	li	a0,1
ffffffffc020201a:	1bd000ef          	jal	ra,ffffffffc02029d6 <alloc_pages>
ffffffffc020201e:	8aaa                	mv	s5,a0
ffffffffc0202020:	3a050c63          	beqz	a0,ffffffffc02023d8 <default_check+0x4f6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202024:	4505                	li	a0,1
ffffffffc0202026:	1b1000ef          	jal	ra,ffffffffc02029d6 <alloc_pages>
ffffffffc020202a:	8a2a                	mv	s4,a0
ffffffffc020202c:	38050663          	beqz	a0,ffffffffc02023b8 <default_check+0x4d6>
    assert(alloc_page() == NULL);
ffffffffc0202030:	4505                	li	a0,1
ffffffffc0202032:	1a5000ef          	jal	ra,ffffffffc02029d6 <alloc_pages>
ffffffffc0202036:	36051163          	bnez	a0,ffffffffc0202398 <default_check+0x4b6>
    free_page(p0);
ffffffffc020203a:	4585                	li	a1,1
ffffffffc020203c:	854e                	mv	a0,s3
ffffffffc020203e:	22b000ef          	jal	ra,ffffffffc0202a68 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0202042:	641c                	ld	a5,8(s0)
ffffffffc0202044:	20878a63          	beq	a5,s0,ffffffffc0202258 <default_check+0x376>
    assert((p = alloc_page()) == p0);
ffffffffc0202048:	4505                	li	a0,1
ffffffffc020204a:	18d000ef          	jal	ra,ffffffffc02029d6 <alloc_pages>
ffffffffc020204e:	30a99563          	bne	s3,a0,ffffffffc0202358 <default_check+0x476>
    assert(alloc_page() == NULL);
ffffffffc0202052:	4505                	li	a0,1
ffffffffc0202054:	183000ef          	jal	ra,ffffffffc02029d6 <alloc_pages>
ffffffffc0202058:	2e051063          	bnez	a0,ffffffffc0202338 <default_check+0x456>
    assert(nr_free == 0);
ffffffffc020205c:	481c                	lw	a5,16(s0)
ffffffffc020205e:	2a079d63          	bnez	a5,ffffffffc0202318 <default_check+0x436>
    free_page(p);
ffffffffc0202062:	854e                	mv	a0,s3
ffffffffc0202064:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0202066:	01843023          	sd	s8,0(s0)
ffffffffc020206a:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc020206e:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0202072:	1f7000ef          	jal	ra,ffffffffc0202a68 <free_pages>
    free_page(p1);
ffffffffc0202076:	4585                	li	a1,1
ffffffffc0202078:	8556                	mv	a0,s5
ffffffffc020207a:	1ef000ef          	jal	ra,ffffffffc0202a68 <free_pages>
    free_page(p2);
ffffffffc020207e:	4585                	li	a1,1
ffffffffc0202080:	8552                	mv	a0,s4
ffffffffc0202082:	1e7000ef          	jal	ra,ffffffffc0202a68 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0202086:	4515                	li	a0,5
ffffffffc0202088:	14f000ef          	jal	ra,ffffffffc02029d6 <alloc_pages>
ffffffffc020208c:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc020208e:	26050563          	beqz	a0,ffffffffc02022f8 <default_check+0x416>
ffffffffc0202092:	651c                	ld	a5,8(a0)
ffffffffc0202094:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0202096:	8b85                	andi	a5,a5,1
ffffffffc0202098:	54079063          	bnez	a5,ffffffffc02025d8 <default_check+0x6f6>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc020209c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc020209e:	00043b03          	ld	s6,0(s0)
ffffffffc02020a2:	00843a83          	ld	s5,8(s0)
ffffffffc02020a6:	e000                	sd	s0,0(s0)
ffffffffc02020a8:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc02020aa:	12d000ef          	jal	ra,ffffffffc02029d6 <alloc_pages>
ffffffffc02020ae:	50051563          	bnez	a0,ffffffffc02025b8 <default_check+0x6d6>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc02020b2:	09098a13          	addi	s4,s3,144
ffffffffc02020b6:	8552                	mv	a0,s4
ffffffffc02020b8:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc02020ba:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc02020be:	0000f797          	auipc	a5,0xf
ffffffffc02020c2:	0207a923          	sw	zero,50(a5) # ffffffffc02110f0 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc02020c6:	1a3000ef          	jal	ra,ffffffffc0202a68 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc02020ca:	4511                	li	a0,4
ffffffffc02020cc:	10b000ef          	jal	ra,ffffffffc02029d6 <alloc_pages>
ffffffffc02020d0:	4c051463          	bnez	a0,ffffffffc0202598 <default_check+0x6b6>
ffffffffc02020d4:	0989b783          	ld	a5,152(s3)
ffffffffc02020d8:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02020da:	8b85                	andi	a5,a5,1
ffffffffc02020dc:	48078e63          	beqz	a5,ffffffffc0202578 <default_check+0x696>
ffffffffc02020e0:	0a89a703          	lw	a4,168(s3)
ffffffffc02020e4:	478d                	li	a5,3
ffffffffc02020e6:	48f71963          	bne	a4,a5,ffffffffc0202578 <default_check+0x696>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02020ea:	450d                	li	a0,3
ffffffffc02020ec:	0eb000ef          	jal	ra,ffffffffc02029d6 <alloc_pages>
ffffffffc02020f0:	8c2a                	mv	s8,a0
ffffffffc02020f2:	46050363          	beqz	a0,ffffffffc0202558 <default_check+0x676>
    assert(alloc_page() == NULL);
ffffffffc02020f6:	4505                	li	a0,1
ffffffffc02020f8:	0df000ef          	jal	ra,ffffffffc02029d6 <alloc_pages>
ffffffffc02020fc:	42051e63          	bnez	a0,ffffffffc0202538 <default_check+0x656>
    assert(p0 + 2 == p1);
ffffffffc0202100:	418a1c63          	bne	s4,s8,ffffffffc0202518 <default_check+0x636>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0202104:	4585                	li	a1,1
ffffffffc0202106:	854e                	mv	a0,s3
ffffffffc0202108:	161000ef          	jal	ra,ffffffffc0202a68 <free_pages>
    free_pages(p1, 3);
ffffffffc020210c:	458d                	li	a1,3
ffffffffc020210e:	8552                	mv	a0,s4
ffffffffc0202110:	159000ef          	jal	ra,ffffffffc0202a68 <free_pages>
ffffffffc0202114:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0202118:	04898c13          	addi	s8,s3,72
ffffffffc020211c:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020211e:	8b85                	andi	a5,a5,1
ffffffffc0202120:	3c078c63          	beqz	a5,ffffffffc02024f8 <default_check+0x616>
ffffffffc0202124:	0189a703          	lw	a4,24(s3)
ffffffffc0202128:	4785                	li	a5,1
ffffffffc020212a:	3cf71763          	bne	a4,a5,ffffffffc02024f8 <default_check+0x616>
ffffffffc020212e:	008a3783          	ld	a5,8(s4)
ffffffffc0202132:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202134:	8b85                	andi	a5,a5,1
ffffffffc0202136:	3a078163          	beqz	a5,ffffffffc02024d8 <default_check+0x5f6>
ffffffffc020213a:	018a2703          	lw	a4,24(s4)
ffffffffc020213e:	478d                	li	a5,3
ffffffffc0202140:	38f71c63          	bne	a4,a5,ffffffffc02024d8 <default_check+0x5f6>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202144:	4505                	li	a0,1
ffffffffc0202146:	091000ef          	jal	ra,ffffffffc02029d6 <alloc_pages>
ffffffffc020214a:	36a99763          	bne	s3,a0,ffffffffc02024b8 <default_check+0x5d6>
    free_page(p0);
ffffffffc020214e:	4585                	li	a1,1
ffffffffc0202150:	119000ef          	jal	ra,ffffffffc0202a68 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202154:	4509                	li	a0,2
ffffffffc0202156:	081000ef          	jal	ra,ffffffffc02029d6 <alloc_pages>
ffffffffc020215a:	32aa1f63          	bne	s4,a0,ffffffffc0202498 <default_check+0x5b6>

    free_pages(p0, 2);
ffffffffc020215e:	4589                	li	a1,2
ffffffffc0202160:	109000ef          	jal	ra,ffffffffc0202a68 <free_pages>
    free_page(p2);
ffffffffc0202164:	4585                	li	a1,1
ffffffffc0202166:	8562                	mv	a0,s8
ffffffffc0202168:	101000ef          	jal	ra,ffffffffc0202a68 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020216c:	4515                	li	a0,5
ffffffffc020216e:	069000ef          	jal	ra,ffffffffc02029d6 <alloc_pages>
ffffffffc0202172:	89aa                	mv	s3,a0
ffffffffc0202174:	48050263          	beqz	a0,ffffffffc02025f8 <default_check+0x716>
    assert(alloc_page() == NULL);
ffffffffc0202178:	4505                	li	a0,1
ffffffffc020217a:	05d000ef          	jal	ra,ffffffffc02029d6 <alloc_pages>
ffffffffc020217e:	2c051d63          	bnez	a0,ffffffffc0202458 <default_check+0x576>

    assert(nr_free == 0);
ffffffffc0202182:	481c                	lw	a5,16(s0)
ffffffffc0202184:	2a079a63          	bnez	a5,ffffffffc0202438 <default_check+0x556>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0202188:	4595                	li	a1,5
ffffffffc020218a:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc020218c:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0202190:	01643023          	sd	s6,0(s0)
ffffffffc0202194:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0202198:	0d1000ef          	jal	ra,ffffffffc0202a68 <free_pages>
    return listelm->next;
ffffffffc020219c:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020219e:	00878963          	beq	a5,s0,ffffffffc02021b0 <default_check+0x2ce>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc02021a2:	ff87a703          	lw	a4,-8(a5)
ffffffffc02021a6:	679c                	ld	a5,8(a5)
ffffffffc02021a8:	397d                	addiw	s2,s2,-1
ffffffffc02021aa:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02021ac:	fe879be3          	bne	a5,s0,ffffffffc02021a2 <default_check+0x2c0>
    }
    assert(count == 0);
ffffffffc02021b0:	26091463          	bnez	s2,ffffffffc0202418 <default_check+0x536>
    assert(total == 0);
ffffffffc02021b4:	46049263          	bnez	s1,ffffffffc0202618 <default_check+0x736>
}
ffffffffc02021b8:	60a6                	ld	ra,72(sp)
ffffffffc02021ba:	6406                	ld	s0,64(sp)
ffffffffc02021bc:	74e2                	ld	s1,56(sp)
ffffffffc02021be:	7942                	ld	s2,48(sp)
ffffffffc02021c0:	79a2                	ld	s3,40(sp)
ffffffffc02021c2:	7a02                	ld	s4,32(sp)
ffffffffc02021c4:	6ae2                	ld	s5,24(sp)
ffffffffc02021c6:	6b42                	ld	s6,16(sp)
ffffffffc02021c8:	6ba2                	ld	s7,8(sp)
ffffffffc02021ca:	6c02                	ld	s8,0(sp)
ffffffffc02021cc:	6161                	addi	sp,sp,80
ffffffffc02021ce:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc02021d0:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc02021d2:	4481                	li	s1,0
ffffffffc02021d4:	4901                	li	s2,0
ffffffffc02021d6:	b3b9                	j	ffffffffc0201f24 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc02021d8:	00003697          	auipc	a3,0x3
ffffffffc02021dc:	08868693          	addi	a3,a3,136 # ffffffffc0205260 <commands+0xc00>
ffffffffc02021e0:	00003617          	auipc	a2,0x3
ffffffffc02021e4:	ba060613          	addi	a2,a2,-1120 # ffffffffc0204d80 <commands+0x720>
ffffffffc02021e8:	0f000593          	li	a1,240
ffffffffc02021ec:	00003517          	auipc	a0,0x3
ffffffffc02021f0:	3fc50513          	addi	a0,a0,1020 # ffffffffc02055e8 <commands+0xf88>
ffffffffc02021f4:	f0ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02021f8:	00003697          	auipc	a3,0x3
ffffffffc02021fc:	46868693          	addi	a3,a3,1128 # ffffffffc0205660 <commands+0x1000>
ffffffffc0202200:	00003617          	auipc	a2,0x3
ffffffffc0202204:	b8060613          	addi	a2,a2,-1152 # ffffffffc0204d80 <commands+0x720>
ffffffffc0202208:	0bd00593          	li	a1,189
ffffffffc020220c:	00003517          	auipc	a0,0x3
ffffffffc0202210:	3dc50513          	addi	a0,a0,988 # ffffffffc02055e8 <commands+0xf88>
ffffffffc0202214:	eeffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202218:	00003697          	auipc	a3,0x3
ffffffffc020221c:	47068693          	addi	a3,a3,1136 # ffffffffc0205688 <commands+0x1028>
ffffffffc0202220:	00003617          	auipc	a2,0x3
ffffffffc0202224:	b6060613          	addi	a2,a2,-1184 # ffffffffc0204d80 <commands+0x720>
ffffffffc0202228:	0be00593          	li	a1,190
ffffffffc020222c:	00003517          	auipc	a0,0x3
ffffffffc0202230:	3bc50513          	addi	a0,a0,956 # ffffffffc02055e8 <commands+0xf88>
ffffffffc0202234:	ecffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202238:	00003697          	auipc	a3,0x3
ffffffffc020223c:	49068693          	addi	a3,a3,1168 # ffffffffc02056c8 <commands+0x1068>
ffffffffc0202240:	00003617          	auipc	a2,0x3
ffffffffc0202244:	b4060613          	addi	a2,a2,-1216 # ffffffffc0204d80 <commands+0x720>
ffffffffc0202248:	0c000593          	li	a1,192
ffffffffc020224c:	00003517          	auipc	a0,0x3
ffffffffc0202250:	39c50513          	addi	a0,a0,924 # ffffffffc02055e8 <commands+0xf88>
ffffffffc0202254:	eaffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0202258:	00003697          	auipc	a3,0x3
ffffffffc020225c:	4f868693          	addi	a3,a3,1272 # ffffffffc0205750 <commands+0x10f0>
ffffffffc0202260:	00003617          	auipc	a2,0x3
ffffffffc0202264:	b2060613          	addi	a2,a2,-1248 # ffffffffc0204d80 <commands+0x720>
ffffffffc0202268:	0d900593          	li	a1,217
ffffffffc020226c:	00003517          	auipc	a0,0x3
ffffffffc0202270:	37c50513          	addi	a0,a0,892 # ffffffffc02055e8 <commands+0xf88>
ffffffffc0202274:	e8ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202278:	00003697          	auipc	a3,0x3
ffffffffc020227c:	38868693          	addi	a3,a3,904 # ffffffffc0205600 <commands+0xfa0>
ffffffffc0202280:	00003617          	auipc	a2,0x3
ffffffffc0202284:	b0060613          	addi	a2,a2,-1280 # ffffffffc0204d80 <commands+0x720>
ffffffffc0202288:	0d200593          	li	a1,210
ffffffffc020228c:	00003517          	auipc	a0,0x3
ffffffffc0202290:	35c50513          	addi	a0,a0,860 # ffffffffc02055e8 <commands+0xf88>
ffffffffc0202294:	e6ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 3);
ffffffffc0202298:	00003697          	auipc	a3,0x3
ffffffffc020229c:	4a868693          	addi	a3,a3,1192 # ffffffffc0205740 <commands+0x10e0>
ffffffffc02022a0:	00003617          	auipc	a2,0x3
ffffffffc02022a4:	ae060613          	addi	a2,a2,-1312 # ffffffffc0204d80 <commands+0x720>
ffffffffc02022a8:	0d000593          	li	a1,208
ffffffffc02022ac:	00003517          	auipc	a0,0x3
ffffffffc02022b0:	33c50513          	addi	a0,a0,828 # ffffffffc02055e8 <commands+0xf88>
ffffffffc02022b4:	e4ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02022b8:	00003697          	auipc	a3,0x3
ffffffffc02022bc:	47068693          	addi	a3,a3,1136 # ffffffffc0205728 <commands+0x10c8>
ffffffffc02022c0:	00003617          	auipc	a2,0x3
ffffffffc02022c4:	ac060613          	addi	a2,a2,-1344 # ffffffffc0204d80 <commands+0x720>
ffffffffc02022c8:	0cb00593          	li	a1,203
ffffffffc02022cc:	00003517          	auipc	a0,0x3
ffffffffc02022d0:	31c50513          	addi	a0,a0,796 # ffffffffc02055e8 <commands+0xf88>
ffffffffc02022d4:	e2ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02022d8:	00003697          	auipc	a3,0x3
ffffffffc02022dc:	43068693          	addi	a3,a3,1072 # ffffffffc0205708 <commands+0x10a8>
ffffffffc02022e0:	00003617          	auipc	a2,0x3
ffffffffc02022e4:	aa060613          	addi	a2,a2,-1376 # ffffffffc0204d80 <commands+0x720>
ffffffffc02022e8:	0c200593          	li	a1,194
ffffffffc02022ec:	00003517          	auipc	a0,0x3
ffffffffc02022f0:	2fc50513          	addi	a0,a0,764 # ffffffffc02055e8 <commands+0xf88>
ffffffffc02022f4:	e0ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 != NULL);
ffffffffc02022f8:	00003697          	auipc	a3,0x3
ffffffffc02022fc:	49068693          	addi	a3,a3,1168 # ffffffffc0205788 <commands+0x1128>
ffffffffc0202300:	00003617          	auipc	a2,0x3
ffffffffc0202304:	a8060613          	addi	a2,a2,-1408 # ffffffffc0204d80 <commands+0x720>
ffffffffc0202308:	0f800593          	li	a1,248
ffffffffc020230c:	00003517          	auipc	a0,0x3
ffffffffc0202310:	2dc50513          	addi	a0,a0,732 # ffffffffc02055e8 <commands+0xf88>
ffffffffc0202314:	deffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 0);
ffffffffc0202318:	00003697          	auipc	a3,0x3
ffffffffc020231c:	0f868693          	addi	a3,a3,248 # ffffffffc0205410 <commands+0xdb0>
ffffffffc0202320:	00003617          	auipc	a2,0x3
ffffffffc0202324:	a6060613          	addi	a2,a2,-1440 # ffffffffc0204d80 <commands+0x720>
ffffffffc0202328:	0df00593          	li	a1,223
ffffffffc020232c:	00003517          	auipc	a0,0x3
ffffffffc0202330:	2bc50513          	addi	a0,a0,700 # ffffffffc02055e8 <commands+0xf88>
ffffffffc0202334:	dcffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202338:	00003697          	auipc	a3,0x3
ffffffffc020233c:	3f068693          	addi	a3,a3,1008 # ffffffffc0205728 <commands+0x10c8>
ffffffffc0202340:	00003617          	auipc	a2,0x3
ffffffffc0202344:	a4060613          	addi	a2,a2,-1472 # ffffffffc0204d80 <commands+0x720>
ffffffffc0202348:	0dd00593          	li	a1,221
ffffffffc020234c:	00003517          	auipc	a0,0x3
ffffffffc0202350:	29c50513          	addi	a0,a0,668 # ffffffffc02055e8 <commands+0xf88>
ffffffffc0202354:	daffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0202358:	00003697          	auipc	a3,0x3
ffffffffc020235c:	41068693          	addi	a3,a3,1040 # ffffffffc0205768 <commands+0x1108>
ffffffffc0202360:	00003617          	auipc	a2,0x3
ffffffffc0202364:	a2060613          	addi	a2,a2,-1504 # ffffffffc0204d80 <commands+0x720>
ffffffffc0202368:	0dc00593          	li	a1,220
ffffffffc020236c:	00003517          	auipc	a0,0x3
ffffffffc0202370:	27c50513          	addi	a0,a0,636 # ffffffffc02055e8 <commands+0xf88>
ffffffffc0202374:	d8ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202378:	00003697          	auipc	a3,0x3
ffffffffc020237c:	28868693          	addi	a3,a3,648 # ffffffffc0205600 <commands+0xfa0>
ffffffffc0202380:	00003617          	auipc	a2,0x3
ffffffffc0202384:	a0060613          	addi	a2,a2,-1536 # ffffffffc0204d80 <commands+0x720>
ffffffffc0202388:	0b900593          	li	a1,185
ffffffffc020238c:	00003517          	auipc	a0,0x3
ffffffffc0202390:	25c50513          	addi	a0,a0,604 # ffffffffc02055e8 <commands+0xf88>
ffffffffc0202394:	d6ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202398:	00003697          	auipc	a3,0x3
ffffffffc020239c:	39068693          	addi	a3,a3,912 # ffffffffc0205728 <commands+0x10c8>
ffffffffc02023a0:	00003617          	auipc	a2,0x3
ffffffffc02023a4:	9e060613          	addi	a2,a2,-1568 # ffffffffc0204d80 <commands+0x720>
ffffffffc02023a8:	0d600593          	li	a1,214
ffffffffc02023ac:	00003517          	auipc	a0,0x3
ffffffffc02023b0:	23c50513          	addi	a0,a0,572 # ffffffffc02055e8 <commands+0xf88>
ffffffffc02023b4:	d4ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02023b8:	00003697          	auipc	a3,0x3
ffffffffc02023bc:	28868693          	addi	a3,a3,648 # ffffffffc0205640 <commands+0xfe0>
ffffffffc02023c0:	00003617          	auipc	a2,0x3
ffffffffc02023c4:	9c060613          	addi	a2,a2,-1600 # ffffffffc0204d80 <commands+0x720>
ffffffffc02023c8:	0d400593          	li	a1,212
ffffffffc02023cc:	00003517          	auipc	a0,0x3
ffffffffc02023d0:	21c50513          	addi	a0,a0,540 # ffffffffc02055e8 <commands+0xf88>
ffffffffc02023d4:	d2ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02023d8:	00003697          	auipc	a3,0x3
ffffffffc02023dc:	24868693          	addi	a3,a3,584 # ffffffffc0205620 <commands+0xfc0>
ffffffffc02023e0:	00003617          	auipc	a2,0x3
ffffffffc02023e4:	9a060613          	addi	a2,a2,-1632 # ffffffffc0204d80 <commands+0x720>
ffffffffc02023e8:	0d300593          	li	a1,211
ffffffffc02023ec:	00003517          	auipc	a0,0x3
ffffffffc02023f0:	1fc50513          	addi	a0,a0,508 # ffffffffc02055e8 <commands+0xf88>
ffffffffc02023f4:	d0ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02023f8:	00003697          	auipc	a3,0x3
ffffffffc02023fc:	24868693          	addi	a3,a3,584 # ffffffffc0205640 <commands+0xfe0>
ffffffffc0202400:	00003617          	auipc	a2,0x3
ffffffffc0202404:	98060613          	addi	a2,a2,-1664 # ffffffffc0204d80 <commands+0x720>
ffffffffc0202408:	0bb00593          	li	a1,187
ffffffffc020240c:	00003517          	auipc	a0,0x3
ffffffffc0202410:	1dc50513          	addi	a0,a0,476 # ffffffffc02055e8 <commands+0xf88>
ffffffffc0202414:	ceffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(count == 0);
ffffffffc0202418:	00003697          	auipc	a3,0x3
ffffffffc020241c:	4c068693          	addi	a3,a3,1216 # ffffffffc02058d8 <commands+0x1278>
ffffffffc0202420:	00003617          	auipc	a2,0x3
ffffffffc0202424:	96060613          	addi	a2,a2,-1696 # ffffffffc0204d80 <commands+0x720>
ffffffffc0202428:	12500593          	li	a1,293
ffffffffc020242c:	00003517          	auipc	a0,0x3
ffffffffc0202430:	1bc50513          	addi	a0,a0,444 # ffffffffc02055e8 <commands+0xf88>
ffffffffc0202434:	ccffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 0);
ffffffffc0202438:	00003697          	auipc	a3,0x3
ffffffffc020243c:	fd868693          	addi	a3,a3,-40 # ffffffffc0205410 <commands+0xdb0>
ffffffffc0202440:	00003617          	auipc	a2,0x3
ffffffffc0202444:	94060613          	addi	a2,a2,-1728 # ffffffffc0204d80 <commands+0x720>
ffffffffc0202448:	11a00593          	li	a1,282
ffffffffc020244c:	00003517          	auipc	a0,0x3
ffffffffc0202450:	19c50513          	addi	a0,a0,412 # ffffffffc02055e8 <commands+0xf88>
ffffffffc0202454:	caffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202458:	00003697          	auipc	a3,0x3
ffffffffc020245c:	2d068693          	addi	a3,a3,720 # ffffffffc0205728 <commands+0x10c8>
ffffffffc0202460:	00003617          	auipc	a2,0x3
ffffffffc0202464:	92060613          	addi	a2,a2,-1760 # ffffffffc0204d80 <commands+0x720>
ffffffffc0202468:	11800593          	li	a1,280
ffffffffc020246c:	00003517          	auipc	a0,0x3
ffffffffc0202470:	17c50513          	addi	a0,a0,380 # ffffffffc02055e8 <commands+0xf88>
ffffffffc0202474:	c8ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202478:	00003697          	auipc	a3,0x3
ffffffffc020247c:	27068693          	addi	a3,a3,624 # ffffffffc02056e8 <commands+0x1088>
ffffffffc0202480:	00003617          	auipc	a2,0x3
ffffffffc0202484:	90060613          	addi	a2,a2,-1792 # ffffffffc0204d80 <commands+0x720>
ffffffffc0202488:	0c100593          	li	a1,193
ffffffffc020248c:	00003517          	auipc	a0,0x3
ffffffffc0202490:	15c50513          	addi	a0,a0,348 # ffffffffc02055e8 <commands+0xf88>
ffffffffc0202494:	c6ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202498:	00003697          	auipc	a3,0x3
ffffffffc020249c:	40068693          	addi	a3,a3,1024 # ffffffffc0205898 <commands+0x1238>
ffffffffc02024a0:	00003617          	auipc	a2,0x3
ffffffffc02024a4:	8e060613          	addi	a2,a2,-1824 # ffffffffc0204d80 <commands+0x720>
ffffffffc02024a8:	11200593          	li	a1,274
ffffffffc02024ac:	00003517          	auipc	a0,0x3
ffffffffc02024b0:	13c50513          	addi	a0,a0,316 # ffffffffc02055e8 <commands+0xf88>
ffffffffc02024b4:	c4ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02024b8:	00003697          	auipc	a3,0x3
ffffffffc02024bc:	3c068693          	addi	a3,a3,960 # ffffffffc0205878 <commands+0x1218>
ffffffffc02024c0:	00003617          	auipc	a2,0x3
ffffffffc02024c4:	8c060613          	addi	a2,a2,-1856 # ffffffffc0204d80 <commands+0x720>
ffffffffc02024c8:	11000593          	li	a1,272
ffffffffc02024cc:	00003517          	auipc	a0,0x3
ffffffffc02024d0:	11c50513          	addi	a0,a0,284 # ffffffffc02055e8 <commands+0xf88>
ffffffffc02024d4:	c2ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02024d8:	00003697          	auipc	a3,0x3
ffffffffc02024dc:	37868693          	addi	a3,a3,888 # ffffffffc0205850 <commands+0x11f0>
ffffffffc02024e0:	00003617          	auipc	a2,0x3
ffffffffc02024e4:	8a060613          	addi	a2,a2,-1888 # ffffffffc0204d80 <commands+0x720>
ffffffffc02024e8:	10e00593          	li	a1,270
ffffffffc02024ec:	00003517          	auipc	a0,0x3
ffffffffc02024f0:	0fc50513          	addi	a0,a0,252 # ffffffffc02055e8 <commands+0xf88>
ffffffffc02024f4:	c0ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02024f8:	00003697          	auipc	a3,0x3
ffffffffc02024fc:	33068693          	addi	a3,a3,816 # ffffffffc0205828 <commands+0x11c8>
ffffffffc0202500:	00003617          	auipc	a2,0x3
ffffffffc0202504:	88060613          	addi	a2,a2,-1920 # ffffffffc0204d80 <commands+0x720>
ffffffffc0202508:	10d00593          	li	a1,269
ffffffffc020250c:	00003517          	auipc	a0,0x3
ffffffffc0202510:	0dc50513          	addi	a0,a0,220 # ffffffffc02055e8 <commands+0xf88>
ffffffffc0202514:	beffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0202518:	00003697          	auipc	a3,0x3
ffffffffc020251c:	30068693          	addi	a3,a3,768 # ffffffffc0205818 <commands+0x11b8>
ffffffffc0202520:	00003617          	auipc	a2,0x3
ffffffffc0202524:	86060613          	addi	a2,a2,-1952 # ffffffffc0204d80 <commands+0x720>
ffffffffc0202528:	10800593          	li	a1,264
ffffffffc020252c:	00003517          	auipc	a0,0x3
ffffffffc0202530:	0bc50513          	addi	a0,a0,188 # ffffffffc02055e8 <commands+0xf88>
ffffffffc0202534:	bcffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202538:	00003697          	auipc	a3,0x3
ffffffffc020253c:	1f068693          	addi	a3,a3,496 # ffffffffc0205728 <commands+0x10c8>
ffffffffc0202540:	00003617          	auipc	a2,0x3
ffffffffc0202544:	84060613          	addi	a2,a2,-1984 # ffffffffc0204d80 <commands+0x720>
ffffffffc0202548:	10700593          	li	a1,263
ffffffffc020254c:	00003517          	auipc	a0,0x3
ffffffffc0202550:	09c50513          	addi	a0,a0,156 # ffffffffc02055e8 <commands+0xf88>
ffffffffc0202554:	baffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202558:	00003697          	auipc	a3,0x3
ffffffffc020255c:	2a068693          	addi	a3,a3,672 # ffffffffc02057f8 <commands+0x1198>
ffffffffc0202560:	00003617          	auipc	a2,0x3
ffffffffc0202564:	82060613          	addi	a2,a2,-2016 # ffffffffc0204d80 <commands+0x720>
ffffffffc0202568:	10600593          	li	a1,262
ffffffffc020256c:	00003517          	auipc	a0,0x3
ffffffffc0202570:	07c50513          	addi	a0,a0,124 # ffffffffc02055e8 <commands+0xf88>
ffffffffc0202574:	b8ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202578:	00003697          	auipc	a3,0x3
ffffffffc020257c:	25068693          	addi	a3,a3,592 # ffffffffc02057c8 <commands+0x1168>
ffffffffc0202580:	00003617          	auipc	a2,0x3
ffffffffc0202584:	80060613          	addi	a2,a2,-2048 # ffffffffc0204d80 <commands+0x720>
ffffffffc0202588:	10500593          	li	a1,261
ffffffffc020258c:	00003517          	auipc	a0,0x3
ffffffffc0202590:	05c50513          	addi	a0,a0,92 # ffffffffc02055e8 <commands+0xf88>
ffffffffc0202594:	b6ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0202598:	00003697          	auipc	a3,0x3
ffffffffc020259c:	21868693          	addi	a3,a3,536 # ffffffffc02057b0 <commands+0x1150>
ffffffffc02025a0:	00002617          	auipc	a2,0x2
ffffffffc02025a4:	7e060613          	addi	a2,a2,2016 # ffffffffc0204d80 <commands+0x720>
ffffffffc02025a8:	10400593          	li	a1,260
ffffffffc02025ac:	00003517          	auipc	a0,0x3
ffffffffc02025b0:	03c50513          	addi	a0,a0,60 # ffffffffc02055e8 <commands+0xf88>
ffffffffc02025b4:	b4ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02025b8:	00003697          	auipc	a3,0x3
ffffffffc02025bc:	17068693          	addi	a3,a3,368 # ffffffffc0205728 <commands+0x10c8>
ffffffffc02025c0:	00002617          	auipc	a2,0x2
ffffffffc02025c4:	7c060613          	addi	a2,a2,1984 # ffffffffc0204d80 <commands+0x720>
ffffffffc02025c8:	0fe00593          	li	a1,254
ffffffffc02025cc:	00003517          	auipc	a0,0x3
ffffffffc02025d0:	01c50513          	addi	a0,a0,28 # ffffffffc02055e8 <commands+0xf88>
ffffffffc02025d4:	b2ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(!PageProperty(p0));
ffffffffc02025d8:	00003697          	auipc	a3,0x3
ffffffffc02025dc:	1c068693          	addi	a3,a3,448 # ffffffffc0205798 <commands+0x1138>
ffffffffc02025e0:	00002617          	auipc	a2,0x2
ffffffffc02025e4:	7a060613          	addi	a2,a2,1952 # ffffffffc0204d80 <commands+0x720>
ffffffffc02025e8:	0f900593          	li	a1,249
ffffffffc02025ec:	00003517          	auipc	a0,0x3
ffffffffc02025f0:	ffc50513          	addi	a0,a0,-4 # ffffffffc02055e8 <commands+0xf88>
ffffffffc02025f4:	b0ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02025f8:	00003697          	auipc	a3,0x3
ffffffffc02025fc:	2c068693          	addi	a3,a3,704 # ffffffffc02058b8 <commands+0x1258>
ffffffffc0202600:	00002617          	auipc	a2,0x2
ffffffffc0202604:	78060613          	addi	a2,a2,1920 # ffffffffc0204d80 <commands+0x720>
ffffffffc0202608:	11700593          	li	a1,279
ffffffffc020260c:	00003517          	auipc	a0,0x3
ffffffffc0202610:	fdc50513          	addi	a0,a0,-36 # ffffffffc02055e8 <commands+0xf88>
ffffffffc0202614:	aeffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(total == 0);
ffffffffc0202618:	00003697          	auipc	a3,0x3
ffffffffc020261c:	2d068693          	addi	a3,a3,720 # ffffffffc02058e8 <commands+0x1288>
ffffffffc0202620:	00002617          	auipc	a2,0x2
ffffffffc0202624:	76060613          	addi	a2,a2,1888 # ffffffffc0204d80 <commands+0x720>
ffffffffc0202628:	12600593          	li	a1,294
ffffffffc020262c:	00003517          	auipc	a0,0x3
ffffffffc0202630:	fbc50513          	addi	a0,a0,-68 # ffffffffc02055e8 <commands+0xf88>
ffffffffc0202634:	acffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(total == nr_free_pages());
ffffffffc0202638:	00003697          	auipc	a3,0x3
ffffffffc020263c:	c3868693          	addi	a3,a3,-968 # ffffffffc0205270 <commands+0xc10>
ffffffffc0202640:	00002617          	auipc	a2,0x2
ffffffffc0202644:	74060613          	addi	a2,a2,1856 # ffffffffc0204d80 <commands+0x720>
ffffffffc0202648:	0f300593          	li	a1,243
ffffffffc020264c:	00003517          	auipc	a0,0x3
ffffffffc0202650:	f9c50513          	addi	a0,a0,-100 # ffffffffc02055e8 <commands+0xf88>
ffffffffc0202654:	aaffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202658:	00003697          	auipc	a3,0x3
ffffffffc020265c:	fc868693          	addi	a3,a3,-56 # ffffffffc0205620 <commands+0xfc0>
ffffffffc0202660:	00002617          	auipc	a2,0x2
ffffffffc0202664:	72060613          	addi	a2,a2,1824 # ffffffffc0204d80 <commands+0x720>
ffffffffc0202668:	0ba00593          	li	a1,186
ffffffffc020266c:	00003517          	auipc	a0,0x3
ffffffffc0202670:	f7c50513          	addi	a0,a0,-132 # ffffffffc02055e8 <commands+0xf88>
ffffffffc0202674:	a8ffd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202678 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0202678:	1141                	addi	sp,sp,-16
ffffffffc020267a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020267c:	14058a63          	beqz	a1,ffffffffc02027d0 <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc0202680:	00359693          	slli	a3,a1,0x3
ffffffffc0202684:	96ae                	add	a3,a3,a1
ffffffffc0202686:	068e                	slli	a3,a3,0x3
ffffffffc0202688:	96aa                	add	a3,a3,a0
ffffffffc020268a:	87aa                	mv	a5,a0
ffffffffc020268c:	02d50263          	beq	a0,a3,ffffffffc02026b0 <default_free_pages+0x38>
ffffffffc0202690:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0202692:	8b05                	andi	a4,a4,1
ffffffffc0202694:	10071e63          	bnez	a4,ffffffffc02027b0 <default_free_pages+0x138>
ffffffffc0202698:	6798                	ld	a4,8(a5)
ffffffffc020269a:	8b09                	andi	a4,a4,2
ffffffffc020269c:	10071a63          	bnez	a4,ffffffffc02027b0 <default_free_pages+0x138>
        p->flags = 0;
ffffffffc02026a0:	0007b423          	sd	zero,8(a5)
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02026a4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02026a8:	04878793          	addi	a5,a5,72
ffffffffc02026ac:	fed792e3          	bne	a5,a3,ffffffffc0202690 <default_free_pages+0x18>
    base->property = n;
ffffffffc02026b0:	2581                	sext.w	a1,a1
ffffffffc02026b2:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc02026b4:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02026b8:	4789                	li	a5,2
ffffffffc02026ba:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02026be:	0000f697          	auipc	a3,0xf
ffffffffc02026c2:	a2268693          	addi	a3,a3,-1502 # ffffffffc02110e0 <free_area>
ffffffffc02026c6:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02026c8:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02026ca:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc02026ce:	9db9                	addw	a1,a1,a4
ffffffffc02026d0:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02026d2:	0ad78863          	beq	a5,a3,ffffffffc0202782 <default_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc02026d6:	fe078713          	addi	a4,a5,-32
ffffffffc02026da:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02026de:	4581                	li	a1,0
            if (base < page) {
ffffffffc02026e0:	00e56a63          	bltu	a0,a4,ffffffffc02026f4 <default_free_pages+0x7c>
    return listelm->next;
ffffffffc02026e4:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02026e6:	06d70263          	beq	a4,a3,ffffffffc020274a <default_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc02026ea:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02026ec:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02026f0:	fee57ae3          	bgeu	a0,a4,ffffffffc02026e4 <default_free_pages+0x6c>
ffffffffc02026f4:	c199                	beqz	a1,ffffffffc02026fa <default_free_pages+0x82>
ffffffffc02026f6:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02026fa:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc02026fc:	e390                	sd	a2,0(a5)
ffffffffc02026fe:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0202700:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0202702:	f118                	sd	a4,32(a0)
    if (le != &free_list) {
ffffffffc0202704:	02d70063          	beq	a4,a3,ffffffffc0202724 <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc0202708:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc020270c:	fe070593          	addi	a1,a4,-32
        if (p + p->property == base) {
ffffffffc0202710:	02081613          	slli	a2,a6,0x20
ffffffffc0202714:	9201                	srli	a2,a2,0x20
ffffffffc0202716:	00361793          	slli	a5,a2,0x3
ffffffffc020271a:	97b2                	add	a5,a5,a2
ffffffffc020271c:	078e                	slli	a5,a5,0x3
ffffffffc020271e:	97ae                	add	a5,a5,a1
ffffffffc0202720:	02f50f63          	beq	a0,a5,ffffffffc020275e <default_free_pages+0xe6>
    return listelm->next;
ffffffffc0202724:	7518                	ld	a4,40(a0)
    if (le != &free_list) {
ffffffffc0202726:	00d70f63          	beq	a4,a3,ffffffffc0202744 <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc020272a:	4d0c                	lw	a1,24(a0)
        p = le2page(le, page_link);
ffffffffc020272c:	fe070693          	addi	a3,a4,-32
        if (base + base->property == p) {
ffffffffc0202730:	02059613          	slli	a2,a1,0x20
ffffffffc0202734:	9201                	srli	a2,a2,0x20
ffffffffc0202736:	00361793          	slli	a5,a2,0x3
ffffffffc020273a:	97b2                	add	a5,a5,a2
ffffffffc020273c:	078e                	slli	a5,a5,0x3
ffffffffc020273e:	97aa                	add	a5,a5,a0
ffffffffc0202740:	04f68863          	beq	a3,a5,ffffffffc0202790 <default_free_pages+0x118>
}
ffffffffc0202744:	60a2                	ld	ra,8(sp)
ffffffffc0202746:	0141                	addi	sp,sp,16
ffffffffc0202748:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020274a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020274c:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc020274e:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0202750:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0202752:	02d70563          	beq	a4,a3,ffffffffc020277c <default_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc0202756:	8832                	mv	a6,a2
ffffffffc0202758:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc020275a:	87ba                	mv	a5,a4
ffffffffc020275c:	bf41                	j	ffffffffc02026ec <default_free_pages+0x74>
            p->property += base->property;
ffffffffc020275e:	4d1c                	lw	a5,24(a0)
ffffffffc0202760:	0107883b          	addw	a6,a5,a6
ffffffffc0202764:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0202768:	57f5                	li	a5,-3
ffffffffc020276a:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc020276e:	7110                	ld	a2,32(a0)
ffffffffc0202770:	751c                	ld	a5,40(a0)
            base = p;
ffffffffc0202772:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc0202774:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc0202776:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc0202778:	e390                	sd	a2,0(a5)
ffffffffc020277a:	b775                	j	ffffffffc0202726 <default_free_pages+0xae>
ffffffffc020277c:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020277e:	873e                	mv	a4,a5
ffffffffc0202780:	b761                	j	ffffffffc0202708 <default_free_pages+0x90>
}
ffffffffc0202782:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0202784:	e390                	sd	a2,0(a5)
ffffffffc0202786:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202788:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020278a:	f11c                	sd	a5,32(a0)
ffffffffc020278c:	0141                	addi	sp,sp,16
ffffffffc020278e:	8082                	ret
            base->property += p->property;
ffffffffc0202790:	ff872783          	lw	a5,-8(a4)
ffffffffc0202794:	fe870693          	addi	a3,a4,-24
ffffffffc0202798:	9dbd                	addw	a1,a1,a5
ffffffffc020279a:	cd0c                	sw	a1,24(a0)
ffffffffc020279c:	57f5                	li	a5,-3
ffffffffc020279e:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02027a2:	6314                	ld	a3,0(a4)
ffffffffc02027a4:	671c                	ld	a5,8(a4)
}
ffffffffc02027a6:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02027a8:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc02027aa:	e394                	sd	a3,0(a5)
ffffffffc02027ac:	0141                	addi	sp,sp,16
ffffffffc02027ae:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02027b0:	00003697          	auipc	a3,0x3
ffffffffc02027b4:	15068693          	addi	a3,a3,336 # ffffffffc0205900 <commands+0x12a0>
ffffffffc02027b8:	00002617          	auipc	a2,0x2
ffffffffc02027bc:	5c860613          	addi	a2,a2,1480 # ffffffffc0204d80 <commands+0x720>
ffffffffc02027c0:	08300593          	li	a1,131
ffffffffc02027c4:	00003517          	auipc	a0,0x3
ffffffffc02027c8:	e2450513          	addi	a0,a0,-476 # ffffffffc02055e8 <commands+0xf88>
ffffffffc02027cc:	937fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0);
ffffffffc02027d0:	00003697          	auipc	a3,0x3
ffffffffc02027d4:	12868693          	addi	a3,a3,296 # ffffffffc02058f8 <commands+0x1298>
ffffffffc02027d8:	00002617          	auipc	a2,0x2
ffffffffc02027dc:	5a860613          	addi	a2,a2,1448 # ffffffffc0204d80 <commands+0x720>
ffffffffc02027e0:	08000593          	li	a1,128
ffffffffc02027e4:	00003517          	auipc	a0,0x3
ffffffffc02027e8:	e0450513          	addi	a0,a0,-508 # ffffffffc02055e8 <commands+0xf88>
ffffffffc02027ec:	917fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02027f0 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02027f0:	c959                	beqz	a0,ffffffffc0202886 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc02027f2:	0000f597          	auipc	a1,0xf
ffffffffc02027f6:	8ee58593          	addi	a1,a1,-1810 # ffffffffc02110e0 <free_area>
ffffffffc02027fa:	0105a803          	lw	a6,16(a1)
ffffffffc02027fe:	862a                	mv	a2,a0
ffffffffc0202800:	02081793          	slli	a5,a6,0x20
ffffffffc0202804:	9381                	srli	a5,a5,0x20
ffffffffc0202806:	00a7ee63          	bltu	a5,a0,ffffffffc0202822 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc020280a:	87ae                	mv	a5,a1
ffffffffc020280c:	a801                	j	ffffffffc020281c <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc020280e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202812:	02071693          	slli	a3,a4,0x20
ffffffffc0202816:	9281                	srli	a3,a3,0x20
ffffffffc0202818:	00c6f763          	bgeu	a3,a2,ffffffffc0202826 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc020281c:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020281e:	feb798e3          	bne	a5,a1,ffffffffc020280e <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0202822:	4501                	li	a0,0
}
ffffffffc0202824:	8082                	ret
    return listelm->prev;
ffffffffc0202826:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc020282a:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc020282e:	fe078513          	addi	a0,a5,-32
            p->property = page->property - n;
ffffffffc0202832:	00060e1b          	sext.w	t3,a2
    prev->next = next;
ffffffffc0202836:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc020283a:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc020283e:	02d67b63          	bgeu	a2,a3,ffffffffc0202874 <default_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc0202842:	00361693          	slli	a3,a2,0x3
ffffffffc0202846:	96b2                	add	a3,a3,a2
ffffffffc0202848:	068e                	slli	a3,a3,0x3
ffffffffc020284a:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc020284c:	41c7073b          	subw	a4,a4,t3
ffffffffc0202850:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202852:	00868613          	addi	a2,a3,8
ffffffffc0202856:	4709                	li	a4,2
ffffffffc0202858:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc020285c:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0202860:	02068613          	addi	a2,a3,32
        nr_free -= n;
ffffffffc0202864:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0202868:	e310                	sd	a2,0(a4)
ffffffffc020286a:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc020286e:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc0202870:	0316b023          	sd	a7,32(a3)
ffffffffc0202874:	41c8083b          	subw	a6,a6,t3
ffffffffc0202878:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020287c:	5775                	li	a4,-3
ffffffffc020287e:	17a1                	addi	a5,a5,-24
ffffffffc0202880:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0202884:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0202886:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0202888:	00003697          	auipc	a3,0x3
ffffffffc020288c:	07068693          	addi	a3,a3,112 # ffffffffc02058f8 <commands+0x1298>
ffffffffc0202890:	00002617          	auipc	a2,0x2
ffffffffc0202894:	4f060613          	addi	a2,a2,1264 # ffffffffc0204d80 <commands+0x720>
ffffffffc0202898:	06200593          	li	a1,98
ffffffffc020289c:	00003517          	auipc	a0,0x3
ffffffffc02028a0:	d4c50513          	addi	a0,a0,-692 # ffffffffc02055e8 <commands+0xf88>
default_alloc_pages(size_t n) {
ffffffffc02028a4:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02028a6:	85dfd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02028aa <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02028aa:	1141                	addi	sp,sp,-16
ffffffffc02028ac:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02028ae:	c9e1                	beqz	a1,ffffffffc020297e <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc02028b0:	00359693          	slli	a3,a1,0x3
ffffffffc02028b4:	96ae                	add	a3,a3,a1
ffffffffc02028b6:	068e                	slli	a3,a3,0x3
ffffffffc02028b8:	96aa                	add	a3,a3,a0
ffffffffc02028ba:	87aa                	mv	a5,a0
ffffffffc02028bc:	00d50f63          	beq	a0,a3,ffffffffc02028da <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02028c0:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02028c2:	8b05                	andi	a4,a4,1
ffffffffc02028c4:	cf49                	beqz	a4,ffffffffc020295e <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc02028c6:	0007ac23          	sw	zero,24(a5)
ffffffffc02028ca:	0007b423          	sd	zero,8(a5)
ffffffffc02028ce:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02028d2:	04878793          	addi	a5,a5,72
ffffffffc02028d6:	fed795e3          	bne	a5,a3,ffffffffc02028c0 <default_init_memmap+0x16>
    base->property = n;
ffffffffc02028da:	2581                	sext.w	a1,a1
ffffffffc02028dc:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02028de:	4789                	li	a5,2
ffffffffc02028e0:	00850713          	addi	a4,a0,8
ffffffffc02028e4:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02028e8:	0000e697          	auipc	a3,0xe
ffffffffc02028ec:	7f868693          	addi	a3,a3,2040 # ffffffffc02110e0 <free_area>
ffffffffc02028f0:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02028f2:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02028f4:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc02028f8:	9db9                	addw	a1,a1,a4
ffffffffc02028fa:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02028fc:	04d78a63          	beq	a5,a3,ffffffffc0202950 <default_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc0202900:	fe078713          	addi	a4,a5,-32
ffffffffc0202904:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0202908:	4581                	li	a1,0
            if (base < page) {
ffffffffc020290a:	00e56a63          	bltu	a0,a4,ffffffffc020291e <default_init_memmap+0x74>
    return listelm->next;
ffffffffc020290e:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0202910:	02d70263          	beq	a4,a3,ffffffffc0202934 <default_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc0202914:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0202916:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc020291a:	fee57ae3          	bgeu	a0,a4,ffffffffc020290e <default_init_memmap+0x64>
ffffffffc020291e:	c199                	beqz	a1,ffffffffc0202924 <default_init_memmap+0x7a>
ffffffffc0202920:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202924:	6398                	ld	a4,0(a5)
}
ffffffffc0202926:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0202928:	e390                	sd	a2,0(a5)
ffffffffc020292a:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020292c:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020292e:	f118                	sd	a4,32(a0)
ffffffffc0202930:	0141                	addi	sp,sp,16
ffffffffc0202932:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0202934:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202936:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0202938:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020293a:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020293c:	00d70663          	beq	a4,a3,ffffffffc0202948 <default_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc0202940:	8832                	mv	a6,a2
ffffffffc0202942:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0202944:	87ba                	mv	a5,a4
ffffffffc0202946:	bfc1                	j	ffffffffc0202916 <default_init_memmap+0x6c>
}
ffffffffc0202948:	60a2                	ld	ra,8(sp)
ffffffffc020294a:	e290                	sd	a2,0(a3)
ffffffffc020294c:	0141                	addi	sp,sp,16
ffffffffc020294e:	8082                	ret
ffffffffc0202950:	60a2                	ld	ra,8(sp)
ffffffffc0202952:	e390                	sd	a2,0(a5)
ffffffffc0202954:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202956:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0202958:	f11c                	sd	a5,32(a0)
ffffffffc020295a:	0141                	addi	sp,sp,16
ffffffffc020295c:	8082                	ret
        assert(PageReserved(p));
ffffffffc020295e:	00003697          	auipc	a3,0x3
ffffffffc0202962:	fca68693          	addi	a3,a3,-54 # ffffffffc0205928 <commands+0x12c8>
ffffffffc0202966:	00002617          	auipc	a2,0x2
ffffffffc020296a:	41a60613          	addi	a2,a2,1050 # ffffffffc0204d80 <commands+0x720>
ffffffffc020296e:	04900593          	li	a1,73
ffffffffc0202972:	00003517          	auipc	a0,0x3
ffffffffc0202976:	c7650513          	addi	a0,a0,-906 # ffffffffc02055e8 <commands+0xf88>
ffffffffc020297a:	f88fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0);
ffffffffc020297e:	00003697          	auipc	a3,0x3
ffffffffc0202982:	f7a68693          	addi	a3,a3,-134 # ffffffffc02058f8 <commands+0x1298>
ffffffffc0202986:	00002617          	auipc	a2,0x2
ffffffffc020298a:	3fa60613          	addi	a2,a2,1018 # ffffffffc0204d80 <commands+0x720>
ffffffffc020298e:	04600593          	li	a1,70
ffffffffc0202992:	00003517          	auipc	a0,0x3
ffffffffc0202996:	c5650513          	addi	a0,a0,-938 # ffffffffc02055e8 <commands+0xf88>
ffffffffc020299a:	f68fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc020299e <pa2page.part.0>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc020299e:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02029a0:	00002617          	auipc	a2,0x2
ffffffffc02029a4:	75860613          	addi	a2,a2,1880 # ffffffffc02050f8 <commands+0xa98>
ffffffffc02029a8:	06500593          	li	a1,101
ffffffffc02029ac:	00002517          	auipc	a0,0x2
ffffffffc02029b0:	76c50513          	addi	a0,a0,1900 # ffffffffc0205118 <commands+0xab8>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02029b4:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02029b6:	f4cfd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02029ba <pte2page.part.0>:
static inline struct Page *pte2page(pte_t pte) {
ffffffffc02029ba:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc02029bc:	00003617          	auipc	a2,0x3
ffffffffc02029c0:	a7c60613          	addi	a2,a2,-1412 # ffffffffc0205438 <commands+0xdd8>
ffffffffc02029c4:	07000593          	li	a1,112
ffffffffc02029c8:	00002517          	auipc	a0,0x2
ffffffffc02029cc:	75050513          	addi	a0,a0,1872 # ffffffffc0205118 <commands+0xab8>
static inline struct Page *pte2page(pte_t pte) {
ffffffffc02029d0:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc02029d2:	f30fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02029d6 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc02029d6:	7139                	addi	sp,sp,-64
ffffffffc02029d8:	f426                	sd	s1,40(sp)
ffffffffc02029da:	f04a                	sd	s2,32(sp)
ffffffffc02029dc:	ec4e                	sd	s3,24(sp)
ffffffffc02029de:	e852                	sd	s4,16(sp)
ffffffffc02029e0:	e456                	sd	s5,8(sp)
ffffffffc02029e2:	e05a                	sd	s6,0(sp)
ffffffffc02029e4:	fc06                	sd	ra,56(sp)
ffffffffc02029e6:	f822                	sd	s0,48(sp)
ffffffffc02029e8:	84aa                	mv	s1,a0
ffffffffc02029ea:	0000f917          	auipc	s2,0xf
ffffffffc02029ee:	b7690913          	addi	s2,s2,-1162 # ffffffffc0211560 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02029f2:	4a05                	li	s4,1
ffffffffc02029f4:	0000fa97          	auipc	s5,0xf
ffffffffc02029f8:	b44a8a93          	addi	s5,s5,-1212 # ffffffffc0211538 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc02029fc:	0005099b          	sext.w	s3,a0
ffffffffc0202a00:	0000fb17          	auipc	s6,0xf
ffffffffc0202a04:	b18b0b13          	addi	s6,s6,-1256 # ffffffffc0211518 <check_mm_struct>
ffffffffc0202a08:	a01d                	j	ffffffffc0202a2e <alloc_pages+0x58>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0202a0a:	00093783          	ld	a5,0(s2)
ffffffffc0202a0e:	6f9c                	ld	a5,24(a5)
ffffffffc0202a10:	9782                	jalr	a5
ffffffffc0202a12:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0202a14:	4601                	li	a2,0
ffffffffc0202a16:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202a18:	ec0d                	bnez	s0,ffffffffc0202a52 <alloc_pages+0x7c>
ffffffffc0202a1a:	029a6c63          	bltu	s4,s1,ffffffffc0202a52 <alloc_pages+0x7c>
ffffffffc0202a1e:	000aa783          	lw	a5,0(s5)
ffffffffc0202a22:	2781                	sext.w	a5,a5
ffffffffc0202a24:	c79d                	beqz	a5,ffffffffc0202a52 <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0202a26:	000b3503          	ld	a0,0(s6)
ffffffffc0202a2a:	b0eff0ef          	jal	ra,ffffffffc0201d38 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202a2e:	100027f3          	csrr	a5,sstatus
ffffffffc0202a32:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0202a34:	8526                	mv	a0,s1
ffffffffc0202a36:	dbf1                	beqz	a5,ffffffffc0202a0a <alloc_pages+0x34>
        intr_disable();
ffffffffc0202a38:	ab7fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202a3c:	00093783          	ld	a5,0(s2)
ffffffffc0202a40:	8526                	mv	a0,s1
ffffffffc0202a42:	6f9c                	ld	a5,24(a5)
ffffffffc0202a44:	9782                	jalr	a5
ffffffffc0202a46:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202a48:	aa1fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0202a4c:	4601                	li	a2,0
ffffffffc0202a4e:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202a50:	d469                	beqz	s0,ffffffffc0202a1a <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0202a52:	70e2                	ld	ra,56(sp)
ffffffffc0202a54:	8522                	mv	a0,s0
ffffffffc0202a56:	7442                	ld	s0,48(sp)
ffffffffc0202a58:	74a2                	ld	s1,40(sp)
ffffffffc0202a5a:	7902                	ld	s2,32(sp)
ffffffffc0202a5c:	69e2                	ld	s3,24(sp)
ffffffffc0202a5e:	6a42                	ld	s4,16(sp)
ffffffffc0202a60:	6aa2                	ld	s5,8(sp)
ffffffffc0202a62:	6b02                	ld	s6,0(sp)
ffffffffc0202a64:	6121                	addi	sp,sp,64
ffffffffc0202a66:	8082                	ret

ffffffffc0202a68 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202a68:	100027f3          	csrr	a5,sstatus
ffffffffc0202a6c:	8b89                	andi	a5,a5,2
ffffffffc0202a6e:	e799                	bnez	a5,ffffffffc0202a7c <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc0202a70:	0000f797          	auipc	a5,0xf
ffffffffc0202a74:	af07b783          	ld	a5,-1296(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0202a78:	739c                	ld	a5,32(a5)
ffffffffc0202a7a:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0202a7c:	1101                	addi	sp,sp,-32
ffffffffc0202a7e:	ec06                	sd	ra,24(sp)
ffffffffc0202a80:	e822                	sd	s0,16(sp)
ffffffffc0202a82:	e426                	sd	s1,8(sp)
ffffffffc0202a84:	842a                	mv	s0,a0
ffffffffc0202a86:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0202a88:	a67fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202a8c:	0000f797          	auipc	a5,0xf
ffffffffc0202a90:	ad47b783          	ld	a5,-1324(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0202a94:	739c                	ld	a5,32(a5)
ffffffffc0202a96:	85a6                	mv	a1,s1
ffffffffc0202a98:	8522                	mv	a0,s0
ffffffffc0202a9a:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0202a9c:	6442                	ld	s0,16(sp)
ffffffffc0202a9e:	60e2                	ld	ra,24(sp)
ffffffffc0202aa0:	64a2                	ld	s1,8(sp)
ffffffffc0202aa2:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0202aa4:	a45fd06f          	j	ffffffffc02004e8 <intr_enable>

ffffffffc0202aa8 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202aa8:	100027f3          	csrr	a5,sstatus
ffffffffc0202aac:	8b89                	andi	a5,a5,2
ffffffffc0202aae:	e799                	bnez	a5,ffffffffc0202abc <nr_free_pages+0x14>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202ab0:	0000f797          	auipc	a5,0xf
ffffffffc0202ab4:	ab07b783          	ld	a5,-1360(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0202ab8:	779c                	ld	a5,40(a5)
ffffffffc0202aba:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0202abc:	1141                	addi	sp,sp,-16
ffffffffc0202abe:	e406                	sd	ra,8(sp)
ffffffffc0202ac0:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0202ac2:	a2dfd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202ac6:	0000f797          	auipc	a5,0xf
ffffffffc0202aca:	a9a7b783          	ld	a5,-1382(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0202ace:	779c                	ld	a5,40(a5)
ffffffffc0202ad0:	9782                	jalr	a5
ffffffffc0202ad2:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202ad4:	a15fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0202ad8:	60a2                	ld	ra,8(sp)
ffffffffc0202ada:	8522                	mv	a0,s0
ffffffffc0202adc:	6402                	ld	s0,0(sp)
ffffffffc0202ade:	0141                	addi	sp,sp,16
ffffffffc0202ae0:	8082                	ret

ffffffffc0202ae2 <get_pte>:
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202ae2:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0202ae6:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202aea:	715d                	addi	sp,sp,-80
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202aec:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202aee:	fc26                	sd	s1,56(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202af0:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202af4:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202af6:	f84a                	sd	s2,48(sp)
ffffffffc0202af8:	f44e                	sd	s3,40(sp)
ffffffffc0202afa:	f052                	sd	s4,32(sp)
ffffffffc0202afc:	e486                	sd	ra,72(sp)
ffffffffc0202afe:	e0a2                	sd	s0,64(sp)
ffffffffc0202b00:	ec56                	sd	s5,24(sp)
ffffffffc0202b02:	e85a                	sd	s6,16(sp)
ffffffffc0202b04:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202b06:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202b0a:	892e                	mv	s2,a1
ffffffffc0202b0c:	8a32                	mv	s4,a2
ffffffffc0202b0e:	0000f997          	auipc	s3,0xf
ffffffffc0202b12:	a4298993          	addi	s3,s3,-1470 # ffffffffc0211550 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202b16:	efb5                	bnez	a5,ffffffffc0202b92 <get_pte+0xb0>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202b18:	14060c63          	beqz	a2,ffffffffc0202c70 <get_pte+0x18e>
ffffffffc0202b1c:	4505                	li	a0,1
ffffffffc0202b1e:	eb9ff0ef          	jal	ra,ffffffffc02029d6 <alloc_pages>
ffffffffc0202b22:	842a                	mv	s0,a0
ffffffffc0202b24:	14050663          	beqz	a0,ffffffffc0202c70 <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202b28:	0000fb97          	auipc	s7,0xf
ffffffffc0202b2c:	a30b8b93          	addi	s7,s7,-1488 # ffffffffc0211558 <pages>
ffffffffc0202b30:	000bb503          	ld	a0,0(s7)
ffffffffc0202b34:	00003b17          	auipc	s6,0x3
ffffffffc0202b38:	6ecb3b03          	ld	s6,1772(s6) # ffffffffc0206220 <error_string+0x38>
ffffffffc0202b3c:	00080ab7          	lui	s5,0x80
ffffffffc0202b40:	40a40533          	sub	a0,s0,a0
ffffffffc0202b44:	850d                	srai	a0,a0,0x3
ffffffffc0202b46:	03650533          	mul	a0,a0,s6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202b4a:	0000f997          	auipc	s3,0xf
ffffffffc0202b4e:	a0698993          	addi	s3,s3,-1530 # ffffffffc0211550 <npage>
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202b52:	4785                	li	a5,1
ffffffffc0202b54:	0009b703          	ld	a4,0(s3)
ffffffffc0202b58:	c01c                	sw	a5,0(s0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202b5a:	9556                	add	a0,a0,s5
ffffffffc0202b5c:	00c51793          	slli	a5,a0,0xc
ffffffffc0202b60:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202b62:	0532                	slli	a0,a0,0xc
ffffffffc0202b64:	14e7fd63          	bgeu	a5,a4,ffffffffc0202cbe <get_pte+0x1dc>
ffffffffc0202b68:	0000f797          	auipc	a5,0xf
ffffffffc0202b6c:	a007b783          	ld	a5,-1536(a5) # ffffffffc0211568 <va_pa_offset>
ffffffffc0202b70:	6605                	lui	a2,0x1
ffffffffc0202b72:	4581                	li	a1,0
ffffffffc0202b74:	953e                	add	a0,a0,a5
ffffffffc0202b76:	3a2010ef          	jal	ra,ffffffffc0203f18 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202b7a:	000bb683          	ld	a3,0(s7)
ffffffffc0202b7e:	40d406b3          	sub	a3,s0,a3
ffffffffc0202b82:	868d                	srai	a3,a3,0x3
ffffffffc0202b84:	036686b3          	mul	a3,a3,s6
ffffffffc0202b88:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202b8a:	06aa                	slli	a3,a3,0xa
ffffffffc0202b8c:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202b90:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202b92:	77fd                	lui	a5,0xfffff
ffffffffc0202b94:	068a                	slli	a3,a3,0x2
ffffffffc0202b96:	0009b703          	ld	a4,0(s3)
ffffffffc0202b9a:	8efd                	and	a3,a3,a5
ffffffffc0202b9c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202ba0:	0ce7fa63          	bgeu	a5,a4,ffffffffc0202c74 <get_pte+0x192>
ffffffffc0202ba4:	0000fa97          	auipc	s5,0xf
ffffffffc0202ba8:	9c4a8a93          	addi	s5,s5,-1596 # ffffffffc0211568 <va_pa_offset>
ffffffffc0202bac:	000ab403          	ld	s0,0(s5)
ffffffffc0202bb0:	01595793          	srli	a5,s2,0x15
ffffffffc0202bb4:	1ff7f793          	andi	a5,a5,511
ffffffffc0202bb8:	96a2                	add	a3,a3,s0
ffffffffc0202bba:	00379413          	slli	s0,a5,0x3
ffffffffc0202bbe:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc0202bc0:	6014                	ld	a3,0(s0)
ffffffffc0202bc2:	0016f793          	andi	a5,a3,1
ffffffffc0202bc6:	ebad                	bnez	a5,ffffffffc0202c38 <get_pte+0x156>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202bc8:	0a0a0463          	beqz	s4,ffffffffc0202c70 <get_pte+0x18e>
ffffffffc0202bcc:	4505                	li	a0,1
ffffffffc0202bce:	e09ff0ef          	jal	ra,ffffffffc02029d6 <alloc_pages>
ffffffffc0202bd2:	84aa                	mv	s1,a0
ffffffffc0202bd4:	cd51                	beqz	a0,ffffffffc0202c70 <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202bd6:	0000fb97          	auipc	s7,0xf
ffffffffc0202bda:	982b8b93          	addi	s7,s7,-1662 # ffffffffc0211558 <pages>
ffffffffc0202bde:	000bb503          	ld	a0,0(s7)
ffffffffc0202be2:	00003b17          	auipc	s6,0x3
ffffffffc0202be6:	63eb3b03          	ld	s6,1598(s6) # ffffffffc0206220 <error_string+0x38>
ffffffffc0202bea:	00080a37          	lui	s4,0x80
ffffffffc0202bee:	40a48533          	sub	a0,s1,a0
ffffffffc0202bf2:	850d                	srai	a0,a0,0x3
ffffffffc0202bf4:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202bf8:	4785                	li	a5,1
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202bfa:	0009b703          	ld	a4,0(s3)
ffffffffc0202bfe:	c09c                	sw	a5,0(s1)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202c00:	9552                	add	a0,a0,s4
ffffffffc0202c02:	00c51793          	slli	a5,a0,0xc
ffffffffc0202c06:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202c08:	0532                	slli	a0,a0,0xc
ffffffffc0202c0a:	08e7fd63          	bgeu	a5,a4,ffffffffc0202ca4 <get_pte+0x1c2>
ffffffffc0202c0e:	000ab783          	ld	a5,0(s5)
ffffffffc0202c12:	6605                	lui	a2,0x1
ffffffffc0202c14:	4581                	li	a1,0
ffffffffc0202c16:	953e                	add	a0,a0,a5
ffffffffc0202c18:	300010ef          	jal	ra,ffffffffc0203f18 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202c1c:	000bb683          	ld	a3,0(s7)
ffffffffc0202c20:	40d486b3          	sub	a3,s1,a3
ffffffffc0202c24:	868d                	srai	a3,a3,0x3
ffffffffc0202c26:	036686b3          	mul	a3,a3,s6
ffffffffc0202c2a:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202c2c:	06aa                	slli	a3,a3,0xa
ffffffffc0202c2e:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202c32:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202c34:	0009b703          	ld	a4,0(s3)
ffffffffc0202c38:	068a                	slli	a3,a3,0x2
ffffffffc0202c3a:	757d                	lui	a0,0xfffff
ffffffffc0202c3c:	8ee9                	and	a3,a3,a0
ffffffffc0202c3e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202c42:	04e7f563          	bgeu	a5,a4,ffffffffc0202c8c <get_pte+0x1aa>
ffffffffc0202c46:	000ab503          	ld	a0,0(s5)
ffffffffc0202c4a:	00c95913          	srli	s2,s2,0xc
ffffffffc0202c4e:	1ff97913          	andi	s2,s2,511
ffffffffc0202c52:	96aa                	add	a3,a3,a0
ffffffffc0202c54:	00391513          	slli	a0,s2,0x3
ffffffffc0202c58:	9536                	add	a0,a0,a3
}
ffffffffc0202c5a:	60a6                	ld	ra,72(sp)
ffffffffc0202c5c:	6406                	ld	s0,64(sp)
ffffffffc0202c5e:	74e2                	ld	s1,56(sp)
ffffffffc0202c60:	7942                	ld	s2,48(sp)
ffffffffc0202c62:	79a2                	ld	s3,40(sp)
ffffffffc0202c64:	7a02                	ld	s4,32(sp)
ffffffffc0202c66:	6ae2                	ld	s5,24(sp)
ffffffffc0202c68:	6b42                	ld	s6,16(sp)
ffffffffc0202c6a:	6ba2                	ld	s7,8(sp)
ffffffffc0202c6c:	6161                	addi	sp,sp,80
ffffffffc0202c6e:	8082                	ret
            return NULL;
ffffffffc0202c70:	4501                	li	a0,0
ffffffffc0202c72:	b7e5                	j	ffffffffc0202c5a <get_pte+0x178>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202c74:	00003617          	auipc	a2,0x3
ffffffffc0202c78:	d1460613          	addi	a2,a2,-748 # ffffffffc0205988 <default_pmm_manager+0x38>
ffffffffc0202c7c:	10200593          	li	a1,258
ffffffffc0202c80:	00003517          	auipc	a0,0x3
ffffffffc0202c84:	d3050513          	addi	a0,a0,-720 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc0202c88:	c7afd0ef          	jal	ra,ffffffffc0200102 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202c8c:	00003617          	auipc	a2,0x3
ffffffffc0202c90:	cfc60613          	addi	a2,a2,-772 # ffffffffc0205988 <default_pmm_manager+0x38>
ffffffffc0202c94:	10f00593          	li	a1,271
ffffffffc0202c98:	00003517          	auipc	a0,0x3
ffffffffc0202c9c:	d1850513          	addi	a0,a0,-744 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc0202ca0:	c62fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202ca4:	86aa                	mv	a3,a0
ffffffffc0202ca6:	00003617          	auipc	a2,0x3
ffffffffc0202caa:	ce260613          	addi	a2,a2,-798 # ffffffffc0205988 <default_pmm_manager+0x38>
ffffffffc0202cae:	10b00593          	li	a1,267
ffffffffc0202cb2:	00003517          	auipc	a0,0x3
ffffffffc0202cb6:	cfe50513          	addi	a0,a0,-770 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc0202cba:	c48fd0ef          	jal	ra,ffffffffc0200102 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202cbe:	86aa                	mv	a3,a0
ffffffffc0202cc0:	00003617          	auipc	a2,0x3
ffffffffc0202cc4:	cc860613          	addi	a2,a2,-824 # ffffffffc0205988 <default_pmm_manager+0x38>
ffffffffc0202cc8:	0ff00593          	li	a1,255
ffffffffc0202ccc:	00003517          	auipc	a0,0x3
ffffffffc0202cd0:	ce450513          	addi	a0,a0,-796 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc0202cd4:	c2efd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202cd8 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202cd8:	1141                	addi	sp,sp,-16
ffffffffc0202cda:	e022                	sd	s0,0(sp)
ffffffffc0202cdc:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202cde:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202ce0:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202ce2:	e01ff0ef          	jal	ra,ffffffffc0202ae2 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0202ce6:	c011                	beqz	s0,ffffffffc0202cea <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0202ce8:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202cea:	c511                	beqz	a0,ffffffffc0202cf6 <get_page+0x1e>
ffffffffc0202cec:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202cee:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202cf0:	0017f713          	andi	a4,a5,1
ffffffffc0202cf4:	e709                	bnez	a4,ffffffffc0202cfe <get_page+0x26>
}
ffffffffc0202cf6:	60a2                	ld	ra,8(sp)
ffffffffc0202cf8:	6402                	ld	s0,0(sp)
ffffffffc0202cfa:	0141                	addi	sp,sp,16
ffffffffc0202cfc:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202cfe:	078a                	slli	a5,a5,0x2
ffffffffc0202d00:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202d02:	0000f717          	auipc	a4,0xf
ffffffffc0202d06:	84e73703          	ld	a4,-1970(a4) # ffffffffc0211550 <npage>
ffffffffc0202d0a:	02e7f263          	bgeu	a5,a4,ffffffffc0202d2e <get_page+0x56>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d0e:	fff80537          	lui	a0,0xfff80
ffffffffc0202d12:	97aa                	add	a5,a5,a0
ffffffffc0202d14:	60a2                	ld	ra,8(sp)
ffffffffc0202d16:	6402                	ld	s0,0(sp)
ffffffffc0202d18:	00379513          	slli	a0,a5,0x3
ffffffffc0202d1c:	97aa                	add	a5,a5,a0
ffffffffc0202d1e:	078e                	slli	a5,a5,0x3
ffffffffc0202d20:	0000f517          	auipc	a0,0xf
ffffffffc0202d24:	83853503          	ld	a0,-1992(a0) # ffffffffc0211558 <pages>
ffffffffc0202d28:	953e                	add	a0,a0,a5
ffffffffc0202d2a:	0141                	addi	sp,sp,16
ffffffffc0202d2c:	8082                	ret
ffffffffc0202d2e:	c71ff0ef          	jal	ra,ffffffffc020299e <pa2page.part.0>

ffffffffc0202d32 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202d32:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202d34:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202d36:	ec06                	sd	ra,24(sp)
ffffffffc0202d38:	e822                	sd	s0,16(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202d3a:	da9ff0ef          	jal	ra,ffffffffc0202ae2 <get_pte>
    if (ptep != NULL) {
ffffffffc0202d3e:	c511                	beqz	a0,ffffffffc0202d4a <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202d40:	611c                	ld	a5,0(a0)
ffffffffc0202d42:	842a                	mv	s0,a0
ffffffffc0202d44:	0017f713          	andi	a4,a5,1
ffffffffc0202d48:	e709                	bnez	a4,ffffffffc0202d52 <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0202d4a:	60e2                	ld	ra,24(sp)
ffffffffc0202d4c:	6442                	ld	s0,16(sp)
ffffffffc0202d4e:	6105                	addi	sp,sp,32
ffffffffc0202d50:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202d52:	078a                	slli	a5,a5,0x2
ffffffffc0202d54:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202d56:	0000e717          	auipc	a4,0xe
ffffffffc0202d5a:	7fa73703          	ld	a4,2042(a4) # ffffffffc0211550 <npage>
ffffffffc0202d5e:	06e7f563          	bgeu	a5,a4,ffffffffc0202dc8 <page_remove+0x96>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d62:	fff80737          	lui	a4,0xfff80
ffffffffc0202d66:	97ba                	add	a5,a5,a4
ffffffffc0202d68:	00379513          	slli	a0,a5,0x3
ffffffffc0202d6c:	97aa                	add	a5,a5,a0
ffffffffc0202d6e:	078e                	slli	a5,a5,0x3
ffffffffc0202d70:	0000e517          	auipc	a0,0xe
ffffffffc0202d74:	7e853503          	ld	a0,2024(a0) # ffffffffc0211558 <pages>
ffffffffc0202d78:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202d7a:	411c                	lw	a5,0(a0)
ffffffffc0202d7c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202d80:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202d82:	cb09                	beqz	a4,ffffffffc0202d94 <page_remove+0x62>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202d84:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202d88:	12000073          	sfence.vma
}
ffffffffc0202d8c:	60e2                	ld	ra,24(sp)
ffffffffc0202d8e:	6442                	ld	s0,16(sp)
ffffffffc0202d90:	6105                	addi	sp,sp,32
ffffffffc0202d92:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202d94:	100027f3          	csrr	a5,sstatus
ffffffffc0202d98:	8b89                	andi	a5,a5,2
ffffffffc0202d9a:	eb89                	bnez	a5,ffffffffc0202dac <page_remove+0x7a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202d9c:	0000e797          	auipc	a5,0xe
ffffffffc0202da0:	7c47b783          	ld	a5,1988(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0202da4:	739c                	ld	a5,32(a5)
ffffffffc0202da6:	4585                	li	a1,1
ffffffffc0202da8:	9782                	jalr	a5
    if (flag) {
ffffffffc0202daa:	bfe9                	j	ffffffffc0202d84 <page_remove+0x52>
        intr_disable();
ffffffffc0202dac:	e42a                	sd	a0,8(sp)
ffffffffc0202dae:	f40fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202db2:	0000e797          	auipc	a5,0xe
ffffffffc0202db6:	7ae7b783          	ld	a5,1966(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0202dba:	739c                	ld	a5,32(a5)
ffffffffc0202dbc:	6522                	ld	a0,8(sp)
ffffffffc0202dbe:	4585                	li	a1,1
ffffffffc0202dc0:	9782                	jalr	a5
        intr_enable();
ffffffffc0202dc2:	f26fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202dc6:	bf7d                	j	ffffffffc0202d84 <page_remove+0x52>
ffffffffc0202dc8:	bd7ff0ef          	jal	ra,ffffffffc020299e <pa2page.part.0>

ffffffffc0202dcc <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202dcc:	7179                	addi	sp,sp,-48
ffffffffc0202dce:	87b2                	mv	a5,a2
ffffffffc0202dd0:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202dd2:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202dd4:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202dd6:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202dd8:	ec26                	sd	s1,24(sp)
ffffffffc0202dda:	f406                	sd	ra,40(sp)
ffffffffc0202ddc:	e84a                	sd	s2,16(sp)
ffffffffc0202dde:	e44e                	sd	s3,8(sp)
ffffffffc0202de0:	e052                	sd	s4,0(sp)
ffffffffc0202de2:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202de4:	cffff0ef          	jal	ra,ffffffffc0202ae2 <get_pte>
    if (ptep == NULL) {
ffffffffc0202de8:	cd71                	beqz	a0,ffffffffc0202ec4 <page_insert+0xf8>
    page->ref += 1;
ffffffffc0202dea:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0202dec:	611c                	ld	a5,0(a0)
ffffffffc0202dee:	89aa                	mv	s3,a0
ffffffffc0202df0:	0016871b          	addiw	a4,a3,1
ffffffffc0202df4:	c018                	sw	a4,0(s0)
ffffffffc0202df6:	0017f713          	andi	a4,a5,1
ffffffffc0202dfa:	e331                	bnez	a4,ffffffffc0202e3e <page_insert+0x72>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202dfc:	0000e797          	auipc	a5,0xe
ffffffffc0202e00:	75c7b783          	ld	a5,1884(a5) # ffffffffc0211558 <pages>
ffffffffc0202e04:	40f407b3          	sub	a5,s0,a5
ffffffffc0202e08:	878d                	srai	a5,a5,0x3
ffffffffc0202e0a:	00003417          	auipc	s0,0x3
ffffffffc0202e0e:	41643403          	ld	s0,1046(s0) # ffffffffc0206220 <error_string+0x38>
ffffffffc0202e12:	028787b3          	mul	a5,a5,s0
ffffffffc0202e16:	00080437          	lui	s0,0x80
ffffffffc0202e1a:	97a2                	add	a5,a5,s0
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202e1c:	07aa                	slli	a5,a5,0xa
ffffffffc0202e1e:	8cdd                	or	s1,s1,a5
ffffffffc0202e20:	0014e493          	ori	s1,s1,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0202e24:	0099b023          	sd	s1,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202e28:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0202e2c:	4501                	li	a0,0
}
ffffffffc0202e2e:	70a2                	ld	ra,40(sp)
ffffffffc0202e30:	7402                	ld	s0,32(sp)
ffffffffc0202e32:	64e2                	ld	s1,24(sp)
ffffffffc0202e34:	6942                	ld	s2,16(sp)
ffffffffc0202e36:	69a2                	ld	s3,8(sp)
ffffffffc0202e38:	6a02                	ld	s4,0(sp)
ffffffffc0202e3a:	6145                	addi	sp,sp,48
ffffffffc0202e3c:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202e3e:	00279713          	slli	a4,a5,0x2
ffffffffc0202e42:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202e44:	0000e797          	auipc	a5,0xe
ffffffffc0202e48:	70c7b783          	ld	a5,1804(a5) # ffffffffc0211550 <npage>
ffffffffc0202e4c:	06f77e63          	bgeu	a4,a5,ffffffffc0202ec8 <page_insert+0xfc>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e50:	fff807b7          	lui	a5,0xfff80
ffffffffc0202e54:	973e                	add	a4,a4,a5
ffffffffc0202e56:	0000ea17          	auipc	s4,0xe
ffffffffc0202e5a:	702a0a13          	addi	s4,s4,1794 # ffffffffc0211558 <pages>
ffffffffc0202e5e:	000a3783          	ld	a5,0(s4)
ffffffffc0202e62:	00371913          	slli	s2,a4,0x3
ffffffffc0202e66:	993a                	add	s2,s2,a4
ffffffffc0202e68:	090e                	slli	s2,s2,0x3
ffffffffc0202e6a:	993e                	add	s2,s2,a5
        if (p == page) {
ffffffffc0202e6c:	03240063          	beq	s0,s2,ffffffffc0202e8c <page_insert+0xc0>
    page->ref -= 1;
ffffffffc0202e70:	00092783          	lw	a5,0(s2)
ffffffffc0202e74:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202e78:	00e92023          	sw	a4,0(s2)
        if (page_ref(page) ==
ffffffffc0202e7c:	cb11                	beqz	a4,ffffffffc0202e90 <page_insert+0xc4>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202e7e:	0009b023          	sd	zero,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202e82:	12000073          	sfence.vma
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202e86:	000a3783          	ld	a5,0(s4)
}
ffffffffc0202e8a:	bfad                	j	ffffffffc0202e04 <page_insert+0x38>
    page->ref -= 1;
ffffffffc0202e8c:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0202e8e:	bf9d                	j	ffffffffc0202e04 <page_insert+0x38>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202e90:	100027f3          	csrr	a5,sstatus
ffffffffc0202e94:	8b89                	andi	a5,a5,2
ffffffffc0202e96:	eb91                	bnez	a5,ffffffffc0202eaa <page_insert+0xde>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202e98:	0000e797          	auipc	a5,0xe
ffffffffc0202e9c:	6c87b783          	ld	a5,1736(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0202ea0:	739c                	ld	a5,32(a5)
ffffffffc0202ea2:	4585                	li	a1,1
ffffffffc0202ea4:	854a                	mv	a0,s2
ffffffffc0202ea6:	9782                	jalr	a5
    if (flag) {
ffffffffc0202ea8:	bfd9                	j	ffffffffc0202e7e <page_insert+0xb2>
        intr_disable();
ffffffffc0202eaa:	e44fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202eae:	0000e797          	auipc	a5,0xe
ffffffffc0202eb2:	6b27b783          	ld	a5,1714(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0202eb6:	739c                	ld	a5,32(a5)
ffffffffc0202eb8:	4585                	li	a1,1
ffffffffc0202eba:	854a                	mv	a0,s2
ffffffffc0202ebc:	9782                	jalr	a5
        intr_enable();
ffffffffc0202ebe:	e2afd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202ec2:	bf75                	j	ffffffffc0202e7e <page_insert+0xb2>
        return -E_NO_MEM;
ffffffffc0202ec4:	5571                	li	a0,-4
ffffffffc0202ec6:	b7a5                	j	ffffffffc0202e2e <page_insert+0x62>
ffffffffc0202ec8:	ad7ff0ef          	jal	ra,ffffffffc020299e <pa2page.part.0>

ffffffffc0202ecc <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202ecc:	00003797          	auipc	a5,0x3
ffffffffc0202ed0:	a8478793          	addi	a5,a5,-1404 # ffffffffc0205950 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202ed4:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0202ed6:	7159                	addi	sp,sp,-112
ffffffffc0202ed8:	f45e                	sd	s7,40(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202eda:	00003517          	auipc	a0,0x3
ffffffffc0202ede:	ae650513          	addi	a0,a0,-1306 # ffffffffc02059c0 <default_pmm_manager+0x70>
    pmm_manager = &default_pmm_manager;
ffffffffc0202ee2:	0000eb97          	auipc	s7,0xe
ffffffffc0202ee6:	67eb8b93          	addi	s7,s7,1662 # ffffffffc0211560 <pmm_manager>
void pmm_init(void) {
ffffffffc0202eea:	f486                	sd	ra,104(sp)
ffffffffc0202eec:	f0a2                	sd	s0,96(sp)
ffffffffc0202eee:	eca6                	sd	s1,88(sp)
ffffffffc0202ef0:	e8ca                	sd	s2,80(sp)
ffffffffc0202ef2:	e4ce                	sd	s3,72(sp)
ffffffffc0202ef4:	f85a                	sd	s6,48(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202ef6:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0202efa:	e0d2                	sd	s4,64(sp)
ffffffffc0202efc:	fc56                	sd	s5,56(sp)
ffffffffc0202efe:	f062                	sd	s8,32(sp)
ffffffffc0202f00:	ec66                	sd	s9,24(sp)
ffffffffc0202f02:	e86a                	sd	s10,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202f04:	9b6fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pmm_manager->init();
ffffffffc0202f08:	000bb783          	ld	a5,0(s7)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0202f0c:	4445                	li	s0,17
ffffffffc0202f0e:	40100913          	li	s2,1025
    pmm_manager->init();
ffffffffc0202f12:	679c                	ld	a5,8(a5)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202f14:	0000e997          	auipc	s3,0xe
ffffffffc0202f18:	65498993          	addi	s3,s3,1620 # ffffffffc0211568 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0202f1c:	0000e497          	auipc	s1,0xe
ffffffffc0202f20:	63448493          	addi	s1,s1,1588 # ffffffffc0211550 <npage>
    pmm_manager->init();
ffffffffc0202f24:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202f26:	57f5                	li	a5,-3
ffffffffc0202f28:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0202f2a:	07e006b7          	lui	a3,0x7e00
ffffffffc0202f2e:	01b41613          	slli	a2,s0,0x1b
ffffffffc0202f32:	01591593          	slli	a1,s2,0x15
ffffffffc0202f36:	00003517          	auipc	a0,0x3
ffffffffc0202f3a:	aa250513          	addi	a0,a0,-1374 # ffffffffc02059d8 <default_pmm_manager+0x88>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202f3e:	00f9b023          	sd	a5,0(s3)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0202f42:	978fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0202f46:	00003517          	auipc	a0,0x3
ffffffffc0202f4a:	ac250513          	addi	a0,a0,-1342 # ffffffffc0205a08 <default_pmm_manager+0xb8>
ffffffffc0202f4e:	96cfd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202f52:	01b41693          	slli	a3,s0,0x1b
ffffffffc0202f56:	16fd                	addi	a3,a3,-1
ffffffffc0202f58:	07e005b7          	lui	a1,0x7e00
ffffffffc0202f5c:	01591613          	slli	a2,s2,0x15
ffffffffc0202f60:	00003517          	auipc	a0,0x3
ffffffffc0202f64:	ac050513          	addi	a0,a0,-1344 # ffffffffc0205a20 <default_pmm_manager+0xd0>
ffffffffc0202f68:	952fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202f6c:	777d                	lui	a4,0xfffff
ffffffffc0202f6e:	0000f797          	auipc	a5,0xf
ffffffffc0202f72:	60178793          	addi	a5,a5,1537 # ffffffffc021256f <end+0xfff>
ffffffffc0202f76:	8ff9                	and	a5,a5,a4
ffffffffc0202f78:	0000eb17          	auipc	s6,0xe
ffffffffc0202f7c:	5e0b0b13          	addi	s6,s6,1504 # ffffffffc0211558 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0202f80:	00088737          	lui	a4,0x88
ffffffffc0202f84:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202f86:	00fb3023          	sd	a5,0(s6)
ffffffffc0202f8a:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202f8c:	4701                	li	a4,0
ffffffffc0202f8e:	4505                	li	a0,1
ffffffffc0202f90:	fff805b7          	lui	a1,0xfff80
ffffffffc0202f94:	a019                	j	ffffffffc0202f9a <pmm_init+0xce>
        SetPageReserved(pages + i);
ffffffffc0202f96:	000b3783          	ld	a5,0(s6)
ffffffffc0202f9a:	97b6                	add	a5,a5,a3
ffffffffc0202f9c:	07a1                	addi	a5,a5,8
ffffffffc0202f9e:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202fa2:	609c                	ld	a5,0(s1)
ffffffffc0202fa4:	0705                	addi	a4,a4,1
ffffffffc0202fa6:	04868693          	addi	a3,a3,72 # 7e00048 <kern_entry-0xffffffffb83fffb8>
ffffffffc0202faa:	00b78633          	add	a2,a5,a1
ffffffffc0202fae:	fec764e3          	bltu	a4,a2,ffffffffc0202f96 <pmm_init+0xca>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202fb2:	000b3503          	ld	a0,0(s6)
ffffffffc0202fb6:	00379693          	slli	a3,a5,0x3
ffffffffc0202fba:	96be                	add	a3,a3,a5
ffffffffc0202fbc:	fdc00737          	lui	a4,0xfdc00
ffffffffc0202fc0:	972a                	add	a4,a4,a0
ffffffffc0202fc2:	068e                	slli	a3,a3,0x3
ffffffffc0202fc4:	96ba                	add	a3,a3,a4
ffffffffc0202fc6:	c0200737          	lui	a4,0xc0200
ffffffffc0202fca:	64e6e463          	bltu	a3,a4,ffffffffc0203612 <pmm_init+0x746>
ffffffffc0202fce:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0202fd2:	4645                	li	a2,17
ffffffffc0202fd4:	066e                	slli	a2,a2,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202fd6:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0202fd8:	4ec6e263          	bltu	a3,a2,ffffffffc02034bc <pmm_init+0x5f0>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0202fdc:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202fe0:	0000e917          	auipc	s2,0xe
ffffffffc0202fe4:	56890913          	addi	s2,s2,1384 # ffffffffc0211548 <boot_pgdir>
    pmm_manager->check();
ffffffffc0202fe8:	7b9c                	ld	a5,48(a5)
ffffffffc0202fea:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202fec:	00003517          	auipc	a0,0x3
ffffffffc0202ff0:	a8450513          	addi	a0,a0,-1404 # ffffffffc0205a70 <default_pmm_manager+0x120>
ffffffffc0202ff4:	8c6fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202ff8:	00006697          	auipc	a3,0x6
ffffffffc0202ffc:	00868693          	addi	a3,a3,8 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0203000:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203004:	c02007b7          	lui	a5,0xc0200
ffffffffc0203008:	62f6e163          	bltu	a3,a5,ffffffffc020362a <pmm_init+0x75e>
ffffffffc020300c:	0009b783          	ld	a5,0(s3)
ffffffffc0203010:	8e9d                	sub	a3,a3,a5
ffffffffc0203012:	0000e797          	auipc	a5,0xe
ffffffffc0203016:	52d7b723          	sd	a3,1326(a5) # ffffffffc0211540 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020301a:	100027f3          	csrr	a5,sstatus
ffffffffc020301e:	8b89                	andi	a5,a5,2
ffffffffc0203020:	4c079763          	bnez	a5,ffffffffc02034ee <pmm_init+0x622>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0203024:	000bb783          	ld	a5,0(s7)
ffffffffc0203028:	779c                	ld	a5,40(a5)
ffffffffc020302a:	9782                	jalr	a5
ffffffffc020302c:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020302e:	6098                	ld	a4,0(s1)
ffffffffc0203030:	c80007b7          	lui	a5,0xc8000
ffffffffc0203034:	83b1                	srli	a5,a5,0xc
ffffffffc0203036:	62e7e663          	bltu	a5,a4,ffffffffc0203662 <pmm_init+0x796>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020303a:	00093503          	ld	a0,0(s2)
ffffffffc020303e:	60050263          	beqz	a0,ffffffffc0203642 <pmm_init+0x776>
ffffffffc0203042:	03451793          	slli	a5,a0,0x34
ffffffffc0203046:	5e079e63          	bnez	a5,ffffffffc0203642 <pmm_init+0x776>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020304a:	4601                	li	a2,0
ffffffffc020304c:	4581                	li	a1,0
ffffffffc020304e:	c8bff0ef          	jal	ra,ffffffffc0202cd8 <get_page>
ffffffffc0203052:	66051a63          	bnez	a0,ffffffffc02036c6 <pmm_init+0x7fa>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0203056:	4505                	li	a0,1
ffffffffc0203058:	97fff0ef          	jal	ra,ffffffffc02029d6 <alloc_pages>
ffffffffc020305c:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc020305e:	00093503          	ld	a0,0(s2)
ffffffffc0203062:	4681                	li	a3,0
ffffffffc0203064:	4601                	li	a2,0
ffffffffc0203066:	85d2                	mv	a1,s4
ffffffffc0203068:	d65ff0ef          	jal	ra,ffffffffc0202dcc <page_insert>
ffffffffc020306c:	62051d63          	bnez	a0,ffffffffc02036a6 <pmm_init+0x7da>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0203070:	00093503          	ld	a0,0(s2)
ffffffffc0203074:	4601                	li	a2,0
ffffffffc0203076:	4581                	li	a1,0
ffffffffc0203078:	a6bff0ef          	jal	ra,ffffffffc0202ae2 <get_pte>
ffffffffc020307c:	60050563          	beqz	a0,ffffffffc0203686 <pmm_init+0x7ba>
    assert(pte2page(*ptep) == p1);
ffffffffc0203080:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203082:	0017f713          	andi	a4,a5,1
ffffffffc0203086:	5e070e63          	beqz	a4,ffffffffc0203682 <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc020308a:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020308c:	078a                	slli	a5,a5,0x2
ffffffffc020308e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203090:	56c7ff63          	bgeu	a5,a2,ffffffffc020360e <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0203094:	fff80737          	lui	a4,0xfff80
ffffffffc0203098:	97ba                	add	a5,a5,a4
ffffffffc020309a:	000b3683          	ld	a3,0(s6)
ffffffffc020309e:	00379713          	slli	a4,a5,0x3
ffffffffc02030a2:	97ba                	add	a5,a5,a4
ffffffffc02030a4:	078e                	slli	a5,a5,0x3
ffffffffc02030a6:	97b6                	add	a5,a5,a3
ffffffffc02030a8:	14fa18e3          	bne	s4,a5,ffffffffc02039f8 <pmm_init+0xb2c>
    assert(page_ref(p1) == 1);
ffffffffc02030ac:	000a2703          	lw	a4,0(s4)
ffffffffc02030b0:	4785                	li	a5,1
ffffffffc02030b2:	16f71fe3          	bne	a4,a5,ffffffffc0203a30 <pmm_init+0xb64>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02030b6:	00093503          	ld	a0,0(s2)
ffffffffc02030ba:	77fd                	lui	a5,0xfffff
ffffffffc02030bc:	6114                	ld	a3,0(a0)
ffffffffc02030be:	068a                	slli	a3,a3,0x2
ffffffffc02030c0:	8efd                	and	a3,a3,a5
ffffffffc02030c2:	00c6d713          	srli	a4,a3,0xc
ffffffffc02030c6:	14c779e3          	bgeu	a4,a2,ffffffffc0203a18 <pmm_init+0xb4c>
ffffffffc02030ca:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02030ce:	96e2                	add	a3,a3,s8
ffffffffc02030d0:	0006ba83          	ld	s5,0(a3)
ffffffffc02030d4:	0a8a                	slli	s5,s5,0x2
ffffffffc02030d6:	00fafab3          	and	s5,s5,a5
ffffffffc02030da:	00cad793          	srli	a5,s5,0xc
ffffffffc02030de:	66c7f463          	bgeu	a5,a2,ffffffffc0203746 <pmm_init+0x87a>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02030e2:	4601                	li	a2,0
ffffffffc02030e4:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02030e6:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02030e8:	9fbff0ef          	jal	ra,ffffffffc0202ae2 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02030ec:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02030ee:	63551c63          	bne	a0,s5,ffffffffc0203726 <pmm_init+0x85a>

    p2 = alloc_page();
ffffffffc02030f2:	4505                	li	a0,1
ffffffffc02030f4:	8e3ff0ef          	jal	ra,ffffffffc02029d6 <alloc_pages>
ffffffffc02030f8:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02030fa:	00093503          	ld	a0,0(s2)
ffffffffc02030fe:	46d1                	li	a3,20
ffffffffc0203100:	6605                	lui	a2,0x1
ffffffffc0203102:	85d6                	mv	a1,s5
ffffffffc0203104:	cc9ff0ef          	jal	ra,ffffffffc0202dcc <page_insert>
ffffffffc0203108:	5c051f63          	bnez	a0,ffffffffc02036e6 <pmm_init+0x81a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020310c:	00093503          	ld	a0,0(s2)
ffffffffc0203110:	4601                	li	a2,0
ffffffffc0203112:	6585                	lui	a1,0x1
ffffffffc0203114:	9cfff0ef          	jal	ra,ffffffffc0202ae2 <get_pte>
ffffffffc0203118:	12050ce3          	beqz	a0,ffffffffc0203a50 <pmm_init+0xb84>
    assert(*ptep & PTE_U);
ffffffffc020311c:	611c                	ld	a5,0(a0)
ffffffffc020311e:	0107f713          	andi	a4,a5,16
ffffffffc0203122:	72070f63          	beqz	a4,ffffffffc0203860 <pmm_init+0x994>
    assert(*ptep & PTE_W);
ffffffffc0203126:	8b91                	andi	a5,a5,4
ffffffffc0203128:	6e078c63          	beqz	a5,ffffffffc0203820 <pmm_init+0x954>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020312c:	00093503          	ld	a0,0(s2)
ffffffffc0203130:	611c                	ld	a5,0(a0)
ffffffffc0203132:	8bc1                	andi	a5,a5,16
ffffffffc0203134:	6c078663          	beqz	a5,ffffffffc0203800 <pmm_init+0x934>
    assert(page_ref(p2) == 1);
ffffffffc0203138:	000aa703          	lw	a4,0(s5)
ffffffffc020313c:	4785                	li	a5,1
ffffffffc020313e:	5cf71463          	bne	a4,a5,ffffffffc0203706 <pmm_init+0x83a>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0203142:	4681                	li	a3,0
ffffffffc0203144:	6605                	lui	a2,0x1
ffffffffc0203146:	85d2                	mv	a1,s4
ffffffffc0203148:	c85ff0ef          	jal	ra,ffffffffc0202dcc <page_insert>
ffffffffc020314c:	66051a63          	bnez	a0,ffffffffc02037c0 <pmm_init+0x8f4>
    assert(page_ref(p1) == 2);
ffffffffc0203150:	000a2703          	lw	a4,0(s4)
ffffffffc0203154:	4789                	li	a5,2
ffffffffc0203156:	64f71563          	bne	a4,a5,ffffffffc02037a0 <pmm_init+0x8d4>
    assert(page_ref(p2) == 0);
ffffffffc020315a:	000aa783          	lw	a5,0(s5)
ffffffffc020315e:	62079163          	bnez	a5,ffffffffc0203780 <pmm_init+0x8b4>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203162:	00093503          	ld	a0,0(s2)
ffffffffc0203166:	4601                	li	a2,0
ffffffffc0203168:	6585                	lui	a1,0x1
ffffffffc020316a:	979ff0ef          	jal	ra,ffffffffc0202ae2 <get_pte>
ffffffffc020316e:	5e050963          	beqz	a0,ffffffffc0203760 <pmm_init+0x894>
    assert(pte2page(*ptep) == p1);
ffffffffc0203172:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203174:	00177793          	andi	a5,a4,1
ffffffffc0203178:	50078563          	beqz	a5,ffffffffc0203682 <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc020317c:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020317e:	00271793          	slli	a5,a4,0x2
ffffffffc0203182:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203184:	48d7f563          	bgeu	a5,a3,ffffffffc020360e <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0203188:	fff806b7          	lui	a3,0xfff80
ffffffffc020318c:	97b6                	add	a5,a5,a3
ffffffffc020318e:	000b3603          	ld	a2,0(s6)
ffffffffc0203192:	00379693          	slli	a3,a5,0x3
ffffffffc0203196:	97b6                	add	a5,a5,a3
ffffffffc0203198:	078e                	slli	a5,a5,0x3
ffffffffc020319a:	97b2                	add	a5,a5,a2
ffffffffc020319c:	72fa1263          	bne	s4,a5,ffffffffc02038c0 <pmm_init+0x9f4>
    assert((*ptep & PTE_U) == 0);
ffffffffc02031a0:	8b41                	andi	a4,a4,16
ffffffffc02031a2:	6e071f63          	bnez	a4,ffffffffc02038a0 <pmm_init+0x9d4>

    page_remove(boot_pgdir, 0x0);
ffffffffc02031a6:	00093503          	ld	a0,0(s2)
ffffffffc02031aa:	4581                	li	a1,0
ffffffffc02031ac:	b87ff0ef          	jal	ra,ffffffffc0202d32 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02031b0:	000a2703          	lw	a4,0(s4)
ffffffffc02031b4:	4785                	li	a5,1
ffffffffc02031b6:	6cf71563          	bne	a4,a5,ffffffffc0203880 <pmm_init+0x9b4>
    assert(page_ref(p2) == 0);
ffffffffc02031ba:	000aa783          	lw	a5,0(s5)
ffffffffc02031be:	78079d63          	bnez	a5,ffffffffc0203958 <pmm_init+0xa8c>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc02031c2:	00093503          	ld	a0,0(s2)
ffffffffc02031c6:	6585                	lui	a1,0x1
ffffffffc02031c8:	b6bff0ef          	jal	ra,ffffffffc0202d32 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc02031cc:	000a2783          	lw	a5,0(s4)
ffffffffc02031d0:	76079463          	bnez	a5,ffffffffc0203938 <pmm_init+0xa6c>
    assert(page_ref(p2) == 0);
ffffffffc02031d4:	000aa783          	lw	a5,0(s5)
ffffffffc02031d8:	74079063          	bnez	a5,ffffffffc0203918 <pmm_init+0xa4c>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02031dc:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02031e0:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02031e2:	000a3783          	ld	a5,0(s4)
ffffffffc02031e6:	078a                	slli	a5,a5,0x2
ffffffffc02031e8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02031ea:	42c7f263          	bgeu	a5,a2,ffffffffc020360e <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02031ee:	fff80737          	lui	a4,0xfff80
ffffffffc02031f2:	973e                	add	a4,a4,a5
ffffffffc02031f4:	00371793          	slli	a5,a4,0x3
ffffffffc02031f8:	000b3503          	ld	a0,0(s6)
ffffffffc02031fc:	97ba                	add	a5,a5,a4
ffffffffc02031fe:	078e                	slli	a5,a5,0x3
static inline int page_ref(struct Page *page) { return page->ref; }
ffffffffc0203200:	00f50733          	add	a4,a0,a5
ffffffffc0203204:	4314                	lw	a3,0(a4)
ffffffffc0203206:	4705                	li	a4,1
ffffffffc0203208:	6ee69863          	bne	a3,a4,ffffffffc02038f8 <pmm_init+0xa2c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020320c:	4037d693          	srai	a3,a5,0x3
ffffffffc0203210:	00003c97          	auipc	s9,0x3
ffffffffc0203214:	010cbc83          	ld	s9,16(s9) # ffffffffc0206220 <error_string+0x38>
ffffffffc0203218:	039686b3          	mul	a3,a3,s9
ffffffffc020321c:	000805b7          	lui	a1,0x80
ffffffffc0203220:	96ae                	add	a3,a3,a1
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203222:	00c69713          	slli	a4,a3,0xc
ffffffffc0203226:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203228:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020322a:	6ac77b63          	bgeu	a4,a2,ffffffffc02038e0 <pmm_init+0xa14>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc020322e:	0009b703          	ld	a4,0(s3)
ffffffffc0203232:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc0203234:	629c                	ld	a5,0(a3)
ffffffffc0203236:	078a                	slli	a5,a5,0x2
ffffffffc0203238:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020323a:	3cc7fa63          	bgeu	a5,a2,ffffffffc020360e <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc020323e:	8f8d                	sub	a5,a5,a1
ffffffffc0203240:	00379713          	slli	a4,a5,0x3
ffffffffc0203244:	97ba                	add	a5,a5,a4
ffffffffc0203246:	078e                	slli	a5,a5,0x3
ffffffffc0203248:	953e                	add	a0,a0,a5
ffffffffc020324a:	100027f3          	csrr	a5,sstatus
ffffffffc020324e:	8b89                	andi	a5,a5,2
ffffffffc0203250:	2e079963          	bnez	a5,ffffffffc0203542 <pmm_init+0x676>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203254:	000bb783          	ld	a5,0(s7)
ffffffffc0203258:	4585                	li	a1,1
ffffffffc020325a:	739c                	ld	a5,32(a5)
ffffffffc020325c:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020325e:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0203262:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203264:	078a                	slli	a5,a5,0x2
ffffffffc0203266:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203268:	3ae7f363          	bgeu	a5,a4,ffffffffc020360e <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc020326c:	fff80737          	lui	a4,0xfff80
ffffffffc0203270:	97ba                	add	a5,a5,a4
ffffffffc0203272:	000b3503          	ld	a0,0(s6)
ffffffffc0203276:	00379713          	slli	a4,a5,0x3
ffffffffc020327a:	97ba                	add	a5,a5,a4
ffffffffc020327c:	078e                	slli	a5,a5,0x3
ffffffffc020327e:	953e                	add	a0,a0,a5
ffffffffc0203280:	100027f3          	csrr	a5,sstatus
ffffffffc0203284:	8b89                	andi	a5,a5,2
ffffffffc0203286:	2a079263          	bnez	a5,ffffffffc020352a <pmm_init+0x65e>
ffffffffc020328a:	000bb783          	ld	a5,0(s7)
ffffffffc020328e:	4585                	li	a1,1
ffffffffc0203290:	739c                	ld	a5,32(a5)
ffffffffc0203292:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0203294:	00093783          	ld	a5,0(s2)
ffffffffc0203298:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fdeda90>
ffffffffc020329c:	100027f3          	csrr	a5,sstatus
ffffffffc02032a0:	8b89                	andi	a5,a5,2
ffffffffc02032a2:	26079a63          	bnez	a5,ffffffffc0203516 <pmm_init+0x64a>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02032a6:	000bb783          	ld	a5,0(s7)
ffffffffc02032aa:	779c                	ld	a5,40(a5)
ffffffffc02032ac:	9782                	jalr	a5
ffffffffc02032ae:	8a2a                	mv	s4,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc02032b0:	73441463          	bne	s0,s4,ffffffffc02039d8 <pmm_init+0xb0c>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02032b4:	00003517          	auipc	a0,0x3
ffffffffc02032b8:	aa450513          	addi	a0,a0,-1372 # ffffffffc0205d58 <default_pmm_manager+0x408>
ffffffffc02032bc:	dfffc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02032c0:	100027f3          	csrr	a5,sstatus
ffffffffc02032c4:	8b89                	andi	a5,a5,2
ffffffffc02032c6:	22079e63          	bnez	a5,ffffffffc0203502 <pmm_init+0x636>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02032ca:	000bb783          	ld	a5,0(s7)
ffffffffc02032ce:	779c                	ld	a5,40(a5)
ffffffffc02032d0:	9782                	jalr	a5
ffffffffc02032d2:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02032d4:	6098                	ld	a4,0(s1)
ffffffffc02032d6:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02032da:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02032dc:	00c71793          	slli	a5,a4,0xc
ffffffffc02032e0:	6a05                	lui	s4,0x1
ffffffffc02032e2:	02f47c63          	bgeu	s0,a5,ffffffffc020331a <pmm_init+0x44e>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02032e6:	00c45793          	srli	a5,s0,0xc
ffffffffc02032ea:	00093503          	ld	a0,0(s2)
ffffffffc02032ee:	30e7f363          	bgeu	a5,a4,ffffffffc02035f4 <pmm_init+0x728>
ffffffffc02032f2:	0009b583          	ld	a1,0(s3)
ffffffffc02032f6:	4601                	li	a2,0
ffffffffc02032f8:	95a2                	add	a1,a1,s0
ffffffffc02032fa:	fe8ff0ef          	jal	ra,ffffffffc0202ae2 <get_pte>
ffffffffc02032fe:	2c050b63          	beqz	a0,ffffffffc02035d4 <pmm_init+0x708>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203302:	611c                	ld	a5,0(a0)
ffffffffc0203304:	078a                	slli	a5,a5,0x2
ffffffffc0203306:	0157f7b3          	and	a5,a5,s5
ffffffffc020330a:	2a879563          	bne	a5,s0,ffffffffc02035b4 <pmm_init+0x6e8>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020330e:	6098                	ld	a4,0(s1)
ffffffffc0203310:	9452                	add	s0,s0,s4
ffffffffc0203312:	00c71793          	slli	a5,a4,0xc
ffffffffc0203316:	fcf468e3          	bltu	s0,a5,ffffffffc02032e6 <pmm_init+0x41a>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc020331a:	00093783          	ld	a5,0(s2)
ffffffffc020331e:	639c                	ld	a5,0(a5)
ffffffffc0203320:	68079c63          	bnez	a5,ffffffffc02039b8 <pmm_init+0xaec>

    struct Page *p;
    p = alloc_page();
ffffffffc0203324:	4505                	li	a0,1
ffffffffc0203326:	eb0ff0ef          	jal	ra,ffffffffc02029d6 <alloc_pages>
ffffffffc020332a:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020332c:	00093503          	ld	a0,0(s2)
ffffffffc0203330:	4699                	li	a3,6
ffffffffc0203332:	10000613          	li	a2,256
ffffffffc0203336:	85d6                	mv	a1,s5
ffffffffc0203338:	a95ff0ef          	jal	ra,ffffffffc0202dcc <page_insert>
ffffffffc020333c:	64051e63          	bnez	a0,ffffffffc0203998 <pmm_init+0xacc>
    assert(page_ref(p) == 1);
ffffffffc0203340:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fdeda90>
ffffffffc0203344:	4785                	li	a5,1
ffffffffc0203346:	62f71963          	bne	a4,a5,ffffffffc0203978 <pmm_init+0xaac>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020334a:	00093503          	ld	a0,0(s2)
ffffffffc020334e:	6405                	lui	s0,0x1
ffffffffc0203350:	4699                	li	a3,6
ffffffffc0203352:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc0203356:	85d6                	mv	a1,s5
ffffffffc0203358:	a75ff0ef          	jal	ra,ffffffffc0202dcc <page_insert>
ffffffffc020335c:	48051263          	bnez	a0,ffffffffc02037e0 <pmm_init+0x914>
    assert(page_ref(p) == 2);
ffffffffc0203360:	000aa703          	lw	a4,0(s5)
ffffffffc0203364:	4789                	li	a5,2
ffffffffc0203366:	74f71563          	bne	a4,a5,ffffffffc0203ab0 <pmm_init+0xbe4>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc020336a:	00003597          	auipc	a1,0x3
ffffffffc020336e:	b2658593          	addi	a1,a1,-1242 # ffffffffc0205e90 <default_pmm_manager+0x540>
ffffffffc0203372:	10000513          	li	a0,256
ffffffffc0203376:	35d000ef          	jal	ra,ffffffffc0203ed2 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020337a:	10040593          	addi	a1,s0,256
ffffffffc020337e:	10000513          	li	a0,256
ffffffffc0203382:	363000ef          	jal	ra,ffffffffc0203ee4 <strcmp>
ffffffffc0203386:	70051563          	bnez	a0,ffffffffc0203a90 <pmm_init+0xbc4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020338a:	000b3683          	ld	a3,0(s6)
ffffffffc020338e:	00080d37          	lui	s10,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203392:	547d                	li	s0,-1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203394:	40da86b3          	sub	a3,s5,a3
ffffffffc0203398:	868d                	srai	a3,a3,0x3
ffffffffc020339a:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020339e:	609c                	ld	a5,0(s1)
ffffffffc02033a0:	8031                	srli	s0,s0,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02033a2:	96ea                	add	a3,a3,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02033a4:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc02033a8:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02033aa:	52f77b63          	bgeu	a4,a5,ffffffffc02038e0 <pmm_init+0xa14>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02033ae:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc02033b2:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02033b6:	96be                	add	a3,a3,a5
ffffffffc02033b8:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fd6eb90>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02033bc:	2e1000ef          	jal	ra,ffffffffc0203e9c <strlen>
ffffffffc02033c0:	6a051863          	bnez	a0,ffffffffc0203a70 <pmm_init+0xba4>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02033c4:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02033c8:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02033ca:	000a3783          	ld	a5,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc02033ce:	078a                	slli	a5,a5,0x2
ffffffffc02033d0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02033d2:	22e7fe63          	bgeu	a5,a4,ffffffffc020360e <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02033d6:	41a787b3          	sub	a5,a5,s10
ffffffffc02033da:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02033de:	96be                	add	a3,a3,a5
ffffffffc02033e0:	03968cb3          	mul	s9,a3,s9
ffffffffc02033e4:	01ac86b3          	add	a3,s9,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02033e8:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02033ea:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02033ec:	4ee47a63          	bgeu	s0,a4,ffffffffc02038e0 <pmm_init+0xa14>
ffffffffc02033f0:	0009b403          	ld	s0,0(s3)
ffffffffc02033f4:	9436                	add	s0,s0,a3
ffffffffc02033f6:	100027f3          	csrr	a5,sstatus
ffffffffc02033fa:	8b89                	andi	a5,a5,2
ffffffffc02033fc:	1a079163          	bnez	a5,ffffffffc020359e <pmm_init+0x6d2>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203400:	000bb783          	ld	a5,0(s7)
ffffffffc0203404:	4585                	li	a1,1
ffffffffc0203406:	8556                	mv	a0,s5
ffffffffc0203408:	739c                	ld	a5,32(a5)
ffffffffc020340a:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020340c:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc020340e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203410:	078a                	slli	a5,a5,0x2
ffffffffc0203412:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203414:	1ee7fd63          	bgeu	a5,a4,ffffffffc020360e <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0203418:	fff80737          	lui	a4,0xfff80
ffffffffc020341c:	97ba                	add	a5,a5,a4
ffffffffc020341e:	000b3503          	ld	a0,0(s6)
ffffffffc0203422:	00379713          	slli	a4,a5,0x3
ffffffffc0203426:	97ba                	add	a5,a5,a4
ffffffffc0203428:	078e                	slli	a5,a5,0x3
ffffffffc020342a:	953e                	add	a0,a0,a5
ffffffffc020342c:	100027f3          	csrr	a5,sstatus
ffffffffc0203430:	8b89                	andi	a5,a5,2
ffffffffc0203432:	14079a63          	bnez	a5,ffffffffc0203586 <pmm_init+0x6ba>
ffffffffc0203436:	000bb783          	ld	a5,0(s7)
ffffffffc020343a:	4585                	li	a1,1
ffffffffc020343c:	739c                	ld	a5,32(a5)
ffffffffc020343e:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203440:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0203444:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203446:	078a                	slli	a5,a5,0x2
ffffffffc0203448:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020344a:	1ce7f263          	bgeu	a5,a4,ffffffffc020360e <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc020344e:	fff80737          	lui	a4,0xfff80
ffffffffc0203452:	97ba                	add	a5,a5,a4
ffffffffc0203454:	000b3503          	ld	a0,0(s6)
ffffffffc0203458:	00379713          	slli	a4,a5,0x3
ffffffffc020345c:	97ba                	add	a5,a5,a4
ffffffffc020345e:	078e                	slli	a5,a5,0x3
ffffffffc0203460:	953e                	add	a0,a0,a5
ffffffffc0203462:	100027f3          	csrr	a5,sstatus
ffffffffc0203466:	8b89                	andi	a5,a5,2
ffffffffc0203468:	10079363          	bnez	a5,ffffffffc020356e <pmm_init+0x6a2>
ffffffffc020346c:	000bb783          	ld	a5,0(s7)
ffffffffc0203470:	4585                	li	a1,1
ffffffffc0203472:	739c                	ld	a5,32(a5)
ffffffffc0203474:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0203476:	00093783          	ld	a5,0(s2)
ffffffffc020347a:	0007b023          	sd	zero,0(a5)
ffffffffc020347e:	100027f3          	csrr	a5,sstatus
ffffffffc0203482:	8b89                	andi	a5,a5,2
ffffffffc0203484:	0c079b63          	bnez	a5,ffffffffc020355a <pmm_init+0x68e>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0203488:	000bb783          	ld	a5,0(s7)
ffffffffc020348c:	779c                	ld	a5,40(a5)
ffffffffc020348e:	9782                	jalr	a5
ffffffffc0203490:	842a                	mv	s0,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc0203492:	3a8c1763          	bne	s8,s0,ffffffffc0203840 <pmm_init+0x974>
}
ffffffffc0203496:	7406                	ld	s0,96(sp)
ffffffffc0203498:	70a6                	ld	ra,104(sp)
ffffffffc020349a:	64e6                	ld	s1,88(sp)
ffffffffc020349c:	6946                	ld	s2,80(sp)
ffffffffc020349e:	69a6                	ld	s3,72(sp)
ffffffffc02034a0:	6a06                	ld	s4,64(sp)
ffffffffc02034a2:	7ae2                	ld	s5,56(sp)
ffffffffc02034a4:	7b42                	ld	s6,48(sp)
ffffffffc02034a6:	7ba2                	ld	s7,40(sp)
ffffffffc02034a8:	7c02                	ld	s8,32(sp)
ffffffffc02034aa:	6ce2                	ld	s9,24(sp)
ffffffffc02034ac:	6d42                	ld	s10,16(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02034ae:	00003517          	auipc	a0,0x3
ffffffffc02034b2:	a5a50513          	addi	a0,a0,-1446 # ffffffffc0205f08 <default_pmm_manager+0x5b8>
}
ffffffffc02034b6:	6165                	addi	sp,sp,112
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02034b8:	c03fc06f          	j	ffffffffc02000ba <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02034bc:	6705                	lui	a4,0x1
ffffffffc02034be:	177d                	addi	a4,a4,-1
ffffffffc02034c0:	96ba                	add	a3,a3,a4
ffffffffc02034c2:	777d                	lui	a4,0xfffff
ffffffffc02034c4:	8f75                	and	a4,a4,a3
    if (PPN(pa) >= npage) {
ffffffffc02034c6:	00c75693          	srli	a3,a4,0xc
ffffffffc02034ca:	14f6f263          	bgeu	a3,a5,ffffffffc020360e <pmm_init+0x742>
    pmm_manager->init_memmap(base, n);
ffffffffc02034ce:	000bb803          	ld	a6,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc02034d2:	95b6                	add	a1,a1,a3
ffffffffc02034d4:	00359793          	slli	a5,a1,0x3
ffffffffc02034d8:	97ae                	add	a5,a5,a1
ffffffffc02034da:	01083683          	ld	a3,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02034de:	40e60733          	sub	a4,a2,a4
ffffffffc02034e2:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02034e4:	00c75593          	srli	a1,a4,0xc
ffffffffc02034e8:	953e                	add	a0,a0,a5
ffffffffc02034ea:	9682                	jalr	a3
}
ffffffffc02034ec:	bcc5                	j	ffffffffc0202fdc <pmm_init+0x110>
        intr_disable();
ffffffffc02034ee:	800fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02034f2:	000bb783          	ld	a5,0(s7)
ffffffffc02034f6:	779c                	ld	a5,40(a5)
ffffffffc02034f8:	9782                	jalr	a5
ffffffffc02034fa:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02034fc:	fedfc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203500:	b63d                	j	ffffffffc020302e <pmm_init+0x162>
        intr_disable();
ffffffffc0203502:	fedfc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0203506:	000bb783          	ld	a5,0(s7)
ffffffffc020350a:	779c                	ld	a5,40(a5)
ffffffffc020350c:	9782                	jalr	a5
ffffffffc020350e:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0203510:	fd9fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203514:	b3c1                	j	ffffffffc02032d4 <pmm_init+0x408>
        intr_disable();
ffffffffc0203516:	fd9fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc020351a:	000bb783          	ld	a5,0(s7)
ffffffffc020351e:	779c                	ld	a5,40(a5)
ffffffffc0203520:	9782                	jalr	a5
ffffffffc0203522:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0203524:	fc5fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203528:	b361                	j	ffffffffc02032b0 <pmm_init+0x3e4>
ffffffffc020352a:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020352c:	fc3fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203530:	000bb783          	ld	a5,0(s7)
ffffffffc0203534:	6522                	ld	a0,8(sp)
ffffffffc0203536:	4585                	li	a1,1
ffffffffc0203538:	739c                	ld	a5,32(a5)
ffffffffc020353a:	9782                	jalr	a5
        intr_enable();
ffffffffc020353c:	fadfc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203540:	bb91                	j	ffffffffc0203294 <pmm_init+0x3c8>
ffffffffc0203542:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203544:	fabfc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0203548:	000bb783          	ld	a5,0(s7)
ffffffffc020354c:	6522                	ld	a0,8(sp)
ffffffffc020354e:	4585                	li	a1,1
ffffffffc0203550:	739c                	ld	a5,32(a5)
ffffffffc0203552:	9782                	jalr	a5
        intr_enable();
ffffffffc0203554:	f95fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203558:	b319                	j	ffffffffc020325e <pmm_init+0x392>
        intr_disable();
ffffffffc020355a:	f95fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020355e:	000bb783          	ld	a5,0(s7)
ffffffffc0203562:	779c                	ld	a5,40(a5)
ffffffffc0203564:	9782                	jalr	a5
ffffffffc0203566:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203568:	f81fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020356c:	b71d                	j	ffffffffc0203492 <pmm_init+0x5c6>
ffffffffc020356e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203570:	f7ffc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203574:	000bb783          	ld	a5,0(s7)
ffffffffc0203578:	6522                	ld	a0,8(sp)
ffffffffc020357a:	4585                	li	a1,1
ffffffffc020357c:	739c                	ld	a5,32(a5)
ffffffffc020357e:	9782                	jalr	a5
        intr_enable();
ffffffffc0203580:	f69fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203584:	bdcd                	j	ffffffffc0203476 <pmm_init+0x5aa>
ffffffffc0203586:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203588:	f67fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc020358c:	000bb783          	ld	a5,0(s7)
ffffffffc0203590:	6522                	ld	a0,8(sp)
ffffffffc0203592:	4585                	li	a1,1
ffffffffc0203594:	739c                	ld	a5,32(a5)
ffffffffc0203596:	9782                	jalr	a5
        intr_enable();
ffffffffc0203598:	f51fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020359c:	b555                	j	ffffffffc0203440 <pmm_init+0x574>
        intr_disable();
ffffffffc020359e:	f51fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02035a2:	000bb783          	ld	a5,0(s7)
ffffffffc02035a6:	4585                	li	a1,1
ffffffffc02035a8:	8556                	mv	a0,s5
ffffffffc02035aa:	739c                	ld	a5,32(a5)
ffffffffc02035ac:	9782                	jalr	a5
        intr_enable();
ffffffffc02035ae:	f3bfc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02035b2:	bda9                	j	ffffffffc020340c <pmm_init+0x540>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02035b4:	00003697          	auipc	a3,0x3
ffffffffc02035b8:	80468693          	addi	a3,a3,-2044 # ffffffffc0205db8 <default_pmm_manager+0x468>
ffffffffc02035bc:	00001617          	auipc	a2,0x1
ffffffffc02035c0:	7c460613          	addi	a2,a2,1988 # ffffffffc0204d80 <commands+0x720>
ffffffffc02035c4:	1ce00593          	li	a1,462
ffffffffc02035c8:	00002517          	auipc	a0,0x2
ffffffffc02035cc:	3e850513          	addi	a0,a0,1000 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc02035d0:	b33fc0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02035d4:	00002697          	auipc	a3,0x2
ffffffffc02035d8:	7a468693          	addi	a3,a3,1956 # ffffffffc0205d78 <default_pmm_manager+0x428>
ffffffffc02035dc:	00001617          	auipc	a2,0x1
ffffffffc02035e0:	7a460613          	addi	a2,a2,1956 # ffffffffc0204d80 <commands+0x720>
ffffffffc02035e4:	1cd00593          	li	a1,461
ffffffffc02035e8:	00002517          	auipc	a0,0x2
ffffffffc02035ec:	3c850513          	addi	a0,a0,968 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc02035f0:	b13fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc02035f4:	86a2                	mv	a3,s0
ffffffffc02035f6:	00002617          	auipc	a2,0x2
ffffffffc02035fa:	39260613          	addi	a2,a2,914 # ffffffffc0205988 <default_pmm_manager+0x38>
ffffffffc02035fe:	1cd00593          	li	a1,461
ffffffffc0203602:	00002517          	auipc	a0,0x2
ffffffffc0203606:	3ae50513          	addi	a0,a0,942 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc020360a:	af9fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc020360e:	b90ff0ef          	jal	ra,ffffffffc020299e <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203612:	00002617          	auipc	a2,0x2
ffffffffc0203616:	43660613          	addi	a2,a2,1078 # ffffffffc0205a48 <default_pmm_manager+0xf8>
ffffffffc020361a:	07700593          	li	a1,119
ffffffffc020361e:	00002517          	auipc	a0,0x2
ffffffffc0203622:	39250513          	addi	a0,a0,914 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc0203626:	addfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020362a:	00002617          	auipc	a2,0x2
ffffffffc020362e:	41e60613          	addi	a2,a2,1054 # ffffffffc0205a48 <default_pmm_manager+0xf8>
ffffffffc0203632:	0bd00593          	li	a1,189
ffffffffc0203636:	00002517          	auipc	a0,0x2
ffffffffc020363a:	37a50513          	addi	a0,a0,890 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc020363e:	ac5fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0203642:	00002697          	auipc	a3,0x2
ffffffffc0203646:	46e68693          	addi	a3,a3,1134 # ffffffffc0205ab0 <default_pmm_manager+0x160>
ffffffffc020364a:	00001617          	auipc	a2,0x1
ffffffffc020364e:	73660613          	addi	a2,a2,1846 # ffffffffc0204d80 <commands+0x720>
ffffffffc0203652:	19300593          	li	a1,403
ffffffffc0203656:	00002517          	auipc	a0,0x2
ffffffffc020365a:	35a50513          	addi	a0,a0,858 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc020365e:	aa5fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203662:	00002697          	auipc	a3,0x2
ffffffffc0203666:	42e68693          	addi	a3,a3,1070 # ffffffffc0205a90 <default_pmm_manager+0x140>
ffffffffc020366a:	00001617          	auipc	a2,0x1
ffffffffc020366e:	71660613          	addi	a2,a2,1814 # ffffffffc0204d80 <commands+0x720>
ffffffffc0203672:	19200593          	li	a1,402
ffffffffc0203676:	00002517          	auipc	a0,0x2
ffffffffc020367a:	33a50513          	addi	a0,a0,826 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc020367e:	a85fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203682:	b38ff0ef          	jal	ra,ffffffffc02029ba <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0203686:	00002697          	auipc	a3,0x2
ffffffffc020368a:	4ba68693          	addi	a3,a3,1210 # ffffffffc0205b40 <default_pmm_manager+0x1f0>
ffffffffc020368e:	00001617          	auipc	a2,0x1
ffffffffc0203692:	6f260613          	addi	a2,a2,1778 # ffffffffc0204d80 <commands+0x720>
ffffffffc0203696:	19a00593          	li	a1,410
ffffffffc020369a:	00002517          	auipc	a0,0x2
ffffffffc020369e:	31650513          	addi	a0,a0,790 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc02036a2:	a61fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02036a6:	00002697          	auipc	a3,0x2
ffffffffc02036aa:	46a68693          	addi	a3,a3,1130 # ffffffffc0205b10 <default_pmm_manager+0x1c0>
ffffffffc02036ae:	00001617          	auipc	a2,0x1
ffffffffc02036b2:	6d260613          	addi	a2,a2,1746 # ffffffffc0204d80 <commands+0x720>
ffffffffc02036b6:	19800593          	li	a1,408
ffffffffc02036ba:	00002517          	auipc	a0,0x2
ffffffffc02036be:	2f650513          	addi	a0,a0,758 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc02036c2:	a41fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02036c6:	00002697          	auipc	a3,0x2
ffffffffc02036ca:	42268693          	addi	a3,a3,1058 # ffffffffc0205ae8 <default_pmm_manager+0x198>
ffffffffc02036ce:	00001617          	auipc	a2,0x1
ffffffffc02036d2:	6b260613          	addi	a2,a2,1714 # ffffffffc0204d80 <commands+0x720>
ffffffffc02036d6:	19400593          	li	a1,404
ffffffffc02036da:	00002517          	auipc	a0,0x2
ffffffffc02036de:	2d650513          	addi	a0,a0,726 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc02036e2:	a21fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02036e6:	00002697          	auipc	a3,0x2
ffffffffc02036ea:	4e268693          	addi	a3,a3,1250 # ffffffffc0205bc8 <default_pmm_manager+0x278>
ffffffffc02036ee:	00001617          	auipc	a2,0x1
ffffffffc02036f2:	69260613          	addi	a2,a2,1682 # ffffffffc0204d80 <commands+0x720>
ffffffffc02036f6:	1a300593          	li	a1,419
ffffffffc02036fa:	00002517          	auipc	a0,0x2
ffffffffc02036fe:	2b650513          	addi	a0,a0,694 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc0203702:	a01fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0203706:	00002697          	auipc	a3,0x2
ffffffffc020370a:	56268693          	addi	a3,a3,1378 # ffffffffc0205c68 <default_pmm_manager+0x318>
ffffffffc020370e:	00001617          	auipc	a2,0x1
ffffffffc0203712:	67260613          	addi	a2,a2,1650 # ffffffffc0204d80 <commands+0x720>
ffffffffc0203716:	1a800593          	li	a1,424
ffffffffc020371a:	00002517          	auipc	a0,0x2
ffffffffc020371e:	29650513          	addi	a0,a0,662 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc0203722:	9e1fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203726:	00002697          	auipc	a3,0x2
ffffffffc020372a:	47a68693          	addi	a3,a3,1146 # ffffffffc0205ba0 <default_pmm_manager+0x250>
ffffffffc020372e:	00001617          	auipc	a2,0x1
ffffffffc0203732:	65260613          	addi	a2,a2,1618 # ffffffffc0204d80 <commands+0x720>
ffffffffc0203736:	1a000593          	li	a1,416
ffffffffc020373a:	00002517          	auipc	a0,0x2
ffffffffc020373e:	27650513          	addi	a0,a0,630 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc0203742:	9c1fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203746:	86d6                	mv	a3,s5
ffffffffc0203748:	00002617          	auipc	a2,0x2
ffffffffc020374c:	24060613          	addi	a2,a2,576 # ffffffffc0205988 <default_pmm_manager+0x38>
ffffffffc0203750:	19f00593          	li	a1,415
ffffffffc0203754:	00002517          	auipc	a0,0x2
ffffffffc0203758:	25c50513          	addi	a0,a0,604 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc020375c:	9a7fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203760:	00002697          	auipc	a3,0x2
ffffffffc0203764:	4a068693          	addi	a3,a3,1184 # ffffffffc0205c00 <default_pmm_manager+0x2b0>
ffffffffc0203768:	00001617          	auipc	a2,0x1
ffffffffc020376c:	61860613          	addi	a2,a2,1560 # ffffffffc0204d80 <commands+0x720>
ffffffffc0203770:	1ad00593          	li	a1,429
ffffffffc0203774:	00002517          	auipc	a0,0x2
ffffffffc0203778:	23c50513          	addi	a0,a0,572 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc020377c:	987fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203780:	00002697          	auipc	a3,0x2
ffffffffc0203784:	54868693          	addi	a3,a3,1352 # ffffffffc0205cc8 <default_pmm_manager+0x378>
ffffffffc0203788:	00001617          	auipc	a2,0x1
ffffffffc020378c:	5f860613          	addi	a2,a2,1528 # ffffffffc0204d80 <commands+0x720>
ffffffffc0203790:	1ac00593          	li	a1,428
ffffffffc0203794:	00002517          	auipc	a0,0x2
ffffffffc0203798:	21c50513          	addi	a0,a0,540 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc020379c:	967fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02037a0:	00002697          	auipc	a3,0x2
ffffffffc02037a4:	51068693          	addi	a3,a3,1296 # ffffffffc0205cb0 <default_pmm_manager+0x360>
ffffffffc02037a8:	00001617          	auipc	a2,0x1
ffffffffc02037ac:	5d860613          	addi	a2,a2,1496 # ffffffffc0204d80 <commands+0x720>
ffffffffc02037b0:	1ab00593          	li	a1,427
ffffffffc02037b4:	00002517          	auipc	a0,0x2
ffffffffc02037b8:	1fc50513          	addi	a0,a0,508 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc02037bc:	947fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02037c0:	00002697          	auipc	a3,0x2
ffffffffc02037c4:	4c068693          	addi	a3,a3,1216 # ffffffffc0205c80 <default_pmm_manager+0x330>
ffffffffc02037c8:	00001617          	auipc	a2,0x1
ffffffffc02037cc:	5b860613          	addi	a2,a2,1464 # ffffffffc0204d80 <commands+0x720>
ffffffffc02037d0:	1aa00593          	li	a1,426
ffffffffc02037d4:	00002517          	auipc	a0,0x2
ffffffffc02037d8:	1dc50513          	addi	a0,a0,476 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc02037dc:	927fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02037e0:	00002697          	auipc	a3,0x2
ffffffffc02037e4:	65868693          	addi	a3,a3,1624 # ffffffffc0205e38 <default_pmm_manager+0x4e8>
ffffffffc02037e8:	00001617          	auipc	a2,0x1
ffffffffc02037ec:	59860613          	addi	a2,a2,1432 # ffffffffc0204d80 <commands+0x720>
ffffffffc02037f0:	1d800593          	li	a1,472
ffffffffc02037f4:	00002517          	auipc	a0,0x2
ffffffffc02037f8:	1bc50513          	addi	a0,a0,444 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc02037fc:	907fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0203800:	00002697          	auipc	a3,0x2
ffffffffc0203804:	45068693          	addi	a3,a3,1104 # ffffffffc0205c50 <default_pmm_manager+0x300>
ffffffffc0203808:	00001617          	auipc	a2,0x1
ffffffffc020380c:	57860613          	addi	a2,a2,1400 # ffffffffc0204d80 <commands+0x720>
ffffffffc0203810:	1a700593          	li	a1,423
ffffffffc0203814:	00002517          	auipc	a0,0x2
ffffffffc0203818:	19c50513          	addi	a0,a0,412 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc020381c:	8e7fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0203820:	00002697          	auipc	a3,0x2
ffffffffc0203824:	42068693          	addi	a3,a3,1056 # ffffffffc0205c40 <default_pmm_manager+0x2f0>
ffffffffc0203828:	00001617          	auipc	a2,0x1
ffffffffc020382c:	55860613          	addi	a2,a2,1368 # ffffffffc0204d80 <commands+0x720>
ffffffffc0203830:	1a600593          	li	a1,422
ffffffffc0203834:	00002517          	auipc	a0,0x2
ffffffffc0203838:	17c50513          	addi	a0,a0,380 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc020383c:	8c7fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203840:	00002697          	auipc	a3,0x2
ffffffffc0203844:	4f868693          	addi	a3,a3,1272 # ffffffffc0205d38 <default_pmm_manager+0x3e8>
ffffffffc0203848:	00001617          	auipc	a2,0x1
ffffffffc020384c:	53860613          	addi	a2,a2,1336 # ffffffffc0204d80 <commands+0x720>
ffffffffc0203850:	1e800593          	li	a1,488
ffffffffc0203854:	00002517          	auipc	a0,0x2
ffffffffc0203858:	15c50513          	addi	a0,a0,348 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc020385c:	8a7fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0203860:	00002697          	auipc	a3,0x2
ffffffffc0203864:	3d068693          	addi	a3,a3,976 # ffffffffc0205c30 <default_pmm_manager+0x2e0>
ffffffffc0203868:	00001617          	auipc	a2,0x1
ffffffffc020386c:	51860613          	addi	a2,a2,1304 # ffffffffc0204d80 <commands+0x720>
ffffffffc0203870:	1a500593          	li	a1,421
ffffffffc0203874:	00002517          	auipc	a0,0x2
ffffffffc0203878:	13c50513          	addi	a0,a0,316 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc020387c:	887fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203880:	00002697          	auipc	a3,0x2
ffffffffc0203884:	30868693          	addi	a3,a3,776 # ffffffffc0205b88 <default_pmm_manager+0x238>
ffffffffc0203888:	00001617          	auipc	a2,0x1
ffffffffc020388c:	4f860613          	addi	a2,a2,1272 # ffffffffc0204d80 <commands+0x720>
ffffffffc0203890:	1b200593          	li	a1,434
ffffffffc0203894:	00002517          	auipc	a0,0x2
ffffffffc0203898:	11c50513          	addi	a0,a0,284 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc020389c:	867fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02038a0:	00002697          	auipc	a3,0x2
ffffffffc02038a4:	44068693          	addi	a3,a3,1088 # ffffffffc0205ce0 <default_pmm_manager+0x390>
ffffffffc02038a8:	00001617          	auipc	a2,0x1
ffffffffc02038ac:	4d860613          	addi	a2,a2,1240 # ffffffffc0204d80 <commands+0x720>
ffffffffc02038b0:	1af00593          	li	a1,431
ffffffffc02038b4:	00002517          	auipc	a0,0x2
ffffffffc02038b8:	0fc50513          	addi	a0,a0,252 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc02038bc:	847fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02038c0:	00002697          	auipc	a3,0x2
ffffffffc02038c4:	2b068693          	addi	a3,a3,688 # ffffffffc0205b70 <default_pmm_manager+0x220>
ffffffffc02038c8:	00001617          	auipc	a2,0x1
ffffffffc02038cc:	4b860613          	addi	a2,a2,1208 # ffffffffc0204d80 <commands+0x720>
ffffffffc02038d0:	1ae00593          	li	a1,430
ffffffffc02038d4:	00002517          	auipc	a0,0x2
ffffffffc02038d8:	0dc50513          	addi	a0,a0,220 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc02038dc:	827fc0ef          	jal	ra,ffffffffc0200102 <__panic>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02038e0:	00002617          	auipc	a2,0x2
ffffffffc02038e4:	0a860613          	addi	a2,a2,168 # ffffffffc0205988 <default_pmm_manager+0x38>
ffffffffc02038e8:	06a00593          	li	a1,106
ffffffffc02038ec:	00002517          	auipc	a0,0x2
ffffffffc02038f0:	82c50513          	addi	a0,a0,-2004 # ffffffffc0205118 <commands+0xab8>
ffffffffc02038f4:	80ffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02038f8:	00002697          	auipc	a3,0x2
ffffffffc02038fc:	41868693          	addi	a3,a3,1048 # ffffffffc0205d10 <default_pmm_manager+0x3c0>
ffffffffc0203900:	00001617          	auipc	a2,0x1
ffffffffc0203904:	48060613          	addi	a2,a2,1152 # ffffffffc0204d80 <commands+0x720>
ffffffffc0203908:	1b900593          	li	a1,441
ffffffffc020390c:	00002517          	auipc	a0,0x2
ffffffffc0203910:	0a450513          	addi	a0,a0,164 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc0203914:	feefc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203918:	00002697          	auipc	a3,0x2
ffffffffc020391c:	3b068693          	addi	a3,a3,944 # ffffffffc0205cc8 <default_pmm_manager+0x378>
ffffffffc0203920:	00001617          	auipc	a2,0x1
ffffffffc0203924:	46060613          	addi	a2,a2,1120 # ffffffffc0204d80 <commands+0x720>
ffffffffc0203928:	1b700593          	li	a1,439
ffffffffc020392c:	00002517          	auipc	a0,0x2
ffffffffc0203930:	08450513          	addi	a0,a0,132 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc0203934:	fcefc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0203938:	00002697          	auipc	a3,0x2
ffffffffc020393c:	3c068693          	addi	a3,a3,960 # ffffffffc0205cf8 <default_pmm_manager+0x3a8>
ffffffffc0203940:	00001617          	auipc	a2,0x1
ffffffffc0203944:	44060613          	addi	a2,a2,1088 # ffffffffc0204d80 <commands+0x720>
ffffffffc0203948:	1b600593          	li	a1,438
ffffffffc020394c:	00002517          	auipc	a0,0x2
ffffffffc0203950:	06450513          	addi	a0,a0,100 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc0203954:	faefc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203958:	00002697          	auipc	a3,0x2
ffffffffc020395c:	37068693          	addi	a3,a3,880 # ffffffffc0205cc8 <default_pmm_manager+0x378>
ffffffffc0203960:	00001617          	auipc	a2,0x1
ffffffffc0203964:	42060613          	addi	a2,a2,1056 # ffffffffc0204d80 <commands+0x720>
ffffffffc0203968:	1b300593          	li	a1,435
ffffffffc020396c:	00002517          	auipc	a0,0x2
ffffffffc0203970:	04450513          	addi	a0,a0,68 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc0203974:	f8efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0203978:	00002697          	auipc	a3,0x2
ffffffffc020397c:	4a868693          	addi	a3,a3,1192 # ffffffffc0205e20 <default_pmm_manager+0x4d0>
ffffffffc0203980:	00001617          	auipc	a2,0x1
ffffffffc0203984:	40060613          	addi	a2,a2,1024 # ffffffffc0204d80 <commands+0x720>
ffffffffc0203988:	1d700593          	li	a1,471
ffffffffc020398c:	00002517          	auipc	a0,0x2
ffffffffc0203990:	02450513          	addi	a0,a0,36 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc0203994:	f6efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0203998:	00002697          	auipc	a3,0x2
ffffffffc020399c:	45068693          	addi	a3,a3,1104 # ffffffffc0205de8 <default_pmm_manager+0x498>
ffffffffc02039a0:	00001617          	auipc	a2,0x1
ffffffffc02039a4:	3e060613          	addi	a2,a2,992 # ffffffffc0204d80 <commands+0x720>
ffffffffc02039a8:	1d600593          	li	a1,470
ffffffffc02039ac:	00002517          	auipc	a0,0x2
ffffffffc02039b0:	00450513          	addi	a0,a0,4 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc02039b4:	f4efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc02039b8:	00002697          	auipc	a3,0x2
ffffffffc02039bc:	41868693          	addi	a3,a3,1048 # ffffffffc0205dd0 <default_pmm_manager+0x480>
ffffffffc02039c0:	00001617          	auipc	a2,0x1
ffffffffc02039c4:	3c060613          	addi	a2,a2,960 # ffffffffc0204d80 <commands+0x720>
ffffffffc02039c8:	1d200593          	li	a1,466
ffffffffc02039cc:	00002517          	auipc	a0,0x2
ffffffffc02039d0:	fe450513          	addi	a0,a0,-28 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc02039d4:	f2efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02039d8:	00002697          	auipc	a3,0x2
ffffffffc02039dc:	36068693          	addi	a3,a3,864 # ffffffffc0205d38 <default_pmm_manager+0x3e8>
ffffffffc02039e0:	00001617          	auipc	a2,0x1
ffffffffc02039e4:	3a060613          	addi	a2,a2,928 # ffffffffc0204d80 <commands+0x720>
ffffffffc02039e8:	1c000593          	li	a1,448
ffffffffc02039ec:	00002517          	auipc	a0,0x2
ffffffffc02039f0:	fc450513          	addi	a0,a0,-60 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc02039f4:	f0efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02039f8:	00002697          	auipc	a3,0x2
ffffffffc02039fc:	17868693          	addi	a3,a3,376 # ffffffffc0205b70 <default_pmm_manager+0x220>
ffffffffc0203a00:	00001617          	auipc	a2,0x1
ffffffffc0203a04:	38060613          	addi	a2,a2,896 # ffffffffc0204d80 <commands+0x720>
ffffffffc0203a08:	19b00593          	li	a1,411
ffffffffc0203a0c:	00002517          	auipc	a0,0x2
ffffffffc0203a10:	fa450513          	addi	a0,a0,-92 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc0203a14:	eeefc0ef          	jal	ra,ffffffffc0200102 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203a18:	00002617          	auipc	a2,0x2
ffffffffc0203a1c:	f7060613          	addi	a2,a2,-144 # ffffffffc0205988 <default_pmm_manager+0x38>
ffffffffc0203a20:	19e00593          	li	a1,414
ffffffffc0203a24:	00002517          	auipc	a0,0x2
ffffffffc0203a28:	f8c50513          	addi	a0,a0,-116 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc0203a2c:	ed6fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203a30:	00002697          	auipc	a3,0x2
ffffffffc0203a34:	15868693          	addi	a3,a3,344 # ffffffffc0205b88 <default_pmm_manager+0x238>
ffffffffc0203a38:	00001617          	auipc	a2,0x1
ffffffffc0203a3c:	34860613          	addi	a2,a2,840 # ffffffffc0204d80 <commands+0x720>
ffffffffc0203a40:	19c00593          	li	a1,412
ffffffffc0203a44:	00002517          	auipc	a0,0x2
ffffffffc0203a48:	f6c50513          	addi	a0,a0,-148 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc0203a4c:	eb6fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203a50:	00002697          	auipc	a3,0x2
ffffffffc0203a54:	1b068693          	addi	a3,a3,432 # ffffffffc0205c00 <default_pmm_manager+0x2b0>
ffffffffc0203a58:	00001617          	auipc	a2,0x1
ffffffffc0203a5c:	32860613          	addi	a2,a2,808 # ffffffffc0204d80 <commands+0x720>
ffffffffc0203a60:	1a400593          	li	a1,420
ffffffffc0203a64:	00002517          	auipc	a0,0x2
ffffffffc0203a68:	f4c50513          	addi	a0,a0,-180 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc0203a6c:	e96fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203a70:	00002697          	auipc	a3,0x2
ffffffffc0203a74:	47068693          	addi	a3,a3,1136 # ffffffffc0205ee0 <default_pmm_manager+0x590>
ffffffffc0203a78:	00001617          	auipc	a2,0x1
ffffffffc0203a7c:	30860613          	addi	a2,a2,776 # ffffffffc0204d80 <commands+0x720>
ffffffffc0203a80:	1e000593          	li	a1,480
ffffffffc0203a84:	00002517          	auipc	a0,0x2
ffffffffc0203a88:	f2c50513          	addi	a0,a0,-212 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc0203a8c:	e76fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203a90:	00002697          	auipc	a3,0x2
ffffffffc0203a94:	41868693          	addi	a3,a3,1048 # ffffffffc0205ea8 <default_pmm_manager+0x558>
ffffffffc0203a98:	00001617          	auipc	a2,0x1
ffffffffc0203a9c:	2e860613          	addi	a2,a2,744 # ffffffffc0204d80 <commands+0x720>
ffffffffc0203aa0:	1dd00593          	li	a1,477
ffffffffc0203aa4:	00002517          	auipc	a0,0x2
ffffffffc0203aa8:	f0c50513          	addi	a0,a0,-244 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc0203aac:	e56fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203ab0:	00002697          	auipc	a3,0x2
ffffffffc0203ab4:	3c868693          	addi	a3,a3,968 # ffffffffc0205e78 <default_pmm_manager+0x528>
ffffffffc0203ab8:	00001617          	auipc	a2,0x1
ffffffffc0203abc:	2c860613          	addi	a2,a2,712 # ffffffffc0204d80 <commands+0x720>
ffffffffc0203ac0:	1d900593          	li	a1,473
ffffffffc0203ac4:	00002517          	auipc	a0,0x2
ffffffffc0203ac8:	eec50513          	addi	a0,a0,-276 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc0203acc:	e36fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203ad0 <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0203ad0:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc0203ad4:	8082                	ret

ffffffffc0203ad6 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203ad6:	7179                	addi	sp,sp,-48
ffffffffc0203ad8:	e84a                	sd	s2,16(sp)
ffffffffc0203ada:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0203adc:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203ade:	f022                	sd	s0,32(sp)
ffffffffc0203ae0:	ec26                	sd	s1,24(sp)
ffffffffc0203ae2:	e44e                	sd	s3,8(sp)
ffffffffc0203ae4:	f406                	sd	ra,40(sp)
ffffffffc0203ae6:	84ae                	mv	s1,a1
ffffffffc0203ae8:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0203aea:	eedfe0ef          	jal	ra,ffffffffc02029d6 <alloc_pages>
ffffffffc0203aee:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0203af0:	cd09                	beqz	a0,ffffffffc0203b0a <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0203af2:	85aa                	mv	a1,a0
ffffffffc0203af4:	86ce                	mv	a3,s3
ffffffffc0203af6:	8626                	mv	a2,s1
ffffffffc0203af8:	854a                	mv	a0,s2
ffffffffc0203afa:	ad2ff0ef          	jal	ra,ffffffffc0202dcc <page_insert>
ffffffffc0203afe:	ed21                	bnez	a0,ffffffffc0203b56 <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc0203b00:	0000e797          	auipc	a5,0xe
ffffffffc0203b04:	a387a783          	lw	a5,-1480(a5) # ffffffffc0211538 <swap_init_ok>
ffffffffc0203b08:	eb89                	bnez	a5,ffffffffc0203b1a <pgdir_alloc_page+0x44>
}
ffffffffc0203b0a:	70a2                	ld	ra,40(sp)
ffffffffc0203b0c:	8522                	mv	a0,s0
ffffffffc0203b0e:	7402                	ld	s0,32(sp)
ffffffffc0203b10:	64e2                	ld	s1,24(sp)
ffffffffc0203b12:	6942                	ld	s2,16(sp)
ffffffffc0203b14:	69a2                	ld	s3,8(sp)
ffffffffc0203b16:	6145                	addi	sp,sp,48
ffffffffc0203b18:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0203b1a:	4681                	li	a3,0
ffffffffc0203b1c:	8622                	mv	a2,s0
ffffffffc0203b1e:	85a6                	mv	a1,s1
ffffffffc0203b20:	0000e517          	auipc	a0,0xe
ffffffffc0203b24:	9f853503          	ld	a0,-1544(a0) # ffffffffc0211518 <check_mm_struct>
ffffffffc0203b28:	a04fe0ef          	jal	ra,ffffffffc0201d2c <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0203b2c:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0203b2e:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc0203b30:	4785                	li	a5,1
ffffffffc0203b32:	fcf70ce3          	beq	a4,a5,ffffffffc0203b0a <pgdir_alloc_page+0x34>
ffffffffc0203b36:	00002697          	auipc	a3,0x2
ffffffffc0203b3a:	3f268693          	addi	a3,a3,1010 # ffffffffc0205f28 <default_pmm_manager+0x5d8>
ffffffffc0203b3e:	00001617          	auipc	a2,0x1
ffffffffc0203b42:	24260613          	addi	a2,a2,578 # ffffffffc0204d80 <commands+0x720>
ffffffffc0203b46:	17a00593          	li	a1,378
ffffffffc0203b4a:	00002517          	auipc	a0,0x2
ffffffffc0203b4e:	e6650513          	addi	a0,a0,-410 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc0203b52:	db0fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203b56:	100027f3          	csrr	a5,sstatus
ffffffffc0203b5a:	8b89                	andi	a5,a5,2
ffffffffc0203b5c:	eb99                	bnez	a5,ffffffffc0203b72 <pgdir_alloc_page+0x9c>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203b5e:	0000e797          	auipc	a5,0xe
ffffffffc0203b62:	a027b783          	ld	a5,-1534(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0203b66:	739c                	ld	a5,32(a5)
ffffffffc0203b68:	8522                	mv	a0,s0
ffffffffc0203b6a:	4585                	li	a1,1
ffffffffc0203b6c:	9782                	jalr	a5
            return NULL;
ffffffffc0203b6e:	4401                	li	s0,0
ffffffffc0203b70:	bf69                	j	ffffffffc0203b0a <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc0203b72:	97dfc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203b76:	0000e797          	auipc	a5,0xe
ffffffffc0203b7a:	9ea7b783          	ld	a5,-1558(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0203b7e:	739c                	ld	a5,32(a5)
ffffffffc0203b80:	8522                	mv	a0,s0
ffffffffc0203b82:	4585                	li	a1,1
ffffffffc0203b84:	9782                	jalr	a5
            return NULL;
ffffffffc0203b86:	4401                	li	s0,0
        intr_enable();
ffffffffc0203b88:	961fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203b8c:	bfbd                	j	ffffffffc0203b0a <pgdir_alloc_page+0x34>

ffffffffc0203b8e <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc0203b8e:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203b90:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc0203b92:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203b94:	fff50713          	addi	a4,a0,-1
ffffffffc0203b98:	17f9                	addi	a5,a5,-2
ffffffffc0203b9a:	04e7ea63          	bltu	a5,a4,ffffffffc0203bee <kmalloc+0x60>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0203b9e:	6785                	lui	a5,0x1
ffffffffc0203ba0:	17fd                	addi	a5,a5,-1
ffffffffc0203ba2:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc0203ba4:	8131                	srli	a0,a0,0xc
ffffffffc0203ba6:	e31fe0ef          	jal	ra,ffffffffc02029d6 <alloc_pages>
    assert(base != NULL);
ffffffffc0203baa:	cd3d                	beqz	a0,ffffffffc0203c28 <kmalloc+0x9a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203bac:	0000e797          	auipc	a5,0xe
ffffffffc0203bb0:	9ac7b783          	ld	a5,-1620(a5) # ffffffffc0211558 <pages>
ffffffffc0203bb4:	8d1d                	sub	a0,a0,a5
ffffffffc0203bb6:	00002697          	auipc	a3,0x2
ffffffffc0203bba:	66a6b683          	ld	a3,1642(a3) # ffffffffc0206220 <error_string+0x38>
ffffffffc0203bbe:	850d                	srai	a0,a0,0x3
ffffffffc0203bc0:	02d50533          	mul	a0,a0,a3
ffffffffc0203bc4:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203bc8:	0000e717          	auipc	a4,0xe
ffffffffc0203bcc:	98873703          	ld	a4,-1656(a4) # ffffffffc0211550 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203bd0:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203bd2:	00c51793          	slli	a5,a0,0xc
ffffffffc0203bd6:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203bd8:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203bda:	02e7fa63          	bgeu	a5,a4,ffffffffc0203c0e <kmalloc+0x80>
    ptr = page2kva(base);
    return ptr;
}
ffffffffc0203bde:	60a2                	ld	ra,8(sp)
ffffffffc0203be0:	0000e797          	auipc	a5,0xe
ffffffffc0203be4:	9887b783          	ld	a5,-1656(a5) # ffffffffc0211568 <va_pa_offset>
ffffffffc0203be8:	953e                	add	a0,a0,a5
ffffffffc0203bea:	0141                	addi	sp,sp,16
ffffffffc0203bec:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203bee:	00002697          	auipc	a3,0x2
ffffffffc0203bf2:	35268693          	addi	a3,a3,850 # ffffffffc0205f40 <default_pmm_manager+0x5f0>
ffffffffc0203bf6:	00001617          	auipc	a2,0x1
ffffffffc0203bfa:	18a60613          	addi	a2,a2,394 # ffffffffc0204d80 <commands+0x720>
ffffffffc0203bfe:	1f000593          	li	a1,496
ffffffffc0203c02:	00002517          	auipc	a0,0x2
ffffffffc0203c06:	dae50513          	addi	a0,a0,-594 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc0203c0a:	cf8fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203c0e:	86aa                	mv	a3,a0
ffffffffc0203c10:	00002617          	auipc	a2,0x2
ffffffffc0203c14:	d7860613          	addi	a2,a2,-648 # ffffffffc0205988 <default_pmm_manager+0x38>
ffffffffc0203c18:	06a00593          	li	a1,106
ffffffffc0203c1c:	00001517          	auipc	a0,0x1
ffffffffc0203c20:	4fc50513          	addi	a0,a0,1276 # ffffffffc0205118 <commands+0xab8>
ffffffffc0203c24:	cdefc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(base != NULL);
ffffffffc0203c28:	00002697          	auipc	a3,0x2
ffffffffc0203c2c:	33868693          	addi	a3,a3,824 # ffffffffc0205f60 <default_pmm_manager+0x610>
ffffffffc0203c30:	00001617          	auipc	a2,0x1
ffffffffc0203c34:	15060613          	addi	a2,a2,336 # ffffffffc0204d80 <commands+0x720>
ffffffffc0203c38:	1f300593          	li	a1,499
ffffffffc0203c3c:	00002517          	auipc	a0,0x2
ffffffffc0203c40:	d7450513          	addi	a0,a0,-652 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc0203c44:	cbefc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203c48 <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc0203c48:	1101                	addi	sp,sp,-32
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203c4a:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0203c4c:	ec06                	sd	ra,24(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203c4e:	fff58713          	addi	a4,a1,-1
ffffffffc0203c52:	17f9                	addi	a5,a5,-2
ffffffffc0203c54:	0ae7ee63          	bltu	a5,a4,ffffffffc0203d10 <kfree+0xc8>
    assert(ptr != NULL);
ffffffffc0203c58:	cd41                	beqz	a0,ffffffffc0203cf0 <kfree+0xa8>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0203c5a:	6785                	lui	a5,0x1
ffffffffc0203c5c:	17fd                	addi	a5,a5,-1
ffffffffc0203c5e:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0203c60:	c02007b7          	lui	a5,0xc0200
ffffffffc0203c64:	81b1                	srli	a1,a1,0xc
ffffffffc0203c66:	06f56863          	bltu	a0,a5,ffffffffc0203cd6 <kfree+0x8e>
ffffffffc0203c6a:	0000e697          	auipc	a3,0xe
ffffffffc0203c6e:	8fe6b683          	ld	a3,-1794(a3) # ffffffffc0211568 <va_pa_offset>
ffffffffc0203c72:	8d15                	sub	a0,a0,a3
    if (PPN(pa) >= npage) {
ffffffffc0203c74:	8131                	srli	a0,a0,0xc
ffffffffc0203c76:	0000e797          	auipc	a5,0xe
ffffffffc0203c7a:	8da7b783          	ld	a5,-1830(a5) # ffffffffc0211550 <npage>
ffffffffc0203c7e:	04f57a63          	bgeu	a0,a5,ffffffffc0203cd2 <kfree+0x8a>
    return &pages[PPN(pa) - nbase];
ffffffffc0203c82:	fff806b7          	lui	a3,0xfff80
ffffffffc0203c86:	9536                	add	a0,a0,a3
ffffffffc0203c88:	00351793          	slli	a5,a0,0x3
ffffffffc0203c8c:	953e                	add	a0,a0,a5
ffffffffc0203c8e:	050e                	slli	a0,a0,0x3
ffffffffc0203c90:	0000e797          	auipc	a5,0xe
ffffffffc0203c94:	8c87b783          	ld	a5,-1848(a5) # ffffffffc0211558 <pages>
ffffffffc0203c98:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203c9a:	100027f3          	csrr	a5,sstatus
ffffffffc0203c9e:	8b89                	andi	a5,a5,2
ffffffffc0203ca0:	eb89                	bnez	a5,ffffffffc0203cb2 <kfree+0x6a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203ca2:	0000e797          	auipc	a5,0xe
ffffffffc0203ca6:	8be7b783          	ld	a5,-1858(a5) # ffffffffc0211560 <pmm_manager>
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc0203caa:	60e2                	ld	ra,24(sp)
    { pmm_manager->free_pages(base, n); }
ffffffffc0203cac:	739c                	ld	a5,32(a5)
}
ffffffffc0203cae:	6105                	addi	sp,sp,32
    { pmm_manager->free_pages(base, n); }
ffffffffc0203cb0:	8782                	jr	a5
        intr_disable();
ffffffffc0203cb2:	e42a                	sd	a0,8(sp)
ffffffffc0203cb4:	e02e                	sd	a1,0(sp)
ffffffffc0203cb6:	839fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0203cba:	0000e797          	auipc	a5,0xe
ffffffffc0203cbe:	8a67b783          	ld	a5,-1882(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0203cc2:	6582                	ld	a1,0(sp)
ffffffffc0203cc4:	6522                	ld	a0,8(sp)
ffffffffc0203cc6:	739c                	ld	a5,32(a5)
ffffffffc0203cc8:	9782                	jalr	a5
}
ffffffffc0203cca:	60e2                	ld	ra,24(sp)
ffffffffc0203ccc:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0203cce:	81bfc06f          	j	ffffffffc02004e8 <intr_enable>
ffffffffc0203cd2:	ccdfe0ef          	jal	ra,ffffffffc020299e <pa2page.part.0>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0203cd6:	86aa                	mv	a3,a0
ffffffffc0203cd8:	00002617          	auipc	a2,0x2
ffffffffc0203cdc:	d7060613          	addi	a2,a2,-656 # ffffffffc0205a48 <default_pmm_manager+0xf8>
ffffffffc0203ce0:	06c00593          	li	a1,108
ffffffffc0203ce4:	00001517          	auipc	a0,0x1
ffffffffc0203ce8:	43450513          	addi	a0,a0,1076 # ffffffffc0205118 <commands+0xab8>
ffffffffc0203cec:	c16fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(ptr != NULL);
ffffffffc0203cf0:	00002697          	auipc	a3,0x2
ffffffffc0203cf4:	28068693          	addi	a3,a3,640 # ffffffffc0205f70 <default_pmm_manager+0x620>
ffffffffc0203cf8:	00001617          	auipc	a2,0x1
ffffffffc0203cfc:	08860613          	addi	a2,a2,136 # ffffffffc0204d80 <commands+0x720>
ffffffffc0203d00:	1fa00593          	li	a1,506
ffffffffc0203d04:	00002517          	auipc	a0,0x2
ffffffffc0203d08:	cac50513          	addi	a0,a0,-852 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc0203d0c:	bf6fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203d10:	00002697          	auipc	a3,0x2
ffffffffc0203d14:	23068693          	addi	a3,a3,560 # ffffffffc0205f40 <default_pmm_manager+0x5f0>
ffffffffc0203d18:	00001617          	auipc	a2,0x1
ffffffffc0203d1c:	06860613          	addi	a2,a2,104 # ffffffffc0204d80 <commands+0x720>
ffffffffc0203d20:	1f900593          	li	a1,505
ffffffffc0203d24:	00002517          	auipc	a0,0x2
ffffffffc0203d28:	c8c50513          	addi	a0,a0,-884 # ffffffffc02059b0 <default_pmm_manager+0x60>
ffffffffc0203d2c:	bd6fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203d30 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203d30:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203d32:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203d34:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203d36:	e9cfc0ef          	jal	ra,ffffffffc02003d2 <ide_device_valid>
ffffffffc0203d3a:	cd01                	beqz	a0,ffffffffc0203d52 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203d3c:	4505                	li	a0,1
ffffffffc0203d3e:	e9afc0ef          	jal	ra,ffffffffc02003d8 <ide_device_size>
}
ffffffffc0203d42:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203d44:	810d                	srli	a0,a0,0x3
ffffffffc0203d46:	0000d797          	auipc	a5,0xd
ffffffffc0203d4a:	7ea7b123          	sd	a0,2018(a5) # ffffffffc0211528 <max_swap_offset>
}
ffffffffc0203d4e:	0141                	addi	sp,sp,16
ffffffffc0203d50:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203d52:	00002617          	auipc	a2,0x2
ffffffffc0203d56:	22e60613          	addi	a2,a2,558 # ffffffffc0205f80 <default_pmm_manager+0x630>
ffffffffc0203d5a:	45b5                	li	a1,13
ffffffffc0203d5c:	00002517          	auipc	a0,0x2
ffffffffc0203d60:	24450513          	addi	a0,a0,580 # ffffffffc0205fa0 <default_pmm_manager+0x650>
ffffffffc0203d64:	b9efc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203d68 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203d68:	1141                	addi	sp,sp,-16
ffffffffc0203d6a:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d6c:	00855793          	srli	a5,a0,0x8
ffffffffc0203d70:	c3a5                	beqz	a5,ffffffffc0203dd0 <swapfs_read+0x68>
ffffffffc0203d72:	0000d717          	auipc	a4,0xd
ffffffffc0203d76:	7b673703          	ld	a4,1974(a4) # ffffffffc0211528 <max_swap_offset>
ffffffffc0203d7a:	04e7fb63          	bgeu	a5,a4,ffffffffc0203dd0 <swapfs_read+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d7e:	0000d617          	auipc	a2,0xd
ffffffffc0203d82:	7da63603          	ld	a2,2010(a2) # ffffffffc0211558 <pages>
ffffffffc0203d86:	8d91                	sub	a1,a1,a2
ffffffffc0203d88:	4035d613          	srai	a2,a1,0x3
ffffffffc0203d8c:	00002597          	auipc	a1,0x2
ffffffffc0203d90:	4945b583          	ld	a1,1172(a1) # ffffffffc0206220 <error_string+0x38>
ffffffffc0203d94:	02b60633          	mul	a2,a2,a1
ffffffffc0203d98:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203d9c:	00002797          	auipc	a5,0x2
ffffffffc0203da0:	48c7b783          	ld	a5,1164(a5) # ffffffffc0206228 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203da4:	0000d717          	auipc	a4,0xd
ffffffffc0203da8:	7ac73703          	ld	a4,1964(a4) # ffffffffc0211550 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203dac:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203dae:	00c61793          	slli	a5,a2,0xc
ffffffffc0203db2:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203db4:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203db6:	02e7f963          	bgeu	a5,a4,ffffffffc0203de8 <swapfs_read+0x80>
}
ffffffffc0203dba:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203dbc:	0000d797          	auipc	a5,0xd
ffffffffc0203dc0:	7ac7b783          	ld	a5,1964(a5) # ffffffffc0211568 <va_pa_offset>
ffffffffc0203dc4:	46a1                	li	a3,8
ffffffffc0203dc6:	963e                	add	a2,a2,a5
ffffffffc0203dc8:	4505                	li	a0,1
}
ffffffffc0203dca:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203dcc:	e12fc06f          	j	ffffffffc02003de <ide_read_secs>
ffffffffc0203dd0:	86aa                	mv	a3,a0
ffffffffc0203dd2:	00002617          	auipc	a2,0x2
ffffffffc0203dd6:	1e660613          	addi	a2,a2,486 # ffffffffc0205fb8 <default_pmm_manager+0x668>
ffffffffc0203dda:	45d1                	li	a1,20
ffffffffc0203ddc:	00002517          	auipc	a0,0x2
ffffffffc0203de0:	1c450513          	addi	a0,a0,452 # ffffffffc0205fa0 <default_pmm_manager+0x650>
ffffffffc0203de4:	b1efc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203de8:	86b2                	mv	a3,a2
ffffffffc0203dea:	06a00593          	li	a1,106
ffffffffc0203dee:	00002617          	auipc	a2,0x2
ffffffffc0203df2:	b9a60613          	addi	a2,a2,-1126 # ffffffffc0205988 <default_pmm_manager+0x38>
ffffffffc0203df6:	00001517          	auipc	a0,0x1
ffffffffc0203dfa:	32250513          	addi	a0,a0,802 # ffffffffc0205118 <commands+0xab8>
ffffffffc0203dfe:	b04fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203e02 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203e02:	1141                	addi	sp,sp,-16
ffffffffc0203e04:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e06:	00855793          	srli	a5,a0,0x8
ffffffffc0203e0a:	c3a5                	beqz	a5,ffffffffc0203e6a <swapfs_write+0x68>
ffffffffc0203e0c:	0000d717          	auipc	a4,0xd
ffffffffc0203e10:	71c73703          	ld	a4,1820(a4) # ffffffffc0211528 <max_swap_offset>
ffffffffc0203e14:	04e7fb63          	bgeu	a5,a4,ffffffffc0203e6a <swapfs_write+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203e18:	0000d617          	auipc	a2,0xd
ffffffffc0203e1c:	74063603          	ld	a2,1856(a2) # ffffffffc0211558 <pages>
ffffffffc0203e20:	8d91                	sub	a1,a1,a2
ffffffffc0203e22:	4035d613          	srai	a2,a1,0x3
ffffffffc0203e26:	00002597          	auipc	a1,0x2
ffffffffc0203e2a:	3fa5b583          	ld	a1,1018(a1) # ffffffffc0206220 <error_string+0x38>
ffffffffc0203e2e:	02b60633          	mul	a2,a2,a1
ffffffffc0203e32:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203e36:	00002797          	auipc	a5,0x2
ffffffffc0203e3a:	3f27b783          	ld	a5,1010(a5) # ffffffffc0206228 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e3e:	0000d717          	auipc	a4,0xd
ffffffffc0203e42:	71273703          	ld	a4,1810(a4) # ffffffffc0211550 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203e46:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e48:	00c61793          	slli	a5,a2,0xc
ffffffffc0203e4c:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203e4e:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e50:	02e7f963          	bgeu	a5,a4,ffffffffc0203e82 <swapfs_write+0x80>
}
ffffffffc0203e54:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e56:	0000d797          	auipc	a5,0xd
ffffffffc0203e5a:	7127b783          	ld	a5,1810(a5) # ffffffffc0211568 <va_pa_offset>
ffffffffc0203e5e:	46a1                	li	a3,8
ffffffffc0203e60:	963e                	add	a2,a2,a5
ffffffffc0203e62:	4505                	li	a0,1
}
ffffffffc0203e64:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e66:	d9cfc06f          	j	ffffffffc0200402 <ide_write_secs>
ffffffffc0203e6a:	86aa                	mv	a3,a0
ffffffffc0203e6c:	00002617          	auipc	a2,0x2
ffffffffc0203e70:	14c60613          	addi	a2,a2,332 # ffffffffc0205fb8 <default_pmm_manager+0x668>
ffffffffc0203e74:	45e5                	li	a1,25
ffffffffc0203e76:	00002517          	auipc	a0,0x2
ffffffffc0203e7a:	12a50513          	addi	a0,a0,298 # ffffffffc0205fa0 <default_pmm_manager+0x650>
ffffffffc0203e7e:	a84fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203e82:	86b2                	mv	a3,a2
ffffffffc0203e84:	06a00593          	li	a1,106
ffffffffc0203e88:	00002617          	auipc	a2,0x2
ffffffffc0203e8c:	b0060613          	addi	a2,a2,-1280 # ffffffffc0205988 <default_pmm_manager+0x38>
ffffffffc0203e90:	00001517          	auipc	a0,0x1
ffffffffc0203e94:	28850513          	addi	a0,a0,648 # ffffffffc0205118 <commands+0xab8>
ffffffffc0203e98:	a6afc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203e9c <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0203e9c:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0203ea0:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0203ea2:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0203ea4:	cb81                	beqz	a5,ffffffffc0203eb4 <strlen+0x18>
        cnt ++;
ffffffffc0203ea6:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0203ea8:	00a707b3          	add	a5,a4,a0
ffffffffc0203eac:	0007c783          	lbu	a5,0(a5)
ffffffffc0203eb0:	fbfd                	bnez	a5,ffffffffc0203ea6 <strlen+0xa>
ffffffffc0203eb2:	8082                	ret
    }
    return cnt;
}
ffffffffc0203eb4:	8082                	ret

ffffffffc0203eb6 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0203eb6:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203eb8:	e589                	bnez	a1,ffffffffc0203ec2 <strnlen+0xc>
ffffffffc0203eba:	a811                	j	ffffffffc0203ece <strnlen+0x18>
        cnt ++;
ffffffffc0203ebc:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203ebe:	00f58863          	beq	a1,a5,ffffffffc0203ece <strnlen+0x18>
ffffffffc0203ec2:	00f50733          	add	a4,a0,a5
ffffffffc0203ec6:	00074703          	lbu	a4,0(a4)
ffffffffc0203eca:	fb6d                	bnez	a4,ffffffffc0203ebc <strnlen+0x6>
ffffffffc0203ecc:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0203ece:	852e                	mv	a0,a1
ffffffffc0203ed0:	8082                	ret

ffffffffc0203ed2 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0203ed2:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0203ed4:	0005c703          	lbu	a4,0(a1)
ffffffffc0203ed8:	0785                	addi	a5,a5,1
ffffffffc0203eda:	0585                	addi	a1,a1,1
ffffffffc0203edc:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0203ee0:	fb75                	bnez	a4,ffffffffc0203ed4 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0203ee2:	8082                	ret

ffffffffc0203ee4 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203ee4:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203ee8:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203eec:	cb89                	beqz	a5,ffffffffc0203efe <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0203eee:	0505                	addi	a0,a0,1
ffffffffc0203ef0:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203ef2:	fee789e3          	beq	a5,a4,ffffffffc0203ee4 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203ef6:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0203efa:	9d19                	subw	a0,a0,a4
ffffffffc0203efc:	8082                	ret
ffffffffc0203efe:	4501                	li	a0,0
ffffffffc0203f00:	bfed                	j	ffffffffc0203efa <strcmp+0x16>

ffffffffc0203f02 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0203f02:	00054783          	lbu	a5,0(a0)
ffffffffc0203f06:	c799                	beqz	a5,ffffffffc0203f14 <strchr+0x12>
        if (*s == c) {
ffffffffc0203f08:	00f58763          	beq	a1,a5,ffffffffc0203f16 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0203f0c:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0203f10:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0203f12:	fbfd                	bnez	a5,ffffffffc0203f08 <strchr+0x6>
    }
    return NULL;
ffffffffc0203f14:	4501                	li	a0,0
}
ffffffffc0203f16:	8082                	ret

ffffffffc0203f18 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0203f18:	ca01                	beqz	a2,ffffffffc0203f28 <memset+0x10>
ffffffffc0203f1a:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0203f1c:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0203f1e:	0785                	addi	a5,a5,1
ffffffffc0203f20:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0203f24:	fec79de3          	bne	a5,a2,ffffffffc0203f1e <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0203f28:	8082                	ret

ffffffffc0203f2a <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0203f2a:	ca19                	beqz	a2,ffffffffc0203f40 <memcpy+0x16>
ffffffffc0203f2c:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0203f2e:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0203f30:	0005c703          	lbu	a4,0(a1)
ffffffffc0203f34:	0585                	addi	a1,a1,1
ffffffffc0203f36:	0785                	addi	a5,a5,1
ffffffffc0203f38:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0203f3c:	fec59ae3          	bne	a1,a2,ffffffffc0203f30 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0203f40:	8082                	ret

ffffffffc0203f42 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203f42:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203f46:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203f48:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203f4c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203f4e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203f52:	f022                	sd	s0,32(sp)
ffffffffc0203f54:	ec26                	sd	s1,24(sp)
ffffffffc0203f56:	e84a                	sd	s2,16(sp)
ffffffffc0203f58:	f406                	sd	ra,40(sp)
ffffffffc0203f5a:	e44e                	sd	s3,8(sp)
ffffffffc0203f5c:	84aa                	mv	s1,a0
ffffffffc0203f5e:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203f60:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203f64:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0203f66:	03067e63          	bgeu	a2,a6,ffffffffc0203fa2 <printnum+0x60>
ffffffffc0203f6a:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0203f6c:	00805763          	blez	s0,ffffffffc0203f7a <printnum+0x38>
ffffffffc0203f70:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203f72:	85ca                	mv	a1,s2
ffffffffc0203f74:	854e                	mv	a0,s3
ffffffffc0203f76:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203f78:	fc65                	bnez	s0,ffffffffc0203f70 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203f7a:	1a02                	slli	s4,s4,0x20
ffffffffc0203f7c:	00002797          	auipc	a5,0x2
ffffffffc0203f80:	05c78793          	addi	a5,a5,92 # ffffffffc0205fd8 <default_pmm_manager+0x688>
ffffffffc0203f84:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203f88:	9a3e                	add	s4,s4,a5
}
ffffffffc0203f8a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203f8c:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203f90:	70a2                	ld	ra,40(sp)
ffffffffc0203f92:	69a2                	ld	s3,8(sp)
ffffffffc0203f94:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203f96:	85ca                	mv	a1,s2
ffffffffc0203f98:	87a6                	mv	a5,s1
}
ffffffffc0203f9a:	6942                	ld	s2,16(sp)
ffffffffc0203f9c:	64e2                	ld	s1,24(sp)
ffffffffc0203f9e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203fa0:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203fa2:	03065633          	divu	a2,a2,a6
ffffffffc0203fa6:	8722                	mv	a4,s0
ffffffffc0203fa8:	f9bff0ef          	jal	ra,ffffffffc0203f42 <printnum>
ffffffffc0203fac:	b7f9                	j	ffffffffc0203f7a <printnum+0x38>

ffffffffc0203fae <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203fae:	7119                	addi	sp,sp,-128
ffffffffc0203fb0:	f4a6                	sd	s1,104(sp)
ffffffffc0203fb2:	f0ca                	sd	s2,96(sp)
ffffffffc0203fb4:	ecce                	sd	s3,88(sp)
ffffffffc0203fb6:	e8d2                	sd	s4,80(sp)
ffffffffc0203fb8:	e4d6                	sd	s5,72(sp)
ffffffffc0203fba:	e0da                	sd	s6,64(sp)
ffffffffc0203fbc:	fc5e                	sd	s7,56(sp)
ffffffffc0203fbe:	f06a                	sd	s10,32(sp)
ffffffffc0203fc0:	fc86                	sd	ra,120(sp)
ffffffffc0203fc2:	f8a2                	sd	s0,112(sp)
ffffffffc0203fc4:	f862                	sd	s8,48(sp)
ffffffffc0203fc6:	f466                	sd	s9,40(sp)
ffffffffc0203fc8:	ec6e                	sd	s11,24(sp)
ffffffffc0203fca:	892a                	mv	s2,a0
ffffffffc0203fcc:	84ae                	mv	s1,a1
ffffffffc0203fce:	8d32                	mv	s10,a2
ffffffffc0203fd0:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203fd2:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203fd6:	5b7d                	li	s6,-1
ffffffffc0203fd8:	00002a97          	auipc	s5,0x2
ffffffffc0203fdc:	034a8a93          	addi	s5,s5,52 # ffffffffc020600c <default_pmm_manager+0x6bc>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203fe0:	00002b97          	auipc	s7,0x2
ffffffffc0203fe4:	208b8b93          	addi	s7,s7,520 # ffffffffc02061e8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203fe8:	000d4503          	lbu	a0,0(s10) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc0203fec:	001d0413          	addi	s0,s10,1
ffffffffc0203ff0:	01350a63          	beq	a0,s3,ffffffffc0204004 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0203ff4:	c121                	beqz	a0,ffffffffc0204034 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0203ff6:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203ff8:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0203ffa:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203ffc:	fff44503          	lbu	a0,-1(s0)
ffffffffc0204000:	ff351ae3          	bne	a0,s3,ffffffffc0203ff4 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204004:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0204008:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020400c:	4c81                	li	s9,0
ffffffffc020400e:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0204010:	5c7d                	li	s8,-1
ffffffffc0204012:	5dfd                	li	s11,-1
ffffffffc0204014:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0204018:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020401a:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020401e:	0ff5f593          	zext.b	a1,a1
ffffffffc0204022:	00140d13          	addi	s10,s0,1
ffffffffc0204026:	04b56263          	bltu	a0,a1,ffffffffc020406a <vprintfmt+0xbc>
ffffffffc020402a:	058a                	slli	a1,a1,0x2
ffffffffc020402c:	95d6                	add	a1,a1,s5
ffffffffc020402e:	4194                	lw	a3,0(a1)
ffffffffc0204030:	96d6                	add	a3,a3,s5
ffffffffc0204032:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0204034:	70e6                	ld	ra,120(sp)
ffffffffc0204036:	7446                	ld	s0,112(sp)
ffffffffc0204038:	74a6                	ld	s1,104(sp)
ffffffffc020403a:	7906                	ld	s2,96(sp)
ffffffffc020403c:	69e6                	ld	s3,88(sp)
ffffffffc020403e:	6a46                	ld	s4,80(sp)
ffffffffc0204040:	6aa6                	ld	s5,72(sp)
ffffffffc0204042:	6b06                	ld	s6,64(sp)
ffffffffc0204044:	7be2                	ld	s7,56(sp)
ffffffffc0204046:	7c42                	ld	s8,48(sp)
ffffffffc0204048:	7ca2                	ld	s9,40(sp)
ffffffffc020404a:	7d02                	ld	s10,32(sp)
ffffffffc020404c:	6de2                	ld	s11,24(sp)
ffffffffc020404e:	6109                	addi	sp,sp,128
ffffffffc0204050:	8082                	ret
            padc = '0';
ffffffffc0204052:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0204054:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204058:	846a                	mv	s0,s10
ffffffffc020405a:	00140d13          	addi	s10,s0,1
ffffffffc020405e:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0204062:	0ff5f593          	zext.b	a1,a1
ffffffffc0204066:	fcb572e3          	bgeu	a0,a1,ffffffffc020402a <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc020406a:	85a6                	mv	a1,s1
ffffffffc020406c:	02500513          	li	a0,37
ffffffffc0204070:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204072:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204076:	8d22                	mv	s10,s0
ffffffffc0204078:	f73788e3          	beq	a5,s3,ffffffffc0203fe8 <vprintfmt+0x3a>
ffffffffc020407c:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0204080:	1d7d                	addi	s10,s10,-1
ffffffffc0204082:	ff379de3          	bne	a5,s3,ffffffffc020407c <vprintfmt+0xce>
ffffffffc0204086:	b78d                	j	ffffffffc0203fe8 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0204088:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc020408c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204090:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204092:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204096:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020409a:	02d86463          	bltu	a6,a3,ffffffffc02040c2 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020409e:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02040a2:	002c169b          	slliw	a3,s8,0x2
ffffffffc02040a6:	0186873b          	addw	a4,a3,s8
ffffffffc02040aa:	0017171b          	slliw	a4,a4,0x1
ffffffffc02040ae:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02040b0:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02040b4:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02040b6:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02040ba:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02040be:	fed870e3          	bgeu	a6,a3,ffffffffc020409e <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02040c2:	f40ddce3          	bgez	s11,ffffffffc020401a <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02040c6:	8de2                	mv	s11,s8
ffffffffc02040c8:	5c7d                	li	s8,-1
ffffffffc02040ca:	bf81                	j	ffffffffc020401a <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02040cc:	fffdc693          	not	a3,s11
ffffffffc02040d0:	96fd                	srai	a3,a3,0x3f
ffffffffc02040d2:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040d6:	00144603          	lbu	a2,1(s0)
ffffffffc02040da:	2d81                	sext.w	s11,s11
ffffffffc02040dc:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02040de:	bf35                	j	ffffffffc020401a <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02040e0:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040e4:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02040e8:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040ea:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02040ec:	bfd9                	j	ffffffffc02040c2 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02040ee:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02040f0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02040f4:	01174463          	blt	a4,a7,ffffffffc02040fc <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02040f8:	1a088e63          	beqz	a7,ffffffffc02042b4 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02040fc:	000a3603          	ld	a2,0(s4)
ffffffffc0204100:	46c1                	li	a3,16
ffffffffc0204102:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204104:	2781                	sext.w	a5,a5
ffffffffc0204106:	876e                	mv	a4,s11
ffffffffc0204108:	85a6                	mv	a1,s1
ffffffffc020410a:	854a                	mv	a0,s2
ffffffffc020410c:	e37ff0ef          	jal	ra,ffffffffc0203f42 <printnum>
            break;
ffffffffc0204110:	bde1                	j	ffffffffc0203fe8 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0204112:	000a2503          	lw	a0,0(s4)
ffffffffc0204116:	85a6                	mv	a1,s1
ffffffffc0204118:	0a21                	addi	s4,s4,8
ffffffffc020411a:	9902                	jalr	s2
            break;
ffffffffc020411c:	b5f1                	j	ffffffffc0203fe8 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020411e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204120:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204124:	01174463          	blt	a4,a7,ffffffffc020412c <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0204128:	18088163          	beqz	a7,ffffffffc02042aa <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc020412c:	000a3603          	ld	a2,0(s4)
ffffffffc0204130:	46a9                	li	a3,10
ffffffffc0204132:	8a2e                	mv	s4,a1
ffffffffc0204134:	bfc1                	j	ffffffffc0204104 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204136:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020413a:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020413c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020413e:	bdf1                	j	ffffffffc020401a <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0204140:	85a6                	mv	a1,s1
ffffffffc0204142:	02500513          	li	a0,37
ffffffffc0204146:	9902                	jalr	s2
            break;
ffffffffc0204148:	b545                	j	ffffffffc0203fe8 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020414a:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc020414e:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204150:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204152:	b5e1                	j	ffffffffc020401a <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0204154:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204156:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020415a:	01174463          	blt	a4,a7,ffffffffc0204162 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc020415e:	14088163          	beqz	a7,ffffffffc02042a0 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0204162:	000a3603          	ld	a2,0(s4)
ffffffffc0204166:	46a1                	li	a3,8
ffffffffc0204168:	8a2e                	mv	s4,a1
ffffffffc020416a:	bf69                	j	ffffffffc0204104 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc020416c:	03000513          	li	a0,48
ffffffffc0204170:	85a6                	mv	a1,s1
ffffffffc0204172:	e03e                	sd	a5,0(sp)
ffffffffc0204174:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204176:	85a6                	mv	a1,s1
ffffffffc0204178:	07800513          	li	a0,120
ffffffffc020417c:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020417e:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0204180:	6782                	ld	a5,0(sp)
ffffffffc0204182:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204184:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0204188:	bfb5                	j	ffffffffc0204104 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020418a:	000a3403          	ld	s0,0(s4)
ffffffffc020418e:	008a0713          	addi	a4,s4,8
ffffffffc0204192:	e03a                	sd	a4,0(sp)
ffffffffc0204194:	14040263          	beqz	s0,ffffffffc02042d8 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0204198:	0fb05763          	blez	s11,ffffffffc0204286 <vprintfmt+0x2d8>
ffffffffc020419c:	02d00693          	li	a3,45
ffffffffc02041a0:	0cd79163          	bne	a5,a3,ffffffffc0204262 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02041a4:	00044783          	lbu	a5,0(s0)
ffffffffc02041a8:	0007851b          	sext.w	a0,a5
ffffffffc02041ac:	cf85                	beqz	a5,ffffffffc02041e4 <vprintfmt+0x236>
ffffffffc02041ae:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02041b2:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02041b6:	000c4563          	bltz	s8,ffffffffc02041c0 <vprintfmt+0x212>
ffffffffc02041ba:	3c7d                	addiw	s8,s8,-1
ffffffffc02041bc:	036c0263          	beq	s8,s6,ffffffffc02041e0 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02041c0:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02041c2:	0e0c8e63          	beqz	s9,ffffffffc02042be <vprintfmt+0x310>
ffffffffc02041c6:	3781                	addiw	a5,a5,-32
ffffffffc02041c8:	0ef47b63          	bgeu	s0,a5,ffffffffc02042be <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02041cc:	03f00513          	li	a0,63
ffffffffc02041d0:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02041d2:	000a4783          	lbu	a5,0(s4)
ffffffffc02041d6:	3dfd                	addiw	s11,s11,-1
ffffffffc02041d8:	0a05                	addi	s4,s4,1
ffffffffc02041da:	0007851b          	sext.w	a0,a5
ffffffffc02041de:	ffe1                	bnez	a5,ffffffffc02041b6 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02041e0:	01b05963          	blez	s11,ffffffffc02041f2 <vprintfmt+0x244>
ffffffffc02041e4:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02041e6:	85a6                	mv	a1,s1
ffffffffc02041e8:	02000513          	li	a0,32
ffffffffc02041ec:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02041ee:	fe0d9be3          	bnez	s11,ffffffffc02041e4 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02041f2:	6a02                	ld	s4,0(sp)
ffffffffc02041f4:	bbd5                	j	ffffffffc0203fe8 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02041f6:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02041f8:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02041fc:	01174463          	blt	a4,a7,ffffffffc0204204 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0204200:	08088d63          	beqz	a7,ffffffffc020429a <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0204204:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0204208:	0a044d63          	bltz	s0,ffffffffc02042c2 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc020420c:	8622                	mv	a2,s0
ffffffffc020420e:	8a66                	mv	s4,s9
ffffffffc0204210:	46a9                	li	a3,10
ffffffffc0204212:	bdcd                	j	ffffffffc0204104 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0204214:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204218:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020421a:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020421c:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0204220:	8fb5                	xor	a5,a5,a3
ffffffffc0204222:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204226:	02d74163          	blt	a4,a3,ffffffffc0204248 <vprintfmt+0x29a>
ffffffffc020422a:	00369793          	slli	a5,a3,0x3
ffffffffc020422e:	97de                	add	a5,a5,s7
ffffffffc0204230:	639c                	ld	a5,0(a5)
ffffffffc0204232:	cb99                	beqz	a5,ffffffffc0204248 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204234:	86be                	mv	a3,a5
ffffffffc0204236:	00002617          	auipc	a2,0x2
ffffffffc020423a:	dd260613          	addi	a2,a2,-558 # ffffffffc0206008 <default_pmm_manager+0x6b8>
ffffffffc020423e:	85a6                	mv	a1,s1
ffffffffc0204240:	854a                	mv	a0,s2
ffffffffc0204242:	0ce000ef          	jal	ra,ffffffffc0204310 <printfmt>
ffffffffc0204246:	b34d                	j	ffffffffc0203fe8 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204248:	00002617          	auipc	a2,0x2
ffffffffc020424c:	db060613          	addi	a2,a2,-592 # ffffffffc0205ff8 <default_pmm_manager+0x6a8>
ffffffffc0204250:	85a6                	mv	a1,s1
ffffffffc0204252:	854a                	mv	a0,s2
ffffffffc0204254:	0bc000ef          	jal	ra,ffffffffc0204310 <printfmt>
ffffffffc0204258:	bb41                	j	ffffffffc0203fe8 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020425a:	00002417          	auipc	s0,0x2
ffffffffc020425e:	d9640413          	addi	s0,s0,-618 # ffffffffc0205ff0 <default_pmm_manager+0x6a0>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204262:	85e2                	mv	a1,s8
ffffffffc0204264:	8522                	mv	a0,s0
ffffffffc0204266:	e43e                	sd	a5,8(sp)
ffffffffc0204268:	c4fff0ef          	jal	ra,ffffffffc0203eb6 <strnlen>
ffffffffc020426c:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204270:	01b05b63          	blez	s11,ffffffffc0204286 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0204274:	67a2                	ld	a5,8(sp)
ffffffffc0204276:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020427a:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020427c:	85a6                	mv	a1,s1
ffffffffc020427e:	8552                	mv	a0,s4
ffffffffc0204280:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204282:	fe0d9ce3          	bnez	s11,ffffffffc020427a <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204286:	00044783          	lbu	a5,0(s0)
ffffffffc020428a:	00140a13          	addi	s4,s0,1
ffffffffc020428e:	0007851b          	sext.w	a0,a5
ffffffffc0204292:	d3a5                	beqz	a5,ffffffffc02041f2 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204294:	05e00413          	li	s0,94
ffffffffc0204298:	bf39                	j	ffffffffc02041b6 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc020429a:	000a2403          	lw	s0,0(s4)
ffffffffc020429e:	b7ad                	j	ffffffffc0204208 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02042a0:	000a6603          	lwu	a2,0(s4)
ffffffffc02042a4:	46a1                	li	a3,8
ffffffffc02042a6:	8a2e                	mv	s4,a1
ffffffffc02042a8:	bdb1                	j	ffffffffc0204104 <vprintfmt+0x156>
ffffffffc02042aa:	000a6603          	lwu	a2,0(s4)
ffffffffc02042ae:	46a9                	li	a3,10
ffffffffc02042b0:	8a2e                	mv	s4,a1
ffffffffc02042b2:	bd89                	j	ffffffffc0204104 <vprintfmt+0x156>
ffffffffc02042b4:	000a6603          	lwu	a2,0(s4)
ffffffffc02042b8:	46c1                	li	a3,16
ffffffffc02042ba:	8a2e                	mv	s4,a1
ffffffffc02042bc:	b5a1                	j	ffffffffc0204104 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02042be:	9902                	jalr	s2
ffffffffc02042c0:	bf09                	j	ffffffffc02041d2 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02042c2:	85a6                	mv	a1,s1
ffffffffc02042c4:	02d00513          	li	a0,45
ffffffffc02042c8:	e03e                	sd	a5,0(sp)
ffffffffc02042ca:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02042cc:	6782                	ld	a5,0(sp)
ffffffffc02042ce:	8a66                	mv	s4,s9
ffffffffc02042d0:	40800633          	neg	a2,s0
ffffffffc02042d4:	46a9                	li	a3,10
ffffffffc02042d6:	b53d                	j	ffffffffc0204104 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02042d8:	03b05163          	blez	s11,ffffffffc02042fa <vprintfmt+0x34c>
ffffffffc02042dc:	02d00693          	li	a3,45
ffffffffc02042e0:	f6d79de3          	bne	a5,a3,ffffffffc020425a <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02042e4:	00002417          	auipc	s0,0x2
ffffffffc02042e8:	d0c40413          	addi	s0,s0,-756 # ffffffffc0205ff0 <default_pmm_manager+0x6a0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02042ec:	02800793          	li	a5,40
ffffffffc02042f0:	02800513          	li	a0,40
ffffffffc02042f4:	00140a13          	addi	s4,s0,1
ffffffffc02042f8:	bd6d                	j	ffffffffc02041b2 <vprintfmt+0x204>
ffffffffc02042fa:	00002a17          	auipc	s4,0x2
ffffffffc02042fe:	cf7a0a13          	addi	s4,s4,-777 # ffffffffc0205ff1 <default_pmm_manager+0x6a1>
ffffffffc0204302:	02800513          	li	a0,40
ffffffffc0204306:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020430a:	05e00413          	li	s0,94
ffffffffc020430e:	b565                	j	ffffffffc02041b6 <vprintfmt+0x208>

ffffffffc0204310 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204310:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204312:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204316:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204318:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020431a:	ec06                	sd	ra,24(sp)
ffffffffc020431c:	f83a                	sd	a4,48(sp)
ffffffffc020431e:	fc3e                	sd	a5,56(sp)
ffffffffc0204320:	e0c2                	sd	a6,64(sp)
ffffffffc0204322:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204324:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204326:	c89ff0ef          	jal	ra,ffffffffc0203fae <vprintfmt>
}
ffffffffc020432a:	60e2                	ld	ra,24(sp)
ffffffffc020432c:	6161                	addi	sp,sp,80
ffffffffc020432e:	8082                	ret

ffffffffc0204330 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0204330:	715d                	addi	sp,sp,-80
ffffffffc0204332:	e486                	sd	ra,72(sp)
ffffffffc0204334:	e0a6                	sd	s1,64(sp)
ffffffffc0204336:	fc4a                	sd	s2,56(sp)
ffffffffc0204338:	f84e                	sd	s3,48(sp)
ffffffffc020433a:	f452                	sd	s4,40(sp)
ffffffffc020433c:	f056                	sd	s5,32(sp)
ffffffffc020433e:	ec5a                	sd	s6,24(sp)
ffffffffc0204340:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0204342:	c901                	beqz	a0,ffffffffc0204352 <readline+0x22>
ffffffffc0204344:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0204346:	00002517          	auipc	a0,0x2
ffffffffc020434a:	cc250513          	addi	a0,a0,-830 # ffffffffc0206008 <default_pmm_manager+0x6b8>
ffffffffc020434e:	d6dfb0ef          	jal	ra,ffffffffc02000ba <cprintf>
readline(const char *prompt) {
ffffffffc0204352:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204354:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0204356:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0204358:	4aa9                	li	s5,10
ffffffffc020435a:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc020435c:	0000db97          	auipc	s7,0xd
ffffffffc0204360:	d9cb8b93          	addi	s7,s7,-612 # ffffffffc02110f8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204364:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0204368:	d8bfb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc020436c:	00054a63          	bltz	a0,ffffffffc0204380 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204370:	00a95a63          	bge	s2,a0,ffffffffc0204384 <readline+0x54>
ffffffffc0204374:	029a5263          	bge	s4,s1,ffffffffc0204398 <readline+0x68>
        c = getchar();
ffffffffc0204378:	d7bfb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc020437c:	fe055ae3          	bgez	a0,ffffffffc0204370 <readline+0x40>
            return NULL;
ffffffffc0204380:	4501                	li	a0,0
ffffffffc0204382:	a091                	j	ffffffffc02043c6 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0204384:	03351463          	bne	a0,s3,ffffffffc02043ac <readline+0x7c>
ffffffffc0204388:	e8a9                	bnez	s1,ffffffffc02043da <readline+0xaa>
        c = getchar();
ffffffffc020438a:	d69fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc020438e:	fe0549e3          	bltz	a0,ffffffffc0204380 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204392:	fea959e3          	bge	s2,a0,ffffffffc0204384 <readline+0x54>
ffffffffc0204396:	4481                	li	s1,0
            cputchar(c);
ffffffffc0204398:	e42a                	sd	a0,8(sp)
ffffffffc020439a:	d57fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i ++] = c;
ffffffffc020439e:	6522                	ld	a0,8(sp)
ffffffffc02043a0:	009b87b3          	add	a5,s7,s1
ffffffffc02043a4:	2485                	addiw	s1,s1,1
ffffffffc02043a6:	00a78023          	sb	a0,0(a5)
ffffffffc02043aa:	bf7d                	j	ffffffffc0204368 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02043ac:	01550463          	beq	a0,s5,ffffffffc02043b4 <readline+0x84>
ffffffffc02043b0:	fb651ce3          	bne	a0,s6,ffffffffc0204368 <readline+0x38>
            cputchar(c);
ffffffffc02043b4:	d3dfb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i] = '\0';
ffffffffc02043b8:	0000d517          	auipc	a0,0xd
ffffffffc02043bc:	d4050513          	addi	a0,a0,-704 # ffffffffc02110f8 <buf>
ffffffffc02043c0:	94aa                	add	s1,s1,a0
ffffffffc02043c2:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02043c6:	60a6                	ld	ra,72(sp)
ffffffffc02043c8:	6486                	ld	s1,64(sp)
ffffffffc02043ca:	7962                	ld	s2,56(sp)
ffffffffc02043cc:	79c2                	ld	s3,48(sp)
ffffffffc02043ce:	7a22                	ld	s4,40(sp)
ffffffffc02043d0:	7a82                	ld	s5,32(sp)
ffffffffc02043d2:	6b62                	ld	s6,24(sp)
ffffffffc02043d4:	6bc2                	ld	s7,16(sp)
ffffffffc02043d6:	6161                	addi	sp,sp,80
ffffffffc02043d8:	8082                	ret
            cputchar(c);
ffffffffc02043da:	4521                	li	a0,8
ffffffffc02043dc:	d15fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            i --;
ffffffffc02043e0:	34fd                	addiw	s1,s1,-1
ffffffffc02043e2:	b759                	j	ffffffffc0204368 <readline+0x38>
