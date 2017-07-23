/*
 * xr16sim.h -- xr16 assembler/simulator assembler/simulator headers
 *
 * Copyright (C) 1999, 2000, Gray Research LLC.  All rights reserved.
 * The contents of this file are subject to the XSOC License Agreement;
 * you may not use this file except in compliance with this Agreement.
 * See the LICENSE file.
 *
 * $Log: /dist/src/xr16/xr16sim.h $
 * 
 * 1     3/02/00 8:36p Jan
 *
 * tabs=4
 */

#ifndef _XR16SIM_H_
#define _XR16SIM_H_

/* Public */
enum {
	trInsn		= 1,	/* trace instructions */
	trMem		= 2,	/* trace memory accesses */
	trCall		= 4,	/* trace function calls/returns */
};

typedef struct XR16 {
	Bool trace;
	Word pc;
	Word r[16];
	Bool imm_prefix;
	Bool c;
	Bool v;
	Bool x;
	Insn insnPrev;
	long insns;
	long cycles;
	Word a, b;
} XR16;

void source(SZ szSrc);
void applyFixups();
void emit(SZ szHex);
void listing(SZ szListing);

XR16 reset(Word trace);
XR16 sim(XR16 p, int cinsns);

/* Private -- move elsewhere */
SZ szForAddr(char buf[], size_t bufsiz, Addr addr);
SZ szForInsn(char buf[], size_t bufsiz, Addr addr, Insn insn);

extern SZ szCurrentFile;
extern int line;
extern Byte rgb[];

#endif /* !_XR16SIM_H_ */

