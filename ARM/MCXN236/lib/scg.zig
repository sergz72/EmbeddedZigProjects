const syscon = @import("syscon");

const SCG0_BASE = 0x40044000;

const PLL_VCO_MIN_FREQUENCY = 275000000;
const PLL_VCO_MAX_FREQUENCY = 550000000;
const PLL_IN_MIN_FREQUENCY = 5000000;
const PLL_IN_MAX_FREQUENCY = 50000000;

pub const Param = packed struct(u32) {
    reserved0: u1,
    soscclkpres: bool,
    sircclkpres: bool,
    fircclkpres: bool,
    roscclkpres: bool,
    apllclkpres: bool,
    spllclkpres: bool,
    upllclkpres: bool,
    troclkpres: bool,
    reserved1: u23
};

pub const TrimLock = packed struct(u32) {
    trim_unlock: bool = false,
    ifr_disable: bool = false,
    reserved0: u14 = 0,
    trim_lock_key: u16 = 0,
};

pub const Scs = enum(u4) {
    sosc = 1,
    sirc = 2,
    firc = 3,
    rosc = 4,
    apll = 5,
    spll = 6,
    upll = 7,
};

pub const Csr = packed struct(u32) {
    reserved0: u24 = 0,
    scs: Scs = .firc,
    reserved1: u4 = 0,
};

pub const Sosccsr = packed struct(u32) {
    soscen: bool = false,
    soscsten: bool = false,
    reserved0: u14 = 0,
    sosccm: bool = false,
    sosccmre: bool = false,
    reserved1: u5 = 0,
    lk: bool = false,
    soscvld: bool = false,
    soscsel: bool = false,
    soscerr: bool = false,
    reserved2: u3 = 0,
    soscvld_ie: bool = false,
    reserved3: u1 = 0,
};

pub const Range = enum(u2) {
    _16to20mhz = 0,
    _20to30mhz = 1,
    _30to50mhz = 2,
    _50to66mhz = 3
};

pub const Sosccfg = packed struct(u32) {
    reserved0: u2 = 0,
    erefs: bool = false,
    reserved1: u1 = 0,
    range: Range = ._16to20mhz,
    reserved2: u26 = 0,
};

pub const Sirccsr = packed struct(u32) {
    reserved0: u1 = 0,
    sircsten: bool = false,
    reserved1: u3 = 1,
    sirc_clk_periph_en: bool = true,
    reserved2: u2 = 0,
    sirctren: bool = false,
    sirctrup: bool = false,
    trim_lock: bool = false,
    coarse_trim_bypass: bool = false,
    reserved3: u11 = 2,
    lk: bool = false,
    sircvld: bool = true,
    sircsel: bool = false,
    sircerr: bool = false,
    sircerr_ie: bool = false,
    reserved4: u4 = 0,
};

pub const Trimsrc = enum(u2) {
    reserved = 0,
    sosc = 2,
    rosc = 3,
};

pub const Sirctcfg = packed struct(u32) {
    trimsrc: Trimsrc = .reserved,
    reserved0: u14 = 0,
    trimdiv: u7 = 0,
    reserved1: u9 = 0,
};

pub const Sirctrim = packed struct(u32) {
    ccotrim: u6 = 0,
    reserved0: u2 = 0,
    cltrim: u6 = 0,
    reserved1: u2 = 0,
    tctrim: u5 = 0,
    reserved2: u3 = 0,
    fvchtrim: u5 = 0,
    reserved3: u3 = 0,
};

pub const Sircstat = packed struct(u32) {
    ccotrim: u6 = 0,
    reserved0: u2 = 0,
    cltrim: u6 = 0,
    reserved1: u18 = 0,
};

pub const Firccsr = packed struct(u32) {
    fircen: bool = true,
    fircsten: bool = false,
    reserved0: u2 = 3,
    firc_sclk_periph_en: bool = true,
    firc_fclk_periph_en: bool = true,
    reserved1: u2 = 0,
    firctren: bool = false,
    firctrup: bool = false,
    trim_lock: bool = false,
    coarse_trim_bypass: bool = false,
    reserved2: u11 = 6,
    lk: bool = false,
    fircvld: bool = true,
    fircsel: bool = true,
    fircerr: bool = false,
    fircerr_ie: bool = false,
    reserved3: u2 = 0,
    fircacc_ie: bool = false,
    fircacc: bool = false,
};

pub const Firccfg = packed struct(u32) {
    range: bool = false,
    reserved0: u31 = 0,
};

