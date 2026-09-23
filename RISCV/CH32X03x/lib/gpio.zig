const GPIOA_BASE: usize = 0x40010800;
const GPIOB_BASE: usize = 0x40010C00;
const GPIOC_BASE: usize = 0x40011000;

pub const GpioModeInput: u32 = 0;
pub const GpioModeOutput: u32 = 3;

pub const GpioCnfInputAnalog: u32 = 0;
pub const GpioCnfInputFloating: u32 = 4;
pub const GpioCnfInputPullupPulldown: u32 = 8;
pub const GpioCnfOutputPushPull: u32 = 0;
pub const GpioCnfAlternatePushPull: u32 = 8;

pub const Gpio = extern struct {
    cfgr: [2]u32,
    indr: u32,
    outdr: u32,
    bshr: u32,
    bcr: u32,
    lckr: u32,
    cfgxr: u32,
    bsxr: u32
};

pub const gpioa: *volatile Gpio = @ptrFromInt(GPIOA_BASE);
pub const gpiob: *volatile Gpio = @ptrFromInt(GPIOB_BASE);
pub const gpioc: *volatile Gpio = @ptrFromInt(GPIOC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x24, @sizeOf(Gpio));
}
