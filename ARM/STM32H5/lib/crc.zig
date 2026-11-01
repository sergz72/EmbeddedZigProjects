const std = @import("std");

const CRC_BASE = 0x40023000;

pub const CrcRevin = enum(u2) {
    none = 0,
    byte = 1,
    half_word = 2,
    word = 3
};

pub const CrcPolySize = enum(u2) {
    _32 = 0,
    _16 = 1,
    _8 = 2,
    _7 = 3
};

pub const CrcCr = packed struct(u32) {
    reset: bool = false,
    reserved0: u2 = 0,
    polysize: CrcPolySize = ._32,
    rev_in: CrcRevin = .none,
    rev_out: bool = false,
    reserved1: u24 = 0
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

    pub fn reset(self: *volatile Crc) void {
        self.cr.reset = true;
    }

    pub fn crc32(self: *volatile Crc, data: []const u8) u32 {
        self.reset();
        self.cr = CrcCr{};
        var idx: usize = 0;
        var l = data.len;
        while (l != 0) {
            if (l >= 4) {
                const d: u32 = std.mem.readInt(u32, data[idx..][0..4], .big);
                self.dr.w = d;
                l -= 4;
                idx += 4;
                continue;
            }
            if (l >= 2) {
                const d: u16 = std.mem.readInt(u16, data[idx..][0..2], .big);
                self.dr.h = d;
                l -= 2;
                idx += 2;
                continue;
            }
            self.dr.b = data[idx];
            l = 0;
        }
        return self.dr.w;
    }
};

pub const crc: *volatile Crc = @ptrFromInt(CRC_BASE);

test "sizeof test" {
    try std.testing.expectEqual(0x18, @sizeOf(Crc));
}
