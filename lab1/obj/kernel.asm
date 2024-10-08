
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp
    80200008:	a009                	j	8020000a <kern_init>

000000008020000a <kern_init>:
    8020000a:	00004517          	auipc	a0,0x4
    8020000e:	00650513          	addi	a0,a0,6 # 80204010 <ticks>
    80200012:	00004617          	auipc	a2,0x4
    80200016:	01660613          	addi	a2,a2,22 # 80204028 <end>
    8020001a:	1141                	addi	sp,sp,-16
    8020001c:	8e09                	sub	a2,a2,a0
    8020001e:	4581                	li	a1,0
    80200020:	e406                	sd	ra,8(sp)
    80200022:	574000ef          	jal	ra,80200596 <memset>
    80200026:	14a000ef          	jal	ra,80200170 <cons_init>
    8020002a:	00001597          	auipc	a1,0x1
    8020002e:	9be58593          	addi	a1,a1,-1602 # 802009e8 <etext+0x4>
    80200032:	00001517          	auipc	a0,0x1
    80200036:	9d650513          	addi	a0,a0,-1578 # 80200a08 <etext+0x24>
    8020003a:	030000ef          	jal	ra,8020006a <cprintf>
    8020003e:	062000ef          	jal	ra,802000a0 <print_kerninfo>
    80200042:	13e000ef          	jal	ra,80200180 <idt_init>
    80200046:	0e8000ef          	jal	ra,8020012e <clock_init>
    8020004a:	130000ef          	jal	ra,8020017a <intr_enable>
    8020004e:	a001                	j	8020004e <kern_init+0x44>

0000000080200050 <cputch>:
    80200050:	1141                	addi	sp,sp,-16
    80200052:	e022                	sd	s0,0(sp)
    80200054:	e406                	sd	ra,8(sp)
    80200056:	842e                	mv	s0,a1
    80200058:	11a000ef          	jal	ra,80200172 <cons_putc>
    8020005c:	401c                	lw	a5,0(s0)
    8020005e:	60a2                	ld	ra,8(sp)
    80200060:	2785                	addiw	a5,a5,1
    80200062:	c01c                	sw	a5,0(s0)
    80200064:	6402                	ld	s0,0(sp)
    80200066:	0141                	addi	sp,sp,16
    80200068:	8082                	ret

000000008020006a <cprintf>:
    8020006a:	711d                	addi	sp,sp,-96
    8020006c:	02810313          	addi	t1,sp,40 # 80204028 <end>
    80200070:	8e2a                	mv	t3,a0
    80200072:	f42e                	sd	a1,40(sp)
    80200074:	f832                	sd	a2,48(sp)
    80200076:	fc36                	sd	a3,56(sp)
    80200078:	00000517          	auipc	a0,0x0
    8020007c:	fd850513          	addi	a0,a0,-40 # 80200050 <cputch>
    80200080:	004c                	addi	a1,sp,4
    80200082:	869a                	mv	a3,t1
    80200084:	8672                	mv	a2,t3
    80200086:	ec06                	sd	ra,24(sp)
    80200088:	e0ba                	sd	a4,64(sp)
    8020008a:	e4be                	sd	a5,72(sp)
    8020008c:	e8c2                	sd	a6,80(sp)
    8020008e:	ecc6                	sd	a7,88(sp)
    80200090:	e41a                	sd	t1,8(sp)
    80200092:	c202                	sw	zero,4(sp)
    80200094:	580000ef          	jal	ra,80200614 <vprintfmt>
    80200098:	60e2                	ld	ra,24(sp)
    8020009a:	4512                	lw	a0,4(sp)
    8020009c:	6125                	addi	sp,sp,96
    8020009e:	8082                	ret

00000000802000a0 <print_kerninfo>:
    802000a0:	1141                	addi	sp,sp,-16
    802000a2:	00001517          	auipc	a0,0x1
    802000a6:	96e50513          	addi	a0,a0,-1682 # 80200a10 <etext+0x2c>
    802000aa:	e406                	sd	ra,8(sp)
    802000ac:	fbfff0ef          	jal	ra,8020006a <cprintf>
    802000b0:	00000597          	auipc	a1,0x0
    802000b4:	f5a58593          	addi	a1,a1,-166 # 8020000a <kern_init>
    802000b8:	00001517          	auipc	a0,0x1
    802000bc:	97850513          	addi	a0,a0,-1672 # 80200a30 <etext+0x4c>
    802000c0:	fabff0ef          	jal	ra,8020006a <cprintf>
    802000c4:	00001597          	auipc	a1,0x1
    802000c8:	92058593          	addi	a1,a1,-1760 # 802009e4 <etext>
    802000cc:	00001517          	auipc	a0,0x1
    802000d0:	98450513          	addi	a0,a0,-1660 # 80200a50 <etext+0x6c>
    802000d4:	f97ff0ef          	jal	ra,8020006a <cprintf>
    802000d8:	00004597          	auipc	a1,0x4
    802000dc:	f3858593          	addi	a1,a1,-200 # 80204010 <ticks>
    802000e0:	00001517          	auipc	a0,0x1
    802000e4:	99050513          	addi	a0,a0,-1648 # 80200a70 <etext+0x8c>
    802000e8:	f83ff0ef          	jal	ra,8020006a <cprintf>
    802000ec:	00004597          	auipc	a1,0x4
    802000f0:	f3c58593          	addi	a1,a1,-196 # 80204028 <end>
    802000f4:	00001517          	auipc	a0,0x1
    802000f8:	99c50513          	addi	a0,a0,-1636 # 80200a90 <etext+0xac>
    802000fc:	f6fff0ef          	jal	ra,8020006a <cprintf>
    80200100:	00004597          	auipc	a1,0x4
    80200104:	32758593          	addi	a1,a1,807 # 80204427 <end+0x3ff>
    80200108:	00000797          	auipc	a5,0x0
    8020010c:	f0278793          	addi	a5,a5,-254 # 8020000a <kern_init>
    80200110:	40f587b3          	sub	a5,a1,a5
    80200114:	43f7d593          	srai	a1,a5,0x3f
    80200118:	60a2                	ld	ra,8(sp)
    8020011a:	3ff5f593          	andi	a1,a1,1023
    8020011e:	95be                	add	a1,a1,a5
    80200120:	85a9                	srai	a1,a1,0xa
    80200122:	00001517          	auipc	a0,0x1
    80200126:	98e50513          	addi	a0,a0,-1650 # 80200ab0 <etext+0xcc>
    8020012a:	0141                	addi	sp,sp,16
    8020012c:	bf3d                	j	8020006a <cprintf>

000000008020012e <clock_init>:
    8020012e:	1141                	addi	sp,sp,-16
    80200130:	e406                	sd	ra,8(sp)
    80200132:	02000793          	li	a5,32
    80200136:	1047a7f3          	csrrs	a5,sie,a5
    8020013a:	c0102573          	rdtime	a0
    8020013e:	67e1                	lui	a5,0x18
    80200140:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    80200144:	953e                	add	a0,a0,a5
    80200146:	06b000ef          	jal	ra,802009b0 <sbi_set_timer>
    8020014a:	60a2                	ld	ra,8(sp)
    8020014c:	00004797          	auipc	a5,0x4
    80200150:	ec07b223          	sd	zero,-316(a5) # 80204010 <ticks>
    80200154:	00001517          	auipc	a0,0x1
    80200158:	98c50513          	addi	a0,a0,-1652 # 80200ae0 <etext+0xfc>
    8020015c:	0141                	addi	sp,sp,16
    8020015e:	b731                	j	8020006a <cprintf>

