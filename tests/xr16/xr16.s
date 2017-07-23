; xr16.s -- simple xr16 test suite
; 
; Copyright (C) 1999, 2000, Gray Research LLC.  All rights reserved.
; The contents of this file are subject to the XSOC License Agreement;
; you may not use this file except in compliance with this Agreement.
; See the LICENSE file.

; $Header: /dist/tests/xr16.s 4     4/03/00 9:04p Jan $

; do not edit the next 10 lines w/o understanding of the hand assembled
; stores to w, and calls to return, in the branch and jump annul tests below.

; br
reset:
	br l10
	jal r2,error
ok:
	mov r2,r0
	j reset
w:
	word 0
w2:
	word 0
align 16
error:
	j reset

; cmp/beq
l10:
	cmp r0,r0
	beq l20
e10:
	jal r2,error

; cmp/bne
l20:
	cmp r0,r0
	bne e20
	cmpi r0,0
	bne e20
	br l30
e20:
	jal r2,error

; addi
l30:
	addi r1,r0,1
	addi r2,r0,1
	cmp r1,r2
	bne e30
	cmp r2,r1
	bne e30
	cmp r1,r0
	beq e30
	cmp r0,r1
	beq e30
	cmp r2,r0
	beq e30
	cmp r0,r2
	beq e30
	br l40
e30:
	jal r2,error

; add
l40:
	addi r1,r0,1
	addi r2,r0,1
	addi r3,r0,2
	cmp r1,r2
	bne e40
	cmp r1,r3
	beq e40
	cmp r2,r3
	beq e40
	add r4,r1,r2
	cmp r4,r3
	bne e40
	br l50
e40:
	jal r2,error

; sub
l50:
	addi r1,r0,1
	addi r2,r0,1
	addi r3,r0,2
	sub r4,r3,r2
	cmp r4,r1
	bne e50
	sub r4,r4,r2
	cmp r4,r0
	bne e50
	cmp r1,r2
	bne e50
	cmp r1,r3
	beq e50
	cmp r2,r3
	beq e50
	add r4,r1,r2
	cmp r4,r3
	bne e50
	br l55
e50:
	jal r2,error

; registers
l55:
	addi r1,r0,1
	add r2,r1,r1
	add r3,r2,r2
	add r4,r3,r3
	add r5,r4,r4
	add r6,r5,r5
	add r7,r6,r6
	add r8,r7,r7
	add r9,r8,r8
	add r10,r9,r9
	add r11,r10,r10
	add r12,r11,r11
	add r13,r12,r12
	add r14,r13,r13
	add r15,r14,r14
	cmpi r1,1
	bne e55
	cmpi r2,2
	bne e55
	cmpi r3,4
	bne e55
	cmpi r4,8
	bne e55
	cmpi r5,0x10
	bne e55
	cmpi r6,0x20
	bne e55
	cmpi r7,0x40
	bne e55
	cmpi r8,0x80
	bne e55
	cmpi r9,0x100
	bne e55
	cmpi r10,0x200
	bne e55
	cmpi r11,0x400
	bne e55
	cmpi r12,0x800
	bne e55
	cmpi r13,0x1000
	bne e55
	cmpi r14,0x2000
	bne e55
	cmpi r15,0x4000
	bne e55
	br t_add
e55:
	jal r2,error

; add
t_add:
	lea r1,1
	lea r2,1
	add r3,r1,r2
	cmpi r3,2
	bne e_add
	lea r1,0x8000
	lea r2,0x8000
	add r3,r1,r2
	cmpi r3,0
	bne e_add

	lea r1,2
	lea r2,-1
	add r3,r2,r1
	add r4,r1,r2
	cmpi r3,1
	bne e_add
	cmp r3,r4
	bne e_add

	lea r1,-2
	lea r2,1
	add r3,r2,r1
	add r4,r1,r2
	cmpi r3,-1
	bne e_add
	cmp r3,r4
	bne e_add

	lea r1,-2
	lea r2,-1
	add r3,r2,r1
	add r4,r1,r2
	cmpi r3,-3
	bne e_add
	cmp r3,r4
	bne e_add
	br t_sub
e_add:
	jal r2,error

; sub
t_sub:
	lea r1,1
	lea r2,1
	sub r3,r1,r2
	cmpi r3,0
	bne e_sub
	lea r1,0x8000
	lea r2,0x8000
	sub r3,r1,r2
	cmpi r3,0
	bne e_sub

	lea r1,2
	lea r2,-1
	sub r3,r2,r1
	sub r4,r1,r2
	sub r4,r0,r4
	cmpi r3,-3
	bne e_sub
	cmp r3,r4
	bne e_sub

	lea r1,-2
	lea r2,1
	sub r3,r2,r1
	sub r4,r1,r2
	sub r4,r0,r4
	cmpi r3,3
	bne e_sub
	cmp r3,r4
	bne e_sub

	lea r1,-2
	lea r2,-1
	sub r3,r2,r1
	sub r4,r1,r2
	sub r4,r0,r4
	cmpi r3,1
	bne e_sub
	cmp r3,r4
	bne e_sub
	br t_addi
e_sub:
	jal r2,error

; addi
t_addi:
	addi r1,r0,1
	addi r1,r1,2
	addi r1,r1,4
	addi r1,r1,8
	addi r1,r1,0x10
	addi r1,r1,0x20
	addi r1,r1,0x40
	addi r1,r1,0x80
	addi r1,r1,0x100
	addi r1,r1,0x200
	addi r1,r1,0x400
	addi r1,r1,0x800
	addi r1,r1,0x1000
	addi r1,r1,0x2000
	addi r1,r1,0x4000
	addi r1,r1,0x8000
	cmpi r1,-1
	bne e_addi
	subi r1,r0,1
	subi r1,r1,2
	subi r1,r1,4
	subi r1,r1,8
	subi r1,r1,0x10
	subi r1,r1,0x20
	subi r1,r1,0x40
	subi r1,r1,0x80
	subi r1,r1,0x100
	subi r1,r1,0x200
	subi r1,r1,0x400
	subi r1,r1,0x800
	subi r1,r1,0x1000
	subi r1,r1,0x2000
	subi r1,r1,0x4000
	lea r2,0x8000
	sub r1,r1,r2
	cmpi r1,1
	bne e_addi
	addi r1,r0,1
	addi r2,r0,1
	add r3,r2,r1
	add r4,r3,r2
	add r5,r4,r3
	add r6,r5,r4
	add r7,r6,r5
	add r8,r7,r6
	add r9,r8,r7
	add r10,r9,r8
	add r11,r10,r9
	add r12,r11,r10
	add r13,r12,r11
	add r14,r13,r12
	add r15,r14,r13
	add r1,r15,r14
	add r2,r1,r15
	add r3,r2,r1
	add r4,r3,r2
	add r5,r4,r3
	add r6,r5,r4
	add r7,r6,r5
	add r8,r7,r6
	add r9,r8,r7
	add r10,r9,r8
	add r11,r10,r9
	add r12,r11,r10
	add r13,r12,r11
	add r14,r13,r12
	add r15,r14,r13
	add r1,r15,r14
	add r2,r1,r15
	add r3,r2,r1
	add r4,r3,r2
	add r5,r4,r3
	add r6,r5,r4
	add r7,r6,r5
	add r8,r7,r6
	add r9,r8,r7
	add r10,r9,r8
	add r11,r10,r9
	add r12,r11,r10
	add r13,r12,r11
	add r14,r13,r12
	add r15,r14,r13
	cmpi r15,16258
	bne e_addi
	br t_log
e_addi:
	jal r2,error

