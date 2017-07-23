/* sram32x8.v -- external async 32Kx8 SRAM Verilog model (simulation only)
 *
 * Copyright (C) 1999, 2000, Gray Research LLC.  All rights reserved.
 * The contents of this file are subject to the XSOC License Agreement;
 * you may not use this file except in compliance with this Agreement.
 * See the LICENSE file.
 *
 * Note this module is a functional model, with no timing, and is only
 * suitable for simulation, not synthesis.
 *
 * $Header: /dist/xsocv/sram32kx8.v 8     4/06/00 10:55a Jan $
 * $Log: /dist/xsocv/sram32kx8.v $
 * 
 * 8     4/06/00 10:55a Jan
 * polish
 *
 * 03/20/00 mbutts-@realizer.com (Mike Butts)
 *	Created.
 */ 

module SRAM32KX8(ce_n, we_n, oe_n, addr, dq);
	input			ce_n;	// active low chip enable
	input			we_n;	// active low write enable
	input			oe_n;	// active low output enable
	input	[14:0]	addr;	// byte address
	inout	[7:0]	dq;		// tri-state data I/O

	reg		[7:0]	mem [0:32767];

	initial begin
		$readmemh ("SRAM32KX8.mem", mem);
		$display ("Loaded SRAM32KX8.mem");
		$display (" 0000: %h%h %h%h %h%h %h%h", 
			mem[0], mem[1], mem[2], mem[3], mem[4], mem[5], mem[6], mem[7]);
	end

	assign dq = (~oe_n & ~ce_n) ? mem[addr] : 8'bz;

	always @(we_n or ce_n or addr or dq) begin
		if(~we_n & ~ce_n)
			mem[addr] = dq;
	end

endmodule