0000000080200160 <clock_set_next_event>:
    80200160:	c0102573          	rdtime	a0
    80200164:	67e1                	lui	a5,0x18
    80200166:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    8020016a:	953e                	add	a0,a0,a5
    8020016c:	0450006f          	j	802009b0 <sbi_set_timer>

0000000080200170 <cons_init>:
    80200170:	8082                	ret

0000000080200172 <cons_putc>:
    80200172:	0ff57513          	zext.b	a0,a0
    80200176:	0210006f          	j	80200996 <sbi_console_putchar>

000000008020017a <intr_enable>:
    8020017a:	100167f3          	csrrsi	a5,sstatus,2
    8020017e:	8082                	ret

0000000080200180 <idt_init>:
    80200180:	14005073          	csrwi	sscratch,0
    80200184:	00000797          	auipc	a5,0x0
    80200188:	34078793          	addi	a5,a5,832 # 802004c4 <__alltraps>
    8020018c:	10579073          	csrw	stvec,a5
    80200190:	8082                	ret

0000000080200192 <print_regs>:
    80200192:	610c                	ld	a1,0(a0)
    80200194:	1141                	addi	sp,sp,-16
    80200196:	e022                	sd	s0,0(sp)
    80200198:	842a                	mv	s0,a0
    8020019a:	00001517          	auipc	a0,0x1
    8020019e:	96650513          	addi	a0,a0,-1690 # 80200b00 <etext+0x11c>
    802001a2:	e406                	sd	ra,8(sp)
    802001a4:	ec7ff0ef          	jal	ra,8020006a <cprintf>
    802001a8:	640c                	ld	a1,8(s0)
    802001aa:	00001517          	auipc	a0,0x1
    802001ae:	96e50513          	addi	a0,a0,-1682 # 80200b18 <etext+0x134>
    802001b2:	eb9ff0ef          	jal	ra,8020006a <cprintf>
    802001b6:	680c                	ld	a1,16(s0)
    802001b8:	00001517          	auipc	a0,0x1
    802001bc:	97850513          	addi	a0,a0,-1672 # 80200b30 <etext+0x14c>
    802001c0:	eabff0ef          	jal	ra,8020006a <cprintf>
    802001c4:	6c0c                	ld	a1,24(s0)
    802001c6:	00001517          	auipc	a0,0x1
    802001ca:	98250513          	addi	a0,a0,-1662 # 80200b48 <etext+0x164>
    802001ce:	e9dff0ef          	jal	ra,8020006a <cprintf>
    802001d2:	700c                	ld	a1,32(s0)
    802001d4:	00001517          	auipc	a0,0x1
    802001d8:	98c50513          	addi	a0,a0,-1652 # 80200b60 <etext+0x17c>
    802001dc:	e8fff0ef          	jal	ra,8020006a <cprintf>
    802001e0:	740c                	ld	a1,40(s0)
    802001e2:	00001517          	auipc	a0,0x1
    802001e6:	99650513          	addi	a0,a0,-1642 # 80200b78 <etext+0x194>
    802001ea:	e81ff0ef          	jal	ra,8020006a <cprintf>
    802001ee:	780c                	ld	a1,48(s0)
    802001f0:	00001517          	auipc	a0,0x1
    802001f4:	9a050513          	addi	a0,a0,-1632 # 80200b90 <etext+0x1ac>
    802001f8:	e73ff0ef          	jal	ra,8020006a <cprintf>
    802001fc:	7c0c                	ld	a1,56(s0)
    802001fe:	00001517          	auipc	a0,0x1
    80200202:	9aa50513          	addi	a0,a0,-1622 # 80200ba8 <etext+0x1c4>
    80200206:	e65ff0ef          	jal	ra,8020006a <cprintf>
    8020020a:	602c                	ld	a1,64(s0)
    8020020c:	00001517          	auipc	a0,0x1
    80200210:	9b450513          	addi	a0,a0,-1612 # 80200bc0 <etext+0x1dc>
    80200214:	e57ff0ef          	jal	ra,8020006a <cprintf>
    80200218:	642c                	ld	a1,72(s0)
    8020021a:	00001517          	auipc	a0,0x1
    8020021e:	9be50513          	addi	a0,a0,-1602 # 80200bd8 <etext+0x1f4>
    80200222:	e49ff0ef          	jal	ra,8020006a <cprintf>
    80200226:	682c                	ld	a1,80(s0)
    80200228:	00001517          	auipc	a0,0x1
    8020022c:	9c850513          	addi	a0,a0,-1592 # 80200bf0 <etext+0x20c>
    80200230:	e3bff0ef          	jal	ra,8020006a <cprintf>
    80200234:	6c2c                	ld	a1,88(s0)
    80200236:	00001517          	auipc	a0,0x1
    8020023a:	9d250513          	addi	a0,a0,-1582 # 80200c08 <etext+0x224>
    8020023e:	e2dff0ef          	jal	ra,8020006a <cprintf>
    80200242:	702c                	ld	a1,96(s0)
    80200244:	00001517          	auipc	a0,0x1
    80200248:	9dc50513          	addi	a0,a0,-1572 # 80200c20 <etext+0x23c>
    8020024c:	e1fff0ef          	jal	ra,8020006a <cprintf>
    80200250:	742c                	ld	a1,104(s0)
    80200252:	00001517          	auipc	a0,0x1
    80200256:	9e650513          	addi	a0,a0,-1562 # 80200c38 <etext+0x254>
    8020025a:	e11ff0ef          	jal	ra,8020006a <cprintf>
    8020025e:	782c                	ld	a1,112(s0)
    80200260:	00001517          	auipc	a0,0x1
    80200264:	9f050513          	addi	a0,a0,-1552 # 80200c50 <etext+0x26c>
    80200268:	e03ff0ef          	jal	ra,8020006a <cprintf>
    8020026c:	7c2c                	ld	a1,120(s0)
    8020026e:	00001517          	auipc	a0,0x1
    80200272:	9fa50513          	addi	a0,a0,-1542 # 80200c68 <etext+0x284>
    80200276:	df5ff0ef          	jal	ra,8020006a <cprintf>
    8020027a:	604c                	ld	a1,128(s0)
    8020027c:	00001517          	auipc	a0,0x1
    80200280:	a0450513          	addi	a0,a0,-1532 # 80200c80 <etext+0x29c>
    80200284:	de7ff0ef          	jal	ra,8020006a <cprintf>
    80200288:	644c                	ld	a1,136(s0)
    8020028a:	00001517          	auipc	a0,0x1
    8020028e:	a0e50513          	addi	a0,a0,-1522 # 80200c98 <etext+0x2b4>
    80200292:	dd9ff0ef          	jal	ra,8020006a <cprintf>
    80200296:	684c                	ld	a1,144(s0)
    80200298:	00001517          	auipc	a0,0x1
    8020029c:	a1850513          	addi	a0,a0,-1512 # 80200cb0 <etext+0x2cc>
    802002a0:	dcbff0ef          	jal	ra,8020006a <cprintf>
    802002a4:	6c4c                	ld	a1,152(s0)
    802002a6:	00001517          	auipc	a0,0x1
    802002aa:	a2250513          	addi	a0,a0,-1502 # 80200cc8 <etext+0x2e4>
    802002ae:	dbdff0ef          	jal	ra,8020006a <cprintf>
    802002b2:	704c                	ld	a1,160(s0)
    802002b4:	00001517          	auipc	a0,0x1
    802002b8:	a2c50513          	addi	a0,a0,-1492 # 80200ce0 <etext+0x2fc>
    802002bc:	dafff0ef          	jal	ra,8020006a <cprintf>
    802002c0:	744c                	ld	a1,168(s0)
    802002c2:	00001517          	auipc	a0,0x1
    802002c6:	a3650513          	addi	a0,a0,-1482 # 80200cf8 <etext+0x314>
    802002ca:	da1ff0ef          	jal	ra,8020006a <cprintf>
    802002ce:	784c                	ld	a1,176(s0)
    802002d0:	00001517          	auipc	a0,0x1
    802002d4:	a4050513          	addi	a0,a0,-1472 # 80200d10 <etext+0x32c>
    802002d8:	d93ff0ef          	jal	ra,8020006a <cprintf>
    802002dc:	7c4c                	ld	a1,184(s0)
    802002de:	00001517          	auipc	a0,0x1
    802002e2:	a4a50513          	addi	a0,a0,-1462 # 80200d28 <etext+0x344>
    802002e6:	d85ff0ef          	jal	ra,8020006a <cprintf>
    802002ea:	606c                	ld	a1,192(s0)
    802002ec:	00001517          	auipc	a0,0x1
    802002f0:	a5450513          	addi	a0,a0,-1452 # 80200d40 <etext+0x35c>
    802002f4:	d77ff0ef          	jal	ra,8020006a <cprintf>
    802002f8:	646c                	ld	a1,200(s0)
    802002fa:	00001517          	auipc	a0,0x1
    802002fe:	a5e50513          	addi	a0,a0,-1442 # 80200d58 <etext+0x374>
    80200302:	d69ff0ef          	jal	ra,8020006a <cprintf>
    80200306:	686c                	ld	a1,208(s0)
    80200308:	00001517          	auipc	a0,0x1
    8020030c:	a6850513          	addi	a0,a0,-1432 # 80200d70 <etext+0x38c>
    80200310:	d5bff0ef          	jal	ra,8020006a <cprintf>
    80200314:	6c6c                	ld	a1,216(s0)
    80200316:	00001517          	auipc	a0,0x1
    8020031a:	a7250513          	addi	a0,a0,-1422 # 80200d88 <etext+0x3a4>
    8020031e:	d4dff0ef          	jal	ra,8020006a <cprintf>
    80200322:	706c                	ld	a1,224(s0)
    80200324:	00001517          	auipc	a0,0x1
    80200328:	a7c50513          	addi	a0,a0,-1412 # 80200da0 <etext+0x3bc>
    8020032c:	d3fff0ef          	jal	ra,8020006a <cprintf>
    80200330:	746c                	ld	a1,232(s0)
    80200332:	00001517          	auipc	a0,0x1
    80200336:	a8650513          	addi	a0,a0,-1402 # 80200db8 <etext+0x3d4>
    8020033a:	d31ff0ef          	jal	ra,8020006a <cprintf>
    8020033e:	786c                	ld	a1,240(s0)
    80200340:	00001517          	auipc	a0,0x1
    80200344:	a9050513          	addi	a0,a0,-1392 # 80200dd0 <etext+0x3ec>
    80200348:	d23ff0ef          	jal	ra,8020006a <cprintf>
    8020034c:	7c6c                	ld	a1,248(s0)
    8020034e:	6402                	ld	s0,0(sp)
    80200350:	60a2                	ld	ra,8(sp)
    80200352:	00001517          	auipc	a0,0x1
    80200356:	a9650513          	addi	a0,a0,-1386 # 80200de8 <etext+0x404>
    8020035a:	0141                	addi	sp,sp,16
    8020035c:	b339                	j	8020006a <cprintf>

