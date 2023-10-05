module RegFile (
    input                       clk,
    input                       wb_en,
    input           [31:0]      wb_data,
    input           [4:0]       rd_index,
    input           [4:0]       rs1_index,
    input           [4:0]       rs2_index,
    output logic    [31:0]      rs1_data_out,
    output logic    [31:0]      rs2_data_out
);

    parameter                   bits = 32;
    parameter                   n_reg = 32;
    integer                     i;

    logic           [bits-1:0]  regs [n_reg-1:0];

    assign rs1_data_out = regs[rs1_index];
    assign rs2_data_out = regs[rs2_index];
    
    always_ff @( posedge clk ) begin
        regs[0] <= 32'b0;
        priority if(wb_en && (rd_index != 5'b0))
            regs[rd_index] <= wb_data;
        else begin
            for(i=1; i<32; i=i+1)
                regs[i] <= regs[i]; 
        end
    end
    

endmodule
