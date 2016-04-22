import lc3b_types::*;
module passed_rom
(
	input lc3b_word ir,
    input [18:0] branch,
    input [1:0] bhr,
);

always_comb
begin
    passed.branch_hit = branch[0];
    passed.branch_pred_target = branch[16:1];
    passed.bhr = branch[18:17];
	passed.dest = ir[11:9];
	passed.ir_5 = ir[5];
	passed.nzp = ir[11:9];
end
endmodule : passed_rom
