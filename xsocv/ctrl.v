/* ctrl.v -- xr16 control unit synthesizable Verilog model
 *
 * Copyright (C) 1999, 2000, Gray Research LLC.  All rights reserved.
 * The contents of this file are subject to the XSOC License Agreement;
 * you may not use this file except in compliance with this Agreement.
 * See the LICENSE file.
 *
 * $Header: /dist/xsocv/ctrl.v 8     4/06/00 10:55a Jan $
 * $Log: /dist/xsocv/ctrl.v $
 * 
 * 8     4/06/00 10:55a Jan
 * polish
 */

// Instruction fields, ref.: The xr16 Specifications (doc/xspecs.pdf).

// Opcodes (IR[15:12])
`define ADD		4'h0
`define SUB		4'h1
`define	ADDI	4'h2
`define	RR		4'h3
`define RI		4'h4
`define LW		4'h5
`define LB		4'h6
`define SW		4'h8
`define SB		4'h9
`define JAL		4'hA
`define Bcond	4'hB
`define CALL	4'hC
`define IMM		4'hD

// Functions (IR[7:4])
`define AND		4'h0
`define OR		4'h1
`define XOR		4'h2
`define ANDN	4'h3
`define ADC		4'h4
`define SBC		4'h5
`define SRL		4'h6
`define SRA		4'h7
`define	SLL		4'h8

// Conditional branches (IR[11:8])
`define BR		4'h0
`define BRN		4'h1
`define	BEQ		4'h2
`define	BNE		4'h3
`define	BC		4'h4
`define	BNC		4'h5
`define	BV		4'h6
`define	BNV		4'h7
`define	BLT		4'h8
`define	BGE		4'h9
`define	BLE		4'hA
`define BGT		4'hB
`define	BLTU	4'hC
`define	BGEU	4'hD
`define	BLEU	4'hE
`define	BGTU	4'hF

