.data
N:      .word 5          # Example value for N

.text
.globl main

main:
    # 1. Load argument N into a0
    la t0, N
    lw a0, 0(t0)         # a0 = N (argument for factorial)
    
    # 2. Call factorial procedure
    jal ra, factorial    # ra = return address, jumps to factorial
    
    # 3. a0 now holds the result (N!)
    mv t0, a0            # Save result to t0 (so we don't lose it)
    
    # 4. Print the result
    # Syscall code in a7, argument to print in a0
    mv a0, t0            # Move result into a0 (argument for print)
    li a7, 1             # Syscall code 1 = Print Integer
    ecall

    # 5. Exit the program
    li a7, 10            # Syscall code 10 = Exit
    ecall

# --- Procedure: factorial ---
# Argument: a0 = n
# Returns: a0 = n!
factorial:
    # Save return address to stack (procedure discipline)
    addi sp, sp, -8
    sw ra, 4(sp)
    
    li t0, 1             # t0 = result = 1
    li t1, 1             # t1 = i = 1
    
fact_loop:
    # Check condition: if i > n, exit loop
    bgt t1, a0, fact_end
    
    # result = result * i
    mul t0, t0, t1
    
    # i++
    addi t1, t1, 1
    j fact_loop

fact_end:
    mv a0, t0            # Return result in a0
    
    # Restore return address and stack
    lw ra, 4(sp)
    addi sp, sp, 8
    ret                  # Return to caller (jalr x0, 0(ra))