module LD_Filter (
    input           [2:0]   func3,
    input           [31:0]  ld_data,
    output logic    [31:0]  ld_data_f
);

    always_comb begin
        unique case(func3)
            `LB:    ld_data_f = { {24{ld_data[7]}}, ld_data[7:0]};
            `LH:    ld_data_f = { {16{ld_data[15]}}, ld_data[15:0]};
            `LW:    ld_data_f = ld_data;
            `LBU:   ld_data_f = { 24'b0, ld_data[7:0]};
            default:ld_data_f = { 16'b0, ld_data[15:0]};
        endcase
    end
    
endmodule 