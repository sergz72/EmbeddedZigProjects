const font = @import("font");

pub const SpiLcdInterface = struct {
    writer: *const fn ([]const u8) void,
    dc_set: *const fn (bool) void,
    cs_set: *const fn (bool) void,
    set_window: *const fn (*anyopaque, u8, u8, u8, u8) void,
};

pub const SpiLcd = struct {
    interface: SpiLcdInterface,
    width: u8,
    height: u8,
    ctx: *anyopaque,

    pub fn send_command(self: *const SpiLcd, cmd: u8) void {
        self.interface.dc_set(false);
        self.interface.writer((&cmd)[0..1]);
    }

    pub fn send_commands(self: *const SpiLcd, cmd: []const u8) void {
        self.interface.dc_set(false);
        self.interface.writer(cmd);
    }

    pub fn send_data(self: *const SpiLcd, data: []u8) void {
        self.interface.dc_set(true);
        self.interface.writer(data);
    }

    pub fn rect_fill(self: *const SpiLcd, x: u8, y: u8, dx: u8, dy: u8, color: u16) void {
        self.interface.set_window(self.ctx, x, y, x + dx - 1, y + dy - 1);
        self.write_color(color, @as(usize, dx) * @as(usize, dy));
        self.interface.cs_set(true);
    }

    pub fn screen_fill(self: *const SpiLcd, color: u16) void {
        self.rect_fill(0, 0, self.width, self.height, color);
    }

    pub fn draw_char(self: *const SpiLcd, x: u8, y: u8, c: u8, f: *const font.FontInfo, text_color: u16, bk_color: u16) void {
        if (c < f.start_character or c > f.start_character + f.character_count or x >= self.width or y >= self.height)
            return;
        const char_bytes = f.get_char_total_bytes();
        var idx = @as(usize, c - f.start_character) * char_bytes;
        self.interface.set_window(self.ctx, x, y, x + f.character_width + f.character_spacing - 1, y + f.character_height - 1);
        for (0..f.character_height) |_| {
            var cnt: usize = 0;
            var ch = f.character_bitmaps[idx];
            idx += 1;
            for (0..f.character_width) |_| {
                if ((ch & 0x80) != 0) {
                    self.write_color(text_color, 1);
                } else {
                    self.write_color(bk_color, 1);
                }
                ch <<= 1;
                cnt += 1;
                if (cnt == 8) {
                    cnt = 0;
                    ch = f.character_bitmaps[idx];
                    idx += 1;
                }
            }
            self.write_color(bk_color, f.character_spacing);
        }
        self.interface.cs_set(true);
    }

    pub fn write_color(self: *const SpiLcd, color: u16, count: usize) void {
        const data: [2]u8 = @bitCast(color);
        self.interface.dc_set(true);
        for (0..count) |_| {
            self.interface.writer(data[0..]);
        }
    }
};
