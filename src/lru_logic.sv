import lc3b_types::*;

module lru_logic
(
	input [4:0] lru_in,
	input [1:0] line_hit,
	output [4:0] lru_out
);

logic [1:0] lru, n_lru;
logic [1:0] mru, n_mru;
logic [1:0] x;
logic [1:0] x1, x2;
logic b1, b2;

assign lru = lru_in[1:0];
assign n_lru = lru_in[3:2];
assign x = lru ^ n_lru;

always_comb
begin
	if(lru == 2'b00) begin
		if(x == 2'b01) begin
			x1 = 2'b10;
			x2 = 2'b11;
		end
		else if(x == 2'b10) begin
			x1 = 2'b01;
			x2 = 2'b11;
		end
		else if(x == 2'b11) begin
			x1 = 2'b01;
			x2 = 2'b10;
		end
	end
	else if(lru == 2'b01) begin
		if(x == 2'b01) begin
			x1 = 2'b10;
			x2 = 2'b11;
		end
		else if(x == 2'b10) begin
			x1 = 2'b00;
			x2 = 2'b10;
		end
		else if(x == 2'b11) begin
			x1 = 2'b00;
			x2 = 2'b11;
		end
	end
	else if(lru == 2'b10) begin
		if(x == 2'b01) begin
			x1 = 2'b00;
			x2 = 2'b01;
		end
		else if(x == 2'b10) begin
			x1 = 2'b01;
			x2 = 2'b11;
		end
		else if(x == 2'b11) begin
			x1 = 2'b00;
			x2 = 2'b11;
		end
	end
	else begin
		if(x == 2'b01) begin
			x1 = 2'b00;
			x2 = 2'b01;
		end
		else if(x == 2'b10) begin
			x1 = 2'b00;
			x2 = 2'b10;
		end
		else if(x == 2'b11) begin
			x1 = 2'b01;
			x2 = 2'b10;
		end
	end

	if(lru_in[4]) begin
		if(x1 > x2) begin
			mru = x1;
			n_mru = x2;
		end
		else begin
			mru = x2;
			n_mru = x1;
		end
	end
	else begin
		if(x1 > x2) begin
			mru = x2;
			n_mru = x1;
		end
		else begin
			mru = x1;
			n_mru = x2;
		end
	end
end

always_comb
begin
	b1 = n_lru > mru;
	b2 = lru > mru;
	if(line_hit == mru)
		lru_out = lru_in;
	else if(line_hit == n_mru)
		lru_out = {~lru_in[4], lru_in[3:0]};
	else if(line_hit == n_lru)
		lru_out = {b1, n_mru, lru};
	else
		lru_out = {b2, n_mru, n_lru};
end

endmodule : lru_logic
