const RCU_BASE: usize = 0x40021000;

pub const RcuCtl = packed struct(u32) {
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
    adcpre: u2 = 0,
    pllsel: bool  = false,
    predv0: bool = false,
    pllmf: u4 = 0,
    usbdpsc: u2 = 0,
    ckout0sel: RcuCfgCkout = RcuCfgCkout.off,
    pllmf4: u1 = 0,
    adcpsc2: u1 = 0,
    reserved: u1 = 0,
    pllmf5: u1 = 0,
    usbdpsc2: u1 = 0
};

pub const RcuCfg1 = packed struct(u32) {
    reserved: u29 = 0,
    adcpsc3: u1 = 0,
    pllpresel: bool = false,
    reserved2: u1 = 0
};

pub const RcuAhben = packed struct(u32) {
    dma0en: bool = false,
    dma1en: bool = false,
    sramspen: bool = true,
    reserved: u1 = 0,
    fmcspen: bool = true,
    reserved2: u1 = 0,
    crcen: bool = false,
    reserved3: u1 = 0,
    exmcen: bool = false,
    reserved4: u1 = 0,
    sdioen: bool = false,
    reserved5: u21 = 0
};

pub const RcuApb2en = packed struct(u32) {
    afen: bool = false,
    reserved: u1 = 0,
    paen: bool = false,
    pben: bool = false,
    pcen: bool = false,
    pden: bool = false,
    peen: bool = false,
    pfen: bool = false,
    pgen: bool = false,
    adc0en: bool = false,
    adc1en: bool = false,
    timer0en: bool = false,
    spi0en: bool = false,
    timer7en: bool = false,
    usart0en: bool = false,
    adc2en: bool = false,
    reserved4: u3 = 0,
    timer8en: bool = false,
    timer9en: bool = false,
    timer10en: bool = false,
    reserved6: u10 = 0
};

pub const RcuApb1en = packed struct(u32) {
    timer1en: bool = false,
    timer2en: bool = false,
    timer3en: bool = false,
    timer4en: bool = false,
    timer5en: bool = false,
    timer6en: bool = false,
    timer11en: bool = false,
    timer12en: bool = false,
    timer13en: bool = false,
    reserved: u2 = 0,
    wwdgten: bool = false,
    reserved2: u2 = 0,
    spi1en: bool = false,
    spi2en: bool = false,
    reserved3: u1 = 0,
    usart1en: bool = false,
    usart2en: bool = false,
    usart3en: bool = false,
    usart4en: bool = false,
    i2c0en: bool = false,
    i2c1en: bool = false,
    usbden: bool = false,
    reserved4: u1 = 0,
    can0en: bool = false,
    reserved5: u1 = 0,
    bkpien: bool = false,
    pmuen: bool = false,
    dacen: bool = false,
    reserved6: u2 = 0
};

pub const RcuBdctlRtcsrc = enum(u2) {
    off = 0,
    lxtal = 1,
    irc40k = 2,
    xtal_div128 = 3
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

pub const RcuAddCtl = packed struct(u32) {
    ck48msel: bool = false,
    reserved: u15 = 0,
    irc48men: bool = false,
    irc48mstb: bool = false,
    reserved2: u6 = 0,
    irc48mcalib: u8 = 0
};

pub const Rcu = extern struct {
    ctl: RcuCtl,
    cfg0: RcuCfg0,
    int: u32,
    apb2rst: u32,
    apb1rst: u32,
    ahben: RcuAhben,
    apb2en: RcuApb2en,
    apb1en: RcuApb1en,
    bdctl: RcuBdctl,
    rstsck: u32,
    reserved: u32,
    cfg1: RcuCfg1,
    reserved2: u32,
    dsv: u32,
    reserved3: [34]u32,
    addctl: RcuAddCtl,
    reserved4: [2]u32,
    addint: u32,
    reserved5: [4]u32,
    addapb1rst: u32,
    addapb1en: u32
};

pub const rcu: *volatile Rcu = @ptrFromInt(RCU_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0xE8, @sizeOf(Rcu));
}
