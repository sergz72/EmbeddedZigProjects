const std = @import("std");

pub const CRC_BASE = 0x40023000;

pub const CrcRevid = enum(u2) {
    none = 0,
    byte = 1,
    half_word = 2,
    word = 3
};

pub const CrcCtrl = packed struct(u32) {
    rst: bool = false,
    reserved: u4 = 0,
    revid: CrcRevid = .none,
    revod: bool = false,
    reserved2: u24 = 0
};

pub const CrcData = extern union {
    b: u8,
    h: u16,
    w: u32
};

pub const Crc = extern struct {
    dt: CrcData,
    cdt: u32,
    ctrl: CrcCtrl,
    reserved: u32,
    idt: u32,

    pub fn reset(self: *volatile Crc) void {
        self.ctrl.rst = true;
    }

    pub fn crc32(self: *volatile Crc, data: []const u8) u32 {
        self.reset();
        self.ctrl = CrcCtrl{};
        var idx: usize = 0;
        var l = data.len;
        while (l != 0) {
            if (l >= 4) {
                const d: u32 = std.mem.readInt(u32, data[idx..][0..4], .big);
                self.dt.w = d;
                l -= 4;
                idx += 4;
                continue;
            }
            if (l >= 2) {
                const d: u16 = std.mem.readInt(u16, data[idx..][0..2], .big);
                self.dt.h = d;
                l -= 2;
                idx += 2;
                continue;
            }
            self.dt.b = data[idx];
            l = 0;
        }
        return self.dt.w;
    }
};

pub const crc: *volatile Crc = @ptrFromInt(CRC_BASE);

test "sizeof test" {
    try std.testing.expectEqual(0x14, @sizeOf(Crc));
}
