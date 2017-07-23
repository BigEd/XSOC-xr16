#
# makefile -- xr16 assembler/simulator makefile
#
# Copyright (C) 1999, 2000, Gray Research LLC.  All rights reserved.
# The contents of this file are subject to the XSOC License Agreement;
# you may not use this file except in compliance with this Agreement.
# See the LICENSE file.
#
# usage: nmake

CC=cl -nologo
CFLAGS=-Ot -ML
O=obj
.c{$O\}.obj::
	 $(CC) $(CFLAGS) -Fo$O\ -c $<

OBJS=$O\main.obj $O\asm.obj $O\sim.obj

xr16.exe: $(OBJS)
	$(CC) -Ot -Fe$@ $(OBJS)

clean:
	del xr16.exe $(OBJS)
