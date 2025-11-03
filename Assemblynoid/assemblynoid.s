.include "constants.inc"
.include "drawing.inc"
.include "terminal.inc"
.include "ball.inc"

.macro m_print_score

    mov x0, SCORE_COUNTER_POS_X
    mov x1, SCORE_COUNTER_POS_Y
    adr x2, score
    bl print_number_variable

.endm

# This defines are used for the game state manager to know if a level 
# should be played or the logic should return to the state manager


.data 


# The define when a char is present
.equ CHAR_PRESENT, 1


# The counter definition of the pallet movement
.equ PALLET_MOVEMENT_LIMIT, 3
.equ PALLET_MOVEMENT_START, 0

# This variable has the game state
.global game_state
game_state: .quad 0

# This will be data variables of the game

.global score
score: .quad 0
.global lives
lives: .quad STARTING_LIVES
.global destroyed_blocks
destroyed_blocks: .quad 0

# Data structure of the pallet

.global pallet_pos
.global pallet_x_pos
.global pallet_size
.global pallet_movement_vector
pallet:
pallet_pos: .quad PALLET_INITIAL_POS 
pallet_x_pos: .quad PALLET_COLUMN_POS
pallet_size: .quad PALLET_START_SIZE 
pallet_init_pos: .quad PALLET_INITIAL_POS
pallet_movement_vector: .quad NONE
pallet_movement_counter: .quad PALLET_MOVEMENT_START

# Offsets for accessing the pallet data object
.equ PALLET_POS, 0
.equ PALLET_X_POS, 8
.equ PALLET_SIZE, 16
.equ PALLET_INIT_POS, 24
.equ PALLET_MOVEMENT_VECTOR, 32
.equ PALLET_MOVEMENT_COUNTER, 40


# Data structure of the power-up (only one is active at a time)


.text

.globl _start

_start:
    bl canonical_off
    print nocursor, nocursor_length
    print clear, clear_length
    
    .level_select:

        bl game_state_manager

       # bl start_screen 
    .main_loop:
        # Check if the number of lives is less than 0 to show the
        # end screen
        ldr x0, lives
        cmp x0, #0
        bge .play_game
        adr x0, game_state
        mov x1, GAME_OVER
        str x1, [x0]
        b .level_select

        

    .play_game:
        # Check if the number of blocks has reached the level to 
        # advance to the next screen 
        adr x0, destroyed_blocks
        ldr x0, [x0]
        cmp x0, #0          // zero blocks left on the level
        beq .add_game_level

        # Check if the break status is activate to jump level
        adr x0, break_status
        ldr x0, [x0]
        cmp x0, ACTIVE
        beq .add_game_level


        m_print_score
        # Check if the ball is active to update coordinates
        bl move_ball_manager
        # Print the position of the ball
        bl print_ball_manager
        bl draw_pallet
        print board, board_size
        # If power up is active it moves it to drop
        bl power_up_drop_movement_manager
        # Check if laser shot is active to move it a draw
        bl move_laser_beams
        bl power_up_timer_manager
        # Call the enemy manager
        bl enemy_manager


    .read_more:
        bl getchar
        
        cmp x0, CHAR_PRESENT
        bne .stop_pallet_vector
        adr x1, input_char
        ldrb w0, [x1]
        
        .check_left:
            cmp x0, 'a'
            bne .check_right
            mov x0, LEFT 
            adr x1, pallet_movement_vector
            str x0, [x1]
            b .done

        .check_right:
            cmp x0, 'd'
            bne .check_space
            mov x0, RIGHT 
            adr x1, pallet_movement_vector
            str x0, [x1]
            b .done
        
        .check_space:
            cmp x0, ' ' 
            bne .check_quit
            mov x0, CHECK_ALL_BALLS
            mov x1, STATE
            bl get_ball_parameter
            cmp x0, INACTIVE
            bne .use_power_up
            mov x0, CHECK_ALL_BALLS
            mov x1, STATE
            mov x2, ACTIVE
            bl set_ball_parameter
            

            .use_power_up:
                bl use_laser_action
                     
            b .stop_pallet_vector

        .check_quit:
            cmp x0, 'q'
            beq exit
    #        b .read_more

        .stop_pallet_vector:
            adr x0, pallet_movement_counter
            ldr x1, [x0]
            cmp x1, PALLET_MOVEMENT_LIMIT
            beq .stop_movement_vector
            add x1, x1, #1
            str x1, [x0]
            b .done

            .stop_movement_vector:
                mov x1, PALLET_MOVEMENT_START
                str x1, [x0]
                mov x0, NONE
                adr x1, pallet_movement_vector
                str x0, [x1]
                b .done 

    .done:
        bl move_pallet
        bl sleeptime
        #print clear, clear_length
        print clear_after_cursor, clear_after_cursor_length
        print update, update_length
        b .main_loop

    .add_game_level:
        adr x0, game_state
        ldr x1, [x0]
        add x1, x1, #1
        str x1, [x0]
        b .level_select

    print clear, clear_length
    bl exit