; and/or/xor/andn
t_log:
	lea r1,1

	mov r2,r0
	and r2,r0
	cmpi r2,0
	bne e_log
	mov r2,r0
	or r2,r0
	cmpi r2,0
	bne e_log
	mov r2,r0
	xor r2,r0
	cmpi r2,0
	bne e_log
	mov r2,r0
	andn r2,r0
	cmpi r2,0
	bne e_log

	mov r2,r1
	and r2,r0
	cmpi r2,0
	bne e_log
	mov r2,r1
	or r2,r0
	cmpi r2,1
	bne e_log
	mov r2,r1
	xor r2,r0
	cmpi r2,1
	bne e_log
	mov r2,r1
	andn r2,r0
	cmpi r2,1
	bne e_log

	mov r2,r0
	and r2,r1
	cmpi r2,0
	bne e_log
	mov r2,r0
	or r2,r1
	cmpi r2,1
	bne e_log
	mov r2,r0
	xor r2,r1
	cmpi r2,1
	bne e_log
	mov r2,r0
	andn r2,r1
	cmpi r2,0
	bne e_log

	mov r2,r1
	and r2,r1
	cmpi r2,1
	bne e_log
	mov r2,r1
	or r2,r1
	cmpi r2,1
	bne e_log
	mov r2,r1
	xor r2,r1
	cmpi r2,0
	bne e_log
	mov r2,r1
	andn r2,r1
	cmpi r2,0
	bne e_log
	br t_log2
e_log:
	jal r2,error

t_log2:
	lea r1,0x5555
	lea r2,0xAAAA

	mov r3,r1
	and r3,r1
	cmp r3,r1
	bne e_log2
	mov r3,r1
	or r3,r1
	cmp r3,r1
	bne e_log2
	mov r3,r1
	xor r3,r1
	cmpi r3,0
	bne e_log2
	mov r3,r1
	andn r3,r1
	cmpi r3,0
	bne e_log2

	mov r3,r2
	and r3,r1
	cmpi r3,0
	bne e_log2
	mov r3,r2
	or r3,r1
	cmpi r3,-1
	bne e_log2
	mov r3,r2
	xor r3,r1
	cmpi r3,-1
	bne e_log2
	mov r3,r2
	andn r3,r1
	cmp r3,r2
	bne e_log2

	mov r3,r1
	and r3,r2
	cmpi r3,0
	bne e_log2
	mov r3,r1
	or r3,r2
	cmpi r3,-1
	bne e_log2
	mov r3,r1
	xor r3,r2
	cmpi r3,-1
	bne e_log2
	mov r3,r1
	andn r3,r2
	cmp r3,r1
	bne e_log2

	mov r3,r2
	and r3,r2
	cmp r3,r2
	bne e_log2
	mov r3,r2
	or r3,r2
	cmp r3,r2
	bne e_log2
	mov r3,r2
	xor r3,r2
	cmpi r3,0
	bne e_log2
	mov r3,r2
	andn r3,r2
	cmpi r3,0
	bne e_log2
	br t_log3
e_log2:
	jal r2,error

t_log3:
	lea r1,0xF0F0
	lea r2,0x5555

	mov r3,r1
	and r3,r1
	cmp r3,r1
	bne e_log3
	mov r3,r1
	or r3,r1
	cmp r3,r1
	bne e_log3
	mov r3,r1
	xor r3,r1
	cmpi r3,0
	bne e_log3
	mov r3,r1
	andn r3,r1
	cmpi r3,0
	bne e_log3

	mov r3,r2
	and r3,r1
	cmpi r3,0x5050
	bne e_log3
	mov r3,r2
	or r3,r1
	cmpi r3,0xF5F5
	bne e_log3
	mov r3,r2
	xor r3,r1
	cmpi r3,0xA5A5
	bne e_log3
	mov r3,r2
	andn r3,r1
	cmpi r3,0x0505
	bne e_log3

	mov r3,r1
	and r3,r2
	cmpi r3,0x5050
	bne e_log3
	mov r3,r1
	or r3,r2
	cmpi r3,0xF5F5
	bne e_log3
	mov r3,r1
	xor r3,r2
	cmpi r3,0xA5A5
	bne e_log3
	mov r3,r1
	andn r3,r2
	cmpi r3,0xA0A0
	bne e_log3

	mov r3,r2
	and r3,r2
	cmp r3,r2
	bne e_log3
	mov r3,r2
	or r3,r2
	cmp r3,r2
	bne e_log3
	mov r3,r2
	xor r3,r2
	cmpi r3,0
	bne e_log3
	mov r3,r2
	andn r3,r2
	cmpi r3,0
	bne e_log3
	br t_logi
e_log3:
	jal r2,error

; andi/ori/xori/andni
t_logi:
	lea r1,1

	mov r2,r0
	andi r2,0
	cmpi r2,0
	bne e_logi
	mov r2,r0
	ori r2,0
	cmpi r2,0
	bne e_logi
	mov r2,r0
	xori r2,0
	cmpi r2,0
	bne e_logi
	mov r2,r0
	andni r2,0
	cmpi r2,0
	bne e_logi

	mov r2,r1
	andi r2,0
	cmpi r2,0
	bne e_logi
	mov r2,r1
	ori r2,0
	cmpi r2,1
	bne e_logi
	mov r2,r1
	xori r2,0
	cmpi r2,1
	bne e_logi
	mov r2,r1
	andni r2,0
	cmpi r2,1
	bne e_logi

	mov r2,r0
	andi r2,1
	cmpi r2,0
	bne e_logi
	mov r2,r0
	ori r2,1
	cmpi r2,1
	bne e_logi
	mov r2,r0
	xori r2,1
	cmpi r2,1
	bne e_logi
	mov r2,r0
	andni r2,1
	cmpi r2,0
	bne e_logi

	mov r2,r1
	andi r2,1
	cmpi r2,1
	bne e_logi
	mov r2,r1
	ori r2,1
	cmpi r2,1
	bne e_logi
	mov r2,r1
	xori r2,1
	cmpi r2,0
	bne e_logi
	mov r2,r1
	andni r2,1
	cmpi r2,0
	bne e_logi
	br t_logi2
e_logi:
	jal r2,error

t_logi2:
	lea r1,0x5555
	lea r2,0xAAAA

	mov r3,r1
	andi r3,0x5555
	cmp r3,r1
	bne e_logi2
	mov r3,r1
	ori r3,0x5555
	cmp r3,r1
	bne e_logi2
	mov r3,r1
	xori r3,0x5555
	cmpi r3,0
	bne e_logi2
	mov r3,r1
	andni r3,0x5555
	cmpi r3,0
	bne e_logi2

	mov r3,r2
	andi r3,0x5555
	cmpi r3,0
	bne e_logi2
	mov r3,r2
	ori r3,0x5555
	cmpi r3,-1
	bne e_logi2
	mov r3,r2
	xori r3,0x5555
	cmpi r3,-1
	bne e_logi2
	mov r3,r2
	andni r3,0x5555
	cmp r3,r2
	bne e_logi2

	mov r3,r1
	andi r3,0xAAAA
	cmpi r3,0
	bne e_logi2
	mov r3,r1
	ori r3,0xAAAA
	cmpi r3,-1
	bne e_logi2
	mov r3,r1
	xori r3,0xAAAA
	cmpi r3,-1
	bne e_logi2
	mov r3,r1
	andni r3,0xAAAA
	cmp r3,r1
	bne e_logi2

	mov r3,r2
	andi r3,0xAAAA
	cmp r3,r2
	bne e_logi2
	mov r3,r2
	ori r3,0xAAAA
	cmp r3,r2
	bne e_logi2
	mov r3,r2
	xori r3,0xAAAA
	cmpi r3,0
	bne e_logi2
	mov r3,r2
	andni r3,0xAAAA
	cmpi r3,0
	bne e_logi2
	br t_logi3
