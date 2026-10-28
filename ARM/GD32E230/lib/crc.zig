const std = @import("std");

const CRC_BASE = 0x40023000;

pub const CrcPolySize = enum(u2) {
    _32 = 0,
    _16 = 1,
    _8 = 2,
    _7 = 3
};

pub const CrcReverse = enum(u2) {
    none = 0,
    byte = 1,
    half_word = 2,
    word = 3
};

pub const CrcCtl = packed struct(u32) {
    rst: bool = false,
    reserved: u2 = 0,
    ps: CrcPolySize = ._32,
    rev_i: CrcReverse = .none,
    rev_o: bool = false,
    reserved2: u24 = 0
};

pub const CrcData = extern union {
    b: u8,
    h: u16,
    w: u32
};

pub const Crc = extern struct {
    data: CrcData,
    fdata: u32,
    ctl: CrcCtl,
    reserved: u32,
    idata: u32,
    poly: u32,

    pub fn reset(self: *volatile Crc) void {
        self.ctl.rst = true;
    }

    pub fn crc32(self: *volatile Crc, data: []const u8) u32 {
        self.reset();
        self.ctl = CrcCtl{};
        var idx: usize = 0;
        var l = data.len;
        while (l != 0) {
            if (l >= 4) {
                const d: u32 = std.mem.readInt(u32, data[idx..][0..4], .big);
                self.data.w = d;
                l -= 4;
                idx += 4;
                continue;
            }
            if (l >= 2) {
                const d: u16 = std.mem.readInt(u16, data[idx..][0..2], .big);
                self.data.h = d;
                l -= 2;
                idx += 2;
                continue;
            }
            self.data.b = data[idx];
            l = 0;
        }
        return self.data.w;
    }
};

pub const crc: *volatile Crc = @ptrFromInt(CRC_BASE);

test "sizeof test" {
    try std.testing.expectEqual(0x18, @sizeOf(Crc));
}
