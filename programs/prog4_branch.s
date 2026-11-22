# prog4_branch.s
# Corner cases for control flow. The program checks itself: every check that
# behaves correctly adds 1 to x31, and any instruction that should have been
# skipped adds 1 to x30.
#
# Expected final state
#   x31 = 8    all eight checks passed
#   x30 = 0    nothing that should be skipped was executed
#   x12 = 42   6 * 7 from the nested loop
#   x10 = 0    x11 = 0    x13 = 42    x14 = 42
#   mem[0] = 42

        addi x1,  x0, -1        # 0xFFFFFFFF
        addi x2,  x0, -1        # 0xFFFFFFFF
        addi x3,  x0, 1

# 1. BEQ with two equal negative numbers: taken
        beq  x1,  x2, c1
        addi x30, x30, 1        # skipped
c1:     addi x31, x31, 1        # check 1

# 2. BNE with equal operands: not taken
        bne  x1,  x2, c2
        addi x31, x31, 1        # check 2 (falls through)

# 3. BEQ with -1 and +1: not taken
c2:     beq  x1,  x3, c3
        addi x31, x31, 1        # check 3 (falls through)

# 4. BNE with different operands: taken, skips two instructions
c3:     bne  x1,  x3, c4
        addi x30, x30, 1        # skipped
        addi x30, x30, 1        # skipped
c4:     addi x31, x31, 1        # check 4

# 5. BNE x0, x0 can never be taken
        bne  x0,  x0, c5
        addi x31, x31, 1        # check 5 (falls through)

# 6 and 7. forward branch over a block, then a backward BEQ into it
c5:     beq  x0,  x0, fwd
back:   addi x31, x31, 1        # check 7 (only reachable by the backward branch)
        beq  x0,  x0, mul
fwd:    addi x31, x31, 1        # check 6
        beq  x3,  x3, back      # backward BEQ, taken

# nested loop: 6 * 7 by repeated addition
mul:    addi x10, x0, 6         # outer counter
        addi x12, x0, 0         # product
outer:  addi x11, x0, 7         # inner counter
inner:  addi x12, x12, 1
        addi x11, x11, -1
        bne  x11, x0, inner
        addi x10, x10, -1
        bne  x10, x0, outer
        sw   x12, 0(x0)         # mem[0] = 42

# 8. branch on a value that came from memory
        lw   x13, 0(x0)
        addi x14, x0, 42
        bne  x13, x14, halt     # equal, so not taken
        addi x31, x31, 1        # check 8
halt:   beq  x0,  x0, halt
