import lc3b_types::*;

module datapath
(
  input clk,
	input mem_resp_0, mem_resp_1,
	input lc3b_word mem_rdata_0, mem_rdata_1,

	output lc3b_word mem_address_0,
	output lc3b_word mem_address_1,
	output lc3b_word mem_wdata_1,
	output logic mem_read_0, mem_read_1,
	output logic mem_write_0, mem_write_1,
	output logic [1:0] mem_byte_enable
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
			adj6_out,
			sext9_out,
			sext11_out,
			adj11_out,
			sext6_out,
			adj9_out,
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
			ex_wdata_out,
			ex_wdata_mux_out,
			lea_mux_out,
			mem_rdata_1_out,
			mem_rdata_0_out,
			jsr_mux_out,
      forward_sr1,
      forward_sr2,
		hazard_ir,
		ex_alu_reg_out;
lc3b_reg dest_mux_out;
lc3b_byte byte_mux_out;
lc3b_passed_vals  mem_passed_reg_out,
						ex_passed_reg_out,
						id_passed_reg_out,
						gen_passed_out;
lc3b_control_word gen_ctrl_out,
						id_ctrl_out,
   					ex_ctrl_out, 
						mem_ctrl_out;
logic mem_ready_0, mem_ready_1;
logic [2:0] src_b_mux_out,
				sr1_addr_out,
				sr2_addr_out;
logic stall, hazard_pc;
lc3b_nzp gencc_out,
			cc_out,
			cc_reg_out;
logic cccomp_out;
assign mem_address_0 = pc_out;
//assign mem_address_1 = ex_alu_out;
assign mem_wdata_1 = ex_wdata_out;
//assign mem_read_1 = ex_ctrl_out.mem_read;
//assign mem_write_1 = ex_ctrl_out.mem_write;
//assign mem_read_0 = 1;
assign stall = ~(mem_ready_0 & mem_ready_1);
mem_ctrl0 mem_ctrl0_obj
(
	.clk,
	.stall,
   .mem_resp(mem_resp_0),
   .mem_rdata_in(mem_rdata_0),
   .mem_rdata_out(mem_rdata_0_out),
   .mem_ready(mem_ready_0),
   .mem_read(mem_read_0)
);
mem_ctrl1 mem_ctrl1_obj
(
	.clk,
	.stall,
   .mem_resp(mem_resp_1),
	.opcode(ex_ctrl_out.opcode),
	.mem_address_in(ex_alu_out),
	.mem_address_out(mem_address_1),
   .mem_rdata_in(mem_rdata_1),
   .mem_rdata_out(mem_rdata_1_out),
   .mem_ready(mem_ready_1),
   .mem_read(mem_read_1),
	.mem_write(mem_write_1)
);

// Control State and Registers
control_rom gen_ctrl
(
	.opcode(lc3b_opcode'(ir_out[15:12])),
	.A(ir_out[5]),
	.D(ir_out[4]),
	.R(ir_out[11]),
	.ctrl(gen_ctrl_out)
);
passed_rom gen_passed
(
	.ir(ir_out),
	.passed(gen_passed_out)
);

// Second block
register #(.width($bits(lc3b_control_word ))) id_control
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
register #(.width(3)) sr1_addr
(
  .clk,
  .load(~stall),
  .in(ir_out[8:6]),
  .out(sr1_addr_out)
);
register #(.width(3)) sr2_addr
(
  .clk,
  .load(~stall),
  .in(src_b_mux_out),
  .out(sr2_addr_out)
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
	.in(ir_out[4:0]),
	.out(sext5_out)
);
adj #(.width(6)) adj6_obj
(
	.in(ir_out[5:0]),
	.out(adj6_out)
);
sext #(.width(9)) sext9_obj
(
	.in(ir_out[8:0]),
	.out(sext9_out)
);
sext #(.width(11)) sext11_obj
(
	.in(ir_out[10:0]),
	.out(sext11_out)
);
adj #(.width(11)) adj11_obj
(
	.in(ir_out[10:0]),
	.out(adj11_out)
);
sext #(.width(6)) sext6_obj
(
	.in(ir_out[5:0]),
	.out(sext6_out)
);
sext #(.width(9)) adj9_obj
(
	.in(ir_out[8:0]),
	.out(adj9_out)
);

mux8 sext_mux
(
	.sel(gen_ctrl_out.sext_sel),
	.x0(sext5_out),
	.x1(adj6_out),
	.x2(sext9_out),
	.x3(sext11_out),
	.x4({12'b0, ir_out[3:0]}),
	.x5(sext6_out),
	.x6(adj9_out),
	.x7({7'b0, ir_out[7:0], 1'b0}),
	.f(sext_mux_out)
);
mux2 #(.width(3)) src_b_mux
(
	.sel(gen_ctrl_out.src_b_mux_sel),
	.a(ir_out[2:0]),
	.b(ir_out[11:9]),
	.f(src_b_mux_out)
);

mux2 #(.width(3)) dest_mux
(
	.sel(mem_ctrl_out.dest_sel),
	.a(mem_passed_reg_out.dest),
	.b(3'b111),
	.f(dest_mux_out)
);
regfile regs
(
	.clk,
	.load(mem_ctrl_out.load_regfile),
	.in(wb_mux_out),
	.src_a(ir_out[8:6]),
	.src_b(src_b_mux_out),
	.dest(dest_mux_out),
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
mux2 ex_wdata_mux
(
	.sel(id_ctrl_out.ex_write_sel),
	.a(forward_sr2),
	.b({forward_sr2[7:0], forward_sr2[7:0]}),
	.f(ex_wdata_mux_out)
);
mux4 #(.width(2)) mem_byte_mux
(
	.sel({ex_ctrl_out.ex_write_sel, ex_alu_out[0]}),
	.a(2'b11),
	.b(2'b11),
	.c(2'b01),
	.d(2'b10),
	.f(mem_byte_enable)
);
register ex_wdata_reg
(
	.clk,
	.load(~stall),
	.in(ex_wdata_mux_out),
	.out(ex_wdata_out)
);
register ex_pc_reg
(
	.clk,
	.load(~stall),
	.in(jsr_mux_out),
	.out(ex_pc_out)
);

mux4 lea_mux
(
	.sel(id_ctrl_out.lea_mux_sel),
	.a(alu_out),
	.b(pc_jmp_out),
	.c(sext_reg_out),
	.d(id_pc_out),
	.f(lea_mux_out)
);

register ex_alu_reg
(
	.clk,
	.load(~stall),
	.in(lea_mux_out),
	.out(ex_alu_out)
);
data_forwarding forward_obj
(
  .sr1(sr1_out),
  .sr2(sr2_out),
  .wb_write(mem_ctrl_out.load_regfile),
  .ex_write(ex_ctrl_out.load_regfile),
  .sr1_addr(sr1_addr_out),
  .sr2_addr(sr2_addr_out),
  .ex_dest(ex_passed_reg_out.dest),
  .wb_dest(dest_mux_out),
  .ex_data(ex_alu_out),
  .wb_data(wb_mux_out),
  .sr1_out(forward_sr1),
  .sr2_out(forward_sr2)
);

alu alu_obj
(
	.aluop(id_ctrl_out.aluop),
	.a(forward_sr1),
	.b(sr2_mux_out),
	.f(alu_out)
);
mux2 sr2_mux
(
	.sel((!id_passed_reg_out.ir_5) && (id_ctrl_out.opcode == op_add || id_ctrl_out.opcode == op_and)),
	.a(sext_reg_out),
	.b(forward_sr2),
	.f(sr2_mux_out)
);
adder2 pc_jmp_adder
(
	.a(sext_reg_out << 1),
	.b(id_pc_out),
	.f(pc_jmp_out)
);

mux4 jsr_mux
(
	.sel(id_ctrl_out.jsr_mux_sel),
	.a(pc_jmp_out),
	.b(alu_out),
	.c(id_pc_out),
	.d(16'b0),
	.f(jsr_mux_out)
);


// Fourth Block
register mem_pc_reg
(
	.clk,
	.load(~stall),
	.in(ex_pc_out),
	.out(mem_pc_out)
);

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
	.in(mem_rdata_1_out),
	.out(mem_data_out)
);
register mem_alu_reg
(
	.clk,
	.load(~stall),
	.in(ex_alu_out),
	.out(mem_alu_out)
);
mux2 #(.width(8)) byte_mux
(
	.sel(mem_alu_out[0]),
	.a(mem_data_out[7:0]),
	.b(mem_data_out[15:8]),
	.f(byte_mux_out)
);

mux4 wb_mux
(
	.sel(mem_ctrl_out.wb_sel),
	.a(mem_alu_out),
	.b(mem_data_out),
	.c({8'b0,byte_mux_out}),
	.d(mem_pc_out),
	.f(wb_mux_out)
);
gencc gencc_obj
(
	.in(wb_mux_out),
	.out(gencc_out)
);
register #(.width(3)) cc_reg
(
	.clk,
	.load(mem_ctrl_out.load_cc),
	.in(gencc_out),
	.out(cc_reg_out)
);
cccomp cccomp_obj
(
	.nzp(ex_passed_reg_out.nzp),
	.cc(cc_reg_out),
	.out(cccomp_out)
);

// PC
register pc
(
	.clk,
	.load(~stall && hazard_pc),
	.in(pc_mux_out),
	.out(pc_out)
);
adder2 pc_adder
(
	.a(pc_out),
	.b(16'd2),
	.f(pc_adder_out)
);

logic cc;
assign cc = (~ex_ctrl_out.check_cc | cccomp_out);

mux4 pc_mux 
(
	.sel(ex_ctrl_out.pc_sel & {1'b1, cc}),
	.a(pc_adder_out),
	.b(ex_pc_out),
	.c(ex_alu_out),
	.d(mem_rdata_1_out),
	.f(pc_mux_out)
);
register ir
(
	.clk,
	.load(~stall),
	.in(hazard_ir),
	.out(ir_out)
);
hazard hazard_obj
(
  .clk,
  .ir_val(mem_rdata_0_out),
  .stall,
  .ir_out(hazard_ir),
  .pc_ld(hazard_pc)
);


endmodule : datapath
