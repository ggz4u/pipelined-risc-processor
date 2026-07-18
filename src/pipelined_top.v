module pipelined_top(
    input clk,
    input rst
);

// FETCH Stage
wire [7:0] pc_out;
wire [15:0] fetch_instruction;
wire pc_write; // from Hazard detection unit   

// IF/ID Pipeline register outputs
wire [7:0] if_id_pc;
wire [15:0] if_id_instruction;
wire flush_if_id;  // from jump_enable (control hazard)
wire stall_if_id;  // from hazard detection unit

// DECODE Stage
wire [2:0] dec_opcode;
wire [2:0] dec_rd;
wire [2:0] dec_rs1;
wire [2:0] dec_rs2;
wire [7:0] dec_imm_addr;
wire dec_is_rtype;
wire dec_is_load;
wire dec_is_store;
wire dec_is_jmp;

// Control Unit Outputs
wire [2:0] ctrl_alu_op;
wire ctrl_reg_write;
wire ctrl_mem_read;
wire ctrl_mem_write;
wire ctrl_wb_select;
wire ctrl_jump_enable;

// Register file read outputs
wire [7:0] rf_read_data1;
wire [7:0] rf_read_data2;

// ID/EX pipeline register outputs
wire [7:0] id_ex_pc;
wire [2:0] id_ex_alu_op;
wire id_ex_reg_write;
wire id_ex_mem_read;
wire id_ex_mem_write;
wire id_ex_wb_select;
wire id_ex_jump_enable;
wire [7:0] id_ex_read_data1;
wire [7:0] id_ex_read_data2;
wire [2:0] id_ex_rd;
wire [2:0] id_ex_rs1;
wire [2:0] id_ex_rs2;
wire [7:0] id_ex_imm_addr;
wire stall_id_ex;  // from hazard detection unit
wire flush_id_ex;  // from hazard detection unit

// EXECUTE Stage
wire [1:0] forward_A;  // from forwarding unit 
wire [1:0] forward_B;  // from forwarding unit
wire [7:0] alu_input_A;  // after forwarding MUX
wire [7:0] alu_input_B;  // after forwarding MUX
wire [7:0] alu_result;
wire alu_carry;
wire alu_zero_flag;
wire [7:0] wb_writeback_data;  // from MEM/WB writeback MUX

// EX/MEM Pipeline register outputs
wire [7:0] ex_mem_pc;
wire ex_mem_reg_write;
wire ex_mem_mem_read;
wire ex_mem_mem_write;
wire ex_mem_wb_select;
wire ex_mem_jump_enable;
wire [7:0] ex_mem_alu_result;
wire ex_mem_carry;
wire ex_mem_zero_flag;
wire [7:0] ex_mem_store_data;
wire [2:0] ex_mem_rd;
wire [7:0] ex_mem_imm_addr;

// MEMORY Stage
wire [7:0] mem_read_data;

// MEM/WB Pipeline register outputs
wire mem_wb_reg_write;
wire mem_wb_wb_select;
wire [7:0] mem_wb_alu_result;
wire [7:0] mem_wb_mem_data;
wire [2:0] mem_wb_rd;


wire flush_id_ex_jmp;
assign flush_id_ex_jmp = ex_mem_jump_enable;

// WRITEBACK Stage
// wb_writeback_data declared above (used in Execute forwarding too)   

// Forwarding MMUXES
// Select ALU inputs based on forwarding signals
// 00 = Register file, 10 = EX/MEM, 01 = MEM/WB

