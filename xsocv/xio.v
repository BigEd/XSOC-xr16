/* xio.v -- XSOC external I/O synthesizable Verilog models
 *
 * Copyright (C) 1999, 2000, Gray Research LLC.  All rights reserved.
 * The contents of this file are subject to the XSOC License Agreement;
 * you may not use this file except in compliance with this Agreement.
 * See the LICENSE file.
 *
 * $Header: /dist/xsocv/xio.v 6     4/06/00 10:55a Jan $
 * $Log: /dist/xsocv/xio.v $
 * 
 * 6     4/06/00 10:55a Jan
 * polish
 */ 

module xin8(clk, rst, ctrl, sel, d, i);
	input			clk;		// global clock
	input			rst;		// global async reset
	input	[15:0]	ctrl;		// abstract control bus
	input			sel;		// peripheral select
	inout	[7:0]	d;			// LSB of on-chip data bus
	input	[7:0]	i;

	tri		[7:0]	d;

	wire [4:0]	addr;
	wire		ud_t, ld_t, ud_ce, ld_ce;
	ctrl_dec dec(.clk(clk), .rst(rst), .ctrl(ctrl), .sel(sel), .ud_t(ud_t),
				 .ld_t(ld_t), .ud_ce(ud_ce), .ld_ce(ld_ce), .addr(addr));

	assign d = ld_t ? 8'bz : i;
endmodule


module xout4(clk, rst, ctrl, sel, d, q);
	input			clk;		// global clock
	input			rst;		// global async reset
	input	[15:0]	ctrl;		// abstract control bus
	input			sel;		// peripheral select
	inout	[3:0]	d;			// lsbs of on-chip data bus
	output	[3:0]	q;

	tri		[3:0]	d;
	reg		[3:0]	q;

	wire [4:0]	addr;
	wire		ud_t, ld_t, ud_ce, ld_ce;
	ctrl_dec dec(.clk(clk), .rst(rst), .ctrl(ctrl), .sel(sel), .ud_t(ud_t),
				 .ld_t(ld_t), .ud_ce(ud_ce), .ld_ce(ld_ce), .addr(addr));

	always @(posedge clk or posedge rst) begin
		if (rst)
			q <= 0;
		else if (ld_ce)
			q <= d;
	end
endmodule


module xout8(clk, rst, ctrl, sel, d, q);
	input			clk;		// global clock
	input			rst;		// global async reset
	input	[15:0]	ctrl;		// abstract control bus
	input			sel;		// peripheral select
	inout	[7:0]	d;			// LSB of on-chip data bus
	output	[7:0]	q;			// output pads

	tri		[7:0]	d;
	reg		[7:0]	q;

	wire [4:0]	addr;
	wire		ud_t, ld_t, ud_ce, ld_ce;
	ctrl_dec dec(.clk(clk), .rst(rst), .ctrl(ctrl), .sel(sel), .ud_t(ud_t),
				 .ld_t(ld_t), .ud_ce(ud_ce), .ld_ce(ld_ce), .addr(addr));

	always @(posedge clk or posedge rst) begin
		if (rst)
			q <= 0;
		else if (ld_ce)
			q <= d;
	end
endmodule
