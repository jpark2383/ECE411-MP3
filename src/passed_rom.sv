import lc3b_types::*;
module passed_rom
(
	input lc3b_word ir,
	output lc3b_passed_vals passed
);

always_comb
begin
	passed.dest = ir[11:9];
	passed.ir_5 = ir[5];
end
endmodule : passed_rom
