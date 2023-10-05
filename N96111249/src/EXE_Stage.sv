module EXE_Stage (
    input                   clk,
    input                   rst,
    input                   stall,
    input                   mul_stall,
    input                   jb,
    input                   wb_en,
    input           [4:0]   rd_index,
    input           [31:0]  pc,
    input           [4:0]   rs1_index,
    input           [4:0]   rs2_index,
    input           [31:0]  inst,
    input           [31:0]  WB_forward_data,
    input           [31:0]  MEM_forward_data,
    input           [1:0]   rs1_data_sel,
    input           [1:0]   rs2_data_sel,
    input                   jb_op1_sel,
    input                   alu_op1_sel,
    input                   alu_op2_sel,
    input           [6:0]   opcode,
    input           [2:0]   funct3,
    input           [1:0]   funct7,
    output logic            jb_condition,
    output logic    [31:0]  alu_out,
    output logic    [13:0]  dm_addr,
    output logic    [1:0]   remainder,
    output logic    [31:0]  rs2_data_out,   
    output logic    [31:0]  jb_data
);

    logic           [4:0]   reg_e_rs1_index_out;
    logic           [4:0]   reg_e_rs2_index_out;
    logic           [31:0]  reg_e_pc_out;
    logic           [31:0]  reg_e_inst_out;
    logic           [31:0]  imm_gen_out;
    logic           [31:0]  regfile_rs1_data_out;
    logic           [31:0]  regfile_rs2_data_out;
    logic           [31:0]  rs1_data_mux_out;
    logic           [31:0]  rs2_data_mux_out;
    logic           [31:0]  alu_op1_mux_out;
    logic           [31:0]  alu_op2_mux_out;
    logic           [31:0]  jb_op1_mux_out;


    Reg_E reg_E (
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .mul_stall(mul_stall),
        .jb(jb),
        .pc(pc),
        .rs1_index(rs1_index),
        .rs2_index(rs2_index),
        .inst(inst),
        .rs1_index_out(reg_e_rs1_index_out),
        .rs2_index_out(reg_e_rs2_index_out),
        .pc_out(reg_e_pc_out),
        .inst_out(reg_e_inst_out)
    );

    Imm_Gen imm_gen(
        .inst(reg_e_inst_out),
        .imm_ext_out(imm_gen_out)
    );

    RegFile regfile(
        .clk(clk),
        .wb_en(wb_en),
        .wb_data(WB_forward_data),
        .rd_index(rd_index),
        .rs1_index(reg_e_rs1_index_out),
        .rs2_index(reg_e_rs2_index_out),
        .rs1_data_out(regfile_rs1_data_out),
        .rs2_data_out(regfile_rs2_data_out)
    );

    Mux3_1 rs1_data_mux (
        .source1(WB_forward_data),
        .source2(MEM_forward_data),
        .source3(regfile_rs1_data_out),
        .sel(rs1_data_sel),
        .mux_out(rs1_data_mux_out)
    );

    Mux3_1 rs2_data_mux (
        .source1(WB_forward_data),
        .source2(MEM_forward_data),
        .source3(regfile_rs2_data_out),
        .sel(rs2_data_sel),
        .mux_out(rs2_data_mux_out)
    );

    Mux2_1 alu_op1_mux (
        .source1(reg_e_pc_out),
        .source2(rs1_data_mux_out),
        .sel(alu_op1_sel),
        .mux_out(alu_op1_mux_out)
    );

    Mux2_1 alu_op2_mux (
        .source1(rs2_data_mux_out),
        .source2(imm_gen_out),
        .sel(alu_op2_sel),
        .mux_out(alu_op2_mux_out)
    );

    ALU alu (
        .clk(clk),
        .rst(rst),
        .opcode(opcode),
        .func3(funct3),
        .func7(funct7),
        .op1(alu_op1_mux_out),
        .op2(alu_op2_mux_out),
        .jb_condition(jb_condition),
        .alu_out(alu_out),
        .dm_addr(dm_addr),
        .remainder(remainder)
    );

    Mux2_1 jb_op1_mux(
        .source1(rs1_data_mux_out),
        .source2(reg_e_pc_out),
        .sel(jb_op1_sel),
        .mux_out(jb_op1_mux_out)
    );

    JB_Unit jb_unit (
        .op1(jb_op1_mux_out),
        .op2(imm_gen_out),
        .jb_out(jb_data)
    );

    assign rs2_data_out = rs2_data_mux_out;

endmodule
