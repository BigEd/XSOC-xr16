/*
 * asm.c -- xr16 assembler
 *
 * Copyright (C) 1999, 2000, Gray Research LLC.  All rights reserved.
 * The contents of this file are subject to the XSOC License Agreement;
 * you may not use this file except in compliance with this Agreement.
 * See the LICENSE file.
 *
 * $Log: /dist/src/xr16/asm.c $
 * 
 * 3     4/06/00 11:55a Jan
 * fix #18, #19
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
	"$Header: /dist/src/xr16/asm.c 3     4/06/00 11:55a Jan $\n"
	"Copyright (C) 1999,2000, Gray Research LLC.  All rights reserved.\n"
	"This program is subject to the XSOC License Agreement.\n"
	"See the LICENSE file.";

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdarg.h>
#include <time.h>
#include <assert.h>
#include "xr16.h"
#include "xr16sim.h"

typedef struct Symbol {
	char id[32];
	Addr addr;
	short file;			// index of file symbol defined in; 0 if global
	Bool defined;		// symbol has been defined
	Bool error;			// undefined symbol error has been issued
} Symbol, *Sym;

typedef enum Type {
	SYM='s', COLON=':', IN='i', REG='r', CON='1', COMMA=',', EOL='\n'
} Type;

typedef struct Token {
	Type type;
	union {
		int in;
		Sym sym;
		int reg;
		int con;
	} u;
} Token;

typedef enum FixupType {
	FIX_ADDR, FIX_LDST, FIX_BR, FIX_CALL
} FixupType;

typedef struct Fixup {
	FixupType type;
	Sym target;
	Addr addr;
	int disp;
} Fixup;

typedef struct Line {
	Addr addr;
	SZ szLine;
} Line;
enum { NLINES = 50000 };
int nlines = 0;
Line lines[NLINES];
void addListingLine(SZ line);
 
Bool constant(char** pp, int *pcon);
Bool ea(char** pp, Sym* psym, int* pdisp, int* preg);
Bool address(char** pp, Sym* psym, int* pdisp);
Bool longreg(int reg);
int pairreg(int reg);
Token lex(char** p);
Bool parse(char** p, ...);
Sym lookup(SZ sz);

Addr here();
int lastDestReg();
void label(Sym sym);
void global(Sym sym);
void align(unsigned alignment);
void insn(unsigned in, unsigned w);
void bss(unsigned c);
void byte(unsigned i);
void word(unsigned i);
void fixup(FixupType type, Sym target, int disp);

void nop();
void mov(int rd, int ra);
void ldst(int in, int rd, Sym sym, int disp, int reg);
void addi(int in, int rd, int ra, int con);
void ri(int in, int rd, int con);

Insn mpininsn[];

int error(SZ szError, ...);

static int file = 0; // index of current file

void source(SZ source)
{
	FILE* src;
	char szLine[BUFSIZ];

	szCurrentFile = source;
	line = 0;
	++file;

	if ((src = fopen(source, "rb")) == 0) {
		error("cannot open '%s' (%s)", source, strerror(errno));
		return;
	}

	_snprintf(szLine, sizeof szLine, "# file %s", source);
	szLine[sizeof(szLine)-1] = 0;
	addListingLine(szLine);

	while (fgets(szLine, sizeof szLine, src)) {
		Token t, t2, rd, ra, rb, lab;
		int con;
		char* p = szLine;
		Sym sym = 0;
		int disp = 0;
		int reg = 0;
		int i;

		/* Strip white space, esp. newlines */
		for (i = strlen(szLine) - 1; i >= 0 && isspace(szLine[i]); --i)
			szLine[i] = 0;

		++line;

		addListingLine(szLine);

		/* "label:" */
		t = lex(&p);
		if (t.type == SYM) {
			t2 = lex(&p);
			if (t2.type != COLON) {
				error("syntax error: %s", szLine);
				continue;
			}
			label(t.u.sym);
			t = lex(&p);
		}

		if (t.type == EOL)
			continue;
		else if (t.type != IN) {
 			error("syntax error; expecting opcode");
			continue;
		}

		switch (t.u.in) {
		case ADD:
		case SUB:
			if (!parse(&p, REG, &rd, ',', REG, &ra, ',', REG, &rb, EOL, 0))
				continue;
			if (rb.u.reg == lastDestReg() && rb.u.reg != 0) {
				if (t.u.in == SUB || ra.u.reg == lastDestReg() && ra.u.reg != 0) {
					/* Since the B register port does not get result
					 * forwarding, insert a nop between insn which computes
					 * a result and this RR instruction which uses it.
					 */
					nop();
				}
				else {
					/* Swap the A and B operands:
					 * lw r1,...
					 * add r2,r3,r1 => add r2,r1,r3
					 */
					Token t = ra;
					ra = rb;
					rb = t;
				}
			}
			insn(t.u.in, INSN_RD(rd.u.reg) | INSN_RA(ra.u.reg) | INSN_RB(rb.u.reg));
			break;
		case ADDI:
		case SUBI:	/* subi rd,ra,imm  =>  addi rd,ra,-imm */
			if (!parse(&p, REG, &rd, ',', REG, &ra, ',', 0) || !constant(&p, &con) || !parse(&p, EOL, 0))
				continue;
			addi(t.u.in, rd.u.reg, ra.u.reg, con);
			break;
		case AND: case OR: case XOR: case ANDN:
		case ADC: case SBC:
			if (!parse(&p, REG, &rd, ',', REG, &rb, EOL, 0))
				continue;
			if (rb.u.reg == lastDestReg() && rb.u.reg != 0) {
				/* Since the B register port does not get result
				 * forwarding, insert a nop between insn which computes
				 * a result and this RR instruction which uses it.
				 */
				nop();
			}
			insn(t.u.in, INSN_RD(rd.u.reg) | INSN_RB(rb.u.reg));
			break;
		case ANDI: case ORI: case XORI: case ANDNI:
		case ADCI: case SBCI:
			if (!parse(&p, REG, &rd, ',', 0) || !constant(&p, &con) || !parse(&p, EOL, 0))
				continue;
			ri(t.u.in, rd.u.reg, con);
			break;
		case SRLI: case SRAI: case SLLI: case SRXI: case SLXI:
			if (!parse(&p, REG, &rd, ',', 0) || !constant(&p, &con) || !parse(&p, EOL, 0))
				continue;
			if (con < 1 || con > 15) {
				error("invalid shift amount");
				con = 1;
			}
			for ( ; con > 0; --con)
				insn(t.u.in, INSN_RD(rd.u.reg) | INSN_I4(1));
			break;
		case LW: case LB:
		case SW: case SB:
		case JAL:
			if (!parse(&p, REG, &rd, ',', 0) || !ea(&p, &sym, &disp, &reg))
				continue;
			ldst(t.u.in, rd.u.reg, sym, disp, reg);
			break;
		case LBS: /* lbs rd,imm(ra)  => lb rd,imm(ra) || xori rd,0x80 || subi rd,rd,0x80 */
			if (!parse(&p, REG, &rd, ',', 0) || !ea(&p, &sym, &disp, &reg))
				continue;
			ldst(LB, rd.u.reg, sym, disp, reg);
			ri(XORI, rd.u.reg, 0x80);
			addi(SUBI, rd.u.reg, rd.u.reg, 0x80);
			break;
		case LL:
		case SL:
			if (!parse(&p, REG, &rd, ',', 0) || !ea(&p, &sym, &disp, &reg))
				continue;
			t.u.in = (t.u.in == LL) ? LW : SW;
			ldst(t.u.in, rd.u.reg, sym, disp+2, reg);
			ldst(t.u.in, pairreg(rd.u.reg), sym, disp, reg);
			break;
		case BR:   case BRN:  case BEQ:  case BNE:
		case BC:   case BNC:  case BV:   case BNV:
		case BLT:  case BGE:  case BLE:  case BGT:
		case BLTU: case BGEU: case BLEU: case BGTU:
		{
			if (!parse(&p, SYM, &lab, EOL, 0))
				continue;
			fixup(FIX_BR, lab.u.sym, 0);
			insn(t.u.in, 0);
			break;
		}
		case CALL:
			if (!parse(&p, SYM, &lab, EOL, 0))
				continue;
			fixup(FIX_CALL, lab.u.sym, 0);
			insn(CALL, 0);
			break;
		case TRAP:
			if (!constant(&p, &con) || !parse(&p, EOL, 0))
				continue;
			insn(TRAP, con);
			break;

		case NOP: /* nop => and r0, r0 */
			if (!parse(&p, EOL, 0))
				continue;
			nop();
			break;
		case MOV: /* mov rd,ra  =>  add rd,ra,r0 */
			if (!parse(&p, REG, &rd, ',', REG, &ra, EOL, 0))
				continue;
			mov(rd.u.reg, ra.u.reg);
			break;
		case CMP: /* cmp ra,rb  =>  sub r0,ra,rb */
			if (!parse(&p, REG, &ra, ',', REG, &rb, EOL, 0))
				continue;
			if (rb.u.reg == lastDestReg() && rb.u.reg != 0) {
				/* Since the B register port does not get result
				 * forwarding, insert a nop between insn which computes
				 * a result and this RR instruction which uses it.
				 */
				nop();
			}
			insn(SUB, INSN_RD(0) | INSN_RA(ra.u.reg) | INSN_RB(rb.u.reg));
			break;
		case CMPI:
			/* cmpi ra,imm  =>  sub  r0,ra,r0   (imm == 0)
			 *              =>  lea  r1,-32768  (imm == -32768)
			 *                  sub  r0,ra,r1 
			 *              =>  subi r0,ra,imm  (otherwise)
			 */
			if (!parse(&p, REG, &ra, ',', 0) || !constant(&p, &con) || !parse(&p, EOL, 0))
				continue;
			if (con == 0)
				insn(SUB, INSN_RD(0) | INSN_RA(ra.u.reg) | INSN_RB(0));
			else if ((Word)con == 0x8000) {
				addi(ADDI, 1, 0, con);
				nop();
				insn(SUB, INSN_RD(0) | INSN_RA(ra.u.reg) | INSN_RB(1));
			}
			else
				addi(SUBI, 0, ra.u.reg, con);
				
			break;
		case LEA: /* lea rd,imm(ra)  =>  addi rd,ra,imm */
			if (!parse(&p, REG, &rd, ',', 0) || !ea(&p, &sym, &disp, &reg))
				continue;
			if (sym)
				fixup(FIX_LDST, sym, disp);
			if (sym || disp < -8 || disp > 7)
				insn(IMM, INSN_I12(disp >> 4));
			insn(ADDI, INSN_RD(rd.u.reg) | INSN_RA(reg) | INSN_I4(disp));
			break;
		case J: /* j ea  =>  jal r0,ea */
			if (!ea(&p, &sym, &disp, &reg))
				continue;
			ldst(JAL, 0, sym, disp, reg);
			break;
		case RET: /* ret  =>  jal r0,0(r15) */
			if (!parse(&p, EOL, 0))
				continue;
			insn(JAL, INSN_RD(0) | INSN_RA(15) | INSN_I4(0));
			break;
		case RETI: /* reti  =>  jal r0,0(r14) */
			if (!parse(&p, EOL, 0))
				continue;
			insn(JAL, INSN_RD(0) | INSN_RA(14) | INSN_I4(0));
			break;
		case SEXT: /* sext rd,ra =>  mov(opt) rd,ra || and rd,0xFF || xor rd,0x80 || subi rd,0x80 */
		case ZEXT: /* zext rd,ra =>  mov(opt) rd,ra || and rd,0xFF */
			if (!parse(&p, REG, &rd, ',', REG, &ra, EOL, 0))
				continue;
			if (rd.u.reg != ra.u.reg)
				mov(rd.u.reg, ra.u.reg);
			ri(ANDI, rd.u.reg, 0xFF);
			if (t.u.in == SEXT) {
				ri(XORI, rd.u.reg, 0x80);
				addi(SUBI, rd.u.reg, rd.u.reg, 0x80);
			}
			break;

		case ADDL:
		case SUBL:
			if (!parse(&p, REG, &rd, ',', REG, &ra, ',', REG, &rb, EOL, 0) ||
			    !longreg(rd.u.reg) || !longreg(ra.u.reg) || !longreg(rb.u.reg))
				continue;
			t.u.in = (t.u.in == ADDL) ? ADD : SUB;
			if (rd.u.reg != ra.u.reg)
				mov(pairreg(rd.u.reg), pairreg(ra.u.reg));
			insn(t.u.in, INSN_RD(rd.u.reg)   | INSN_RA(ra.u.reg)   | INSN_RB(rb.u.reg));
			insn(t.u.in == ADD ? ADC : SBC, INSN_RD(pairreg(rd.u.reg)) | INSN_RB(pairreg(rb.u.reg)));
			break;
		case ANDL: case ORL: case XORL: case ANDNL:
			if (!parse(&p, REG, &rd, ',', REG, &rb, EOL, 0) ||
			    !longreg(rd.u.reg) || !longreg(rb.u.reg))
				continue;

			t.u.in = t.u.in - ANDL + AND;
			insn(t.u.in, INSN_RD(rd.u.reg) | INSN_RB(rb.u.reg));
			insn(t.u.in, INSN_RD(pairreg(rd.u.reg)) | INSN_RB(pairreg(rb.u.reg)));
			break;
		case MOVL:
			if (!parse(&p, REG, &rd, ',', REG, &ra, EOL, 0) ||
			    !longreg(rd.u.reg) || !longreg(ra.u.reg))
				continue;
			mov(rd.u.reg, ra.u.reg);
			mov(pairreg(rd.u.reg), pairreg(ra.u.reg));
			break;

		case GLOBAL:
			if (!parse(&p, SYM, &t, EOL, 0))
				continue;
			global(t.u.sym);
			break;
		
		case ALIGN:
			if (!constant(&p, &con) || !parse(&p, EOL, 0))
				continue;
			else if ((con & (con-1)) != 0) {
				error("alignment %d is not a power of 2", con);
				continue;
			}
			align(con);
			break;

		case BYTE_:
			if (!constant(&p, &disp))
				continue;
			byte(disp);
			break;

		case WORD_:
			if (!address(&p, &sym, &disp))
				continue;
			if (sym)
				fixup(FIX_ADDR, sym, disp);
			word(disp);
			break;

		case BSS: /* bss size */
			if (!constant(&p, &con) || !parse(&p, EOL, 0))
				continue;
			if (con > 0) {
				if ((con & 1) == 0)
					align(2);
				bss(con);
			}
			else {
				error("bss %d is not positive", con);
				continue;
			}
			break;

		default:
			error("unexpected token");
			continue;
		}
	}

	if (ferror(src) || fclose(src))
		error("error reading '%s' (%s)", source, strerror(errno));

	szCurrentFile = 0;
	line = 0;
}

