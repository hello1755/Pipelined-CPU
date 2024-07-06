module Zero_Filled (
    data_i,
    data_o
);

  //I/O ports
  input [16-1:0] data_i;
  output [32-1:0] data_o;

  //Internal Signals
  reg [32-1:0] data_o;
  integer i;
  //Zero_Filled
  always@(data_i)
  begin
    data_o[15:0] <= data_i[15:0];
    for(i = 16 ; i < 32 ; i++)
    begin
      data_o[i] <= 0;
    end
  end

endmodule