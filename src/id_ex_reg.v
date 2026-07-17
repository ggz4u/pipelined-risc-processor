module id_ex_reg(
    input clk, rst, flush, stall,

    // PC - needed for branch address calc
    input [7:0] pc_in,
    output reg [7:0] pc_out,

    // Control Signals
    input [2:0] alu_op_in,
    input reg_write_in,
    input mem_read_in, 
    input mem_write_in,
    input wb_select_in,
    input jump_enable_in,

    output reg [2:0] alu_op_out,
    output reg reg_write_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg wb_select_out,
    output reg jump_enable_out,

    // Register values from register file
    input [7:0] read_data1_in,
    input [7:0] read_data2_in,
    output reg [7:0] read_data1_out,
    output reg [7:0] read_data2_out,

    //Instruction fields from decoder
    input [2:0] rd_in,  // destination register
    input [2:0] rs1_in,  // source register 1
    input [2:0] rs2_in,
    // Rs1 and Rs2 have been stored for the forwarding unit check whether forwarding is required or not.
    input [7:0] imm_addr_in, // immediate / memory address
    output reg [2:0] rd_out,
    output reg [2:0] rs1_out,
    output reg [2:0] rs2_out,
    output reg [7:0] imm_addr_out
);

    always @(posedge clk or posedge rst) begin
        if(rst || flush) begin
            // NOP: Zeroing all control signals
            // No operation will happen downstream
            pc_out <= 8'b0;
            alu_op_out <= 3'b0;
            reg_write_out <= 1'b0;
            mem_read_out <= 1'b0;
            mem_write_out <= 1'b0;
            wb_select_out <= 1'b0;
            jump_enable_out <= 1'b0;
            read_data1_out <= 8'b0;
            read_data2_out <= 8'b0;
            rd_out <= 3'b0;
            rs1_out <= 3'b0;
            rs2_out <= 3'b0;
            imm_addr_out <= 8'b0;
        end
        else if(!stall) begin
            pc_out <= pc_in;
            alu_op_out <= alu_op_in;
            reg_write_out <= reg_write_in;
            mem_read_out <= mem_read_in;
            mem_write_out <= mem_write_in;
            wb_select_out <= wb_select_in;
            jump_enable_out <= jump_enable_in;
            read_data1_out <= read_data1_in;
            read_data2_out <= read_data2_in;
            rd_out <= rd_in;
            rs1_out <= rs1_in;
            rs2_out <= rs2_in;
            imm_addr_out <= imm_addr_in;
        end
        // Stall = 1 => hold all current values
    end
endmodule