000000008020035e <print_trapframe>:
    8020035e:	1141                	addi	sp,sp,-16
    80200360:	e022                	sd	s0,0(sp)
    80200362:	85aa                	mv	a1,a0
    80200364:	842a                	mv	s0,a0
    80200366:	00001517          	auipc	a0,0x1
    8020036a:	a9a50513          	addi	a0,a0,-1382 # 80200e00 <etext+0x41c>
    8020036e:	e406                	sd	ra,8(sp)
    80200370:	cfbff0ef          	jal	ra,8020006a <cprintf>
    80200374:	8522                	mv	a0,s0
    80200376:	e1dff0ef          	jal	ra,80200192 <print_regs>
    8020037a:	10043583          	ld	a1,256(s0)
    8020037e:	00001517          	auipc	a0,0x1
    80200382:	a9a50513          	addi	a0,a0,-1382 # 80200e18 <etext+0x434>
    80200386:	ce5ff0ef          	jal	ra,8020006a <cprintf>
    8020038a:	10843583          	ld	a1,264(s0)
    8020038e:	00001517          	auipc	a0,0x1
    80200392:	aa250513          	addi	a0,a0,-1374 # 80200e30 <etext+0x44c>
    80200396:	cd5ff0ef          	jal	ra,8020006a <cprintf>
    8020039a:	11043583          	ld	a1,272(s0)
    8020039e:	00001517          	auipc	a0,0x1
    802003a2:	aaa50513          	addi	a0,a0,-1366 # 80200e48 <etext+0x464>
    802003a6:	cc5ff0ef          	jal	ra,8020006a <cprintf>
    802003aa:	11843583          	ld	a1,280(s0)
    802003ae:	6402                	ld	s0,0(sp)
    802003b0:	60a2                	ld	ra,8(sp)
    802003b2:	00001517          	auipc	a0,0x1
    802003b6:	aae50513          	addi	a0,a0,-1362 # 80200e60 <etext+0x47c>
    802003ba:	0141                	addi	sp,sp,16
    802003bc:	b17d                	j	8020006a <cprintf>

