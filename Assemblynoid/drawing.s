.include "constants.inc"
.include "drawing.inc"


# Global functions included in this file:
#   get_screen_pointer   
#   draw_horizontal_character_line
#   clear_board
#   draw_vertical_character_line
#   draw_play_field
#   draw_pallet
#   print_number_variable
#   print_text
#   print_block
#   draw_game_block_line
#   print_lives_counter
#   print_lives_counter
#   clear_position
#   clear_line

# Global memory objects/constants in this file:
#   clear/clear_length
#   update/update_length
#   nocursor/nocursor_length
#   clear_after_cursor/clear_after_cursor_length
#   nl/nl_lenght
#   msg_score/msg_score_length
#   msg_round/msg_round_length
#   msg_lives/msg_lives_length
#   numbers_text/numbers_text_length
#   board/board_size

.equ LIVES_PER_ROW, 6


.data

# For cleaning the screen
.global clear
clear: .byte 27, '[', '2', 'J', 27, '[', 'H'
.global clear_length
.equ clear_length, (. -clear)

#clear: .byte 27, '[', 'H', 27, '[', '2', 'J'
#.equ clear_length, (. -clear)

# This works for updating the screen
.global update
update: .byte 27, '[', 'H' 
.global update_length
.equ update_length, (. -update)

# Make the cursor invisible
.global nocursor
nocursor: .byte 27, '[', '?', '2', '5', 'l'
.global nocursor_length
.equ nocursor_length, (. -nocursor)

# Clean after cursor, for this, the vt100 commands are used 
# for manipulating the screen
# This was implemented as the screen accumulates garbage at 
# the end of the play zone
# So in order to clean that garbage, this commands are implemented
.global clear_after_cursor
clear_after_cursor:
.byte 27, '[', '1', ';', '8', '1', 'H', 27, '[', '0', 'K' 
.byte 27, '[', '2', ';', '8', '1', 'H', 27, '[', '0', 'K' 
.byte 27, '[', '3', ';', '8', '1', 'H', 27, '[', '0', 'K' 
.byte 27, '[', '4', ';', '8', '1', 'H', 27, '[', '0', 'K' 
.byte 27, '[', '5', ';', '8', '1', 'H', 27, '[', '0', 'K' 
.byte 27, '[', '6', ';', '8', '1', 'H', 27, '[', '0', 'K' 
.byte 27, '[', '7', ';', '8', '1', 'H', 27, '[', '0', 'K' 
.byte 27, '[', '8', ';', '8', '1', 'H', 27, '[', '0', 'K' 
.byte 27, '[', '9', ';', '8', '1', 'H', 27, '[', '0', 'K' 
.byte 27, '[', '1', '0', ';', '8', '1', 'H', 27, '[', '0', 'K' 
.byte 27, '[', '1', '1', ';', '8', '1', 'H', 27, '[', '0', 'K' 
.byte 27, '[', '1', '2', ';', '8', '1', 'H', 27, '[', '0', 'K' 
.byte 27, '[', '1', '3', ';', '8', '1', 'H', 27, '[', '0', 'K' 
.byte 27, '[', '1', '4', ';', '8', '1', 'H', 27, '[', '0', 'K' 
.byte 27, '[', '1', '5', ';', '8', '1', 'H', 27, '[', '0', 'K' 
.byte 27, '[', '1', '6', ';', '8', '1', 'H', 27, '[', '0', 'K' 
.byte 27, '[', '1', '7', ';', '8', '1', 'H', 27, '[', '0', 'K' 
.byte 27, '[', '1', '8', ';', '8', '1', 'H', 27, '[', '0', 'K' 
.byte 27, '[', '1', '9', ';', '8', '1', 'H', 27, '[', '0', 'K' 
.byte 27, '[', '2', '0', ';', '8', '1', 'H', 27, '[', '0', 'K' 
.byte 27, '[', '2', '1', ';', '8', '1', 'H', 27, '[', '0', 'K' 
.byte 27, '[', '2', '2', ';', '8', '1', 'H', 27, '[', '0', 'K' 
.byte 27, '[', '2', '3', ';', '8', '1', 'H', 27, '[', '0', 'K' 
.byte 27, '[', '2', '4', ';', '8', '1', 'H', 27, '[', '0', 'K' 
.byte 27, '[', '2', '5', ';', '8', '1', 'H', 27, '[', '0', 'K' 
.byte 27, '[', '2', '6', ';', '8', '1', 'H', 27, '[', '0', 'K' 
.byte 27, '[', '2', '7', ';', '8', '1', 'H', 27, '[', '0', 'K' 
.byte 27, '[', '2', '8', ';', '8', '1', 'H', 27, '[', '0', 'K' 
.byte 27, '[', '2', '9', ';', '8', '1', 'H', 27, '[', '0', 'K' 
.byte 27, '[', '3', '0', ';', '8', '1', 'H', 27, '[', '0', 'K' 
.byte 27, '[', '3', '1', ';', '8', '1', 'H', 27, '[', '0', 'K' 
.byte 27, '[', '3', '2', ';', '8', '1', 'H', 27, '[', '0', 'K' 
.byte 27, '[', '3', '3', ';', '1', 'H', 27, '[', '0', 'K' 
.global clear_after_cursor_length
.equ clear_after_cursor_length, (. -clear_after_cursor)

