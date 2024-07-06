module Decoder (
    instr_op_i,
    RegWrite_o,
    ALUOp_o,
    ALUSrc_o,
    RegDst_o,
    Jump_o,
    Branch_o,
    BranchType_o,
    MemRead_o,
    MemWrite_o,
    MemtoReg_o
);

  //I/O ports
  input [6-1:0] instr_op_i;

  output [3-1:0] ALUOp_o;
  output ALUSrc_o;
  output RegDst_o;
  output RegWrite_o;
  output Jump_o;
  output Branch_o;
  output BranchType_o;
  output MemRead_o;
  output MemWrite_o;
  output MemtoReg_o;

  //Internal Signals
  reg [3-1:0] ALUOp_o;
  reg ALUSrc_o;
  reg RegDst_o;
  reg RegWrite_o;
  reg Jump_o;
  reg Branch_o;
  reg BranchType_o;
  reg MemRead_o;
  reg MemWrite_o;
  reg MemtoReg_o;

  //Main function
  always@(*)
  begin
    case(instr_op_i)
      6'b000000: //R type
        begin
          ALUOp_o <= 3'b010;
          ALUSrc_o <= 1'b0;
          RegDst_o <= 1'b1;
          RegWrite_o <= 1'b1;
          Jump_o <= 1'b0;
          Branch_o <= 1'b0;
          BranchType_o <= 1'b0;
          MemRead_o <= 1'b0;
          MemWrite_o <= 1'b0;
          MemtoReg_o <= 1'b0;
        end
      6'b010011: //addi (算在R type)
        begin
          ALUOp_o <= 3'b000;
          ALUSrc_o <= 1'b1;
          RegDst_o <= 1'b0;
          RegWrite_o <= 1'b1;
          Jump_o <= 1'b0;
          Branch_o <= 1'b0;
          BranchType_o <= 1'b0;
          MemRead_o <= 1'b0;
          MemWrite_o <= 1'b0;
          MemtoReg_o <= 1'b0;
        end
      6'b011000: //lw - I-type
        begin
          ALUOp_o <= 3'b000;
          ALUSrc_o <= 1'b1;
          RegDst_o <= 1'b0;
          RegWrite_o <= 1'b1;
          Jump_o <= 1'b0;
          Branch_o <= 1'b0;
          BranchType_o <= 1'b0;
          MemRead_o <= 1'b1;
          MemWrite_o <= 1'b0;
          MemtoReg_o <= 1'b1;
        end
      6'b101000: //sw - I-type
        begin
          ALUOp_o <= 3'b000;
          ALUSrc_o <= 1'b1;
          RegDst_o <= 1'b0;
          RegWrite_o <= 1'b0;
          Jump_o <= 1'b0;
          Branch_o <= 1'b0;
          BranchType_o <= 1'b0;
          MemRead_o <= 1'b0;
          MemWrite_o <= 1'b1;
          MemtoReg_o <= 1'b0;
        end
      6'b011001: //beq - I-type
        begin
          ALUOp_o <= 3'b100;
          ALUSrc_o <= 1'b0;
          RegDst_o <= 1'b0;
          RegWrite_o <= 1'b0;
          Jump_o <= 1'b0;
          Branch_o <= 1'b1;
          BranchType_o <= 1'b0;
          MemRead_o <= 1'b0;
          MemWrite_o <= 1'b0;
          MemtoReg_o <= 1'b0;
        end
      6'b011010: //bne - I-type
        begin
          ALUOp_o <= 3'b100;
          ALUSrc_o <= 1'b0;
          RegDst_o <= 1'b0;
          RegWrite_o <= 1'b0;
          Jump_o <= 1'b0;
          Branch_o <= 1'b1;
          BranchType_o <= 1'b1;
          MemRead_o <= 1'b0;
          MemWrite_o <= 1'b0;
          MemtoReg_o <= 1'b0;
        end
      6'b001100: //jump - I-type
        begin
          ALUOp_o <= 3'b011;
          ALUSrc_o <= 1'b1;
          RegDst_o <= 1'b0;
          RegWrite_o <= 1'b0;
          Jump_o <= 1'b1;
          Branch_o <= 1'b0;
          BranchType_o <= 1'b0;
          MemRead_o <= 1'b0;
          MemWrite_o <= 1'b0;
          MemtoReg_o <= 1'b0;
        end
    endcase
  end

endmodule
