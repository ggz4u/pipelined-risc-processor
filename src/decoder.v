module decoder(
    input [15:0] instruction,
    
    output [2:0] opcode,
    output [2:0] rd,
    output [2:0] rs1,
    output [2:0] rs2,
    
    // Load and JMP fields
    output [7:0] immediate_addr,
    
    //instruction type flags
    output is_jmp,
    output is_load,
    output is_rtype,
    output is_store
    );

    assign opcode = instruction[15:13];
    assign rd = instruction[12:10];
    assign rs1 = instruction[9:7];
    assign rs2 = instruction[6:4];
    assign immediate_addr = instruction[7:0];

    //instruction type detection
    assign is_jmp = (opcode == 3'b111);
    assign is_load = (opcode == 3'b110);
    assign is_store = (opcode == 3'b101);
    assign is_rtype = !(is_jmp || is_load || is_store);
    //these flags are 'wire' type because they are used as control signals for executing the instructions.
    //So live values of these flags are needed in the next clock cycle.
endmodule