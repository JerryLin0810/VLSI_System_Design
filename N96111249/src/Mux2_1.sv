module Mux2_1 (
    input           [31:0]  source1,
    input           [31:0]  source2,
    input                   sel,
    output logic    [31:0]  mux_out
);
    
    always_comb begin
        unique case(sel)
            1'b1:   mux_out = source1;
            default:mux_out = source2;
        endcase
    end
    
endmodule