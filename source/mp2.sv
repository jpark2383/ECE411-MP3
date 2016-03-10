import lc3b_types::*;

module mp2
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

lc3b_opcode opcode;
wire branch_enable, 
	  load_pc,
	  load_ir,
	  load_regfile,
	  load_mar,
	  load_mdr,
	  load_cc,
	  destmux_sel,
	  storemux_sel,
	  instr_4,
	  instr_5,
	  instr_11,
	  mem_addr_0,
	  rbytemux_sel,
	  mem_resp,
	  mem_read,
	  mem_write;
lc3b_word mem_address, mem_wdata, mem_rdata;
lc3b_mem_wmask mem_byte_enable;
wire [1:0] pcmux_sel,
	  regfilemux_sel,
	  marmux_sel,
	  mdrmux_sel,
	  pc_adder_sel;
wire [2:0] alumux_sel;
	  

lc3b_aluop aluop;

/* Instantiate MP 0 top level blocks here */


assign mem_addr_0 = mem_address[0];
control oontrol_obj(.*);
datapath datapath_obj(.*);
cache cache_obj(.*);
endmodule : mp2
