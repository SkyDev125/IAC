.data
    A: .word 4, -1, 5, 3, -6, -6
    N: .word 6

.text
    li s0 1 # n_trocas
    lw s2 N
    loop1: 
        beq s0 x0 4f
            li s0 0 # n_trocas = 0
            li t0 1 # i = 1
            la s1 A
            loop2: 
                bge t0 s2 continue1 # while i < n
                    # Exchange
                    lw t1 0(s1) 
                    lw t2 4(s1)
                    bge t2 t1 continue2
                        sw t2 0(s1)
                        sw t1 4(s1)
                        addi s0 s0 1 # Increment n_trocas
                    
                    continue2:
                    addi s1 s1 4
                    addi t0 t0 1
                    j loop2
                continue1: 
        j loop1
    end: 
        li a7 10
        ecall