void nop()
{
	insn(AND, 0);
}

void mov(int rd, int ra)
{
	insn(ADD, INSN_RD(rd) | INSN_RA(ra) | INSN_RB(0));
}

void ldst(int in, int rd, Sym sym, int disp, int reg)
{
	if (sym) {
		fixup(FIX_LDST, sym, disp);
		insn(IMM, 0);
	}
	else if (in == LW || in == SW || in == JAL) {
		if (disp & 1)
			error("odd offset");
		else if (disp < 0 || disp > 30)
			insn(IMM, INSN_I12(disp >> 4));
		else
			disp = ((disp>>1)<<1)|((disp&0x10)>>4);
	}
	else if (disp < 0 || disp > 15) {
		insn(IMM, INSN_I12(disp >> 4));
	}

	if ((in == SW || in == SB) && rd == lastDestReg() && rd != 0) {
		/* Since the store register port does not get result
		 * forwarding, insert a nop between insn which computes
		 * a result and a store instruction which sources that result.
		 */
		nop();
	}

	insn(in, INSN_RD(rd) | INSN_RA(reg) | INSN_I4(disp));
}

void addi(int in, int rd, int ra, int con)
{
	if (in == SUBI) {
		in = ADDI;
		con = -con;
	}
	if (con < -8 || con > 7)
		insn(IMM, INSN_I12(con >> 4));
	insn(ADDI, INSN_RD(rd) | INSN_RA(ra) | INSN_I4(con));
}

