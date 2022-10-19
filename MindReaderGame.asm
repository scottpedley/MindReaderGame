.data
    array: .word 0, 1, 2, 3, 4, 5
    arrElement: .word 0
    soundYes: .word 1
    soundNo: .word 0
    newLine: .asciiz "\n"
    question: .asciiz "Is your number on the card above (y/n)? "
    question2: .asciiz "Would you like to play again? (y/n)? "
    question3: .asciiz "ERROR: INVALID INPUT "
    answerPrompt: .asciiz "The number you were thinking of was "
    buffer: .space 2
    yes: .asciiz "y"
    no: .asciiz "n"

.text

# ----------- Array Shuffle (AS)----------- #


AS_main:
    addi $s0, $zero, 0  # $s0 - array index 
    addi $a1, $zero, 6  # $a1 - upper bound for random number 
     

AS_FirstLoop:
    # branches once the loop has iterated 6 times
    slti $t0, $s0, 6 
    beq $t0, $zero, M_OuterLoop

    # generates random number
    li $v0, 42
    syscall

    # temp = array[i] stored in t3
    sll $t2, $s0, 2
    lw $t3, array($t2)

    # loading array[randomIndex] into t5
    sll $t4, $a0, 2
    lw $t5, array($t4)

    # array[i] = array[randomIndex]
    sw $t5, array($t2)

    # array[randomIndex] = temp
    sw $t3, array($t4)
    addi $s0, $s0, 1
    j AS_FirstLoop

# ----------- Display Card (DC)----------- #

DC_start:
    addi $s1, $zero, 1  # value that will be shifted
    sll $t7, $s0, 2 # multiplies array index by 4
    lw $t2, array($t7)
    sw $t2, arrElement
    addi $s2, $zero, 0

# this for loop is for doing 2^(bit number)
DC_for:
    slt $t0, $s2, $t2
    beq $t0, $zero, DC_endFor
    sll $s1, $s1, 1
    addi $s2, $s2, 1
    j DC_for

DC_endFor:
    addi $s3, $zero, 1  # creating new array index variable
    addi $s4, $zero, 0  # making new lines for formatting output

DC_FirstLoop:
    # branching once the loop has iterated 63 times
    slti $t0, $s3, 64
    beq $t0, $zero, DC_end

    # testing if the current number contains the card bit
    and $t4, $s3, $s1

    # if it does contain the card bit, the continue. If it doesn't, jump to beginning of the loop
    slt $t0, $t4, $s1
    bne $t0, $zero, DC_increment

    # outputting the number
    addi $a0, $s3, 0
    li $v0, 1
    syscall

    # outputting the space
    addi $a0, $zero, 32
    li $v0, 11
    syscall

    # incrementing the variable used to create spaces for more readable output
    addi $s4, $s4, 1

    # creating a new line every 8 numbers so the output looks more readable
    slti $t0, $s4, 8
    bne $t0, $zero, DC_increment
    li $v0, 4
    la $a0, newLine
    syscall
    addi $s4, $zero, 0

DC_increment:
    # incremet array index 
    addi $s3, $s3, 1
    j DC_FirstLoop

DC_end: 
    j I_ask

# ----------- Input (I) ----------- #
I_ask:
    # print question y/n
    li $v0, 4     
    la $a0, question 
    syscall

     # get user input
    li   $v0, 8
    la   $a0, buffer
    li   $a1, 2
    move $t5,$a0
    syscall
  
    # sound for input
    la $t8, soundYes
    li $t9, 114

    li $a0, 100
    li $v0, 32
    syscall

    li $a0, 62 
    li $a1, 500
    move $a2, $t2
    li $a3, 120
    la $v0, 33
    syscall
    # end of sound for input

    # compare input with yes/no
    lb $t1, no
    lb $t6, yes
    lb $t5, 0($t5)
    
    # error message if invalid input
    beq $t5, $t6, I_skip 
    beq $t5, $t1, I_skip 
    j M_error
    
    I_skip :
    bne $t5, $t6, M_Loop 
    move $t7, $s1
    
    # update sum
    add $s7, $s7, $t7 
    j M_Loop
  
# ----------- Main (M) ----------- #

M_OuterLoop:
    # begins loop that runs through array
    addi $s0, $zero, 0 # array index
    addi $s7, $zero, 0 # $s7 - sum

    j DC_start

M_Loop:
    # loops through randomized array
    slti $t0, $s0, 5
    beq $t0, $zero, M_printSum
    sll $t2, $s0, 2
    lw $a0, newLine
    li $v0, 11
    syscall
    addi $s0, $s0, 1
    j DC_start


M_printSum:
    # prints sum
    li $v0, 4
    la $a0, newLine
    syscall
    la $a0, answerPrompt
    syscall
    move $a0, $s7
    li $v0, 1
    syscall
    j M_reset

M_reset:

    # new line formatting
    li $v0, 4
    la $a0, newLine
    syscall

   # ask user if play again
    li $v0, 4     
    la $a0, question2 
    syscall
    
     # get user input
    li   $v0, 8
    la   $a0, buffer
    li   $a1, 2
    move $t5,$a0
    syscall   
    
    # compare and branch
    lb $t6, yes
    lb $t5, 0($t5)
    bne $t5, $t6, M_End
    li $v0, 4
    la $a0, newLine
    syscall
    j AS_main

M_error:
    # displays error message upon invalid input
    lw $a0, newLine
    li $v0, 11
    syscall
    
    li $v0, 4     
    la $a0, question3 
    syscall
    
    lw $a0, newLine
    li $v0, 11
    syscall
    j I_ask



M_End:
    # terminate program
    li $v0, 10
    syscall
    
    

