module CSR_INST (
    input                   clk,
    input                   rst,
    input                   nop,        // ACTIVE LOW 
    input                   mul_stall,
    input                   inst_r_en,
    input                   inst_r_pos,
    output logic    [31:0]  csr_inst_out   
);

    logic   [63:0]  INST_reg;

    always_ff @( posedge clk or posedge rst ) begin
        priority if(rst)
            INST_reg <= 64'b0;
        else begin
            unique if(nop && (!mul_stall))
                INST_reg <= INST_reg + 64'b1;
            else   
                INST_reg <= INST_reg;
        end
    end

    always_comb begin
        priority if(inst_r_en) begin
            unique case(inst_r_pos)
                1'b1:   csr_inst_out = INST_reg[63:32];
                default:csr_inst_out = INST_reg[31:0];
            endcase
        end
        else
            csr_inst_out = 32'b0;
    end

endmodule
