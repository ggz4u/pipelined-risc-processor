module if_id_reg(
    input clk,
    input rst,
    input flush,        // clears register — used for JMP hazard
    input stall,        // holds register — used for data hazard
    input [7:0] pc_in,
    input [15:0] instr_in,
    output reg [7:0] pc_out,
    output reg [15:0] instr_out
);
    always @(posedge clk or posedge rst) begin
        if(rst || flush) begin
            pc_out    <= 8'b0;
            instr_out <= 16'b0; // NOP = ADD R0,R0,R0
        end
        else if(!stall) begin
            pc_out    <= pc_in;
            instr_out <= instr_in;
        end
        // if stall=1 and no reset/flush: hold current values
    end
endmodule