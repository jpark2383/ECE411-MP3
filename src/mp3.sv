import lc3b_types::*;

module mp3
(
    input clk,

    /* pmem signals */
	input pmem_resp,
	input lc3b_cache_line pmem_rdata,
	output lc3b_word pmem_address,
	output logic pmem_read,
	output logic pmem_write,
	output lc3b_cache_line pmem_wdata
);

lc3b_word mem_address_0, mem_address_1,
			mem_wdata_0, mem_wdata_1;
logic mem_read_0, mem_read_1,
		mem_write_0, mem_write_1;

logic resp_a;
logic [15:0] rdata_a;
logic resp_b;
logic [15:0] rdata_b;
		
logic [1:0] mem_byte_enable;

lc3b_word l2_address;
lc3b_cache_line l2_wdata;
lc3b_cache_line l2_rdata;
logic l2_mem_resp;
logic l2_read;
logic l2_write;

lc3b_word cpu_address;
		
datapath datapath_obj(.*, 
							 .mem_rdata_0(rdata_a), 
							 .mem_rdata_1(rdata_b),
							 .mem_resp_0(resp_a),
							 .mem_resp_1(resp_b));


logic l2_dirty_in;
logic l2_dirty_out;

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
	.l2_write,
	.l2_dirty_in,
	.l2_dirty_out,
	.cpu_address
);

/* WITHOUT L2 CACHE  
victim_cache victim_cache_obj
(
	.clk,
	.tag(cpu_address[15:4]),
	.l1_wdata(l2_wdata),
	.l1_write(l2_write), 
	.l1_read(l2_read),
	.l1_tag(l2_address[15:4]),
	.dirty_in(l2_dirty_out),
	.l1_rdata(l2_rdata),
	.l1_dirty(l2_dirty_in),
	.mem_resp(l2_mem_resp),
	.l2_rdata(pmem_rdata),
	.l2_mem_resp(pmem_resp),
	.l2_address(pmem_address),
	.l2_wdata(pmem_wdata),
	.l2_write(pmem_write), 
	.l2_read(pmem_read)
);
*/

/* WITH L2 CACHE  */
lc3b_cache_line rdata, wdata;
logic w, r, resp;
lc3b_word addr;

victim_cache victim_cache_obj
(
	.clk,
	.tag(cpu_address[15:4]),
	.l1_wdata(l2_wdata),
	.l1_write(l2_write), 
	.l1_read(l2_read),
	.l1_tag(l2_address[15:4]),
	.dirty_in(l2_dirty_out),
	.l1_rdata(l2_rdata),
	.l1_dirty(l2_dirty_in),
	.mem_resp(l2_mem_resp),
	.l2_rdata(rdata),
	.l2_mem_resp(resp),
	.l2_address(addr),
	.l2_wdata(wdata),
	.l2_write(w),
	.l2_read(r)
);

l2_cache l2_cache_obj
(
	.clk,
	.mem_address(addr),
	.mem_wdata(wdata),
	.mem_read(r),
	.mem_write(w),
	.pmem_rdata,
	.pmem_resp,
	.mem_rdata(rdata),
	.mem_resp(resp),
	.pmem_address,
	.pmem_wdata,
	.pmem_read,
	.pmem_write
);

endmodule : mp3
