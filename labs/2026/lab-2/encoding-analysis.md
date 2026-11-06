# Lab 2 — Step 5: Encoding Analysis

**Source file:** `ex1-larger-of-two/solution.s`

## 1. Branch Instruction (B-type)

**Instruction (as written):** `bgt t1, t2, print_a`
**Instruction (as assembled by Ripes):** `blt x6, x7, <print_a>`
**Ripes 32-bit encoding:** `0x0063C463`

### Binary
0000 0000 0110 0011 1100 0100 0110 0011

### Field split

| Field       | Bits  | Value   | Meaning                       |
|-------------|-------|---------|-------------------------------|
| imm[12]     | 31    | 0       |                               |
| imm[10:5]   | 30–25 | 000000  |                               |
| rs2         | 24–20 | 00111   | x7 (t2)                       |
| rs1         | 19–15 | 00110   | x6 (t1)                       |
| funct3      | 14–12 | 100     | BLT (branch if less than)     |
| imm[4:1]    | 11–8  | 0100    |                               |
| imm[11]     | 7     | 0       |                               |
| opcode      | 6–0   | 1100011 | BRANCH                        |

### Reconstructed immediate
imm[12] | imm[11] | imm[10:5] | imm[4:1] | imm[0]=0
0 0 000000 0100 0
→ offset = `0b000000001000` = **+8 bytes** (target address `0x20`, current PC `0x18`)

**Format: B-type** (opcode `1100011`)

> **Note:** Ripes inverted the branch because `bgt` is a pseudo-instruction.
> It assembled to `blt x6, x7, <print_a>` — the operands swapped, funct3 = `100` (BLT).

---

## 2. Jump Instruction (J-type)

**Instruction (as written):** `j print_b`
**Instruction (as assembled by Ripes):** `jal x0, <print_b>`
**Ripes 32-bit encoding:** `0x0140006F`

### Binary
0000 0001 0100 0000 0000 0000 0110 1111

### Field split

| Field       | Bits  | Value      | Meaning                    |
|-------------|-------|------------|----------------------------|
| imm[20]     | 31    | 0          |                            |
| imm[10:1]   | 30–21 | 0000000000 |                            |
| imm[11]     | 20    | 0          |                            |
| imm[19:12]  | 19–12 | 00000001   |                            |
| rd          | 11–7  | 00000      | x0 (zero) — no link        |
| opcode      | 6–0   | 1101111    | JAL                        |

### Reconstructed immediate
imm[20] | imm[19:12] | imm[11] | imm[10:1] | imm[0]=0
0 00000001 0 0000000000 0
→ offset = `0b0000000000010100` = **+20 bytes** (target address `0x30`, current PC `0x1C`)

**Format: J-type** (opcode `1101111`)

> **Note:** `j label` is a pseudo-instruction for `jal x0, label`. Because `rd = x0`,
> no return address is saved — this is a true unconditional jump.

## 3. Why is the immediate scattered?

The immediate bits are deliberately scattered across the instruction word so
that the register specifiers (`rs1`, `rs2`, `rd`) and the `opcode` always sit
in the **same bit positions across all formats** (R, I, S, B, J). This lets
the CPU's register-file read and instruction-decode hardware begin work
immediately, without waiting to know which format the instruction is.
