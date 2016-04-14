import lc3b_types::*;

module branch
(
    input clk,
    input lc3b_opcode opcode, 
    input lc3b_word pc,

    input branch_load,
    input branch_taken,
    input lc3b_word branch_target,
    input lc3b_word branch_pc,
    
    input logic [1:0] branch_pred_in,
    input logic [1:0] bhr_in,

    output logic[1:0] bhr_out,
    output lc3b_word branch_pred_target,
    output[1:0] branch_pred_take
);

logic [33:0] btb_line_out, btb_line_in;
logic [1:0] branch_pred_new;
always_comb begin
    branch_pred_new = branch_pred_in;
    if (branch_taken == 1) && (branch_pred_in != 2'b11)
        branch_pred_new = branch_pred_in + 1;
    if (branch_taken == 0) && (branch_pred_in != 2'b00)
        branch_pred_new = branch_pred_in - 1;
end

assign btb_line_in = {branch_pc, branch_target, branch_pred_new};
assign branch_pred_target = btb_line_out[17:2];
assign branch_pred_take = (btb_line_out[33:18] == pc) && btb_line_out[1];
register #(.width(2)) bhr
(
    .clk,
    .load(branch_load),
    .in({branch_taken, bhr_out[1]}),
    .out(bhr_out)
);

array2 #(.width(34), .height(32)) btb
(
    .clk,
    .write(branch_load),
    .index_in({bhr_in, branch_pc[5:3]}),
    .index_out({bhr_out, branch_pc[5:3]}),
    .datain(btb_line_in),
    .dataout(btb_line_out)
);
endmodule:branch
