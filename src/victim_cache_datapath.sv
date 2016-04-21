import lc3b_types::*;

module victim_cache_datapath
(
	input clk,

	input lc3b_cache_line l1_wdata,
	input lc3b_v_tag tag,
	input lc3b_v_tag l1_tag,
	input dirty_in,
	input valid_in,
	input inputreg_load,
	input outputreg_load,
	input selmux_sel,
	input lru_load,
	input linehitmux_sel,
	input cacheslot_load,
	input l2_tagmux_sel,
	input outputregmux_sel,

	input lc3b_cache_line l2_rdata,

	output logic hit,
	output logic [1:0] line_hit,
	output logic dirty,
	output logic full,
	output lc3b_word l2_address,
	output lc3b_cache_line l2_wdata,
	output lc3b_cache_line l1_rdata,
	output logic l1_dirty
);

lc3b_cache_line inputreg_out;
logic [128:0] outputreg_out;

lc3b_cache_line line0, line1, line2, line3;
lc3b_v_tag tag0, tag1, tag2, tag3;
logic dirty0, dirty1, dirty2, dirty3;
logic valid0, valid1, valid2, valid3;
logic hit0, hit1, hit2, hit3;

logic [7:0] lru_in, lru_out;

logic [1:0] linemux_sel;
lc3b_cache_line linemux_out;
logic validmux_out;
logic dirtymux_out;
lc3b_v_tag tagmux_out;

logic [1:0] lru_line, linehitmux_out;
assign lru_line = lru_out[1:0];

lc3b_v_tag l2_tagmuxout;
logic [128:0] outputregmux_out;

logic [3:0] en;

register #(.width(128)) inputreg
(
	.clk,
	.load(inputreg_load),
	.in(l1_wdata),
	.out(inputreg_out)
);

cache_slot slot0
(
	.clk,
	.write(cacheslot_load & en[0]),
	.dirty_in(dirty_in),
	.valid_in(valid_in),
	.tag_in(l1_tag),
	.tagcpu(tag),
	.wdata(inputreg_out),
	.line(line0),
	.tag(tag0),
	.hit(hit0),
	.valid(valid0),
	.dirty(dirty0)
);

cache_slot slot1
(
	.clk,
	.write(cacheslot_load & en[1]),
	.dirty_in(dirty_in),
	.valid_in(valid_in),
	.tag_in(l1_tag),
	.tagcpu(tag),
	.wdata(inputreg_out),
	.line(line1),
	.tag(tag1),
	.hit(hit1),
	.valid(valid1),
	.dirty(dirty1)
);

cache_slot slot2
(
	.clk,
	.write(cacheslot_load & en[2]),
	.dirty_in(dirty_in),
	.valid_in(valid_in),
	.tag_in(l1_tag),
	.tagcpu(tag),
	.wdata(inputreg_out),
	.line(line2),
	.tag(tag2),
	.hit(hit2),
	.valid(valid2),
	.dirty(dirty2)
);

cache_slot slot3
(
	.clk,
	.write(cacheslot_load & en[3]),
	.dirty_in(dirty_in),
	.valid_in(valid_in),
	.tag_in(l1_tag),
	.tagcpu(tag),
	.wdata(inputreg_out),
	.line(line3),
	.tag(tag3),
	.hit(hit3),
	.valid(valid3),
	.dirty(dirty3)
);

encoder2 enc2
(
	.in({hit3, hit2, hit1, hit0}),
	.out(line_hit)
);

decoder2 dec2
(
	.in(linehitmux_out),
	.enable(1'b1),
	.out(en)
);

lruarray lru 
(
	.clk,
	.load(lru_load),
	.in(lru_in),
	.out(lru_out)
);

mux2 #(.width(2)) linehitmux
(
	.sel(linehitmux_sel),
	.a(line_hit),
	.b(lru_line),
	.f(linehitmux_out)
);

lru_logic lru_update_logic
(
	.lru_in(lru_out),
	.line_hit(linehitmux_out),
	.lru_out(lru_in)
);

mux2 #(.width(2)) selmux
(
	.sel(~hit),
	.a(line_hit),
	.b(lru_line),
	.f(linemux_sel)
);

mux4 #(.width(1)) validmux
(
	.sel(linemux_sel),
	.a(valid0),
	.b(valid1),
	.c(valid2),
	.d(valid3),
	.f(validmux_out)
);

mux4 #(.width(1)) dirtymux
(
	.sel(linemux_sel),
	.a(dirty0),
	.b(dirty1),
	.c(dirty2),
	.d(dirty3),
	.f(dirtymux_out)
);

mux4 #(.width(12)) tagmux
(
	.sel(linemux_sel),
	.a(tag0),
	.b(tag1),
	.c(tag2),
	.d(tag3),
	.f(tagmux_out)
);

mux4 #(.width(128)) linemux
(
	.sel(linemux_sel),
	.a(line0),
	.b(line1),
	.c(line2),
	.d(line3),
	.f(linemux_out)
);

register #(.width(129)) outputreg
(
	.clk,
	.load(outputreg_load),
	.in({dirtymux_out, linemux_out}),
	.out(outputreg_out)
);

mux2 #(.width(129)) outputregmux
(
	.sel(outputregmux_sel),
	.a(outputreg_out),
	.b({1'b0, l2_rdata}),
	.f(outputregmux_out)
);

mux2 #(.width(12)) l2_tagmux
(
	.sel(l2_tagmux_sel),
	.a(tagmux_out),
	.b(tag),
	.f(l2_tagmuxout)
);

assign hit = (hit0 | hit1 | hit2 | hit3);
assign full = (valid0 & valid1 & valid2 & valid3);
assign dirty = dirtymux_out;
assign l2_address = {l2_tagmuxout, 4'b0};
assign l2_wdata = outputreg_out[127:0];
assign l1_rdata = outputregmux_out[127:0];
assign l1_dirty = outputregmux_out[128];

endmodule : victim_cache_datapath