pub const Firctcfg = packed struct(u32) {
    trimsrc: Trimsrc = .reserved,
    reserved0: u14 = 0,
    trimdiv: u7 = 0,
    reserved1: u9 = 0,
};

pub const Firctrim = packed struct(u32) {
    trimfine: u8 = 0,
    trimcoar: u6 = 0,
    reserved0: u2 = 0,
    trimtemp: u2 = 0,
    reserved1: u6 = 0,
    trimstart: u6 = 0,
    reserved2: u2 = 0,
};

pub const Fircstat = packed struct(u32) {
    trimfine: u8 = 0,
    trimcoar: u6 = 0,
    reserved0: u18 = 0,
};

pub const Rosccsr = packed struct(u32) {
    reserved0: u16 = 0,
    rosccm: bool = false,
    rosccmre: bool = false,
    reserved1: u5 = 0,
    lk: bool = false,
    roscvld: bool = false,
    roscsel: bool = false,
    roscerr: bool = false,
    reserved2: u5 = 0,
};

pub const Pllcsr = packed struct(u32) {
    pwren: bool = false,
    clken: bool = false,
    sten: bool = false,
    frm_clockstable: bool = false,
    reserved0: u12 = 0,
    cm: bool = false,
    cmre: bool = false,
    reserved1: u5 = 0,
    lk: bool = false,
    lock: bool = false,
    sel: bool = false,
    err: bool = false,
    reserved2: u3 = 0,
    lock_ie: bool = false,
    reserved3: u1 = 0,
};

pub const Source = enum(u2) {
    sosc = 0,
    firc = 1,
    no_clock = 3,
};

pub const Pllctrl = packed struct(u32) {
    selr: u4 = 0,
    seli: u6 = 0,
    selp: u5 = 0,
    reserved0: u1 = 0,
    bypasspostdiv2: bool = false,
    limupoff: bool = false,
    banddirect: bool = false,
    bypassprediv: bool = false,
    bypasspostdiv: bool = false,
    reserved1: u1 = 0,
    frm: bool = false,
    reserved2: u2 = 0,
    source: Source = .sosc,
    reserved3: u5 = 0,
};

pub const Pllstat = packed struct(u32) {
    reserved0: u1,
    ndivack: bool,
    mdivack: bool,
    pdivack: bool,
    frmdet: bool,
    reserved1: u27,
};

pub const Pllndiv = packed struct(u32) {
    ndiv: u8 = 1,
    reserved0: u23 = 0,
    nreq: bool = false,
};

pub const Pllmdiv = packed struct(u32) {
    mdiv: u16 = 1,
    reserved0: u15 = 0,
    mreq: bool = false,
};

pub const Pllpdiv = packed struct(u32) {
    pdiv: u5 = 1,
    reserved0: u26 = 0,
    preq: bool = false,
};

pub const PlllockCnfg = packed struct(u32) {
    lock_time: u17 = 20300,
    reserved0: u15 = 0,
};

pub const Pllsscgstat = packed struct(u32) {
    ss_mdiv_ack: bool,
    reserved0: u31,
};

pub const Mc = enum(u2) {
    no_comp = 0,
    max_comp = 3,
};

pub const Pllsscg1 = packed struct(u32) {
    ss_mdiv_msb: bool = false,
    ss_mdiv_req: bool = false,
    mf: u3 = 0,
    mr: u3 = 0,
    mc: Mc = .no_comp,
    dither: bool = false,
    sel_ss_mdiv: bool = false,
    reserved0: u19 = 1,
    ss_pd: bool = true,
};

pub const PllOvrd = packed struct(u32) {
    pwren_ovrd: bool = false,
    clken_ovrd: bool = false,
    reserved0: u29 = 0,
    ovrd_en: bool = false,
};

pub const Upllcsr = packed struct(u32) {
    reserved0: u16 = 0,
    upllcm: bool = false,
    upllcmre: bool = false,
    reserved1: u5 = 0,
    lk: bool = false,
    upllvld: bool = false,
    upllsel: bool = false,
    upllerr: bool = false,
    reserved2: u3 = 0,
    upllvor: bool = false,
    upllvore: bool = false,
};

pub const VoutSel = enum(u3) {
    _1v = 0,
    _1v05 = 3,
    _1v1 = 4,
    _1v15 = 5,
    _1v2 = 6,
    _1v25 = 7,
};

pub const Ldocsr = packed struct(u32) {
    ldoen: bool = false,
    vout_sel: VoutSel = ._1v1,
    ldobypass: bool = false,
    reserved0: u26 = 0,
    vout_ok: bool = false,
};

