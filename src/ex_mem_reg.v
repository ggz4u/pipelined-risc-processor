module ex_mem_reg(
    input clk,
    input rst,
    input flush, // Control Hazard
    // Note: EX/MEM does NOT need 'stall' in basic pipeline
    // Because data hazard has already been taken care of in IF/ID and ID/EX stages

    //PC - carry forward for debugging/ branch prediction
    input [7:0] pc_in,
    output reg [7:0] pc_out,

    // Control signals still need downstream 
    // alu_op is NOT carried - execution is done
    input reg_write_in, // needed @ writeback 
    input mem_read_in,  // needed @ memory
    input mem_write_in, // needed @ memory
    input wb_select_in, // needed @ writeback
    input jump_enable_in, //needed to redirect PC

    output reg reg_write_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg wb_select_out,
    output reg jump_enable_out,

    //ALU Outputs
    input [7:0] alu_result_in,
    input carry_in,
    input zero_flag_in,
    output reg [7:0] alu_result_out,
    output reg carry_out,
    output reg zero_flag_out,

    // read_data1 - needed for STORE (write to memory) naming it store_data_in
    // read_data2 is NOT carried - STORE requires rs1 (only) to write to memory
    input [7:0] store_data_in,
    output reg [7:0] store_data_out,

    // Destination Regoster - needed at Writeback
    input [2:0] rd_in,
    output reg [2:0] rd_out,

    // Immediate address - needed for memory access address
    input [7:0] imm_addr_in,
    output reg [7:0] imm_addr_out
);

    always @(posedge clk or posedge rst) begin
        if(rst || flush) begin
            pc_out <= 8'b0;
            reg_write_out <= 1'b0;
            mem_read_out <= 1'b0;
            mem_write_out <= 1'b0;
            wb_select_out <= 1'b0;
            jump_enable_out <= 1'b0;
            alu_result_out <= 8'b0;
            carry_out <= 1'b0;
            zero_flag_out <= 1'b0;
            store_data_out <= 8'b0;
            rd_out <= 3'b0;
            imm_addr_out <= 8'b0;
        end
        else begin
            pc_out <= pc_in;
            reg_write_out <= reg_write_in;
            mem_read_out <= mem_read_in;
            mem_write_out <= mem_write_in;
            wb_select_out <= wb_select_in;
            jump_enable_out <= jump_enable_in;
            alu_result_out <= alu_result_in;
            carry_out <= carry_in;
            zero_flag_out <= zero_flag_in;
            store_data_out <= store_data_in;
            rd_out <= rd_in;
            imm_addr_out <= imm_addr_in;
        end
    end
endmodule