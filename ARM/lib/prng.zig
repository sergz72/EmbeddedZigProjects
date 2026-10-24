var rng_seed: usize = undefined;

pub fn prngInit(seed: usize) void {
    rng_seed = seed;
}

fn prng() usize {
    return asm volatile(
        \\ldr  r0, [r1]

        \\mov r2, r0, lsl #13
        \\eor r0, r2, r0

        \\mov r2, r0, lsr #17
        \\eor r0, r2, r0

        \\mov r2, r0, lsl #5
        \\eor r0, r2, r0

        \\str  r0, [r1]
        : [result] "={r0}" (-> usize),
        : [seed_ptr] "{r1}" (&rng_seed)
        : .{ .r1 = true, .r2 = true }
    );
}

pub fn prngGen(data:[]u32) bool {
    for (data) |*b| {
        b.* = prng();
    }
    return true;
}
