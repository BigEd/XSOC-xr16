/*
 * sim.c -- xr16 simulator
 *
 * Copyright (C) 1999, 2000, Gray Research LLC.  All rights reserved.
 * The contents of this file are subject to the XSOC License Agreement;
 * you may not use this file except in compliance with this Agreement.
 * See the LICENSE file.
 *
 * $Log: /dist/src/xr16/sim.c $
 * 
 * 3     4/06/00 11:54a Jan
 * implement bv bnv bc bnc
 * 
 * 2     3/04/00 9:44a Jan
 * getting automatic rebuild to work
 * applying proper rcsids
 * 
 * 1     3/02/00 8:36p Jan
 *
 * tabs=4
 */

static char rcsid[] =
	"$Header: /dist/src/xr16/sim.c 3     4/06/00 11:54a Jan $\n"
	"Copyright (C) 1999,2000, Gray Research LLC.  All rights reserved.\n"
	"This program is subject to the XSOC License Agreement.\n"
	"See the LICENSE file.";

#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <memory.h>
#include "xr16.h"
#include "xr16sim.h"

#define TRACE(p)	((p).trace)
#define TR_INSN(p)	((p).trace & trInsn)
#define TR_MEM(p)	((p).trace & trMem)
#define TR_CALL(p)	((p).trace & trCall)

#define SIGNED(a)	((int)(short)(a))

/* eval sign-extended immediate operand */
#define SEXT_IMM(p, insn) \
	((p).imm_prefix ? ((Word)((p).insnPrev << 4) | IMM(insn)) : IMM_SEXT(insn))

/* eval 0-extended word offset (scale 2X) immediate operand */
#define WORD_IMM(p, insn) \
	((p).imm_prefix ? ((Word)((p).insnPrev << 4) | IMM(insn)) : IMM_WORD(insn))

/* eval 0-extended byte offset immediate operand */
#define BYTE_IMM(p, insn) \
	((p).imm_prefix ? ((Word)((p).insnPrev << 4) | IMM(insn)) : IMM(insn))

/* eval word effective address imm(ra) */
#define WORD_EA(p, insn) \
	((Word)((p).r[RA(insn)] + WORD_IMM((p), (insn))))

/* eval byte effective address imm(ra) */
#define BYTE_EA(p, insn) \
	((Word)((p).r[RA(insn)] + BYTE_IMM((p), (insn))))

#define SIGN(w) ((w)&0x8000)

#define BIT(i) (1<<(i))

enum {
	bitopResult	= BIT(OP_ADD) | BIT(OP_SUB) | BIT(OP_ADDI) | BIT(OP_RR) |
                  BIT(OP_RI) | BIT(OP_LW) | BIT(OP_LB) | BIT(OP_JAL) |
	              BIT(OP_CALL),
	bitopCall	= BIT(OP_CALL) | BIT(OP_JAL),
};

enum {
	cbAddr		= 13,	/* length of symbolic address display */
	cbInsn		= 19	/* length of instruction dissambly display */
};

Word fetchInsn(Addr addr);
Word loadWord(XR16* p, Addr addr);
Word loadByte(XR16* p, Addr addr);
void storeWord(XR16* p, Addr addr, Word w);
void storeByte(XR16* p, Addr addr, Word w);
void trap(XR16* p, int n);
void nyi();
void invalidOpcode();
void notreached();
void invalidseq();

/* Return processor state following reset.
 *
 * Args
 *	trace	- initial trace flags
 */
XR16 reset(Word trace)
{
	XR16 p;

	memset(&p, 0, sizeof p);
	p.trace = trace;

	return p;
}

/* Simulate one or more instructions.  Return updated processor state.
 *
 * Args
 *	p		- initial processor state
 *	cinsns	- count of instructions to step through, or -1 to run until pc==0
 *
 * Also trace instruction execution according to p.trace.
 */
