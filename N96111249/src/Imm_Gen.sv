module Imm_Gen (
    input           [31:0]  inst,
    output logic    [31:0]  imm_ext_out
);

    always_comb begin
        unique case(inst[6:0])
            `I_TYPE:
                imm_ext_out = { {20{inst[31]}}, inst[31:20]};
            `LOAD:
                imm_ext_out = { {20{inst[31]}}, inst[31:20]};
            `JALR:
                imm_ext_out = { {20{inst[31]}}, inst[31:20]};
            `S_TYPE:
                imm_ext_out = { {20{inst[31]}}, inst[31:25], inst[11:7]};
            `B_TYPE:
                imm_ext_out = { {20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
            `LUI:
                imm_ext_out = { inst[31:12], 12'b0};
            `AUIPC:
                imm_ext_out = { inst[31:12], 12'b0};
            `JAL:
                imm_ext_out = { {12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
            default:
                imm_ext_out = 32'b0;
        endcase
    end
    
endmodule