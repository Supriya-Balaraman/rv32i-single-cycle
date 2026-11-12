# RV32I Single-Cycle Processor

A single-cycle RISC-V (RV32I) processor I built in SystemVerilog and simulated in Xilinx Vivado. Every instruction finishes in one clock cycle: fetch, decode, execute, memory access and write-back all happen before the next clock edge.

I built this to understand how a CPU works at the hardware level, from the instruction bits down to the register writes.

## What it can do

It supports the base RV32I integer instruction set:

| Type | Instructions |
|---|---|
| R-type | add, sub, sll, slt, sltu, xor, srl, sra, or, and |
| I-type ALU | addi, slti, sltiu, xori, ori, andi, slli, srli, srai |
| Loads | lb, lh, lw, lbu, lhu |
| Stores | sb, sh, sw |
| Branches | beq, bne, blt, bge, bltu, bgeu |
| Jumps | jal, jalr |
| Upper immediates | lui, auipc |

## How it's organized

```
rv32i-single-cycle/
├── src/
│   ├── interface_module.sv    PC register and PC+4 logic
│   ├── instruction_memory.sv  instruction ROM, loaded from program.mem
│   ├── if_stage.sv            instruction fetch (PC + instruction memory)
│   ├── decoder_interface.sv   splits the instruction into fields and immediates
│   ├── imm_generator.sv       picks the right immediate for each instruction
│   ├── main_control.sv        main control signals from the opcode
│   ├── register_file.sv       32 registers, x0 hardwired to zero
│   ├── id_stage.sv            decode stage (decoder + control + registers)
│   ├── alu_control.sv         turns aluop, funct3 and funct7 into an ALU code
│   ├── alu.sv                 the ALU, also does the branch compares
│   ├── ex_stage.sv            operand muxes, ALU, branch and jump targets
│   ├── data_memory.sv         data memory with byte, half and word access
│   ├── wb_stage.sv            picks what gets written back to the register file
│   └── single_cycle_rv32i.sv  top level that wires everything together
└── sim/
    ├── tb_single_cycle.sv     testbench, checks the registers automatically
    └── program.mem            test program in hex, one instruction per line
```

## How the pieces fit together

- **IF:** The PC sends its address to instruction memory, and the PC moves to PC+4 unless a branch or jump is taken.
- **ID:** The decoder splits the instruction into rs1, rs2, rd, funct3, funct7 and the five immediate formats. The immediate generator picks the right one, main control sets the control signals, and the register file reads rs1 and rs2.
- **EX:** The ALU control picks the operation. The ALU's first input is rs1, the PC (for `auipc`), or zero (for `lui`). Its second input is rs2 or the immediate. The ALU also does the branch compares. Jump and branch targets are worked out here too.
- **MEM:** The data memory is addressed by the ALU result. It handles byte, half and word loads and stores, with sign or zero extension on loads.
- **WB:** Two muxes in series. The first picks by opcode between the ALU result, PC+4 (return address for `jal`/`jalr`), the immediate (`lui`) and PC+imm (`auipc`). The second uses `memtoreg` to choose between that and the data read from memory.

### Control signals

| Signal | Meaning |
|---|---|
| `aluop` | `00` add, `01` branch, `10` R-type, `11` I-type ALU |
| `alu_src` | `0` use rs2, `1` use the immediate |
| `memtoreg` | `1` for loads, write the memory data back |
| `jalr` | `1` for jalr, picks the `rs1 + imm` target |

### ALU codes (5 bits)

| Code | Op | Code | Op |
|---|---|---|---|
| 00000 | ADD | 01000 | SLT |
| 00001 | SUB | 01001 | SLTU |
| 00010 | XOR | 01010 | BEQ |
| 00011 | OR | 01011 | BNE |
| 00100 | AND | 01100 | BLT |
| 00101 | SLL | 01101 | BGE |
| 00110 | SRL | 01110 | BLTU |
| 00111 | SRA | 01111 | BGEU |

`10000` to `11111` are unused.

## Design decisions

- **Immediates are built once, in the decoder.** All five formats (I, S, B, U, J) come out of `decoder_interface` already sign-extended. The branch and jump ones already include the shift by 1, so nothing downstream shifts them again.
- **`funct7[5]` is only checked when it matters.** For `addi` that bit is just part of the immediate, so it's ignored. It's only used for `sub`, `sra` and `srai`. Otherwise something like `addi x1, x0, -1024` would turn into a subtract.
- **Branch compares live in the ALU.** The ALU control turns `funct3` into one of the six branch codes, and the ALU gives back a `branch_taken` flag.
- **x0 can never change.** The register file blocks writes to x0 and returns 0 on reads of it.
- **`jalr` clears bit 0** of its target address, as the spec requires.
- **Shifts only use the low 5 bits** of the second operand.

## How to run it

You need Vivado. I used version 2025.1.

1. Create a new RTL project in Vivado.
2. Add every file in `src/` as a **design source**.
3. Add `sim/tb_single_cycle.sv` as a **simulation source**.
4. Add `sim/program.mem` as a **simulation source**. If the instruction memory stays `X` when you simulate, this is usually why. You can also put the full path in the `$readmemh` call.
5. Set `single_cycle_rv32i` as the top design module and `tb_single_cycle` as the top simulation module.
6. Click **Run Simulation**, then **Run Behavioral Simulation**, then **Run All**.
7. Read the Tcl console. You should see `PASS` for each register and `ALL TESTS PASSED` at the end.
8. To watch it work, add `dut.address`, `dut.instruction` and `dut.wb_data` to the waveform.

## Test program

`program.mem` runs 18 instructions: an add and a sub, a store and a load, a taken branch, a `jal`, a `lui`, a `jalr`, and a final infinite loop. The skipped instructions (after the branch and the jumps) must leave their registers at 0, which proves the jumps worked. The testbench checks all the registers at the end and prints PASS or FAIL for each.

## Status

Tested with the program above: add, sub, addi, lui, sw, lw, beq, jal and jalr. Not yet tested: the other branches, the shifts, slt/sltu, and byte or half loads and stores.
