.include "constants.inc"
.include "terminal.inc"

# Sleep time constants
timespec:
    tv_sec: .quad 0
    tv_nsec: .quad 10000000

# The syscall for the random number
.equ SYS_GETRANDOM, 278

# The flag for the random syscall
.equ GRND_RANDOM, 1

.data
# The buffer used for the random number generator
random_buffer: .quad 0

    


.text

.type sleeptime, %function
.global sleeptime
# Function: sleeptime
#   This function is called when a sleeptime time is required in game
# Arguments:
#   None.
# Return:
#   Void.
sleeptime:
    stp x29, x30, [sp, #-16]!
    
    adr x0, timespec
    mov x8, SYS_NANOSLEEP
    svc 0

    ldp x29, x30, [sp], #16
    ret




# Function: get_random_number
#   This function is called to get a random byte from the syscall.
#   It will get 8 random bytes and return a number in tha range 
#   defined in the arguments.
# Arguments:
#   x0: The range between 0 and the number defined in the argument
# Return:
#   x0: A value between 0 and the number defined in the argument.
.type get_random_number, %function
.global get_random_number
get_random_number:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
   
    mov x19, x0

    adr x0, random_buffer
    mov x1, EIGHT_BYTES
    mov x2, GRND_RANDOM
    mov x8, SYS_GETRANDOM
    svc 0

    adr x0, random_buffer
    ldr x0, [x0]
    mov x1, x19
    bl unsigned_division_64

    mov x0, x1

    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.size get_random_number, (. -get_random_number)

# Function: unsigned_division_64
#   This function performs the unsigned division of a number. 
# Arguments:
#   x0: dividend
#   x1: divisor
# Return:
#   x0: quotient
#   x1: remainder
.type unsigned_division_64, %function
.global unsigned_division_64
unsigned_division_64:
    stp x29, x30, [sp, #-16]!

    .udiv64:
        cbnz x1, .endif1    // if(divisor == 0)
        mov x0, #0          //     return 0
        mov x1, #0 
        b .ud64_end

    .endif1:
        clz x2, x1          // x2 = count
        lsl x1, x1, x2      // divisor <<= count
        mov x3, #0          // x3 = quotient
        add x2, x2, #1      // x2 = count + 1

    .divloop:
        lsl x3, x3, #1      // Shift 0 into quotient LSB
        cmp x0, x1      
        blo .endif2         // if (dividend >= divisor)
        orr x3, x3, #1      // Set LSB of quotient
        sub x0, x0, x1      // dividend -= divisor

    .endif2:
        sub x2, x2, #1      // Decrement count
        lsr x1, x1, #1      // Shift divisor right
        cbnz x2, .divloop    // while (count+1 != 0)
        mov x1, x0          // remainder is the dividen
        mov x0, x3          // return quotient
        b .ud64_end

    .ud64_end:

    ldp x29, x30, [sp], #16
    ret



