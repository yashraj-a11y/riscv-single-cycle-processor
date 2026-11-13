# prog1_arith.s
# Tests: ADDI, ADD, SUB, AND, OR, XOR, SW, LW (and BEQ as the halt loop)
#
# Expected final state
#   x1 = 10   x2 = 6    x3 = 16   x4 = 4    x5 = 2    x6 = 14
#   x7 = 12   x8 = -3 (0xFFFFFFFD)  x9 = 16  x10 = 4  x11 = 20
#   mem[0] = 16   mem[4] = 4   mem[8] = 20

        addi x1,  x0, 10        # x1 = 10
        addi x2,  x0, 6         # x2 = 6
        add  x3,  x1, x2        # x3 = 10 + 6  = 16
        sub  x4,  x1, x2        # x4 = 10 - 6  = 4
        and  x5,  x1, x2        # x5 = 1010 & 0110 = 0010 = 2
        or   x6,  x1, x2        # x6 = 1010 | 0110 = 1110 = 14
        xor  x7,  x1, x2        # x7 = 1010 ^ 0110 = 1100 = 12
        addi x8,  x0, -3        # negative immediate (sign extension)
        sw   x3,  0(x0)         # mem[0] = 16
        sw   x4,  4(x0)         # mem[4] = 4
        lw   x9,  0(x0)         # x9  = 16
        lw   x10, 4(x0)         # x10 = 4
        add  x11, x9, x10       # x11 = 20
        sw   x11, 8(x0)         # mem[8] = 20
halt:   beq  x0,  x0, halt      # stop here forever