void ri(int in, int rd, int con)
{
	if (con < -8 || con > 7)
		insn(IMM, INSN_I12(con >> 4));
	insn(in, INSN_RD(rd) | INSN_I4(con));
}

Bool constant(char** pp, int *pcon)
{
	Token t;
	Bool neg = FALSE;

	*pcon = 0;

	t = lex(pp);
	if (t.type == '-') {
		neg = TRUE;
		t = lex(pp);
	}
	if (t.type == CON) {
		*pcon = neg ? -t.u.con : t.u.con;
		return TRUE;
	}
	else
		return FALSE;
}

/* address parser.
 * address ::= [SYM | CON ] { ['+' | '-'] CON }*
 */
Bool address(char** pp, Sym* psym, int* pdisp)
{
	Token t;

	*psym  = 0;
	*pdisp = 0;

	t = lex(pp);
	if (t.type == SYM) {
		*psym = t.u.sym;
		t = lex(pp);
	}
	else if (t.type == CON) {
		*pdisp = t.u.con;
		t = lex(pp);
	}
	else
		return FALSE;

	while (t.type == '+' || t.type == '-') {
		Bool add = t.type == '+';
		t = lex(pp);
		if (t.type != CON)
			return FALSE;
		*pdisp = add ? *pdisp + t.u.con : *pdisp - t.u.con;
		t = lex(pp);
	}
	return (t.type == EOL);
}

