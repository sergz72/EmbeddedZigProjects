const cpu = @import("cpu");

const IWDG_BASE = 0x40003000;

pub const IwdgKey = enum(u32) {
    reload_counter = 0xAAAA,
    unlock = 0x5555,
    enable = 0xCCCC
};

pub const IwdgPr = enum(u32) {
    div4 = 0,
    div8 = 1,
    div16 = 2,
    div32 = 3,
    div64 = 4,
    div128 = 5,
    div256 = 6
};

pub const IwdgSr = bitpack struct(u32) {
    pvu: bool,
    rvu: bool,
    reserved0: u30,
};

pub const Iwdg = extern struct {
    kr: IwdgKey,
    pr: IwdgPr,
    rlr: u32,
    sr: IwdgSr,

    pub fn init(self: *volatile Iwdg, interval_ms: usize) bool {
        const rld = interval_ms * 1000 / (128000000/cpu.LSI_FREQUENCY);
        if (rld == 0 or rld > 4095) {
            return false;
        }
        self.kr = IwdgKey.unlock;
        self.pr = .div128;
        self.rlr = @truncate(rld);
        self.kr = IwdgKey.enable;
        return true;
    }

    pub fn reload(self: *volatile Iwdg) void {
        self.kr = IwdgKey.reload_counter;
    }
};

pub const iwdg: *volatile Iwdg = @ptrFromInt(IWDG_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x10, @sizeOf(Iwdg));
}
