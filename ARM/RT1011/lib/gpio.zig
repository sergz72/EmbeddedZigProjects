const GPIO1_BASE = 0x401B8000;
const GPIO2_BASE = 0x42000000;
const GPIO5_BASE = 0x400C0000;

pub const GpioIcr = enum(u2) {
    low_level = 0,
    high_level = 1,
    rising_edge = 2,
    falling_edge = 3,
};

pub const GpioIcr1 = bitpack struct(u32) {
    icr0: GpioIcr = .low_level,
    icr1: GpioIcr = .low_level,
    icr2: GpioIcr = .low_level,
    icr3: GpioIcr = .low_level,
    icr4: GpioIcr = .low_level,
    icr5: GpioIcr = .low_level,
    icr6: GpioIcr = .low_level,
    icr7: GpioIcr = .low_level,
    icr8: GpioIcr = .low_level,
    icr9: GpioIcr = .low_level,
    icr10: GpioIcr = .low_level,
    icr11: GpioIcr = .low_level,
    icr12: GpioIcr = .low_level,
    icr13: GpioIcr = .low_level,
    icr14: GpioIcr = .low_level,
    icr15: GpioIcr = .low_level,
};

pub const GpioIcr2 = bitpack struct(u32) {
    icr16: GpioIcr = .low_level,
    icr17: GpioIcr = .low_level,
    icr18: GpioIcr = .low_level,
    icr19: GpioIcr = .low_level,
    icr20: GpioIcr = .low_level,
    icr21: GpioIcr = .low_level,
    icr22: GpioIcr = .low_level,
    icr23: GpioIcr = .low_level,
    icr24: GpioIcr = .low_level,
    icr25: GpioIcr = .low_level,
    icr26: GpioIcr = .low_level,
    icr27: GpioIcr = .low_level,
    icr28: GpioIcr = .low_level,
    icr29: GpioIcr = .low_level,
    icr30: GpioIcr = .low_level,
    icr31: GpioIcr = .low_level,
};

pub const Gpio = extern struct {
    dr: u32,
    gdir: u32,
    psr: u32,
    icr1: GpioIcr1,
    icr2: GpioIcr2,
    imr: u32,
    isr: u32,
    sel: u32,
    reserved0: [25]u32,
    set: u32,
    clear: u32,
    toggle: u32,
};

pub const gpio1: *volatile Gpio = @ptrFromInt(GPIO1_BASE);
pub const gpio2: *volatile Gpio = @ptrFromInt(GPIO2_BASE);
pub const gpio5: *volatile Gpio = @ptrFromInt(GPIO5_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x90, @sizeOf(Gpio));
}
