const std = @import("std");

const CRC_BASE = 0x40023000;

pub const CrcRevin = enum(u2) {
    none = 0,
    byte = 1,
    half_word = 2,
    word = 3
};

pub const CrcRevout = enum(u2) {
    none = 0,
    half_word = 1,
    byte = 2
};

pub const CrcPolySize = enum(u2) {
    _32 = 0,
    _16 = 1,
    _8 = 2,
    _7 = 3
};

pub const CrcCr = bitpack struct(u32) {
    reset: bool = false,
    reserved0: u2 = 0,
    polysize: CrcPolySize = ._32,
    rev_in: CrcRevin = .none,
    rev_out: CrcRevout = .none,
    rtype_in: bool = false,
    rtype_out: bool = false,
    reserved1: u21 = 0
};

pub const CrcData = extern union {
    b: u8,
    h: u16,
    w: u32
};

pub const Crc = extern struct {
    dr: CrcData,
    idr: u32,
    cr: CrcCr,
    reserved: u32,
    init: u32,
    pol: u32,
};

pub fn reset() void {
    crc.cr.reset = true;
}

pub fn crc32(data: []const u8) u32 {
    reset();
    crc.cr = CrcCr{};
    var idx: usize = 0;
    var l = data.len;
    while (l != 0) {
        if (l >= 4) {
            const d: u32 = std.mem.readInt(u32, data[idx..][0..4], .big);
            crc.dr.w = d;
            l -= 4;
            idx += 4;
            continue;
        }
        if (l >= 2) {
            const d: u16 = std.mem.readInt(u16, data[idx..][0..2], .big);
            crc.dr.h = d;
            l -= 2;
            idx += 2;
            continue;
        }
        crc.dr.b = data[idx];
        l = 0;
    }
    return crc.dr.w;
}

pub const crc: *volatile Crc = @ptrFromInt(CRC_BASE);

test "sizeof test" {
    try std.testing.expectEqual(0x18, @sizeOf(Crc));
}