pub const Pll = extern struct {
    csr: Pllcsr,
    ctrl: Pllctrl,
    stat: Pllstat,
    ndiv: Pllndiv,
    mdiv: Pllmdiv,
    pdiv: Pllpdiv,
    lock_cnfg: PlllockCnfg,
    reserved11: u32,
    sscgstat: Pllsscgstat,
    sscg0: u32,
    sscg1: Pllsscg1,
    reserved12: [50]u32,
    ovrd: PllOvrd,
    reserved13: [2]u32
};

pub const Scg = extern struct {
    verid: u32,
    param: Param,
    trim_lock: TrimLock,
    reserved0: u32,
    csr: Csr,
    rccr: Csr,
    reserved1: [58]u32,
    sosccsr: Sosccsr,
    reserved2: u32,
    sosccfg: Sosccfg,
    reserved3: [61]u32,
    sirccsr: Sirccsr,
    reserved4: [2]u32,
    sirctcfg: Sirctcfg,
    sirctrim: Sirctrim,
    reserved5: u32,
    sircstat: Sircstat,
    reserved6: [57]u32,
    firccsr: Firccsr,
    reserved7: u32,
    firccfg: Firccfg,
    firctcfg: Firctcfg,
    firctrim: Firctrim,
    reserved8: u32,
    fircstat: Fircstat,
    reserved9: [57]u32,
    rosccsr: Rosccsr,
    reserved10: [63]u32,
    pll: [2]Pll,
    upllcsr: Upllcsr,
    reserved17: [63]u32,
    ldocsr: Ldocsr,

    pub fn enable() void {
        syscon.syscon0.ahbclkctrlset2 = syscon.Ahbclkctrl2{.scg = true};
    }

    pub fn enableXosc(self: *volatile Scg, frequency: usize) void {
        if (frequency <= 20000000) {
            self.sosccfg = Sosccfg{
                .erefs = true,
                .range = ._16to20mhz
            };
        } else if (frequency <= 30000000) {
            self.sosccfg = Sosccfg{
                .erefs = true,
                .range = ._20to30mhz
            };
        } else if (frequency <= 50000000) {
            self.sosccfg = Sosccfg{
                .erefs = true,
                .range = ._30to50mhz
            };
        } else {
            self.sosccfg = Sosccfg{
                .erefs = true,
                .range = ._50to66mhz
            };
        }
        self.sosccsr = Sosccsr{
            .soscen = true,
        };
        while (!self.sosccsr.soscvld) {
            asm volatile ("nop");
        }
    }

    pub fn switchMainClockTo(self: *volatile Scg, source: Scs) void {
        self.rccr = Csr{
            .scs = source
        };
        while (self.csr.scs != source) {
            asm volatile ("nop");
        }
    }

    pub fn pllInit(self: *volatile Scg, pll1: bool, source: Source, source_frequency: usize, output_frequency: usize) bool {
        const fi = source_frequency / 2;
        var m: usize = PLL_VCO_MIN_FREQUENCY / fi;
        if (PLL_VCO_MIN_FREQUENCY % fi != 0) {
            m += 1;
        }
        var f: usize = fi * m;
        while (f <= PLL_VCO_MAX_FREQUENCY) : (f += fi) {
            if (f % output_frequency == 0 and (f / output_frequency) & 1 == 0) {
                const pll = if (pll1) &self.pll[1] else &self.pll[0];
                const selp = m / 4 + 1;
                const seli = 2 * (m / 4) + 3;
                pll.ctrl = Pllctrl{.source = source, .seli = @truncate(seli), .selp = @truncate(selp)};
                pll.ndiv = Pllndiv{.ndiv = 2};
                pll.mdiv = Pllmdiv{.mdiv = @truncate(m)};
                pll.pdiv = Pllpdiv{.pdiv = @truncate(f / output_frequency / 2)};
                self.trim_lock = TrimLock{.trim_unlock = true, .ifr_disable = false, .trim_lock_key = 0x5A5A};
                pll.lock_cnfg = PlllockCnfg{.lock_time = @truncate(fi / 2000 + 300)};
                pll.csr = Pllcsr{
                    .pwren = true,
                    .clken = true
                };
                while (!pll.csr.lock) {
                    asm volatile ("nop");
                }
                return true;
            }
            m += 1;
        }
        return false;
    }
};

pub const scg0: *volatile Scg = @ptrFromInt(SCG0_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x804, @sizeOf(Scg));
}
