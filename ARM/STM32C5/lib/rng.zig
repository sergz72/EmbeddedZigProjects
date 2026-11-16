const rcc = @import("rcc");

const RNG_BASE = 0x420C0800;

pub const Clkdiv = enum(u4) {
    div1 = 0,
    div2 = 1,
    div4 = 2,
    div8 = 3,
    div16 = 4,
    div32 = 5,
    div64 = 6,
    div128 = 7,
    div256 = 8,
    div512 = 9,
    div1024 = 10,
    div2048 = 11,
    div4096 = 12,
    div8192 = 13,
    div16384 = 14,
    div32768 = 15
};

pub const RngCr = bitpack struct(u32) {
    reserved0: u2 = 0,
    rngen: bool = false,
    ie: bool = false,
    reserved1: u1 = 0,
    ced: bool = false,
    reserved2: u1 = 0,
    ardis: bool = false,
    rng_config3: u4 = 13,
    nistc: bool = false,
    rng_config2: u3 = 0,
    clkdiv: Clkdiv = .div1,
    rng_config1: u8 = 8,
    reserved3: u2 = 0,
    condrst: bool = false,
    configlock: bool = false,
};

pub const RngSr = bitpack struct(u32) {
    drdy: bool = false,
    cecs: bool = false,
    secs: bool = false,
    reserved0: u1 = 0,
    busy: bool = false,
    ceis: bool = false,
    seis: bool = false,
    reserved1: u25 = 0,
};

pub const RngNscr = bitpack struct(u32) {
    en_osc1: u3 = 7,
    en_osc2: u3 = 7,
    en_osc3: u3 = 7,
    reserved0: u23 = 0,
};

pub const RngHtsr0 = bitpack struct(u32) {
    rperrx: bool,
    rperr1: bool,
    rperr2: bool,
    rperr3: bool,
    rperr4: bool,
    rperr5: bool,
    rperr6: bool,
    rperr7: bool,
    rperr8: bool,
    rperr9: bool,
    reserved0: u22,
};

pub const RngHtsr1 = bitpack struct(u32) {
    aderrx: bool,
    aderr1: bool,
    aderr2: bool,
    aderr3: bool,
    aderr4: bool,
    aderr5: bool,
    aderr6: bool,
    aderr7: bool,
    aderr8: bool,
    aderr9: bool,
    reserved0: u22,
};

pub const RngNsmr = bitpack struct(u32) {
    mosc1: bool = true,
    mosc2: bool = true,
    mosc3: bool = true,
    mosc4: bool = true,
    mosc5: bool = true,
    mosc6: bool = true,
    mosc7: bool = true,
    mosc8: bool = true,
    mosc9: bool = true,
    reserved0: u23 = 0,
};

pub const Rng = extern struct {
    cr: RngCr,
    sr: RngSr,
    dr: u32,
    nscr: RngNscr,
    htcr0: u32,
    htcr1: u32,
    htcr2: u32,
    htcr3: u32,
    htsr0: RngHtsr0,
    htsr1: RngHtsr1,
    reserved0: [2]u32,
    nsmr: RngNsmr,

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

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x34, @sizeOf(Rng));
}
