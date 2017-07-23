; sim.s -- Simple simulator startup code
; Copyright (C) 2000, Gray Research LLC.  All rights reserved.
; Usage subject to XSOC License Agreement.  See the LICENSE file.

global _main

sim:
	lea sp,0x7FFE
	call _main
	j 0            ; exit simulator
