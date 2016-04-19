
module lruarray
(
	input clk,
	input load,
	input [7:0] in,
	output logic [7:0] out
);

logic [7:0] data;

initial
begin
	data = 8'b00011011;
end

always_ff @ (posedge clk)
begin
	if(load)
		data = in;
end

always_comb
begin
	out = data;
end

endmodule : lruarray
