
  .data
N:      .word 5          # Example value for N
sum:    .word 0          # Memory location to store the result

.text
.globl main

main:
    # 1. Load N into a register
    la t0, N             # Load address of N into t0
    lw t1, 0(t0)         # Load value of N (5) into t1
    
    # 2. Initialize loop variables
    li t2, 0             # t2 = sum = 0
    li t3, 1             # t3 = i = 1

loop:
    # 3. Check loop condition: if i > N, exit loop
    bgt t3, t1, end_loop
    
    # 4. Body of loop: sum = sum + i
    add t2, t2, t3
    
    # 5. Increment i
    addi t3, t3, 1
    
    # 6. Jump back to start of loop
    j loop

end_loop:
    # 7. Store the final sum to memory
    la t0, sum
    sw t2, 0(t0)
    
    # 8. Print the result
    # In your simulator, the syscall code goes in a7.
    # The argument (the number to print) goes in a0.
    mv a0, t2            # Move sum into a0 (argument for print)
    li a7, 1             # Syscall code 1 = Print Integer
    ecall

    # 9. Exit the program
    li a7, 10            # Syscall code 10 = Exit
    ecall