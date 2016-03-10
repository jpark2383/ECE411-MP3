import lc3b_types::*;

module cccomp
(
	input lc3b_reg nzp,
	input lc3b_nzp cc,
	output logic out
);

always_comb
begin
	if ((nzp & cc) != 0)
		out = 1'b1;
	else
		out = 1'b0;
end

endmodule: cccomp