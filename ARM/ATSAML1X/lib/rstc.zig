const RSTC_BASE = 0x40000c00;

pub const RstcRcause = packed struct(u8) {
    por: bool,
    bod12: bool,
    bod33: bool,
    reserved: u1,
    ext: bool,
    wdt: bool,
    syst: bool,
    reserved2: u1
};

pub const Rstc = extern struct {
    rcause: RstcRcause,

    pub fn getResetCause(self: *volatile Rstc) []const u8 {
        const cause = self.rcause;
        if (cause.por) return "Power-on Reset";
        if (cause.bod12) return "Brown-out 1.2V Reset";
        if (cause.bod33) return "Brown-out 3.3V Reset";
        if (cause.ext) return "External Reset";
        if (cause.wdt) return "Watchdog Timer Reset";
        if (cause.syst) return "System Reset";
        return "Unknown Reset cause";
    }
};

pub const rstc: *volatile Rstc = @ptrFromInt(RSTC_BASE);
