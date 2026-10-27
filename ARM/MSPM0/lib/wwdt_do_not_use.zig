// works incorrectly!!!

const builtin = @import("builtin");
const common = @import("common");
//const common = if (builtin.is_test) @import("common.zig") else @import("common");

const WWDT0_BASE: usize = 0x40080000 + 0x800;
const WWDT1_BASE: usize = 0x40082000 + 0x800;

const WWDT_RESTART = 0xA7;

pub const WwdtInt = extern struct {
    iidx: u32,
    reserved0: u32,
    imask: u32,
    reserved1: u32,
    ris: u32,
    reserved2: u32,
    mis: u32,
    reserved3: u32,
    iset: u32,
    reserved4: u32,
    iclr: u32,
};

pub const WwdtGprcm = extern struct {
    pwren: common.GprcmPwren,
    rstctl: common.GprcmRstctl,
    reserved0: [3]u32,
    stat: u32,
};

pub const WwdtEvtMode = packed struct(u32) {
    int0_cfg: common.EvtCfg = .software_mode,
    reserved: u30 = 0
};

pub const WwdtClkdiv = enum(u3) {
    div1 = 0,
    div2 = 1,
    div3 = 2,
    div4 = 3,
    div5 = 4,
    div6 = 5,
    div7 = 6,
    div8 = 7
};

pub const WwdtPer = enum(u3) {
    _2pow25 = 0,
    _2pow21 = 1,
    _2pow18 = 2,
    _2pow15 = 3,
    _2pow12 = 4,
    _2pow10 = 5,
    _2pow8 = 6,
    _2pow6 = 7
};

pub const WwdtWindow = enum(u3) {
    no_closed = 0,
    _12p5closed = 1,
    _18p75closed = 2,
    _25closed = 3,
    _50closed = 4,
    _75closed = 5,
    _81p25closed = 6,
    _87p5closed = 7
};

pub const WwdtCtl0 = packed struct(u32) {
    clkdiv: WwdtClkdiv = .div4,
    reserved: u1 = 0,
    per: WwdtPer = ._2pow12,
    reserved2: u1 = 0,
    window0: WwdtWindow = .no_closed,
    reserved3: u1 = 0,
    window1: WwdtWindow = .no_closed,
    reserved4: u1 = 0,
    mode: bool = false,
    stism: bool = false,
    reserved5: u6 = 0,
    key: u8 = 0xC9
};

pub const Wwdt = extern struct {
    gprcm: WwdtGprcm,
    reserved1: [512]u32,
    pdbgctl: u32,
    reserved2: u32,
    cpu_int: WwdtInt,
    reserved3: [37]u32,
    evt_mode: WwdtEvtMode,
    reserved4: [6]u32,
    desc: u32,
    wwdtctl0: WwdtCtl0,
    wwdtctl1: u32,
    wwdtcntrst: u32,
    wwdtstat: u32,

    pub inline fn enablePower(self: *volatile Wwdt) void {
        const v = common.GprcmPwren{.enable = true};
        self.gprcm.pwren = v;
    }

    pub inline fn reset(self: *volatile Wwdt) void {
        const v = common.GprcmRstctl{.resetassert = true, .resetstkyclr = true};
        self.gprcm.rstctl = v;
    }

    pub inline fn restart(self: *volatile Wwdt) void {
        self.wwdtcntrst = WWDT_RESTART;
    }

    pub fn initWithPeriod(self: *volatile Wwdt, period_ms: usize) bool {
        var div = period_ms * 32768 / 64000;
        var per: WwdtPer = ._2pow6;
        while (div > 8) {
            switch (per) {
                ._2pow6 => {div /= 4; per = ._2pow8;},
                ._2pow8 => {div /= 4; per = ._2pow10;},
                ._2pow10 => {div /= 4; per = ._2pow12;},
                ._2pow12 => {div /= 8; per = ._2pow15;},
                ._2pow15 => {div /= 8; per = ._2pow18;},
                ._2pow18 => {div /= 8; per = ._2pow21;},
                ._2pow21 => {div /= 16; per = ._2pow25;},
                ._2pow25 => break,
            }
        }
        if (div > 8) {
            return false;
        }
        if (div == 0) {
            div = 1;
        }
        const d: u3 = @truncate(div - 1);
        self.wwdtctl0 = WwdtCtl0{.clkdiv = @bitCast(d), .per = per, .window0 = ._50closed};
        self.wwdtctl1 = 0; // window 0 is active
        return true;
    }
};

pub const wwdt0: *volatile Wwdt = @ptrFromInt(WWDT0_BASE);
pub const wwdt1: *volatile Wwdt = @ptrFromInt(WWDT1_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x1110-0x800, @sizeOf(Wwdt));
}
