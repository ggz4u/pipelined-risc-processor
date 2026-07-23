# 5 Stage Pipelined 8-bit RISC Processor


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

## 🛠️ Simulation & Toolchain

# ![Architecture](output/architecture.png)

### Prerequisites
To simulate and view the waveforms, make sure you have the following open-source or commercial tools installed:
* **Simulator:** [Icarus Verilog](http://iverilog.icarus.com/) (recommended) or Vivado/ModelSim
* **Waveform Viewer:** [GTKWave](https://gtkwave.sourceforge.net/)

### How to Run Simulation

Clone the repository and run the simulation using the terminal:

```bash
# 1. Clone the repository
git clone [https://github.com/ggz4u/pipelined-risc-processor.git](https://github.com/ggz4u/pipelined-risc-processor.git)
cd pipelined-risc-processor

# 2. Compile the design files and testbench
iverilog -o riscv_tb.vvp pipelined_top_tb.v pipelined_top.v

# 3. Run the simulation
vvp riscv_tb.vvp

# 4. Open the waveform in GTKWave
gtkwave pipelined_top_tb.vcd