/* effective address parser.
 * ea ::= [SYM | CON | ] { ['+' | '-'] CON }* { '(' REG ')' }
 */
Bool ea(char** pp, Sym* psym, int* pdisp, int* preg)
{
	Token t;

	*psym  = 0;
	*pdisp = 0;
	*preg  = 0;

	t = lex(pp);
	if (!(t.type == SYM || t.type == CON || t.type == '+' || t.type == '-' || t.type == '('))
		return FALSE;

	if (t.type == SYM) {
		*psym = t.u.sym;
		t = lex(pp);
	}
	else if (t.type == CON) {
		*pdisp = t.u.con;
		t = lex(pp);
	}
	while (t.type == '+' || t.type == '-') {
		Bool add = t.type == '+';
		t = lex(pp);
		if (t.type != CON)
			return FALSE;
		*pdisp = add ? *pdisp + t.u.con : *pdisp - t.u.con;
		t = lex(pp);
	}
	if (t.type == '(') {
		t = lex(pp);
		if (t.type == REG)
			*preg = t.u.reg;
		else
			return FALSE;
		t = lex(pp);
		if (t.type != ')')
			return FALSE;
		t = lex(pp);
	}
	return (t.type == EOL);
}

Bool longreg(int reg)
{
	if (0 <= reg && reg <= 11)
		return TRUE;
	else {
		error("r%d is not a long register name", reg);
		return FALSE;
	}
}

int pairreg(int reg)
{
	return (reg != 0) ? reg + 1 : 0;
}


typedef struct {
	SZ sz;
	Token token;
} SzToken;

SzToken tokens[];

Token lex(char** pp)
{
	char* p1;
	char c;
	Token t;

	memset(&t, 0, sizeof t);

	/* skip white space */
	while (**pp && isspace(**pp))
		++*pp;

	p1 = *pp;

	if (!**pp || **pp == ';') {
		/* end of line, or comment -- do not advance p. */
		t.type = EOL;
	}
	else if (isalpha(**pp) || **pp == '_') {
		int i;

		++*pp;
		while (isalnum(**pp) || **pp == '_')
			++*pp;

		c = **pp;
		**pp = 0;

		for (i = 0; tokens[i].sz; i++) {
			if (strcmp(tokens[i].sz, p1) == 0) {
				**pp = c;
				return tokens[i].token;
			}
		}

		t.type = SYM;
		t.u.sym = lookup(p1);
		**pp = c;
	}
	else if (isdigit(**pp)) {
		if (**pp == '0') {
			++*pp;
			if (**pp == 'x' || **pp == 'X') {
				while (isxdigit(*++*pp))
					;
				c = **pp;
				**pp = 0;
				t.type = CON;
				sscanf(p1, "%x", &t.u.con);
				**pp = c;
				return t;
			}
			--*pp;
		}

		while (isdigit(*++*pp))
			;
		c = **pp;
		**pp = 0;
		t.type = CON;
		t.u.con = atoi(p1);
		**pp = c;
	}
	else {
		t.type = **pp;
		++*pp;
	}

	return t;
}

