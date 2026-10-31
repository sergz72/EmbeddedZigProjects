const rcc = @import("rcc");

const RNG_BASE = 0x40023C00;

pub const RngCr = packed struct(u32) {
     reserved: u2 = 0,
     /// Random number generator enable
     rngen: bool = false,
     /// Interrupt enable
     ie: bool = false,
     reserved1: u28 = 0
};

pub const RngSr = packed struct(u32) {
        /// Data ready
        drdy: bool = false,
        /// Clock error current status
        cecs: bool = false,
        /// Seed error current status
        secs: bool = false,
        reserved: u2 = 0,
        /// Clock error interrupt status (write 0 to clear)
        ceis: bool = false,
        /// Seed error interrupt status (write 0 to clear)
        seis: bool = false,
        reserved1: u25 = 0
};

pub const RngError = error{
    ClockError,
    SeedError,
};

pub const Rng = extern struct {
    cr: RngCr,
    sr: RngSr,
    dr: u32,

    pub fn enable(self: *volatile Rng) void {
        self.cr.rngen = true;
    }

    pub fn disable(self: *volatile Rng) void {
        self.cr.rngen = false;
    }

    pub fn init(self: *volatile Rng) void {
        rcc.rcc.ahbpcenr.rngen = true;
        self.disable();
        self.sr = RngSr{};
        self.enable();
    }

    pub fn generate(self: *volatile Rng, data: []u32) RngError!void {
        for (data) |*d| {
            while (!self.sr.drdy) {
                if (self.sr.cecs) return RngError.ClockError;
                if (self.sr.secs) return RngError.SeedError;
            }
            d.* = self.dr;
        }
    }
};

pub const rng: *volatile Rng = @ptrFromInt(RNG_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0xC0, @sizeOf(Rng));
}
