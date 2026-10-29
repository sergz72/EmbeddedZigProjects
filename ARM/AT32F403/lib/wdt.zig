const cpu = @import("cpu");

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
    sts: WdtSts,

    pub fn init(self: *volatile Wdt, interval_ms: usize) bool {
        const rld = interval_ms * 1000 / (128000000/cpu.LICK_FREQUENCY);
        if (rld == 0 or rld > 4095) {
            return false;
        }
        self.cmd = WdtCommand.unlock;
        self.div = .div128;
        self.rld = @truncate(rld);
        self.cmd = WdtCommand.enable;
        return true;
    }

    pub fn reload(self: *volatile Wdt) void {
        self.cmd = WdtCommand.reload_counter;
    }
};

pub const wdt: *volatile Wdt = @ptrFromInt(WDT_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x10, @sizeOf(Wdt));
}
