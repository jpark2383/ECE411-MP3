import lc3b_types::*;

module hazard
(
  input  clk,
  input  lc3b_word ir_val,
  input  stall,
  output lc3b_word ir_out,
  output logic pc_ld
);

logic [1:0] counter, next_counter;
initial begin
	counter = 2'b0;
	end
always_comb begin
	next_counter = 0;
  if (counter > 0) begin
    ir_out = 16'b0;
    pc_ld = 0;
	 if (~stall)
		next_counter = counter - 2'b01;
	 else next_counter = counter;
  end
  else begin
     if ((lc3b_opcode'(ir_val[15:12]) == op_br && ir_val[11:9] != 0)|| lc3b_opcode'(ir_val[15:12]) == op_jsr || lc3b_opcode'(ir_val[15:12]) == op_trap) begin
		 if (~stall)
			next_counter = 2'b10;
	  end
     else if (lc3b_opcode'(ir_val[15:12]) == op_ldr || lc3b_opcode'(ir_val[15:12]) == op_ldb || lc3b_opcode'(ir_val[15:12]) == op_ldi) begin 
	    if (~stall)
			next_counter = 2'b11;
	  end
     ir_out = ir_val;
     pc_ld = 1;
  end
end
always_ff @(posedge clk) begin
   counter = next_counter;
end
endmodule : hazard
