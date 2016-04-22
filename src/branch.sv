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
	 output logic[1:0] branch_pred_out,
    output lc3b_word branch_pred_target,
    output branch_hit
);

logic[31:0] btb_out0, btb_out1, btb_out2, btb_out3;
logic[31:0] btb_preview0, btb_preview1, btb_preview2, btb_preview3;
logic btb0_load, btb1_load, btb2_load, btb3_load;
logic[1:0] bht_preview, branch_pred_new;

always_comb begin
    branch_pred_new = bht_preview;
    if ((branch_taken == 1) && (bht_preview != 2'b11))
        branch_pred_new = bht_preview + 2'b01;
    if ((branch_taken == 0) && (bht_preview != 2'b00))
        branch_pred_new = bht_preview - 2'b01;
end

register #(.width(2)) bhr
(
    .clk,
    .load(branch_load),
    .in({branch_taken, bhr_out[1]}),
    .out(bhr_out)
);

array2 #(.width(2), .height(5)) bht
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

array2 #(.width(32), .height(3)) btb0
(
    .clk,
    .write(btb0_load),
    .index_in(branch_pc[4:2]),
    .index_out(pc[4:2]),
    .datain({branch_pc, branch_target}),
    .preview(btb_preview0),
    .dataout(btb_out0)
);

array2 #(.width(32), .height(3)) btb1
(
    .clk,
    .write(btb1_load),
    .index_in(branch_pc[4:2]),
    .index_out(pc[4:2]),
    .datain({branch_pc, branch_target}),
    .preview(btb_preview1),
    .dataout(btb_out1)
);
array2 #(.width(32), .height(3)) btb2
(
    .clk,
    .write(btb2_load),
    .index_in(branch_pc[4:2]),
    .index_out(pc[4:2]),
    .datain({branch_pc, branch_target}),
    .preview(btb_preview2),
    .dataout(btb_out2)
);
array2 #(.width(32), .height(3)) btb3
(
    .clk,
    .write(btb3_load),
    .index_in(branch_pc[4:2]),
    .index_out(pc[4:2]),
    .datain({branch_pc, branch_target}),
    .preview(btb_preview3),
    .dataout(btb_out3)
);

endmodule:branch
