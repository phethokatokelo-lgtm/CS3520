# Lab 3 – Datapath Notes

## Step 2 – Think: the third write-back input
The write-back mux has three inputs: ALU result, data-memory output and **PC+4**. The textbook MemtoReg is two-way. PC+4 is required by `jal` and `jalr`, which must save a return address in `rd`. Without it, neither function calls nor returns could work.

## Step 3 – Think: data_mem.addr during `add`
`data_mem.addr` is wired straight to `alu.res`, so it shows 17 for every instruction. It is harmless because `wr_en` = 0 (nothing is stored) and `reg_wr_src` selects the ALU result, ignoring the memory output. The cost is time: the memory is on the path of every instruction, so the clock period must cover the slowest instruction (`lw`) and every instruction pays for it.

## Step 4 – Questions
1. **lui vs auipc.** The ALU operand-1 mux, together with the ALU operation, makes the difference. `auipc` selects the PC for operand 1, so the result is PC + imm. `lui` does not use the PC; the ALU passes the immediate (operand 2) through, so the result is just imm << 12. (Verify the exact lui path in your Ripes build by clicking the wires.)
2. **sw.** `reg_do_write_ctrl` (RegWrite) is 0. The write-back mux still selects the ALU result, but with no write enable the register file ignores it.
3. **beq vs bne.** The branch unit compares rs1 and rs2 and outputs its result. `br_and` ANDs it with the Branch control signal, and `controlflow_or` ORs that with the Jump signal; its output drives `pc_src.select`. For `beq` (12 ≠ 5) the unit outputs 0 and pc_src stays 0 (PC+4). For `bne` the unit outputs 1, so pc_src is 1 and the PC takes the ALU's target.
4. **jal/jalr return address.** It comes from the **PC+4 input** of the write-back mux. The ALU cannot supply it because it is busy computing the jump target (PC + imm for jal, rs1 + imm for jalr). Data memory cannot, because the return address is not stored in memory.

## Step 5 – Think: which term did the design sacrifice?
CPU time = IC × CPI × Tc. IC is fixed by the ISA and CPI is already the ideal 1.00, so the sacrificed term is **Tc**. The clock period equals the sum of the delays along the longest path (instruction fetch, register read, ALU, data memory, register write, as in `lw`), so every instruction runs at the speed of the slowest. In the Week 7 worked exercise, a pipelined design with the same components would have a clock set by the slowest single stage, roughly 4–5x shorter (e.g. about 800 ps total vs about 200 ps for the longest stage). Fill in your own Week 7 numbers here.

## Step 6 – Differences from the Week 6 figure

**A. No dedicated branch adder.** The ALU computes the branch/jump target: `alu_op1_src` selects the PC, `alu_op2_src` selects the immediate, and the ALU produces PC + offset. The implementer gains less hardware (one adder fewer, less area and wiring). In a single-cycle design the ALU has nothing else to do during a branch, since the comparison is done elsewhere, so no performance is lost.

**B. Separate comparison (branch) unit.** The Week 6 design tests the ALU's Zero output after a subtraction. The branch unit instead compares the operands directly. It supports signed and unsigned less-than and greater-or-equal, which a Zero flag cannot give cleanly (and subtraction can overflow). The instructions that need it are `blt`, `bge`, `bltu` and `bgeu` (beq and bne also use it). It also frees the ALU to compute the target in the same cycle as the comparison, which is what makes finding A possible.

**C. Three-input write-back mux.** The third input is PC+4. `jal` and `jalr` depend on it to write the return address. `lw` uses the memory input, and all arithmetic, lui and auipc use the ALU input.

**Think – dedicated adder vs reusing the ALU.**
- *Dedicated adder (textbook):* costs extra area, but the ALU stays free, so target and operation can proceed in parallel. Choose it where the ALU is busy in the same cycle, e.g. in a pipelined processor where the ALU serves another instruction while the branch target is computed, or when speed matters more than area.
- *Reusing the ALU (Ripes):* saves hardware, but needs extra muxes on the ALU inputs and ties up the ALU. Choose it when only one instruction is in flight per cycle (a single-cycle design) or in a small, low-cost design where area matters more.
