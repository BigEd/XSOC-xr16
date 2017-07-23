/* gr.c -- bitmapped graphics demo
 *
 * Copyright (C) 2000, Gray Research LLC.  All rights reserved.
 * The contents of this file are subject to the XSOC License Agreement;
 * you may not use this file except in compliance with this Agreement.
 * See the LICENSE file.
 */

#define xMin 0
#define xMac 559
#define xMax 560
#define yMin 56
#define yMac 449
#define yMax 450
#define cbRow 72

#define xLMin xMin
#define xLMax xMax
#define xLMid ((xLMax+xLMin)/2)
#define yLMin (yMin + 23*8)
#define yLMax yMax
#define yLMid ((yLMax+yLMin)/2)

typedef unsigned char byte;

extern byte glyphs[];
extern char* msg[];

void clear();
void put(int y, int x, char* s);
void line(int x, int y, int x2, int y2);
byte* row(unsigned);

#define swap(a,b) if (1) { int t; t = (a); (a) = (b); (b) = t; } else

int main()
{
	int i;
	unsigned x, y;

	clear();
	
	y = yMin;
	for (i = 0; msg[i]; i++, y += 8)
		put(y,0, msg[i]);

	for (;;) {
		for (x = xLMin; x < xLMax; x += 4)
			line(xLMid, yLMid, x, yLMin);
		for (y = yLMin; y < yLMax; y += 4)
			line(xLMid, yLMid, xLMax, y);
		for (x = xLMax-4; ; x -= 4) {
			line(xLMid, yLMid, x, yLMax);
			if (x == xLMin)
				break;
		}
		for (y = yLMax-4; y >= yLMin; y -= 4)
			line(xLMid, yLMid, xLMin, y);
	}
}


#define G(c,i) (glyphs[((c)-0x20)*7U + i])

#define cbLine 96

void put(int y, int x, char* s)
{
	byte* p;
	byte* bp;
	int i;
	char line[cbLine+1];

	/* Copy s into line, padding last 4 chars with ' ',
	 * so that (line[i] == 0) => (i%4 == 0).
	 */
	for (i = 0; i < cbLine && s[i]; i++)
		line[i] = s[i];
	for ( ; i < cbLine && (i&3) != 0; i++)
		line[i] = ' ';
	line[i] = 0;

	for (i = 0; i < 7; i++) {
		bp = row(y + i);
		for (p = (byte*)line; *p; p += 4, bp += 3) {
			byte b0 = G(p[0],i);
			byte b1 = G(p[1],i);
			byte b2 = G(p[2],i);
			byte b3 = G(p[3],i);

			bp[0] = ((b0 << 2) | (b1 >> 4));
			bp[1] = ((b1 << 4) | (b2 >> 2));
			bp[2] = ((b2 << 6) | b3);
		}
	}
}

void clear()
{
	byte *p;
	byte *pEnd = row(yMax);

	for (p = row(yMin); p < pEnd; p++)
		*p = 0;
}

int abs(int n)
{
	return (n >= 0) ? n : -n;
}

static unsigned mask[] = {
	0x80, 0x40, 0x20, 0x10, 0x8, 0x4, 0x2, 0x1
};

void lineX(byte* p, unsigned m, int e, int x, int dx, int d, int _2dx, int _2dy);
void lineY1(byte* p, unsigned m, int e, int x, int dy, int _2dx, int _2dy);
void lineY2(byte* p, unsigned m, int e, int x, int dy, int _2dx, int _2dy);

