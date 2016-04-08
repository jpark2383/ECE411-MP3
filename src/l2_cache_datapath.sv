import lc3b_types::*;

module l2_cache_datapath
(
	 input clk,
	 
	 input lc3b_word mem_address,
	 input lc3b_c2_tag tag,
	 input lc3b_c2_index index,
	 input lc3b_c2_offset offset,
	 
	 input lc3b_cache_line l2_mem_wdata,
	 input lc3b_cache_line pmem_rdata,
	 
	 input pmem_addressmux_sel,
	 
	 input dirty0_write,
	 input dirty0_in,
	 input valid0_write,
	 input valid0_in,
	 input tag0_write,
  	 input data0_write,
 
	 input dirty1_write,
	 input dirty1_in,
	 input valid1_write,
	 input valid1_in,
	 input tag1_write,
	 input data1_write,

	 input lru_write,

	 input datawritemux_sel,
	 
	 input mem_write,
	 
	 output logic hit, full, valid0, valid1,
	 output lc3b_cache_line pmem_wdata,
	 output lc3b_word pmem_address,
	 output lc3b_cache_line l2_mem_rdata,
	 output logic mem_resp,
	 output logic lru,
	 output logic dirty0, dirty1
);

lc3b_cache_line data0_out, data1_out;
lc3b_cache_line cachelinemux_out;
lc3b_cache_line datawrite_out;
lc3b_cache_line datawritemux_out;

lc3b_c_tag tag0_out, tag1_out, tagout;

logic tag0comp_out, tag1comp_out;
logic valid0_out, valid1_out;
logic dirty0_out, dirty1_out;
logic hit0, hit1;
logic cachelinemux_sel;
logic lru_out;
logic selmux_out;

logic data0w;
logic data1w;
assign data0w = data0_write | (hit0 & mem_write);
assign data1w = data1_write | (hit1 & mem_write);
assign l2_mem_rdata = cachelinemux_out;

array #(.width(1)) dirty0arr
(
	.clk(clk),
	.write(dirty0_write | (hit0 & mem_write)),
	.index(index),
	.datain(dirty0_in | (hit0 & mem_write)),
	.dataout(dirty0_out)
);

array #(.width(1)) valid0arr
(
	.clk(clk),
	.write(valid0_write),
	.index(index),
	.datain(valid0_in),
	.dataout(valid0_out)
);

array #(.width(6)) tag0
(
	.clk(clk),
	.write(tag0_write),
	.index(index),
	.datain(tag),
	.dataout(tag0_out)
);

array #(.width(128),.height(64)) data0
(
	.clk(clk),
	.write(data0w),
	.index(index),
	.datain(datawritemux_out),
	.dataout(data0_out)
);

comparator #(.width(6)) tag0comp
(
	.a(tag0_out),
	.b(tag),
	.c(tag0comp_out)
);

array #(.width(1)) dirty1arr
(
	.clk(clk),
	.write(dirty1_write | (hit1 & mem_write)),
	.index(index),
	.datain(dirty1_in | (hit1 & mem_write)),
	.dataout(dirty1_out)
);

array #(.width(1)) valid1arr
(
	.clk(clk),
	.write(valid1_write),
	.index(index),
	.datain(valid1_in),
	.dataout(valid1_out)
);

array #(.width(6)) tag1
(
	.clk(clk),
	.write(tag1_write),
	.index(index),
	.datain(tag),
	.dataout(tag1_out)
);

array #(.width(128),. height(64)) data1
(
	.clk(clk),
	.write(data1w),
	.index(index),
	.datain(datawritemux_out),
	.dataout(data1_out)
);

comparator #(.width(6)) tag1comp
(
	.a(tag1_out),
	.b(tag),
	.c(tag1comp_out)
);

array #(.width(1)) LRU
(
	.clk(clk),
	.write(lru_write),
	.index(index),
	.datain(~cachelinemux_sel),
	.dataout(lru_out)
);

encoder1 encoder
(
	.in({hit1, hit0}),
	.out(selmux_out)
);

mux2 #(.width(1)) selmux
(
	 .sel(hit),
	 .a(lru_out),
	 .b(selmux_out),
	 .f(cachelinemux_sel)
);

mux2 #(.width(128)) cachelinemux
(
	.sel(cachelinemux_sel),
	.a(data0_out),
	.b(data1_out),
	.f(cachelinemux_out)
);

mux2 #(.width(128)) datawritemux
(
	 .sel(datawritemux_sel),
	 .a(l2_mem_wdata),
	 .b(pmem_rdata),
	 .f(datawritemux_out)
);

mux2 #(.width(6)) tagmux
(
	.sel(cachelinemux_sel),
	.a(tag0_out),
	.b(tag1_out),
	.f(tagout)
);

mux2 #(.width(16)) pmem_addressmux
(
	 .sel(pmem_addressmux_sel),
	 .a(mem_address),
	 .b({tagout, index, 4'b0}),
	 .f(pmem_address)
);

assign hit0 = (tag0comp_out & valid0_out);
assign hit1 = (tag1comp_out & valid1_out);
assign hit = hit0 | hit1;
assign full = (valid0_out & valid1_out);
assign valid0 = valid0_out;
assign valid1 = valid1_out;
assign pmem_wdata = cachelinemux_out;
assign mem_resp = hit;
assign lru = lru_out;
assign dirty0 = dirty0_out;
assign dirty1 = dirty1_out;

endmodule : l2_cache_datapath
