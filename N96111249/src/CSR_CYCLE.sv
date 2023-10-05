module CSR_CYCLE (
    input                   clk,
    input                   rst,
    input                   cycle_r_en,  // SRC_CYCLE read enable
    input                   cycle_r_pos, // SRC_CYCLE read position, 1 for MSB and 0 for LSB
    output logic    [31:0]  cycle_out    // SRC_CYCLE data output
);

    logic           [63:0]  CYCLE;  // CYCLE register, record CPU total cycles
    logic           [31:0]  cycle_out_buf;

    always_ff @( posedge clk or posedge rst ) begin
        priority if(rst)
            CYCLE <= 64'b0;
        else
            CYCLE <= CYCLE + 64'b1;
    end

    always_comb begin
        unique case(cycle_r_pos)
            1'b1:   cycle_out_buf = CYCLE[63:32];
            default:cycle_out_buf = CYCLE[31:0];
        endcase
    end

    always_comb begin 
        priority if(cycle_r_en)
            cycle_out = cycle_out_buf - 32'd3;
        else
            cycle_out = 32'b0;
    end
    
endmodule