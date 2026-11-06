.data
A:      .word 48         # Example value for A
B:      .word 18         # Example value for B

.text
.globl main

main:
    # 1. Load arguments A and B into a0 and a1
    la t0, A
    lw a0, 0(t0)         # a0 = A (argument 1)
    la t0, B
    lw a1, 0(t0)         # a1 = B (argument 2)
    
    # 2. Call gcd procedure
    jal ra, gcd          # ra = return address, jumps to gcd
    
    # 3. a0 now holds the GCD
    mv t0, a0            # Save result to t0
    
    # 4. Print the result
    # Syscall code in a7, argument to print in a0
    mv a0, t0            # Move GCD into a0 (argument for print)
    li a7, 1             # Syscall code 1 = Print Integer
    ecall

    # 5. Exit the program
    li a7, 10            # Syscall code 10 = Exit
    ecall

# --- Procedure: gcd ---
# Arguments: a0 = a, a1 = b
# Returns: a0 = gcd(a, b)
gcd:
    # Save return address to stack (procedure discipline)
    addi sp, sp, -8
    sw ra, 4(sp)
    
gcd_loop:
    # Check condition: while (b != 0)
    beqz a1, gcd_end
    
    # Euclid's algorithm:
    # temp = b
    mv t0, a1            # t0 = b
    
    # b = a % b
    rem a1, a0, a1       # a1 = a % b
    
    # a = temp
    mv a0, t0            # a0 = temp
    
    j gcd_loop

gcd_end:
    # Result is already in a0 (which holds 'a')
    
    # Restore return address and stack
    lw ra, 4(sp)
    addi sp, sp, 8
    ret                  # Return to caller