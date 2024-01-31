#ifdef __arm__

#include "c_defs.h"

	.global soundInit
	.global soundReset
	.global setMuteSoundGUI
	.global setMuteSoundGame
	.global SN_0_W

	.extern pauseEmulation


	.syntax unified
	.arm

	.section .text
	.align 2
;@----------------------------------------------------------------------------
soundInit:
	.type soundInit STT_FUNC
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}

	ldmfd sp!,{lr}
//	bx lr

;@----------------------------------------------------------------------------
soundReset:
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}
//	ldr r1,=SN76496_0
	mov r0,#1
//	bl SN76496Reset				;@ sound
	ldmfd sp!,{lr}
	bx lr

;@----------------------------------------------------------------------------
setMuteSoundGUI:
	.type   setMuteSoundGUI STT_FUNC
;@----------------------------------------------------------------------------
	ldr r1,=pauseEmulation		;@ Output silence when emulation paused.
	ldrb r0,[r1]
	strb r0,muteSoundGUI
	stmfd sp!,{r3,lr}
	orr r1,r0,#(FIFO_APU_PAUSE<<20)+(0<<16)
	mov r0,#15		// FIFO_USER_8
	bl fifoSendValue32
	ldmfd sp!,{r3,lr}
	bx lr
;@----------------------------------------------------------------------------
setMuteSoundGame:			;@ For System E ?
;@----------------------------------------------------------------------------
	strb r0,muteSoundGame
	bx lr

;@----------------------------------------------------------------------------
SN_0_W:
;@----------------------------------------------------------------------------
	stmfd sp!,{r3,lr}
	orr r1,r0,#(FIFO_CHIP0<<20)+(0<<16)
	mov r0,#15		// FIFO_USER_8
	bl fifoSendValue32
	ldmfd sp!,{r3,lr}
	bx lr

;@----------------------------------------------------------------------------

muteSound:
muteSoundGUI:
	.byte 0
muteSoundGame:
	.byte 0
	.space 2

;@----------------------------------------------------------------------------
	.end
#endif // #ifdef __arm__
