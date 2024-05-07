.data
    array1: .word 5, 10, 15, 9, 11
    array2: .word 1, 2, 3, 4, 5, 6, 7
    n1: .word 5
    n2: .word 7
    new_line: .string "\n"

.text
j start

average:
    # a0 return value
    # a1 vector address
    # a2 vector size
    mv t0 a1
    mv t1 a2
    li t2 0 # accumulator
    loop:
        ble t1 x0 end_loop
            lw t3 0(t0)
            add t2 t2 t3
            addi t0 t0 4
            addi t1 t1 -1
            j loop
        end_loop:
    div t2 t2 a2
    mv a0 t2
    jr x1

start:
    # First average call
    la a1 array1
    lw a2 n1
    jal average
    mv s0 a0

    # Second average call
    la a1 array2
    lw a2 n2
    jal average
    mv s1 a0

    # Print first average
    li a7 1
    mv a0 s0
    ecall
    
    # Print new line
    li a7 4
    la a0 new_line
    ecall

    # Print second average
    li a7 1
    mv a0 s1
    ecall

    # End program
    li a7 10
    ecall