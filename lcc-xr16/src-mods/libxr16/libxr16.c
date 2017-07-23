/*
 * libxr16.c -- minimal xr16 runtime library
 *
 * Copyright (C) 1999, 2000, Gray Research LLC.  All rights reserved.
 * The contents of this file are subject to the XSOC License Agreement;
 * you may not use this file except in compliance with this Agreement.
 * See the LICENSE file.
 */

typedef unsigned Word;

extern int main();
extern Word	_end;

void _zeromem();
Word* _tos();

/* Processor reset: zero memory and call main.
 */
int _reset() {
	_zeromem();

	main();

	/* dynamic halt */
	for (;;)
		;
}

/* Reset memory to consistent known state.
 */
void _zeromem() {
	Word* p = &_end;
	Word* end = _tos();

	for ( ; p < end; ++p)
		*p = 0;
}

/* Interrupts have not been tested.
 */
int _interrupt() {
	return 0;
}

/* Too clever way to return address of approximately the top of stack;
 * ignore compiler warning on returning address of argument.
 */
Word* _tos(Word arg) {
	return &arg;
}

/* Multiply unsigned times unsigned.
 */
unsigned mulu2(unsigned a, unsigned b) {
	unsigned w = 0;

	for ( ; a; a >>= 1) {
		if (a&1) w += b;
		b <<= 1;
	}
	return w;
}

/* This must be the last symbol in the last module "linked" into the load
 * image.
 */
Word _end;
