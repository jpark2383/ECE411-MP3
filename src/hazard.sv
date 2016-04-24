import lc3b_types::*;

module hazard
(
  input  clk,
  input  lc3b_word ir_val,
  input  stall,
  output lc3b_word ir_out,
  output logic pc_ld
);

logic next_b_counter;
logic [1:0] counter, next_counter;
logic [15:0] bubble_counter, total;

initial begin
	counter = 2'b0;
	bubble_counter = 16'b0;
	total = 16'b0;
	end
always_comb begin
	next_counter = 0;
	next_b_counter = 0;
  if (counter > 0) begin
    ir_out = 16'b0;
    pc_ld = 0;
	 if (~stall) begin
		next_counter = counter - 2'b01;
		next_b_counter = 1;
	 end
	 else 
		next_counter = counter;
  end
  else begin
     ir_out = ir_val;
     pc_ld = 1;
     if ((lc3b_opcode'(ir_val[15:12]) == op_br && ir_val[11:9] != 0)|| lc3b_opcode'(ir_val[15:12]) == op_jsr || lc3b_opcode'(ir_val[15:12]) == op_trap || lc3b_opcode'(ir_val[15:12]) == op_jmp) begin
		 if (~stall) begin
			next_counter = 2'b01;
			next_b_counter = 1;
		 end
	  end
     else if (lc3b_opcode'(ir_val[15:12]) == op_ldr || lc3b_opcode'(ir_val[15:12]) == op_ldb || lc3b_opcode'(ir_val[15:12]) == op_ldi) begin 
	    if (~stall) begin
			next_counter = 2'b11;
			next_b_counter = 1;
		end	
	  end
  end
end

always_ff @(posedge clk) begin
   counter = next_counter;
   bubble_counter = bubble_counter + next_b_counter;
   total = total + 16'b0000000000000001;
end

endmodule : hazard