e_logi2:
	jal r2,error

t_logi3:
	lea r1,0xF0F0
	lea r2,0x5555

	mov r3,r1
	andi r3,0xF0F0
	cmp r3,r1
	bne e_logi3
	mov r3,r1
	ori r3,0xF0F0
	cmp r3,r1
	bne e_logi3
	mov r3,r1
	xori r3,0xF0F0
	cmpi r3,0
	bne e_logi3
	mov r3,r1
	andni r3,0xF0F0
	cmpi r3,0
	bne e_logi3

	mov r3,r2
	andi r3,0xF0F0
	cmpi r3,0x5050
	bne e_logi3
	mov r3,r2
	ori r3,0xF0F0
	cmpi r3,0xF5F5
	bne e_logi3
	mov r3,r2
	xori r3,0xF0F0
	cmpi r3,0xA5A5
	bne e_logi3
	mov r3,r2
	andni r3,0xF0F0
	cmpi r3,0x0505
	bne e_logi3

	mov r3,r1
	andi r3,0x5555
	cmpi r3,0x5050
	bne e_logi3
	mov r3,r1
	ori r3,0x5555
	cmpi r3,0xF5F5
	bne e_logi3
	mov r3,r1
	xori r3,0x5555
	cmpi r3,0xA5A5
	bne e_logi3
	mov r3,r1
	andni r3,0x5555
	cmpi r3,0xA0A0
	bne e_logi3

	mov r3,r2
	andi r3,0x5555
	cmp r3,r2
	bne e_logi3
	mov r3,r2
	ori r3,0x5555
	cmp r3,r2
	bne e_logi3
	mov r3,r2
	xori r3,0x5555
	cmpi r3,0
	bne e_logi3
	mov r3,r2
	andni r3,0x5555
	cmpi r3,0
	bne e_logi3
;	br l190
	br t_slli
e_logi3:
	jal r2,error

; ; adc/sbc/adci/sbci
; l190:
; 	lea r1,0xFFFF
; 	mov r2,r1
; 	mov r3,r1
; 	mov r4,r1
; 	addi r1,r1,1
; 	adc r2,r0
; 	adc r3,r0
; 	adc r4,r0
; 	cmpi r3,0
; 	bne e190
; 
; 	subi r1,r1,1
; 	sbc r2,r0
; 	sbc r3,r0
; 	sbc r4,r0
; 	cmpi r4,-1
; 	bne e190
; 
; 	addi r1,r1,1
; 	adci r2,0
; 	adci r3,0
; 	adci r4,0
; 	cmpi r3,0
; 	bne e190
; 
; 	subi r1,r1,1
; 	sbci r2,0
; 	sbci r3,0
; 	sbci r4,0
; 	cmpi r4,-1
; 	bne e190
; 	j reset
; e190:
; 	jal r2,error

t_slli:
	lea r1,1
	slli r1,1
	cmpi r1,2
	bne e_slli
	slli r1,1
	cmpi r1,4
	bne e_slli
	slli r1,1
	cmpi r1,8
	bne e_slli
	slli r1,1
	cmpi r1,0x10
	bne e_slli
	slli r1,1
	cmpi r1,0x20
	bne e_slli
	slli r1,1
	cmpi r1,0x40
	bne e_slli
	slli r1,1
	cmpi r1,0x80
	bne e_slli
	slli r1,1
	cmpi r1,0x100
	bne e_slli
	slli r1,1
	cmpi r1,0x200
	bne e_slli
	slli r1,1
	cmpi r1,0x400
	bne e_slli
	slli r1,1
	cmpi r1,0x800
	bne e_slli
	slli r1,1
	cmpi r1,0x1000
	bne e_slli
	slli r1,1
	cmpi r1,0x2000
	bne e_slli
	slli r1,1
	cmpi r1,0x4000
	bne e_slli
	slli r1,1
	lea r2,0x8000
	cmp r2,r1
	bne e_slli
	br t_srai
e_slli:
	jal r2,error

t_srai:
	srai r1,1
	cmpi r1,0xC000
	bne e_srai
	srai r1,1
	cmpi r1,0xE000
	bne e_srai
	srai r1,1
	cmpi r1,0xF000
	bne e_srai
	srai r1,1
	cmpi r1,0xF800
	bne e_srai
	srai r1,1
	cmpi r1,0xFC00
	bne e_srai
	srai r1,1
	cmpi r1,0xFE00
	bne e_srai
	srai r1,1
	cmpi r1,0xFF00
	bne e_srai
	srai r1,1
	cmpi r1,0xFF80
	bne e_srai
	srai r1,1
	cmpi r1,0xFFC0
	bne e_srai
	srai r1,1
	cmpi r1,0xFFE0
	bne e_srai
	srai r1,1
	cmpi r1,0xFFF0
	bne e_srai
	srai r1,1
	cmpi r1,0xFFF8
	bne e_srai
	srai r1,1
	cmpi r1,0xFFFC
	bne e_srai
	srai r1,1
	cmpi r1,0xFFFE
	bne e_srai
	srai r1,1
	cmpi r1,0xFFFF
	bne e_srai
	lea r1,0x8000
	srli r1,1
	cmpi r1,0x4000
	bne e_srai
	srli r1,1
	cmpi r1,0x2000
	bne e_srai
	srli r1,1
	cmpi r1,0x1000
	bne e_srai
	srli r1,1
	cmpi r1,0x800
	bne e_srai
	srli r1,1
	cmpi r1,0x400
	bne e_srai
	srli r1,1
	cmpi r1,0x200
	bne e_srai
	srli r1,1
	cmpi r1,0x100
	bne e_srai
	srli r1,1
	cmpi r1,0x80
	bne e_srai
	srli r1,1
	cmpi r1,0x40
	bne e_srai
	srli r1,1
	cmpi r1,0x20
	bne e_srai
	srli r1,1
	cmpi r1,0x10
	bne e_srai
	srli r1,1
	cmpi r1,8
	bne e_srai
	srli r1,1
	cmpi r1,4
	bne e_srai
	srli r1,1
	cmpi r1,2
	bne e_srai
	srli r1,1
	cmpi r1,1
	bne e_srai
	srli r1,1
	cmpi r1,0
	bne e_srai
	br t_shc
e_srai:
	jal r2,error

t_shc:
	lea r1,1
	slli r1,15
	lea r2,0x8000
	cmp r2,r1
	bne e_shc
	srli r1,15
	cmpi r1,1
	bne e_shc
	slli r1,15
	srai r1,15
	cmpi r1,-1
	bne e_shc
	br t_ldst
e_shc:
	jal r2,error

; lw/sw/lb/sb/lbs
t_ldst:
	lea r1,0xABCD
	sw r1,w
	lw r2,w
	cmp r1,r2
	bne e_ldst
	lb r2,w
	cmpi r2,0xAB
	bne e_ldst
	lb r3,w+1
	cmpi r3,0xCD
	bne e_ldst
	sb r3,w
	sb r2,w+1
	lw r1,w
	cmpi r1,0xCDAB
	bne e_ldst
	lea r1,0x1234
	sw r1,w2
	lw r2,w2
	cmp r1,r2
	bne e_ldst
	lb r2,w2
	cmpi r2,0x12
	bne e_ldst
	lb r3,w2+1
	cmpi r3,0x34
	bne e_ldst
	sb r3,w2
	sb r2,w2+1
	lw r1,w2
	cmpi r1,0x3412
	bne e_ldst
	lea r1,-1
	sb r1,w
	lb r1,w
	cmpi r1,255
	bne e_ldst
	lbs r1,w
	cmpi r1,-1
	bne e_ldst
	lea r1,1
	sb r1,w
	lb r1,w
	cmpi r1,1
	bne e_ldst
	lbs r1,w
	cmpi r1,1
	bne e_ldst
	br t_jal
