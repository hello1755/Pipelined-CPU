module ALU_Ctrl (
    funct_i,
    ALUOp_i,
    ALU_operation_o,
    FURslt_o,
    leftRight_o
);

  //I/O ports
  input [6-1:0] funct_i;
  input [3-1:0] ALUOp_i;

  output [4-1:0] ALU_operation_o;
  output [2-1:0] FURslt_o;
  output leftRight_o;

  //Internal Signals
  wire [6-1:0] funct_i;
  wire [3-1:0] ALUOp_i;
  
  reg [4-1:0] ALU_operation_o;
  reg [2-1:0] FURslt_o;
  reg leftRight_o;

  //Main function
  always@(*)
    begin
      case(ALUOp_i)
        3'b010: //R type
          case(funct_i)
            6'b100011: //add
              begin
                ALU_operation_o <= 4'b0010;
                FURslt_o <= 2'b00;
              end
            6'b010011: //sub
              begin
                ALU_operation_o <= 4'b0110;
                FURslt_o <= 2'b00;
              end
            6'b011111: //and
              begin
                ALU_operation_o <= 4'b0000; 
                FURslt_o <= 2'b00;
              end
            6'b101111: //or
              begin
                ALU_operation_o <= 4'b0001; 
                FURslt_o <= 2'b00;
              end
            6'b010000: //nor
              begin
                ALU_operation_o <= 4'b1100; 
                FURslt_o <= 2'b00;
              end
            6'b010100: //slt
              begin
                ALU_operation_o <= 4'b0111;
                FURslt_o <= 2'b00;
              end
            6'b010010: //shift left
              begin
                leftRight_o <= 1'b0;
                FURslt_o <= 2'b01;
              end
            6'b100010: //shift right
              begin
                leftRight_o <= 1'b1; 
                FURslt_o <= 2'b01;
              end
          endcase

        3'b000: //addi、lw、sw
          begin
            ALU_operation_o <= 4'b0010;
            FURslt_o <= 2'b00;
          end
        3'b100: //beq、bne
          ALU_operation_o <= 4'b0110;

      endcase
    end


endmodule