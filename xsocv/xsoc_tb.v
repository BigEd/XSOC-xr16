/* xsoc_tb.v -- XSOC test bench (simulation only)
 *
 * Copyright (C) 1999, 2000, Gray Research LLC.  All rights reserved.
 * The contents of this file are subject to the XSOC License Agreement;
 * you may not use this file except in compliance with this Agreement.
 * See the LICENSE file.
 *
 * $Header: /dist/xsocv/xsoc_tb.v 9     4/06/00 10:55a Jan $
 * $Log: /dist/xsocv/xsoc_tb.v $
 * 
 * 9     4/06/00 10:55a Jan
 * polish
 *
 * 03/20/00 mbutts-@realizer.com (Mike Butts)
 *	Created.
 */ 

//`timescale 1ns / 100ps

module xsoc_tb ();
	reg		clk, rst;
	wire	[16:0]	xa;
	wire	[7:0]	xd;
	wire			xa_0, ram_ce_n, ram_oe_n, ram_we_n, res8031;
	wire	[14:0]	sramaddr = {xa[14:1], xa_0};
	reg		[4:0]	par_d;
	wire	[6:3]	par_s;
	wire	[1:0]	r, g, b;
	wire			hsync_n, vsync_n;

	initial begin
		clk = 1;
		rst = 0;
		par_d = 0;
		#10 rst = 1;
		#10 rst = 0;
	end

	always #40 clk = ~clk;	// 12.5 MHz
	
	xsoc x(
		.clk(clk), .rst(rst), .par_d(par_d), .par_s(par_s),
		.r(r), .g(g), .b(b), .hsync_n(hsync_n), .vsync_n(vsync_n),
		.ram_ce_n(ram_ce_n), .ram_oe_n(ram_oe_n), .ram_we_n(ram_we_n),
		.res8031(res8031), .xa(xa), .xa_0(xa_0), .xd(xd));

	SRAM32KX8 sram(
		.ce_n(ram_ce_n), .we_n(ram_we_n), .oe_n(ram_oe_n),
		.addr(sramaddr), .dq(xd));
	
	always @(posedge clk) begin
		#10 $display($time,,
			"addr=%h xd=%h we_=%b oe_=%b  ir=%h%sex_ir=%h%sa=%h b=%h d=%h %s%s%s%s",
			sramaddr, xd, ram_we_n, ram_oe_n,
			x.p.ctrl.ir, (x.p.ctrl.dc_annul ? "#" : " "),
			x.p.ctrl.ex_ir, (x.p.ctrl.ex_annul ? "#" : " "),
			x.p.dp.a, x.p.dp.b, x.d,
			(x.p.z ? "z" : "-"),
			(x.p.n ? "n" : "-"),
			(x.p.co ? "c" : "-"),
			(x.p.v ? "v" : "-"));
		if ($time > 100 && sramaddr == 0) $finish;
	end

endmodule
