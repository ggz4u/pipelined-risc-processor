<<<<<<< HEAD
module if_id_reg_tb;
    
    reg clk, rst, stall, flush;
    reg [7:0] pc_in;
    reg [15:0] instr_in;
    wire [7:0] pc_out;
    wire [15:0] instr_out;

    if_id_reg uut(
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .flush(flush),
        .pc_in(pc_in),
        .instr_in(instr_in),
        .pc_out(pc_out),
        .instr_out(instr_out)
    );

    initial begin
        $dumpfile("if_id_reg_tb.vcd");
        $dumpvars(0, if_id_reg_tb);
        $monitor("Time: %2d | rst: %b | stall: %b | flush: %b | pc_in: %h | instr_in: %h | pc_out: %h | instr_out: %h", 
                 $time, rst, stall, flush, pc_in, instr_in, pc_out, instr_out);
    end

    // Clock generation
    always #5 clk = ~clk;
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        stall = 0;
        flush = 0;
        pc_in = 8'b00000000;
        instr_in = 16'b0000000000000000;

        // Reset the register
        #10 rst = 0;

        // Test normal operation
        #10 pc_in = 8'b00000001; instr_in = 16'b0000000000000001; // Load instruction
        #10 pc_in = 8'b00000010; instr_in = 16'b0000000000000010; // Load instruction

        // Test stall condition
        #10 stall = 1; pc_in = 8'b00000011; instr_in = 16'b0000000000000011; // Should hold previous values
        #10 stall = 0; // Resume normal operation

        // Test flush condition
        #10 flush = 1; // Should clear the register
        #10 flush = 0; // Resume normal operation

        // Finish simulation
        #10 $finish;
    end
=======
module if_id_reg_tb;
    
    reg clk, rst, stall, flush;
    reg [7:0] pc_in;
    reg [15:0] instr_in;
    wire [7:0] pc_out;
    wire [15:0] instr_out;

    if_id_reg uut(
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .flush(flush),
        .pc_in(pc_in),
        .instr_in(instr_in),
        .pc_out(pc_out),
        .instr_out(instr_out)
    );

    initial begin
        $dumpfile("if_id_reg_tb.vcd");
        $dumpvars(0, if_id_reg_tb);
        $monitor("Time: %2d | rst: %b | stall: %b | flush: %b | pc_in: %h | instr_in: %h | pc_out: %h | instr_out: %h", 
                 $time, rst, stall, flush, pc_in, instr_in, pc_out, instr_out);
    end

    // Clock generation
    always #5 clk = ~clk;
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        stall = 0;
        flush = 0;
        pc_in = 8'b00000000;
        instr_in = 16'b0000000000000000;

        // Reset the register
        #10 rst = 0;

        // Test normal operation
        #10 pc_in = 8'b00000001; instr_in = 16'b0000000000000001; // Load instruction
        #10 pc_in = 8'b00000010; instr_in = 16'b0000000000000010; // Load instruction

        // Test stall condition
        #10 stall = 1; pc_in = 8'b00000011; instr_in = 16'b0000000000000011; // Should hold previous values
        #10 stall = 0; // Resume normal operation

        // Test flush condition
        #10 flush = 1; // Should clear the register
        #10 flush = 0; // Resume normal operation

        // Finish simulation
        #10 $finish;
    end
>>>>>>> 9d7d4de1716e196a3a5cb570e5450076a7de0be8
endmodule