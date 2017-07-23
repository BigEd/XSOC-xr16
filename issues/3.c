/*
 * 3.c -- illustrate that far branch displacement conversion is
 * not implemented
 *
 * Copyright (C) 2000, Gray Research LLC.  All rights reserved.
 * The contents of this file are subject to the XSOC License Agreement;
 * you may not use this file except in compliance with this Agreement.
 * See the LICENSE file.
 */

int main()
{
	int i;

	while (i < 1000) {
		/* emit a loop body of about 140 instructions */
		++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i;
		++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i;
		++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i;
		++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i;
		++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i;
		++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i;
		++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i;
		++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i;
		++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i;
		++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i; ++i;
	}
	return i;
}
