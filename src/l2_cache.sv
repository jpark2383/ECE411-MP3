import lc3b_types::*;

module l2_cache
(
	input clk,

	input lc3b_word mem_address,
	input lc3b_cache_line mem_wdata,
	input mem_read,
	input mem_write,
		 
	input lc3b_cache_line pmem_rdata,
	input pmem_resp,

	output lc3b_cache_line mem_rdata,
	output logic mem_resp,

	output lc3b_word pmem_address,
	output lc3b_cache_line pmem_wdata,
	output logic pmem_read,
	output logic pmem_write,
	output lc3b_word l2_miss,
	output lc3b_word l2_total
);	

lc3b_c2_tag tag;
lc3b_c2_index index;

assign tag = mem_address[15:7];
assign index = mem_address[6:4];

logic hit, full, dirty;
logic write, dirty_in, valid_in;
logic pseudoarray_load;
logic pmem_addressmuxsel;
logic wdatamux_sel;

l2_cache_control controller
(
	 .*
);

l2_cache_datapath datapath
(
	 .*
);

logic total_counter, miss_counter;
initial begin
	l2_miss = 0;
	l2_total = 0;
end

always_comb begin
	total_counter = 0;
	miss_counter = 0;

	if(mem_resp == 1 || pmem_resp == 1)
		total_counter = 1;
	if(pmem_resp == 1)
		miss_counter = 1;
end

always_ff @(posedge clk) begin
	l2_total = l2_total + total_counter;
	l2_miss = l2_miss + miss_counter;
end

endmodule : l2_cache