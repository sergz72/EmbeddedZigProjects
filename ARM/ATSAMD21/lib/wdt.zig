const WDT_BASE = 0x40001000;

const WDT_CLEAR = 0xA5;
const WDT_CLOCK_FREQUENCY = 1024;

pub const WdtCtrl = bitpack struct(u8) {
    reserved: u1 = 0,
    enable: bool,
    wen: bool,
    reserved2: u4 = 0,
    alwayson: bool
};

pub const WdtPer = enum(u4) {
    cyc8 = 0,
    cyc16 = 1,
    cyc32 = 2,
    cyc64 = 3,
    cyc128 = 4,
    cyc256 = 5,
    cyc512 = 6,
    cyc1024 = 7,
    cyc2048 = 8,
    cyc4096 = 9,
    cyc8192 = 10,
    cyc16384 = 11
};

pub const WdtEwOffset = enum(u8) {
    cyc8 = 0,
    cyc16 = 1,
    cyc32 = 2,
    cyc64 = 3,
    cyc128 = 4,
    cyc256 = 5,
    cyc512 = 6,
    cyc1024 = 7,
    cyc2048 = 8,
    cyc4096 = 9,
    cyc8192 = 10,
    cyc16384 = 11
};

pub const WdtConfig = bitpack struct(u8) {
    per: WdtPer,
    window: WdtPer
};

pub const WdtStatus = bitpack struct(u8) {
    reserved0: u7,
    syncbusy: bool,
};

pub const Wdt = extern struct {
    ctrl: WdtCtrl,
    config: WdtConfig,
    ewctrl: WdtEwOffset,
    reserved1: u8,
    intenclr: u8,
    intenset: u8,
    intflag: u8,
    status: WdtStatus,
    clear: u8,
};

pub fn reset() void {
    wdt.clear = WDT_CLEAR;
}

pub fn init(period_ms: usize) void {
    const div = period_ms * WDT_CLOCK_FREQUENCY / 1000;
    const per: WdtPer = switch (div) {
        0...8 => WdtPer.cyc8,
        9...16 => WdtPer.cyc16,
        17...32 => WdtPer.cyc32,
        33...64 => WdtPer.cyc64,
        65...128 => WdtPer.cyc128,
        129...256 => WdtPer.cyc256,
        257...512 => WdtPer.cyc512,
        513...1024 => WdtPer.cyc1024,
        1025...2048 => WdtPer.cyc2048,
        2049...4096 => WdtPer.cyc4096,
        4097...8192 => WdtPer.cyc8192,
        else => WdtPer.cyc16384
    };
    wdt.config = WdtConfig{ .per = per, .window = per };
    while (wdt.status.syncbusy) {
        asm volatile ("nop");
    }
    wdt.ctrl.enable = true;
    while (wdt.status.syncbusy) {
        asm volatile ("nop");
    }
}

pub const wdt: *volatile Wdt = @ptrFromInt(WDT_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(9, @sizeOf(Wdt));
}
