const std = @import("std");

pub const DisplayCharacter = struct {
    x: u16,
    y: u16,
    text_color: u16 = 0xFFFF,
    bk_color: u16 = 0,
    c: u8 = ' '
};

pub const DisplayRectangle = struct {
    x: u16,
    y: u16,
    width: u16,
    height: u16,
    color: u16 = 0
};

pub const Display = struct {
    characters: []DisplayCharacter = undefined,
    rectangles: []DisplayRectangle = undefined,
    width: usize,
    draw_char: *const fn (u16, u16, u8, u16, u16) void,
    rect_fill: *const fn (u16, u16, u16, u16, u16) void,

    pub fn init(self: *Display, allocator: std.mem.Allocator,
        rows: usize, symbol_width: u16, symbol_height: u16, rectangle_count: usize) !void {
        self.characters = try allocator.alloc(DisplayCharacter, rows * self.width);
        self.rectangles = try allocator.alloc(DisplayRectangle, rectangle_count);
        var y: u16 = 0;
        var idx: usize = 0;
        for (0..rows) |_| {
            var x: u16 = 0;
            for (0..self.width) |_| {
                self.characters[idx] = DisplayCharacter{
                    .x = x,
                    .y = y
                };
                x += symbol_width;
                idx += 1;
            }
            y += symbol_height;
        }
        for (0..rectangle_count) |ridx| {
            self.rectangles[ridx].color = 0;
        }
    }

    pub fn init_rectangle(self: *Display, idx: usize, x: u16, y: u16, width: u16, height: u16) void {
        var r = &self.rectangles[idx];
        r.x = x;
        r.y = y;
        r.width = width;
        r.height = height;
    }

    pub fn set_rectangle_color(self: *Display, idx: usize, color: u16) void {
        var r = &self.rectangles[idx];
        if (r.color == color)
            return;
        r.color = color;
        self.rect_fill(r.x, r.y, r.width, r.height, color);
    }

    pub fn init_char(self: *Display, column: usize, row: usize, text_color: u16, bk_color: u16) void {
        var ch = &self.characters[self.width * row + column];
        ch.text_color = text_color;
        ch.bk_color = bk_color;
    }

    pub fn set_char(self: *Display, column: usize, row: usize, c: u8) void {
        var ch = &self.characters[self.width * row + column];
        if (ch.c == c)
            return;
        ch.c = c;
        self.draw_char(ch.x, ch.y, c, ch.text_color, ch.bk_color);
    }
};
