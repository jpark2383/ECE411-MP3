import lc3b_types::*;

module cache
(
	input clk,
	input lc3b_word mem_address,
	input lc3b_word mem_wdata,
	input mem_read,
	input mem_write,
	input[1:0] mem_byte_enable,
	
	output logic mem_resp,
	output lc3b_word mem_rdata,
	
	input[127:0] pmem_rdata,
	input pmem_resp,
	
	output lc3b_word pmem_address,
	output logic [127:0] pmem_wdata,
	output logic pmem_read, pmem_write
	
);
logic data_sel_m, data_sel_p,
		load_word_0, load_word_1,
		load_line_0, load_line_1,
		dirty_load_0, dirty_load_1,
		dirty_val_0, dirty_val_1, 
		dirty_0, dirty_1,
		load_tag_0, load_tag_1,
		valid_0, valid_1,
		valid_out_0, valid_out_1,
		valid_load_0, valid_load_1,
		lru_out, lru_load, lru_val;
logic[8:0] tag;
logic[2:0] index, offset;
lc3b_word enable_out_0, enable_out_1;

assign tag = mem_address[15:7];
assign index = mem_address[6:4];
assign offset = mem_address[3:1];

logic[7:0] enable_high_0, enable_low_0,
			  enable_high_1, enable_low_1;
assign enable_out_0 = {enable_high_0, enable_low_0};
assign enable_out_1 = {enable_high_1, enable_low_1};

logic[15:0] data_word_0, data_word_1;
logic[127:0] data_line_0, data_line_1,
				 reg_in_line_0, reg_in_line_1;

logic[8:0] tag_out_0, tag_out_1;

array reg_0(
	.clk,
	.write(load_line_0),
   .index,
   .datain(reg_in_line_0),
   .dataout(data_line_0)
);
array reg_1(
	.clk,
	.write(load_line_1),
   .index,
   .datain(reg_in_line_1),
   .dataout(data_line_1)
);
mux8 word_mux_0 
(
	.sel(offset),
	.x0(data_line_0[15:0]),
	.x1(data_line_0[31:16]),
	.x2(data_line_0[47:32]),
	.x3(data_line_0[63:48]),
	.x4(data_line_0[79:64]),
	.x5(data_line_0[95:80]),
	.x6(data_line_0[111:96]),
	.x7(data_line_0[127:112]),
	.f(data_word_0)
);
mux8 word_mux_1
(
	.sel(offset),
	.x0(data_line_1[15:0]),
	.x1(data_line_1[31:16]),
	.x2(data_line_1[47:32]),
	.x3(data_line_1[63:48]),
	.x4(data_line_1[79:64]),
	.x5(data_line_1[95:80]),
	.x6(data_line_1[111:96]),
	.x7(data_line_1[127:112]),
	.f(data_word_1)
);
cache_logic logic_unit
(
	.*,
	.mem_read_m(pmem_read),
	.mem_write_m(pmem_write),
	.mem_read_p(mem_read),
	.mem_write_p(mem_write),
	.mem_resp_m(pmem_resp),
	.mem_resp_p(mem_resp)
);

generate
	logic[127:0] load_word_line_0, load_word_line_1;
	genvar i;
	for (i=0; i < 8; i++)  begin: M0
		mux2 mux_cache0(
			.sel(offset == i),
			.a(data_line_0[i*16+15:i*16]),
			.b(enable_out_0),
			.f(load_word_line_0[i*16+15:i*16])
		);
	end
	mux2 #(.width(128)) mux_word0(
		.sel(load_word_0),
		.a(pmem_rdata),
		.b(load_word_line_0),
		.f(reg_in_line_0)
	);
	
	for (i=0; i < 8; i++)  begin: M1
		mux2 mux_cache1(
			.sel(offset == i),
			.a(data_line_1[i*16+15:i*16]),
			.b(enable_out_1),
			.f(load_word_line_1[i*16+15:i*16])
		);
	end
	mux2 #(.width(128)) mux_word1(
		.sel(load_word_1),
		.a(pmem_rdata),
		.b(load_word_line_1),
		.f(reg_in_line_1)
	);
endgenerate
mux4 pmem_mux
(
	.sel({pmem_write, data_sel_m}),
	.a({tag, index, 4'b0}),
	.b({tag, index, 4'b0}),
	.c({tag_out_0, index, 4'b0}),
	.d({tag_out_1, index, 4'b0}),
	.f(pmem_address)
);

mux2 data_mux_processor
(
	.sel(data_sel_p),
	.a(data_word_0),
	.b(data_word_1),
	.f(mem_rdata)
);
mux2 #(.width(128)) data_mux_mem
(
	.sel(data_sel_m),
	.a(data_line_0),
	.b(data_line_1),
	.f(pmem_wdata)
);

mux2 #(.width(8)) enable_mux_high_0
(
	.sel(mem_byte_enable[1]),
	.a(data_word_0[15:8]),
	.b(mem_wdata[15:8]),
	.f(enable_high_0)
);
mux2 #(.width(8)) enable_mux_low_0
(
	.sel(mem_byte_enable[0]),
	.a(data_word_0[7:0]),
	.b(mem_wdata[7:0]),
	.f(enable_low_0)
);
mux2 #(.width(8)) enable_mux_high_1
(
	.sel(mem_byte_enable[1]),
	.a(data_word_1[15:8]),
	.b(mem_wdata[15:8]),
	.f(enable_high_1)
);
mux2 #(.width(8)) enable_mux_low_1
(
	.sel(mem_byte_enable[0]),
	.a(data_word_1[7:0]),
	.b(mem_wdata[7:0]),
	.f(enable_low_1)
);

array #(.width(1)) dirty_reg_0
(
	.clk,
	.index,
	.write(dirty_load_0),
	.datain(dirty_val_0),
	.dataout(dirty_0)
);
array #(.width(1)) dirty_reg_1
(
	.clk,
	.index,
	.write(dirty_load_1),
	.datain(dirty_val_1),
	.dataout(dirty_1)
);

array #(.width(1)) valid_reg_0
(
	.clk,
	.index,
	.write(valid_load_0),
	.datain(1'b1),
	.dataout(valid_out_0)
);
array #(.width(1)) valid_reg_1
(
	.clk,
	.index,
	.write(valid_load_1),
	.datain(1'b1),
	.dataout(valid_out_1)
);

array #(.width(1)) lru
(
	.clk,
	.index,
	.write(lru_load),
	.datain(lru_val),
	.dataout(lru_out)
);

array #(.width(9)) tags_0
(
	.clk,
	.write(load_tag_0),
	.index,
	.datain(tag),
	.dataout(tag_out_0)
);
array #(.width(9)) tags_1
(
	.clk,
	.write(load_tag_1),
	.index,
	.datain(tag),
	.dataout(tag_out_1)
);

always_comb
begin
	valid_0 = 1'b0;
	valid_1 = 1'b0;
	if(tag == tag_out_0 && valid_out_0 == 1'b1)
		valid_0 = 1'b1;
	if(tag == tag_out_1 && valid_out_1 == 1'b1)
		valid_1 = 1'b1;
end


endmodule: cache