.data
    between: .string "The greatest common divisor between "
    and: .string " and "
    is: .string " is: "

.text
    li s0 22
    li s1 22

    # Function call
    mv a0 s0
    mv a1 s1
    jal x1 mdc

    # Save return value
    mv s2 a0
    j end

    mdc:
        # Organize variables (if else)
        blt a0 a1 smaller
        mv t0 a0
        mv t1 a1
        j continue
        smaller:
            mv t0 a1
            mv t1 a0

        continue:
            beq t0 t1 mdc_end

            # Euclides algorithm
            loop: 
                mv t3 t1
                rem t1 t0 t1
                mv t0 t3
                bne t1 x0 loop

            # Return the MDC
            mdc_end:
                mv a0 t0
                jr x1

    end:
        li a7 4
        la a0 between
        ecall

        li a7 1
        mv a0 s0
        ecall

        li a7 4
        la a0 and
        ecall

        li a7 1
        mv a0 s1
        ecall

        li a7 4
        la a0 is
        ecall

        li a7 1
        mv a0 s2
        ecall