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
    div256 = 6,
    div512 = 7,
    div1024 = 8
};

pub const IwdgSr = bitpack struct(u32) {
    pvu: bool,
    rvu: bool,
    wvu: bool,
    ewu: bool,
    reserved0: u4,
    onf: bool,
    reserved1: u5,
    ewif: bool,
    reserved2: u17
};

pub const IwdgEwcr = bitpack struct(u32) {
    ewit: u12 = 0,
    reserved0: u2 = 0,
    ewic: bool = false,
    ewie: bool = false,
    reserved1: u16 = 0,
};

pub const IwdgIcr = bitpack struct(u32) {
    reserbed: u15 = 0,
    ewic: bool = false,
    reserved: u16 = 0
};

pub const Iwdg = extern struct {
    kr: IwdgKey,
    pr: IwdgPr,
    rlr: u32,
    sr: IwdgSr,
    winr: u32,
    ewcr: IwdgEwcr,
    icr: IwdgIcr,

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
    try std.testing.expectEqual(0x1C, @sizeOf(Iwdg));

}