e_ldst:
	jal r2,error

; jal
t_jal:
	jal r15,jals
	jal r15,jals+2
	jal r15,jals+4
	jal r15,jals+6
	jal r15,jals+8
	jal r15,jals+10
	jal r15,jals+12
	jal r15,jals+14
	jal r15,jals+16
	jal r15,jals+18
	jal r15,jals+20
	jal r15,jals+22
	jal r15,jals+24
	jal r15,jals+26
	jal r15,jals+28
	jal r15,jals+30
	add r1,r1,r2
	add r1,r1,r3
	add r1,r1,r4
	add r1,r1,r5
	add r1,r1,r6
	add r1,r1,r7
	add r1,r1,r8
	add r1,r1,r9
	add r1,r1,r10
	add r1,r1,r11
	add r1,r1,r12
	add r1,r1,r13
	add r1,r1,r14
	add r1,r1,r15
	jal r15,sum
	cmp r1,r2
	bne e_jal

	lea r1,jals
	jal r15,4(r1)
	jal r15,6(r1)
	jal r15,8(r1)
	jal r15,10(r1)
	jal r15,12(r1)
	jal r15,14(r1)
	jal r15,16(r1)
	jal r15,18(r1)
	jal r15,20(r1)
	jal r15,22(r1)
	jal r15,24(r1)
	jal r15,26(r1)
	jal r15,28(r1)
	jal r15,30(r1)
	lea r1,jals+4
	add r1,r1,r2
	add r1,r1,r3
	add r1,r1,r4
	add r1,r1,r5
	add r1,r1,r6
	add r1,r1,r7
	add r1,r1,r8
	add r1,r1,r9
	add r1,r1,r10
	add r1,r1,r11
	add r1,r1,r12
	add r1,r1,r13
	add r1,r1,r14
	add r1,r1,r15
	jal r15,sum
	cmp r1,r2
	bne e_jal
	br t_br

e_jal:
	jal r2,error

jals:
	jal r0,(r15)
	jal r1,(r15)
	jal r2,(r15)
	jal r3,(r15)
	jal r4,(r15)
	jal r5,(r15)
	jal r6,(r15)
	jal r7,(r15)
	jal r8,(r15)
	jal r9,(r15)
	jal r10,(r15)
	jal r11,(r15)
	jal r12,(r15)
	jal r13,(r15)
	jal r14,(r15)
	jal r15,(r15)

sum:
	lea r2,jals+4
	lea r3,jals+6
	add r2,r3,r2
	lea r3,jals+8
	add r2,r3,r2
	lea r3,jals+10
	add r2,r3,r2
	lea r3,jals+12
	add r2,r3,r2
	lea r3,jals+14
	add r2,r3,r2
	lea r3,jals+16
	add r2,r3,r2
	lea r3,jals+18
	add r2,r3,r2
	lea r3,jals+20
	add r2,r3,r2
	lea r3,jals+22
	add r2,r3,r2
	lea r3,jals+24
	add r2,r3,r2
	lea r3,jals+26
	add r2,r3,r2
	lea r3,jals+28
	add r2,r3,r2
	lea r3,jals+30
	add r2,r3,r2
	lea r3,jals+32
	add r2,r3,r2
	ret

t_br:
	cmp r0,r0
	beq t_br1
	br e_br
t_br1:
	cmp r0,r0
	bne e_br
	lea r1,0xFFFF
	addi r1,r1,1
	bc t_br2
	br e_br
t_br2:
	lea r1,0xFFFF
	addi r1,r1,1
	bnc e_br
	lea r1,0xFFFF
	addi r1,r1,0
	bc e_br
	lea r1,32767
	addi r1,r1,1
	bc e_br
	lea r1,32767
	addi r1,r1,1
	bv t_br3
	br e_br
t_br3:
	lea r1,32767
	addi r1,r1,1
	bnv e_br
	lea r1,32767
	addi r1,r1,0
	bv e_br
	lea r1,32767
	addi r1,r1,0
	bnv t_br4
	br e_br
t_br4:
	lea r1,32767
	addi r1,r1,1
	bnv e_br
	lea r1,-32768
	addi r1,r1,-1
	bv t_br5
	br e_br
t_br5:
	lea r1,-32768
	addi r1,r1,-1
	bnv e_br
	lea r1,-32768
	addi r1,r1,0
	bv e_br
	lea r1,-32768
	addi r1,r1,1
	bv e_br
	br t_blt
e_br:
	jal r2,error

t_blt:

t_blt0:
	lea  r2,-32768
	cmpi r2,-32768
	blt  e_blt
t_blt1:
	cmpi r2,-32767
	blt  t_blt2
	br   e_blt
t_blt2:
	cmpi r2,-1
	blt  t_blt3
	br   e_blt
t_blt3:
	cmpi r2,0
	blt  t_blt4
	br   e_blt
t_blt4:
	cmpi r2,1
	blt  t_blt5
	br   e_blt
t_blt5:
	cmpi r2,32767
	blt  t_blt6
	br   e_blt
t_blt6:
	lea  r2,-32767
	cmpi r2,-32768
	blt  e_blt
t_blt7:
	cmpi r2,-32767
	blt  e_blt
t_blt8:
	cmpi r2,-1
	blt  t_blt9
	br   e_blt
t_blt9:
	cmpi r2,0
	blt  t_blt10
	br   e_blt
t_blt10:
	cmpi r2,1
	blt  t_blt11
	br   e_blt
t_blt11:
	cmpi r2,32767
	blt  t_blt12
	br   e_blt
t_blt12:
	lea  r2,-1
	cmpi r2,-32768
	blt  e_blt
t_blt13:
	cmpi r2,-32767
	blt  e_blt
t_blt14:
	cmpi r2,-1
	blt  e_blt
t_blt15:
	cmpi r2,0
	blt  t_blt16
	br   e_blt
t_blt16:
	cmpi r2,1
	blt  t_blt17
	br   e_blt
t_blt17:
	cmpi r2,32767
	blt  t_blt18
	br   e_blt
t_blt18:
	lea  r2,0
	cmpi r2,-32768
	blt  e_blt
t_blt19:
	cmpi r2,-32767
	blt  e_blt
t_blt20:
	cmpi r2,-1
	blt  e_blt
t_blt21:
	cmpi r2,0
	blt  e_blt
t_blt22:
	cmpi r2,1
	blt  t_blt23
	br   e_blt
t_blt23:
	cmpi r2,32767
	blt  t_blt24
	br   e_blt
t_blt24:
	lea  r2,1
	cmpi r2,-32768
	blt  e_blt
t_blt25:
	cmpi r2,-32767
	blt  e_blt
t_blt26:
	cmpi r2,-1
	blt  e_blt
t_blt27:
	cmpi r2,0
	blt  e_blt
t_blt28:
	cmpi r2,1
	blt  e_blt
t_blt29:
	cmpi r2,32767
	blt  t_blt30
	br   e_blt
t_blt30:
	lea  r2,32767
	cmpi r2,-32768
	blt  e_blt
t_blt31:
	cmpi r2,-32767
	blt  e_blt
t_blt32:
	cmpi r2,-1
	blt  e_blt
t_blt33:
	cmpi r2,0
	blt  e_blt
t_blt34:
	cmpi r2,1
	blt  e_blt
t_blt35:
	cmpi r2,32767
	blt  e_blt
