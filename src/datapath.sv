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
			ir_out,
			id_pc_out,
			ex_pc_out,
			mem_pc_out,
			regfile_sr1,
			regfile_sr2,
			sr1_out,
			sr2_out,
			sext5_out
			sext5_reg_out;
lc3b_control_word 	gen_ctrl_out,
					id_ctrl_out,
   					ex_ctrl_out, 
					mem_ctrl_out;
lc3b_reg 	id_dest_reg_out,
			ex_dest_reg_out,
			mem_reg_out;
assign mem_address_0 = pc_out;


// Control State and Registers
control_rom gen_ctrl
(
	.opcode(ir_out[15:12]),
	.ctrl(gen_ctrl_out)
);

// Second block
register #(.width=$(bits(lc3b_control_word))) id_control
(
	.clk,
	.load(~stall),
	.in(gen_ctrl_out),
	.out(id_ctrl_out)
);
register #(.width=3) id_dest_reg
(
	.clk,
	.load(~stall),
	.in(ir_out[11:9]),
	.out(id_dest_reg_out)
);
register id_pc
(
	.clk,
	.load(~stall),
	.in(pc_out),
	.out(id_pc_out)
);
register sr1
(
	.clk,
	.load(~stall),
	.in(regfile_sr1),
	.out(sr1_out)
);
register sr2
(
	.clk,
	.load(~stall),
	.in(regfile_sr2),
	.out(sr2_out)
);
register sext5_reg
(
	.clk
	.load(~stall),
	.in(sext5_out),
	.out(sext5_reg_out)
);
sext #(.width=5) sext5_obj
(
	.in(ir[4:0]),
	.out(sext5_out)
);
regfile regs
(
	.clk,
	.load(mem_ctrl_out.load_regfile),
	.in(mem_mux_out),
	.src_a(ir_out[8:6]),
	.src_b(ir_out[2:0]),
	.dest(mem_dest_reg_out),
	.reg_a(regfile_sr1),
	.reg_b(regfile_sr2),
);


// Third Block
register #(.width=$(bits(lc3b_control_word))) ex_control
(
	.clk,
	.load(~stall),
	.in(id_ctrl_out),
	.out(ex_ctrl_out)
);

register #(.width=3) ex_dest_reg
(
	.clk,
	.load(~stall),
	.in(id_dest_reg_out),
	.out(ex_dest_reg_out)
);

// Fourth Block
register #(.width=$(bits(lc3b_control_word))) mem_control
(
	.clk,
	.load(~stall),
	.in(ex_ctrl_out),
	.out(mem_ctrl_out)
);
register #(.width=3) id_dest_reg
(
	.clk,
	.load(~stall),
	.in(ex_dest_reg_out),
	.out(mem_dest_reg_out)
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
