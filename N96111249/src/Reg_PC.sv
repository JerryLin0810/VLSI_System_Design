module Reg_PC (
    input                   clk,
    input                   rst,
    input                   stall,
    input                   mul_stall,
    input           [31:0]  next_pc,
	output logic	[31:0]	current_pc
);
	
    logic           [31:0]  pc_reg;

    always_ff @(posedge clk or posedge rst) begin
        priority if(rst)
            pc_reg <= 32'b0;
        else begin
            unique if(stall || mul_stall)
                pc_reg <= pc_reg;
            else
		        pc_reg <= next_pc;
        end
    end

	assign current_pc = pc_reg;

endmodule
