import lc3b_types::*;

module cache_regfile
(
    input clk,
    input load_word, load_line,
    input lc3b_word in_word,
	 input logic[127:0] in_line,
    input logic[2:0] index, offset,
    output lc3b_word data_word,
	 output logic[127:0] data_line
);

lc3b_word [7:0][7:0] data /* synthesis ramstyle = "logic" */;

/* Altera device registers are 0 at power on. Specify this
 * so that Modelsim works as expected.
 */
initial
begin
    for (int i = 0; i < $size(data); i++)
    begin
        data[i] = 16'b0;
    end
end

always_ff @(posedge clk)
begin
   if (load_word == 1)
   begin
		data[index][offset] = in_word;
   end
	else if (load_line == 1)
	begin
		data[index] = in_line;
	end
end

always_comb
begin
    data_word = data[index][offset];
    data_line = data[index];
end

endmodule : cache_regfile
