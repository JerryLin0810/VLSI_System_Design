module Mux3_1 (
    input           [31:0]  source1,
    input           [31:0]  source2,
    input           [31:0]  source3,
    input           [1:0]   sel,
    output logic    [31:0]  mux_out
);

    always_comb begin
        unique case(sel)
            2'b00:  mux_out = source1;
            2'b01:  mux_out = source2;
            default:mux_out = source3;
        endcase
    end
    
endmodule