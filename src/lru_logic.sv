
module lru_logic
(
	input [7:0] lru_in,
	input [1:0] line_hit,
	output logic [7:0] lru_out
);

logic [1:0] l1, l2, l3, l4;
assign l1 = lru_in[7:6];
assign l2 = lru_in[5:4];
assign l3 = lru_in[3:2];
assign l4 = lru_in[1:0];

always_comb
begin
	if(line_hit == l1)
		lru_out = lru_in;
	else if(line_hit == l2) 
		lru_out = {l2, l1, l3, l4};
	else if(line_hit == l3)
		lru_out = {l3, l1, l2, l4};
	else
		lru_out = {l4, l1, l2, l3};
end 

endmodule : lru_logic