module array2 #(parameter width = 16, parameter height = 32)
(
    input clk,
    input write,
    input [height-1:0] index_in,
    input [height-1:0] index_out,
    input [width-1:0] datain,
    output logic [width-1:0] dataout,
    output logic [width-1:0] preview
);
logic [width-1:0] data [2**height-1:0];
/* Initialize array */
initial
begin
    for (int i = 0; i < $size(data); i++)
    begin
        data[i] = 1'b0;
    end
end
always_ff @(posedge clk)
begin
    if (write == 1)
    begin
        data[index_in] = datain;
    end
end

assign preview = data[index_in];
assign dataout = data[index_out];
endmodule : array2