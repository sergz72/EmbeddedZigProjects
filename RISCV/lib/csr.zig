pub inline fn getHartId() u32 {
    return asm volatile (
        "csrr a0, mhartid"
        : [result] "={a0}" (-> usize)
    );
}