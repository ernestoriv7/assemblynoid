.include "constants.inc"
.include "ball.inc"


# Functions included in this file
#   move_ball
#   check_ball_collision
#   check_ball_collision_exceptions
#   advance_ball
#   adjust_ball_direction
#   execute_collision_action
#   get_ball_angle_movement
#   change_ball_angle  
#   get_ball_parameter
#   get_active_ball_pointer
#   set_ball_parameter
#   check_active_balls
#   move_ball_manager
#   print_ball_manager





# The define for the special cases that the ball should not identify
# a collision.
.equ NO_EXCEPTION, 0
.equ EXCEPTION, 1


.data

#Data variables of the ball

main_ball: .quad ball0

.global ball0
.global ball0_pos_x
.global ball0_pos_y
.global ball0_state
.global ball0_speed_delay
.global ball0_pallet_offset
ball0:
ball0_pos_x: .quad BALL_COLUMN_POS 
ball0_pos_y: .quad BALL_ROW_POS 
ball0_dx: .quad RIGHT 
ball0_dy: .quad UP
ball0_state: .quad INACTIVE 
ball0_speed_delay: .quad BALL_INITIAL_SPEED 
ball0_spin: .quad NONE
ball0_angle_state: .quad ANGLE_45
ball0_angle_counter: .quad NONE 
ball0_pallet_offset: .quad BALL_STARTING_OFFSET
ball0_in_game: .quad ACTIVE

.global ball1
ball1:
ball1_pos_x: .quad BALL_COLUMN_POS 
ball1_pos_y: .quad BALL_ROW_POS 
ball1_dx: .quad RIGHT 
ball1_dy: .quad UP
ball1_state: .quad INACTIVE 
ball1_speed_delay: .quad BALL_INITIAL_SPEED 
ball1_spin: .quad NONE
ball1_angle_state: .quad ANGLE_30
ball1_angle_counter: .quad NONE 
ball1_pallet_offset: .quad BALL_STARTING_OFFSET
ball1_in_game: .quad INACTIVE

.global ball2
ball2:
ball2_pos_x: .quad BALL_COLUMN_POS 
ball2_pos_y: .quad BALL_ROW_POS 
ball2_dx: .quad RIGHT 
ball2_dy: .quad UP
ball2_state: .quad INACTIVE 
ball2_speed_delay: .quad BALL_INITIAL_SPEED 
ball2_spin: .quad NONE
ball2_angle_state: .quad ANGLE_60
ball2_angle_counter: .quad NONE 
ball2_pallet_offset: .quad BALL_STARTING_OFFSET
ball2_in_game: .quad INACTIVE

.global ball_delay_limit
ball_delay_limit: .quad BALL_INITIAL_SPEED


.text

