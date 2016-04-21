import lc3b_types::*;

module cache
(
	 input clk,
	
	 input lc3b_word mem_address,
	 input lc3b_word mem_wdata,
	 input mem_read,
	 input mem_write,
	 input lc3b_mem_wmask mem_byte_enable,
	 
	 input lc3b_word i_miss,
	 input lc3b_word i_total,
	 input lc3b_word l2_miss,
	 input lc3b_word l2_total,	 

	 input lc3b_cache_line pmem_rdata,
	 input pmem_resp,
	 
	 output lc3b_word mem_rdata,
	 output logic mem_resp,
	
     output lc3b_word pmem_address,
	 output lc3b_cache_line pmem_wdata,
	 output pmem_read,
	 output pmem_write,
	 output lc3b_word total_count,
	 output lc3b_word miss_count
);	

lc3b_c_tag tag;
lc3b_c_index index;
lc3b_c_offset offset;

assign tag = mem_address[15:7];
assign index = mem_address[6:4];
assign offset = mem_address[3:0];

lc3b_word temp_mem_r_data;
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

cache_control controller
(
	 .*
);

cache_datapath datapath
(
	 .clk,
	 .mem_address,
	 .tag,
	 .index,
	 .offset,
	 .mem_wdata,
	 .mem_byte_enable,
	 .pmem_rdata,
	 .pmem_addressmux_sel,
	 .dirty0_write,
	 .dirty0_in,
	 .valid0_write,
	 .valid0_in,
	 .tag0_write,
	 .data0_write,
	 .dirty1_write,
	 .dirty1_in,
	 .valid1_write,
	 .valid1_in,
	 .tag1_write,
	 .data1_write,
	 .lru_write,
	 .datawritemux_sel,
	 .mem_write,
	 .hit,
	 .full,
	 .valid0,
	 .valid1,
	 .pmem_wdata,
	 .pmem_address,
	 .mem_rdata(temp_mem_r_data),
	 .mem_resp,
	 .lru,
	 .dirty0,
	 .dirty1
);

/* cache hit/miss counters */
logic [2:0] counter_sel;
logic total_counter, miss_counter;
initial begin
	total_count = 0;
	miss_count = 0;
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
	total_count = total_count + total_counter;
	miss_count = miss_count + miss_counter;
end

always_comb begin
	if(mem_address == 16'hFFFE)
		counter_sel = 3'b000;
	else if(mem_address == 16'hFFFC)
		counter_sel = 3'b001;
	else if(mem_address == 16'hFFFA)
		counter_sel = 3'b010;
	else if(mem_address == 16'hFFF8)
		counter_sel = 3'b011;
	else if (mem_address == 16'hFFF6)
		counter_sel = 3'b100;
	else if(mem_address == 16'hFFF4)
		counter_sel = 3'b101;
	else
		counter_sel = 3'b111;
end

//{total, miss}
mux8 counter_mux
(
	.sel(counter_sel),
	.x0(l2_total),
	.x1(l2_miss),
	.x2(i_total),
	.x3(i_miss),
	.x4(total_count),
	.x5(miss_count),
	.x6(temp_mem_r_data),
	.x7(temp_mem_r_data),
	.f(mem_rdata)
);


endmodule : cache