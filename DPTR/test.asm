l1:
    addi $t0, $zero, 1
    nop
    nop
l2:
    beq $t0, $t0, l3
    nop
    nop
    nop
l3:
    bne $t0, $t0, l4
    nop
    nop
    nop
l4:
    bgtz $t0, l1
    nop
    nop
    nop