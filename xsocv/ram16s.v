/* ram16s.v -- RAM block synthesizable Verilog models
 *
 * Copyright (C) 1999, 2000, Gray Research LLC.  All rights reserved.
 * The contents of this file are subject to the XSOC License Agreement;
 * you may not use this file except in compliance with this Agreement.
 * See the LICENSE file.
 *
 * $Header: /dist/xsocv/ram16s.v 6     4/06/00 10:55a Jan $
 * $Log: /dist/xsocv/ram16s.v $
 * 
 * 6     4/06/00 10:55a Jan
 * polish
 */ 

module ram16x16s(wclk, addr, we, d, o);
	input			wclk;	// write clock
	input	[3:0]	addr;	// address
	input			we;		// write enable
	input	[15:0]	d;		// write data in
	output	[15:0]	o;		// read data out

	RAM16X1S r0 (.A0(addr[0]), .A1(addr[1]), .A2(addr[2]), .A3(addr[3]),
				 .D(d[0]), .O(o[0]),  .WCLK(wclk), .WE(we));
	RAM16X1S r1 (.A0(addr[0]), .A1(addr[1]), .A2(addr[2]), .A3(addr[3]),
				 .D(d[1]), .O(o[1]),  .WCLK(wclk), .WE(we));
	RAM16X1S r2 (.A0(addr[0]), .A1(addr[1]), .A2(addr[2]), .A3(addr[3]),
				 .D(d[2]), .O(o[2]),  .WCLK(wclk), .WE(we));
	RAM16X1S r3 (.A0(addr[0]), .A1(addr[1]), .A2(addr[2]), .A3(addr[3]),
				 .D(d[3]), .O(o[3]),  .WCLK(wclk), .WE(we));
	RAM16X1S r4 (.A0(addr[0]), .A1(addr[1]), .A2(addr[2]), .A3(addr[3]),
				 .D(d[4]), .O(o[4]),  .WCLK(wclk), .WE(we));
	RAM16X1S r5 (.A0(addr[0]), .A1(addr[1]), .A2(addr[2]), .A3(addr[3]),
				 .D(d[5]), .O(o[5]),  .WCLK(wclk), .WE(we));
	RAM16X1S r6 (.A0(addr[0]), .A1(addr[1]), .A2(addr[2]), .A3(addr[3]),
				 .D(d[6]), .O(o[6]),  .WCLK(wclk), .WE(we));
	RAM16X1S r7 (.A0(addr[0]), .A1(addr[1]), .A2(addr[2]), .A3(addr[3]),
				 .D(d[7]), .O(o[7]),  .WCLK(wclk), .WE(we));
	RAM16X1S r8 (.A0(addr[0]), .A1(addr[1]), .A2(addr[2]), .A3(addr[3]),
				 .D(d[8]), .O(o[8]),  .WCLK(wclk), .WE(we));
	RAM16X1S r9 (.A0(addr[0]), .A1(addr[1]), .A2(addr[2]), .A3(addr[3]),
				 .D(d[9]), .O(o[9]),  .WCLK(wclk), .WE(we));
	RAM16X1S r10(.A0(addr[0]), .A1(addr[1]), .A2(addr[2]), .A3(addr[3]),
				 .D(d[10]), .O(o[10]), .WCLK(wclk), .WE(we));
	RAM16X1S r11(.A0(addr[0]), .A1(addr[1]), .A2(addr[2]), .A3(addr[3]),
				 .D(d[11]), .O(o[11]), .WCLK(wclk), .WE(we));
	RAM16X1S r12(.A0(addr[0]), .A1(addr[1]), .A2(addr[2]), .A3(addr[3]),
				 .D(d[12]), .O(o[12]), .WCLK(wclk), .WE(we));
	RAM16X1S r13(.A0(addr[0]), .A1(addr[1]), .A2(addr[2]), .A3(addr[3]),
				 .D(d[13]), .O(o[13]), .WCLK(wclk), .WE(we));
	RAM16X1S r14(.A0(addr[0]), .A1(addr[1]), .A2(addr[2]), .A3(addr[3]),
				 .D(d[14]), .O(o[14]), .WCLK(wclk), .WE(we));
	RAM16X1S r15(.A0(addr[0]), .A1(addr[1]), .A2(addr[2]), .A3(addr[3]),
				 .D(d[15]), .O(o[15]), .WCLK(wclk), .WE(we));
endmodule


module ram16x8s(wclk, addr, we, d, o);
	input			wclk;	// write clock
	input	[3:0]	addr;	// address
	input			we;		// write enable
	input	[7:0]	d;		// write data in
	output	[7:0]	o;		// read data out

	RAM16X1S r0(.A0(addr[0]), .A1(addr[1]), .A2(addr[2]), .A3(addr[3]),
				 .D(d[0]), .O(o[0]),  .WCLK(wclk), .WE(we));
	RAM16X1S r1(.A0(addr[0]), .A1(addr[1]), .A2(addr[2]), .A3(addr[3]),
				 .D(d[1]), .O(o[1]),  .WCLK(wclk), .WE(we));
	RAM16X1S r2(.A0(addr[0]), .A1(addr[1]), .A2(addr[2]), .A3(addr[3]),
				 .D(d[2]), .O(o[2]),  .WCLK(wclk), .WE(we));
	RAM16X1S r3(.A0(addr[0]), .A1(addr[1]), .A2(addr[2]), .A3(addr[3]),
				 .D(d[3]), .O(o[3]),  .WCLK(wclk), .WE(we));
	RAM16X1S r4(.A0(addr[0]), .A1(addr[1]), .A2(addr[2]), .A3(addr[3]),
				 .D(d[4]), .O(o[4]),  .WCLK(wclk), .WE(we));
	RAM16X1S r5(.A0(addr[0]), .A1(addr[1]), .A2(addr[2]), .A3(addr[3]),
				 .D(d[5]), .O(o[5]),  .WCLK(wclk), .WE(we));
	RAM16X1S r6(.A0(addr[0]), .A1(addr[1]), .A2(addr[2]), .A3(addr[3]),
				 .D(d[6]), .O(o[6]),  .WCLK(wclk), .WE(we));
	RAM16X1S r7(.A0(addr[0]), .A1(addr[1]), .A2(addr[2]), .A3(addr[3]),
				 .D(d[7]), .O(o[7]),  .WCLK(wclk), .WE(we));

endmodule
