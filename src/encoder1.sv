module encoder1
(
	 input [1:0] in,
	 output logic out
);

always_comb
begin
	out = 0;
	if(in == 2'b01)
		out = 0;
	else if(in == 2'b10)
		out = 1;
end

endmodule : encoder1