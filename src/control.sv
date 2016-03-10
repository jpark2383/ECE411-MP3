import lc3b_types::*; /* Import types defined in lc3b_types.sv */

module control
(
    /* Input and output port declarations */
	 input clk,
	 
	 input lc3b_opcode opcode,
	 input branch_enable,
	 input instr_4, instr_5, instr_11,
	 
	 output logic load_pc, 
	 output logic load_ir,
	 output logic load_regfile,
	 output logic load_mar,
	 output logic load_mdr,
	 output logic load_cc,
	 output logic[1:0] pc_adder_sel,
	 output logic[1:0] pcmux_sel,
	 output logic storemux_sel,
	 output logic[2:0] alumux_sel,
	 output logic[1:0] regfilemux_sel,
	 output logic[1:0] marmux_sel,
	 output logic rbytemux_sel,
	 output logic[1:0] mdrmux_sel,
	 output logic destmux_sel,
	 output lc3b_aluop aluop,
	 
	 input mem_resp, mem_addr_0,
	 output logic mem_read,
	 output logic mem_write,
	 output lc3b_mem_wmask mem_byte_enable
);

enum int unsigned {
    fetch1,
	 fetch2,
	 fetch3,
	 decode,
	 s_add,
	 s_and,
	 s_not,
	 br,
	 br_taken,/* Assignment of next state on clock edge */
	 calc_addr,
	 calc_addr_b,
	 ldb1,
	 ldb2,
	 stb1,
	 stb2,
	 ldr1,
	 ldr2,
	 str1,
	 str2,
	 s_jmp,
	 s_lea,
	 s_jsr,
	 s_jsr2,
	 s_shf,
	 calc_indir1,
	 calc_indir2, 
	 trap1,
	 trap2,
	 trap3
} state, next_state;