t_blt36:
	br t_blt37
e_blt:
	jal r2,error
t_blt37:

t_bge0:
	lea  r2,-32768
	cmpi r2,-32768
	bge  t_bge1
	br   e_bge
t_bge1:
	cmpi r2,-32767
	bge  e_bge
t_bge2:
	cmpi r2,-1
	bge  e_bge
t_bge3:
	cmpi r2,0
	bge  e_bge
t_bge4:
	cmpi r2,1
	bge  e_bge
t_bge5:
	cmpi r2,32767
	bge  e_bge
t_bge6:
	lea  r2,-32767
	cmpi r2,-32768
	bge  t_bge7
	br   e_bge
t_bge7:
	cmpi r2,-32767
	bge  t_bge8
	br   e_bge
t_bge8:
	cmpi r2,-1
	bge  e_bge
t_bge9:
	cmpi r2,0
	bge  e_bge
t_bge10:
	cmpi r2,1
	bge  e_bge
t_bge11:
	cmpi r2,32767
	bge  e_bge
t_bge12:
	lea  r2,-1
	cmpi r2,-32768
	bge  t_bge13
	br   e_bge
t_bge13:
	cmpi r2,-32767
	bge  t_bge14
	br   e_bge
t_bge14:
	cmpi r2,-1
	bge  t_bge15
	br   e_bge
t_bge15:
	cmpi r2,0
	bge  e_bge
t_bge16:
	cmpi r2,1
	bge  e_bge
t_bge17:
	cmpi r2,32767
	bge  e_bge
t_bge18:
	lea  r2,0
	cmpi r2,-32768
	bge  t_bge19
	br   e_bge
t_bge19:
	cmpi r2,-32767
	bge  t_bge20
	br   e_bge
t_bge20:
	cmpi r2,-1
	bge  t_bge21
	br   e_bge
t_bge21:
	cmpi r2,0
	bge  t_bge22
	br   e_bge
t_bge22:
	cmpi r2,1
	bge  e_bge
t_bge23:
	cmpi r2,32767
	bge  e_bge
t_bge24:
	lea  r2,1
	cmpi r2,-32768
	bge  t_bge25
	br   e_bge
t_bge25:
	cmpi r2,-32767
	bge  t_bge26
	br   e_bge
t_bge26:
	cmpi r2,-1
	bge  t_bge27
	br   e_bge
t_bge27:
	cmpi r2,0
	bge  t_bge28
	br   e_bge
t_bge28:
	cmpi r2,1
	bge  t_bge29
	br   e_bge
t_bge29:
	cmpi r2,32767
	bge  e_bge
t_bge30:
	lea  r2,32767
	cmpi r2,-32768
	bge  t_bge31
	br   e_bge
t_bge31:
	cmpi r2,-32767
	bge  t_bge32
	br   e_bge
t_bge32:
	cmpi r2,-1
	bge  t_bge33
	br   e_bge
t_bge33:
	cmpi r2,0
	bge  t_bge34
	br   e_bge
t_bge34:
	cmpi r2,1
	bge  t_bge35
	br   e_bge
t_bge35:
	cmpi r2,32767
	bge  t_bge36
	br   e_bge
t_bge36:
	br t_bge37
e_bge:
	jal r2,error
t_bge37:

t_ble0:
	lea  r2,-32768
	cmpi r2,-32768
	ble  t_ble1
	br   e_ble
t_ble1:
	cmpi r2,-32767
	ble  t_ble2
	br   e_ble
t_ble2:
	cmpi r2,-1
	ble  t_ble3
	br   e_ble
t_ble3:
	cmpi r2,0
	ble  t_ble4
	br   e_ble
t_ble4:
	cmpi r2,1
	ble  t_ble5
	br   e_ble
t_ble5:
	cmpi r2,32767
	ble  t_ble6
	br   e_ble
t_ble6:
	lea  r2,-32767
	cmpi r2,-32768
	ble  e_ble
t_ble7:
	cmpi r2,-32767
	ble  t_ble8
	br   e_ble
t_ble8:
	cmpi r2,-1
	ble  t_ble9
	br   e_ble
t_ble9:
	cmpi r2,0
	ble  t_ble10
	br   e_ble
t_ble10:
	cmpi r2,1
	ble  t_ble11
	br   e_ble
t_ble11:
	cmpi r2,32767
	ble  t_ble12
	br   e_ble
t_ble12:
	lea  r2,-1
	cmpi r2,-32768
	ble  e_ble
t_ble13:
	cmpi r2,-32767
	ble  e_ble
t_ble14:
	cmpi r2,-1
	ble  t_ble15
	br   e_ble
t_ble15:
	cmpi r2,0
	ble  t_ble16
	br   e_ble
t_ble16:
	cmpi r2,1
	ble  t_ble17
	br   e_ble
t_ble17:
	cmpi r2,32767
	ble  t_ble18
	br   e_ble
t_ble18:
	lea  r2,0
	cmpi r2,-32768
	ble  e_ble
t_ble19:
	cmpi r2,-32767
	ble  e_ble
t_ble20:
	cmpi r2,-1
	ble  e_ble
t_ble21:
	cmpi r2,0
	ble  t_ble22
	br   e_ble
t_ble22:
	cmpi r2,1
	ble  t_ble23
	br   e_ble
t_ble23:
	cmpi r2,32767
	ble  t_ble24
	br   e_ble
t_ble24:
	lea  r2,1
	cmpi r2,-32768
	ble  e_ble
t_ble25:
	cmpi r2,-32767
	ble  e_ble
t_ble26:
	cmpi r2,-1
	ble  e_ble
t_ble27:
	cmpi r2,0
	ble  e_ble
t_ble28:
	cmpi r2,1
	ble  t_ble29
	br   e_ble
t_ble29:
	cmpi r2,32767
	ble  t_ble30
	br   e_ble
t_ble30:
	lea  r2,32767
	cmpi r2,-32768
	ble  e_ble
t_ble31:
	cmpi r2,-32767
	ble  e_ble
t_ble32:
	cmpi r2,-1
	ble  e_ble
t_ble33:
	cmpi r2,0
	ble  e_ble
t_ble34:
	cmpi r2,1
	ble  e_ble
t_ble35:
	cmpi r2,32767
	ble  t_ble36
	br   e_ble
t_ble36:
	br t_ble37
e_ble:
	jal r2,error
t_ble37:

t_bgt0:
	lea  r2,-32768
	cmpi r2,-32768
	bgt  e_bgt
t_bgt1:
	cmpi r2,-32767
	bgt  e_bgt
t_bgt2:
	cmpi r2,-1
	bgt  e_bgt
t_bgt3:
	cmpi r2,0
	bgt  e_bgt
t_bgt4:
	cmpi r2,1
	bgt  e_bgt
t_bgt5:
	cmpi r2,32767
	bgt  e_bgt
t_bgt6:
	lea  r2,-32767
	cmpi r2,-32768
	bgt  t_bgt7
	br   e_bgt
t_bgt7:
	cmpi r2,-32767
	bgt  e_bgt
t_bgt8:
	cmpi r2,-1
	bgt  e_bgt
t_bgt9:
	cmpi r2,0
	bgt  e_bgt
t_bgt10:
	cmpi r2,1
	bgt  e_bgt
t_bgt11:
	cmpi r2,32767
	bgt  e_bgt
t_bgt12:
	lea  r2,-1
	cmpi r2,-32768
	bgt  t_bgt13
	br   e_bgt
t_bgt13:
	cmpi r2,-32767
	bgt  t_bgt14
	br   e_bgt
t_bgt14:
	cmpi r2,-1
	bgt  e_bgt
