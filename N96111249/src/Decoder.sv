module Decoder (
    input           [31:0]  inst,
    output logic    [6:0]   opcode,     
    output logic    [2:0]   func3,
    output logic    [1:0]   func7,
    output logic    [4:0]   rs1_index,
    output logic    [4:0]   rs2_index,
    output logic    [4:0]   rd_index,
    output logic            csr_r_pos
);

    assign  opcode = inst[6:0];
    assign  func3 = inst[14:12];
    assign  func7 = {inst[30], inst[25]};
    assign  rs1_index = inst[19:15];
    assign  rs2_index = inst[24:20];
    assign  rd_index = inst[11:7];
    assign  csr_r_pos = inst[27];
    
endmodule