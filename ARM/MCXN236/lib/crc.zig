const std = @import("std");

const CRC0_BASE = 0x400CB000;

pub const CrcData = extern union {
    b: u8,
    h: u16,
    w: u32
};

pub const CrcPoly = extern union {
    h: u16,
    w: u32
};

pub const CrcTot = enum(u2) {
    none = 0,
    bits = 1,
    bytes_bits = 2,
    bytes = 3,
};

pub const CrcCtrl = bitpack struct(u32) {
    reserved0: u24 = 0,
    tcrc: bool = false,
    was: bool = false,
    fxor: bool = false,
    reserved1: u1 = 0,
    totr: CrcTot = .none,
    tot: CrcTot = .none,
};

pub const CrcParameters32 = struct {
    poly: u32,
    seed: u32,
    fxor: bool
};

pub const CrcParameters16 = struct {
    poly: u16,
    seed: u16,
    fxor: bool
};

pub const Crc = extern struct {
    data: CrcData,
    gpoly: CrcPoly,
    ctrl: CrcCtrl,
};

pub fn crc32(parameters: *const CrcParameters32, data: []const u8) u32 {
    crc0.gpoly.w = parameters.poly;
    crc0.ctrl = CrcCtrl{.was = true};
    crc0.data.w = parameters.seed;
    crc0.ctrl = CrcCtrl{.fxor = parameters.fxor};
    var idx: usize = 0;
    var l = data.len;
    while (l != 0) {
        if (l >= 4) {
            const d: u32 = std.mem.readInt(u32, data[idx..][0..4], .big);
            crc0.data.w = d;
            l -= 4;
            idx += 4;
            continue;
        }
        if (l >= 2) {
            const d: u16 = std.mem.readInt(u16, data[idx..][0..2], .big);
            crc0.data.h = d;
            l -= 2;
            idx += 2;
            continue;
        }
        crc0.data.b = data[idx];
        l = 0;
    }
    return crc0.data.w;
}

pub fn crc16(parameters: *const CrcParameters16, data: []const u8) u16 {
    crc0.gpoly.h = parameters.poly;
    crc0.ctrl = CrcCtrl{.was = true};
    crc0.data.h = parameters.seed;
    crc0.ctrl = CrcCtrl{.fxor = parameters.fxor};
    var idx: usize = 0;
    var l = data.len;
    while (l != 0) {
        if (l >= 2) {
            const d: u16 = std.mem.readInt(u16, data[idx..][0..2], .big);
            crc0.data.h = d;
            l -= 2;
            idx += 2;
            continue;
        }
        crc0.data.b = data[idx];
        l = 0;
    }
    return crc0.data.h;
}

pub const crc0: *volatile Crc = @ptrFromInt(CRC0_BASE);

test "sizeof test" {
    try std.testing.expectEqual(0xC, @sizeOf(Crc));
}