00000000802003be <interrupt_handler>:
    802003be:	11853783          	ld	a5,280(a0)
    802003c2:	472d                	li	a4,11
    802003c4:	0786                	slli	a5,a5,0x1
    802003c6:	8385                	srli	a5,a5,0x1
    802003c8:	06f76763          	bltu	a4,a5,80200436 <interrupt_handler+0x78>
    802003cc:	00001717          	auipc	a4,0x1
    802003d0:	b5c70713          	addi	a4,a4,-1188 # 80200f28 <etext+0x544>
    802003d4:	078a                	slli	a5,a5,0x2
    802003d6:	97ba                	add	a5,a5,a4
    802003d8:	439c                	lw	a5,0(a5)
    802003da:	97ba                	add	a5,a5,a4
    802003dc:	8782                	jr	a5
    802003de:	00001517          	auipc	a0,0x1
    802003e2:	afa50513          	addi	a0,a0,-1286 # 80200ed8 <etext+0x4f4>
    802003e6:	b151                	j	8020006a <cprintf>
    802003e8:	00001517          	auipc	a0,0x1
    802003ec:	ad050513          	addi	a0,a0,-1328 # 80200eb8 <etext+0x4d4>
    802003f0:	b9ad                	j	8020006a <cprintf>
    802003f2:	00001517          	auipc	a0,0x1
    802003f6:	a8650513          	addi	a0,a0,-1402 # 80200e78 <etext+0x494>
    802003fa:	b985                	j	8020006a <cprintf>
    802003fc:	00001517          	auipc	a0,0x1
    80200400:	a9c50513          	addi	a0,a0,-1380 # 80200e98 <etext+0x4b4>
    80200404:	b19d                	j	8020006a <cprintf>
    80200406:	1141                	addi	sp,sp,-16
    80200408:	e406                	sd	ra,8(sp)
    8020040a:	d57ff0ef          	jal	ra,80200160 <clock_set_next_event>
    8020040e:	00004697          	auipc	a3,0x4
    80200412:	c0268693          	addi	a3,a3,-1022 # 80204010 <ticks>
    80200416:	629c                	ld	a5,0(a3)
    80200418:	06400713          	li	a4,100
    8020041c:	0785                	addi	a5,a5,1
    8020041e:	02e7f733          	remu	a4,a5,a4
    80200422:	e29c                	sd	a5,0(a3)
    80200424:	cb11                	beqz	a4,80200438 <interrupt_handler+0x7a>
    80200426:	60a2                	ld	ra,8(sp)
    80200428:	0141                	addi	sp,sp,16
    8020042a:	8082                	ret
    8020042c:	00001517          	auipc	a0,0x1
    80200430:	adc50513          	addi	a0,a0,-1316 # 80200f08 <etext+0x524>
    80200434:	b91d                	j	8020006a <cprintf>
    80200436:	b725                	j	8020035e <print_trapframe>
    80200438:	06400593          	li	a1,100
    8020043c:	00001517          	auipc	a0,0x1
    80200440:	abc50513          	addi	a0,a0,-1348 # 80200ef8 <etext+0x514>
    80200444:	c27ff0ef          	jal	ra,8020006a <cprintf>
    80200448:	00004797          	auipc	a5,0x4
    8020044c:	bd078793          	addi	a5,a5,-1072 # 80204018 <PRINT_NUM>
    80200450:	6398                	ld	a4,0(a5)
    80200452:	46a9                	li	a3,10
    80200454:	0705                	addi	a4,a4,1
    80200456:	e398                	sd	a4,0(a5)
    80200458:	639c                	ld	a5,0(a5)
    8020045a:	fcd796e3          	bne	a5,a3,80200426 <interrupt_handler+0x68>
    8020045e:	60a2                	ld	ra,8(sp)
    80200460:	0141                	addi	sp,sp,16
    80200462:	a3a5                	j	802009ca <sbi_shutdown>

0000000080200464 <exception_handler>:
    80200464:	11853783          	ld	a5,280(a0)
    80200468:	470d                	li	a4,3
    8020046a:	00e78b63          	beq	a5,a4,80200480 <exception_handler+0x1c>
    8020046e:	00f77863          	bgeu	a4,a5,8020047e <exception_handler+0x1a>
    80200472:	17f1                	addi	a5,a5,-4
    80200474:	471d                	li	a4,7
    80200476:	00f77363          	bgeu	a4,a5,8020047c <exception_handler+0x18>
    8020047a:	b5d5                	j	8020035e <print_trapframe>
    8020047c:	8082                	ret
    8020047e:	8082                	ret
    80200480:	1141                	addi	sp,sp,-16
    80200482:	e022                	sd	s0,0(sp)
    80200484:	842a                	mv	s0,a0
    80200486:	00001517          	auipc	a0,0x1
    8020048a:	ad250513          	addi	a0,a0,-1326 # 80200f58 <etext+0x574>
    8020048e:	e406                	sd	ra,8(sp)
    80200490:	bdbff0ef          	jal	ra,8020006a <cprintf>
    80200494:	10843583          	ld	a1,264(s0)
    80200498:	00001517          	auipc	a0,0x1
    8020049c:	ae050513          	addi	a0,a0,-1312 # 80200f78 <etext+0x594>
    802004a0:	bcbff0ef          	jal	ra,8020006a <cprintf>
    802004a4:	10843783          	ld	a5,264(s0)
    802004a8:	60a2                	ld	ra,8(sp)
    802004aa:	0791                	addi	a5,a5,4
    802004ac:	10f43423          	sd	a5,264(s0)
    802004b0:	6402                	ld	s0,0(sp)
    802004b2:	0141                	addi	sp,sp,16
    802004b4:	8082                	ret

00000000802004b6 <trap>:
    802004b6:	11853783          	ld	a5,280(a0)
    802004ba:	0007c363          	bltz	a5,802004c0 <trap+0xa>
    802004be:	b75d                	j	80200464 <exception_handler>
    802004c0:	bdfd                	j	802003be <interrupt_handler>
	...

00000000802004c4 <__alltraps>:
    802004c4:	14011073          	csrw	sscratch,sp
    802004c8:	712d                	addi	sp,sp,-288
    802004ca:	e002                	sd	zero,0(sp)
    802004cc:	e406                	sd	ra,8(sp)
    802004ce:	ec0e                	sd	gp,24(sp)
    802004d0:	f012                	sd	tp,32(sp)
    802004d2:	f416                	sd	t0,40(sp)
    802004d4:	f81a                	sd	t1,48(sp)
    802004d6:	fc1e                	sd	t2,56(sp)
    802004d8:	e0a2                	sd	s0,64(sp)
    802004da:	e4a6                	sd	s1,72(sp)
    802004dc:	e8aa                	sd	a0,80(sp)
    802004de:	ecae                	sd	a1,88(sp)
    802004e0:	f0b2                	sd	a2,96(sp)
    802004e2:	f4b6                	sd	a3,104(sp)
    802004e4:	f8ba                	sd	a4,112(sp)
    802004e6:	fcbe                	sd	a5,120(sp)
    802004e8:	e142                	sd	a6,128(sp)
    802004ea:	e546                	sd	a7,136(sp)
    802004ec:	e94a                	sd	s2,144(sp)
    802004ee:	ed4e                	sd	s3,152(sp)
    802004f0:	f152                	sd	s4,160(sp)
    802004f2:	f556                	sd	s5,168(sp)
    802004f4:	f95a                	sd	s6,176(sp)
    802004f6:	fd5e                	sd	s7,184(sp)
    802004f8:	e1e2                	sd	s8,192(sp)
    802004fa:	e5e6                	sd	s9,200(sp)
    802004fc:	e9ea                	sd	s10,208(sp)
    802004fe:	edee                	sd	s11,216(sp)
    80200500:	f1f2                	sd	t3,224(sp)
    80200502:	f5f6                	sd	t4,232(sp)
    80200504:	f9fa                	sd	t5,240(sp)
    80200506:	fdfe                	sd	t6,248(sp)
    80200508:	14001473          	csrrw	s0,sscratch,zero
    8020050c:	100024f3          	csrr	s1,sstatus
    80200510:	14102973          	csrr	s2,sepc
    80200514:	143029f3          	csrr	s3,stval
    80200518:	14202a73          	csrr	s4,scause
    8020051c:	e822                	sd	s0,16(sp)
    8020051e:	e226                	sd	s1,256(sp)
    80200520:	e64a                	sd	s2,264(sp)
    80200522:	ea4e                	sd	s3,272(sp)
    80200524:	ee52                	sd	s4,280(sp)
    80200526:	850a                	mv	a0,sp
    80200528:	f8fff0ef          	jal	ra,802004b6 <trap>

