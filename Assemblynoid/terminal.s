.include "terminal.inc"
.data
# Needed for the blocking thing of the terminal
#  The space reserved is for the termios struct
termios: .fill 36, 1, 0

.global input_char
input_char: .byte 0

.text

.type getchar, %function
.global getchar
getchar:
    stp x29, x30, [sp, #-16]!

    mov x0, STDIN_FILENO
    adr x1, input_char
    mov x2, 1
    mov x8, SYS_READ
    svc 0

    ldp x29, x30, [sp], #16
    ret
.size getchar, (. -getchar)


.type canonical_off, %function
.global canonical_off
canonical_off:
    stp x29, x30, [sp, #-16]! 
    
    bl read_stdin_termios
    
    mov w0, ICANON
    mvn w0, w0
    adr x1, termios
    ldr w2, [x1, #12]
    and w0, w2, w0
    str w0, [x1, #12]
    # 23 = CC_C + VTIME
    strb wzr, [x1, #CC_C+VTIME]
    strb wzr, [x1, #CC_C+VMIN]
    bl write_stdin_termios
    ldp x29, x30, [sp], #16
    ret
.size canonical_off, (. -canonical_off)

.type echo_off, %function
.global echo_off
echo_off:
    stp x29, x30, [sp, #-16]! 
    bl read_stdin_termios
    mov w0, ECHO
    mvn w0, w0
    adr x1, termios
    ldr w2, [x1, #12]!
    and w0, w2, w0
    str w0, [x1, #12]!
    bl write_stdin_termios
    ldp x29, x30, [sp], #16
    ret
.size echo_off, (. -echo_off)


.type canonical_on, %function
.global canonical_on
canonical_on:
    stp x29, x30, [sp, #-16]! 
    bl read_stdin_termios
    
    mov w0, ICANON
    mvn w0, w0
    adr x1, termios
    ldr w2, [x1, #12]
    orr w0, w2, w0
    str w0, [x1, #12]
    # 23 = CC_C + VTIME
    strb wzr, [x1, #CC_C+VTIME]
    mov w3, #1
    strb w3, [x1, #CC_C+VMIN]
    bl write_stdin_termios

    ldp x29, x30, [sp], #16
    ret
.size canonical_on, (. -canonical_on)

.type read_stdin_termios, %function
.global read_stdin_termios
read_stdin_termios:
    #syscall is ioctl, needed for avoiding the blocking issue 
    stp x29, x30, [sp, #-16]! 
    mov x0, stdin 
    mov x1, 0x5401
    adr x2, termios
    mov x8, 29 
    svc 0
    ldp x29, x30, [sp], #16
    ret
.size read_stdin_termios, (. -read_stdin_termios)

.type write_stdin_termios, %function
.global write_stdin_termios
write_stdin_termios:
    stp x29, x30, [sp, #-16]! 
    #syscall is ioctl, needed for avoiding the blocking issue 
    mov x0, stdin 
    mov x1, 0x5402
    adr x2, termios
    mov x8, 29 
    svc 0
    ldp x29, x30, [sp], #16
    ret
.size write_stdin_termios, (. -write_stdin_termios)

