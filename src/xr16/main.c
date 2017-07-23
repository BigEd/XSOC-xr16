/*
 * main.c -- xr16 assembler/simulator driver
 *
 * Copyright (C) 1999, 2000, Gray Research LLC.  All rights reserved.
 * The contents of this file are subject to the XSOC License Agreement;
 * you may not use this file except in compliance with this Agreement.
 * See the LICENSE file.
 *
 * $Log: /dist/src/xr16/main.c $
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
	"$Header: /dist/src/xr16/main.c 2     3/04/00 9:44a Jan $\n"
	"Copyright (C) 1999,2000, Gray Research LLC.  All rights reserved.\n"
	"This program is subject to the XSOC License Agreement.\n"
	"See the LICENSE file.";

#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <string.h>
#include <ctype.h>
#include <stdarg.h>
#include <assert.h>
#include <io.h>
#include "xr16.h"
#include "xr16sim.h"
 
int usage();

SZ szProgram;
SZ szCurrentFile;
int line;
int errors = 0;

int main(int argc, SZ argv[]) {
	int		i;
	SZ		hexfile = 0;
	SZ		lstfile = 0;

	szProgram = argv[0];
	if (argc < 2)
		return usage();

	/* Process options and source files */
	for (i = 1; i < argc; i++) {
		if (argv[i][0] == '-') {
			if (strlen(argv[i]) > 5 && strncmp(argv[i], "-hex=", 5) == 0) {
				hexfile = argv[i] + 5;
			}
			else if (strlen(argv[i]) > 5 && strncmp(argv[i], "-lst=", 5) == 0) {
				lstfile = argv[i] + 5;
			}
			else if (strcmp(argv[i], "-sim") == 0)
				break;
			else
				return usage();
		}
		else
			source(argv[i]);
	}

	/* Finish assembly and write output files (if any) */
	applyFixups();
	if (hexfile)
		emit(hexfile);
	if (lstfile)
		listing(lstfile);

	/* Clean up in case of error.  Leave the listing file though. */
	if (errors > 0) {
		if (hexfile)
			_unlink(hexfile);
		return 1;
	}

	/* Run simulator */
	if (i < argc && strcmp(argv[i], "-sim") == 0) {
		XR16 p = reset(trInsn | trMem | trCall);

		++i;
		if (i == argc) {
			/* No instruction count specified, run until return from main */
			p = sim(p, -1);
		}
		else {
			/* Instruction counts specified.  Run bursts of n instructions,
			 * toggling tracing on-and-off.
			 */
			for ( ; i < argc; i++) {
				p = sim(p, atoi(argv[i]));
				p.trace = p.trace ? 0 : trInsn | trMem | trCall;
			}
		}
		printf("%ld instructions  %ld cycles  %f CPI\n", p.insns, p.cycles, (double)p.cycles / p.insns);
	}
	return 0;
}


int usage() {
	fprintf(stderr, "Usage: %s [-hex=out.hex] [-lst=out.lst] source* [-sim insns*] \n", szProgram);

	return 1;
}
