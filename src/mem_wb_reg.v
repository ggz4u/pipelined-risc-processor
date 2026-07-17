module mem_wb_reg(
    input clk,
    input rst,
    // No flush and stall needed as those has been handled in prev stages

    // Control signals
    input reg_write_in,
    input wb_select_in, // 0=ALU result, 1=Memory data
    output reg reg_write_out,
    output reg wb_select_out,

    // Data sourses for writeback MUX
    input [7:0] alu_result_in,
    input [7:0] mem_data_in, // from data memory - LOAD result
    output reg [7:0] alu_result_out,
    output reg [7:0] mem_data_out,

    // Destination register
    input [2:0] rd_in,
    output reg [2:0] rd_out
);

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            reg_write_out <= 1'b0;
            wb_select_out <= 1'b0;
            alu_result_out <= 8'b0;
            mem_data_out <= 8'b0;
            rd_out <= 3'b0;
        end
        else begin
            reg_write_out <= reg_write_in;
            wb_select_out <= wb_select_in;
            alu_result_out <= alu_result_in;
            mem_data_out <= mem_data_in;
            rd_out <= rd_in;
        end
    end
endmodule