t_bgt15:
	cmpi r2,0
	bgt  e_bgt
t_bgt16:
	cmpi r2,1
	bgt  e_bgt
t_bgt17:
	cmpi r2,32767
	bgt  e_bgt
t_bgt18:
	lea  r2,0
	cmpi r2,-32768
	bgt  t_bgt19
	br   e_bgt
t_bgt19:
	cmpi r2,-32767
	bgt  t_bgt20
	br   e_bgt
t_bgt20:
	cmpi r2,-1
	bgt  t_bgt21
	br   e_bgt
t_bgt21:
	cmpi r2,0
	bgt  e_bgt
t_bgt22:
	cmpi r2,1
	bgt  e_bgt
t_bgt23:
	cmpi r2,32767
	bgt  e_bgt
t_bgt24:
	lea  r2,1
	cmpi r2,-32768
	bgt  t_bgt25
	br   e_bgt
t_bgt25:
	cmpi r2,-32767
	bgt  t_bgt26
	br   e_bgt
t_bgt26:
	cmpi r2,-1
	bgt  t_bgt27
	br   e_bgt
t_bgt27:
	cmpi r2,0
	bgt  t_bgt28
	br   e_bgt
t_bgt28:
	cmpi r2,1
	bgt  e_bgt
t_bgt29:
	cmpi r2,32767
	bgt  e_bgt
t_bgt30:
	lea  r2,32767
	cmpi r2,-32768
	bgt  t_bgt31
	br   e_bgt
t_bgt31:
	cmpi r2,-32767
	bgt  t_bgt32
	br   e_bgt
t_bgt32:
	cmpi r2,-1
	bgt  t_bgt33
	br   e_bgt
t_bgt33:
	cmpi r2,0
	bgt  t_bgt34
	br   e_bgt
t_bgt34:
	cmpi r2,1
	bgt  t_bgt35
	br   e_bgt
t_bgt35:
	cmpi r2,32767
	bgt  e_bgt
t_bgt36:
	br t_bgt37
e_bgt:
	jal r2,error
t_bgt37:

t_bltu0:
	lea  r2,-32768
	cmpi r2,-32768
	bltu e_bltu
t_bltu1:
	cmpi r2,-32767
	bltu t_bltu2
	br   e_bltu
t_bltu2:
	cmpi r2,-1
	bltu t_bltu3
	br   e_bltu
t_bltu3:
	cmpi r2,0
	bltu e_bltu
t_bltu4:
	cmpi r2,1
	bltu e_bltu
t_bltu5:
	cmpi r2,32767
	bltu e_bltu
t_bltu6:
	lea  r2,-32767
	cmpi r2,-32768
	bltu e_bltu
t_bltu7:
	cmpi r2,-32767
	bltu e_bltu
t_bltu8:
	cmpi r2,-1
	bltu t_bltu9
	br   e_bltu
t_bltu9:
	cmpi r2,0
	bltu e_bltu
t_bltu10:
	cmpi r2,1
	bltu e_bltu
t_bltu11:
	cmpi r2,32767
	bltu e_bltu
t_bltu12:
	lea  r2,-1
	cmpi r2,-32768
	bltu e_bltu
t_bltu13:
	cmpi r2,-32767
	bltu e_bltu
t_bltu14:
	cmpi r2,-1
	bltu e_bltu
t_bltu15:
	cmpi r2,0
	bltu e_bltu
t_bltu16:
	cmpi r2,1
	bltu e_bltu
t_bltu17:
	cmpi r2,32767
	bltu e_bltu
t_bltu18:
	lea  r2,0
	cmpi r2,-32768
	bltu t_bltu19
	br   e_bltu
t_bltu19:
	cmpi r2,-32767
	bltu t_bltu20
	br   e_bltu
t_bltu20:
	cmpi r2,-1
	bltu t_bltu21
	br   e_bltu
t_bltu21:
	cmpi r2,0
	bltu e_bltu
t_bltu22:
	cmpi r2,1
	bltu t_bltu23
	br   e_bltu
t_bltu23:
	cmpi r2,32767
	bltu t_bltu24
	br   e_bltu
t_bltu24:
	lea  r2,1
	cmpi r2,-32768
	bltu t_bltu25
	br   e_bltu
t_bltu25:
	cmpi r2,-32767
	bltu t_bltu26
	br   e_bltu
t_bltu26:
	cmpi r2,-1
	bltu t_bltu27
	br   e_bltu
t_bltu27:
	cmpi r2,0
	bltu e_bltu
t_bltu28:
	cmpi r2,1
	bltu e_bltu
t_bltu29:
	cmpi r2,32767
	bltu t_bltu30
	br   e_bltu
t_bltu30:
	lea  r2,32767
	cmpi r2,-32768
	bltu t_bltu31
	br   e_bltu
t_bltu31:
	cmpi r2,-32767
	bltu t_bltu32
	br   e_bltu
t_bltu32:
	cmpi r2,-1
	bltu t_bltu33
	br   e_bltu
t_bltu33:
	cmpi r2,0
	bltu e_bltu
t_bltu34:
	cmpi r2,1
	bltu e_bltu
t_bltu35:
	cmpi r2,32767
	bltu e_bltu
t_bltu36:
	br t_bltu37
e_bltu:
	jal r2,error
t_bltu37:

t_bgeu0:
	lea  r2,-32768
	cmpi r2,-32768
	bgeu t_bgeu1
	br   e_bgeu
t_bgeu1:
	cmpi r2,-32767
	bgeu e_bgeu
t_bgeu2:
	cmpi r2,-1
	bgeu e_bgeu
t_bgeu3:
	cmpi r2,0
	bgeu t_bgeu4
	br   e_bgeu
t_bgeu4:
	cmpi r2,1
	bgeu t_bgeu5
	br   e_bgeu
t_bgeu5:
	cmpi r2,32767
	bgeu t_bgeu6
	br   e_bgeu
t_bgeu6:
	lea  r2,-32767
	cmpi r2,-32768
	bgeu t_bgeu7
	br   e_bgeu
t_bgeu7:
	cmpi r2,-32767
	bgeu t_bgeu8
	br   e_bgeu
t_bgeu8:
	cmpi r2,-1
	bgeu e_bgeu
t_bgeu9:
	cmpi r2,0
	bgeu t_bgeu10
	br   e_bgeu
t_bgeu10:
	cmpi r2,1
	bgeu t_bgeu11
	br   e_bgeu
t_bgeu11:
	cmpi r2,32767
	bgeu t_bgeu12
	br   e_bgeu
t_bgeu12:
	lea  r2,-1
	cmpi r2,-32768
	bgeu t_bgeu13
	br   e_bgeu
t_bgeu13:
	cmpi r2,-32767
	bgeu t_bgeu14
	br   e_bgeu
t_bgeu14:
	cmpi r2,-1
	bgeu t_bgeu15
	br   e_bgeu
t_bgeu15:
	cmpi r2,0
	bgeu t_bgeu16
	br   e_bgeu
t_bgeu16:
	cmpi r2,1
	bgeu t_bgeu17
	br   e_bgeu
t_bgeu17:
	cmpi r2,32767
	bgeu t_bgeu18
	br   e_bgeu
t_bgeu18:
	lea  r2,0
	cmpi r2,-32768
	bgeu e_bgeu
t_bgeu19:
	cmpi r2,-32767
	bgeu e_bgeu
t_bgeu20:
	cmpi r2,-1
	bgeu e_bgeu
t_bgeu21:
	cmpi r2,0
	bgeu t_bgeu22
	br   e_bgeu
t_bgeu22:
	cmpi r2,1
	bgeu e_bgeu
