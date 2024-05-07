.text
    li    x5, 10
    li    x6, 23
    li    x7, 5
    li    x10, 0
    mul   x10, x5, x6
    add   x10, x10, x7

    li    a7 1
    mv    a0, x10
    ecall