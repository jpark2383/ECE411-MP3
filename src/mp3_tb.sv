import lc3b_types::*;

module mp3_tb;

timeunit 1ns;
timeprecision 1ns;

logic clk;

logic pmem_resp;
lc3b_cache_line pmem_rdata;
lc3b_word pmem_address;
logic pmem_read;
logic pmem_write;
lc3b_cache_line pmem_wdata;

/* Clock generator */
initial clk = 0;
always #5 clk = ~clk;

mp3 dut(.*);

physical_memory memory
(
	.clk,
	.read(pmem_read),
	.write(pmem_write),
	.address(pmem_address),
	.wdata(pmem_wdata),
	.resp(pmem_resp),
	.rdata(pmem_rdata)
);

endmodule : mp3_tb
