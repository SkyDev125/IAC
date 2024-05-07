.data
    a: .word 3
    b: .word 4
    c: .word 5
    d: .word -1
    y: .zero 4

.text
    lw x5 a
    lw x6 b
    mul x7, x5, x6
    lw x5 c
    lw x6 d
    add x5, x5, x6
    div x7, x7, x5
    
    # save to memory
    la x5 y
    sw x7, 0(x5)

    # print
    li a7 1
    mv a0, x7
    ecall

    end: j end