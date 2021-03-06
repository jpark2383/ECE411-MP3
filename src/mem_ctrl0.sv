import lc3b_types::*;

module mem_ctrl0
(
  input  clk,
  input  stall,
  input  mem_resp,
  input  lc3b_word mem_rdata_in,
  output lc3b_word mem_rdata_out,
  output logic mem_ready,
  output logic mem_read
);

logic load_mem;

enum int unsigned {
   regular,
   done
} state, next_state;

register mem_data
(
  .clk,
  .load(load_mem),
  .in(mem_rdata_in),
  .out(mem_rdata_out)
);

always_comb begin
   load_mem = 0;
   mem_read = 0;
   mem_ready = 0;
   case (state)
     regular: begin
       load_mem = 1;
       mem_read = 1;
		 mem_ready = 0;
     end
     done: begin
        mem_ready = 1;
     end
	 endcase
end

always_comb begin
   next_state = regular;
   case (state)
     regular: begin
        if (mem_resp == 1) begin
             next_state = done;
        end
     end
     done: begin
        if (stall == 1)
          next_state = done;
     end
	 endcase
end

always_ff @(posedge clk) begin
   state <= next_state;
end
endmodule : mem_ctrl0
