module victim_cache_controller
(
	input clk,

	input hit,
	input [1:0] line_hit,
	input dirty,
	input full,
	input l1_read, l1_write,
	input l2_mem_resp,

	output logic inputreg_load,
	output logic outputreg_load,
	output logic selmux_sel,
	output logic lru_load,
	output logic linehitmux_sel,
	output logic cacheslot_load,
	output logic l2_tagmux_sel,
	output logic mem_resp,
	output logic l2_read,
	output logic l2_write,
	output logic outputregmux_sel,
	output logic valid_in
);

enum int unsigned {
	idle, 
	swap,
	write_l2,
	read_l2,
	write_victim
} state, next_state; 

/* output logic */
always_comb
begin
	inputreg_load = 0;
	outputreg_load = 0;
	selmux_sel = 0;
	lru_load = 0;
	linehitmux_sel = 0;
	cacheslot_load = 0;
	mem_resp = 0;
	outputregmux_sel = 0;
	valid_in = 0;
	l2_write = 0;
	l2_read = 0;

	case(state)
		idle: begin
			if(hit && l1_write) begin	/* inreg  <= L1 cache; outreg <= victim hit line */
				inputreg_load = 1;
				outputreg_load = 1;
				lru_load = 1;
				mem_resp = 1;
			end
			else if(~hit && l1_write) begin /* inreg  <= L1 cache; outreg <= victim lru line */
				inputreg_load = 1;
				outputreg_load = 1;
				selmux_sel = 1;
				linehitmux_sel = 1;
			end
		end

		swap: begin
			if(l1_read) begin
				valid_in = 1;
				cacheslot_load = 1;
				mem_resp = 1;
			end
		end

		write_l2: begin		/* write dirty lru line to L2 and load L1 line to victim*/
			selmux_sel = 1;
			l2_write = 1;
			if(l2_mem_resp) begin
				valid_in = 1;
				cacheslot_load = 1;
				linehitmux_sel = 1;
			end
		end 

		read_l2: begin		/* read line from L2 and forward to L1*/
			l2_read = 1;
			outputregmux_sel = 1;
			if(l2_mem_resp) begin
				lru_load = 1;
				linehitmux_sel = 1;
				mem_resp = 1;
			end
		end

		write_victim: begin	/* load L1 line to victim */
			valid_in = 1;
			cacheslot_load = 1;
			mem_resp = 1;
			linehitmux_sel = 1;
			lru_load = 1;
		end

		default: ;
	endcase
end

always_comb
begin
	l2_tagmux_sel = 0;
	if(next_state == read_l2) begin
		l2_tagmux_sel = 1;
	end
end

/* next_state logic */ 
always_comb
begin
	next_state = state;
	case(state)
		idle: begin
			if(hit && l1_write)
				next_state = swap;
			else if(~hit && l1_write && full && dirty) begin
				next_state = write_l2;
			end
			else if(~hit && l1_write && (~full | ~dirty)) 
				next_state = write_victim;
			else if(l1_read) begin
				next_state = read_l2;
			end
		end

		swap: begin
			if(l1_read)
				next_state = idle;
		end

		write_l2: begin
			if(l2_mem_resp) begin
				next_state = read_l2;
			end
		end

		read_l2: begin
			if(l2_mem_resp)
				next_state = idle;
		end

		write_victim: begin
			if(l1_read) begin
				next_state = read_l2;
			end
			else
				next_state = idle;
		end

		default: ;
	endcase
end

/* next state assignment */
always_ff @ (posedge clk)
begin
	state <= next_state;
end

endmodule : victim_cache_controller