module mem_wb_reg_tb;
    reg clk;
    reg rst;
    reg reg_write_in;
    reg wb_select_in;
    wire reg_write_out;
    wire wb_select_out;
    reg [7:0] alu_result_in;
    reg [7:0] mem_data_in;
    wire [7:0] alu_result_out;
    wire [7:0] mem_data_out;
    reg [2:0] rd_in;
    wire [2:0] rd_out;

    mem_wb_reg uut (
        .clk(clk),
        .rst(rst),
        .reg_write_in(reg_write_in),
        .wb_select_in(wb_select_in),
        .reg_write_out(reg_write_out),
        .wb_select_out(wb_select_out),
        .alu_result_in(alu_result_in),
        .mem_data_in(mem_data_in),
        .alu_result_out(alu_result_out),
        .mem_data_out(mem_data_out),
        .rd_in(rd_in),
        .rd_out(rd_out)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("mem_wb_reg_tb.vcd");
        $dumpvars(0, mem_wb_reg_tb);
        $monitor("Time: %0t | rst: %b | reg_write_in: %b | wb_select_in: %b | alu_result_in: %b | mem_data_in: %b | rd_in: %b | reg_write_out: %b | wb_select_out: %b | alu_result_out: %b | mem_data_out: %b | rd_out: %b",
                 $time, rst, reg_write_in, wb_select_in, alu_result_in, mem_data_in, rd_in, reg_write_out, wb_select_out, alu_result_out, mem_data_out, rd_out);
    end

    initial begin
        // Initialize inputs
        rst = 1; // Start with reset active
        reg_write_in = 0;
        wb_select_in = 0;
        alu_result_in = 8'b00000000;
        mem_data_in = 8'b00000000;
        rd_in = 3'b000;

        // Wait for a few clock cycles
        #10 rst = 0; // Deactivate reset

        // Test case 1: Write ALU result to register
        #10 reg_write_in = 1; 
            wb_select_in = 0; 
            alu_result_in = 8'hA5; // 165 %d
            rd_in = 3'b011;

        // Test case 2: Write in Memory
        #10 reg_write_in = 1;
        wb_select_in = 1;
        mem_data_in = 8'h42; // 204 %d

        // Test case 3: Disable write
        #10 reg_write_in = 0;
        wb_select_in = 0; 
        alu_result_in = 8'b00001010; // 10 %d
        rd_in = 3'b001;

        #20 $finish; // End simulation
    end
endmodule

