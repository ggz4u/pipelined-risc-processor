# 5-Stage Pipelined 8-bit RISC Processor

An open-source, 8-bit Reduced Instruction Set Computer (RISC) processor designed with a 5-stage pipeline architecture. This project implements a custom Instruction Set Architecture (ISA) and is built using Verilog. It is fully verifiable using open-source simulation tools.

### Pipeline Stages Breakdown
1. **Instruction Fetch (IF):** Fetches the target instruction from Instruction Memory using the Program Counter (PC).
2. **Instruction Decode (ID):** Decodes opcode/registers, reads operands from the Register File, and generates control signals.
3. **Execute (EX):** The Arithmetic Logic Unit (ALU) performs mathematical, logical, or address calculations.
4. **Memory Access (MEM):** Reads or writes data to the Data Memory for load/store operations.
5. **Write Back (WB):** Updates the Register File with the calculated ALU result or memory load value.

---

# Instruction Set Architecture (ISA)

| Instruction | Opcode | Operation         | Description            |
| ----------- | ------ | ----------------- | ---------------------- |
| ADD         | 000    | Rd = Rs1 + Rs2    | Add two registers      |
| SUB         | 001    | Rd = Rs1 − Rs2    | Subtract two registers |
| AND         | 010    | Rd = Rs1 & Rs2    | Bitwise AND            |
| OR          | 011    | Rd = Rs1 or Rs2    | Bitwise OR            |
| NOT         | 100    | Rd = ~Rs1         | Bitwise NOT            |
| STORE       | 101    | Mem[address] = Rs1| Store data in memory   |
| LOAD        | 110    | Rd = Mem[address] | Load data from memory  |
| JMP         | 111    | PC = address      | Jump to instruction    |

#### *MOV instruction is implemented by ADD Rd, Rs1, R0 ; R0 is hardwired to 0 so this instruction is equivalent to MOV

---

## Hazard Handling
 
This is the core challenge of pipelined design. Three types of hazards are fully handled:
 
### Data Hazards - Forwarding Unit
When an instruction depends on the result of a previous instruction still in the pipeline, the processor forwards the result directly from a later pipeline stage back to the EX stage input, avoiding a stall.
 
- **EX/MEM Forwarding (`forward_A = 10` or `forward_B = 10`):** Result from the EX/MEM pipeline register is forwarded to the ALU input of the current instruction in EX stage. Fires when the instruction two steps ahead writes to a register the current instruction reads.
- **MEM/WB Forwarding (`forward_A = 01` or `forward_B = 01`):** Result from the MEM/WB pipeline register is forwarded to the ALU input. Fires when the instruction three steps ahead writes to a register which the current instruction reads.
### Load-Use Hazard - Stall & Bubble Insertion
Forwarding alone cannot resolve a **load-use hazard** — when a LOAD is immediately followed by an instruction that uses the loaded value (the value isn't available until the end of MEM stage, one cycle too late for forwarding).
 
**Resolution:** The Hazard Detection Unit detects this case and:
1. Freezes the PC and IF/ID register for one cycle (`pc_write = 0`, `stall_if_id = 1`)
2. Inserts a NOP(No Operation) bubble into the ID/EX register (`flush_id_ex = 1`)
3. Forwarding then resolves the dependency in the next cycle
### Control Hazards - Pipeline Flush on JMP
When a JMP instruction is decoded, one instruction has already been fetched into IF/ID that should not execute. The processor flushes this incorrectly fetched instruction (replaces it with a NOP bubble) and redirects the PC to the jump target address.
 
---

## 🖥️ Architecture & Verification

### Hardware Architecture
![Architecture](Output/architecture.png)

### Simulation Output Waveform
![Output](Output/output_waveform.png)

---

# 🛠️ Simulation & Toolchain

### Prerequisites
To simulate and view the waveforms locally, ensure you have the following tools installed:
* **Simulator:** [Icarus Verilog](http://iverilog.icarus.com/) (recommended) or Vivado/ModelSim
* **Waveform Viewer:** [GTKWave](https://gtkwave.sourceforge.net/)

### Quick Start Guide

Clone the repository and run the simulation using your terminal:

```bash
# 1. Clone the repository
git clone https://github.com/ggz4u/pipelined-risc-processor.git
cd pipelined-risc-processor

# 2. Compile the design files and testbench
iverilog -o vvp/pipelined_top_tb.vvp tb/pipelined_top_tb.v src/pipelined_top.v src/alu.v src/register_file.v src/program_counter.v src/instruction_memory.v src/decoder.v src/data_memory.v src/control_unit.v src/if_id_reg.v src/id_ex_reg.v src/ex_mem_reg.v src/mem_wb_reg.v src/forwarding_unit.v src/hazard_detection_unit.v

# 3. Run the simulation
vvp vvp/pipelined_top_tb.vvp

# 4. Open the waveform in GTKWave
gtkwave vcd/pipelined_top_tb.vcd
```
