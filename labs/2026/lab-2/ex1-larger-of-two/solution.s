.data
a: .word 12
b: .word 25

.text
.global main

main:
#load a and b from memory
la t0,a
lw t1,0(t0)  #t1=a
la t0, b 
lw t2, 0(t0) #t2=b

bgt t1, t2, print_a
j  print_b

print_a:
mv a0, t1
li a7, 1
ecall

j end

print_b:
mv a0, t2
li a7, 1
ecall

end:
li a7, 10
ecall

