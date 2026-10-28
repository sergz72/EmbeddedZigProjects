const cpu = @import("cpu");

const FWDGT_BASE: usize = 0x40003000;

pub const FwdgtCommand = enum(u32) {
    reload_counter = 0xAAAA,
    unlock = 0x5555,
    start = 0xCCCC
};

pub const FwdgtPsc = enum(u32) {
    div4 = 0,
    div8 = 1,
    div16 = 2,
    div32 = 3,
    div64 = 4,
    div128 = 5,
    div256 = 6
};

pub const FwdgtStat = packed struct(u32) {
    pud: bool,
    rud: bool,
    wud: bool,
    reserved: u29
};

pub const Fwdgt = extern struct {
    cmd: FwdgtCommand,
    psc: FwdgtPsc,
    rld: u32,
    stat: FwdgtStat,
    wnd: u32,

    pub fn init(self: *volatile Fwdgt, interval_ms: usize) bool {
        const rld = interval_ms * 1000 / (128000000/cpu.IRC40K_FREQUENCY);
        if (rld == 0 or rld > 4095) {
            return false;
        }
        self.cmd = FwdgtCommand.unlock;
        self.psc = .div128;
        self.rld = @truncate(rld);
        self.cmd = FwdgtCommand.start;
        return true;
    }

    pub fn reload(self: *volatile Fwdgt) void {
        self.cmd = FwdgtCommand.reload_counter;
    }
};

pub const fwdgt: *volatile Fwdgt = @ptrFromInt(FWDGT_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x14, @sizeOf(Fwdgt));
}
