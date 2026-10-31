const cpu = @import("cpu");

pub const IWDG_BASE = 0x40003000;

pub const IwdgCommand = enum(u16) {
    reload_counter = 0xAAAA,
    unlock = 0x5555,
    enable = 0xCCCC
};

pub const IwdgDiv = enum(u16) {
    div4 = 0,
    div8 = 1,
    div16 = 2,
    div32 = 3,
    div64 = 4,
    div128 = 5,
    div256 = 6
};

pub const IwdgStatr = packed struct(u16) {
    pvu: bool,
    rvu: bool,
    reserved1: u14
};

pub const Iwdg = extern struct {
    ctlr: IwdgCommand,
    reserved0: u16,
    pscr: IwdgDiv,
    reserved1: u16,
    rldr: u16,
    reserved2: u16,
    statr: IwdgStatr,

    pub fn init(self: *volatile Iwdg, interval_ms: usize) bool {
        const rld = interval_ms * 1000 / (128000000/cpu.LSI_FREQUENCY);
        if (rld == 0 or rld > 4095) {
            return false;
        }
        self.ctlr = IwdgCommand.unlock;
        self.pscr = .div128;
        self.rldr = @truncate(rld);
        self.ctlr = IwdgCommand.enable;
        return true;
    }

    pub fn reload(self: *volatile Iwdg) void {
        self.ctlr = IwdgCommand.reload_counter;
    }
};

pub const iwdg: *volatile Iwdg = @ptrFromInt(IWDG_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x0E, @sizeOf(Iwdg));
}
