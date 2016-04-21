import lc3b_types::*;

module cache_slot
(
	input clk,

	input write,
	input dirty_in,
	input valid_in,
	input lc3b_v_tag tag_in,
	input lc3b_v_tag tagcpu,
	input lc3b_cache_line wdata,
	
	output lc3b_cache_line line,
	output lc3b_v_tag tag,
	output logic hit,
	output logic valid,
	output logic dirty
);

lc3b_cache_line data_out;
lc3b_v_tag tag_out;
logic tageq;
logic valid_out;
logic dirty_out;

register #(.width(1)) dirtyreg
(
	.clk,
	.load(write),
	.in(dirty_in),
	.out(dirty_out)
);

register #(.width(1)) validreg
(
	.clk,
	.load(write),
	.in(valid_in),
	.out(valid_out)
);

register #(.width(12)) tagreg
(
	.clk,
	.load(write),
	.in(tag_in),
	.out(tag_out)
);

register #(.width(128)) datareg
(
	.clk,
	.load(write),
	.in(wdata),
	.out(data_out)
);

comparator #(.width(12)) tagcomp
(
	.a(tagcpu),
	.b(tag_out),
	.c(tageq)
);

assign hit = tageq & valid_out;
assign valid = valid_out;
assign dirty = dirty_out;
assign line = data_out;
assign tag = tag_out;

endmodule : cache_slot