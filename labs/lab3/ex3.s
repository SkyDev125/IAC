.data
    val: .word 1,2,3,4,5,6,7,8
    m: .zero 4
    var: .zero 4
    new_line: .string "\n"
    str_average: .string "average: "
    str_variancia: .string "variancia: "

.text
    # initialize values
    la x10 val
    li x1 0 # accumulator
    li x2 0 # start
    li x3 8 # end
    average:
        lw x11, 0(x10)
        add x1, x1, x11
        
        # Move to next value
        addi x10, x10, 4
        addi x2, x2, 1
        bne x2, x3, average
        div x20, x1, x3 # save average
        
    # restart values
    la x10 val
    li x1 0 # accumulator
    li x2 0 # start
    li x3 8 # end
    variance:
        lw x11, 0(x10)
        sub x1, x11, x20
        mul x1, x1, x1
        add x21, x21, x1
        
        # Move to next value
        addi x10, x10, 4
        addi x2, x2, 1
        bne x2, x3, variance
        addi x3, x3, -1
        div x21, x21, x3 # save variance
        
    print:
        # average
        li a7 4
        la a0, str_average
        ecall
        
        li a7 1
        mv a0 x20
        ecall
        
        li a7 4
        la a0, new_line
        ecall
        
        #variance
        li a7 4
        la a0, str_variancia
        ecall
        
        li a7 1
        mv a0 x21
        ecall