addi $ra $zero 0

addi $t2 $zero 255 # 0x000000FF (byte mask)
addi $a0 $zero 544
addi $gp $zero 544
rotr $t2 $t2 8


findMessageEnd:

lw $a1 0($a0) # Load word into $a1
addi $a3 $a0 0 # Memory address of word
nop

and $a2 $a1 $t2 # If byte is 0x00
rotr $t2 $t2 8
nop
beq $a2 $zero foundMessageEnd # Found message ending byte
nop
nop
nop
addi $a0 $a0 1
nop
nop

and $a2 $a1 $t2 # If byte is 0x00
rotr $t2 $t2 8
nop
beq $a2 $zero foundMessageEnd # Found message ending byte
nop
nop
nop
addi $a0 $a0 1
nop
nop

and $a2 $a1 $t2 # If byte is 0x00
rotr $t2 $t2 8
nop
beq $a2 $zero foundMessageEnd # Found message ending byte
nop
nop
nop
addi $a0 $a0 1
nop
nop

and $a2 $a1 $t2 # If byte is 0x00
rotr $t2 $t2 8
nop
beq $a2 $zero foundMessageEnd # Found message ending byte
nop
nop
nop
addi $a0 $a0 1
nop
nop

j findMessageEnd
nop
nop
nop


foundMessageEnd:
sub $a2 $a0 $a3 # relative position of 0x00 byte in word ()
addi $t2 $zero 0
addi $t3 $zero 128
nop
nop


add $t0 $a2 $zero
nop
nop
maskLastWord:
slt $t1 $zero $t0
addi $t0 $t0 -1

rotr $t3 $t3 8
beq $t1 $zero addMask
nop
nop
nop
addi $t2 $t2 255
nop
nop
rotr $t2 $t2 8

j maskLastWord
nop
nop
nop


addMask:
and $a1 $a1 $t2
nop
nop
or $a1 $a1 $t3

sub $a2 $a0 $gp # length_bytes
addi $t0 $zero 56 # constant 56
sw $a1 0($a3) # save new message
sll $t2 $a2 3 # size of original message in bits (for padding)
nop
addi $a3 $a3 4 # first unknown word

addi $a2 $a2 1 # length_bytes + 1
nop
nop
andi $a2 $a2 63 # % 64
nop
nop
sub $a2 $t0 $a2 # 56 - a2
nop
nop
andi $a2 $a2 60 # % 64 (remove two last bits to make multiple of 4)
nop

add $t0 $a3 $zero
add $t1 $a3 $a2
nop
nop
padMessage:
beq $t0 $t1 padMessageEnd
nop
nop
nop

sw $zero 0($t0)
addi $t0 $t0 4
j padMessage
nop
nop
nop


padMessageEnd:
sw $zero 0($t0)
sw $t2 4($t0)

addi $a1 $t0 8 # end of padded message
addi $a0 $zero 544 # start of current message block
addi $a3 $zero 544 # end of chunk block
nop
nop
processChunk:
beq $a0 $a1 processChunkEnd
nop
nop
nop
addi $a2 $zero 288 # start of chunk block

lw $t0  0($a0)
lw $t1  4($a0)
lw $t2  8($a0)
lw $t3 12($a0)
lw $t4 16($a0)
lw $t5 20($a0)
lw $t6 24($a0)
lw $t7 28($a0)
sw $t0  0($a2)
sw $t1  4($a2)
sw $t2  8($a2)
sw $t3 12($a2)
sw $t4 16($a2)
sw $t5 20($a2)
sw $t6 24($a2)
sw $t7 28($a2)

lw $t0 32($a0)
lw $t1 36($a0)
lw $t2 40($a0)
lw $t3 44($a0)
lw $t4 48($a0)
lw $t5 52($a0)
lw $t6 56($a0)
lw $t7 60($a0)
sw $t0 32($a2)
sw $t1 36($a2)
sw $t2 40($a2)
sw $t3 44($a2)
sw $t4 48($a2)
sw $t5 52($a2)
sw $t6 56($a2)
sw $t7 60($a2)

addi $t8 $a2 64 # &chunk[16]
nop
nop
calculateW:
beq $t8 $a3 calculateWEnd
nop
nop
nop

