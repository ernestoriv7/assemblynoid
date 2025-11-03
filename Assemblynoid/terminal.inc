.macro setnonblocking
    mov x0, STDIN_FILENO
    mov x1, F_SETFL
    mov x2, O_NONBLOCK
    mov x8, SYS_FCNTL
    svc 0
.endm

.macro unsetnonblocking
    mov x0, STDIN_FILENO
    mov x1, F_SETFL
    mov x2, 0
    mov x8, SYS_FCNTL
    svc 0
.endm
# Defines for non blocking, take in consideration that syscalls for arm64 are used
.equ SYS_READ, 63 
.equ SYS_WRITE, 64 
.equ SYS_NANOSLEEP, 101
.equ SYS_TIME, 201
.equ SYS_FCNTL, 72

.equ STDIN_FILENO, 0


.equ F_SETFL, 0x0004
.equ O_NONBLOCK, 0x0004



.equ stdin, 0
.equ ICANON, 1<<1
.equ ECHO, 1<<3
.equ VTIME, 5
.equ VMIN, 6
.equ CC_C, 18


