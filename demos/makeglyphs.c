/* makeglyphs.c -- emit glyphs.c
 *
 * Copyright (C) 2000, Gray Research LLC.  All rights reserved.
 * The contents of this file are subject to the XSOC License Agreement;
 * you may not use this file except in compliance with this Agreement.
 * See the LICENSE file.
 */

#include <ctype.h>
#include <stdlib.h>

char* chars =
	"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	"abcdefghijklmnopqrstuvwxyz"
	"0123456789"
	" .,:;'`!\"$^#+*()/\\-_=[]{}?~@%&<>";

char* glyphs =

".OOO."
"O...O"
"OOOOO"
"O...O"
"O...O"
"....."
"....."

"OOOO."
"O...O"
"OOOO."
"O...O"
"OOOO."
"....."
"....."

".OOO."
"O...."
"O...."
"O...."
".OOO."
"....."
"....."

"OOOO."
"O...O"
"O...O"
"O...O"
"OOOO."
"....."
"....."

"OOOOO"
"O...."
"OOO.."
"O...."
"OOOOO"
"....."
"....."

"OOOOO"
"O...."
"OOOO."
"O...."
"O...."
"....."
"....."

".OOO."
"O...."
"O..OO"
"O...O"
".OOO."
"....."
"....."

"O...O"
"O...O"
"OOOOO"
"O...O"
"O...O"
"....."
"....."

".OOO."
"..O.."
"..O.."
"..O.."
".OOO."
"....."
"....."

"....O"
"....O"
"....O"
"O...O"
".OOO."
"....."
"....."

"O...O"
"O..O."
"OOO.."
"O..O."
"O...O"
"....."
"....."

"O...."
"O...."
"O...."
"O...."
"OOOOO"
"....."
"....."

"O...O"
"OO.OO"
"O.O.O"
"O...O"
"O...O"
"....."
"....."

"O...O"
"OO..O"
"O.O.O"
"O..OO"
"O...O"
"....."
"....."

".OOO."
"O...O"
"O...O"
"O...O"
".OOO."
"....."
"....."

"OOOO."
"O...O"
"OOOO."
"O...."
"O...."
"....."
"....."

".OOO."
"O...O"
"O...O"
"O..OO"
".OOOO"
"....."
"....."

"OOOO."
"O...O"
"OOOO."
"O..O."
"O...O"
"....."
"....."

".OOO."
"O...."
".OOO."
"....O"
".OOO."
"....."
"....."

"OOOOO"
"..O.."
"..O.."
"..O.."
"..O.."
"....."
"....."

"O...O"
"O...O"
"O...O"
"O...O"
".OOO."
"....."
"....."

"O...O"
"O...O"
".O.O."
".O.O."
"..O.."
"....."
"....."

"O...O"
"O...O"
"O.O.O"
"O.O.O"
".O.O."
"....."
"....."

"O...O"
".O.O."
"..O.."
".O.O."
"O...O"
"....."
"....."

"O...O"
".O.O."
"..O.."
"..O.."
"..O.."
"....."
"....."

"OOOOO"
"...O."
"..O.."
".O..."
"OOOOO"
"....."
"....."

"....."
".OO.."
"...O."
"OOOO."
".OOO."
"....."
"....."

"O...."
"OOO.."
"O..O."
"O..O."
"OOO.."
"....."
"....."

"....."
".OOO."
"O...."
"O...."
".OOO."
"....."
"....."

"...O."
".OOO."
"O..O."
"O..O."
".OOO."
"....."
"....."

"....."
".OO.."
"OOOO."
"O...."
".OO.."
"....."
"....."

"..O.."
".O..."
"OOO.."
".O..."
".O..."
"....."
"....."

"....."
".OO.."
"O..O."
"O..O."
".OOO."
"...O."
".OO.."

"O...."
"OOO.."
"O..O."
"O..O."
"O..O."
"....."
"....."

"....."
".OO.."
"..O.."
"..O.."
".OOO."
"....."
"....."

"....."
"..OO."
"...O."
"...O."
"...O."
"O..O."
".OO.."

"O...."
"O..O."
"OOO.."
"OOO.."
"O..O."
"....."
"....."

".OO.."
"..O.."
"..O.."
"..O.."
".OOO."
"....."
"....."

"....."
"OO.O."
"O.O.O"
"O...O"
"O...O"
"....."
"....."

"....."
"OOO.."
"O..O."
"O..O."
"O..O."
"....."
"....."

"....."
".OO.."
"O..O."
"O..O."
".OO.."
"....."
"....."

"....."
"OOO.."
"O..O."
"O..O."
"OOO.."
"O...."
"O...."

"....."
".OOO."
"O..O."
"O..O."
".OOO."
"...O."
"...O."

"....."
"OOO.."
"O..O."
"O...."
"O...."
"....."
"....."

"....."
".OOO."
"OO..."
"..OO."
"OOO.."
"....."
"....."

"..O.."
".OOO."
"..O.."
"..O.."
"..O.."
"....."
"....."

"....."
"O..O."
"O..O."
"O..O."
".OOO."
"....."
"....."

"....."
"O..O."
"O..O."
"O.O.."
".O..."
"....."
"....."

"....."
"O...O"
"O...O"
"O.O.O"
".O.O."
"....."
"....."

"....."
"O..O."
".OO.."
".OO.."
"O..O."
"....."
"....."

