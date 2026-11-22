# prog3_corner.s
# Corner cases for the datapath: immediates at their limits, writes to x0,
# signed overflow, logic identities, and memory accesses with a negative
# offset and at the last word of data memory.
#
# There is no LUI in our subset, so the large constant 0x80000000 is built by
# doubling 1 thirty-one times in a loop.
#
# Expected final state
#   x1  = 2047 (0x000007FF)      largest ADDI immediate
#   x2  = -2048 (0xFFFFF800)     smallest ADDI immediate
#   x3  = -1 (0xFFFFFFFF)
#   x4  = 0                      x0 was not changed by the two writes
#   x5  = 0x80000000             most negative number
#   x6  = 0
#   x7  = 0x7FFFFFFF             most positive number
#   x8  = 0x80000000             0x7FFFFFFF + 1 wraps around
#   x9  = -2 (0xFFFFFFFE)        carry out of bit 31 is dropped
#   x10 = 0x80000000             0 - 0x80000000 is still 0x80000000
#   x11 = -4095 (0xFFFFF001)
#   x12 = 0   x13 = 0   x14 = 0xFFFFFFFF   x15 = 0x80000000
#   x16 = 16
#   x17 = 0x7FFFFFFF   x18 = 0x80000000   x19 = 0xFFFFFFFF   x20 = 0
#   mem[12] = 0x7FFFFFFF   mem[252] = 0xFFFFFFFF

# --- immediates at the limits of the 12-bit field ---
        addi x1,  x0, 2047      # largest positive immediate
        addi x2,  x0, -2048     # most negative immediate
        add  x3,  x1, x2        # 2047 + (-2048) = -1

# --- x0 must stay zero ---
        addi x0,  x0, 5         # write to x0, must be ignored
        add  x0,  x1, x1        # write to x0, must be ignored
        add  x4,  x0, x0        # x4 = 0 proves x0 is still 0

# --- build 0x80000000 = 1 doubled 31 times ---
        addi x5,  x0, 1
        addi x6,  x0, 31
dbl:    add  x5,  x5, x5        # same register as source and destination
        addi x6,  x6, -1
        bne  x6,  x0, dbl

# --- overflow and wraparound ---
        addi x7,  x5, -1        # 0x80000000 - 1 = 0x7FFFFFFF
        addi x8,  x7, 1         # 0x7FFFFFFF + 1 = 0x80000000 (overflow)
        add  x9,  x3, x3        # -1 + -1 = -2
        sub  x10, x0, x5        # 0 - 0x80000000 = 0x80000000
        sub  x11, x2, x1        # -2048 - 2047 = -4095

# --- logic identities ---
        xor  x12, x7, x7        # a ^ a = 0
        and  x13, x7, x5        # no bits in common = 0
        or   x14, x7, x5        # every bit set = 0xFFFFFFFF
        xor  x15, x3, x7        # 0xFFFFFFFF ^ 0x7FFFFFFF = 0x80000000

# --- memory corner cases ---
        addi x16, x0, 16
        sw   x7,  -4(x16)       # negative offset: address 12
        lw   x17, -4(x16)       # read it straight back
        sw   x5,  252(x0)       # last word of data memory
        lw   x18, 252(x0)
        sw   x3,  236(x16)      # 16 + 236 = 252: overwrite the same word
        lw   x19, 252(x0)       # must see the new value
        lw   x0,  252(x0)       # load into x0, must be ignored
        add  x20, x0, x0        # x20 = 0 proves x0 is still 0
halt:   beq  x0,  x0, halt
