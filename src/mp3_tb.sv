import lc3b_types::*;

module mp3_tb;

timeunit 1ns;
timeprecision 1ns;

logic clk;

logic l2_mem_resp;
lc3b_cache_line l2_rdata;
lc3b_word l2_address;
logic l2_read;
logic l2_write;
lc3b_cache_line l2_wdata;

/* Clock generator */
initial clk = 0;
always #5 clk = ~clk;

mp3 dut(.*);

physical_memory memory
(
	.clk,
	.read(l2_read),
	.write(l2_write),
	.address(l2_address),
	.wdata(l2_wdata),
	.resp(l2_mem_resp),
	.rdata(l2_rdata)
);

endmodule : mp3_tb
