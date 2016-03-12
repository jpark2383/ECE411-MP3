import lc3b_types::*;

module mp3
(
    input clk,

    /* Memory signals */
    input pmem_resp,
    input logic[127:0] pmem_rdata,
    output pmem_read,
    output pmem_write,
    output lc3b_word pmem_address,
    output logic[127:0] pmem_wdata
);
logic stall;
lc3b_word 	mem_address_0, mem_address_1,
				mem_rdata_0, mem_rdata_1,
				mem_wdata_0, mem_wdata_1;
logic mem_resp_0, mem_resp_1,
		mem_read_0, mem_read_1,
		mem_write_0, mem_write_1;
datapath datapath_obj(.*);
	  


endmodule : mp3
