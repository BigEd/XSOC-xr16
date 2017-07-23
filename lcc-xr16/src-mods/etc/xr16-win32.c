/*
 * xr16-win32.c -- lcc-xr16 for win32 driver
 *
 * Portions copyright (C) 1999, 2000, Gray Research LLC.  All rights reserved.
 * Portions of this file are subject to the XSOC License Agreement;
 * you may not use them except in compliance with this Agreement.
 * See the LICENSE file.
 *
 * This work is derived from the original etc/win32.c file in the
 * lcc4.1 distribution.  See the CPYRIGHT file.
 */

#include <string.h>

static char rcsid[] =
	"$Header: /dist/lcc-xr16/src-mods/etc/xr16-win32.c 3     3/04/00 10:05a Jan $\n"
	"Portions copyright (C) 1999,2000, Gray Research LLC.  All rights reserved.\n"
	"This program is subject to the XSOC License Agreement.\n"
	"See the LICENSE file.";

#ifndef LCCDIR
#define LCCDIR "\\progra~1\\lcc\\4.1\\bin\\"
#endif

char *suffixes[] = { ".c;.C", ".i;.I", ".s;.S", ".o;.O", ".hex", 0 };
char inputs[256] = "";
char *cpp[] = { LCCDIR "cpp", "-D__STDC__=1", "-D_XR16=1", "$1", "$2", "$3", 0 };
char *include[] = { "-I" LCCDIR "include", 0 };
char *com[] = { LCCDIR "rcc-xr16", "-target=xr16/win32", "$1", "$2", "$3", 0 };
char *as[] = { "command", "/c", "copy", "/b", "$1", "$2", "$3", ">nul", 0 };
char *ld[] = { "xr16", "-hex=$3", "$1", LCCDIR "reset.s", "$2", LCCDIR "libxr16.s", 0 };

extern char *concat(char *, char *);
extern char *replace(const char *, int, int);

int option(char *arg) {
	if (strncmp(arg, "-lccdir=", 8) == 0) {
		arg = replace(arg + 8, '/', '\\');
		if (arg[strlen(arg)-1] == '\\')
			arg[strlen(arg)-1] = '\0';
		cpp[0] = concat(arg, "\\cpp.exe");
		include[0] = concat("-I", concat(arg, "\\include"));
		com[0] = concat(arg, "\\rcc-xr16.exe");
		ld[3] = concat(arg, "\\reset.s");
		ld[5] = concat(arg, "\\libxr16.s");
	} else if (strcmp(arg, "-b") == 0)
		;
	else if (strncmp(arg, "-ld=", 4) == 0)
		ld[0] = &arg[4];
	else
		return 0;
	return 1;
}
