module control_unit(
    input [2:0] opcode,
    output reg [2:0] alu_op, // alu opcode doesn't include '110' and '111'
    output reg mem_read,
    output reg mem_write,
    output reg reg_write,
    output reg jump_enable,
    output reg wb_select //writeback select: =0 while writing back from ALU ; =1 while writing back from memory
);



    always @(*) begin
        // Initializing all signals with 0 value
        alu_op = 3'b000;
        mem_read = 1'b0;
        mem_write = 1'b0;
        reg_write = 1'b0;
        jump_enable = 1'b0;
        wb_select = 1'b0;

        case (opcode)
            3'b000: begin alu_op=3'b000; reg_write=1; end // ADD
            3'b001: begin alu_op=3'b001; reg_write=1; end // SUB
            3'b010: begin alu_op=3'b010; reg_write=1; end // AND
            3'b011: begin alu_op=3'b011; reg_write=1; end // OR
            3'b100: begin alu_op=3'b100; reg_write=1; end // NOT
            3'b101: begin mem_write=1; end                // STORE(store data in data_memory)
            // For STORE Rs, addr — the source register field occupies the same bit position as Rd does for other R-type instructions, 
            // but it's now functioning as a source, not a destination
            // STORE format: [15:13]opcode | [12:10]unused | [9:7]Rs | [6:4]unused | mem_addr in [7:0]
            3'b110: begin mem_read=1'b1; reg_write=1; wb_select=1'b1; end // LOAD
            3'b111: begin jump_enable=1'b1; end           // JUMP
        endcase
    end
endmodule
