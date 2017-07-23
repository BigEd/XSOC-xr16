;
; reset.s -- minimal xr16 runtime library startup
; 
; Copyright (C) 1999, 2000, Gray Research LLC.  All rights reserved.
; The contents of this file are subject to the XSOC License Agreement;
; you may not use this file except in compliance with this Agreement.
; See the LICENSE file.
;
; This file must be assembled first, so that reset and interrupt receive
; the correct addresses:
; 0000 reset vector
; 0010 interrupt vector; interrupts are untested
;
; tabs=4

global __reset
global __interrupt
global _mulu2

align 16
reset:
	; perhaps should zero all regs
	lea sp,0x7ffe
	j __reset

align 16
interrupt:
	; save registers
	sw r1,saveregs+2
	lea r1,saveregs
	sw r2,4(r1)
	sw r3,6(r1)
	sw r4,8(r1)
	sw r5,10(r1)
	sw r6,12(r1)
	sw r7,14(r1)
	sw r8,16(r1)
	sw r9,18(r1)
	sw r10,20(r1)
	sw r11,22(r1)
	sw r12,24(r1)
	sw r13,26(r1)
	; r14 is the (reserved) interrupt return address
	sw r15,30(r1)

	; use interrupted function's stack
	call __interrupt

	; reload registers
	lea r1,saveregs
	lw r2,4(r1)
	lw r3,6(r1)
	lw r4,8(r1)
	lw r5,10(r1)
	lw r6,12(r1)
	lw r7,14(r1)
	lw r8,16(r1)
	lw r9,18(r1)
	lw r10,20(r1)
	lw r11,22(r1)
	lw r12,24(r1)
	lw r13,26(r1)
	; r14 is the (reserved) interrupt return address
	lw r15,30(r1) ; unnecessary but doesn't hurt to be sure
	lw r1,saveregs+2

	; return from interrupt
	reti

saveregs:
	bss 32