000000008020052c <__trapret>:
    8020052c:	6492                	ld	s1,256(sp)
    8020052e:	6932                	ld	s2,264(sp)
    80200530:	10049073          	csrw	sstatus,s1
    80200534:	14191073          	csrw	sepc,s2
    80200538:	60a2                	ld	ra,8(sp)
    8020053a:	61e2                	ld	gp,24(sp)
    8020053c:	7202                	ld	tp,32(sp)
    8020053e:	72a2                	ld	t0,40(sp)
    80200540:	7342                	ld	t1,48(sp)
    80200542:	73e2                	ld	t2,56(sp)
    80200544:	6406                	ld	s0,64(sp)
    80200546:	64a6                	ld	s1,72(sp)
    80200548:	6546                	ld	a0,80(sp)
    8020054a:	65e6                	ld	a1,88(sp)
    8020054c:	7606                	ld	a2,96(sp)
    8020054e:	76a6                	ld	a3,104(sp)
    80200550:	7746                	ld	a4,112(sp)
    80200552:	77e6                	ld	a5,120(sp)
    80200554:	680a                	ld	a6,128(sp)
    80200556:	68aa                	ld	a7,136(sp)
    80200558:	694a                	ld	s2,144(sp)
    8020055a:	69ea                	ld	s3,152(sp)
    8020055c:	7a0a                	ld	s4,160(sp)
    8020055e:	7aaa                	ld	s5,168(sp)
    80200560:	7b4a                	ld	s6,176(sp)
    80200562:	7bea                	ld	s7,184(sp)
    80200564:	6c0e                	ld	s8,192(sp)
    80200566:	6cae                	ld	s9,200(sp)
    80200568:	6d4e                	ld	s10,208(sp)
    8020056a:	6dee                	ld	s11,216(sp)
    8020056c:	7e0e                	ld	t3,224(sp)
    8020056e:	7eae                	ld	t4,232(sp)
    80200570:	7f4e                	ld	t5,240(sp)
    80200572:	7fee                	ld	t6,248(sp)
    80200574:	6142                	ld	sp,16(sp)
    80200576:	10200073          	sret

000000008020057a <strnlen>:
    8020057a:	4781                	li	a5,0
    8020057c:	e589                	bnez	a1,80200586 <strnlen+0xc>
    8020057e:	a811                	j	80200592 <strnlen+0x18>
    80200580:	0785                	addi	a5,a5,1
    80200582:	00f58863          	beq	a1,a5,80200592 <strnlen+0x18>
    80200586:	00f50733          	add	a4,a0,a5
    8020058a:	00074703          	lbu	a4,0(a4)
    8020058e:	fb6d                	bnez	a4,80200580 <strnlen+0x6>
    80200590:	85be                	mv	a1,a5
    80200592:	852e                	mv	a0,a1
    80200594:	8082                	ret

0000000080200596 <memset>:
    80200596:	ca01                	beqz	a2,802005a6 <memset+0x10>
    80200598:	962a                	add	a2,a2,a0
    8020059a:	87aa                	mv	a5,a0
    8020059c:	0785                	addi	a5,a5,1
    8020059e:	feb78fa3          	sb	a1,-1(a5)
    802005a2:	fec79de3          	bne	a5,a2,8020059c <memset+0x6>
    802005a6:	8082                	ret

00000000802005a8 <printnum>:
    802005a8:	02069813          	slli	a6,a3,0x20
    802005ac:	7179                	addi	sp,sp,-48
    802005ae:	02085813          	srli	a6,a6,0x20
    802005b2:	e052                	sd	s4,0(sp)
    802005b4:	03067a33          	remu	s4,a2,a6
    802005b8:	f022                	sd	s0,32(sp)
    802005ba:	ec26                	sd	s1,24(sp)
    802005bc:	e84a                	sd	s2,16(sp)
    802005be:	f406                	sd	ra,40(sp)
    802005c0:	e44e                	sd	s3,8(sp)
    802005c2:	84aa                	mv	s1,a0
    802005c4:	892e                	mv	s2,a1
    802005c6:	fff7041b          	addiw	s0,a4,-1
    802005ca:	2a01                	sext.w	s4,s4
    802005cc:	03067e63          	bgeu	a2,a6,80200608 <printnum+0x60>
    802005d0:	89be                	mv	s3,a5
    802005d2:	00805763          	blez	s0,802005e0 <printnum+0x38>
    802005d6:	347d                	addiw	s0,s0,-1
    802005d8:	85ca                	mv	a1,s2
    802005da:	854e                	mv	a0,s3
    802005dc:	9482                	jalr	s1
    802005de:	fc65                	bnez	s0,802005d6 <printnum+0x2e>
    802005e0:	1a02                	slli	s4,s4,0x20
    802005e2:	00001797          	auipc	a5,0x1
    802005e6:	9b678793          	addi	a5,a5,-1610 # 80200f98 <etext+0x5b4>
    802005ea:	020a5a13          	srli	s4,s4,0x20
    802005ee:	9a3e                	add	s4,s4,a5
    802005f0:	7402                	ld	s0,32(sp)
    802005f2:	000a4503          	lbu	a0,0(s4)
    802005f6:	70a2                	ld	ra,40(sp)
    802005f8:	69a2                	ld	s3,8(sp)
    802005fa:	6a02                	ld	s4,0(sp)
    802005fc:	85ca                	mv	a1,s2
    802005fe:	87a6                	mv	a5,s1
    80200600:	6942                	ld	s2,16(sp)
    80200602:	64e2                	ld	s1,24(sp)
    80200604:	6145                	addi	sp,sp,48
    80200606:	8782                	jr	a5
    80200608:	03065633          	divu	a2,a2,a6
    8020060c:	8722                	mv	a4,s0
    8020060e:	f9bff0ef          	jal	ra,802005a8 <printnum>
    80200612:	b7f9                	j	802005e0 <printnum+0x38>

