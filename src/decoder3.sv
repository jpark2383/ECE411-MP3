module decoder3
(
	 input [2:0] in,
	 input enable,
	 output [7:0] out
);

assign out = (enable)?(1<<in):8'b0;

endmodule : decoder3