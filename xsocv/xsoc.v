/* xsoc.v -- XSOC System-on-a-Chip synthesizable Verilog model
 *
 * Copyright (C) 1999, 2000, Gray Research LLC.  All rights reserved.
 * The contents of this file are subject to the XSOC License Agreement;
 * you may not use this file except in compliance with this Agreement.
 * See the LICENSE file.
 *
 * $Header: /dist/xsocv/xsoc.v 8     4/06/00 10:55a Jan $
 * $Log: /dist/xsocv/xsoc.v $
 * 
 * 8     4/06/00 10:55a Jan
 * polish
 */ 

module xsoc(
	clk, rst, par_d, par_s, r, g, b, hsync_n, vsync_n,
	ram_ce_n, ram_oe_n, ram_we_n, res8031, xa, xa_0, xd);

	parameter		W	= 16;	// word width
	parameter		N	= W-1;	// msb index
	parameter		XAN	= 16;	// external address msb index

	// ports
	input			clk;		// global clock
	input			rst;		// global async reset
	input	[4:0]	par_d;		// parallel port data in
	output	[6:3]	par_s;		// parallel port status out
	output	[1:0]	r, g, b;	// (red, green, blue) outputs
	output			hsync_n;	// active low horizontal sync output
	output			vsync_n;	// active low vertical sync output
	output			ram_ce_n;	// active low external RAM chip enable
	output			ram_oe_n;	// active low external RAM output enable
	output			ram_we_n;	// active low external RAM write enable
	output			res8031;	// reset external 8031 MCU
	output	[XAN:0]	xa;			// external RAM address bus
	reg		[XAN:0]	xa;
	output			xa_0;		// external RAM address lsb
	inout	[7:0]	xd;			// external RAM data bus
	tri		[7:0]	xd;

	// locals
	wire [N:0]	addr_nxt;	// address of next memory access
	wire [N:0]	d;			// on-chip data bus
	wire		mem_ce;		// memory access clock enable
	wire		word_nxt;	// next access is word wide
	wire		read_nxt;	// next access is read
	wire		dbus_nxt;	// next access uses on-chip data bus
	wire		dma;		// current access is a DMA transfer
	wire		int_req;	// interrupt request
	wire		dma_req;	// DMA request
	wire		zerodma;	// zero DMA counter request
	wire		rdy;		// current memory access is ready
	wire		ud_t;		// active low store data MSB output enable
	wire		ld_t;		// active low store data LSB output enable
	wire		udlt_t;		// active low store data MSB->LSB output enable
	wire		vreq;		// video word DMA request
	wire		vreset;		// video word address counter reset
	wire		vack;		// video DMA acknowledge
	wire [7:0]	sel;		// on-chip peripheral select
	wire [15:0]	ctrl;		// abstract control bus
	reg  [7:0]	xdq;		// RAM external data half-cycle capture register

	// submodules
	xr16 p(
		.clk(clk), .rst(rst), .rdy(rdy),
		.ud_t(ud_t), .ld_t(ld_t), .udlt_t(udlt_t),
		.int_req(int_req), .dma_req(dma_req), .zerodma(zerodma),
		.insn({xdq,xd}), .mem_ce(mem_ce),
		.word_nxt(word_nxt), .read_nxt(read_nxt), .dbus_nxt(dbus_nxt),
		.dma(dma), .addr_nxt(addr_nxt), .d(d));

	memctrl mc(
		.clk(clk), .rst(rst),
		.mem_ce(mem_ce), .word_nxt(word_nxt), .read_nxt(read_nxt),
		.dbus_nxt(dbus_nxt), .dma(dma), .addr_nxt(addr_nxt),
		.dma_req_in(vreq), .zero_req_in(vreset),
		.rdy(rdy), .ud_t(ud_t), .ld_t(ld_t), .udlt_t(udlt_t),
		.int_req(int_req), .dma_req(dma_req), .zerodma(zerodma),
		.ram_oe_n(ram_oe_n), .ram_we_n(ram_we_n), .xa_0(xa_0),
		.xdout_t(xdout_t), .uxd_t(uxd_t), .lxd_t(lxd_t),
		.sel(sel), .ctrl(ctrl), .dma_ack(vack));

	vga vga(
		.clk(clk), .rst(rst), .vack(vack), .pixels_in({xdq,xd}),
	    .vreq(vreq), .vreset(vreset),
		.hsync_n(hsync_n), .vsync_n(vsync_n), .r(r), .g(g), .b(b));

	// External RAM interface
	always @(posedge clk or posedge rst) begin
		if (rst)
			xa <= 0;
		else if (mem_ce)
			xa[16:0] <= {1'b0, addr_nxt[15:0]};	// use low 64 KB of SRAM
	end
	always @(negedge clk or posedge rst) begin
		if (rst)
			xdq <= 0;
		else
			xdq <= xd;
	end
	assign	xd		= xdout_t ? 8'bz : d[7:0];
	assign	d[7:0]	= lxd_t ? 8'bz : xd;
	assign	d[15:8]	= uxd_t ? 8'bz : xdq;
	assign	ram_ce_n	= 0;
	assign	res8031	= 1;

	// On-chip peripherals
	xram16x16 iram(
		.clk(clk), .rst(rst), .ctrl(ctrl), .sel(sel[0]), .d(d));

	xin8 parin(
		.clk(clk), .rst(rst), .ctrl(ctrl), .sel(sel[1]), .d(d[7:0]),
		.i({3'b0,par_d}));

	xout4 parout(
		.clk(clk), .rst(rst), .ctrl(ctrl), .sel(sel[2]), .d(d[3:0]),
		.q(par_s));

endmodule
