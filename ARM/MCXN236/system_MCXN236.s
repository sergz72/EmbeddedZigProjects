	.syntax	unified
	.cpu	cortex-m33
	.text
	.globl	SystemPreInit                   @ -- Begin function SystemPreInit
	.p2align	1
	.prefalign	2, .Lfunc_end0, nop
	.type	SystemPreInit,%function
	.code	16
	.thumb_func
SystemPreInit:                          @ @SystemPreInit
	movw	r1, #60808
	movt	r1, #57344
	ldr	r0, [r1]
	movw	r2, #3075
	orr	r0, r0, #15728640
	str	r0, [r1]
	ldr	r0, [r1]
	mov.w	r12, #0
	orr	r0, r0, #15
	str	r0, [r1]
	ldr	r0, [r1, #4]
	movw	r3, #1024
	orrs	r0, r2
	movw	r2, #2084
	movt	r2, #16384
	str	r0, [r1, #4]
	str.w	r12, [r2, #1568]
	movt	r3, #16384
	ldr	r0, [r3]
	bic	r0, r0, #131072
	str	r0, [r3]
	movw	r0, :lower16:__Vectors
	movt	r0, :upper16:__Vectors
	str	r0, [r1, #-128]
	ldr	r0, [r2]
	movw	r1, #24616
	bic	r0, r0, #1
	str	r0, [r2]
	movt	r1, #16386
	ldr	r0, [r1]
	movs	r2, #2
	bfi	r0, r2, #18, #2
	str	r0, [r1]
	ldr	r0, [r1, #4]
	bfi	r0, r2, #18, #2
	str	r0, [r1, #4]
	movw	r0, #20804
	movt	r0, #16388
	ldr	r3, [r0, #-68]
	orr	r3, r3, #4096
	str	r3, [r0, #-68]
	ldr	r3, [r0]
	bic	r3, r3, #65536
	str	r3, [r0]
	movs	r3, #60
	str	r3, [r0]
	ldr	r3, [r0]
	orr	r3, r3, #65536
	str	r3, [r0]
	ldr	r3, [r1]
	bfi	r3, r2, #0, #2
	str	r3, [r1]
	ldr	r3, [r1, #4]
	bfi	r3, r2, #0, #2
	str	r3, [r1, #4]
	movw	r1, #16392
	movt	r1, #16386
	str.w	r12, [r1]
	movw	r1, #20488
	movt	r1, #16386
	str.w	r12, [r1]
	ldr.w	r1, [r0, #444]
	orr	r1, r1, #16777216
	str.w	r1, [r0, #444]
	bx	lr
.Lfunc_end0:
