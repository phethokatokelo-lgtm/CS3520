.data
array:  .word 2, 7, 10, 15, 22, 33, 40   # The array of integers
size:   .word 7                          # The number of elements in the array
count:  .word 0                          # Memory location to store the final count

.text
.globl main

main:
    # 1. Initialize pointers and variables
    la t0, array         # t0 = base address of the array
    la t1, size
    lw t1, 0(t1)         # t1 = size (7)
    li t2, 0             # t2 = i (index) = 0
    li t3, 0             # t3 = count = 0

loop:
    # 2. Check loop condition: if i >= size, exit loop
    bge t2, t1, end_loop
    
    # 3. Array indexing: load array[i]
    # Calculate byte offset: i * 4 (since each word is 4 bytes)
    slli t4, t2, 2       # t4 = i * 4
    add t4, t0, t4       # t4 = base_address + (i * 4)
    lw t5, 0(t4)         # t5 = array[i]
    
    # 4. Bit test: check if array[i] is even
    # If the lowest bit is 1, the number is odd, so we skip incrementing
    andi t6, t5, 1       # t6 = array[i] & 1
    bnez t6, skip_inc    # If t6 != 0 (meaning odd), branch to skip_inc
    
    # 5. It's even, so increment the count
    addi t3, t3, 1

skip_inc:
    # 6. Increment loop counter (i++)
    addi t2, t2, 1
    j loop               # Jump back to start of loop

end_loop:
    # 7. Store the final count to memory
    la t0, count
    sw t3, 0(t0)
    
    # 8. Print the result
    # Syscall code in a7, argument to print in a0
    mv a0, t3            # Move count into a0 (argument for print)
    li a7, 1             # Syscall code 1 = Print Integer
    ecall

    # 9. Exit the program
    li a7, 10            # Syscall code 10 = Exit
    ecall