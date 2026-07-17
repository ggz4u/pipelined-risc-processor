//Instruction Memory: ROM/Flash memory; stroes bootloader and program instructions(fixed size); CANNOT be OVERWRITTEN(NON VOLATILE)
//PC → [Instruction Memory] → instruction bits → [Decoder]
//[15:13] — opcode    (3 bits — 8 possible instructions)
// [12:10] — dest reg  (3 bits — Rd)
// [9:7]   — src reg1  (3 bits — Rs1)
// [6:4]   — src reg2  (3 bits — Rs2)
// [3:0]   — unused / immediate (4 bits)

module instruction_memory(
    input [7:0] addr,
    output reg [15:0] instruction
);
    //Memory - 256 locations of 16 bits each (256 x 16 bits)[512B instruction memory]
    reg [15:0] memory [255:0];
    integer i;
    //Preload the instruction memory with some instructions
    initial begin
        // Format: opcode(3) | Rd(3) | Rs1(3) | Rs2(3) | unused(4)
        // ADD R1, R2, R3 → opcode=000, Rd=001, Rs1=010, Rs2=011
        
        for(i=0; i<256; i=i+1) begin
            memory[i] = 16'b0000000000000000; // Initialize all memory to NOP(No operation) (or 0)
        end
            // ── Test Program ──
    // Instruction format reference:
    // R-type:  [15:13]opcode | [12:10]rd | [9:7]rs1 | [6:4]rs2 | [3:0]unused
    // LOAD:    [15:13]opcode | [12:10]rd | [9:8]unused | [7:0]mem_addr
    // STORE:   [15:13]opcode | [12:10]unused | [9:7]rs1 | [6:0]mem_addr(7bit)
    // JMP:     [15:13]opcode | [12:8]unused | [7:0]jump_addr

    // Instr 0: LOAD R1, addr 10
    // opcode=110, rd=001, addr=00001010
    memory[0] = 16'b110_001_00_00001010;

    // Instr 1: ADD R2, R1, R1
    // opcode=000, rd=010, rs1=001, rs2=001
    // Load-use hazard with instr 0 → HDU inserts 1 stall bubble
    memory[1] = 16'b000_010_001_001_0000;

    // Instr 2: ADD R3, R2, R1
    // opcode=000, rd=011, rs1=010, rs2=001
    // EX/MEM forward: R2 comes from instr 1 result
    memory[2] = 16'b000_011_010_001_0000;

    // Instr 3: STORE R3, addr 20
    // opcode=101, rs1=011 (R3), addr=0010100 (7-bit = 20)
    // MEM/WB forward: R3 comes from instr 2 result
    memory[3] = 16'b101_000_011_0010100;

    // Instr 4: LOAD R4, addr 20
    // opcode=110, rd=100, addr=00010100
    // Verify STORE wrote correctly
    memory[4] = 16'b110_100_00_00010100;

    // Instr 5: JMP to addr 0
    // opcode=111, jump_addr=00000000
    memory[5] = 16'b111_00000_00000000;

    end

    always @(*) begin
        instruction = memory[addr];
    end
endmodule




