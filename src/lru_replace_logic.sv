
module lru_replace_logic
(
	input [2:0] lru_in,
	output logic [1:0] lru
);

always_comb
begin
	lru = 0;
	casex(lru_in)
		3'bx11: begin
			lru = 2'b00;
		end

		3'bx01: begin
			lru = 2'b01;
		end 

		3'b1x0: begin
			lru = 2'b10;
		end

		3'b0x0: begin
			lru = 2'b11;
		end
		default: ;
	endcase
end

endmodule : lru_replace_logic