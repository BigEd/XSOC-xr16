/* lfsr: help design an lfsr counter and decoder to divide by n.
 *
 * Copyright (C) 1999, 2000, Gray Research LLC.  All rights reserved.
 * The contents of this file are subject to the XSOC License Agreement;
 * you may not use this file except in compliance with this Agreement.
 * See the LICENSE file.
 *
 * Usage: lfsr [-v] bits count [subcount]*
 *
 * Finds the bit pattern to recognize when to complement the
 * lfsr input in order to achieve the desired cycle count.
 * Also finds the bit patterns of other counts within
 * that lfsr count sequence.
 *
 * See "Efficient Shift Registers, LFSR Counters, and
 * Long Pseudo-Random Sequence Generators", Peter Alfke,
 * Xilinx App Note, Aug. 1995
 *
 * tabs=4
 */

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <memory.h>

typedef int Bool;

static char rcsid[] =
	"$Header: /dist/src/lfsr/lfsr.c 1     3/21/00 3:06p Jan $\n"
	"Copyright (C) 1999,2000, Gray Research LLC.  All rights reserved.\n"
	"This program is subject to the XSOC License Agreement.\n"
	"See the LICENSE file.";

static unsigned taps[32][4] = {
	{ 0 }, { 0 }, { 0 }, { 3, 2 },
	{ 4, 3 }, { 5, 3 },	{ 6, 5 }, { 7, 6 },
	{ 8, 6, 5, 4 }, { 9, 5 }, { 10, 7 }, { 11, 9 },
	{ 12, 6, 4, 1 }, { 13, 4, 3, 1 }, { 14, 5, 3, 1 }, { 15, 14 },
	{ 16, 15, 13, 4 }, { 17, 14 }, { 18, 11 }, { 19, 6, 2, 1 },
	{ 20, 17 }, { 21, 19 }, { 22, 21 }, { 23, 18 },
	{ 24, 23, 22, 17 }, { 25, 22 }, { 26, 6, 2, 1 }, { 27, 5, 2, 1 },
	{ 28, 25 }, { 29, 27 }, { 30, 6, 4, 1, }, { 31, 28 }
};

void usage()
{
	fprintf(stderr, "lfsr: usage: lfsr [-v] bits count [subcount]*\n");
	exit(1);
}

int main(int argc, char *argv[])
{
	int n;				/* desired cycle length	*/
	int bits;			/* lfsr width */
	int i, j;			/* loop indices */
	unsigned w;			/* lfsr bit pattern */
	unsigned* history;	/* lfsr bit pattern history over last n cycles */
	int fmtwidth;		/* bit pattern width (for pretty printing only) */
	Bool verbose = 0;

	if (argc > 1 && strcmp(argv[1], "-v") == 0) {
		verbose = 1;
		--argc;
		++argv;
	}
	if (argc < 3)
		usage();

	bits = atoi(argv[1]);
	n    = atoi(argv[2]);
	if (!(2 <= n && n < 1 << 30)
	||	!(2 <= bits && bits <= 30)
	||	n >= (1 << bits))
		usage();

	fmtwidth = (bits+3)/4;

	history = malloc(n*sizeof(unsigned));
	if (history == 0) {
		fprintf(stderr, "lfsr: malloc(%d) failed\n", n*sizeof(unsigned));
		exit(1);
	}

	/* Evaluate and print the list of states. */
	if (verbose) {
		printf("\n%8s %*s %d-back\n", "n", fmtwidth, "w", n);
		printf("%8s %*.*s ------\n", "-", fmtwidth, fmtwidth, "------------");
		printf("%8d %0*X\n", 0, fmtwidth, 0);
	}
	w = 0;
	memset(history, 0, n*sizeof(unsigned));
	for (i = 1; ; i++) {
		unsigned in = 0;

		for (j = 0; j < 4 && taps[bits][j]; j++)
			in ^= (w >> ((taps[bits][j]) - 1)) & 1;
		w = ((w << 1) & ((1 << bits) - 1)) ^ !in;
		
		if (verbose) {
			printf("%8d %0*X", i, fmtwidth, w);
			if (i >= n)
				printf(" %0*X", fmtwidth, history[i%n]);
		}

		if (i >= n && (history[i%n] ^ 1) == w) {
			/* Found the cyclic bit pattern initiator state.
			 * If we complement the lfsr input bit when the
			 * count is in this state, it will cycle every n
			 * clocks.
			 */
			if (verbose)
				printf(" %d-cycle [%d-%d]: complement d0 when w==%0*X maps %0*X=>%0*X\n\n",
					n, i-n, i-1, fmtwidth, history[(i+n-1)%n], fmtwidth, w, fmtwidth, history[i%n]);
			break;
		}
		else {
			if (verbose)
				printf("\n");
			history[i%n] = w;
		}
	}

	w = history[(i+n-1)%n];

	/* Print counter bit patterns. */
	printf("lfsr %d-bits %d-cycle=%0*X", bits, n, fmtwidth, w);
	for (j = 3; j < argc; j++) {
		int d = atoi(argv[j]);
		printf(" %d=%0*X", d, fmtwidth, history[(i+d+n-1)%n]);
	}
	printf("\n");

	/* Print logic equation for n-cycle lfsr counter */
	printf("lfsr %d-bits %d-cycle: ", bits, n);
	printf("d0=xnor(");
	for (j = 0; j < 4 && taps[bits][j]; j++) {
		if (j > 0)
			printf(",");
		printf("q%d", taps[bits][j]-1);
	}

	printf(", /*%0*X*/and(", fmtwidth, w);
	for (j = bits-1; j >= 0; j--) {
		if (j != bits-1)
			printf(",");
		printf("%sq%d", (((w>>j)&1) ? "" : "~"), j);
	}
	printf("));\n");

	return 0;
}
