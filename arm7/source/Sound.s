#ifdef __arm__

#include "SN76496/SN76496.i"

	.global soundInit
	.global soundReset
	.global soundMixer
	.global setMuteSoundGUI
	.global setMuteSoundGame
	.global SN_0_W

//	.extern pauseEmulation


;@----------------------------------------------------------------------------

	.syntax unified
	.arm

	.section .text
	.align 2
;@----------------------------------------------------------------------------
soundInit:
	.type soundInit STT_FUNC
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}

	ldr snptr,=SN76496_0
//	bl sn76496Init				;@ sound

	ldmfd sp!,{lr}
//	bx lr

;@----------------------------------------------------------------------------
soundReset:
	.type soundReset STT_FUNC
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}
	ldr snptr,=SN76496_0
	mov r0,#1
	bl sn76496Reset				;@ sound
	ldmfd sp!,{lr}
	bx lr

;@----------------------------------------------------------------------------
setMuteSoundGUI:
	.type   setMuteSoundGUI STT_FUNC
;@----------------------------------------------------------------------------
//	ldr r1,=pauseEmulation		;@ Output silence when emulation paused.
//	ldrb r0,[r1]
	strb r0,muteSoundGUI
	bx lr
;@----------------------------------------------------------------------------
setMuteSoundGame:			;@ For System E ?
;@----------------------------------------------------------------------------
	strb r0,muteSoundGame
	bx lr
;@----------------------------------------------------------------------------
soundMixer:					;@ r0=length, r1=pointer
	.type soundMixer STT_FUNC
;@----------------------------------------------------------------------------
;@	mov r11,r11
	stmfd sp!,{r0,r1,lr}

	ldr r2,muteSound
	cmp r2,#0
	bne silenceMix

	mov r0,r0,lsl#1
	ldr r1,pcmPtr0
	ldr snptr,=SN76496_0
	bl sn76496Mixer

	ldmfd sp,{r0,r1}
	ldr r3,pcmPtr0
wavLoop:
	ldr r2,[r3],#4
	adds r2,r2,r2,lsl#16
	mov r2,r2,rrx
	mov r2,r2,lsr#16
	subs r0,r0,#1
	strhpl r2,[r1],#2
	bhi wavLoop

	ldmfd sp!,{r0,r1,lr}
	bx lr

silenceMix:
	ldmfd sp!,{r0,r1}
	mov r12,r0
	mov r2,#0
silenceLoop:
	subs r12,r12,#1
	strhpl r2,[r1],#2
	bhi silenceLoop

	ldmfd sp!,{lr}
	bx lr

;@----------------------------------------------------------------------------
SN_0_W:
	.type SN_0_W STT_FUNC
;@----------------------------------------------------------------------------
	ldr snptr,=SN76496_0
	b sn76496W

;@----------------------------------------------------------------------------
pcmPtr0:	.long WAVBUFFER
pcmPtr1:	.long WAVBUFFER+528

muteSound:
muteSoundGUI:
	.byte 0
muteSoundGame:
	.byte 0
	.space 2

	.section .bss
	.align 2
SN76496_0:
	.space snSize
WAVBUFFER:
	.space 0x1000
;@----------------------------------------------------------------------------
	.end
#endif // #ifdef __arm__
