import lc3b_types::*;

module mp3
(
    input clk,

    /* l2 signals */
	 input l2_mem_resp,
	 input lc3b_cache_line l2_rdata,
	 output lc3b_word l2_address,
	 output logic l2_read,
	 output logic l2_write,
	 output lc3b_cache_line l2_wdata
	 
);

lc3b_word 	mem_address_0, mem_address_1,
				mem_wdata_0, mem_wdata_1;
logic mem_read_0, mem_read_1,
		mem_write_0, mem_write_1;

logic resp_a;
logic [15:0] rdata_a;
logic resp_b;
logic [15:0] rdata_b;
		
logic [1:0] mem_byte_enable;
		
datapath datapath_obj(.*, 
							 .mem_rdata_0(rdata_a), 
							 .mem_rdata_1(rdata_b),
							 .mem_resp_0(resp_a),
							 .mem_resp_1(resp_b));
							 
l1_cache l1_cache_obj
(
	.clk,
	.icache_mem_address(mem_address_0),
	.icache_mem_wdata(mem_wdata_0),
	.icache_mem_read(mem_read_0),
	.icache_mem_write(mem_write_0),
	.icache_mem_byte_enable(2'b11),
	.icache_mem_resp(resp_a),
	.icache_mem_rdata(rdata_a),
	.dcache_mem_address(mem_address_1),
	.dcache_mem_wdata(mem_wdata_1),
	.dcache_mem_read(mem_read_1),
	.dcache_mem_write(mem_write_1),
	.dcache_mem_byte_enable(mem_byte_enable),
	.dcache_mem_resp(resp_b),
	.dcache_mem_rdata(rdata_b),
	.l2_rdata,
	.l2_mem_resp,
	.l2_address,
	.l2_wdata,
	.l2_read,
	.l2_write
);



endmodule : mp3
