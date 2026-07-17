module register_file(
    input clk,
    input rst,
    input write_enable,
    input [2:0] read_addr1, // Address of first source register
    input [2:0] read_addr2, // Address of second source register
    input [2:0] write_addr, // Address of destination register
    input [7:0] write_data, // Data to be written to the destination register
    output reg[7:0] read_data1, // Data from first source register
    output reg[7:0] read_data2 // Data from second source register
);
    integer i;

    reg [7:0] registers [0:7];
    always @(*) begin

        // To replace MOV instruction with STORE and preserve MOV instruction, R0 is hardwired to 0
        // Because there is no way after the 1st initialization, any register can have value 0 after instructions start executing.
        // So R0 = 0(a register which always contains a 0 value) and MOV is duplicated by "ADD Rd, Rs1, R0" : (Rd <- Rs1 + 0) => (Rd <- Rs1) => similar to MOV.

        if(read_addr1 == 3'b0)
            read_data1 = 8'b0;
        else
            read_data1 = (write_enable && (read_addr1 == write_addr)) ? write_data : registers[read_addr1]; // rectifying the read-before-write hazard
        
        if(read_addr2 == 3'b0)
            read_data2 = 8'b0;
        else    
            read_data2 = (write_enable && (read_addr2 == write_addr)) ? write_data : registers[read_addr2];
    end

    always @(posedge clk or posedge rst) begin
        
        if(rst) begin
            for(i=0; i<8; i=i+1)begin
                registers[i] <= 8'b0;
            end

        end else if(write_enable && write_addr != 3'b0) begin // R0 cannot be overwritten
            registers[write_addr] <= write_data;
        end
    end
endmodule
