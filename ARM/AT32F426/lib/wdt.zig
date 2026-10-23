pub const WDT_BASE = 0x40003000;

pub const WdtCommand = enum(u32) {
    reload_counter = 0xAAAA,
    unlock = 0x5555,
    enable = 0xCCCC
};

pub const WdtDiv = enum(u32) {
    div4 = 0,
    div8 = 1,
    div16 = 2,
    div32 = 3,
    div64 = 4,
    div128 = 5,
    div256 = 6
};

pub const WdtSts = packed struct(u32) {
    divf: bool,
    rldf: bool,
    reserved1: u30
};

pub const Wdt = extern struct {
    cmd: WdtCommand,
    div: WdtDiv,
    rld: u32,
    sts: WdtSts
};

pub const wdt: *volatile Wdt = @ptrFromInt(WDT_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x10, @sizeOf(Wdt));
}
