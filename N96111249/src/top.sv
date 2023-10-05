`include "../src/Param.sv"
`include "../src/SRAM_wrapper.sv"
`include "../src/IF_Stage.sv"
`include "../src/ID_Stage.sv"
`include "../src/EXE_Stage.sv"
`include "../src/MEM_Stage.sv"
`include "../src/WB_Stage.sv"
`include "../src/Controller.sv"
`include "../src/Decoder.sv"
`include "../src/Imm_Gen.sv"
`include "../src/RegFile.sv"
`include "../src/Reg_D.sv"
`include "../src/Reg_E.sv"
`include "../src/Reg_M.sv"
`include "../src/Reg_W.sv"
`include "../src/Reg_PC.sv"
`include "../src/PC_Adder.sv"
`include "../src/Mux3_1.sv"
`include "../src/Mux2_1.sv"
`include "../src/LD_Filter.sv"
`include "../src/JB_Unit.sv"
`include "../src/CSR_wrapper.sv"
`include "../src/CSR_INST.sv"
`include "../src/CSR_CYCLE.sv"
`include "../src/ALU.sv"


module top (
    input           clk, 
    input           rst
);

    // Controller output signal
    logic           stall;
    logic           mul_stall;
    logic           jb;
    logic           IF_chip_sel;
    logic   [3:0]   IF_im_w_en;
    logic           IF_im_r_en;
    logic           ID_rs1_data_sel; 
    logic           ID_rs2_data_sel;
    logic           ID_csr_r_pos_out;
    logic   [1:0]   EXE_rs1_data_sel;
    logic   [1:0]   EXE_rs2_data_sel;
    logic           EXE_jb_op1_sel;
    logic           EXE_alu_op1_sel;
    logic           EXE_alu_op2_sel;
    logic   [6:0]   EXE_op;
    logic   [2:0]   EXE_funct3;
    logic   [1:0]   EXE_funct7;
    logic   [2:0]   MEM_funct3;
    logic           MEM_nop_out;
    logic           MEM_chip_sel;
    logic   [3:0]   MEM_dm_w_en;
    logic           MEM_dm_r_en;
    logic   [1:0]   MEM_alu_csr_sel;
    logic           MEM_csr_cycle_r_en;
    logic           MEM_csr_inst_r_en;
    logic           MEM_csr_r_pos;
    logic           WB_wb_en;
    logic   [4:0]   WB_rd_index;
    logic   [2:0]   WB_funct3;

    // IF stage output signals
    logic   [13:0]  im_addr;
    logic   [31:0]  current_pc;

    // Instruction memory output signals
    logic   [31:0]  im_out;

    // ID stage output signals
    logic   [31:0]  ID_rs1_data_out;
    logic   [31:0]  ID_rs2_data_out;
    logic   [31:0]  ID_pc_out;
    logic   [6:0]   ID_op_out;
    logic   [2:0]   ID_f3_out;
    logic   [1:0]   ID_f7_out;
    logic   [4:0]   ID_rs1_index_out;
    logic   [4:0]   ID_rs2_index_out;
    logic   [4:0]   ID_rd_index_out;
    logic   [31:0]  ID_inst_out;

    // EXE stage output signals
    logic           EXE_jb_condition_out;
    logic   [31:0]  EXE_alu_out;
    logic   [31:0]  EXE_rs2_data_out;
    logic   [31:0]  EXE_jb_data_out;
    logic   [13:0]  EXE_dm_addr;
    logic   [1:0]   EXE_remainder_out;

    // MEM stage output signals
    logic   [31:0]  MEM_alu_out;
    logic   [31:0]  dm_data_in;
    logic           MEM_stall_out;

    // Data memory signals
    logic   [31:0]  dm_out;

    // WB stage output signals
    logic   [31:0]  WB_wb_data_out;


    Controller controller (
        .clk(clk), 
        .rst(rst), 
        .opcode(ID_op_out), 
        .func3(ID_f3_out), 
        .func7(ID_f7_out), 
        .rs1_index(ID_rs1_index_out), 
        .rs2_index(ID_rs2_index_out), 
        .rd_index(ID_rd_index_out), 
        .csr_r_pos(ID_csr_r_pos_out),
        .jb_condition(EXE_jb_condition_out), 
        .remainder(EXE_remainder_out),
        .MEM_stall(MEM_stall_out),
        .stall(stall), 
        .mul_stall(mul_stall),
        .next_pc_sel(jb), 
        .F_chip_sel(IF_chip_sel),
        .F_im_w_en(IF_im_w_en), 
        .F_im_r_en(IF_im_r_en), 
        .E_op_out(EXE_op), 
        .E_f3_out(EXE_funct3), 
        .E_f7_out(EXE_funct7), 
        .E_jb_op1_sel(EXE_jb_op1_sel), 
        .E_alu_op1_sel(EXE_alu_op1_sel),
        .E_alu_op2_sel(EXE_alu_op2_sel), 
        .E_rs1_data_sel(EXE_rs1_data_sel), 
        .E_rs2_data_sel(EXE_rs2_data_sel), 
        .M_nop(MEM_nop_out),
        .M_chip_sel(MEM_chip_sel),
        .M_dm_w_en(MEM_dm_w_en),
        .M_dm_r_en(MEM_dm_r_en),
        .M_funct3(MEM_funct3),
        .M_alu_csr_sel(MEM_alu_csr_sel),
        .M_csr_cycle_r_en(MEM_csr_cycle_r_en),
        .M_csr_inst_r_en(MEM_csr_inst_r_en),
        .M_csr_r_pos(MEM_csr_r_pos),
        .W_wb_en(WB_wb_en), 
        .W_rd_out(WB_rd_index), 
        .W_f3_out(WB_funct3), 
        .W_wb_data_sel(WB_wb_data_sel)
    );

    IF_Stage IF_stage (
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .mul_stall(mul_stall),
        .jb(jb),
        .jb_pc(EXE_jb_data_out),
        .im_addr(im_addr),        // for IM access
        .current_pc(current_pc)
    );

    SRAM_wrapper IM1 (
        .CK(clk),
        .CS(IF_chip_sel),
        .OE(IF_im_r_en),
        .WEB(IF_im_w_en),
        .A(im_addr),
        .DI(32'b0),              // Not allow to write
        .DO(im_out)
    );

    ID_Stage ID_stage (
        .clk(clk),
        .rst(rst),
        .pc_in(current_pc),
        .im_inst(im_out),
        .stall(stall),
        .mul_stall(mul_stall),
        .jb(jb),
        .pc_out(ID_pc_out),
        .opcode_out(ID_op_out),
        .funct3_out(ID_f3_out),
        .rd_index_out(ID_rd_index_out),
        .rs1_index_out(ID_rs1_index_out),
        .rs2_index_out(ID_rs2_index_out),
        .funct7_out(ID_f7_out),
        .csr_r_pos(ID_csr_r_pos_out),
        .inst_out(ID_inst_out)
    );

    EXE_Stage EXE_stage (
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .mul_stall(mul_stall),
        .jb(jb),
        .wb_en(WB_wb_en),
        .rd_index(WB_rd_index),
        .pc(ID_pc_out),
        .rs1_index(ID_rs1_index_out),
        .rs2_index(ID_rs2_index_out),
        .inst(ID_inst_out),
        .WB_forward_data(WB_wb_data_out),
        .MEM_forward_data(MEM_alu_out),
        .rs1_data_sel(EXE_rs1_data_sel),
        .rs2_data_sel(EXE_rs2_data_sel),
        .jb_op1_sel(EXE_jb_op1_sel),
        .alu_op1_sel(EXE_alu_op1_sel),
        .alu_op2_sel(EXE_alu_op2_sel),
        .opcode(EXE_op),
        .funct3(EXE_funct3),
        .funct7(EXE_funct7),
        .jb_condition(EXE_jb_condition_out),
        .alu_out(EXE_alu_out),
        .dm_addr(EXE_dm_addr),
        .remainder(EXE_remainder_out),
        .rs2_data_out(EXE_rs2_data_out),   
        .jb_data(EXE_jb_data_out)
    );

    MEM_Stage MEM_stage (
        .clk(clk),
        .rst(rst),
        .mul_stall(mul_stall),
        .nop_in(MEM_nop_out),
        .funct3(MEM_funct3),
        .alu_result_in(EXE_alu_out),
        .rs2_data_in(EXE_rs2_data_out),
        .remainder(EXE_remainder_out),
        .alu_data_sel(MEM_alu_csr_sel),
        .csr_cycle_r_en(MEM_csr_cycle_r_en),
        .csr_inst_r_en(MEM_csr_inst_r_en),
        .csr_r_pos(MEM_csr_r_pos),
        .dm_w_data(dm_data_in),
        .forward_data(MEM_alu_out),
        .MEM_stall(MEM_stall_out)
    );

    SRAM_wrapper DM1 (
        .CK(clk),
        .CS(MEM_chip_sel),
        .OE(MEM_dm_r_en),
        .WEB(MEM_dm_w_en),
        .A(EXE_dm_addr),
        .DI(dm_data_in),
        .DO(dm_out)
    );

    WB_Stage WB_stage (
        .clk(clk),
        .rst(rst),
        .mul_stall(mul_stall),
        .MEM_alu_out(MEM_alu_out),
        .ld_data_in(dm_out),
        .funct3(WB_funct3),
        .wb_data_sel(WB_wb_data_sel),
        .wb_data(WB_wb_data_out)      
    );

endmodule