t_bgeu23:
	cmpi r2,32767
	bgeu e_bgeu
t_bgeu24:
	lea  r2,1
	cmpi r2,-32768
	bgeu e_bgeu
t_bgeu25:
	cmpi r2,-32767
	bgeu e_bgeu
t_bgeu26:
	cmpi r2,-1
	bgeu e_bgeu
t_bgeu27:
	cmpi r2,0
	bgeu t_bgeu28
	br   e_bgeu
t_bgeu28:
	cmpi r2,1
	bgeu t_bgeu29
	br   e_bgeu
t_bgeu29:
	cmpi r2,32767
	bgeu e_bgeu
t_bgeu30:
	lea  r2,32767
	cmpi r2,-32768
	bgeu e_bgeu
t_bgeu31:
	cmpi r2,-32767
	bgeu e_bgeu
t_bgeu32:
	cmpi r2,-1
	bgeu e_bgeu
t_bgeu33:
	cmpi r2,0
	bgeu t_bgeu34
	br   e_bgeu
t_bgeu34:
	cmpi r2,1
	bgeu t_bgeu35
	br   e_bgeu
t_bgeu35:
	cmpi r2,32767
	bgeu t_bgeu36
	br   e_bgeu
t_bgeu36:
	br t_bgeu37
e_bgeu:
	jal r2,error
t_bgeu37:

t_bleu0:
	lea  r2,-32768
	cmpi r2,-32768
	bleu t_bleu1
	br   e_bleu
t_bleu1:
	cmpi r2,-32767
	bleu t_bleu2
	br   e_bleu
t_bleu2:
	cmpi r2,-1
	bleu t_bleu3
	br   e_bleu
t_bleu3:
	cmpi r2,0
	bleu e_bleu
t_bleu4:
	cmpi r2,1
	bleu e_bleu
t_bleu5:
	cmpi r2,32767
	bleu e_bleu
t_bleu6:
	lea  r2,-32767
	cmpi r2,-32768
	bleu e_bleu
t_bleu7:
	cmpi r2,-32767
	bleu t_bleu8
	br   e_bleu
t_bleu8:
	cmpi r2,-1
	bleu t_bleu9
	br   e_bleu
t_bleu9:
	cmpi r2,0
	bleu e_bleu
t_bleu10:
	cmpi r2,1
	bleu e_bleu
t_bleu11:
	cmpi r2,32767
	bleu e_bleu
t_bleu12:
	lea  r2,-1
	cmpi r2,-32768
	bleu e_bleu
t_bleu13:
	cmpi r2,-32767
	bleu e_bleu
t_bleu14:
	cmpi r2,-1
	bleu t_bleu15
	br   e_bleu
t_bleu15:
	cmpi r2,0
	bleu e_bleu
t_bleu16:
	cmpi r2,1
	bleu e_bleu
t_bleu17:
	cmpi r2,32767
	bleu e_bleu
t_bleu18:
	lea  r2,0
	cmpi r2,-32768
	bleu t_bleu19
	br   e_bleu
t_bleu19:
	cmpi r2,-32767
	bleu t_bleu20
	br   e_bleu
t_bleu20:
	cmpi r2,-1
	bleu t_bleu21
	br   e_bleu
t_bleu21:
	cmpi r2,0
	bleu t_bleu22
	br   e_bleu
t_bleu22:
	cmpi r2,1
	bleu t_bleu23
	br   e_bleu
t_bleu23:
	cmpi r2,32767
	bleu t_bleu24
	br   e_bleu
t_bleu24:
	lea  r2,1
	cmpi r2,-32768
	bleu t_bleu25
	br   e_bleu
t_bleu25:
	cmpi r2,-32767
	bleu t_bleu26
	br   e_bleu
t_bleu26:
	cmpi r2,-1
	bleu t_bleu27
	br   e_bleu
t_bleu27:
	cmpi r2,0
	bleu e_bleu
t_bleu28:
	cmpi r2,1
	bleu t_bleu29
	br   e_bleu
t_bleu29:
	cmpi r2,32767
	bleu t_bleu30
	br   e_bleu
t_bleu30:
	lea  r2,32767
	cmpi r2,-32768
	bleu t_bleu31
	br   e_bleu
t_bleu31:
	cmpi r2,-32767
	bleu t_bleu32
	br   e_bleu
t_bleu32:
	cmpi r2,-1
	bleu t_bleu33
	br   e_bleu
t_bleu33:
	cmpi r2,0
	bleu e_bleu
t_bleu34:
	cmpi r2,1
	bleu e_bleu
t_bleu35:
	cmpi r2,32767
	bleu t_bleu36
	br   e_bleu
t_bleu36:
	br t_bleu37
e_bleu:
	jal r2,error
t_bleu37:

t_bgtu0:
	lea  r2,-32768
	cmpi r2,-32768
	bgtu e_bgtu
t_bgtu1:
	cmpi r2,-32767
	bgtu e_bgtu
t_bgtu2:
	cmpi r2,-1
	bgtu e_bgtu
t_bgtu3:
	cmpi r2,0
	bgtu t_bgtu4
	br   e_bgtu
t_bgtu4:
	cmpi r2,1
	bgtu t_bgtu5
	br   e_bgtu
t_bgtu5:
	cmpi r2,32767
	bgtu t_bgtu6
	br   e_bgtu
t_bgtu6:
	lea  r2,-32767
	cmpi r2,-32768
	bgtu t_bgtu7
	br   e_bgtu
t_bgtu7:
	cmpi r2,-32767
	bgtu e_bgtu
t_bgtu8:
	cmpi r2,-1
	bgtu e_bgtu
t_bgtu9:
	cmpi r2,0
	bgtu t_bgtu10
	br   e_bgtu
t_bgtu10:
	cmpi r2,1
	bgtu t_bgtu11
	br   e_bgtu
t_bgtu11:
	cmpi r2,32767
	bgtu t_bgtu12
	br   e_bgtu
t_bgtu12:
	lea  r2,-1
	cmpi r2,-32768
	bgtu t_bgtu13
	br   e_bgtu
t_bgtu13:
	cmpi r2,-32767
	bgtu t_bgtu14
	br   e_bgtu
t_bgtu14:
	cmpi r2,-1
	bgtu e_bgtu
t_bgtu15:
	cmpi r2,0
	bgtu t_bgtu16
	br   e_bgtu
t_bgtu16:
	cmpi r2,1
	bgtu t_bgtu17
	br   e_bgtu
t_bgtu17:
	cmpi r2,32767
	bgtu t_bgtu18
	br   e_bgtu
t_bgtu18:
	lea  r2,0
	cmpi r2,-32768
	bgtu e_bgtu
t_bgtu19:
	cmpi r2,-32767
	bgtu e_bgtu
t_bgtu20:
	cmpi r2,-1
	bgtu e_bgtu
t_bgtu21:
	cmpi r2,0
	bgtu e_bgtu
t_bgtu22:
	cmpi r2,1
	bgtu e_bgtu
t_bgtu23:
	cmpi r2,32767
	bgtu e_bgtu
t_bgtu24:
	lea  r2,1
	cmpi r2,-32768
	bgtu e_bgtu
t_bgtu25:
	cmpi r2,-32767
	bgtu e_bgtu
t_bgtu26:
	cmpi r2,-1
	bgtu e_bgtu
t_bgtu27:
	cmpi r2,0
	bgtu t_bgtu28
	br   e_bgtu
t_bgtu28:
	cmpi r2,1
	bgtu e_bgtu
t_bgtu29:
	cmpi r2,32767
	bgtu e_bgtu
t_bgtu30:
	lea  r2,32767
	cmpi r2,-32768
	bgtu e_bgtu
