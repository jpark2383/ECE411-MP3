module comparator #(parameter width = 9)
(
	input [width-1:0] a, b,
	output logic c
);

always_comb
begin
	if(a == b)
		c = 1;
	else
		c = 0;
end

endmodule : comparator