Bool parse(char**p, ...)
{
	va_list va;
	Token t;
	Type expected;
	Bool ret = TRUE;

	va_start(va, p);

	while ((expected = va_arg(va, Type)) != 0) {
		t = lex(p);
		if (t.type != expected) {
			error("syntax error");
			ret = FALSE;
			break;
		}
		if (t.type == SYM || t.type == REG || t.type == CON) {
			Token* pt = va_arg(va, Token*);
			*pt = t;
		}
	}

	va_end(va);

	return ret;
}

enum { NSYMS = 10000 };
static int nsyms = 0;
static Symbol symtab[NSYMS];

/* Look-up symbol for string in current file's symbol table.
 * If found, return symbol.
 * If not, create new symbol and return that.
 *
 * Each source file has its own logical name space.
 * Global names (sym.file == 0) are visible across all files.
 */
Sym lookup(SZ sz)
{
	int i;

	for (i = 0; i < nsyms; i++)
		if ((symtab[i].file == 0 || symtab[i].file == file) &&
		    strncmp(symtab[i].id, sz, sizeof(symtab[i].id)-1) == 0)
			return &symtab[i];

	/* not found, add it */
	if (nsyms < NSYMS) {
		strncpy(symtab[i].id, sz, sizeof(symtab[i].id)-1);
		symtab[nsyms].addr = 0;
		symtab[nsyms].defined = FALSE;
		symtab[nsyms].file = file;
		return &symtab[nsyms++];
	}
	else
		return 0;
}

int cmpAddr(const void* pv1, const void* pv2)
{
	const Symbol* ps1 = pv1;
	const Symbol* ps2 = pv2;

	return ps1->addr - ps2->addr;
}

SZ szForAddr(char buf[], size_t cbbuf, Addr addr)
{
	static Bool sorted = FALSE;
	Symbol *p, *base = 0;

	if (!sorted) {
		qsort(symtab, nsyms, sizeof(symtab[0]), cmpAddr);
		sorted = TRUE;
	}

	/* find last symbol address <= addr
	 * 
	 * Takes advantage of the invariant that symbols are in order
	 * of increasing address.
	 */
	for (p = symtab; p < &symtab[nsyms] && p->addr <= addr; p++)
		if (p->id[0] != 'L') /* skip labels */
			base = p;

	if (base && !(strcmp(base->id, "end")==0 || strcmp(base->id, "__end")==0)) {
		if (addr == base->addr)
			_snprintf(buf, cbbuf, "%s", base->id);
		else
			_snprintf(buf, cbbuf, "%s+%d", base->id, addr - base->addr);
	} else
		_snprintf(buf, cbbuf, "%04X", addr);

	buf[cbbuf-1] = 0;

	return buf;
}


enum { cbMax = 65536 };
Byte rgb[cbMax];

unsigned cb = 0;

Addr here()
{
	return cb;
}

void label(Sym sym)
{
	sym->addr = cb;
	sym->defined = TRUE;
}

void global(Sym sym)
{
	sym->file = 0;
}

int lastDestReg()
{
	Insn insn = (rgb[cb-2] << 8) | rgb[cb-1];
	if (OP_ADD <= OP(insn) && OP(insn) < OP_SW)
		return RD(insn);
	else
		return 0;
}

void insn(unsigned in, unsigned w) {
	word(mpininsn[in] | w);
}

void align(unsigned alignment) {
	while (cb % alignment != 0)
		byte(0);
}

void bss(unsigned c) {
	while (c--)
		byte(0);
}

void word(unsigned w) {
	align(2);
	byte(w >> 8);
	byte(w);
}

unsigned wordAt(Addr addr) {
	return (rgb[addr] << 8) | rgb[addr+1];
}

void byte(unsigned b) {
	if (cb < sizeof(rgb))
		rgb[cb++] = (Byte)b;
}

enum { NFIXUPS = 10000 };
Fixup fixups[NFIXUPS];
int cfixup = 0;

void fixup(FixupType type, Sym target, int disp)
{
	if (cfixup < NFIXUPS) {
		fixups[cfixup].type = type;
		fixups[cfixup].target = target;
		fixups[cfixup].addr = cb;
		fixups[cfixup].disp = disp;
		++cfixup;
	}
}