always_comb
begin : state_actions
    load_pc = 1'b0;
	 load_ir = 1'b0;
	 load_regfile = 1'b0;
	 load_mar = 1'b0;
	 load_mdr = 1'b0;
	 load_cc = 1'b0;
	 pcmux_sel = 2'b0;
	 pc_adder_sel = 1'b0;
	 storemux_sel = 1'b0;
	 alumux_sel = 2'b0;
	 regfilemux_sel = 2'b0;
	 marmux_sel = 1'b0;
	 mdrmux_sel = 1'b0;
	 destmux_sel = 1'b0;
	 aluop = alu_add;
	 mem_read = 1'b0;
	 mem_write = 1'b0;
	 mem_byte_enable = 2'b11;
	 rbytemux_sel = 0;
	 case(state)
		fetch1: begin
			marmux_sel = 1;
			load_mar = 1;
			
			pcmux_sel = 2'b0;
			load_pc = 1;
		end
		
		fetch2: begin
			mdrmux_sel = 1;
			load_mdr = 1;
			mem_read = 1;
		end
		fetch3: begin
			load_ir = 1;
		end
		
		decode: /* Nothing */;
		
		s_add: begin
			aluop = alu_add;
			load_regfile = 1;
			load_cc = 1;
			if (instr_5 == 1'b0)
				alumux_sel = 3'b000;
			else
				alumux_sel = 3'b010;
		end
		
		s_and: begin
			aluop = alu_and;
			load_regfile = 1;
			load_cc = 1;
			if (instr_5 == 1'b0)
				alumux_sel = 3'b000;
			else
				alumux_sel = 3'b010;
		end
		
		s_not: begin
			aluop = alu_not;
			load_regfile = 1;
			load_cc = 1;
		end
		
		br: /* Do nothing */;
		
		br_taken: begin
			pcmux_sel = 2'b01;
			load_pc = 1;
		end
		
		calc_addr: begin
			alumux_sel = 3'b001;
			aluop = alu_add;
			load_mar = 1;
		end
		calc_addr_b: begin
			storemux_sel = 1'b0;
			alumux_sel = 3'b100;
			aluop = alu_add;
			load_mar = 1;
		end
		calc_indir1: begin
			mdrmux_sel = 1;
			mem_read = 1;
			load_mdr = 1;
		end
		calc_indir2: begin
			marmux_sel = 2'b10;
			load_mar = 1;
		end
		s_jmp: begin
			alumux_sel = 3'b010;
			aluop = alu_pass;
			pcmux_sel = 2'b10;
			load_pc = 1'b1;
		end
		
		ldr1: begin
			mdrmux_sel = 1;
			load_mdr = 1;
			mem_read = 1;
		end
		
		ldr2: begin
			regfilemux_sel = 2'b01;
			load_regfile = 1;
			load_cc = 1;
		end
		
		str1: begin
			storemux_sel = 1'b1;
			aluop = alu_pass;
			load_mdr = 1;
		end
		
		str2: begin
			mem_write = 1;
		end
		
		ldb1: begin
			mdrmux_sel = 1;
			load_mdr = 1;
			mem_read = 1;
		end
		
		ldb2: begin
			if (mem_addr_0 == 0)
				rbytemux_sel = 0;
			else
				rbytemux_sel = 1;
			regfilemux_sel = 2'b11;
			load_regfile = 1;
			load_cc = 1;
		end
		
		stb1: begin
			storemux_sel = 1'b1;
			aluop = alu_pass;
			mdrmux_sel = 2'b10;
			load_mdr = 1;
		end
		stb2: begin
			if(mem_addr_0 == 0)
				mem_byte_enable = 2'b01;
			else
				mem_byte_enable = 2'b10;
			mem_write = 1;
		end
		s_lea: begin
			regfilemux_sel = 2'b10;
			load_regfile = 1'b1;
			load_cc = 1'b1;
		end
		
		s_jsr: begin
			load_regfile = 1;
			destmux_sel = 1'b1;
			regfilemux_sel = 2'b10;
			pc_adder_sel = 2'b10;
		end
		
		s_jsr2: begin
			if (instr_11 == 1'b0) begin
				storemux_sel = 1'b0;
				aluop = alu_pass;
				pcmux_sel = 2'b10;
			end
			else begin 
				pcmux_sel = 2'b01;
				pc_adder_sel = 1;
			end
			load_pc = 1;
		end
		
		s_shf: begin
			destmux_sel = 1'b0;
			load_cc = 1;
			alumux_sel = 3'b011;
			load_regfile = 1;
			if (instr_4 == 0) 
				aluop = alu_sll;
			else if (instr_5 == 0)
				aluop = alu_srl;
			else
				aluop = alu_sra;
		end

		trap1: begin
			destmux_sel = 1;
			load_regfile = 1;
			regfilemux_sel = 2'b10;
			pc_adder_sel = 2'b10;
			marmux_sel = 2'b11;
			load_mar = 1;
		end
		trap2: begin
			mdrmux_sel = 1;
			load_mdr = 1;
			mem_read = 1;
		end
		trap3: begin
			pcmux_sel = 2'b11;
			load_pc = 1;
		end
		default:/*  Do nothing */;
	endcase
end

always_comb
begin : next_state_logic
	case (state)
		fetch1:
			next_state = fetch2;
		
		fetch2: begin
			if (mem_resp == 0)
				next_state = fetch2;
			else
				next_state = fetch3;
		end
		
		fetch3:
			next_state = decode;
		
		decode: begin
			case(opcode)
			op_add:
				next_state = s_add;
			op_and:
				next_state = s_and;
			op_not:
				next_state = s_not;
			op_ldr:
				next_state = calc_addr;
			op_str:
				next_state = calc_addr;
			op_br:
				next_state = br;
			op_jmp:
				next_state = s_jmp;
			op_lea:
				next_state = s_lea;
			op_jsr:
				next_state = s_jsr;
			op_ldb:
				next_state = calc_addr_b;
			op_stb:
				next_state = calc_addr_b;
			op_ldi:
				next_state = calc_addr;
			op_sti:
				next_state = calc_addr;
			op_shf:
				next_state = s_shf;
			op_trap:
				next_state = trap1;
			default:
				next_state = fetch1;
			endcase
		end
		
		calc_addr: begin
			if (opcode == op_ldr)
				next_state = ldr1;
			else if (opcode == op_str)
				next_state = str1;
			else if (opcode == op_ldi)
				next_state = calc_indir1;
			else if (opcode == op_sti)
				next_state = calc_indir1;
			else
				next_state = fetch1;
		end
		calc_addr_b: begin
			if (opcode == op_ldb)
				next_state = ldb1;
			else if (opcode == op_stb)
				next_state = stb1;
			else
				next_state = fetch1;
		end
		
		ldr1: begin
			if(mem_resp == 0)
				next_state = ldr1;
			else
				next_state = ldr2;
		end
		trap1: 
			next_state = trap2;
		trap2: begin
			if (mem_resp == 0)
				next_state = trap2;
			else
				next_state = trap3;
		end
		calc_indir1: begin
			if(mem_resp == 0)
				next_state = calc_indir1;
			else
				next_state = calc_indir2;
		end
		calc_indir2: begin
			if (opcode == op_ldi)
				next_state = ldr1;
			else if (opcode == op_sti)
				next_state = str1;
			else
				next_state = fetch1;
		end
		str1:
			next_state = str2;
		
		str2: begin
			if (mem_resp == 0)
				next_state = str2;
			else
				next_state = fetch1;
		end
		
		ldb1: begin
			if(mem_resp == 0)
				next_state = ldb1;
			else
				next_state = ldb2;
		end
		
		stb1:
			next_state = stb2;
		
		stb2: begin
			if (mem_resp == 0)
				next_state = stb2;
			else
				next_state = fetch1;
		end
		
		br: begin 
			if(branch_enable == 1)
				next_state = br_taken;
			else
				next_state = fetch1;
		end
		s_jsr:
			next_state = s_jsr2;
		default:
			next_state = fetch1;
	endcase	
end

always_ff @(posedge clk)
begin: next_state_assignment
    state <= next_state;
end

endmodule : control
