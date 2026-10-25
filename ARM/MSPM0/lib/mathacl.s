        .syntax unified
        .cpu    cortex-m0plus
        .thumb

        .equ MATHACL_BASE,   0x40410000
        .equ MATHACL_REGS,   MATHACL_BASE + 0x1100
        .equ CTL,            0x00
        .equ OP2,            0x18         @ divisor
        .equ OP1,            0x1C         @ dividend
        .equ RES1,           0x20         @ quotient
        .equ RES2,           0x24         @ remainder
        .equ STATUS,         0x30
        .equ CTL_DIV_UNSIGNED, 0x04       @ FUNC=DIV(4), OPTYPE=unsigned, Q0
        .equ CTL_DIV_SIGNED,   0x24       @ FUNC=DIV(4) | OPTYPE=signed (bit 5), Q0
    
        .macro  MATHACL_DIV ctl
        ldr     r2, =MATHACL_REGS
        movs    r3, #\ctl
        str     r3, [r2, #CTL]
        str     r1, [r2, #OP2]
        str     r0, [r2, #OP1]
1:      ldr     r3, [r2, #STATUS]
        lsls    r3, r3, #23         @ BUSY -> bit 8
        bmi     1b
        ldr     r0, [r2, #RES1]
        ldr     r1, [r2, #RES2]
        bx      lr
        .endm

        .section .text.__aeabi_idivmod,"ax",%progbits
        .global __aeabi_idiv
        .global __aeabi_idivmod
        .type   __aeabi_idivmod, %function
        .thumb_func
__aeabi_idiv:
__aeabi_idivmod:
        MATHACL_DIV CTL_DIV_SIGNED

        .section .text.__aeabi_uidivmod,"ax",%progbits
        .global __aeabi_uidiv
        .global __aeabi_uidivmod
        .type   __aeabi_uidivmod, %function
        .thumb_func
__aeabi_uidiv:
__aeabi_uidivmod:
        MATHACL_DIV CTL_DIV_UNSIGNED
