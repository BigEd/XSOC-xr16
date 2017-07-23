/*
 * xr16.h -- xr16 assembler/simulator xr16 instruction set definition
 *
 * Copyright (C) 1999, 2000, Gray Research LLC.  All rights reserved.
 * The contents of this file are subject to the XSOC License Agreement;
 * you may not use this file except in compliance with this Agreement.
 * See the LICENSE file.
 *
 * $Log: /dist/src/xr16/xr16.h $
 * 
 * 1     3/02/00 8:36p Jan
 *
 * tabs=4
 */

#ifndef _XR16_H_
#define _XR16_H_

/*
Instruction formats

Fmt  15-12 11--8 7---4 3---0
rrr    op    rd    ra   rb
rri    op    rd    ra   imm
rr     op    rd    fn   rb
ri     op    rd    fn   imm
br     op   cond  --disp8--
imm    op   -----imm12-----

Instructions

Insn	Fmt	Assembler			Semantics
0dab	rrr	add   rd,ra,rb		rd = ra + rb;
1dab	rrr	sub   rd,ra,rb		rd = ra - rb;
2dai	rri	addi  rd,ra,imm		rd = ra + imm;
3d0b	rr	and   rd,rb			rd = rd & rb;
3d1b	rr	or    rd,rb			rd = rd | rb;
3d2b	rr	xor   rd,rb			rd = rd ^ rb;
3d3b	rr	andn  rd,rb			rd = rd & ~rb;
3d4b	rr	adc   rd,rb			rd = rd + rb + C;
3d5b	rr	sbc   rd,rb			rd = rd - rb - C;
4d0b	rr	andi  rd,rb			rd = rd & imm;
4d1b	ri	ori   rd,imm		rd = rd | imm;
4d2b	ri	xori  rd,imm		rd = rd ^ imm;
4d3b	ri	andni rd,imm		rd = rd & ~imm;
4d4b	ri	adci  rd,imm		rd = rd + imm + C;
4d5b	ri	sbci  rd,imm		rd = rd - imm - C;
4d6b	ri	srli  rd,imm		rd = rd >> imm;
4d7b	ri	srai  rd,imm		rd = (signed)rd >> imm;
4d8b	ri	slli  rd,imm		rd = rd << imm;
4d9b	ri	srxi  rd,imm		rd = (rd >> imm) | (t << 15);
4dab	ri	slxi  rd,imm		rd = (rd << imm) | t;
5dai	rri	lw    rd,imm(ra)	rd = *(int*)(ra+imm);
6dai	rri	lb    rd,imm(ra)	rd = *(byte*)(ra+imm);
8dai	rri	sw rd,imm(ra)		*(int*)(ra+imm) = rd;
9dai	rri	sb rd,imm(ra)		*(byte*)(ra+imm) = rd;
Adai	rri	jal rd,imm(ra)		rd = pc, pc = ra + imm;
B0dd	br	br   label			pc += 2*disp8 + 2
B2dd	br	beq  label			pc += 2*disp8 + 2 if ==
B3dd	br	bne  label			pc += 2*disp8 + 2 if !=
B4dd	br	bc   label			pc += 2*disp8 + 2 if carry
B5dd	br	bnc  label			pc += 2*disp8 + 2 if !carry
B6dd	br	bv   label			pc += 2*disp8 + 2 if overflow
B7dd	br	bnv  label			pc += 2*disp8 + 2 if !overflow
B8dd	br	blt  label			pc += 2*disp8 + 2 if signed <
B9dd	br	bge  label			pc += 2*disp8 + 2 if signed >=
BAdd	br	ble  label			pc += 2*disp8 + 2 if signed <=
BBdd	br	bgt  label			pc += 2*disp8 + 2 if signed >
BCdd	br	bltu label			pc += 2*disp8 + 2 if unsigned <
BDdd	br	bgeu label			pc += 2*disp8 + 2 if unsigned >=
BEdd	br	bleu label			pc += 2*disp8 + 2 if unsigned <=
BFdd	br	bgtu label			pc += 2*disp8 + 2 if unsigned >
Ciii	imm	call imm12			r15 = pc, pc = imm12<<4;
Diii	imm	imm imm12			imm'next |= imm12<<4;
Fiii	imm trap imm12			<simulator trap>
*/

