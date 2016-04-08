import lc3_types::*;

module hazard
(
  input  clk,
  input  lc3b_word ir_val,
  output lc3b_word ir_out,
  output logic pc_ld
);

logic [1:0] counter, next_counter;
always_comb begin
  if (counter > 1) begin
    ir_out = 16'b0;
    pc_ld = 0;
    next_counter = counter - 1;
  end
  else begin
     if (lc3b_opcode'(ir_val[15:12]) == op_br || lc3b_opcode'(ir_val[15:12]) == op_jsr || lc3b_opcode'(ir_val[15:12]) == op_trap)
       next_counter = 2;
     else if (lc3b_opcode'(ir_val[15:12]) == op_ldr || lc3b_opcode'(ir_val[15:12]) == op_ldb || lc3b_opcode'(ir_val[15:12]) == op_ldi)
       next_counter = 3;
     ir_out = ir_val;
     pr_ld = 1;
  end
end
always_ff @(posedge clk) begin
   counter = next_counter;
end
endmodule : hazard
