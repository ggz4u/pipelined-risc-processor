module program_counter(
    input clk,
    input rst,
    input jump_enable,
    input [7:0] jump_addr,
    input pc_write,
    output reg [7:0] pc
);
    always @(posedge clk or posedge rst) begin
        if(rst)
            pc <= 8'b0;
        else if(pc_write) begin
            if(jump_enable)
                pc <= jump_addr;
            else
                pc <= pc + 1;
        // when pc_write = 0 : pc will hold the previous value/addr : by using Non-blocking assignments        
        end        
    end 
endmodule