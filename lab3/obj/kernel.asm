
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
ffffffffc020003e:	52e60613          	addi	a2,a2,1326 # ffffffffc0211568 <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	769030ef          	jal	ra,ffffffffc0203fb2 <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020004e:	00004597          	auipc	a1,0x4
ffffffffc0200052:	43258593          	addi	a1,a1,1074 # ffffffffc0204480 <etext+0x2>
ffffffffc0200056:	00004517          	auipc	a0,0x4
ffffffffc020005a:	44a50513          	addi	a0,a0,1098 # ffffffffc02044a0 <etext+0x22>
ffffffffc020005e:	05c000ef          	jal	ra,ffffffffc02000ba <cprintf>

    print_kerninfo();
ffffffffc0200062:	0fc000ef          	jal	ra,ffffffffc020015e <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc0200066:	701020ef          	jal	ra,ffffffffc0202f66 <pmm_init>
    // 我们加入了多级页表的接口和测试

    idt_init();                 // init interrupt descriptor table
ffffffffc020006a:	4fa000ef          	jal	ra,ffffffffc0200564 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020006e:	423000ef          	jal	ra,ffffffffc0200c90 <vmm_init>
    // 新增函数, 初始化虚拟内存管理并测试

    ide_init();                 // init ide devices初始化“硬盘”
ffffffffc0200072:	35e000ef          	jal	ra,ffffffffc02003d0 <ide_init>
    swap_init();                // init swap
ffffffffc0200076:	2c0010ef          	jal	ra,ffffffffc0201336 <swap_init>
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
ffffffffc02000ae:	79b030ef          	jal	ra,ffffffffc0204048 <vprintfmt>
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
ffffffffc02000e4:	765030ef          	jal	ra,ffffffffc0204048 <vprintfmt>
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
ffffffffc0200134:	37850513          	addi	a0,a0,888 # ffffffffc02044a8 <etext+0x2a>
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
ffffffffc020014a:	d8250513          	addi	a0,a0,-638 # ffffffffc0205ec8 <default_pmm_manager+0x420>
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
ffffffffc0200164:	36850513          	addi	a0,a0,872 # ffffffffc02044c8 <etext+0x4a>
void print_kerninfo(void) {
ffffffffc0200168:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020016a:	f51ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc020016e:	00000597          	auipc	a1,0x0
ffffffffc0200172:	ec458593          	addi	a1,a1,-316 # ffffffffc0200032 <kern_init>
ffffffffc0200176:	00004517          	auipc	a0,0x4
ffffffffc020017a:	37250513          	addi	a0,a0,882 # ffffffffc02044e8 <etext+0x6a>
ffffffffc020017e:	f3dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200182:	00004597          	auipc	a1,0x4
ffffffffc0200186:	2fc58593          	addi	a1,a1,764 # ffffffffc020447e <etext>
ffffffffc020018a:	00004517          	auipc	a0,0x4
ffffffffc020018e:	37e50513          	addi	a0,a0,894 # ffffffffc0204508 <etext+0x8a>
ffffffffc0200192:	f29ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200196:	0000a597          	auipc	a1,0xa
ffffffffc020019a:	eaa58593          	addi	a1,a1,-342 # ffffffffc020a040 <ide>
ffffffffc020019e:	00004517          	auipc	a0,0x4
ffffffffc02001a2:	38a50513          	addi	a0,a0,906 # ffffffffc0204528 <etext+0xaa>
ffffffffc02001a6:	f15ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc02001aa:	00011597          	auipc	a1,0x11
ffffffffc02001ae:	3be58593          	addi	a1,a1,958 # ffffffffc0211568 <end>
ffffffffc02001b2:	00004517          	auipc	a0,0x4
ffffffffc02001b6:	39650513          	addi	a0,a0,918 # ffffffffc0204548 <etext+0xca>
ffffffffc02001ba:	f01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001be:	00011597          	auipc	a1,0x11
ffffffffc02001c2:	7a958593          	addi	a1,a1,1961 # ffffffffc0211967 <end+0x3ff>
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
ffffffffc02001e4:	38850513          	addi	a0,a0,904 # ffffffffc0204568 <etext+0xea>
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
ffffffffc02001f2:	3aa60613          	addi	a2,a2,938 # ffffffffc0204598 <etext+0x11a>
ffffffffc02001f6:	04e00593          	li	a1,78
ffffffffc02001fa:	00004517          	auipc	a0,0x4
ffffffffc02001fe:	3b650513          	addi	a0,a0,950 # ffffffffc02045b0 <etext+0x132>
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
ffffffffc020020e:	3be60613          	addi	a2,a2,958 # ffffffffc02045c8 <etext+0x14a>
ffffffffc0200212:	00004597          	auipc	a1,0x4
ffffffffc0200216:	3d658593          	addi	a1,a1,982 # ffffffffc02045e8 <etext+0x16a>
ffffffffc020021a:	00004517          	auipc	a0,0x4
ffffffffc020021e:	3d650513          	addi	a0,a0,982 # ffffffffc02045f0 <etext+0x172>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200222:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200224:	e97ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200228:	00004617          	auipc	a2,0x4
ffffffffc020022c:	3d860613          	addi	a2,a2,984 # ffffffffc0204600 <etext+0x182>
ffffffffc0200230:	00004597          	auipc	a1,0x4
ffffffffc0200234:	3f858593          	addi	a1,a1,1016 # ffffffffc0204628 <etext+0x1aa>
ffffffffc0200238:	00004517          	auipc	a0,0x4
ffffffffc020023c:	3b850513          	addi	a0,a0,952 # ffffffffc02045f0 <etext+0x172>
ffffffffc0200240:	e7bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200244:	00004617          	auipc	a2,0x4
ffffffffc0200248:	3f460613          	addi	a2,a2,1012 # ffffffffc0204638 <etext+0x1ba>
ffffffffc020024c:	00004597          	auipc	a1,0x4
ffffffffc0200250:	40c58593          	addi	a1,a1,1036 # ffffffffc0204658 <etext+0x1da>
ffffffffc0200254:	00004517          	auipc	a0,0x4
ffffffffc0200258:	39c50513          	addi	a0,a0,924 # ffffffffc02045f0 <etext+0x172>
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
ffffffffc0200292:	3da50513          	addi	a0,a0,986 # ffffffffc0204668 <etext+0x1ea>
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
ffffffffc02002b4:	3e050513          	addi	a0,a0,992 # ffffffffc0204690 <etext+0x212>
ffffffffc02002b8:	e03ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    if (tf != NULL) {
ffffffffc02002bc:	000b8563          	beqz	s7,ffffffffc02002c6 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002c0:	855e                	mv	a0,s7
ffffffffc02002c2:	48c000ef          	jal	ra,ffffffffc020074e <print_trapframe>
ffffffffc02002c6:	00004c17          	auipc	s8,0x4
ffffffffc02002ca:	432c0c13          	addi	s8,s8,1074 # ffffffffc02046f8 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc02002ce:	00005917          	auipc	s2,0x5
ffffffffc02002d2:	19a90913          	addi	s2,s2,410 # ffffffffc0205468 <commands+0xd70>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d6:	00004497          	auipc	s1,0x4
ffffffffc02002da:	3e248493          	addi	s1,s1,994 # ffffffffc02046b8 <etext+0x23a>
        if (argc == MAXARGS - 1) {
ffffffffc02002de:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002e0:	00004b17          	auipc	s6,0x4
ffffffffc02002e4:	3e0b0b13          	addi	s6,s6,992 # ffffffffc02046c0 <etext+0x242>
        argv[argc ++] = buf;
ffffffffc02002e8:	00004a17          	auipc	s4,0x4
ffffffffc02002ec:	300a0a13          	addi	s4,s4,768 # ffffffffc02045e8 <etext+0x16a>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4a8d                	li	s5,3
        if ((buf = readline("")) != NULL) {
ffffffffc02002f2:	854a                	mv	a0,s2
ffffffffc02002f4:	0d6040ef          	jal	ra,ffffffffc02043ca <readline>
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
ffffffffc020030e:	3eed0d13          	addi	s10,s10,1006 # ffffffffc02046f8 <commands>
        argv[argc ++] = buf;
ffffffffc0200312:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200314:	4401                	li	s0,0
ffffffffc0200316:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200318:	467030ef          	jal	ra,ffffffffc0203f7e <strcmp>
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
ffffffffc020032c:	453030ef          	jal	ra,ffffffffc0203f7e <strcmp>
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
ffffffffc020036a:	433030ef          	jal	ra,ffffffffc0203f9c <strchr>
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
ffffffffc02003a8:	3f5030ef          	jal	ra,ffffffffc0203f9c <strchr>
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
ffffffffc02003c6:	31e50513          	addi	a0,a0,798 # ffffffffc02046e0 <etext+0x262>
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
ffffffffc02003f6:	3cf030ef          	jal	ra,ffffffffc0203fc4 <memcpy>
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
ffffffffc020041a:	3ab030ef          	jal	ra,ffffffffc0203fc4 <memcpy>
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
ffffffffc0200450:	2f450513          	addi	a0,a0,756 # ffffffffc0204740 <commands+0x48>
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
ffffffffc0200528:	23c50513          	addi	a0,a0,572 # ffffffffc0204760 <commands+0x68>
ffffffffc020052c:	b8fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200530:	00011517          	auipc	a0,0x11
ffffffffc0200534:	fe053503          	ld	a0,-32(a0) # ffffffffc0211510 <check_mm_struct>
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
ffffffffc0200548:	5210006f          	j	ffffffffc0201268 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020054c:	00004617          	auipc	a2,0x4
ffffffffc0200550:	23460613          	addi	a2,a2,564 # ffffffffc0204780 <commands+0x88>
ffffffffc0200554:	07800593          	li	a1,120
ffffffffc0200558:	00004517          	auipc	a0,0x4
ffffffffc020055c:	24050513          	addi	a0,a0,576 # ffffffffc0204798 <commands+0xa0>
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
ffffffffc020058e:	22650513          	addi	a0,a0,550 # ffffffffc02047b0 <commands+0xb8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200592:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200594:	b27ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200598:	640c                	ld	a1,8(s0)
ffffffffc020059a:	00004517          	auipc	a0,0x4
ffffffffc020059e:	22e50513          	addi	a0,a0,558 # ffffffffc02047c8 <commands+0xd0>
ffffffffc02005a2:	b19ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005a6:	680c                	ld	a1,16(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	23850513          	addi	a0,a0,568 # ffffffffc02047e0 <commands+0xe8>
ffffffffc02005b0:	b0bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005b4:	6c0c                	ld	a1,24(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	24250513          	addi	a0,a0,578 # ffffffffc02047f8 <commands+0x100>
ffffffffc02005be:	afdff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005c2:	700c                	ld	a1,32(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	24c50513          	addi	a0,a0,588 # ffffffffc0204810 <commands+0x118>
ffffffffc02005cc:	aefff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005d0:	740c                	ld	a1,40(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	25650513          	addi	a0,a0,598 # ffffffffc0204828 <commands+0x130>
ffffffffc02005da:	ae1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005de:	780c                	ld	a1,48(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	26050513          	addi	a0,a0,608 # ffffffffc0204840 <commands+0x148>
ffffffffc02005e8:	ad3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005ec:	7c0c                	ld	a1,56(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	26a50513          	addi	a0,a0,618 # ffffffffc0204858 <commands+0x160>
ffffffffc02005f6:	ac5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02005fa:	602c                	ld	a1,64(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	27450513          	addi	a0,a0,628 # ffffffffc0204870 <commands+0x178>
ffffffffc0200604:	ab7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200608:	642c                	ld	a1,72(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	27e50513          	addi	a0,a0,638 # ffffffffc0204888 <commands+0x190>
ffffffffc0200612:	aa9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200616:	682c                	ld	a1,80(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	28850513          	addi	a0,a0,648 # ffffffffc02048a0 <commands+0x1a8>
ffffffffc0200620:	a9bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200624:	6c2c                	ld	a1,88(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	29250513          	addi	a0,a0,658 # ffffffffc02048b8 <commands+0x1c0>
ffffffffc020062e:	a8dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200632:	702c                	ld	a1,96(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	29c50513          	addi	a0,a0,668 # ffffffffc02048d0 <commands+0x1d8>
ffffffffc020063c:	a7fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200640:	742c                	ld	a1,104(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	2a650513          	addi	a0,a0,678 # ffffffffc02048e8 <commands+0x1f0>
ffffffffc020064a:	a71ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020064e:	782c                	ld	a1,112(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	2b050513          	addi	a0,a0,688 # ffffffffc0204900 <commands+0x208>
ffffffffc0200658:	a63ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020065c:	7c2c                	ld	a1,120(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	2ba50513          	addi	a0,a0,698 # ffffffffc0204918 <commands+0x220>
ffffffffc0200666:	a55ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020066a:	604c                	ld	a1,128(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	2c450513          	addi	a0,a0,708 # ffffffffc0204930 <commands+0x238>
ffffffffc0200674:	a47ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200678:	644c                	ld	a1,136(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	2ce50513          	addi	a0,a0,718 # ffffffffc0204948 <commands+0x250>
ffffffffc0200682:	a39ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200686:	684c                	ld	a1,144(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	2d850513          	addi	a0,a0,728 # ffffffffc0204960 <commands+0x268>
ffffffffc0200690:	a2bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200694:	6c4c                	ld	a1,152(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	2e250513          	addi	a0,a0,738 # ffffffffc0204978 <commands+0x280>
ffffffffc020069e:	a1dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006a2:	704c                	ld	a1,160(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	2ec50513          	addi	a0,a0,748 # ffffffffc0204990 <commands+0x298>
ffffffffc02006ac:	a0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006b0:	744c                	ld	a1,168(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	2f650513          	addi	a0,a0,758 # ffffffffc02049a8 <commands+0x2b0>
ffffffffc02006ba:	a01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006be:	784c                	ld	a1,176(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	30050513          	addi	a0,a0,768 # ffffffffc02049c0 <commands+0x2c8>
ffffffffc02006c8:	9f3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006cc:	7c4c                	ld	a1,184(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	30a50513          	addi	a0,a0,778 # ffffffffc02049d8 <commands+0x2e0>
ffffffffc02006d6:	9e5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006da:	606c                	ld	a1,192(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	31450513          	addi	a0,a0,788 # ffffffffc02049f0 <commands+0x2f8>
ffffffffc02006e4:	9d7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006e8:	646c                	ld	a1,200(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	31e50513          	addi	a0,a0,798 # ffffffffc0204a08 <commands+0x310>
ffffffffc02006f2:	9c9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006f6:	686c                	ld	a1,208(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	32850513          	addi	a0,a0,808 # ffffffffc0204a20 <commands+0x328>
ffffffffc0200700:	9bbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200704:	6c6c                	ld	a1,216(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	33250513          	addi	a0,a0,818 # ffffffffc0204a38 <commands+0x340>
ffffffffc020070e:	9adff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200712:	706c                	ld	a1,224(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	33c50513          	addi	a0,a0,828 # ffffffffc0204a50 <commands+0x358>
ffffffffc020071c:	99fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200720:	746c                	ld	a1,232(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	34650513          	addi	a0,a0,838 # ffffffffc0204a68 <commands+0x370>
ffffffffc020072a:	991ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020072e:	786c                	ld	a1,240(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	35050513          	addi	a0,a0,848 # ffffffffc0204a80 <commands+0x388>
ffffffffc0200738:	983ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020073c:	7c6c                	ld	a1,248(s0)
}
ffffffffc020073e:	6402                	ld	s0,0(sp)
ffffffffc0200740:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200742:	00004517          	auipc	a0,0x4
ffffffffc0200746:	35650513          	addi	a0,a0,854 # ffffffffc0204a98 <commands+0x3a0>
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
ffffffffc020075a:	35a50513          	addi	a0,a0,858 # ffffffffc0204ab0 <commands+0x3b8>
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
ffffffffc0200772:	35a50513          	addi	a0,a0,858 # ffffffffc0204ac8 <commands+0x3d0>
ffffffffc0200776:	945ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020077a:	10843583          	ld	a1,264(s0)
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	36250513          	addi	a0,a0,866 # ffffffffc0204ae0 <commands+0x3e8>
ffffffffc0200786:	935ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020078a:	11043583          	ld	a1,272(s0)
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	36a50513          	addi	a0,a0,874 # ffffffffc0204af8 <commands+0x400>
ffffffffc0200796:	925ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020079a:	11843583          	ld	a1,280(s0)
}
ffffffffc020079e:	6402                	ld	s0,0(sp)
ffffffffc02007a0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007a2:	00004517          	auipc	a0,0x4
ffffffffc02007a6:	36e50513          	addi	a0,a0,878 # ffffffffc0204b10 <commands+0x418>
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
ffffffffc02007c2:	41a70713          	addi	a4,a4,1050 # ffffffffc0204bd8 <commands+0x4e0>
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
ffffffffc02007d4:	3b850513          	addi	a0,a0,952 # ffffffffc0204b88 <commands+0x490>
ffffffffc02007d8:	8e3ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007dc:	00004517          	auipc	a0,0x4
ffffffffc02007e0:	38c50513          	addi	a0,a0,908 # ffffffffc0204b68 <commands+0x470>
ffffffffc02007e4:	8d7ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007e8:	00004517          	auipc	a0,0x4
ffffffffc02007ec:	34050513          	addi	a0,a0,832 # ffffffffc0204b28 <commands+0x430>
ffffffffc02007f0:	8cbff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007f4:	00004517          	auipc	a0,0x4
ffffffffc02007f8:	35450513          	addi	a0,a0,852 # ffffffffc0204b48 <commands+0x450>
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
ffffffffc020082a:	39250513          	addi	a0,a0,914 # ffffffffc0204bb8 <commands+0x4c0>
ffffffffc020082e:	88dff06f          	j	ffffffffc02000ba <cprintf>
            print_trapframe(tf);
ffffffffc0200832:	bf31                	j	ffffffffc020074e <print_trapframe>
}
ffffffffc0200834:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200836:	06400593          	li	a1,100
ffffffffc020083a:	00004517          	auipc	a0,0x4
ffffffffc020083e:	36e50513          	addi	a0,a0,878 # ffffffffc0204ba8 <commands+0x4b0>
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
ffffffffc0200860:	56470713          	addi	a4,a4,1380 # ffffffffc0204dc0 <commands+0x6c8>
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
ffffffffc0200872:	53a50513          	addi	a0,a0,1338 # ffffffffc0204da8 <commands+0x6b0>
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
ffffffffc0200894:	37850513          	addi	a0,a0,888 # ffffffffc0204c08 <commands+0x510>
}
ffffffffc0200898:	6442                	ld	s0,16(sp)
ffffffffc020089a:	60e2                	ld	ra,24(sp)
ffffffffc020089c:	64a2                	ld	s1,8(sp)
ffffffffc020089e:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008a0:	81bff06f          	j	ffffffffc02000ba <cprintf>
ffffffffc02008a4:	00004517          	auipc	a0,0x4
ffffffffc02008a8:	38450513          	addi	a0,a0,900 # ffffffffc0204c28 <commands+0x530>
ffffffffc02008ac:	b7f5                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02008ae:	00004517          	auipc	a0,0x4
ffffffffc02008b2:	39a50513          	addi	a0,a0,922 # ffffffffc0204c48 <commands+0x550>
ffffffffc02008b6:	b7cd                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02008b8:	00004517          	auipc	a0,0x4
ffffffffc02008bc:	3a850513          	addi	a0,a0,936 # ffffffffc0204c60 <commands+0x568>
ffffffffc02008c0:	bfe1                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02008c2:	00004517          	auipc	a0,0x4
ffffffffc02008c6:	3ae50513          	addi	a0,a0,942 # ffffffffc0204c70 <commands+0x578>
ffffffffc02008ca:	b7f9                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02008cc:	00004517          	auipc	a0,0x4
ffffffffc02008d0:	3c450513          	addi	a0,a0,964 # ffffffffc0204c90 <commands+0x598>
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
ffffffffc02008ee:	3be60613          	addi	a2,a2,958 # ffffffffc0204ca8 <commands+0x5b0>
ffffffffc02008f2:	0ca00593          	li	a1,202
ffffffffc02008f6:	00004517          	auipc	a0,0x4
ffffffffc02008fa:	ea250513          	addi	a0,a0,-350 # ffffffffc0204798 <commands+0xa0>
ffffffffc02008fe:	805ff0ef          	jal	ra,ffffffffc0200102 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc0200902:	00004517          	auipc	a0,0x4
ffffffffc0200906:	3c650513          	addi	a0,a0,966 # ffffffffc0204cc8 <commands+0x5d0>
ffffffffc020090a:	b779                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc020090c:	00004517          	auipc	a0,0x4
ffffffffc0200910:	3d450513          	addi	a0,a0,980 # ffffffffc0204ce0 <commands+0x5e8>
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
ffffffffc020092e:	37e60613          	addi	a2,a2,894 # ffffffffc0204ca8 <commands+0x5b0>
ffffffffc0200932:	0d400593          	li	a1,212
ffffffffc0200936:	00004517          	auipc	a0,0x4
ffffffffc020093a:	e6250513          	addi	a0,a0,-414 # ffffffffc0204798 <commands+0xa0>
ffffffffc020093e:	fc4ff0ef          	jal	ra,ffffffffc0200102 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200942:	00004517          	auipc	a0,0x4
ffffffffc0200946:	3b650513          	addi	a0,a0,950 # ffffffffc0204cf8 <commands+0x600>
ffffffffc020094a:	b7b9                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc020094c:	00004517          	auipc	a0,0x4
ffffffffc0200950:	3cc50513          	addi	a0,a0,972 # ffffffffc0204d18 <commands+0x620>
ffffffffc0200954:	b791                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200956:	00004517          	auipc	a0,0x4
ffffffffc020095a:	3e250513          	addi	a0,a0,994 # ffffffffc0204d38 <commands+0x640>
ffffffffc020095e:	bf2d                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200960:	00004517          	auipc	a0,0x4
ffffffffc0200964:	3f850513          	addi	a0,a0,1016 # ffffffffc0204d58 <commands+0x660>
ffffffffc0200968:	bf05                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc020096a:	00004517          	auipc	a0,0x4
ffffffffc020096e:	40e50513          	addi	a0,a0,1038 # ffffffffc0204d78 <commands+0x680>
ffffffffc0200972:	b71d                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200974:	00004517          	auipc	a0,0x4
ffffffffc0200978:	41c50513          	addi	a0,a0,1052 # ffffffffc0204d90 <commands+0x698>
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
ffffffffc0200998:	31460613          	addi	a2,a2,788 # ffffffffc0204ca8 <commands+0x5b0>
ffffffffc020099c:	0ea00593          	li	a1,234
ffffffffc02009a0:	00004517          	auipc	a0,0x4
ffffffffc02009a4:	df850513          	addi	a0,a0,-520 # ffffffffc0204798 <commands+0xa0>
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
ffffffffc02009c4:	2e860613          	addi	a2,a2,744 # ffffffffc0204ca8 <commands+0x5b0>
ffffffffc02009c8:	0f100593          	li	a1,241
ffffffffc02009cc:	00004517          	auipc	a0,0x4
ffffffffc02009d0:	dcc50513          	addi	a0,a0,-564 # ffffffffc0204798 <commands+0xa0>
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

ffffffffc0200ab0 <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200ab0:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0200ab2:	00004697          	auipc	a3,0x4
ffffffffc0200ab6:	34e68693          	addi	a3,a3,846 # ffffffffc0204e00 <commands+0x708>
ffffffffc0200aba:	00004617          	auipc	a2,0x4
ffffffffc0200abe:	36660613          	addi	a2,a2,870 # ffffffffc0204e20 <commands+0x728>
ffffffffc0200ac2:	07d00593          	li	a1,125
ffffffffc0200ac6:	00004517          	auipc	a0,0x4
ffffffffc0200aca:	37250513          	addi	a0,a0,882 # ffffffffc0204e38 <commands+0x740>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200ace:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0200ad0:	e32ff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200ad4 <mm_create>:
mm_create(void) {
ffffffffc0200ad4:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200ad6:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0200ada:	e022                	sd	s0,0(sp)
ffffffffc0200adc:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200ade:	14a030ef          	jal	ra,ffffffffc0203c28 <kmalloc>
ffffffffc0200ae2:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200ae4:	c105                	beqz	a0,ffffffffc0200b04 <mm_create+0x30>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200ae6:	e408                	sd	a0,8(s0)
ffffffffc0200ae8:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0200aea:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200aee:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200af2:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200af6:	00011797          	auipc	a5,0x11
ffffffffc0200afa:	a3a7a783          	lw	a5,-1478(a5) # ffffffffc0211530 <swap_init_ok>
ffffffffc0200afe:	eb81                	bnez	a5,ffffffffc0200b0e <mm_create+0x3a>
        else mm->sm_priv = NULL;
ffffffffc0200b00:	02053423          	sd	zero,40(a0)
}
ffffffffc0200b04:	60a2                	ld	ra,8(sp)
ffffffffc0200b06:	8522                	mv	a0,s0
ffffffffc0200b08:	6402                	ld	s0,0(sp)
ffffffffc0200b0a:	0141                	addi	sp,sp,16
ffffffffc0200b0c:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200b0e:	693000ef          	jal	ra,ffffffffc02019a0 <swap_init_mm>
}
ffffffffc0200b12:	60a2                	ld	ra,8(sp)
ffffffffc0200b14:	8522                	mv	a0,s0
ffffffffc0200b16:	6402                	ld	s0,0(sp)
ffffffffc0200b18:	0141                	addi	sp,sp,16
ffffffffc0200b1a:	8082                	ret

ffffffffc0200b1c <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0200b1c:	1101                	addi	sp,sp,-32
ffffffffc0200b1e:	e04a                	sd	s2,0(sp)
ffffffffc0200b20:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200b22:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0200b26:	e822                	sd	s0,16(sp)
ffffffffc0200b28:	e426                	sd	s1,8(sp)
ffffffffc0200b2a:	ec06                	sd	ra,24(sp)
ffffffffc0200b2c:	84ae                	mv	s1,a1
ffffffffc0200b2e:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200b30:	0f8030ef          	jal	ra,ffffffffc0203c28 <kmalloc>
    if (vma != NULL) {
ffffffffc0200b34:	c509                	beqz	a0,ffffffffc0200b3e <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0200b36:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200b3a:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200b3c:	ed00                	sd	s0,24(a0)
}
ffffffffc0200b3e:	60e2                	ld	ra,24(sp)
ffffffffc0200b40:	6442                	ld	s0,16(sp)
ffffffffc0200b42:	64a2                	ld	s1,8(sp)
ffffffffc0200b44:	6902                	ld	s2,0(sp)
ffffffffc0200b46:	6105                	addi	sp,sp,32
ffffffffc0200b48:	8082                	ret

ffffffffc0200b4a <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0200b4a:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0200b4c:	c505                	beqz	a0,ffffffffc0200b74 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0200b4e:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200b50:	c501                	beqz	a0,ffffffffc0200b58 <find_vma+0xe>
ffffffffc0200b52:	651c                	ld	a5,8(a0)
ffffffffc0200b54:	02f5f263          	bgeu	a1,a5,ffffffffc0200b78 <find_vma+0x2e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200b58:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0200b5a:	00f68d63          	beq	a3,a5,ffffffffc0200b74 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0200b5e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200b62:	00e5e663          	bltu	a1,a4,ffffffffc0200b6e <find_vma+0x24>
ffffffffc0200b66:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200b6a:	00e5ec63          	bltu	a1,a4,ffffffffc0200b82 <find_vma+0x38>
ffffffffc0200b6e:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0200b70:	fef697e3          	bne	a3,a5,ffffffffc0200b5e <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0200b74:	4501                	li	a0,0
}
ffffffffc0200b76:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200b78:	691c                	ld	a5,16(a0)
ffffffffc0200b7a:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0200b58 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0200b7e:	ea88                	sd	a0,16(a3)
ffffffffc0200b80:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0200b82:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0200b86:	ea88                	sd	a0,16(a3)
ffffffffc0200b88:	8082                	ret

ffffffffc0200b8a <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200b8a:	6590                	ld	a2,8(a1)
ffffffffc0200b8c:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0200b90:	1141                	addi	sp,sp,-16
ffffffffc0200b92:	e406                	sd	ra,8(sp)
ffffffffc0200b94:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200b96:	01066763          	bltu	a2,a6,ffffffffc0200ba4 <insert_vma_struct+0x1a>
ffffffffc0200b9a:	a085                	j	ffffffffc0200bfa <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200b9c:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200ba0:	04e66863          	bltu	a2,a4,ffffffffc0200bf0 <insert_vma_struct+0x66>
ffffffffc0200ba4:	86be                	mv	a3,a5
ffffffffc0200ba6:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0200ba8:	fef51ae3          	bne	a0,a5,ffffffffc0200b9c <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0200bac:	02a68463          	beq	a3,a0,ffffffffc0200bd4 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0200bb0:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200bb4:	fe86b883          	ld	a7,-24(a3)
ffffffffc0200bb8:	08e8f163          	bgeu	a7,a4,ffffffffc0200c3a <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200bbc:	04e66f63          	bltu	a2,a4,ffffffffc0200c1a <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc0200bc0:	00f50a63          	beq	a0,a5,ffffffffc0200bd4 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200bc4:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200bc8:	05076963          	bltu	a4,a6,ffffffffc0200c1a <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0200bcc:	ff07b603          	ld	a2,-16(a5)
ffffffffc0200bd0:	02c77363          	bgeu	a4,a2,ffffffffc0200bf6 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0200bd4:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0200bd6:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0200bd8:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200bdc:	e390                	sd	a2,0(a5)
ffffffffc0200bde:	e690                	sd	a2,8(a3)
}
ffffffffc0200be0:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0200be2:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0200be4:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0200be6:	0017079b          	addiw	a5,a4,1
ffffffffc0200bea:	d11c                	sw	a5,32(a0)
}
ffffffffc0200bec:	0141                	addi	sp,sp,16
ffffffffc0200bee:	8082                	ret
    if (le_prev != list) {
ffffffffc0200bf0:	fca690e3          	bne	a3,a0,ffffffffc0200bb0 <insert_vma_struct+0x26>
ffffffffc0200bf4:	bfd1                	j	ffffffffc0200bc8 <insert_vma_struct+0x3e>
ffffffffc0200bf6:	ebbff0ef          	jal	ra,ffffffffc0200ab0 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200bfa:	00004697          	auipc	a3,0x4
ffffffffc0200bfe:	24e68693          	addi	a3,a3,590 # ffffffffc0204e48 <commands+0x750>
ffffffffc0200c02:	00004617          	auipc	a2,0x4
ffffffffc0200c06:	21e60613          	addi	a2,a2,542 # ffffffffc0204e20 <commands+0x728>
ffffffffc0200c0a:	08400593          	li	a1,132
ffffffffc0200c0e:	00004517          	auipc	a0,0x4
ffffffffc0200c12:	22a50513          	addi	a0,a0,554 # ffffffffc0204e38 <commands+0x740>
ffffffffc0200c16:	cecff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200c1a:	00004697          	auipc	a3,0x4
ffffffffc0200c1e:	26e68693          	addi	a3,a3,622 # ffffffffc0204e88 <commands+0x790>
ffffffffc0200c22:	00004617          	auipc	a2,0x4
ffffffffc0200c26:	1fe60613          	addi	a2,a2,510 # ffffffffc0204e20 <commands+0x728>
ffffffffc0200c2a:	07c00593          	li	a1,124
ffffffffc0200c2e:	00004517          	auipc	a0,0x4
ffffffffc0200c32:	20a50513          	addi	a0,a0,522 # ffffffffc0204e38 <commands+0x740>
ffffffffc0200c36:	cccff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200c3a:	00004697          	auipc	a3,0x4
ffffffffc0200c3e:	22e68693          	addi	a3,a3,558 # ffffffffc0204e68 <commands+0x770>
ffffffffc0200c42:	00004617          	auipc	a2,0x4
ffffffffc0200c46:	1de60613          	addi	a2,a2,478 # ffffffffc0204e20 <commands+0x728>
ffffffffc0200c4a:	07b00593          	li	a1,123
ffffffffc0200c4e:	00004517          	auipc	a0,0x4
ffffffffc0200c52:	1ea50513          	addi	a0,a0,490 # ffffffffc0204e38 <commands+0x740>
ffffffffc0200c56:	cacff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200c5a <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0200c5a:	1141                	addi	sp,sp,-16
ffffffffc0200c5c:	e022                	sd	s0,0(sp)
ffffffffc0200c5e:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0200c60:	6508                	ld	a0,8(a0)
ffffffffc0200c62:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0200c64:	00a40e63          	beq	s0,a0,ffffffffc0200c80 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200c68:	6118                	ld	a4,0(a0)
ffffffffc0200c6a:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0200c6c:	03000593          	li	a1,48
ffffffffc0200c70:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200c72:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200c74:	e398                	sd	a4,0(a5)
ffffffffc0200c76:	06c030ef          	jal	ra,ffffffffc0203ce2 <kfree>
    return listelm->next;
ffffffffc0200c7a:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0200c7c:	fea416e3          	bne	s0,a0,ffffffffc0200c68 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200c80:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0200c82:	6402                	ld	s0,0(sp)
ffffffffc0200c84:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200c86:	03000593          	li	a1,48
}
ffffffffc0200c8a:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200c8c:	0560306f          	j	ffffffffc0203ce2 <kfree>

ffffffffc0200c90 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0200c90:	715d                	addi	sp,sp,-80
ffffffffc0200c92:	e486                	sd	ra,72(sp)
ffffffffc0200c94:	f44e                	sd	s3,40(sp)
ffffffffc0200c96:	f052                	sd	s4,32(sp)
ffffffffc0200c98:	e0a2                	sd	s0,64(sp)
ffffffffc0200c9a:	fc26                	sd	s1,56(sp)
ffffffffc0200c9c:	f84a                	sd	s2,48(sp)
ffffffffc0200c9e:	ec56                	sd	s5,24(sp)
ffffffffc0200ca0:	e85a                	sd	s6,16(sp)
ffffffffc0200ca2:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200ca4:	69f010ef          	jal	ra,ffffffffc0202b42 <nr_free_pages>
ffffffffc0200ca8:	89aa                	mv	s3,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200caa:	699010ef          	jal	ra,ffffffffc0202b42 <nr_free_pages>
ffffffffc0200cae:	8a2a                	mv	s4,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200cb0:	03000513          	li	a0,48
ffffffffc0200cb4:	775020ef          	jal	ra,ffffffffc0203c28 <kmalloc>
    if (mm != NULL) {
ffffffffc0200cb8:	56050863          	beqz	a0,ffffffffc0201228 <vmm_init+0x598>
    elm->prev = elm->next = elm;
ffffffffc0200cbc:	e508                	sd	a0,8(a0)
ffffffffc0200cbe:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0200cc0:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200cc4:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200cc8:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200ccc:	00011797          	auipc	a5,0x11
ffffffffc0200cd0:	8647a783          	lw	a5,-1948(a5) # ffffffffc0211530 <swap_init_ok>
ffffffffc0200cd4:	84aa                	mv	s1,a0
ffffffffc0200cd6:	e7b9                	bnez	a5,ffffffffc0200d24 <vmm_init+0x94>
        else mm->sm_priv = NULL;
ffffffffc0200cd8:	02053423          	sd	zero,40(a0)
vmm_init(void) {
ffffffffc0200cdc:	03200413          	li	s0,50
ffffffffc0200ce0:	a811                	j	ffffffffc0200cf4 <vmm_init+0x64>
        vma->vm_start = vm_start;
ffffffffc0200ce2:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200ce4:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200ce6:	00053c23          	sd	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc0200cea:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0200cec:	8526                	mv	a0,s1
ffffffffc0200cee:	e9dff0ef          	jal	ra,ffffffffc0200b8a <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0200cf2:	cc05                	beqz	s0,ffffffffc0200d2a <vmm_init+0x9a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200cf4:	03000513          	li	a0,48
ffffffffc0200cf8:	731020ef          	jal	ra,ffffffffc0203c28 <kmalloc>
ffffffffc0200cfc:	85aa                	mv	a1,a0
ffffffffc0200cfe:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0200d02:	f165                	bnez	a0,ffffffffc0200ce2 <vmm_init+0x52>
        assert(vma != NULL);
ffffffffc0200d04:	00004697          	auipc	a3,0x4
ffffffffc0200d08:	3d468693          	addi	a3,a3,980 # ffffffffc02050d8 <commands+0x9e0>
ffffffffc0200d0c:	00004617          	auipc	a2,0x4
ffffffffc0200d10:	11460613          	addi	a2,a2,276 # ffffffffc0204e20 <commands+0x728>
ffffffffc0200d14:	0ce00593          	li	a1,206
ffffffffc0200d18:	00004517          	auipc	a0,0x4
ffffffffc0200d1c:	12050513          	addi	a0,a0,288 # ffffffffc0204e38 <commands+0x740>
ffffffffc0200d20:	be2ff0ef          	jal	ra,ffffffffc0200102 <__panic>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200d24:	47d000ef          	jal	ra,ffffffffc02019a0 <swap_init_mm>
ffffffffc0200d28:	bf55                	j	ffffffffc0200cdc <vmm_init+0x4c>
ffffffffc0200d2a:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0200d2e:	1f900913          	li	s2,505
ffffffffc0200d32:	a819                	j	ffffffffc0200d48 <vmm_init+0xb8>
        vma->vm_start = vm_start;
ffffffffc0200d34:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200d36:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200d38:	00053c23          	sd	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0200d3c:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0200d3e:	8526                	mv	a0,s1
ffffffffc0200d40:	e4bff0ef          	jal	ra,ffffffffc0200b8a <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0200d44:	03240a63          	beq	s0,s2,ffffffffc0200d78 <vmm_init+0xe8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200d48:	03000513          	li	a0,48
ffffffffc0200d4c:	6dd020ef          	jal	ra,ffffffffc0203c28 <kmalloc>
ffffffffc0200d50:	85aa                	mv	a1,a0
ffffffffc0200d52:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0200d56:	fd79                	bnez	a0,ffffffffc0200d34 <vmm_init+0xa4>
        assert(vma != NULL);
ffffffffc0200d58:	00004697          	auipc	a3,0x4
ffffffffc0200d5c:	38068693          	addi	a3,a3,896 # ffffffffc02050d8 <commands+0x9e0>
ffffffffc0200d60:	00004617          	auipc	a2,0x4
ffffffffc0200d64:	0c060613          	addi	a2,a2,192 # ffffffffc0204e20 <commands+0x728>
ffffffffc0200d68:	0d400593          	li	a1,212
ffffffffc0200d6c:	00004517          	auipc	a0,0x4
ffffffffc0200d70:	0cc50513          	addi	a0,a0,204 # ffffffffc0204e38 <commands+0x740>
ffffffffc0200d74:	b8eff0ef          	jal	ra,ffffffffc0200102 <__panic>
    return listelm->next;
ffffffffc0200d78:	649c                	ld	a5,8(s1)
ffffffffc0200d7a:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0200d7c:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0200d80:	2ef48463          	beq	s1,a5,ffffffffc0201068 <vmm_init+0x3d8>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0200d84:	fe87b603          	ld	a2,-24(a5)
ffffffffc0200d88:	ffe70693          	addi	a3,a4,-2
ffffffffc0200d8c:	26d61e63          	bne	a2,a3,ffffffffc0201008 <vmm_init+0x378>
ffffffffc0200d90:	ff07b683          	ld	a3,-16(a5)
ffffffffc0200d94:	26e69a63          	bne	a3,a4,ffffffffc0201008 <vmm_init+0x378>
    for (i = 1; i <= step2; i ++) {
ffffffffc0200d98:	0715                	addi	a4,a4,5
ffffffffc0200d9a:	679c                	ld	a5,8(a5)
ffffffffc0200d9c:	feb712e3          	bne	a4,a1,ffffffffc0200d80 <vmm_init+0xf0>
ffffffffc0200da0:	4b1d                	li	s6,7
ffffffffc0200da2:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0200da4:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0200da8:	85a2                	mv	a1,s0
ffffffffc0200daa:	8526                	mv	a0,s1
ffffffffc0200dac:	d9fff0ef          	jal	ra,ffffffffc0200b4a <find_vma>
ffffffffc0200db0:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0200db2:	2c050b63          	beqz	a0,ffffffffc0201088 <vmm_init+0x3f8>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0200db6:	00140593          	addi	a1,s0,1
ffffffffc0200dba:	8526                	mv	a0,s1
ffffffffc0200dbc:	d8fff0ef          	jal	ra,ffffffffc0200b4a <find_vma>
ffffffffc0200dc0:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc0200dc2:	2e050363          	beqz	a0,ffffffffc02010a8 <vmm_init+0x418>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0200dc6:	85da                	mv	a1,s6
ffffffffc0200dc8:	8526                	mv	a0,s1
ffffffffc0200dca:	d81ff0ef          	jal	ra,ffffffffc0200b4a <find_vma>
        assert(vma3 == NULL);
ffffffffc0200dce:	2e051d63          	bnez	a0,ffffffffc02010c8 <vmm_init+0x438>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0200dd2:	00340593          	addi	a1,s0,3
ffffffffc0200dd6:	8526                	mv	a0,s1
ffffffffc0200dd8:	d73ff0ef          	jal	ra,ffffffffc0200b4a <find_vma>
        assert(vma4 == NULL);
ffffffffc0200ddc:	30051663          	bnez	a0,ffffffffc02010e8 <vmm_init+0x458>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0200de0:	00440593          	addi	a1,s0,4
ffffffffc0200de4:	8526                	mv	a0,s1
ffffffffc0200de6:	d65ff0ef          	jal	ra,ffffffffc0200b4a <find_vma>
        assert(vma5 == NULL);
ffffffffc0200dea:	30051f63          	bnez	a0,ffffffffc0201108 <vmm_init+0x478>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0200dee:	00893783          	ld	a5,8(s2)
ffffffffc0200df2:	24879b63          	bne	a5,s0,ffffffffc0201048 <vmm_init+0x3b8>
ffffffffc0200df6:	01093783          	ld	a5,16(s2)
ffffffffc0200dfa:	25679763          	bne	a5,s6,ffffffffc0201048 <vmm_init+0x3b8>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0200dfe:	008ab783          	ld	a5,8(s5)
ffffffffc0200e02:	22879363          	bne	a5,s0,ffffffffc0201028 <vmm_init+0x398>
ffffffffc0200e06:	010ab783          	ld	a5,16(s5)
ffffffffc0200e0a:	21679f63          	bne	a5,s6,ffffffffc0201028 <vmm_init+0x398>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0200e0e:	0415                	addi	s0,s0,5
ffffffffc0200e10:	0b15                	addi	s6,s6,5
ffffffffc0200e12:	f9741be3          	bne	s0,s7,ffffffffc0200da8 <vmm_init+0x118>
ffffffffc0200e16:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0200e18:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0200e1a:	85a2                	mv	a1,s0
ffffffffc0200e1c:	8526                	mv	a0,s1
ffffffffc0200e1e:	d2dff0ef          	jal	ra,ffffffffc0200b4a <find_vma>
ffffffffc0200e22:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc0200e26:	c90d                	beqz	a0,ffffffffc0200e58 <vmm_init+0x1c8>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0200e28:	6914                	ld	a3,16(a0)
ffffffffc0200e2a:	6510                	ld	a2,8(a0)
ffffffffc0200e2c:	00004517          	auipc	a0,0x4
ffffffffc0200e30:	17c50513          	addi	a0,a0,380 # ffffffffc0204fa8 <commands+0x8b0>
ffffffffc0200e34:	a86ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0200e38:	00004697          	auipc	a3,0x4
ffffffffc0200e3c:	19868693          	addi	a3,a3,408 # ffffffffc0204fd0 <commands+0x8d8>
ffffffffc0200e40:	00004617          	auipc	a2,0x4
ffffffffc0200e44:	fe060613          	addi	a2,a2,-32 # ffffffffc0204e20 <commands+0x728>
ffffffffc0200e48:	0f600593          	li	a1,246
ffffffffc0200e4c:	00004517          	auipc	a0,0x4
ffffffffc0200e50:	fec50513          	addi	a0,a0,-20 # ffffffffc0204e38 <commands+0x740>
ffffffffc0200e54:	aaeff0ef          	jal	ra,ffffffffc0200102 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc0200e58:	147d                	addi	s0,s0,-1
ffffffffc0200e5a:	fd2410e3          	bne	s0,s2,ffffffffc0200e1a <vmm_init+0x18a>
ffffffffc0200e5e:	a811                	j	ffffffffc0200e72 <vmm_init+0x1e2>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200e60:	6118                	ld	a4,0(a0)
ffffffffc0200e62:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0200e64:	03000593          	li	a1,48
ffffffffc0200e68:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0200e6a:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200e6c:	e398                	sd	a4,0(a5)
ffffffffc0200e6e:	675020ef          	jal	ra,ffffffffc0203ce2 <kfree>
    return listelm->next;
ffffffffc0200e72:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list) {
ffffffffc0200e74:	fea496e3          	bne	s1,a0,ffffffffc0200e60 <vmm_init+0x1d0>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200e78:	03000593          	li	a1,48
ffffffffc0200e7c:	8526                	mv	a0,s1
ffffffffc0200e7e:	665020ef          	jal	ra,ffffffffc0203ce2 <kfree>
    }

    mm_destroy(mm);

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200e82:	4c1010ef          	jal	ra,ffffffffc0202b42 <nr_free_pages>
ffffffffc0200e86:	3caa1163          	bne	s4,a0,ffffffffc0201248 <vmm_init+0x5b8>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0200e8a:	00004517          	auipc	a0,0x4
ffffffffc0200e8e:	18650513          	addi	a0,a0,390 # ffffffffc0205010 <commands+0x918>
ffffffffc0200e92:	a28ff0ef          	jal	ra,ffffffffc02000ba <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200e96:	4ad010ef          	jal	ra,ffffffffc0202b42 <nr_free_pages>
ffffffffc0200e9a:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200e9c:	03000513          	li	a0,48
ffffffffc0200ea0:	589020ef          	jal	ra,ffffffffc0203c28 <kmalloc>
ffffffffc0200ea4:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200ea6:	2a050163          	beqz	a0,ffffffffc0201148 <vmm_init+0x4b8>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200eaa:	00010797          	auipc	a5,0x10
ffffffffc0200eae:	6867a783          	lw	a5,1670(a5) # ffffffffc0211530 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc0200eb2:	e508                	sd	a0,8(a0)
ffffffffc0200eb4:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0200eb6:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200eba:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200ebe:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200ec2:	14079063          	bnez	a5,ffffffffc0201002 <vmm_init+0x372>
        else mm->sm_priv = NULL;
ffffffffc0200ec6:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();

    assert(check_mm_struct != NULL);
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0200eca:	00010917          	auipc	s2,0x10
ffffffffc0200ece:	67693903          	ld	s2,1654(s2) # ffffffffc0211540 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0200ed2:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc0200ed6:	00010717          	auipc	a4,0x10
ffffffffc0200eda:	62873d23          	sd	s0,1594(a4) # ffffffffc0211510 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0200ede:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc0200ee2:	24079363          	bnez	a5,ffffffffc0201128 <vmm_init+0x498>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200ee6:	03000513          	li	a0,48
ffffffffc0200eea:	53f020ef          	jal	ra,ffffffffc0203c28 <kmalloc>
ffffffffc0200eee:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc0200ef0:	28050063          	beqz	a0,ffffffffc0201170 <vmm_init+0x4e0>
        vma->vm_end = vm_end;
ffffffffc0200ef4:	002007b7          	lui	a5,0x200
ffffffffc0200ef8:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc0200efc:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0200efe:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0200f00:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc0200f04:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0200f06:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc0200f0a:	c81ff0ef          	jal	ra,ffffffffc0200b8a <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0200f0e:	10000593          	li	a1,256
ffffffffc0200f12:	8522                	mv	a0,s0
ffffffffc0200f14:	c37ff0ef          	jal	ra,ffffffffc0200b4a <find_vma>
ffffffffc0200f18:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0200f1c:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0200f20:	26aa1863          	bne	s4,a0,ffffffffc0201190 <vmm_init+0x500>
        *(char *)(addr + i) = i;
ffffffffc0200f24:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i ++) {
ffffffffc0200f28:	0785                	addi	a5,a5,1
ffffffffc0200f2a:	fee79de3          	bne	a5,a4,ffffffffc0200f24 <vmm_init+0x294>
        sum += i;
ffffffffc0200f2e:	6705                	lui	a4,0x1
ffffffffc0200f30:	10000793          	li	a5,256
ffffffffc0200f34:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0200f38:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0200f3c:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc0200f40:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc0200f42:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0200f44:	fec79ce3          	bne	a5,a2,ffffffffc0200f3c <vmm_init+0x2ac>
    }
    assert(sum == 0);
ffffffffc0200f48:	26071463          	bnez	a4,ffffffffc02011b0 <vmm_init+0x520>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0200f4c:	4581                	li	a1,0
ffffffffc0200f4e:	854a                	mv	a0,s2
ffffffffc0200f50:	67d010ef          	jal	ra,ffffffffc0202dcc <page_remove>
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
ffffffffc0200f54:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0200f58:	00010717          	auipc	a4,0x10
ffffffffc0200f5c:	5f073703          	ld	a4,1520(a4) # ffffffffc0211548 <npage>
    return pa2page(PDE_ADDR(pde));
ffffffffc0200f60:	078a                	slli	a5,a5,0x2
ffffffffc0200f62:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200f64:	26e7f663          	bgeu	a5,a4,ffffffffc02011d0 <vmm_init+0x540>
    return &pages[PPN(pa) - nbase];
ffffffffc0200f68:	00005717          	auipc	a4,0x5
ffffffffc0200f6c:	41873703          	ld	a4,1048(a4) # ffffffffc0206380 <nbase>
ffffffffc0200f70:	8f99                	sub	a5,a5,a4
ffffffffc0200f72:	00379713          	slli	a4,a5,0x3
ffffffffc0200f76:	97ba                	add	a5,a5,a4
ffffffffc0200f78:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc0200f7a:	00010517          	auipc	a0,0x10
ffffffffc0200f7e:	5d653503          	ld	a0,1494(a0) # ffffffffc0211550 <pages>
ffffffffc0200f82:	953e                	add	a0,a0,a5
ffffffffc0200f84:	4585                	li	a1,1
ffffffffc0200f86:	37d010ef          	jal	ra,ffffffffc0202b02 <free_pages>
    return listelm->next;
ffffffffc0200f8a:	6408                	ld	a0,8(s0)

    pgdir[0] = 0;
ffffffffc0200f8c:	00093023          	sd	zero,0(s2)

    mm->pgdir = NULL;
ffffffffc0200f90:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0200f94:	00a40e63          	beq	s0,a0,ffffffffc0200fb0 <vmm_init+0x320>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200f98:	6118                	ld	a4,0(a0)
ffffffffc0200f9a:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0200f9c:	03000593          	li	a1,48
ffffffffc0200fa0:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0200fa2:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200fa4:	e398                	sd	a4,0(a5)
ffffffffc0200fa6:	53d020ef          	jal	ra,ffffffffc0203ce2 <kfree>
    return listelm->next;
ffffffffc0200faa:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0200fac:	fea416e3          	bne	s0,a0,ffffffffc0200f98 <vmm_init+0x308>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200fb0:	03000593          	li	a1,48
ffffffffc0200fb4:	8522                	mv	a0,s0
ffffffffc0200fb6:	52d020ef          	jal	ra,ffffffffc0203ce2 <kfree>
    mm_destroy(mm);

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc0200fba:	14fd                	addi	s1,s1,-1
    check_mm_struct = NULL;
ffffffffc0200fbc:	00010797          	auipc	a5,0x10
ffffffffc0200fc0:	5407ba23          	sd	zero,1364(a5) # ffffffffc0211510 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200fc4:	37f010ef          	jal	ra,ffffffffc0202b42 <nr_free_pages>
ffffffffc0200fc8:	22a49063          	bne	s1,a0,ffffffffc02011e8 <vmm_init+0x558>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0200fcc:	00004517          	auipc	a0,0x4
ffffffffc0200fd0:	0d450513          	addi	a0,a0,212 # ffffffffc02050a0 <commands+0x9a8>
ffffffffc0200fd4:	8e6ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200fd8:	36b010ef          	jal	ra,ffffffffc0202b42 <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc0200fdc:	19fd                	addi	s3,s3,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200fde:	22a99563          	bne	s3,a0,ffffffffc0201208 <vmm_init+0x578>
}
ffffffffc0200fe2:	6406                	ld	s0,64(sp)
ffffffffc0200fe4:	60a6                	ld	ra,72(sp)
ffffffffc0200fe6:	74e2                	ld	s1,56(sp)
ffffffffc0200fe8:	7942                	ld	s2,48(sp)
ffffffffc0200fea:	79a2                	ld	s3,40(sp)
ffffffffc0200fec:	7a02                	ld	s4,32(sp)
ffffffffc0200fee:	6ae2                	ld	s5,24(sp)
ffffffffc0200ff0:	6b42                	ld	s6,16(sp)
ffffffffc0200ff2:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0200ff4:	00004517          	auipc	a0,0x4
ffffffffc0200ff8:	0cc50513          	addi	a0,a0,204 # ffffffffc02050c0 <commands+0x9c8>
}
ffffffffc0200ffc:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc0200ffe:	8bcff06f          	j	ffffffffc02000ba <cprintf>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201002:	19f000ef          	jal	ra,ffffffffc02019a0 <swap_init_mm>
ffffffffc0201006:	b5d1                	j	ffffffffc0200eca <vmm_init+0x23a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0201008:	00004697          	auipc	a3,0x4
ffffffffc020100c:	eb868693          	addi	a3,a3,-328 # ffffffffc0204ec0 <commands+0x7c8>
ffffffffc0201010:	00004617          	auipc	a2,0x4
ffffffffc0201014:	e1060613          	addi	a2,a2,-496 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201018:	0dd00593          	li	a1,221
ffffffffc020101c:	00004517          	auipc	a0,0x4
ffffffffc0201020:	e1c50513          	addi	a0,a0,-484 # ffffffffc0204e38 <commands+0x740>
ffffffffc0201024:	8deff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0201028:	00004697          	auipc	a3,0x4
ffffffffc020102c:	f5068693          	addi	a3,a3,-176 # ffffffffc0204f78 <commands+0x880>
ffffffffc0201030:	00004617          	auipc	a2,0x4
ffffffffc0201034:	df060613          	addi	a2,a2,-528 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201038:	0ee00593          	li	a1,238
ffffffffc020103c:	00004517          	auipc	a0,0x4
ffffffffc0201040:	dfc50513          	addi	a0,a0,-516 # ffffffffc0204e38 <commands+0x740>
ffffffffc0201044:	8beff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0201048:	00004697          	auipc	a3,0x4
ffffffffc020104c:	f0068693          	addi	a3,a3,-256 # ffffffffc0204f48 <commands+0x850>
ffffffffc0201050:	00004617          	auipc	a2,0x4
ffffffffc0201054:	dd060613          	addi	a2,a2,-560 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201058:	0ed00593          	li	a1,237
ffffffffc020105c:	00004517          	auipc	a0,0x4
ffffffffc0201060:	ddc50513          	addi	a0,a0,-548 # ffffffffc0204e38 <commands+0x740>
ffffffffc0201064:	89eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0201068:	00004697          	auipc	a3,0x4
ffffffffc020106c:	e4068693          	addi	a3,a3,-448 # ffffffffc0204ea8 <commands+0x7b0>
ffffffffc0201070:	00004617          	auipc	a2,0x4
ffffffffc0201074:	db060613          	addi	a2,a2,-592 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201078:	0db00593          	li	a1,219
ffffffffc020107c:	00004517          	auipc	a0,0x4
ffffffffc0201080:	dbc50513          	addi	a0,a0,-580 # ffffffffc0204e38 <commands+0x740>
ffffffffc0201084:	87eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma1 != NULL);
ffffffffc0201088:	00004697          	auipc	a3,0x4
ffffffffc020108c:	e7068693          	addi	a3,a3,-400 # ffffffffc0204ef8 <commands+0x800>
ffffffffc0201090:	00004617          	auipc	a2,0x4
ffffffffc0201094:	d9060613          	addi	a2,a2,-624 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201098:	0e300593          	li	a1,227
ffffffffc020109c:	00004517          	auipc	a0,0x4
ffffffffc02010a0:	d9c50513          	addi	a0,a0,-612 # ffffffffc0204e38 <commands+0x740>
ffffffffc02010a4:	85eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma2 != NULL);
ffffffffc02010a8:	00004697          	auipc	a3,0x4
ffffffffc02010ac:	e6068693          	addi	a3,a3,-416 # ffffffffc0204f08 <commands+0x810>
ffffffffc02010b0:	00004617          	auipc	a2,0x4
ffffffffc02010b4:	d7060613          	addi	a2,a2,-656 # ffffffffc0204e20 <commands+0x728>
ffffffffc02010b8:	0e500593          	li	a1,229
ffffffffc02010bc:	00004517          	auipc	a0,0x4
ffffffffc02010c0:	d7c50513          	addi	a0,a0,-644 # ffffffffc0204e38 <commands+0x740>
ffffffffc02010c4:	83eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma3 == NULL);
ffffffffc02010c8:	00004697          	auipc	a3,0x4
ffffffffc02010cc:	e5068693          	addi	a3,a3,-432 # ffffffffc0204f18 <commands+0x820>
ffffffffc02010d0:	00004617          	auipc	a2,0x4
ffffffffc02010d4:	d5060613          	addi	a2,a2,-688 # ffffffffc0204e20 <commands+0x728>
ffffffffc02010d8:	0e700593          	li	a1,231
ffffffffc02010dc:	00004517          	auipc	a0,0x4
ffffffffc02010e0:	d5c50513          	addi	a0,a0,-676 # ffffffffc0204e38 <commands+0x740>
ffffffffc02010e4:	81eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma4 == NULL);
ffffffffc02010e8:	00004697          	auipc	a3,0x4
ffffffffc02010ec:	e4068693          	addi	a3,a3,-448 # ffffffffc0204f28 <commands+0x830>
ffffffffc02010f0:	00004617          	auipc	a2,0x4
ffffffffc02010f4:	d3060613          	addi	a2,a2,-720 # ffffffffc0204e20 <commands+0x728>
ffffffffc02010f8:	0e900593          	li	a1,233
ffffffffc02010fc:	00004517          	auipc	a0,0x4
ffffffffc0201100:	d3c50513          	addi	a0,a0,-708 # ffffffffc0204e38 <commands+0x740>
ffffffffc0201104:	ffffe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma5 == NULL);
ffffffffc0201108:	00004697          	auipc	a3,0x4
ffffffffc020110c:	e3068693          	addi	a3,a3,-464 # ffffffffc0204f38 <commands+0x840>
ffffffffc0201110:	00004617          	auipc	a2,0x4
ffffffffc0201114:	d1060613          	addi	a2,a2,-752 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201118:	0eb00593          	li	a1,235
ffffffffc020111c:	00004517          	auipc	a0,0x4
ffffffffc0201120:	d1c50513          	addi	a0,a0,-740 # ffffffffc0204e38 <commands+0x740>
ffffffffc0201124:	fdffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0201128:	00004697          	auipc	a3,0x4
ffffffffc020112c:	f0868693          	addi	a3,a3,-248 # ffffffffc0205030 <commands+0x938>
ffffffffc0201130:	00004617          	auipc	a2,0x4
ffffffffc0201134:	cf060613          	addi	a2,a2,-784 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201138:	10d00593          	li	a1,269
ffffffffc020113c:	00004517          	auipc	a0,0x4
ffffffffc0201140:	cfc50513          	addi	a0,a0,-772 # ffffffffc0204e38 <commands+0x740>
ffffffffc0201144:	fbffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0201148:	00004697          	auipc	a3,0x4
ffffffffc020114c:	fa068693          	addi	a3,a3,-96 # ffffffffc02050e8 <commands+0x9f0>
ffffffffc0201150:	00004617          	auipc	a2,0x4
ffffffffc0201154:	cd060613          	addi	a2,a2,-816 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201158:	10a00593          	li	a1,266
ffffffffc020115c:	00004517          	auipc	a0,0x4
ffffffffc0201160:	cdc50513          	addi	a0,a0,-804 # ffffffffc0204e38 <commands+0x740>
    check_mm_struct = mm_create();
ffffffffc0201164:	00010797          	auipc	a5,0x10
ffffffffc0201168:	3a07b623          	sd	zero,940(a5) # ffffffffc0211510 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc020116c:	f97fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(vma != NULL);
ffffffffc0201170:	00004697          	auipc	a3,0x4
ffffffffc0201174:	f6868693          	addi	a3,a3,-152 # ffffffffc02050d8 <commands+0x9e0>
ffffffffc0201178:	00004617          	auipc	a2,0x4
ffffffffc020117c:	ca860613          	addi	a2,a2,-856 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201180:	11100593          	li	a1,273
ffffffffc0201184:	00004517          	auipc	a0,0x4
ffffffffc0201188:	cb450513          	addi	a0,a0,-844 # ffffffffc0204e38 <commands+0x740>
ffffffffc020118c:	f77fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0201190:	00004697          	auipc	a3,0x4
ffffffffc0201194:	eb068693          	addi	a3,a3,-336 # ffffffffc0205040 <commands+0x948>
ffffffffc0201198:	00004617          	auipc	a2,0x4
ffffffffc020119c:	c8860613          	addi	a2,a2,-888 # ffffffffc0204e20 <commands+0x728>
ffffffffc02011a0:	11600593          	li	a1,278
ffffffffc02011a4:	00004517          	auipc	a0,0x4
ffffffffc02011a8:	c9450513          	addi	a0,a0,-876 # ffffffffc0204e38 <commands+0x740>
ffffffffc02011ac:	f57fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(sum == 0);
ffffffffc02011b0:	00004697          	auipc	a3,0x4
ffffffffc02011b4:	eb068693          	addi	a3,a3,-336 # ffffffffc0205060 <commands+0x968>
ffffffffc02011b8:	00004617          	auipc	a2,0x4
ffffffffc02011bc:	c6860613          	addi	a2,a2,-920 # ffffffffc0204e20 <commands+0x728>
ffffffffc02011c0:	12000593          	li	a1,288
ffffffffc02011c4:	00004517          	auipc	a0,0x4
ffffffffc02011c8:	c7450513          	addi	a0,a0,-908 # ffffffffc0204e38 <commands+0x740>
ffffffffc02011cc:	f37fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02011d0:	00004617          	auipc	a2,0x4
ffffffffc02011d4:	ea060613          	addi	a2,a2,-352 # ffffffffc0205070 <commands+0x978>
ffffffffc02011d8:	06500593          	li	a1,101
ffffffffc02011dc:	00004517          	auipc	a0,0x4
ffffffffc02011e0:	eb450513          	addi	a0,a0,-332 # ffffffffc0205090 <commands+0x998>
ffffffffc02011e4:	f1ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02011e8:	00004697          	auipc	a3,0x4
ffffffffc02011ec:	e0068693          	addi	a3,a3,-512 # ffffffffc0204fe8 <commands+0x8f0>
ffffffffc02011f0:	00004617          	auipc	a2,0x4
ffffffffc02011f4:	c3060613          	addi	a2,a2,-976 # ffffffffc0204e20 <commands+0x728>
ffffffffc02011f8:	12e00593          	li	a1,302
ffffffffc02011fc:	00004517          	auipc	a0,0x4
ffffffffc0201200:	c3c50513          	addi	a0,a0,-964 # ffffffffc0204e38 <commands+0x740>
ffffffffc0201204:	efffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201208:	00004697          	auipc	a3,0x4
ffffffffc020120c:	de068693          	addi	a3,a3,-544 # ffffffffc0204fe8 <commands+0x8f0>
ffffffffc0201210:	00004617          	auipc	a2,0x4
ffffffffc0201214:	c1060613          	addi	a2,a2,-1008 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201218:	0bd00593          	li	a1,189
ffffffffc020121c:	00004517          	auipc	a0,0x4
ffffffffc0201220:	c1c50513          	addi	a0,a0,-996 # ffffffffc0204e38 <commands+0x740>
ffffffffc0201224:	edffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(mm != NULL);
ffffffffc0201228:	00004697          	auipc	a3,0x4
ffffffffc020122c:	ed868693          	addi	a3,a3,-296 # ffffffffc0205100 <commands+0xa08>
ffffffffc0201230:	00004617          	auipc	a2,0x4
ffffffffc0201234:	bf060613          	addi	a2,a2,-1040 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201238:	0c700593          	li	a1,199
ffffffffc020123c:	00004517          	auipc	a0,0x4
ffffffffc0201240:	bfc50513          	addi	a0,a0,-1028 # ffffffffc0204e38 <commands+0x740>
ffffffffc0201244:	ebffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201248:	00004697          	auipc	a3,0x4
ffffffffc020124c:	da068693          	addi	a3,a3,-608 # ffffffffc0204fe8 <commands+0x8f0>
ffffffffc0201250:	00004617          	auipc	a2,0x4
ffffffffc0201254:	bd060613          	addi	a2,a2,-1072 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201258:	0fb00593          	li	a1,251
ffffffffc020125c:	00004517          	auipc	a0,0x4
ffffffffc0201260:	bdc50513          	addi	a0,a0,-1060 # ffffffffc0204e38 <commands+0x740>
ffffffffc0201264:	e9ffe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201268 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0201268:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020126a:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc020126c:	f022                	sd	s0,32(sp)
ffffffffc020126e:	ec26                	sd	s1,24(sp)
ffffffffc0201270:	f406                	sd	ra,40(sp)
ffffffffc0201272:	e84a                	sd	s2,16(sp)
ffffffffc0201274:	8432                	mv	s0,a2
ffffffffc0201276:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0201278:	8d3ff0ef          	jal	ra,ffffffffc0200b4a <find_vma>

    pgfault_num++;
ffffffffc020127c:	00010797          	auipc	a5,0x10
ffffffffc0201280:	29c7a783          	lw	a5,668(a5) # ffffffffc0211518 <pgfault_num>
ffffffffc0201284:	2785                	addiw	a5,a5,1
ffffffffc0201286:	00010717          	auipc	a4,0x10
ffffffffc020128a:	28f72923          	sw	a5,658(a4) # ffffffffc0211518 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc020128e:	c159                	beqz	a0,ffffffffc0201314 <do_pgfault+0xac>
ffffffffc0201290:	651c                	ld	a5,8(a0)
ffffffffc0201292:	08f46163          	bltu	s0,a5,ffffffffc0201314 <do_pgfault+0xac>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0201296:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0201298:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020129a:	8b89                	andi	a5,a5,2
ffffffffc020129c:	ebb1                	bnez	a5,ffffffffc02012f0 <do_pgfault+0x88>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc020129e:	75fd                	lui	a1,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc02012a0:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02012a2:	8c6d                	and	s0,s0,a1
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc02012a4:	85a2                	mv	a1,s0
ffffffffc02012a6:	4605                	li	a2,1
ffffffffc02012a8:	0d5010ef          	jal	ra,ffffffffc0202b7c <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc02012ac:	610c                	ld	a1,0(a0)
ffffffffc02012ae:	c1b9                	beqz	a1,ffffffffc02012f4 <do_pgfault+0x8c>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc02012b0:	00010797          	auipc	a5,0x10
ffffffffc02012b4:	2807a783          	lw	a5,640(a5) # ffffffffc0211530 <swap_init_ok>
ffffffffc02012b8:	c7bd                	beqz	a5,ffffffffc0201326 <do_pgfault+0xbe>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            swap_in(mm, addr, &page);
ffffffffc02012ba:	85a2                	mv	a1,s0
ffffffffc02012bc:	0030                	addi	a2,sp,8
ffffffffc02012be:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc02012c0:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);
ffffffffc02012c2:	00b000ef          	jal	ra,ffffffffc0201acc <swap_in>
            page_insert(mm->pgdir, page, addr, perm); //更新页表，插入新的页表项
ffffffffc02012c6:	65a2                	ld	a1,8(sp)
ffffffffc02012c8:	6c88                	ld	a0,24(s1)
ffffffffc02012ca:	86ca                	mv	a3,s2
ffffffffc02012cc:	8622                	mv	a2,s0
ffffffffc02012ce:	399010ef          	jal	ra,ffffffffc0202e66 <page_insert>
            swap_map_swappable(mm, addr, page, 1); 
ffffffffc02012d2:	6622                	ld	a2,8(sp)
ffffffffc02012d4:	4685                	li	a3,1
ffffffffc02012d6:	85a2                	mv	a1,s0
ffffffffc02012d8:	8526                	mv	a0,s1
ffffffffc02012da:	6d2000ef          	jal	ra,ffffffffc02019ac <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc02012de:	67a2                	ld	a5,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc02012e0:	4501                	li	a0,0
            page->pra_vaddr = addr;
ffffffffc02012e2:	e3a0                	sd	s0,64(a5)
failed:
    return ret;
}
ffffffffc02012e4:	70a2                	ld	ra,40(sp)
ffffffffc02012e6:	7402                	ld	s0,32(sp)
ffffffffc02012e8:	64e2                	ld	s1,24(sp)
ffffffffc02012ea:	6942                	ld	s2,16(sp)
ffffffffc02012ec:	6145                	addi	sp,sp,48
ffffffffc02012ee:	8082                	ret
        perm |= (PTE_R | PTE_W);
ffffffffc02012f0:	4959                	li	s2,22
ffffffffc02012f2:	b775                	j	ffffffffc020129e <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02012f4:	6c88                	ld	a0,24(s1)
ffffffffc02012f6:	864a                	mv	a2,s2
ffffffffc02012f8:	85a2                	mv	a1,s0
ffffffffc02012fa:	077020ef          	jal	ra,ffffffffc0203b70 <pgdir_alloc_page>
ffffffffc02012fe:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc0201300:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0201302:	f3ed                	bnez	a5,ffffffffc02012e4 <do_pgfault+0x7c>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0201304:	00004517          	auipc	a0,0x4
ffffffffc0201308:	e3c50513          	addi	a0,a0,-452 # ffffffffc0205140 <commands+0xa48>
ffffffffc020130c:	daffe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0201310:	5571                	li	a0,-4
            goto failed;
ffffffffc0201312:	bfc9                	j	ffffffffc02012e4 <do_pgfault+0x7c>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0201314:	85a2                	mv	a1,s0
ffffffffc0201316:	00004517          	auipc	a0,0x4
ffffffffc020131a:	dfa50513          	addi	a0,a0,-518 # ffffffffc0205110 <commands+0xa18>
ffffffffc020131e:	d9dfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = -E_INVAL;
ffffffffc0201322:	5575                	li	a0,-3
        goto failed;
ffffffffc0201324:	b7c1                	j	ffffffffc02012e4 <do_pgfault+0x7c>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0201326:	00004517          	auipc	a0,0x4
ffffffffc020132a:	e4250513          	addi	a0,a0,-446 # ffffffffc0205168 <commands+0xa70>
ffffffffc020132e:	d8dfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0201332:	5571                	li	a0,-4
            goto failed;
ffffffffc0201334:	bf45                	j	ffffffffc02012e4 <do_pgfault+0x7c>

ffffffffc0201336 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0201336:	7135                	addi	sp,sp,-160
ffffffffc0201338:	ed06                	sd	ra,152(sp)
ffffffffc020133a:	e922                	sd	s0,144(sp)
ffffffffc020133c:	e526                	sd	s1,136(sp)
ffffffffc020133e:	e14a                	sd	s2,128(sp)
ffffffffc0201340:	fcce                	sd	s3,120(sp)
ffffffffc0201342:	f8d2                	sd	s4,112(sp)
ffffffffc0201344:	f4d6                	sd	s5,104(sp)
ffffffffc0201346:	f0da                	sd	s6,96(sp)
ffffffffc0201348:	ecde                	sd	s7,88(sp)
ffffffffc020134a:	e8e2                	sd	s8,80(sp)
ffffffffc020134c:	e4e6                	sd	s9,72(sp)
ffffffffc020134e:	e0ea                	sd	s10,64(sp)
ffffffffc0201350:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0201352:	279020ef          	jal	ra,ffffffffc0203dca <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0201356:	00010697          	auipc	a3,0x10
ffffffffc020135a:	1ca6b683          	ld	a3,458(a3) # ffffffffc0211520 <max_swap_offset>
ffffffffc020135e:	010007b7          	lui	a5,0x1000
ffffffffc0201362:	ff968713          	addi	a4,a3,-7
ffffffffc0201366:	17e1                	addi	a5,a5,-8
ffffffffc0201368:	3ee7e063          	bltu	a5,a4,ffffffffc0201748 <swap_init+0x412>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm=&swap_manager_fifo;
ffffffffc020136c:	00009797          	auipc	a5,0x9
ffffffffc0201370:	c9478793          	addi	a5,a5,-876 # ffffffffc020a000 <swap_manager_fifo>
     //sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
     int r = sm->init();
ffffffffc0201374:	6798                	ld	a4,8(a5)
     sm=&swap_manager_fifo;
ffffffffc0201376:	00010b17          	auipc	s6,0x10
ffffffffc020137a:	1b2b0b13          	addi	s6,s6,434 # ffffffffc0211528 <sm>
ffffffffc020137e:	00fb3023          	sd	a5,0(s6)
     int r = sm->init();
ffffffffc0201382:	9702                	jalr	a4
ffffffffc0201384:	89aa                	mv	s3,a0
     
     if (r == 0)
ffffffffc0201386:	c10d                	beqz	a0,ffffffffc02013a8 <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0201388:	60ea                	ld	ra,152(sp)
ffffffffc020138a:	644a                	ld	s0,144(sp)
ffffffffc020138c:	64aa                	ld	s1,136(sp)
ffffffffc020138e:	690a                	ld	s2,128(sp)
ffffffffc0201390:	7a46                	ld	s4,112(sp)
ffffffffc0201392:	7aa6                	ld	s5,104(sp)
ffffffffc0201394:	7b06                	ld	s6,96(sp)
ffffffffc0201396:	6be6                	ld	s7,88(sp)
ffffffffc0201398:	6c46                	ld	s8,80(sp)
ffffffffc020139a:	6ca6                	ld	s9,72(sp)
ffffffffc020139c:	6d06                	ld	s10,64(sp)
ffffffffc020139e:	7de2                	ld	s11,56(sp)
ffffffffc02013a0:	854e                	mv	a0,s3
ffffffffc02013a2:	79e6                	ld	s3,120(sp)
ffffffffc02013a4:	610d                	addi	sp,sp,160
ffffffffc02013a6:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02013a8:	000b3783          	ld	a5,0(s6)
ffffffffc02013ac:	00004517          	auipc	a0,0x4
ffffffffc02013b0:	e1450513          	addi	a0,a0,-492 # ffffffffc02051c0 <commands+0xac8>
ffffffffc02013b4:	00010497          	auipc	s1,0x10
ffffffffc02013b8:	d2c48493          	addi	s1,s1,-724 # ffffffffc02110e0 <free_area>
ffffffffc02013bc:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02013be:	4785                	li	a5,1
ffffffffc02013c0:	00010717          	auipc	a4,0x10
ffffffffc02013c4:	16f72823          	sw	a5,368(a4) # ffffffffc0211530 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02013c8:	cf3fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02013cc:	649c                	ld	a5,8(s1)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc02013ce:	4401                	li	s0,0
ffffffffc02013d0:	4d01                	li	s10,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02013d2:	2c978163          	beq	a5,s1,ffffffffc0201694 <swap_init+0x35e>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02013d6:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02013da:	8b09                	andi	a4,a4,2
ffffffffc02013dc:	2a070e63          	beqz	a4,ffffffffc0201698 <swap_init+0x362>
        count ++, total += p->property;
ffffffffc02013e0:	ff87a703          	lw	a4,-8(a5)
ffffffffc02013e4:	679c                	ld	a5,8(a5)
ffffffffc02013e6:	2d05                	addiw	s10,s10,1
ffffffffc02013e8:	9c39                	addw	s0,s0,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc02013ea:	fe9796e3          	bne	a5,s1,ffffffffc02013d6 <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc02013ee:	8922                	mv	s2,s0
ffffffffc02013f0:	752010ef          	jal	ra,ffffffffc0202b42 <nr_free_pages>
ffffffffc02013f4:	47251663          	bne	a0,s2,ffffffffc0201860 <swap_init+0x52a>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc02013f8:	8622                	mv	a2,s0
ffffffffc02013fa:	85ea                	mv	a1,s10
ffffffffc02013fc:	00004517          	auipc	a0,0x4
ffffffffc0201400:	e0c50513          	addi	a0,a0,-500 # ffffffffc0205208 <commands+0xb10>
ffffffffc0201404:	cb7fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0201408:	eccff0ef          	jal	ra,ffffffffc0200ad4 <mm_create>
ffffffffc020140c:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc020140e:	52050963          	beqz	a0,ffffffffc0201940 <swap_init+0x60a>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0201412:	00010797          	auipc	a5,0x10
ffffffffc0201416:	0fe78793          	addi	a5,a5,254 # ffffffffc0211510 <check_mm_struct>
ffffffffc020141a:	6398                	ld	a4,0(a5)
ffffffffc020141c:	54071263          	bnez	a4,ffffffffc0201960 <swap_init+0x62a>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201420:	00010b97          	auipc	s7,0x10
ffffffffc0201424:	120bbb83          	ld	s7,288(s7) # ffffffffc0211540 <boot_pgdir>
     assert(pgdir[0] == 0);
ffffffffc0201428:	000bb703          	ld	a4,0(s7)
     check_mm_struct = mm;
ffffffffc020142c:	e388                	sd	a0,0(a5)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020142e:	01753c23          	sd	s7,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0201432:	3c071763          	bnez	a4,ffffffffc0201800 <swap_init+0x4ca>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0201436:	6599                	lui	a1,0x6
ffffffffc0201438:	460d                	li	a2,3
ffffffffc020143a:	6505                	lui	a0,0x1
ffffffffc020143c:	ee0ff0ef          	jal	ra,ffffffffc0200b1c <vma_create>
ffffffffc0201440:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0201442:	3c050f63          	beqz	a0,ffffffffc0201820 <swap_init+0x4ea>

     insert_vma_struct(mm, vma);
ffffffffc0201446:	8556                	mv	a0,s5
ffffffffc0201448:	f42ff0ef          	jal	ra,ffffffffc0200b8a <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc020144c:	00004517          	auipc	a0,0x4
ffffffffc0201450:	dfc50513          	addi	a0,a0,-516 # ffffffffc0205248 <commands+0xb50>
ffffffffc0201454:	c67fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0201458:	018ab503          	ld	a0,24(s5)
ffffffffc020145c:	4605                	li	a2,1
ffffffffc020145e:	6585                	lui	a1,0x1
ffffffffc0201460:	71c010ef          	jal	ra,ffffffffc0202b7c <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0201464:	3c050e63          	beqz	a0,ffffffffc0201840 <swap_init+0x50a>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0201468:	00004517          	auipc	a0,0x4
ffffffffc020146c:	e3050513          	addi	a0,a0,-464 # ffffffffc0205298 <commands+0xba0>
ffffffffc0201470:	00010917          	auipc	s2,0x10
ffffffffc0201474:	bf090913          	addi	s2,s2,-1040 # ffffffffc0211060 <check_rp>
ffffffffc0201478:	c43fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020147c:	00010a17          	auipc	s4,0x10
ffffffffc0201480:	c04a0a13          	addi	s4,s4,-1020 # ffffffffc0211080 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0201484:	8c4a                	mv	s8,s2
          check_rp[i] = alloc_page();
ffffffffc0201486:	4505                	li	a0,1
ffffffffc0201488:	5e8010ef          	jal	ra,ffffffffc0202a70 <alloc_pages>
ffffffffc020148c:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc0201490:	28050c63          	beqz	a0,ffffffffc0201728 <swap_init+0x3f2>
ffffffffc0201494:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0201496:	8b89                	andi	a5,a5,2
ffffffffc0201498:	26079863          	bnez	a5,ffffffffc0201708 <swap_init+0x3d2>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020149c:	0c21                	addi	s8,s8,8
ffffffffc020149e:	ff4c14e3          	bne	s8,s4,ffffffffc0201486 <swap_init+0x150>
     }
     list_entry_t free_list_store = free_list;
ffffffffc02014a2:	609c                	ld	a5,0(s1)
ffffffffc02014a4:	0084bd83          	ld	s11,8(s1)
    elm->prev = elm->next = elm;
ffffffffc02014a8:	e084                	sd	s1,0(s1)
ffffffffc02014aa:	f03e                	sd	a5,32(sp)
     list_init(&free_list);
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
ffffffffc02014ac:	489c                	lw	a5,16(s1)
ffffffffc02014ae:	e484                	sd	s1,8(s1)
     nr_free = 0;
ffffffffc02014b0:	00010c17          	auipc	s8,0x10
ffffffffc02014b4:	bb0c0c13          	addi	s8,s8,-1104 # ffffffffc0211060 <check_rp>
     unsigned int nr_free_store = nr_free;
ffffffffc02014b8:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc02014ba:	00010797          	auipc	a5,0x10
ffffffffc02014be:	c207ab23          	sw	zero,-970(a5) # ffffffffc02110f0 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc02014c2:	000c3503          	ld	a0,0(s8)
ffffffffc02014c6:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02014c8:	0c21                	addi	s8,s8,8
        free_pages(check_rp[i],1);
ffffffffc02014ca:	638010ef          	jal	ra,ffffffffc0202b02 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02014ce:	ff4c1ae3          	bne	s8,s4,ffffffffc02014c2 <swap_init+0x18c>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02014d2:	0104ac03          	lw	s8,16(s1)
ffffffffc02014d6:	4791                	li	a5,4
ffffffffc02014d8:	4afc1463          	bne	s8,a5,ffffffffc0201980 <swap_init+0x64a>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc02014dc:	00004517          	auipc	a0,0x4
ffffffffc02014e0:	e4450513          	addi	a0,a0,-444 # ffffffffc0205320 <commands+0xc28>
ffffffffc02014e4:	bd7fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02014e8:	6605                	lui	a2,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc02014ea:	00010797          	auipc	a5,0x10
ffffffffc02014ee:	0207a723          	sw	zero,46(a5) # ffffffffc0211518 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02014f2:	4529                	li	a0,10
ffffffffc02014f4:	00a60023          	sb	a0,0(a2) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc02014f8:	00010597          	auipc	a1,0x10
ffffffffc02014fc:	0205a583          	lw	a1,32(a1) # ffffffffc0211518 <pgfault_num>
ffffffffc0201500:	4805                	li	a6,1
ffffffffc0201502:	00010797          	auipc	a5,0x10
ffffffffc0201506:	01678793          	addi	a5,a5,22 # ffffffffc0211518 <pgfault_num>
ffffffffc020150a:	3f059b63          	bne	a1,a6,ffffffffc0201900 <swap_init+0x5ca>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc020150e:	00a60823          	sb	a0,16(a2)
     assert(pgfault_num==1);
ffffffffc0201512:	4390                	lw	a2,0(a5)
ffffffffc0201514:	2601                	sext.w	a2,a2
ffffffffc0201516:	40b61563          	bne	a2,a1,ffffffffc0201920 <swap_init+0x5ea>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc020151a:	6589                	lui	a1,0x2
ffffffffc020151c:	452d                	li	a0,11
ffffffffc020151e:	00a58023          	sb	a0,0(a1) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0201522:	4390                	lw	a2,0(a5)
ffffffffc0201524:	4809                	li	a6,2
ffffffffc0201526:	2601                	sext.w	a2,a2
ffffffffc0201528:	35061c63          	bne	a2,a6,ffffffffc0201880 <swap_init+0x54a>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc020152c:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==2);
ffffffffc0201530:	438c                	lw	a1,0(a5)
ffffffffc0201532:	2581                	sext.w	a1,a1
ffffffffc0201534:	36c59663          	bne	a1,a2,ffffffffc02018a0 <swap_init+0x56a>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201538:	658d                	lui	a1,0x3
ffffffffc020153a:	4531                	li	a0,12
ffffffffc020153c:	00a58023          	sb	a0,0(a1) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0201540:	4390                	lw	a2,0(a5)
ffffffffc0201542:	480d                	li	a6,3
ffffffffc0201544:	2601                	sext.w	a2,a2
ffffffffc0201546:	37061d63          	bne	a2,a6,ffffffffc02018c0 <swap_init+0x58a>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc020154a:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==3);
ffffffffc020154e:	438c                	lw	a1,0(a5)
ffffffffc0201550:	2581                	sext.w	a1,a1
ffffffffc0201552:	38c59763          	bne	a1,a2,ffffffffc02018e0 <swap_init+0x5aa>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201556:	6591                	lui	a1,0x4
ffffffffc0201558:	4535                	li	a0,13
ffffffffc020155a:	00a58023          	sb	a0,0(a1) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc020155e:	4390                	lw	a2,0(a5)
ffffffffc0201560:	2601                	sext.w	a2,a2
ffffffffc0201562:	21861f63          	bne	a2,s8,ffffffffc0201780 <swap_init+0x44a>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0201566:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==4);
ffffffffc020156a:	439c                	lw	a5,0(a5)
ffffffffc020156c:	2781                	sext.w	a5,a5
ffffffffc020156e:	22c79963          	bne	a5,a2,ffffffffc02017a0 <swap_init+0x46a>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0201572:	489c                	lw	a5,16(s1)
ffffffffc0201574:	24079663          	bnez	a5,ffffffffc02017c0 <swap_init+0x48a>
ffffffffc0201578:	00010797          	auipc	a5,0x10
ffffffffc020157c:	b0878793          	addi	a5,a5,-1272 # ffffffffc0211080 <swap_in_seq_no>
ffffffffc0201580:	00010617          	auipc	a2,0x10
ffffffffc0201584:	b2860613          	addi	a2,a2,-1240 # ffffffffc02110a8 <swap_out_seq_no>
ffffffffc0201588:	00010517          	auipc	a0,0x10
ffffffffc020158c:	b2050513          	addi	a0,a0,-1248 # ffffffffc02110a8 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0201590:	55fd                	li	a1,-1
ffffffffc0201592:	c38c                	sw	a1,0(a5)
ffffffffc0201594:	c20c                	sw	a1,0(a2)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0201596:	0791                	addi	a5,a5,4
ffffffffc0201598:	0611                	addi	a2,a2,4
ffffffffc020159a:	fef51ce3          	bne	a0,a5,ffffffffc0201592 <swap_init+0x25c>
ffffffffc020159e:	00010817          	auipc	a6,0x10
ffffffffc02015a2:	aa280813          	addi	a6,a6,-1374 # ffffffffc0211040 <check_ptep>
ffffffffc02015a6:	00010897          	auipc	a7,0x10
ffffffffc02015aa:	aba88893          	addi	a7,a7,-1350 # ffffffffc0211060 <check_rp>
ffffffffc02015ae:	6585                	lui	a1,0x1
    return &pages[PPN(pa) - nbase];
ffffffffc02015b0:	00010c97          	auipc	s9,0x10
ffffffffc02015b4:	fa0c8c93          	addi	s9,s9,-96 # ffffffffc0211550 <pages>
ffffffffc02015b8:	00005c17          	auipc	s8,0x5
ffffffffc02015bc:	dc8c0c13          	addi	s8,s8,-568 # ffffffffc0206380 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc02015c0:	00083023          	sd	zero,0(a6)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02015c4:	4601                	li	a2,0
ffffffffc02015c6:	855e                	mv	a0,s7
ffffffffc02015c8:	ec46                	sd	a7,24(sp)
ffffffffc02015ca:	e82e                	sd	a1,16(sp)
         check_ptep[i]=0;
ffffffffc02015cc:	e442                	sd	a6,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02015ce:	5ae010ef          	jal	ra,ffffffffc0202b7c <get_pte>
ffffffffc02015d2:	6822                	ld	a6,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc02015d4:	65c2                	ld	a1,16(sp)
ffffffffc02015d6:	68e2                	ld	a7,24(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02015d8:	00a83023          	sd	a0,0(a6)
         assert(check_ptep[i] != NULL);
ffffffffc02015dc:	00010317          	auipc	t1,0x10
ffffffffc02015e0:	f6c30313          	addi	t1,t1,-148 # ffffffffc0211548 <npage>
ffffffffc02015e4:	16050e63          	beqz	a0,ffffffffc0201760 <swap_init+0x42a>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02015e8:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02015ea:	0017f613          	andi	a2,a5,1
ffffffffc02015ee:	0e060563          	beqz	a2,ffffffffc02016d8 <swap_init+0x3a2>
    if (PPN(pa) >= npage) {
ffffffffc02015f2:	00033603          	ld	a2,0(t1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02015f6:	078a                	slli	a5,a5,0x2
ffffffffc02015f8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02015fa:	0ec7fb63          	bgeu	a5,a2,ffffffffc02016f0 <swap_init+0x3ba>
    return &pages[PPN(pa) - nbase];
ffffffffc02015fe:	000c3603          	ld	a2,0(s8)
ffffffffc0201602:	000cb503          	ld	a0,0(s9)
ffffffffc0201606:	0008bf03          	ld	t5,0(a7)
ffffffffc020160a:	8f91                	sub	a5,a5,a2
ffffffffc020160c:	00379613          	slli	a2,a5,0x3
ffffffffc0201610:	97b2                	add	a5,a5,a2
ffffffffc0201612:	078e                	slli	a5,a5,0x3
ffffffffc0201614:	97aa                	add	a5,a5,a0
ffffffffc0201616:	0aff1163          	bne	t5,a5,ffffffffc02016b8 <swap_init+0x382>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020161a:	6785                	lui	a5,0x1
ffffffffc020161c:	95be                	add	a1,a1,a5
ffffffffc020161e:	6795                	lui	a5,0x5
ffffffffc0201620:	0821                	addi	a6,a6,8
ffffffffc0201622:	08a1                	addi	a7,a7,8
ffffffffc0201624:	f8f59ee3          	bne	a1,a5,ffffffffc02015c0 <swap_init+0x28a>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0201628:	00004517          	auipc	a0,0x4
ffffffffc020162c:	dd850513          	addi	a0,a0,-552 # ffffffffc0205400 <commands+0xd08>
ffffffffc0201630:	a8bfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = sm->check_swap();
ffffffffc0201634:	000b3783          	ld	a5,0(s6)
ffffffffc0201638:	7f9c                	ld	a5,56(a5)
ffffffffc020163a:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc020163c:	1a051263          	bnez	a0,ffffffffc02017e0 <swap_init+0x4aa>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0201640:	00093503          	ld	a0,0(s2)
ffffffffc0201644:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201646:	0921                	addi	s2,s2,8
         free_pages(check_rp[i],1);
ffffffffc0201648:	4ba010ef          	jal	ra,ffffffffc0202b02 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020164c:	ff491ae3          	bne	s2,s4,ffffffffc0201640 <swap_init+0x30a>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0201650:	8556                	mv	a0,s5
ffffffffc0201652:	e08ff0ef          	jal	ra,ffffffffc0200c5a <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0201656:	77a2                	ld	a5,40(sp)
     free_list = free_list_store;
ffffffffc0201658:	01b4b423          	sd	s11,8(s1)
     nr_free = nr_free_store;
ffffffffc020165c:	c89c                	sw	a5,16(s1)
     free_list = free_list_store;
ffffffffc020165e:	7782                	ld	a5,32(sp)
ffffffffc0201660:	e09c                	sd	a5,0(s1)

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201662:	009d8a63          	beq	s11,s1,ffffffffc0201676 <swap_init+0x340>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0201666:	ff8da783          	lw	a5,-8(s11)
    return listelm->next;
ffffffffc020166a:	008dbd83          	ld	s11,8(s11)
ffffffffc020166e:	3d7d                	addiw	s10,s10,-1
ffffffffc0201670:	9c1d                	subw	s0,s0,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201672:	fe9d9ae3          	bne	s11,s1,ffffffffc0201666 <swap_init+0x330>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0201676:	8622                	mv	a2,s0
ffffffffc0201678:	85ea                	mv	a1,s10
ffffffffc020167a:	00004517          	auipc	a0,0x4
ffffffffc020167e:	db650513          	addi	a0,a0,-586 # ffffffffc0205430 <commands+0xd38>
ffffffffc0201682:	a39fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0201686:	00004517          	auipc	a0,0x4
ffffffffc020168a:	dca50513          	addi	a0,a0,-566 # ffffffffc0205450 <commands+0xd58>
ffffffffc020168e:	a2dfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0201692:	b9dd                	j	ffffffffc0201388 <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201694:	4901                	li	s2,0
ffffffffc0201696:	bba9                	j	ffffffffc02013f0 <swap_init+0xba>
        assert(PageProperty(p));
ffffffffc0201698:	00004697          	auipc	a3,0x4
ffffffffc020169c:	b4068693          	addi	a3,a3,-1216 # ffffffffc02051d8 <commands+0xae0>
ffffffffc02016a0:	00003617          	auipc	a2,0x3
ffffffffc02016a4:	78060613          	addi	a2,a2,1920 # ffffffffc0204e20 <commands+0x728>
ffffffffc02016a8:	0bb00593          	li	a1,187
ffffffffc02016ac:	00004517          	auipc	a0,0x4
ffffffffc02016b0:	b0450513          	addi	a0,a0,-1276 # ffffffffc02051b0 <commands+0xab8>
ffffffffc02016b4:	a4ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02016b8:	00004697          	auipc	a3,0x4
ffffffffc02016bc:	d2068693          	addi	a3,a3,-736 # ffffffffc02053d8 <commands+0xce0>
ffffffffc02016c0:	00003617          	auipc	a2,0x3
ffffffffc02016c4:	76060613          	addi	a2,a2,1888 # ffffffffc0204e20 <commands+0x728>
ffffffffc02016c8:	0fb00593          	li	a1,251
ffffffffc02016cc:	00004517          	auipc	a0,0x4
ffffffffc02016d0:	ae450513          	addi	a0,a0,-1308 # ffffffffc02051b0 <commands+0xab8>
ffffffffc02016d4:	a2ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02016d8:	00004617          	auipc	a2,0x4
ffffffffc02016dc:	cd860613          	addi	a2,a2,-808 # ffffffffc02053b0 <commands+0xcb8>
ffffffffc02016e0:	07000593          	li	a1,112
ffffffffc02016e4:	00004517          	auipc	a0,0x4
ffffffffc02016e8:	9ac50513          	addi	a0,a0,-1620 # ffffffffc0205090 <commands+0x998>
ffffffffc02016ec:	a17fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02016f0:	00004617          	auipc	a2,0x4
ffffffffc02016f4:	98060613          	addi	a2,a2,-1664 # ffffffffc0205070 <commands+0x978>
ffffffffc02016f8:	06500593          	li	a1,101
ffffffffc02016fc:	00004517          	auipc	a0,0x4
ffffffffc0201700:	99450513          	addi	a0,a0,-1644 # ffffffffc0205090 <commands+0x998>
ffffffffc0201704:	9fffe0ef          	jal	ra,ffffffffc0200102 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0201708:	00004697          	auipc	a3,0x4
ffffffffc020170c:	bd068693          	addi	a3,a3,-1072 # ffffffffc02052d8 <commands+0xbe0>
ffffffffc0201710:	00003617          	auipc	a2,0x3
ffffffffc0201714:	71060613          	addi	a2,a2,1808 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201718:	0dc00593          	li	a1,220
ffffffffc020171c:	00004517          	auipc	a0,0x4
ffffffffc0201720:	a9450513          	addi	a0,a0,-1388 # ffffffffc02051b0 <commands+0xab8>
ffffffffc0201724:	9dffe0ef          	jal	ra,ffffffffc0200102 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0201728:	00004697          	auipc	a3,0x4
ffffffffc020172c:	b9868693          	addi	a3,a3,-1128 # ffffffffc02052c0 <commands+0xbc8>
ffffffffc0201730:	00003617          	auipc	a2,0x3
ffffffffc0201734:	6f060613          	addi	a2,a2,1776 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201738:	0db00593          	li	a1,219
ffffffffc020173c:	00004517          	auipc	a0,0x4
ffffffffc0201740:	a7450513          	addi	a0,a0,-1420 # ffffffffc02051b0 <commands+0xab8>
ffffffffc0201744:	9bffe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0201748:	00004617          	auipc	a2,0x4
ffffffffc020174c:	a4860613          	addi	a2,a2,-1464 # ffffffffc0205190 <commands+0xa98>
ffffffffc0201750:	02700593          	li	a1,39
ffffffffc0201754:	00004517          	auipc	a0,0x4
ffffffffc0201758:	a5c50513          	addi	a0,a0,-1444 # ffffffffc02051b0 <commands+0xab8>
ffffffffc020175c:	9a7fe0ef          	jal	ra,ffffffffc0200102 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0201760:	00004697          	auipc	a3,0x4
ffffffffc0201764:	c3868693          	addi	a3,a3,-968 # ffffffffc0205398 <commands+0xca0>
ffffffffc0201768:	00003617          	auipc	a2,0x3
ffffffffc020176c:	6b860613          	addi	a2,a2,1720 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201770:	0fa00593          	li	a1,250
ffffffffc0201774:	00004517          	auipc	a0,0x4
ffffffffc0201778:	a3c50513          	addi	a0,a0,-1476 # ffffffffc02051b0 <commands+0xab8>
ffffffffc020177c:	987fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==4);
ffffffffc0201780:	00004697          	auipc	a3,0x4
ffffffffc0201784:	bf868693          	addi	a3,a3,-1032 # ffffffffc0205378 <commands+0xc80>
ffffffffc0201788:	00003617          	auipc	a2,0x3
ffffffffc020178c:	69860613          	addi	a2,a2,1688 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201790:	09e00593          	li	a1,158
ffffffffc0201794:	00004517          	auipc	a0,0x4
ffffffffc0201798:	a1c50513          	addi	a0,a0,-1508 # ffffffffc02051b0 <commands+0xab8>
ffffffffc020179c:	967fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==4);
ffffffffc02017a0:	00004697          	auipc	a3,0x4
ffffffffc02017a4:	bd868693          	addi	a3,a3,-1064 # ffffffffc0205378 <commands+0xc80>
ffffffffc02017a8:	00003617          	auipc	a2,0x3
ffffffffc02017ac:	67860613          	addi	a2,a2,1656 # ffffffffc0204e20 <commands+0x728>
ffffffffc02017b0:	0a000593          	li	a1,160
ffffffffc02017b4:	00004517          	auipc	a0,0x4
ffffffffc02017b8:	9fc50513          	addi	a0,a0,-1540 # ffffffffc02051b0 <commands+0xab8>
ffffffffc02017bc:	947fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert( nr_free == 0);         
ffffffffc02017c0:	00004697          	auipc	a3,0x4
ffffffffc02017c4:	bc868693          	addi	a3,a3,-1080 # ffffffffc0205388 <commands+0xc90>
ffffffffc02017c8:	00003617          	auipc	a2,0x3
ffffffffc02017cc:	65860613          	addi	a2,a2,1624 # ffffffffc0204e20 <commands+0x728>
ffffffffc02017d0:	0f200593          	li	a1,242
ffffffffc02017d4:	00004517          	auipc	a0,0x4
ffffffffc02017d8:	9dc50513          	addi	a0,a0,-1572 # ffffffffc02051b0 <commands+0xab8>
ffffffffc02017dc:	927fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(ret==0);
ffffffffc02017e0:	00004697          	auipc	a3,0x4
ffffffffc02017e4:	c4868693          	addi	a3,a3,-952 # ffffffffc0205428 <commands+0xd30>
ffffffffc02017e8:	00003617          	auipc	a2,0x3
ffffffffc02017ec:	63860613          	addi	a2,a2,1592 # ffffffffc0204e20 <commands+0x728>
ffffffffc02017f0:	10100593          	li	a1,257
ffffffffc02017f4:	00004517          	auipc	a0,0x4
ffffffffc02017f8:	9bc50513          	addi	a0,a0,-1604 # ffffffffc02051b0 <commands+0xab8>
ffffffffc02017fc:	907fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0201800:	00004697          	auipc	a3,0x4
ffffffffc0201804:	83068693          	addi	a3,a3,-2000 # ffffffffc0205030 <commands+0x938>
ffffffffc0201808:	00003617          	auipc	a2,0x3
ffffffffc020180c:	61860613          	addi	a2,a2,1560 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201810:	0cb00593          	li	a1,203
ffffffffc0201814:	00004517          	auipc	a0,0x4
ffffffffc0201818:	99c50513          	addi	a0,a0,-1636 # ffffffffc02051b0 <commands+0xab8>
ffffffffc020181c:	8e7fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(vma != NULL);
ffffffffc0201820:	00004697          	auipc	a3,0x4
ffffffffc0201824:	8b868693          	addi	a3,a3,-1864 # ffffffffc02050d8 <commands+0x9e0>
ffffffffc0201828:	00003617          	auipc	a2,0x3
ffffffffc020182c:	5f860613          	addi	a2,a2,1528 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201830:	0ce00593          	li	a1,206
ffffffffc0201834:	00004517          	auipc	a0,0x4
ffffffffc0201838:	97c50513          	addi	a0,a0,-1668 # ffffffffc02051b0 <commands+0xab8>
ffffffffc020183c:	8c7fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0201840:	00004697          	auipc	a3,0x4
ffffffffc0201844:	a4068693          	addi	a3,a3,-1472 # ffffffffc0205280 <commands+0xb88>
ffffffffc0201848:	00003617          	auipc	a2,0x3
ffffffffc020184c:	5d860613          	addi	a2,a2,1496 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201850:	0d600593          	li	a1,214
ffffffffc0201854:	00004517          	auipc	a0,0x4
ffffffffc0201858:	95c50513          	addi	a0,a0,-1700 # ffffffffc02051b0 <commands+0xab8>
ffffffffc020185c:	8a7fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(total == nr_free_pages());
ffffffffc0201860:	00004697          	auipc	a3,0x4
ffffffffc0201864:	98868693          	addi	a3,a3,-1656 # ffffffffc02051e8 <commands+0xaf0>
ffffffffc0201868:	00003617          	auipc	a2,0x3
ffffffffc020186c:	5b860613          	addi	a2,a2,1464 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201870:	0be00593          	li	a1,190
ffffffffc0201874:	00004517          	auipc	a0,0x4
ffffffffc0201878:	93c50513          	addi	a0,a0,-1732 # ffffffffc02051b0 <commands+0xab8>
ffffffffc020187c:	887fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==2);
ffffffffc0201880:	00004697          	auipc	a3,0x4
ffffffffc0201884:	ad868693          	addi	a3,a3,-1320 # ffffffffc0205358 <commands+0xc60>
ffffffffc0201888:	00003617          	auipc	a2,0x3
ffffffffc020188c:	59860613          	addi	a2,a2,1432 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201890:	09600593          	li	a1,150
ffffffffc0201894:	00004517          	auipc	a0,0x4
ffffffffc0201898:	91c50513          	addi	a0,a0,-1764 # ffffffffc02051b0 <commands+0xab8>
ffffffffc020189c:	867fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==2);
ffffffffc02018a0:	00004697          	auipc	a3,0x4
ffffffffc02018a4:	ab868693          	addi	a3,a3,-1352 # ffffffffc0205358 <commands+0xc60>
ffffffffc02018a8:	00003617          	auipc	a2,0x3
ffffffffc02018ac:	57860613          	addi	a2,a2,1400 # ffffffffc0204e20 <commands+0x728>
ffffffffc02018b0:	09800593          	li	a1,152
ffffffffc02018b4:	00004517          	auipc	a0,0x4
ffffffffc02018b8:	8fc50513          	addi	a0,a0,-1796 # ffffffffc02051b0 <commands+0xab8>
ffffffffc02018bc:	847fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==3);
ffffffffc02018c0:	00004697          	auipc	a3,0x4
ffffffffc02018c4:	aa868693          	addi	a3,a3,-1368 # ffffffffc0205368 <commands+0xc70>
ffffffffc02018c8:	00003617          	auipc	a2,0x3
ffffffffc02018cc:	55860613          	addi	a2,a2,1368 # ffffffffc0204e20 <commands+0x728>
ffffffffc02018d0:	09a00593          	li	a1,154
ffffffffc02018d4:	00004517          	auipc	a0,0x4
ffffffffc02018d8:	8dc50513          	addi	a0,a0,-1828 # ffffffffc02051b0 <commands+0xab8>
ffffffffc02018dc:	827fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==3);
ffffffffc02018e0:	00004697          	auipc	a3,0x4
ffffffffc02018e4:	a8868693          	addi	a3,a3,-1400 # ffffffffc0205368 <commands+0xc70>
ffffffffc02018e8:	00003617          	auipc	a2,0x3
ffffffffc02018ec:	53860613          	addi	a2,a2,1336 # ffffffffc0204e20 <commands+0x728>
ffffffffc02018f0:	09c00593          	li	a1,156
ffffffffc02018f4:	00004517          	auipc	a0,0x4
ffffffffc02018f8:	8bc50513          	addi	a0,a0,-1860 # ffffffffc02051b0 <commands+0xab8>
ffffffffc02018fc:	807fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==1);
ffffffffc0201900:	00004697          	auipc	a3,0x4
ffffffffc0201904:	a4868693          	addi	a3,a3,-1464 # ffffffffc0205348 <commands+0xc50>
ffffffffc0201908:	00003617          	auipc	a2,0x3
ffffffffc020190c:	51860613          	addi	a2,a2,1304 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201910:	09200593          	li	a1,146
ffffffffc0201914:	00004517          	auipc	a0,0x4
ffffffffc0201918:	89c50513          	addi	a0,a0,-1892 # ffffffffc02051b0 <commands+0xab8>
ffffffffc020191c:	fe6fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==1);
ffffffffc0201920:	00004697          	auipc	a3,0x4
ffffffffc0201924:	a2868693          	addi	a3,a3,-1496 # ffffffffc0205348 <commands+0xc50>
ffffffffc0201928:	00003617          	auipc	a2,0x3
ffffffffc020192c:	4f860613          	addi	a2,a2,1272 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201930:	09400593          	li	a1,148
ffffffffc0201934:	00004517          	auipc	a0,0x4
ffffffffc0201938:	87c50513          	addi	a0,a0,-1924 # ffffffffc02051b0 <commands+0xab8>
ffffffffc020193c:	fc6fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(mm != NULL);
ffffffffc0201940:	00003697          	auipc	a3,0x3
ffffffffc0201944:	7c068693          	addi	a3,a3,1984 # ffffffffc0205100 <commands+0xa08>
ffffffffc0201948:	00003617          	auipc	a2,0x3
ffffffffc020194c:	4d860613          	addi	a2,a2,1240 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201950:	0c300593          	li	a1,195
ffffffffc0201954:	00004517          	auipc	a0,0x4
ffffffffc0201958:	85c50513          	addi	a0,a0,-1956 # ffffffffc02051b0 <commands+0xab8>
ffffffffc020195c:	fa6fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0201960:	00004697          	auipc	a3,0x4
ffffffffc0201964:	8d068693          	addi	a3,a3,-1840 # ffffffffc0205230 <commands+0xb38>
ffffffffc0201968:	00003617          	auipc	a2,0x3
ffffffffc020196c:	4b860613          	addi	a2,a2,1208 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201970:	0c600593          	li	a1,198
ffffffffc0201974:	00004517          	auipc	a0,0x4
ffffffffc0201978:	83c50513          	addi	a0,a0,-1988 # ffffffffc02051b0 <commands+0xab8>
ffffffffc020197c:	f86fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0201980:	00004697          	auipc	a3,0x4
ffffffffc0201984:	97868693          	addi	a3,a3,-1672 # ffffffffc02052f8 <commands+0xc00>
ffffffffc0201988:	00003617          	auipc	a2,0x3
ffffffffc020198c:	49860613          	addi	a2,a2,1176 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201990:	0e900593          	li	a1,233
ffffffffc0201994:	00004517          	auipc	a0,0x4
ffffffffc0201998:	81c50513          	addi	a0,a0,-2020 # ffffffffc02051b0 <commands+0xab8>
ffffffffc020199c:	f66fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02019a0 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc02019a0:	00010797          	auipc	a5,0x10
ffffffffc02019a4:	b887b783          	ld	a5,-1144(a5) # ffffffffc0211528 <sm>
ffffffffc02019a8:	6b9c                	ld	a5,16(a5)
ffffffffc02019aa:	8782                	jr	a5

ffffffffc02019ac <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc02019ac:	00010797          	auipc	a5,0x10
ffffffffc02019b0:	b7c7b783          	ld	a5,-1156(a5) # ffffffffc0211528 <sm>
ffffffffc02019b4:	739c                	ld	a5,32(a5)
ffffffffc02019b6:	8782                	jr	a5

ffffffffc02019b8 <swap_out>:
{
ffffffffc02019b8:	711d                	addi	sp,sp,-96
ffffffffc02019ba:	ec86                	sd	ra,88(sp)
ffffffffc02019bc:	e8a2                	sd	s0,80(sp)
ffffffffc02019be:	e4a6                	sd	s1,72(sp)
ffffffffc02019c0:	e0ca                	sd	s2,64(sp)
ffffffffc02019c2:	fc4e                	sd	s3,56(sp)
ffffffffc02019c4:	f852                	sd	s4,48(sp)
ffffffffc02019c6:	f456                	sd	s5,40(sp)
ffffffffc02019c8:	f05a                	sd	s6,32(sp)
ffffffffc02019ca:	ec5e                	sd	s7,24(sp)
ffffffffc02019cc:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc02019ce:	cde9                	beqz	a1,ffffffffc0201aa8 <swap_out+0xf0>
ffffffffc02019d0:	8a2e                	mv	s4,a1
ffffffffc02019d2:	892a                	mv	s2,a0
ffffffffc02019d4:	8ab2                	mv	s5,a2
ffffffffc02019d6:	4401                	li	s0,0
ffffffffc02019d8:	00010997          	auipc	s3,0x10
ffffffffc02019dc:	b5098993          	addi	s3,s3,-1200 # ffffffffc0211528 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02019e0:	00004b17          	auipc	s6,0x4
ffffffffc02019e4:	af0b0b13          	addi	s6,s6,-1296 # ffffffffc02054d0 <commands+0xdd8>
                    cprintf("SWAP: failed to save\n");
ffffffffc02019e8:	00004b97          	auipc	s7,0x4
ffffffffc02019ec:	ad0b8b93          	addi	s7,s7,-1328 # ffffffffc02054b8 <commands+0xdc0>
ffffffffc02019f0:	a825                	j	ffffffffc0201a28 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02019f2:	67a2                	ld	a5,8(sp)
ffffffffc02019f4:	8626                	mv	a2,s1
ffffffffc02019f6:	85a2                	mv	a1,s0
ffffffffc02019f8:	63b4                	ld	a3,64(a5)
ffffffffc02019fa:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc02019fc:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02019fe:	82b1                	srli	a3,a3,0xc
ffffffffc0201a00:	0685                	addi	a3,a3,1
ffffffffc0201a02:	eb8fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0201a06:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0201a08:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0201a0a:	613c                	ld	a5,64(a0)
ffffffffc0201a0c:	83b1                	srli	a5,a5,0xc
ffffffffc0201a0e:	0785                	addi	a5,a5,1
ffffffffc0201a10:	07a2                	slli	a5,a5,0x8
ffffffffc0201a12:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0201a16:	0ec010ef          	jal	ra,ffffffffc0202b02 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0201a1a:	01893503          	ld	a0,24(s2)
ffffffffc0201a1e:	85a6                	mv	a1,s1
ffffffffc0201a20:	14a020ef          	jal	ra,ffffffffc0203b6a <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0201a24:	048a0d63          	beq	s4,s0,ffffffffc0201a7e <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0201a28:	0009b783          	ld	a5,0(s3)
ffffffffc0201a2c:	8656                	mv	a2,s5
ffffffffc0201a2e:	002c                	addi	a1,sp,8
ffffffffc0201a30:	7b9c                	ld	a5,48(a5)
ffffffffc0201a32:	854a                	mv	a0,s2
ffffffffc0201a34:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0201a36:	e12d                	bnez	a0,ffffffffc0201a98 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0201a38:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201a3a:	01893503          	ld	a0,24(s2)
ffffffffc0201a3e:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0201a40:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201a42:	85a6                	mv	a1,s1
ffffffffc0201a44:	138010ef          	jal	ra,ffffffffc0202b7c <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0201a48:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201a4a:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0201a4c:	8b85                	andi	a5,a5,1
ffffffffc0201a4e:	cfb9                	beqz	a5,ffffffffc0201aac <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0201a50:	65a2                	ld	a1,8(sp)
ffffffffc0201a52:	61bc                	ld	a5,64(a1)
ffffffffc0201a54:	83b1                	srli	a5,a5,0xc
ffffffffc0201a56:	0785                	addi	a5,a5,1
ffffffffc0201a58:	00879513          	slli	a0,a5,0x8
ffffffffc0201a5c:	440020ef          	jal	ra,ffffffffc0203e9c <swapfs_write>
ffffffffc0201a60:	d949                	beqz	a0,ffffffffc02019f2 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0201a62:	855e                	mv	a0,s7
ffffffffc0201a64:	e56fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0201a68:	0009b783          	ld	a5,0(s3)
ffffffffc0201a6c:	6622                	ld	a2,8(sp)
ffffffffc0201a6e:	4681                	li	a3,0
ffffffffc0201a70:	739c                	ld	a5,32(a5)
ffffffffc0201a72:	85a6                	mv	a1,s1
ffffffffc0201a74:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0201a76:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0201a78:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0201a7a:	fa8a17e3          	bne	s4,s0,ffffffffc0201a28 <swap_out+0x70>
}
ffffffffc0201a7e:	60e6                	ld	ra,88(sp)
ffffffffc0201a80:	8522                	mv	a0,s0
ffffffffc0201a82:	6446                	ld	s0,80(sp)
ffffffffc0201a84:	64a6                	ld	s1,72(sp)
ffffffffc0201a86:	6906                	ld	s2,64(sp)
ffffffffc0201a88:	79e2                	ld	s3,56(sp)
ffffffffc0201a8a:	7a42                	ld	s4,48(sp)
ffffffffc0201a8c:	7aa2                	ld	s5,40(sp)
ffffffffc0201a8e:	7b02                	ld	s6,32(sp)
ffffffffc0201a90:	6be2                	ld	s7,24(sp)
ffffffffc0201a92:	6c42                	ld	s8,16(sp)
ffffffffc0201a94:	6125                	addi	sp,sp,96
ffffffffc0201a96:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0201a98:	85a2                	mv	a1,s0
ffffffffc0201a9a:	00004517          	auipc	a0,0x4
ffffffffc0201a9e:	9d650513          	addi	a0,a0,-1578 # ffffffffc0205470 <commands+0xd78>
ffffffffc0201aa2:	e18fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
                  break;
ffffffffc0201aa6:	bfe1                	j	ffffffffc0201a7e <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0201aa8:	4401                	li	s0,0
ffffffffc0201aaa:	bfd1                	j	ffffffffc0201a7e <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0201aac:	00004697          	auipc	a3,0x4
ffffffffc0201ab0:	9f468693          	addi	a3,a3,-1548 # ffffffffc02054a0 <commands+0xda8>
ffffffffc0201ab4:	00003617          	auipc	a2,0x3
ffffffffc0201ab8:	36c60613          	addi	a2,a2,876 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201abc:	06700593          	li	a1,103
ffffffffc0201ac0:	00003517          	auipc	a0,0x3
ffffffffc0201ac4:	6f050513          	addi	a0,a0,1776 # ffffffffc02051b0 <commands+0xab8>
ffffffffc0201ac8:	e3afe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201acc <swap_in>:
{
ffffffffc0201acc:	7179                	addi	sp,sp,-48
ffffffffc0201ace:	e84a                	sd	s2,16(sp)
ffffffffc0201ad0:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0201ad2:	4505                	li	a0,1
{
ffffffffc0201ad4:	ec26                	sd	s1,24(sp)
ffffffffc0201ad6:	e44e                	sd	s3,8(sp)
ffffffffc0201ad8:	f406                	sd	ra,40(sp)
ffffffffc0201ada:	f022                	sd	s0,32(sp)
ffffffffc0201adc:	84ae                	mv	s1,a1
ffffffffc0201ade:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0201ae0:	791000ef          	jal	ra,ffffffffc0202a70 <alloc_pages>
     assert(result!=NULL);
ffffffffc0201ae4:	c129                	beqz	a0,ffffffffc0201b26 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0201ae6:	842a                	mv	s0,a0
ffffffffc0201ae8:	01893503          	ld	a0,24(s2)
ffffffffc0201aec:	4601                	li	a2,0
ffffffffc0201aee:	85a6                	mv	a1,s1
ffffffffc0201af0:	08c010ef          	jal	ra,ffffffffc0202b7c <get_pte>
ffffffffc0201af4:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0201af6:	6108                	ld	a0,0(a0)
ffffffffc0201af8:	85a2                	mv	a1,s0
ffffffffc0201afa:	308020ef          	jal	ra,ffffffffc0203e02 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0201afe:	00093583          	ld	a1,0(s2)
ffffffffc0201b02:	8626                	mv	a2,s1
ffffffffc0201b04:	00004517          	auipc	a0,0x4
ffffffffc0201b08:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0205520 <commands+0xe28>
ffffffffc0201b0c:	81a1                	srli	a1,a1,0x8
ffffffffc0201b0e:	dacfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0201b12:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0201b14:	0089b023          	sd	s0,0(s3)
}
ffffffffc0201b18:	7402                	ld	s0,32(sp)
ffffffffc0201b1a:	64e2                	ld	s1,24(sp)
ffffffffc0201b1c:	6942                	ld	s2,16(sp)
ffffffffc0201b1e:	69a2                	ld	s3,8(sp)
ffffffffc0201b20:	4501                	li	a0,0
ffffffffc0201b22:	6145                	addi	sp,sp,48
ffffffffc0201b24:	8082                	ret
     assert(result!=NULL);
ffffffffc0201b26:	00004697          	auipc	a3,0x4
ffffffffc0201b2a:	9ea68693          	addi	a3,a3,-1558 # ffffffffc0205510 <commands+0xe18>
ffffffffc0201b2e:	00003617          	auipc	a2,0x3
ffffffffc0201b32:	2f260613          	addi	a2,a2,754 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201b36:	07d00593          	li	a1,125
ffffffffc0201b3a:	00003517          	auipc	a0,0x3
ffffffffc0201b3e:	67650513          	addi	a0,a0,1654 # ffffffffc02051b0 <commands+0xab8>
ffffffffc0201b42:	dc0fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201b46 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0201b46:	0000f797          	auipc	a5,0xf
ffffffffc0201b4a:	58a78793          	addi	a5,a5,1418 # ffffffffc02110d0 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0201b4e:	f51c                	sd	a5,40(a0)
ffffffffc0201b50:	e79c                	sd	a5,8(a5)
ffffffffc0201b52:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0201b54:	4501                	li	a0,0
ffffffffc0201b56:	8082                	ret

ffffffffc0201b58 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0201b58:	4501                	li	a0,0
ffffffffc0201b5a:	8082                	ret

ffffffffc0201b5c <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0201b5c:	4501                	li	a0,0
ffffffffc0201b5e:	8082                	ret

ffffffffc0201b60 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0201b60:	4501                	li	a0,0
ffffffffc0201b62:	8082                	ret

ffffffffc0201b64 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0201b64:	711d                	addi	sp,sp,-96
ffffffffc0201b66:	fc4e                	sd	s3,56(sp)
ffffffffc0201b68:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0201b6a:	00004517          	auipc	a0,0x4
ffffffffc0201b6e:	9f650513          	addi	a0,a0,-1546 # ffffffffc0205560 <commands+0xe68>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201b72:	698d                	lui	s3,0x3
ffffffffc0201b74:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0201b76:	e0ca                	sd	s2,64(sp)
ffffffffc0201b78:	ec86                	sd	ra,88(sp)
ffffffffc0201b7a:	e8a2                	sd	s0,80(sp)
ffffffffc0201b7c:	e4a6                	sd	s1,72(sp)
ffffffffc0201b7e:	f456                	sd	s5,40(sp)
ffffffffc0201b80:	f05a                	sd	s6,32(sp)
ffffffffc0201b82:	ec5e                	sd	s7,24(sp)
ffffffffc0201b84:	e862                	sd	s8,16(sp)
ffffffffc0201b86:	e466                	sd	s9,8(sp)
ffffffffc0201b88:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0201b8a:	d30fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201b8e:	01498023          	sb	s4,0(s3) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0201b92:	00010917          	auipc	s2,0x10
ffffffffc0201b96:	98692903          	lw	s2,-1658(s2) # ffffffffc0211518 <pgfault_num>
ffffffffc0201b9a:	4791                	li	a5,4
ffffffffc0201b9c:	14f91e63          	bne	s2,a5,ffffffffc0201cf8 <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201ba0:	00004517          	auipc	a0,0x4
ffffffffc0201ba4:	a0050513          	addi	a0,a0,-1536 # ffffffffc02055a0 <commands+0xea8>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201ba8:	6a85                	lui	s5,0x1
ffffffffc0201baa:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201bac:	d0efe0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0201bb0:	00010417          	auipc	s0,0x10
ffffffffc0201bb4:	96840413          	addi	s0,s0,-1688 # ffffffffc0211518 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201bb8:	016a8023          	sb	s6,0(s5) # 1000 <kern_entry-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc0201bbc:	4004                	lw	s1,0(s0)
ffffffffc0201bbe:	2481                	sext.w	s1,s1
ffffffffc0201bc0:	2b249c63          	bne	s1,s2,ffffffffc0201e78 <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201bc4:	00004517          	auipc	a0,0x4
ffffffffc0201bc8:	a0450513          	addi	a0,a0,-1532 # ffffffffc02055c8 <commands+0xed0>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201bcc:	6b91                	lui	s7,0x4
ffffffffc0201bce:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201bd0:	ceafe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201bd4:	018b8023          	sb	s8,0(s7) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc0201bd8:	00042903          	lw	s2,0(s0)
ffffffffc0201bdc:	2901                	sext.w	s2,s2
ffffffffc0201bde:	26991d63          	bne	s2,s1,ffffffffc0201e58 <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201be2:	00004517          	auipc	a0,0x4
ffffffffc0201be6:	a0e50513          	addi	a0,a0,-1522 # ffffffffc02055f0 <commands+0xef8>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201bea:	6c89                	lui	s9,0x2
ffffffffc0201bec:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201bee:	cccfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201bf2:	01ac8023          	sb	s10,0(s9) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc0201bf6:	401c                	lw	a5,0(s0)
ffffffffc0201bf8:	2781                	sext.w	a5,a5
ffffffffc0201bfa:	23279f63          	bne	a5,s2,ffffffffc0201e38 <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0201bfe:	00004517          	auipc	a0,0x4
ffffffffc0201c02:	a1a50513          	addi	a0,a0,-1510 # ffffffffc0205618 <commands+0xf20>
ffffffffc0201c06:	cb4fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0201c0a:	6795                	lui	a5,0x5
ffffffffc0201c0c:	4739                	li	a4,14
ffffffffc0201c0e:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0201c12:	4004                	lw	s1,0(s0)
ffffffffc0201c14:	4795                	li	a5,5
ffffffffc0201c16:	2481                	sext.w	s1,s1
ffffffffc0201c18:	20f49063          	bne	s1,a5,ffffffffc0201e18 <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201c1c:	00004517          	auipc	a0,0x4
ffffffffc0201c20:	9d450513          	addi	a0,a0,-1580 # ffffffffc02055f0 <commands+0xef8>
ffffffffc0201c24:	c96fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201c28:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc0201c2c:	401c                	lw	a5,0(s0)
ffffffffc0201c2e:	2781                	sext.w	a5,a5
ffffffffc0201c30:	1c979463          	bne	a5,s1,ffffffffc0201df8 <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201c34:	00004517          	auipc	a0,0x4
ffffffffc0201c38:	96c50513          	addi	a0,a0,-1684 # ffffffffc02055a0 <commands+0xea8>
ffffffffc0201c3c:	c7efe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201c40:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0201c44:	401c                	lw	a5,0(s0)
ffffffffc0201c46:	4719                	li	a4,6
ffffffffc0201c48:	2781                	sext.w	a5,a5
ffffffffc0201c4a:	18e79763          	bne	a5,a4,ffffffffc0201dd8 <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201c4e:	00004517          	auipc	a0,0x4
ffffffffc0201c52:	9a250513          	addi	a0,a0,-1630 # ffffffffc02055f0 <commands+0xef8>
ffffffffc0201c56:	c64fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201c5a:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc0201c5e:	401c                	lw	a5,0(s0)
ffffffffc0201c60:	471d                	li	a4,7
ffffffffc0201c62:	2781                	sext.w	a5,a5
ffffffffc0201c64:	14e79a63          	bne	a5,a4,ffffffffc0201db8 <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0201c68:	00004517          	auipc	a0,0x4
ffffffffc0201c6c:	8f850513          	addi	a0,a0,-1800 # ffffffffc0205560 <commands+0xe68>
ffffffffc0201c70:	c4afe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201c74:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0201c78:	401c                	lw	a5,0(s0)
ffffffffc0201c7a:	4721                	li	a4,8
ffffffffc0201c7c:	2781                	sext.w	a5,a5
ffffffffc0201c7e:	10e79d63          	bne	a5,a4,ffffffffc0201d98 <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201c82:	00004517          	auipc	a0,0x4
ffffffffc0201c86:	94650513          	addi	a0,a0,-1722 # ffffffffc02055c8 <commands+0xed0>
ffffffffc0201c8a:	c30fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201c8e:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0201c92:	401c                	lw	a5,0(s0)
ffffffffc0201c94:	4725                	li	a4,9
ffffffffc0201c96:	2781                	sext.w	a5,a5
ffffffffc0201c98:	0ee79063          	bne	a5,a4,ffffffffc0201d78 <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0201c9c:	00004517          	auipc	a0,0x4
ffffffffc0201ca0:	97c50513          	addi	a0,a0,-1668 # ffffffffc0205618 <commands+0xf20>
ffffffffc0201ca4:	c16fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0201ca8:	6795                	lui	a5,0x5
ffffffffc0201caa:	4739                	li	a4,14
ffffffffc0201cac:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==10);
ffffffffc0201cb0:	4004                	lw	s1,0(s0)
ffffffffc0201cb2:	47a9                	li	a5,10
ffffffffc0201cb4:	2481                	sext.w	s1,s1
ffffffffc0201cb6:	0af49163          	bne	s1,a5,ffffffffc0201d58 <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201cba:	00004517          	auipc	a0,0x4
ffffffffc0201cbe:	8e650513          	addi	a0,a0,-1818 # ffffffffc02055a0 <commands+0xea8>
ffffffffc0201cc2:	bf8fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0201cc6:	6785                	lui	a5,0x1
ffffffffc0201cc8:	0007c783          	lbu	a5,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0201ccc:	06979663          	bne	a5,s1,ffffffffc0201d38 <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc0201cd0:	401c                	lw	a5,0(s0)
ffffffffc0201cd2:	472d                	li	a4,11
ffffffffc0201cd4:	2781                	sext.w	a5,a5
ffffffffc0201cd6:	04e79163          	bne	a5,a4,ffffffffc0201d18 <_fifo_check_swap+0x1b4>
}
ffffffffc0201cda:	60e6                	ld	ra,88(sp)
ffffffffc0201cdc:	6446                	ld	s0,80(sp)
ffffffffc0201cde:	64a6                	ld	s1,72(sp)
ffffffffc0201ce0:	6906                	ld	s2,64(sp)
ffffffffc0201ce2:	79e2                	ld	s3,56(sp)
ffffffffc0201ce4:	7a42                	ld	s4,48(sp)
ffffffffc0201ce6:	7aa2                	ld	s5,40(sp)
ffffffffc0201ce8:	7b02                	ld	s6,32(sp)
ffffffffc0201cea:	6be2                	ld	s7,24(sp)
ffffffffc0201cec:	6c42                	ld	s8,16(sp)
ffffffffc0201cee:	6ca2                	ld	s9,8(sp)
ffffffffc0201cf0:	6d02                	ld	s10,0(sp)
ffffffffc0201cf2:	4501                	li	a0,0
ffffffffc0201cf4:	6125                	addi	sp,sp,96
ffffffffc0201cf6:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0201cf8:	00003697          	auipc	a3,0x3
ffffffffc0201cfc:	68068693          	addi	a3,a3,1664 # ffffffffc0205378 <commands+0xc80>
ffffffffc0201d00:	00003617          	auipc	a2,0x3
ffffffffc0201d04:	12060613          	addi	a2,a2,288 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201d08:	05500593          	li	a1,85
ffffffffc0201d0c:	00004517          	auipc	a0,0x4
ffffffffc0201d10:	87c50513          	addi	a0,a0,-1924 # ffffffffc0205588 <commands+0xe90>
ffffffffc0201d14:	beefe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==11);
ffffffffc0201d18:	00004697          	auipc	a3,0x4
ffffffffc0201d1c:	9b068693          	addi	a3,a3,-1616 # ffffffffc02056c8 <commands+0xfd0>
ffffffffc0201d20:	00003617          	auipc	a2,0x3
ffffffffc0201d24:	10060613          	addi	a2,a2,256 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201d28:	07700593          	li	a1,119
ffffffffc0201d2c:	00004517          	auipc	a0,0x4
ffffffffc0201d30:	85c50513          	addi	a0,a0,-1956 # ffffffffc0205588 <commands+0xe90>
ffffffffc0201d34:	bcefe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0201d38:	00004697          	auipc	a3,0x4
ffffffffc0201d3c:	96868693          	addi	a3,a3,-1688 # ffffffffc02056a0 <commands+0xfa8>
ffffffffc0201d40:	00003617          	auipc	a2,0x3
ffffffffc0201d44:	0e060613          	addi	a2,a2,224 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201d48:	07500593          	li	a1,117
ffffffffc0201d4c:	00004517          	auipc	a0,0x4
ffffffffc0201d50:	83c50513          	addi	a0,a0,-1988 # ffffffffc0205588 <commands+0xe90>
ffffffffc0201d54:	baefe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==10);
ffffffffc0201d58:	00004697          	auipc	a3,0x4
ffffffffc0201d5c:	93868693          	addi	a3,a3,-1736 # ffffffffc0205690 <commands+0xf98>
ffffffffc0201d60:	00003617          	auipc	a2,0x3
ffffffffc0201d64:	0c060613          	addi	a2,a2,192 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201d68:	07300593          	li	a1,115
ffffffffc0201d6c:	00004517          	auipc	a0,0x4
ffffffffc0201d70:	81c50513          	addi	a0,a0,-2020 # ffffffffc0205588 <commands+0xe90>
ffffffffc0201d74:	b8efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==9);
ffffffffc0201d78:	00004697          	auipc	a3,0x4
ffffffffc0201d7c:	90868693          	addi	a3,a3,-1784 # ffffffffc0205680 <commands+0xf88>
ffffffffc0201d80:	00003617          	auipc	a2,0x3
ffffffffc0201d84:	0a060613          	addi	a2,a2,160 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201d88:	07000593          	li	a1,112
ffffffffc0201d8c:	00003517          	auipc	a0,0x3
ffffffffc0201d90:	7fc50513          	addi	a0,a0,2044 # ffffffffc0205588 <commands+0xe90>
ffffffffc0201d94:	b6efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==8);
ffffffffc0201d98:	00004697          	auipc	a3,0x4
ffffffffc0201d9c:	8d868693          	addi	a3,a3,-1832 # ffffffffc0205670 <commands+0xf78>
ffffffffc0201da0:	00003617          	auipc	a2,0x3
ffffffffc0201da4:	08060613          	addi	a2,a2,128 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201da8:	06d00593          	li	a1,109
ffffffffc0201dac:	00003517          	auipc	a0,0x3
ffffffffc0201db0:	7dc50513          	addi	a0,a0,2012 # ffffffffc0205588 <commands+0xe90>
ffffffffc0201db4:	b4efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==7);
ffffffffc0201db8:	00004697          	auipc	a3,0x4
ffffffffc0201dbc:	8a868693          	addi	a3,a3,-1880 # ffffffffc0205660 <commands+0xf68>
ffffffffc0201dc0:	00003617          	auipc	a2,0x3
ffffffffc0201dc4:	06060613          	addi	a2,a2,96 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201dc8:	06a00593          	li	a1,106
ffffffffc0201dcc:	00003517          	auipc	a0,0x3
ffffffffc0201dd0:	7bc50513          	addi	a0,a0,1980 # ffffffffc0205588 <commands+0xe90>
ffffffffc0201dd4:	b2efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==6);
ffffffffc0201dd8:	00004697          	auipc	a3,0x4
ffffffffc0201ddc:	87868693          	addi	a3,a3,-1928 # ffffffffc0205650 <commands+0xf58>
ffffffffc0201de0:	00003617          	auipc	a2,0x3
ffffffffc0201de4:	04060613          	addi	a2,a2,64 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201de8:	06700593          	li	a1,103
ffffffffc0201dec:	00003517          	auipc	a0,0x3
ffffffffc0201df0:	79c50513          	addi	a0,a0,1948 # ffffffffc0205588 <commands+0xe90>
ffffffffc0201df4:	b0efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc0201df8:	00004697          	auipc	a3,0x4
ffffffffc0201dfc:	84868693          	addi	a3,a3,-1976 # ffffffffc0205640 <commands+0xf48>
ffffffffc0201e00:	00003617          	auipc	a2,0x3
ffffffffc0201e04:	02060613          	addi	a2,a2,32 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201e08:	06400593          	li	a1,100
ffffffffc0201e0c:	00003517          	auipc	a0,0x3
ffffffffc0201e10:	77c50513          	addi	a0,a0,1916 # ffffffffc0205588 <commands+0xe90>
ffffffffc0201e14:	aeefe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc0201e18:	00004697          	auipc	a3,0x4
ffffffffc0201e1c:	82868693          	addi	a3,a3,-2008 # ffffffffc0205640 <commands+0xf48>
ffffffffc0201e20:	00003617          	auipc	a2,0x3
ffffffffc0201e24:	00060613          	mv	a2,a2
ffffffffc0201e28:	06100593          	li	a1,97
ffffffffc0201e2c:	00003517          	auipc	a0,0x3
ffffffffc0201e30:	75c50513          	addi	a0,a0,1884 # ffffffffc0205588 <commands+0xe90>
ffffffffc0201e34:	acefe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==4);
ffffffffc0201e38:	00003697          	auipc	a3,0x3
ffffffffc0201e3c:	54068693          	addi	a3,a3,1344 # ffffffffc0205378 <commands+0xc80>
ffffffffc0201e40:	00003617          	auipc	a2,0x3
ffffffffc0201e44:	fe060613          	addi	a2,a2,-32 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201e48:	05e00593          	li	a1,94
ffffffffc0201e4c:	00003517          	auipc	a0,0x3
ffffffffc0201e50:	73c50513          	addi	a0,a0,1852 # ffffffffc0205588 <commands+0xe90>
ffffffffc0201e54:	aaefe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==4);
ffffffffc0201e58:	00003697          	auipc	a3,0x3
ffffffffc0201e5c:	52068693          	addi	a3,a3,1312 # ffffffffc0205378 <commands+0xc80>
ffffffffc0201e60:	00003617          	auipc	a2,0x3
ffffffffc0201e64:	fc060613          	addi	a2,a2,-64 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201e68:	05b00593          	li	a1,91
ffffffffc0201e6c:	00003517          	auipc	a0,0x3
ffffffffc0201e70:	71c50513          	addi	a0,a0,1820 # ffffffffc0205588 <commands+0xe90>
ffffffffc0201e74:	a8efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==4);
ffffffffc0201e78:	00003697          	auipc	a3,0x3
ffffffffc0201e7c:	50068693          	addi	a3,a3,1280 # ffffffffc0205378 <commands+0xc80>
ffffffffc0201e80:	00003617          	auipc	a2,0x3
ffffffffc0201e84:	fa060613          	addi	a2,a2,-96 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201e88:	05800593          	li	a1,88
ffffffffc0201e8c:	00003517          	auipc	a0,0x3
ffffffffc0201e90:	6fc50513          	addi	a0,a0,1788 # ffffffffc0205588 <commands+0xe90>
ffffffffc0201e94:	a6efe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201e98 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0201e98:	751c                	ld	a5,40(a0)
{
ffffffffc0201e9a:	1101                	addi	sp,sp,-32
ffffffffc0201e9c:	ec06                	sd	ra,24(sp)
ffffffffc0201e9e:	e822                	sd	s0,16(sp)
ffffffffc0201ea0:	e426                	sd	s1,8(sp)
         assert(head != NULL);
ffffffffc0201ea2:	c3b5                	beqz	a5,ffffffffc0201f06 <_fifo_swap_out_victim+0x6e>
     assert(in_tick==0);
ffffffffc0201ea4:	e229                	bnez	a2,ffffffffc0201ee6 <_fifo_swap_out_victim+0x4e>
    return listelm->prev;
ffffffffc0201ea6:	6380                	ld	s0,0(a5)
ffffffffc0201ea8:	84ae                	mv	s1,a1
    if (entry != head) {
ffffffffc0201eaa:	02878663          	beq	a5,s0,ffffffffc0201ed6 <_fifo_swap_out_victim+0x3e>
        cprintf("curr_ptr %p\n", entry);
ffffffffc0201eae:	85a2                	mv	a1,s0
ffffffffc0201eb0:	00004517          	auipc	a0,0x4
ffffffffc0201eb4:	84850513          	addi	a0,a0,-1976 # ffffffffc02056f8 <commands+0x1000>
ffffffffc0201eb8:	a02fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    __list_del(listelm->prev, listelm->next);
ffffffffc0201ebc:	6018                	ld	a4,0(s0)
ffffffffc0201ebe:	641c                	ld	a5,8(s0)
        *ptr_page = le2page(entry, pra_page_link);
ffffffffc0201ec0:	fd040413          	addi	s0,s0,-48
}
ffffffffc0201ec4:	60e2                	ld	ra,24(sp)
    prev->next = next;
ffffffffc0201ec6:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201ec8:	e398                	sd	a4,0(a5)
        *ptr_page = le2page(entry, pra_page_link);
ffffffffc0201eca:	e080                	sd	s0,0(s1)
}
ffffffffc0201ecc:	6442                	ld	s0,16(sp)
ffffffffc0201ece:	64a2                	ld	s1,8(sp)
ffffffffc0201ed0:	4501                	li	a0,0
ffffffffc0201ed2:	6105                	addi	sp,sp,32
ffffffffc0201ed4:	8082                	ret
ffffffffc0201ed6:	60e2                	ld	ra,24(sp)
ffffffffc0201ed8:	6442                	ld	s0,16(sp)
        *ptr_page = NULL;
ffffffffc0201eda:	0005b023          	sd	zero,0(a1) # 1000 <kern_entry-0xffffffffc01ff000>
}
ffffffffc0201ede:	64a2                	ld	s1,8(sp)
ffffffffc0201ee0:	4501                	li	a0,0
ffffffffc0201ee2:	6105                	addi	sp,sp,32
ffffffffc0201ee4:	8082                	ret
     assert(in_tick==0);
ffffffffc0201ee6:	00004697          	auipc	a3,0x4
ffffffffc0201eea:	80268693          	addi	a3,a3,-2046 # ffffffffc02056e8 <commands+0xff0>
ffffffffc0201eee:	00003617          	auipc	a2,0x3
ffffffffc0201ef2:	f3260613          	addi	a2,a2,-206 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201ef6:	04200593          	li	a1,66
ffffffffc0201efa:	00003517          	auipc	a0,0x3
ffffffffc0201efe:	68e50513          	addi	a0,a0,1678 # ffffffffc0205588 <commands+0xe90>
ffffffffc0201f02:	a00fe0ef          	jal	ra,ffffffffc0200102 <__panic>
         assert(head != NULL);
ffffffffc0201f06:	00003697          	auipc	a3,0x3
ffffffffc0201f0a:	7d268693          	addi	a3,a3,2002 # ffffffffc02056d8 <commands+0xfe0>
ffffffffc0201f0e:	00003617          	auipc	a2,0x3
ffffffffc0201f12:	f1260613          	addi	a2,a2,-238 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201f16:	04100593          	li	a1,65
ffffffffc0201f1a:	00003517          	auipc	a0,0x3
ffffffffc0201f1e:	66e50513          	addi	a0,a0,1646 # ffffffffc0205588 <commands+0xe90>
ffffffffc0201f22:	9e0fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201f26 <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0201f26:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0201f28:	cb91                	beqz	a5,ffffffffc0201f3c <_fifo_map_swappable+0x16>
    __list_add(elm, listelm, listelm->next);
ffffffffc0201f2a:	6794                	ld	a3,8(a5)
ffffffffc0201f2c:	03060713          	addi	a4,a2,48
}
ffffffffc0201f30:	4501                	li	a0,0
    prev->next = next->prev = elm;
ffffffffc0201f32:	e298                	sd	a4,0(a3)
ffffffffc0201f34:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201f36:	fe14                	sd	a3,56(a2)
    elm->prev = prev;
ffffffffc0201f38:	fa1c                	sd	a5,48(a2)
ffffffffc0201f3a:	8082                	ret
{
ffffffffc0201f3c:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0201f3e:	00003697          	auipc	a3,0x3
ffffffffc0201f42:	7ca68693          	addi	a3,a3,1994 # ffffffffc0205708 <commands+0x1010>
ffffffffc0201f46:	00003617          	auipc	a2,0x3
ffffffffc0201f4a:	eda60613          	addi	a2,a2,-294 # ffffffffc0204e20 <commands+0x728>
ffffffffc0201f4e:	03200593          	li	a1,50
ffffffffc0201f52:	00003517          	auipc	a0,0x3
ffffffffc0201f56:	63650513          	addi	a0,a0,1590 # ffffffffc0205588 <commands+0xe90>
{
ffffffffc0201f5a:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0201f5c:	9a6fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201f60 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0201f60:	0000f797          	auipc	a5,0xf
ffffffffc0201f64:	18078793          	addi	a5,a5,384 # ffffffffc02110e0 <free_area>
ffffffffc0201f68:	e79c                	sd	a5,8(a5)
ffffffffc0201f6a:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0201f6c:	0007a823          	sw	zero,16(a5)
}
ffffffffc0201f70:	8082                	ret

ffffffffc0201f72 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0201f72:	0000f517          	auipc	a0,0xf
ffffffffc0201f76:	17e56503          	lwu	a0,382(a0) # ffffffffc02110f0 <free_area+0x10>
ffffffffc0201f7a:	8082                	ret

ffffffffc0201f7c <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0201f7c:	715d                	addi	sp,sp,-80
ffffffffc0201f7e:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0201f80:	0000f417          	auipc	s0,0xf
ffffffffc0201f84:	16040413          	addi	s0,s0,352 # ffffffffc02110e0 <free_area>
ffffffffc0201f88:	641c                	ld	a5,8(s0)
ffffffffc0201f8a:	e486                	sd	ra,72(sp)
ffffffffc0201f8c:	fc26                	sd	s1,56(sp)
ffffffffc0201f8e:	f84a                	sd	s2,48(sp)
ffffffffc0201f90:	f44e                	sd	s3,40(sp)
ffffffffc0201f92:	f052                	sd	s4,32(sp)
ffffffffc0201f94:	ec56                	sd	s5,24(sp)
ffffffffc0201f96:	e85a                	sd	s6,16(sp)
ffffffffc0201f98:	e45e                	sd	s7,8(sp)
ffffffffc0201f9a:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201f9c:	2c878763          	beq	a5,s0,ffffffffc020226a <default_check+0x2ee>
    int count = 0, total = 0;
ffffffffc0201fa0:	4481                	li	s1,0
ffffffffc0201fa2:	4901                	li	s2,0
ffffffffc0201fa4:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0201fa8:	8b09                	andi	a4,a4,2
ffffffffc0201faa:	2c070463          	beqz	a4,ffffffffc0202272 <default_check+0x2f6>
        count ++, total += p->property;
ffffffffc0201fae:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201fb2:	679c                	ld	a5,8(a5)
ffffffffc0201fb4:	2905                	addiw	s2,s2,1
ffffffffc0201fb6:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201fb8:	fe8796e3          	bne	a5,s0,ffffffffc0201fa4 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0201fbc:	89a6                	mv	s3,s1
ffffffffc0201fbe:	385000ef          	jal	ra,ffffffffc0202b42 <nr_free_pages>
ffffffffc0201fc2:	71351863          	bne	a0,s3,ffffffffc02026d2 <default_check+0x756>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201fc6:	4505                	li	a0,1
ffffffffc0201fc8:	2a9000ef          	jal	ra,ffffffffc0202a70 <alloc_pages>
ffffffffc0201fcc:	8a2a                	mv	s4,a0
ffffffffc0201fce:	44050263          	beqz	a0,ffffffffc0202412 <default_check+0x496>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201fd2:	4505                	li	a0,1
ffffffffc0201fd4:	29d000ef          	jal	ra,ffffffffc0202a70 <alloc_pages>
ffffffffc0201fd8:	89aa                	mv	s3,a0
ffffffffc0201fda:	70050c63          	beqz	a0,ffffffffc02026f2 <default_check+0x776>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201fde:	4505                	li	a0,1
ffffffffc0201fe0:	291000ef          	jal	ra,ffffffffc0202a70 <alloc_pages>
ffffffffc0201fe4:	8aaa                	mv	s5,a0
ffffffffc0201fe6:	4a050663          	beqz	a0,ffffffffc0202492 <default_check+0x516>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201fea:	2b3a0463          	beq	s4,s3,ffffffffc0202292 <default_check+0x316>
ffffffffc0201fee:	2aaa0263          	beq	s4,a0,ffffffffc0202292 <default_check+0x316>
ffffffffc0201ff2:	2aa98063          	beq	s3,a0,ffffffffc0202292 <default_check+0x316>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201ff6:	000a2783          	lw	a5,0(s4)
ffffffffc0201ffa:	2a079c63          	bnez	a5,ffffffffc02022b2 <default_check+0x336>
ffffffffc0201ffe:	0009a783          	lw	a5,0(s3)
ffffffffc0202002:	2a079863          	bnez	a5,ffffffffc02022b2 <default_check+0x336>
ffffffffc0202006:	411c                	lw	a5,0(a0)
ffffffffc0202008:	2a079563          	bnez	a5,ffffffffc02022b2 <default_check+0x336>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020200c:	0000f797          	auipc	a5,0xf
ffffffffc0202010:	5447b783          	ld	a5,1348(a5) # ffffffffc0211550 <pages>
ffffffffc0202014:	40fa0733          	sub	a4,s4,a5
ffffffffc0202018:	870d                	srai	a4,a4,0x3
ffffffffc020201a:	00004597          	auipc	a1,0x4
ffffffffc020201e:	35e5b583          	ld	a1,862(a1) # ffffffffc0206378 <error_string+0x38>
ffffffffc0202022:	02b70733          	mul	a4,a4,a1
ffffffffc0202026:	00004617          	auipc	a2,0x4
ffffffffc020202a:	35a63603          	ld	a2,858(a2) # ffffffffc0206380 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020202e:	0000f697          	auipc	a3,0xf
ffffffffc0202032:	51a6b683          	ld	a3,1306(a3) # ffffffffc0211548 <npage>
ffffffffc0202036:	06b2                	slli	a3,a3,0xc
ffffffffc0202038:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020203a:	0732                	slli	a4,a4,0xc
ffffffffc020203c:	28d77b63          	bgeu	a4,a3,ffffffffc02022d2 <default_check+0x356>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202040:	40f98733          	sub	a4,s3,a5
ffffffffc0202044:	870d                	srai	a4,a4,0x3
ffffffffc0202046:	02b70733          	mul	a4,a4,a1
ffffffffc020204a:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020204c:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020204e:	4cd77263          	bgeu	a4,a3,ffffffffc0202512 <default_check+0x596>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202052:	40f507b3          	sub	a5,a0,a5
ffffffffc0202056:	878d                	srai	a5,a5,0x3
ffffffffc0202058:	02b787b3          	mul	a5,a5,a1
ffffffffc020205c:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020205e:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202060:	30d7f963          	bgeu	a5,a3,ffffffffc0202372 <default_check+0x3f6>
    assert(alloc_page() == NULL);
ffffffffc0202064:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202066:	00043c03          	ld	s8,0(s0)
ffffffffc020206a:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc020206e:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0202072:	e400                	sd	s0,8(s0)
ffffffffc0202074:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0202076:	0000f797          	auipc	a5,0xf
ffffffffc020207a:	0607ad23          	sw	zero,122(a5) # ffffffffc02110f0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc020207e:	1f3000ef          	jal	ra,ffffffffc0202a70 <alloc_pages>
ffffffffc0202082:	2c051863          	bnez	a0,ffffffffc0202352 <default_check+0x3d6>
    free_page(p0);
ffffffffc0202086:	4585                	li	a1,1
ffffffffc0202088:	8552                	mv	a0,s4
ffffffffc020208a:	279000ef          	jal	ra,ffffffffc0202b02 <free_pages>
    free_page(p1);
ffffffffc020208e:	4585                	li	a1,1
ffffffffc0202090:	854e                	mv	a0,s3
ffffffffc0202092:	271000ef          	jal	ra,ffffffffc0202b02 <free_pages>
    free_page(p2);
ffffffffc0202096:	4585                	li	a1,1
ffffffffc0202098:	8556                	mv	a0,s5
ffffffffc020209a:	269000ef          	jal	ra,ffffffffc0202b02 <free_pages>
    assert(nr_free == 3);
ffffffffc020209e:	4818                	lw	a4,16(s0)
ffffffffc02020a0:	478d                	li	a5,3
ffffffffc02020a2:	28f71863          	bne	a4,a5,ffffffffc0202332 <default_check+0x3b6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02020a6:	4505                	li	a0,1
ffffffffc02020a8:	1c9000ef          	jal	ra,ffffffffc0202a70 <alloc_pages>
ffffffffc02020ac:	89aa                	mv	s3,a0
ffffffffc02020ae:	26050263          	beqz	a0,ffffffffc0202312 <default_check+0x396>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02020b2:	4505                	li	a0,1
ffffffffc02020b4:	1bd000ef          	jal	ra,ffffffffc0202a70 <alloc_pages>
ffffffffc02020b8:	8aaa                	mv	s5,a0
ffffffffc02020ba:	3a050c63          	beqz	a0,ffffffffc0202472 <default_check+0x4f6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02020be:	4505                	li	a0,1
ffffffffc02020c0:	1b1000ef          	jal	ra,ffffffffc0202a70 <alloc_pages>
ffffffffc02020c4:	8a2a                	mv	s4,a0
ffffffffc02020c6:	38050663          	beqz	a0,ffffffffc0202452 <default_check+0x4d6>
    assert(alloc_page() == NULL);
ffffffffc02020ca:	4505                	li	a0,1
ffffffffc02020cc:	1a5000ef          	jal	ra,ffffffffc0202a70 <alloc_pages>
ffffffffc02020d0:	36051163          	bnez	a0,ffffffffc0202432 <default_check+0x4b6>
    free_page(p0);
ffffffffc02020d4:	4585                	li	a1,1
ffffffffc02020d6:	854e                	mv	a0,s3
ffffffffc02020d8:	22b000ef          	jal	ra,ffffffffc0202b02 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc02020dc:	641c                	ld	a5,8(s0)
ffffffffc02020de:	20878a63          	beq	a5,s0,ffffffffc02022f2 <default_check+0x376>
    assert((p = alloc_page()) == p0);
ffffffffc02020e2:	4505                	li	a0,1
ffffffffc02020e4:	18d000ef          	jal	ra,ffffffffc0202a70 <alloc_pages>
ffffffffc02020e8:	30a99563          	bne	s3,a0,ffffffffc02023f2 <default_check+0x476>
    assert(alloc_page() == NULL);
ffffffffc02020ec:	4505                	li	a0,1
ffffffffc02020ee:	183000ef          	jal	ra,ffffffffc0202a70 <alloc_pages>
ffffffffc02020f2:	2e051063          	bnez	a0,ffffffffc02023d2 <default_check+0x456>
    assert(nr_free == 0);
ffffffffc02020f6:	481c                	lw	a5,16(s0)
ffffffffc02020f8:	2a079d63          	bnez	a5,ffffffffc02023b2 <default_check+0x436>
    free_page(p);
ffffffffc02020fc:	854e                	mv	a0,s3
ffffffffc02020fe:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0202100:	01843023          	sd	s8,0(s0)
ffffffffc0202104:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0202108:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc020210c:	1f7000ef          	jal	ra,ffffffffc0202b02 <free_pages>
    free_page(p1);
ffffffffc0202110:	4585                	li	a1,1
ffffffffc0202112:	8556                	mv	a0,s5
ffffffffc0202114:	1ef000ef          	jal	ra,ffffffffc0202b02 <free_pages>
    free_page(p2);
ffffffffc0202118:	4585                	li	a1,1
ffffffffc020211a:	8552                	mv	a0,s4
ffffffffc020211c:	1e7000ef          	jal	ra,ffffffffc0202b02 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0202120:	4515                	li	a0,5
ffffffffc0202122:	14f000ef          	jal	ra,ffffffffc0202a70 <alloc_pages>
ffffffffc0202126:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0202128:	26050563          	beqz	a0,ffffffffc0202392 <default_check+0x416>
ffffffffc020212c:	651c                	ld	a5,8(a0)
ffffffffc020212e:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0202130:	8b85                	andi	a5,a5,1
ffffffffc0202132:	54079063          	bnez	a5,ffffffffc0202672 <default_check+0x6f6>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0202136:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202138:	00043b03          	ld	s6,0(s0)
ffffffffc020213c:	00843a83          	ld	s5,8(s0)
ffffffffc0202140:	e000                	sd	s0,0(s0)
ffffffffc0202142:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0202144:	12d000ef          	jal	ra,ffffffffc0202a70 <alloc_pages>
ffffffffc0202148:	50051563          	bnez	a0,ffffffffc0202652 <default_check+0x6d6>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc020214c:	09098a13          	addi	s4,s3,144
ffffffffc0202150:	8552                	mv	a0,s4
ffffffffc0202152:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0202154:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0202158:	0000f797          	auipc	a5,0xf
ffffffffc020215c:	f807ac23          	sw	zero,-104(a5) # ffffffffc02110f0 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0202160:	1a3000ef          	jal	ra,ffffffffc0202b02 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0202164:	4511                	li	a0,4
ffffffffc0202166:	10b000ef          	jal	ra,ffffffffc0202a70 <alloc_pages>
ffffffffc020216a:	4c051463          	bnez	a0,ffffffffc0202632 <default_check+0x6b6>
ffffffffc020216e:	0989b783          	ld	a5,152(s3)
ffffffffc0202172:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202174:	8b85                	andi	a5,a5,1
ffffffffc0202176:	48078e63          	beqz	a5,ffffffffc0202612 <default_check+0x696>
ffffffffc020217a:	0a89a703          	lw	a4,168(s3)
ffffffffc020217e:	478d                	li	a5,3
ffffffffc0202180:	48f71963          	bne	a4,a5,ffffffffc0202612 <default_check+0x696>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202184:	450d                	li	a0,3
ffffffffc0202186:	0eb000ef          	jal	ra,ffffffffc0202a70 <alloc_pages>
ffffffffc020218a:	8c2a                	mv	s8,a0
ffffffffc020218c:	46050363          	beqz	a0,ffffffffc02025f2 <default_check+0x676>
    assert(alloc_page() == NULL);
ffffffffc0202190:	4505                	li	a0,1
ffffffffc0202192:	0df000ef          	jal	ra,ffffffffc0202a70 <alloc_pages>
ffffffffc0202196:	42051e63          	bnez	a0,ffffffffc02025d2 <default_check+0x656>
    assert(p0 + 2 == p1);
ffffffffc020219a:	418a1c63          	bne	s4,s8,ffffffffc02025b2 <default_check+0x636>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc020219e:	4585                	li	a1,1
ffffffffc02021a0:	854e                	mv	a0,s3
ffffffffc02021a2:	161000ef          	jal	ra,ffffffffc0202b02 <free_pages>
    free_pages(p1, 3);
ffffffffc02021a6:	458d                	li	a1,3
ffffffffc02021a8:	8552                	mv	a0,s4
ffffffffc02021aa:	159000ef          	jal	ra,ffffffffc0202b02 <free_pages>
ffffffffc02021ae:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc02021b2:	04898c13          	addi	s8,s3,72
ffffffffc02021b6:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02021b8:	8b85                	andi	a5,a5,1
ffffffffc02021ba:	3c078c63          	beqz	a5,ffffffffc0202592 <default_check+0x616>
ffffffffc02021be:	0189a703          	lw	a4,24(s3)
ffffffffc02021c2:	4785                	li	a5,1
ffffffffc02021c4:	3cf71763          	bne	a4,a5,ffffffffc0202592 <default_check+0x616>
ffffffffc02021c8:	008a3783          	ld	a5,8(s4)
ffffffffc02021cc:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02021ce:	8b85                	andi	a5,a5,1
ffffffffc02021d0:	3a078163          	beqz	a5,ffffffffc0202572 <default_check+0x5f6>
ffffffffc02021d4:	018a2703          	lw	a4,24(s4)
ffffffffc02021d8:	478d                	li	a5,3
ffffffffc02021da:	38f71c63          	bne	a4,a5,ffffffffc0202572 <default_check+0x5f6>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02021de:	4505                	li	a0,1
ffffffffc02021e0:	091000ef          	jal	ra,ffffffffc0202a70 <alloc_pages>
ffffffffc02021e4:	36a99763          	bne	s3,a0,ffffffffc0202552 <default_check+0x5d6>
    free_page(p0);
ffffffffc02021e8:	4585                	li	a1,1
ffffffffc02021ea:	119000ef          	jal	ra,ffffffffc0202b02 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02021ee:	4509                	li	a0,2
ffffffffc02021f0:	081000ef          	jal	ra,ffffffffc0202a70 <alloc_pages>
ffffffffc02021f4:	32aa1f63          	bne	s4,a0,ffffffffc0202532 <default_check+0x5b6>

    free_pages(p0, 2);
ffffffffc02021f8:	4589                	li	a1,2
ffffffffc02021fa:	109000ef          	jal	ra,ffffffffc0202b02 <free_pages>
    free_page(p2);
ffffffffc02021fe:	4585                	li	a1,1
ffffffffc0202200:	8562                	mv	a0,s8
ffffffffc0202202:	101000ef          	jal	ra,ffffffffc0202b02 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202206:	4515                	li	a0,5
ffffffffc0202208:	069000ef          	jal	ra,ffffffffc0202a70 <alloc_pages>
ffffffffc020220c:	89aa                	mv	s3,a0
ffffffffc020220e:	48050263          	beqz	a0,ffffffffc0202692 <default_check+0x716>
    assert(alloc_page() == NULL);
ffffffffc0202212:	4505                	li	a0,1
ffffffffc0202214:	05d000ef          	jal	ra,ffffffffc0202a70 <alloc_pages>
ffffffffc0202218:	2c051d63          	bnez	a0,ffffffffc02024f2 <default_check+0x576>

    assert(nr_free == 0);
ffffffffc020221c:	481c                	lw	a5,16(s0)
ffffffffc020221e:	2a079a63          	bnez	a5,ffffffffc02024d2 <default_check+0x556>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0202222:	4595                	li	a1,5
ffffffffc0202224:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0202226:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc020222a:	01643023          	sd	s6,0(s0)
ffffffffc020222e:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0202232:	0d1000ef          	jal	ra,ffffffffc0202b02 <free_pages>
    return listelm->next;
ffffffffc0202236:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202238:	00878963          	beq	a5,s0,ffffffffc020224a <default_check+0x2ce>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc020223c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202240:	679c                	ld	a5,8(a5)
ffffffffc0202242:	397d                	addiw	s2,s2,-1
ffffffffc0202244:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202246:	fe879be3          	bne	a5,s0,ffffffffc020223c <default_check+0x2c0>
    }
    assert(count == 0);
ffffffffc020224a:	26091463          	bnez	s2,ffffffffc02024b2 <default_check+0x536>
    assert(total == 0);
ffffffffc020224e:	46049263          	bnez	s1,ffffffffc02026b2 <default_check+0x736>
}
ffffffffc0202252:	60a6                	ld	ra,72(sp)
ffffffffc0202254:	6406                	ld	s0,64(sp)
ffffffffc0202256:	74e2                	ld	s1,56(sp)
ffffffffc0202258:	7942                	ld	s2,48(sp)
ffffffffc020225a:	79a2                	ld	s3,40(sp)
ffffffffc020225c:	7a02                	ld	s4,32(sp)
ffffffffc020225e:	6ae2                	ld	s5,24(sp)
ffffffffc0202260:	6b42                	ld	s6,16(sp)
ffffffffc0202262:	6ba2                	ld	s7,8(sp)
ffffffffc0202264:	6c02                	ld	s8,0(sp)
ffffffffc0202266:	6161                	addi	sp,sp,80
ffffffffc0202268:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc020226a:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020226c:	4481                	li	s1,0
ffffffffc020226e:	4901                	li	s2,0
ffffffffc0202270:	b3b9                	j	ffffffffc0201fbe <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0202272:	00003697          	auipc	a3,0x3
ffffffffc0202276:	f6668693          	addi	a3,a3,-154 # ffffffffc02051d8 <commands+0xae0>
ffffffffc020227a:	00003617          	auipc	a2,0x3
ffffffffc020227e:	ba660613          	addi	a2,a2,-1114 # ffffffffc0204e20 <commands+0x728>
ffffffffc0202282:	0f000593          	li	a1,240
ffffffffc0202286:	00003517          	auipc	a0,0x3
ffffffffc020228a:	4ba50513          	addi	a0,a0,1210 # ffffffffc0205740 <commands+0x1048>
ffffffffc020228e:	e75fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202292:	00003697          	auipc	a3,0x3
ffffffffc0202296:	52668693          	addi	a3,a3,1318 # ffffffffc02057b8 <commands+0x10c0>
ffffffffc020229a:	00003617          	auipc	a2,0x3
ffffffffc020229e:	b8660613          	addi	a2,a2,-1146 # ffffffffc0204e20 <commands+0x728>
ffffffffc02022a2:	0bd00593          	li	a1,189
ffffffffc02022a6:	00003517          	auipc	a0,0x3
ffffffffc02022aa:	49a50513          	addi	a0,a0,1178 # ffffffffc0205740 <commands+0x1048>
ffffffffc02022ae:	e55fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02022b2:	00003697          	auipc	a3,0x3
ffffffffc02022b6:	52e68693          	addi	a3,a3,1326 # ffffffffc02057e0 <commands+0x10e8>
ffffffffc02022ba:	00003617          	auipc	a2,0x3
ffffffffc02022be:	b6660613          	addi	a2,a2,-1178 # ffffffffc0204e20 <commands+0x728>
ffffffffc02022c2:	0be00593          	li	a1,190
ffffffffc02022c6:	00003517          	auipc	a0,0x3
ffffffffc02022ca:	47a50513          	addi	a0,a0,1146 # ffffffffc0205740 <commands+0x1048>
ffffffffc02022ce:	e35fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02022d2:	00003697          	auipc	a3,0x3
ffffffffc02022d6:	54e68693          	addi	a3,a3,1358 # ffffffffc0205820 <commands+0x1128>
ffffffffc02022da:	00003617          	auipc	a2,0x3
ffffffffc02022de:	b4660613          	addi	a2,a2,-1210 # ffffffffc0204e20 <commands+0x728>
ffffffffc02022e2:	0c000593          	li	a1,192
ffffffffc02022e6:	00003517          	auipc	a0,0x3
ffffffffc02022ea:	45a50513          	addi	a0,a0,1114 # ffffffffc0205740 <commands+0x1048>
ffffffffc02022ee:	e15fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(!list_empty(&free_list));
ffffffffc02022f2:	00003697          	auipc	a3,0x3
ffffffffc02022f6:	5b668693          	addi	a3,a3,1462 # ffffffffc02058a8 <commands+0x11b0>
ffffffffc02022fa:	00003617          	auipc	a2,0x3
ffffffffc02022fe:	b2660613          	addi	a2,a2,-1242 # ffffffffc0204e20 <commands+0x728>
ffffffffc0202302:	0d900593          	li	a1,217
ffffffffc0202306:	00003517          	auipc	a0,0x3
ffffffffc020230a:	43a50513          	addi	a0,a0,1082 # ffffffffc0205740 <commands+0x1048>
ffffffffc020230e:	df5fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202312:	00003697          	auipc	a3,0x3
ffffffffc0202316:	44668693          	addi	a3,a3,1094 # ffffffffc0205758 <commands+0x1060>
ffffffffc020231a:	00003617          	auipc	a2,0x3
ffffffffc020231e:	b0660613          	addi	a2,a2,-1274 # ffffffffc0204e20 <commands+0x728>
ffffffffc0202322:	0d200593          	li	a1,210
ffffffffc0202326:	00003517          	auipc	a0,0x3
ffffffffc020232a:	41a50513          	addi	a0,a0,1050 # ffffffffc0205740 <commands+0x1048>
ffffffffc020232e:	dd5fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 3);
ffffffffc0202332:	00003697          	auipc	a3,0x3
ffffffffc0202336:	56668693          	addi	a3,a3,1382 # ffffffffc0205898 <commands+0x11a0>
ffffffffc020233a:	00003617          	auipc	a2,0x3
ffffffffc020233e:	ae660613          	addi	a2,a2,-1306 # ffffffffc0204e20 <commands+0x728>
ffffffffc0202342:	0d000593          	li	a1,208
ffffffffc0202346:	00003517          	auipc	a0,0x3
ffffffffc020234a:	3fa50513          	addi	a0,a0,1018 # ffffffffc0205740 <commands+0x1048>
ffffffffc020234e:	db5fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202352:	00003697          	auipc	a3,0x3
ffffffffc0202356:	52e68693          	addi	a3,a3,1326 # ffffffffc0205880 <commands+0x1188>
ffffffffc020235a:	00003617          	auipc	a2,0x3
ffffffffc020235e:	ac660613          	addi	a2,a2,-1338 # ffffffffc0204e20 <commands+0x728>
ffffffffc0202362:	0cb00593          	li	a1,203
ffffffffc0202366:	00003517          	auipc	a0,0x3
ffffffffc020236a:	3da50513          	addi	a0,a0,986 # ffffffffc0205740 <commands+0x1048>
ffffffffc020236e:	d95fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202372:	00003697          	auipc	a3,0x3
ffffffffc0202376:	4ee68693          	addi	a3,a3,1262 # ffffffffc0205860 <commands+0x1168>
ffffffffc020237a:	00003617          	auipc	a2,0x3
ffffffffc020237e:	aa660613          	addi	a2,a2,-1370 # ffffffffc0204e20 <commands+0x728>
ffffffffc0202382:	0c200593          	li	a1,194
ffffffffc0202386:	00003517          	auipc	a0,0x3
ffffffffc020238a:	3ba50513          	addi	a0,a0,954 # ffffffffc0205740 <commands+0x1048>
ffffffffc020238e:	d75fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 != NULL);
ffffffffc0202392:	00003697          	auipc	a3,0x3
ffffffffc0202396:	54e68693          	addi	a3,a3,1358 # ffffffffc02058e0 <commands+0x11e8>
ffffffffc020239a:	00003617          	auipc	a2,0x3
ffffffffc020239e:	a8660613          	addi	a2,a2,-1402 # ffffffffc0204e20 <commands+0x728>
ffffffffc02023a2:	0f800593          	li	a1,248
ffffffffc02023a6:	00003517          	auipc	a0,0x3
ffffffffc02023aa:	39a50513          	addi	a0,a0,922 # ffffffffc0205740 <commands+0x1048>
ffffffffc02023ae:	d55fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 0);
ffffffffc02023b2:	00003697          	auipc	a3,0x3
ffffffffc02023b6:	fd668693          	addi	a3,a3,-42 # ffffffffc0205388 <commands+0xc90>
ffffffffc02023ba:	00003617          	auipc	a2,0x3
ffffffffc02023be:	a6660613          	addi	a2,a2,-1434 # ffffffffc0204e20 <commands+0x728>
ffffffffc02023c2:	0df00593          	li	a1,223
ffffffffc02023c6:	00003517          	auipc	a0,0x3
ffffffffc02023ca:	37a50513          	addi	a0,a0,890 # ffffffffc0205740 <commands+0x1048>
ffffffffc02023ce:	d35fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02023d2:	00003697          	auipc	a3,0x3
ffffffffc02023d6:	4ae68693          	addi	a3,a3,1198 # ffffffffc0205880 <commands+0x1188>
ffffffffc02023da:	00003617          	auipc	a2,0x3
ffffffffc02023de:	a4660613          	addi	a2,a2,-1466 # ffffffffc0204e20 <commands+0x728>
ffffffffc02023e2:	0dd00593          	li	a1,221
ffffffffc02023e6:	00003517          	auipc	a0,0x3
ffffffffc02023ea:	35a50513          	addi	a0,a0,858 # ffffffffc0205740 <commands+0x1048>
ffffffffc02023ee:	d15fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02023f2:	00003697          	auipc	a3,0x3
ffffffffc02023f6:	4ce68693          	addi	a3,a3,1230 # ffffffffc02058c0 <commands+0x11c8>
ffffffffc02023fa:	00003617          	auipc	a2,0x3
ffffffffc02023fe:	a2660613          	addi	a2,a2,-1498 # ffffffffc0204e20 <commands+0x728>
ffffffffc0202402:	0dc00593          	li	a1,220
ffffffffc0202406:	00003517          	auipc	a0,0x3
ffffffffc020240a:	33a50513          	addi	a0,a0,826 # ffffffffc0205740 <commands+0x1048>
ffffffffc020240e:	cf5fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202412:	00003697          	auipc	a3,0x3
ffffffffc0202416:	34668693          	addi	a3,a3,838 # ffffffffc0205758 <commands+0x1060>
ffffffffc020241a:	00003617          	auipc	a2,0x3
ffffffffc020241e:	a0660613          	addi	a2,a2,-1530 # ffffffffc0204e20 <commands+0x728>
ffffffffc0202422:	0b900593          	li	a1,185
ffffffffc0202426:	00003517          	auipc	a0,0x3
ffffffffc020242a:	31a50513          	addi	a0,a0,794 # ffffffffc0205740 <commands+0x1048>
ffffffffc020242e:	cd5fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202432:	00003697          	auipc	a3,0x3
ffffffffc0202436:	44e68693          	addi	a3,a3,1102 # ffffffffc0205880 <commands+0x1188>
ffffffffc020243a:	00003617          	auipc	a2,0x3
ffffffffc020243e:	9e660613          	addi	a2,a2,-1562 # ffffffffc0204e20 <commands+0x728>
ffffffffc0202442:	0d600593          	li	a1,214
ffffffffc0202446:	00003517          	auipc	a0,0x3
ffffffffc020244a:	2fa50513          	addi	a0,a0,762 # ffffffffc0205740 <commands+0x1048>
ffffffffc020244e:	cb5fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202452:	00003697          	auipc	a3,0x3
ffffffffc0202456:	34668693          	addi	a3,a3,838 # ffffffffc0205798 <commands+0x10a0>
ffffffffc020245a:	00003617          	auipc	a2,0x3
ffffffffc020245e:	9c660613          	addi	a2,a2,-1594 # ffffffffc0204e20 <commands+0x728>
ffffffffc0202462:	0d400593          	li	a1,212
ffffffffc0202466:	00003517          	auipc	a0,0x3
ffffffffc020246a:	2da50513          	addi	a0,a0,730 # ffffffffc0205740 <commands+0x1048>
ffffffffc020246e:	c95fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202472:	00003697          	auipc	a3,0x3
ffffffffc0202476:	30668693          	addi	a3,a3,774 # ffffffffc0205778 <commands+0x1080>
ffffffffc020247a:	00003617          	auipc	a2,0x3
ffffffffc020247e:	9a660613          	addi	a2,a2,-1626 # ffffffffc0204e20 <commands+0x728>
ffffffffc0202482:	0d300593          	li	a1,211
ffffffffc0202486:	00003517          	auipc	a0,0x3
ffffffffc020248a:	2ba50513          	addi	a0,a0,698 # ffffffffc0205740 <commands+0x1048>
ffffffffc020248e:	c75fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202492:	00003697          	auipc	a3,0x3
ffffffffc0202496:	30668693          	addi	a3,a3,774 # ffffffffc0205798 <commands+0x10a0>
ffffffffc020249a:	00003617          	auipc	a2,0x3
ffffffffc020249e:	98660613          	addi	a2,a2,-1658 # ffffffffc0204e20 <commands+0x728>
ffffffffc02024a2:	0bb00593          	li	a1,187
ffffffffc02024a6:	00003517          	auipc	a0,0x3
ffffffffc02024aa:	29a50513          	addi	a0,a0,666 # ffffffffc0205740 <commands+0x1048>
ffffffffc02024ae:	c55fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(count == 0);
ffffffffc02024b2:	00003697          	auipc	a3,0x3
ffffffffc02024b6:	57e68693          	addi	a3,a3,1406 # ffffffffc0205a30 <commands+0x1338>
ffffffffc02024ba:	00003617          	auipc	a2,0x3
ffffffffc02024be:	96660613          	addi	a2,a2,-1690 # ffffffffc0204e20 <commands+0x728>
ffffffffc02024c2:	12500593          	li	a1,293
ffffffffc02024c6:	00003517          	auipc	a0,0x3
ffffffffc02024ca:	27a50513          	addi	a0,a0,634 # ffffffffc0205740 <commands+0x1048>
ffffffffc02024ce:	c35fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 0);
ffffffffc02024d2:	00003697          	auipc	a3,0x3
ffffffffc02024d6:	eb668693          	addi	a3,a3,-330 # ffffffffc0205388 <commands+0xc90>
ffffffffc02024da:	00003617          	auipc	a2,0x3
ffffffffc02024de:	94660613          	addi	a2,a2,-1722 # ffffffffc0204e20 <commands+0x728>
ffffffffc02024e2:	11a00593          	li	a1,282
ffffffffc02024e6:	00003517          	auipc	a0,0x3
ffffffffc02024ea:	25a50513          	addi	a0,a0,602 # ffffffffc0205740 <commands+0x1048>
ffffffffc02024ee:	c15fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02024f2:	00003697          	auipc	a3,0x3
ffffffffc02024f6:	38e68693          	addi	a3,a3,910 # ffffffffc0205880 <commands+0x1188>
ffffffffc02024fa:	00003617          	auipc	a2,0x3
ffffffffc02024fe:	92660613          	addi	a2,a2,-1754 # ffffffffc0204e20 <commands+0x728>
ffffffffc0202502:	11800593          	li	a1,280
ffffffffc0202506:	00003517          	auipc	a0,0x3
ffffffffc020250a:	23a50513          	addi	a0,a0,570 # ffffffffc0205740 <commands+0x1048>
ffffffffc020250e:	bf5fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202512:	00003697          	auipc	a3,0x3
ffffffffc0202516:	32e68693          	addi	a3,a3,814 # ffffffffc0205840 <commands+0x1148>
ffffffffc020251a:	00003617          	auipc	a2,0x3
ffffffffc020251e:	90660613          	addi	a2,a2,-1786 # ffffffffc0204e20 <commands+0x728>
ffffffffc0202522:	0c100593          	li	a1,193
ffffffffc0202526:	00003517          	auipc	a0,0x3
ffffffffc020252a:	21a50513          	addi	a0,a0,538 # ffffffffc0205740 <commands+0x1048>
ffffffffc020252e:	bd5fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202532:	00003697          	auipc	a3,0x3
ffffffffc0202536:	4be68693          	addi	a3,a3,1214 # ffffffffc02059f0 <commands+0x12f8>
ffffffffc020253a:	00003617          	auipc	a2,0x3
ffffffffc020253e:	8e660613          	addi	a2,a2,-1818 # ffffffffc0204e20 <commands+0x728>
ffffffffc0202542:	11200593          	li	a1,274
ffffffffc0202546:	00003517          	auipc	a0,0x3
ffffffffc020254a:	1fa50513          	addi	a0,a0,506 # ffffffffc0205740 <commands+0x1048>
ffffffffc020254e:	bb5fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202552:	00003697          	auipc	a3,0x3
ffffffffc0202556:	47e68693          	addi	a3,a3,1150 # ffffffffc02059d0 <commands+0x12d8>
ffffffffc020255a:	00003617          	auipc	a2,0x3
ffffffffc020255e:	8c660613          	addi	a2,a2,-1850 # ffffffffc0204e20 <commands+0x728>
ffffffffc0202562:	11000593          	li	a1,272
ffffffffc0202566:	00003517          	auipc	a0,0x3
ffffffffc020256a:	1da50513          	addi	a0,a0,474 # ffffffffc0205740 <commands+0x1048>
ffffffffc020256e:	b95fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202572:	00003697          	auipc	a3,0x3
ffffffffc0202576:	43668693          	addi	a3,a3,1078 # ffffffffc02059a8 <commands+0x12b0>
ffffffffc020257a:	00003617          	auipc	a2,0x3
ffffffffc020257e:	8a660613          	addi	a2,a2,-1882 # ffffffffc0204e20 <commands+0x728>
ffffffffc0202582:	10e00593          	li	a1,270
ffffffffc0202586:	00003517          	auipc	a0,0x3
ffffffffc020258a:	1ba50513          	addi	a0,a0,442 # ffffffffc0205740 <commands+0x1048>
ffffffffc020258e:	b75fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202592:	00003697          	auipc	a3,0x3
ffffffffc0202596:	3ee68693          	addi	a3,a3,1006 # ffffffffc0205980 <commands+0x1288>
ffffffffc020259a:	00003617          	auipc	a2,0x3
ffffffffc020259e:	88660613          	addi	a2,a2,-1914 # ffffffffc0204e20 <commands+0x728>
ffffffffc02025a2:	10d00593          	li	a1,269
ffffffffc02025a6:	00003517          	auipc	a0,0x3
ffffffffc02025aa:	19a50513          	addi	a0,a0,410 # ffffffffc0205740 <commands+0x1048>
ffffffffc02025ae:	b55fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02025b2:	00003697          	auipc	a3,0x3
ffffffffc02025b6:	3be68693          	addi	a3,a3,958 # ffffffffc0205970 <commands+0x1278>
ffffffffc02025ba:	00003617          	auipc	a2,0x3
ffffffffc02025be:	86660613          	addi	a2,a2,-1946 # ffffffffc0204e20 <commands+0x728>
ffffffffc02025c2:	10800593          	li	a1,264
ffffffffc02025c6:	00003517          	auipc	a0,0x3
ffffffffc02025ca:	17a50513          	addi	a0,a0,378 # ffffffffc0205740 <commands+0x1048>
ffffffffc02025ce:	b35fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02025d2:	00003697          	auipc	a3,0x3
ffffffffc02025d6:	2ae68693          	addi	a3,a3,686 # ffffffffc0205880 <commands+0x1188>
ffffffffc02025da:	00003617          	auipc	a2,0x3
ffffffffc02025de:	84660613          	addi	a2,a2,-1978 # ffffffffc0204e20 <commands+0x728>
ffffffffc02025e2:	10700593          	li	a1,263
ffffffffc02025e6:	00003517          	auipc	a0,0x3
ffffffffc02025ea:	15a50513          	addi	a0,a0,346 # ffffffffc0205740 <commands+0x1048>
ffffffffc02025ee:	b15fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02025f2:	00003697          	auipc	a3,0x3
ffffffffc02025f6:	35e68693          	addi	a3,a3,862 # ffffffffc0205950 <commands+0x1258>
ffffffffc02025fa:	00003617          	auipc	a2,0x3
ffffffffc02025fe:	82660613          	addi	a2,a2,-2010 # ffffffffc0204e20 <commands+0x728>
ffffffffc0202602:	10600593          	li	a1,262
ffffffffc0202606:	00003517          	auipc	a0,0x3
ffffffffc020260a:	13a50513          	addi	a0,a0,314 # ffffffffc0205740 <commands+0x1048>
ffffffffc020260e:	af5fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202612:	00003697          	auipc	a3,0x3
ffffffffc0202616:	30e68693          	addi	a3,a3,782 # ffffffffc0205920 <commands+0x1228>
ffffffffc020261a:	00003617          	auipc	a2,0x3
ffffffffc020261e:	80660613          	addi	a2,a2,-2042 # ffffffffc0204e20 <commands+0x728>
ffffffffc0202622:	10500593          	li	a1,261
ffffffffc0202626:	00003517          	auipc	a0,0x3
ffffffffc020262a:	11a50513          	addi	a0,a0,282 # ffffffffc0205740 <commands+0x1048>
ffffffffc020262e:	ad5fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0202632:	00003697          	auipc	a3,0x3
ffffffffc0202636:	2d668693          	addi	a3,a3,726 # ffffffffc0205908 <commands+0x1210>
ffffffffc020263a:	00002617          	auipc	a2,0x2
ffffffffc020263e:	7e660613          	addi	a2,a2,2022 # ffffffffc0204e20 <commands+0x728>
ffffffffc0202642:	10400593          	li	a1,260
ffffffffc0202646:	00003517          	auipc	a0,0x3
ffffffffc020264a:	0fa50513          	addi	a0,a0,250 # ffffffffc0205740 <commands+0x1048>
ffffffffc020264e:	ab5fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202652:	00003697          	auipc	a3,0x3
ffffffffc0202656:	22e68693          	addi	a3,a3,558 # ffffffffc0205880 <commands+0x1188>
ffffffffc020265a:	00002617          	auipc	a2,0x2
ffffffffc020265e:	7c660613          	addi	a2,a2,1990 # ffffffffc0204e20 <commands+0x728>
ffffffffc0202662:	0fe00593          	li	a1,254
ffffffffc0202666:	00003517          	auipc	a0,0x3
ffffffffc020266a:	0da50513          	addi	a0,a0,218 # ffffffffc0205740 <commands+0x1048>
ffffffffc020266e:	a95fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(!PageProperty(p0));
ffffffffc0202672:	00003697          	auipc	a3,0x3
ffffffffc0202676:	27e68693          	addi	a3,a3,638 # ffffffffc02058f0 <commands+0x11f8>
ffffffffc020267a:	00002617          	auipc	a2,0x2
ffffffffc020267e:	7a660613          	addi	a2,a2,1958 # ffffffffc0204e20 <commands+0x728>
ffffffffc0202682:	0f900593          	li	a1,249
ffffffffc0202686:	00003517          	auipc	a0,0x3
ffffffffc020268a:	0ba50513          	addi	a0,a0,186 # ffffffffc0205740 <commands+0x1048>
ffffffffc020268e:	a75fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202692:	00003697          	auipc	a3,0x3
ffffffffc0202696:	37e68693          	addi	a3,a3,894 # ffffffffc0205a10 <commands+0x1318>
ffffffffc020269a:	00002617          	auipc	a2,0x2
ffffffffc020269e:	78660613          	addi	a2,a2,1926 # ffffffffc0204e20 <commands+0x728>
ffffffffc02026a2:	11700593          	li	a1,279
ffffffffc02026a6:	00003517          	auipc	a0,0x3
ffffffffc02026aa:	09a50513          	addi	a0,a0,154 # ffffffffc0205740 <commands+0x1048>
ffffffffc02026ae:	a55fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(total == 0);
ffffffffc02026b2:	00003697          	auipc	a3,0x3
ffffffffc02026b6:	38e68693          	addi	a3,a3,910 # ffffffffc0205a40 <commands+0x1348>
ffffffffc02026ba:	00002617          	auipc	a2,0x2
ffffffffc02026be:	76660613          	addi	a2,a2,1894 # ffffffffc0204e20 <commands+0x728>
ffffffffc02026c2:	12600593          	li	a1,294
ffffffffc02026c6:	00003517          	auipc	a0,0x3
ffffffffc02026ca:	07a50513          	addi	a0,a0,122 # ffffffffc0205740 <commands+0x1048>
ffffffffc02026ce:	a35fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(total == nr_free_pages());
ffffffffc02026d2:	00003697          	auipc	a3,0x3
ffffffffc02026d6:	b1668693          	addi	a3,a3,-1258 # ffffffffc02051e8 <commands+0xaf0>
ffffffffc02026da:	00002617          	auipc	a2,0x2
ffffffffc02026de:	74660613          	addi	a2,a2,1862 # ffffffffc0204e20 <commands+0x728>
ffffffffc02026e2:	0f300593          	li	a1,243
ffffffffc02026e6:	00003517          	auipc	a0,0x3
ffffffffc02026ea:	05a50513          	addi	a0,a0,90 # ffffffffc0205740 <commands+0x1048>
ffffffffc02026ee:	a15fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02026f2:	00003697          	auipc	a3,0x3
ffffffffc02026f6:	08668693          	addi	a3,a3,134 # ffffffffc0205778 <commands+0x1080>
ffffffffc02026fa:	00002617          	auipc	a2,0x2
ffffffffc02026fe:	72660613          	addi	a2,a2,1830 # ffffffffc0204e20 <commands+0x728>
ffffffffc0202702:	0ba00593          	li	a1,186
ffffffffc0202706:	00003517          	auipc	a0,0x3
ffffffffc020270a:	03a50513          	addi	a0,a0,58 # ffffffffc0205740 <commands+0x1048>
ffffffffc020270e:	9f5fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202712 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0202712:	1141                	addi	sp,sp,-16
ffffffffc0202714:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202716:	14058a63          	beqz	a1,ffffffffc020286a <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc020271a:	00359693          	slli	a3,a1,0x3
ffffffffc020271e:	96ae                	add	a3,a3,a1
ffffffffc0202720:	068e                	slli	a3,a3,0x3
ffffffffc0202722:	96aa                	add	a3,a3,a0
ffffffffc0202724:	87aa                	mv	a5,a0
ffffffffc0202726:	02d50263          	beq	a0,a3,ffffffffc020274a <default_free_pages+0x38>
ffffffffc020272a:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020272c:	8b05                	andi	a4,a4,1
ffffffffc020272e:	10071e63          	bnez	a4,ffffffffc020284a <default_free_pages+0x138>
ffffffffc0202732:	6798                	ld	a4,8(a5)
ffffffffc0202734:	8b09                	andi	a4,a4,2
ffffffffc0202736:	10071a63          	bnez	a4,ffffffffc020284a <default_free_pages+0x138>
        p->flags = 0;
ffffffffc020273a:	0007b423          	sd	zero,8(a5)
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020273e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0202742:	04878793          	addi	a5,a5,72
ffffffffc0202746:	fed792e3          	bne	a5,a3,ffffffffc020272a <default_free_pages+0x18>
    base->property = n;
ffffffffc020274a:	2581                	sext.w	a1,a1
ffffffffc020274c:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc020274e:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202752:	4789                	li	a5,2
ffffffffc0202754:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0202758:	0000f697          	auipc	a3,0xf
ffffffffc020275c:	98868693          	addi	a3,a3,-1656 # ffffffffc02110e0 <free_area>
ffffffffc0202760:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202762:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0202764:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc0202768:	9db9                	addw	a1,a1,a4
ffffffffc020276a:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020276c:	0ad78863          	beq	a5,a3,ffffffffc020281c <default_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc0202770:	fe078713          	addi	a4,a5,-32
ffffffffc0202774:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0202778:	4581                	li	a1,0
            if (base < page) {
ffffffffc020277a:	00e56a63          	bltu	a0,a4,ffffffffc020278e <default_free_pages+0x7c>
    return listelm->next;
ffffffffc020277e:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0202780:	06d70263          	beq	a4,a3,ffffffffc02027e4 <default_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc0202784:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0202786:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc020278a:	fee57ae3          	bgeu	a0,a4,ffffffffc020277e <default_free_pages+0x6c>
ffffffffc020278e:	c199                	beqz	a1,ffffffffc0202794 <default_free_pages+0x82>
ffffffffc0202790:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202794:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0202796:	e390                	sd	a2,0(a5)
ffffffffc0202798:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020279a:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020279c:	f118                	sd	a4,32(a0)
    if (le != &free_list) {
ffffffffc020279e:	02d70063          	beq	a4,a3,ffffffffc02027be <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc02027a2:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc02027a6:	fe070593          	addi	a1,a4,-32
        if (p + p->property == base) {
ffffffffc02027aa:	02081613          	slli	a2,a6,0x20
ffffffffc02027ae:	9201                	srli	a2,a2,0x20
ffffffffc02027b0:	00361793          	slli	a5,a2,0x3
ffffffffc02027b4:	97b2                	add	a5,a5,a2
ffffffffc02027b6:	078e                	slli	a5,a5,0x3
ffffffffc02027b8:	97ae                	add	a5,a5,a1
ffffffffc02027ba:	02f50f63          	beq	a0,a5,ffffffffc02027f8 <default_free_pages+0xe6>
    return listelm->next;
ffffffffc02027be:	7518                	ld	a4,40(a0)
    if (le != &free_list) {
ffffffffc02027c0:	00d70f63          	beq	a4,a3,ffffffffc02027de <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc02027c4:	4d0c                	lw	a1,24(a0)
        p = le2page(le, page_link);
ffffffffc02027c6:	fe070693          	addi	a3,a4,-32
        if (base + base->property == p) {
ffffffffc02027ca:	02059613          	slli	a2,a1,0x20
ffffffffc02027ce:	9201                	srli	a2,a2,0x20
ffffffffc02027d0:	00361793          	slli	a5,a2,0x3
ffffffffc02027d4:	97b2                	add	a5,a5,a2
ffffffffc02027d6:	078e                	slli	a5,a5,0x3
ffffffffc02027d8:	97aa                	add	a5,a5,a0
ffffffffc02027da:	04f68863          	beq	a3,a5,ffffffffc020282a <default_free_pages+0x118>
}
ffffffffc02027de:	60a2                	ld	ra,8(sp)
ffffffffc02027e0:	0141                	addi	sp,sp,16
ffffffffc02027e2:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02027e4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02027e6:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc02027e8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02027ea:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02027ec:	02d70563          	beq	a4,a3,ffffffffc0202816 <default_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc02027f0:	8832                	mv	a6,a2
ffffffffc02027f2:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02027f4:	87ba                	mv	a5,a4
ffffffffc02027f6:	bf41                	j	ffffffffc0202786 <default_free_pages+0x74>
            p->property += base->property;
ffffffffc02027f8:	4d1c                	lw	a5,24(a0)
ffffffffc02027fa:	0107883b          	addw	a6,a5,a6
ffffffffc02027fe:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0202802:	57f5                	li	a5,-3
ffffffffc0202804:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202808:	7110                	ld	a2,32(a0)
ffffffffc020280a:	751c                	ld	a5,40(a0)
            base = p;
ffffffffc020280c:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc020280e:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc0202810:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc0202812:	e390                	sd	a2,0(a5)
ffffffffc0202814:	b775                	j	ffffffffc02027c0 <default_free_pages+0xae>
ffffffffc0202816:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0202818:	873e                	mv	a4,a5
ffffffffc020281a:	b761                	j	ffffffffc02027a2 <default_free_pages+0x90>
}
ffffffffc020281c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020281e:	e390                	sd	a2,0(a5)
ffffffffc0202820:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202822:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0202824:	f11c                	sd	a5,32(a0)
ffffffffc0202826:	0141                	addi	sp,sp,16
ffffffffc0202828:	8082                	ret
            base->property += p->property;
ffffffffc020282a:	ff872783          	lw	a5,-8(a4)
ffffffffc020282e:	fe870693          	addi	a3,a4,-24
ffffffffc0202832:	9dbd                	addw	a1,a1,a5
ffffffffc0202834:	cd0c                	sw	a1,24(a0)
ffffffffc0202836:	57f5                	li	a5,-3
ffffffffc0202838:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020283c:	6314                	ld	a3,0(a4)
ffffffffc020283e:	671c                	ld	a5,8(a4)
}
ffffffffc0202840:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0202842:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0202844:	e394                	sd	a3,0(a5)
ffffffffc0202846:	0141                	addi	sp,sp,16
ffffffffc0202848:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020284a:	00003697          	auipc	a3,0x3
ffffffffc020284e:	20e68693          	addi	a3,a3,526 # ffffffffc0205a58 <commands+0x1360>
ffffffffc0202852:	00002617          	auipc	a2,0x2
ffffffffc0202856:	5ce60613          	addi	a2,a2,1486 # ffffffffc0204e20 <commands+0x728>
ffffffffc020285a:	08300593          	li	a1,131
ffffffffc020285e:	00003517          	auipc	a0,0x3
ffffffffc0202862:	ee250513          	addi	a0,a0,-286 # ffffffffc0205740 <commands+0x1048>
ffffffffc0202866:	89dfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0);
ffffffffc020286a:	00003697          	auipc	a3,0x3
ffffffffc020286e:	1e668693          	addi	a3,a3,486 # ffffffffc0205a50 <commands+0x1358>
ffffffffc0202872:	00002617          	auipc	a2,0x2
ffffffffc0202876:	5ae60613          	addi	a2,a2,1454 # ffffffffc0204e20 <commands+0x728>
ffffffffc020287a:	08000593          	li	a1,128
ffffffffc020287e:	00003517          	auipc	a0,0x3
ffffffffc0202882:	ec250513          	addi	a0,a0,-318 # ffffffffc0205740 <commands+0x1048>
ffffffffc0202886:	87dfd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc020288a <default_alloc_pages>:
    assert(n > 0);
ffffffffc020288a:	c959                	beqz	a0,ffffffffc0202920 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc020288c:	0000f597          	auipc	a1,0xf
ffffffffc0202890:	85458593          	addi	a1,a1,-1964 # ffffffffc02110e0 <free_area>
ffffffffc0202894:	0105a803          	lw	a6,16(a1)
ffffffffc0202898:	862a                	mv	a2,a0
ffffffffc020289a:	02081793          	slli	a5,a6,0x20
ffffffffc020289e:	9381                	srli	a5,a5,0x20
ffffffffc02028a0:	00a7ee63          	bltu	a5,a0,ffffffffc02028bc <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02028a4:	87ae                	mv	a5,a1
ffffffffc02028a6:	a801                	j	ffffffffc02028b6 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02028a8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02028ac:	02071693          	slli	a3,a4,0x20
ffffffffc02028b0:	9281                	srli	a3,a3,0x20
ffffffffc02028b2:	00c6f763          	bgeu	a3,a2,ffffffffc02028c0 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02028b6:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02028b8:	feb798e3          	bne	a5,a1,ffffffffc02028a8 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02028bc:	4501                	li	a0,0
}
ffffffffc02028be:	8082                	ret
    return listelm->prev;
ffffffffc02028c0:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02028c4:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc02028c8:	fe078513          	addi	a0,a5,-32
            p->property = page->property - n;
ffffffffc02028cc:	00060e1b          	sext.w	t3,a2
    prev->next = next;
ffffffffc02028d0:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02028d4:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02028d8:	02d67b63          	bgeu	a2,a3,ffffffffc020290e <default_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc02028dc:	00361693          	slli	a3,a2,0x3
ffffffffc02028e0:	96b2                	add	a3,a3,a2
ffffffffc02028e2:	068e                	slli	a3,a3,0x3
ffffffffc02028e4:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc02028e6:	41c7073b          	subw	a4,a4,t3
ffffffffc02028ea:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02028ec:	00868613          	addi	a2,a3,8
ffffffffc02028f0:	4709                	li	a4,2
ffffffffc02028f2:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02028f6:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02028fa:	02068613          	addi	a2,a3,32
        nr_free -= n;
ffffffffc02028fe:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0202902:	e310                	sd	a2,0(a4)
ffffffffc0202904:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0202908:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc020290a:	0316b023          	sd	a7,32(a3)
ffffffffc020290e:	41c8083b          	subw	a6,a6,t3
ffffffffc0202912:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0202916:	5775                	li	a4,-3
ffffffffc0202918:	17a1                	addi	a5,a5,-24
ffffffffc020291a:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc020291e:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0202920:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0202922:	00003697          	auipc	a3,0x3
ffffffffc0202926:	12e68693          	addi	a3,a3,302 # ffffffffc0205a50 <commands+0x1358>
ffffffffc020292a:	00002617          	auipc	a2,0x2
ffffffffc020292e:	4f660613          	addi	a2,a2,1270 # ffffffffc0204e20 <commands+0x728>
ffffffffc0202932:	06200593          	li	a1,98
ffffffffc0202936:	00003517          	auipc	a0,0x3
ffffffffc020293a:	e0a50513          	addi	a0,a0,-502 # ffffffffc0205740 <commands+0x1048>
default_alloc_pages(size_t n) {
ffffffffc020293e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202940:	fc2fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202944 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0202944:	1141                	addi	sp,sp,-16
ffffffffc0202946:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202948:	c9e1                	beqz	a1,ffffffffc0202a18 <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc020294a:	00359693          	slli	a3,a1,0x3
ffffffffc020294e:	96ae                	add	a3,a3,a1
ffffffffc0202950:	068e                	slli	a3,a3,0x3
ffffffffc0202952:	96aa                	add	a3,a3,a0
ffffffffc0202954:	87aa                	mv	a5,a0
ffffffffc0202956:	00d50f63          	beq	a0,a3,ffffffffc0202974 <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020295a:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc020295c:	8b05                	andi	a4,a4,1
ffffffffc020295e:	cf49                	beqz	a4,ffffffffc02029f8 <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc0202960:	0007ac23          	sw	zero,24(a5)
ffffffffc0202964:	0007b423          	sd	zero,8(a5)
ffffffffc0202968:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020296c:	04878793          	addi	a5,a5,72
ffffffffc0202970:	fed795e3          	bne	a5,a3,ffffffffc020295a <default_init_memmap+0x16>
    base->property = n;
ffffffffc0202974:	2581                	sext.w	a1,a1
ffffffffc0202976:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202978:	4789                	li	a5,2
ffffffffc020297a:	00850713          	addi	a4,a0,8
ffffffffc020297e:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0202982:	0000e697          	auipc	a3,0xe
ffffffffc0202986:	75e68693          	addi	a3,a3,1886 # ffffffffc02110e0 <free_area>
ffffffffc020298a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020298c:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020298e:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc0202992:	9db9                	addw	a1,a1,a4
ffffffffc0202994:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0202996:	04d78a63          	beq	a5,a3,ffffffffc02029ea <default_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc020299a:	fe078713          	addi	a4,a5,-32
ffffffffc020299e:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02029a2:	4581                	li	a1,0
            if (base < page) {
ffffffffc02029a4:	00e56a63          	bltu	a0,a4,ffffffffc02029b8 <default_init_memmap+0x74>
    return listelm->next;
ffffffffc02029a8:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02029aa:	02d70263          	beq	a4,a3,ffffffffc02029ce <default_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc02029ae:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02029b0:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02029b4:	fee57ae3          	bgeu	a0,a4,ffffffffc02029a8 <default_init_memmap+0x64>
ffffffffc02029b8:	c199                	beqz	a1,ffffffffc02029be <default_init_memmap+0x7a>
ffffffffc02029ba:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02029be:	6398                	ld	a4,0(a5)
}
ffffffffc02029c0:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02029c2:	e390                	sd	a2,0(a5)
ffffffffc02029c4:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02029c6:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02029c8:	f118                	sd	a4,32(a0)
ffffffffc02029ca:	0141                	addi	sp,sp,16
ffffffffc02029cc:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02029ce:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02029d0:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc02029d2:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02029d4:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02029d6:	00d70663          	beq	a4,a3,ffffffffc02029e2 <default_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc02029da:	8832                	mv	a6,a2
ffffffffc02029dc:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02029de:	87ba                	mv	a5,a4
ffffffffc02029e0:	bfc1                	j	ffffffffc02029b0 <default_init_memmap+0x6c>
}
ffffffffc02029e2:	60a2                	ld	ra,8(sp)
ffffffffc02029e4:	e290                	sd	a2,0(a3)
ffffffffc02029e6:	0141                	addi	sp,sp,16
ffffffffc02029e8:	8082                	ret
ffffffffc02029ea:	60a2                	ld	ra,8(sp)
ffffffffc02029ec:	e390                	sd	a2,0(a5)
ffffffffc02029ee:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02029f0:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02029f2:	f11c                	sd	a5,32(a0)
ffffffffc02029f4:	0141                	addi	sp,sp,16
ffffffffc02029f6:	8082                	ret
        assert(PageReserved(p));
ffffffffc02029f8:	00003697          	auipc	a3,0x3
ffffffffc02029fc:	08868693          	addi	a3,a3,136 # ffffffffc0205a80 <commands+0x1388>
ffffffffc0202a00:	00002617          	auipc	a2,0x2
ffffffffc0202a04:	42060613          	addi	a2,a2,1056 # ffffffffc0204e20 <commands+0x728>
ffffffffc0202a08:	04900593          	li	a1,73
ffffffffc0202a0c:	00003517          	auipc	a0,0x3
ffffffffc0202a10:	d3450513          	addi	a0,a0,-716 # ffffffffc0205740 <commands+0x1048>
ffffffffc0202a14:	eeefd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0);
ffffffffc0202a18:	00003697          	auipc	a3,0x3
ffffffffc0202a1c:	03868693          	addi	a3,a3,56 # ffffffffc0205a50 <commands+0x1358>
ffffffffc0202a20:	00002617          	auipc	a2,0x2
ffffffffc0202a24:	40060613          	addi	a2,a2,1024 # ffffffffc0204e20 <commands+0x728>
ffffffffc0202a28:	04600593          	li	a1,70
ffffffffc0202a2c:	00003517          	auipc	a0,0x3
ffffffffc0202a30:	d1450513          	addi	a0,a0,-748 # ffffffffc0205740 <commands+0x1048>
ffffffffc0202a34:	ecefd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202a38 <pa2page.part.0>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0202a38:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0202a3a:	00002617          	auipc	a2,0x2
ffffffffc0202a3e:	63660613          	addi	a2,a2,1590 # ffffffffc0205070 <commands+0x978>
ffffffffc0202a42:	06500593          	li	a1,101
ffffffffc0202a46:	00002517          	auipc	a0,0x2
ffffffffc0202a4a:	64a50513          	addi	a0,a0,1610 # ffffffffc0205090 <commands+0x998>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0202a4e:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0202a50:	eb2fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202a54 <pte2page.part.0>:
static inline struct Page *pte2page(pte_t pte) {
ffffffffc0202a54:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0202a56:	00003617          	auipc	a2,0x3
ffffffffc0202a5a:	95a60613          	addi	a2,a2,-1702 # ffffffffc02053b0 <commands+0xcb8>
ffffffffc0202a5e:	07000593          	li	a1,112
ffffffffc0202a62:	00002517          	auipc	a0,0x2
ffffffffc0202a66:	62e50513          	addi	a0,a0,1582 # ffffffffc0205090 <commands+0x998>
static inline struct Page *pte2page(pte_t pte) {
ffffffffc0202a6a:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0202a6c:	e96fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202a70 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0202a70:	7139                	addi	sp,sp,-64
ffffffffc0202a72:	f426                	sd	s1,40(sp)
ffffffffc0202a74:	f04a                	sd	s2,32(sp)
ffffffffc0202a76:	ec4e                	sd	s3,24(sp)
ffffffffc0202a78:	e852                	sd	s4,16(sp)
ffffffffc0202a7a:	e456                	sd	s5,8(sp)
ffffffffc0202a7c:	e05a                	sd	s6,0(sp)
ffffffffc0202a7e:	fc06                	sd	ra,56(sp)
ffffffffc0202a80:	f822                	sd	s0,48(sp)
ffffffffc0202a82:	84aa                	mv	s1,a0
ffffffffc0202a84:	0000f917          	auipc	s2,0xf
ffffffffc0202a88:	ad490913          	addi	s2,s2,-1324 # ffffffffc0211558 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202a8c:	4a05                	li	s4,1
ffffffffc0202a8e:	0000fa97          	auipc	s5,0xf
ffffffffc0202a92:	aa2a8a93          	addi	s5,s5,-1374 # ffffffffc0211530 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0202a96:	0005099b          	sext.w	s3,a0
ffffffffc0202a9a:	0000fb17          	auipc	s6,0xf
ffffffffc0202a9e:	a76b0b13          	addi	s6,s6,-1418 # ffffffffc0211510 <check_mm_struct>
ffffffffc0202aa2:	a01d                	j	ffffffffc0202ac8 <alloc_pages+0x58>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0202aa4:	00093783          	ld	a5,0(s2)
ffffffffc0202aa8:	6f9c                	ld	a5,24(a5)
ffffffffc0202aaa:	9782                	jalr	a5
ffffffffc0202aac:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0202aae:	4601                	li	a2,0
ffffffffc0202ab0:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202ab2:	ec0d                	bnez	s0,ffffffffc0202aec <alloc_pages+0x7c>
ffffffffc0202ab4:	029a6c63          	bltu	s4,s1,ffffffffc0202aec <alloc_pages+0x7c>
ffffffffc0202ab8:	000aa783          	lw	a5,0(s5)
ffffffffc0202abc:	2781                	sext.w	a5,a5
ffffffffc0202abe:	c79d                	beqz	a5,ffffffffc0202aec <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0202ac0:	000b3503          	ld	a0,0(s6)
ffffffffc0202ac4:	ef5fe0ef          	jal	ra,ffffffffc02019b8 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202ac8:	100027f3          	csrr	a5,sstatus
ffffffffc0202acc:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0202ace:	8526                	mv	a0,s1
ffffffffc0202ad0:	dbf1                	beqz	a5,ffffffffc0202aa4 <alloc_pages+0x34>
        intr_disable();
ffffffffc0202ad2:	a1dfd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202ad6:	00093783          	ld	a5,0(s2)
ffffffffc0202ada:	8526                	mv	a0,s1
ffffffffc0202adc:	6f9c                	ld	a5,24(a5)
ffffffffc0202ade:	9782                	jalr	a5
ffffffffc0202ae0:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202ae2:	a07fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0202ae6:	4601                	li	a2,0
ffffffffc0202ae8:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202aea:	d469                	beqz	s0,ffffffffc0202ab4 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0202aec:	70e2                	ld	ra,56(sp)
ffffffffc0202aee:	8522                	mv	a0,s0
ffffffffc0202af0:	7442                	ld	s0,48(sp)
ffffffffc0202af2:	74a2                	ld	s1,40(sp)
ffffffffc0202af4:	7902                	ld	s2,32(sp)
ffffffffc0202af6:	69e2                	ld	s3,24(sp)
ffffffffc0202af8:	6a42                	ld	s4,16(sp)
ffffffffc0202afa:	6aa2                	ld	s5,8(sp)
ffffffffc0202afc:	6b02                	ld	s6,0(sp)
ffffffffc0202afe:	6121                	addi	sp,sp,64
ffffffffc0202b00:	8082                	ret

ffffffffc0202b02 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202b02:	100027f3          	csrr	a5,sstatus
ffffffffc0202b06:	8b89                	andi	a5,a5,2
ffffffffc0202b08:	e799                	bnez	a5,ffffffffc0202b16 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc0202b0a:	0000f797          	auipc	a5,0xf
ffffffffc0202b0e:	a4e7b783          	ld	a5,-1458(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc0202b12:	739c                	ld	a5,32(a5)
ffffffffc0202b14:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0202b16:	1101                	addi	sp,sp,-32
ffffffffc0202b18:	ec06                	sd	ra,24(sp)
ffffffffc0202b1a:	e822                	sd	s0,16(sp)
ffffffffc0202b1c:	e426                	sd	s1,8(sp)
ffffffffc0202b1e:	842a                	mv	s0,a0
ffffffffc0202b20:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0202b22:	9cdfd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202b26:	0000f797          	auipc	a5,0xf
ffffffffc0202b2a:	a327b783          	ld	a5,-1486(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc0202b2e:	739c                	ld	a5,32(a5)
ffffffffc0202b30:	85a6                	mv	a1,s1
ffffffffc0202b32:	8522                	mv	a0,s0
ffffffffc0202b34:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0202b36:	6442                	ld	s0,16(sp)
ffffffffc0202b38:	60e2                	ld	ra,24(sp)
ffffffffc0202b3a:	64a2                	ld	s1,8(sp)
ffffffffc0202b3c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0202b3e:	9abfd06f          	j	ffffffffc02004e8 <intr_enable>

ffffffffc0202b42 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202b42:	100027f3          	csrr	a5,sstatus
ffffffffc0202b46:	8b89                	andi	a5,a5,2
ffffffffc0202b48:	e799                	bnez	a5,ffffffffc0202b56 <nr_free_pages+0x14>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202b4a:	0000f797          	auipc	a5,0xf
ffffffffc0202b4e:	a0e7b783          	ld	a5,-1522(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc0202b52:	779c                	ld	a5,40(a5)
ffffffffc0202b54:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0202b56:	1141                	addi	sp,sp,-16
ffffffffc0202b58:	e406                	sd	ra,8(sp)
ffffffffc0202b5a:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0202b5c:	993fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202b60:	0000f797          	auipc	a5,0xf
ffffffffc0202b64:	9f87b783          	ld	a5,-1544(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc0202b68:	779c                	ld	a5,40(a5)
ffffffffc0202b6a:	9782                	jalr	a5
ffffffffc0202b6c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202b6e:	97bfd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0202b72:	60a2                	ld	ra,8(sp)
ffffffffc0202b74:	8522                	mv	a0,s0
ffffffffc0202b76:	6402                	ld	s0,0(sp)
ffffffffc0202b78:	0141                	addi	sp,sp,16
ffffffffc0202b7a:	8082                	ret

ffffffffc0202b7c <get_pte>:
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202b7c:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0202b80:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202b84:	715d                	addi	sp,sp,-80
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202b86:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202b88:	fc26                	sd	s1,56(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202b8a:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202b8e:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202b90:	f84a                	sd	s2,48(sp)
ffffffffc0202b92:	f44e                	sd	s3,40(sp)
ffffffffc0202b94:	f052                	sd	s4,32(sp)
ffffffffc0202b96:	e486                	sd	ra,72(sp)
ffffffffc0202b98:	e0a2                	sd	s0,64(sp)
ffffffffc0202b9a:	ec56                	sd	s5,24(sp)
ffffffffc0202b9c:	e85a                	sd	s6,16(sp)
ffffffffc0202b9e:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202ba0:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202ba4:	892e                	mv	s2,a1
ffffffffc0202ba6:	8a32                	mv	s4,a2
ffffffffc0202ba8:	0000f997          	auipc	s3,0xf
ffffffffc0202bac:	9a098993          	addi	s3,s3,-1632 # ffffffffc0211548 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202bb0:	efb5                	bnez	a5,ffffffffc0202c2c <get_pte+0xb0>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202bb2:	14060c63          	beqz	a2,ffffffffc0202d0a <get_pte+0x18e>
ffffffffc0202bb6:	4505                	li	a0,1
ffffffffc0202bb8:	eb9ff0ef          	jal	ra,ffffffffc0202a70 <alloc_pages>
ffffffffc0202bbc:	842a                	mv	s0,a0
ffffffffc0202bbe:	14050663          	beqz	a0,ffffffffc0202d0a <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202bc2:	0000fb97          	auipc	s7,0xf
ffffffffc0202bc6:	98eb8b93          	addi	s7,s7,-1650 # ffffffffc0211550 <pages>
ffffffffc0202bca:	000bb503          	ld	a0,0(s7)
ffffffffc0202bce:	00003b17          	auipc	s6,0x3
ffffffffc0202bd2:	7aab3b03          	ld	s6,1962(s6) # ffffffffc0206378 <error_string+0x38>
ffffffffc0202bd6:	00080ab7          	lui	s5,0x80
ffffffffc0202bda:	40a40533          	sub	a0,s0,a0
ffffffffc0202bde:	850d                	srai	a0,a0,0x3
ffffffffc0202be0:	03650533          	mul	a0,a0,s6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202be4:	0000f997          	auipc	s3,0xf
ffffffffc0202be8:	96498993          	addi	s3,s3,-1692 # ffffffffc0211548 <npage>
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202bec:	4785                	li	a5,1
ffffffffc0202bee:	0009b703          	ld	a4,0(s3)
ffffffffc0202bf2:	c01c                	sw	a5,0(s0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202bf4:	9556                	add	a0,a0,s5
ffffffffc0202bf6:	00c51793          	slli	a5,a0,0xc
ffffffffc0202bfa:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202bfc:	0532                	slli	a0,a0,0xc
ffffffffc0202bfe:	14e7fd63          	bgeu	a5,a4,ffffffffc0202d58 <get_pte+0x1dc>
ffffffffc0202c02:	0000f797          	auipc	a5,0xf
ffffffffc0202c06:	95e7b783          	ld	a5,-1698(a5) # ffffffffc0211560 <va_pa_offset>
ffffffffc0202c0a:	6605                	lui	a2,0x1
ffffffffc0202c0c:	4581                	li	a1,0
ffffffffc0202c0e:	953e                	add	a0,a0,a5
ffffffffc0202c10:	3a2010ef          	jal	ra,ffffffffc0203fb2 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202c14:	000bb683          	ld	a3,0(s7)
ffffffffc0202c18:	40d406b3          	sub	a3,s0,a3
ffffffffc0202c1c:	868d                	srai	a3,a3,0x3
ffffffffc0202c1e:	036686b3          	mul	a3,a3,s6
ffffffffc0202c22:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202c24:	06aa                	slli	a3,a3,0xa
ffffffffc0202c26:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202c2a:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202c2c:	77fd                	lui	a5,0xfffff
ffffffffc0202c2e:	068a                	slli	a3,a3,0x2
ffffffffc0202c30:	0009b703          	ld	a4,0(s3)
ffffffffc0202c34:	8efd                	and	a3,a3,a5
ffffffffc0202c36:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202c3a:	0ce7fa63          	bgeu	a5,a4,ffffffffc0202d0e <get_pte+0x192>
ffffffffc0202c3e:	0000fa97          	auipc	s5,0xf
ffffffffc0202c42:	922a8a93          	addi	s5,s5,-1758 # ffffffffc0211560 <va_pa_offset>
ffffffffc0202c46:	000ab403          	ld	s0,0(s5)
ffffffffc0202c4a:	01595793          	srli	a5,s2,0x15
ffffffffc0202c4e:	1ff7f793          	andi	a5,a5,511
ffffffffc0202c52:	96a2                	add	a3,a3,s0
ffffffffc0202c54:	00379413          	slli	s0,a5,0x3
ffffffffc0202c58:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc0202c5a:	6014                	ld	a3,0(s0)
ffffffffc0202c5c:	0016f793          	andi	a5,a3,1
ffffffffc0202c60:	ebad                	bnez	a5,ffffffffc0202cd2 <get_pte+0x156>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202c62:	0a0a0463          	beqz	s4,ffffffffc0202d0a <get_pte+0x18e>
ffffffffc0202c66:	4505                	li	a0,1
ffffffffc0202c68:	e09ff0ef          	jal	ra,ffffffffc0202a70 <alloc_pages>
ffffffffc0202c6c:	84aa                	mv	s1,a0
ffffffffc0202c6e:	cd51                	beqz	a0,ffffffffc0202d0a <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202c70:	0000fb97          	auipc	s7,0xf
ffffffffc0202c74:	8e0b8b93          	addi	s7,s7,-1824 # ffffffffc0211550 <pages>
ffffffffc0202c78:	000bb503          	ld	a0,0(s7)
ffffffffc0202c7c:	00003b17          	auipc	s6,0x3
ffffffffc0202c80:	6fcb3b03          	ld	s6,1788(s6) # ffffffffc0206378 <error_string+0x38>
ffffffffc0202c84:	00080a37          	lui	s4,0x80
ffffffffc0202c88:	40a48533          	sub	a0,s1,a0
ffffffffc0202c8c:	850d                	srai	a0,a0,0x3
ffffffffc0202c8e:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202c92:	4785                	li	a5,1
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202c94:	0009b703          	ld	a4,0(s3)
ffffffffc0202c98:	c09c                	sw	a5,0(s1)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202c9a:	9552                	add	a0,a0,s4
ffffffffc0202c9c:	00c51793          	slli	a5,a0,0xc
ffffffffc0202ca0:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202ca2:	0532                	slli	a0,a0,0xc
ffffffffc0202ca4:	08e7fd63          	bgeu	a5,a4,ffffffffc0202d3e <get_pte+0x1c2>
ffffffffc0202ca8:	000ab783          	ld	a5,0(s5)
ffffffffc0202cac:	6605                	lui	a2,0x1
ffffffffc0202cae:	4581                	li	a1,0
ffffffffc0202cb0:	953e                	add	a0,a0,a5
ffffffffc0202cb2:	300010ef          	jal	ra,ffffffffc0203fb2 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202cb6:	000bb683          	ld	a3,0(s7)
ffffffffc0202cba:	40d486b3          	sub	a3,s1,a3
ffffffffc0202cbe:	868d                	srai	a3,a3,0x3
ffffffffc0202cc0:	036686b3          	mul	a3,a3,s6
ffffffffc0202cc4:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202cc6:	06aa                	slli	a3,a3,0xa
ffffffffc0202cc8:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202ccc:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202cce:	0009b703          	ld	a4,0(s3)
ffffffffc0202cd2:	068a                	slli	a3,a3,0x2
ffffffffc0202cd4:	757d                	lui	a0,0xfffff
ffffffffc0202cd6:	8ee9                	and	a3,a3,a0
ffffffffc0202cd8:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202cdc:	04e7f563          	bgeu	a5,a4,ffffffffc0202d26 <get_pte+0x1aa>
ffffffffc0202ce0:	000ab503          	ld	a0,0(s5)
ffffffffc0202ce4:	00c95913          	srli	s2,s2,0xc
ffffffffc0202ce8:	1ff97913          	andi	s2,s2,511
ffffffffc0202cec:	96aa                	add	a3,a3,a0
ffffffffc0202cee:	00391513          	slli	a0,s2,0x3
ffffffffc0202cf2:	9536                	add	a0,a0,a3
}
ffffffffc0202cf4:	60a6                	ld	ra,72(sp)
ffffffffc0202cf6:	6406                	ld	s0,64(sp)
ffffffffc0202cf8:	74e2                	ld	s1,56(sp)
ffffffffc0202cfa:	7942                	ld	s2,48(sp)
ffffffffc0202cfc:	79a2                	ld	s3,40(sp)
ffffffffc0202cfe:	7a02                	ld	s4,32(sp)
ffffffffc0202d00:	6ae2                	ld	s5,24(sp)
ffffffffc0202d02:	6b42                	ld	s6,16(sp)
ffffffffc0202d04:	6ba2                	ld	s7,8(sp)
ffffffffc0202d06:	6161                	addi	sp,sp,80
ffffffffc0202d08:	8082                	ret
            return NULL;
ffffffffc0202d0a:	4501                	li	a0,0
ffffffffc0202d0c:	b7e5                	j	ffffffffc0202cf4 <get_pte+0x178>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202d0e:	00003617          	auipc	a2,0x3
ffffffffc0202d12:	dd260613          	addi	a2,a2,-558 # ffffffffc0205ae0 <default_pmm_manager+0x38>
ffffffffc0202d16:	10200593          	li	a1,258
ffffffffc0202d1a:	00003517          	auipc	a0,0x3
ffffffffc0202d1e:	dee50513          	addi	a0,a0,-530 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc0202d22:	be0fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202d26:	00003617          	auipc	a2,0x3
ffffffffc0202d2a:	dba60613          	addi	a2,a2,-582 # ffffffffc0205ae0 <default_pmm_manager+0x38>
ffffffffc0202d2e:	10f00593          	li	a1,271
ffffffffc0202d32:	00003517          	auipc	a0,0x3
ffffffffc0202d36:	dd650513          	addi	a0,a0,-554 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc0202d3a:	bc8fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202d3e:	86aa                	mv	a3,a0
ffffffffc0202d40:	00003617          	auipc	a2,0x3
ffffffffc0202d44:	da060613          	addi	a2,a2,-608 # ffffffffc0205ae0 <default_pmm_manager+0x38>
ffffffffc0202d48:	10b00593          	li	a1,267
ffffffffc0202d4c:	00003517          	auipc	a0,0x3
ffffffffc0202d50:	dbc50513          	addi	a0,a0,-580 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc0202d54:	baefd0ef          	jal	ra,ffffffffc0200102 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202d58:	86aa                	mv	a3,a0
ffffffffc0202d5a:	00003617          	auipc	a2,0x3
ffffffffc0202d5e:	d8660613          	addi	a2,a2,-634 # ffffffffc0205ae0 <default_pmm_manager+0x38>
ffffffffc0202d62:	0ff00593          	li	a1,255
ffffffffc0202d66:	00003517          	auipc	a0,0x3
ffffffffc0202d6a:	da250513          	addi	a0,a0,-606 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc0202d6e:	b94fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202d72 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202d72:	1141                	addi	sp,sp,-16
ffffffffc0202d74:	e022                	sd	s0,0(sp)
ffffffffc0202d76:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202d78:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202d7a:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202d7c:	e01ff0ef          	jal	ra,ffffffffc0202b7c <get_pte>
    if (ptep_store != NULL) {
ffffffffc0202d80:	c011                	beqz	s0,ffffffffc0202d84 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0202d82:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202d84:	c511                	beqz	a0,ffffffffc0202d90 <get_page+0x1e>
ffffffffc0202d86:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202d88:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202d8a:	0017f713          	andi	a4,a5,1
ffffffffc0202d8e:	e709                	bnez	a4,ffffffffc0202d98 <get_page+0x26>
}
ffffffffc0202d90:	60a2                	ld	ra,8(sp)
ffffffffc0202d92:	6402                	ld	s0,0(sp)
ffffffffc0202d94:	0141                	addi	sp,sp,16
ffffffffc0202d96:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202d98:	078a                	slli	a5,a5,0x2
ffffffffc0202d9a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202d9c:	0000e717          	auipc	a4,0xe
ffffffffc0202da0:	7ac73703          	ld	a4,1964(a4) # ffffffffc0211548 <npage>
ffffffffc0202da4:	02e7f263          	bgeu	a5,a4,ffffffffc0202dc8 <get_page+0x56>
    return &pages[PPN(pa) - nbase];
ffffffffc0202da8:	fff80537          	lui	a0,0xfff80
ffffffffc0202dac:	97aa                	add	a5,a5,a0
ffffffffc0202dae:	60a2                	ld	ra,8(sp)
ffffffffc0202db0:	6402                	ld	s0,0(sp)
ffffffffc0202db2:	00379513          	slli	a0,a5,0x3
ffffffffc0202db6:	97aa                	add	a5,a5,a0
ffffffffc0202db8:	078e                	slli	a5,a5,0x3
ffffffffc0202dba:	0000e517          	auipc	a0,0xe
ffffffffc0202dbe:	79653503          	ld	a0,1942(a0) # ffffffffc0211550 <pages>
ffffffffc0202dc2:	953e                	add	a0,a0,a5
ffffffffc0202dc4:	0141                	addi	sp,sp,16
ffffffffc0202dc6:	8082                	ret
ffffffffc0202dc8:	c71ff0ef          	jal	ra,ffffffffc0202a38 <pa2page.part.0>

ffffffffc0202dcc <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202dcc:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202dce:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202dd0:	ec06                	sd	ra,24(sp)
ffffffffc0202dd2:	e822                	sd	s0,16(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202dd4:	da9ff0ef          	jal	ra,ffffffffc0202b7c <get_pte>
    if (ptep != NULL) {
ffffffffc0202dd8:	c511                	beqz	a0,ffffffffc0202de4 <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202dda:	611c                	ld	a5,0(a0)
ffffffffc0202ddc:	842a                	mv	s0,a0
ffffffffc0202dde:	0017f713          	andi	a4,a5,1
ffffffffc0202de2:	e709                	bnez	a4,ffffffffc0202dec <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0202de4:	60e2                	ld	ra,24(sp)
ffffffffc0202de6:	6442                	ld	s0,16(sp)
ffffffffc0202de8:	6105                	addi	sp,sp,32
ffffffffc0202dea:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202dec:	078a                	slli	a5,a5,0x2
ffffffffc0202dee:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202df0:	0000e717          	auipc	a4,0xe
ffffffffc0202df4:	75873703          	ld	a4,1880(a4) # ffffffffc0211548 <npage>
ffffffffc0202df8:	06e7f563          	bgeu	a5,a4,ffffffffc0202e62 <page_remove+0x96>
    return &pages[PPN(pa) - nbase];
ffffffffc0202dfc:	fff80737          	lui	a4,0xfff80
ffffffffc0202e00:	97ba                	add	a5,a5,a4
ffffffffc0202e02:	00379513          	slli	a0,a5,0x3
ffffffffc0202e06:	97aa                	add	a5,a5,a0
ffffffffc0202e08:	078e                	slli	a5,a5,0x3
ffffffffc0202e0a:	0000e517          	auipc	a0,0xe
ffffffffc0202e0e:	74653503          	ld	a0,1862(a0) # ffffffffc0211550 <pages>
ffffffffc0202e12:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202e14:	411c                	lw	a5,0(a0)
ffffffffc0202e16:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202e1a:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202e1c:	cb09                	beqz	a4,ffffffffc0202e2e <page_remove+0x62>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202e1e:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202e22:	12000073          	sfence.vma
}
ffffffffc0202e26:	60e2                	ld	ra,24(sp)
ffffffffc0202e28:	6442                	ld	s0,16(sp)
ffffffffc0202e2a:	6105                	addi	sp,sp,32
ffffffffc0202e2c:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202e2e:	100027f3          	csrr	a5,sstatus
ffffffffc0202e32:	8b89                	andi	a5,a5,2
ffffffffc0202e34:	eb89                	bnez	a5,ffffffffc0202e46 <page_remove+0x7a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202e36:	0000e797          	auipc	a5,0xe
ffffffffc0202e3a:	7227b783          	ld	a5,1826(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc0202e3e:	739c                	ld	a5,32(a5)
ffffffffc0202e40:	4585                	li	a1,1
ffffffffc0202e42:	9782                	jalr	a5
    if (flag) {
ffffffffc0202e44:	bfe9                	j	ffffffffc0202e1e <page_remove+0x52>
        intr_disable();
ffffffffc0202e46:	e42a                	sd	a0,8(sp)
ffffffffc0202e48:	ea6fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202e4c:	0000e797          	auipc	a5,0xe
ffffffffc0202e50:	70c7b783          	ld	a5,1804(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc0202e54:	739c                	ld	a5,32(a5)
ffffffffc0202e56:	6522                	ld	a0,8(sp)
ffffffffc0202e58:	4585                	li	a1,1
ffffffffc0202e5a:	9782                	jalr	a5
        intr_enable();
ffffffffc0202e5c:	e8cfd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202e60:	bf7d                	j	ffffffffc0202e1e <page_remove+0x52>
ffffffffc0202e62:	bd7ff0ef          	jal	ra,ffffffffc0202a38 <pa2page.part.0>

ffffffffc0202e66 <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202e66:	7179                	addi	sp,sp,-48
ffffffffc0202e68:	87b2                	mv	a5,a2
ffffffffc0202e6a:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202e6c:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202e6e:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202e70:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202e72:	ec26                	sd	s1,24(sp)
ffffffffc0202e74:	f406                	sd	ra,40(sp)
ffffffffc0202e76:	e84a                	sd	s2,16(sp)
ffffffffc0202e78:	e44e                	sd	s3,8(sp)
ffffffffc0202e7a:	e052                	sd	s4,0(sp)
ffffffffc0202e7c:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202e7e:	cffff0ef          	jal	ra,ffffffffc0202b7c <get_pte>
    if (ptep == NULL) {
ffffffffc0202e82:	cd71                	beqz	a0,ffffffffc0202f5e <page_insert+0xf8>
    page->ref += 1;
ffffffffc0202e84:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0202e86:	611c                	ld	a5,0(a0)
ffffffffc0202e88:	89aa                	mv	s3,a0
ffffffffc0202e8a:	0016871b          	addiw	a4,a3,1
ffffffffc0202e8e:	c018                	sw	a4,0(s0)
ffffffffc0202e90:	0017f713          	andi	a4,a5,1
ffffffffc0202e94:	e331                	bnez	a4,ffffffffc0202ed8 <page_insert+0x72>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202e96:	0000e797          	auipc	a5,0xe
ffffffffc0202e9a:	6ba7b783          	ld	a5,1722(a5) # ffffffffc0211550 <pages>
ffffffffc0202e9e:	40f407b3          	sub	a5,s0,a5
ffffffffc0202ea2:	878d                	srai	a5,a5,0x3
ffffffffc0202ea4:	00003417          	auipc	s0,0x3
ffffffffc0202ea8:	4d443403          	ld	s0,1236(s0) # ffffffffc0206378 <error_string+0x38>
ffffffffc0202eac:	028787b3          	mul	a5,a5,s0
ffffffffc0202eb0:	00080437          	lui	s0,0x80
ffffffffc0202eb4:	97a2                	add	a5,a5,s0
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202eb6:	07aa                	slli	a5,a5,0xa
ffffffffc0202eb8:	8cdd                	or	s1,s1,a5
ffffffffc0202eba:	0014e493          	ori	s1,s1,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0202ebe:	0099b023          	sd	s1,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202ec2:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0202ec6:	4501                	li	a0,0
}
ffffffffc0202ec8:	70a2                	ld	ra,40(sp)
ffffffffc0202eca:	7402                	ld	s0,32(sp)
ffffffffc0202ecc:	64e2                	ld	s1,24(sp)
ffffffffc0202ece:	6942                	ld	s2,16(sp)
ffffffffc0202ed0:	69a2                	ld	s3,8(sp)
ffffffffc0202ed2:	6a02                	ld	s4,0(sp)
ffffffffc0202ed4:	6145                	addi	sp,sp,48
ffffffffc0202ed6:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202ed8:	00279713          	slli	a4,a5,0x2
ffffffffc0202edc:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ede:	0000e797          	auipc	a5,0xe
ffffffffc0202ee2:	66a7b783          	ld	a5,1642(a5) # ffffffffc0211548 <npage>
ffffffffc0202ee6:	06f77e63          	bgeu	a4,a5,ffffffffc0202f62 <page_insert+0xfc>
    return &pages[PPN(pa) - nbase];
ffffffffc0202eea:	fff807b7          	lui	a5,0xfff80
ffffffffc0202eee:	973e                	add	a4,a4,a5
ffffffffc0202ef0:	0000ea17          	auipc	s4,0xe
ffffffffc0202ef4:	660a0a13          	addi	s4,s4,1632 # ffffffffc0211550 <pages>
ffffffffc0202ef8:	000a3783          	ld	a5,0(s4)
ffffffffc0202efc:	00371913          	slli	s2,a4,0x3
ffffffffc0202f00:	993a                	add	s2,s2,a4
ffffffffc0202f02:	090e                	slli	s2,s2,0x3
ffffffffc0202f04:	993e                	add	s2,s2,a5
        if (p == page) {
ffffffffc0202f06:	03240063          	beq	s0,s2,ffffffffc0202f26 <page_insert+0xc0>
    page->ref -= 1;
ffffffffc0202f0a:	00092783          	lw	a5,0(s2)
ffffffffc0202f0e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202f12:	00e92023          	sw	a4,0(s2)
        if (page_ref(page) ==
ffffffffc0202f16:	cb11                	beqz	a4,ffffffffc0202f2a <page_insert+0xc4>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202f18:	0009b023          	sd	zero,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202f1c:	12000073          	sfence.vma
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202f20:	000a3783          	ld	a5,0(s4)
}
ffffffffc0202f24:	bfad                	j	ffffffffc0202e9e <page_insert+0x38>
    page->ref -= 1;
ffffffffc0202f26:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0202f28:	bf9d                	j	ffffffffc0202e9e <page_insert+0x38>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202f2a:	100027f3          	csrr	a5,sstatus
ffffffffc0202f2e:	8b89                	andi	a5,a5,2
ffffffffc0202f30:	eb91                	bnez	a5,ffffffffc0202f44 <page_insert+0xde>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202f32:	0000e797          	auipc	a5,0xe
ffffffffc0202f36:	6267b783          	ld	a5,1574(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc0202f3a:	739c                	ld	a5,32(a5)
ffffffffc0202f3c:	4585                	li	a1,1
ffffffffc0202f3e:	854a                	mv	a0,s2
ffffffffc0202f40:	9782                	jalr	a5
    if (flag) {
ffffffffc0202f42:	bfd9                	j	ffffffffc0202f18 <page_insert+0xb2>
        intr_disable();
ffffffffc0202f44:	daafd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202f48:	0000e797          	auipc	a5,0xe
ffffffffc0202f4c:	6107b783          	ld	a5,1552(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc0202f50:	739c                	ld	a5,32(a5)
ffffffffc0202f52:	4585                	li	a1,1
ffffffffc0202f54:	854a                	mv	a0,s2
ffffffffc0202f56:	9782                	jalr	a5
        intr_enable();
ffffffffc0202f58:	d90fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202f5c:	bf75                	j	ffffffffc0202f18 <page_insert+0xb2>
        return -E_NO_MEM;
ffffffffc0202f5e:	5571                	li	a0,-4
ffffffffc0202f60:	b7a5                	j	ffffffffc0202ec8 <page_insert+0x62>
ffffffffc0202f62:	ad7ff0ef          	jal	ra,ffffffffc0202a38 <pa2page.part.0>

ffffffffc0202f66 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202f66:	00003797          	auipc	a5,0x3
ffffffffc0202f6a:	b4278793          	addi	a5,a5,-1214 # ffffffffc0205aa8 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202f6e:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0202f70:	7159                	addi	sp,sp,-112
ffffffffc0202f72:	f45e                	sd	s7,40(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202f74:	00003517          	auipc	a0,0x3
ffffffffc0202f78:	ba450513          	addi	a0,a0,-1116 # ffffffffc0205b18 <default_pmm_manager+0x70>
    pmm_manager = &default_pmm_manager;
ffffffffc0202f7c:	0000eb97          	auipc	s7,0xe
ffffffffc0202f80:	5dcb8b93          	addi	s7,s7,1500 # ffffffffc0211558 <pmm_manager>
void pmm_init(void) {
ffffffffc0202f84:	f486                	sd	ra,104(sp)
ffffffffc0202f86:	f0a2                	sd	s0,96(sp)
ffffffffc0202f88:	eca6                	sd	s1,88(sp)
ffffffffc0202f8a:	e8ca                	sd	s2,80(sp)
ffffffffc0202f8c:	e4ce                	sd	s3,72(sp)
ffffffffc0202f8e:	f85a                	sd	s6,48(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202f90:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0202f94:	e0d2                	sd	s4,64(sp)
ffffffffc0202f96:	fc56                	sd	s5,56(sp)
ffffffffc0202f98:	f062                	sd	s8,32(sp)
ffffffffc0202f9a:	ec66                	sd	s9,24(sp)
ffffffffc0202f9c:	e86a                	sd	s10,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202f9e:	91cfd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pmm_manager->init();
ffffffffc0202fa2:	000bb783          	ld	a5,0(s7)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0202fa6:	4445                	li	s0,17
ffffffffc0202fa8:	40100913          	li	s2,1025
    pmm_manager->init();
ffffffffc0202fac:	679c                	ld	a5,8(a5)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202fae:	0000e997          	auipc	s3,0xe
ffffffffc0202fb2:	5b298993          	addi	s3,s3,1458 # ffffffffc0211560 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0202fb6:	0000e497          	auipc	s1,0xe
ffffffffc0202fba:	59248493          	addi	s1,s1,1426 # ffffffffc0211548 <npage>
    pmm_manager->init();
ffffffffc0202fbe:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202fc0:	57f5                	li	a5,-3
ffffffffc0202fc2:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0202fc4:	07e006b7          	lui	a3,0x7e00
ffffffffc0202fc8:	01b41613          	slli	a2,s0,0x1b
ffffffffc0202fcc:	01591593          	slli	a1,s2,0x15
ffffffffc0202fd0:	00003517          	auipc	a0,0x3
ffffffffc0202fd4:	b6050513          	addi	a0,a0,-1184 # ffffffffc0205b30 <default_pmm_manager+0x88>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202fd8:	00f9b023          	sd	a5,0(s3)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0202fdc:	8defd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0202fe0:	00003517          	auipc	a0,0x3
ffffffffc0202fe4:	b8050513          	addi	a0,a0,-1152 # ffffffffc0205b60 <default_pmm_manager+0xb8>
ffffffffc0202fe8:	8d2fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202fec:	01b41693          	slli	a3,s0,0x1b
ffffffffc0202ff0:	16fd                	addi	a3,a3,-1
ffffffffc0202ff2:	07e005b7          	lui	a1,0x7e00
ffffffffc0202ff6:	01591613          	slli	a2,s2,0x15
ffffffffc0202ffa:	00003517          	auipc	a0,0x3
ffffffffc0202ffe:	b7e50513          	addi	a0,a0,-1154 # ffffffffc0205b78 <default_pmm_manager+0xd0>
ffffffffc0203002:	8b8fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203006:	777d                	lui	a4,0xfffff
ffffffffc0203008:	0000f797          	auipc	a5,0xf
ffffffffc020300c:	55f78793          	addi	a5,a5,1375 # ffffffffc0212567 <end+0xfff>
ffffffffc0203010:	8ff9                	and	a5,a5,a4
ffffffffc0203012:	0000eb17          	auipc	s6,0xe
ffffffffc0203016:	53eb0b13          	addi	s6,s6,1342 # ffffffffc0211550 <pages>
    npage = maxpa / PGSIZE;
ffffffffc020301a:	00088737          	lui	a4,0x88
ffffffffc020301e:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203020:	00fb3023          	sd	a5,0(s6)
ffffffffc0203024:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0203026:	4701                	li	a4,0
ffffffffc0203028:	4505                	li	a0,1
ffffffffc020302a:	fff805b7          	lui	a1,0xfff80
ffffffffc020302e:	a019                	j	ffffffffc0203034 <pmm_init+0xce>
        SetPageReserved(pages + i);
ffffffffc0203030:	000b3783          	ld	a5,0(s6)
ffffffffc0203034:	97b6                	add	a5,a5,a3
ffffffffc0203036:	07a1                	addi	a5,a5,8
ffffffffc0203038:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020303c:	609c                	ld	a5,0(s1)
ffffffffc020303e:	0705                	addi	a4,a4,1
ffffffffc0203040:	04868693          	addi	a3,a3,72 # 7e00048 <kern_entry-0xffffffffb83fffb8>
ffffffffc0203044:	00b78633          	add	a2,a5,a1
ffffffffc0203048:	fec764e3          	bltu	a4,a2,ffffffffc0203030 <pmm_init+0xca>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020304c:	000b3503          	ld	a0,0(s6)
ffffffffc0203050:	00379693          	slli	a3,a5,0x3
ffffffffc0203054:	96be                	add	a3,a3,a5
ffffffffc0203056:	fdc00737          	lui	a4,0xfdc00
ffffffffc020305a:	972a                	add	a4,a4,a0
ffffffffc020305c:	068e                	slli	a3,a3,0x3
ffffffffc020305e:	96ba                	add	a3,a3,a4
ffffffffc0203060:	c0200737          	lui	a4,0xc0200
ffffffffc0203064:	64e6e463          	bltu	a3,a4,ffffffffc02036ac <pmm_init+0x746>
ffffffffc0203068:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc020306c:	4645                	li	a2,17
ffffffffc020306e:	066e                	slli	a2,a2,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203070:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0203072:	4ec6e263          	bltu	a3,a2,ffffffffc0203556 <pmm_init+0x5f0>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0203076:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020307a:	0000e917          	auipc	s2,0xe
ffffffffc020307e:	4c690913          	addi	s2,s2,1222 # ffffffffc0211540 <boot_pgdir>
    pmm_manager->check();
ffffffffc0203082:	7b9c                	ld	a5,48(a5)
ffffffffc0203084:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0203086:	00003517          	auipc	a0,0x3
ffffffffc020308a:	b4250513          	addi	a0,a0,-1214 # ffffffffc0205bc8 <default_pmm_manager+0x120>
ffffffffc020308e:	82cfd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203092:	00006697          	auipc	a3,0x6
ffffffffc0203096:	f6e68693          	addi	a3,a3,-146 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc020309a:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020309e:	c02007b7          	lui	a5,0xc0200
ffffffffc02030a2:	62f6e163          	bltu	a3,a5,ffffffffc02036c4 <pmm_init+0x75e>
ffffffffc02030a6:	0009b783          	ld	a5,0(s3)
ffffffffc02030aa:	8e9d                	sub	a3,a3,a5
ffffffffc02030ac:	0000e797          	auipc	a5,0xe
ffffffffc02030b0:	48d7b623          	sd	a3,1164(a5) # ffffffffc0211538 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02030b4:	100027f3          	csrr	a5,sstatus
ffffffffc02030b8:	8b89                	andi	a5,a5,2
ffffffffc02030ba:	4c079763          	bnez	a5,ffffffffc0203588 <pmm_init+0x622>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02030be:	000bb783          	ld	a5,0(s7)
ffffffffc02030c2:	779c                	ld	a5,40(a5)
ffffffffc02030c4:	9782                	jalr	a5
ffffffffc02030c6:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02030c8:	6098                	ld	a4,0(s1)
ffffffffc02030ca:	c80007b7          	lui	a5,0xc8000
ffffffffc02030ce:	83b1                	srli	a5,a5,0xc
ffffffffc02030d0:	62e7e663          	bltu	a5,a4,ffffffffc02036fc <pmm_init+0x796>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02030d4:	00093503          	ld	a0,0(s2)
ffffffffc02030d8:	60050263          	beqz	a0,ffffffffc02036dc <pmm_init+0x776>
ffffffffc02030dc:	03451793          	slli	a5,a0,0x34
ffffffffc02030e0:	5e079e63          	bnez	a5,ffffffffc02036dc <pmm_init+0x776>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02030e4:	4601                	li	a2,0
ffffffffc02030e6:	4581                	li	a1,0
ffffffffc02030e8:	c8bff0ef          	jal	ra,ffffffffc0202d72 <get_page>
ffffffffc02030ec:	66051a63          	bnez	a0,ffffffffc0203760 <pmm_init+0x7fa>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02030f0:	4505                	li	a0,1
ffffffffc02030f2:	97fff0ef          	jal	ra,ffffffffc0202a70 <alloc_pages>
ffffffffc02030f6:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02030f8:	00093503          	ld	a0,0(s2)
ffffffffc02030fc:	4681                	li	a3,0
ffffffffc02030fe:	4601                	li	a2,0
ffffffffc0203100:	85d2                	mv	a1,s4
ffffffffc0203102:	d65ff0ef          	jal	ra,ffffffffc0202e66 <page_insert>
ffffffffc0203106:	62051d63          	bnez	a0,ffffffffc0203740 <pmm_init+0x7da>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc020310a:	00093503          	ld	a0,0(s2)
ffffffffc020310e:	4601                	li	a2,0
ffffffffc0203110:	4581                	li	a1,0
ffffffffc0203112:	a6bff0ef          	jal	ra,ffffffffc0202b7c <get_pte>
ffffffffc0203116:	60050563          	beqz	a0,ffffffffc0203720 <pmm_init+0x7ba>
    assert(pte2page(*ptep) == p1);
ffffffffc020311a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020311c:	0017f713          	andi	a4,a5,1
ffffffffc0203120:	5e070e63          	beqz	a4,ffffffffc020371c <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc0203124:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203126:	078a                	slli	a5,a5,0x2
ffffffffc0203128:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020312a:	56c7ff63          	bgeu	a5,a2,ffffffffc02036a8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc020312e:	fff80737          	lui	a4,0xfff80
ffffffffc0203132:	97ba                	add	a5,a5,a4
ffffffffc0203134:	000b3683          	ld	a3,0(s6)
ffffffffc0203138:	00379713          	slli	a4,a5,0x3
ffffffffc020313c:	97ba                	add	a5,a5,a4
ffffffffc020313e:	078e                	slli	a5,a5,0x3
ffffffffc0203140:	97b6                	add	a5,a5,a3
ffffffffc0203142:	14fa18e3          	bne	s4,a5,ffffffffc0203a92 <pmm_init+0xb2c>
    assert(page_ref(p1) == 1);
ffffffffc0203146:	000a2703          	lw	a4,0(s4)
ffffffffc020314a:	4785                	li	a5,1
ffffffffc020314c:	16f71fe3          	bne	a4,a5,ffffffffc0203aca <pmm_init+0xb64>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203150:	00093503          	ld	a0,0(s2)
ffffffffc0203154:	77fd                	lui	a5,0xfffff
ffffffffc0203156:	6114                	ld	a3,0(a0)
ffffffffc0203158:	068a                	slli	a3,a3,0x2
ffffffffc020315a:	8efd                	and	a3,a3,a5
ffffffffc020315c:	00c6d713          	srli	a4,a3,0xc
ffffffffc0203160:	14c779e3          	bgeu	a4,a2,ffffffffc0203ab2 <pmm_init+0xb4c>
ffffffffc0203164:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203168:	96e2                	add	a3,a3,s8
ffffffffc020316a:	0006ba83          	ld	s5,0(a3)
ffffffffc020316e:	0a8a                	slli	s5,s5,0x2
ffffffffc0203170:	00fafab3          	and	s5,s5,a5
ffffffffc0203174:	00cad793          	srli	a5,s5,0xc
ffffffffc0203178:	66c7f463          	bgeu	a5,a2,ffffffffc02037e0 <pmm_init+0x87a>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020317c:	4601                	li	a2,0
ffffffffc020317e:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203180:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203182:	9fbff0ef          	jal	ra,ffffffffc0202b7c <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203186:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203188:	63551c63          	bne	a0,s5,ffffffffc02037c0 <pmm_init+0x85a>

    p2 = alloc_page();
ffffffffc020318c:	4505                	li	a0,1
ffffffffc020318e:	8e3ff0ef          	jal	ra,ffffffffc0202a70 <alloc_pages>
ffffffffc0203192:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203194:	00093503          	ld	a0,0(s2)
ffffffffc0203198:	46d1                	li	a3,20
ffffffffc020319a:	6605                	lui	a2,0x1
ffffffffc020319c:	85d6                	mv	a1,s5
ffffffffc020319e:	cc9ff0ef          	jal	ra,ffffffffc0202e66 <page_insert>
ffffffffc02031a2:	5c051f63          	bnez	a0,ffffffffc0203780 <pmm_init+0x81a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02031a6:	00093503          	ld	a0,0(s2)
ffffffffc02031aa:	4601                	li	a2,0
ffffffffc02031ac:	6585                	lui	a1,0x1
ffffffffc02031ae:	9cfff0ef          	jal	ra,ffffffffc0202b7c <get_pte>
ffffffffc02031b2:	12050ce3          	beqz	a0,ffffffffc0203aea <pmm_init+0xb84>
    assert(*ptep & PTE_U);
ffffffffc02031b6:	611c                	ld	a5,0(a0)
ffffffffc02031b8:	0107f713          	andi	a4,a5,16
ffffffffc02031bc:	72070f63          	beqz	a4,ffffffffc02038fa <pmm_init+0x994>
    assert(*ptep & PTE_W);
ffffffffc02031c0:	8b91                	andi	a5,a5,4
ffffffffc02031c2:	6e078c63          	beqz	a5,ffffffffc02038ba <pmm_init+0x954>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02031c6:	00093503          	ld	a0,0(s2)
ffffffffc02031ca:	611c                	ld	a5,0(a0)
ffffffffc02031cc:	8bc1                	andi	a5,a5,16
ffffffffc02031ce:	6c078663          	beqz	a5,ffffffffc020389a <pmm_init+0x934>
    assert(page_ref(p2) == 1);
ffffffffc02031d2:	000aa703          	lw	a4,0(s5)
ffffffffc02031d6:	4785                	li	a5,1
ffffffffc02031d8:	5cf71463          	bne	a4,a5,ffffffffc02037a0 <pmm_init+0x83a>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02031dc:	4681                	li	a3,0
ffffffffc02031de:	6605                	lui	a2,0x1
ffffffffc02031e0:	85d2                	mv	a1,s4
ffffffffc02031e2:	c85ff0ef          	jal	ra,ffffffffc0202e66 <page_insert>
ffffffffc02031e6:	66051a63          	bnez	a0,ffffffffc020385a <pmm_init+0x8f4>
    assert(page_ref(p1) == 2);
ffffffffc02031ea:	000a2703          	lw	a4,0(s4)
ffffffffc02031ee:	4789                	li	a5,2
ffffffffc02031f0:	64f71563          	bne	a4,a5,ffffffffc020383a <pmm_init+0x8d4>
    assert(page_ref(p2) == 0);
ffffffffc02031f4:	000aa783          	lw	a5,0(s5)
ffffffffc02031f8:	62079163          	bnez	a5,ffffffffc020381a <pmm_init+0x8b4>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02031fc:	00093503          	ld	a0,0(s2)
ffffffffc0203200:	4601                	li	a2,0
ffffffffc0203202:	6585                	lui	a1,0x1
ffffffffc0203204:	979ff0ef          	jal	ra,ffffffffc0202b7c <get_pte>
ffffffffc0203208:	5e050963          	beqz	a0,ffffffffc02037fa <pmm_init+0x894>
    assert(pte2page(*ptep) == p1);
ffffffffc020320c:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020320e:	00177793          	andi	a5,a4,1
ffffffffc0203212:	50078563          	beqz	a5,ffffffffc020371c <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc0203216:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203218:	00271793          	slli	a5,a4,0x2
ffffffffc020321c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020321e:	48d7f563          	bgeu	a5,a3,ffffffffc02036a8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0203222:	fff806b7          	lui	a3,0xfff80
ffffffffc0203226:	97b6                	add	a5,a5,a3
ffffffffc0203228:	000b3603          	ld	a2,0(s6)
ffffffffc020322c:	00379693          	slli	a3,a5,0x3
ffffffffc0203230:	97b6                	add	a5,a5,a3
ffffffffc0203232:	078e                	slli	a5,a5,0x3
ffffffffc0203234:	97b2                	add	a5,a5,a2
ffffffffc0203236:	72fa1263          	bne	s4,a5,ffffffffc020395a <pmm_init+0x9f4>
    assert((*ptep & PTE_U) == 0);
ffffffffc020323a:	8b41                	andi	a4,a4,16
ffffffffc020323c:	6e071f63          	bnez	a4,ffffffffc020393a <pmm_init+0x9d4>

    page_remove(boot_pgdir, 0x0);
ffffffffc0203240:	00093503          	ld	a0,0(s2)
ffffffffc0203244:	4581                	li	a1,0
ffffffffc0203246:	b87ff0ef          	jal	ra,ffffffffc0202dcc <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc020324a:	000a2703          	lw	a4,0(s4)
ffffffffc020324e:	4785                	li	a5,1
ffffffffc0203250:	6cf71563          	bne	a4,a5,ffffffffc020391a <pmm_init+0x9b4>
    assert(page_ref(p2) == 0);
ffffffffc0203254:	000aa783          	lw	a5,0(s5)
ffffffffc0203258:	78079d63          	bnez	a5,ffffffffc02039f2 <pmm_init+0xa8c>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc020325c:	00093503          	ld	a0,0(s2)
ffffffffc0203260:	6585                	lui	a1,0x1
ffffffffc0203262:	b6bff0ef          	jal	ra,ffffffffc0202dcc <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0203266:	000a2783          	lw	a5,0(s4)
ffffffffc020326a:	76079463          	bnez	a5,ffffffffc02039d2 <pmm_init+0xa6c>
    assert(page_ref(p2) == 0);
ffffffffc020326e:	000aa783          	lw	a5,0(s5)
ffffffffc0203272:	74079063          	bnez	a5,ffffffffc02039b2 <pmm_init+0xa4c>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0203276:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc020327a:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020327c:	000a3783          	ld	a5,0(s4)
ffffffffc0203280:	078a                	slli	a5,a5,0x2
ffffffffc0203282:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203284:	42c7f263          	bgeu	a5,a2,ffffffffc02036a8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0203288:	fff80737          	lui	a4,0xfff80
ffffffffc020328c:	973e                	add	a4,a4,a5
ffffffffc020328e:	00371793          	slli	a5,a4,0x3
ffffffffc0203292:	000b3503          	ld	a0,0(s6)
ffffffffc0203296:	97ba                	add	a5,a5,a4
ffffffffc0203298:	078e                	slli	a5,a5,0x3
static inline int page_ref(struct Page *page) { return page->ref; }
ffffffffc020329a:	00f50733          	add	a4,a0,a5
ffffffffc020329e:	4314                	lw	a3,0(a4)
ffffffffc02032a0:	4705                	li	a4,1
ffffffffc02032a2:	6ee69863          	bne	a3,a4,ffffffffc0203992 <pmm_init+0xa2c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02032a6:	4037d693          	srai	a3,a5,0x3
ffffffffc02032aa:	00003c97          	auipc	s9,0x3
ffffffffc02032ae:	0cecbc83          	ld	s9,206(s9) # ffffffffc0206378 <error_string+0x38>
ffffffffc02032b2:	039686b3          	mul	a3,a3,s9
ffffffffc02032b6:	000805b7          	lui	a1,0x80
ffffffffc02032ba:	96ae                	add	a3,a3,a1
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02032bc:	00c69713          	slli	a4,a3,0xc
ffffffffc02032c0:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02032c2:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02032c4:	6ac77b63          	bgeu	a4,a2,ffffffffc020397a <pmm_init+0xa14>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc02032c8:	0009b703          	ld	a4,0(s3)
ffffffffc02032cc:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc02032ce:	629c                	ld	a5,0(a3)
ffffffffc02032d0:	078a                	slli	a5,a5,0x2
ffffffffc02032d2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02032d4:	3cc7fa63          	bgeu	a5,a2,ffffffffc02036a8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02032d8:	8f8d                	sub	a5,a5,a1
ffffffffc02032da:	00379713          	slli	a4,a5,0x3
ffffffffc02032de:	97ba                	add	a5,a5,a4
ffffffffc02032e0:	078e                	slli	a5,a5,0x3
ffffffffc02032e2:	953e                	add	a0,a0,a5
ffffffffc02032e4:	100027f3          	csrr	a5,sstatus
ffffffffc02032e8:	8b89                	andi	a5,a5,2
ffffffffc02032ea:	2e079963          	bnez	a5,ffffffffc02035dc <pmm_init+0x676>
    { pmm_manager->free_pages(base, n); }
ffffffffc02032ee:	000bb783          	ld	a5,0(s7)
ffffffffc02032f2:	4585                	li	a1,1
ffffffffc02032f4:	739c                	ld	a5,32(a5)
ffffffffc02032f6:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02032f8:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02032fc:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02032fe:	078a                	slli	a5,a5,0x2
ffffffffc0203300:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203302:	3ae7f363          	bgeu	a5,a4,ffffffffc02036a8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0203306:	fff80737          	lui	a4,0xfff80
ffffffffc020330a:	97ba                	add	a5,a5,a4
ffffffffc020330c:	000b3503          	ld	a0,0(s6)
ffffffffc0203310:	00379713          	slli	a4,a5,0x3
ffffffffc0203314:	97ba                	add	a5,a5,a4
ffffffffc0203316:	078e                	slli	a5,a5,0x3
ffffffffc0203318:	953e                	add	a0,a0,a5
ffffffffc020331a:	100027f3          	csrr	a5,sstatus
ffffffffc020331e:	8b89                	andi	a5,a5,2
ffffffffc0203320:	2a079263          	bnez	a5,ffffffffc02035c4 <pmm_init+0x65e>
ffffffffc0203324:	000bb783          	ld	a5,0(s7)
ffffffffc0203328:	4585                	li	a1,1
ffffffffc020332a:	739c                	ld	a5,32(a5)
ffffffffc020332c:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc020332e:	00093783          	ld	a5,0(s2)
ffffffffc0203332:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fdeda98>
ffffffffc0203336:	100027f3          	csrr	a5,sstatus
ffffffffc020333a:	8b89                	andi	a5,a5,2
ffffffffc020333c:	26079a63          	bnez	a5,ffffffffc02035b0 <pmm_init+0x64a>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0203340:	000bb783          	ld	a5,0(s7)
ffffffffc0203344:	779c                	ld	a5,40(a5)
ffffffffc0203346:	9782                	jalr	a5
ffffffffc0203348:	8a2a                	mv	s4,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc020334a:	73441463          	bne	s0,s4,ffffffffc0203a72 <pmm_init+0xb0c>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc020334e:	00003517          	auipc	a0,0x3
ffffffffc0203352:	b6250513          	addi	a0,a0,-1182 # ffffffffc0205eb0 <default_pmm_manager+0x408>
ffffffffc0203356:	d65fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020335a:	100027f3          	csrr	a5,sstatus
ffffffffc020335e:	8b89                	andi	a5,a5,2
ffffffffc0203360:	22079e63          	bnez	a5,ffffffffc020359c <pmm_init+0x636>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0203364:	000bb783          	ld	a5,0(s7)
ffffffffc0203368:	779c                	ld	a5,40(a5)
ffffffffc020336a:	9782                	jalr	a5
ffffffffc020336c:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020336e:	6098                	ld	a4,0(s1)
ffffffffc0203370:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203374:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0203376:	00c71793          	slli	a5,a4,0xc
ffffffffc020337a:	6a05                	lui	s4,0x1
ffffffffc020337c:	02f47c63          	bgeu	s0,a5,ffffffffc02033b4 <pmm_init+0x44e>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0203380:	00c45793          	srli	a5,s0,0xc
ffffffffc0203384:	00093503          	ld	a0,0(s2)
ffffffffc0203388:	30e7f363          	bgeu	a5,a4,ffffffffc020368e <pmm_init+0x728>
ffffffffc020338c:	0009b583          	ld	a1,0(s3)
ffffffffc0203390:	4601                	li	a2,0
ffffffffc0203392:	95a2                	add	a1,a1,s0
ffffffffc0203394:	fe8ff0ef          	jal	ra,ffffffffc0202b7c <get_pte>
ffffffffc0203398:	2c050b63          	beqz	a0,ffffffffc020366e <pmm_init+0x708>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020339c:	611c                	ld	a5,0(a0)
ffffffffc020339e:	078a                	slli	a5,a5,0x2
ffffffffc02033a0:	0157f7b3          	and	a5,a5,s5
ffffffffc02033a4:	2a879563          	bne	a5,s0,ffffffffc020364e <pmm_init+0x6e8>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02033a8:	6098                	ld	a4,0(s1)
ffffffffc02033aa:	9452                	add	s0,s0,s4
ffffffffc02033ac:	00c71793          	slli	a5,a4,0xc
ffffffffc02033b0:	fcf468e3          	bltu	s0,a5,ffffffffc0203380 <pmm_init+0x41a>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc02033b4:	00093783          	ld	a5,0(s2)
ffffffffc02033b8:	639c                	ld	a5,0(a5)
ffffffffc02033ba:	68079c63          	bnez	a5,ffffffffc0203a52 <pmm_init+0xaec>

    struct Page *p;
    p = alloc_page();
ffffffffc02033be:	4505                	li	a0,1
ffffffffc02033c0:	eb0ff0ef          	jal	ra,ffffffffc0202a70 <alloc_pages>
ffffffffc02033c4:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02033c6:	00093503          	ld	a0,0(s2)
ffffffffc02033ca:	4699                	li	a3,6
ffffffffc02033cc:	10000613          	li	a2,256
ffffffffc02033d0:	85d6                	mv	a1,s5
ffffffffc02033d2:	a95ff0ef          	jal	ra,ffffffffc0202e66 <page_insert>
ffffffffc02033d6:	64051e63          	bnez	a0,ffffffffc0203a32 <pmm_init+0xacc>
    assert(page_ref(p) == 1);
ffffffffc02033da:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fdeda98>
ffffffffc02033de:	4785                	li	a5,1
ffffffffc02033e0:	62f71963          	bne	a4,a5,ffffffffc0203a12 <pmm_init+0xaac>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02033e4:	00093503          	ld	a0,0(s2)
ffffffffc02033e8:	6405                	lui	s0,0x1
ffffffffc02033ea:	4699                	li	a3,6
ffffffffc02033ec:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc02033f0:	85d6                	mv	a1,s5
ffffffffc02033f2:	a75ff0ef          	jal	ra,ffffffffc0202e66 <page_insert>
ffffffffc02033f6:	48051263          	bnez	a0,ffffffffc020387a <pmm_init+0x914>
    assert(page_ref(p) == 2);
ffffffffc02033fa:	000aa703          	lw	a4,0(s5)
ffffffffc02033fe:	4789                	li	a5,2
ffffffffc0203400:	74f71563          	bne	a4,a5,ffffffffc0203b4a <pmm_init+0xbe4>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0203404:	00003597          	auipc	a1,0x3
ffffffffc0203408:	be458593          	addi	a1,a1,-1052 # ffffffffc0205fe8 <default_pmm_manager+0x540>
ffffffffc020340c:	10000513          	li	a0,256
ffffffffc0203410:	35d000ef          	jal	ra,ffffffffc0203f6c <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203414:	10040593          	addi	a1,s0,256
ffffffffc0203418:	10000513          	li	a0,256
ffffffffc020341c:	363000ef          	jal	ra,ffffffffc0203f7e <strcmp>
ffffffffc0203420:	70051563          	bnez	a0,ffffffffc0203b2a <pmm_init+0xbc4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203424:	000b3683          	ld	a3,0(s6)
ffffffffc0203428:	00080d37          	lui	s10,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020342c:	547d                	li	s0,-1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020342e:	40da86b3          	sub	a3,s5,a3
ffffffffc0203432:	868d                	srai	a3,a3,0x3
ffffffffc0203434:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203438:	609c                	ld	a5,0(s1)
ffffffffc020343a:	8031                	srli	s0,s0,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020343c:	96ea                	add	a3,a3,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020343e:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0203442:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203444:	52f77b63          	bgeu	a4,a5,ffffffffc020397a <pmm_init+0xa14>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0203448:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020344c:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0203450:	96be                	add	a3,a3,a5
ffffffffc0203452:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fd6eb98>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203456:	2e1000ef          	jal	ra,ffffffffc0203f36 <strlen>
ffffffffc020345a:	6a051863          	bnez	a0,ffffffffc0203b0a <pmm_init+0xba4>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc020345e:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203462:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203464:	000a3783          	ld	a5,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0203468:	078a                	slli	a5,a5,0x2
ffffffffc020346a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020346c:	22e7fe63          	bgeu	a5,a4,ffffffffc02036a8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0203470:	41a787b3          	sub	a5,a5,s10
ffffffffc0203474:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203478:	96be                	add	a3,a3,a5
ffffffffc020347a:	03968cb3          	mul	s9,a3,s9
ffffffffc020347e:	01ac86b3          	add	a3,s9,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203482:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203484:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203486:	4ee47a63          	bgeu	s0,a4,ffffffffc020397a <pmm_init+0xa14>
ffffffffc020348a:	0009b403          	ld	s0,0(s3)
ffffffffc020348e:	9436                	add	s0,s0,a3
ffffffffc0203490:	100027f3          	csrr	a5,sstatus
ffffffffc0203494:	8b89                	andi	a5,a5,2
ffffffffc0203496:	1a079163          	bnez	a5,ffffffffc0203638 <pmm_init+0x6d2>
    { pmm_manager->free_pages(base, n); }
ffffffffc020349a:	000bb783          	ld	a5,0(s7)
ffffffffc020349e:	4585                	li	a1,1
ffffffffc02034a0:	8556                	mv	a0,s5
ffffffffc02034a2:	739c                	ld	a5,32(a5)
ffffffffc02034a4:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02034a6:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02034a8:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02034aa:	078a                	slli	a5,a5,0x2
ffffffffc02034ac:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02034ae:	1ee7fd63          	bgeu	a5,a4,ffffffffc02036a8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02034b2:	fff80737          	lui	a4,0xfff80
ffffffffc02034b6:	97ba                	add	a5,a5,a4
ffffffffc02034b8:	000b3503          	ld	a0,0(s6)
ffffffffc02034bc:	00379713          	slli	a4,a5,0x3
ffffffffc02034c0:	97ba                	add	a5,a5,a4
ffffffffc02034c2:	078e                	slli	a5,a5,0x3
ffffffffc02034c4:	953e                	add	a0,a0,a5
ffffffffc02034c6:	100027f3          	csrr	a5,sstatus
ffffffffc02034ca:	8b89                	andi	a5,a5,2
ffffffffc02034cc:	14079a63          	bnez	a5,ffffffffc0203620 <pmm_init+0x6ba>
ffffffffc02034d0:	000bb783          	ld	a5,0(s7)
ffffffffc02034d4:	4585                	li	a1,1
ffffffffc02034d6:	739c                	ld	a5,32(a5)
ffffffffc02034d8:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02034da:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02034de:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02034e0:	078a                	slli	a5,a5,0x2
ffffffffc02034e2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02034e4:	1ce7f263          	bgeu	a5,a4,ffffffffc02036a8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02034e8:	fff80737          	lui	a4,0xfff80
ffffffffc02034ec:	97ba                	add	a5,a5,a4
ffffffffc02034ee:	000b3503          	ld	a0,0(s6)
ffffffffc02034f2:	00379713          	slli	a4,a5,0x3
ffffffffc02034f6:	97ba                	add	a5,a5,a4
ffffffffc02034f8:	078e                	slli	a5,a5,0x3
ffffffffc02034fa:	953e                	add	a0,a0,a5
ffffffffc02034fc:	100027f3          	csrr	a5,sstatus
ffffffffc0203500:	8b89                	andi	a5,a5,2
ffffffffc0203502:	10079363          	bnez	a5,ffffffffc0203608 <pmm_init+0x6a2>
ffffffffc0203506:	000bb783          	ld	a5,0(s7)
ffffffffc020350a:	4585                	li	a1,1
ffffffffc020350c:	739c                	ld	a5,32(a5)
ffffffffc020350e:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0203510:	00093783          	ld	a5,0(s2)
ffffffffc0203514:	0007b023          	sd	zero,0(a5)
ffffffffc0203518:	100027f3          	csrr	a5,sstatus
ffffffffc020351c:	8b89                	andi	a5,a5,2
ffffffffc020351e:	0c079b63          	bnez	a5,ffffffffc02035f4 <pmm_init+0x68e>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0203522:	000bb783          	ld	a5,0(s7)
ffffffffc0203526:	779c                	ld	a5,40(a5)
ffffffffc0203528:	9782                	jalr	a5
ffffffffc020352a:	842a                	mv	s0,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc020352c:	3a8c1763          	bne	s8,s0,ffffffffc02038da <pmm_init+0x974>
}
ffffffffc0203530:	7406                	ld	s0,96(sp)
ffffffffc0203532:	70a6                	ld	ra,104(sp)
ffffffffc0203534:	64e6                	ld	s1,88(sp)
ffffffffc0203536:	6946                	ld	s2,80(sp)
ffffffffc0203538:	69a6                	ld	s3,72(sp)
ffffffffc020353a:	6a06                	ld	s4,64(sp)
ffffffffc020353c:	7ae2                	ld	s5,56(sp)
ffffffffc020353e:	7b42                	ld	s6,48(sp)
ffffffffc0203540:	7ba2                	ld	s7,40(sp)
ffffffffc0203542:	7c02                	ld	s8,32(sp)
ffffffffc0203544:	6ce2                	ld	s9,24(sp)
ffffffffc0203546:	6d42                	ld	s10,16(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0203548:	00003517          	auipc	a0,0x3
ffffffffc020354c:	b1850513          	addi	a0,a0,-1256 # ffffffffc0206060 <default_pmm_manager+0x5b8>
}
ffffffffc0203550:	6165                	addi	sp,sp,112
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0203552:	b69fc06f          	j	ffffffffc02000ba <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0203556:	6705                	lui	a4,0x1
ffffffffc0203558:	177d                	addi	a4,a4,-1
ffffffffc020355a:	96ba                	add	a3,a3,a4
ffffffffc020355c:	777d                	lui	a4,0xfffff
ffffffffc020355e:	8f75                	and	a4,a4,a3
    if (PPN(pa) >= npage) {
ffffffffc0203560:	00c75693          	srli	a3,a4,0xc
ffffffffc0203564:	14f6f263          	bgeu	a3,a5,ffffffffc02036a8 <pmm_init+0x742>
    pmm_manager->init_memmap(base, n);
ffffffffc0203568:	000bb803          	ld	a6,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc020356c:	95b6                	add	a1,a1,a3
ffffffffc020356e:	00359793          	slli	a5,a1,0x3
ffffffffc0203572:	97ae                	add	a5,a5,a1
ffffffffc0203574:	01083683          	ld	a3,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0203578:	40e60733          	sub	a4,a2,a4
ffffffffc020357c:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc020357e:	00c75593          	srli	a1,a4,0xc
ffffffffc0203582:	953e                	add	a0,a0,a5
ffffffffc0203584:	9682                	jalr	a3
}
ffffffffc0203586:	bcc5                	j	ffffffffc0203076 <pmm_init+0x110>
        intr_disable();
ffffffffc0203588:	f67fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020358c:	000bb783          	ld	a5,0(s7)
ffffffffc0203590:	779c                	ld	a5,40(a5)
ffffffffc0203592:	9782                	jalr	a5
ffffffffc0203594:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203596:	f53fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020359a:	b63d                	j	ffffffffc02030c8 <pmm_init+0x162>
        intr_disable();
ffffffffc020359c:	f53fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02035a0:	000bb783          	ld	a5,0(s7)
ffffffffc02035a4:	779c                	ld	a5,40(a5)
ffffffffc02035a6:	9782                	jalr	a5
ffffffffc02035a8:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc02035aa:	f3ffc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02035ae:	b3c1                	j	ffffffffc020336e <pmm_init+0x408>
        intr_disable();
ffffffffc02035b0:	f3ffc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02035b4:	000bb783          	ld	a5,0(s7)
ffffffffc02035b8:	779c                	ld	a5,40(a5)
ffffffffc02035ba:	9782                	jalr	a5
ffffffffc02035bc:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc02035be:	f2bfc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02035c2:	b361                	j	ffffffffc020334a <pmm_init+0x3e4>
ffffffffc02035c4:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02035c6:	f29fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc02035ca:	000bb783          	ld	a5,0(s7)
ffffffffc02035ce:	6522                	ld	a0,8(sp)
ffffffffc02035d0:	4585                	li	a1,1
ffffffffc02035d2:	739c                	ld	a5,32(a5)
ffffffffc02035d4:	9782                	jalr	a5
        intr_enable();
ffffffffc02035d6:	f13fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02035da:	bb91                	j	ffffffffc020332e <pmm_init+0x3c8>
ffffffffc02035dc:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02035de:	f11fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02035e2:	000bb783          	ld	a5,0(s7)
ffffffffc02035e6:	6522                	ld	a0,8(sp)
ffffffffc02035e8:	4585                	li	a1,1
ffffffffc02035ea:	739c                	ld	a5,32(a5)
ffffffffc02035ec:	9782                	jalr	a5
        intr_enable();
ffffffffc02035ee:	efbfc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02035f2:	b319                	j	ffffffffc02032f8 <pmm_init+0x392>
        intr_disable();
ffffffffc02035f4:	efbfc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02035f8:	000bb783          	ld	a5,0(s7)
ffffffffc02035fc:	779c                	ld	a5,40(a5)
ffffffffc02035fe:	9782                	jalr	a5
ffffffffc0203600:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203602:	ee7fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203606:	b71d                	j	ffffffffc020352c <pmm_init+0x5c6>
ffffffffc0203608:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020360a:	ee5fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020360e:	000bb783          	ld	a5,0(s7)
ffffffffc0203612:	6522                	ld	a0,8(sp)
ffffffffc0203614:	4585                	li	a1,1
ffffffffc0203616:	739c                	ld	a5,32(a5)
ffffffffc0203618:	9782                	jalr	a5
        intr_enable();
ffffffffc020361a:	ecffc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020361e:	bdcd                	j	ffffffffc0203510 <pmm_init+0x5aa>
ffffffffc0203620:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203622:	ecdfc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0203626:	000bb783          	ld	a5,0(s7)
ffffffffc020362a:	6522                	ld	a0,8(sp)
ffffffffc020362c:	4585                	li	a1,1
ffffffffc020362e:	739c                	ld	a5,32(a5)
ffffffffc0203630:	9782                	jalr	a5
        intr_enable();
ffffffffc0203632:	eb7fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203636:	b555                	j	ffffffffc02034da <pmm_init+0x574>
        intr_disable();
ffffffffc0203638:	eb7fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc020363c:	000bb783          	ld	a5,0(s7)
ffffffffc0203640:	4585                	li	a1,1
ffffffffc0203642:	8556                	mv	a0,s5
ffffffffc0203644:	739c                	ld	a5,32(a5)
ffffffffc0203646:	9782                	jalr	a5
        intr_enable();
ffffffffc0203648:	ea1fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020364c:	bda9                	j	ffffffffc02034a6 <pmm_init+0x540>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020364e:	00003697          	auipc	a3,0x3
ffffffffc0203652:	8c268693          	addi	a3,a3,-1854 # ffffffffc0205f10 <default_pmm_manager+0x468>
ffffffffc0203656:	00001617          	auipc	a2,0x1
ffffffffc020365a:	7ca60613          	addi	a2,a2,1994 # ffffffffc0204e20 <commands+0x728>
ffffffffc020365e:	1ce00593          	li	a1,462
ffffffffc0203662:	00002517          	auipc	a0,0x2
ffffffffc0203666:	4a650513          	addi	a0,a0,1190 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc020366a:	a99fc0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020366e:	00003697          	auipc	a3,0x3
ffffffffc0203672:	86268693          	addi	a3,a3,-1950 # ffffffffc0205ed0 <default_pmm_manager+0x428>
ffffffffc0203676:	00001617          	auipc	a2,0x1
ffffffffc020367a:	7aa60613          	addi	a2,a2,1962 # ffffffffc0204e20 <commands+0x728>
ffffffffc020367e:	1cd00593          	li	a1,461
ffffffffc0203682:	00002517          	auipc	a0,0x2
ffffffffc0203686:	48650513          	addi	a0,a0,1158 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc020368a:	a79fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc020368e:	86a2                	mv	a3,s0
ffffffffc0203690:	00002617          	auipc	a2,0x2
ffffffffc0203694:	45060613          	addi	a2,a2,1104 # ffffffffc0205ae0 <default_pmm_manager+0x38>
ffffffffc0203698:	1cd00593          	li	a1,461
ffffffffc020369c:	00002517          	auipc	a0,0x2
ffffffffc02036a0:	46c50513          	addi	a0,a0,1132 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc02036a4:	a5ffc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc02036a8:	b90ff0ef          	jal	ra,ffffffffc0202a38 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02036ac:	00002617          	auipc	a2,0x2
ffffffffc02036b0:	4f460613          	addi	a2,a2,1268 # ffffffffc0205ba0 <default_pmm_manager+0xf8>
ffffffffc02036b4:	07700593          	li	a1,119
ffffffffc02036b8:	00002517          	auipc	a0,0x2
ffffffffc02036bc:	45050513          	addi	a0,a0,1104 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc02036c0:	a43fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02036c4:	00002617          	auipc	a2,0x2
ffffffffc02036c8:	4dc60613          	addi	a2,a2,1244 # ffffffffc0205ba0 <default_pmm_manager+0xf8>
ffffffffc02036cc:	0bd00593          	li	a1,189
ffffffffc02036d0:	00002517          	auipc	a0,0x2
ffffffffc02036d4:	43850513          	addi	a0,a0,1080 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc02036d8:	a2bfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02036dc:	00002697          	auipc	a3,0x2
ffffffffc02036e0:	52c68693          	addi	a3,a3,1324 # ffffffffc0205c08 <default_pmm_manager+0x160>
ffffffffc02036e4:	00001617          	auipc	a2,0x1
ffffffffc02036e8:	73c60613          	addi	a2,a2,1852 # ffffffffc0204e20 <commands+0x728>
ffffffffc02036ec:	19300593          	li	a1,403
ffffffffc02036f0:	00002517          	auipc	a0,0x2
ffffffffc02036f4:	41850513          	addi	a0,a0,1048 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc02036f8:	a0bfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02036fc:	00002697          	auipc	a3,0x2
ffffffffc0203700:	4ec68693          	addi	a3,a3,1260 # ffffffffc0205be8 <default_pmm_manager+0x140>
ffffffffc0203704:	00001617          	auipc	a2,0x1
ffffffffc0203708:	71c60613          	addi	a2,a2,1820 # ffffffffc0204e20 <commands+0x728>
ffffffffc020370c:	19200593          	li	a1,402
ffffffffc0203710:	00002517          	auipc	a0,0x2
ffffffffc0203714:	3f850513          	addi	a0,a0,1016 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc0203718:	9ebfc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc020371c:	b38ff0ef          	jal	ra,ffffffffc0202a54 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0203720:	00002697          	auipc	a3,0x2
ffffffffc0203724:	57868693          	addi	a3,a3,1400 # ffffffffc0205c98 <default_pmm_manager+0x1f0>
ffffffffc0203728:	00001617          	auipc	a2,0x1
ffffffffc020372c:	6f860613          	addi	a2,a2,1784 # ffffffffc0204e20 <commands+0x728>
ffffffffc0203730:	19a00593          	li	a1,410
ffffffffc0203734:	00002517          	auipc	a0,0x2
ffffffffc0203738:	3d450513          	addi	a0,a0,980 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc020373c:	9c7fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0203740:	00002697          	auipc	a3,0x2
ffffffffc0203744:	52868693          	addi	a3,a3,1320 # ffffffffc0205c68 <default_pmm_manager+0x1c0>
ffffffffc0203748:	00001617          	auipc	a2,0x1
ffffffffc020374c:	6d860613          	addi	a2,a2,1752 # ffffffffc0204e20 <commands+0x728>
ffffffffc0203750:	19800593          	li	a1,408
ffffffffc0203754:	00002517          	auipc	a0,0x2
ffffffffc0203758:	3b450513          	addi	a0,a0,948 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc020375c:	9a7fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0203760:	00002697          	auipc	a3,0x2
ffffffffc0203764:	4e068693          	addi	a3,a3,1248 # ffffffffc0205c40 <default_pmm_manager+0x198>
ffffffffc0203768:	00001617          	auipc	a2,0x1
ffffffffc020376c:	6b860613          	addi	a2,a2,1720 # ffffffffc0204e20 <commands+0x728>
ffffffffc0203770:	19400593          	li	a1,404
ffffffffc0203774:	00002517          	auipc	a0,0x2
ffffffffc0203778:	39450513          	addi	a0,a0,916 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc020377c:	987fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203780:	00002697          	auipc	a3,0x2
ffffffffc0203784:	5a068693          	addi	a3,a3,1440 # ffffffffc0205d20 <default_pmm_manager+0x278>
ffffffffc0203788:	00001617          	auipc	a2,0x1
ffffffffc020378c:	69860613          	addi	a2,a2,1688 # ffffffffc0204e20 <commands+0x728>
ffffffffc0203790:	1a300593          	li	a1,419
ffffffffc0203794:	00002517          	auipc	a0,0x2
ffffffffc0203798:	37450513          	addi	a0,a0,884 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc020379c:	967fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02037a0:	00002697          	auipc	a3,0x2
ffffffffc02037a4:	62068693          	addi	a3,a3,1568 # ffffffffc0205dc0 <default_pmm_manager+0x318>
ffffffffc02037a8:	00001617          	auipc	a2,0x1
ffffffffc02037ac:	67860613          	addi	a2,a2,1656 # ffffffffc0204e20 <commands+0x728>
ffffffffc02037b0:	1a800593          	li	a1,424
ffffffffc02037b4:	00002517          	auipc	a0,0x2
ffffffffc02037b8:	35450513          	addi	a0,a0,852 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc02037bc:	947fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02037c0:	00002697          	auipc	a3,0x2
ffffffffc02037c4:	53868693          	addi	a3,a3,1336 # ffffffffc0205cf8 <default_pmm_manager+0x250>
ffffffffc02037c8:	00001617          	auipc	a2,0x1
ffffffffc02037cc:	65860613          	addi	a2,a2,1624 # ffffffffc0204e20 <commands+0x728>
ffffffffc02037d0:	1a000593          	li	a1,416
ffffffffc02037d4:	00002517          	auipc	a0,0x2
ffffffffc02037d8:	33450513          	addi	a0,a0,820 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc02037dc:	927fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02037e0:	86d6                	mv	a3,s5
ffffffffc02037e2:	00002617          	auipc	a2,0x2
ffffffffc02037e6:	2fe60613          	addi	a2,a2,766 # ffffffffc0205ae0 <default_pmm_manager+0x38>
ffffffffc02037ea:	19f00593          	li	a1,415
ffffffffc02037ee:	00002517          	auipc	a0,0x2
ffffffffc02037f2:	31a50513          	addi	a0,a0,794 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc02037f6:	90dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02037fa:	00002697          	auipc	a3,0x2
ffffffffc02037fe:	55e68693          	addi	a3,a3,1374 # ffffffffc0205d58 <default_pmm_manager+0x2b0>
ffffffffc0203802:	00001617          	auipc	a2,0x1
ffffffffc0203806:	61e60613          	addi	a2,a2,1566 # ffffffffc0204e20 <commands+0x728>
ffffffffc020380a:	1ad00593          	li	a1,429
ffffffffc020380e:	00002517          	auipc	a0,0x2
ffffffffc0203812:	2fa50513          	addi	a0,a0,762 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc0203816:	8edfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020381a:	00002697          	auipc	a3,0x2
ffffffffc020381e:	60668693          	addi	a3,a3,1542 # ffffffffc0205e20 <default_pmm_manager+0x378>
ffffffffc0203822:	00001617          	auipc	a2,0x1
ffffffffc0203826:	5fe60613          	addi	a2,a2,1534 # ffffffffc0204e20 <commands+0x728>
ffffffffc020382a:	1ac00593          	li	a1,428
ffffffffc020382e:	00002517          	auipc	a0,0x2
ffffffffc0203832:	2da50513          	addi	a0,a0,730 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc0203836:	8cdfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc020383a:	00002697          	auipc	a3,0x2
ffffffffc020383e:	5ce68693          	addi	a3,a3,1486 # ffffffffc0205e08 <default_pmm_manager+0x360>
ffffffffc0203842:	00001617          	auipc	a2,0x1
ffffffffc0203846:	5de60613          	addi	a2,a2,1502 # ffffffffc0204e20 <commands+0x728>
ffffffffc020384a:	1ab00593          	li	a1,427
ffffffffc020384e:	00002517          	auipc	a0,0x2
ffffffffc0203852:	2ba50513          	addi	a0,a0,698 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc0203856:	8adfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020385a:	00002697          	auipc	a3,0x2
ffffffffc020385e:	57e68693          	addi	a3,a3,1406 # ffffffffc0205dd8 <default_pmm_manager+0x330>
ffffffffc0203862:	00001617          	auipc	a2,0x1
ffffffffc0203866:	5be60613          	addi	a2,a2,1470 # ffffffffc0204e20 <commands+0x728>
ffffffffc020386a:	1aa00593          	li	a1,426
ffffffffc020386e:	00002517          	auipc	a0,0x2
ffffffffc0203872:	29a50513          	addi	a0,a0,666 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc0203876:	88dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020387a:	00002697          	auipc	a3,0x2
ffffffffc020387e:	71668693          	addi	a3,a3,1814 # ffffffffc0205f90 <default_pmm_manager+0x4e8>
ffffffffc0203882:	00001617          	auipc	a2,0x1
ffffffffc0203886:	59e60613          	addi	a2,a2,1438 # ffffffffc0204e20 <commands+0x728>
ffffffffc020388a:	1d800593          	li	a1,472
ffffffffc020388e:	00002517          	auipc	a0,0x2
ffffffffc0203892:	27a50513          	addi	a0,a0,634 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc0203896:	86dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020389a:	00002697          	auipc	a3,0x2
ffffffffc020389e:	50e68693          	addi	a3,a3,1294 # ffffffffc0205da8 <default_pmm_manager+0x300>
ffffffffc02038a2:	00001617          	auipc	a2,0x1
ffffffffc02038a6:	57e60613          	addi	a2,a2,1406 # ffffffffc0204e20 <commands+0x728>
ffffffffc02038aa:	1a700593          	li	a1,423
ffffffffc02038ae:	00002517          	auipc	a0,0x2
ffffffffc02038b2:	25a50513          	addi	a0,a0,602 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc02038b6:	84dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02038ba:	00002697          	auipc	a3,0x2
ffffffffc02038be:	4de68693          	addi	a3,a3,1246 # ffffffffc0205d98 <default_pmm_manager+0x2f0>
ffffffffc02038c2:	00001617          	auipc	a2,0x1
ffffffffc02038c6:	55e60613          	addi	a2,a2,1374 # ffffffffc0204e20 <commands+0x728>
ffffffffc02038ca:	1a600593          	li	a1,422
ffffffffc02038ce:	00002517          	auipc	a0,0x2
ffffffffc02038d2:	23a50513          	addi	a0,a0,570 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc02038d6:	82dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02038da:	00002697          	auipc	a3,0x2
ffffffffc02038de:	5b668693          	addi	a3,a3,1462 # ffffffffc0205e90 <default_pmm_manager+0x3e8>
ffffffffc02038e2:	00001617          	auipc	a2,0x1
ffffffffc02038e6:	53e60613          	addi	a2,a2,1342 # ffffffffc0204e20 <commands+0x728>
ffffffffc02038ea:	1e800593          	li	a1,488
ffffffffc02038ee:	00002517          	auipc	a0,0x2
ffffffffc02038f2:	21a50513          	addi	a0,a0,538 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc02038f6:	80dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*ptep & PTE_U);
ffffffffc02038fa:	00002697          	auipc	a3,0x2
ffffffffc02038fe:	48e68693          	addi	a3,a3,1166 # ffffffffc0205d88 <default_pmm_manager+0x2e0>
ffffffffc0203902:	00001617          	auipc	a2,0x1
ffffffffc0203906:	51e60613          	addi	a2,a2,1310 # ffffffffc0204e20 <commands+0x728>
ffffffffc020390a:	1a500593          	li	a1,421
ffffffffc020390e:	00002517          	auipc	a0,0x2
ffffffffc0203912:	1fa50513          	addi	a0,a0,506 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc0203916:	fecfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020391a:	00002697          	auipc	a3,0x2
ffffffffc020391e:	3c668693          	addi	a3,a3,966 # ffffffffc0205ce0 <default_pmm_manager+0x238>
ffffffffc0203922:	00001617          	auipc	a2,0x1
ffffffffc0203926:	4fe60613          	addi	a2,a2,1278 # ffffffffc0204e20 <commands+0x728>
ffffffffc020392a:	1b200593          	li	a1,434
ffffffffc020392e:	00002517          	auipc	a0,0x2
ffffffffc0203932:	1da50513          	addi	a0,a0,474 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc0203936:	fccfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020393a:	00002697          	auipc	a3,0x2
ffffffffc020393e:	4fe68693          	addi	a3,a3,1278 # ffffffffc0205e38 <default_pmm_manager+0x390>
ffffffffc0203942:	00001617          	auipc	a2,0x1
ffffffffc0203946:	4de60613          	addi	a2,a2,1246 # ffffffffc0204e20 <commands+0x728>
ffffffffc020394a:	1af00593          	li	a1,431
ffffffffc020394e:	00002517          	auipc	a0,0x2
ffffffffc0203952:	1ba50513          	addi	a0,a0,442 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc0203956:	facfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020395a:	00002697          	auipc	a3,0x2
ffffffffc020395e:	36e68693          	addi	a3,a3,878 # ffffffffc0205cc8 <default_pmm_manager+0x220>
ffffffffc0203962:	00001617          	auipc	a2,0x1
ffffffffc0203966:	4be60613          	addi	a2,a2,1214 # ffffffffc0204e20 <commands+0x728>
ffffffffc020396a:	1ae00593          	li	a1,430
ffffffffc020396e:	00002517          	auipc	a0,0x2
ffffffffc0203972:	19a50513          	addi	a0,a0,410 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc0203976:	f8cfc0ef          	jal	ra,ffffffffc0200102 <__panic>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020397a:	00002617          	auipc	a2,0x2
ffffffffc020397e:	16660613          	addi	a2,a2,358 # ffffffffc0205ae0 <default_pmm_manager+0x38>
ffffffffc0203982:	06a00593          	li	a1,106
ffffffffc0203986:	00001517          	auipc	a0,0x1
ffffffffc020398a:	70a50513          	addi	a0,a0,1802 # ffffffffc0205090 <commands+0x998>
ffffffffc020398e:	f74fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0203992:	00002697          	auipc	a3,0x2
ffffffffc0203996:	4d668693          	addi	a3,a3,1238 # ffffffffc0205e68 <default_pmm_manager+0x3c0>
ffffffffc020399a:	00001617          	auipc	a2,0x1
ffffffffc020399e:	48660613          	addi	a2,a2,1158 # ffffffffc0204e20 <commands+0x728>
ffffffffc02039a2:	1b900593          	li	a1,441
ffffffffc02039a6:	00002517          	auipc	a0,0x2
ffffffffc02039aa:	16250513          	addi	a0,a0,354 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc02039ae:	f54fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02039b2:	00002697          	auipc	a3,0x2
ffffffffc02039b6:	46e68693          	addi	a3,a3,1134 # ffffffffc0205e20 <default_pmm_manager+0x378>
ffffffffc02039ba:	00001617          	auipc	a2,0x1
ffffffffc02039be:	46660613          	addi	a2,a2,1126 # ffffffffc0204e20 <commands+0x728>
ffffffffc02039c2:	1b700593          	li	a1,439
ffffffffc02039c6:	00002517          	auipc	a0,0x2
ffffffffc02039ca:	14250513          	addi	a0,a0,322 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc02039ce:	f34fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02039d2:	00002697          	auipc	a3,0x2
ffffffffc02039d6:	47e68693          	addi	a3,a3,1150 # ffffffffc0205e50 <default_pmm_manager+0x3a8>
ffffffffc02039da:	00001617          	auipc	a2,0x1
ffffffffc02039de:	44660613          	addi	a2,a2,1094 # ffffffffc0204e20 <commands+0x728>
ffffffffc02039e2:	1b600593          	li	a1,438
ffffffffc02039e6:	00002517          	auipc	a0,0x2
ffffffffc02039ea:	12250513          	addi	a0,a0,290 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc02039ee:	f14fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02039f2:	00002697          	auipc	a3,0x2
ffffffffc02039f6:	42e68693          	addi	a3,a3,1070 # ffffffffc0205e20 <default_pmm_manager+0x378>
ffffffffc02039fa:	00001617          	auipc	a2,0x1
ffffffffc02039fe:	42660613          	addi	a2,a2,1062 # ffffffffc0204e20 <commands+0x728>
ffffffffc0203a02:	1b300593          	li	a1,435
ffffffffc0203a06:	00002517          	auipc	a0,0x2
ffffffffc0203a0a:	10250513          	addi	a0,a0,258 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc0203a0e:	ef4fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0203a12:	00002697          	auipc	a3,0x2
ffffffffc0203a16:	56668693          	addi	a3,a3,1382 # ffffffffc0205f78 <default_pmm_manager+0x4d0>
ffffffffc0203a1a:	00001617          	auipc	a2,0x1
ffffffffc0203a1e:	40660613          	addi	a2,a2,1030 # ffffffffc0204e20 <commands+0x728>
ffffffffc0203a22:	1d700593          	li	a1,471
ffffffffc0203a26:	00002517          	auipc	a0,0x2
ffffffffc0203a2a:	0e250513          	addi	a0,a0,226 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc0203a2e:	ed4fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0203a32:	00002697          	auipc	a3,0x2
ffffffffc0203a36:	50e68693          	addi	a3,a3,1294 # ffffffffc0205f40 <default_pmm_manager+0x498>
ffffffffc0203a3a:	00001617          	auipc	a2,0x1
ffffffffc0203a3e:	3e660613          	addi	a2,a2,998 # ffffffffc0204e20 <commands+0x728>
ffffffffc0203a42:	1d600593          	li	a1,470
ffffffffc0203a46:	00002517          	auipc	a0,0x2
ffffffffc0203a4a:	0c250513          	addi	a0,a0,194 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc0203a4e:	eb4fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0203a52:	00002697          	auipc	a3,0x2
ffffffffc0203a56:	4d668693          	addi	a3,a3,1238 # ffffffffc0205f28 <default_pmm_manager+0x480>
ffffffffc0203a5a:	00001617          	auipc	a2,0x1
ffffffffc0203a5e:	3c660613          	addi	a2,a2,966 # ffffffffc0204e20 <commands+0x728>
ffffffffc0203a62:	1d200593          	li	a1,466
ffffffffc0203a66:	00002517          	auipc	a0,0x2
ffffffffc0203a6a:	0a250513          	addi	a0,a0,162 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc0203a6e:	e94fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203a72:	00002697          	auipc	a3,0x2
ffffffffc0203a76:	41e68693          	addi	a3,a3,1054 # ffffffffc0205e90 <default_pmm_manager+0x3e8>
ffffffffc0203a7a:	00001617          	auipc	a2,0x1
ffffffffc0203a7e:	3a660613          	addi	a2,a2,934 # ffffffffc0204e20 <commands+0x728>
ffffffffc0203a82:	1c000593          	li	a1,448
ffffffffc0203a86:	00002517          	auipc	a0,0x2
ffffffffc0203a8a:	08250513          	addi	a0,a0,130 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc0203a8e:	e74fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203a92:	00002697          	auipc	a3,0x2
ffffffffc0203a96:	23668693          	addi	a3,a3,566 # ffffffffc0205cc8 <default_pmm_manager+0x220>
ffffffffc0203a9a:	00001617          	auipc	a2,0x1
ffffffffc0203a9e:	38660613          	addi	a2,a2,902 # ffffffffc0204e20 <commands+0x728>
ffffffffc0203aa2:	19b00593          	li	a1,411
ffffffffc0203aa6:	00002517          	auipc	a0,0x2
ffffffffc0203aaa:	06250513          	addi	a0,a0,98 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc0203aae:	e54fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203ab2:	00002617          	auipc	a2,0x2
ffffffffc0203ab6:	02e60613          	addi	a2,a2,46 # ffffffffc0205ae0 <default_pmm_manager+0x38>
ffffffffc0203aba:	19e00593          	li	a1,414
ffffffffc0203abe:	00002517          	auipc	a0,0x2
ffffffffc0203ac2:	04a50513          	addi	a0,a0,74 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc0203ac6:	e3cfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203aca:	00002697          	auipc	a3,0x2
ffffffffc0203ace:	21668693          	addi	a3,a3,534 # ffffffffc0205ce0 <default_pmm_manager+0x238>
ffffffffc0203ad2:	00001617          	auipc	a2,0x1
ffffffffc0203ad6:	34e60613          	addi	a2,a2,846 # ffffffffc0204e20 <commands+0x728>
ffffffffc0203ada:	19c00593          	li	a1,412
ffffffffc0203ade:	00002517          	auipc	a0,0x2
ffffffffc0203ae2:	02a50513          	addi	a0,a0,42 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc0203ae6:	e1cfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203aea:	00002697          	auipc	a3,0x2
ffffffffc0203aee:	26e68693          	addi	a3,a3,622 # ffffffffc0205d58 <default_pmm_manager+0x2b0>
ffffffffc0203af2:	00001617          	auipc	a2,0x1
ffffffffc0203af6:	32e60613          	addi	a2,a2,814 # ffffffffc0204e20 <commands+0x728>
ffffffffc0203afa:	1a400593          	li	a1,420
ffffffffc0203afe:	00002517          	auipc	a0,0x2
ffffffffc0203b02:	00a50513          	addi	a0,a0,10 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc0203b06:	dfcfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203b0a:	00002697          	auipc	a3,0x2
ffffffffc0203b0e:	52e68693          	addi	a3,a3,1326 # ffffffffc0206038 <default_pmm_manager+0x590>
ffffffffc0203b12:	00001617          	auipc	a2,0x1
ffffffffc0203b16:	30e60613          	addi	a2,a2,782 # ffffffffc0204e20 <commands+0x728>
ffffffffc0203b1a:	1e000593          	li	a1,480
ffffffffc0203b1e:	00002517          	auipc	a0,0x2
ffffffffc0203b22:	fea50513          	addi	a0,a0,-22 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc0203b26:	ddcfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203b2a:	00002697          	auipc	a3,0x2
ffffffffc0203b2e:	4d668693          	addi	a3,a3,1238 # ffffffffc0206000 <default_pmm_manager+0x558>
ffffffffc0203b32:	00001617          	auipc	a2,0x1
ffffffffc0203b36:	2ee60613          	addi	a2,a2,750 # ffffffffc0204e20 <commands+0x728>
ffffffffc0203b3a:	1dd00593          	li	a1,477
ffffffffc0203b3e:	00002517          	auipc	a0,0x2
ffffffffc0203b42:	fca50513          	addi	a0,a0,-54 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc0203b46:	dbcfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203b4a:	00002697          	auipc	a3,0x2
ffffffffc0203b4e:	48668693          	addi	a3,a3,1158 # ffffffffc0205fd0 <default_pmm_manager+0x528>
ffffffffc0203b52:	00001617          	auipc	a2,0x1
ffffffffc0203b56:	2ce60613          	addi	a2,a2,718 # ffffffffc0204e20 <commands+0x728>
ffffffffc0203b5a:	1d900593          	li	a1,473
ffffffffc0203b5e:	00002517          	auipc	a0,0x2
ffffffffc0203b62:	faa50513          	addi	a0,a0,-86 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc0203b66:	d9cfc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203b6a <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0203b6a:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc0203b6e:	8082                	ret

ffffffffc0203b70 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203b70:	7179                	addi	sp,sp,-48
ffffffffc0203b72:	e84a                	sd	s2,16(sp)
ffffffffc0203b74:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0203b76:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203b78:	f022                	sd	s0,32(sp)
ffffffffc0203b7a:	ec26                	sd	s1,24(sp)
ffffffffc0203b7c:	e44e                	sd	s3,8(sp)
ffffffffc0203b7e:	f406                	sd	ra,40(sp)
ffffffffc0203b80:	84ae                	mv	s1,a1
ffffffffc0203b82:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0203b84:	eedfe0ef          	jal	ra,ffffffffc0202a70 <alloc_pages>
ffffffffc0203b88:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0203b8a:	cd09                	beqz	a0,ffffffffc0203ba4 <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0203b8c:	85aa                	mv	a1,a0
ffffffffc0203b8e:	86ce                	mv	a3,s3
ffffffffc0203b90:	8626                	mv	a2,s1
ffffffffc0203b92:	854a                	mv	a0,s2
ffffffffc0203b94:	ad2ff0ef          	jal	ra,ffffffffc0202e66 <page_insert>
ffffffffc0203b98:	ed21                	bnez	a0,ffffffffc0203bf0 <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc0203b9a:	0000e797          	auipc	a5,0xe
ffffffffc0203b9e:	9967a783          	lw	a5,-1642(a5) # ffffffffc0211530 <swap_init_ok>
ffffffffc0203ba2:	eb89                	bnez	a5,ffffffffc0203bb4 <pgdir_alloc_page+0x44>
}
ffffffffc0203ba4:	70a2                	ld	ra,40(sp)
ffffffffc0203ba6:	8522                	mv	a0,s0
ffffffffc0203ba8:	7402                	ld	s0,32(sp)
ffffffffc0203baa:	64e2                	ld	s1,24(sp)
ffffffffc0203bac:	6942                	ld	s2,16(sp)
ffffffffc0203bae:	69a2                	ld	s3,8(sp)
ffffffffc0203bb0:	6145                	addi	sp,sp,48
ffffffffc0203bb2:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0203bb4:	4681                	li	a3,0
ffffffffc0203bb6:	8622                	mv	a2,s0
ffffffffc0203bb8:	85a6                	mv	a1,s1
ffffffffc0203bba:	0000e517          	auipc	a0,0xe
ffffffffc0203bbe:	95653503          	ld	a0,-1706(a0) # ffffffffc0211510 <check_mm_struct>
ffffffffc0203bc2:	debfd0ef          	jal	ra,ffffffffc02019ac <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0203bc6:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0203bc8:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc0203bca:	4785                	li	a5,1
ffffffffc0203bcc:	fcf70ce3          	beq	a4,a5,ffffffffc0203ba4 <pgdir_alloc_page+0x34>
ffffffffc0203bd0:	00002697          	auipc	a3,0x2
ffffffffc0203bd4:	4b068693          	addi	a3,a3,1200 # ffffffffc0206080 <default_pmm_manager+0x5d8>
ffffffffc0203bd8:	00001617          	auipc	a2,0x1
ffffffffc0203bdc:	24860613          	addi	a2,a2,584 # ffffffffc0204e20 <commands+0x728>
ffffffffc0203be0:	17a00593          	li	a1,378
ffffffffc0203be4:	00002517          	auipc	a0,0x2
ffffffffc0203be8:	f2450513          	addi	a0,a0,-220 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc0203bec:	d16fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203bf0:	100027f3          	csrr	a5,sstatus
ffffffffc0203bf4:	8b89                	andi	a5,a5,2
ffffffffc0203bf6:	eb99                	bnez	a5,ffffffffc0203c0c <pgdir_alloc_page+0x9c>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203bf8:	0000e797          	auipc	a5,0xe
ffffffffc0203bfc:	9607b783          	ld	a5,-1696(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc0203c00:	739c                	ld	a5,32(a5)
ffffffffc0203c02:	8522                	mv	a0,s0
ffffffffc0203c04:	4585                	li	a1,1
ffffffffc0203c06:	9782                	jalr	a5
            return NULL;
ffffffffc0203c08:	4401                	li	s0,0
ffffffffc0203c0a:	bf69                	j	ffffffffc0203ba4 <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc0203c0c:	8e3fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203c10:	0000e797          	auipc	a5,0xe
ffffffffc0203c14:	9487b783          	ld	a5,-1720(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc0203c18:	739c                	ld	a5,32(a5)
ffffffffc0203c1a:	8522                	mv	a0,s0
ffffffffc0203c1c:	4585                	li	a1,1
ffffffffc0203c1e:	9782                	jalr	a5
            return NULL;
ffffffffc0203c20:	4401                	li	s0,0
        intr_enable();
ffffffffc0203c22:	8c7fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203c26:	bfbd                	j	ffffffffc0203ba4 <pgdir_alloc_page+0x34>

ffffffffc0203c28 <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc0203c28:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203c2a:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc0203c2c:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203c2e:	fff50713          	addi	a4,a0,-1
ffffffffc0203c32:	17f9                	addi	a5,a5,-2
ffffffffc0203c34:	04e7ea63          	bltu	a5,a4,ffffffffc0203c88 <kmalloc+0x60>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0203c38:	6785                	lui	a5,0x1
ffffffffc0203c3a:	17fd                	addi	a5,a5,-1
ffffffffc0203c3c:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc0203c3e:	8131                	srli	a0,a0,0xc
ffffffffc0203c40:	e31fe0ef          	jal	ra,ffffffffc0202a70 <alloc_pages>
    assert(base != NULL);
ffffffffc0203c44:	cd3d                	beqz	a0,ffffffffc0203cc2 <kmalloc+0x9a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c46:	0000e797          	auipc	a5,0xe
ffffffffc0203c4a:	90a7b783          	ld	a5,-1782(a5) # ffffffffc0211550 <pages>
ffffffffc0203c4e:	8d1d                	sub	a0,a0,a5
ffffffffc0203c50:	00002697          	auipc	a3,0x2
ffffffffc0203c54:	7286b683          	ld	a3,1832(a3) # ffffffffc0206378 <error_string+0x38>
ffffffffc0203c58:	850d                	srai	a0,a0,0x3
ffffffffc0203c5a:	02d50533          	mul	a0,a0,a3
ffffffffc0203c5e:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c62:	0000e717          	auipc	a4,0xe
ffffffffc0203c66:	8e673703          	ld	a4,-1818(a4) # ffffffffc0211548 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c6a:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c6c:	00c51793          	slli	a5,a0,0xc
ffffffffc0203c70:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203c72:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c74:	02e7fa63          	bgeu	a5,a4,ffffffffc0203ca8 <kmalloc+0x80>
    ptr = page2kva(base);
    return ptr;
}
ffffffffc0203c78:	60a2                	ld	ra,8(sp)
ffffffffc0203c7a:	0000e797          	auipc	a5,0xe
ffffffffc0203c7e:	8e67b783          	ld	a5,-1818(a5) # ffffffffc0211560 <va_pa_offset>
ffffffffc0203c82:	953e                	add	a0,a0,a5
ffffffffc0203c84:	0141                	addi	sp,sp,16
ffffffffc0203c86:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203c88:	00002697          	auipc	a3,0x2
ffffffffc0203c8c:	41068693          	addi	a3,a3,1040 # ffffffffc0206098 <default_pmm_manager+0x5f0>
ffffffffc0203c90:	00001617          	auipc	a2,0x1
ffffffffc0203c94:	19060613          	addi	a2,a2,400 # ffffffffc0204e20 <commands+0x728>
ffffffffc0203c98:	1f000593          	li	a1,496
ffffffffc0203c9c:	00002517          	auipc	a0,0x2
ffffffffc0203ca0:	e6c50513          	addi	a0,a0,-404 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc0203ca4:	c5efc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203ca8:	86aa                	mv	a3,a0
ffffffffc0203caa:	00002617          	auipc	a2,0x2
ffffffffc0203cae:	e3660613          	addi	a2,a2,-458 # ffffffffc0205ae0 <default_pmm_manager+0x38>
ffffffffc0203cb2:	06a00593          	li	a1,106
ffffffffc0203cb6:	00001517          	auipc	a0,0x1
ffffffffc0203cba:	3da50513          	addi	a0,a0,986 # ffffffffc0205090 <commands+0x998>
ffffffffc0203cbe:	c44fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(base != NULL);
ffffffffc0203cc2:	00002697          	auipc	a3,0x2
ffffffffc0203cc6:	3f668693          	addi	a3,a3,1014 # ffffffffc02060b8 <default_pmm_manager+0x610>
ffffffffc0203cca:	00001617          	auipc	a2,0x1
ffffffffc0203cce:	15660613          	addi	a2,a2,342 # ffffffffc0204e20 <commands+0x728>
ffffffffc0203cd2:	1f300593          	li	a1,499
ffffffffc0203cd6:	00002517          	auipc	a0,0x2
ffffffffc0203cda:	e3250513          	addi	a0,a0,-462 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc0203cde:	c24fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203ce2 <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc0203ce2:	1101                	addi	sp,sp,-32
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203ce4:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0203ce6:	ec06                	sd	ra,24(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203ce8:	fff58713          	addi	a4,a1,-1
ffffffffc0203cec:	17f9                	addi	a5,a5,-2
ffffffffc0203cee:	0ae7ee63          	bltu	a5,a4,ffffffffc0203daa <kfree+0xc8>
    assert(ptr != NULL);
ffffffffc0203cf2:	cd41                	beqz	a0,ffffffffc0203d8a <kfree+0xa8>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0203cf4:	6785                	lui	a5,0x1
ffffffffc0203cf6:	17fd                	addi	a5,a5,-1
ffffffffc0203cf8:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0203cfa:	c02007b7          	lui	a5,0xc0200
ffffffffc0203cfe:	81b1                	srli	a1,a1,0xc
ffffffffc0203d00:	06f56863          	bltu	a0,a5,ffffffffc0203d70 <kfree+0x8e>
ffffffffc0203d04:	0000e697          	auipc	a3,0xe
ffffffffc0203d08:	85c6b683          	ld	a3,-1956(a3) # ffffffffc0211560 <va_pa_offset>
ffffffffc0203d0c:	8d15                	sub	a0,a0,a3
    if (PPN(pa) >= npage) {
ffffffffc0203d0e:	8131                	srli	a0,a0,0xc
ffffffffc0203d10:	0000e797          	auipc	a5,0xe
ffffffffc0203d14:	8387b783          	ld	a5,-1992(a5) # ffffffffc0211548 <npage>
ffffffffc0203d18:	04f57a63          	bgeu	a0,a5,ffffffffc0203d6c <kfree+0x8a>
    return &pages[PPN(pa) - nbase];
ffffffffc0203d1c:	fff806b7          	lui	a3,0xfff80
ffffffffc0203d20:	9536                	add	a0,a0,a3
ffffffffc0203d22:	00351793          	slli	a5,a0,0x3
ffffffffc0203d26:	953e                	add	a0,a0,a5
ffffffffc0203d28:	050e                	slli	a0,a0,0x3
ffffffffc0203d2a:	0000e797          	auipc	a5,0xe
ffffffffc0203d2e:	8267b783          	ld	a5,-2010(a5) # ffffffffc0211550 <pages>
ffffffffc0203d32:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203d34:	100027f3          	csrr	a5,sstatus
ffffffffc0203d38:	8b89                	andi	a5,a5,2
ffffffffc0203d3a:	eb89                	bnez	a5,ffffffffc0203d4c <kfree+0x6a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203d3c:	0000e797          	auipc	a5,0xe
ffffffffc0203d40:	81c7b783          	ld	a5,-2020(a5) # ffffffffc0211558 <pmm_manager>
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc0203d44:	60e2                	ld	ra,24(sp)
    { pmm_manager->free_pages(base, n); }
ffffffffc0203d46:	739c                	ld	a5,32(a5)
}
ffffffffc0203d48:	6105                	addi	sp,sp,32
    { pmm_manager->free_pages(base, n); }
ffffffffc0203d4a:	8782                	jr	a5
        intr_disable();
ffffffffc0203d4c:	e42a                	sd	a0,8(sp)
ffffffffc0203d4e:	e02e                	sd	a1,0(sp)
ffffffffc0203d50:	f9efc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0203d54:	0000e797          	auipc	a5,0xe
ffffffffc0203d58:	8047b783          	ld	a5,-2044(a5) # ffffffffc0211558 <pmm_manager>
ffffffffc0203d5c:	6582                	ld	a1,0(sp)
ffffffffc0203d5e:	6522                	ld	a0,8(sp)
ffffffffc0203d60:	739c                	ld	a5,32(a5)
ffffffffc0203d62:	9782                	jalr	a5
}
ffffffffc0203d64:	60e2                	ld	ra,24(sp)
ffffffffc0203d66:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0203d68:	f80fc06f          	j	ffffffffc02004e8 <intr_enable>
ffffffffc0203d6c:	ccdfe0ef          	jal	ra,ffffffffc0202a38 <pa2page.part.0>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0203d70:	86aa                	mv	a3,a0
ffffffffc0203d72:	00002617          	auipc	a2,0x2
ffffffffc0203d76:	e2e60613          	addi	a2,a2,-466 # ffffffffc0205ba0 <default_pmm_manager+0xf8>
ffffffffc0203d7a:	06c00593          	li	a1,108
ffffffffc0203d7e:	00001517          	auipc	a0,0x1
ffffffffc0203d82:	31250513          	addi	a0,a0,786 # ffffffffc0205090 <commands+0x998>
ffffffffc0203d86:	b7cfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(ptr != NULL);
ffffffffc0203d8a:	00002697          	auipc	a3,0x2
ffffffffc0203d8e:	33e68693          	addi	a3,a3,830 # ffffffffc02060c8 <default_pmm_manager+0x620>
ffffffffc0203d92:	00001617          	auipc	a2,0x1
ffffffffc0203d96:	08e60613          	addi	a2,a2,142 # ffffffffc0204e20 <commands+0x728>
ffffffffc0203d9a:	1fa00593          	li	a1,506
ffffffffc0203d9e:	00002517          	auipc	a0,0x2
ffffffffc0203da2:	d6a50513          	addi	a0,a0,-662 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc0203da6:	b5cfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203daa:	00002697          	auipc	a3,0x2
ffffffffc0203dae:	2ee68693          	addi	a3,a3,750 # ffffffffc0206098 <default_pmm_manager+0x5f0>
ffffffffc0203db2:	00001617          	auipc	a2,0x1
ffffffffc0203db6:	06e60613          	addi	a2,a2,110 # ffffffffc0204e20 <commands+0x728>
ffffffffc0203dba:	1f900593          	li	a1,505
ffffffffc0203dbe:	00002517          	auipc	a0,0x2
ffffffffc0203dc2:	d4a50513          	addi	a0,a0,-694 # ffffffffc0205b08 <default_pmm_manager+0x60>
ffffffffc0203dc6:	b3cfc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203dca <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203dca:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203dcc:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203dce:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203dd0:	e02fc0ef          	jal	ra,ffffffffc02003d2 <ide_device_valid>
ffffffffc0203dd4:	cd01                	beqz	a0,ffffffffc0203dec <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203dd6:	4505                	li	a0,1
ffffffffc0203dd8:	e00fc0ef          	jal	ra,ffffffffc02003d8 <ide_device_size>
}
ffffffffc0203ddc:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203dde:	810d                	srli	a0,a0,0x3
ffffffffc0203de0:	0000d797          	auipc	a5,0xd
ffffffffc0203de4:	74a7b023          	sd	a0,1856(a5) # ffffffffc0211520 <max_swap_offset>
}
ffffffffc0203de8:	0141                	addi	sp,sp,16
ffffffffc0203dea:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203dec:	00002617          	auipc	a2,0x2
ffffffffc0203df0:	2ec60613          	addi	a2,a2,748 # ffffffffc02060d8 <default_pmm_manager+0x630>
ffffffffc0203df4:	45b5                	li	a1,13
ffffffffc0203df6:	00002517          	auipc	a0,0x2
ffffffffc0203dfa:	30250513          	addi	a0,a0,770 # ffffffffc02060f8 <default_pmm_manager+0x650>
ffffffffc0203dfe:	b04fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203e02 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203e02:	1141                	addi	sp,sp,-16
ffffffffc0203e04:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e06:	00855793          	srli	a5,a0,0x8
ffffffffc0203e0a:	c3a5                	beqz	a5,ffffffffc0203e6a <swapfs_read+0x68>
ffffffffc0203e0c:	0000d717          	auipc	a4,0xd
ffffffffc0203e10:	71473703          	ld	a4,1812(a4) # ffffffffc0211520 <max_swap_offset>
ffffffffc0203e14:	04e7fb63          	bgeu	a5,a4,ffffffffc0203e6a <swapfs_read+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203e18:	0000d617          	auipc	a2,0xd
ffffffffc0203e1c:	73863603          	ld	a2,1848(a2) # ffffffffc0211550 <pages>
ffffffffc0203e20:	8d91                	sub	a1,a1,a2
ffffffffc0203e22:	4035d613          	srai	a2,a1,0x3
ffffffffc0203e26:	00002597          	auipc	a1,0x2
ffffffffc0203e2a:	5525b583          	ld	a1,1362(a1) # ffffffffc0206378 <error_string+0x38>
ffffffffc0203e2e:	02b60633          	mul	a2,a2,a1
ffffffffc0203e32:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203e36:	00002797          	auipc	a5,0x2
ffffffffc0203e3a:	54a7b783          	ld	a5,1354(a5) # ffffffffc0206380 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e3e:	0000d717          	auipc	a4,0xd
ffffffffc0203e42:	70a73703          	ld	a4,1802(a4) # ffffffffc0211548 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203e46:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e48:	00c61793          	slli	a5,a2,0xc
ffffffffc0203e4c:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203e4e:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e50:	02e7f963          	bgeu	a5,a4,ffffffffc0203e82 <swapfs_read+0x80>
}
ffffffffc0203e54:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e56:	0000d797          	auipc	a5,0xd
ffffffffc0203e5a:	70a7b783          	ld	a5,1802(a5) # ffffffffc0211560 <va_pa_offset>
ffffffffc0203e5e:	46a1                	li	a3,8
ffffffffc0203e60:	963e                	add	a2,a2,a5
ffffffffc0203e62:	4505                	li	a0,1
}
ffffffffc0203e64:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e66:	d78fc06f          	j	ffffffffc02003de <ide_read_secs>
ffffffffc0203e6a:	86aa                	mv	a3,a0
ffffffffc0203e6c:	00002617          	auipc	a2,0x2
ffffffffc0203e70:	2a460613          	addi	a2,a2,676 # ffffffffc0206110 <default_pmm_manager+0x668>
ffffffffc0203e74:	45d1                	li	a1,20
ffffffffc0203e76:	00002517          	auipc	a0,0x2
ffffffffc0203e7a:	28250513          	addi	a0,a0,642 # ffffffffc02060f8 <default_pmm_manager+0x650>
ffffffffc0203e7e:	a84fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203e82:	86b2                	mv	a3,a2
ffffffffc0203e84:	06a00593          	li	a1,106
ffffffffc0203e88:	00002617          	auipc	a2,0x2
ffffffffc0203e8c:	c5860613          	addi	a2,a2,-936 # ffffffffc0205ae0 <default_pmm_manager+0x38>
ffffffffc0203e90:	00001517          	auipc	a0,0x1
ffffffffc0203e94:	20050513          	addi	a0,a0,512 # ffffffffc0205090 <commands+0x998>
ffffffffc0203e98:	a6afc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203e9c <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203e9c:	1141                	addi	sp,sp,-16
ffffffffc0203e9e:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203ea0:	00855793          	srli	a5,a0,0x8
ffffffffc0203ea4:	c3a5                	beqz	a5,ffffffffc0203f04 <swapfs_write+0x68>
ffffffffc0203ea6:	0000d717          	auipc	a4,0xd
ffffffffc0203eaa:	67a73703          	ld	a4,1658(a4) # ffffffffc0211520 <max_swap_offset>
ffffffffc0203eae:	04e7fb63          	bgeu	a5,a4,ffffffffc0203f04 <swapfs_write+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203eb2:	0000d617          	auipc	a2,0xd
ffffffffc0203eb6:	69e63603          	ld	a2,1694(a2) # ffffffffc0211550 <pages>
ffffffffc0203eba:	8d91                	sub	a1,a1,a2
ffffffffc0203ebc:	4035d613          	srai	a2,a1,0x3
ffffffffc0203ec0:	00002597          	auipc	a1,0x2
ffffffffc0203ec4:	4b85b583          	ld	a1,1208(a1) # ffffffffc0206378 <error_string+0x38>
ffffffffc0203ec8:	02b60633          	mul	a2,a2,a1
ffffffffc0203ecc:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203ed0:	00002797          	auipc	a5,0x2
ffffffffc0203ed4:	4b07b783          	ld	a5,1200(a5) # ffffffffc0206380 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ed8:	0000d717          	auipc	a4,0xd
ffffffffc0203edc:	67073703          	ld	a4,1648(a4) # ffffffffc0211548 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203ee0:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ee2:	00c61793          	slli	a5,a2,0xc
ffffffffc0203ee6:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203ee8:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203eea:	02e7f963          	bgeu	a5,a4,ffffffffc0203f1c <swapfs_write+0x80>
}
ffffffffc0203eee:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203ef0:	0000d797          	auipc	a5,0xd
ffffffffc0203ef4:	6707b783          	ld	a5,1648(a5) # ffffffffc0211560 <va_pa_offset>
ffffffffc0203ef8:	46a1                	li	a3,8
ffffffffc0203efa:	963e                	add	a2,a2,a5
ffffffffc0203efc:	4505                	li	a0,1
}
ffffffffc0203efe:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f00:	d02fc06f          	j	ffffffffc0200402 <ide_write_secs>
ffffffffc0203f04:	86aa                	mv	a3,a0
ffffffffc0203f06:	00002617          	auipc	a2,0x2
ffffffffc0203f0a:	20a60613          	addi	a2,a2,522 # ffffffffc0206110 <default_pmm_manager+0x668>
ffffffffc0203f0e:	45e5                	li	a1,25
ffffffffc0203f10:	00002517          	auipc	a0,0x2
ffffffffc0203f14:	1e850513          	addi	a0,a0,488 # ffffffffc02060f8 <default_pmm_manager+0x650>
ffffffffc0203f18:	9eafc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203f1c:	86b2                	mv	a3,a2
ffffffffc0203f1e:	06a00593          	li	a1,106
ffffffffc0203f22:	00002617          	auipc	a2,0x2
ffffffffc0203f26:	bbe60613          	addi	a2,a2,-1090 # ffffffffc0205ae0 <default_pmm_manager+0x38>
ffffffffc0203f2a:	00001517          	auipc	a0,0x1
ffffffffc0203f2e:	16650513          	addi	a0,a0,358 # ffffffffc0205090 <commands+0x998>
ffffffffc0203f32:	9d0fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203f36 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0203f36:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0203f3a:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0203f3c:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0203f3e:	cb81                	beqz	a5,ffffffffc0203f4e <strlen+0x18>
        cnt ++;
ffffffffc0203f40:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0203f42:	00a707b3          	add	a5,a4,a0
ffffffffc0203f46:	0007c783          	lbu	a5,0(a5)
ffffffffc0203f4a:	fbfd                	bnez	a5,ffffffffc0203f40 <strlen+0xa>
ffffffffc0203f4c:	8082                	ret
    }
    return cnt;
}
ffffffffc0203f4e:	8082                	ret

ffffffffc0203f50 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0203f50:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203f52:	e589                	bnez	a1,ffffffffc0203f5c <strnlen+0xc>
ffffffffc0203f54:	a811                	j	ffffffffc0203f68 <strnlen+0x18>
        cnt ++;
ffffffffc0203f56:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203f58:	00f58863          	beq	a1,a5,ffffffffc0203f68 <strnlen+0x18>
ffffffffc0203f5c:	00f50733          	add	a4,a0,a5
ffffffffc0203f60:	00074703          	lbu	a4,0(a4)
ffffffffc0203f64:	fb6d                	bnez	a4,ffffffffc0203f56 <strnlen+0x6>
ffffffffc0203f66:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0203f68:	852e                	mv	a0,a1
ffffffffc0203f6a:	8082                	ret

ffffffffc0203f6c <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0203f6c:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0203f6e:	0005c703          	lbu	a4,0(a1)
ffffffffc0203f72:	0785                	addi	a5,a5,1
ffffffffc0203f74:	0585                	addi	a1,a1,1
ffffffffc0203f76:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0203f7a:	fb75                	bnez	a4,ffffffffc0203f6e <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0203f7c:	8082                	ret

ffffffffc0203f7e <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203f7e:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203f82:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203f86:	cb89                	beqz	a5,ffffffffc0203f98 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0203f88:	0505                	addi	a0,a0,1
ffffffffc0203f8a:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203f8c:	fee789e3          	beq	a5,a4,ffffffffc0203f7e <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203f90:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0203f94:	9d19                	subw	a0,a0,a4
ffffffffc0203f96:	8082                	ret
ffffffffc0203f98:	4501                	li	a0,0
ffffffffc0203f9a:	bfed                	j	ffffffffc0203f94 <strcmp+0x16>

ffffffffc0203f9c <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0203f9c:	00054783          	lbu	a5,0(a0)
ffffffffc0203fa0:	c799                	beqz	a5,ffffffffc0203fae <strchr+0x12>
        if (*s == c) {
ffffffffc0203fa2:	00f58763          	beq	a1,a5,ffffffffc0203fb0 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0203fa6:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0203faa:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0203fac:	fbfd                	bnez	a5,ffffffffc0203fa2 <strchr+0x6>
    }
    return NULL;
ffffffffc0203fae:	4501                	li	a0,0
}
ffffffffc0203fb0:	8082                	ret

ffffffffc0203fb2 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0203fb2:	ca01                	beqz	a2,ffffffffc0203fc2 <memset+0x10>
ffffffffc0203fb4:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0203fb6:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0203fb8:	0785                	addi	a5,a5,1
ffffffffc0203fba:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0203fbe:	fec79de3          	bne	a5,a2,ffffffffc0203fb8 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0203fc2:	8082                	ret

ffffffffc0203fc4 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0203fc4:	ca19                	beqz	a2,ffffffffc0203fda <memcpy+0x16>
ffffffffc0203fc6:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0203fc8:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0203fca:	0005c703          	lbu	a4,0(a1)
ffffffffc0203fce:	0585                	addi	a1,a1,1
ffffffffc0203fd0:	0785                	addi	a5,a5,1
ffffffffc0203fd2:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0203fd6:	fec59ae3          	bne	a1,a2,ffffffffc0203fca <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0203fda:	8082                	ret

ffffffffc0203fdc <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203fdc:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203fe0:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203fe2:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203fe6:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203fe8:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203fec:	f022                	sd	s0,32(sp)
ffffffffc0203fee:	ec26                	sd	s1,24(sp)
ffffffffc0203ff0:	e84a                	sd	s2,16(sp)
ffffffffc0203ff2:	f406                	sd	ra,40(sp)
ffffffffc0203ff4:	e44e                	sd	s3,8(sp)
ffffffffc0203ff6:	84aa                	mv	s1,a0
ffffffffc0203ff8:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203ffa:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203ffe:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0204000:	03067e63          	bgeu	a2,a6,ffffffffc020403c <printnum+0x60>
ffffffffc0204004:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0204006:	00805763          	blez	s0,ffffffffc0204014 <printnum+0x38>
ffffffffc020400a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020400c:	85ca                	mv	a1,s2
ffffffffc020400e:	854e                	mv	a0,s3
ffffffffc0204010:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0204012:	fc65                	bnez	s0,ffffffffc020400a <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204014:	1a02                	slli	s4,s4,0x20
ffffffffc0204016:	00002797          	auipc	a5,0x2
ffffffffc020401a:	11a78793          	addi	a5,a5,282 # ffffffffc0206130 <default_pmm_manager+0x688>
ffffffffc020401e:	020a5a13          	srli	s4,s4,0x20
ffffffffc0204022:	9a3e                	add	s4,s4,a5
}
ffffffffc0204024:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204026:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020402a:	70a2                	ld	ra,40(sp)
ffffffffc020402c:	69a2                	ld	s3,8(sp)
ffffffffc020402e:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204030:	85ca                	mv	a1,s2
ffffffffc0204032:	87a6                	mv	a5,s1
}
ffffffffc0204034:	6942                	ld	s2,16(sp)
ffffffffc0204036:	64e2                	ld	s1,24(sp)
ffffffffc0204038:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020403a:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020403c:	03065633          	divu	a2,a2,a6
ffffffffc0204040:	8722                	mv	a4,s0
ffffffffc0204042:	f9bff0ef          	jal	ra,ffffffffc0203fdc <printnum>
ffffffffc0204046:	b7f9                	j	ffffffffc0204014 <printnum+0x38>

ffffffffc0204048 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0204048:	7119                	addi	sp,sp,-128
ffffffffc020404a:	f4a6                	sd	s1,104(sp)
ffffffffc020404c:	f0ca                	sd	s2,96(sp)
ffffffffc020404e:	ecce                	sd	s3,88(sp)
ffffffffc0204050:	e8d2                	sd	s4,80(sp)
ffffffffc0204052:	e4d6                	sd	s5,72(sp)
ffffffffc0204054:	e0da                	sd	s6,64(sp)
ffffffffc0204056:	fc5e                	sd	s7,56(sp)
ffffffffc0204058:	f06a                	sd	s10,32(sp)
ffffffffc020405a:	fc86                	sd	ra,120(sp)
ffffffffc020405c:	f8a2                	sd	s0,112(sp)
ffffffffc020405e:	f862                	sd	s8,48(sp)
ffffffffc0204060:	f466                	sd	s9,40(sp)
ffffffffc0204062:	ec6e                	sd	s11,24(sp)
ffffffffc0204064:	892a                	mv	s2,a0
ffffffffc0204066:	84ae                	mv	s1,a1
ffffffffc0204068:	8d32                	mv	s10,a2
ffffffffc020406a:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020406c:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0204070:	5b7d                	li	s6,-1
ffffffffc0204072:	00002a97          	auipc	s5,0x2
ffffffffc0204076:	0f2a8a93          	addi	s5,s5,242 # ffffffffc0206164 <default_pmm_manager+0x6bc>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020407a:	00002b97          	auipc	s7,0x2
ffffffffc020407e:	2c6b8b93          	addi	s7,s7,710 # ffffffffc0206340 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204082:	000d4503          	lbu	a0,0(s10) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc0204086:	001d0413          	addi	s0,s10,1
ffffffffc020408a:	01350a63          	beq	a0,s3,ffffffffc020409e <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc020408e:	c121                	beqz	a0,ffffffffc02040ce <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0204090:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204092:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0204094:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204096:	fff44503          	lbu	a0,-1(s0)
ffffffffc020409a:	ff351ae3          	bne	a0,s3,ffffffffc020408e <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020409e:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02040a2:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02040a6:	4c81                	li	s9,0
ffffffffc02040a8:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02040aa:	5c7d                	li	s8,-1
ffffffffc02040ac:	5dfd                	li	s11,-1
ffffffffc02040ae:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02040b2:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040b4:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02040b8:	0ff5f593          	zext.b	a1,a1
ffffffffc02040bc:	00140d13          	addi	s10,s0,1
ffffffffc02040c0:	04b56263          	bltu	a0,a1,ffffffffc0204104 <vprintfmt+0xbc>
ffffffffc02040c4:	058a                	slli	a1,a1,0x2
ffffffffc02040c6:	95d6                	add	a1,a1,s5
ffffffffc02040c8:	4194                	lw	a3,0(a1)
ffffffffc02040ca:	96d6                	add	a3,a3,s5
ffffffffc02040cc:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02040ce:	70e6                	ld	ra,120(sp)
ffffffffc02040d0:	7446                	ld	s0,112(sp)
ffffffffc02040d2:	74a6                	ld	s1,104(sp)
ffffffffc02040d4:	7906                	ld	s2,96(sp)
ffffffffc02040d6:	69e6                	ld	s3,88(sp)
ffffffffc02040d8:	6a46                	ld	s4,80(sp)
ffffffffc02040da:	6aa6                	ld	s5,72(sp)
ffffffffc02040dc:	6b06                	ld	s6,64(sp)
ffffffffc02040de:	7be2                	ld	s7,56(sp)
ffffffffc02040e0:	7c42                	ld	s8,48(sp)
ffffffffc02040e2:	7ca2                	ld	s9,40(sp)
ffffffffc02040e4:	7d02                	ld	s10,32(sp)
ffffffffc02040e6:	6de2                	ld	s11,24(sp)
ffffffffc02040e8:	6109                	addi	sp,sp,128
ffffffffc02040ea:	8082                	ret
            padc = '0';
ffffffffc02040ec:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02040ee:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040f2:	846a                	mv	s0,s10
ffffffffc02040f4:	00140d13          	addi	s10,s0,1
ffffffffc02040f8:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02040fc:	0ff5f593          	zext.b	a1,a1
ffffffffc0204100:	fcb572e3          	bgeu	a0,a1,ffffffffc02040c4 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0204104:	85a6                	mv	a1,s1
ffffffffc0204106:	02500513          	li	a0,37
ffffffffc020410a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020410c:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204110:	8d22                	mv	s10,s0
ffffffffc0204112:	f73788e3          	beq	a5,s3,ffffffffc0204082 <vprintfmt+0x3a>
ffffffffc0204116:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020411a:	1d7d                	addi	s10,s10,-1
ffffffffc020411c:	ff379de3          	bne	a5,s3,ffffffffc0204116 <vprintfmt+0xce>
ffffffffc0204120:	b78d                	j	ffffffffc0204082 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0204122:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0204126:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020412a:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020412c:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204130:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204134:	02d86463          	bltu	a6,a3,ffffffffc020415c <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0204138:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020413c:	002c169b          	slliw	a3,s8,0x2
ffffffffc0204140:	0186873b          	addw	a4,a3,s8
ffffffffc0204144:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204148:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc020414a:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc020414e:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204150:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0204154:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204158:	fed870e3          	bgeu	a6,a3,ffffffffc0204138 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc020415c:	f40ddce3          	bgez	s11,ffffffffc02040b4 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0204160:	8de2                	mv	s11,s8
ffffffffc0204162:	5c7d                	li	s8,-1
ffffffffc0204164:	bf81                	j	ffffffffc02040b4 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0204166:	fffdc693          	not	a3,s11
ffffffffc020416a:	96fd                	srai	a3,a3,0x3f
ffffffffc020416c:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204170:	00144603          	lbu	a2,1(s0)
ffffffffc0204174:	2d81                	sext.w	s11,s11
ffffffffc0204176:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204178:	bf35                	j	ffffffffc02040b4 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc020417a:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020417e:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204182:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204184:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0204186:	bfd9                	j	ffffffffc020415c <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0204188:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020418a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020418e:	01174463          	blt	a4,a7,ffffffffc0204196 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0204192:	1a088e63          	beqz	a7,ffffffffc020434e <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0204196:	000a3603          	ld	a2,0(s4)
ffffffffc020419a:	46c1                	li	a3,16
ffffffffc020419c:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020419e:	2781                	sext.w	a5,a5
ffffffffc02041a0:	876e                	mv	a4,s11
ffffffffc02041a2:	85a6                	mv	a1,s1
ffffffffc02041a4:	854a                	mv	a0,s2
ffffffffc02041a6:	e37ff0ef          	jal	ra,ffffffffc0203fdc <printnum>
            break;
ffffffffc02041aa:	bde1                	j	ffffffffc0204082 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02041ac:	000a2503          	lw	a0,0(s4)
ffffffffc02041b0:	85a6                	mv	a1,s1
ffffffffc02041b2:	0a21                	addi	s4,s4,8
ffffffffc02041b4:	9902                	jalr	s2
            break;
ffffffffc02041b6:	b5f1                	j	ffffffffc0204082 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02041b8:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02041ba:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02041be:	01174463          	blt	a4,a7,ffffffffc02041c6 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02041c2:	18088163          	beqz	a7,ffffffffc0204344 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02041c6:	000a3603          	ld	a2,0(s4)
ffffffffc02041ca:	46a9                	li	a3,10
ffffffffc02041cc:	8a2e                	mv	s4,a1
ffffffffc02041ce:	bfc1                	j	ffffffffc020419e <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041d0:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02041d4:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041d6:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02041d8:	bdf1                	j	ffffffffc02040b4 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02041da:	85a6                	mv	a1,s1
ffffffffc02041dc:	02500513          	li	a0,37
ffffffffc02041e0:	9902                	jalr	s2
            break;
ffffffffc02041e2:	b545                	j	ffffffffc0204082 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041e4:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02041e8:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041ea:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02041ec:	b5e1                	j	ffffffffc02040b4 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02041ee:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02041f0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02041f4:	01174463          	blt	a4,a7,ffffffffc02041fc <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02041f8:	14088163          	beqz	a7,ffffffffc020433a <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02041fc:	000a3603          	ld	a2,0(s4)
ffffffffc0204200:	46a1                	li	a3,8
ffffffffc0204202:	8a2e                	mv	s4,a1
ffffffffc0204204:	bf69                	j	ffffffffc020419e <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0204206:	03000513          	li	a0,48
ffffffffc020420a:	85a6                	mv	a1,s1
ffffffffc020420c:	e03e                	sd	a5,0(sp)
ffffffffc020420e:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204210:	85a6                	mv	a1,s1
ffffffffc0204212:	07800513          	li	a0,120
ffffffffc0204216:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204218:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020421a:	6782                	ld	a5,0(sp)
ffffffffc020421c:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020421e:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0204222:	bfb5                	j	ffffffffc020419e <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204224:	000a3403          	ld	s0,0(s4)
ffffffffc0204228:	008a0713          	addi	a4,s4,8
ffffffffc020422c:	e03a                	sd	a4,0(sp)
ffffffffc020422e:	14040263          	beqz	s0,ffffffffc0204372 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0204232:	0fb05763          	blez	s11,ffffffffc0204320 <vprintfmt+0x2d8>
ffffffffc0204236:	02d00693          	li	a3,45
ffffffffc020423a:	0cd79163          	bne	a5,a3,ffffffffc02042fc <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020423e:	00044783          	lbu	a5,0(s0)
ffffffffc0204242:	0007851b          	sext.w	a0,a5
ffffffffc0204246:	cf85                	beqz	a5,ffffffffc020427e <vprintfmt+0x236>
ffffffffc0204248:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020424c:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204250:	000c4563          	bltz	s8,ffffffffc020425a <vprintfmt+0x212>
ffffffffc0204254:	3c7d                	addiw	s8,s8,-1
ffffffffc0204256:	036c0263          	beq	s8,s6,ffffffffc020427a <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc020425a:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020425c:	0e0c8e63          	beqz	s9,ffffffffc0204358 <vprintfmt+0x310>
ffffffffc0204260:	3781                	addiw	a5,a5,-32
ffffffffc0204262:	0ef47b63          	bgeu	s0,a5,ffffffffc0204358 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0204266:	03f00513          	li	a0,63
ffffffffc020426a:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020426c:	000a4783          	lbu	a5,0(s4)
ffffffffc0204270:	3dfd                	addiw	s11,s11,-1
ffffffffc0204272:	0a05                	addi	s4,s4,1
ffffffffc0204274:	0007851b          	sext.w	a0,a5
ffffffffc0204278:	ffe1                	bnez	a5,ffffffffc0204250 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc020427a:	01b05963          	blez	s11,ffffffffc020428c <vprintfmt+0x244>
ffffffffc020427e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204280:	85a6                	mv	a1,s1
ffffffffc0204282:	02000513          	li	a0,32
ffffffffc0204286:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204288:	fe0d9be3          	bnez	s11,ffffffffc020427e <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020428c:	6a02                	ld	s4,0(sp)
ffffffffc020428e:	bbd5                	j	ffffffffc0204082 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204290:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204292:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0204296:	01174463          	blt	a4,a7,ffffffffc020429e <vprintfmt+0x256>
    else if (lflag) {
ffffffffc020429a:	08088d63          	beqz	a7,ffffffffc0204334 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc020429e:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02042a2:	0a044d63          	bltz	s0,ffffffffc020435c <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02042a6:	8622                	mv	a2,s0
ffffffffc02042a8:	8a66                	mv	s4,s9
ffffffffc02042aa:	46a9                	li	a3,10
ffffffffc02042ac:	bdcd                	j	ffffffffc020419e <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02042ae:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02042b2:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02042b4:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02042b6:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02042ba:	8fb5                	xor	a5,a5,a3
ffffffffc02042bc:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02042c0:	02d74163          	blt	a4,a3,ffffffffc02042e2 <vprintfmt+0x29a>
ffffffffc02042c4:	00369793          	slli	a5,a3,0x3
ffffffffc02042c8:	97de                	add	a5,a5,s7
ffffffffc02042ca:	639c                	ld	a5,0(a5)
ffffffffc02042cc:	cb99                	beqz	a5,ffffffffc02042e2 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02042ce:	86be                	mv	a3,a5
ffffffffc02042d0:	00002617          	auipc	a2,0x2
ffffffffc02042d4:	e9060613          	addi	a2,a2,-368 # ffffffffc0206160 <default_pmm_manager+0x6b8>
ffffffffc02042d8:	85a6                	mv	a1,s1
ffffffffc02042da:	854a                	mv	a0,s2
ffffffffc02042dc:	0ce000ef          	jal	ra,ffffffffc02043aa <printfmt>
ffffffffc02042e0:	b34d                	j	ffffffffc0204082 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02042e2:	00002617          	auipc	a2,0x2
ffffffffc02042e6:	e6e60613          	addi	a2,a2,-402 # ffffffffc0206150 <default_pmm_manager+0x6a8>
ffffffffc02042ea:	85a6                	mv	a1,s1
ffffffffc02042ec:	854a                	mv	a0,s2
ffffffffc02042ee:	0bc000ef          	jal	ra,ffffffffc02043aa <printfmt>
ffffffffc02042f2:	bb41                	j	ffffffffc0204082 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02042f4:	00002417          	auipc	s0,0x2
ffffffffc02042f8:	e5440413          	addi	s0,s0,-428 # ffffffffc0206148 <default_pmm_manager+0x6a0>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02042fc:	85e2                	mv	a1,s8
ffffffffc02042fe:	8522                	mv	a0,s0
ffffffffc0204300:	e43e                	sd	a5,8(sp)
ffffffffc0204302:	c4fff0ef          	jal	ra,ffffffffc0203f50 <strnlen>
ffffffffc0204306:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020430a:	01b05b63          	blez	s11,ffffffffc0204320 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc020430e:	67a2                	ld	a5,8(sp)
ffffffffc0204310:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204314:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204316:	85a6                	mv	a1,s1
ffffffffc0204318:	8552                	mv	a0,s4
ffffffffc020431a:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020431c:	fe0d9ce3          	bnez	s11,ffffffffc0204314 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204320:	00044783          	lbu	a5,0(s0)
ffffffffc0204324:	00140a13          	addi	s4,s0,1
ffffffffc0204328:	0007851b          	sext.w	a0,a5
ffffffffc020432c:	d3a5                	beqz	a5,ffffffffc020428c <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020432e:	05e00413          	li	s0,94
ffffffffc0204332:	bf39                	j	ffffffffc0204250 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0204334:	000a2403          	lw	s0,0(s4)
ffffffffc0204338:	b7ad                	j	ffffffffc02042a2 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc020433a:	000a6603          	lwu	a2,0(s4)
ffffffffc020433e:	46a1                	li	a3,8
ffffffffc0204340:	8a2e                	mv	s4,a1
ffffffffc0204342:	bdb1                	j	ffffffffc020419e <vprintfmt+0x156>
ffffffffc0204344:	000a6603          	lwu	a2,0(s4)
ffffffffc0204348:	46a9                	li	a3,10
ffffffffc020434a:	8a2e                	mv	s4,a1
ffffffffc020434c:	bd89                	j	ffffffffc020419e <vprintfmt+0x156>
ffffffffc020434e:	000a6603          	lwu	a2,0(s4)
ffffffffc0204352:	46c1                	li	a3,16
ffffffffc0204354:	8a2e                	mv	s4,a1
ffffffffc0204356:	b5a1                	j	ffffffffc020419e <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0204358:	9902                	jalr	s2
ffffffffc020435a:	bf09                	j	ffffffffc020426c <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc020435c:	85a6                	mv	a1,s1
ffffffffc020435e:	02d00513          	li	a0,45
ffffffffc0204362:	e03e                	sd	a5,0(sp)
ffffffffc0204364:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204366:	6782                	ld	a5,0(sp)
ffffffffc0204368:	8a66                	mv	s4,s9
ffffffffc020436a:	40800633          	neg	a2,s0
ffffffffc020436e:	46a9                	li	a3,10
ffffffffc0204370:	b53d                	j	ffffffffc020419e <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0204372:	03b05163          	blez	s11,ffffffffc0204394 <vprintfmt+0x34c>
ffffffffc0204376:	02d00693          	li	a3,45
ffffffffc020437a:	f6d79de3          	bne	a5,a3,ffffffffc02042f4 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc020437e:	00002417          	auipc	s0,0x2
ffffffffc0204382:	dca40413          	addi	s0,s0,-566 # ffffffffc0206148 <default_pmm_manager+0x6a0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204386:	02800793          	li	a5,40
ffffffffc020438a:	02800513          	li	a0,40
ffffffffc020438e:	00140a13          	addi	s4,s0,1
ffffffffc0204392:	bd6d                	j	ffffffffc020424c <vprintfmt+0x204>
ffffffffc0204394:	00002a17          	auipc	s4,0x2
ffffffffc0204398:	db5a0a13          	addi	s4,s4,-587 # ffffffffc0206149 <default_pmm_manager+0x6a1>
ffffffffc020439c:	02800513          	li	a0,40
ffffffffc02043a0:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02043a4:	05e00413          	li	s0,94
ffffffffc02043a8:	b565                	j	ffffffffc0204250 <vprintfmt+0x208>

ffffffffc02043aa <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02043aa:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02043ac:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02043b0:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02043b2:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02043b4:	ec06                	sd	ra,24(sp)
ffffffffc02043b6:	f83a                	sd	a4,48(sp)
ffffffffc02043b8:	fc3e                	sd	a5,56(sp)
ffffffffc02043ba:	e0c2                	sd	a6,64(sp)
ffffffffc02043bc:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02043be:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02043c0:	c89ff0ef          	jal	ra,ffffffffc0204048 <vprintfmt>
}
ffffffffc02043c4:	60e2                	ld	ra,24(sp)
ffffffffc02043c6:	6161                	addi	sp,sp,80
ffffffffc02043c8:	8082                	ret

ffffffffc02043ca <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02043ca:	715d                	addi	sp,sp,-80
ffffffffc02043cc:	e486                	sd	ra,72(sp)
ffffffffc02043ce:	e0a6                	sd	s1,64(sp)
ffffffffc02043d0:	fc4a                	sd	s2,56(sp)
ffffffffc02043d2:	f84e                	sd	s3,48(sp)
ffffffffc02043d4:	f452                	sd	s4,40(sp)
ffffffffc02043d6:	f056                	sd	s5,32(sp)
ffffffffc02043d8:	ec5a                	sd	s6,24(sp)
ffffffffc02043da:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02043dc:	c901                	beqz	a0,ffffffffc02043ec <readline+0x22>
ffffffffc02043de:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02043e0:	00002517          	auipc	a0,0x2
ffffffffc02043e4:	d8050513          	addi	a0,a0,-640 # ffffffffc0206160 <default_pmm_manager+0x6b8>
ffffffffc02043e8:	cd3fb0ef          	jal	ra,ffffffffc02000ba <cprintf>
readline(const char *prompt) {
ffffffffc02043ec:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02043ee:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02043f0:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02043f2:	4aa9                	li	s5,10
ffffffffc02043f4:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02043f6:	0000db97          	auipc	s7,0xd
ffffffffc02043fa:	d02b8b93          	addi	s7,s7,-766 # ffffffffc02110f8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02043fe:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0204402:	cf1fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc0204406:	00054a63          	bltz	a0,ffffffffc020441a <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020440a:	00a95a63          	bge	s2,a0,ffffffffc020441e <readline+0x54>
ffffffffc020440e:	029a5263          	bge	s4,s1,ffffffffc0204432 <readline+0x68>
        c = getchar();
ffffffffc0204412:	ce1fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc0204416:	fe055ae3          	bgez	a0,ffffffffc020440a <readline+0x40>
            return NULL;
ffffffffc020441a:	4501                	li	a0,0
ffffffffc020441c:	a091                	j	ffffffffc0204460 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc020441e:	03351463          	bne	a0,s3,ffffffffc0204446 <readline+0x7c>
ffffffffc0204422:	e8a9                	bnez	s1,ffffffffc0204474 <readline+0xaa>
        c = getchar();
ffffffffc0204424:	ccffb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc0204428:	fe0549e3          	bltz	a0,ffffffffc020441a <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020442c:	fea959e3          	bge	s2,a0,ffffffffc020441e <readline+0x54>
ffffffffc0204430:	4481                	li	s1,0
            cputchar(c);
ffffffffc0204432:	e42a                	sd	a0,8(sp)
ffffffffc0204434:	cbdfb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i ++] = c;
ffffffffc0204438:	6522                	ld	a0,8(sp)
ffffffffc020443a:	009b87b3          	add	a5,s7,s1
ffffffffc020443e:	2485                	addiw	s1,s1,1
ffffffffc0204440:	00a78023          	sb	a0,0(a5)
ffffffffc0204444:	bf7d                	j	ffffffffc0204402 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0204446:	01550463          	beq	a0,s5,ffffffffc020444e <readline+0x84>
ffffffffc020444a:	fb651ce3          	bne	a0,s6,ffffffffc0204402 <readline+0x38>
            cputchar(c);
ffffffffc020444e:	ca3fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i] = '\0';
ffffffffc0204452:	0000d517          	auipc	a0,0xd
ffffffffc0204456:	ca650513          	addi	a0,a0,-858 # ffffffffc02110f8 <buf>
ffffffffc020445a:	94aa                	add	s1,s1,a0
ffffffffc020445c:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0204460:	60a6                	ld	ra,72(sp)
ffffffffc0204462:	6486                	ld	s1,64(sp)
ffffffffc0204464:	7962                	ld	s2,56(sp)
ffffffffc0204466:	79c2                	ld	s3,48(sp)
ffffffffc0204468:	7a22                	ld	s4,40(sp)
ffffffffc020446a:	7a82                	ld	s5,32(sp)
ffffffffc020446c:	6b62                	ld	s6,24(sp)
ffffffffc020446e:	6bc2                	ld	s7,16(sp)
ffffffffc0204470:	6161                	addi	sp,sp,80
ffffffffc0204472:	8082                	ret
            cputchar(c);
ffffffffc0204474:	4521                	li	a0,8
ffffffffc0204476:	c7bfb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            i --;
ffffffffc020447a:	34fd                	addiw	s1,s1,-1
ffffffffc020447c:	b759                	j	ffffffffc0204402 <readline+0x38>
