module data_memory(
    input clk,
    input rst,
    input mem_read, // read enable
    input mem_write, // write enable
    input [7:0] addr, // Address 8-bits for 256 locations
    input [7:0] write_data, // Data to write
    output reg [7:0] read_data // Data to read
);

    //256 locations of 8 bits each (256 x 8 bits)[256B data memory]
    //Stores data values not INSTRUCTIONS
    reg [7:0] memory [0:255];
    integer i;
    //write: sequential clock driven
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            for(i=0; i<256; i=i+1) begin
                memory[i] <= 8'b0;
            end
        end else if(mem_write) begin
            memory[addr] <= write_data;
        end
    end
    

    //read: combinational
    always @(*) begin
        if(mem_read) begin
            read_data = memory[addr];
        end
        else
            read_data = 8'b0;
    end
endmodule


