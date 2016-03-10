import lc3b_types::*;

module if_block
(
   input clk,
	input stall;
	input lc3b_word pc_in,
	input lc3b_word ir_in,
	input lc3b_word mem_rdata_0,
	
	output lc3b_word mem_address_0,
	output logic mem_read_0,
	output lc3b_word r1_out,
	output lc3b_word r2_out,
	output lc3b_word ir_out,
	output lc3b_word pc_out
);

register ir_reg 
(
	.clk,
	.load(~stall),
	.in(ir_in),
	.out(ir_out)
);
register pc_reg
(
	.clk,
	.load(~stall),
	.in(pc_val_out),
	.out(pc_out)
);


endmodule : if_block
