const std = @import("std");
const system_timer = @import("system_timer");
const spi_lcd = @import("spi_lcd");

pub const BLACK_COLOR   : u16 = 0;
pub const BLUE_COLOR    : u16 = 0x1F00;
pub const RED_COLOR     : u16 = 0x00F8;
pub const GREEN_COLOR   : u16 = 0xE007;
pub const CYAN_COLOR    : u16 = 0xFF7F;
pub const MAGENTA_COLOR : u16 = 0x1FF8;
pub const YELLOW_COLOR  : u16 = 0xE0FF;
pub const WHITE_COLOR   : u16 = 0xFFFF;
pub const GRAY_COLOR    : u16 = 0x3084;

pub const SSD1357_MADCTL_XY_SWAP:  u8 = 1;
pub const SSD1357_MADCTL_X_MIRROR: u8 = 2;
pub const SSD1357_MADCTL_Y_MIRROR: u8 = 0x10;

const SSD1357_CMD_WRITERAM       : u8 = 0x5C;
const SSD1357_CMD_DISPLAYOFFSET  : u8 = 0xA2;     // Set display offset

const SSD1357_CMD_SETCOLUMN      : u8 = 0x15;     // Set column address
const SSD1357_CMD_SETROW         : u8 = 0x75;     // Set row adress
const SSD1357_CMD_SETREMAP       : u8 = 0xA0;     // Set re-map & data format
const SSD1357_CMD_STARTLINE      : u8 = 0xA1;     // Set display start line
const SSD1357_CMD_DISPLAYALLOFF  : u8 = 0xA4;     // Set entire display OFF
const SSD1357_CMD_DISPLAYALLON   : u8 = 0xA5;     // Set entire display ON
const SSD1357_CMD_NORMALDISPLAY  : u8 = 0xA6;     // Set display to normal mode
const SSD1357_CMD_INVERTDISPLAY  : u8 = 0xA7;     // Invert display
const SSD1357_CMD_DISPLAYOFF     : u8 = 0xAE;     // Display OFF (sleep mode)
const SSD1357_CMD_DISPLAYON      : u8 = 0xAF;     // Normal Brightness Display ON
const SSD1357_CMD_PRECHARGE      : u8 = 0xB1;     // Phase 1 and 2 period adjustment
const SSD1357_CMD_CLOCKDIV       : u8 = 0xB3;     // Set display clock divide ratio/oscillator frequency
const SSD1357_CMD_PRECHARGE2     : u8 = 0xB6;     // Set second precharge period
const SSD1357_CMD_MASTERTABLE    : u8 = 0xB8;     // Set master look up table for grayscale
const SSD1357_CMD_BUILTINLUT     : u8 = 0xB9;     // Use builtin linear LUT
const SSD1357_CMD_PRECHARGELEVEL : u8 = 0xBB;     // Set pre-charge voltage
const SSD1357_CMD_LUTTABLEA      : u8 = 0xBC;     // Set invividual lookup table for grayscale (color A)
const SSD1357_CMD_LUTTABLEC      : u8 = 0xBD;     // Set invividual lookup table for grayscale (color C)
const SSD1357_CMD_VCOMH          : u8 = 0xBE;     // Set Vcomh voltge
const SSD1357_CMD_CONTRASTABC    : u8 = 0xC1;     // Set contrast for colors A,B,C
const SSD1357_CMD_MASTERCURRENT  : u8 = 0xC7;     // Set master contrast current control
const SSD1357_CMD_SETMULTIPLEX   : u8 = 0xCA;     // Set multiplex ratio
const SSD1357_CMD_SETCOMMANDLOCK : u8 = 0xFD;

pub const LcdSSD1357 = struct {
    spi_lcd: spi_lcd.SpiLcd,
    reset_set: *const fn (bool) void,

    pub fn reset(self: *LcdSSD1357) void {
        self.reset_set(true);
        system_timer.delayus(5);
        self.reset_set(false);
        system_timer.delayus(5);
        self.reset_set(true);
        system_timer.delayus(300);
    }

    pub fn init(self: *LcdSSD1357, madctl: u8) !void {
        self.reset();
        self.spi_lcd.interface.cs_set(false);
        self.spi_lcd.send_command(SSD1357_CMD_SETMULTIPLEX);
        var data: [2]u8 = undefined;
        data[0] = 0x3f;
        self.spi_lcd.send_data(data[0..1]);
        self.spi_lcd.send_command(SSD1357_CMD_DISPLAYOFFSET);
        data[0] = if (madctl & SSD1357_MADCTL_Y_MIRROR != 0) 0x40 else 0;
        self.spi_lcd.send_data(data[0..1]);
        self.spi_lcd.send_command(SSD1357_CMD_SETREMAP);
        data[0] = madctl | 0x60;
        data[1] = 0;
        self.spi_lcd.send_data(&data);
        self.spi_lcd.send_command(SSD1357_CMD_DISPLAYON);
        self.spi_lcd.screen_fill(BLACK_COLOR);
    }

    pub fn set_window(ctx: *anyopaque, x1: u8, x2: u8, y1: u8, y2: u8) void {
        const self: *LcdSSD1357 = @ptrCast(@alignCast(ctx));

        self.spi_lcd.interface.cs_set(false);

        var data: [2]u8 = undefined;

        data[0] = x1 + 0x20;
        data[1] = x2 + 0x20;
        self.spi_lcd.send_command(SSD1357_CMD_SETCOLUMN);
        self.spi_lcd.send_data(&data);

        data[0] = y1;
        data[1] = y2;

        self.spi_lcd.send_command(SSD1357_CMD_SETROW);
        self.spi_lcd.send_data(&data);

        self.spi_lcd.send_command(SSD1357_CMD_WRITERAM);
    }
};
