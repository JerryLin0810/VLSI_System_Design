module Reg_D(
    input                   clk,
    input                   rst,
    input           [31:0]  pc,
    input                   stall,
    input                   mul_stall,
    input                   jb,
    input           [31:0]  inst,
    output logic    [31:0]  pc_out,
    output logic    [31:0]  inst_out,
    output logic    [1:0]   inst_sel
);

    logic   [31:0]  inst_reg;

    always_ff @( posedge clk or posedge rst ) begin
        priority if(rst)
            pc_out <= 32'b0;
        else begin
            unique if(stall || mul_stall)
                pc_out <= pc_out;
            else if(jb)
                pc_out <= 32'b0;
            else
                pc_out <= pc;
        end
    end

    always_ff @( posedge clk or posedge rst ) begin
        priority if(rst)
            inst_reg <= 32'b0;
        else
            inst_reg <= inst;
    end
 
    always_ff @( posedge clk or posedge rst ) begin
        priority if(rst)
            inst_sel <= 2'd2;   // initial 0
        else begin
            priority if(mul_stall)
                inst_sel <= 2'd1;
            else begin
                unique case({stall, jb})
                    2'b10:  inst_sel <= 2'd1;   // stall
                    2'b01:  inst_sel <= 2'd2;   // jb
                    default:inst_sel <= 2'd0;   // normal
                endcase
            end
        end
    end

    assign inst_out = inst_reg;

endmodule
