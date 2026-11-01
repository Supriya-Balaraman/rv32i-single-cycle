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
│   ├── alu_control.sv         turns alu_op, funct3 and funct7 into an ALU code
│   ├── alu.sv                 the ALU
│   ├── execute.sv             operand muxes, branch compare, jump targets
│   ├── wb_stage.sv            picks what gets written back to the register file
│   └── single_cycle_rv32i.sv  top level that wires everything together
└── sim/
    ├── tb_single_cycle.sv     testbench
    
```

## How the pieces fit together

- **IF:** The PC sends its address to instruction memory, and the PC moves to PC+4 unless a branch or jump is taken.
- **ID:** The decoder splits the instruction into rs1, rs2, rd, funct3, funct7 and the five immediate formats. The immediate generator picks the right one, main control sets the control signals, and the register file reads rs1 and rs2.
- **EX:** The ALU control picks the operation. The ALU's first input is rs1, the PC (for `auipc`), or zero (for `lui`). Its second input is rs2 or the immediate. Branch conditions and jump targets are worked out here too.
- **WB:** A 3-way mux picks what goes into `rd`: the ALU result, data loaded from memory, or PC+4 (the return address for `jal`/`jalr`).

### Control signals

| Signal | Meaning |
|---|---|
| `alu_op` | `00` add, `01` branch, `10` R-type, `11` I-type ALU |
| `alu_src` | `0` use rs2, `1` use the immediate |
| `a_sel` | `00` rs1, `01` PC (auipc), `10` zero (lui) |
| `wb_sel` | `00` ALU result, `01` load data, `10` PC+4 |

## Design decisions

- **Immediates are built once, in the decoder.** All five formats (I, S, B, U, J) come out of `decoder_interface` already sign-extended. The branch and jump ones already include the shift by 1, so nothing downstream shifts them again.
- **`funct7[5]` is only checked when it matters.** For `addi` that bit is just part of the immediate, so it's ignored. It's only used for `sub`, `sra` and `srai`. Otherwise something like `addi x1, x0, -1024` would turn into a subtract.
- **x0 can never change.** The register file blocks writes to x0 and returns 0 on reads of it.
- **`jalr` clears bit 0** of its target address, as the spec requires.
- **Shifts only use the low 5 bits** of the second operand.

## How to run it

You need Vivado. I used version 2025.1

1. Create a new RTL project in Vivado.
2. Add every file in `src/` as a **design source**.
3. You can run linter to check the block diagram.




