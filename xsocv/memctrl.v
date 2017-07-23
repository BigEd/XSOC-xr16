/* memctrl.v -- XSOC memory/on-chip bus controller synthesizable Verilog model
 *
 * Copyright (C) 1999, 2000, Gray Research LLC.  All rights reserved.
 * The contents of this file are subject to the XSOC License Agreement;
 * you may not use this file except in compliance with this Agreement.
 * See the LICENSE file.
 *
 * $Header: /dist/xsocv/memctrl.v 6     4/06/00 10:55a Jan $
 * $Log: /dist/xsocv/memctrl.v $
 * 
 * 6     4/06/00 10:55a Jan
 * polish
 */ 

module memctrl(
	clk, rst,
	mem_ce, word_nxt, read_nxt, dbus_nxt, dma, addr_nxt,
	dma_req_in, zero_req_in,
	rdy, ud_t, ld_t, udlt_t, int_req, dma_req, zerodma,
	ram_oe_n, ram_we_n, xa_0, xdout_t, uxd_t, lxd_t,
	sel, ctrl, dma_ack);

	parameter		W	= 16;	// word width
	parameter		N	= W-1;	// msb index
	parameter		XAN	= 16;	// external address msb index

	input			clk;		// global clock
	input			rst;		// global async reset
	input			mem_ce;		// memory access clock enable
	input			word_nxt;	// next access is word wide
	input			read_nxt;	// next access is read
	input			dbus_nxt;	// next access uses on-chip data bus
	input			dma;		// current access is a DMA transfer
	input	[N:0]	addr_nxt;	// address of next memory access
	input			dma_req_in;
	input			zero_req_in;
	output			rdy;		// current memory access is ready
	output			ud_t;		// active low store data MSB output enable
	output			ld_t;		// active low store data LSB output enable
	output			udlt_t;		// active low store data MSB->LSB output enable
	output			int_req;	// interrupt request
	output			dma_req;	// DMA request
	output			zerodma;	// zero DMA counter request
	output			ram_oe_n;	// active low external RAM output enable
	output			ram_we_n;	// active low external RAM write enable
	output			xa_0;		// external RAM address lsb
	output			xdout_t;	// active low external RAM data output enable
	output			uxd_t;		// active low external RAM MSB input output en
	output			lxd_t;		// active low external RAM LSB input output en
	output	[7:0]	sel;		// on-chip peripheral select
	output	[15:0]	ctrl;		// abstract control bus
	output			dma_ack;	// DMA ackwnowledge

	reg				uxd_t, lxd_t;

	// locals
	wire		selio	= addr_nxt[15:8] == 8'hFF;
	assign		sel[0]	= addr_nxt[7:5] == 0;
	assign		sel[1]	= addr_nxt[7:5] == 1;
	assign		sel[2]	= addr_nxt[7:5] == 2;
	assign		sel[3]	= addr_nxt[7:5] == 3;
	assign		sel[4]	= addr_nxt[7:5] == 4;
	assign		sel[5]	= addr_nxt[7:5] == 5;
	assign		sel[6]	= addr_nxt[7:5] == 6;
	assign		sel[7]	= addr_nxt[7:5] == 7;
	wire		ud_t_nxt	= ~(word_nxt & read_nxt);
	wire		ld_t_nxt	= ~read_nxt;
	wire		ud_ce_nxt	= word_nxt & ~read_nxt;
	wire		ld_ce_nxt	= ~read_nxt;
	reg [4:0]	addr;	// current access address
	reg			word;	// current access is word wide
	reg			read;	// current access is read
	reg			io;		// current access is to I/O space

	// memory / I/O access FSM
	reg			ramrd;	// RAM read access
	reg			ramwr;	// RAM write access
	reg			w12;	// RAM write half-clock states W1, W2
	reg			w34;	// RAM write half-clock states W3, W4
	reg			w56;	// RAM write half-clock states W5, W6
	reg			w23_45;	// RAM write half-clock states W2, W3, and W4, W5
	reg			w45;	// RAM write half-clock states W4, W5

	assign		rdy		= (io&ctrl[0]) | ramrd | (w34&~word) | w56;
	assign		ctrl	= {4'b0, ud_t_nxt, ld_t_nxt, ud_ce_nxt, ld_ce_nxt,
						   mem_ce, selio, addr[4:0], 1'b1};
						  // ctrl[0] pullup?
						  
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			addr <= 0;
			word <= 1;
			read <= 1;
			io <= 0;
			ramrd <= 1;
			ramwr <= 0;
			w12 <= 0;
			w34 <= 0;
			w56 <= 0;
			uxd_t <= 1;
			lxd_t <= 1;
		end
		else begin
			if (mem_ce) begin
				addr <= addr_nxt[4:0];
				word <= word_nxt;
				read <= read_nxt;
				io <= selio;
				ramrd <= read_nxt & ~selio;
				ramwr <= ~read_nxt & ~selio;
				uxd_t <= ~(read_nxt & dbus_nxt & ~selio & word_nxt);
				lxd_t <= ~(read_nxt & dbus_nxt & ~selio);
			end
			w12 <= ~read_nxt & ~selio & mem_ce;
			w34 <= w12;
			w56 <= w34 & word;
		end
	end
	always @(negedge clk or posedge rst) begin
		if (rst) begin
			w23_45 <= 0;
			w45 <= 0;
		end
		else begin
			w23_45 <= w12 | (w34 & word);
			w45 <= w34 & word;
		end
	end

	assign xdout_t	= ~(w23_45 | w56);
	assign ram_we_n	= ~(w23_45 & ~w34);
	assign ram_oe_n	= ramwr;
	assign xa_0		= word ? ~(ramwr ? (w45|w56) : clk) : addr[0];
	assign udlt_t	= ~((w45|w56) & ~read);
	assign ld_t		= ~(~(w45|w56) & ~read);
	assign ud_t		= read;
	assign dma_req	= dma_req_in;
	assign zerodma	= zero_req_in;
	assign dma_ack	= dma & rdy;
	assign int_req	= 0;

endmodule


// ctrl_dec -- XSOC abstract control bus decoder

module ctrl_dec(clk, rst, ctrl, sel, ud_t, ld_t, ud_ce, ld_ce, addr);
	input			clk;		// global clock
	input			rst;		// global async reset
	input	[15:0]	ctrl;		// abstract control bus
	input			sel;		// peripheral select
	output			ud_t;		// active low read data MSB output enable
	output			ld_t;		// active low read data LSB output enable
	output			ud_ce;		// write data MSB clock enable
	output			ld_ce;		// write data LSB clock enable
	output	[4:0]	addr;		// current I/O control register address

	reg				ud_t, ld_t, ud_ce, ld_ce;

	// locals
	wire		ud_t_nxt, ld_t_nxt, ud_ce_nxt, ld_ce_nxt, mem_ce, selio;
	wire [4:0]	addr;

	assign { ud_t_nxt, ld_t_nxt, ud_ce_nxt, ld_ce_nxt, mem_ce, selio, addr }
		= ctrl[11:1];

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			ud_ce <= 0;
			ld_ce <= 0;
			ud_t <= 1;
			ld_t <= 1;
		end
		else if (mem_ce) begin
			ud_ce <= sel & selio & ud_ce_nxt;
			ld_ce <= sel & selio & ld_ce_nxt;
			ud_t <= ~(sel & selio & ~ud_t_nxt);
			ld_t <= ~(sel & selio & ~ld_t_nxt);
		end
	end

endmodule

