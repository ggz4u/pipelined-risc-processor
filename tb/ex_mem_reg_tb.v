module ex_mem_reg_tb;
    reg clk;
    reg rst;
    reg flush;
    reg [7:0] pc_in;
    reg [7:0] alu_result_in;
    reg carry_in;
    reg zero_flag_in;
    reg [7:0] store_data_in;
    reg [2:0] rd_in;
    reg [7:0] imm_addr_in;
    reg reg_write_in;
    reg mem_read_in;
    reg mem_write_in;
    reg wb_select_in;
    reg jump_enable_in;

    wire [7:0] pc_out;
    wire reg_write_out;
    wire mem_read_out;
    wire mem_write_out;
    wire wb_select_out;
    wire jump_enable_out;
    wire [7:0] alu_result_out;
    wire carry_out;
    wire zero_flag_out;
    wire [7:0] store_data_out;
    wire [2:0] rd_out;
    wire [7:0] imm_addr_out;

    ex_mem_reg dut (
        .clk(clk),
        .rst(rst),
        .flush(flush),
        .pc_in(pc_in),
        .pc_out(pc_out),
        .reg_write_in(reg_write_in),
        .mem_read_in(mem_read_in),
        .mem_write_in(mem_write_in),
        .wb_select_in(wb_select_in),
        .jump_enable_in(jump_enable_in),
        .alu_result_in(alu_result_in),
        .carry_in(carry_in),
        .zero_flag_in(zero_flag_in),
        .store_data_in(store_data_in),
        .alu_result_out(alu_result_out),
        .carry_out(carry_out),
        .zero_flag_out(zero_flag_out),
        .store_data_out(store_data_out),
        .rd_in(rd_in),
        .rd_out(rd_out),
        .imm_addr_in(imm_addr_in),
        .imm_addr_out(imm_addr_out)
    );

    initial begin
        $dumpfile("ex_mem_reg_tb.vcd");
        $dumpvars(0, ex_mem_reg_tb);
        $monitor("Time: %2d | clk: %b | rst: %b | flush: %b | pc_in: %h | pc_out: %h | reg_write_in: %b | reg_write_out: %b | mem_read_in: %b | mem_read_out: %b | mem_write_in: %b | mem_write_out: %b | wb_select_in: %b | wb_select_out: %b | jump_enable_in: %b | jump_enable_out: %b | alu_result_in: %h | alu_result_out: %h | carry_in: %b | carry_out: %b | zero_flag_in: %b | zero_flag_out: %b | store_data_in: %h | store_data_out: %h | rd_in: %b | rd_out: %b | imm_addr_in: %h | imm_addr_out: %h", $time, clk, rst, flush, pc_in, pc_out, reg_write_in, reg_write_out, mem_read_in, mem_read_out, mem_write_in, mem_write_out, wb_select_in, wb_select_out, jump_enable_in, jump_enable_out, alu_result_in, alu_result_out, carry_in, carry_out, zero_flag_in, zero_flag_out, store_data_in, store_data_out, rd_in, rd_out, imm_addr_in, imm_addr_out);
    end

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        rst = 0;
        flush = 0;
        reg_write_in    = 0;
        mem_read_in     = 0;
        mem_write_in    = 0;
        wb_select_in    = 0;
        jump_enable_in  = 0;
        pc_in = 8'b0;
        alu_result_in = 8'b0;
        carry_in = 0;
        zero_flag_in = 0;
        store_data_in = 8'b0;
        rd_in = 3'b0;
        imm_addr_in = 8'b0;

        // Apply reset
        rst = 1;
        #10;
        rst = 0;

        // Test case 1: Normal operation
        pc_in = 8'hAA;
        alu_result_in = 8'h55;
        carry_in = 1;
        zero_flag_in = 0;
        store_data_in = 8'hFF;
        rd_in = 3'b101;
        imm_addr_in = 8'h12;
        #10;

        // Test case 2: Flush
        flush = 1;
        #10;
        flush = 0;

        // Test case 3: Another normal operation
        pc_in = 8'hBB;
        alu_result_in = 8'h66;
        carry_in = 0;
        zero_flag_in = 1;
        store_data_in = 8'hEE;
        rd_in = 3'b110;
        imm_addr_in = 8'h34;
        #10;

        // Finish simulation
        $finish;
    end

endmodule