import lc3b_types::*;

module mp3
(
    input clk,

    /* Memory signals */
    output logic read_a,
    output logic write_a,
    output logic [1:0] wmask_a,
    output logic [15:0] address_a,
    output logic [15:0] wdata_a,
    input resp_a,
    input [15:0] rdata_a,

    /* Port B */
    output logic read_b,
    output logic write_b,
    output logic [1:0] wmask_b,
    output logic [15:0] address_b,
    output logic [15:0] wdata_b,
    input resp_b,
    input [15:0] rdata_b
);
logic stall;
lc3b_word 	mem_address_0, mem_address_1,
				mem_wdata_0, mem_wdata_1;
logic mem_read_0, mem_read_1,
		mem_write_0, mem_write_1;
		
datapath datapath_obj(.*, 
							 .mem_rdata_0(rdata_a), 
							 .mem_rdata_1(rdata_b),
							 .mem_resp_0(resp_a),
							 .mem_resp_1(resp_b));
assign stall = 0;

assign read_a = mem_read_0;
assign read_b = mem_read_1;
assign write_a = mem_write_0;
assign write_b = mem_write_1;

assign wmask_a = 2'b11;
assign wmask_b = 2'b11;

assign address_a = mem_address_0;
assign address_b = mem_address_1;
assign wdata_a = mem_wdata_0;
assign wdata_b = mem_wdata_1;

	  


endmodule : mp3
