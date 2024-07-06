`include "Program_Counter.v"
`include "Adder.v"
`include "Instr_Memory.v"
`include "Mux2to1.v"
`include "Mux3to1.v"
`include "Reg_File.v"
`include "Decoder.v"
`include "ALU_Ctrl.v"
`include "Sign_Extend.v"
`include "Zero_Filled.v"
`include "ALU.v"
`include "Shifter.v"
`include "Data_Memory.v"
`include "Pipe_Reg.v"

module Pipeline_CPU (
    clk_i,
    rst_n
);

  //I/O port
  input clk_i;
  input rst_n;

  //Internal Signals
  wire [32-1:0] pc_in_i, pc_out_o, instr_o, adder1_out, adder2_out, 
                signed_extend_out, Mux_Branch_out, write_data, Read_Data1, 
                Read_Data2, Zero_Filled_out, ALUSrc_out, ALU_result, 
                Shifter_result, Access_Memory_address, Read_Memory_Data;

  wire [5-1:0] Write_Register, shamt;
  wire [4-1:0] ALU_operation;
  wire [3-1:0] ALUOp;
  wire [2-1:0] FURslt;

  wire         Branch, ALU_zero, Jump, RegWrite, ALUSrc, RegDst, 
               BranchType, MemRead, MemWrite, MemtoReg, leftRight, 
               overflow;

  //modules

  /////////////////////////////          IF     ///////////////////////////////
   Mux2to1 #(
      .size(32)
  ) Mux_PCSrc (
      .data0_i (adder1_out),
      .data1_i (MEM_adder2_out),/////adder2 output
      .select_i(PCSrc), //// Branch output
      .data_o  (pc_in_i)
  );


  Program_Counter PC (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .pc_in_i(pc_in_i),
      .pc_out_o(pc_out_o)
  );

  Adder Adder1 (
      .src1_i(pc_out_o),
      .src2_i(32'd4),
      .sum_o (adder1_out)
  );


  Instr_Memory IM (
      .pc_addr_i(pc_out_o),
      .instr_o  (instr_o)
  );


  wire [32-1:0] ID_adder1_out, ID_instr_o;
  Pipe_Reg #(.size(32 + 32)) IF_ID(      
	   .clk_i(clk_i),
       .rst_n(rst_n),
       .data_i({adder1_out, instr_o}),
       .data_o({ID_adder1_out, ID_instr_o})
);

//////////////////      ID    ////////////////////

  Reg_File RF (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .RSaddr_i(ID_instr_o[25:21]),
      .RTaddr_i(ID_instr_o[20:16]),
      .RDaddr_i(WB_Write_Register),
      .RDdata_i(write_data),
      .RegWrite_i(WB_RegWrite),
      .RSdata_o(Read_Data1),
      .RTdata_o(Read_Data2)
  );


  Sign_Extend SE (
      .data_i(ID_instr_o[15:0]),
      .data_o(signed_extend_out)
  );

  Zero_Filled ZF (
      .data_i(ID_instr_o[15:0]),
      .data_o(Zero_Filled_out)
  );


  Decoder Decoder (
      .instr_op_i(ID_instr_o[31:26]),
      .RegWrite_o(RegWrite),
      .ALUOp_o(ALUOp),
      .ALUSrc_o(ALUSrc),
      .RegDst_o(RegDst),
      .Jump_o(Jump),
      .Branch_o(Branch),
      .BranchType_o(BranchType),
      .MemRead_o(MemRead),
      .MemWrite_o(MemWrite),
      .MemtoReg_o(MemtoReg)
  );
  
  wire EX_ALUSrc, EX_RegDst, EX_Branch, EX_MemRead, EX_MemWrite, EX_MemtoReg, EX_RegWrite, EX_BranchType;
  wire [3-1:0] EX_ALUOp;
  wire [32-1:0] EX_Read_Data1, EX_Read_Data2, EX_signed_extend_out, EX_Zero_Filled_out, EX_adder1_out;
  wire [20:0] EX_instr_o;
  Pipe_Reg #(.size(3 + 1*8 + 32*5 + 21)) ID_EX(      
	   .clk_i(clk_i),
       .rst_n(rst_n),
       .data_i({RegWrite, ALUOp, ALUSrc, RegDst, Branch, MemRead, MemWrite, MemtoReg, BranchType,
                Read_Data1, Read_Data2, signed_extend_out, Zero_Filled_out, ID_adder1_out, ID_instr_o[20:0]}),
       .data_o({EX_RegWrite, EX_ALUOp, EX_ALUSrc, EX_RegDst, EX_Branch, EX_MemRead, EX_MemWrite, EX_MemtoReg, EX_BranchType,
                EX_Read_Data1, EX_Read_Data2, EX_signed_extend_out, EX_Zero_Filled_out, EX_adder1_out, EX_instr_o})
  );
  /////////////////////////   EX  ///////////////////////////////////////////////
  
  Adder Adder2 (
      .src1_i(EX_adder1_out),
      .src2_i({EX_signed_extend_out[29:0],2'b0}),
      .sum_o (adder2_out)
  );

  Mux2to1 #(
      .size(32)
  ) ALU_src2Src (
      .data0_i (EX_Read_Data2),
      .data1_i (EX_signed_extend_out),
      .select_i(EX_ALUSrc),
      .data_o  (ALUSrc_out)
  );

  ALU_Ctrl AC (
      .funct_i(EX_instr_o[5:0]),
      .ALUOp_i(EX_ALUOp),
      .ALU_operation_o(ALU_operation),
      .FURslt_o(FURslt),
      .leftRight_o(leftRight)
  );

  ALU ALU (
      .aluSrc1(EX_Read_Data1),
      .aluSrc2(ALUSrc_out),
      .ALU_operation_i(ALU_operation),
      .result(ALU_result),
      .zero(ALU_zero),
      .overflow(overflow)
  );



  Mux3to1 #(
      .size(32)
  ) RDdata_Source (
      .data0_i (ALU_result),
      .data1_i (Shifter_result),
      .data2_i (EX_Zero_Filled_out),
      .select_i(FURslt),
      .data_o  (Access_Memory_address)
  );


  Mux2to1 #(
      .size(5)
  ) Mux_Write_Reg (
      .data0_i (EX_instr_o[20:16]),
      .data1_i (EX_instr_o[15:11]),
      .select_i(EX_RegDst),
      .data_o  (Write_Register)
  );
