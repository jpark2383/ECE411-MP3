import lc3b_types::*;

module cache
(
	input clk,
	
	input lc3b_word mem_address,
	input lc3b_word mem_wdata,
	input mem_read,
	input mem_write,
	input lc3b_mem_wmask mem_byte_enable,
	 
	input lc3b_cache_line pmem_rdata,
	input pmem_resp,
	 
	output lc3b_word mem_rdata,
	output logic mem_resp,
	
    output lc3b_word pmem_address,
	output lc3b_cache_line pmem_wdata,
	output pmem_read,
	output pmem_write,

	input dirty_in,
	output logic dirty_out
);	

lc3b_c_tag tag;
lc3b_c_index index;
lc3b_c_offset offset;

assign tag = mem_address[15:7];
assign index = mem_address[6:4];
assign offset = mem_address[3:0];

logic dirty0_write;
logic valid0_write;
logic valid0_in;
logic tag0_write;
logic data0_write;
 
logic dirty1_write;
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
	 .*
);

endmodule : cache