# Lab 2 — Step 2 Discussion Answers

Worked example studied: `examples/2026/array-max/` (`model.cpp` and `array-max.s`).

## 1. Why is the loop test inverted (`i < n` in C++, `bge` in assembly)?

In C++, the condition `i < n` says when to *keep going*. In assembly, a
conditional branch does the opposite job: when its condition is true, it
*jumps away* from the next instruction. The loop body sits directly after the
test, so execution naturally falls into it. The only thing the branch needs to
do is jump **out** of the loop when it should stop.

The loop stops when `i < n` becomes false, which is `i >= n`. So the branch
that exits is `bge t1, a1, done`. If the original `blt` were used instead, the
program would jump when the loop should *continue*, and it would need a second
unconditional jump to get back into the body.

## 2. Pseudo-instructions and what they become

| Pseudo-instruction | Real instruction(s) in the machine code |
|--------------------|------------------------------------------|
| `li a7, 4`         | `addi a7, x0, 4` (add the constant to the zero register) |
| `mv s0, a0`        | `addi s0, a0, 0` (add zero) |
| `la a0, array`     | `auipc a0, <upper 20 bits>` followed by `addi a0, a0, <lower 12 bits>` |
| `ble t4, s1, skip` | `bge s1, t4, skip` (same test with the operands swapped) |

RISC-V keeps the real instruction set small and regular, so there is no
dedicated move, load-immediate or `ble`. The assembler provides pseudo-instructions
so the programmer can write readable code, while the hardware still only has to
implement a few simple instructions. `la` needs two real instructions because
an address is 32 bits but one `addi` immediate only holds 12 bits. `ble` has no
encoding of its own because swapping the operands of `bge` gives the same test.

(Check this table against the disassembly in Ripes for your own run.)

## 3. Why does `find_max` save `s1` but not `ra`?

- **`s1` is a callee-saved register.** The calling convention promises the
  caller that `s1` will have the same value when the procedure returns.
  `find_max` uses `s1` for the running maximum, so it must push the old value
  on the stack at the start and pop it before returning. Saving `s1` is
  therefore required.
- **`ra` is never overwritten.** `find_max` is a *leaf procedure*: it calls no
  other procedure, so there is no `jal` inside it that would replace `ra`. The
  return address from `main`'s call is still in `ra` at the end, and
  `jalr x0, ra, 0` returns correctly. Saving `ra` would be harmless but
  unnecessary work.

If `find_max` called another procedure, that inner `jal` would overwrite `ra`,
and `ra` would have to be saved on the stack first.
