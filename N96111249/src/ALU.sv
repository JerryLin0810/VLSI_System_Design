module ALU (
    input                   clk,
    input                   rst,
    input           [6:0]   opcode,
    input           [2:0]   func3,
    input           [1:0]   func7,
    input           [31:0]  op1,
    input           [31:0]  op2,
    output logic            jb_condition,
    output logic    [31:0]  alu_out,
    output logic    [13:0]  dm_addr,
    output logic    [1:0]   remainder
);

    logic           [63:0]  product;
    logic           [31:0]  BRANCH_TRUE;
    logic           [31:0]  BRANCH_FALSE;
    logic           [31:0]  op1_reg;
    logic           [31:0]  op2_reg;

    always_ff @( posedge clk or posedge rst ) begin
        priority if(rst) begin
            op1_reg <= 32'b0;
            op2_reg <= 32'b0;
        end
        else begin
            op1_reg <= op1;
            op2_reg <= op2;
        end
    end

    always_comb begin
        unique case(func3)
            `MULH:  product = $signed(op1_reg) * $signed(op2_reg);
            `MULHSU:product = $signed(op1_reg) * $signed({1'b0, op2_reg});
            default:product = op1_reg * op2_reg;
        endcase
    end

    assign BRANCH_FALSE = 32'b0;
    assign BRANCH_TRUE  = 32'b1;

    always_comb begin
        unique case(opcode)
            `R_TYPE: begin
                unique case(func7[0])
                    1'b1: begin
                        unique case(func3)
                            `MUL:   alu_out = product[31:0];
                            default:alu_out = product[63:32];
                        endcase
                    end
                    default: begin
                        unique case(func3)
                            `ADD_SUB: begin
                                unique case(func7[1])
                                    `ADD:   alu_out = op1 + op2;
                                    default:alu_out = op1 - op2;
                                endcase
                            end
                            `SLL:   alu_out = op1 << op2[4:0];
                            `SLT:   alu_out = ($signed(op1) < $signed(op2))? BRANCH_TRUE : BRANCH_FALSE;
                            `SLTU:  alu_out = (op1 < op2)? BRANCH_TRUE : BRANCH_FALSE;
                            `OP_XOR:alu_out = op1 ^ op2;
                            `SRL_SRA: begin
                                unique case(func7[1])
                                    `SRL:   alu_out = op1 >> op2[4:0];
                                    default:alu_out = $signed(op1) >>> op2[4:0];
                                endcase
                            end
                            `OP_OR: alu_out = op1 | op2;
                            default:alu_out = op1 & op2;
                        endcase
                    end
                endcase
            end
            `I_TYPE: begin
                unique case(func3)
                    `ADDI:  alu_out = op1 + op2;
                    `SLTI:  alu_out = ($signed(op1) < $signed(op2))? BRANCH_TRUE : BRANCH_FALSE;
                    `SLTIU: alu_out = (op1 < op2)? BRANCH_TRUE : BRANCH_FALSE;
                    `XORI:  alu_out = op1 ^ op2;
                    `ORI:   alu_out = op1 | op2;
                    `ANDI:  alu_out = op1 & op2;
                    `SLLI:  alu_out = op1 << op2[4:0];
                    default: begin
                        unique case(func7[1])
                            `SRLI:  alu_out = op1 >> op2[4:0];
                            default:alu_out = $signed(op1) >>> op2[4:0];
                        endcase
                    end
                endcase
            end
            `S_TYPE: alu_out = op1 + op2;
            `LOAD:   alu_out = op1 + op2;
            `B_TYPE: begin
                unique case(func3)
                    `BEQ:   alu_out = (op1 == op2)? BRANCH_TRUE : BRANCH_FALSE;
                    `BNE:   alu_out = (op1 == op2)? BRANCH_FALSE : BRANCH_TRUE;
                    `BLT:   alu_out = ($signed(op1) < $signed(op2))? BRANCH_TRUE : BRANCH_FALSE;
                    `BGE:   alu_out = ($signed(op1) < $signed(op2))? BRANCH_FALSE : BRANCH_TRUE;
                    `BLTU:  alu_out = (op1 < op2)? BRANCH_TRUE : BRANCH_FALSE;
                    `BGEU:  alu_out = (op1 < op2)? BRANCH_FALSE : BRANCH_TRUE;
                    default:alu_out = 32'b0;
                endcase
            end
            `JALR:  alu_out = op1 + 32'd4;
            `JAL:   alu_out = op1 + 32'd4;
            `LUI:   alu_out = op2;
            `AUIPC: alu_out = op1 + op2;  
            default:alu_out = 32'b0;
        endcase
    end

    assign jb_condition = alu_out[0];
    assign dm_addr = alu_out[15:2];
    assign remainder = alu_out[1:0];

endmodule