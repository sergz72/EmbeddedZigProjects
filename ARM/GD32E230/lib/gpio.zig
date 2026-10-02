const GPIOA_BASE: usize = 0x48000000;
const GPIOB_BASE: usize = 0x48000400;
const GPIOC_BASE: usize = 0x48000800;
const GPIOF_BASE: usize = 0x48001400;

pub const GpioMode = enum(u2) {
    input = 0,
    output = 1,
    alternate = 2,
    analog = 3
};

pub const GpioOutputSpeed = enum(u2) {
    low = 0,
    mid = 1,
    high = 3
};

pub const GpioPud = enum(u2) {
    floating = 0,
    pullup = 1,
    pulldown = 2
};

pub const GpioInit = struct {
    mode: GpioMode,
    open_drain: bool = false,
    output_speed: GpioOutputSpeed,
    pud: GpioPud = .floating,
    alternate: u4 = 0
};

pub const Gpio = extern struct {
    ctl: u32,
    omode: u32,
    ospd: u32,
    pud: u32,
    istat: u32,
    octl: u32,
    bop: u32,
    lock: u32,
    afsel: [2]u32,
    bc: u32,
    tg: u32,

    pub fn init(self: *volatile Gpio, pins: u16, init_data: GpioInit) void {
        var pin_mask = pins;
        var mask4: u32 = 0x0F;
        var mask2: u32 = 3;
        var mask1: u32 = 1;
        var afsel_idx: usize = 0;
        var shift1: u5 = 0;
        var shift2: u5 = 0;
        var shift4: u5 = 0;
        var ctl = self.ctl;
        var omode = self.omode;
        var ospd = self.ospd;
        var pud = self.pud;
        var afsel = self.afsel;
        while (true) {
            if (pin_mask & 1 != 0) {
                ctl &= ~mask2;
                ctl |= @as(u32, @intFromEnum(init_data.mode)) << shift2;
                omode &= ~mask1;
                if (init_data.open_drain)
                    omode |=  @as(u32, 1) << shift1;
                ospd &= ~mask2;
                ospd |= @as(u32, @intFromEnum(init_data.output_speed)) << shift2;
                pud &= ~mask2;
                pud |= @as(u32, @intFromEnum(init_data.pud)) << shift2;
                afsel[afsel_idx] &= ~mask4;
                afsel[afsel_idx] |= @as(u32, init_data.alternate) << shift4;
            }
            pin_mask >>= 1;
            if (pin_mask == 0)
                break;
            if (shift4 == 28) {
                mask4 = 0x0F;
                shift4 = 0;
                afsel_idx += 1;
            } else {
                mask4 <<= 4;
                shift4 += 4;
            }
            mask2 <<= 2;
            mask1 <<= 1;
            shift1 += 1;
            shift2 += 2;
        }
        self.omode = omode;
        self.ospd = ospd;
        self.pud = pud;
        self.ctl = ctl;
    }
};

pub const gpioa: *volatile Gpio = @ptrFromInt(GPIOA_BASE);
pub const gpiob: *volatile Gpio = @ptrFromInt(GPIOB_BASE);
pub const gpioc: *volatile Gpio = @ptrFromInt(GPIOC_BASE);
pub const gpiof: *volatile Gpio = @ptrFromInt(GPIOF_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x30, @sizeOf(Gpio));
}
