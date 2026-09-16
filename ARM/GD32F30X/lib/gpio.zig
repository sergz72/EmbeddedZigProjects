const GPIOA_BASE: usize = 0x40010800;
const GPIOB_BASE: usize = 0x40010C00;
const GPIOC_BASE: usize = 0x40011000;
const GPIOD_BASE: usize = 0x40011400;
const GPIOE_BASE: usize = 0x40011800;
const GPIOF_BASE: usize = 0x40011C00;
const GPIOG_BASE: usize = 0x40012000;

pub const GpioModeInput: u32 = 0;
pub const GpioModeOutputMidSpeed: u32 = 1;
pub const GpioModeOutputSlowSpeed: u32 = 2;
pub const GpioModeOutputFastSpeed: u32 = 3;

pub const GpioCnfInputAnalog: u32 = 0;
pub const GpioCnfInputFloating: u32 = 4;
pub const GpioCnfInputPullupPulldown: u32 = 8;
pub const GpioCnfOutputPushPull: u32 = 0;
pub const GpioCnfOutputOpenDrain: u32 = 4;
pub const GpioCnfAlternatePushPull: u32 = 8;
pub const GpioCnfAlternateOpenDrain: u32 = 12;

pub const Gpio = extern struct {
    ctl: [2]u32,
    istat: u32,
    octl: u32,
    bop: u32,
    bc: u32,
    lock: u32,

    fn init(self: *volatile Gpio, pins: u8, mode_and_speed: u32, index: usize) void {
        if (pins == 0)
            return;
        var pin_mask = pins;
        var cfgr_mask: u32 = 0x0F;
        var cfgr = self.ctl[index];
        var shift: u5 = 0;
        while (pin_mask != 0) {
            if (pin_mask & 1 != 0) {
                cfgr &= ~cfgr_mask;
                cfgr |= mode_and_speed << shift;
            }
            pin_mask >>= 1;
            if (pin_mask == 0)
                break;
            cfgr_mask <<= 4;
            shift += 4;
        }
        self.ctl[index] = cfgr;
    }

    pub fn Init(self: *volatile Gpio, pins: u16, mode_and_speed: u32) void {
        self.init(@truncate(pins), mode_and_speed, 0);
        self.init(@truncate(pins >> 8), mode_and_speed, 1);
    }
};

pub const gpioa: *volatile Gpio = @ptrFromInt(GPIOA_BASE);
pub const gpiob: *volatile Gpio = @ptrFromInt(GPIOB_BASE);
pub const gpioc: *volatile Gpio = @ptrFromInt(GPIOC_BASE);
pub const gpiod: *volatile Gpio = @ptrFromInt(GPIOD_BASE);
pub const gpioe: *volatile Gpio = @ptrFromInt(GPIOE_BASE);
pub const gpiof: *volatile Gpio = @ptrFromInt(GPIOF_BASE);
pub const gpiog: *volatile Gpio = @ptrFromInt(GPIOG_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x1C, @sizeOf(Gpio));
}
