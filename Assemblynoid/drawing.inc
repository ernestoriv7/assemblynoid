.macro m_draw_horizontal_character_line x, y, utf_character, line_length
    mov x0, \x
    mov x1, \y
    ldr x2, =\utf_character
    mov x3, \line_length 
    bl draw_horizontal_character_line
.endm

# By default, linux is little endian, so the values must be inverted

.macro full_line
    .fill COLUMN_CELLS, FOUR_BYTES, UTF_FULL_BLOCK 
    .word UTF_NEW_LINE, UTF_CARRIAGE_RETURN
.endm

.macro blank_line
    .fill COLUMN_CELLS, FOUR_BYTES, UTF_SPACE
    .word UTF_NEW_LINE, UTF_CARRIAGE_RETURN
.endm

.macro hollow_line
    .word UTF_FULL_BLOCK 
    .fill COLUMN_CELLS_WITHOUT_BORDERS - COLUMN_CELLS_PLAYFIELD_OFFSET, FOUR_BYTES, UTF_SPACE
    .word UTF_FULL_BLOCK
    .fill COLUMN_CELLS_PLAYFIELD_OFFSET - 1, FOUR_BYTES, UTF_SPACE
    .word UTF_FULL_BLOCK, UTF_NEW_LINE, UTF_CARRIAGE_RETURN 
.endm

.macro bottom_line
    .word UTF_FULL_BLOCK
    .fill COLUMN_CELLS_WITHOUT_BORDERS - COLUMN_CELLS_PLAYFIELD_OFFSET, FOUR_BYTES, UTF_HORIZONTAL_ELLIPSIS
    .word UTF_FULL_BLOCK
    .fill COLUMN_CELLS_PLAYFIELD_OFFSET - 1, FOUR_BYTES, UTF_FULL_BLOCK
    .word UTF_FULL_BLOCK, UTF_NEW_LINE, UTF_CARRIAGE_RETURN
.endm

.macro m_draw_vertical_character_line x, y, utf_character, line_length
    mov x0, \x
    mov x1, \y
    ldr x2, =\utf_character
    mov x3, \line_length 
    bl draw_vertical_character_line
.endm


.macro m_draw_game_block_line x, y, number_of_blocks, start_block, end_block
    mov x0, \x
    mov x1, \y
    mov x2, \number_of_blocks
    mov x3, \start_block
    mov x4, \end_block
    bl draw_game_block_line
.endm

.macro m_print_block x, y, block_type
    mov x0, \x
    mov x1, \y
    mov x2, \block_type
    bl print_block
.endm

.macro m_print_text x, y, message, message_length

    mov x0, \x
    mov x1, \y
    ldr x2, =\message
    ldr x3, =\message_length
    bl print_text

.endm


.macro print a, b
    mov x0, #1
    ldr x1, =\a
    ldr x2, =\b
    mov x8, SYS_WRITE
    svc 0
.endm


