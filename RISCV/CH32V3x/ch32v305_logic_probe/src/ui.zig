const std = @import("std");
const lcd = @import("lcd");
const font5 = @import("font5");
const display = @import("display");
const hal = @import("hal");

const lcd_interface = lcd.LcdSSD1357Interface ;

var lcd_instance = lcd.LcdSSD1357 {
    .spi_lcd = .{
        .interface = .{
            .writer = hal.lcd_writer,
            .dc_set = hal.lcd_dc_set,
            .cs_set = hal.lcd_cs_set,
            .set_window = lcd.LcdSSD1357.set_window
        },
        .width = 64,
        .height = 64,
        .ctx = undefined
    },
    .reset_set = hal.lcd_reset_set
};

var disp = display.Display{
    .draw_char = display_draw_char,
    .rect_fill = display_rect_fill,
    .width = 8
};

fn display_draw_char(x: u16, y: u16, c: u8, text_color: u16, bk_color: u16) void {
    lcd_instance.spi_lcd.draw_char(@truncate(x), @truncate(y), c, &font5.fiveBySevenFontInfo, text_color, bk_color);
}

fn display_rect_fill(x: u16, y: u16, width: u16, height: u16, color: u16) void {
    lcd_instance.spi_lcd.rect_fill(@truncate(x), @truncate(y), @truncate(width), @truncate(height), color);
}

pub const UI = struct {
    pub fn init(allocator: std.mem.Allocator) !void {
        lcd_instance.spi_lcd.ctx = &lcd_instance;
        lcd_instance.init(0);
        try disp.init(allocator, 8, 8, 8, 4);
        disp.init_rectangle(0, 54, 24, 10, 10);
        disp.init_rectangle(1, 54, 34, 10, 10);
        disp.init_rectangle(2, 54, 44, 10, 10);
        disp.init_rectangle(3, 54, 54, 10, 10);
        for (0..8) |column| {
            disp.init_char(column, 0, lcd.RED_COLOR, lcd.BLACK_COLOR);
            disp.init_char(column, 1, lcd.YELLOW_COLOR, lcd.BLACK_COLOR);
            disp.init_char(column, 2, lcd.GREEN_COLOR, lcd.BLACK_COLOR);
            disp.init_char(column, 3, lcd.RED_COLOR, lcd.BLACK_COLOR);
            disp.init_char(column, 4, lcd.GREEN_COLOR, lcd.BLACK_COLOR);
            disp.init_char(column, 5, lcd.RED_COLOR, lcd.BLACK_COLOR);
            disp.init_char(column, 6, lcd.YELLOW_COLOR, lcd.BLACK_COLOR);
            disp.init_char(column, 7, lcd.GREEN_COLOR, lcd.BLACK_COLOR);
        }
        for (0..3) |row| {
            for (0..8) |col| {
                disp.set_char(col, row, '0');
            }
        }
        disp.set_char(0, 3, 'L');
        disp.set_char(2, 3, '.');
        disp.set_char(4, 3, 'V');
        disp.set_char(0, 4, 'H');
        disp.set_char(2, 4, '.');
        disp.set_char(4, 4, 'V');
        disp.set_char(0, 5, 'L');
        disp.set_char(3, 5, '%');
        disp.set_char(0, 6, 'Z');
        disp.set_char(3, 6, '%');
        disp.set_char(0, 7, 'H');
        disp.set_char(3, 7, '%');
    }
};
