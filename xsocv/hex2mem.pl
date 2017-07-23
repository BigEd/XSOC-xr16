#!/usr/local/bin/perl
#
# Copyright (C) 1999, 2000, Gray Research LLC.  All rights reserved.
# The contents of this file are subject to the XSOC License Agreement;
# you may not use this file except in compliance with this Agreement.
# See the LICENSE file.
#
# $Header:$
# 03/20/00 mbutts-@realizer.com (Mike Butts)
#	Created/contributed.

# usage: hex2mem file.hex > file.mem
# takes intel hex file and writes file for verilog $readmemh

while (<>) {
	@f = split;
	print "$f[3] $f[4] $f[5] $f[6] $f[7] $f[8] $f[9] $f[10] $f[11] $f[12] $f[13] $f[14] $f[15] $f[16] $f[17] $f[18]\n";
}
