push:
    addi sp, sp, -8
    sw ra 4(sp)


pop:
    la ra sp
    addi sp, sp 4