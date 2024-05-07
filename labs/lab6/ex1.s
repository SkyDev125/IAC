# f = x5
# g = x6
# h = x7
# i = x28
# j = x29
# A = x10
# B = x11

mv x5 x10
mv x6 x11

addi x6 x6 32   # B[8] 8*4
sub x7 x28 x29  # i-j
slli x7 x7 2    # (i-j)*4
add x5 x5 x7    # A[i-j]

lw x5 0(x5)
sw x5 0(x11)
