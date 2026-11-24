const RSTC_BASE = 0x40000C00;

pub const RstcRcause = bitpack struct(u8) {
    por: bool,
    bod12: bool,
    bod33: bool,
    nvm: bool,
    ext: bool,
    wdt: bool,
    syst: bool,
    backup: bool,
};

pub const RstcBkupexit = bitpack struct(u8) {
    reserved0: u1,
    rtc: bool,
    bbps: bool,
    reserved1: u4,
    hib: bool,
};

pub const Rstc = extern struct {
    rcause: RstcRcause,
    reserved0: u8,
    bkupexit: RstcBkupexit,
};

pub fn getResetCause() []const u8 {
    const cause = rstc.rcause;
    if (cause.por) return "Power-on Reset";
    if (cause.bod12) return "Brown-out 1.2V Reset";
    if (cause.bod33) return "Brown-out 3.3V Reset";
    if (cause.nvm) return "NVM Reset";
    if (cause.ext) return "External Reset";
    if (cause.wdt) return "Watchdog Timer Reset";
    if (cause.syst) return "System Reset";
    if (cause.backup) return "Backup Reset";
    return "Unknown Reset cause";
}

pub const rstc: *volatile Rstc = @ptrFromInt(RSTC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x3, @sizeOf(Rstc));
}
