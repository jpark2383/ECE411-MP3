import lc3b_types::*;

module branch_logic
(
	 input clk,
    input logic[31:0] btb_out0, btb_out1, btb_out2, btb_out3,
    input logic[31:0] btb_preview0, btb_preview1, btb_preview2, btb_preview3,
    input lc3b_word pc,
	 input branch_load,

    output logic[15:0] branch_pred_target,
    output logic branch_hit,
    output logic btb0_load, btb1_load, btb2_load, btb3_load
);
logic[7:0] lru_cur, lru_new, lru_out;
logic branch_miss;
logic[1:0] lru_hit;
initial begin
	lru_cur = 8'b00011011;
end
always_ff@(posedge clk) begin
	 if (branch_load == 1)
		lru_cur = lru_new;
end
lru_logic lru_logic_obj
(
    .lru_in(lru_cur),
    .line_hit(lru_hit),
    .lru_out(lru_out)
);
always_comb begin
    lru_new = lru_cur;
    if (branch_hit != 0)
        lru_new = lru_out;
	 else if (branch_miss != 0)
		  lru_new = {lru_cur[7:2], lru_cur[1:0]};
end
always_comb begin
    branch_pred_target = 16'b0;
    branch_hit = 0;
    branch_miss = 0;
	 lru_hit = 0;
    if (btb_out0[31:16] == pc) begin
        branch_pred_target = btb_out0[15:0];
        lru_hit = 0;
        branch_hit = 1;
    end
    else if (btb_out1[31:16] == pc) begin
        branch_pred_target = btb_out1[15:0];
        lru_hit = 1;
        branch_hit = 1;
    end
    else if (btb_out2[31:16] == pc) begin
        branch_pred_target = btb_out2[15:0];
        lru_hit = 2;
        branch_hit = 1;
    end
    else if (btb_out3[31:16] == pc) begin
        branch_pred_target = btb_out3[15:0];
        lru_hit = 3;
        branch_hit = 1;
    end
    else begin
        branch_miss = 1;
    end
end

always_comb begin
    btb0_load = 0;
    btb1_load = 0;
    btb2_load = 0;
    btb3_load = 0;
	 if (branch_load == 1) begin
		 if (btb_preview0[31:16] == btb_preview0[15:0])
			  btb0_load = 1;
		 else if (btb_preview1[31:16] == btb_preview1[15:0])
			  btb1_load = 1;
		 else if (btb_preview2[31:16] == btb_preview2[15:0])
			  btb2_load = 1;
		 else if (btb_preview3[31:16] == btb_preview3[15:0])
			  btb3_load = 1;
		 else begin
			  if (lru_out[1:0] == 0)
					btb0_load = 1;
			  else if (lru_out[1:0] == 1)
					btb1_load = 1;
			  else if (lru_out[1:0] == 2)
					btb2_load = 1;
			  else if (lru_out[1:0] == 3)
					btb3_load = 1;
		 end
    end
end

endmodule : branch_logic
