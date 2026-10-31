const std = @import("std");

const CRC_BASE = 0x40023000;

pub const Crc = extern struct {
    datar: u32,
    idatar: u16,
    reserved: u16,
    ctlr: u32,

    pub fn calculate(self: *volatile Crc, data: []const u8) u32 {
        self.ctlr = 1; // reset
        var idx: usize = 0;
        var l = data.len;
        while (l >= 4) {
            const d: u32 = std.mem.readInt(u32, data[idx..][0..4], .big);
            self.datar = d;
            l -= 4;
            idx += 4;
        }
        if (l != 0) {
            var v: [4]u8 = .{0, 0, 0, 0};
            @memcpy(v[0..l], data[idx..]);
            const d = std.mem.readInt(u32, &v, .big);
            self.datar = d;
        }
        return self.datar;
    }
};
    
pub const crc: *volatile Crc = @ptrFromInt(CRC_BASE);

test "sizeof test" {
    try std.testing.expectEqual(0x0C, @sizeOf(Crc));
}
