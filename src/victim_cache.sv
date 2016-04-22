import lc3b_types::*;

module victim_cache
(
	input clk,

	input lc3b_v_tag tag,
	
	input lc3b_cache_line l1_wdata,
	input l1_write, l1_read,
	input lc3b_v_tag l1_tag,
	input dirty_in,
	output lc3b_cache_line l1_rdata,
	output logic l1_dirty,
	output logic mem_resp,

	input lc3b_cache_line l2_rdata,
	input l2_mem_resp,
	output lc3b_word l2_address,
	output lc3b_cache_line l2_wdata,
	output logic l2_write, l2_read
);

logic valid_in;
logic inputreg_load;
logic outputreg_load;
logic selmux_sel;
logic lru_load;
logic linehitmux_sel;
logic cacheslot_load;
logic l2_tagmux_sel;
logic outputregmux_sel;
logic hit;
logic [1:0] line_hit;
logic dirty;
logic full;
logic addr_regload;

victim_cache_datapath datapath
(
	.*
);

victim_cache_controller controller
(
	.*
);

endmodule : victim_cache