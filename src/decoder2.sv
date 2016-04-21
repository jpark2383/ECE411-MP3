module decoder2
(
	input [1:0] in,
	input enable,
	output [3:0] out
);

assign out = (enable)?(1<<in):4'b0;

endmodule : decoder2