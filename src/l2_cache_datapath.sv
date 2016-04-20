import lc3b_types::*;

module l2_cache_datapath
(
	input clk,

	input lc3b_c2_tag tag,
	input lc3b_c2_index index,
	input lc3b_cache_line mem_wdata,

	input lc3b_cache_line pmem_rdata,

	input write, valid_in, dirty_in,
	input pseudoarray_load,
	input pmem_addressmuxsel,

	output logic hit,
	output logic full,
	output logic dirty,
	output lc3b_word pmem_address,
	output lc3b_cache_line mem_rdata,
	output lc3b_cache_line pmem_wdata,
	output logic mem_resp
);

logic dirty0, dirty1, dirty2, dirty3;
logic valid0, valid1, valid2, valid3, valid;
logic hit0, hit1, hit2, hit3;
lc3b_c2_tag tag0, tag1, tag2, tag3, tagmux_out;
lc3b_cache_line data0, data1, data2, data3, datamux_out, wdatamux_out;

logic [1:0] line_hit, lru_line, lineselmux_out;

logic [2:0] lru_update, lru_out;

logic [3:0] en;

mux2 #(.width(128)) wdatamux
(
	.sel(hit),
	.a(pmem_rdata),
	.b(mem_wdata),
	.f(wdatamux_out)
);

cache_way way0
(
	.clk,
	.write(write & en[0]),
	.index,
	.tag_in(tag),
	.data_in(wdatamux_out),
	.valid_in,
	.dirty_in,
	.dirty(dirty0),
	.valid(valid0),
	.hit(hit0),
	.tag(tag0),
	.data(data0)
);

cache_way way1
(
	.clk,
	.write(write & en[1]),
	.index,
	.tag_in(tag),
	.data_in(wdatamux_out),
	.valid_in,
	.dirty_in,
	.dirty(dirty1),
	.valid(valid1),
	.hit(hit1),
	.tag(tag1),
	.data(data1)
);

cache_way way2
(
	.clk,
	.write(write & en[2]),
	.index,
	.tag_in(tag),
	.data_in(wdatamux_out),
	.valid_in,
	.dirty_in,
	.dirty(dirty2),
	.valid(valid2),
	.hit(hit2),
	.tag(tag2),
	.data(data2)
);

cache_way way3
(
	.clk,
	.write(write & en[3]),
	.index,
	.tag_in(tag),
	.data_in(wdatamux_out),
	.valid_in,
	.dirty_in,
	.dirty(dirty3),
	.valid(valid3),
	.hit(hit3),
	.tag(tag3),
	.data(data3)
);

encoder2 enc2
(
	.in({hit3, hit2, hit1, hit0}),
	.out(line_hit)
);

decoder2 dec2
(
	.in(lineselmux_out),
	.enable(1'b1),
	.out(en)
);

register #(.width(3)) pseudoarray
(
	.clk,
	.load(pseudoarray_load),
	.in(lru_update),
	.out(lru_out)
);

pseudo_lru_logic updatelogic
(
	.lru_in(lru_out), 
	.line_hit(line_hit),
	.lru_out(lru_update)
);

lru_replace_logic lrulogic
(
	.lru_in(lru_out),
	.lru(lru_line)
);

mux2 #(.width(2)) lineselmux
(
	.sel(hit),
	.a(lru_line),
	.b(line_hit),
	.f(lineselmux_out)
);

mux4 #(.width(1)) dirtymux
(
	.sel(lineselmux_out),
	.a(dirty0),
	.b(dirty1),
	.c(dirty2),
	.d(dirty3),
	.f(dirty)
);

mux4 #(.width(1)) validmux
(
	.sel(lineselmux_out),
	.a(valid0),
	.b(valid1),
	.c(valid2),
	.d(valid3),
	.f(valid)
);

mux4 #(.width(9)) tagmux
(
	.sel(lineselmux_out),
	.a(tag0),
	.b(tag1),
	.c(tag2),
	.d(tag3),
	.f(tagmux_out)
);

mux4 #(.width(128)) datamux
(
	.sel(lineselmux_out),
	.a(data0),
	.b(data1),
	.c(data2),
	.d(data3),
	.f(datamux_out)
);

mux2 #(.width(16)) pmem_addressmux
(
	.sel(pmem_addressmuxsel),
	.a({tag, index, 4'b0000}),
	.b({tagmux_out, index, 4'b0000}),
	.f(pmem_address)
);

assign hit = (hit0 | hit1 | hit2 | hit3);
assign full = (valid0 & valid1 & valid2 & valid3);
assign mem_rdata = datamux_out;
assign pmem_wdata = datamux_out;
assign mem_resp = hit;

endmodule : l2_cache_datapath
