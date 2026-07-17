module hazard_detection_unit(
    
    // LOAD Instruction in ID/EX stage
    input id_ex_mem_read,
    input [2:0] id_ex_rd,

    // Next instruction in IF/ID satge that is about to enter decode  
    input [2:0] if_id_rs1,
    input [2:0] if_id_rs2,

    // Stall Control outputs
    output reg stall_if_id,
    output reg stall_id_ex,
    output reg flush_id_ex, // Insert NOP into Execute stage
    output reg pc_write
);

    always @(*) begin
        
        // Default - No Hazard
        stall_if_id = 1'b0;
        stall_id_ex = 1'b0;
        flush_id_ex = 1'b0;
        pc_write = 1'b1; // Normal PC operation    

        if(id_ex_mem_read && (id_ex_rd != 3'b0)) begin
            if(id_ex_rd == if_id_rs1 || id_ex_rd == if_id_rs2) begin
                stall_if_id = 1'b1;
                stall_id_ex = 1'b1;
                flush_id_ex = 1'b1; // insert NOP bubble into execute
                pc_write = 1'b0; // Freeze PC - do NOT fetch more instructions
            end
        end
    end
endmodule
