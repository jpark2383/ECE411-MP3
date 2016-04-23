
module pseudo_lru_logic
(
	input [2:0] lru_in,
	input [1:0] line_hit,
	output logic [2:0] lru_out
);

always_comb
begin
	lru_out = 0;
	case(line_hit)
		2'b00: begin
			lru_out = {lru_in[2], 2'b00};
		end

		2'b01: begin
			lru_out = {lru_in[2], 2'b10};
		end

		2'b10: begin
			lru_out = {1'b0, lru_in[1], 1'b1};
		end

		2'b11: begin
			lru_out = {1'b1, lru_in[1], 1'b1};
		end

		default: ;
	endcase
end

endmodule : pseudo_lru_logic