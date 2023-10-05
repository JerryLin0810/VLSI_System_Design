module IF_Stage (
    input                   clk,
    input                   rst,
    input                   stall,
    input                   mul_stall,
    input                   jb,
    input           [31:0]  jb_pc,
    output logic    [13:0]  im_addr,        // for IM access
	output logic 	[31:0]	current_pc      // for debug
);

    logic           [31:0]  reg_pc_out;
    logic           [31:0]  pc_adder_out;
    logic           [31:0]  mux_out;

    Reg_PC reg_pc (
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .mul_stall(mul_stall),
        .next_pc(mux_out),
        .current_pc(reg_pc_out)
    );

    Mux2_1 pc_mux(
        .source1(jb_pc),
        .source2(pc_adder_out),
        .sel(jb),
        .mux_out(mux_out)
    );
    
    PC_Adder pc_adder(
        .add_in(reg_pc_out),
        .add_out(pc_adder_out)
    );

    assign current_pc = reg_pc_out;
    assign im_addr = reg_pc_out[15:2];


endmodule