# Function: move_ball
# Arguments:
#   x0: Pointer to the ball object
# The data in the ball struct in quad words is:
#       [0]: position x
#       [1]: position y
#       [2]: dx
#       [3]: dy
#       [4]: state
#       [5]: delay
#       [6]: spin
#       [7]: angle dir state
#       [8]: angle dir counter
#       [9]: pallet offset
#       [10]: in game
# Return: void
.type move_ball, %function
.global move_ball
move_ball:
    stp x29, x30, [sp, #-48]! 
    stp x19, x20, [sp, #16] 
    stp x21, x22, [sp, #32]

    mov x19, x0

    # If ball is not active it will be moved with the pallet
    # This is the state of the ball
    ldr x0, [x19, BALL_STATE]
    cmp x0, INACTIVE
    beq .mb_with_pallet

    # Check speed delay counter to determine if ball will be moved
    ldr x0, [x19, BALL_SPEED_DELAY]  
    cmp x0, 0 
    bgt .mb_reduce_velocity_counter
    adr x0, ball_delay_limit
    ldr x0, [x0]
    str x0, [x19, BALL_SPEED_DELAY]

    mov x0, x19 
    bl check_ball_collision
    cmp x0, NO_COLLISION
    bne .mb_collision_detected
   
    # This scenario happens if the ball does not detects collision
    .mb_advance_ball:

        mov x0, x19
        bl advance_ball

        b .mb_reduce_velocity_counter

    .mb_collision_detected:
        mov x20, x1
        mov x21, x2
        mov x0, x1
        mov x1, x2
        bl check_collision_with_pallet
        cmp x0, FALSE
        beq .mb_change_ball_dir
        mov x0, x20
        bl catch_ball_function 
        b .mb_change_ball_dir

    .mb_change_ball_dir:
        # For destroying the block only the pointer will be calculated 
        # and saved
        mov x0, x19
        bl adjust_ball_direction
        ldr x0, [x19, BALL_X_POS]    
        ldr x1, [x19, BALL_Y_POS]
        # The new position of the ball is assigned
        bl clear_position
        # Finally the game block which the collision was detected is 
        # destroyed
             
    .mb_execute_collision_action:
        # Get the x and y coordinates of the block where the collision
        # was detected 
        mov x0, x20
        mov x1, x21
        mov x2, x19
        bl execute_collision_action
        b .mb_reduce_velocity_counter

    .mb_with_pallet: 
       
        # It is necessary to clear the old position of the ball
        ldr x0, [x19, BALL_X_POS]
        ldr x1, [x19, BALL_Y_POS]
        bl clear_position

        # Load the x coordinate of the pallet
        ldr x0, pallet_x_pos
        # The x coordinate of the ball is the same as the pallet + 2
        # using the pallet offset
        ldr x1, [x19, BALL_PALLET_OFFSET]
        add x0, x0, x1
        str x0, [x19, BALL_X_POS]
        b .mb_end

    .mb_reduce_velocity_counter:

        # If it is ball 1 decrease the counter twice as fast
        mov x0, x19
        adr x1, ball1
        cmp x0, x1
        bne .mb_rvc_substract_1
        
        .mb_rvc_substract_2:
         #   ldr x0, [x19, BALL_SPEED_DELAY]
         #   sub x0, x0, #2
         #   str x0, [x19, BALL_SPEED_DELAY]
         #   b .mb_end

        .mb_rvc_substract_1:
            # Substract 1 to the ball object speed
            ldr x0, [x19, BALL_SPEED_DELAY]
            sub x0, x0, #1
            str x0, [x19, BALL_SPEED_DELAY]

    
    .mb_end:
    # clean stack
    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x29, x30, [sp], #48
    ret
.size move_ball, (. -move_ball)


# Function: check_ball_collision
#   This function detects if the ball had a collision, it will check 
#   collision in all directions and combination of its moving vectors.
# Arguments:
#   x0: object memory pointer
# The data in the ball struct in quad words is:
#       [0]: position x
#       [1]: position y
#       [2]: dx
#       [3]: dy
#       [4]: state
#       [5]: delay
#       [6]: spin
#       [7]: angle dir
#       [8]: angle dir counter
# Return:
#   x0: 0 no collision, 1 collision detected
#   x1: x coordinate of the collision
#   x2: y coordinate of the collision
check_ball_collision:
    stp x29, x30, [sp, #-64]! 
    stp x19, x20, [sp, #16] 
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48] 

    # Saving the position of the pointer for function calls
    mov x5, x0
    # Getting the object x, y and dir attributes
    ldr x19, [x5, #0]    
    ldr x20, [x5, #8]
    ldr x21, [x5, #16]
    ldr x22, [x5, #24]

    # The first type of collision is in the y axis
    mov x0, x19
    add x1, x20, x22
    bl check_ball_collision_exceptions
    cmp x0, EXCEPTION
    bne .cbc_y_collision

    # If no collision is detected in y axis, proceed with x axis
    add x0, x19, x21
    mov x1, x20
    bl check_ball_collision_exceptions
    cmp x0, EXCEPTION 
    bne .cbc_x_collision

    # If no collision is detected calculate the next position by the sum
    # of the x and y direction vectors.

    # Calculating the next position of the object
    add x0, x19, x21
    add x1, x20, x22
    bl check_ball_collision_exceptions
    cmp x0, EXCEPTION
    bne .cbc_xy_collision
    
    mov x0, NO_COLLISION
    b .cbc_end

    .cbc_y_collision:
        mov x0, COLLISION
        mov x1, x19
        add x2, x20, x22
        b .cbc_end

    .cbc_x_collision:
        mov x0, COLLISION
        add x1, x19, x21
        mov x2, x20
        b .cbc_end

    .cbc_xy_collision:
        mov x0, COLLISION
        add x1, x19, x21
        add x2, x20, x22
        b .cbc_end

    .cbc_end:
    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x23, x24, [sp, #48]
    ldp x29, x30, [sp], #64
    
    ret

# Function: check_ball_collision_exceptions
#   This function analyzes the cases in which the ball movement should
#   not report a collision, this is in order to improve the behavior
#   of the ball and avoid that it bounces against power ups and
#   laser beams
# Arguments:
#   x0: x coordinate of the position that will be analyzed
#   x1: y coordinate of the position that will be analyzed
# Return:
#   x0: NO_EXCEPTION, EXCEPTION
check_ball_collision_exceptions:
    stp x29, x30, [sp, #-16]!

    bl get_screen_pointer

    ldr w0, [x0]

    ldr w1, =UTF_SPACE
    cmp w0, w1
    beq .cbce_exception_detected

    ldr w1, =UTF_HEAVY_VERTICAL
    cmp w0, w1
    beq .cbce_exception_detected

    ldr w1, =UTF_WHITE_SQUARE_ROUNDED_CORNERS
    cmp w0, w1
    beq .cbce_exception_detected

    ldr w1, =UTF_BLACK_CIRCLE
    cmp w0, w1
    beq .cbce_exception_detected

    mov w1, 'L'
    cmp w0, w1
    beq .cbce_exception_detected

    mov w1, 'E'
    cmp w0, w1
    beq .cbce_exception_detected
    
    mov w1, 'C'
    cmp w0, w1
    beq .cbce_exception_detected

    mov w1, 'S'
    cmp w0, w1
    beq .cbce_exception_detected

    mov w1, 'B'
    cmp w0, w1
    beq .cbce_exception_detected

    mov w1, 'D'
    cmp w0, w1
    beq .cbce_exception_detected

    mov w1, 'P'
    cmp w0, w1
    beq .cbce_exception_detected


    mov x0, NO_EXCEPTION
    b .cbce_end

    .cbce_exception_detected:
        mov x0, EXCEPTION
        b .cbce_end

    .cbce_end:

    ldp x29, x30, [sp], #16
    ret


# Function: advance_ball
# This function is called to move the ball with angles, as the movement mechanics differs in that
# case.
# Arguments:
#   x0: Pointer to the ball object
# The data in the ball struct in quad words is:
#       [0]: position x
#       [1]: position y
#       [2]: dx
#       [3]: dy
#       [4]: state
#       [5]: delay
#       [6]: spin
#       [7]: angle dir state
#       [8]: angle dir counter
# Return: void
advance_ball:
    stp x29, x30, [sp, #-32]! 
    stp x19, x20, [sp, #16] 


    # To preserve the value in function calls
    mov x19, x0

    ldr x0, [x19, #64]
    cmp x0, NONE
    beq .ab_normal_movement
    # Load the angle state of the ball
    ldr x0, [x19, #56]
    bl get_ball_angle_movement
    cmp x0, X_DIR 
    beq .ab_x_movement
    # If not the x case, it is the y movement case 
    b .ab_y_movement


    .ab_normal_movement:
        # This is the normal movement of the ball
        ldr x0, [x19, #0]    
        ldr x1, [x19, #8]
        bl clear_position
        ldr x0, [x19, #0]
        ldr x1, [x19, #8]
        ldr x2, [x19, #16]
        ldr x3, [x19, #24]
        add x0, x0, x2
        add x1, x1, x3
        str x0, [x19, #0]
        str x1, [x19, #8]
       
        # As this happens when the counter is zero, reinitialize the counter.
        ldr x0, [x19, #56]
        bl get_ball_angle_movement
        str x1, [x19, #64]
        b .ab_end

    .ab_x_movement:
        ldr x0, [x19, #0]    
        ldr x1, [x19, #8]
        bl clear_position
        # Move only in the x coordinate
        ldr x0, [x19, #0]
        ldr x1, [x19, #16]
        add x0, x0, x1
        str x0, [x19, #0]
       
        # Substract one to the counter of angle dir
        ldr x0, [x19, #64]
        sub x0, x0, #1
        str x0, [x19, #64]
        b .ab_end


    .ab_y_movement:
        ldr x0, [x19, #0]    
        ldr x1, [x19, #8]
        bl clear_position
        # Move only in the y coordinate
        ldr x0, [x19, #8]
        ldr x1, [x19, #24]
        add x0, x0, x1
        str x0, [x19, #8]
       
        # Substract one to the counter of angle dir
        ldr x0, [x19, #64]
        sub x0, x0, #1
        str x0, [x19, #64]
        b .ab_end



    .ab_end:

    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

# Function: adjust_ball_direction
#   The function adjusts the direction of the received memory
#   object depending of the point of collision.
#   This function should be called if previous collision was
#   detected.
# Arguments: 
#   x0: ball memory pointer
# The data in the ball struct in quad words is:
#       [0]: position x
#       [1]: position y
#       [2]: dx
#       [3]: dy
#       [4]: state
#       [5]: delay
#       [6]: spin
#       [7]: angle dir
#       [8]: angle dir counter
# Return: 
#   void
adjust_ball_direction:
    stp x29, x30, [sp, #-32]! 
    stp x19, x20, [sp, #16] 
    #Saving the position of the pointer for function calls
    mov x19, x0
    # Check if direction is up or down
    ldr x0, [x19, #24]
    cmp x0, UP
    bne .abd_dir_down
    # Checking if collision is in ceiling.
    # Checking the ceiling is enough to detect which direction must
    # change
    .abd_dir_up:
        ldr x0, [x19, #0]    
        ldr x1, [x19, #8]
        # add 1 to y coordinate to check case 
        add x1, x1, UP
        bl get_screen_pointer
        ldr w0, [x0]
        cmp w0, UTF_SPACE 
        bne .abd_invert_y
        # If equal x should be inverted 
        b .abd_invert_x

    .abd_dir_down:
        ldr x0, [x19, #0]    
        ldr x1, [x19, #8]
        # substract 1 to y coordinate to check case 
        add x1, x1, DOWN 
        bl get_screen_pointer
        ldr w0, [x0]
        cmp w0, UTF_SPACE 
        bne .abd_invert_y
        # If equal x should be inverted 
        b .abd_invert_x


    .abd_invert_x:
        # Invert the x direction
        ldr x0, [x19, #16]
        neg x0, x0
        str x0, [x19, #16]
        b .adjust_ball_direction_end

    .abd_invert_y:
        # Invert the y direction
        ldr x0, [x19, #24]
        neg x0, x0 
        str x0, [x19, #24]
        # Must be checked if x needs to be inverted
        ldr x0, [x19, #0]    
        ldr x1, [x19, #8]
        add x0, x0, RIGHT
        bl get_screen_pointer
        ldr w0, [x0]
        cmp w0, UTF_SPACE 
        bne .abd_invert_x
        ldr x0, [x19, #0]    
        ldr x1, [x19, #8]
        add x0, x0, LEFT 
        bl get_screen_pointer
        ldr w0, [x0]
        cmp w0, UTF_SPACE 
        bne .abd_invert_x


        b .adjust_ball_direction_end
    

   
    .adjust_ball_direction_end:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

# Function: execute_collision_action
#   This function will be called if ball movement detected collision, it
#   will destroy the game block if object should be destroyed. 
#   If is game wall, no action will be performed.
# Arguments:
#   x0: x coordinate of the block which a collision was detected 
#   x1: y coordinate of the block which a collision was detected 
#   x2: pointer to the ball object
# Return:
#   void as it alters directly the object
execute_collision_action:
    stp x29, x30, [sp, #-48]! 
    stp x19, x20, [sp, #16] 
    stp x20, x21, [sp, #32]

    #Saving the original x, y coordinates for future use
    mov x19, x0
    mov x20, x1
    mov x21, x2

    # First we check if collision with the pallet was detected
    bl check_collision_with_pallet
    cmp x0, TRUE
    beq .eca_change_ball_angle

    # Check the next character exceptions for destroyed block are added 
    # here
    mov x0, x19
    mov x1, x20
    bl get_screen_pointer
    
    # Detect if colliding with a border
    ldr w0, [x0]
    ldr w1, =UTF_FULL_BLOCK
    cmp w0, w1 
    beq .eca_end 

    # Detect if colliding with the place enemies get out
    ldr w1, =UTF_DOUBLE_VERTICAL_AND_HORIZONTAL
    cmp w0, w1 
    beq .eca_end 

    # Detect if colliding with the bottom of the playing field
    ldr w1, =UTF_HORIZONTAL_ELLIPSIS
    cmp w0, w1
    beq .eca_loose_life

    # Detect if colliding with a silver block
    ldr w1, =UTF_QUADRANT_UPPER_LEFT_LOWER_LEFT_RIGHT
    cmp w0, w1
    beq .eca_silver_block_hit

    ldr w1, =UTF_QUADRANT_UPPER_LEFT_RIGHT_LOWER_RIGHT
    cmp w0, w1
    beq .eca_silver_block_hit

    # Check if the collision was with an enemy
    mov w1, '*'
    cmp w0, w1
    beq .eca_enemy_hit
    mov w1, '-'
    cmp w0, w1
    beq .eca_enemy_hit
    
    # If next character is not a border, destroy the block accordingly
    # In the first iteration only one block will be destroyed.
    # I will compare the characters to the left until a different 
    # type of block is detected

    .eca_destroy_block:
        mov x0, x19
        mov x1, x20
        bl drop_power_up
        cmp x0, ACTIVE
        beq .eca_end
        mov x0, x19
        mov x1, x20
        bl destroy_block
        b .eca_end


    .eca_loose_life:
        mov x0, x21
        bl loose_life
        b .eca_end
    
    .eca_silver_block_hit:
        mov x0, x19
        mov x1, x20
        bl silver_block_action
        b .eca_end

    .eca_enemy_hit:
        mov x0, x19
        mov x1, x20
        bl collision_with_enemy_manager
        b .eca_end
    .eca_change_ball_angle:
    #   adr x0, ball0 
    #   bl change_ball_angle

    .eca_end:
    ldp x19, x20, [sp, #16]
    ldp x20, x21, [sp, #32]
    ldp x29, x30, [sp], #48
    ret



# Function: get_ball_angle_movement
#   This function is called to define the angle movement that the ball 
#   is going to follow depending on the value of the angle, this function
#   will return the direction that the ball should do the extra movement.
# Arguments:
#   x0: The value of the angle state
# Return:
#   x0: The direction of which the ball should move more
#   x1: The number of steps that the ball should take in that direction.
get_ball_angle_movement:
    stp x29, x30, [sp, #-16]! 

    adr x3, .gbam_jump_table
    add x3, x3, x0, LSL#2
    br x3

    .gbam_jump_table:
        b .gbam_jt_case0
        b .gbam_jt_case1
        b .gbam_jt_case2
        b .gbam_jt_case3
        b .gbam_jt_case4
    
    .gbam_jt_case0:
        mov x0, X_DIR
        mov x1, ONE_X_STEP
        b .gbam_jt_end

    .gbam_jt_case1:
        mov x0, X_DIR
        mov x1, ONE_X_STEP
        b .gbam_jt_end

    .gbam_jt_case2:
        mov x0, NONE 
        mov x1, NONE
        b .gbam_jt_end

    .gbam_jt_case3:
        mov x0, Y_DIR
        mov x1, ONE_Y_STEP
        b .gbam_jt_end

    .gbam_jt_case4:
        mov x0, Y_DIR
        mov x1, TWO_Y_STEP
        b .gbam_jt_end
   
    .gbam_jt_end:


    ldp x29, x30, [sp], #16
    ret

# Function: change_ball_angle:
# This function is the one that alters the angle when a collission with the pallet
# is detected
# Arguments:
#   x0: Pointer to the ball object
# The data in the ball struct in quad words is:
#       [0]: position x
#       [1]: position y
#       [2]: dx
#       [3]: dy
#       [4]: state
#       [5]: delay
#       [6]: spin
#       [7]: angle dir state
#       [8]: angle dir counter
# Return: void
change_ball_angle:
    stp x29, x30, [sp, #-16]! 
    # Depending on the x direction of the ball the angle adds or substracts based on the
    # direction of the ball
    
    ldr x1, pallet_movement_vector
    cmp x1, NONE
    beq .cba_end
    ldr x2, [x0, #56]
    ldr x3, [x0, #16]
    cmp x3, LEFT
    bne .cba_right_case

    .cba_left_case:
        # Compare if the pallet if moving to the left to substract angle
        cmp x1, LEFT
        beq .cba_lc_substract_angle

        .cba_lc_add_angle:
            cmp x2, ANGLE_75
            beq .cba_end
            add x2, x2, #1
            str x2, [x0, #56]
            b .cba_end

        .cba_lc_substract_angle:
            cmp x2, ANGLE_15
            beq .cba_end
            sub x2, x2, #1
            str x2, [x0, #56]
            b .cba_end

    .cba_right_case:
        cmp x1, LEFT
        bne .cba_rc_substract_angle

        .cba_rc_add_angle:
            cmp x2, ANGLE_75
            beq .cba_end
            add x2, x2, #1
            str x2, [x0, #56]
            b .cba_end

        .cba_rc_substract_angle:
            cmp x2, ANGLE_15
            beq .cba_end
            sub x2, x2, #1
            str x2, [x0, #56]
            b .cba_end

    .cba_end:

    ldp x29, x30, [sp], #16
    ret

# Function: get_ball_parameter
#   This function is in charge of returning the contents
#   parameter of the main ball or a specific ball. The check all balls
#   parementer returns the parameter of the first ball that finds active 
#   in the game.
# Arguments:
#   x0: The ball which the parameter will be returned
#   x1: The parameter to be checked
# Return:
#   x0: The parameter of the main ball
.type get_ball_parameter, %function
.global get_ball_parameter
get_ball_parameter:
    stp x29, x30, [sp, #-16]!
   
    cmp x0, CHECK_ALL_BALLS
    beq .gbp_ball0
    cmp x0, BALL0
    beq .gbp_ball0
    cmp x0, BALL1
    beq .gbp_ball1
    cmp x0, BALL2
    beq .gbp_ball2
    b .gbp_end


    .gbp_ball0:
        adr x2, ball0
        ldr x3, [x2, #80]
        cmp x3, ACTIVE
        bne .gbp_ball1
        ldr x0, [x2, x1, lsl #3]        // Check if the ball is in game
        b .gbp_end
        
    .gbp_ball1:
        adr x2, ball1
        ldr x3, [x2, #80]
        cmp x3, ACTIVE
        bne .gbp_ball2
        ldr x0, [x2, x1, lsl #3]        // Check if the ball is in game
        b .gbp_end
        
    .gbp_ball2:
        adr x2, ball2
        ldr x3, [x2, #80]
        cmp x3, ACTIVE
        bne .gbp_end
        ldr x0, [x2, x1, lsl #3]        // Check if the ball is in game
        b .gbp_end
        
    .gbp_end:

    ldp x29, x30, [sp], #16
    ret
.size get_ball_parameter, (. -get_ball_parameter)


# Function: get_active_ball_pointer
#   This function is in charge of returning the pointer of the first
#   active ball that is found in the game.
# Arguments:
#   None.
# Return:
#   x0: The pointer to the first active ball
.type get_active_ball_pointer, %function
.global get_active_ball_pointer
get_active_ball_pointer:
    stp x29, x30, [sp, #-16]!
   
    .gabp_ball0:
        adr x2, ball0
        ldr x3, [x2, #80]
        cmp x3, ACTIVE
        bne .gabp_ball1
        mov x0, x2 
        b .gabp_end
        
    .gabp_ball1:
        adr x2, ball1
        ldr x3, [x2, #80]
        cmp x3, ACTIVE
        bne .gabp_ball2
        mov x0, x2 
        b .gabp_end
        
    .gabp_ball2:
        adr x2, ball2
        ldr x3, [x2, #80]
        cmp x3, ACTIVE
        bne .gabp_end
        mov x0, x2
        b .gabp_end
        
    .gabp_end:

    ldp x29, x30, [sp], #16
    ret
.size get_active_ball_pointer, (. -get_active_ball_pointer)



# Function: set_ball_parameter
#   This function is in charge of setting
#   parameter of the main ball. The check all balls will set the
#   the parameter of the first ball that finds active in the game.
# Arguments:
#   x0: The ball which the parameter will set
#   x1: The parameter to be set.
#   x2: The value to be set a that parameter
# Return:
#   Void.
.type set_ball_parameter, %function
.global set_ball_parameter
set_ball_parameter:
    stp x29, x30, [sp, #-16]!
   
    cmp x0, CHECK_ALL_BALLS
    beq .sbp_ball0
    cmp x0, BALL0
    beq .sbp_ball0
    cmp x0, BALL1
    beq .sbp_ball1
    cmp x0, BALL2
    beq .sbp_ball2
    b .sbp_end


    .sbp_ball0:
        adr x3, ball0
        ldr x4, [x3, #80]
        cmp x4, ACTIVE
        bne .sbp_ball1
        str x2, [x3, x1, lsl #3]       
        b .sbp_end
        
    .sbp_ball1:
        adr x3, ball1
        ldr x4, [x3, #80]
        cmp x4, ACTIVE
        bne .sbp_ball2
        str x2, [x2, x1, lsl #3]        // Check if the ball is in game
        b .sbp_end
        
    .sbp_ball2:
        adr x3, ball2
        ldr x4, [x3, #80]
        cmp x4, ACTIVE
        bne .sbp_end
        str x2, [x2, x1, lsl #3]        // Check if the ball is in game
        b .sbp_end
        
    .sbp_end:

    ldp x29, x30, [sp], #16
    ret
.size set_ball_parameter, (. -set_ball_parameter)

# Function: check_active_balls
#   This function analyzes if there is more than one ball active in 
#   game during gameplay. This information is used to determine if
#   more power-ups will continue falling, and if a life should be
#   discounted if the ball touches the bottom.
# Arguments:
#   None.
# Return:
#   x0: TRUE if there is more than one ball on field
#       FALSE if there is only one ball active in the field
.type check_active_balls, %function
.global check_active_balls
check_active_balls:
    stp x29, x30, [sp, #-16]!

    mov x1, #0

    adr x0, ball0
    ldr x0, [x0, #80]
    add x1, x1, x0
    
    adr x0, ball1
    ldr x0, [x0, #80]
    add x1, x1, x0

    adr x0, ball2
    ldr x0, [x0, #80]
    add x1, x1, x0

    cmp x1, #1          // The magic number is the number of balls
    bne .cab_more_balls_active

    .cab_one_ball_active:
        mov x0, FALSE
        b .cab_end

    .cab_more_balls_active:
        mov x0, TRUE
        b .cab_end

    .cab_end:

    ldp x29, x30, [sp], #16
    ret
.size check_active_balls, (. -check_active_balls)


# Function: move_ball_manager
#   This function is used for moving the balls of the game. It will
#   perform the movement operation only in the balls that are in-game
#   active.
# Arguments:
#   None.
# Return:
#   Void.
.type move_ball_manager, %function
.global move_ball_manager
move_ball_manager:
    stp x29, x30, [sp, #-16]!

    .mbm_move_ball0:
        adr x0, ball0
        ldr x1, [x0, #80]
        cmp x1, ACTIVE
        bne .mbm_move_ball1
        bl move_ball

    .mbm_move_ball1:
        adr x0, ball1
        ldr x1, [x0, #80]
        cmp x1, ACTIVE
        bne .mbm_move_ball2
        bl move_ball

    .mbm_move_ball2:
        adr x0, ball2
        ldr x1, [x0, #80]
        cmp x1, ACTIVE
        bne .mbm_end
        bl move_ball

    .mbm_end:

    ldp x29, x30, [sp], #16
    ret
.size move_ball_manager, (. -move_ball_manager)


# Function: print_ball_manager
#   This function is in charge of printing the balls on screen depending
#   if the in game attribute of the ball is active
# Arguments:
#   None.
# Return:
#   Void.
.type print_ball_manager, %function
.global print_ball_manager
print_ball_manager:
    stp x29, x30, [sp, #-16]!

    .pbm_ball0:
        adr x3, ball0
        ldr x1, [x3, #80]
        cmp x1, ACTIVE
        bne .pbm_ball1
        ldr x0, [x3, #0]        // Coordinate x of the ball
        ldr x1, [x3, #8]        // Coordinate y of the ball
        bl print_ball

    .pbm_ball1:
        adr x3, ball1
        ldr x1, [x3, #80]
        cmp x1, ACTIVE
        bne .pbm_ball2
        ldr x0, [x3, #0]        // Coordinate x of the ball
        ldr x1, [x3, #8]        // Coordinate y of the ball
        bl print_ball

    .pbm_ball2:
        adr x3, ball2
        ldr x1, [x3, #80]
        cmp x1, ACTIVE
        bne .pbm_end
        ldr x0, [x3, #0]        // Coordinate x of the ball
        ldr x1, [x3, #8]        // Coordinate y of the ball
        bl print_ball

    .pbm_end:

    ldp x29, x30, [sp], #16
    ret