wire down_branch;
assign down_branch = EX_BranchType ^ ALU_zero;

wire MEM_RegWrite, MEM_Branch, MEM_MemRead, MEM_MemWrite, MEM_MemtoReg, MEM_down_branch;
wire [32-1:0] MEM_adder2_out, MEM_Access_Memory_address, MEM_Read_Data2;
wire [5-1:0] MEM_Write_Register;
Pipe_Reg #(.size(1*6 + 32*3 + 5)) EX_MEM(      
	   .clk_i(clk_i),
       .rst_n(rst_n),
       .data_i({EX_RegWrite, EX_Branch, EX_MemRead, EX_MemWrite, EX_MemtoReg, down_branch,
                adder2_out, Access_Memory_address, EX_Read_Data2,
                Write_Register}),
       .data_o({MEM_RegWrite, MEM_Branch, MEM_MemRead, MEM_MemWrite, MEM_MemtoReg, MEM_down_branch,
                MEM_adder2_out, MEM_Access_Memory_address, MEM_Read_Data2,
                MEM_Write_Register})
  );


////////////////////////   MEM  /////////////////////////////////
wire PCSrc;
assign PCSrc = MEM_Branch & MEM_down_branch;

Data_Memory DM (
      .clk_i(clk_i),
      .addr_i(MEM_Access_Memory_address),
      .data_i(MEM_Read_Data2),
      .MemRead_i(MEM_MemRead),
      .MemWrite_i(MEM_MemWrite),
      .data_o(Read_Memory_Data)
  );

wire WB_RegWrite,WB_MemtoReg;
wire [32-1:0] WB_Read_Memory_Data, WB_Access_Memory_address;
wire [5-1:0] WB_Write_Register;
Pipe_Reg #(.size(1*2 + 32*2 + 5)) MEM_WB(      
	   .clk_i(clk_i),
       .rst_n(rst_n),
       .data_i({MEM_RegWrite, MEM_MemtoReg, 
                Read_Memory_Data, MEM_Access_Memory_address,
                MEM_Write_Register}),
       .data_o({WB_RegWrite,WB_MemtoReg,
                WB_Read_Memory_Data, WB_Access_Memory_address,
                WB_Write_Register})
  );


/////////////////////         WB    ///// /////////////////////////

  Mux2to1 #(
      .size(32)
  ) Mux_Write (
      .data0_i(WB_Access_Memory_address),
      .data1_i(WB_Read_Memory_Data),//
      .select_i(WB_MemtoReg),
      .data_o(write_data)
  );


endmodule



