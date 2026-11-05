    .syntax unified
    .thumb

    .section .text.copyFromPMA32,"ax",%progbits
    .global copyFromPMA32
    .global copyToPMA32
    .type   copyFromPMA32, %function
    .thumb_func
copyToPMA32:
copyFromPMA32: // dest = r0, src = r1, length = r2
    cbz r2, 2f
    lsr r12, r2, #2   // Divide length by 4 to get number of 32-bit words
    tst r2, #3
    beq 1f
    add r2, r12, #1
1:
    ldr r3, [r1], #4   // Load 32-bit word, post-index increment src by 4
    str r3, [r0], #4   // Store 32-bit word, post-index increment dest by 4
    subs r2, r2, #1
    bne 1b
2:
    bx lr

    .section .text.copyFromPMA16,"ax",%progbits
    .global copyFromPMA16
    .global copyToPMA16
    .type   copyFromPMA16, %function
    .thumb_func
copyToPMA16:
copyFromPMA16: // dest = r0, src = r1, length = r2
    cbz r2, 2f
    lsr r12, r2, #1   // Divide length by 2 to get number of 16-bit words
    tst r2, #1
    beq 1f
    add r2, r12, #1
1:
    ldrh r3, [r1], #2   // Load 16-bit word, post-index increment src by 2
    strh r3, [r0], #2   // Store 16-bit word, post-index increment dest by 2
    subs r2, r2, #1
    bne 1b
2:
    bx lr
