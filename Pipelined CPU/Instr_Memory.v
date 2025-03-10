module Instr_Memory (
    pc_addr_i,
    instr_o
);

  //I/O ports
  input  [32-1:0] pc_addr_i;
  output [32-1:0] instr_o;

  //Internal Signals
  reg     [32-1:0] instr_o;
  integer          i;

  //32 words Memory
  reg     [32-1:0] Instr_Mem[0:32-1]; //從Instr_Mem[0]開始 ~ Instr_Mem[31]共32個Mem，每個Mem 32 bits

  //Main function
  always @(pc_addr_i) begin
    instr_o = Instr_Mem[pc_addr_i/4];
  end

  //Initial Memory Contents //初始化
  initial begin
    for (i = 0; i < 32; i = i + 1) 
    Instr_Mem[i] = 32'b0;

  end
endmodule
