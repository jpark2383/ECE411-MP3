
module l2_cache_control
(
	input clk,

	/* memory signals from L1 */
	input mem_write,
	input mem_read,

	/* memory signals from  physical memory */
	input pmem_resp,

	/* signals from cache datapath */
	input hit,
	input full,
	input dirty,

	/* output signals to physical memory */
	output logic pmem_write,
	output logic pmem_read,

	/* output signals to cache datapath */
	output logic write,
	output logic dirty_in,
	output logic valid_in,
	output logic pseudoarray_load,
	output logic pmem_addressmuxsel,
	output logic wdatamux_sel
);

enum int unsigned {
	idle,
	write_back,
	read_pmem
} state, next_state;

always_comb
begin
	write = 0;
	dirty_in = 0;
	valid_in = 1;
	pseudoarray_load = 0;
	pmem_write = 0;
	pmem_read = 0;
	wdatamux_sel = 0;

	case(state)
		idle: begin
			if(hit) begin
				write = mem_write;
				dirty_in = mem_write;
				pseudoarray_load = (mem_write | mem_read);
			end
		end
		
		write_back: begin
			pmem_write = 1;
		end
		
		read_pmem: begin
			pmem_read = 1;
			wdatamux_sel = 1;
			if(pmem_resp) begin
				write = 1;
				pseudoarray_load = 1;
				valid_in = 1;
			end
		end
		
		default: ;
	endcase
end

always_comb
begin
	pmem_addressmuxsel = 0;
	if(next_state == write_back)
		pmem_addressmuxsel = 1;
end

always_comb
begin
	next_state = state;
	case(state)
		idle: begin
			if((mem_read | mem_write) & full & (~hit)) begin
				next_state = write_back;
			end
			else if((mem_read | mem_write) & ~hit) begin
				next_state = read_pmem;
			end
		end
		
		write_back: begin
			if(pmem_resp == 0)
				next_state = write_back;
			else
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
begin
	 state <= next_state;
end

endmodule : l2_cache_control