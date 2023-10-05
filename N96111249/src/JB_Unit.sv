module JB_Unit (
    input           [31:0]  op1,
    input           [31:0]  op2,
    output  logic   [31:0]  jb_out
);
    logic   [31:0]  tmp_jb;

    assign tmp_jb = op1 + op2;
    assign jb_out = {tmp_jb[31:1], 1'b0};
     
endmodule
