.include "constants.inc"

/* Functions included in this file:

    move_laser_beams
    laser_beam_action    
    check_laser_collision
    use_laser_action
    drop_power_up
    draw_power_up
    get_power_up_type_letter
    move_power_up
    power_up_collision_detection
    power_up_timer_manager
    power_up_drop_movement_manager    
    check_and_activate_power_up
    catch_ball_function
    enlarge_pallet_function
    reduce_pallet_function
    change_power_up_state
    set_powerup_next_pos_buffer:
*/

# Power-up types
.equ NONE, 0
.equ LASER, 1
.equ ENLARGE, 2
.equ CATCH, 3
.equ SLOW, 4
.equ BREAK, 5
.equ DISRUPTION, 6
.equ PLAYER, 7

# Power-up active
.equ INACTIVE, 0
.equ ACTIVE, 1
.equ ALREADY_ACTIVE, 0
.equ ACTIVATED, 1

# Power-up states
.equ STATE_0, 0
.equ STATE_1, 1
.equ STATE_2, 2
.equ STATE_3, 3

# Power-up direction
.equ LEFT, -1
.equ RIGHT, 1

# Collision type
.equ NO_COLLISION, 0
.equ PALLET_COLLISION, 1
.equ BOTTOM_COLLISION, 2
.equ BLOCK_COLLISION, 1
# Falling speed of the power up
.equ POWER_UP_SPEED, 10

# Movement speed of the laser
.equ LASER_SPEED, 2

# Constant where there is no delay
.equ NO_DELAY, 0

# The timer of the power up
.equ POWER_UP_TIMER, 2000
.equ POWER_UP_START_TIME, 0

# Power-up range probability
.equ POWER_UP_RANGE, 20

# Ball delay when the power-up is active
.equ SLOW_DELAY, 10


.data

# Data structure of the power-up (only one is active at a time)
# This is regarding the dropping of the power_up

.global power_up_status
power_up:
power_up_x_pos: .quad 0
power_up_y_pos: .quad 0
power_up_status: .quad INACTIVE     // Use for the drop of the powerup
power_up_type: .quad NONE
power_up_state: .quad STATE_0
power_up_state_dir: .quad RIGHT
power_up_speed_delay: .quad POWER_UP_SPEED

# This variable is used for the timer that determines how long the
# power up is going to be active

power_up_timer: .quad POWER_UP_START_TIME

# This variables are for the implementation of the correct falling of
# the power-up
power_up_drop_buffer: .quad NONE

# Data structure of the laser power up
laser:
.global laser_status
laser_status: .quad INACTIVE
laser_length: .quad 0
laser_shot1_status: .quad INACTIVE
laser_shot1_delay: .quad LASER_SPEED
laser_shot1_left_x_pos: .quad 0
laser_shot1_left_y_pos: .quad 0
laser_shot1_right_x_pos: .quad 0
laser_shot1_right_y_pos: .quad 0
laser_shot2_status: .quad INACTIVE
laser_shot2_delay: .quad LASER_SPEED
laser_shot2_left_x_pos: .quad 0
laser_shot2_left_y_pos: .quad 0 
laser_shot2_right_x_pos: .quad 0
laser_shot2_right_y_pos: .quad 0

# Data structure of the enlarge power-up
enlarge:
enlarge_status: .quad INACTIVE

# Data structure of the catch power-up
catch:
.global catch_status
catch_status: .quad INACTIVE

# Data structure of the slow power-up
slow:
.global slow_status
slow_status: .quad INACTIVE

# Data structure of the break power-up
break:
.global break_status
break_status: .quad INACTIVE

