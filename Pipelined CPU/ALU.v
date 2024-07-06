module ALU (
    aluSrc1,
    aluSrc2,
    ALU_operation_i,
    result,
    zero,
    overflow
);

  //I/O ports
  input [32-1:0] aluSrc1;
  input [32-1:0] aluSrc2;
  input [4-1:0] ALU_operation_i;

  output [32-1:0] result;
  output zero;
  output overflow;

  //Internal Signals
  reg [32-1:0] result;
  reg overflow;

  //Main function
  always@(*)
    begin
      case(ALU_operation_i)
        4'b0010: //add
          begin
            result <= $signed(aluSrc1) + $signed(aluSrc2);
            overflow <= ((aluSrc1[31] & aluSrc2[31] & ~result[31])|(~aluSrc1[31] & ~aluSrc2[31] & result[31]));
          end
        4'b0110: //sub
          begin
            result <= $signed(aluSrc1) - $signed(aluSrc2);
            overflow <= ((aluSrc1[31] & ~aluSrc2[31] & ~result[31])|(aluSrc1[31] & ~aluSrc2[31] & ~result[31]));
          end
        4'b0000: //and
          result <= aluSrc1 & aluSrc2;
        4'b0001: //or
          result <= aluSrc1 | aluSrc2;
        4'b1100: //nor
          result <= ~(aluSrc1 | aluSrc2);
        4'b0111: //slt
          result <= ($signed(aluSrc1) < $signed(aluSrc2)) ? 32'd1 : 32'd0;
      endcase
    end
  assign zero = (result == 32'd0);

endmodule
