module CSR_wrapper (
    input                   clk,
    input                   rst,
    input                   nop,
    input                   mul_stall,
    input                   cycle_r_en,
    input                   inst_r_en,
    input                   csr_r_pos,
    output logic    [31:0]  CYCLE_out,
    output logic    [31:0]  INST_out
);

    CSR_CYCLE csr_cycle (
        .clk(clk),
        .rst(rst),
        .cycle_r_en(cycle_r_en),
        .cycle_r_pos(csr_r_pos),
        .cycle_out(CYCLE_out)
    );

    CSR_INST csr_inst (
        .clk(clk),
        .rst(rst),
        .nop(nop),
        .mul_stall(mul_stall),
        .inst_r_en(inst_r_en),
        .inst_r_pos(csr_r_pos),
        .csr_inst_out(INST_out)
    );
 
endmodule