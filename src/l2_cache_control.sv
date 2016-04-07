
module l2_cache_control
(
	 input clk,

		/* memory signals from cpu */
	 input mem_write,
	 input mem_read,
	 
		/* memory signals from  physical memory */
	 input pmem_resp,

		/* signals from cache datapath */
	 input hit,
	 input full,
	 input valid0, valid1,
	 input lru,
	 input dirty0, dirty1,
	
		/* output signals to physical memory */
	 output logic pmem_write,
	 output logic pmem_read,
	 
		/* output signals to cache datapath */
	 output logic dirty0_write,
	 output logic dirty0_in,
	 output logic valid0_write,
	 output logic valid0_in,
	 output logic tag0_write,
	 output logic data0_write,
	 
	 output logic dirty1_write,
	 output logic dirty1_in,
	 output logic valid1_write,
	 output logic valid1_in,
	 output logic tag1_write,
	 output logic data1_write,
	 
	 output logic lru_write,
	 output logic datawritemux_sel,
	 output logic pmem_addressmux_sel
);

enum int unsigned {
	idle,
	write_back,
	read_pmem
} state, next_state;

always_comb
begin
	pmem_write = 0;
	pmem_read = 0;
	datawritemux_sel = 0;
	valid0_in = 0;
	valid0_write = 0;
	dirty0_in = 0;
	dirty0_write = 0;
	valid1_in = 0;
	valid1_write = 0;
	dirty1_in = 0;
	dirty1_write = 0;
	tag1_write = 0;
	data1_write= 0;
	tag0_write = 0;
	data0_write = 0;
	lru_write = 0;
	pmem_addressmux_sel = 0;
	
	case(state)
		idle: begin
			if(hit) begin
				lru_write = (mem_write | mem_read);
			end
		end
		
		write_back: begin
			if((lru == 0 && dirty0 == 0) || (lru == 1 && dirty1 == 0)) begin
				pmem_write = 0;
				pmem_addressmux_sel = 0;
			end
			else begin
				pmem_write = 1;
				pmem_addressmux_sel = 1;
			end
				
			if(lru == 0) begin
				valid0_in = 0;
				valid0_write = 1;
			end
			else if(lru == 1) begin
				valid1_in = 0;
				valid1_write = 1;
			end
		end
		
		read_pmem: begin
			pmem_read = 1;
			datawritemux_sel = 1;
			pmem_addressmux_sel = 0;
			if(pmem_resp == 1 && (valid0 == 0)) begin
				valid0_in = 1;
				valid0_write = 1;
				dirty0_in = 0;
				dirty0_write = 1;
				tag0_write = 1;
				data0_write = 1;
			end
			else if(pmem_resp == 1 && (valid1 == 0)) begin
				valid1_in = 1;
				valid1_write = 1;
				dirty1_in = 0;
				dirty1_write = 1;
				tag1_write = 1;
				data1_write= 1;
			end
		end
		
		default: ;
	endcase
end

always_comb
begin
	next_state = idle;
	case(state)
		idle: begin
			if((mem_read | mem_write) & full & (~hit)) begin
					next_state = write_back;
			end
			else if((mem_read | mem_write) & ~hit)
				next_state = read_pmem;
		end
		
		write_back: begin
			if((lru == 0 && dirty0 == 0) || (lru == 1 && dirty1 == 0))
				next_state = read_pmem;
			else if(pmem_resp == 0)
				next_state = write_back;
			else if(pmem_resp & mem_read)
				next_state = read_pmem;
		end
		
		read_pmem: begin
			if(pmem_resp == 0)
				next_state = read_pmem;
			else if(pmem_resp & mem_read)
				next_state = idle;
		end
		
		default: ;
	endcase
end


always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
	 state <= next_state;
end

endmodule : l2_cache_control