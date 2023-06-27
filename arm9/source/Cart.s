#ifdef __arm__

#include "Shared/EmuSettings.h"
#include "ARMZ80/ARMZ80mac.h"
#include "K005849/K005849.i"

	.global machineInit
	.global loadCart
	.global z80Mapper
	.global emuFlags
	.global romNum
	.global cartFlags
	.global romStart
	.global vromBase0
	.global vromBase1
	.global promBase
	.global gberetMapRom

	.global ROM_Space


	.syntax unified
	.arm

	.section .rodata
	.align 2

rawRom:
/*
	.incbin "gberet/577l03.10c"
	.incbin "gberet/577l02.8c"
	.incbin "gberet/577l01.7c"
	.incbin "gberet/577l06.5e"
	.incbin "gberet/577l05.4e"
	.incbin "gberet/577l08.4f"
	.incbin "gberet/577l04.3e"
	.incbin "gberet/577l07.3f"
	.incbin "gberet/577h09.2f"
	.incbin "gberet/577h10.5f"
	.incbin "gberet/577h11.6f"
*/
/*
	.incbin "gberet/621d01.10c"
	.incbin "gberet/621d02.12c"
	.incbin "gberet/621d03.4d"
	.incbin "gberet/621d04.5d"
	.incbin "gberet/621a05.6d"
	.incbin "gberet/621a06.5f"
	.incbin "gberet/621a07.6f"
	.incbin "gberet/621a08.7f"
*/
	.align 2
;@----------------------------------------------------------------------------
machineInit: 	;@ Called from C
	.type   machineInit STT_FUNC
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}
	bl gfxInit
//	bl ioInit
//	bl soundInit
//	bl cpuInit

	ldmfd sp!,{lr}
	bx lr

	.section .ewram,"ax"
	.align 2
;@----------------------------------------------------------------------------
loadCart: 		;@ Called from C:  r0=rom number, r1=emuflags
	.type   loadCart STT_FUNC
;@----------------------------------------------------------------------------
	stmfd sp!,{r4-r11,lr}
	str r0,romNum
	str r1,emuFlags

//	ldr r7,=rawRom
	ldr r7,=ROM_Space
								;@ r7=rombase til end of loadcart so DON'T FUCK IT UP
	cmp r0,#3
	str r7,romStart				;@ Set rom base
	add r0,r7,#0xC000			;@ 0xC000
	addeq r0,r0,#0x4000			;@ Mr. Goemon
	str r0,vromBase0			;@ Spr & bg
	str r0,vromBase1			;@
	add r0,r0,#0x14000
	str r0,promBase				;@ Colour prom

	ldr r4,=MEMMAPTBL_
	ldr r5,=RDMEMTBL_
	ldr r6,=WRMEMTBL_

	mov r0,#0
	ldr r2,=memZ80R0
	ldr r3,=rom_W
tbLoop1:
	add r1,r7,r0,lsl#13
	str r1,[r4,r0,lsl#2]
	str r2,[r5,r0,lsl#2]
	str r3,[r6,r0,lsl#2]
	add r0,r0,#1
	cmp r0,#0x88
	bne tbLoop1

	ldr r2,=empty_R
	ldr r3,=empty_W
tbLoop2:
	str r1,[r4,r0,lsl#2]
	str r2,[r5,r0,lsl#2]
	str r3,[r6,r0,lsl#2]
	add r0,r0,#1
	cmp r0,#0x100
	bne tbLoop2

	mov r0,#0xFE				;@ Graphic
	ldr r1,=emuRAM
	ldr r2,=memZ80R6
	ldr r3,=k005849Ram_0W
	str r1,[r4,r0,lsl#2]		;@ MemMap
	str r2,[r5,r0,lsl#2]		;@ RdMem
	str r3,[r6,r0,lsl#2]		;@ WrMem

	mov r0,#0xFF				;@ IO
	ldr r2,=GreenBeretIO_R
	ldr r3,=GreenBeretIO_W
	str r2,[r5,r0,lsl#2]		;@ RdMem
	str r3,[r6,r0,lsl#2]		;@ WrMem


	bl gfxReset
	bl ioReset
	bl soundReset
	bl cpuReset

	ldmfd sp!,{r4-r11,lr}
	bx lr

;@----------------------------------------------------------------------------
//	.section itcm
;@----------------------------------------------------------------------------

;@----------------------------------------------------------------------------
z80Mapper:		;@ Rom paging..
;@----------------------------------------------------------------------------
	ands r0,r0,#0xFF			;@ Safety
	bxeq lr
	stmfd sp!,{r3-r8,lr}
	ldr r5,=MEMMAPTBL_
	ldr r2,[r5,r1,lsl#2]!
	ldr r3,[r5,#-1024]			;@ RDMEMTBL_
	ldr r4,[r5,#-2048]			;@ WRMEMTBL_

	mov r5,#0
	cmp r1,#0xF8
	movmi r5,#12

	add r6,z80ptr,#z80ReadTbl
	add r7,z80ptr,#z80WriteTbl
	add r8,z80ptr,#z80MemTbl
	b z80MemAps
z80MemApl:
	add r6,r6,#4
	add r7,r7,#4
	add r8,r8,#4
z80MemAp2:
	add r3,r3,r5
	sub r2,r2,#0x2000
z80MemAps:
	movs r0,r0,lsr#1
	bcc z80MemApl				;@ C=0
	strcs r3,[r6],#4			;@ readmem_tbl
	strcs r4,[r7],#4			;@ writemem_tb
	strcs r2,[r8],#4			;@ memmap_tbl
	bne z80MemAp2

;@------------------------------------------
z80Flush:		;@ Update cpu_pc & lastbank
;@------------------------------------------
	reEncodePC

	ldmfd sp!,{r3-r8,lr}
	bx lr


;@----------------------------------------------------------------------------
gberetMapRom:
;@----------------------------------------------------------------------------
	and r0,r0,#0xE0
	ldr r1,=romStart
	ldr r1,[r1]
	sub r1,r1,#0x3800
	add r1,r1,r0,lsl#6
	str r1,[z80ptr,#z80MemTbl+28]
	bx lr

;@----------------------------------------------------------------------------

romNum:
	.long 0						;@ romnumber
romInfo:						;@ Keep emuflags/BGmirror together for savestate/loadstate
emuFlags:
	.byte 0						;@ emuflags      (label this so Gui.c can take a peek) see EmuSettings.h for bitfields
//scaling:
	.byte SCALED				;@ (display type)
	.byte 0,0					;@ (sprite follow val)
cartFlags:
	.byte 0 					;@ cartflags
	.space 3

romStart:
	.long 0
vromBase0:
	.long 0
vromBase1:
	.long 0
promBase:
	.long 0
	.pool

	.section .bss
WRMEMTBL_:
	.space 256*4
RDMEMTBL_:
	.space 256*4
MEMMAPTBL_:
	.space 256*4
ROM_Space:
	.space 0x24220
;@----------------------------------------------------------------------------
	.end
#endif // #ifdef __arm__
