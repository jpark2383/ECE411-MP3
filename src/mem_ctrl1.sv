import lc3b_types::*;

module mem_ctrl1
(
  input  clk,
  input  stall,
  input  mem_resp,
  input  lc3b_opcode opcode,
  input  lc3b_word mem_rdata_in,
  input  lc3b_word mem_address_in, 
  output lc3b_word mem_address_out,
  output lc3b_word mem_rdata_out,
  output logic mem_ready,
  output logic mem_read,
  output logic mem_write
);

logic load_mem, mem_sel, mem_data_addr;

enum int unsigned {
   regular,
   indirect,
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
   mem_sel = 0;
   load_mem = 0;
   mem_read = 0;
	mem_write = 0;
   mem_ready = 1;
   case (state)
     regular: begin
       mem_sel = 0;
       load_mem = 1;
		 if (opcode == op_sti || opcode == op_ldi) begin
		   mem_read = 1;
			mem_ready = 0;
		end
		 if (opcode == op_ldr || opcode == op_ldb || opcode == op_trap) begin
			mem_read = 1;
			mem_ready = 0;
		 end
		 if (opcode == op_stb || opcode == op_str) begin
			mem_write = 1;
			mem_ready = 0;
		 end
     end
     indirect: begin
        load_mem = 1;
		  if (opcode == op_sti)
			 mem_write = 1;
		  else
			 mem_read = 1;
        mem_sel = 1;
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
           if (opcode == op_sti || opcode == op_ldi)
             next_state = indirect;
           else
             next_state = done;
        end
     end
     indirect: begin
       if (mem_resp == 1)
         next_state = done;
       else
         next_state = indirect;
     end
     done: begin
        if (stall == 1)
          next_state = done;
     end
	endcase
end

mux2 mem_addr_mux
(
  .sel(mem_sel),
  .a(mem_address_in),
  .b(mem_rdata_in),
  .f(mem_address_out)
 );

always_ff @(posedge clk) begin
   state <= next_state;
end
endmodule : mem_ctrl1
