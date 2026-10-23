pub const DEBUG_BASE = 0xE0042000;

pub const DebugCtrl = packed struct(u32) {
    sleep_debug: bool = false,
    deepsleep_debug: bool = false,
    standby_debug: bool = false,
    reserved1: u5 = 0,
    wdt_pause: bool = false,
    wwdt_pause: bool = false,
    tmr1_pause: bool = false,
    reserved2: u1 = 0,
    tmr3_pause: bool = false,
    reserved3: u1 = 0,
    ertc_pause: bool = false,
    i2c1_smbus_timeout: bool = false,
    i2c2_smbus_timeout: bool = false,
    reserved4: u2 = 0,
    tmr6_pause: bool = false,
    reserved5: u1 = 0,
    ertc_512_pause: bool = false,
    tmr15_pause: bool = false,
    tmr16_pause: bool = false,
    tmr17_pause: bool = false,
    reserved6: u2 = 0,
    tmr4_pause: bool = false,
    reserved7: u4 = 0
};

pub const DebugSerId = packed struct(u32) {
    rev_id: u3,
    reserved1: u5,
    ser_id: u8,
    reserved2: u16
};

pub const Debug = extern struct {
    pid: u32,
    ctrl: DebugCtrl,
    reserved1: [6]u32,
    ser_id: DebugSerId
};

pub const debug: *volatile Debug = @ptrFromInt(DEBUG_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x24, @sizeOf(Debug));
}
