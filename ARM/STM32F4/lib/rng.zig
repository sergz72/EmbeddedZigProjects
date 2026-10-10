const rcc = @import("rcc");

const RNG_BASE: usize = 0x50060800;

pub const RngCr = packed struct(u32) {
    reserved: u2 = 0,
    rngen: bool = false,
    ie: bool = false,
    reserved2: u28 = 0
};

pub const RngSr = packed struct(u32) {
    drdy: bool,
    cecs: bool,
    secs: bool,
    reserved: u2,
    ceis: bool,
    seis: bool,
    reserved2: u25
};

pub const Rng = extern struct {
    cr: RngCr,
    sr: RngSr,
    dr: u32,

    pub fn init(self: *volatile Rng) void {
        rcc.rcc.ahb2enr.rngen = true;
        self.cr.rngen = true;
    }

    pub fn generate(self: *volatile Rng, result: []u32) bool {
        for (result) |*value| {
            while (true) {
                while (!self.sr.drdy) {
                    if (self.sr.cecs)
                        return false;
                    if (self.sr.secs) {
                        self.cr.rngen = false;
                        self.cr.rngen = true;
                    }
                }
                if (self.sr.cecs)
                    return false;
                if (!self.sr.secs)
                    break;
                self.cr.rngen = false;
                self.cr.rngen = true;
            }
            value.* = self.dr;
        }
        return true;
    }
};

pub const rng: *volatile Rng = @ptrFromInt(RNG_BASE);
