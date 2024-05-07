.data
    n: .word 4
    a: .word 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
    b: .zero 128

.text
    li s0 0 #i
    lw s2 n
    loop1:
        bge s0 s2 continue1
        li s1 0 #j
        loop2:
            bge s1 s2 continue2
            
            # (i*n +j)*4
            mv t2  s0
            mul t2 t2 s2
            add t2 t2 s1
            mul t2 t2 s2

            # (j*n + i)*4
            mv t3  s1
            mul t3 t3 s2
            add t3 t3 s0
            mul t3 t3 s2

            la t0 a
            la t1 b

            add t1 t1 t2
            add t0 t0 t3

            # B[i*n +j] = A[j*n + I]
            lw t4 0(t0)
            sw t4 0(t1)

            # j++
            addi s1 s1 1
            j loop2
            continue2:
        
        #i++ 
        addi s0 s0 1
        j loop1
        continue1:
            li a7 10
            ecall