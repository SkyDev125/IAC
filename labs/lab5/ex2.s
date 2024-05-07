.data
    array1: .word 5, 10, 15, 9, 11
    array2: .word 1, 2, 3, 4, 5, 6, 7
    n1: .word 5
    n2: .word 7
    new_line: .string "\n"

.text
j start

average:
    # Calculates the average of an array of numbers
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
    jr ra

average_arrays:
    # Calculates the average between two arrays of numbers
    # a0 return value
    # a1 first vector
    # a2 second vector
    # a3 first vector size
    # a4 second vector size

    # save arguments to stack before calling new function a1-a4 & ra
    addi sp sp -12
    sw a1 8(sp)
    sw a2 4(sp)
    sw ra 0(sp)

    # First average call
    mv a1 a1
    mv a2 a3
    jal average
    mv t0 a0
    
    # Recover values from stack
    lw a1 8(sp)
    lw a2 4(sp)
    lw ra 0(sp)
    addi sp sp 12

    # save arguments to stack before calling new function a1-a4 & ra
    addi sp sp -16
    sw t0 12(sp)
    sw a1 8(sp)
    sw a2 4(sp)
    sw ra 0(sp)

    # Second average call
    mv a1 a2
    mv a2 a4
    jal average
    mv t1 a0

    # Recover values from stack
    lw t0 12(sp)
    lw a1 8(sp)
    lw a2 4(sp)
    lw ra 0(sp)
    addi sp sp 16

    # v1average*size
    mul t0 t0 a3

    # v2average*size
    mul t1 t1 a4

    # add both values v1average*size + v2average*size
    add t0 t0 t1

    # add the sizes together
    li t1 0
    add t1 t1 a3
    add t1 t1 a4

    # (v1average*size + v2average*size) / (sizev1 + sizev2) 
    div a0 t0 t1
    jr ra

start:
    la s0 array1
    la s1 array2
    lw s2 n1
    lw s3 n2

    # Average arryas call
    mv a1 s0
    mv a2 s1
    mv a3 s2
    mv a4 s3
    jal average_arrays
    mv s4 a0
    
    # Print
    li a7 1
    mv a0 s4
    ecall
    
    # End program
    li a7 10
    ecall