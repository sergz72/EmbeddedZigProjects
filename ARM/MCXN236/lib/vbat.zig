const VBAT0_BASE = 0x40059000;

pub const Verid = bitpack struct(u32) {
    feature: u16,
    minor: u8,
    major: u8,
};

pub const Statusa = bitpack struct(u32) {
    por_det: bool = true,
    wakeup_flag: bool = false,
    timer0_flag: bool = false,
    timer1_flag: bool = false,
    ldo_rdy: bool = false,
    osc_rdy: bool = false,
    reserved3: u1 = 0,
    config_det: bool = true,
    reserved1: u8 = 0,
    irq0_det: bool = false,
    irq1_det: bool = false,
    irq2_det: bool = false,
    irq3_det: bool = false,
    reserved2: u12 = 0,
};

pub const Irqena = bitpack struct(u32) {
    por_det: bool = false,
    wakeup_flag: bool = false,
    timer0_flag: bool = false,
    timer1_flag: bool = false,
    ldo_rdy: bool = false,
    osc_rdy: bool = false,
    clock_det: bool = false,
    config_det: bool = false,
    volt_det: bool = false,
    temp_det: bool = false,
    light_det: bool = false,
    reserved0: u1 = 0,
    sec0_det: bool = false,
    reserved1: u3 = 0,
    irq0_det: bool = false,
    irq1_det: bool = false,
    irq2_det: bool = false,
    irq3_det: bool = false,
    reserved2: u12 = 0,
};

pub const Wakena = bitpack struct(u32) {
    por_det: bool = false,
    wakeup_flag: bool = false,
    timer0_flag: bool = false,
    timer1_flag: bool = false,
    ldo_rdy: bool = false,
    osc_rdy: bool = false,
    clock_det: bool = false,
    config_det: bool = false,
    volt_det: bool = false,
    temp_det: bool = false,
    light_det: bool = false,
    reserved0: u1 = 0,
    sec0_det: bool = false,
    reserved1: u3 = 0,
    irq0_det: bool = false,
    irq1_det: bool = false,
    irq2_det: bool = false,
    irq3_det: bool = false,
    reserved2: u12 = 0,
};

pub const Tampera = bitpack struct(u32) {
    por_det: bool = true,
    reserved0: u5 = 0,
    clock_det: bool = false,
    config_det: bool = false,
    volt_det: bool = false,
    temp_det: bool = false,
    light_det: bool = false,
    reserved1: u1 = 0,
    sec0_det: bool = false,
    reserved2: u19 = 0,
};

pub const Locka = bitpack struct(u32) {
    lock: bool = false,
    reserved0: u31 = 0,
};

pub const Lockb = bitpack struct(u32) {
    lock: bool = true,
    reserved0: u31 = 0,
};

pub const Wakecfg = bitpack struct(u32) {
    out: bool = false,
    reserved0: u31 = 0,
};

pub const CapSel = enum(u4) {
    _0pf = 0,
    _2pf = 1,
    _4pf = 2,
    _6pf = 3,
    _8pf = 4,
    _10pf = 5,
    _12pf = 6,
    _14pf = 7,
    _16pf = 8,
    _18pf = 9,
    _20pf = 10,
    _22pf = 11,
    _24pf = 12,
    _26pf = 13,
    _28pf = 14,
    _30pf = 15,
};

pub const ModeEn = enum(u2) {
    normal = 0,
    startup = 1,
    low_power = 3,
};

pub const SupplyDet = enum(u2) {
    less3v = 0,
    greater3v = 1,
};

pub const Oscctla = bitpack struct(u32) {
    osc_en: bool = false,
    osc_byp_en: bool = false,
    coarse_amp_gain: u2 = 0,
    reserved0: u3 = 0,
    cap_sel_en: bool = false,
    extal_cap_sel: CapSel = ._0pf,
    xtal_cap_sel: CapSel = ._0pf,
    mode_en: ModeEn = .normal,
    supply_det: SupplyDet = .less3v,
    reserved1: u12 = 0,
};

pub const CmpTrim = enum(u2) {
    _760mv = 0,
    _770mv = 1,
    _740mv = 3,
};

pub const CapTrim = enum(u2) {
    default = 0,
    _1us = 1,
    _2us = 2,
    _2us5 = 3,
};

pub const InitTrim = enum(u3) {
    _8s = 0,
    _4s = 1,
    _2s = 2,
    _1s = 3,
    _500ms = 4,
    _250ms = 5,
    _125ms = 6,
    _0p5ms = 7,
};

pub const Osccfga = bitpack struct(u32) {
    cmp_trim: CmpTrim = ._760mv,
    cap2_trim: bool = false,
    dly_trim: u4 = 0,
    cap_trim: CapTrim = .default,
    init_trim: InitTrim = ._8s,
    reserved0: u20 = 0,
};

pub const Osclcka = bitpack struct(u32) {
    lock: bool = false,
    reserved0: u31 = 0,
};

