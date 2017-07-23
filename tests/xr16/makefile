# makefile -- tests makefile
#
# Copyright (C) 1999, 2000, Gray Research LLC.  All rights reserved.
# The contents of this file are subject to the XSOC License Agreement;
# you may not use this file except in compliance with this Agreement.
# See the LICENSE file.
#
# $Header:$

xr16.hex xr16.lst xr16.sim xr16.mem: xr16.s
	xr16 -hex=xr16.hex -lst=xr16.lst xr16.s -sim >xr16.sim
	perl ../../xsocv/hex2mem.pl <xr16.hex >xr16.mem
