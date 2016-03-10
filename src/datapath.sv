import lc3b_types::*;

module datapath
(
    input clk,
    input stall,
	input mem_resp_0, mem_resp_1,
	input lc3b_word mem_rdata_0, mem_rdata_1,

	output lc3b_word mem_address_0,
	output lc3b_word mem_address_1,
	output logic mem_read_0, mem_read_1,
);

lc3b_word 	pc_out,
			ir_out;
lc3b_control_word 	gen_ctrl_out,
					id_ctrl_out,
   					ex_ctrl_out, 
					wb_ctrl_out;
assign mem_address_0 = pc_out;

regfile

// Control State and Registers
control_rom gen_ctrl
(
	.opcode(ir_out[15:12]),
	.ctrl(gen_ctrl_out)
);

register #(.width=$(bits(lc3b_control_word))) id_control
(
	.clk,
	.load(~stall),
	.in(gen_ctrl_out),
	.out(id_ctrl_out)
);

register #(.width=$(bits(lc3b_control_word))) ex_control
(
	.clk,
	.load(~stall),
	.in(id_ctrl_out),
	.out(ex_ctrl_out)
);

register #(.width=$(bits(lc3b_control_word))) wb_control
(
	.clk,
	.load(~stall),
	.in(ex_ctrl_out),
	.out(wb_ctrl_out)
);

// PC
lc3b_word pc_mux_out, pc_adder_out;
register pc
(
	.clk,
	.load(~stall),
	.in(pc_mux_out),
	.out(pc_out),
);
adder2 pc_adder
(
	.a(pc_out),
	.b(16'd4),
	.sel(pc_adder_out)
);
mux2 pc_mux 
(
	.sel(pc_sel),
	.a(pc_adder_out),
	.b(16'b0),
	.f(pc_mux_out)
);
register ir
(
	.clk,
	.load(~stall),
	.in(mem_rdata_0),
	.out(ir_out)
);
	


endmodule : datapath
