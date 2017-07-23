/* vga.v -- XSOC bilevel VGA controller synthesizable Verilog model
 *
 * Copyright (C) 1999, 2000, Gray Research LLC.  All rights reserved.
 * The contents of this file are subject to the XSOC License Agreement;
 * you may not use this file except in compliance with this Agreement.
 * See the LICENSE file.
 *
 * $Header: /dist/xsocv/vga.v 6     4/06/00 10:55a Jan $
 * $Log: /dist/xsocv/vga.v $
 * 
 * 6     4/06/00 10:55a Jan
 * polish
 */ 

// vga -- 576x455 bilevel video controller with VGA compatible timings
//
module vga(clk, rst, vack, pixels_in, vreq, vreset, hsync_n, vsync_n, r, g, b);
	input			clk;		// global clock
	input			rst;		// global async reset
	input			vack;		// video data DMA acknowledge
	input	[15:0]	pixels_in;	// video data in
	output			vreq;		// video data DMA request
	output			vreset;		// video data reset DMA counter request
	output			hsync_n;	// active low horizontal sync
	output			vsync_n;	// active low vertical sync
	output	[1:0]	r, g, b;	// red, green, blue pixel output

	// Horizontal and vertical sync and enable timings, 12.5 MHz
	wire [9:0]	hc, vc;
	wire		h0		= hc == 10'h31D;
	wire		hblank	= hc == 10'h1C4;
	wire		hsyncon	= hc == 10'h122;
	wire		hsyncoff= hc == 10'h3B6;
	wire		v0		= vc == 10'h27D;
	wire		vblank	= vc == 10'h01D;
	wire		vsyncon	= vc == 10'h3F5;
	wire		vsyncoff= vc == 10'h3D7;

	lfsr10		hctr(.clk(clk), .rst(rst), .ce(1'b1), .cycle(h0), .q(hc));
	lfsr10		vctr(.clk(clk), .rst(rst), .ce(h0),   .cycle(v0), .q(vc));
	reg			henn, hen, hsync_n, ven, vsync_n;

	wire		en		= hen & ven;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			henn <= 0;
			hen <= 0;
			hsync_n <= 1;
			ven <= 0;
			vsync_n <= 1;
		end
		else begin
			if (h0)
				henn <= 1;
			else if (hblank)
				henn <= 0;
			hen <= henn;

			if (hsyncon)
				hsync_n <= 0;
			else if (hsyncoff)
				hsync_n <= 1;
				
			if (v0)
				ven <= 1;
			else if (vblank)
				ven <= 0;
			if (h0) begin
				if (vsyncon)
					vsync_n <= 0;
				else if (vsyncoff)
					vsync_n <= 1;
			end
		end
	end

	// Pixel shift register datapath
	reg [2:0]	paircnt;
	wire		needword = paircnt == 7;
	reg [15:0]	pending, sr;
	always @(posedge clk or posedge rst) begin
		if (rst)
			paircnt <= 0;
		else if (vsyncoff)
			paircnt <= 0;
		else if (en)
			paircnt <= paircnt + 1;
	end
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			pending <= 0;
			sr <= 0;
		end
		else begin
			if (vack)
				pending <= pixels_in;
			if (needword)
				sr <= pending;
			else
				sr <= {sr[13:0],2'b0};
		end
	end
	assign	vreset	= h0 & vsyncoff;
	assign	vreq	= needword | vreset;
	wire	pixel	= en ? (clk ? sr[15] : sr[14]) : 0;
	assign	r[1]	= pixel;
	assign	r[0]	= pixel;
	assign	g[1]	= pixel;
	assign	g[0]	= pixel;
	assign	b[1]	= pixel;
	assign	b[0]	= pixel;
endmodule


// lfsr10 -- 10-bit linear feedback shift register counter
//
module lfsr10(clk, rst, ce, cycle, q);
	input			clk;		// global clock
	input			rst;		// global async reset
	input			ce;			// counter clock enable
	input			cycle;		// toggle LFSR input to force short cycle
	output	[9:0]	q;			// counter output
	reg		[9:0]	q;

	always @(posedge clk or posedge rst) begin
		if (rst)
			q <= 0;
		else if (ce)
			q <= { q[8:0], ~(q[9] ^ q[6] ^ cycle) };
	end
endmodule

