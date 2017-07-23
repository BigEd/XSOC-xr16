/* xram16.v -- XSOC on-chip RAM synthesizable Verilog model
 *
 * Copyright (C) 1999, 2000, Gray Research LLC.  All rights reserved.
 * The contents of this file are subject to the XSOC License Agreement;
 * you may not use this file except in compliance with this Agreement.
 * See the LICENSE file.
 *
 * $Header: /dist/xsocv/xram16.v 6     4/06/00 10:55a Jan $
 * $Log: /dist/xsocv/xram16.v $
 * 
 * 6     4/06/00 10:55a Jan
 * polish
 */ 

module xram16x16(clk, rst, ctrl, sel, d);
	input			clk;		// global clock
	input			rst;		// global async reset
	input	[15:0]	ctrl;		// abstract control bus
	input			sel;		// peripheral select
	inout	[15:0]	d;			// on-chip data bus

	tri		[15:0]	d;

	wire [4:0]	addr;
	wire		ud_t, ld_t, ud_ce, ld_ce;
	ctrl_dec dec(.clk(clk), .rst(rst), .ctrl(ctrl), .sel(sel), .ud_t(ud_t),
				 .ld_t(ld_t), .ud_ce(ud_ce), .ld_ce(ld_ce), .addr(addr));

	wire [15:0]	o;
	ram16x8s	ram8(clk, addr[4:1], ud_ce, d[15:8], o[15:8]);
	ram16x8s	ram0(clk, addr[4:1], ld_ce, d[7:0],  o[7:0]);

	assign d[15:8]	= ud_t ? 8'bz : o[15:8];
	assign d[7:0]	= ld_t ? 8'bz : o[7:0];

endmodule

