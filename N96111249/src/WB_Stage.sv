module WB_Stage (
    input                   clk,
    input                   rst,
    input                   mul_stall,
    input           [31:0]  MEM_alu_out,
    input           [31:0]  ld_data_in,
    input           [2:0]   funct3,
    input                   wb_data_sel,
    output logic    [31:0]  wb_data
);

    logic           [31:0]  reg_w_alu_out;
    logic           [31:0]  reg_w_ld_data_out;
    logic           [31:0]  ld_filter_out;

    Reg_W reg_w (
        .clk(clk),
        .rst(rst),
        .mul_stall(mul_stall),
        .alu_data_in(MEM_alu_out),
        .ld_data_in(ld_data_in),
        .alu_data_out(reg_w_alu_out),
        .ld_data_out(reg_w_ld_data_out)
    );

    LD_Filter ld_filter (
        .func3(funct3),
        .ld_data(reg_w_ld_data_out),
        .ld_data_f(ld_filter_out)
    );

    Mux2_1 mux (
        .source1(ld_filter_out),
        .source2(reg_w_alu_out),
        .sel(wb_data_sel),
        .mux_out(wb_data)
    );
    
endmodule
