module Shifter (
    result,
    leftRight,
    shamt,
    sftSrc
);

  //I/O ports
  input leftRight;
  input [5-1:0] shamt;
  input [32-1:0] sftSrc;

  output [32-1:0] result;
  //Internal Signals
  wire [32-1:0] result;

  //Main function
   assign result = (leftRight == 0) ? (sftSrc << shamt) : 
                   (leftRight == 1) ? (sftSrc >> shamt) : 0 ;


endmodule
