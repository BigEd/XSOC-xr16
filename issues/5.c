/*
 * 5.c -- illustrate that variable bit-count shifts are not implemented
 *
 * Copyright (C) 2000, Gray Research LLC.  All rights reserved.
 * The contents of this file are subject to the XSOC License Agreement;
 * you may not use this file except in compliance with this Agreement.
 * See the LICENSE file.
 */

int main()
{
	int i;
	unsigned u;
	long l;
	unsigned long ul;

	i = i << i;
	i = i << u;
	i = i << l;
	i = i << ul;

	u = u << i;
	u = u << u;
	u = u << l;
	u = u << ul;

	l = l << i;
	l = l << u;
	l = l << l;
	i = l << ul;

	ul = ul << i;
	ul = ul << u;
	ul = ul << l;
	ul = ul << ul;

	i = i >> i;
	i = i >> u;
	i = i >> l;
	i = i >> ul;

	u = u >> i;
	u = u >> u;
	u = u >> l;
	u = u >> ul;

	l = l >> i;
	l = l >> u;
	l = l >> l;
	i = l >> ul;

	ul = ul >> i;
	ul = ul >> u;
	ul = ul >> l;
	ul = ul >> ul;

	return 0;
}
