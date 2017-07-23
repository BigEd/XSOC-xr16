#
# makefile -- lfsr makefile
#
# Copyright (C) 1999, 2000, Gray Research LLC.  All rights reserved.
# The contents of this file are subject to the XSOC License Agreement;
# you may not use this file except in compliance with this Agreement.
# See the LICENSE file.
#
# usage: nmake

CC=cl -nologo
CFLAGS=-Os -ML
O=obj
.c{$O\}.obj::
	 $(CC) $(CFLAGS) -Fo$O\ -c $<

OBJS=$O\lfsr.obj

lfsr.exe: $(OBJS)
	$(CC) -Os -Fe$@ $(OBJS)

clean:
	del lfsr.exe $(OBJS)
