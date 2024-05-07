.data
    A: .word -4, 1

.text
    li s0 1
    la s1 A
    lw s2 0(s1)
    lw s3 4(s1)
    bge s2 s3 end
        sw s3 0(s1)
        sw s2 4(s1)

    end:
        li a7 10
        ecall