0000000080200614 <vprintfmt>:
    80200614:	7119                	addi	sp,sp,-128
    80200616:	f4a6                	sd	s1,104(sp)
    80200618:	f0ca                	sd	s2,96(sp)
    8020061a:	ecce                	sd	s3,88(sp)
    8020061c:	e8d2                	sd	s4,80(sp)
    8020061e:	e4d6                	sd	s5,72(sp)
    80200620:	e0da                	sd	s6,64(sp)
    80200622:	fc5e                	sd	s7,56(sp)
    80200624:	f06a                	sd	s10,32(sp)
    80200626:	fc86                	sd	ra,120(sp)
    80200628:	f8a2                	sd	s0,112(sp)
    8020062a:	f862                	sd	s8,48(sp)
    8020062c:	f466                	sd	s9,40(sp)
    8020062e:	ec6e                	sd	s11,24(sp)
    80200630:	892a                	mv	s2,a0
    80200632:	84ae                	mv	s1,a1
    80200634:	8d32                	mv	s10,a2
    80200636:	8a36                	mv	s4,a3
    80200638:	02500993          	li	s3,37
    8020063c:	5b7d                	li	s6,-1
    8020063e:	00001a97          	auipc	s5,0x1
    80200642:	98ea8a93          	addi	s5,s5,-1650 # 80200fcc <etext+0x5e8>
    80200646:	00001b97          	auipc	s7,0x1
    8020064a:	b62b8b93          	addi	s7,s7,-1182 # 802011a8 <error_string>
    8020064e:	000d4503          	lbu	a0,0(s10)
    80200652:	001d0413          	addi	s0,s10,1
    80200656:	01350a63          	beq	a0,s3,8020066a <vprintfmt+0x56>
    8020065a:	c121                	beqz	a0,8020069a <vprintfmt+0x86>
    8020065c:	85a6                	mv	a1,s1
    8020065e:	0405                	addi	s0,s0,1
    80200660:	9902                	jalr	s2
    80200662:	fff44503          	lbu	a0,-1(s0)
    80200666:	ff351ae3          	bne	a0,s3,8020065a <vprintfmt+0x46>
    8020066a:	00044603          	lbu	a2,0(s0)
    8020066e:	02000793          	li	a5,32
    80200672:	4c81                	li	s9,0
    80200674:	4881                	li	a7,0
    80200676:	5c7d                	li	s8,-1
    80200678:	5dfd                	li	s11,-1
    8020067a:	05500513          	li	a0,85
    8020067e:	4825                	li	a6,9
    80200680:	fdd6059b          	addiw	a1,a2,-35
    80200684:	0ff5f593          	zext.b	a1,a1
    80200688:	00140d13          	addi	s10,s0,1
    8020068c:	04b56263          	bltu	a0,a1,802006d0 <vprintfmt+0xbc>
    80200690:	058a                	slli	a1,a1,0x2
    80200692:	95d6                	add	a1,a1,s5
    80200694:	4194                	lw	a3,0(a1)
    80200696:	96d6                	add	a3,a3,s5
    80200698:	8682                	jr	a3
    8020069a:	70e6                	ld	ra,120(sp)
    8020069c:	7446                	ld	s0,112(sp)
    8020069e:	74a6                	ld	s1,104(sp)
    802006a0:	7906                	ld	s2,96(sp)
    802006a2:	69e6                	ld	s3,88(sp)
    802006a4:	6a46                	ld	s4,80(sp)
    802006a6:	6aa6                	ld	s5,72(sp)
    802006a8:	6b06                	ld	s6,64(sp)
    802006aa:	7be2                	ld	s7,56(sp)
    802006ac:	7c42                	ld	s8,48(sp)
    802006ae:	7ca2                	ld	s9,40(sp)
    802006b0:	7d02                	ld	s10,32(sp)
    802006b2:	6de2                	ld	s11,24(sp)
    802006b4:	6109                	addi	sp,sp,128
    802006b6:	8082                	ret
    802006b8:	87b2                	mv	a5,a2
    802006ba:	00144603          	lbu	a2,1(s0)
    802006be:	846a                	mv	s0,s10
    802006c0:	00140d13          	addi	s10,s0,1
    802006c4:	fdd6059b          	addiw	a1,a2,-35
    802006c8:	0ff5f593          	zext.b	a1,a1
    802006cc:	fcb572e3          	bgeu	a0,a1,80200690 <vprintfmt+0x7c>
    802006d0:	85a6                	mv	a1,s1
    802006d2:	02500513          	li	a0,37
    802006d6:	9902                	jalr	s2
    802006d8:	fff44783          	lbu	a5,-1(s0)
    802006dc:	8d22                	mv	s10,s0
    802006de:	f73788e3          	beq	a5,s3,8020064e <vprintfmt+0x3a>
    802006e2:	ffed4783          	lbu	a5,-2(s10)
    802006e6:	1d7d                	addi	s10,s10,-1
    802006e8:	ff379de3          	bne	a5,s3,802006e2 <vprintfmt+0xce>
    802006ec:	b78d                	j	8020064e <vprintfmt+0x3a>
    802006ee:	fd060c1b          	addiw	s8,a2,-48
    802006f2:	00144603          	lbu	a2,1(s0)
    802006f6:	846a                	mv	s0,s10
    802006f8:	fd06069b          	addiw	a3,a2,-48
    802006fc:	0006059b          	sext.w	a1,a2
    80200700:	02d86463          	bltu	a6,a3,80200728 <vprintfmt+0x114>
    80200704:	00144603          	lbu	a2,1(s0)
    80200708:	002c169b          	slliw	a3,s8,0x2
    8020070c:	0186873b          	addw	a4,a3,s8
    80200710:	0017171b          	slliw	a4,a4,0x1
    80200714:	9f2d                	addw	a4,a4,a1
    80200716:	fd06069b          	addiw	a3,a2,-48
    8020071a:	0405                	addi	s0,s0,1
    8020071c:	fd070c1b          	addiw	s8,a4,-48
    80200720:	0006059b          	sext.w	a1,a2
    80200724:	fed870e3          	bgeu	a6,a3,80200704 <vprintfmt+0xf0>
    80200728:	f40ddce3          	bgez	s11,80200680 <vprintfmt+0x6c>
    8020072c:	8de2                	mv	s11,s8
    8020072e:	5c7d                	li	s8,-1
    80200730:	bf81                	j	80200680 <vprintfmt+0x6c>
    80200732:	fffdc693          	not	a3,s11
    80200736:	96fd                	srai	a3,a3,0x3f
    80200738:	00ddfdb3          	and	s11,s11,a3
    8020073c:	00144603          	lbu	a2,1(s0)
    80200740:	2d81                	sext.w	s11,s11
    80200742:	846a                	mv	s0,s10
    80200744:	bf35                	j	80200680 <vprintfmt+0x6c>
    80200746:	000a2c03          	lw	s8,0(s4)
    8020074a:	00144603          	lbu	a2,1(s0)
    8020074e:	0a21                	addi	s4,s4,8
    80200750:	846a                	mv	s0,s10
    80200752:	bfd9                	j	80200728 <vprintfmt+0x114>
    80200754:	4705                	li	a4,1
    80200756:	008a0593          	addi	a1,s4,8
    8020075a:	01174463          	blt	a4,a7,80200762 <vprintfmt+0x14e>
    8020075e:	1a088e63          	beqz	a7,8020091a <vprintfmt+0x306>
    80200762:	000a3603          	ld	a2,0(s4)
    80200766:	46c1                	li	a3,16
    80200768:	8a2e                	mv	s4,a1
    8020076a:	2781                	sext.w	a5,a5
    8020076c:	876e                	mv	a4,s11
    8020076e:	85a6                	mv	a1,s1
    80200770:	854a                	mv	a0,s2
    80200772:	e37ff0ef          	jal	ra,802005a8 <printnum>
    80200776:	bde1                	j	8020064e <vprintfmt+0x3a>
    80200778:	000a2503          	lw	a0,0(s4)
    8020077c:	85a6                	mv	a1,s1
    8020077e:	0a21                	addi	s4,s4,8
    80200780:	9902                	jalr	s2
    80200782:	b5f1                	j	8020064e <vprintfmt+0x3a>
    80200784:	4705                	li	a4,1
    80200786:	008a0593          	addi	a1,s4,8
    8020078a:	01174463          	blt	a4,a7,80200792 <vprintfmt+0x17e>
    8020078e:	18088163          	beqz	a7,80200910 <vprintfmt+0x2fc>
    80200792:	000a3603          	ld	a2,0(s4)
    80200796:	46a9                	li	a3,10
    80200798:	8a2e                	mv	s4,a1
    8020079a:	bfc1                	j	8020076a <vprintfmt+0x156>
    8020079c:	00144603          	lbu	a2,1(s0)
    802007a0:	4c85                	li	s9,1
    802007a2:	846a                	mv	s0,s10
    802007a4:	bdf1                	j	80200680 <vprintfmt+0x6c>
    802007a6:	85a6                	mv	a1,s1
    802007a8:	02500513          	li	a0,37
    802007ac:	9902                	jalr	s2
    802007ae:	b545                	j	8020064e <vprintfmt+0x3a>
    802007b0:	00144603          	lbu	a2,1(s0)
    802007b4:	2885                	addiw	a7,a7,1
    802007b6:	846a                	mv	s0,s10
    802007b8:	b5e1                	j	80200680 <vprintfmt+0x6c>
    802007ba:	4705                	li	a4,1
    802007bc:	008a0593          	addi	a1,s4,8
    802007c0:	01174463          	blt	a4,a7,802007c8 <vprintfmt+0x1b4>
    802007c4:	14088163          	beqz	a7,80200906 <vprintfmt+0x2f2>
    802007c8:	000a3603          	ld	a2,0(s4)
    802007cc:	46a1                	li	a3,8
    802007ce:	8a2e                	mv	s4,a1
    802007d0:	bf69                	j	8020076a <vprintfmt+0x156>
    802007d2:	03000513          	li	a0,48
    802007d6:	85a6                	mv	a1,s1
    802007d8:	e03e                	sd	a5,0(sp)
    802007da:	9902                	jalr	s2
    802007dc:	85a6                	mv	a1,s1
    802007de:	07800513          	li	a0,120
    802007e2:	9902                	jalr	s2
    802007e4:	0a21                	addi	s4,s4,8
    802007e6:	6782                	ld	a5,0(sp)
    802007e8:	46c1                	li	a3,16
    802007ea:	ff8a3603          	ld	a2,-8(s4)
    802007ee:	bfb5                	j	8020076a <vprintfmt+0x156>
    802007f0:	000a3403          	ld	s0,0(s4)
    802007f4:	008a0713          	addi	a4,s4,8
    802007f8:	e03a                	sd	a4,0(sp)
    802007fa:	14040263          	beqz	s0,8020093e <vprintfmt+0x32a>
    802007fe:	0fb05763          	blez	s11,802008ec <vprintfmt+0x2d8>
    80200802:	02d00693          	li	a3,45
    80200806:	0cd79163          	bne	a5,a3,802008c8 <vprintfmt+0x2b4>
    8020080a:	00044783          	lbu	a5,0(s0)
    8020080e:	0007851b          	sext.w	a0,a5
    80200812:	cf85                	beqz	a5,8020084a <vprintfmt+0x236>
    80200814:	00140a13          	addi	s4,s0,1
    80200818:	05e00413          	li	s0,94
    8020081c:	000c4563          	bltz	s8,80200826 <vprintfmt+0x212>
    80200820:	3c7d                	addiw	s8,s8,-1
    80200822:	036c0263          	beq	s8,s6,80200846 <vprintfmt+0x232>
    80200826:	85a6                	mv	a1,s1
    80200828:	0e0c8e63          	beqz	s9,80200924 <vprintfmt+0x310>
    8020082c:	3781                	addiw	a5,a5,-32
    8020082e:	0ef47b63          	bgeu	s0,a5,80200924 <vprintfmt+0x310>
    80200832:	03f00513          	li	a0,63
    80200836:	9902                	jalr	s2
    80200838:	000a4783          	lbu	a5,0(s4)
    8020083c:	3dfd                	addiw	s11,s11,-1
    8020083e:	0a05                	addi	s4,s4,1
    80200840:	0007851b          	sext.w	a0,a5
    80200844:	ffe1                	bnez	a5,8020081c <vprintfmt+0x208>
    80200846:	01b05963          	blez	s11,80200858 <vprintfmt+0x244>
    8020084a:	3dfd                	addiw	s11,s11,-1
    8020084c:	85a6                	mv	a1,s1
    8020084e:	02000513          	li	a0,32
    80200852:	9902                	jalr	s2
    80200854:	fe0d9be3          	bnez	s11,8020084a <vprintfmt+0x236>
    80200858:	6a02                	ld	s4,0(sp)
    8020085a:	bbd5                	j	8020064e <vprintfmt+0x3a>
    8020085c:	4705                	li	a4,1
    8020085e:	008a0c93          	addi	s9,s4,8
    80200862:	01174463          	blt	a4,a7,8020086a <vprintfmt+0x256>
    80200866:	08088d63          	beqz	a7,80200900 <vprintfmt+0x2ec>
    8020086a:	000a3403          	ld	s0,0(s4)
    8020086e:	0a044d63          	bltz	s0,80200928 <vprintfmt+0x314>
    80200872:	8622                	mv	a2,s0
    80200874:	8a66                	mv	s4,s9
    80200876:	46a9                	li	a3,10
    80200878:	bdcd                	j	8020076a <vprintfmt+0x156>
    8020087a:	000a2783          	lw	a5,0(s4)
    8020087e:	4719                	li	a4,6
    80200880:	0a21                	addi	s4,s4,8
    80200882:	41f7d69b          	sraiw	a3,a5,0x1f
    80200886:	8fb5                	xor	a5,a5,a3
    80200888:	40d786bb          	subw	a3,a5,a3
    8020088c:	02d74163          	blt	a4,a3,802008ae <vprintfmt+0x29a>
    80200890:	00369793          	slli	a5,a3,0x3
    80200894:	97de                	add	a5,a5,s7
    80200896:	639c                	ld	a5,0(a5)
    80200898:	cb99                	beqz	a5,802008ae <vprintfmt+0x29a>
    8020089a:	86be                	mv	a3,a5
    8020089c:	00000617          	auipc	a2,0x0
    802008a0:	72c60613          	addi	a2,a2,1836 # 80200fc8 <etext+0x5e4>
    802008a4:	85a6                	mv	a1,s1
    802008a6:	854a                	mv	a0,s2
    802008a8:	0ce000ef          	jal	ra,80200976 <printfmt>
    802008ac:	b34d                	j	8020064e <vprintfmt+0x3a>
    802008ae:	00000617          	auipc	a2,0x0
    802008b2:	70a60613          	addi	a2,a2,1802 # 80200fb8 <etext+0x5d4>
    802008b6:	85a6                	mv	a1,s1
    802008b8:	854a                	mv	a0,s2
    802008ba:	0bc000ef          	jal	ra,80200976 <printfmt>
    802008be:	bb41                	j	8020064e <vprintfmt+0x3a>
    802008c0:	00000417          	auipc	s0,0x0
    802008c4:	6f040413          	addi	s0,s0,1776 # 80200fb0 <etext+0x5cc>
    802008c8:	85e2                	mv	a1,s8
    802008ca:	8522                	mv	a0,s0
    802008cc:	e43e                	sd	a5,8(sp)
    802008ce:	cadff0ef          	jal	ra,8020057a <strnlen>
    802008d2:	40ad8dbb          	subw	s11,s11,a0
    802008d6:	01b05b63          	blez	s11,802008ec <vprintfmt+0x2d8>
    802008da:	67a2                	ld	a5,8(sp)
    802008dc:	00078a1b          	sext.w	s4,a5
    802008e0:	3dfd                	addiw	s11,s11,-1
    802008e2:	85a6                	mv	a1,s1
    802008e4:	8552                	mv	a0,s4
    802008e6:	9902                	jalr	s2
    802008e8:	fe0d9ce3          	bnez	s11,802008e0 <vprintfmt+0x2cc>
    802008ec:	00044783          	lbu	a5,0(s0)
    802008f0:	00140a13          	addi	s4,s0,1
    802008f4:	0007851b          	sext.w	a0,a5
    802008f8:	d3a5                	beqz	a5,80200858 <vprintfmt+0x244>
    802008fa:	05e00413          	li	s0,94
    802008fe:	bf39                	j	8020081c <vprintfmt+0x208>
    80200900:	000a2403          	lw	s0,0(s4)
    80200904:	b7ad                	j	8020086e <vprintfmt+0x25a>
    80200906:	000a6603          	lwu	a2,0(s4)
    8020090a:	46a1                	li	a3,8
    8020090c:	8a2e                	mv	s4,a1
    8020090e:	bdb1                	j	8020076a <vprintfmt+0x156>
    80200910:	000a6603          	lwu	a2,0(s4)
    80200914:	46a9                	li	a3,10
    80200916:	8a2e                	mv	s4,a1
    80200918:	bd89                	j	8020076a <vprintfmt+0x156>
    8020091a:	000a6603          	lwu	a2,0(s4)
    8020091e:	46c1                	li	a3,16
    80200920:	8a2e                	mv	s4,a1
    80200922:	b5a1                	j	8020076a <vprintfmt+0x156>
    80200924:	9902                	jalr	s2
    80200926:	bf09                	j	80200838 <vprintfmt+0x224>
    80200928:	85a6                	mv	a1,s1
    8020092a:	02d00513          	li	a0,45
    8020092e:	e03e                	sd	a5,0(sp)
    80200930:	9902                	jalr	s2
    80200932:	6782                	ld	a5,0(sp)
    80200934:	8a66                	mv	s4,s9
    80200936:	40800633          	neg	a2,s0
    8020093a:	46a9                	li	a3,10
    8020093c:	b53d                	j	8020076a <vprintfmt+0x156>
    8020093e:	03b05163          	blez	s11,80200960 <vprintfmt+0x34c>
    80200942:	02d00693          	li	a3,45
    80200946:	f6d79de3          	bne	a5,a3,802008c0 <vprintfmt+0x2ac>
    8020094a:	00000417          	auipc	s0,0x0
    8020094e:	66640413          	addi	s0,s0,1638 # 80200fb0 <etext+0x5cc>
    80200952:	02800793          	li	a5,40
    80200956:	02800513          	li	a0,40
    8020095a:	00140a13          	addi	s4,s0,1
    8020095e:	bd6d                	j	80200818 <vprintfmt+0x204>
    80200960:	00000a17          	auipc	s4,0x0
    80200964:	651a0a13          	addi	s4,s4,1617 # 80200fb1 <etext+0x5cd>
    80200968:	02800513          	li	a0,40
    8020096c:	02800793          	li	a5,40
    80200970:	05e00413          	li	s0,94
    80200974:	b565                	j	8020081c <vprintfmt+0x208>