# Function game_state_manager:
#   This function is called to draw the state of the level that is being
#   shown to the player. The returns determines if the game logic should
#   continue to level or screen.
# Arguments:
#   None.
# Return:
#   x0: LEVEL or SCREEN
game_state_manager:
    stp x29, x30, [sp, #-16]!

    .gsm_evaluate:
        adr x0, game_state
        ldr x0, [x0]
        adr x1, .gsm_jump_table
        add x1, x1, x0, LSL#2
        br x1

    .gsm_jump_table:

        b .gsm_jt_start_screen
        b .gsm_jt_level_1
        b .gsm_jt_level_2
        b .gsm_jt_level_3
        b .gsm_jt_level_4
        b .gsm_jt_game_over_screen

    .gsm_jt_start_screen:
        bl start_screen
        adr x0, game_state
        mov x1, LEVEL_1
        str x1, [x0]
        b .gsm_evaluate
    
    .gsm_jt_level_1:
        bl draw_play_field
        bl init_level_1
        b .gsm_end
        
    .gsm_jt_level_2:
        bl reset_game_state_values
        bl draw_play_field
        bl init_level_2
        b .gsm_end
    
    .gsm_jt_level_3:
        bl reset_game_state_values
        bl draw_play_field
        bl init_level_3
        b .gsm_end

    .gsm_jt_level_4:
        bl reset_game_state_values
        bl draw_play_field
        bl init_level_4
        b .gsm_end

    .gsm_jt_game_over_screen:
        bl reset_game_state_values
        bl game_over_screen
        # Re-initialize the values of the game
        adr x0, lives
        mov x1, STARTING_LIVES
        str x1, [x0]
        
        # Change the game state to the start_screen
        adr x0, game_state
        mov x1, START_SCREEN
        str x1, [x0]
        bl reset_game_state_values

        b .gsm_evaluate



    .gsm_end:

    ldp x29, x30, [sp], #16
    ret


# Function: reset_game_state_values
#   This function is called every time a level is passed, as well
#   when the game ends with a game over. It will reset all the
#   enemies and power-up values, as well as the score.
# Arguments:
#   None.
# Return:
#   Void.
reset_game_state_values:
    stp x29, x30, [sp, #-16]!


    # Reset the enemies state
    bl reset_enemies
   
    # Reset the score
    adr x0, score
    mov x1, 0
    str x1, [x0] 

    # Reset the lives counter
    adr x0, lives
    mov x1, STARTING_LIVES
    str x1, [x0]
        
    # Clear the line where the pallet is
    mov x0, #1
    mov x1, PALLET_ROW_POS
    mov x2, PLAYFIELD_SIZE
    bl clear_line

    # Move the pallet to initial positions
    adr x0, pallet
    ldr x1, =PALLET_INITIAL_POS
    str x1, [x0]
    ldr x1, =PALLET_COLUMN_POS
    str x1, [x0, BALL_Y_POS]

    # Move the ball0 to initial position and reset it's state 
    adr x0, ball0
    mov x1, BALL_COLUMN_POS
    str x1, [x0]
    mov x1, BALL_ROW_POS
    str x1, [x0, BALL_Y_POS]
    mov x1, INACTIVE
    str x1, [x0, BALL_STATE]
    mov x1, ANGLE_45
    str x1, [x0, BALL_ANGLE_STATE]
    mov x1, ACTIVE
    str x1, [x0, BALL_IN_GAME]

    # Move the ball0 to initial position and reset it's state 
    adr x0, ball1
    mov x1, INACTIVE
    str x1, [x0, BALL_STATE]
    mov x1, INACTIVE
    str x1, [x0, BALL_IN_GAME]

    # Move the ball0 to initial position and reset it's state 
    adr x0, ball2
    mov x1, INACTIVE
    str x1, [x0, BALL_STATE]
    mov x1, INACTIVE
    str x1, [x0, BALL_IN_GAME]

    # Deactivate the power_ups
    adr x0, laser_status
    mov x1, INACTIVE
    str x1, [x0]
    
    bl reduce_pallet_function       // For the enlarge power-up
    
    adr x0, catch_status
    mov x1, INACTIVE
    str x1, [x0]

    adr x0, slow_status
    mov x1, INACTIVE
    str x1, [x0]
    adr x0, ball_delay_limit
    mov x1, BALL_INITIAL_SPEED
    str x1, [x0]

    # Disable the falling of the power-up

    adr x0, power_up_status
    mov x1, INACTIVE
    str x1, [x0]

    # Deactivate the break power up in case that it was the one that made
    # the level jump   
    adr x0, break_status
    mov x1, INACTIVE
    str x0, [x0]

    # Clear the board of old values

    bl clear_board


    ldp x29, x30, [sp], #16
    ret




# Function: move_pallet
#   This function alters the data structure of the pallet, specifically 
#   the position
# Arguments: 
#   x0 direction -1 for left, 1 for right
# Return:
#   void
move_pallet:
    stp x29, x30, [sp, #-32]! 
    stp x19, x20, [sp, #16]

    adr x0, pallet_movement_vector
    ldr x0, [x0]
    cmp x0, NONE
    beq .mp_end
    
    adr x1, pallet
    # Load the pallet global position
    ldr x2, [x1, PALLET_POS]
    # Load the pallet size
    ldr x3, [x1, PALLET_SIZE]
    ldr w4, =UTF_SPACE
    # Multiply by 4 the size of the pallet due to the 4 bytes
    # required for unicode 
    lsl x3, x3, #2
    cmp x0, RIGHT
    bne .mp_move_left

    .mp_move_right:
        
        # Analizing the next position
        add x5, x2, x3
        ldr w5, [x5]
        cmp w5, UTF_SPACE
        beq .mp_mr_move
        # Here is implemented the collision of the pallet with the
        # enemy
        mov x19, x5
        mov x7, x1
        ldr x0, [x7, PALLET_X_POS]
        ldr x1, [x7, PALLET_SIZE]
        add x0, x0, x1
        mov x1, PALLET_ROW_POS
        bl collision_with_enemy_manager
        
        # Here is implemented the break power-up
        mov x5, x19
        ldr w6, =UTF_HEAVY_QUADRUPLE_DASH_VERTICAL
        cmp w5, w6
        bne .mp_end
        adr x0, break_status
        mov x1, ACTIVE
        str x1, [x0]
        b .mp_end


        .mp_mr_move:
        # Next position is not a border
        str w4, [x2]
        add x2, x2, #4
        str x2, [x1, #0]
        # Add 1 to the x coordinate of the pallet
        ldr x5, [x1, #8]
        add x5, x5, #1
        str x5, [x1, #8]
        b .mp_end
        
    .mp_move_left:
        # Analizing the next position
        sub x5, x2, #4
        ldr w5, [x5]
        cmp w5, UTF_SPACE
        beq .mp_ml_move
         
        # Here is implemented the collision of the pallet with the
        # enemy
        mov x19, x5
        mov x7, x1
        ldr x0, [x7, PALLET_X_POS]
        ldr x1, [x7, PALLET_SIZE]
        add x0, x0, LEFT
        mov x1, PALLET_ROW_POS
        bl collision_with_enemy_manager
        b .mp_end 
        .mp_ml_move:

        # Next position is not a border
        sub x2, x2, #4
        str x2, [x1, PALLET_POS] 
        add x2, x3, x2
        str w4, [x2]
        # Substract 1 to the coordinate of the pallet
        ldr x5, [x1, PALLET_X_POS]
        sub x5, x5, #1
        str x5, [x1, PALLET_X_POS]
        b .mp_end
        
    .mp_end:
    ldp x19, x20, [sp, #16]
    ldp  x29, x30, [sp], #32
    ret
    


# Function: loose_life
#   This function performs all the required steps when a life is lost
#   it was created to make the code more readable
# Arguments:
#   x0: pointer to the ball object that is touching the bottom
# Return:
#   Void.
.type loose_life, %function
.global loose_life
loose_life:
    stp x29, x30, [sp, #-32]! 
    stp x19, x20, [sp, #16]

    mov x19, x0

    bl check_active_balls
    cmp x0, TRUE
    beq .ll_deactivate_ball

    # Deactivate the current ball
    mov x0, INACTIVE
    str x0, [x19, BALL_IN_GAME]

    # Reduce the live counter
    adr x0, lives
    ldr x1, [x0]
    sub x1, x1, #1
    str x1, [x0]
        
    # Clear the line where the pallet is
    mov x0, #1
    mov x1, PALLET_ROW_POS
    mov x2, PLAYFIELD_SIZE
    bl clear_line

        # Reprint the lives counter with the new value
    bl print_lives_counter

    # Move the pallet to initial positions
    adr x0, pallet
    ldr x1, =PALLET_INITIAL_POS
    str x1, [x0]
    ldr x1, =PALLET_COLUMN_POS
    str x1, [x0, BALL_Y_POS]

    # Move the ball0 to initial position and reset it's state 
    adr x0, ball0
    mov x1, BALL_COLUMN_POS
    str x1, [x0]
    mov x1, BALL_ROW_POS
    str x1, [x0, BALL_Y_POS]
    mov x1, INACTIVE
    str x1, [x0, BALL_STATE]
    mov x1, ANGLE_45
    str x1, [x0, BALL_ANGLE_STATE]
    mov x1, ACTIVE
    str x1, [x0, BALL_IN_GAME]

    # Deactivate the power_ups
    adr x0, laser_status
    mov x1, INACTIVE
    str x1, [x0]
    
    bl reduce_pallet_function       // For the enlarge power-up
    
    adr x0, catch_status
    mov x1, INACTIVE
    str x1, [x0]

    adr x0, slow_status
    mov x1, INACTIVE
    str x1, [x0]
    adr x0, ball_delay_limit
    mov x1, BALL_INITIAL_SPEED
    str x1, [x0]

    # Reset the game state
   # adr x0, game_state
   # mov x1, START_SCREEN
   # str x1, [x0]

    b .ll_end

    .ll_deactivate_ball:
    mov x0, INACTIVE
    str x0, [x19, BALL_STATE]
    str x0, [x19, BALL_IN_GAME]

    .ll_end:

    ldp x19, x20, [sp, #16] 
    ldp x29, x30, [sp], #32
    ret
.size loose_life, (. -loose_life)

.type destroy_block, %function
.global destroy_block
# Function: destroy_block
#   This functions destroys (erases) a game block during play
# Arguments:
#   x0: x coordinate of any point of the block to be destroyed
#   x1: y coordiante of any point of the block to be destroyed
# Return:
#   Void.
destroy_block:
    stp x29, x30, [sp, #-16]! 
    
    bl get_block_beggining 
    ldr w1, =UTF_SPACE
    str w1, [x0]
    str w1, [x0, #4]
    str w1, [x0, #8]
    str w1, [x0, #12]
        
    # If block is destroyed, the score counter must increase
    adr x0, score
    ldr x1, [x0]
    add x1, x1, #1
    str x1, [x0]

    # Substract the pending blocks to win the level
    adr x0, destroyed_blocks
    ldr x1, [x0]
    sub x1, x1, #1
    str x1, [x0]

    ldp x29, x30, [sp], #16
    ret
.size destroy_block, (. -destroy_block)

# Function: get_block_beggining
#   It is used for the determining the beggining of the block in which
#   a collision was detected
#   This function receives as a paramenter the character which it detected
#   collision, as well as the coordinates the collision was
#   detected. Returns the address of the pointer of the beggining of the 
#   block.
# Arguments:
#   x0: x coordinate of the beggining of the block to be destroyed.
#   x1: y coordinate of the beggining of the block to be destroyed.
# Return:
#   x0: Pointer to the beggining of the collided block.
.type get_block_beggining, % function
.global get_block_beggining
get_block_beggining:
    stp x29, x30, [sp, #-16]!
    
    bl get_screen_pointer
    ldr w1, [x0]
    .gbb_loop:
        ldr w2, [x0, #-4]
        cmp w1, w2
        bne .gbb_end
        # We move one space to the left if value is equal
        sub x0, x0, FOUR_BYTES
    b .gbb_loop

    .gbb_end:
    ldp x29, x30, [sp], #16
    ret
.size get_block_beggining, (. -get_block_beggining)


# Function: silver_block_action
#   This function is called when a collision with a silver block is 
#   detected, it will redraw that block as an element that the next hit
#   can destroy without mayor problem.
# Arguments:
#   x0: x coordinate where the collision was detected.
#   x1: y coordinate where the collision was detected.
# Return:
#   Void.
.type silver_block_action, %function
.global silver_block_action
silver_block_action:
    stp x29, x30, [sp, #-16]!
    
    bl get_block_beggining 
    # Identify the type of silver block to determine to which it will
    # be changed.
    ldr w1, [x0]
    ldr w2, =UTF_QUADRANT_UPPER_LEFT_LOWER_LEFT_RIGHT
    cmp w1,w2
    bne .sba_case_2
    # Case 1
        ldr w1, =UTF_QUADRANT_UPPER_LEFT
        str w1, [x0]
        str w1, [x0, #4]
        str w1, [x0, #8]
        str w1, [x0, #12]
        b .sba_end

    .sba_case_2:
    # Case 2
        ldr w1, =UTF_QUADRANT_UPPER_RIGHT
        str w1, [x0]
        str w1, [x0, #4]
        str w1, [x0, #8]
        str w1, [x0, #12]
        b .sba_end

    .sba_end:

    ldp x29, x30, [sp], #16
    ret
.size silver_block_action, (. -silver_block_action)


# Function: check_collision_with_pallet
#   This function is called by the exectute_collision_action function to 
#   determine
#   if the collision is detected with the game pallet
# Arguments:
#   x0: x coordinate of the block which a collision was detected.
#   x1: y coordiante of the block which a collision was detected.
# Return:
#   FALSE if there is no collision with the pallet.
#   TRUE if collision with the pallet is detected.
.type check_collision_with_pallet, %function
.global check_collision_with_pallet
check_collision_with_pallet:
    stp x29, x30, [sp, #-16]! 
   
    bl get_screen_pointer

    ldr x1, pallet_pos
    ldr x2, pallet_size

    .ccwp_loop:
        cmp x0, x1
        beq .ccwp_collision_present
        add x1, x1, FOUR_BYTES
        sub x2, x2, #1
        cbnz x2, .ccwp_loop
    ldr x0, =FALSE
    b .ccwp_end

    .ccwp_collision_present:
        ldr x0, =TRUE
        b .ccwp_end

    .ccwp_end:

    ldp x29, x30, [sp], #16
    ret
.size check_collision_with_pallet, (. -check_collision_with_pallet)


# Function: add_live
#   This function is in charge of adding lives to the counter
#   the maximum number of lives is 12.
# Arguments:
#   None.
# Return:
#   Void.
.type add_live, %function
.global add_live
add_live:
    stp x29, x30, [sp, #-16]!

    adr x0, lives
    ldr x1, [x0]
    cmp x1, MAXIMUM_LIVES 
    beq .al_end
    add x1, x1, #1
    str x1, [x0]
    
    .al_end:
    ldp x29, x30, [sp], #16
    ret
.size add_live, (. -add_live)


exit:
    bl canonical_on