pub const Osclckb = bitpack struct(u32) {
    lock: bool = true,
    reserved0: u31 = 0,
};

pub const Oscclke = bitpack struct(u32) {
    clke: u4 = 0,
    reserved0: u28 = 0,
};

pub const Froctla = bitpack struct(u32) {
    fro_en: bool = true,
    reserved0: u31 = 0,
};

pub const Froctlb = bitpack struct(u32) {
    inverse: bool = false,
    reserved0: u31 = 0,
};

pub const Frolcka = bitpack struct(u32) {
    lock: bool = false,
    reserved0: u31 = 0,
};

pub const Frolckb = bitpack struct(u32) {
    lock: bool = true,
    reserved0: u31 = 0,
};

pub const Froclke = bitpack struct(u32) {
    clke: u4 = 0,
    reserved0: u28 = 0,
};

pub const Ldoctla = bitpack struct(u32) {
    bg_en: bool = false,
    ldo_en: bool = false,
    refresh_en: bool = false,
    reserved0: u29 = 0,
};

pub const Ldolcka = bitpack struct(u32) {
    lock: bool = false,
    reserved0: u31 = 0,
};

pub const Ldolckb = bitpack struct(u32) {
    lock: bool = true,
    reserved0: u31 = 0,
};

pub const Ldoramc = bitpack struct(u32) {
    iso: bool = false,
    swi: bool = false,
    reserved0: u6 = 0,
    ret0: bool = false,
    ret1: bool = false,
    ret2: bool = false,
    ret3: bool = false,
    reserved1: u20 = 0,
};

pub const Timcfg = enum(u3) {
    _1s = 0,
    _500ms = 1,
    _250ms = 2,
    _125ms = 3,
    _62ms = 4,
    _31ms = 5,
    _16ms = 6,
    _8ms = 7,
};

pub const Ldotimer0 = bitpack struct(u32) {
    timcfg: Timcfg = ._1s,
    reserved0: u28 = 0,
    timen: bool = false,
};

pub const Ldotimer1 = bitpack struct(u32) {
    timcfg: u24 = 0,
    reserved0: u7 = 0,
    timen: bool = false,
};

pub const Swictla = bitpack struct(u32) {
    swi_en: bool = false,
    lp_en: bool = false,
    reserved0: u30 = 0,
};

pub const Swictlb = bitpack struct(u32) {
    inverse: u2 = 3,
    reserved0: u30 = 0,
};

pub const Swilcka = bitpack struct(u32) {
    lock: bool = false,
    reserved0: u31 = 0,
};

pub const Swilckb = bitpack struct(u32) {
    lock: bool = true,
    reserved0: u31 = 0,
};

pub const Waklcka = bitpack struct(u32) {
    lock: bool = false,
    reserved0: u31 = 0,
};

pub const Waklckb = bitpack struct(u32) {
    lock: bool = true,
    reserved0: u31 = 0,
};

pub const Vbat = extern struct {
    verid: Verid,
    reserved0: [3]u32,
    statusa: Statusa,
    statusb: Statusa,
    irqena: Irqena,
    irqenb: Irqena,
    wakena: Wakena,
    wakenb: Wakena,
    tampera: Tampera,
    tamperb: Tampera,
    locka: Locka,
    lockb: Lockb,
    wakecfg: Wakecfg,
    reserved1: [49]u32,
    oscctla: Oscctla,
    oscctlb: Oscctla,
    osccfga: Osccfga,
    osccfgb: Osccfga,
    reserved2: [2]u32,
    osclcka: Osclcka,
    osclckb: Osclckb,
    oscclke: Oscclke,
    reserved3: [55]u32,
    froctla: Froctla,
    froctlb: Froctlb,
    reserved4: [4]u32,
    frolcka: Frolcka,
    frolckb: Frolckb,
    froclke: Froclke,
    reserved5: [55]u32,
    ldoctla: Ldoctla,
    ldoctlb: Ldoctla,
    reserved6: [4]u32,
    ldolcka: Ldolcka,
    ldolckb: Ldolckb,
    ldoramc: Ldoramc,
    reserved7: [3]u32,
    ldotimer0: Ldotimer0,
    reserved8: u32,
    ldotimer1: Ldotimer1,
    reserved9: [177]u32,
    swictla: Swictla,
    swictlb: Swictlb,
    reserved14: [4]u32,
    swilcka: Swilcka,
    swilckb: Swilckb,
    reserved15: [118]u32,
    waklcka: Waklcka,
    waklckb: Waklckb,

    pub fn enableOsc32k(self: *volatile Vbat) void {
        self.oscctla = Oscctla{
            .osc_en = true,
            .cap_sel_en = true,
            .extal_cap_sel = ._12pf,
            .xtal_cap_sel = ._12pf
        };
        while (!self.statusa.osc_rdy) {
            asm volatile ("nop");
        }
    }
};

pub const vbat0: *volatile Vbat = @ptrFromInt(VBAT0_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x800, @sizeOf(Vbat));

}