void applyFixups() {
	Fixup*	pfix;

	for (pfix = fixups; pfix < &fixups[cfixup]; pfix++) {
		int disp;
		unsigned abs;

		if (!pfix->target->defined && !pfix->target->error) {
			error("undefined symbol '%s'", pfix->target->id);
			pfix->target->error = TRUE;
			continue;
		}

		switch (pfix->type) {
		case FIX_ADDR:
			abs = pfix->target->addr + pfix->disp;
			rgb[pfix->addr  ] = abs >> 8;
			rgb[pfix->addr+1] = abs;
			break;
		case FIX_LDST: {
			Insn imm  = (rgb[pfix->addr]   << 8) | rgb[pfix->addr+1];
			Insn insn = (rgb[pfix->addr+2] << 8) | rgb[pfix->addr+3];
			Bool byte = (OP(insn) == OP_LB || OP(insn) == OP_SB || OP(insn) == OP_ADDI);
			Bool word = (OP(insn) == OP_LW || OP(insn) == OP_SW || OP(insn) == OP_JAL);

			abs = pfix->target->addr + pfix->disp;

			if (OP(imm) != OP_IMM || !(byte || word)) {
				error("ldst fixup error");
				break;
			}
			else if ((abs&1) && word) {
				error("ldst word fixup error target '%s' odd address %04X + %d", pfix->target->id, pfix->target->addr, pfix->disp);
				break;
			}

			imm = mpininsn[IMM] | IMM12(abs >> 4);
			insn = (insn & ~0xF) | INSN_I4(abs);

			rgb[pfix->addr  ] = imm >> 8;
			rgb[pfix->addr+1] = (Byte)imm;
			rgb[pfix->addr+2] = insn >> 8;
			rgb[pfix->addr+3] = (Byte)insn;
			break;
		}
		case FIX_BR:
			disp = ((int)pfix->target->addr - (int)pfix->addr)/2 - 2;
			if (-128 <= disp && disp < 128)
				rgb[pfix->addr+1] = (Byte)disp;
			else
				error("branch displacement overflow at %04X target '%s'", pfix->addr, pfix->target->id);
			break;
		case FIX_CALL:
			if ((pfix->target->addr & 0xF) == 0) {
				rgb[pfix->addr]   |= (pfix->target->addr >> 12) & 0x0F;
				rgb[pfix->addr+1] |= (pfix->target->addr >>  4) & 0xFF;
			}
			else
				error("call at %04X target '%s' is not 16-byte aligned", pfix->addr, pfix->target->id);
			break;
		default:
			error("unexpected fixup type");
			break;
		}
	}
}

void addListingLine(SZ line) {
	if (nlines < NLINES) {
		lines[nlines].addr = here();
		lines[nlines].szLine = _strdup(line);
		++nlines;
	}
}

void listing(SZ lstfile) {
	FILE*	lst;
	Addr	addr;
	Insn	insn;
	time_t	now;
	struct tm* ptmNow;
	char	szInsn[20];
	static char rev[] = "$Revision: 3 $";

	if ((lst = fopen(lstfile, "w")) == 0) {
		error("cannot open '%s' (%s)", lstfile, strerror(errno));
		return;
	}

	time(&now);
	ptmNow = localtime(&now);
	rev[strlen(rev)-2] = 0;
	fprintf(lst, "# generated by xr16 rev.%s on %s\n", rev+11, asctime(ptmNow));
	fprintf(lst, "addr code  disassembly       source\n");
	fprintf(lst, "---- ----  -----------       ------\n");
	line = 0;
	for (addr = 0; addr < cb; addr += sizeof(Insn)) {
		while (line+1 < nlines && lines[line].addr <= addr && lines[line+1].addr <= addr)
			fprintf(lst, "%-28s %s\n", "", lines[line++].szLine);

		insn = wordAt(addr);
		szForInsn(szInsn, sizeof szInsn, addr, insn);
		fprintf(lst, "%04X %04X  %-18s", addr, insn, szInsn);

		if (line < nlines && lines[line].addr <= addr)
			fprintf(lst, "%s\n", lines[line++].szLine);
		else
			fprintf(lst, "\n");
	}
	for ( ; line < nlines; ++line)
		fprintf(lst, "%-28s %s\n", "", lines[line].szLine);

	if (ferror(lst) || fclose(lst))
		error("error writing '%s' (%s)", lstfile, strerror(errno));
}

void emit(SZ hexfile) {
	FILE*	hex;
	Addr	addr;

	if ((hex = fopen(hexfile, "w")) == 0) {
		error("cannot open '%s' (%s)", hexfile, strerror(errno));
		return;
	}

	for (addr = 0; addr < cb; addr++) {
		if (addr % 16 == 0)
			fprintf(hex, "- %02X %04X", __min(0x10, cb - addr), addr);
		fprintf(hex, " %02X", rgb[addr]);
		if (addr % 16 == 15 || addr == cb-1)
			fprintf(hex, "\n");
	}

	if (ferror(hex) || fclose(hex))
		error("error writing '%s' (%s)", hexfile, strerror(errno));
}

static SZ mprnsz[16] = {
	"r0", "r1", "r2", "r3",
	"r4", "r5", "r6", "r7",
	"r8", "r9", "r10", "r11",
	"r12", "r13", "sp", "r15"
};

static SZ mpopsz[16] = {
	"add  %s,%s,%s",
	"sub  %s,%s,%s",
	"addi %s,%s,%d",
	0,
	0,
	"lw   %s,%d(%s)",
	"lb   %s,%d(%s)",
	0,
	"sw   %s,%d(%s)",
	"sb   %s,%d(%s)",
	"jal  %s,%d(%s)",
	0,
	"call %04X",
	"imm  %04X",
	0,
	"trap %d"
};

static SZ mpfnszRR[16] = {
	"and  %s,%s",
	"or   %s,%s",
	"xor  %s,%s",
	"andn %s,%s",
	"adc  %s,%s",
	"sbc  %s,%s"
};

static SZ mpfnszRI[16] = {
	"andi %s,%d",
	"ori  %s,%d",
	"xori %s,%d",
	"andni %s,%d",
	"adci %s,%d",
	"sbci %s,%d",
	"srli %s,%d",
	"srai %s,%d",
	"slli %s,%d",
	"srxi %s,%d",
	"slxi %s,%d",
};

