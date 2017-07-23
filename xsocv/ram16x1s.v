/* ram16x1s.v -- 16x1 sync SRAM primitive Verilog model (simulation only)
 *
 * Copyright (C) 1999, 2000, Gray Research LLC.  All rights reserved.
 * The contents of this file are subject to the XSOC License Agreement;
 * you may not use this file except in compliance with this Agreement.
 * See the LICENSE file.
 *
 * 16x1 Static RAM with synchronous write capability; note this
 * module is a functional model, with no timing, and is only
 * suitable for simulation, not synthesis.
 *
 * $Header: /dist/xsocv/ram16x1s.v 6     4/06/00 10:55a Jan $
 * $Log: /dist/xsocv/ram16x1s.v $
 * 
 * 6     4/06/00 10:55a Jan
 * polish
 *
 * 03/20/00 Mike Butts
 *	Created.
 */ 

module RAM16X1S (O, A0, A1, A2, A3, D, WCLK, WE);
    output	O;				// data out
    input	A0, A1, A2, A3;	// address lines
	input	D;				// data in
	input	WCLK;			// write clock
	input	WE;				// write enable
    reg		mem [0:15];

    reg		[4:0]	count;

	wire	[3:0]	adr = {A3, A2, A1, A0};

    initial begin
        for(count = 0; count < 16; count = count + 1)
            mem[count] = 1'b0;
    end

	assign O = mem[adr];

    always @(posedge WCLK) begin
        if(WE == 1'b1)
            mem[adr] = D;
    end

endmodule

