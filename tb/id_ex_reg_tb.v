module id_ex_reg_tb;

    // ---- Inputs to the DUT ----
    reg clk, rst, stall, flush;
    reg [7:0] pc_in;
    reg [2:0] alu_op_in;
    reg reg_write_in;
    reg mem_read_in;
    reg mem_write_in;
    reg wb_select_in;
    reg jump_enable_in;
    reg [7:0] read_data1_in;
    reg [7:0] read_data2_in;
    reg [2:0] rd_in;
    reg [2:0] rs1_in;
    reg [2:0] rs2_in;
    reg [7:0] imm_addr_in;

    // ---- Outputs from the DUT ----
    wire [7:0] pc_out;
    wire [2:0] alu_op_out;
    wire reg_write_out;
    wire mem_read_out;
    wire mem_write_out;
    wire wb_select_out;
    wire jump_enable_out;
    wire [7:0] read_data1_out;
    wire [7:0] read_data2_out;
    wire [2:0] rd_out;
    wire [2:0] rs1_out;
    wire [2:0] rs2_out;
    wire [7:0] imm_addr_out;

    // ---- Instantiate the DUT ----
    id_ex_reg uut (
        .clk(clk), .rst(rst), .stall(stall), .flush(flush),
        .pc_in(pc_in),                 .pc_out(pc_out),
        .alu_op_in(alu_op_in),         .alu_op_out(alu_op_out),
        .reg_write_in(reg_write_in),   .reg_write_out(reg_write_out),
        .mem_read_in(mem_read_in),     .mem_read_out(mem_read_out),
        .mem_write_in(mem_write_in),   .mem_write_out(mem_write_out),
        .wb_select_in(wb_select_in),   .wb_select_out(wb_select_out),
        .jump_enable_in(jump_enable_in), .jump_enable_out(jump_enable_out),
        .read_data1_in(read_data1_in), .read_data1_out(read_data1_out),
        .read_data2_in(read_data2_in), .read_data2_out(read_data2_out),
        .rd_in(rd_in),                 .rd_out(rd_out),
        .rs1_in(rs1_in),               .rs1_out(rs1_out),
        .rs2_in(rs2_in),               .rs2_out(rs2_out),
        .imm_addr_in(imm_addr_in),     .imm_addr_out(imm_addr_out)
    );

    // ---- Clock ----
    // clk is given its starting value in its own standalone initial
    // statement, separate from the always block that toggles it, so
    // there's no ambiguity about which one executes first at time=0.
    initial clk = 0;
    always #5 clk = ~clk;

    // ---- Waveform dump ----
    initial begin
        $dumpfile("id_ex_reg_tb.vcd");
        $dumpvars(0, id_ex_reg_tb);
    end

    // ---- Watch the key signals every time any of them change ----
    initial begin
        $monitor("time=%0t  rst=%b stall=%b flush=%b | pc_in=%h -> pc_out=%h | alu_op_in=%b -> alu_op_out=%b | reg_write_out=%b",
                  $time, rst, stall, flush, pc_in, pc_out, alu_op_in, alu_op_out, reg_write_out);
    end

    // ---- Stimulus ----
    initial begin
        // Start everything at a known, quiet state.
        rst = 1;
        stall = 0;
        flush = 0;
        pc_in = 8'h00;
        alu_op_in = 3'b000;
        reg_write_in = 0;
        mem_read_in = 0;
        mem_write_in = 0;
        wb_select_in = 0;
        jump_enable_in = 0;
        read_data1_in = 8'h00;
        read_data2_in = 8'h00;
        rd_in = 3'b000;
        rs1_in = 3'b000;
        rs2_in = 3'b000;
        imm_addr_in = 8'h00;

        // ---- Reset ----
        // Hold rst through one clock edge, then release it. Because rst
        // is in the DUT's sensitivity list (posedge rst), the clear is
        // asynchronous, but we still wait for a clean edge before moving on.
        @(posedge clk);
        #1;                 // step past the edge before changing signals,
        rst = 0;             // so we never race the DUT's own always block

        // ---- Normal operation: cycle 1 ----
        // Drive a full set of "instruction" values and confirm they show
        // up on pc_out / alu_op_out / reg_write_out after the next edge.
        pc_in = 8'h01;
        alu_op_in = 3'b001;
        reg_write_in = 1;
        mem_read_in = 1;
        read_data1_in = 8'h02;
        read_data2_in = 8'h03;
        rd_in = 3'b001;
        rs1_in = 3'b010;
        rs2_in = 3'b011;
        imm_addr_in = 8'h04;
        @(posedge clk);
        #1;

        // ---- Normal operation: cycle 2 ----
        // A second, different value so we can see the register keep
        // advancing normally, not just latch once and stop.
        pc_in = 8'h02;
        alu_op_in = 3'b010;
        reg_write_in = 0;
        @(posedge clk);
        #1;

        // ---- Stall ----
        // Assert stall, then change the inputs. If the DUT is correct,
        // pc_out/alu_op_out/reg_write_out must NOT change for as long as
        // stall stays high, even though pc_in/alu_op_in clearly did.
        stall = 1;
        pc_in = 8'h09;
        alu_op_in = 3'b011;
        reg_write_in = 1;
        @(posedge clk);
        #1;                  // outputs should still show the cycle-2 values here
        @(posedge clk);
        #1;                  // still frozen after a second stalled cycle

        // Release stall - the values that were waiting (pc_in=09, etc.)
        // should now flow through on the very next edge.
        stall = 0;
        @(posedge clk);
        #1;

        // ---- Flush ----
        // Latch one more clearly-nonzero value in first, so the flush
        // has something real to clear.
        pc_in = 8'hAA;
        alu_op_in = 3'b100;
        reg_write_in = 1;
        @(posedge clk);
        #1;

        // Now flush. Per the DUT, flush is checked alongside rst in the
        // same posedge-clk block, so the clear happens on the NEXT edge,
        // not instantly - we wait for that edge before checking.
        flush = 1;
        @(posedge clk);
        #1;                  // pc_out/alu_op_out/reg_write_out should be 0 now
        flush = 0;

        // One more ordinary cycle afterward, to confirm the register
        // resumes normal latching once flush is released.
        pc_in = 8'hBB;
        alu_op_in = 3'b101;
        reg_write_in = 1;
        @(posedge clk);
        #1;

        $finish;
    end

endmodule