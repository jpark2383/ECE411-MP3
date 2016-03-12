import lc3b_types::*;
module control_rom
(
	input lc3b_opcode opcode,
	output lc3b_control_word ctrl
);

always_comb
begin
	/* Default assignments */
	ctrl.opcode = opcode;
	ctrl.load_cc = 0;
	ctrl.pc_sel = 0;
	ctrl.sext_sel = 0;
	ctrl.wb_sel = 0;
	ctrl.regfile = 0;
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
			ctrl.aluop = alu_br;
			ctrl.pc_sel = 1;
			ctrl.sext_sel = 1;
			ctrl.load_cc = 1;
		end
		op_ldr: begin
			ctrl.aluop = alu_ldr;
			ctrl.load_regfile = 1;
			ctrl.wb_sel = 1;
			ctrl.load_cc = 1;
		end
		op_str: begin
			ctrl.aluop = alu_str;
		end
		op_not: begin
			ctrl.aluop = alu_not;
			ctrl.load_regfile = 1;
			ctrl.load_cc = 1;
		end
		/* ... other opcodes ... */
		default: begin
			ctrl = 0; /* Unknown opcode, set control word to zero */
		end
	endcase
end
endmodule : control_rom
