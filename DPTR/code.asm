inicio:
nop
addi $t0, $zero, 10
slti $t1, $zero, 10
andi $t2, $zero, 10
ori $t3, $zero, 10
sw $t0, 0($zero)
lw $t0, 0($zero)
beq $zero, $zero, inicio
nop