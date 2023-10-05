module MEM_Stage (
    input                   clk,
    input                   rst,
    input                   mul_stall,
    input           [2:0]   funct3,
    input           [31:0]  alu_result_in,
    input           [31:0]  rs2_data_in,
    input           [1:0]   remainder,
    input           [1:0]   alu_data_sel,
    input                   csr_cycle_r_en,
    input                   csr_inst_r_en,
    input                   csr_r_pos,
    input                   nop_in,
    output logic    [31:0]  dm_w_data,
    output logic    [31:0]  forward_data,
    output logic            MEM_stall
);

    logic           [31:0]  reg_m_alu_result_out;
    logic           [31:0]  reg_m_rs2_data_out;
    logic           [31:0]  csr_cycle_out;
    logic           [31:0]  csr_inst_out;
    logic           [31:0]  dm_w_data_mux_out;

    Reg_M reg_m (
        .clk(clk),
        .rst(rst),
        .mul_stall(mul_stall),
        .alu_result(alu_result_in),
        .alu_result_out(reg_m_alu_result_out),
	    .MEM_stall(MEM_stall)
    );

    CSR_wrapper csr_wrapper (
        .clk(clk),
        .rst(rst),
        .nop(nop_in),
        .mul_stall(mul_stall),
        .cycle_r_en(csr_cycle_r_en),
        .inst_r_en(csr_inst_r_en),
        .csr_r_pos(csr_r_pos),
        .CYCLE_out(csr_cycle_out),
        .INST_out(csr_inst_out)        
    );

    Mux3_1 alu_csr_mux (
        .source1(reg_m_alu_result_out),
        .source2(csr_inst_out),
        .source3(csr_cycle_out),
        .sel(alu_data_sel),
        .mux_out(forward_data)
    );

    always_comb begin
        unique case(remainder)
            2'd1:   dm_w_data = {rs2_data_in[23:0], 8'b0};
            2'd2:   dm_w_data = {rs2_data_in[15:0], 16'b0};
            2'd3:   dm_w_data = {rs2_data_in[7:0],  24'b0};
            default:dm_w_data = rs2_data_in;
        endcase
    end

    
endmodule
