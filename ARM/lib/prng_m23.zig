var rng_seed: usize = undefined;

pub fn prngInit(seed: usize) void {
    rng_seed = seed;
}

fn prng() usize {
    return asm volatile(
        \\ldr  r0, [r1]

        \\lsls r2, r0, #13
        \\eors r0, r2

        \\lsrs r2, r0, #17
        \\eors r0, r2

        \\lsls r2, r0, #5
        \\eors r0, r2

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
