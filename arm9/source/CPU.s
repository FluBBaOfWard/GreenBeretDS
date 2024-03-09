#ifdef __arm__

#include "Shared/nds_asm.h"
#include "ARMZ80/ARMZ80.i"
#include "K005849/K005849.i"

#define CYCLE_PSL (H_PIXEL_COUNT/2)

	.global frameTotal
	.global waitMaskIn
	.global waitMaskOut

	.global run
	.global stepFrame
	.global cpuReset

	.syntax unified
	.arm

#if GBA
	.section .ewram, "ax", %progbits	;@ For the GBA
#else
	.section .text						;@ For anything else
#endif
	.align 2
;@----------------------------------------------------------------------------
run:						;@ Return after X frame(s)
	.type   run STT_FUNC
;@----------------------------------------------------------------------------
	ldrh r0,waitCountIn
	add r0,r0,#1
	ands r0,r0,r0,lsr#8
	strb r0,waitCountIn
	bxne lr
	stmfd sp!,{r4-r11,lr}

;@----------------------------------------------------------------------------
runStart:
;@----------------------------------------------------------------------------
	ldr r0,=EMUinput
	ldr r0,[r0]

	ldr r2,=yStart
	ldrb r1,[r2]
	tst r0,#0x200				;@ L?
	subsne r1,#1
	movmi r1,#0
	tst r0,#0x100				;@ R?
	addne r1,#1
	cmp r1,#GAME_HEIGHT-SCREEN_HEIGHT
	movpl r1,#GAME_HEIGHT-SCREEN_HEIGHT
	strb r1,[r2]

	bl refreshEMUjoypads		;@ Z=1 if communication ok

	ldr r0,frameLoopPtr
	blx r0

	ldr r1,=fpsValue
	ldr r0,[r1]
	add r0,r0,#1
	str r0,[r1]

	ldr r1,frameTotal
	add r1,r1,#1
	str r1,frameTotal

	ldrh r0,waitCountOut
	add r0,r0,#1
	ands r0,r0,r0,lsr#8
	strb r0,waitCountOut
	ldmfdeq sp!,{r4-r11,lr}		;@ Exit here if doing single frame:
	bxeq lr						;@ Return to rommenu()
	b runStart

;@----------------------------------------------------------------------------
frameLoopPtr:			.long gbRunFrame
z80CyclesPerScanline:	.long 0
frameTotal:			.long 0		;@ Let Gui.c see frame count for savestates
waitCountIn:		.byte 0
waitMaskIn:			.byte 0
waitCountOut:		.byte 0
waitMaskOut:		.byte 0

;@----------------------------------------------------------------------------
gbRunFrame:					;@ GreenBeret/Goemon
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}
	ldr z80ptr,=Z80OpTable
	add r0,z80ptr,#z80Regs
	ldmia r0,{z80f-z80pc,z80sp}	;@ Restore Z80 state
;@----------------------------------------------------------------------------
gbFrameLoop:
	ldr r0,z80CyclesPerScanline
	bl Z80RunXCycles
	ldr koptr,=k005849_0
	bl doScanline
	cmp r0,#0
	bne gbFrameLoop
;@----------------------------------------------------------------------------
	add r0,z80ptr,#z80Regs
	stmia r0,{z80f-z80pc,z80sp}	;@ Save Z80 state
	ldmfd sp!,{pc}

;@----------------------------------------------------------------------------
stepFrame:					;@ Return after 1 frame
	.type stepFrame STT_FUNC
;@----------------------------------------------------------------------------
	stmfd sp!,{r4-r11,lr}

	ldr r0,frameLoopPtr
	blx r0

	ldr r1,frameTotal
	add r1,r1,#1
	str r1,frameTotal

	ldmfd sp!,{r4-r11,lr}
	bx lr
;@----------------------------------------------------------------------------
cpuReset:		;@ Called by loadCart/resetGame
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}

;@---Speed - 3.072MHz / 60Hz		;Green Beret, Mr.Goemon.
	ldr r0,=CYCLE_PSL
	str r0,z80CyclesPerScanline

;@--------------------------------------
	ldr r0,=Z80OpTable
	mov r1,#0
	bl Z80Reset
	ldmfd sp!,{lr}
	bx lr
;@----------------------------------------------------------------------------
	.end
#endif // #ifdef __arm__
