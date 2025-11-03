.include "drawing.inc"
.include "constants.inc"
.include "terminal.inc"

# These are the block ammounts of each one of the leves
.equ LEVEL_1_BLOCK_AMMOUNT, 78         
.equ LEVEL_2_BLOCK_AMMOUNT, 91
.equ LEVEL_3_BLOCK_AMMOUNT, 20



.data




.text

.type start_screen, %function
.global start_screen
# Function: start_screen
# This function will be called to present the start screen of the game.
# Arguments:
#   None.
# Return:
#   Void.
start_screen:
    stp x29, x30, [sp, #-16]!
    
    bl clear_board
    bl draw_start_screen 
    
    .sc_loop:
        bl sleeptime

        print board, board_size    
        print clear_after_cursor, clear_after_cursor_length
        print update, update_length
    

        bl getchar
        cmp x0, #1
        bne .sc_loop 
     
        adr x1, input_char
        ldrb w0, [x1]
        
        cmp x0, ' '
        beq .sc_end

        b .sc_loop
   
    .sc_end:
    
    print clear, clear_length
    bl clear_board
    ldp x29, x30, [sp], #16
    ret
.size start_screen, (. -start_screen)


.type game_over_screen, %function
.global game_over_screen
# Function: game_over_screen
# This function will be called to present the start screen of the game.
# Arguments:
#   None.
# Return:
#   void.
game_over_screen:
    stp x29, x30, [sp, #-16]!
    
    bl clear_board
    bl draw_game_over_screen
    
    .gos_loop:
        bl sleeptime

        print board, board_size    
        print clear_after_cursor, clear_after_cursor_length
        print update, update_length
    

        bl getchar
        cmp x0, #1
        bne .gos_loop 
        adr x1, input_char
        ldrb w0, [x1]
        
        cmp x0, ' '
        beq .gos_end

        b .gos_loop
   
    .gos_end:

    print clear, clear_length
    bl clear_board
    ldp x29, x30, [sp], #16
    ret
.size game_over_screen, (. -game_over_screen)


.type init_level_1, %function
.global init_level_1
# Function: init_level_1
# Arguments:
#   No arguments
# Return: 
#   void
init_level_1:
    stp x29, x30, [sp, #-16]!
   # 3 y 4 
    m_draw_game_block_line #1, #5, #13, BLOCK_3, BLOCK_4
    m_draw_game_block_line #1, #6, #13, BLOCK_0, BLOCK_1
    m_draw_game_block_line #1, #7, #13, BLOCK_1, BLOCK_0
    m_draw_game_block_line #1, #8, #13, BLOCK_0, BLOCK_1
    m_draw_game_block_line #1, #9, #13, BLOCK_1, BLOCK_0
    m_draw_game_block_line #1, #10, #13, BLOCK_0, BLOCK_1

    # The text messages of the right side of the game
    # The order of the mesages are:
    #   1) SCORE
    #   2) LIVES
    #   3) ROUND

    m_print_text MSG_SCORE_POS_X, MSG_SCORE_POS_Y, msg_score, msg_score_length
    m_print_text MSG_LIVES_POS_X, MSG_LIVES_POS_Y, msg_lives, msg_lives_length    
    m_print_text MSG_ROUND_POS_X, MSG_ROUND_POS_Y, msg_round, msg_round_length

    bl print_lives_counter
   
    # The total ammount of blocks in the level
    adr x0, destroyed_blocks
    mov x1, LEVEL_1_BLOCK_AMMOUNT
    str x1, [x0] 

    # Print the current round

    mov x0, MSG_ROUND_POS_X
    add x0, x0, #4
    mov x1, MSG_ROUND_POS_Y
    add x1, x1, #1
    adr x2, game_state
    bl print_number_variable

    ldp x29, x30, [sp], #16
    ret
.size init_level_1, (. -init_level_1)


.type init_level_2, %function
.global init_level_2
# Function: init_level_2
# Arguments:
#   No arguments
# Return: 
#   void
init_level_2:
    stp x29, x30, [sp, #-16]!
   # 3 y 4 
    m_draw_game_block_line #1, #3, #1, BLOCK_1, BLOCK_0
    m_draw_game_block_line #1, #4, #2, BLOCK_0, BLOCK_1
    m_draw_game_block_line #1, #5, #3, BLOCK_1, BLOCK_0
    m_draw_game_block_line #1, #6, #4, BLOCK_0, BLOCK_1
    m_draw_game_block_line #1, #7, #5, BLOCK_1, BLOCK_0
    m_draw_game_block_line #1, #8, #6, BLOCK_0, BLOCK_1
    m_draw_game_block_line #1, #9, #7, BLOCK_1, BLOCK_0
    m_draw_game_block_line #1, #10, #8, BLOCK_0, BLOCK_1
    m_draw_game_block_line #1, #11, #9, BLOCK_1, BLOCK_0
    m_draw_game_block_line #1, #12, #10, BLOCK_0, BLOCK_1
    m_draw_game_block_line #1, #13, #11, BLOCK_1, BLOCK_0
    m_draw_game_block_line #1, #14, #12, BLOCK_0, BLOCK_1
    m_draw_game_block_line #1, #15, #12, BLOCK_3, BLOCK_4
    m_draw_game_block_line #49, #15, #1, BLOCK_1, BLOCK_0

    # The text messages of the right side of the game
    # The order of the mesages are:
    #   1) SCORE
    #   2) LIVES
    #   3) ROUND

    m_print_text MSG_SCORE_POS_X, MSG_SCORE_POS_Y, msg_score, msg_score_length
    m_print_text MSG_LIVES_POS_X, MSG_LIVES_POS_Y, msg_lives, msg_lives_length    
    m_print_text MSG_ROUND_POS_X, MSG_ROUND_POS_Y, msg_round, msg_round_length

    bl print_lives_counter
   
    # The total ammount of blocks in the level
    adr x0, destroyed_blocks
    mov x1, LEVEL_2_BLOCK_AMMOUNT
    str x1, [x0] 

    # Print the current round

    mov x0, MSG_ROUND_POS_X
    add x0, x0, #4
    mov x1, MSG_ROUND_POS_Y
    add x1, x1, #1
    adr x2, game_state
    bl print_number_variable


    ldp x29, x30, [sp], #16
    ret
.size init_level_2, (. -init_level_2)

.type init_level_3, %function
.global init_level_3
# Function: init_level_3
# Arguments:
#   No arguments
# Return: 
#   void
init_level_3:
    stp x29, x30, [sp, #-16]!
   # 3 y 4 
    m_draw_game_block_line #1, #4, #13, BLOCK_1, BLOCK_0
    m_draw_game_block_line #1, #6, #3, BLOCK_0, BLOCK_1
    m_draw_game_block_line #13, #6, #10, BLOCK_12, BLOCK_12
    m_draw_game_block_line #1, #8, #13, BLOCK_1, BLOCK_0
    m_draw_game_block_line #1, #10, #10, BLOCK_12, BLOCK_12
    m_draw_game_block_line #41, #10, #3, BLOCK_0, BLOCK_1
    m_draw_game_block_line #1, #12, #13, BLOCK_1, BLOCK_0
    m_draw_game_block_line #1, #14, #3, BLOCK_0, BLOCK_1
    m_draw_game_block_line #13, #14, #10, BLOCK_12, BLOCK_12
    m_draw_game_block_line #1, #16, #13, BLOCK_1, BLOCK_0
    m_draw_game_block_line #1, #18, #10, BLOCK_12, BLOCK_12
    m_draw_game_block_line #41, #18, #3, BLOCK_0, BLOCK_1

    # The text messages of the right side of the game
    # The order of the mesages are:
    #   1) SCORE
    #   2) LIVES
    #   3) ROUND

    m_print_text MSG_SCORE_POS_X, MSG_SCORE_POS_Y, msg_score, msg_score_length
    m_print_text MSG_LIVES_POS_X, MSG_LIVES_POS_Y, msg_lives, msg_lives_length    
    m_print_text MSG_ROUND_POS_X, MSG_ROUND_POS_Y, msg_round, msg_round_length

    bl print_lives_counter
   
    # The total ammount of blocks in the level
    adr x0, destroyed_blocks
    mov x1, LEVEL_3_BLOCK_AMMOUNT
    str x1, [x0] 
    

    # Print the current round

    mov x0, MSG_ROUND_POS_X
    add x0, x0, #4
    mov x1, MSG_ROUND_POS_Y
    add x1, x1, #1
    adr x2, game_state
    bl print_number_variable


    ldp x29, x30, [sp], #16
    ret
.size init_level_3, (. -init_level_3)

.type init_level_4, %function
.global init_level_4
# Function: init_level_4
# Arguments:
#   No arguments
# Return: 
#   void
init_level_4:
    stp x29, x30, [sp, #-16]!
    
    m_draw_game_block_line #5, #5, #3, BLOCK_1, BLOCK_0
    m_draw_game_block_line #17, #5, #1, BLOCK_3, BLOCK_3
    m_draw_game_block_line #21, #5, #1, BLOCK_0, BLOCK_1
    m_draw_game_block_line #29, #5, #5, BLOCK_1, BLOCK_0
    m_draw_game_block_line #5, #6, #2, BLOCK_0, BLOCK_1
    m_draw_game_block_line #13, #6, #1, BLOCK_3, BLOCK_3
    m_draw_game_block_line #17, #6, #2, BLOCK_0, BLOCK_1
    m_draw_game_block_line #29, #6, #4, BLOCK_0, BLOCK_1
    m_draw_game_block_line #45, #6, #1, BLOCK_3, BLOCK_3
    m_draw_game_block_line #5, #7, #1, BLOCK_1, BLOCK_0
    m_draw_game_block_line #9, #7, #1, BLOCK_3, BLOCK_3
    m_draw_game_block_line #13, #7, #3, BLOCK_0, BLOCK_1
    m_draw_game_block_line #29, #7, #3, BLOCK_1, BLOCK_0
    m_draw_game_block_line #41, #7, #1, BLOCK_3, BLOCK_3
    m_draw_game_block_line #45, #7, #1, BLOCK_1, BLOCK_0
    m_draw_game_block_line #5, #8, #1, BLOCK_3, BLOCK_3
    m_draw_game_block_line #9, #8, #4, BLOCK_0, BLOCK_1
    m_draw_game_block_line #29, #8, #2, BLOCK_0, BLOCK_1
    m_draw_game_block_line #37, #8, #1, BLOCK_3, BLOCK_3
    m_draw_game_block_line #41, #8, #2, BLOCK_1, BLOCK_0
    m_draw_game_block_line #5, #9, #5, BLOCK_0, BLOCK_1
    m_draw_game_block_line #29, #9, #1, BLOCK_1, BLOCK_0
    m_draw_game_block_line #33, #9, #1, BLOCK_3, BLOCK_3
    m_draw_game_block_line #37, #9, #3, BLOCK_1, BLOCK_0
    m_draw_game_block_line #5, #10, #5, BLOCK_1, BLOCK_0
    m_draw_game_block_line #29, #10, #1, BLOCK_3, BLOCK_3
    m_draw_game_block_line #33, #10, #4, BLOCK_1, BLOCK_0
    m_draw_game_block_line #5, #11, #5, BLOCK_0, BLOCK_1
    m_draw_game_block_line #29, #11, #5, BLOCK_1, BLOCK_0
    m_draw_game_block_line #5, #12, #4, BLOCK_1, BLOCK_0
    m_draw_game_block_line #21, #12, #1, BLOCK_3, BLOCK_3
    m_draw_game_block_line #29, #12, #5, BLOCK_0, BLOCK_1
    m_draw_game_block_line #5, #13, #3, BLOCK_0, BLOCK_1
    m_draw_game_block_line #17, #13, #1, BLOCK_3, BLOCK_3
    m_draw_game_block_line #21, #13, #1, BLOCK_0, BLOCK_1
    m_draw_game_block_line #29, #13, #5, BLOCK_1, BLOCK_0
    m_draw_game_block_line #5, #14, #2, BLOCK_1, BLOCK_0
    m_draw_game_block_line #5, #14, #2, BLOCK_1, BLOCK_0
    m_draw_game_block_line #13, #14, #1, BLOCK_3, BLOCK_3
    m_draw_game_block_line #17, #14, #2, BLOCK_0, BLOCK_1
    m_draw_game_block_line #29, #14, #4, BLOCK_0, BLOCK_1
    m_draw_game_block_line #45, #14, #1, BLOCK_3, BLOCK_3
    m_draw_game_block_line #5, #15, #1, BLOCK_0, BLOCK_1
    m_draw_game_block_line #9, #15, #1, BLOCK_3, BLOCK_3
    m_draw_game_block_line #13, #15, #3, BLOCK_0, BLOCK_1
    m_draw_game_block_line #29, #15, #3, BLOCK_1, BLOCK_0
    m_draw_game_block_line #41, #15, #1, BLOCK_3, BLOCK_3
    m_draw_game_block_line #45, #15, #1, BLOCK_1, BLOCK_0
    m_draw_game_block_line #5, #16, #1, BLOCK_3, BLOCK_3
    m_draw_game_block_line #9, #16, #4, BLOCK_0, BLOCK_1
    m_draw_game_block_line #29, #16, #2, BLOCK_0, BLOCK_1
    m_draw_game_block_line #37, #16, #1, BLOCK_3, BLOCK_3
    m_draw_game_block_line #41, #16, #2, BLOCK_1, BLOCK_0
    m_draw_game_block_line #5, #17, #5, BLOCK_0, BLOCK_1
    m_draw_game_block_line #29, #17, #1, BLOCK_1, BLOCK_0
    m_draw_game_block_line #33, #17, #1, BLOCK_3, BLOCK_3
    m_draw_game_block_line #37, #17, #3, BLOCK_1, BLOCK_0
    m_draw_game_block_line #5, #18, #5, BLOCK_1, BLOCK_0
    m_draw_game_block_line #29, #18, #1, BLOCK_3, BLOCK_3
    m_draw_game_block_line #33, #18, #4, BLOCK_1, BLOCK_0

    # The text messages of the right side of the game
    # The order of the mesages are:
    #   1) SCORE
    #   2) LIVES
    #   3) ROUND

    m_print_text MSG_SCORE_POS_X, MSG_SCORE_POS_Y, msg_score, msg_score_length
    m_print_text MSG_LIVES_POS_X, MSG_LIVES_POS_Y, msg_lives, msg_lives_length    
    m_print_text MSG_ROUND_POS_X, MSG_ROUND_POS_Y, msg_round, msg_round_length

    bl print_lives_counter
   
    # The total ammount of blocks in the level
    adr x0, destroyed_blocks
    mov x1, LEVEL_2_BLOCK_AMMOUNT
    str x1, [x0] 

    # Print the current round

    mov x0, MSG_ROUND_POS_X
    add x0, x0, #4
    mov x1, MSG_ROUND_POS_Y
    add x1, x1, #1
    adr x2, game_state
    bl print_number_variable


    ldp x29, x30, [sp], #16
    ret
.size init_level_4, (. -init_level_4)



.type draw_game_over_screen, %function
.global draw_game_over_screen
# Function: draw_game_over_screen
# This function prints in board what will be shown in the game over screen
# Arguments:
#   None.
# Return:
#   void.
draw_game_over_screen:

    stp x29, x30, [sp, #-16]!
    
    # The "G"
    
    m_draw_horizontal_character_line #8, #4, UTF_FULL_BLOCK, #4
    m_draw_horizontal_character_line #7, #11, UTF_FULL_BLOCK, #4
    m_draw_horizontal_character_line #9, #8, UTF_FULL_BLOCK, #3

    m_draw_vertical_character_line #5, #7, UTF_FULL_BLOCK, #3
    m_draw_vertical_character_line #6, #6, UTF_FULL_BLOCK, #1
    m_draw_vertical_character_line #7, #5, UTF_FULL_BLOCK, #1
    m_draw_vertical_character_line #11, #5, UTF_FULL_BLOCK, #1
    m_draw_vertical_character_line #6, #10, UTF_FULL_BLOCK, #1
    m_draw_vertical_character_line #11, #9, UTF_FULL_BLOCK, #2

    # The "a"
    m_draw_horizontal_character_line #14, #9, UTF_FULL_BLOCK, #1
    m_draw_horizontal_character_line #15, #8, UTF_FULL_BLOCK, #1
    m_draw_horizontal_character_line #15, #10, UTF_FULL_BLOCK, #1
    m_draw_horizontal_character_line #16, #7, UTF_FULL_BLOCK, #2
    m_draw_horizontal_character_line #16, #11, UTF_FULL_BLOCK, #2
    m_draw_horizontal_character_line #18, #10, UTF_FULL_BLOCK, #1
    m_draw_horizontal_character_line #18, #8, UTF_FULL_BLOCK, #1

    m_draw_vertical_character_line #19, #7, UTF_FULL_BLOCK, #5

    # The "m"
    m_draw_vertical_character_line #22, #7, UTF_FULL_BLOCK, #5
    m_draw_vertical_character_line #23, #8, UTF_FULL_BLOCK, #2
    m_draw_vertical_character_line #24, #7, UTF_FULL_BLOCK, #2
    m_draw_vertical_character_line #25, #7, UTF_FULL_BLOCK, #5
    m_draw_vertical_character_line #26, #8, UTF_FULL_BLOCK, #2
    m_draw_vertical_character_line #27, #7, UTF_FULL_BLOCK, #2
    m_draw_vertical_character_line #28, #7, UTF_FULL_BLOCK, #5

    # The "e"
    m_draw_horizontal_character_line #31, #7, UTF_FULL_BLOCK, #5
    m_draw_horizontal_character_line #31, #8, UTF_FULL_BLOCK, #1
    m_draw_horizontal_character_line #35, #8, UTF_FULL_BLOCK, #1
    m_draw_horizontal_character_line #31, #9, UTF_FULL_BLOCK, #5
    m_draw_horizontal_character_line #31, #10, UTF_FULL_BLOCK, #1
    m_draw_horizontal_character_line #31, #11, UTF_FULL_BLOCK, #5

    # The "O"
    m_draw_vertical_character_line #43, #5, UTF_FULL_BLOCK, #6
    m_draw_vertical_character_line #44, #5, UTF_FULL_BLOCK, #1
    m_draw_vertical_character_line #44, #10, UTF_FULL_BLOCK, #1
    m_draw_vertical_character_line #49, #10, UTF_FULL_BLOCK, #1
    m_draw_vertical_character_line #49, #5, UTF_FULL_BLOCK, #1
    m_draw_vertical_character_line #50, #5, UTF_FULL_BLOCK, #6

    m_draw_horizontal_character_line #44, #4, UTF_FULL_BLOCK, #6
    m_draw_horizontal_character_line #44, #11, UTF_FULL_BLOCK, #6

    # The "V"
    m_draw_vertical_character_line #53, #7, UTF_FULL_BLOCK, #2
    m_draw_vertical_character_line #54, #8, UTF_FULL_BLOCK, #2
    m_draw_vertical_character_line #55, #9, UTF_FULL_BLOCK, #2
    m_draw_vertical_character_line #56, #10, UTF_FULL_BLOCK, #2
    m_draw_vertical_character_line #57, #9, UTF_FULL_BLOCK, #2
    m_draw_vertical_character_line #58, #8, UTF_FULL_BLOCK, #2
    m_draw_vertical_character_line #59, #7, UTF_FULL_BLOCK, #2

    # The "e"
    m_draw_horizontal_character_line #62, #7, UTF_FULL_BLOCK, #5
    m_draw_horizontal_character_line #62, #8, UTF_FULL_BLOCK, #1
    m_draw_horizontal_character_line #66, #8, UTF_FULL_BLOCK, #1
    m_draw_horizontal_character_line #62, #9, UTF_FULL_BLOCK, #5
    m_draw_horizontal_character_line #62, #10, UTF_FULL_BLOCK, #1
    m_draw_horizontal_character_line #62, #11, UTF_FULL_BLOCK, #5

    # The "r"
    m_draw_vertical_character_line #69, #7, UTF_FULL_BLOCK, #5
    m_draw_vertical_character_line #70, #8, UTF_FULL_BLOCK, #2
    m_draw_vertical_character_line #71, #7, UTF_FULL_BLOCK, #2
    m_draw_vertical_character_line #72, #7, UTF_FULL_BLOCK, #1
     

    ldp x29, x30, [sp], #16
    ret
.size draw_game_over_screen, (. -draw_game_over_screen)

.type draw_start_screen, %function
.global draw_start_screen
# Function: draw_start_screen
#   This function prints in board what will be show in the start screen
# Arguments:
#   None.
# Return:
#   void.
draw_start_screen:
    stp x29, x30, [sp, #-16]!
    # The "A"
    m_draw_horizontal_character_line #1, #12, UTF_FULL_BLOCK, #2
    m_draw_horizontal_character_line #2, #9, UTF_FULL_BLOCK, #6
    m_draw_horizontal_character_line #7, #12, UTF_FULL_BLOCK, #2 
    m_draw_horizontal_character_line #4, #6, UTF_FULL_BLOCK, #2 
    m_draw_vertical_character_line #2, #9, UTF_FULL_BLOCK, #3
    m_draw_vertical_character_line #7, #9, UTF_FULL_BLOCK, #3
    m_draw_vertical_character_line #3, #6, UTF_FULL_BLOCK, #3 
    m_draw_vertical_character_line #6, #6, UTF_FULL_BLOCK, #3 
    m_draw_vertical_character_line #4, #4, UTF_FULL_BLOCK, #2 
    m_draw_vertical_character_line #5, #4, UTF_FULL_BLOCK, #2

    # The "s"
    m_draw_horizontal_character_line #11, #12, UTF_FULL_BLOCK, #4
    m_draw_horizontal_character_line #15, #11, UTF_FULL_BLOCK, #1
    m_draw_horizontal_character_line #12, #10, UTF_FULL_BLOCK, #3
    m_draw_horizontal_character_line #11, #9, UTF_FULL_BLOCK, #1
    m_draw_horizontal_character_line #12, #8, UTF_FULL_BLOCK, #4
    
    # The other "s"
    m_draw_horizontal_character_line #18, #12, UTF_FULL_BLOCK, #4
    m_draw_horizontal_character_line #22, #11, UTF_FULL_BLOCK, #1
    m_draw_horizontal_character_line #19, #10, UTF_FULL_BLOCK, #3
    m_draw_horizontal_character_line #18, #9, UTF_FULL_BLOCK, #1
    m_draw_horizontal_character_line #19, #8, UTF_FULL_BLOCK, #4

    # The "e"
    m_draw_horizontal_character_line #25, #12, UTF_FULL_BLOCK, #5
    m_draw_horizontal_character_line #26, #8, UTF_FULL_BLOCK, #4
    m_draw_horizontal_character_line #26, #10, UTF_FULL_BLOCK, #4
    m_draw_horizontal_character_line #29, #9, UTF_FULL_BLOCK, #1
    m_draw_vertical_character_line #25, #8, UTF_FULL_BLOCK, #4 


    # The "m"
    m_draw_vertical_character_line #32, #8, UTF_FULL_BLOCK, #5 
    m_draw_vertical_character_line #33, #9, UTF_FULL_BLOCK, #2
    m_draw_vertical_character_line #34, #8, UTF_FULL_BLOCK, #2
    m_draw_vertical_character_line #35, #8, UTF_FULL_BLOCK, #5 
    m_draw_vertical_character_line #36, #9, UTF_FULL_BLOCK, #2
    m_draw_vertical_character_line #37, #8, UTF_FULL_BLOCK, #2
    m_draw_vertical_character_line #38, #8, UTF_FULL_BLOCK, #5 
    
    # The "b" 
    m_draw_vertical_character_line #41, #4, UTF_FULL_BLOCK, #9 
    m_draw_horizontal_character_line #42, #9, UTF_FULL_BLOCK, #4
    m_draw_horizontal_character_line #42, #12, UTF_FULL_BLOCK, #4
    m_draw_vertical_character_line #45, #10, UTF_FULL_BLOCK, #2 

    # The "l"
    m_draw_vertical_character_line #48, #4, UTF_FULL_BLOCK, #9 

    # The "y"
    m_draw_vertical_character_line #51, #8, UTF_FULL_BLOCK, #2 
    m_draw_vertical_character_line #52, #9, UTF_FULL_BLOCK, #3 
    m_draw_vertical_character_line #54, #9, UTF_FULL_BLOCK, #3 
    m_draw_vertical_character_line #55, #8, UTF_FULL_BLOCK, #2 
    m_draw_vertical_character_line #53, #11, UTF_FULL_BLOCK, #3 
    m_draw_vertical_character_line #52, #13, UTF_FULL_BLOCK, #3 
    m_draw_vertical_character_line #51, #15, UTF_FULL_BLOCK, #2 

    # The "n"
    m_draw_vertical_character_line #58, #8, UTF_FULL_BLOCK, #5 
    m_draw_vertical_character_line #59, #9, UTF_FULL_BLOCK, #2 
    m_draw_vertical_character_line #60, #8, UTF_FULL_BLOCK, #2 
    m_draw_vertical_character_line #61, #8, UTF_FULL_BLOCK, #5 

    # The "o"
    m_draw_horizontal_character_line #64, #12, UTF_FULL_BLOCK, #5
    m_draw_horizontal_character_line #64, #8, UTF_FULL_BLOCK, #5
    m_draw_vertical_character_line #64, #9, UTF_FULL_BLOCK, #3 
    m_draw_vertical_character_line #68, #9, UTF_FULL_BLOCK, #3 

    # The "i"
    m_draw_vertical_character_line #71, #9, UTF_FULL_BLOCK, #4
    m_draw_vertical_character_line #71, #7, UTF_FULL_BLOCK, #1

    # The "d"
    m_draw_horizontal_character_line #74, #12, UTF_FULL_BLOCK, #4
    m_draw_horizontal_character_line #74, #9, UTF_FULL_BLOCK, #5
    m_draw_vertical_character_line #74, #10, UTF_FULL_BLOCK, #2
    m_draw_vertical_character_line #78, #4, UTF_FULL_BLOCK, #9 

    ldp x29, x30, [sp], #16
    ret
.size draw_start_screen, (. -draw_start_screen)