.global nl
nl: .byte 0xA, 0xD
.global nl_length
.equ nl_length, 2

.global msg_score
msg_score: .ascii "SCORE"
.global msg_score_length
.equ msg_score_length, (. - msg_score)

.global msg_round
msg_round: .ascii "ROUND"
.global msg_round_length
.equ msg_round_length, (. - msg_round)

.global msg_lives
msg_lives: .ascii "LIVES"
.global msg_lives_length
.equ msg_lives_length, (. -  msg_lives)



.global numbers_text
numbers_text: .ascii "0123456789"
.global numbers_text_length
.equ numbers_text_length, 10

.type board, %object
.global board
board:
    blank_line
    #full_line
    .rept 30
        blank_line
        #hollow_line
    .endr
    blank_line
    #bottom_line
.global board_size
.equ board_size, (. -board)
.size board, (. -board)

.text

.type get_screen_pointer, %function
.global get_screen_pointer
# Function: get_screen_pointer
#   This function calculates the screen pointer based on the x
#   and y coordinate of the object.
# Arguments:
#   x0: coordinate x
#   x1: coordinate y
# Return:
#   x0: Screen pointer of the object
get_screen_pointer:
    stp x29, x30, [sp, #-16]! 

    lsl x0, x0, #2
    lsl x1, x1, #2
    adr x2, board
    mov x3, COLUMN_CELLS_WITH_LINE_FEED
    add x2, x2, x0
    madd x2, x1, x3, x2
    mov x0, x2 

    ldp  x29, x30, [sp], #16
    ret
.size get_screen_pointer, (. -get_screen_pointer)


.type draw_horizontal_character_line, %function
.global draw_horizontal_character_line
# Function: write_horizontal_line
#   This function write a vertical line of a character that receives as
#   argument.
#   Receives as argument the caracter that is going to be written and 
#   the length of the line. Is is important to remember that the top 
#   left corner represents the 0,0 coordinates.
# Arguments:
#   x0: Starting x coordinate of the line
#   x1: Starting y coordiante of the line
#   x2: UTF character that is going to be printed on the line
#   x3: Line length
# Return: 
#   void.
# Macro:
# m_draw_horizontal_character_line x, y, utf_character, line_length
draw_horizontal_character_line:
    stp x29, x30, [sp, #-48]! 
    stp x19, x20, [sp, #16] 
    stp x21, x22, [sp, #32]
    
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3

    .whcl_loop:
        mov x0, x19
        mov x1, x20
        bl get_screen_pointer
        str w21, [x0]
        add x19, x19, #1
        sub x22, x22, #1
        cbnz x22, .whcl_loop

    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x29, x30, [sp], #48
    
    ret
.size draw_horizontal_character_line, (. -draw_horizontal_character_line)

.type clear_board, %function
.global clear_board
# Function: clear_board
#   This function clears the whole board after a screen change, for now 
#   is needed the that cover screen is presented and the game starts.
# Arguments:
#   None
# Return:
#   void.
clear_board:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16] 
    mov x19, #0
    mov x20, ROW_CELLS 
    
    .cb_loop:

        sub x20, x20, #1
        m_draw_horizontal_character_line x19, x20, UTF_SPACE, COLUMN_CELLS

        cbnz x1, .cb_loop

    .cb_end:

    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size clear_board, (. -clear_board)

.type draw_vertical_character_line, %function
.global draw_vertical_character_line
# Function: draw_vertical_character_line
#   This function prints a vertical line of a character that receives as
#   argument.
#   Receives as argument the caracter that is going to be printed and the
#   length of the line. Is is important to remember that the top left 
#   corner represents the 0,0 coordinates.
# Arguments:
#   x0: Starting x coordinate of the line
#   x1: Starting y coordiante of the line
#   x2: UTF character that is going to be printed on the line
#   x3: Line length
# Return: 
#   void.
# Macro:
# m_draw_vertical_character_line x, y, utf_character, line_length
draw_vertical_character_line:
    stp x29, x30, [sp, #-48]! 
    stp x19, x20, [sp, #16] 
    stp x21, x22, [sp, #32]
    
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3

    .pvc_loop:
        mov x0, x19
        mov x1, x20
        bl get_screen_pointer
        str w21, [x0]
        add x20, x20, #1
        sub x22, x22, #1
        cbnz x22, .pvc_loop

    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x29, x30, [sp], #48
    
    ret
.size draw_vertical_character_line, (. -draw_vertical_character_line)


.type draw_play_field, %function
.global draw_play_field
# Function draw_play_field
#   This function writes in the board the playfield that is going to be 
#   used for playing the game. This function was implemented as a unified 
#   way of having graphics displayed on the screen.
# Arguments:
#   None.
# Return:
#   void
draw_play_field:
    stp x29, x30, [sp, #-16]! 
    
    # The top line 
    #m_draw_horizontal_character_line #0, #0, UTF_FULL_BLOCK, COLUMN_CELLS
    m_draw_horizontal_character_line #0, #0, UTF_FULL_BLOCK, 10
    m_draw_horizontal_character_line #10, #0, UTF_DOUBLE_VERTICAL_AND_HORIZONTAL, 6

    m_draw_horizontal_character_line #16, #0, UTF_FULL_BLOCK, 22
    m_draw_horizontal_character_line #38, #0, UTF_DOUBLE_VERTICAL_AND_HORIZONTAL, 6
    m_draw_horizontal_character_line #44, #0, UTF_FULL_BLOCK, 36



    # The three columns of the play field
    m_draw_vertical_character_line #0, #1, UTF_FULL_BLOCK, #31
    m_draw_vertical_character_line COLUMN_CELLS_PLAYFIELD, #1, UTF_FULL_BLOCK, #31
    m_draw_vertical_character_line COLUMN_CELLS-1, #1, UTF_FULL_BLOCK, #31

    # Bottom dots of the playfield 
    m_draw_horizontal_character_line #1, ROW_CELLS-1, UTF_HORIZONTAL_ELLIPSIS, COLUMN_CELLS_PLAYFIELD - 1

    # Bottom blocks of the info field
    m_draw_horizontal_character_line COLUMN_CELLS_PLAYFIELD + 1, ROW_CELLS - 1, UTF_FULL_BLOCK, COLUMN_CELLS_PLAYFIELD_OFFSET 

    ldp x29, x30, [sp], #16
    ret
.size draw_play_field, (. -draw_play_field)


.type draw_pallet, %function
.global draw_pallet
# Function draw_pallet
#   This function writes in the framebuffer the pallet using its memory 
#   reference. It uses directly the memory reference as there is only one
#   pallet in the game.
# Arguments:
#   None.
# Return:
#   void.
draw_pallet:
    stp x29, x30, [sp, #-16]! 
    # Moving to x2 the start position of the pallet
    adr x0, pallet_pos 
    adr x1, pallet_size
    ldr x0, [x0]
    ldr x1, [x1]
    ldr w2, =UTF_LEFT_HALF_BLACK_CIRCLE
    str w2, [x0]
    add x0, x0, #4 
    sub x1, x1, #1
    ldr w2, =UTF_FULL_BLOCK
    
    .loop_print:
        str w2, [x0]
        sub x1, x1, #1
        add x0, x0, #4
        cmp x1, #1
        bne .loop_print

    ldr w2, =UTF_RIGHT_HALF_BLACK_CIRCLE
    str w2, [x0]

    ldp  x29, x30, [sp], #16
    ret
.size draw_pallet, (. -draw_pallet) 

.type print_number_variable, %function
.global print_number_variable
# Function: print_score
#   The function will read the memory variable score and it will convert
#   it's value to text format in order to print it on screen.
# Arguments:
#   x0: x coordinate of the text
#   x1: y coordinate of the text
#   x2: pointer to the variable to be printed
# Return:
#   Void.
print_number_variable:
    stp x29, x30, [sp, #-32]! 
    stp x19, x20, [sp, #16]

    mov x19, x2

    #mov x0, SCORE_COUNTER_POS_X
    #mov x1, SCORE_COUNTER_POS_Y
    bl get_screen_pointer

    adr x1, numbers_text 
    ldr x2, [x19]
    mov x3, #10
    mov x6, #5
    .ps_loop:
        # Divide by ten: x4 quotient, x5 remainder
        udiv x4, x2, x3
        msub x5, x4, x3, x2
        # Recover the number ascii
        add x5, x1, x5
        ldrb w5, [x5]
        str w5, [x0]
        sub x0, x0, FOUR_BYTES
        mov x2, x4
        sub x6, x6, #1
        cbnz x6, .ps_loop
       

    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size print_number_variable, (. -print_number_variable)

.type print_text, %function
.global print_text

# Function: print_text
#   This functions prints text in the desired coordinates of the board
# Arguments:
#   x0: x coordinate of the text
#   x1: y coordinate of the text
#   x2: pointer to the text string
#   x3: string length
# Return:
#   void
print_text:
    stp x29, x30, [sp, #-32]! 
    stp x19, x20, [sp, #16] 
    
    mov x19, x2
    mov x20, x3
    bl get_screen_pointer
    
    .pt_loop:
    # We load byte by byte of the screen
        ldrb w1, [x19]
        str w1, [x0]
        add x0, x0, FOUR_BYTES
        add x19, x19, #1
        sub x20, x20, #1
        cbnz x20, .pt_loop

    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    
    ret
.size print_text, (. -print_text) 

.type print_block, %function
.global print_block
# Function: print_block
# Arguments:
#   x0: x coordinate of the left side of the block
#   x1: y coordinate of the left side of the block
#   x2: block type
# Return:
#   void
print_block:
    stp x29, x30, [sp, #-32]! 
    stp x19, x20, [sp, #16] 
    
    
    adr x3, .pb_jump_table
    add x3, x3, x2, LSL#2
    br x3

    .pb_jump_table:
        b .pb_jt_case0
        b .pb_jt_case1
        b .pb_jt_case2
        b .pb_jt_case3
        b .pb_jt_case4
        b .pb_jt_case5
        b .pb_jt_case6
        b .pb_jt_case7
        b .pb_jt_case8
        b .pb_jt_case9
        b .pb_jt_case10
        b .pb_jt_case11
        b .pb_jt_case12

    .pb_jt_case0:
        ldr w4, =UTF_LIGHT_SHADE
        b .pb_jt_end
    
    .pb_jt_case1:
        ldr w4, =UTF_MEDIUM_SHADE
        b .pb_jt_end

    .pb_jt_case2:
        ldr w4, =UTF_DARK_SHADE
        b .pb_jt_end

    .pb_jt_case3:
        ldr w4, =UTF_QUADRANT_UPPER_LEFT_LOWER_LEFT_RIGHT
        b .pb_jt_end

    .pb_jt_case4:
        ldr w4, =UTF_QUADRANT_UPPER_LEFT_RIGHT_LOWER_RIGHT
        b .pb_jt_end

    .pb_jt_case5:
        ldr w4, =UTF_QUADRANT_UPPER_RIGHT_LOWER_LEFT_RIGHT
        b .pb_jt_end

    .pb_jt_case6:
        ldr w4, =UTF_QUADRANT_UPPER_LEFT_RIGHT_LOWER_LEFT
        b .pb_jt_end

    .pb_jt_case7:
        ldr w4, =UTF_QUADRANT_UPPER_LEFT
        b .pb_jt_end

    .pb_jt_case8:
        ldr w4, =UTF_QUADRANT_UPPER_RIGHT
        b .pb_jt_end

    .pb_jt_case9:
        ldr w4, =UTF_WHITE_SQUARE_BLACK_SQUARE
        b .pb_jt_end

    .pb_jt_case10:
        ldr w4, =UTF_WHITE_SQUARE
        b .pb_jt_end

    .pb_jt_case11:
        ldr w4, =UTF_WHITE_SQUARE_ROUNDED_CORNERS
        b .pb_jt_end
    
    .pb_jt_case12:
        ldr w4, =UTF_FULL_BLOCK
        b .pb_jt_end


    .pb_jt_end:
    bl get_screen_pointer
    mov x3, BLOCK_SIZE

    .pb_loop:
    
        str w4, [x0]
        # advance to the next position
        add x0, x0, #4
        add x3, x3,#-1
        cmp x3, #0
        bne .pb_loop

    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size print_block, (. -print_block)

.type draw_game_block_line, %function
.global draw_game_block_line
# Function: draw_game_block_line
#   This function prints a line of blocks, receiving as arguments the 
#   starting coordinate of the line of blocks, the starting position is
#   in the left side of the screen, another argument is the number of
#   blocks that will be included in the line, as well of an offset of 
#   an starting block. If the number of blocks in the line is greater 
#   than the total of blocks of a defined final block, the pattern 
#   restarts. The blocks are alternated to better distinguish them in 
#   gameplay.
# Arguments:
#   x0: x coordinate of the starting point of the line of blocks.
#   x1: y coordinate of the starting point of the line of blocks.
#   x2: number of blocks that will be included in the line
#   x3: initial block offset (defines the starting block)
#   x4: final block offset
# Return:
#   Void.
draw_game_block_line:
    stp x29, x30, [sp, #-64]! 
    stp x19, x20, [sp, #16] 
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]

    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    mov x23, x3
    mov x24, x4

    # Determine order of the initial and final block
    cmp x3,x4
    bhi .pbl_reverse_loop
    
    .pbl_loop:
        m_print_block x19, x20, x22
        add x19, x19, BLOCK_SIZE 
        add x21, x21, #-1
        cmp x22, x24
        bne .pbl_add_block_counter
        mov x22, x23
        b .pbl_continue
        .pbl_add_block_counter:
        add x22, x22, #1
        .pbl_continue:
        cbnz x21, .pbl_loop
        b .pbl_end

    .pbl_reverse_loop:
        m_print_block x19, x20, x22
        add x19, x19, BLOCK_SIZE
        add x21, x21, #-1
        cmp x22, x24
        bne .pblr_add_block_counter
        mov x22, x23
        b .pblr_continue
        .pblr_add_block_counter:
        add x22, x22, #-1
        .pblr_continue:
        cbnz x21, .pbl_reverse_loop
        b .pbl_end



    .pbl_end:
    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x23, x24, [sp, #48]
    ldp x29, x30, [sp], #64
    ret    
.size draw_game_block_line, (. -draw_game_block_line)


.type print_lives_counter, %function
.global print_lives_counter
# Function: print_lives_counter
#   This function prints the number of lives that the memory variable 
#   lives is holding in a given time
# Arguments:
#   none
# Return:
#   void
print_lives_counter:
    stp x29, x30, [sp, #-16]!

    # First clear of the lives of the lives counter
    mov x0, LIVES_STARTING_POS_X
    mov x1, LIVES_STARTING_POS_Y
    mov x2, #24 
    bl clear_line
    
    # First clear of the lives of the lives counter
    mov x0, LIVES_STARTING_POS_X
    mov x1, LIVES_STARTING_POS_Y
    add x1, x1, #1              // The next row of lives
    mov x2, #24 
    bl clear_line

    mov x0, LIVES_STARTING_POS_X 
    mov x1, LIVES_STARTING_POS_Y
    bl get_screen_pointer

    ldr w1, =UTF_LEFT_HALF_BLACK_CIRCLE
    ldr w2, =UTF_FULL_BLOCK
    ldr w3, =UTF_RIGHT_HALF_BLACK_CIRCLE
    ldr x4, lives
    
    cmp x4, #0
    ble .plc_end
    
    mov x5, LIVES_PER_ROW
    sub x5, x4, x5
    cmp x5, #0
    bgt .plc_two_rows
    mov x6, x4
    b .plc_loop

    .plc_two_rows:
    mov x6, LIVES_PER_ROW

    # This is the first row of lives
    .plc_loop:

        str w1, [x0]
        str w2, [x0, #4]
        str w2, [x0, #8]
        str w3, [x0, #12]
        add x0, x0, #16
        sub x6, x6, #1
        cmp x6, #0
        bgt .plc_loop

    # For the second row of lives
    cmp x5, #0
    ble .plc_end
    
    mov x0, LIVES_STARTING_POS_X 
    mov x1, LIVES_STARTING_POS_Y
    add x1, x1, #1              // The second row of lives
    bl get_screen_pointer

    ldr w1, =UTF_LEFT_HALF_BLACK_CIRCLE
    ldr w2, =UTF_FULL_BLOCK
    ldr w3, =UTF_RIGHT_HALF_BLACK_CIRCLE
    
    mov x6, x5
    mov x5, #0
    b .plc_loop
    
    .plc_end:

    ldp x29, x30, [sp], #16
    ret
.size print_lives_counter, (. -print_lives_counter)


.type print_ball, %function
.global print_ball
# Function: print_ball
# Arguments
#   x0: Position x of the ball
#   x1: Position y of the ball
# Return:  
#   Void.
print_ball:
    stp x29, x30, [sp, #-16]! 
   
    bl get_screen_pointer
    ldr w4, =UTF_BLACK_CIRCLE 
    str w4, [x0]

    ldp  x29, x30, [sp], #16
    ret
.size print_ball, (. -print_ball)

.type clear_position, %function
.global clear_position
# Function: clear_position
# Arguments
#   x0: Position x
#   x1: Position y
# Return: 
#   Void.
clear_position:
    stp x29, x30, [sp, #-16]! 
    
    bl get_screen_pointer
    ldr w4, =UTF_SPACE 
    str w4, [x0]
    
    ldp  x29, x30, [sp], #16
    ret
.size clear_position, (. -clear_position)

.type clear_line, %function
.global clear_line
# Function: clear_line
# This functions clears a designed number of characters in a line
# Arguments:
#   x0: Starting x position
#   x1: Starting y position
#   x2: Line length from the starting position
# Return:
#   Void.
clear_line:
    stp x29, x30, [sp, #-32]! 
    stp x19, x20, [sp, #16] 
    
    mov x19, x2
    bl get_screen_pointer
    ldr w1, =UTF_SPACE

    .cl_clear_loop:
        str w1, [x0]
        add x0, x0, FOUR_BYTES
        sub x19, x19, #1
        cbnz x19, .cl_clear_loop

    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size clear_line, (. -clear_line)

