`timescale 1ns/1ps

module pipelined_top_tb;

    reg clk;
    reg rst;

    // Instantiate pipelined processor
    pipelined_top uut(
        .clk(clk),
        .rst(rst)
    );

    // Clock — 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // Monitor key pipeline signals every cycle
    initial begin
        $monitor("T=%0t | PC=%0d | IF/ID=%b | ID/EX_rd=R%0d | EX/MEM_res=%0d | WB_rd=R%0d | fwdA=%b fwdB=%b | stall=%b | flush=%b",
                  $time,
                  uut.pc_out,
                  uut.if_id_instruction[15:13],  // just opcode for readability
                  uut.id_ex_rd,
                  uut.ex_mem_alu_result,
                  uut.mem_wb_rd,
                  uut.forward_A,
                  uut.forward_B,
                  uut.stall_if_id,
                  uut.flush_id_ex);
    end

    initial begin
        $dumpfile("pipelined_top_tb.vcd");
        $dumpvars(0, pipelined_top_tb);

        // Reset for 2 cycles
        rst = 1;
        #20;
        rst = 0;
        uut.dmem_inst.memory[10] = 8'd42;
        uut.dmem_inst.memory[20] = 8'd0;
        // Run for 40 cycles — enough to see
        // 2 full loops including stall and forwarding
        #400;

        $finish;
    end

endmodule