XR16 sim(XR16 p, int cinsns)
{
	while (cinsns == -1 || --cinsns >= 0) {
		Insn insn = fetchInsn(p.pc);
		Word* prd = &p.r[RD(insn)];
		char szAddr[cbAddr];

		++p.insns;
		++p.cycles;

		if (TRACE(p) && (TR_INSN(p) || (TR_CALL(p) && (BIT(OP(insn))&bitopCall)))) {
			char szInsn[19];
			szForAddr(szAddr, sizeof szAddr, p.pc);
			szForInsn(szInsn, sizeof szInsn, p.pc, insn);
			printf("%7d  %04X %-12.12s %04X %-17s", p.cycles, p.pc, szAddr, insn, szInsn);
		}

		p.pc += 2;

		switch (OP(insn)) {
		case OP_ADD:
			p.a = p.r[RA(insn)];
			p.b = p.r[RB(insn)];
			*prd = p.a + p.b;
			break;
		case OP_SUB:
			p.a = p.r[RA(insn)];
			p.b = -p.r[RB(insn)];
			*prd = p.a + p.b;
			break;
		case OP_ADDI:
			p.a = p.r[RA(insn)];
			p.b = SEXT_IMM(p, insn);
			*prd = p.a + p.b;
			break;
		case OP_RR:
			switch (FN(insn)) {
			case FN_AND:
				*prd &= p.r[RB(insn)];
				break;
			case FN_OR:
				*prd |= p.r[RB(insn)];
				break;
			case FN_XOR:
				*prd ^= p.r[RB(insn)];
				break;
			case FN_ANDN:
				*prd &= ~p.r[RB(insn)];
				break;
			case FN_ADC:
				p.a = *prd;
				p.b = p.r[RB(insn)];
				nyi();
				*prd = p.a + p.b + p.c;
				break;
			case FN_SBC:
				p.a = *prd;
				p.b = -p.r[RB(insn)];
				nyi();
				*prd = p.a + p.b - p.c;
				break;
			default:
				invalidOpcode();
			}
			break;
		case OP_RI:
			switch (FN(insn)) {
			case FN_AND:
				*prd = *prd & SEXT_IMM(p, insn);
				break;
			case FN_OR:
				*prd = *prd | SEXT_IMM(p, insn);
				break;
			case FN_XOR:
				*prd = *prd ^ SEXT_IMM(p, insn);
				break;
			case FN_ANDN:
				*prd = *prd & ~SEXT_IMM(p, insn);
				break;
			case FN_ADC:
				p.a = *prd;
				p.b = SEXT_IMM(p, insn);
				nyi();
				*prd = p.a + p.b + p.c;
				break;
			case FN_SBC:
				p.a = *prd;
				p.b = -SEXT_IMM(p, insn);
				nyi();
				*prd = p.a + p.b - p.c;
				break;
			case FN_SLL:
				p.x = !!(*prd & 0x8000);
				*prd <<= 1;
				break;
			case FN_SLX: {
				int x = !!(*prd & 0x8000);
				*prd = (*prd << 1) | p.x;
				p.x = x;
				break;
			}
			case FN_SRA:
				p.x = *prd & 1;
				*prd = (short)*prd >> 1;
				break;
			case FN_SRL:
				p.x = *prd & 1;
				*prd >>= 1;
				break;
			case FN_SRX: {
				int x = *prd & 1;
				*prd = (p.x << 15) | (*prd >> 1);
				p.x = x;
				break;
			}
			default:
				invalidOpcode();
			}
			break;
		case OP_LW:
			*prd = loadWord(&p, WORD_EA(p, insn));
			break;
		case OP_LB:
			*prd = loadByte(&p, BYTE_EA(p, insn));
			break;
		case OP_SW:
			storeWord(&p, WORD_EA(p, insn), *prd);
			break;
		case OP_SB:
			storeByte(&p, BYTE_EA(p, insn), *prd);
			break;
		case OP_JAL: {
			Word target = WORD_EA(p, insn);
			*prd = p.pc;
			p.pc = target;
			p.cycles += 2;

			if (TRACE(p)) {
				if (TR_INSN(p) || TR_CALL(p))
					szForAddr(szAddr, sizeof szAddr, p.pc);
				if (TR_CALL(p) && RD(insn) == 15)
					printf(" call %s %d %d %d", szAddr, (short)p.r[3], (short)p.r[4], (short)p.r[5]);
				else if (TR_CALL(p) && RD(insn) == 0 && RA(insn) == 15)
					printf(" ret %s %d", szAddr, (short)p.r[2]);
				else if (TR_INSN(p) || TR_CALL(p))
					printf(" pc=%s", szAddr);
			}
			break;
		}
		case OP_BR: {
			Bool t;
			Word sum;
			switch (COND(insn) & ~1) {
			case BR_BR:
				t = TRUE;
				break;
			case BR_BEQ:
				t = p.a == (Word)-p.b;
				break;
			case BR_BC:
				sum = p.a + p.b;
				t = sum < p.a || sum < p.b;
				break;
			case BR_BV:
				sum = p.a + p.b;
				t = SIGN(p.a) == SIGN(p.b) && SIGN(p.a) != SIGN(sum);
				break;
			case BR_BLT:
				t = SIGNED(p.a) < SIGNED(-p.b);
				break;
			case BR_BLE:
				t = SIGNED(p.a) <= SIGNED(-p.b);
				break;
			case BR_BLTU:
				t = p.a < (Word)-p.b;
				break;
			case BR_BLEU:
				t = p.a <= (Word)-p.b;
				break;
			}

			if (t != (COND(insn) & 1)) {
				p.pc += 2*DISP(insn) + 2;
				p.cycles += 2;

				if (TR_INSN(p))
					printf(" pc=%s", szForAddr(szAddr, sizeof szAddr, p.pc));
			}
			break;
		}
		case OP_CALL:
			prd = &p.r[15];
			*prd = p.pc;
			p.pc = IMM12(insn) << 4;
			p.cycles += 2;

			if (TRACE(p)) {
				if (TR_INSN(p) || TR_CALL(p))
					szForAddr(szAddr, sizeof szAddr, p.pc);
				if (TR_CALL(p))
					printf(" call %s %d %d %d", szAddr, (short)p.r[3], (short)p.r[4], (short)p.r[5]);
				else if (TR_INSN(p))
					printf(" pc=%s", szAddr);
			}
			break;
		case OP_IMM:
			break;
		case OP_TRAP:
			trap(&p, IMM12(insn));
			break;
		default:
			invalidOpcode();
			break;
		}
		p.imm_prefix = OP(insn) == OP_IMM;
		p.insnPrev = insn;
		p.r[0] = 0; /* cheaper to forgive writes to r0 than to guard them */

		if (TRACE(p) && (TR_INSN(p) || (TR_CALL(p) && (BIT(OP(insn))&bitopCall)))) {
			if ((BIT(OP(insn)) & bitopResult) && prd != &p.r[0])
				printf(" r%d=%d", prd - p.r, (short)*prd);
			printf("\n");
		}

		if (!p.pc)
			break;
	}

	return p;
}


