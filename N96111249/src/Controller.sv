module Controller (
    input                   clk,
    input                   rst,
    input           [6:0]   opcode,
    input           [2:0]   func3,
    input           [1:0]   func7,
    input           [4:0]   rs1_index,
    input           [4:0]   rs2_index,
    input           [4:0]   rd_index,
    input                   csr_r_pos,
    input                   jb_condition,
    input           [1:0]   remainder,
    input                   MEM_stall,
    output logic            stall,
    output logic            mul_stall,
    output logic            next_pc_sel,
    output logic            F_chip_sel,
    output logic    [3:0]   F_im_w_en,
    output logic            F_im_r_en, 
    output logic    [6:0]   E_op_out,
    output logic    [2:0]   E_f3_out,
    output logic    [1:0]   E_f7_out,
    output logic            E_jb_op1_sel,
    output logic            E_alu_op1_sel,
    output logic            E_alu_op2_sel,
    output logic    [1:0]   E_rs1_data_sel,
    output logic    [1:0]   E_rs2_data_sel,
    output logic            M_chip_sel,
    output logic    [3:0]   M_dm_w_en, 
    output logic            M_dm_r_en,
    output logic    [2:0]   M_funct3, 
    output logic            M_nop,
    output logic    [1:0]   M_alu_csr_sel,
    output logic            M_csr_cycle_r_en,
    output logic            M_csr_inst_r_en,
    output logic            M_csr_r_pos,
    output logic            W_wb_en,
    output logic    [4:0]   W_rd_out,
    output logic    [2:0]   W_f3_out,
    output logic            W_wb_data_sel
);

    // =======================================================================================
    // pipline registers                                                                    
    // =======================================================================================
    logic           [6:0]   E_op; 
    logic           [6:0]   M_op;
    logic           [6:0]   W_op;
    logic           [2:0]   E_f3;
    logic           [2:0]   M_f3;
    logic           [2:0]   W_f3;
    logic           [4:0]   E_rd;
    logic           [4:0]   M_rd;
    logic           [4:0]   W_rd;
    logic           [4:0]   E_rs1;
    logic           [4:0]   E_rs2;
    logic           [1:0]   E_f7;
    // CSR pipeline register
    // 1 for CSR_INST, 0 for CSR_CYCLE
    logic                   E_csr;
    logic                   M_csr;
    // CSR read position
    // 1 for upper 32-bits, 0 for lower 32-bits
    logic                   E_csr_read_pos;
    logic                   M_csr_read_pos;

    logic                   mul_cycle_count;
    logic                   alu_busy;

    // =======================================================================================
    // hazard signals
    // =======================================================================================
    logic                   is_D_use_rs1;
    logic                   is_D_use_rs2;
    logic                   is_W_use_rd;
    logic                   is_E_rs1_W_rd_overlap;
    logic                   is_E_rs1_M_rd_overlap;
    logic                   is_E_rs2_W_rd_overlap;
    logic                   is_E_rs2_M_rd_overlap;
    logic                   is_E_use_rs1;
    logic                   is_E_use_rs2;
    logic                   is_M_use_rd;
    logic                   is_DE_overlap;
    logic                   is_D_rs1_E_rd_overlap;
    logic                   is_D_rs2_E_rd_overlap;

    // =======================================================================================
    // EX Stage pipeline Registers
    // =======================================================================================
    always_ff @( posedge clk or posedge rst ) begin
        priority if(rst) begin
            E_op    <= 7'b0;
            E_f3    <= 3'b0;
            E_f7    <= 2'b0;
            E_rs1   <= 5'b0;
            E_rs2   <= 5'b0;
            E_rd    <= 5'b0;
            E_csr   <= 1'b0;
            E_csr_read_pos <= 1'b0;
        end
        else begin
            unique if(alu_busy) begin
                E_op    <= E_op;
                E_f3    <= E_f3;
                E_f7    <= E_f7;
                E_rs1   <= E_rs1;
                E_rs2   <= E_rs2;
                E_rd    <= E_rd;
                E_csr   <= E_csr;
                E_csr_read_pos <= E_csr_read_pos;
            end
            else if(stall) begin
                E_op    <= 7'b0;
                E_f3    <= 3'b0;
                E_f7    <= 2'b0;
                E_rs1   <= 5'b0;
                E_rs2   <= 5'b0;
                E_rd    <= 5'b0;
                E_csr   <= 1'b0;
                E_csr_read_pos <= 1'b0;
            end
            else if(next_pc_sel) begin
                E_op    <= 7'b0;
                E_f3    <= 3'b0;
                E_f7    <= 2'b0;
                E_rs1   <= 5'b0;
                E_rs2   <= 5'b0;
                E_rd    <= 5'b0;
                E_csr   <= 1'b0;
                E_csr_read_pos <= 1'b0;
            end
            else begin
                E_op    <= opcode;
                E_f3    <= func3;
                E_f7    <= func7;
                E_rs1   <= rs1_index;
                E_rs2   <= rs2_index;
                E_rd    <= rd_index;
                E_csr   <= rs2_index[1];
                E_csr_read_pos <= csr_r_pos;
            end
        end
    end

    // =======================================================================================
    // MEM Stage pipeline Registers
    // =======================================================================================
    always_ff @(posedge clk or posedge rst) begin
        priority if(rst) begin
            M_op    <= 7'b0;
            M_f3    <= 3'b0;
            M_rd    <= 5'b0;
            M_csr   <= 1'b0;
            M_csr_read_pos <= 1'b0;
        end
        else begin
            unique if(alu_busy) begin
                M_op    <= M_op;
                M_f3    <= M_f3;
                M_rd    <= M_rd;
                M_csr   <= M_csr;
                M_csr_read_pos <= M_csr_read_pos;
            end
            else begin
                M_op    <= E_op;
                M_f3    <= E_f3;
                M_rd    <= E_rd;
                M_csr   <= E_csr;
                M_csr_read_pos <= E_csr_read_pos;
            end
        end
    end

    // =======================================================================================
    // WB Stage pipeline Registers
    // =======================================================================================
    always_ff @(posedge clk or posedge rst) begin
        priority if(rst) begin
            W_op <= 7'b0;
            W_rd <= 5'b0;
            W_f3 <= 3'b0;
        end
        else begin
            unique if(alu_busy) begin
                W_op <= W_op;
                W_f3 <= W_f3;
                W_rd <= W_rd;
            end
            else begin
                W_op <= M_op;
                W_f3 <= M_f3;
                W_rd <= M_rd;
            end
        end
    end

    assign E_op_out = E_op;
    assign E_f3_out = E_f3;
    assign E_f7_out = E_f7;
    assign W_rd_out = W_rd;
    assign W_f3_out = W_f3;
    assign M_funct3 = M_f3;

    // =======================================================================================
    // Instruction memory signal
    // Not allow to write, always allow to read
    // =======================================================================================
    assign F_im_w_en  = 4'b1111;
    assign F_im_r_en  = 1'b1;
  	assign F_chip_sel = 1'b1;

    // =======================================================================================
    // next_pc_sel Logic (jb signal)
    // 1: jump
    // 0: pc+4
    // =======================================================================================
    always_comb begin
        unique case(E_op)
            `JAL:   next_pc_sel = 1'b1;
            `JALR:  next_pc_sel = 1'b1;
            `B_TYPE: begin
                unique if(jb_condition)
                    next_pc_sel = 1'b1;
                else
                    next_pc_sel = 1'b0;
            end
            default:next_pc_sel = 1'b0;
        endcase
    end

    // =======================================================================================
    // ID stage rs1 data select signal
    // =======================================================================================
    always_comb begin
        unique case(opcode)
            `LUI:   is_D_use_rs1 = 1'b0;
            `AUIPC: is_D_use_rs1 = 1'b0;
            `JAL:   is_D_use_rs1 = 1'b0;
            default:is_D_use_rs1 = 1'b1;
        endcase
    end
    always_comb begin
        unique case(W_op)
            `B_TYPE:    is_W_use_rd = 1'b0;
            `S_TYPE:    is_W_use_rd = 1'b0;
            default:    is_W_use_rd = 1'b1;
        endcase
    end

    // =======================================================================================
    // ID stage rs2 data select signal
    // =======================================================================================
    always_comb begin
        unique case(opcode)
            `R_TYPE:    is_D_use_rs2 = 1'b1;
            `S_TYPE:    is_D_use_rs2 = 1'b1;
            `B_TYPE:    is_D_use_rs2 = 1'b1;
            default:    is_D_use_rs2 = 1'b0;
        endcase
    end

    // =======================================================================================
    // EXE stage rs1 data sel signal
    // EXE and MEM overlap:     MEM stage forward data  (1)
    // EXE and WB overlap:      WB stage forward data   (0)
    // EXE, MEM and WB overlap: MEM stage forward data  (1)
    // No overlap:              rs2 data                (2)
    // =======================================================================================
    always_comb begin
        unique case(E_op)
            `LUI:   is_E_use_rs1 = 1'b0;
            `AUIPC: is_E_use_rs1 = 1'b0;
            `JAL:   is_E_use_rs1 = 1'b0;
            default:is_E_use_rs1 = 1'b1;
        endcase
    end
    always_comb begin
        unique case(M_op)
            `B_TYPE:    is_M_use_rd = 1'b0;
            `S_TYPE:    is_M_use_rd = 1'b0;
            default:    is_M_use_rd = 1'b1;
        endcase
    end
    assign is_E_rs1_W_rd_overlap = (is_E_use_rs1 && is_W_use_rd && (E_rs1 == W_rd) && (W_rd != 5'b0))? 1'b1 : 1'b0;
    assign is_E_rs1_M_rd_overlap = (is_E_use_rs1 && is_M_use_rd && (E_rs1 == M_rd) && (M_rd != 5'b0))? 1'b1 : 1'b0;
    always_comb begin
        unique case({is_E_rs1_M_rd_overlap, is_E_rs1_W_rd_overlap})
            2'b10:  E_rs1_data_sel = 2'b01;
            2'b01:  E_rs1_data_sel = 2'b00;
            2'b11:  E_rs1_data_sel = 2'b01;
            default:E_rs1_data_sel = 2'b10;
        endcase
    end

    // =======================================================================================
    // EXE stage rs2 data select signal
    // EXE and MEM overlap:     MEM stage forward data  (1)
    // EXE and WB overlap:      WB stage forward data   (0)
    // EXE, MEM and WB overlap: MEM stage forward data  (1)
    // No overlap:              rs2 data                (2)
    // =======================================================================================
    always_comb begin
        unique case(E_op)
            `R_TYPE:    is_E_use_rs2 = 1'b1;
            `S_TYPE:    is_E_use_rs2 = 1'b1;
            `B_TYPE:    is_E_use_rs2 = 1'b1;
            default:    is_E_use_rs2 = 1'b0;
        endcase
    end
    assign is_E_rs2_W_rd_overlap = (is_E_use_rs2 && is_W_use_rd && (E_rs2 == W_rd) && (W_rd != 5'b0))? 1'b1 : 1'b0;
    assign is_E_rs2_M_rd_overlap = (is_E_use_rs2 && is_M_use_rd && (E_rs2 == M_rd) && (M_rd != 5'b0))? 1'b1 : 1'b0;
    always_comb begin
        unique case({is_E_rs2_M_rd_overlap, is_E_rs2_W_rd_overlap})
            2'b10:  E_rs2_data_sel = 2'b01;
            2'b01:  E_rs2_data_sel = 2'b00;
            2'b11:  E_rs2_data_sel = 2'b01;
            default:E_rs2_data_sel = 2'b10;
        endcase
    end

    // =======================================================================================
    // stall signal
    // =======================================================================================
    assign is_D_rs1_E_rd_overlap = (is_D_use_rs1 && (rs1_index == E_rd) && (E_rd != 5'b0))? 1'b1 : 1'b0;
    assign is_D_rs2_E_rd_overlap = (is_D_use_rs2 && (rs2_index == E_rd) && (E_rd != 5'b0))? 1'b1 : 1'b0;
    assign is_DE_overlap = (is_D_rs1_E_rd_overlap || is_D_rs2_E_rd_overlap)? 1'b1 : 1'b0;
    assign stall = ((E_op == `LOAD) && is_DE_overlap)? 1'b1 : 1'b0;

    // =======================================================================================
    // MUL stall signal
    // =======================================================================================
    always_comb begin
        unique if((E_op == `R_TYPE) && E_f7[0] && (! mul_cycle_count))
            alu_busy = 1'b1; 
        else
            alu_busy = 1'b0;
    end
    always_ff @( posedge clk or posedge rst ) begin
        priority if(rst)
            mul_cycle_count <= 1'b0;
        else begin
            unique if((E_op == `R_TYPE) && E_f7[0])
                mul_cycle_count <= mul_cycle_count + 1'b1;
            else
                mul_cycle_count <= mul_cycle_count;
        end
    end
    assign mul_stall = alu_busy;

    // =======================================================================================
    // WB stage write back to RegFile signal
    // =======================================================================================
    always_comb begin
        unique case(W_op)
            `B_TYPE:    W_wb_en = 1'b0;
            `S_TYPE:    W_wb_en = 1'b0;
            default:    W_wb_en = 1'b1;
        endcase
    end

    // =======================================================================================
    // EXE stage jump branch op1 select signal
    // 1 for rs1, 0 for pc
    // =======================================================================================
    assign E_jb_op1_sel = (E_op == `JALR)? 1'b1 : 1'b0;
    
    // =======================================================================================
    // EXE stage alu op1 select signal
    // 1 for pc, 0 for rs1
    // =======================================================================================
    always_comb begin
        unique case(E_op)
            `AUIPC:     E_alu_op1_sel = 1'b1;
            `JAL:       E_alu_op1_sel = 1'b1;
            `JALR:      E_alu_op1_sel = 1'b1;
            default:    E_alu_op1_sel = 1'b0; 
        endcase
    end

    // =======================================================================================
    // EXE stage alu op2 select signal
    // 1 for rs2, 0 for imme
    // =======================================================================================
    always_comb begin
        unique case(E_op)
            `R_TYPE:    E_alu_op2_sel = 1'b1;
            `B_TYPE:    E_alu_op2_sel = 1'b1;
            default:    E_alu_op2_sel = 1'b0;
        endcase
    end

    // =======================================================================================
    // MEM stage data memory write enable signal
    // =======================================================================================
    assign M_chip_sel = 1'b1;
    
    always_comb begin
        priority if(E_op == `S_TYPE) begin
            unique case(E_f3)
                `SB: begin
                    unique case(remainder)
                        2'd1:   M_dm_w_en = 4'b1101;
                        2'd2:   M_dm_w_en = 4'b1011;
                        2'd3:   M_dm_w_en = 4'b0111;
                        default:M_dm_w_en = 4'b1110;
                    endcase
                end
                `SH: begin
                    unique case(remainder)
                        2'd1:   M_dm_w_en = 4'b1001;
                        2'd2:   M_dm_w_en = 4'b0011;
                        default:M_dm_w_en = 4'b1100;
                    endcase 
                end
                default:        M_dm_w_en = 4'b0000;
            endcase
        end
        else
            M_dm_w_en = 4'b1111;
    end

    // =======================================================================================
    // MEM stage data memory read enable signal
    // =======================================================================================
    always_comb begin
        unique if((M_op == `LOAD) && (!MEM_stall))
            M_dm_r_en = 1'b1;
        else    
            M_dm_r_en = 1'b0;
    end

    // =======================================================================================
    // MEM stage CSR register read enable signal
    // =======================================================================================

    always_comb begin
        unique if((M_op == `CSR) && (! M_csr))
            M_csr_cycle_r_en = 1'b1;
        else
            M_csr_cycle_r_en = 1'b0;
    end
    always_comb begin
        unique if((M_op == `CSR) && (M_csr))
            M_csr_inst_r_en = 1'b1;
        else
            M_csr_inst_r_en = 1'b0;
    end
    assign M_csr_r_pos = M_csr_read_pos;
    assign M_nop = M_op[0];

    // =======================================================================================
    // MEM stage CSR register read enable signal
    // 0: alu_out
    // 1: CSR_INST
    // 2: CSR_CYCLE
    // =======================================================================================
    always_comb begin
        priority if(M_op != `CSR)
            M_alu_csr_sel = 2'b00;
        else begin
            unique case(M_csr)
                1'b1:   M_alu_csr_sel = 2'b01;
                default:M_alu_csr_sel = 2'b10;
            endcase
        end
    end

    // =======================================================================================
    // WB stage write back (to RegFile) data select signal
    // 1 for ld_data, 0 for alu_out
    // =======================================================================================
    always_comb begin
        unique if(W_op == `LOAD)
            W_wb_data_sel = 1'b1;
        else   
            W_wb_data_sel = 1'b0;
    end
    
endmodule