// Draw line from (x,y) to (x2,y2) inclusive.
// Bresenham's algorithm.
//
void line(int x, int y, int x2, int y2)
{
	int dx, dy, d;
	int e;

	dx = x2 - x;
	dy = y2 - y;

	if (abs(dx) >= abs(dy)) {
		int _2dx, _2dy;

		if (x > x2) {
			swap(x, x2);
			swap(y, y2);
			dx = x2 - x;
			dy = y2 - y;
		}

		if (dy >= 0) {
			d = 1;
		}
		else {
			d = -1;
			dy = -dy;
		}

		_2dx = dx + dx;
		_2dy = dy + dy;
		e = _2dy - dx;

		lineX(row(y), 0, e, x, dx, d, _2dx, _2dy);
	}
	else {
		int _2dx, _2dy;

		if (y > y2) {
			swap(x, x2);
			swap(y, y2);
			dx = x2 - x;
			dy = y2 - y;
		}

		if (dx >= 0)
			d = 1;
		else {
			d = -1;
			dx = -dx;
		}

		_2dx = dx + dx;
		_2dy = dy + dy;
		e = _2dx - dy;

		if (d == 1)
			lineY1(row(y), 0, e, x, dy, _2dx, _2dy);
		else
			lineY2(row(y), 0, e, x, dy, _2dx, _2dy);
	}
}

void lineX(byte* p, unsigned m, int e, int x, int dx, int d, int _2dx, int _2dy)
{
	int dbRow = (d > 0) ? cbRow : -cbRow;

	p += (unsigned)x >> 3;
	m = mask[x&7U];
	*p ^= m;
	
	while (dx--) {
		if (e > 0) {
			p += dbRow;
			e -= _2dx;
		}
		e += _2dy;
		if (!(m >>= 1)) {
			m = mask[0];
			p++;
		}
		*p ^= m;
	}
}

void lineY1(byte* p, unsigned m, int e, int x, int dy, int _2dx, int _2dy)
{
	p += (unsigned)x >> 3;
	m = mask[x&7U];
	*p ^= m;

	while (dy--) {
		if (e > 0) {
			if (!(m >>= 1)) {
				m = mask[0];
				p++;
			}
			e -= _2dy;
		}
		e += _2dx;
		p += cbRow;
		*p ^= m;
	}
}

void lineY2(byte* p, unsigned m, int e, int x, int dy, int _2dx, int _2dy)
{
	p += (unsigned)x >> 3;
	m = mask[x&7U];
	*p ^= m;

	while (dy--) {
		if (e > 0) {
			if (!((m <<= 1) & 0xFF)) {
				m = mask[7];
				p--;
			}
			e -= _2dy;
		}
		e += _2dx;
		p += cbRow;
		*p ^= m;
	}
}

byte* row(unsigned r)
{
	return (byte*)(r*cbRow);
}

char* msg[] = {
"",
"Building a RISC CPU and System-on-a-Chip in an FPGA    -- by Jan Gray, "
 "jan@fpgacpu.org --",
"",
"I USED TO envy CPU designers, those lucky engineers with access to expensive "
 "tools and fabs.",
"Now field-programmable gate arrays make custom processor and integrated "
 "system design",
"accessible to everyone.  These days I design my own systems-on-a-chip, and "
 "it\'s great fun.",
"",
"20-50 MHz FPGA CPUs are perfect for many embedded applications.  They can "
 "support custom",
"instructions and function units, and can be reconfigured to enhance "
 "system-on-chip",
"development, testing, debugging, and tuning.  Of course, FPGA systems offer "
 "high integration,",
"short time-to-market, low NRE costs, and easy field updates of entire "
 "systems.",
"",
"THE PROJECT",
"",
"While several companies now sell FPGA CPU cores, most are synthesized "
 "implementations of",
"existing instruction sets, filling huge, expensive FPGAs, too slow and too "
 "costly for",
"production use.  These cores are marketed as ASIC prototyping platforms.",
"",
"In contrast, this series demonstrates that a streamlined and thrifty CPU "
 "design,",
"optimized for FPGAs, can achieve a cost-effective integrated computer "
 "system, even for",
"low-volume products that can\'t justify an ASIC run.  We\'ll build a "
 "system-on-a-chip, ",
"including a 16-bit RISC CPU, memory controller, video display controller, "
 "and peripherals,",
"in a small Xilinx 4005XL. ...",
0,
};
