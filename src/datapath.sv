import lc3b_types::*;

module datapath
(
    input clk,

    /* control signals */
    input[1:0] pcmux_sel,
    input load_pc,
	 input storemux_sel,
	 input destmux_sel,
	 input rbytemux_sel,
	 input[1:0] regfilemux_sel,
	 
	 input load_cc,
	 
	 input[1:0] marmux_sel,
	 input load_mar,
	 input[1:0] mdrmux_sel,
	 input load_mdr,
	 input[1:0] pc_adder_sel,
	 
	 input[2:0] alumux_sel,
	 
	 input load_ir,
	 input load_regfile,
	 
	 input lc3b_word mem_rdata,
	 input lc3b_aluop aluop,

	
    /* declare more ports here */
	 output lc3b_word mem_address,
	 output lc3b_word mem_wdata,
	 output lc3b_opcode opcode,
	 output branch_enable,
	 output instr_4, instr_5, instr_11
);

/* declare internal signals */
lc3b_word pcmux_out;
lc3b_word pc_out;
lc3b_word pc_adder_mux_out;
lc3b_word br_add_out;
lc3b_word pc_plus2_out;

lc3b_word alu_out;
lc3b_word alumux_out;

lc3b_word marmux_out;
lc3b_word mdrmux_out;

lc3b_word sr1_out;
lc3b_word sr2_out;
lc3b_word regfilemux_out;
lc3b_word psrmux_out;

lc3b_word zext4_out;
lc3b_word sext5_out;
lc3b_word sext6_out;
lc3b_word zext8_0_out;
lc3b_word zext8_1_out;
lc3b_word adj11_out;
lc3b_word adj9_out;
lc3b_word adjz8_out;
lc3b_word adj6_out;

lc3b_word rbytemux_out;
lc3b_reg sr1, sr2;
lc3b_reg dest, destmux_out;
lc3b_reg storemux_out;

lc3b_offset4 offset4;
lc3b_offset5 offset5;
lc3b_offset6 offset6;
lc3b_offset8 offset8;
lc3b_offset9 offset9;
lc3b_offset11 offset11;

lc3b_nzp gencc_out;
lc3b_nzp cc_out;

/*
 * CC
 */

gencc gencc_obj
(
	.in(regfilemux_out),
	.out(gencc_out)
);
register #(.width(3)) cc_obj
(
	.clk,
	.load(load_cc),
	.in(gencc_out),
	.out(cc_out)
);

cccomp cccomp_obj
(
	.nzp(dest),
	.cc(cc_out),
	.out(branch_enable)
);



/*
 * ALU
 */

alu alu_obj
(
    .aluop,
    .a(sr1_out), 
	 .b(alumux_out),
    .f(alu_out)
);

mux8 alumux
(
	.sel(alumux_sel),
	.x0(sr2_out),
	.x1(adj6_out),
	.x2(sext5_out),
	.x3(zext4_out),
	.x4(sext6_out),
	.x5(16'b0),
	.x6(16'b0),
	.x7(16'b0),
	.f(alumux_out)
);
 
/*
 * Regfile
 */
regfile regfile_obj
(
	 .clk,
    .load(load_regfile),
    .in(regfilemux_out),
    .src_a(storemux_out), 
	 .src_b(sr2),
	 .dest(destmux_out),
    .reg_a(sr1_out), 
	 .reg_b(sr2_out)
);
mux4 regfilemux
(
	.sel(regfilemux_sel),
	.a(alu_out),
	.b(mem_wdata),
	.c(br_add_out),
	.d(rbytemux_out),
	.f(regfilemux_out)
);

mux2 rbytemux
(
	.sel(rbytemux_sel),
	.a(zext8_0_out),
	.b(zext8_1_out),
	.f(rbytemux_out)
);


/*
 * ADJ
 */
adj #(.width(11)) adj11
(
	.in(offset11),
	.out(adj11_out)
);
adj #(.width(9)) adj9
(
	.in(offset9),
	.out(adj9_out)
);
adj #(.width(6)) adj6
(
	.in(offset6),
	.out(adj6_out)
);
adjz #(.width(8)) adjz8
(
	.in(offset8),
	.out(adjz8_out)
);
zext #(.width(4)) zext4
(
	.in(offset4),
	.out(zext4_out)
);
sext #(.width(5)) sext5
(
	.in(offset5),
	.out(sext5_out)
);
sext #(.width(6)) sext6
(
	.in(offset6),
	.out(sext6_out)
);
zext #(.width(8)) zext8_0
(
	.in(mem_wdata[7:0]),
	.out(zext8_0_out)
);
zext #(.width(8)) zext8_1
(
	.in(mem_wdata[15:8]),
	.out(zext8_1_out)
);

/*
 * IR
 */
ir ir_obj
(
	 .clk,
    .load(load_ir),
    .in(mem_wdata),
    .opcode,
    .src1(sr1),
	 .src2(sr2),
	 .dest,
	 .instr_4,
	 .instr_5,
	 .instr_11,
	 .offset4,
	 .offset5,
    .offset6,
	 .offset8,
    .offset9,
	 .offset11
);

mux2 #(.width(3)) storemux
(
	.sel(storemux_sel),
	.a(sr1),
	.b(dest),
	.f(storemux_out)
);

mux2 #(.width(3)) destmux
(
	.sel(destmux_sel),
	.a(dest),
	.b(3'b111),
	.f(destmux_out)
);

/*
 * MAR
 */
mux4 marmux
(
	.sel(marmux_sel),
	.a(alu_out),
	.b(pc_out),
	.c(mem_wdata),
	.d(adjz8_out),
	.f(marmux_out)
);
register mar
(
	.clk,
	.load(load_mar),
	.in(marmux_out),
	.out(mem_address)
);

/*
 * MDR
 */
mux4 mdrmux
(
	.sel(mdrmux_sel),
	.a(alu_out),
	.b(mem_rdata),
	.c({alu_out[7:0], alu_out[7:0]}),
	.d(16'b0),
	.f(mdrmux_out)
);
register mdr
(
	.clk,
	.load(load_mdr),
	.in(mdrmux_out),
	.out(mem_wdata)
);


/*
 * PC
 */
mux4 pcmux
(
    .sel(pcmux_sel),
    .a(pc_plus2_out),
    .b(br_add_out),
	 .c(alu_out),
	 .d(mem_wdata),
    .f(pcmux_out)
);

register pc
(
    .clk,
    .load(load_pc),
    .in(pcmux_out),
    .out(pc_out)
);
mux4 pc_adder_mux
(
	.sel(pc_adder_sel),
	.a(adj9_out),
	.b(adj11_out),
	.c(16'b0),
	.d(16'b0),
	.f(pc_adder_mux_out)
);
adder2 pc_adder
(
	.a(pc_adder_mux_out),
	.b(pc_out),
	.f(br_add_out)
);

plus2 pc_inc
(
	.in(pc_out),
	.out(pc_plus2_out)
);


endmodule : datapath
