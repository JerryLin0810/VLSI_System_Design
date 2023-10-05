module ID_Stage (
    input                   clk,
    input                   rst,
    input           [31:0]  pc_in,
    input           [31:0]  im_inst,
    input                   stall,
    input                   mul_stall,
    input                   jb,
    output logic    [31:0]  pc_out,
    output logic    [6:0]   opcode_out,
    output logic    [2:0]   funct3_out,
    output logic    [4:0]   rd_index_out,
    output logic    [4:0]   rs1_index_out,
    output logic    [4:0]   rs2_index_out,
    output logic    [1:0]   funct7_out,
    output logic            csr_r_pos,
    output logic    [31:0]  inst_out
);

    logic           [1:0]   reg_d_inst_sel;
    logic           [31:0]  reg_d_inst_out;
    logic           [31:0]  inst_mux_out;
    logic           [4:0]   decoder_rs1_index_out;
    logic           [4:0]   decoder_rs2_index_out;
    logic           [31:0]  regfile_rs1_data_out;
    logic           [31:0]  regfile_rs2_data_out;

    Reg_D reg_d (
        .clk(clk),
        .rst(rst),
        .pc(pc_in),
        .stall(stall),
        .mul_stall(mul_stall),
        .jb(jb),
        .inst(im_inst),
        .pc_out(pc_out),
        .inst_out(reg_d_inst_out),
        .inst_sel(reg_d_inst_sel)
    );

    always_comb begin
        unique case(reg_d_inst_sel)
            2'd0:   inst_mux_out = im_inst;         // normal
            2'd1:   inst_mux_out = reg_d_inst_out;  // stall
            default:inst_mux_out = 32'b0;           // jb
        endcase
    end

    Decoder decoder (
        .inst(inst_mux_out), 
        .opcode(opcode_out),
        .func3(funct3_out),
        .func7(funct7_out),
        .rs1_index(rs1_index_out),
        .rs2_index(rs2_index_out),
        .rd_index(rd_index_out),
        .csr_r_pos(csr_r_pos)
    );

    assign inst_out = inst_mux_out;
    
endmodule
