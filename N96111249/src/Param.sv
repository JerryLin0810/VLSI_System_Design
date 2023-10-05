// opcode parameter
`define R_TYPE  7'b0110011
`define I_TYPE  7'b0010011
`define S_TYPE  7'b0100011
`define LOAD    7'b0000011
`define B_TYPE  7'b1100011
`define JALR    7'b1100111
`define JAL     7'b1101111
`define AUIPC   7'b0010111
`define LUI     7'b0110111
`define CSR     7'b1110011

//funct3 parameter
`define ADD_SUB 3'b000
`define ADD     1'b0
`define SUB     1'b1
`define SLL     3'b001
`define SLT     3'b010
`define SLTU    3'b011
`define OP_XOR  3'b100
`define SRL_SRA 3'b101
`define SRL     1'b0
`define SRA     1'b1
`define OP_OR   3'b110
`define OP_AND  3'b111

`define ADDI    3'b000
`define SLTI    3'b010
`define SLTIU   3'b011
`define XORI    3'b100
`define ORI     3'b110
`define ANDI    3'b111
`define SLLI    3'b001
`define SRLI_AI 3'b101
`define SRLI    1'b0
`define SRAI    1'b1

`define BEQ     3'b000
`define BNE     3'b001
`define BLT     3'b100
`define BGE     3'b101
`define BLTU    3'b110
`define BGEU    3'b111

`define MUL     3'b000
`define MULH    3'b001
`define MULHSU  3'b010
`define MULHU   3'b011

`define SB      3'b000
`define SH      3'b001
`define SW      3'b010

`define LB      3'b000
`define LH      3'b001
`define LW      3'b010
`define LBU     3'b100
`define LHU     3'b101