addi $t9 $zero 0 # res
lw $t0 -64($t8)
lw $t1 -60($t8)
lw $t2 -28($t8)
lw $t3  -8($t8)

rotr $t4 $t1 7 # σ0
rotr $t5 $t1 18
srl $t6 $t1 3
nop
xor $t1 $t4 $t5
nop
nop
xor $t1 $t1 $t6
nop
nop

rotr $t4 $t3 17 # σ1
rotr $t5 $t3 19
srl $t6 $t3 10
nop
xor $t3 $t4 $t5
nop
nop
xor $t3 $t3 $t6
nop
nop


add $t9 $t9 $t0
nop
nop
add $t9 $t9 $t1
nop
nop
add $t9 $t9 $t2
nop
nop
add $t9 $t9 $t3
nop
nop
sw $t9 0($t8)


addi $t8 $t8 4
j calculateW
nop
nop
nop
calculateWEnd:

lw $s0  0($zero) # $s0-$s7 contain ha
lw $s1  4($zero)
lw $s2  8($zero)
lw $s3 12($zero)
lw $s4 16($zero)
lw $s5 20($zero)
lw $s6 24($zero)
lw $s7 28($zero)

addi $t8 $zero 288 # w[0]
addi $t9 $zero 32 # k[0]
nop
nop
calculateWorkingVars:
beq $t8 $a3 calculateWorkingVarsEnd
nop
nop
nop

addi $v0 $zero 0 # Temp1
addi $v1 $zero 0 # Temp2

lw $t0 0($t8) # t0 = w0
lw $t1 0($t9) # t1 = k0

rotr $t4 $s4 6 # $t2 = Σ1
rotr $t5 $s4 11
rotr $t6 $s4 25
nop
xor $t2 $t4 $t5
nop
nop
xor $t2 $t2 $t6

xori $t5 $s4 -1 # $t3 = Choice
and $t4 $s4 $s5
nop
and $t6 $t5 $s6
nop
nop
xor $t3 $t4 $t6

add $v0 $s7 $t0 # Temp1 = h + Σ1 + Choice + w0 + k0
nop
nop
add $v0 $v0 $t1
nop
nop
add $v0 $v0 $t2
nop
nop
add $v0 $v0 $t3

rotr $t4 $s0 2 # $t0 = Σ0
rotr $t5 $s0 13
rotr $t6 $s0 22
nop
xor $t0 $t4 $t5
nop
nop
xor $t0 $t0 $t6

and $t4 $s0 $s1 # $t1 = Majority
and $t5 $s0 $s2
and $t6 $s1 $s2
nop
xor $t1 $t4 $t5
nop
nop
xor $t1 $t1 $t6
nop
nop

add $v1 $t0 $t1 # Temp2 = Σ0 + Majority

add $s7 $s6 $zero # h = g
add $s6 $s5 $zero # g = f
add $s5 $s4 $zero # f = e
add $s4 $s3 $v0   # e = d + Temp1
add $s3 $s2 $zero # d = c
add $s2 $s1 $zero # c = b
add $s1 $s0 $zero # b = a
add $s0 $v0 $v1   # a = Temp1 + Temp2

addi $t8 $t8 4
addi $t9 $t9 4
j calculateWorkingVars
nop
nop
nop
calculateWorkingVarsEnd:

lw $t0  0($zero)
lw $t1  4($zero)
lw $t2  8($zero)
lw $t3 12($zero)
lw $t4 16($zero)
lw $t5 20($zero)
lw $t6 24($zero)
lw $t7 28($zero)
add $t0 $t0 $s0
add $t1 $t1 $s1
add $t2 $t2 $s2
add $t3 $t3 $s3
add $t4 $t4 $s4
add $t5 $t5 $s5
add $t6 $t6 $s6
add $t7 $t7 $s7
sw $t0  0($zero)
sw $t1  4($zero)
sw $t2  8($zero)
sw $t3 12($zero)
sw $t4 16($zero)
sw $t5 20($zero)
sw $t6 24($zero)
sw $t7 28($zero)


addi $a0 $a0 64
j processChunk
nop
nop
nop

processChunkEnd:

addi $ra $zero -1