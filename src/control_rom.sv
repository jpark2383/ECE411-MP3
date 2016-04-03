import lc3b_types::*;
module control_rom
(
	input lc3b_opcode opcode,
	input A, D, R,
	output lc3b_control_word ctrl
);

always_comb
begin
	/* Default assignments */
	ctrl.opcode = opcode;
	ctrl.load_cc = 0;
	ctrl.pc_sel = 2'b0;
	ctrl.sext_sel = 3'b0;
	ctrl.wb_sel = 0;
	ctrl.load_regfile = 0;
	ctrl.aluop = alu_add;
	ctrl.src_b_mux_sel = 0;
	ctrl.dest_sel = 0;
	ctrl.ex_write_sel = 0;
	ctrl.lea_mux_sel = 2'b0;
	ctrl.jsr_mux_sel = 0;
	/* ... other defaults ... */
	/* Assign control signals based on opcode */
	case(opcode)
		op_add: begin
			ctrl.aluop = alu_add;
			ctrl.load_regfile = 1;
			ctrl.load_cc = 1;
		end
		op_and: begin
			ctrl.aluop = alu_and;
			ctrl.load_regfile = 1;
			ctrl.load_cc = 1;
		end
		op_br: begin
			ctrl.pc_sel = 2'b01;
			ctrl.sext_sel = 3'b010;
		end
		op_ldr: begin
			ctrl.load_regfile = 1;
			ctrl.wb_sel = 2'b01;
			ctrl.load_cc = 1;
			ctrl.sext_sel = 3'b001;
		end
		op_str: begin
			ctrl.sext_sel = 3'b001;
			ctrl.src_b_mux_sel = 1'b1;
		end
		op_not: begin
			ctrl.aluop = alu_not;
			ctrl.load_regfile = 1;
			ctrl.load_cc = 1;
		end
		//Checkpoint 2
		op_jmp: begin
			ctrl.aluop = alu_pass;
			ctrl.pc_sel = 2'b01;
		end
		op_jsr: begin
			ctrl.load_regfile = 1;
			ctrl.dest_sel = 1;
			ctrl.lea_mux_sel = 2'b11;
			ctrl.aluop = alu_pass;
			if(R == 0) begin
				ctrl.pc_sel = 2'b01;
				ctrl.jsr_mux_sel = 1;
			end
			else begin
				ctrl.sext_sel = 3'b011;
				ctrl.pc_sel = 2'b01;
			end
		end
		op_ldb: begin
			ctrl.load_cc = 1;
			ctrl.wb_sel = 2'b10;
			ctrl.sext_sel = 3'b101;
			ctrl.load_regfile = 1;
		end
		op_ldi: begin
		end
		op_lea: begin
			ctrl.load_regfile = 1;
			ctrl.load_cc = 1;
			ctrl.sext_sel = 3'b110;
			ctrl.lea_mux_sel = 2'b01;
		end
		op_shf: begin
			ctrl.load_cc = 1;
			ctrl.load_regfile = 1;
			ctrl.sext_sel = 3'b100;
			if(D == 0)
				ctrl.aluop = alu_sll;
			else begin
				if(A == 0)
					ctrl.aluop = alu_srl;
				else
					ctrl.aluop = alu_sra;
			end
		end
		op_stb: begin
			ctrl.ex_write_sel = 1;
			ctrl.src_b_mux_sel = 1;
		end
		op_sti: begin
		end
		op_trap: begin
			ctrl.load_regfile = 1;
			ctrl.dest_sel = 1;
			ctrl.lea_mux_sel = 2'b10;
			ctrl.pc_sel = 2'b11;
		end
		
		/* ... other opcodes ... */
		default: begin
			ctrl = 0; /* Unknown opcode, set control word to zero */
		end
	endcase
end
endmodule : control_rom
