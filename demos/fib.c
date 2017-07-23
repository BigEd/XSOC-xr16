/* fib.c -- find largest Fibonacci sequence number less than N
 *
 * Copyright (C) 2000, Gray Research LLC.  All rights reserved.
 * The contents of this file are subject to the XSOC License Agreement;
 * you may not use this file except in compliance with this Agreement.
 * See the LICENSE file.
 */

enum { N = 10000 };

int main() {
	int a = 1, b = 1, c = 1;

	while (c < N) {
		c = a + b;
		a = b;
		b = c;
	}
	return a;
}