SZ mpcondszBR[16] = {
	"br   %04X",
	"brn",
	"beq  %04X",
	"bne  %04X",
	"bc   %04X",
	"bnc  %04X",
	"bv   %04X",
	"bnv  %04X",
	"blt  %04X",
	"bge  %04X",
	"ble  %04X",
	"bgt  %04X",
	"bltu %04X",
	"bgeu %04X",
	"bleu %04X",
	"bgtu %04X"
};

SZ szForInsn(char buf[], size_t cbbuf, Addr addr, Insn insn) {
	strcpy(buf, "<reserved>");

	buf[--cbbuf] = 0;

	switch (OP(insn)) {
	case OP_ADD:
	case OP_SUB:
		_snprintf(buf, cbbuf, mpopsz[OP(insn)], mprnsz[RD(insn)], mprnsz[RA(insn)], mprnsz[RB(insn)]);
		break;
	case OP_ADDI:
		_snprintf(buf, cbbuf, mpopsz[OP(insn)], mprnsz[RD(insn)], mprnsz[RA(insn)], IMM_SEXT(insn));
		break;
	case OP_RR:
		if (mpfnszRR[FN(insn)])
			_snprintf(buf, cbbuf, mpfnszRR[FN(insn)], mprnsz[RD(insn)], mprnsz[RB(insn)]);
		break;
	case OP_RI:
		if (mpfnszRI[FN(insn)])
			_snprintf(buf, cbbuf, mpfnszRI[FN(insn)], mprnsz[RD(insn)], IMM_SEXT(insn));
		break;
	case OP_LW:
	case OP_SW:
	case OP_JAL:
		_snprintf(buf, cbbuf, mpopsz[OP(insn)], mprnsz[RD(insn)], (((IMM(insn)>>1)<<1)|((IMM(insn)&1)<<4)), mprnsz[RA(insn)]);
		break;
	case OP_LB:
	case OP_SB:
		_snprintf(buf, cbbuf, mpopsz[OP(insn)], mprnsz[RD(insn)], IMM(insn), mprnsz[RA(insn)]);
		break;
	case OP_BR:
		if (mpcondszBR[COND(insn)])
			_snprintf(buf, cbbuf, mpcondszBR[COND(insn)], addr + (DISP(insn) + 2)*sizeof(Insn));
		break;
	case OP_CALL:
	case OP_IMM:
		_snprintf(buf, cbbuf, mpopsz[OP(insn)], IMM12(insn) << 4);
		break;
	case OP_TRAP:
		_snprintf(buf, cbbuf, mpopsz[OP(insn)], IMM12(insn));
		break;
	}
	buf[cbbuf] = 0;

	return buf;
}

SZ mpinsz[] = {
	"and", "sub", "addi",
	"and", "or", "xor", "andn", "adc", "sbc",
	"andi", "ori", "xori", "andni", "adci", "sbci", "srli", "srai", "slli", "srxi", "slxi",
	"lw", "lb", 0, "sw", "sb", "jal",
	"br", "brn", "beq", "bne", "bc", "bnc", "bv", "bnv",
	"blt", "bge", "ble", "bgt", "bltu", "bgeu", "bleu", "bgtu",
	"call", "imm", 0
};

Insn mpininsn[] = {
	INSN_OP(OP_ADD),
	INSN_OP(OP_SUB),
	INSN_OP(OP_ADDI),
	INSN_OPFN(OP_RR, FN_AND),
	INSN_OPFN(OP_RR, FN_OR),
	INSN_OPFN(OP_RR, FN_XOR),
	INSN_OPFN(OP_RR, FN_ANDN),
	INSN_OPFN(OP_RR, FN_ADC),
	INSN_OPFN(OP_RR, FN_SBC),
	INSN_OPFN(OP_RI, FN_AND),
	INSN_OPFN(OP_RI, FN_OR),
	INSN_OPFN(OP_RI, FN_XOR),
	INSN_OPFN(OP_RI, FN_ANDN),
	INSN_OPFN(OP_RI, FN_ADC),
	INSN_OPFN(OP_RI, FN_SBC),
	INSN_OPFN(OP_RI, FN_SRL),
	INSN_OPFN(OP_RI, FN_SRA),
	INSN_OPFN(OP_RI, FN_SLL),
	INSN_OPFN(OP_RI, FN_SRX),
	INSN_OPFN(OP_RI, FN_SLX),
	INSN_OP(OP_LW),
	INSN_OP(OP_LB),
	INSN_OP(OP_SW),
	INSN_OP(OP_SB),
	INSN_OP(OP_JAL),
	INSN_BR(BR_BR),
	INSN_BR(BR_BRN),
	INSN_BR(BR_BEQ),
	INSN_BR(BR_BNE),
	INSN_BR(BR_BC),
	INSN_BR(BR_BNC),
	INSN_BR(BR_BV),
	INSN_BR(BR_BNV),
	INSN_BR(BR_BLT),
	INSN_BR(BR_BGE),
	INSN_BR(BR_BLE),
	INSN_BR(BR_BGT),
	INSN_BR(BR_BLTU),
	INSN_BR(BR_BGEU),
	INSN_BR(BR_BLEU),
	INSN_BR(BR_BGTU), 
	INSN_OP(OP_CALL),
	INSN_OP(OP_IMM),
	INSN_OP(OP_TRAP),
};