/* Memory abstraction: big-endian word, byte put/get functions */

/* Fetch instruction word at addr. */
Word fetchInsn(Addr addr)
{
	return (rgb[addr] << 8) | rgb[addr+1];
}

/* Fetch word at addr. */
Word loadWord(XR16* p, Addr addr)
{
	char szAddr[cbAddr];
	if (TR_MEM(*p))
		printf(" %04X=[%s]", (rgb[addr] << 8) | rgb[addr+1], szForAddr(szAddr, sizeof szAddr, addr));
	p->cycles++;
	return (rgb[addr] << 8) | rgb[addr+1];
}

/* Fetch byte at addr. */
Word loadByte(XR16* p, Addr addr)
{
	char szAddr[cbAddr];
	if (TR_MEM(*p))
		printf(" %02X=[%04X]", rgb[addr], szForAddr(szAddr, sizeof szAddr, addr));
	p->cycles++;
	return rgb[addr];
}

/* Store word at addr. */
void storeWord(XR16* p, Addr addr, Word w)
{
	char szAddr[cbAddr];
	if (TR_MEM(*p))
		printf(" [%s]=%04X", szForAddr(szAddr, sizeof szAddr, addr), w);
	rgb[addr] = w >> 8;
	rgb[addr+1] = (Byte)w;
	p->cycles++;
}

/* Store byte at addr. */
void storeByte(XR16* p, Addr addr, Word w)
{
	char szAddr[cbAddr];
	if (TR_MEM(*p))
		printf(" [%s]=%02X", szForAddr(szAddr, sizeof szAddr, addr), (Byte)w);
	p->cycles++;
	rgb[addr] = (Byte)w;
}

/* Execute a trap instruction. */
void trap(XR16* p, int n)
{
	switch (n) {
	case 0: /* puts */
		printf("%s", rgb + p->r[3]);
		break;
	default:
		printf("trap %d?\n", n);
		break;
	}
}

/* Report invalid opcode. */
void invalidOpcode()
{
	assert(0);
}

/* Report invalid sequence of instructions. */
void invalidseq()
{
	assert(0);
}

/* Highlight code that should not be reached. */
void notreached()
{
	assert(0);
}

/* Highlight Not Yet Implemented functionality. */
void nyi()
{
	assert(0);
}

