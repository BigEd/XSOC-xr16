/* xr16.v -- xr16 pipelined RISC processor synthesizable Verilog model
 *
 * Copyright (C) 1999, 2000, Gray Research LLC.  All rights reserved.
 * The contents of this file are subject to the XSOC License Agreement;
 * you may not use this file except in compliance with this Agreement.
 * See the LICENSE file.
 *
 * $Header: /dist/xsocv/xr16.v 7     4/06/00 10:55a Jan $
 * $Log: /dist/xsocv/xr16.v $
 * 
 * 7     4/06/00 10:55a Jan
 * polish
 */ 

module xr16(
	clk, rst, rdy, ud_t, ld_t, udlt_t, int_req, dma_req, zerodma,
    insn, mem_ce, word_nxt, read_nxt, dbus_nxt, dma, addr_nxt, d);

	parameter		W	= 16;	// word width
	parameter		N	= W-1;	// msb index

	input			clk;		// global clock
	input			rst;		// global async reset
	input			rdy;		// current memory access is ready
	input			ud_t;		// active low store data MSB output enable
	input			ld_t;		// active low store data LSB output enable
	input			udlt_t;		// active low store data MSB->LSB output en
	input			int_req;	// interrupt request
	input			dma_req;	// DMA request
	input			zerodma;	// zero DMA counter request
	input	[N:0]	insn;		// new instruction word
	output			mem_ce;		// memory access clock enable
	output			word_nxt;	// next access is word wide
	output			read_nxt;	// next access is read
	output			dbus_nxt;	// next access uses on-chip data bus
	output			dma;		// current access is a DMA transfer
	output	[N:0]	addr_nxt;	// address of next memory access
	inout	[N:0]	d;			// on-chip data bus

	// locals
	wire		a15;		// A operand msb
	wire		z;			// zero result condition code
	wire		n;			// negative result condition code
	wire		co;			// carry-out result codition code
	wire		v;			// oVerflow result condition code
	wire		rf_we;		// register file write enable
	wire [3:0]	rna;		// register file port A register number
	wire [3:0]	rnb;		// register file port B register number
	wire		fwd;		// forward result bus into A operand register
	wire [11:0]	imm;		// 12-bit immediate field
	wire		sextimm4;	// sign-extend 4-bit immediate operand
	wire		zextimm4;	// zero-extend 4-bit immediate operand
	wire		wordimm4;	// word-offset 4-bit immediate operand
	wire		imm12;		// 12-bit immediate operand
	wire		pipe_ce;	// pipeline clock enable
	wire		b15_4_ce;	// b[15:4] clock enable
	wire		add;		// 1 => A + B; 0 => A - B
	wire		ci;			// carry-in
	wire [1:0]	logicop;	// logic unit opcode
	wire		sri;		// shift right msb input
	wire		sum_t;		// active low adder output enable
	wire		logic_t;	// active low logic unit output enable
	wire		zeroext_t;	// active low zero-extension output enable
	wire		shr_t;		// active low shift right output enable
	wire		shl_t;		// active low shift left output enable
	wire		ret_t;		// active low return address output enable
	wire		branch;		// branch taken
	wire [7:0]	brdisp;		// 8-bit branch displacement
	wire		selpc;		// address mux selects next PC
	wire		zeropc;		// force next PC to 0
	wire		dmapc;		// use DMA register in PC register file
	wire		pc_ce;		// PC clock enable
	wire		ret_ce;		// return address clock enable

	// submodules
	control ctrl(
		.clk(clk), .rst(rst), .rdy(rdy),
		.int_req(int_req), .dma_req(dma_req), .zerodma(zerodma),
		.insn(insn), .a15(a15), .z(z), .n(n), .co(co), .v(v),
		.mem_ce(mem_ce), .word_nxt(word_nxt), .read_nxt(read_nxt),
		.dbus_nxt(dbus_nxt), .dma(dma),
		.rf_we(rf_we), .rna(rna), .rnb(rnb),
		.fwd(fwd), .imm(imm), .sextimm4(sextimm4), .zextimm4(zextimm4),
		.wordimm4(wordimm4), .imm12(imm12),
		.pipe_ce(pipe_ce), .b15_4_ce(b15_4_ce),
		.add(add), .ci(ci), .logicop(logicop), .sri(sri),
		.sum_t(sum_t), .logic_t(logic_t), .shl_t(shl_t), .shr_t(shr_t),
		.zeroext_t(zeroext_t), .ret_t(ret_t),
		.branch(branch), .brdisp(brdisp), .selpc(selpc), .zeropc(zeropc),
		.dmapc(dmapc), .pc_ce(pc_ce), .ret_ce(ret_ce));

	datapath dp(
		.clk(clk), .rst(rst),
		.rf_we(rf_we), .rna(rna), .rnb(rnb),
		.fwd(fwd), .imm(imm), .sextimm4(sextimm4), .zextimm4(zextimm4),
		.wordimm4(wordimm4), .imm12(imm12),
		.pipe_ce(pipe_ce), .b15_4_ce(b15_4_ce),
		.add(add), .ci(ci), .logicop(logicop), .sri(sri),
		.sum_t(sum_t), .logic_t(logic_t), .shl_t(shl_t), .shr_t(shr_t),
		.zeroext_t(zeroext_t), .ret_t(ret_t),
		.ld_t(ld_t), .ud_t(ud_t), .udlt_t(udlt_t),
		.branch(branch), .brdisp(brdisp), .selpc(selpc), .zeropc(zeropc),
		.dmapc(dmapc), .pc_ce(pc_ce), .ret_ce(ret_ce),
		.a15(a15), .z(z), .n(n), .co(co), .v(v),
		.addr_nxt(addr_nxt), .res(d));

endmodule
