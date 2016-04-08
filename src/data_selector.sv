import lc3b_types::*;

module data_selector
(
	 input lc3b_word w0, w1, w2, w3, w4, w5, w6, w7,
	 input lc3b_word cpu_data,
	 input lc3b_mem_wmask mem_byte_enable,
	 input mem_write,
	 
	 input lc3b_c_offset offset,
	 
	 output lc3b_cache_line out
);

lc3b_word word0, word1, word2, word3, word4, word5, word6, word7;
lc3b_word cpu_data0, cpu_data1, cpu_data2, cpu_data3, cpu_data4, cpu_data5, cpu_data6, cpu_data7;
logic [7:0] sel;

decoder3 decoder
(
	.in(offset[3:1]),
	.enable(mem_write),
	.out(sel)
);

mux2 #(.width(8)) hibytemux0
(
	.sel(mem_byte_enable[1]),
	.a(w0[15:8]),
	.b(cpu_data[15:8]),
	.f(cpu_data0[15:8])
);

mux2 #(.width(8)) lobytemux0
(
	.sel(mem_byte_enable[0]),
	.a(w0[7:0]),
	.b(cpu_data[7:0]),
	.f(cpu_data0[7:0])
);

mux2 word0mux
(
	.sel(sel[0]),
	.a(w0),
	.b(cpu_data0),
	.f(word0)
);

mux2 #(.width(8)) hibytemux1
(
	.sel(mem_byte_enable[1]),
	.a(w1[15:8]),
	.b(cpu_data[15:8]),
	.f(cpu_data1[15:8])
);

mux2 #(.width(8)) lobytemux1
(
	.sel(mem_byte_enable[0]),
	.a(w1[7:0]),
	.b(cpu_data[7:0]),
	.f(cpu_data1[7:0])
);


mux2 word1mux
(
	.sel(sel[1]),
	.a(w1),
	.b(cpu_data1),
	.f(word1)
);

mux2 #(.width(8)) hibytemux2
(
	.sel(mem_byte_enable[1]),
	.a(w2[15:8]),
	.b(cpu_data[15:8]),
	.f(cpu_data2[15:8])
);

mux2 #(.width(8)) lobytemux2
(
	.sel(mem_byte_enable[0]),
	.a(w2[7:0]),
	.b(cpu_data[7:0]),
	.f(cpu_data2[7:0])
);

mux2 word2mux
(
	.sel(sel[2]),
	.a(w2),
	.b(cpu_data2),
	.f(word2)
);

mux2 #(.width(8)) hibytemux3
(
	.sel(mem_byte_enable[1]),
	.a(w3[15:8]),
	.b(cpu_data[15:8]),
	.f(cpu_data3[15:8])
);

mux2 #(.width(8)) lobytemux3
(
	.sel(mem_byte_enable[0]),
	.a(w3[7:0]),
	.b(cpu_data[7:0]),
	.f(cpu_data3[7:0])
);

mux2 word3mux
(
	.sel(sel[3]),
	.a(w3),
	.b(cpu_data3),
	.f(word3)
);

mux2 #(.width(8)) hibytemux4
(
	.sel(mem_byte_enable[1]),
	.a(w4[15:8]),
	.b(cpu_data[15:8]),
	.f(cpu_data4[15:8])
);

mux2 #(.width(8)) lobytemux4
(
	.sel(mem_byte_enable[0]),
	.a(w4[7:0]),
	.b(cpu_data[7:0]),
	.f(cpu_data4[7:0])
);

mux2 word4mux
(
	.sel(sel[4]),
	.a(w4),
	.b(cpu_data4),
	.f(word4)
);

mux2 #(.width(8)) hibytemux5
(
	.sel(mem_byte_enable[1]),
	.a(w5[15:8]),
	.b(cpu_data[15:8]),
	.f(cpu_data5[15:8])
);

mux2 #(.width(8)) lobytemux5
(
	.sel(mem_byte_enable[0]),
	.a(w5[7:0]),
	.b(cpu_data[7:0]),
	.f(cpu_data5[7:0])
);

mux2 word5mux
(
	.sel(sel[5]),
	.a(w5),
	.b(cpu_data5),
	.f(word5)
);

mux2 #(.width(8)) hibytemux6
(
	.sel(mem_byte_enable[1]),
	.a(w6[15:8]),
	.b(cpu_data[15:8]),
	.f(cpu_data6[15:8])
);

mux2 #(.width(8)) lobytemux6
(
	.sel(mem_byte_enable[0]),
	.a(w6[7:0]),
	.b(cpu_data[7:0]),
	.f(cpu_data6[7:0])
);

mux2 word6mux
(
	.sel(sel[6]),
	.a(w6),
	.b(cpu_data6),
	.f(word6)
);

mux2 #(.width(8)) hibytemux7
(
	.sel(mem_byte_enable[1]),
	.a(w7[15:8]),
	.b(cpu_data[15:8]),
	.f(cpu_data7[15:8])
);

mux2 #(.width(8)) lobytemux7
(
	.sel(mem_byte_enable[0]),
	.a(w7[7:0]),
	.b(cpu_data[7:0]),
	.f(cpu_data7[7:0])
);

mux2 word7mux
(
	.sel(sel[7]),
	.a(w7),
	.b(cpu_data7),
	.f(word7)
);

assign out = {word7, word6, word5, word4, word3, word2, word1, word0};

endmodule : data_selector
