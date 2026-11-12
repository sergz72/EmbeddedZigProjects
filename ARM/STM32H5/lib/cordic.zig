const CORDIC_BASE = 0x40023800;

pub const Func = enum(u4) {
    cos = 0,
    sin = 1,
    phase = 2,
    modulus = 3,
    atan = 4,
    cosh = 5,
    sinh = 6,
    atanh = 7,
    ln = 8,
    sqrt = 9
};

pub const CordicCsr = bitpack struct(u32) {
    func: Func = .cos,
    precision: u4 = 5,
    scale: u3 = 0,
    reserved0: u5 = 0,
    ien: bool = false,
    dmaren: bool = false,
    dmawen: bool = false,
    nres: bool = false,
    nargs: bool = false,
    ressize: bool = false,
    argsize: bool = false,
    reserved1: u8 = 0,
    rrdy: bool = false,
};

pub const Cordic = extern struct {
    csr: CordicCsr,
    wdata: u32,
    rdata: u32
};

pub const cordic: *volatile Cordic = @ptrFromInt(CORDIC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x0C, @sizeOf(Cordic));
}
