import lc3b_types::*;

module cache_logic
(
	input dirty_0, dirty_1,
	input valid_0, valid_1,
	input lru_out,
	input mem_resp_m,
	input mem_read_p, 
	input mem_write_p,

	output logic load_tag_0, load_tag_1,
	output logic valid_load_0, valid_load_1,
	output logic dirty_load_0, dirty_load_1,
	output logic dirty_val_0, dirty_val_1,
	output logic lru_load,
	output logic lru_val,
	output logic load_word_0, load_word_1, 
	output logic load_line_0, load_line_1,
	output logic mem_resp_p,
	output logic mem_read_m,
	output logic mem_write_m,
	output logic data_sel_m,
	output logic data_sel_p
);

always_comb
begin
	load_tag_0 = 0;
	load_tag_1 = 0;
	valid_load_0 = 0;
	valid_load_1 = 0;
	dirty_load_0 = 0;
	dirty_load_1 = 0;
	dirty_val_0 = 0;
	dirty_val_1 = 0;
	lru_load = 0;
	lru_val = 0;
	load_word_0 = 0;
	load_word_1 = 0;
	load_line_0 = 0;
	load_line_1 = 0;
	mem_resp_p = 0;
	mem_read_m = 0;
	mem_write_m = 0;
	data_sel_m = 0;
	data_sel_p = 0;
	
	
	if (mem_read_p && valid_0) begin
		data_sel_p = 0;
		lru_load = 1;
		lru_val = 0;
		mem_resp_p = 1;
	end
	else if (mem_read_p && valid_1) begin
		data_sel_p = 1;
		lru_load = 1;
		lru_val = 1;
		mem_resp_p = 1;
	end
	else if (mem_write_p && valid_0) begin
		mem_resp_p = 1;
		load_word_0 = 1;
		load_line_0 = 1;
		load_tag_0 = 1;
		valid_load_0 = 1;
		dirty_load_0 = 1;
		dirty_val_0 = 1;
		lru_load = 1;
		lru_val = 0;
	end
	else if (mem_write_p && valid_1) begin
		mem_resp_p = 1;
		load_word_1 = 1;
		load_line_1 = 1;
		load_tag_1 = 1;
		valid_load_1 = 1;
		dirty_load_1 = 1;
		dirty_val_1 = 1;
		lru_load = 1;
		lru_val = 1;
	end
	else if ((mem_read_p || mem_write_p) && lru_out == 1) begin
		if (dirty_0) begin
			if (mem_resp_m == 0) begin
				data_sel_m = 0;
				mem_write_m = 1;
			end
			else begin
				dirty_load_0 = 1;
				dirty_val_0 = 0;
			end
		end
		else begin
			mem_read_m = 1;
			load_line_0 = 1;
			if (mem_resp_m != 0) begin
				load_tag_0 = 1;
				valid_load_0 = 1;
			end
		end
	end
	else if ((mem_read_p || mem_write_p) && lru_out == 0) begin
		if (dirty_1) begin
			mem_write_m = 1;
			if (mem_resp_m == 0) begin
				data_sel_m = 0;
			end
			else begin
				dirty_load_1 = 1;
				dirty_val_1 = 0;
			end
		end
		else begin
			load_line_1 = 1;
			mem_read_m = 1;
			if (mem_resp_m != 0) begin
				load_tag_1 = 1;
				valid_load_1 = 1;
			end
		end
	end
end

endmodule: cache_logic
