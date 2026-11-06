# Lab 3 – Trace Tables (trace-classes.s, RISC-V Single Cycle, Extended layout)

## Program layout (from the Instruction memory panel – 18 rows, source has 17 lines)

`la a0, val` is a pseudo-instruction and expands to `auipc` + `addi`, hence 18 rows.

| Addr | Instruction | Executed? |
|------|-------------|-----------|
| 0x00 | addi t0, zero, 12 | yes |
| 0x04 | addi t1, zero, 5 | yes |
| 0x08 | add t2, t0, t1 | yes |
| 0x0C | sub t3, t0, t1 | yes |
| 0x10 | lui t4, 0x2B | yes |
| 0x14 | auipc t5, 0x0 | yes |
| 0x18 | auipc a0, ... (la, part 1) | yes |
| 0x1C | addi a0, a0, ... (la, part 2) | yes |
| 0x20 | lw a1, 0(a0) | yes |
| 0x24 | sw t2, 4(a0) | yes |
| 0x28 | beq t0, t1, skip | yes (not taken) |
| 0x2C | bne t0, t1, target | yes (taken) |
| 0x30 | addi a2, zero, 99 (skip) | **never** |
| 0x34 | jal ra, report | yes |
| 0x38 | addi a7, zero, 10 | yes (after return) |
| 0x3C | ecall | yes |
| 0x40 | addi a2, zero, 7 | yes |
| 0x44 | jalr zero, ra, 0 | yes |

## Step 3 – add t2, t0, t1 (PC = 0x00000008)

| Element | Port | Value |
|---------|------|-------|
| pc_reg | out | 0x00000008 |
| pc_4 | out | 0x0000000C |
| instr_mem | data_out | 0x006283B3 |
| decode | r1_reg_idx / r2_reg_idx | 5 / 6 |
| decode | wr_reg_idx | 7 |
| control | reg_do_write_ctrl | 1 |
| control | alu_op2_ctrl | 0 (register, not immediate) |
| registerFile | r1_out / r2_out | 12 / 5 |
| alu_op1_src | out | 12 |
| alu_op2_src | out | 5 |
| alu | res | 17 |
| data_mem | wr_en | 0 |
| reg_wr_src | select / out | ALU result / 17 |
| pc_src | select / out | 0 / 0x0000000C |

*Verified against Ripes: pc_4 = 0xC, instr = 0x006283B3, r1/r2 = 12/5, alu res = 0x11 (17), write-back out = 0x11, branch output = 0, data_mem Wr = 0. Ripes also showed imm = 0xdeadbeef and data_mem data_out = 0x170002be: junk, ignored for R-type.*

## Step 4 – every class

Predictions are in the section at the end of this file.

| Instruction | Format | imm | op1 mux | op2 mux | alu.res | wb mux / pc mux |
|---|---|---|---|---|---|---|
| addi t0, zero, 12 | I | 12 | reg (zero = 0) | imm (12) | 12 | ALU / PC+4 (0x04) |
| add t2, t0, t1 | R | n/a (Ripes shows junk 0xdeadbeef, unused) | reg (12) | reg (5) | 17 | ALU / PC+4 |
| lui t4, 0x2B | U | 0x2B000 (176128) | not used (don't care) | imm | 176128 (0x2B000), ALU passes op2 | ALU / PC+4 |
| auipc t5, 0x0 | U | 0 | **PC** (0x14) | imm (0) | 20 (0x14) | ALU / PC+4 |
| lw a1, 0(a0) | I | 0 | reg (a0 = 0x10000000) | imm (0) | 0x10000000 | **Memory** (42) / PC+4 |
| sw t2, 4(a0) | S | 4 | reg (0x10000000) | imm (4) | 0x10000004 (268435460) | none written (RegWrite = 0) / PC+4 |
| beq t0, t1, skip | B | 8 | **PC** (0x28) | imm (8) | 0x30 (target) | branch unit = 0 → pc_src 0 → PC+4 (0x2C) |
| bne t0, t1, target | B | 8 | **PC** (0x2C) | imm (8) | 0x34 (target) | branch unit = 1 → pc_src 1 → 0x34 |
| jal ra, report | J | 12 | **PC** (0x34) | imm (12) | 0x40 (target) | **PC+4** (0x38 into ra) / pc_src 1 → 0x40 |
| jalr zero, ra, 0 | I | 0 | reg (ra = 0x38) | imm (0) | 0x38 | PC+4 (discarded: rd = zero) / pc_src 1 → 0x38 |

## Step 5 – Statistics (reset, run to completion)

| Item | Value |
|---|---|
| Instructions listed in panel | 18 |
| Instructions never executed | 1 (the `addi a2, zero, 99` at 0x30) |
| Instructions retired | 17 |
| Cycles | 17 (confirmed in Ripes) |
| CPI | 1.00 |
| IPC | 1.00 |

*Read from the Ripes Statistics panel: 17 cycles, 17 retired, CPI 1, IPC 1, clock rate about 1.47 Hz (a simulation figure that varies between runs).*

## Form answers

| Q | Answer |
|---|---|
| Q1 | 18 |
| Q2 | 1 |
| Q3 | 1.00 |
| Q4 | 176128 |
| Q5 | 20 |
| Q6 | 006283B3 |
| Q7 | 4 |
| Q8 | 268435460 |
| Q9 | 0 |
| Q10 | 1 |

## Predictions and Ripes check

Expected values for each instruction, checked against the simulator afterwards:

- lui: ALU result = 0x2B000 (176128). The ALU passes the immediate through, so operand 1 shouldn't matter.
- auipc: ALU operand 1 mux selects the PC, so result = PC + 0 = 0x14 (20).
- lw: ALU computes a0 + 0 = 0x10000000; write-back mux selects the memory output (42).
- sw: immediate = 4, ALU result = 0x10000004, RegWrite = 0 so no register is written.
- beq: t0 != t1, so the branch unit outputs 0 and pc_src stays 0 (PC goes to 0x2C).
- bne: t0 != t1, so the branch unit outputs 1, pc_src = 1, PC jumps to 0x34 and 0x30 is skipped.
- jal: ALU computes PC + 12 = 0x40; write-back mux selects PC+4 (0x38) into ra.
- jalr: ALU computes ra + 0 = 0x38; PC goes back to 0x38.
- Statistics: 17 instructions retired, 17 cycles, CPI = 1.00.

Result: the Ripes values in the Step 4 table and the Statistics panel (17 cycles, 17 retired, CPI 1) match every item above.