"....."
"O..O."
"O..O."
"O..O."
".OOO."
"...O."
".OO.."

"....."
"OOOO."
"..O.."
".O..."
"OOOO."
"....."
"....."

".OOO."
"O...O"
"O.O.O"
"O...O"
".OOO."
"....."
"....."

"..O.."
".OO.."
"..O.."
"..O.."
".OOO."
"....."
"....."

".OOO."
"....O"
".OOO."
"O...."
"OOOOO"
"....."
"....."

".OOO."
"....O"
".OOO."
"....O"
".OOO."
"....."
"....."

"O..O."
"O..O."
"OOOOO"
"...O."
"...O."
"....."
"....."

"OOOO."
"O...."
"OOOO."
"....O"
"OOOO."
"....."
"....."

".OOO."
"O...."
"OOOO."
"O...O"
".OOO."
"....."
"....."

"OOOOO"
"...O."
"..O.."
"..O.."
"..O.."
"....."
"....."

".OOO."
"O...O"
".OOO."
"O...O"
".OOO."
"....."
"....."

".OOO."
"O...O"
".OOOO"
"....O"
".OOO."
"....."
"....."

"....."
"....."
"....."
"....."
"....."
"....."
"....."

"....."
"....."
"....."
"..OO."
"..OO."
"....."
"....."

"....."
"....."
"....."
"..OO."
"...O."
"..O.."
"....."

"....."
"..OO."
"..OO."
"....."
"..OO."
"..OO."
"....."

"....."
"..OO."
"..OO."
"....."
"..OO."
".OO.."
"....."

"..O.."
".O..."
"....."
"....."
"....."
"....."
"....."

".O..."
".O..."
"..O.."
"....."
"....."
"....."
"....."

"..O.."
"..O.."
"..O.."
"....."
"..O.."
"....."
"....."

".O.O."
".O.O."
"....."
"....."
"....."
"....."
"....."

".OOO."
"O.O.."
".OOO."
"..O.O"
".OOO."
"....."
"....."

"..O.."
".O.O."
"....."
"....."
"....."
"....."
"....."

".O.O."
"OOOOO"
".O.O."
"OOOOO"
".O.O."
"....."
"....."

"..O.."
"..O.."
"OOOOO"
"..O.."
"..O.."
"....."
"....."

"O.O.O"
".OOO."
"..O.."
".OOO."
"O.O.O"
"....."
"....."

"..O.."
".O..."
".O..."
".O..."
"..O.."
"....."
"....."

"..O.."
"...O."
"...O."
"...O."
"..O.."
"....."
"....."

"....O"
"...O."
"..O.."
".O..."
"O...."
"....."
"....."

"O...."
".O..."
"..O.."
"...O."
"....O"
"....."
"....."

"....."
"....."
"OOOOO"
"....."
"....."
"....."
"....."

"....."
"....."
"....."
"....."
"OOOOO"
"....."
"....."

"....."
"OOOOO"
"....."
"OOOOO"
"....."
"....."
"....."

".OOO."
".O..."
".O..."
".O..."
".OOO."
"....."
"....."

".OOO."
"...O."
"...O."
"...O."
".OOO."
"....."
"....."

"..O.."
".O..."
"OOO.."
".O..."
"..O.."
"....."
"....."

"..O.."
"...O."
"..OOO"
"...O."
"..O.."
"....."
"....."

".OOO."
"....O"
"..OO."
"....."
"..O.."
"....."
"....."

".O..."
"O.O.O"
"...O."
"....."
"....."
"....."
"....."

".OOO."
"O.OOO"
"O.OOO"
"O...."
".OOO."
"....."
"....."

"OO..O"
"OO.O."
"..O.."
".O.OO"
"O..OO"
"....."
"....."

".OO.."
".O.O."
".OO.."
"O..O."
".OO.O"
"....."
"....."

"...O."
"..O.."
".O..."
"..O.."
"...O."
"....."
"....."

".O..."
"..O.."
"...O."
"..O.."
".O..."
"....."
"....."
;

char* gly[128];

static char header[] =
	"/* glyphs.c -- character glyph tables\n"
	" *\n"
	" * Copyright (C) 2000, Gray Research LLC.  All rights reserved.\n"
	" * The contents of this file are subject to the XSOC License Agreement;\n"
	" * you may not use this file except in compliance with this Agreement.\n"
	" * See the LICENSE file.\n"
	" */\n\n";

int main(int argc, char* argv[])
{
	char* p;
	char* gp;
	int i, j;
	int off;

	for (gp = glyphs; *gp; gp++)
		if (*gp == '.')
			*gp = ' ';

	for (i = 0; i < 128; i++)
		gly[i] = "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO";

	gp = glyphs;
	for (p = chars; *p; p++) {
		gly[*p] = gp; 
		gp += 35;
	}

#define V(k) ((gly[i][5*j+k] == 'O') << (4-(k)))

	printf(header);
	printf("unsigned char glyphs[96*7] = {\n");
	for (i = 32; i < 128; i++) {
		printf("/* %02X ", i);
		if (isprint(i))
			printf("'%c' */ ", i);
		else
			printf("*** */ " );
		for (j = 0; j < 7; j++)
			printf(" 0x%02X,", V(4)+V(3)+V(2)+V(1)+V(0));
		printf("\n");
	}
	printf("};\n");

	return 0;
}
