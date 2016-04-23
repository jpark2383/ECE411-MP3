import lc3b_types::*;

module l1_cache
(
	input clk,

	/* icache signals */
	input lc3b_word icache_mem_address,
	input lc3b_word icache_mem_wdata,
	input icache_mem_read,
	input icache_mem_write,
	input [1:0] icache_mem_byte_enable,

	output logic icache_mem_resp,
	output lc3b_word icache_mem_rdata,

	/* dcache signals */
	input lc3b_word dcache_mem_address,
	input lc3b_word dcache_mem_wdata,
	input dcache_mem_read,
	input dcache_mem_write,
	input[1:0] dcache_mem_byte_enable,

	output logic dcache_mem_resp,
	output lc3b_word dcache_mem_rdata,

	/* l2 signals */
	input lc3b_cache_line l2_rdata,
	input l2_mem_resp,
	output lc3b_word l2_address,
	output lc3b_cache_line l2_wdata,
	output logic l2_read, 
	output logic l2_write,

	input l2_dirty_in,
	output logic l2_dirty_out,
	output lc3b_word cpu_address
);

lc3b_word icache_address;
logic icache_read;
logic icache_write;
lc3b_cache_line icache_rdata, icache_wdata;
logic arb_icache_mem_resp;

logic icache_dirty_out, dcache_dirty_out;
logic dcache_dirty_in, icache_dirty_in;

cache icache
(
	.clk,
	.mem_address(icache_mem_address),
	.mem_wdata(icache_mem_wdata),
	.mem_read(icache_mem_read),
	.mem_write(icache_mem_write),
	.mem_byte_enable(icache_mem_byte_enable),
	.mem_resp(icache_mem_resp),
	.mem_rdata(icache_mem_rdata),
	.pmem_rdata(icache_rdata),
	.pmem_resp(arb_icache_mem_resp),
	.pmem_address(icache_address),
	.pmem_wdata(icache_wdata),
	.pmem_read(icache_read),
	.pmem_write(icache_write),
	.dirty_in(icache_dirty_in),
	.dirty_out(icache_dirty_out)
);

lc3b_word dcache_address;
logic dcache_read;
logic dcache_write;
lc3b_cache_line dcache_rdata, dcache_wdata;
logic arb_dcache_mem_resp;

cache dcache
(
	.clk,
	.mem_address(dcache_mem_address),
	.mem_wdata(dcache_mem_wdata),
	.mem_read(dcache_mem_read),
	.mem_write(dcache_mem_write),
	.mem_byte_enable(dcache_mem_byte_enable),
	.mem_resp(dcache_mem_resp),
	.mem_rdata(dcache_mem_rdata),
	.pmem_rdata(dcache_rdata),
	.pmem_resp(arb_dcache_mem_resp),
	.pmem_address(dcache_address),
	.pmem_wdata(dcache_wdata),
	.pmem_read(dcache_read),
	.pmem_write(dcache_write),
	.dirty_in(dcache_dirty_in),
	.dirty_out(dcache_dirty_out)
);

arbiter cache_arbiter
(
	.clk,
	.icache_address,
	.icache_read,
	.icache_write,
	.icache_wdata,
	.icache_rdata,
	.icache_mem_resp(arb_icache_mem_resp),
	.dcache_address,
	.dcache_read,
	.dcache_write,
	.dcache_wdata,
	.dcache_rdata,
	.dcache_mem_resp(arb_dcache_mem_resp),
	.l2_rdata,
	.l2_mem_resp,
	.l2_address,
	.l2_wdata,
	.l2_read,
	.l2_write,
	.icache_dirty_in,
	.icache_dirty_out,
	.dcache_dirty_in,
	.dcache_dirty_out,
	.l2_dirty_in,
	.l2_dirty_out,
	.icpu_address(icache_mem_address),
	.dcpu_address(dcache_mem_address),
	.cpu_address
);


endmodule : l1_cache
