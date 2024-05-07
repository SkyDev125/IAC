.text
    li  s0 1
    li  s1 2

    mv  a0 s0
    mv  a1 s1
    jal ra, sum
    mv s2 a0
    j end

sum:
    add a0, a0, a1
    jr  ra

end:
    li a7 1
    mv a0 s2
    ecall