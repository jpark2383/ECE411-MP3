import lc3b_types::*;

module branch_counter
(
  input  clk,
  input  branch,
  input 	miss
);
lc3b_word miss_counter, branch_counter;
initial begin
	miss_counter = 0;
	branch_counter	 = 0;
end

always_ff @(posedge clk) begin
	if (branch)
		branch_counter = branch_counter + 1;
	if (miss)
		miss_counter = miss_counter + 1;

end

endmodule : branch_counter
