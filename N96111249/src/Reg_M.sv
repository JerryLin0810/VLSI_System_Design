module Reg_M (
    input                   clk,
    input                   rst,
    input                   mul_stall,
    input           [31:0]  alu_result,
    output logic    [31:0]  alu_result_out,
    output logic            MEM_stall
);
    
    always_ff @( posedge clk or posedge rst ) begin
        priority if(rst)
            alu_result_out <= 32'b0;
        else begin
            priority if(mul_stall)
                alu_result_out <= alu_result_out;
            else
                alu_result_out <= alu_result;
        end
    end

    always_ff @( posedge clk or posedge rst ) begin
        priority if(rst)
            MEM_stall <= 1'b0;
        else    
            MEM_stall <= mul_stall;
    end

endmodule
