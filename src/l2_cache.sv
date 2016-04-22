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
	 output pmem_write,
	 output lc3b_word l2_miss,
	 output lc3b_word l2_total
);	

lc3b_c2_tag tag;
lc3b_c2_index index;
lc3b_c2_offset offset;

assign tag = mem_address[15:10];
assign index = mem_address[9:4];
assign offset = mem_address[3:0];

logic dirty0_write;
logic dirty0_in;
logic valid0_write;
logic valid0_in;
logic tag0_write;
logic data0_write;
 
logic dirty1_write;
logic dirty1_in;
logic valid1_write;
logic valid1_in;
logic tag1_write;
logic data1_write;

logic lru_write;

logic datawritemux_sel;
 
logic hit, full;
logic valid0, valid1;
logic lru;
logic dirty0, dirty1;
logic pmem_addressmux_sel;

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