.text
# Function: move_laser_beams
#   This function is in charge of drawing into screen the laser beams
#   in case that they are active. Also it updates its coordinates
#   for the next call.
# Arguments:
#   None.
# Return:
#   Void.
.type move_laser_beams %function
.global move_laser_beams
move_laser_beams:
    stp x29, x30, [sp, #-48]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]


    .mlb_laser_shot1:

        # check the status of the shot 1, if not active, continue to shot 2
        adr x0, laser_shot1_status
        ldr x0, [x0]
        cmp x0, ACTIVE
        bne .mlb_laser_shot2
    
        #Verify if the speed of the counter is in the correct level
        adr x0, laser_shot1_delay
        ldr x1, [x0]
        cmp x1, NO_DELAY
        beq .mlb_laser_move_shot1
        sub x1, x1, #1
        str x1, [x0]
        b .mlb_laser_shot2

    .mlb_laser_move_shot1:
    
        # Initialize again the value of the speed delay
        mov x1, LASER_SPEED
        str x1, [x0]

        adr x0, laser_shot1_left_x_pos
        adr x1, laser_shot1_left_y_pos
    
        bl laser_beam_action
        mov x19, x0

        adr x0, laser_shot1_right_x_pos
        adr x1, laser_shot1_right_y_pos

        bl laser_beam_action

        cmp x0, NO_COLLISION
        bne .mlb_ls1_inactive_laser
        cmp x19, NO_COLLISION
        bne .mlb_ls1_inactive_laser
        b .mlb_laser_shot2

    .mlb_ls1_inactive_laser:
        adr x0, laser_shot1_status
        mov x1, INACTIVE
        str x1, [x0]
        # delete the positions of the laser
        adr x0, laser_shot1_left_x_pos
        adr x1, laser_shot1_left_y_pos
        ldr x0, [x0]
        ldr x1, [x1]
        bl clear_position 
        adr x0, laser_shot1_right_x_pos
        adr x1, laser_shot1_right_y_pos
        ldr x0, [x0]
        ldr x1, [x1]
        bl clear_position

        b .mlb_laser_shot2

    .mlb_laser_shot2:

        # check the status of the shot 1, if not active, continue to shot 2
        adr x0, laser_shot2_status
        ldr x0, [x0]
        cmp x0, ACTIVE
        bne .mlb_end
    
        #Verify if the speed of the counter is in the correct level
        adr x0, laser_shot2_delay
        ldr x1, [x0]
        cmp x1, NO_DELAY
        beq .mlb_laser_move_shot2
        sub x1, x1, #1
        str x1, [x0]
        b .mlb_end

    .mlb_laser_move_shot2:
    
        # Initialize again the value of the speed delay
        mov x1, LASER_SPEED
        str x1, [x0]

        adr x0, laser_shot2_left_x_pos
        adr x1, laser_shot2_left_y_pos

        bl laser_beam_action
        mov x19, x0

        adr x0, laser_shot2_right_x_pos
        adr x1, laser_shot2_right_y_pos

        bl laser_beam_action

        cmp x0, NO_COLLISION
        bne .mlb_ls2_inactive_laser
        cmp x19, NO_COLLISION
        bne .mlb_ls2_inactive_laser
        b .mlb_end

    .mlb_ls2_inactive_laser:
        adr x0, laser_shot2_status
        mov x1, INACTIVE
        str x1, [x0]
        # delete the positions of the laser
        adr x0, laser_shot2_left_x_pos
        adr x1, laser_shot2_left_y_pos
        ldr x0, [x0]
        ldr x1, [x1]
        bl clear_position 
        adr x0, laser_shot2_right_x_pos
        adr x1, laser_shot2_right_y_pos
        ldr x0, [x0]
        ldr x1, [x1]
        bl clear_position

    b .mlb_end

        .mlb_end:

    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x29, x30, [sp], #48
    ret
.size move_laser_beams, (. -move_laser_beams)


# Function: laser_beam_action
#   This function is created due to the way that each of the laser
#   beam needs to be moved and checked against collisions.
#   The code is repeateble so it is implemented in this function.
# Arguments:
#   x0: Address to the x coordinate of the beam
#   x1: Address to the y coordinate of the beam
# Return:
#   x0: NO_COLLISION or BLOCK_COLLISION to deactivate the beam
laser_beam_action:
    stp x29, x30, [sp, #-48]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    
    mov x19, x0
    mov x20, x1
    ldr x21, [x19]
    ldr x22, [x20]
    
    mov x0, x21
    mov x1, x22
 
    bl clear_position
    # substract to the y coordinate to advance the projectil
    mov x0, x21
    sub x1, x22, #1

    # Added the function that verifies the collision of the beam
    # with a block 

    bl check_laser_collision
    cmp x0, NO_COLLISION    
    bne .lba_analyze_block_collision

    mov x0, x21
    sub x1, x22, #1
    str x1, [x20]
        
    bl get_screen_pointer
    ldr w1, =UTF_HEAVY_VERTICAL
    str w1, [x0]
    mov x0, NO_COLLISION
    b .lba_end
    
    .lba_analyze_block_collision:
        mov x0, x21
        sub x1, x22, #1

        bl get_screen_pointer

        ldr x0, [x0]
        ldr w1, =UTF_FULL_BLOCK
        cmp w0, w1
        beq .lba_end
        ldr w1, =UTF_QUADRANT_UPPER_LEFT_LOWER_LEFT_RIGHT
        cmp w0, w1
        beq .lba_silver_block_hit
        ldr w1, =UTF_QUADRANT_UPPER_LEFT_RIGHT_LOWER_RIGHT
        cmp w0, w1
        beq .lba_silver_block_hit
    
        mov x0, x21
        sub x1, x22, #1

        bl destroy_block
        # Reduce the total block counter
        adr x0, destroyed_blocks
        ldr x1, [x0]
        sub x1, x1, #1          //substract the block
        str x1, [x0]

        mov x0, BLOCK_COLLISION
        b .lba_end
    

    .lba_silver_block_hit:
        mov x0, x21
        sub x1, x22, #1
        bl silver_block_action
    
    .lba_end:

    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x29, x30, [sp], #48
    ret


# Function: check_laser_collision
#   This function is used to determine if the laser beam has collided
#   with a block in the screen
# Arguments:
#   x0: x coordinate of the laser beam
#   x1: y coordiante of the laser beam
# Return:
#   x0: NO_COLLISION or BLOCK_COLLISION
check_laser_collision:
    stp x29, x30, [sp, #-16]!

    bl get_screen_pointer
    ldr w0, [x0]

    ldr w1, =UTF_LIGHT_SHADE
    cmp w0, w1
    beq .clc_collision_detected
    
    ldr w1, =UTF_MEDIUM_SHADE
    cmp w0, w1
    beq .clc_collision_detected

    ldr w1, =UTF_QUADRANT_UPPER_LEFT_LOWER_LEFT_RIGHT
    cmp w0, w1
    beq .clc_collision_detected

    ldr w1, =UTF_QUADRANT_UPPER_LEFT_RIGHT_LOWER_RIGHT
    cmp w0, w1
    beq .clc_collision_detected

    ldr w1, =UTF_QUADRANT_UPPER_LEFT
    cmp w0, w1
    beq .clc_collision_detected

    ldr w1, =UTF_QUADRANT_UPPER_RIGHT
    cmp w0, w1
    beq .clc_collision_detected

    ldr w1, =UTF_FULL_BLOCK
    cmp w0, w1
    beq .clc_collision_detected

    ldr w1, =UTF_DOUBLE_VERTICAL_AND_HORIZONTAL
    cmp w0, w1
    beq .clc_collision_detected

    mov x0, NO_COLLISION
    b .clc_end

    .clc_collision_detected:
    mov x0, BLOCK_COLLISION
    b .clc_end

    .clc_end:

    ldp x29, x30, [sp], #16
    ret

# Function: use_laser_action
#   This function initializes the laser value status to activate
#   it. It also initialiazes the coordinate values of each
#   of the laser beams depending on how many shots are in the way
#   By the way that arkanoid works it seems that only two 
#   pair of shots can be active at a time.
#   This function will be called when the player presses
#   spacebar.
# Arguments:
#   None.
# Return:
#   Void.
.type use_laser_action, %function
.global use_laser_action
use_laser_action:
    stp x29, x30, [sp, #16]!

    adr x0, laser_status
    ldr x0, [x0]
    cmp x0, INACTIVE
    beq .ula_end
    
    .ula_shot1:

        adr x0, laser_shot1_status
        ldr x1, [x0]
        cmp x1, ACTIVE
        beq .ula_shot2

    .ula_activate_shot1:
        mov x1, ACTIVE
        str x1, [x0]

        # Get coordinates from the pallet
        adr x0, pallet_x_pos
        ldr x0, [x0]
        mov x1, PALLET_ROW_POS
        sub x1, x1, #1
        # Assign the shoot coordinates 
        adr x2, laser_shot1_left_x_pos
        adr x3, laser_shot1_left_y_pos
        str x0, [x2]
        str x1, [x3]
        # By the way that collisions work, the first writing on the
        # should be performed here.
        bl get_screen_pointer
        ldr w1, =UTF_HEAVY_VERTICAL
        str w1, [x0]

        # Repeat the process for the right side
        adr x0, pallet_x_pos
        ldr x0, [x0]
        mov x1, PALLET_ROW_POS
        sub x1, x1, #1
        adr x4, pallet_size
        ldr x4, [x4]
        add x0, x0, x4
        sub x0, x0, #1
        adr x2, laser_shot1_right_x_pos
        adr x3, laser_shot1_right_y_pos
        str x0, [x2]
        str x1, [x3]
        # By the way that collisions work, the first writing on the
        # should be performed here.
        bl get_screen_pointer
        ldr w1, =UTF_HEAVY_VERTICAL
        str w1, [x0]

        b .ula_end        
    

    .ula_shot2:

        adr x0, laser_shot2_status
        ldr x1, [x0]
        cmp x1, ACTIVE
        beq .ula_end

    .ula_activate_shot2:
        mov x1, ACTIVE
        str x1, [x0]

        # Get coordinates from the pallet
        adr x0, pallet_x_pos
        ldr x0, [x0]
        mov x1, PALLET_ROW_POS
        sub x1, x1, #1
        # Assign the shoot coordinates 
        adr x2, laser_shot2_left_x_pos
        adr x3, laser_shot2_left_y_pos
        str x0, [x2]
        str x1, [x3]
        # By the way that collisions work, the first writing on the
        # should be performed here.
        bl get_screen_pointer
        ldr w1, =UTF_HEAVY_VERTICAL
        str w1, [x0]

        # Repeat the process for the right side
        adr x0, pallet_x_pos
        ldr x0, [x0]
        mov x1, PALLET_ROW_POS
        sub x1, x1, #1
        adr x4, pallet_size
        ldr x4, [x4]
        add x0, x0, x4
        sub x0, x0, #1
        adr x2, laser_shot2_right_x_pos
        adr x3, laser_shot2_right_y_pos
        str x0, [x2]
        str x1, [x3]
        # By the way that collisions work, the first writing on the
        # should be performed here.
        bl get_screen_pointer
        ldr w1, =UTF_HEAVY_VERTICAL
        str w1, [x0]

        b .ula_end        
    

    .ula_end:
    ldp x29, x30, [sp], #16
    ret
.size use_laser_action, (. -use_laser_action)



# Function: drop_power_up
#   This functions activates a power-up when is determined that be active
#   it will determine randomly the type of power-up that is going to be
#   activated and initialize it in it's position.
# Arguments:
#   x0: x coordinate of the starting point of the power-up
#   x1: y coordinate of the starting point of the power-up
# Return:
#   x0: INACTIVE: power_up already active
#       ACTIVE: power was activated
.type drop_power_up, %function
.global drop_power_up
drop_power_up:
    stp x29, x30, [sp, #-48]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]

    # Save the original values of x and y
    mov x19, x0
    mov x20, x1

    # Verify if power up is dropping, if it is the case, do nothing
    adr x2, power_up_status
    ldr x2, [x2]
    cmp x2, ACTIVE
    beq .apu_power_up_already_active
    
    bl check_active_balls
    cmp x0, TRUE
    beq .apu_power_up_already_active

    # Get a random number between 0 and 5 (not including 5), if the
    # random number is 0, drop the power up, else do nothing
    mov x0, POWER_UP_RANGE
    bl get_random_number
  
    # Analyze if the random number coincides with a power-up
    mov x1, LASER
    cmp x0, x1
    beq .apu_drop_power_up

    mov x1, ENLARGE
    cmp x0, x1
    beq .apu_drop_power_up
    
    mov x1, CATCH
    cmp x0, x1
    beq .apu_drop_power_up
    
    mov x1, SLOW
    cmp x0, x1
    beq .apu_drop_power_up
    
    mov x1, BREAK
    cmp x0, x1
    beq .apu_drop_power_up
    
    mov x1, DISRUPTION
    cmp x0, x1
    beq .apu_drop_power_up

    mov x1, PLAYER
    cmp x0, x1
    bne .apu_power_up_already_active



    # Drop the power up

    .apu_drop_power_up:
        
        # Save the power-up type
        mov x22, x1

        # Restore the original values of x and y
        mov x0, x19
        mov x1, x20

        # Get the position of the screen pointer and save it
        bl get_screen_pointer
        mov x21, x0

        # Get the pointer to the beggining of the block where the 
        # collision was detected.
        mov x0, x19
        mov x1, x20
        bl get_block_beggining

        # Obtain the coordinate x of the value of the power up
        sub x0, x0, x21
        lsr x0, x0, #2
        add x0, x19, x0
        mov x1, x20

        # Set the coordinates of the power_up
        adr x2, power_up_x_pos
        str x0, [x2]
        adr x2, power_up_y_pos
        str x1, [x2]     

        # Activate the power-up
        adr x2, power_up_status
        mov x3, ACTIVE
        str x3, [x2]

        # Determine the type of power
        adr x2, power_up_type 
        mov x3, x22
        str x3, [x2]
    
                # Decrease the destroyed blocks counter as the initiation of
        # a power up drop actually destroyes a block
        adr x0, destroyed_blocks
        ldr x1, [x0]
        sub x1, x1, #1
        str x1, [x0]

        # Increase the score counter
        adr x0, score
        ldr x1, [x0]
        add x1, x1, #1
        str x1, [x0]

        # Draw the power-up in it's initial position
        bl draw_power_up
        mov x0, ACTIVATED

        b .apu_end
   
    .apu_power_up_already_active:
    mov x0, ALREADY_ACTIVE
    beq .apu_end

    .apu_end:

    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x29, x30, [sp], #48
    ret

# Function draw_power_up
#   This function is in charge of drawing the power up in a position
#   that is determined by the internal state of its coordinates.
# Arguments:
#   None.
# Return:
#   Void.
draw_power_up:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    
    # Get the position coordinates
    adr x0, power_up_x_pos
    ldr x0, [x0]
    adr x1, power_up_y_pos
    ldr x1, [x1]
    
    bl get_screen_pointer
    mov x19, x0

    bl get_power_up_type_letter
    mov w1, w0
    mov x0, x19
    
    # Get the drawing state of the power up to draw.
    adr x2, power_up_state
    ldr x2, [x2]

    adr x3, .dpu_jump_table
    add x3, x3, x2, LSL#2
    br x3

    .dpu_jump_table:
        b .dpu_jt_state0
        b .dpu_jt_state1
        b .dpu_jt_state2
        b .dpu_jt_state3

    .dpu_jt_state0:
        ldr w2, =UTF_WHITE_SQUARE_ROUNDED_CORNERS
        str w1, [x0]
        str w2, [x0, #4]
        str w2, [x0, #8]
        str w2, [x0, #12]
        b .dpu_end

    .dpu_jt_state1:
        ldr w2, =UTF_WHITE_SQUARE_ROUNDED_CORNERS
        str w2, [x0]
        str w1, [x0, #4]
        str w2, [x0, #8]
        str w2, [x0, #12]
        b .dpu_end

    .dpu_jt_state2:
        ldr w2, =UTF_WHITE_SQUARE_ROUNDED_CORNERS
        str w2, [x0]
        str w2, [x0, #4]
        str w1, [x0, #8]
        str w2, [x0, #12]
        b .dpu_end

    .dpu_jt_state3:
        ldr w2, =UTF_WHITE_SQUARE_ROUNDED_CORNERS
        str w2, [x0]
        str w2, [x0, #4]
        str w2, [x0, #8]
        str w1, [x0, #12]
        b .dpu_end

    .dpu_end:
    
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

# Function: get_power_up_type_letter
#   This function returns the letter that should be used for drawing
#   the power up.
# Arguments: 
#   None.
# Return:
#   x0: The letter of the power-up type
get_power_up_type_letter:
    stp x29, x30, [sp, #-16]!

    adr x0, power_up_type
    ldr x0, [x0]

    cmp x0, LASER
    beq .gputl_return_l

    cmp x0, ENLARGE
    beq .gputl_return_e

    cmp x0, CATCH
    beq .gputl_return_c

    cmp x0, SLOW
    beq .gputl_return_s

    cmp x0, BREAK
    beq .gputl_return_b
    
    cmp x0, DISRUPTION
    beq .gputl_return_d
    
    cmp x0, PLAYER
    beq .gputl_return_p



    .gputl_return_l:
    mov w0, 'L'
    b .gputl_end
    
    .gputl_return_e:
    mov w0, 'E'
    b .gputl_end

    .gputl_return_c:
    mov w0, 'C'
    b .gputl_end

    .gputl_return_s:
    mov w0, 'S'
    b .gputl_end

    .gputl_return_b:
    mov w0, 'B'
    b .gputl_end
    
    .gputl_return_d:
    mov w0, 'D'
    b .gputl_end

    .gputl_return_p:
    mov w0, 'P'
    b .gputl_end

    .gputl_end:

    ldp x29, x30, [sp], #16
    ret


# Function: move_power_up
#   This function is called in each cycle to implement the fall
#   of the power-up towards the player. Verifies if the power-up is
#   active, if it is it moves it, if not, nothing is done.
# Arguments:
#   None.
# Return:
#   Void.
.type move_power_up, %function
.global move_power_up
move_power_up:
    stp x29, x30, [sp, #-16]!
  
    # Verify the speed delay of the power up
    adr x0, power_up_speed_delay
    ldr x1, [x0]
    cmp x1, 0
    bne .mpu_reduce_speed_counter

    mov x1, POWER_UP_SPEED
    str x1, [x0]
    bl change_power_up_state

    # Restore what is the power_up buffer
    # Get the current location of the power-up to delete the block
    adr x0, power_up_x_pos
    ldr x0, [x0]
    adr x1, power_up_y_pos
    ldr x1, [x1]
    bl restore_block_from_powerup_buffer

   # mov x2, BLOCK_SIZE
   # bl clear_line

    # Get the current location of the power-up for drawing the new
    # position 
    adr x0, power_up_x_pos
    ldr x0, [x0]
    adr x1, power_up_y_pos
    ldr x1, [x1]

    # Add 1 to y coordinate to advance the power-up and store it's
    # new value 
    add x1, x1, #1
    adr x2, power_up_y_pos
    str x1, [x2]

    bl set_powerup_next_pos_buffer

    bl draw_power_up
    b .mpu_end

    .mpu_reduce_speed_counter:
       sub x1, x1, #1
       str x1, [x0]

    .mpu_end:

    ldp x29, x30, [sp], #16
    ret

# Function: set_powerup_next_pos_buffer
#   This function analyzes the next position of the dropping power
#   up, if it is a block of the game, it will store it in the buffer
#   to be redrawn when the power up continues falling.
# Arguments:
#   x0: x coordinate of the next position of the power-up
#   x1: y coordinate of the next position of the power-up
# Return:
#   Void.
set_powerup_next_pos_buffer:
    stp x29, x30, [sp, #-16]!
    
    bl get_screen_pointer
    ldr w1, [x0]
    ldr w2, =UTF_LIGHT_SHADE
    cmp w1, w2
    beq .spnpb_store_in_buffer
    ldr w2, =UTF_MEDIUM_SHADE
    cmp w1, w2
    beq .spnpb_store_in_buffer
    ldr w2, =UTF_QUADRANT_UPPER_LEFT_LOWER_LEFT_RIGHT
    cmp w1, w2
    beq .spnpb_store_in_buffer
    ldr w2, =UTF_QUADRANT_UPPER_LEFT_RIGHT_LOWER_RIGHT
    cmp w1, w2
    beq .spnpb_store_in_buffer
  
    .spnpb_none_to_store: 
        adr x1, power_up_drop_buffer
        ldr x2, =NONE
        str x2, [x1]
        b .spnpb_end

    .spnpb_store_in_buffer:
        adr x1, power_up_drop_buffer
        str x2, [x1]
        b .spnpb_end

    .spnpb_end:

    ldp x29, x30, [sp], #16
    ret

# Function: restore_block_from_powerup_buffer
#   This function is called to restore the value contained in the 
#   power-up buffer. If the contents of the buffer is the value
#   NONE, the block will be deleted
# Arguments:
#   x0: x coordinate where the block must be restored.
#   x1: y coordinate where the block must be restored.
# Return:
#   void.
restore_block_from_powerup_buffer:
    stp x29, x30, [sp, #-16]!

    adr x2, power_up_drop_buffer
    ldr w3, [x2]
    cmp w3, NONE
    beq .rbfpb_clear_line
    ldr w2, =UTF_LIGHT_SHADE
    cmp w3, w2
    beq .rbfpb_block0
    ldr w2, =UTF_MEDIUM_SHADE
    cmp w3, w2
    beq .rbfpb_block1
    ldr w2, =UTF_QUADRANT_UPPER_LEFT_LOWER_LEFT_RIGHT
    cmp w1, w2
    beq .rbfpb_block3
    ldr w2, =UTF_QUADRANT_UPPER_LEFT_RIGHT_LOWER_RIGHT
    cmp w1, w2
    beq .rbfpb_blockr4
  
    .rbfpb_block0:
        mov x2, BLOCK_0
        bl print_block
        b .rbfpb_end

    .rbfpb_block1:
        mov x2, BLOCK_1
        bl print_block
        b .rbfpb_end

    .rbfpb_block3:
        mov x2, BLOCK_3
        bl print_block
        b .rbfpb_end

    .rbfpb_blockr4:
        mov x2, BLOCK_4
        bl print_block
        b .rbfpb_end

    .rbfpb_clear_line:
        mov x2, BLOCK_SIZE
        bl clear_line


    .rbfpb_end:
    ldp x29, x30, [sp], #16
    ret



# Function: power_up_collision_detection
#   This function is in charge to verify the collision of the power up
#   with the pallet or with the end of the screen.
# Arguments:
#   None.
# Return:
#   x0: collision type 0 no collision, 1 pallet, 2 end of screen.
power_up_collision_detection:

    stp x29, x30, [sp, #-16]!

    adr x0, power_up_x_pos
    adr x1, power_up_y_pos

    ldr x0, [x0]
    ldr x1, [x1]
    # Calculate the next y position of the power-up to determine if it
    # colites with anything.

    add x1, x1, #1

    bl get_screen_pointer

    mov x2, #0
    ldr w3, =UTF_HORIZONTAL_ELLIPSIS
    ldr w4, =UTF_FULL_BLOCK
    ldr w5, =UTF_LEFT_HALF_BLACK_CIRCLE
    ldr w6, =UTF_RIGHT_HALF_BLACK_CIRCLE

    .puc_loop:
        ldr w1, [x0]
        cmp w1, w3
        beq .puc_bottom_collision
        cmp w1, w4 
        beq .puc_pallet_collision
        cmp w1, w5
        beq .puc_pallet_collision
        cmp w1, w6
        beq .puc_pallet_collision

        add x2, x2, #1
        add x0, x0, FOUR_BYTES
        cmp x2, #4
        beq .puc_no_collision
        b .puc_loop

    .puc_no_collision:
        mov x0, NO_COLLISION
        b .puc_end
        
    .puc_pallet_collision:
        mov x0, PALLET_COLLISION
        b .puc_end 
    .puc_bottom_collision:
        mov x0, BOTTOM_COLLISION 
        b .puc_end

    .puc_end: 

    ldp x29, x30, [sp], #16
    ret

# Function: power_up_timer_manager
#   This function is in charge of managing the power up time in order
#   to deactivate it when the timer has run up. In the beggining it
#   will work only with the laser power_up.
# Arguments:
#   None.
# Return:
#   Void.
.type power_up_timer_manager, %function
.global power_up_timer_manager
power_up_timer_manager:
    stp x29, x30, [sp, #-16]!

    adr x0, laser_status
    ldr x0, [x0]
    cmp x0, INACTIVE
    bne .putm_verify_timer

    adr x0, enlarge_status
    ldr x0, [x0]
    cmp x0, INACTIVE
    bne .putm_verify_timer

    adr x0, catch_status
    ldr x0, [x0]
    cmp x0, INACTIVE
    bne .putm_verify_timer

    adr x0, slow_status
    ldr x0, [x0]
    cmp x0, INACTIVE
    beq .putm_end


    .putm_verify_timer:
        # Verify the power_up_timer
        adr x0, power_up_timer
        ldr x1, [x0]
        cmp x1, POWER_UP_TIMER
        beq .pum_power_up_timer_up
        add x1, x1, #1
        str x1, [x0]
        b .putm_end

   .pum_power_up_timer_up:
        # Reinitize the power up timer
        mov x1, POWER_UP_START_TIME
        str x1, [x0]
        # Deactivate the power up
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

        
    .putm_end:

    ldp x29, x30, [sp], #16
    ret

.size power_up_timer_manager, (. -power_up_timer_manager)


# Function: power_up_drop_movement_manager
#   This function is in charge of orchestrating the actions of the power
#   including it's movement.
#   Arguments:
#       None.
#   Return:
#       Void.
.type power_up_drop_movement_manager, %function
.global power_up_drop_movement_manager
power_up_drop_movement_manager:
    stp x29, x30, [sp, #-16]!

    
    # Check if power up is active, if not go to end
    adr x0, power_up_status
    ldr x0, [x0]
    cmp x0, INACTIVE
    beq .pum_end

  
    # Check if the next position the type of collision for the next
    # Position of the power up.

    bl power_up_collision_detection
    
    cmp x0, NO_COLLISION
    beq .pum_move_power_up

    cmp x0, PALLET_COLLISION
    beq .pum_pallet_collision

    cmp x0, BOTTOM_COLLISION
    beq .pum_bottom_collision

    .pum_move_power_up:
        bl move_power_up
        b .pum_end

    .pum_pallet_collision:
        # Check power type and activate
        bl check_and_activate_power_up

        # Deactivate the power_up and delete it
        adr x0, power_up_status
        mov x1, INACTIVE
        str x1, [x0]
        # Delete the power-up graphic
        adr x0, power_up_x_pos
        adr x1, power_up_y_pos
        ldr x0, [x0]
        ldr x1, [x1]
        mov x2, #4
        bl clear_line
        b .pum_end

    .pum_bottom_collision:
    # Deactivate the power_up and delete it
        adr x0, power_up_status
        mov x1, INACTIVE
        str x1, [x0]
    # Delete the power-up graphic
        adr x0, power_up_x_pos
        adr x1, power_up_y_pos
        ldr x0, [x0]
        ldr x1, [x1]
        mov x2, #4
        bl clear_line
        b .pum_end

   .pum_end:

    ldp x29, x30, [sp], #16
    ret
.size power_up_drop_movement_manager, (. -power_up_drop_movement_manager)

# Function: check_and_activate_power_up
#   This function is called when there is a collision of the power
#   up with the pallet, it checks which type of power_up was 
#   falling and actives the required data of function for the
#   use of the power_up.
# Arguments:
#   None.
# Return:
#   Void.
check_and_activate_power_up:
    stp x29, x30, [sp, #-16]!
    
    adr x0, power_up_type
    ldr x0, [x0]

    adr x1, .capu_jump_table
    add x1, x1, x0, LSL#2
    br x1

    .capu_jump_table:
        b .capu_jt_none
        b .capu_jt_laser
        b .capu_jt_enlarge
        b .capu_jt_catch
        b .capu_jt_slow
        b .capu_jt_break
        b .capu_jt_disruption
        b .capu_jt_player

    .capu_jt_none:

        b .capu_end

    .capu_jt_laser:
        adr x0, laser_status
        mov x1, ACTIVE
        str x1, [x0]
        b .capu_end

    .capu_jt_enlarge:
        adr x0, enlarge_status
        mov x1, ACTIVE
        str x1, [x0]
        bl enlarge_pallet_function

        b .capu_end

    .capu_jt_catch:
        adr x0, catch_status
        mov x1, ACTIVE
        str x1, [x0]
        b .capu_end

    .capu_jt_slow:
        adr x0, slow_status
        mov x1, ACTIVE
        str x1, [x0]
        adr x0, ball_delay_limit
        mov x1, SLOW_DELAY
        str x1, [x0]
        b .capu_end

    .capu_jt_break:
        bl break_power_up_function
        b .capu_end

    .capu_jt_disruption:
        bl disruption_function
        b .capu_end

    .capu_jt_player:
        bl add_live
        bl print_lives_counter
        b .capu_end


    .capu_end:

    ldp x29, x30, [sp], #16
    ret

# Function: disruption_function
#   This function is in charge of initialize and activate each of the 
#   balls that are going to be in the active state.
# Arguments:
#   None.
# Return:
#   Void
disruption_function:
    stp x29, x30, [sp, #-16]!

    # Get the beggining of the pointer for all the balls
    bl get_active_ball_pointer

    ldr x1, [x0]
    ldr x2, [x0, #8]
    ldr x3, [x0, #16]
    ldr x4, [x0, #24]
    mov x5, ACTIVE

    adr x0, ball0
    str x1, [x0]
    str x2, [x0, #8]
    str x3, [x0, #16]
    str x4, [x0, #24]
    str x5, [x0, #32]
    str x5, [x0, #80]

    adr x0, ball1
    str x1, [x0]
    str x2, [x0, #8]
    str x3, [x0, #16]
    str x4, [x0, #24]
    str x5, [x0, #32]
    str x5, [x0, #80]

    adr x0, ball2
    str x1, [x0]
    str x2, [x0, #8]
    str x3, [x0, #16]
    str x4, [x0, #24]
    str x5, [x0, #32]
    str x5, [x0, #80]


    ldp x29, x30, [sp], #16
    ret


# Function: break_power_up_function
#   This function is the one in charge of opening the channel in the 
#   right side of the screen to let the Vaus advance to the next
#   stage.
# Arguments:
#   None.
# Return:
#   Void.
break_power_up_function:
    stp x29, x30, [sp, #-16]!

    # Convert the right side of the play field to ellipsis
    mov x0, COLUMN_CELLS_PLAYFIELD
    mov x1, PALLET_ROW_POS
    ldr x2, =UTF_HEAVY_QUADRUPLE_DASH_VERTICAL
    mov x3, #1
    bl draw_horizontal_character_line

    ldp x29, x30, [sp], #16
    ret

# Function: catch_ball_function
#   This function is called when a collision with the ball and the 
#   pallet is detected. It calls this function to determine if the
#   power up is active, and if it is the case, it will deactivate
#   the ball in order to avoid the bounce and it will start following
#   the pallet.
# Arguments:
#   x0: x position of the ball collision
# Return:
#   Void.
.type catch_ball_function, %function
.global catch_ball_function
catch_ball_function:
    stp x29, x30, [sp, #-16]!

    adr x1, catch_status
    ldr x1, [x1]

    cmp x1, ACTIVE
    bne .cbf_end

    adr x1, ball0_state
    mov x2, INACTIVE
    str x2, [x1]

    adr x1, pallet_x_pos
    ldr x1, [x1]

    adr x2, ball0_pallet_offset

    sub x3, x0, x1
    str x3, [x2]

    .cbf_end:

    ldp x29, x30, [sp], #16
    ret
.size catch_ball_function, (. -catch_ball_function)

# Function: enlarge_pallet_function
#   This function manages the enlarge the pallet for the power-up
#   of enlargement. Specifically the edges of the play field are
#   the critical point that should be analized.
# Arguments:
#   None.
# Return:
#   Void.
enlarge_pallet_function:
    stp x29, x30, [sp, #-16]!

    adr x0, pallet_x_pos
    ldr x1, [x0]

    cmp x1, #1      // This corresponds at the left most position
    beq .ef_increase_to_the_right
    
    cmp x1, #2      // The same case but with the second position 
    beq .ef_increase_to_the_right

    adr x2, pallet_size
    ldr x2, [x2]
    mov x3, COLUMN_CELLS_PLAYFIELD
    sub x2, x3, x2
    cmp x2, x1
    beq .ef_increase_to_the_left

    sub x2, x2, #1
    cmp x2, x1
    beq .ef_increase_to_the_left


    .ef_increase_both_sides:
        sub x1, x1, #2
        str x1, [x0]

        adr x0, pallet_pos
        ldr x1, [x0]
        sub x1, x1, #8
        str x1, [x0]
        
        adr x0, pallet_size
        ldr x1, [x0]
        add x1, x1, #4
        str x1, [x0]
        b .ef_end


    .ef_increase_to_the_right:
        adr x0, pallet_size
        ldr x1, [x0]        // Increase size by 4
        add x1, x1, #4
        str x1, [x0]
        b .ef_end
    
    .ef_increase_to_the_left:
        sub x1, x1, #4
        str x1, [x0]

        adr x0, pallet_pos
        ldr x1, [x0]
        sub x1, x1, #16     // The 16 = 4*4 because of UTF
        str x1, [x0]
        
        adr x0, pallet_size
        ldr x1, [x0]
        add x1, x1, #4
        str x1, [x0]
        b .ef_end


    .ef_end:

    ldp x29, x30, [sp], #16
    ret

# Function: reduce_pallet_function
#   This function will be in charge of reducing the size of the pallet
#   when the power up has timed out or when the player loses a life
# Arguments:
#   None.
# Return:
#   Void.
.type reduce_pallet_function, %function
.global reduce_pallet_function
reduce_pallet_function:
    stp x29, x30, [sp, #-16]!

    adr x0, enlarge_status
    ldr x1, [x0]
    cmp x1, ACTIVE
    bne .rpf_end

    mov x1, INACTIVE
    str x1, [x0]

    # Clear the line of the pallet
    adr x0, pallet_x_pos
    ldr x0, [x0]
    mov x1, PALLET_ROW_POS
    adr x2, pallet_size
    ldr x2, [x2]
    bl clear_line

    adr x0, pallet_x_pos
    ldr x1, [x0]
    add x1, x1, #2
    str x1, [x0]

    adr x0, pallet_pos
    ldr x1, [x0]
    add x1, x1, #8
    str x1, [x0]

    adr x0, pallet_size
    #ldr x1, [x0]
    #sub x1, x1, #4
    mov x1, PALLET_START_SIZE
    str x1, [x0]
   
    

    .rpf_end:

    ldp x29, x30, [sp], #16
    ret
.size reduce_pallet_function, (. -reduce_pallet_function)



# Function: change_power_up_state
#   This function modifies the state of the power up
#   To create an animation effect where the letter is going
#   to be moving.
# Arguments:
#   None.
# Return:
#   Void.
change_power_up_state:
    stp x29, x30, [sp, #-16]!
    
    adr x0, power_up_state
    ldr x1, [x0]
    adr x2, power_up_state_dir
    ldr x3, [x2]

    cmp x1, STATE_0
    beq .cpus_change_dir_to_right
    cmp x1, STATE_3
    beq .cpus_change_dir_to_left
    b .cpus_change_state

    .cpus_change_dir_to_right:
        mov x3, RIGHT
        str x3, [x2]
        b .cpus_change_state

    .cpus_change_dir_to_left:
        mov x3, LEFT
        str x3, [x2]
        b .cpus_change_state

    .cpus_change_state:
    add x1, x1, x3
    str x1, [x0]


    ldp x29, x30, [sp], #16
    ret