`define INT		16'hAE01	// int ::= jal r14,10(r0)

module control(
	clk, rst, rdy, int_req, dma_req, zerodma, insn, a15, z, n, co, v,
	mem_ce, word_nxt, read_nxt, dbus_nxt, dma,
	rf_we, rna, rnb,
	fwd, imm, sextimm4, zextimm4, wordimm4, imm12, pipe_ce, b15_4_ce,
	add, ci, logicop, sri,
	sum_t, logic_t, shl_t, shr_t, zeroext_t, ret_t,
	branch, brdisp, selpc, zeropc, dmapc, pc_ce, ret_ce);

	parameter		W	= 16;	// data word width
	parameter		N	= W-1;	// msb index
	parameter		IW	= 16;	// instruction word width
	parameter		IN	= 15;	// instruction word msb index

	// ports
	input			clk;		// global clock
	input			rst;		// global async reset
	input			rdy;		// current memory access is ready
	input			int_req;	// interrupt request
	input			dma_req;	// DMA request
	input			zerodma;	// zero DMA counter request
	input	[IN:0]	insn;		// new instruction word
	input			a15;		// A operand msb
	input			z;			// zero result condition code
	input			n;			// negative result condition code
	input			co;			// carry-out result codition code
	input			v;			// oVerflow result condition code
	output			mem_ce;		// memory access clock enable
	output			word_nxt;	// next access is word wide
	output			read_nxt;	// next access is read
	output			dbus_nxt;	// next access uses on-chip data bus
	output			dma;		// current access is a DMA transfer
	output			rf_we;		// register file write enable
	output	[3:0]	rna;		// register file port A register number
	output	[3:0]	rnb;		// register file port B register number
	output			fwd;		// forward result bus into A operand register
	output	[11:0]	imm;		// 12-bit immediate field
	output			sextimm4;	// sign-extend 4-bit immediate operand
	output			zextimm4;	// zero-extend 4-bit immediate operand
	output			wordimm4;	// word-offset 4-bit immediate operand
	output			imm12;		// 12-bit immediate operand
	output			pipe_ce;	// pipeline clock enable
	output			b15_4_ce;	// b[15:4] clock enable
	output			add;		// 1 => A + B; 0 => A - B
	output			ci;			// carry-in
	output [1:0]	logicop;	// logic unit opcode
	output			sri;		// shift right msb input
	output			sum_t;		// active low adder output enable
	output			logic_t;	// active low logic unit output enable
	output			shl_t;		// active low shift left output enable
	output			shr_t;		// active low shift right output enable
	output			zeroext_t;	// active low zero-extension output enable
	output			ret_t;		// active low return address output enable
	output			branch;		// branch taken
	output [7:0]	brdisp;		// 8-bit branch displacement
	output			selpc;		// address mux selects next PC
	output			zeropc;		// force next PC to 0
	output			dmapc;		// use DMA register in PC register file
	output			pc_ce;		// PC clock enable
	output			ret_ce;		// return address clock enable
	reg				add, ci, branch;
	reg				sum_t, logic_t, shl_t, shr_t, zeroext_t, ret_t;

	// locals
	reg [IN:0]	if_ir, ir, ex_ir;	// instruction registers

	// IR fields
	wire [3:0]	op		= ir[15:12];	// opcode
	wire [3:0]	rd		= ir[11:8];		// destination register
	wire [3:0]	ra		= ir[7:4];		// source register A
	wire [3:0]	rb		= ir[3:0];		// source register B
	wire [3:0]	cond	= ir[11:8];		// branch condition
	wire [3:0]	fn		= ir[7:4];		// rr or ri function sub-opcode
	wire [3:0]	ex_op	= ex_ir[15:12];	// EX stage opcode
	wire [3:0]	ex_rd	= ex_ir[11:8];	// EX stage destination register
	wire [3:0]	ex_fn	= ex_ir[7:4];	// EX stage function sub-opcode
	assign		imm		= ir[11:0];		// 12-bit immediate field
	assign		brdisp	= ex_ir[7:0];	// 8-bit branch displacement

	// IF stage instruction decoding
	assign imm12	= op==`CALL || op==`IMM;
	assign sextimm4	= op==`ADDI || op==`RI;
	assign zextimm4	= op==`LB || op==`SB;
	assign wordimm4 = op==`LW || op==`SW || op==`JAL;
	wire addsub		= op==`ADD || op==`SUB || op==`ADDI;
	wire call		= op==`CALL;
	wire st			= op==`SW || op==`SB;
	wire rrri		= op==`RR || op == `RI;
	wire adcsbc		= rrri && (fn==`ADC || fn==`SBC);
	wire dcintinh	= op==`ADD || op==`SUB || op==`ADDI || op==`Bcond ||
					  op==`CALL || op==`IMM || adcsbc;
	wire sub		= op==`SUB || (rrri && (fn==`SBC));

	// EX stage decoding
	wire ex_ldst	= ex_op==`LW || ex_op==`LB || ex_op==`SW || ex_op==`SB;
	wire ex_lbsb	= ex_op==`LB || ex_op==`SB;
	wire ex_results	= ex_op==`ADD || ex_op==`SUB || ex_op==`ADDI ||
					  ex_op==`RR || ex_op==`RI ||
					  ex_op==`LW || ex_op==`LB || ex_op==`JAL || ex_op==`CALL;
	wire ex_jump	= (ex_op==`JAL || ex_op==`CALL);
	reg  ex_call;	// EX stage call
	reg  ex_st;		// EX stage store

	// memory access FSM states -- each access is an instruction fetch,
	// unless DMA or load/store is pending
	reg  ifetch;	// "current access is insn fetch"
	reg  dma;		// "current access is DMA"
					// "current access is load/store" ::= ~(ifetch|dma)
	// annul FSM states
	reg  sync_reset; // synchronous memory FSM reset
	reg  dc_annul;	// annul DC stage instruction
	reg  ex_annul;	// annul EX stage instruction

	// interrupt state
	reg  int_pend;	// interrupt is pending
	reg  dc_int;	// DC stage instruction is int
	wire if_int;	// IF stage 'interrupt in progress'

	// DMA state
	reg	 dma_pend;	// DMA is pending
	reg  zero_pend;	// zero (reset) DMA is pending

	// memory access FSM transitions:
	// case (state)
	//   IF:  state_nxt = dma_pend ? DMA : ldst_pend ? LS : IF;
	//   DMA: state_nxt =                  ldst_pend ? LS : IF;
	//   LS:  state_nxt =                                   IF;
	// endcase
	wire ldst_pend	= ex_ldst & ~ex_annul;
	wire if_nxt		= ifetch&~dma_pend&~ldst_pend | dma&~ldst_pend |
					  ~ifetch&~dma;
	wire dma_nxt	= ifetch&dma_pend;
	wire ldst_nxt	= ifetch&~dma_pend&ldst_pend | dma&ldst_pend;

	wire jump		= ex_jump && ~ex_annul;
	wire exannul_nxt= sync_reset | branch | jump | dc_annul;

	// FSM output decodes
	assign mem_ce	= rdy;
	assign pipe_ce	= rdy&if_nxt;
	assign pc_ce	= rdy&(if_nxt|dma_nxt);
	assign ret_ce	= rdy&if_nxt&~dc_int;
	assign word_nxt	= ~(ldst_nxt&ex_lbsb);
	assign read_nxt	= ~(ldst_nxt&ex_st);
	assign dbus_nxt	= ldst_nxt;
	assign dmapc	= dma_nxt;
	assign selpc	= if_nxt&~jump | dma_nxt;
	assign zeropc	= (zero_pend&dma_nxt) | sync_reset;
	assign if_int	= int_pend&~branch&~jump&~dcintinh;

	// IR clocking
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			if_ir <= 0;
			ir <= 0;
			ex_ir <= 0;
		end
		else begin
			if (ifetch && rdy)
				if_ir <= insn;
			if (pipe_ce) begin
				ir <= (if_int) ? `INT : (ifetch) ? insn : if_ir;
				ex_ir <= ir;
			end
		end
	end

	// instruction decode clocking
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			ex_call <= 0;
			ex_st <= 0;
		end
		else if (pipe_ce) begin
			ex_call <= call;
			ex_st <= st;
		end
	end

	// memory access FSM clocking
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			ifetch <= 1;
			dma <= 0;
		end
		else if (rdy) begin
			ifetch <= if_nxt;
			dma <= dma_nxt;
		end
	end

	// annul states clocking
	always @(posedge clk or posedge rst) begin
		if (rst)
			sync_reset <= 1;
		else if (rdy)
			sync_reset <= 0;
	end
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			dc_annul <= 1;
			ex_annul <= 1;
		end
		else if (pipe_ce) begin
			dc_annul <= sync_reset | branch | jump;
			ex_annul <= exannul_nxt;
		end
	end

	// DMA request clocking
	always @(posedge clk or posedge rst) begin
		if (rst)
			dma_pend <= 0;
		else if (dma_req)
			dma_pend <= 1;
		else if (dma)
			dma_pend <= 0;
	end
	always @(posedge clk or posedge rst) begin
		if (rst)
			zero_pend <= 0;
		else if (zerodma)
			zero_pend <= 1;
		else if (dma)
			zero_pend <= 0;
	end

	// interrupt request clocking
	always @(posedge clk or posedge rst) begin
		if (rst)
			int_pend <= 0;
		else if (int_req)
			int_pend <= 1;
		else if (if_int && pipe_ce)
			int_pend <= 0;
	end
	always @(posedge clk or posedge rst) begin
		if (rst)
			dc_int <= 0;
		else if (pipe_ce)
			dc_int <= if_int;
	end

	// DC stage operand selection
	wire [3:0]	rsrc 	= call ? 0 : rrri ? rd : ra;
	wire [3:0]	rdest	= ex_call ? 15 : ex_rd;
	assign		rna		= clk ? rsrc : rdest;
	assign		rnb		= clk ? (st ? rd : rb) : (ex_call ? 15 : ex_rd);
	assign		rf_we	= ex_results & pipe_ce & ~ex_annul & (rdest != 0);
	assign		fwd		= (rsrc==rdest) & (rdest!=0) && ex_results & ~ex_annul;
	assign		b15_4_ce= pipe_ce && ~(ex_op==`IMM && ~ex_annul);

	// DC stage conditional branches
	reg taken;
	always @(posedge clk or posedge rst) begin
		if (rst)
			branch = 0;
		else if (pipe_ce) begin
			case (cond)
			`BR:   taken = 1;
			`BRN:  taken = 0;
			`BEQ:  taken = z;
			`BNE:  taken = ~z;
			`BC:   taken = co;
			`BNC:  taken = ~co;
			`BV:   taken = v;
			`BNV:  taken = ~v;
			`BLT:  taken = n^v;
			`BGE:  taken = ~(n^v);
			`BLE:  taken = (n^v)|z;
			`BGT:  taken = ~((n^v)|z);
			`BLTU: taken = ~z&~co;
			`BGEU: taken = z|co;
			`BLEU: taken = z|~co;
			`BGTU: taken = ~z&co;
			endcase
			branch = op==`Bcond && taken && ~exannul_nxt;
		end
	end

	// EX stage ALU control
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			add <= 1;
			ci <= 0;
		end
		else if (pipe_ce) begin
			add <= ~sub;
			ci <= sub ^ (adcsbc & co);
		end
	end
	assign	logicop	= ex_ir[5:4];
	assign	sri		= ex_fn==`SRA && a15;

	// EX stage result multiplexer control
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			sum_t	<= 1;
			logic_t	<= 1;
			zeroext_t <= 1;
			shr_t	<= 1;
			shl_t	<= 1;
			ret_t	<= 1;
		end
		else if (pipe_ce) begin
			sum_t	<= ~(addsub || adcsbc);
			logic_t	<= ~(rrri&& (fn==`AND || fn==`OR || fn==`XOR || fn==`ANDN));
			zeroext_t <= ~(op==`LB);
			shr_t	<= ~(rrri && (fn==`SRL || fn==`SRA));
			shl_t	<= ~(rrri && fn==`SLL);
			ret_t	<= ~(op==`JAL || op==`CALL);
		end
	end

endmodule
