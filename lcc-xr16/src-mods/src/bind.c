/*
 * bind.c -- machine description interface binding table
 *
 * Portions copyright (C) 1999, 2000, Gray Research LLC.  All rights reserved.
 * Portions of this file are subject to the XSOC License Agreement;
 * you may not use them except in compliance with this Agreement.
 * See the LICENSE file.
 *
 * This work is derived from the original src/bind.c file in the
 * lcc4.1 distribution.  See the CPYRIGHT file.
 */

static char rcsid[] =
	"$Header: /dist/lcc-xr16/src-mods/src/bind.c 3     3/04/00 10:05a Jan $\n"
	"Portions copyright (C) 1999,2000, Gray Research LLC.  All rights reserved.\n"
	"This program is subject to the XSOC License Agreement.\n"
	"See the LICENSE file.";

#include "c.h"
extern Interface alphaIR;
extern Interface mipsebIR, mipselIR;
extern Interface xr16IR;
extern Interface sparcIR, solarisIR;
extern Interface x86IR, x86linuxIR;
extern Interface symbolicIR, symbolic64IR;
extern Interface nullIR;
extern Interface bytecodeIR;
Binding bindings[] = {
	"alpha/osf",     &alphaIR,
	"mips/irix",     &mipsebIR,
	"mips/ultrix",   &mipselIR,
	"xr16/win32",    &xr16IR,
	"sparc/sun",     &sparcIR,
	"sparc/solaris", &solarisIR,
	"x86/win32",	 &x86IR,
	"x86/linux",	 &x86linuxIR,
	"symbolic/osf",  &symbolic64IR,
	"symbolic/irix", &symbolicIR,
	"symbolic",      &symbolicIR,
	"null",          &nullIR,
	"bytecode",      &bytecodeIR,
	NULL,            NULL
};
