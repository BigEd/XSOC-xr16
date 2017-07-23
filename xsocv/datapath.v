/* datapath.v -- xr16 datapath synthesizable Verilog model
 *
 * Copyright (C) 1999, 2000, Gray Research LLC.  All rights reserved.
 * The contents of this file are subject to the XSOC License Agreement;
 * you may not use this file except in compliance with this Agreement.
 * See the LICENSE file.
 *
 * $Header: /dist/xsocv/datapath.v 6     4/06/00 10:55a Jan $
 * $Log: /dist/xsocv/datapath.v $
 * 
 * 6     4/06/00 10:55a Jan
 * polish
 */ 

module datapath(
		clk, rst,
		rf_we, rna, rnb,
		fwd, imm, sextimm4, zextimm4, wordimm4, imm12, pipe_ce, b15_4_ce,
		add, ci, logicop, sri,
		sum_t, logic_t, shl_t, shr_t, zeroext_t, ret_t, ld_t, ud_t, udlt_t,
		branch, brdisp, selpc, zeropc, dmapc, pc_ce, ret_ce,
		a15, z, n, co, v, addr_nxt, res);

	parameter		W	= 16;	// word width
	parameter		N	= W-1;	// msb index

	// ports
	input			clk;		// global clock
	input			rst;		// global async reset
	input			rf_we;		// register file write enable
	input [3:0]		rna;		// register file port A register number
	input [3:0]		rnb;		// register file port B register number
	input			fwd;		// forward result bus into A operand reg
	input [11:0]	imm;		// 12-bit immediate field
	input			sextimm4;	// sign-extend 4-bit immediate operand
	input			zextimm4;	// zero-extend 4-bit immediate operand
	input			wordimm4;	// word-offset 4-bit immediate operand
	input			imm12;		// 12-bit immediate operand
	input			pipe_ce;	// pipeline clock enable
	input			b15_4_ce;	// b[15:4] clock enable
	input			add;		// 1 => A + B; 0 => A - B
	input			ci;			// carry-in
	input [1:0]		logicop;	// logic unit opcode
	input			sri;		// shift right msb input
	input			sum_t;		// active low adder output enable
	input			logic_t;	// active low logic unit output enable
	input			shl_t;		// active low shift left output enable
	input			shr_t;		// active low shift right output enable
	input			zeroext_t;	// active low zero-extension output enable
	input			ret_t;		// active low return address output enable
	input			ud_t;		// active low store data MSB output enable
	input			ld_t;		// active low store data LSB output enable
	input			udlt_t;		// active low store data MSB->LSB output en
	input			branch;		// branch taken
	input [7:0]		brdisp;		// 8-bit branch displacement
	input			selpc;		// address mux selects next PC
	input			zeropc;		// force next PC to 0
	input			dmapc;		// use DMA register in PC register file
	input			pc_ce;		// PC clock enable
	input			ret_ce;		// return address clock enable
	output			a15;		// A operand msb
	output			z;			// zero result condition code
	output			n;			// negative result condition code
	output			co;			// carry-out result codition code
	output			v;			// oVerflow result condition code
	output	[N:0]	addr_nxt;	// address of next memory access
	inout	[N:0]	res;		// on-chip data bus
	tri		[N:0]	res;

	reg				z, n, co, v;
	reg		[N:0]	addr_nxt;

	// locals
	wire [N:0]	areg_nxt, breg_nxt; // reg file read port RAM output buses
	reg	 [N:0]	areg, breg;	// register file read ports
	reg  [N:0]	a, b;		// operand registers
	reg  [N:0]	dout;		// store data output register
	reg  [N:0]	sum;		// adder output
	reg  [N:0]	logic;		// logic unit output
	wire [N:0]	pc;			// current PC
	reg  [N:0]	pcnext;		// next PC	// REVIEW
	reg  [N:0]	ret;		// return address (DC stage PC)
	wire [6:0]	brdispext = {brdisp[7],brdisp[7],brdisp[7],brdisp[7],
								 brdisp[7],brdisp[7],brdisp[7]};

	// submodules
	ram16x16s aregs(.wclk(clk), .addr(rna), .we(rf_we), .d(res), .o(areg_nxt));
	ram16x16s bregs(.wclk(clk), .addr(rnb), .we(rf_we), .d(res), .o(breg_nxt));
	ram16x16s pcs(.wclk(clk), .addr({3'b0,dmapc}), .we(pc_ce), .d(addr_nxt),
				  .o(pc));

	// register file output registers
	always @(negedge clk or posedge rst) begin
		if (rst) begin
			areg <= 0;
			breg <= 0;
		end
		else begin
			areg <= areg_nxt;
			breg <= breg_nxt;
		end
	end

	// operand registers
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			a <= 0;
			b <= 0;
			dout <= 0;
		end
		else begin
			if (pipe_ce) begin
				a <= fwd ? res : areg;
				if (sextimm4 || zextimm4)
					b[3:0] <= imm[3:0];
				else if (wordimm4)
					b[3:0] <= {imm[3:1],1'b0};
				else if (imm12)
					b[3:0] <= 0;
				else
					b[3:0] <= breg[3:0];
				dout <= breg;
			end
			if (b15_4_ce) begin
				if (sextimm4)
					b[15:4] <= {12{imm[3]}};
				else if (zextimm4)
					b[15:4] <= 12'b0;
				else if (wordimm4)
					b[15:4] <= {11'b0,imm[0]};
				else if (imm12)
					b[15:4] <= imm[11:0];
				else
					b[15:4] <= breg[15:4];
			end
		end
	end

	// ALU
	assign a15 = a[15];
	reg ign;
	reg co0;
	always @(a or b or add or ci) begin
		if (add) begin
			{co0,sum,ign} = {a,ci} + {b,1'b1};
			co = co0;
		end
		else begin
			{co0,sum,ign} = {a,ci} - {b,1'b1};
			co = ~co0;
		end
		z = sum == 0;
		n = sum[15];
		// sum[15] = a[15] ^ b[15] ^ c15 <===> c15 = sum[15] ^ a[15] ^ b[15]
		v = co0 ^ sum[15] ^ a[15] ^ b[15];
	end
	always @(a or b or logicop) begin
		case (logicop)
		0: logic <= a&b;
		1: logic <= a|b;
		2: logic <= a^b;
		3: logic <= a&~b;
		endcase
	end

	// address/PC unit
	always @(branch or pc or brdispext or brdisp or dmapc) begin
		if (branch & ~dmapc)
			pcnext <= pc + {brdispext[6:0],brdisp[7:0],1'b0};
		else
			pcnext <= pc + 2;
	end
	always @(sum or pcnext or selpc or zeropc) begin
		if (zeropc)
			addr_nxt <= 0;
		else if (selpc)
			addr_nxt <= pcnext;
		else
			addr_nxt <= sum;
	end
	always @(posedge clk or posedge rst) begin
		if (rst)
			ret <= 0;
		else if (ret_ce)
			ret <= pc;
	end

	// result multiplexer
	assign res		 = sum_t     ? 16'bz : sum;
	assign res		 = logic_t   ? 16'bz : logic;
	assign res		 = shl_t     ? 16'bz : { a[14:0],1'b0 };
	assign res		 = shr_t     ? 16'bz : { sri, a[15:1] };
	assign res		 = ret_t     ? 16'bz : ret;
	assign res[7:0]	 = ld_t      ? 8'bz  : dout[7:0];
	assign res[15:8] = ud_t      ? 8'bz  : dout[15:8];
	assign res[7:0]	 = udlt_t    ? 8'bz  : dout[15:8];
	assign res[15:8] = zeroext_t ? 8'bz  : 0;

endmodule