SzToken tokens[] = {
	{ "add",	{ IN, ADD } },
	{ "sub",	{ IN, SUB } },
	{ "addi",	{ IN, ADDI } },
	{ "and",	{ IN, AND } },
	{ "or",		{ IN, OR } },
	{ "xor",	{ IN, XOR } },
	{ "andn",	{ IN, ANDN } },
	{ "adc",	{ IN, ADC } },
	{ "sbc",	{ IN, SBC } },
	{ "andi",	{ IN, ANDI } },
	{ "ori",	{ IN, ORI } },
	{ "xori",	{ IN, XORI } },
	{ "andni",	{ IN, ANDNI } },
	{ "adci",	{ IN, ADCI } },
	{ "sbci",	{ IN, SBCI } },
	{ "srli",	{ IN, SRLI } },
	{ "srai",	{ IN, SRAI } },
	{ "slli",	{ IN, SLLI } },
	{ "srxi",	{ IN, SRXI } },
	{ "slxi",	{ IN, SLXI } },
	{ "lw",		{ IN, LW } },
	{ "lb",		{ IN, LB } },
	{ "sw",		{ IN, SW } },
	{ "sb",		{ IN, SB } },
	{ "jal",	{ IN, JAL } },
	{ "br",		{ IN, BR } },
	{ "brn",	{ IN, BRN } },
	{ "beq",	{ IN, BEQ } },
	{ "bne",	{ IN, BNE } },
	{ "bc",		{ IN, BC } },
	{ "bnc",	{ IN, BNC } },
	{ "bv",		{ IN, BV } },
	{ "bnv",	{ IN, BNV } },
	{ "blt",	{ IN, BLT } },
	{ "bge",	{ IN, BGE } },
	{ "ble",	{ IN, BLE } },
	{ "bgt",	{ IN, BGT } },
	{ "bltu",	{ IN, BLTU } },
	{ "bgeu",	{ IN, BGEU } },
	{ "bleu",	{ IN, BLEU } },
	{ "bgtu",	{ IN, BGTU,  } },
	{ "call",	{ IN, CALL } },
	{ "imm",	{ IN, IMM } },

	{ "trap",	{ IN, TRAP } },

	{ "nop",	{ IN, NOP } },
	{ "mov",	{ IN, MOV } },
	{ "subi",	{ IN, SUBI } },
	{ "cmp",	{ IN, CMP } },
	{ "cmpi",	{ IN, CMPI } },
	{ "lea",	{ IN, LEA } },
	{ "j",		{ IN, J } },
	{ "ret",	{ IN, RET } },
	{ "reti",	{ IN, RETI } },
	{ "sext",	{ IN, SEXT } },
	{ "zext",	{ IN, ZEXT } },
	{ "lbs",	{ IN, LBS } },

	{ "addl",	{ IN, ADDL } },
	{ "subl",	{ IN, SUBL } },
	{ "andl",	{ IN, ANDL } },
	{ "orl",	{ IN, ORL } },
	{ "xorl",	{ IN, XORL } },
	{ "andnl",	{ IN, ANDNL } },
	{ "movl",	{ IN, MOVL } },
	{ "cmpl",	{ IN, CMPL } },
	{ "ll",		{ IN, LL } },
	{ "sl",		{ IN, SL } },

	{ "global",	{ IN, GLOBAL } },
	{ "align",	{ IN, ALIGN } },
	{ "byte",	{ IN, BYTE_ } },
	{ "word",	{ IN, WORD_ } },
	{ "bss",	{ IN, BSS } },

	{ "r0",		{ REG, 0 } },
	{ "r1",		{ REG, 1 } },
	{ "r2",		{ REG, 2 } },
	{ "r3",		{ REG, 3 } },
	{ "r4",		{ REG, 4 } },
	{ "r5",		{ REG, 5 } },
	{ "r6",		{ REG, 6 } },
	{ "r7",		{ REG, 7 } },
	{ "r8",		{ REG, 8 } },
	{ "r9",		{ REG, 9 } },
	{ "r10",	{ REG, 10 } },
	{ "r11",	{ REG, 11 } },
	{ "r12",	{ REG, 12 } },
	{ "r13",	{ REG, 13 } },
	{ "r14",	{ REG, 14 } },
	{ "r15",	{ REG, 15 } },
	{ "sp",		{ REG, 13 } },
	{ 0 }
};
 
extern SZ szProgram;
extern int errors;

int error(SZ szError, ...) {
	va_list va;
	char error[BUFSIZ], prefix[BUFSIZ], listing[BUFSIZ];

	++errors;

	va_start(va, szError);
	_vsnprintf(error, sizeof error, szError, va);
	va_end(va);
	error[sizeof(error)-1] = 0;

	if (szCurrentFile) {
		if (line)
			_snprintf(prefix, sizeof prefix, "%s(%d): %s", szCurrentFile, line, error);
		else
			_snprintf(prefix, sizeof prefix, "%s: %s", szCurrentFile, error);
	}
	else
		_snprintf(prefix, sizeof prefix, "%s", error);
	prefix[sizeof(prefix)-1] = 0;

	if (szProgram)
		fprintf(stderr, "%s: ", szProgram);
	fprintf(stderr, "%s\n", prefix);
	fflush(stderr);

	_snprintf(listing, sizeof listing, "# error %s", prefix);
	listing[sizeof(listing)-1] = 0;
	addListingLine(listing);

	return 1;
}
