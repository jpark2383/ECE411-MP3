import lc3b_types::*;

module arbiter
(
	input clk,
	
	/* instruction cache signals */
	input lc3b_word icache_address,
	input icache_read,
	input icache_write,
	input lc3b_cache_line icache_wdata,
	output lc3b_cache_line icache_rdata,
	output logic icache_mem_resp,
	
	/* data cache signals */
	input lc3b_word dcache_address,
	input dcache_read,
	input dcache_write,
	input lc3b_cache_line dcache_wdata,
	output lc3b_cache_line dcache_rdata,
	output logic dcache_mem_resp,
	
	/* L2 cache signals */
	input lc3b_cache_line l2_rdata,
	input l2_mem_resp,
	output lc3b_word l2_address,
	output lc3b_cache_line l2_wdata,
	output logic l2_read,
	output logic l2_write,

	output logic icache_dirty_in,
	input icache_dirty_out,
	output logic dcache_dirty_in,
	input dcache_dirty_out,
	input l2_dirty_in,
	output logic l2_dirty_out
);

enum int unsigned {
	idle,
	icache,
	dcache
} state, next_state;

/* Output logic */
always_comb
begin
	l2_address = 0;
	l2_wdata = 0;
	l2_read = 0;
	l2_write = 0;

	icache_mem_resp = 0;
	icache_rdata = 0;
	
	dcache_mem_resp = 0;
	dcache_rdata = 0;

	icache_dirty_in = 0;
	dcache_dirty_in = 0;
	l2_dirty_out = 0;
	
	case(state)
		idle: begin
			;
		end
		
		icache: begin
			l2_address = icache_address;
			l2_wdata = icache_wdata;
			l2_read = icache_read;
			l2_write = icache_write;

			icache_mem_resp = l2_mem_resp;
			icache_rdata = l2_rdata;
			
			dcache_mem_resp = 0;
			dcache_rdata = 0;

			icache_dirty_in = l2_dirty_in;
			dcache_dirty_in = 0;
			l2_dirty_out = icache_dirty_out;	
		end
		
		dcache: begin
			l2_address = dcache_address;
			l2_wdata = dcache_wdata;
			l2_read = dcache_read;
			l2_write = dcache_write;

			icache_mem_resp = 0;
			icache_rdata = 0;
			
			dcache_mem_resp = l2_mem_resp;
			dcache_rdata = l2_rdata;

			icache_dirty_in = 0;
			dcache_dirty_in = l2_dirty_in;
			l2_dirty_out = dcache_dirty_out;
		end
		
		default: ;
	endcase
end

/* Next state logic */
always_comb
begin
	next_state = idle;
	case(state)
		idle: begin
			if(icache_read)
				next_state = icache;
			else if(dcache_read | dcache_write)
				next_state = dcache;
		end
		
		icache: begin
			if(l2_mem_resp)
				next_state = idle;
			else 
				next_state = icache;
		end
		
		dcache: begin
			if(l2_mem_resp)
				next_state = idle;
			else
				next_state = dcache;
		end
		
		default: ;
	endcase
end

always_ff @ (posedge clk)
begin
	state <= next_state;
end

endmodule : arbiter
