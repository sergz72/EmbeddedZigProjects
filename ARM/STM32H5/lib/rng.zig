const RNG_BASE = 0x420C0800;

pub const Clkdiv = enum(u4) {
    div1 = 0,
    div2 = 1,
    div4 = 2,
    div8 = 3,
    div16 = 4,
    div32 = 5,
    div64 = 6,
    div128 = 7,
    div256 = 8,
    div512 = 9,
    div1024 = 10,
    div2048 = 11,
    div4096 = 12,
    div8192 = 13,
    div16384 = 14,
    div32768 = 15
};

pub const RngCr = packed struct(u32) {
    reserved0: u2 = 0,
    rngen: bool = false,
    ie: bool = false,
    reserved1: u1 = 0,
    ced: bool = false,
    reserved2: u1 = 0,
    ardis: bool = false,
    rng_config3: u4 = 14,
    nistc: bool = true,
    rng_config2: u3 = 0,
    clkdiv: Clkdiv = .div2,
    rng_config1: u6 = 8,
    reserved3: u4 = 0,
    condrst: bool = false,
    configlock: bool = false,
};

pub const RngSr = packed struct(u32) {
    drdy: bool = false,
    cecs: bool = false,
    secs: bool = false,
    reserved0: u2 = 0,
    ceis: bool = false,
    seis: bool = false,
    reserved1: u25 = 0,
};

pub const RngNscr = packed struct(u32) {
    en_osc1: u3 = 7,
    en_osc2: u3 = 7,
    en_osc3: u3 = 7,
    en_osc4: u3 = 7,
    en_osc5: u3 = 7,
    en_osc6: u3 = 7,
    reserved0: u14 = 0,
};

pub const Rng = extern struct {
    cr: RngCr,
    sr: RngSr,
    dr: u32,
    nscr: RngNscr,
    htcr: u32,
};

pub const rng: *volatile Rng = @ptrFromInt(RNG_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x14, @sizeOf(Rng));

}
