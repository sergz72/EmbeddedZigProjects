const nvic = @import("nvic");

const WWDT0_BASE = 0x40016000;

pub const Mod = bitpack struct(u32) {
    wden: bool = false,
    wdreset: bool = false,
    wdtof: bool = false,
    wdint: bool = false,
    wdprotect: bool = false,
    lock: bool = false,
    debug_en: bool = false,
    reserved0: u25 = 0,
};

pub const Wwdt = extern struct {
    mod: Mod,
    tc: u32,
    feed: u32,
    tv: u32,
    reserved0: u32,
    warnint: u32,
    window: u32,
};

pub fn init(interval_ms: usize, wdt_clock: usize) bool {
    const tc = @as(u64, interval_ms) * @as(u64, wdt_clock) / 4000;
    if (tc < 256 or tc > 0xFFFFFF) return false;
    wwdt0.tc = @truncate(tc);
    wwdt0.mod = Mod{.wdreset = true, .wden = true};
    reload();
    return true;
}

pub fn reload() void {
    const primask = nvic.getPrimask();
    nvic.disableIrq();
    wwdt0.feed = 0xAA;
    wwdt0.feed = 0x55;
    nvic.setPrimask(primask);
}

pub const wwdt0: *volatile Wwdt = @ptrFromInt(WWDT0_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x1C, @sizeOf(Wwdt));
}
