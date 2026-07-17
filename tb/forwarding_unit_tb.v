module forwarding_unit_tb;
    reg [2:0] id_ex_rs1;
    reg [2:0] id_ex_rs2;
    reg [2:0] ex_mem_rd;
    reg ex_mem_reg_write;
    reg [2:0] mem_wb_rd;
    reg mem_wb_reg_write;
    wire [1:0] forward_A;
    wire [1:0] forward_B;

    forwarding_unit uut (
        .id_ex_rs1(id_ex_rs1),
        .id_ex_rs2(id_ex_rs2),
        .ex_mem_rd(ex_mem_rd),
        .ex_mem_reg_write(ex_mem_reg_write),
        .mem_wb_rd(mem_wb_rd),
        .mem_wb_reg_write(mem_wb_reg_write),
        .forward_A(forward_A),
        .forward_B(forward_B)
    );

    initial begin
        $dumpfile("forwarding_unit_tb.vcd");
        $dumpvars(0, forwarding_unit_tb);
        $monitor("Time: %0t | id_ex_rs1: %b | id_ex_rs2: %b | ex_mem_rd: %b | ex_mem_reg_write: %b | mem_wb_rd: %b | mem_wb_reg_write: %b | forward_A: %b | forward_B: %b",
                 $time, id_ex_rs1, id_ex_rs2, ex_mem_rd, ex_mem_reg_write, mem_wb_rd, mem_wb_reg_write, forward_A, forward_B);
    end

    initial begin
        id_ex_rs1 = 3'b0;
        id_ex_rs2 = 3'b0;
        ex_mem_rd = 3'b0;
        ex_mem_reg_write = 1'b0;
        mem_wb_rd = 3'b0;
        mem_wb_reg_write = 1'b0;

        // Test case 1: No forwarding
       #10;
       id_ex_rs1 = 3'b010;
       id_ex_rs2 = 3'b011;
       ex_mem_rd = 3'b101;
       ex_mem_reg_write = 1'b0;
       mem_wb_rd = 3'b110;
       mem_wb_reg_write = 1'b0;

       // Test case 2: Simple forwarding
       #10;
       id_ex_rs1 = 3'b010;
       id_ex_rs2 = 3'b011;
       ex_mem_rd = 3'b010;
       ex_mem_reg_write = 1'b1;

       // Test case 3: Double forward
       #10;
       id_ex_rs1 = 3'b010;
       id_ex_rs2 = 3'b011;
       ex_mem_rd = 3'b010;
       ex_mem_reg_write = 1'b1;
       mem_wb_rd = 3'b011;
       mem_wb_reg_write = 1'b1;

       //Test case 4: Priority Check
       #10;
       id_ex_rs1 = 3'b001;
       id_ex_rs2 = 3'b010;
       ex_mem_rd = 3'b001;
       ex_mem_reg_write = 1'b1;
       mem_wb_rd = 3'b001;
       mem_wb_reg_write = 1'b1;

       // Test case 5: No forwarding with zero register
        #10;
        id_ex_rs1 = 3'b001;
        id_ex_rs2 = 3'b101;
        ex_mem_rd = 3'b000;
        ex_mem_reg_write = 1'b1;

        #10;
        ex_mem_reg_write = 1'b0;
        ex_mem_rd = 3'b010;
        id_ex_rs1 = 3'b010;


       // Finish simulation
       #10;
       $finish;
   end
endmodule