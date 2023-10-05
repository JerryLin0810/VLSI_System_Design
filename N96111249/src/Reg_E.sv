module Reg_E (
    input                   clk,
    input                   rst,
    input                   stall,
    input                   mul_stall,
    input                   jb,
    input           [31:0]  pc,
    input           [4:0]   rs1_index,
    input           [4:0]   rs2_index,
    input           [31:0]  inst,
    output logic    [4:0]   rs1_index_out,
    output logic    [4:0]   rs2_index_out,
    output logic    [31:0]  pc_out,
    output logic    [31:0]  inst_out
);

    always_ff @( posedge clk or posedge rst ) begin
        priority if(rst)
            pc_out <= 32'b0;
        else begin
            unique if(stall || jb)
                pc_out <= 32'b0;
            else if(mul_stall)
                pc_out <= pc_out;
            else
                pc_out <= pc;
        end
    end

    always_ff @( posedge clk or posedge rst ) begin
        priority if(rst)
            rs1_index_out <= 5'b0;
        else begin
            unique if(stall || jb)
                rs1_index_out <= 5'b0;
            else if(mul_stall)
                rs1_index_out <= rs1_index_out;
            else
                rs1_index_out <= rs1_index;
        end
    end

    always_ff @( posedge clk or posedge rst ) begin
        priority if(rst)
            rs2_index_out <= 5'b0;
        else begin
            unique if(stall || jb)
                rs2_index_out <= 5'b0;
            else if(mul_stall)
                rs2_index_out <= rs2_index_out;
            else
                rs2_index_out <= rs2_index;
        end
    end

    always_ff @( posedge clk or posedge rst ) begin
        priority if(rst)
            inst_out <= 32'b0;
        else begin
            unique if(stall || jb)
                inst_out <= 32'b0;
            else if(mul_stall)
                inst_out <= inst;
            else
                inst_out <= inst;
        end
    end

endmodule
