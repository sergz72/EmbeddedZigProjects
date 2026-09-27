.section .text,"ax",@progbits
.global __riscv_restore_0
.global __riscv_save_0

__riscv_restore_0:
    lw      s2,0(sp)
    lw      s1,4(sp)
    lw      s0,8(sp)
    lw      ra,12(sp)
    addi    sp,sp,16
    ret

__riscv_save_0:
    addi    sp,sp,-16
    sw      s2,0(sp)
    sw      s1,4(sp)
    sw      s0,8(sp)
    sw      ra,12(sp)
    jr      t0

