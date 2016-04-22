import lc3b_types::*;

module branch
(
    input clk,
    input lc3b_word pc,

    input branch_load,
    input branch_taken,
    input lc3b_word branch_target,
    input lc3b_word branch_pc,
    
    input logic [1:0] bhr_in,

    output logic[1:0] bhr_out,
    output lc3b_word branch_pred_target,
    output branch_hit
);

logic [31:0] btb0_out, btb1_out, btb2_out, btb3_out;
logic [1:0] branch_pred_new, branch_pred_out;

always_comb begin
    branch_pred_new = bht_preview;
    if (branch_taken == 1) && (bht_preview != 2'b11)
        branch_pred_new = bht_preview + 1;
    if (branch_taken == 0) && (bht_preview != 2'b00)
        branch_pred_new = bht_preview - 1;
end

//assign branch_pred_target = btb_line_out[17:2];
assign branch_pred_take = branch_hit && branch_pred_out[1];

register #(.width(2)) bhr
(
    .clk,
    .load(branch_load),
    .in({branch_taken, bhr_out[1]}),
    .out(bhr_out)
);

array2 #(.width(2), .height(32)) bht
(
    .clk,
    .write(branch_load),
    .index_in({bhr_in, branch_pc[5:3]}),
    .index_out({bhr_out, branch_pc[5:3]}),
    .preview(bht_preview),
    .datain(branch_pred_new),
    .dataout(branch_pred_out)
);

branch_logic branch_logic_obj(.*);

array2 #(.width(32), .height(8)) btb0
(
    .clk,
    .write(btb0_load),
    .index_in(branch_pc[4:2]),
    .index_out(pc[4:2]),
    .datain({branch_pc, branch_target}),
    .preview(btb0_preview)
    .dataout(btb0_out)
);

array2 #(.width(32), .height(8)) btb1
(
    .clk,
    .write(btb1_load),
    .index_in(branch_pc[4:2]),
    .index_out(pc[4:2]),
    .datain({branch_pc, branch_target}),
    .preview(btb1_preview)
    .dataout(btb1_out)
);
array2 #(.width(32), .height(8)) btb2
(
    .clk,
    .write(btb2_load),
    .index_in(branch_pc[4:2]),
    .index_out(pc[4:2]),
    .datain({branch_pc, branch_target}),
    .preview(btb2_preview)
    .dataout(btb2_out)
);
array2 #(.width(32), .height(8)) btb3
(
    .clk,
    .write(btb3_load),
    .index_in(branch_pc[4:2]),
    .index_out(pc[4:2]),
    .datain({branch_pc, branch_target}),
    .preview(btb3_preview)
    .dataout(btb3_out)
);

endmodule:branch
