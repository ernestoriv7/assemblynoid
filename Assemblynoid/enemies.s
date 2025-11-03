/* This are the functions included in this file
    reset_enemies
    move_enemy    
    try_move_enemy_in_direction
    check_enemy_collision_with_pallet
    draw_enemy
    clear_enemy
    get_random_direction
    check_enemy_movement_collision
    check_collision_enemy_space
    enemy_manager
    enemy_spawner
    check_collision_with_enemy
    collision_with_enemy_manager

*/




.include "constants.inc"
.include "drawing.inc"

.equ LEFT_ENEMY_POSITION, -1
.equ RIGHT_ENEMY_POSITION, 3
.equ UP_ENEMY_POSITION, -1
.equ DOWN_ENEMY_POSITION, 1

.equ ENEMY_WIDTH, 3
.equ TOTAL_DIRECTIONS, 4

.equ ENEMY_MOVEMENT_SPEED, 10
.equ ENEMY_DIR_COUNTER, 10

.equ FAILED, 0
.equ SUCCEED, 1

# Enemy direction movement
.equ ENEMY_DIR_LEFT, 0
.equ ENEMY_DIR_RIGHT, 1
.equ ENEMY_DIR_UP, 2
.equ ENEMY_DIR_DOWN, 3

.equ ENEMY_SPAWNING_TIMER, 200

.data

enemy_spawning_timer: .quad ENEMY_SPAWNING_TIMER

enemy0:
enemy0_x_pos: .quad 0
enemy0_y_pos: .quad 0
enemy0_dir: .quad ENEMY_DIR_DOWN
enemy0_dir_movement_counter: .quad ENEMY_DIR_COUNTER
enemy0_speed_movement_counter: .quad ENEMY_MOVEMENT_SPEED
enemy0_state: .quad INACTIVE

.equ ENEMY_0_SPAWN_X_COORDINATE, 11
.equ ENEMY_0_SPAWN_Y_COORDINATE, 1

enemy1:
enemy1_x_pos: .quad 0
enemy1_y_pos: .quad 0
enemy1_dir: .quad ENEMY_DIR_DOWN
enemy1_dir_movement_counter: .quad ENEMY_DIR_COUNTER
enemy1_speed_movement_counter: .quad ENEMY_MOVEMENT_SPEED
enemy1_state: .quad INACTIVE

.equ ENEMY_1_SPAWN_X_COORDINATE, 40
.equ ENEMY_1_SPAWN_Y_COORDINATE, 1

enemy2:
enemy2_x_pos: .quad 0
enemy2_y_pos: .quad 0
enemy2_dir: .quad ENEMY_DIR_DOWN
enemy2_dir_movement_counter: .quad ENEMY_DIR_COUNTER
enemy2_speed_movement_counter: .quad ENEMY_MOVEMENT_SPEED
enemy2_state: .quad INACTIVE

.equ ENEMY_2_SPAWN_X_COORDINATE, 11
.equ ENEMY_2_SPAWN_Y_COORDINATE, 1


# These are used for the offsets of accessing the data object
.equ ENEMY_X_POS, 0
.equ ENEMY_Y_POS, 8
.equ ENEMY_DIR, 16
.equ ENEMY_DIR_MOVEMENT_COUNTER, 24
.equ ENEMY_SPEED_MOVEMENT_COUNTER, 32
.equ ENEMY_STATE, 40

.text





