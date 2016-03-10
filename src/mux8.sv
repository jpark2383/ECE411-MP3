module mux8 #(parameter width = 16)
(
	input[2:0] sel,
	input [width-1:0] x0, x1, x2, x3, x4, x5, x6, x7,
	output logic [width-1:0] f
);

always_comb
begin 
	case (sel)
		3'b000:
			f = x0;
		3'b001:
			f = x1;
		3'b010:
			f = x2;
		3'b011:
			f = x3;
		3'b100:
			f = x4;
		3'b101:
			f = x5;
		3'b110:
			f = x6;
		3'b111:
			f = x7;
	endcase
end


endmodule: mux8