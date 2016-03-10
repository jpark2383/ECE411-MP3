import lc3b_types::*;

module cache_tags
(
   input clk,
	input load_tag,
	input[2:0] index,
	input[8:0] in,
	output logic[8:0] out
);

logic[8:0] data [7:0] /* synthesis ramstyle = "logic" */;

/* Altera device registers are 0 at power on. Specify this
 * so that Modelsim works as expected.
 */
initial
begin
    for (int i = 0; i < $size(data); i++)
    begin
        data[i] = 9'b0;
    end
end

always_ff @(posedge clk)
begin
   if (load_tag == 1)
   begin
		data[index] = in;
   end
end

always_comb
begin
    out = data[index];
end

endmodule : cache_tags
