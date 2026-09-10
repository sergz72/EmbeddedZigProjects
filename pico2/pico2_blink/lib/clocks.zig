const CLOCKS_BASE: u32 = 0x40010000;

pub const Clock = extern struct {
    ctrl: u32,
    div: u32,
    selected: u32
};

pub const Fc0 = extern struct {
    ref_khz: u32,
    min_khz: u32,
    max_khz: u32,
    delay: u32,
    interval: u32,
    src: u32,
    status: u32,
    result: u32
};

pub const Clocks = extern struct {
    gpout: [4]Clock,
    ref: Clock,
    sys: Clock,
    peri: Clock,
    hstx: Clock,
    usb: Clock,
    adc: Clock,
    dftclk_xosc_ctrl: u32,
    dftclk_rosc_ctrl: u32,
    dftclk_lposc_ctrl: u32,
    clk_sys_resus_ctrl: u32,
    clk_sys_resus_ststus: u32,
    fc0: Fc0,
    wake_en: [2]u32,
    slep_en: [2]u32,
    enabled: [2]u32,
    intr: u32,
    inte: u32,
    intf: u32,
    ints: u32
};

pub const clocks: *volatile Clocks = @ptrFromInt(CLOCKS_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0xD4, @sizeOf(Clocks));
}