0000000080200976 <printfmt>:
    80200976:	715d                	addi	sp,sp,-80
    80200978:	02810313          	addi	t1,sp,40
    8020097c:	f436                	sd	a3,40(sp)
    8020097e:	869a                	mv	a3,t1
    80200980:	ec06                	sd	ra,24(sp)
    80200982:	f83a                	sd	a4,48(sp)
    80200984:	fc3e                	sd	a5,56(sp)
    80200986:	e0c2                	sd	a6,64(sp)
    80200988:	e4c6                	sd	a7,72(sp)
    8020098a:	e41a                	sd	t1,8(sp)
    8020098c:	c89ff0ef          	jal	ra,80200614 <vprintfmt>
    80200990:	60e2                	ld	ra,24(sp)
    80200992:	6161                	addi	sp,sp,80
    80200994:	8082                	ret

0000000080200996 <sbi_console_putchar>:
    80200996:	4781                	li	a5,0
    80200998:	00003717          	auipc	a4,0x3
    8020099c:	66873703          	ld	a4,1640(a4) # 80204000 <SBI_CONSOLE_PUTCHAR>
    802009a0:	88ba                	mv	a7,a4
    802009a2:	852a                	mv	a0,a0
    802009a4:	85be                	mv	a1,a5
    802009a6:	863e                	mv	a2,a5
    802009a8:	00000073          	ecall
    802009ac:	87aa                	mv	a5,a0
    802009ae:	8082                	ret

00000000802009b0 <sbi_set_timer>:
    802009b0:	4781                	li	a5,0
    802009b2:	00003717          	auipc	a4,0x3
    802009b6:	66e73703          	ld	a4,1646(a4) # 80204020 <SBI_SET_TIMER>
    802009ba:	88ba                	mv	a7,a4
    802009bc:	852a                	mv	a0,a0
    802009be:	85be                	mv	a1,a5
    802009c0:	863e                	mv	a2,a5
    802009c2:	00000073          	ecall
    802009c6:	87aa                	mv	a5,a0
    802009c8:	8082                	ret

00000000802009ca <sbi_shutdown>:
    802009ca:	4781                	li	a5,0
    802009cc:	00003717          	auipc	a4,0x3
    802009d0:	63c73703          	ld	a4,1596(a4) # 80204008 <SBI_SHUTDOWN>
    802009d4:	88ba                	mv	a7,a4
    802009d6:	853e                	mv	a0,a5
    802009d8:	85be                	mv	a1,a5
    802009da:	863e                	mv	a2,a5
    802009dc:	00000073          	ecall
    802009e0:	87aa                	mv	a5,a0
    802009e2:	8082                	ret
