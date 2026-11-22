const RTWDOG_BASE = 0x400BC000;

const UNLOCK_KEY1 = 0xC520;
const UNLOCK_KEY2 = 0xD928;

pub const RtwdogClk = enum(u2) {
    bus = 0,
    lpo = 1,
    intclk = 2,
    erclk = 3,
};

pub const RtwdogCs = bitpack struct(u32) {
    stop: bool = false,
    wait: bool = false,
    dbg: bool = false,
    tst: u2 = 0,
    update: bool = false,
    int: bool = false,
    en: bool = true,
    clk: RtwdogClk = .lpo,
    rcs: bool = false,
    ulk: bool = true,
    pres: bool = false,
    cmd32en: bool = true,
    flg: bool = false,
    win: bool = false,
    reserved0: u16 = 0,
};

pub const RtwdogCnt = bitpack struct(u32) {
    low: u8 = 0,
    high: u8 = 0,
    reserved0: u16 = 0,
};

pub const Rtwdog = extern struct {
    cs: RtwdogCs,
    cnt: u32,
    toval: u32,
    win: u32,

    pub inline fn unlock(self: *volatile Rtwdog) void {
        self.cnt = UNLOCK_KEY1;
        self.cnt = UNLOCK_KEY2;
    }

    pub fn disable(self: *volatile Rtwdog) void {
        self.unlock();
        self.cs.en = false;
    }
};

pub const rtwdog: *volatile Rtwdog = @ptrFromInt(RTWDOG_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x10, @sizeOf(Rtwdog));
}