t_bgtu31:
	cmpi r2,-32767
	bgtu e_bgtu
t_bgtu32:
	cmpi r2,-1
	bgtu e_bgtu
t_bgtu33:
	cmpi r2,0
	bgtu t_bgtu34
	br   e_bgtu
t_bgtu34:
	cmpi r2,1
	bgtu t_bgtu35
	br   e_bgtu
t_bgtu35:
	cmpi r2,32767
	bgtu e_bgtu
t_bgtu36:
	br t_bgtu37
e_bgtu:
	jal r2,error
t_bgtu37:

; call
t_call:
	lea r15,0
	call t_call1
	br e_call
align 16
t_call1:
	lea r1,t_call+4
	cmp r1,r15
	bne e_call
t_call2:
	call t_call3
	br e_call
align 16
t_call3:
	lea r1,t_call2+2
	cmp r1,r15
	bne e_call
t_call4:
	call t_call5
	br e_call
align 16
t_call5:
	lea r1,t_call4+2
	cmp r1,r15
	bne e_call
t_call6:
	call t_call7
	br e_call
align 16
t_call7:
	lea r1,t_call6+2
	cmp r1,r15
	bne e_call
	br t_imm
e_call:
	jal r2,error

; imm
t_imm:
	lw r1,k1
	lw r2,kAAAA
	lw r3,kFFFF
	lea r4,1
	cmp r1,r4
	bne e_imm
	lea r4,0xAAAA
	cmp r2,r4
	bne e_imm
	lea r4,0xFFFF
	cmp r3,r4
	bne e_imm
	br t_bp
e_imm:
	jal r2,error
k1:
	word 1
kAAAA:
	word 0xAAAA
kFFFF:
	word 0xFFFF

; branch pipeline annul
t_bp:
	lea r1,1
	lea r2,2
	cmp r0,r0
	beq t_bp1
	lea r1,3 ;a
	lea r2,4 ;a
t_bp1:
	cmpi r1,1
	bne e_bp
	cmpi r2,2
	bne e_bp
	cmp r0,r0
	beq t_bp2
	br  e_bp ;a
	br  e_bp ;a
t_bp2:
	cmp r0,r0
	beq t_bp3
	word 0xD001 ; imm 0x0010 ;a
	word 0xD001 ; imm 0x0010 ;a
t_bp3:
	addi r1,r1,0
	cmpi r1,1
	bne e_bp
	sw r1,w
	cmp r0,r0
	beq t_bp4
	word 0x8206 ; sw r2,w ; sw r2,6(r0) ; a
	word 0x8206 ; sw r2,w ; sw r2,6(r0) ; a
t_bp4:
	cmp r0,r0
	beq t_bp5
	word 0x9206 ; sb r2,w ; sb r2,6(r0) ; a
	word 0x9206 ; sb r2,w ; sb r2,6(r0) ; a
t_bp5:
	lw r3,w
	cmp r1,r3
	bne e_bp
	cmp r0,r0
	beq t_bp5
	word 0xA201 ; jal r2,error ; jal r15,10(r0) ;a
	word 0xA201 ; jal r2,error ; jal r15,10(r0) ;a
t_bp5:
	cmpi r1,1
	bne e_bp
	lea r15,3
	cmp r0,r0
	beq t_bp6
	call e_bp ;a
	call e_bp ;a
t_bp6:
	cmpi r15,3
	bne e_bp
	br t_jp
align 16
e_bp:
	jal r2,error

; jump pipeline annul
t_jp:
	lea r1,1
	lea r2,2
	j t_jp1
	lea r1,3 ;a
	lea r2,4 ;a
t_jp1:
	cmpi r1,1
	bne e_jp
	cmpi r2,2
	bne e_jp
	j t_jp2
	br e_jp ;a
	br e_jp ;a
t_jp2:
	j t_jp3
	word 0xD001 ; imm 0x0010 ;a
	word 0xD001 ; imm 0x0010 ;a
t_jp3:
	addi r1,r1,0
	cmpi r1,1
	bne e_jp
	sw r1,w
	j t_jp4
	word 0x8206 ; sw r2,w ; sw r2,6(r0) ; a
	word 0x8206 ; sw r2,w ; sw r2,6(r0) ; a
t_jp4:
	j t_jp5
	word 0x9206 ; sb r2,w ; sb r2,6(r0) ; a
	word 0x9206 ; sb r2,w ; sb r2,6(r0) ; a
t_jp5:
	lw r3,w
	cmp r1,r3
	bne e_jp
	j t_jp5
	word 0xA201 ; jal r2,error ; jal r15,10(r0) ;a
	word 0xA201 ; jal r2,error ; jal r15,10(r0) ;a
t_jp5:
	cmpi r1,1
	bne e_jp
	lea r15,3
	j t_jp6
	call e_jp ;a
	call e_jp ;a
t_jp6:
	cmpi r15,3
	bne e_jp
	br t_cp
align 16
e_jp:
	jal r2,error

; call pipeline annul
t_cp:
	lea r1,1
	lea r2,2
	call t_cp1
	lea r1,3 ;a
	lea r2,4 ;a
align 16
t_cp1:
	cmpi r1,1
	bne e_cp
	cmpi r2,2
	bne e_cp
	call t_cp2
	br e_cp ;a
	br e_cp ;a
align 16
t_cp2:
	call t_cp3
	word 0xD001 ; imm 0x0010 ;a
	word 0xD001 ; imm 0x0010 ;a
align 16
t_cp3:
	addi r1,r1,0
	cmpi r1,1
	bne e_cp
	sw r1,w
	call t_cp4
	word 0x8206 ; sw r2,w ; sw r2,6(r0) ; a
	word 0x8206 ; sw r2,w ; sw r2,6(r0) ; a
align 16
t_cp4:
	call t_cp5
	word 0x9206 ; sb r2,w ; sb r2,6(r0) ; a
	word 0x9206 ; sb r2,w ; sb r2,6(r0) ; a
align 16
t_cp5:
	lw r3,w
	cmp r1,r3
	bne e_cp
	call t_cp5
	word 0xA201 ; jal r2,error ; jal r15,10(r0) ;a
	word 0xA201 ; jal r2,error ; jal r15,10(r0) ;a
align 16
t_cp5:
	cmpi r1,1
	bne e_cp
	call t_cp6
	call e_cp ;a
	call e_cp ;a
align 16
t_cp6:
	lea r3,t_cp5+6
	cmp r3,r15
	bne e_cp
	br t_fwd
align 16
e_cp:
	jal r2,error

; test result forwarding
t_fwd:
	lea  r2,1
	lea  r3,2
	lea  r4,4
	lea  r5,7
	add  r6,r5,r4 ; 11
	add  r6,r6,r0 ; 11
	add  r6,r6,r2 ; 12
	sub  r6,r6,r5 ; 5
	andi r6,7 ; 5
	ori  r6,3 ; 7
	xori r6,4 ; 3
	andni r6,0  ; 3
	xori r6,-1 ; -4
    or   r6,r2 ; -3
	xori r6,-1 ; 2
    cmpi r6,2
	bne  e_fwd
	sw   r5,w
	lw   r2,w
	cmpi r2,7
	bne  e_fwd
    lb   r2,w
	cmp  r2,r0
	bne  e_fwd
; r0 results should not be forwarded
	addi r0,r0,1
	add  r2,r0,r0
	cmp  r2,r0
	bne  e_fwd
	addi r0,r0,1
	addi r2,r0,0
	cmp  r2,r0
	bne  e_fwd
	lea  r2,1
	addi r0,r2,0
	cmp  r0,r0
	bne  e_fwd
	j    ok
e_fwd:
	jal r2,error
