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
	output pmem_read,
	output pmem_write
);	

lc3b_c2_tag tag;
lc3b_c2_index index;

assign tag = mem_address[15:7];
assign index = mem_address[6:4];

logic hit, full, dirty;
logic write, dirty_in, valid_in;
logic pseudoarray_load;
logic pmem_addressmuxsel;

l2_cache_control controller
(
	 .*
);

l2_cache_datapath datapath
(
	 .*
);

endmodule : l2_cache