assign alu_input_A = (forward_A == 2'b10) ? ex_mem_alu_result : 
                     (forward_A == 2'b01) ? wb_writeback_data : id_ex_read_data1;

assign alu_input_B = (forward_B == 2'b10) ? ex_mem_alu_result : 
                     (forward_B == 2'b01) ? wb_writeback_data : id_ex_read_data2;

// Writeback MUX : Selects b/w ALU result and memory data
assign wb_writeback_data = mem_wb_wb_select ? mem_wb_mem_data : mem_wb_alu_result;

// JUMP Flush
// JMP detected in decode -> flush IF/ID
assign flush_if_id = id_ex_jump_enable;


// MODULE INSTANTIATIONS

// 1. Program counter
program_counter pc_inst(
    .clk(clk),
    .rst(rst),
    .jump_enable(id_ex_jump_enable),   // from ID/EX
    .jump_addr(id_ex_imm_addr),        // from ID/EX — same register, same cycle
    .pc_write(pc_write),
    .pc(pc_out)
);

// 2. Instruction Memory
instruction_memory imem_inst(
    .addr(pc_out),
    .instruction(fetch_instruction)
);

// 3. IF/ID pipeline register
if_id_reg if_id_inst(
    .clk(clk),
    .rst(rst),
    .flush(flush_if_id),
    .stall(stall_if_id),
    .pc_in(pc_out),
    .instr_in(fetch_instruction),
    .pc_out(if_id_pc),
    .instr_out(if_id_instruction)
);

// 4. Decoder
decoder dec_inst(
    .instruction(if_id_instruction),
    .opcode(dec_opcode),
    .rd(dec_rd),
    .rs1(dec_rs1),
    .rs2(dec_rs2),
    .immediate_addr(dec_imm_addr),
    .is_rtype(dec_is_rtype),
    .is_load(dec_is_load),
    .is_store(dec_is_store),
    .is_jmp(dec_is_jmp)
);

// 5. Control Unit
control_unit cu_inst(
    .opcode(dec_opcode),
    .alu_op(ctrl_alu_op),
    .reg_write(ctrl_reg_write),
    .mem_read(ctrl_mem_read),
    .mem_write(ctrl_mem_write),
    .wb_select(ctrl_wb_select),
    .jump_enable(ctrl_jump_enable)
);

// 6. Register File
register_file rf_inst(
    .clk(clk),
    .rst(rst),
    .write_enable(mem_wb_reg_write),
    .read_addr1(dec_rs1),
    .read_addr2(dec_rs2),
    .write_addr(mem_wb_rd),
    .write_data(wb_writeback_data),
    .read_data1(rf_read_data1),
    .read_data2(rf_read_data2)
);

// 7. ID/EX pipeline register
id_ex_reg id_ex_inst(
    .clk(clk),
    .rst(rst),
    .flush(flush_id_ex),
    .stall(stall_id_ex),
    .pc_in(if_id_pc),
    .alu_op_in(ctrl_alu_op),
    .reg_write_in(ctrl_reg_write),
    .mem_read_in(ctrl_mem_read),
    .mem_write_in(ctrl_mem_write),
    .wb_select_in(ctrl_wb_select),
    .jump_enable_in(ctrl_jump_enable),
    .read_data1_in(rf_read_data1),
    .read_data2_in(rf_read_data2),
    .rd_in(dec_rd),
    .rs1_in(dec_rs1),
    .rs2_in(dec_rs2),
    .imm_addr_in(dec_imm_addr),
    .pc_out(id_ex_pc),
    .alu_op_out(id_ex_alu_op),
    .reg_write_out(id_ex_reg_write),
    .mem_read_out(id_ex_mem_read),
    .mem_write_out(id_ex_mem_write),
    .wb_select_out(id_ex_wb_select),
    .jump_enable_out(id_ex_jump_enable),
    .read_data1_out(id_ex_read_data1),
    .read_data2_out(id_ex_read_data2),
    .rd_out(id_ex_rd),
    .rs1_out(id_ex_rs1),
    .rs2_out(id_ex_rs2),
    .imm_addr_out(id_ex_imm_addr)
);

// 8. Hazard detection unit
hazard_detection_unit hdu_inst(
    .id_ex_mem_read(id_ex_mem_read),
    .id_ex_rd(id_ex_rd),
    .if_id_rs1(dec_rs1),
    .if_id_rs2(dec_rs2),
    .stall_if_id(stall_if_id),
    .flush_id_ex(flush_id_ex),
    .pc_write(pc_write),
    .stall_id_ex(stall_id_ex)
);

// 9. Forwarding Unit
forwarding_unit fu_inst(
    .id_ex_rs1(id_ex_rs1),
    .id_ex_rs2(id_ex_rs2),
    .ex_mem_rd(ex_mem_rd),
    .ex_mem_reg_write(ex_mem_reg_write),
    .mem_wb_rd(mem_wb_rd),
    .mem_wb_reg_write(mem_wb_reg_write),
    .forward_A(forward_A),
    .forward_B(forward_B)
);

// 10. ALU
alu alu_inst(
    .a(alu_input_A),
    .b(alu_input_B),
    .opcode(id_ex_alu_op),
    .result(alu_result),
    .carry(alu_carry),
    .zero_flag(alu_zero_flag)
);

// 11. EX/MEM Pipeline Register
ex_mem_reg ex_mem_inst(
    .clk(clk),
    .rst(rst),
    .flush(id_ex_jump_enable),
    .pc_in(id_ex_pc),
    .reg_write_in(id_ex_reg_write),
    .mem_read_in(id_ex_mem_read),
    .mem_write_in(id_ex_mem_write),
    .wb_select_in(id_ex_wb_select),
    .jump_enable_in(id_ex_jump_enable),
    .alu_result_in(alu_result),
    .carry_in(alu_carry),
    .zero_flag_in(alu_zero_flag),
    .store_data_in(id_ex_read_data1),
    .rd_in(id_ex_rd),
    .imm_addr_in(id_ex_imm_addr),
    .pc_out(ex_mem_pc),
    .reg_write_out(ex_mem_reg_write),
    .mem_read_out(ex_mem_mem_read),
    .mem_write_out(ex_mem_mem_write),
    .wb_select_out(ex_mem_wb_select),
    .jump_enable_out(ex_mem_jump_enable),
    .alu_result_out(ex_mem_alu_result),
    .carry_out(ex_mem_carry),
    .zero_flag_out(ex_mem_zero_flag),
    .store_data_out(ex_mem_store_data),
    .rd_out(ex_mem_rd),
    .imm_addr_out(ex_mem_imm_addr)
);

// 12. Data Memory
data_memory dmem_inst(
    .clk(clk),
    .rst(rst),
    .mem_read(ex_mem_mem_read),
    .mem_write(ex_mem_mem_write),
    .addr(ex_mem_imm_addr),
    .write_data(ex_mem_store_data),
    .read_data(mem_read_data)
);

// 13. MEM/WB Pipeline Register
mem_wb_reg mem_wb_inst(
    .clk(clk),
    .rst(rst),
    .reg_write_in(ex_mem_reg_write),
    .wb_select_in(ex_mem_wb_select),
    .alu_result_in(ex_mem_alu_result),
    .mem_data_in(mem_read_data),
    .rd_in(ex_mem_rd),
    .reg_write_out(mem_wb_reg_write),
    .wb_select_out(mem_wb_wb_select),
    .alu_result_out(mem_wb_alu_result),
    .mem_data_out(mem_wb_mem_data),
    .rd_out(mem_wb_rd)
);

endmodule


