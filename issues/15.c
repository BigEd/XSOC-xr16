/*
 * 15.c -- illustrate that unsigned consts like 0x8000 are mistakenly
 * promoted to long.
 *
 * Copyright (C) 2000, Gray Research LLC.  All rights reserved.
 * The contents of this file are subject to the XSOC License Agreement;
 * you may not use this file except in compliance with this Agreement.
 * See the LICENSE file.
 */

int main()
{
	/* should evaluate to 1 but (0.92) evaluates to 0 */
	return sizeof(0x8000) == sizeof(unsigned);
}
