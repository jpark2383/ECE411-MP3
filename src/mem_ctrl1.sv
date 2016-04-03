import lc3b_types::*;

module mem_ctrl
(
  input  clk,
  input  stall,
  input  mem_resp,
  input  lc3b_opcode opcode,
  input  lc3b_word mem_rdata_in,
  input  lc3b_word mem_address_in, 
  output lc3b_word mem_address_out,
  output lc3b_word mem_rdata_out,
  output mem_ready,
  output mem_read
)

wire load_mem, mem_sel;
enum int unsigned {
   regular,
   indirect,
   done
}

register mem_data
(
  .clk
  .load(load_mem),
  .in(mem_rdata_in),
  .out(mem_rdata_out)
);

always_comb begin
   mem_sel = 0;
   load_mem = 0;
   mem_read = 0;
   mem_ready = 0;
   case (state)
     regular: begin
       mem_sel = 0;
       load_mem = 1;
       mem_read = 1;
     end
     indirect: begin
        load_mem = 1;
        mem_sel = 1;
        mem_read = 1;
     end
     done: begin
        mem_ready = 1;
     end
end

always_comb begin
   next_state = regular;
   case (state)
     regular: begin
        if (mem_resp_1 == 1) begin
           if (opcode == op_sti || opcode == op_ldi)
             next_state = indirect;
           else
             next_state = done;
        end
     end
     indirect: begin
       if (mem_resp_1 == 1)
         next_state = done;
       else
         next_state = indirect;
     end
     done: begin
        if (stall == 1)
          next_state = done;
     end
end

mux2 mem_addr_mux
(
  .sel(mem_sel),
  .a(mem_address_in),
  .b(mem_rdata_out),
  .f(mem_address_out)
 );

always_ff @(posedge clk) begin
   state <= next_state;
end
endmodule : mem_ctrl
