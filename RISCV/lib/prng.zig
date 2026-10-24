var rng_seed: usize = undefined;

pub fn prngInit(seed: usize) void {
    rng_seed = seed;
}

fn prng() usize {
    return asm volatile(
        \\lw   t0, 0(t2)
        
        \\slli t1, t0, 13
        \\xor  t0, t0, t1

        \\srli t1, t0, 17
        \\xor  t0, t0, t1

        \\slli t1, t0, 5
        \\xor  t0, t0, t1

        \\sw   t0, 0(t2)
        \\mv   a0, t0
        : [result] "={t0}" (-> usize),
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
