const RCU_BASE: usize = 0x40021000;

pub const RcuCtl0 = packed struct(u32) {
    irc8men: bool,
    irc8mstb: bool,
    reserved: u1,
    irc8madj: u5,
    irc8mcalib: u8,
    hxtalen: bool,
    hxtalstb: bool,
    hxtalbps: bool,
    ckmen: bool,
    reserved2: u4,
    pllen: bool,
    pllstb: bool,
    reserved3: u6
};

pub const RcuCfg0Sw = enum(u2) {
    irc8m = 0,
    hxtal = 1,
    pll = 2
};

pub const RcuCfgAhbPsc = enum(u4) {
    off = 0,
    div2 = 8,
    div4 = 9,
    div8 = 10,
    div16 = 11,
    div64 = 12,
    div128 = 13,
    div256 = 14,
    div512 = 15
};

pub const RcuCfgApbPsc = enum(u3) {
    off = 0,
    div2 = 4,
    div4 = 5,
    div8 = 6,
    div16 = 7
};

pub const RcuCfgCkout = enum(u3) {
    off = 0,
    rc28m = 1,
    rc40k = 2,
    lxtal = 3,
    sysclk = 4,
    irc8m = 5,
    hxtal = 6,
    plldiv2 = 7
};

pub const RcuCfg0 = packed struct(u32) {
    scs: RcuCfg0Sw = RcuCfg0Sw.irc8m,
    scss: RcuCfg0Sw = RcuCfg0Sw.irc8m,
    ahbpsc: RcuCfgAhbPsc = RcuCfgAhbPsc.off,
    apb1psc: RcuCfgApbPsc = RcuCfgApbPsc.off,
    apb2psc: RcuCfgApbPsc = RcuCfgApbPsc.off,
    adcpsc: u2 = 0,
    pllsel: bool  = false,
    pllpredv: bool = false,
    pllmf: u4 = 0,
    reserved2: u2 = 0,
    ckout0sel: RcuCfgCkout = RcuCfgCkout.off,
    pllmf4: bool = false,
    ckoutdiv: u3 = 0,
    plldv: bool = false
};

pub const RcuCfg1 = packed struct(u32) {
    predv: u3 = 0,
    reserved: u29 = 0
};

pub const RcuCfg2 = packed struct(u32) {
    usart0sel: u2 = 0,
    reserved: u6 = 0,
    adcsel: bool = false,
    reserved2: u7 = 0,
    irc28mdiv: bool = false,
    reserved3: u14 = 0,
    adcpsc2: bool = false
};

pub const RcuAhben = packed struct(u32) {
    dmaen: bool = false,
    reserved: u1 = 0,
    sramspen: bool = true,
    reserved2: u1 = 0,
    fmcspen: bool = true,
    reserved3: u1 = 0,
    crcen: bool = false,
    reserved4: u10 = 0,
    paen: bool = false,
    pben: bool = false,
    pcen: bool = false,
    reserved5: u2 = 0,
    pfen: bool = false,
    reserved6: u9 = 0
};

pub const RcuApb2en = packed struct(u32) {
    cfgcmpen: bool = false,
    reserved: u8 = 0,
    adcen: bool = false,
    reserved2: u1 = 0,
    timer0en: bool = false,
    spi0en: bool = false,
    reserved3: u1 = 0,
    usart0en: bool = false,
    reserved4: u1 = 0,
    timer14en: bool = false,
    timer15en: bool = false,
    timer16en: bool = false,
    reserved6: u3 = 0,
    dbgmcuen: bool = false,
    reserved7: u9 = 0
};

pub const RcuApb1en = packed struct(u32) {
    reserved: u1 = 0,
    timer2en: bool = false,
    reserved2: u2 = 0,
    timer5en: bool = false,
    reserved3: u3 = 0,
    timer13en: bool = false,
    reserved4: u2 = 0,
    wwdgten: bool = false,
    reserved5: u2 = 0,
    spi1en: bool = false,
    reserved6: u2 = 0,
    usart1en: bool = false,
    reserved7: u3 = 0,
    i2c0en: bool = false,
    i2c1en: bool = false,
    reserved8: u5 = 0,
    pmuen: bool = false,
    reserved9: u3 = 0
};

pub const RcuBdctlRtcsrc = enum(u2) {
    off = 0,
    lxtal = 1,
    irc40k = 2,
    xtal_div32 = 3
};

pub const RcuBdctl = packed struct(u32) {
    lxtalen: bool = false,
    lxtalstb: bool = false,
    lxtalbps: bool = false,
    lxtaldri: u2 = 3,
    reserved: u3 = 0,
    rtcsrc: RcuBdctlRtcsrc,
    reserved2: u5 = 0,
    rtcen: bool = false,
    bkpst: bool = false,
    reserved3: u15 = 0,
};

pub const RcuCtl1 = packed struct(u32) {
    irc28men: bool = false,
    irc28mstb: bool = false,
    reserved: u1 = 0,
    irc28madj: u5 = 0x10,
    irc28calib: u8,
    reserved2: u16 = 0
};

pub const Rcu = extern struct {
    ctl0: RcuCtl0,
    cfg0: RcuCfg0,
    int: u32,
    apb2rst: u32,
    apb1rst: u32,
    ahben: RcuAhben,
    apb2en: RcuApb2en,
    apb1en: RcuApb1en,
    bdctl: RcuBdctl,
    rstsck: u32,
    ahbrst: u32,
    cfg1: RcuCfg1,
    cfg2: RcuCfg2,
    //0x34
    ctl1: RcuCtl1,
    reserved3: [50]u32,
    //0x100
    vkey: u32,
    reserved4: [12]u32,
    //0x134
    dsv: u32
};

pub const rcu: *volatile Rcu = @ptrFromInt(RCU_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x138, @sizeOf(Rcu));
}