.type reset_enemies, %function
.global reset_enemies
# Function: reset_enemies
#   This function is called when the state of the enemies needs
#   to be reset due to level change or losing the game
# Arguments:
#   None.
# Return:
#   Void.
reset_enemies:
    stp x29, x30, [sp, #-16]!

    adr x0, enemy0
    mov x1, ENEMY_DIR_DOWN
    str x1, [x0, ENEMY_DIR]
    mov x1, ENEMY_DIR_COUNTER
    str x1, [x0, ENEMY_DIR_MOVEMENT_COUNTER]
    mov x1, INACTIVE
    str x1, [x0, ENEMY_STATE]
    bl destroy_enemy

    adr x0, enemy1
    mov x1, ENEMY_DIR_DOWN
    str x1, [x0, ENEMY_DIR]
    mov x1, ENEMY_DIR_COUNTER
    str x1, [x0, ENEMY_DIR_MOVEMENT_COUNTER]
    mov x1, INACTIVE
    str x1, [x0, ENEMY_STATE]
    bl destroy_enemy

    adr x0, enemy2
    mov x1, ENEMY_DIR_DOWN
    str x1, [x0, ENEMY_DIR]
    mov x1, ENEMY_DIR_COUNTER
    str x1, [x0, ENEMY_DIR_MOVEMENT_COUNTER]
    mov x1, INACTIVE
    str x1, [x0, ENEMY_STATE]
    bl destroy_enemy

    # Reset the enemies spawning timer
    adr x0, enemy_spawning_timer
    mov x1, ENEMY_SPAWNING_TIMER
    str x1, [x0]

    ldp x29, x30, [sp], #16
    ret
.size reset_enemies, (. -reset_enemies)


# Function: move_enemy
#   This function is in charge of moving an enemy according to it's
#   internal state.
# Arguments:
#   x0: Pointer to the enemy object
# Return:
#   Void.
move_enemy:
    stp x29, x30, [sp, #-32]!
    stp x19, x30, [sp, #16]

    # Check if enemy should be moved in this cycle
    ldr x1, [x0, ENEMY_SPEED_MOVEMENT_COUNTER]
    cmp x1, #0
    bne .me_reduce_velocity_counter
    # Reinitizale the movement counter
    mov x1, ENEMY_MOVEMENT_SPEED
    str x1, [x0, ENEMY_SPEED_MOVEMENT_COUNTER]
    mov x19, x0

    # Check if enemy is going to continue having the same direction 
    ldr x1, [x0, ENEMY_DIR_MOVEMENT_COUNTER]
    cmp x1, #0
    bgt .me_move_enemy
    # Reinitialize the movement counter
    mov x1, ENEMY_DIR_COUNTER
    str x1, [x0, ENEMY_DIR_MOVEMENT_COUNTER]

    .me_change_direction:
        bl get_random_direction
        str x0, [x19, ENEMY_DIR]
        ldr x1, [x19, ENEMY_DIR_MOVEMENT_COUNTER]

    .me_move_enemy:
        # substract to the counter of the enemy movement
        sub x1, x1, #1
        str x1, [x19, ENEMY_DIR_MOVEMENT_COUNTER]
        mov x0, x19
        bl try_move_enemy_in_direction
        cmp x0, SUCCEED
        beq .me_end
        bl get_random_direction
        str x0, [x19, ENEMY_DIR]
        b .me_end

    .me_reduce_velocity_counter:
        sub x1, x1, #1
        str x1, [x0, ENEMY_SPEED_MOVEMENT_COUNTER]
        b .me_end 

    .me_end:
    ldp x19, x30, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

# Function: try_move_enemy_in_direction
#   This function is complementary to the move_enemy function as it
#   is in charge of attemptingo to move an enemy in a given direction
#   and calculate the direction coordinates
# Arguments:
#   x0: Pointer to the enemy object.
# Return:
#   x0: FAILED, SUCCEED
try_move_enemy_in_direction:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]

    mov x19, x0
        
    ldr x2, [x19, ENEMY_DIR]
    cmp x2, ENEMY_DIR_LEFT
    beq .tmed_left
    cmp x2, ENEMY_DIR_RIGHT
    beq .tmed_right
    cmp x2, ENEMY_DIR_UP
    beq .tmed_up
    cmp x2, ENEMY_DIR_DOWN
    beq .tmed_down

    .tmed_left:
        bl check_enemy_movement_collision
        cmp x0, COLLISION
        beq .tmed_collision
        # If there is no collision, save the new coordinates
        ldr x0, [x19, ENEMY_X_POS]
        add x0, x0, LEFT
        str x0, [x19, ENEMY_X_POS]
        mov x0, SUCCEED
        b .tmed_end

    .tmed_right:
        bl check_enemy_movement_collision
        cmp x0, COLLISION
        beq .tmed_collision
        # If there is no collision, save the new coordinates
        ldr x0, [x19, ENEMY_X_POS]
        add x0, x0, RIGHT
        str x0, [x19, ENEMY_X_POS]
        mov x0, SUCCEED
        b .tmed_end

    .tmed_up:
        bl check_enemy_movement_collision
        cmp x0, COLLISION
        beq .tmed_collision
        # If there is no collision, save the new coordinates
        ldr x0, [x19, ENEMY_Y_POS]
        add x0, x0, UP
        str x0, [x19, ENEMY_Y_POS]
        mov x0, SUCCEED
        b .tmed_end
    
    .tmed_down:
        bl check_enemy_movement_collision
        cmp x0, COLLISION
        beq .tmed_collision
        # If there is no collision, save the new coordinates
        ldr x0, [x19, ENEMY_Y_POS]
        add x0, x0, DOWN
        str x0, [x19, ENEMY_Y_POS]
        mov x0, SUCCEED
        b .tmed_end

    .tmed_collision:
        # Deactivate     
        mov x0, x19
        bl check_enemy_collision_with_pallet
        cmp x0, FALSE
        beq .tmed_c_no_pallet_collision
        mov x0, x19
        #mov x1, INACTIVE
        #str x1, [x0, ENEMY_STATE]
        #bl clear_enemy
        bl destroy_enemy
        b .tmed_end

        .tmed_c_no_pallet_collision:
        
            mov x0, FAILED
            b .tmed_end

    .tmed_end:

    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

# Function: check_enemy_collision_with_pallet
#   This function verifies if when attempting to move the enemy
#   in a given direction, there is a collision with an element
#   of the game
# Arguments:
#   x0: Pointer to the enemy which the collision will be checked
# Return:
#   x0: FALSE or TRUE
check_enemy_collision_with_pallet:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16] 
    
    # Get the coordinates of the enemy
    ldr x19, [x0, ENEMY_X_POS]
    ldr x20, [x0, ENEMY_Y_POS]

    ldr x1, [x0, ENEMY_DIR]

    cmp x1, ENEMY_DIR_LEFT
    beq .cecwp_left
    cmp x1, ENEMY_DIR_RIGHT
    beq .cecwp_right
    cmp x1, ENEMY_DIR_UP
    beq .cecwp_up
    cmp x1, ENEMY_DIR_DOWN
    beq .cecwp_down
    b .cecwp_end

    .cecwp_left:
    add x0, x19, LEFT_ENEMY_POSITION
    mov x1, x20
    bl check_collision_with_pallet
    cmp x0, TRUE
    beq .cecwp_collision
    b .cecwp_no_collision

    .cecwp_right:
    add x0, x19, RIGHT_ENEMY_POSITION
    mov x1, x20
    bl check_collision_with_pallet
    cmp x0, TRUE
    beq .cecwp_collision
    b .cecwp_no_collision

    .cecwp_up:
    mov x0, x19     
    add x1, x20, UP_ENEMY_POSITION
    bl check_collision_with_pallet
    cmp x0, TRUE
    beq .cecwp_collision
    
    add x0, x19, #1 
    add x1, x20, UP_ENEMY_POSITION
    bl check_collision_with_pallet
    cmp x0, TRUE
    beq .cecwp_collision

    add x0, x19, #2
    add x1, x20, UP_ENEMY_POSITION
    bl check_collision_with_pallet
    cmp x0, TRUE
    beq .cecwp_collision

    b .cecwp_no_collision

    .cecwp_down:
    mov x0, x19     
    add x1, x20, DOWN_ENEMY_POSITION
    bl check_collision_with_pallet
    cmp x0, TRUE
    beq .cecwp_collision
    
    add x0, x19, #1 
    add x1, x20, DOWN_ENEMY_POSITION
    bl check_collision_with_pallet
    cmp x0, TRUE
    beq .cecwp_collision

    add x0, x19, #2
    add x1, x20, DOWN_ENEMY_POSITION
    bl check_collision_with_pallet
    cmp x0, TRUE
    beq .cecwp_collision

    b .cecwp_no_collision

    .cecwp_collision:
        mov x0, TRUE
        b .cemc_end

    .cecwp_no_collision:
        mov x0, FALSE
        b .cemc_end

    .cecwp_end:

    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret



# Function: draw_enemy
#   This function draw the enemy in a given location.
#   It important to have in mind that the enemy takes two
#   rows for its drawing
# Arguments: 
#   x0: pointer to the enemy object
# Return:
#   Void.
.type draw_enemy, %function
.global draw_enemy
draw_enemy:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    
    ldr x19, [x0, ENEMY_X_POS] 
    ldr x20, [x0, ENEMY_Y_POS]

    m_draw_horizontal_character_line x19, x20, '*', #1
    add x19, x19, #1
    m_draw_horizontal_character_line x19, x20, '-', #1
    add x19, x19, #1
    m_draw_horizontal_character_line x19, x20, '*', #1

    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size draw_enemy, (. -draw_enemy)

# Function: clear_enemy
#   This functions delete the enemy in a given position
#   It is needed for the movement of the enemy.
# Arguments:
#   x0: pointer to the enemy object that is going to be deleted.
# Return:
#   Void.
clear_enemy:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    
    ldr x19, [x0, ENEMY_X_POS]
    ldr x20, [x0, ENEMY_Y_POS]

    mov x0, x19
    mov x1, x20
    mov x2, ENEMY_WIDTH
    bl clear_line

    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

# Function: get_random_direction
#   This function is used to get a random direction which is needed
#   for the movement logic that is going to be implemented on the
#   enemies.
# Arguments:
#   None.
# Return:
#   x0: random direction LEFT, RIGHT, UP, DOWN
get_random_direction:
    stp x29, x30, [sp, #-16]!

    mov x0, TOTAL_DIRECTIONS
    bl get_random_number

  /*  cmp x0, #0
    beq .grd_return_left
    cmp x0, #1
    beq .grd_return_right
    cmp x0, #2
    beq .grd_return_up
    cmp x0, #3
    beq .grd_return_down
    b .grd_end

    .grd_return_left:
        mov x0, LEFT
        b .grd_end

    .grd_return_right:
        mov x0, RIGHT
        b .grd_end

    .grd_return_up:
        mov x0, UP
        b .grd_end

    .grd_return_down:
        mov x0, DOWN
        b .grd_end
*/
    .grd_end:
    ldp x29, x30, [sp], #16
    ret



# Function: check_enemy_movement_collision
#   This function verifies if when attempting to move the enemy
#   in a given direction, there is a collision with an element
#   of the game
# Arguments:
#   x0: Pointer to the enemy which the collision will be checked
# Return:
#   Void.
check_enemy_movement_collision:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16] 
    
    # Get the coordinates of the enemy
    ldr x19, [x0, ENEMY_X_POS]
    ldr x20, [x0, ENEMY_Y_POS]

    ldr x1, [x0, ENEMY_DIR]

    cmp x1, ENEMY_DIR_LEFT
    beq .cemc_left
    cmp x1, ENEMY_DIR_RIGHT
    beq .cemc_right
    cmp x1, ENEMY_DIR_UP
    beq .cemc_up
    cmp x1, ENEMY_DIR_DOWN
    beq .cemc_down
    b .cemc_end

    .cemc_left:
    add x0, x19, LEFT_ENEMY_POSITION
    mov x1, x20
    bl check_collision_enemy_space
    cmp x0, COLLISION
    beq .cemc_collision
    b .cemc_no_collision

    .cemc_right:
    add x0, x19, RIGHT_ENEMY_POSITION
    mov x1, x20
    bl check_collision_enemy_space
    cmp x0, COLLISION
    beq .cemc_collision
    b .cemc_no_collision

    .cemc_up:
    mov x0, x19     
    add x1, x20, UP_ENEMY_POSITION
    bl check_collision_enemy_space
    cmp x0, COLLISION
    beq .cemc_collision
    
    add x0, x19, #1 
    add x1, x20, UP_ENEMY_POSITION
    bl check_collision_enemy_space
    cmp x0, COLLISION
    beq .cemc_collision

    add x0, x19, #2
    add x1, x20, UP_ENEMY_POSITION
    bl check_collision_enemy_space
    cmp x0, COLLISION
    beq .cemc_collision

    b .cemc_no_collision

    .cemc_down:
    mov x0, x19     
    add x1, x20, DOWN_ENEMY_POSITION
    bl check_collision_enemy_space
    cmp x0, COLLISION
    beq .cemc_collision
    
    add x0, x19, #1 
    add x1, x20, DOWN_ENEMY_POSITION
    bl check_collision_enemy_space
    cmp x0, COLLISION
    beq .cemc_collision

    add x0, x19, #2
    add x1, x20, DOWN_ENEMY_POSITION
    bl check_collision_enemy_space
    cmp x0, COLLISION
    beq .cemc_collision

    b .cemc_no_collision

    .cemc_collision:
        mov x0, COLLISION
        b .cemc_end

    .cemc_no_collision:
        mov x0, NO_COLLISION
        b .cemc_end

    .cemc_end:

    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

# Function: check_collision_enemy_space
#   This function receives as parameters the coordinates where
#   a collision will be checked. It returns if valid collision
#    is present at those coordinates.
# Arguments:
#   x0: x coordinate where it will be checked.
#   x1, y coordinate where it will be checked.
# Return:
#   x0: NO_COLLISION and COLLISION
check_collision_enemy_space:
    stp x29, x30, [sp, #-16]!

    bl get_screen_pointer
    ldr w0, [x0]
    cmp w0, UTF_SPACE
    beq .cces_no_collision
    
    .cces_collision:
        mov x0, COLLISION
        b .cces_end

    .cces_no_collision:
        mov x0, NO_COLLISION
        b .cces_end

    .cces_end:

    ldp x29, x30, [sp], #16
    ret

# Function: enemy_manager
#   This function is in charge of orchestrating all the activities 
#   regarding the enemies of the game. It is called in every cycle.
#   The functions that will perform are:
#       Spawn enemies.
#       Move active enemies.
# Arguments:
#   None.
# Return:
#   Void.
.type enemy_manager, %function
.global enemy_manager
enemy_manager:
    stp x29, x30, [sp, #-16]!
    
    bl enemy_spawner

    .em_enemy0:
        adr x0, enemy0
        ldr x1, [x0, ENEMY_STATE]
        cmp x1, INACTIVE
        beq .em_enemy1
        adr x0, enemy0
        bl clear_enemy
        adr x0, enemy0
        bl move_enemy
        adr x0, enemy0
        # Check if enemy state change due to collision
        ldr x1, [x0, ENEMY_STATE]
        cmp x1, INACTIVE
        beq .em_enemy1
        bl draw_enemy

    .em_enemy1:
        adr x0, enemy1
        ldr x1, [x0, ENEMY_STATE]
        cmp x1, INACTIVE
        beq .em_enemy2
        adr x0, enemy1
        bl clear_enemy
        adr x0, enemy1
        bl move_enemy
        adr x0, enemy1
        # Check if enemy state change due to collision
        ldr x1, [x0, ENEMY_STATE]
        cmp x1, INACTIVE
        beq .em_enemy2
        bl draw_enemy 

    .em_enemy2:
        adr x0, enemy2
        ldr x1, [x0, ENEMY_STATE]
        cmp x1, INACTIVE
        beq .em_end
        adr x0, enemy2
        bl clear_enemy
        adr x0, enemy2
        bl move_enemy
        adr x0, enemy2
        # Check if enemy state change due to collision
        ldr x1, [x0, ENEMY_STATE]
        cmp x1, INACTIVE
        beq .em_end
        bl draw_enemy 

    .em_end:
    ldp x29, x30, [sp], #16
    ret
.size enemy_manager, (. -enemy_manager)

# Function: enemy_spawner
#   This function will be in charge of spawning the enemies as needed
#   The enemies will have an attribute that will represent the spawning
#   state of the enemies, due to the animation of the enemy getting out
#   of the place where they spawn.
# Arguments:
#   None.
# Return:
#   Void.
enemy_spawner:
    stp x29, x30, [sp, #-16]!
    
    # First check if the enemy spawning time has run out, if not the case
    # do not spawn the enemy.

    adr x0, enemy_spawning_timer
    ldr x1, [x0]
    cmp x1, 0
    bne .es_timer_not_up
    mov x1, ENEMY_SPAWNING_TIMER
    str x1, [x0]

    # Enemies will be spawned one at a time. The first enemy that the
    # games finds inactive will ve spawned.
   
    .es_enemy0:
        adr x0, enemy0
        ldr x1, [x0, ENEMY_STATE]
        cmp x1, INACTIVE
        bne .es_enemy1
        # Activate the enemy and initialize it's coordinates
        mov x1, ACTIVE
        str x1, [x0, ENEMY_STATE]
        mov x1, ENEMY_0_SPAWN_X_COORDINATE
        str x1, [x0, ENEMY_X_POS]
        mov x1, ENEMY_0_SPAWN_Y_COORDINATE
        str x1, [x0, ENEMY_Y_POS]
        b .es_end
     
    .es_enemy1:
        adr x0, enemy1
        ldr x1, [x0, ENEMY_STATE]
        cmp x1, INACTIVE
        bne .es_enemy2
        # Activate the enemy and initialize it's coordinates
        mov x1, ACTIVE
        str x1, [x0, ENEMY_STATE]
        mov x1, ENEMY_1_SPAWN_X_COORDINATE
        str x1, [x0, ENEMY_X_POS]
        mov x1, ENEMY_1_SPAWN_Y_COORDINATE
        str x1, [x0, ENEMY_Y_POS]
        b .es_end

    .es_enemy2:
        adr x0, enemy2
        ldr x1, [x0, ENEMY_STATE]
        cmp x1, INACTIVE
        bne .es_end
        # Activate the enemy and initialize it's coordinates
        mov x1, ACTIVE
        str x1, [x0, ENEMY_STATE]
        mov x1, ENEMY_2_SPAWN_X_COORDINATE
        str x1, [x0, ENEMY_X_POS]
        mov x1, ENEMY_2_SPAWN_Y_COORDINATE
        str x1, [x0, ENEMY_Y_POS]
        b .es_end

    .es_timer_not_up:
        sub x1, x1, #1
        str x1, [x0]
        b .es_end

    .es_end:

    ldp x29, x30, [sp], #16
    ret

# Function: check_collision_with_enemy
#   This function receives a pair of coordinates and determines and 
#   determines if there is a collision with any of the enemies
#   if there is no collision, NO_COLLISION is returned, if there is 
#   collision, COLLISION is returned
# Arguments:
#   x0: x coordinate of the point that is going to be evaluated.
#   x1: y coordinate of the point that is going to be evaluated.
#   x2: Pointer to the enemy object that is going to be evaluated.
# Return:
#   x0: NO_COLLISION or COLLISION
check_collision_with_enemy:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
   
    mov x19, x2     // Save the pointer to the enemy object

    bl get_screen_pointer
    mov x20, x0

    ldr x0, [x19, ENEMY_X_POS]
    ldr x1, [x19, ENEMY_Y_POS] 

    bl get_screen_pointer
    
    cmp x0, x20
    beq .ccwe_collision_detected
    add x0, x0, FOUR_BYTES
    cmp x0, x20
    beq .ccwe_collision_detected
    add x0, x0, FOUR_BYTES
    cmp x0, x20
    beq .ccwe_collision_detected
    
    mov x0, NO_COLLISION
    b .ccwe_end

    .ccwe_collision_detected:
    mov x0, COLLISION
    b .ccwe_end

    .ccwe_end:

    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret


# Function: collision_with_enemy_manager
#   This function evaluates if a pair of coordiantes have a collision
#   with an enemy, if that is the case, erase and deactivate the enemy
# Arguments:
#   x0: The x coordinate that is going to be evaluated
#   x1: The y coordinate that is going to be evaluated
# Return:
#   Void.
.type collision_with_enemy_manager, %function
.global collision_with_enemy_manager
collision_with_enemy_manager:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]

    mov x19, x0
    mov x20, x1

    .cwem_enemy0:
        # Check if enemy is active
        adr x2, enemy0
        ldr x1, [x2, ENEMY_STATE]
        cmp x1, INACTIVE
        beq .cwen_enemy1
        mov x0, x19
        mov x1, x20
        bl check_collision_with_enemy
        cmp x0, NO_COLLISION
        beq .cwen_enemy1
        adr x0, enemy0
        bl destroy_enemy
       # mov x1, INACTIVE
       # str x1, [x0, ENEMY_STATE]
       # bl clear_enemy
        b .cwen_end

    .cwen_enemy1:
        # Check if enemy is active
        adr x2, enemy1
        ldr x1, [x2, ENEMY_STATE]
        cmp x1, INACTIVE
        beq .cwen_enemy2
        mov x0, x19
        mov x1, x20
        bl check_collision_with_enemy
        cmp x0, NO_COLLISION
        beq .cwen_enemy2

        adr x0, enemy1
        bl destroy_enemy
      #  mov x1, INACTIVE
      #  str x1, [x0, ENEMY_STATE]
      #  bl clear_enemy
        b .cwen_end
    
    .cwen_enemy2:
        # Check if enemy is active
        adr x2, enemy2
        ldr x1, [x2, ENEMY_STATE]
        cmp x1, INACTIVE
        beq .cwen_end
        mov x0, x19
        mov x1, x20
        bl check_collision_with_enemy
        cmp x0, NO_COLLISION
        beq .cwen_end
        adr x0, enemy2
        bl destroy_enemy
       # mov x1, INACTIVE
       # str x1, [x0, ENEMY_STATE]
       # bl clear_enemy
        b .cwen_end
    

    .cwen_end:

    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size collision_with_enemy_manager, (. -collision_with_enemy_manager)


# Function: destroy_enemy
#   This function is in charge of deactivating an enemy when it is 
#   destroyed and increasing the score.
# Arguments:
#   x0: Pointer to the enemy object
# Return:
#   void.
destroy_enemy:
    stp x29, x30, [sp, #-16]!

    mov x1, INACTIVE
    str x1, [x0, ENEMY_STATE]
    bl clear_enemy
     
    # If enemy is destroyed, the score counter must increase
    adr x0, score
    ldr x1, [x0]
    add x1, x1, #1
    str x1, [x0]

   

    ldp x29, x30, [sp], #16
    ret



