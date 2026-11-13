# prog2_loop.s
# Sums 5 + 4 + 3 + 2 + 1 with a loop, then checks the answer.
# Tests: BNE taken (backward) and not taken, BEQ taken and not taken,
#        plus ADDI / ADD / SW / LW along the way.
#
# Expected final state
#   x1 = 0    x2 = 15   x4 = 15   x5 = 15
#   x6 = 1    (1 = self-check passed, -1 = failed)
#   x7 = 7    (proves the not-taken BEQ fell through)
#   mem[0] = 15

        addi x1, x0, 5          # n = 5
        addi x2, x0, 0          # sum = 0
loop:   add  x2, x2, x1         # sum += n
        addi x1, x1, -1         # n--
        bne  x1, x0, loop       # repeat until n == 0
        beq  x1, x2, skip       # 0 != 15, so NOT taken
        addi x7, x0, 7          # runs only because the BEQ fell through
skip:   sw   x2, 0(x0)          # mem[0] = 15
        lw   x4, 0(x0)          # x4 = 15
        addi x5, x0, 15         # expected answer
        addi x6, x0, 1          # assume pass
        beq  x4, x5, halt       # equal, so taken: skips the fail line
        addi x6, x0, -1         # fail marker (should be skipped)
halt:   beq  x0, x0, halt       # stop here forever
