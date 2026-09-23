const GPIOA_BASE: usize = 0x40010800;
const GPIOC_BASE: usize = 0x40011000;
const GPIOD_BASE: usize = 0x40011400;

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
    cfglr: u32,
    reserved: u32,
    indr: u32,
    outdr: u32,
    bshr: u32,
    bcr: u32,
    lckr: u32
};

pub const gpioa: *volatile Gpio = @ptrFromInt(GPIOA_BASE);
pub const gpioc: *volatile Gpio = @ptrFromInt(GPIOC_BASE);
pub const gpiod: *volatile Gpio = @ptrFromInt(GPIOD_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x1C, @sizeOf(Gpio));
}
