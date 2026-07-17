// Module: ALU
// Description: 8-bit ALU supporting ADD, SUB, AND, OR, NOT, MOV
// Inputs: a[7:0], b[7:0], opcode[2:0]
// Outputs: result[7:0], carry, zero_flag
// Author: Gautam Gupta
// Date: June 2026
module alu(
    input [7:0] a,
    input [7:0] b,
    input [2:0] opcode,
    output reg [7:0] result,
    output reg carry,
    output reg zero_flag
);
    always @(*)
       begin
        carry = 0;
        case(opcode)
            3'b000: {carry, result} = a + b; //ADD
            3'b001: {carry, result} = {1'b0, a} - {1'b0, b}; //SUB
            3'b010: result = a & b; //AND
            3'b011: result = a | b; //OR
            3'b100: result = ~ a; //NOT
            3'b101: result = a; //MOV
            default : result = 8'b0;
        endcase
        zero_flag = (result == 8'b0);
       end
endmodule       
    
    