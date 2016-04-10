import lc3b_types::*;

module data_forwarding
(
  input  lc3b_word sr1, sr2,
  input  lc3b_reg sr1_addr, sr2_addr,
  input  lc3b_reg ex_dest, wb_dest,
  input  wb_write, ex_write,
  input  lc3b_word ex_data, wb_data,

  output lc3b_word sr1_out, sr2_out
);

always_comb begin
  if (ex_dest == sr1_addr && ex_write)
    sr1_out = ex_data;
  else if (wb_dest == sr1_addr && wb_write)
    sr1_out = wb_data;
  else
    sr1_out = sr1;
end
always_comb begin
    if (ex_dest == sr2_addr && ex_write)
      sr2_out = ex_data;
    else if (wb_dest == sr2_addr && wb_write)
      sr2_out = wb_data;
    else
      sr2_out = sr2;
end
endmodule: data_forwarding

