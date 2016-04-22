import lc3b_types::*;
module passed_rom
(
	input lc3b_word ir,
    input [20:0] branch,
	 input lc3b_word pc,
	 output lc3b_passed_vals passed
);

always_comb
begin
    passed.branch_hit = branch[0];
    passed.branch_pred_target = branch[16:1];
    passed.bhr_out = branch[18:17];
	passed.dest = ir[11:9];
	passed.ir_5 = ir[5];
	passed.pc = pc;
	passed.branch_pred = branch[20:19];
	passed.nzp = ir[11:9];
end
endmodule : passed_rom
