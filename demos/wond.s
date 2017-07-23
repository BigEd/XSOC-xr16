; wond.s -- wondrous(27) simulation demo
;
; Copyright (C) 1999, 2000, Gray Research LLC.  All rights reserved.
; The contents of this file are subject to the XSOC License Agreement;
; you may not use this file except in compliance with this Agreement.
; See the LICENSE file.


; wondrous(x) = if (x == 1) then true
;               else if (even(x)) then wondrous(x/2)
;               else wondrous(3*x+1)
;
; (See Doug Hofstadter's "Godel, Escher, Bach: An Eternal Golden Braid",
; p.400.)
;
; evaluate wondrous(27):

reset:	lea  r1,27
		br   do
loop:	mov  r2,r1
		andi r2,1
		cmp  r2,r0
		beq  even
odd:	add  r2,r1,r1
		add  r1,r2,r1
		addi r1,r1,1
		br   do
even:	srli r1,1
do:		cmpi r1,1
		bne  loop
		br   reset
