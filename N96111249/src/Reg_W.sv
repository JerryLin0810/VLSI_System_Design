module Reg_W (
    input                   clk,
    input                   rst,
    input                   mul_stall,
    input           [31:0]  alu_data_in,
    input           [31:0]  ld_data_in,
    output logic    [31:0]  alu_data_out,
    output logic    [31:0]  ld_data_out
);

    always_ff @(posedge clk or posedge rst) begin
        priority if(rst)
            alu_data_out <= 32'b0;
        else begin
            priority if(mul_stall)
                alu_data_out <= alu_data_out;
            else
                alu_data_out <= alu_data_in;
        end
    end

    always_ff @( posedge clk or posedge rst ) begin
        priority if(rst)
            ld_data_out <= 32'b0;
        else 
            ld_data_out <= ld_data_in;
    end
    
endmodule
