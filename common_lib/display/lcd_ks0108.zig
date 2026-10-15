const std = @import("std");
const lcd_bw = @import("lcd_bw");

const LCD_CONTROLLER_AREA = 64;
const LCD_PAGE_COUNT = 8;
const LCD_CS1 = 1;
const LCD_CS2 = 2;
const LCD_WIDTH = 128;
const LCD_HEIGHT = 64;

pub const LcdKS0108 = struct {
    write: *const fn(data: u8, cs: u2, dc: bool) void,
    set_reset: *const fn(state: bool) void,
    canvas: lcd_bw.LcdBw = undefined,
    buffer: []u8 = undefined,

    inline fn command(self: *LcdKS0108, data: u8, cs: u2) void {
        self.write(data, cs, false);
    }

    inline fn writeData(self: *LcdKS0108, data: u8, cs: u2) void {
        self.write(data, cs, true);
    }

    pub fn init(self: *LcdKS0108, orientation: lcd_bw.Orientation, allocator: std.mem.Allocator) error{OutOfMemory}!void {
        self.buffer = try allocator.alloc(u8, LCD_WIDTH * LCD_HEIGHT / 8);
        self.canvas = lcd_bw.LcdBw{
            .width = LCD_WIDTH,
            .height = LCD_HEIGHT,
            .orientation = orientation,
            .getPixelIndexAndBit = getPixelIndexAndBit
        };
        try self.canvas.init(allocator);
        self.set_reset(true);
        self.canvas.clearScreen();
        @memset(self.buffer, 0);
        self.setStartLine(0, LCD_CS1|LCD_CS2);
    }

    pub fn off(self: *LcdKS0108) void {
        self.command(0x3E, LCD_CS1|LCD_CS2);
    }

    pub fn on(self: *LcdKS0108) void {
        self.command(0x3F, LCD_CS1|LCD_CS2);
    }

    pub fn setY(self: *LcdKS0108, y: u6, cs: u2) void {
        self.command(0x40 | @as(u8, y), cs);
    }

    pub fn setX(self: *LcdKS0108, x: u3, cs: u2) void {
        self.command(0xB8 | @as(u8, x), cs);
    }

    pub fn setStartLine(self: *LcdKS0108, line: u6, cs: u2) void {
        self.command(0xC0 | @as(u8, line), cs);
    }

    pub fn update(self: *LcdKS0108) void {
        var buffer_idx: usize = 0;
        for (0..LCD_PAGE_COUNT) |xx| {
            const x: u3 = @truncate(xx);
            var setx = true;
            var sety = true;
            for (0..LCD_CONTROLLER_AREA) |yy| {
                const y: u6 = @truncate(yy);
                const paint_data = self.canvas.buffer[buffer_idx];
                if (paint_data != self.buffer[buffer_idx]) {
                    self.buffer[buffer_idx] = paint_data;
                    if (sety) {
                        if (setx) {
                            self.setX(x, LCD_CS1);
                            setx = false;
                        }
                        self.setY(y, LCD_CS1);
                        sety = false;
                    }
                    self.writeData(paint_data, LCD_CS1);
                }
                else {
                    sety = true;
                }
                buffer_idx += 1;
            }

            setx = true;
            sety = true;
            for (0..LCD_CONTROLLER_AREA) |yy| {
                const y: u6 = @truncate(yy);
                const paint_data = self.canvas.buffer[buffer_idx];
                if (paint_data != self.buffer[buffer_idx]) {
                    self.buffer[buffer_idx] = paint_data;
                    if (sety) {
                        if (setx) {
                            self.setX(x, LCD_CS2);
                            setx = false;
                        }
                        self.setY(y, LCD_CS2);
                        sety = false;
                    }
                    self.writeData(paint_data, LCD_CS2);
                }
                else {
                    sety = true;
                }
                buffer_idx += 1;
            }
        }
    }
};

fn getPixelIndexAndBit(canvas: *const lcd_bw.LcdBw, x: u16, y: u16) struct { usize, u3 } {
    switch (canvas.orientation) {
        .portrait => {
            const idx = ((LCD_HEIGHT - 1 - x) >> 3) * LCD_WIDTH + y;
            const bit: u3 = @truncate(7 - (x & 7));
            return .{ idx, bit };
        },
        .landscape => {
            const idx = (y >> 3) * LCD_WIDTH + x;
            const bit: u3 = @truncate(y & 7);
            return .{ idx, bit };
        },
        .reverse_portrait => {
            const idx = (x >> 3) * LCD_WIDTH + (LCD_WIDTH - 1 - y);
            const bit: u3 = @truncate(x & 7);
            return .{ idx, bit };
        },
        .reverse_landscape => {
            const idx = ((LCD_HEIGHT - 1 - y) >> 3) * LCD_WIDTH + (LCD_WIDTH - 1 - x);
            const bit: u3 = @truncate(7 - (y & 7));
            return .{ idx, bit };
        },
    }
}