typedef unsigned char Byte;
typedef unsigned short Word;
typedef Word Insn;
typedef unsigned Addr;

typedef int Bool;
enum { FALSE, TRUE };

typedef char* SZ; // zero (null) terminated string

enum {
	OP_ADD,  OP_SUB, OP_ADDI, OP_RR,
	OP_RI,   OP_LW,  OP_LB,  OP_7,
	OP_SW,   OP_SB,  OP_JAL, OP_BR,
	OP_CALL, OP_IMM, OP_E, OP_TRAP
};

enum {
	FN_AND, FN_OR,  FN_XOR, FN_ANDN,
	FN_ADC, FN_SBC, FN_SRL, FN_SRA,
	FN_SLL, FN_SRX, FN_SLX
};

enum {
	BR_BR,   BR_BRN,  BR_BEQ,  BR_BNE,
	BR_BC,   BR_BNC,  BR_BV,   BR_BNV,
	BR_BLT,  BR_BGE,  BR_BLE,  BR_BGT,
	BR_BLTU, BR_BGEU, BR_BLEU, BR_BGTU
};
 

#define OP(insn)			((insn) >> 12)
#define RD(insn)			(((insn) >> 8) & 0xF)
#define RA(insn)			(((insn) >> 4) & 0xF)
#define RB(insn)			((insn) & 0xF)
#define FN(insn)			(RA(insn))
#define IMM(insn)			(RB(insn))
#define IMM_SEXT(insn)		(((insn) & 0x8) ? (IMM(insn) | ~0xF) : IMM(insn))
#define IMM_WORD(insn)		(((insn) & 0xE) | (((insn)&1) << 4))
#define IMM12(insn)			((insn) & 0xFFF)
#define COND(insn)			(RD(insn))
#define DISP(insn)			(((insn) & 0x80) ? (((insn) & 0xFF) | ~0xFF) : ((insn) & 0xFF))

#define INSN_OP(op)			(((Insn)(op)) << 12)
#define INSN_OPFN(op,fn)	((((Insn)(op)) << 12) | ((Insn)(fn) << 4))
#define INSN_BR(br)			((((Insn)OP_BR) << 12) | ((Insn)(br) << 8))

#define INSN_RD(rd)			(((Insn)(rd)&0xF) << 8)
#define INSN_RA(ra)			(((Insn)(ra)&0xF) << 4)
#define INSN_RB(rb)			((Insn)(rb)&0xF)
#define INSN_I4(i4)			((Insn)(i4)&0xF)
#define INSN_I12(i12)		((Insn)(i12)&0xFFF)

enum {
	ADD,
	SUB,
	ADDI,
	AND, OR, XOR, ANDN, ADC, SBC,
	ANDI, ORI, XORI, ANDNI, ADCI, SBCI, SRLI, SRAI, SLLI, SRXI, SLXI,
	LW,
	LB,
	SW,
	SB,
	JAL,
	BR, BRN, BEQ, BNE, BC, BNC, BV, BNV, BLT, BGE, BLE, BGT, BLTU, BGEU, BLEU, BGTU,
	CALL,
	IMM,
	TRAP,

	/* pseudo-instructions */
	NOP,
	MOV,
	SUBI,
	CMP,
	CMPI,
	LEA,
	J,
	RET,
	RETI,
	SEXT,
	ZEXT,
	LBS,

	ADDL,
	SUBL,
	ANDL,
	ORL,
	XORL,
	ANDNL,
	MOVL,
	CMPL,
	LL,
	SL,

	GLOBAL,
	ALIGN,
	BYTE_,
	WORD_,
	BSS
};

#endif /* !_XR16_H_ */

