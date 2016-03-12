import lc3b_types::*;

module datapath
(
    input clk,
    input stall,
	input mem_resp_0, mem_resp_1,
	input lc3b_word mem_rdata_0, mem_rdata_1,

	output lc3b_word mem_address_0,
	output lc3b_word mem_address_1,
	output lc3b_word mem_wdata_1,
	output logic mem_read_0, mem_read_1
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
			sext5_out,
			sext9_out,
			pc_jmp_out,
			sr2_mux_out,
			alu_out,
			sext_reg_out,
			wb_mux_out,
			pc_mux_out, 
			pc_adder_out,
			sext_mux_out,
			ex_alu_out,
			mem_data_out,
			mem_alu_out,
			ex_wdata_out;
lc3b_passed_vals  mem_passed_reg_out,
						ex_passed_reg_out,
						id_passed_reg_out,
						gen_passed_out;
lc3b_control_word 	gen_ctrl_out,
					id_ctrl_out,
   					ex_ctrl_out, 
					mem_ctrl_out;
lc3b_nzp gencc_out,
			cc_out;
logic cccomp_out;
assign mem_address_0 = pc_out;
assign mem_address_1 = ex_alu_out;
assign mem_wdata_1 = ex_wdata_out;


// Control State and Registers
control_rom gen_ctrl
(
	.opcode(lc3b_opcode'(ir_out[15:12])),
	.ctrl(gen_ctrl_out)
);
passed_rom gen_passed
(
	.ir(ir_out),
	.passed(gen_passed_out)
);

// Second block
register #(.width($bits(lc3b_control_word))) id_control
(
	.clk,
	.load(~stall),
	.in(gen_ctrl_out),
	.out(id_ctrl_out)
);
register #(.width($bits(lc3b_passed_vals))) id_passed_reg
(
	.clk,
	.load(~stall),
	.in(gen_passed_out),
	.out(id_passed_reg_out)
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
register sext_reg
(
	.clk,
	.load(~stall),
	.in(sext_mux_out),
	.out(sext_reg_out)
);
sext #(.width(5)) sext5_obj
(
	.in(ir[4:0]),
	.out(sext5_out)
);
sext #(.width(9)) sext9_obj
(
	.in(ir[8:0]),
	.out(sext9_out)
);
mux2 sext_mux
(
	.sel(gen_ctrl_out.sext_sel),
	.a(sext5_out),
	.b(sext9_out),
	.f(sext_mux_out)
);
regfile regs
(
	.clk,
	.load(mem_ctrl_out.load_regfile),
	.in(wb_mux_out),
	.src_a(ir_out[8:6]),
	.src_b(ir_out[2:0]),
	.dest(mem_passed_reg_out.dest),
	.reg_a(regfile_sr1),
	.reg_b(regfile_sr2)
);


// Third Block
register #(.width($bits(lc3b_control_word))) ex_control
(
	.clk,
	.load(~stall),
	.in(id_ctrl_out),
	.out(ex_ctrl_out)
);

register #(.width($bits(lc3b_passed_vals))) ex_passed_reg
(
	.clk,
	.load(~stall),
	.in(id_passed_reg_out),
	.out(ex_passed_reg_out)
);
register ex_wdata_reg
(
	.clk,
	.load(~stall),
	.in(sr2_out),
	.out(ex_wdata_out)
);
register ex_pc_reg
(
	.clk,
	.load(~stall),
	.in(pc_jmp_out),
	.out(ex_pc_out)
);
register ex_alu_reg
(
	.clk,
	.load(~stall),
	.in(alu_out),
	.out(ex_alu_out)
);
alu alu_obj
(
	.aluop(id_ctrl_out.aluop),
	.a(sr1_out),
	.b(sr2_mux_out),
	.f(alu_out)
);
mux2 sr2_mux
(
	.sel(id_passed_reg_out.ir_5),
	.a(sr2_out),
	.b(sext_reg_out),
	.f(sr2_mux_out)
);
adder2 pc_jmp_adder
(
	.a(sext_reg_out << 2),
	.b(id_pc_out),
	.f(pc_jmp_out)
);
gencc gencc_obj
(
	.in(alu_out),
	.out(gencc_out)
);
cccomp cccomp_obj
(
	.nzp(id_passed_reg_out.nzp),
	.cc(cc_out),
	.out(cccomp_out)
);


// Fourth Block
register #(.width($bits(lc3b_control_word))) mem_control
(
	.clk,
	.load(~stall),
	.in(ex_ctrl_out),
	.out(mem_ctrl_out)
);
register #(.width($bits(lc3b_passed_vals))) mem_passed_reg
(
	.clk,
	.load(~stall),
	.in(ex_passed_reg_out),
	.out(mem_passed_reg_out)
);
register mem_data
(
	.clk,
	.load(~stall),
	.in(mem_rdata_1),
	.out(mem_data_out)
);
register mem_alu_reg
(
	.clk,
	.load(~stall),
	.in(ex_alu_out),
	.out(mem_alu_out)
);

mux2 wb_mux
(
	.sel(mem_ctrl_out.wb_sel),
	.a(mem_alu_out),
	.b(mem_data_out),
	.f(wb_mux_out)
);

// PC
register pc
(
	.clk,
	.load(~stall),
	.in(pc_mux_out),
	.out(pc_out)
);
adder2 pc_adder
(
	.a(pc_out),
	.b(16'd4),
	.f(pc_adder_out)
);
mux2 pc_mux 
(
	.sel(mem_ctrl_out.pc_sel & cccomp_out),
	.a(pc_adder_out),
	.b(ex_pc_out),
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
