`timescale 1ns/1ps

module hazard_detection_unit_tb;

    // 1. Declare inputs as registers (reg)
    reg id_ex_mem_read;
    reg [2:0] id_ex_rd;
    reg [2:0] if_id_rs1;
    reg [2:0] if_id_rs2;

    // 2. Declare outputs as wires
    wire stall_if_id;
    wire stall_id_ex;
    wire flush_id_ex;
    wire pc_write;

    // 3. Instantiate the Unit Under Test (UUT)
    hazard_detection_unit uut (
        .id_ex_mem_read(id_ex_mem_read),
        .id_ex_rd(id_ex_rd),
        .if_id_rs1(if_id_rs1),
        .if_id_rs2(if_id_rs2),
        .stall_if_id(stall_if_id),
        .stall_id_ex(stall_id_ex),
        .flush_id_ex(flush_id_ex),
        .pc_write(pc_write)
    );

    // 4. Waveform generation and console tracking
    initial begin
        $dumpfile("hazard_detection_unit_tb.vcd");
        $dumpvars(0, hazard_detection_unit_tb);
        
        // Simple monitor layout to visually check outputs
        $monitor("Time=%2d | mem_read=%b rd=%d rs1=%d rs2=%d | stall_if_id=%b stall_id_ex=%b flush_id_ex=%b pc_write=%b", 
                 $time, id_ex_mem_read, id_ex_rd, if_id_rs1, if_id_rs2, 
                 stall_if_id, stall_id_ex, flush_id_ex, pc_write);
    end

    // 5. Linear Stimulus Timeline
    initial begin
        // --- Initialize Inputs at Time 0 ---
        id_ex_mem_read = 0;
        id_ex_rd   = 3'd0;
        if_id_rs1  = 3'd0;
        if_id_rs2  = 3'd0;
        #10; // Wait a brief moment

        // --- Test 1: No hazard, normal flow ---
        // Expected: stall/flush=0, pc_write=1
        id_ex_mem_read = 1'b0; 
        id_ex_rd   = 3'd2;
        if_id_rs1  = 3'd2;
        if_id_rs2  = 3'd3;
        #10;

        // --- Test 2: LOAD-USE hazard on rs1 ---
        // Expected: stall_if_id=1, stall_id_ex=1, flush_id_ex=1, pc_write=0
        id_ex_mem_read = 1'b1;
        id_ex_rd   = 3'd2; // R2
        if_id_rs1  = 3'd2; // R2 (Match!)
        if_id_rs2  = 3'd3;
        #10;

        // --- Test 3: LOAD-USE hazard on rs2 ---
        // Expected: stall_if_id=1, stall_id_ex=1, flush_id_ex=1, pc_write=0
        id_ex_mem_read = 1'b1;
        id_ex_rd   = 3'd3; // R3
        if_id_rs1  = 3'd1;
        if_id_rs2  = 3'd3; // R3 (Match!)
        #10;

        // --- Test 4: LOAD but no register match ---
        // Expected: stall/flush=0, pc_write=1
        id_ex_mem_read = 1'b1;
        id_ex_rd   = 3'd5; // R5
        if_id_rs1  = 3'd2; 
        if_id_rs2  = 3'd3; // No match
        #10;

        // --- Test 5: LOAD to R0 ---
        // Expected: stall/flush=0, pc_write=1 (R0 hardwired to 0, no dependency)
        id_ex_mem_read = 1'b1;
        id_ex_rd   = 3'd0; // R0
        if_id_rs1  = 3'd0; 
        if_id_rs2  = 3'd4;
        #10;

        // --- Test 6: Hazard clears next cycle ---
        // Phase A: Force a hazard
        id_ex_mem_read = 1'b1;
        id_ex_rd   = 3'd4;
        if_id_rs1  = 3'd4;
        if_id_rs2  = 3'd1;
        #10; // Let the stalls assert for 10 time units
        
        // Phase B: Clear the hazard condition
        // Expected: Stalls immediately drop to 0, pc_write restores to 1
        id_ex_mem_read = 1'b0; 
        #10;

        // --- End Simulation ---
        $finish;
    end

endmodule