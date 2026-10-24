var rng_seed: usize = undefined;

pub fn prngInit(seed: usize) void {
    rng_seed = seed;
}

fn prng() usize {
    return asm volatile(
        \\lw   a0, 0(t2)
        
        \\slli t1, a0, 13
        \\xor  a0, a0, t1

        \\srli t1, a0, 17
        \\xor  a0, a0, t1

        \\slli t1, a0, 5
        \\xor  a0, a0, t1

        \\sw   a0, 0(t2)
        : [result] "={a0}" (-> usize),
        : [seed_ptr] "{t2}" (&rng_seed)
        : .{ .t1 = true, .t2 = true }
    );
}

pub fn prngGen(data:[]u32) bool {
    for (data) |*b| {
        b.* = prng();
    }
    return true;
}
