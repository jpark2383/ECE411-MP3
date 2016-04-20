import lc3b_types::*;

module cache_way
(
	input clk,

	input write,
	input lc3b_c2_index index,
	input lc3b_c2_tag tag_in,
	input lc3b_cache_line data_in,
	input valid_in,
	input dirty_in,

	output logic dirty,
	output logic valid,
	output logic hit,
	output lc3b_c2_tag tag,
	output lc3b_cache_line data,
);

logic tageq;

array #(.width(1)) dirty_array
(
	.clk,
	.write,
	.index,
	.datain(dirty_in),
	.dataout(dirty)
);

array #(.width(1)) valid_array
(
	.clk,
	.write,
	.index,
	.datain(valid_in),
	.dataout(valid)
);

array #(.width()) tag_array
(
	.clk,
	.write,
	.index,
	.datain(tag_in),
	.dataout(tag)
);

array #(.width(128)) data_array
(
	.clk,
	.write,
	.index,
	.datain(data_in),
	.dataout(data)
);

comparator #(.width()) tagcomp
(
	.a(tag)
	.b(tag_in)
	.c(tageq)
);

assign hit = tageq & valid;

endmodule : cache_way