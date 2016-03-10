import lc3b_types::*;

module if_block
(
   input clk,
	input stall;
	input lc3b_word pc_in,
	input lc3b_word ir_in,
	
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
	.in
);


endmodule : if_block
