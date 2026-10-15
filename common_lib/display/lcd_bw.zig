const std = @import("std");
const font = @import("font");

pub const Orientation = enum(usize) {
    portrait,
    landscape,
    reverse_portrait,
    reverse_landscape,
};

pub const LcdBw = struct {
    width: u16,
    height: u16,
    orientation: Orientation,
    getPixelIndexAndBit: *const fn(canvas: *const LcdBw, x: u16, y: u16) struct { usize, u3 },
    buffer: []u8 = undefined,

    pub fn init(self: *LcdBw, allocator: std.mem.Allocator) error{OutOfMemory}!void {
        self.buffer = try allocator.alloc(u8, self.width * self.height / 8);
        self.clearScreen();
    }

    pub fn clearScreen(self: *LcdBw) void {
        @memset(self.buffer, 0);
    }

    pub fn drawChar(self: *const LcdBw, x: u16, y: u16, c: u8, f: *const font.FontInfo, white_on_black: bool) void {
        if (c < f.start_character or c > f.start_character + f.character_count or x >= self.width or y >= self.height)
            return;
        const char_bytes = f.getCharTotalBytes();
        var idx = @as(usize, c - f.start_character) * char_bytes;
        var y_pos = y;
        for (0..f.character_height) |_| {
            var cnt: usize = 0;
            var ch = f.character_bitmaps[idx];
            idx += 1;
            var x_pos = x;
            for (0..f.character_width) |_| {
                if ((ch & 0x80) != 0) {
                    self.writeColor(x_pos, y_pos, !white_on_black, 1);
                } else {
                    self.writeColor(x_pos, y_pos, white_on_black, 1);
                }
                ch <<= 1;
                cnt += 1;
                if (cnt == 8) {
                    cnt = 0;
                    ch = f.character_bitmaps[idx];
                    idx += 1;
                }
                x_pos += 1;
            }
            self.writeColor(x_pos, y_pos, white_on_black, f.character_spacing);
            y_pos += 1;
        }
    }

    pub fn writeColor(self: *const LcdBw, x: u16, y: u16, color: bool, count: usize) void {
        var x_pos = x;
        for (0..count) |_| {
            const idx, const bit = self.getPixelIndexAndBit(self, x_pos, y);
            if (color) {
                self.buffer[idx] |= (@as(u8, 1) << bit);
            } else {
                self.buffer[idx] &= ~(@as(u8, 1) << bit);
            }
            x_pos += 1;
        }
    }
};