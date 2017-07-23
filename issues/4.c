/*
 * 4.c -- illustrate that most kinds of mul div and mod are not implemented
 *
 * Copyright (C) 2000, Gray Research LLC.  All rights reserved.
 * The contents of this file are subject to the XSOC License Agreement;
 * you may not use this file except in compliance with this Agreement.
 * See the LICENSE file.
 */

int main()
{
	int i1, i2, i3;
	unsigned u1, u2, u3;
	long l1, l2, l3;
	unsigned long ul1, ul2, ul3;

	i3 = i1 * i2;
	i3 = i1 / i2;
	i3 = i1 % i2;

	u3 = u1 * u2;
	u3 = u1 / u2;
	u3 = u1 % u2;

	l3 = l1 * l2;
	l3 = l1 / l2;
	l3 = l1 % l2;

	ul3 = ul1 * ul2;
	ul3 = ul1 / ul2;
	ul3 = ul1 % ul2;

	return 0;
}
