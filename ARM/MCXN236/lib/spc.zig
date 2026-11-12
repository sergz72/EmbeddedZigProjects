const SPC0_BASE = 0x40045000;

pub const Verid = bitpack struct(u32) {
    feature: u16,
    minor: u8,
    major: u8,
};

pub const LpMode = enum(u4) {
    reserved = 0,
    dsleep = 1,
    pdown = 2,
    dpdown = 8
};

pub const Sc = bitpack struct(u32) {
    busy: bool = false,
    spc_lp_req: bool = false,
    reserved0: u2 = 0,
    spc_lp_mode: LpMode = .reserved,
    reserved1: u8 = 0,
    iso_clr: u2 = 0,
    reserved2: u14 = 0,
};

pub const Cntrl = bitpack struct(u32) {
    coreldo_en: bool = true,
    sysldo_en: bool = true,
    dcdc_en: bool = true,
    reserved0: u29 = 0,
};

pub const Lpreqov = enum(u2) {
    not_forced = 0,
    forced_low = 2,
    forced_high = 3,
};

pub const LpreqCfg = bitpack struct(u32) {
    lpreqoe: bool = false,
    lpreqpol: bool = false,
    lpreqov: Lpreqov = .not_forced,
    reserved0: u28 = 0,
};

pub const PdStatus = bitpack struct(u32) {
    pwr_req_status: bool = false,
    reserved0: u3 = 0,
    pd_lp_req: bool = false,
    reserved1: u3 = 0,
    lp_mode: LpMode = .reserved,
    reserved2: u20 = 0,
};

pub const Vsm = enum(u2) {
    _1v0 = 1,
    _1v1 = 2,
};

pub const Sramctl = bitpack struct(u32) {
    vsm: Vsm = ._1v0,
    reserved0: u28 = 0,
    req: bool = false,
    ack: bool = false,
};

pub const VddLvl = enum(u2) {
    mid = 1,
    normal = 2,
    overdrive = 3
};

pub const DcdcVddDs = enum(u2) {
    pulse = 0,
    low = 1,
    normal = 2,
};

pub const Bgmode = enum(u2) {
    disabled = 0,
    enabled_without_buffer = 1,
    enabled_with_buffer = 2
};

pub const ActiveCfg = bitpack struct(u32) {
    coreldo_vdd_ds: bool = true,
    reserved0: u1 = 1,
    coreldo_vdd_lvl: VddLvl = .mid,
    sysldo_vdd_ds: bool = true,
    reserved1: u1 = 0,
    sysldo_vdd_lvl: bool = false,
    reserved2: u1 = 0,
    dcdc_vdd_ds: DcdcVddDs = .normal,
    dcdc_vdd_lvl: VddLvl = .mid,
    glitch_detect_disable: bool = false,
    reserved3: u5 = 4,
    lpbuff_en: bool = false,
    reserved4: u1 = 1,
    bgmode: Bgmode = .enabled_without_buffer,
    reserved5: u1 = 0,
    vdd_vd_disable: bool = false,
    core_lvde: bool = true,
    sys_lvde: bool = true,
    io_lvde: bool = true,
    core_hvde: bool = true,
    sys_hvde: bool = true,
    io_hvde: bool = true,
    reserved6: u2 = 0,
};

pub const LpCfg = bitpack struct(u32) {
    coreldo_vdd_ds: bool = false,
    reserved0: u1 = 1,
    coreldo_vdd_lvl: VddLvl = .mid,
    sysldo_vdd_ds: bool = false,
    reserved1: u3 = 5,
    dcdc_vdd_ds: DcdcVddDs = .low,
    dcdc_vdd_lvl: VddLvl = .mid,
    glitch_detect_disable: bool = true,
    reserved2: u4 = 1,
    corevdd_ivs_en: bool = true,
    lpbuff_en: bool = false,
    reserved3: u1 = 0,
    bgmode: Bgmode = .disabled,
    reserved4: u1 = 0,
    lp_irefen: bool = false,
    core_lvde: bool = false,
    sys_lvde: bool = false,
    io_lvde: bool = false,
    core_hvde: bool = false,
    sys_hvde: bool = false,
    io_hvde: bool = false,
    reserved5: u2 = 0,
};

pub const VdStat = bitpack struct(u32) {
    corevdd_lvdf: bool = false,
    sysvdd_lvdf: bool = false,
    iovdd_lvdf: bool = false,
    reserved0: u1 = 0,
    corevdd_hvdf: bool = false,
    sysvdd_hvdf: bool = false,
    iovdd_hvdf: bool = false,
    reserved1: u25 = 0,
};

pub const VdCoreCfg = bitpack struct(u32) {
    lvdre: bool = true,
    lvdie: bool = false,
    hvdre: bool = false,
    hvdie: bool = false,
    reserved0: u12 = 0,
    lock: bool = false,
    reserved1: u15 = 0,
};

pub const VdSysCfg = bitpack struct(u32) {
    lvdre: bool = true,
    lvdie: bool = false,
    hvdre: bool = false,
    hvdie: bool = false,
    reserved0: u4 = 0,
    lvsel: bool = false,
    reserved1: u7 = 0,
    lock: bool = false,
    reserved2: u15 = 0,
};

pub const VdIoCfg = bitpack struct(u32) {
    lvdre: bool = true,
    lvdie: bool = false,
    hvdre: bool = false,
    hvdie: bool = false,
    reserved0: u4 = 1,
    lvsel: bool = true,
    reserved1: u7 = 0,
    lock: bool = false,
    reserved2: u15 = 0,
};

pub const EvdCfg = bitpack struct(u32) {
    evdiso: u6 = 0,
    reserved0: u2 = 0,
    evdlpiso: u6 = 0,
    reserved1: u2 = 0,
    evdstat: u6 = 0,
    reserved2: u10 = 0,
};

pub const GlitchDetectSc = bitpack struct(u32) {
    cnt_select: u2 = 3,
    timeout: u4 = 15,
    re: bool = false,
    ie: bool = false,
    glitch_detect_flag: u4 = 0,
    reserved0: u4 = 0,
    lock: bool = false,
    reserved1: u15 = 0,
};

pub const CoreldoCfg = bitpack struct(u32) {
    reserved0: u16 = 0,
    dpdown_pulldown_disable: bool = false,
    reserved1: u15 = 0,
};

pub const SysldoCfg = bitpack struct(u32) {
    isinken: bool = true,
    reserved0: u31 = 128,
};

pub const DcdcCfg = bitpack struct(u32) {
    freq_cntrl_on: bool = false,
    reserved0: u7 = 0,
    freq_cntrl: u6 = 0,
    reserved1: u5 = 0,
    bleed_en: bool = false,
    reserved2: u12 = 0,
};

pub const DcdcBurstCfg = bitpack struct(u32) {
    burst_req: bool = false,
    ext_burst_en: bool = false,
    reserved0: u1 = 0,
    burst_ack: bool = false,
    reserved1: u12 = 320,
    pulse_refresh_cnt: u16 = 320,
};

pub const Spc0 = extern struct {
    verid: Verid,
    reserved0: [3]u32,
    sc: Sc,
    cntrl: Cntrl,
    reserved1: u32,
    lpreq_cfg: LpreqCfg,
    reserved2: [4]u32,
    pd_status: [2]PdStatus,
    reserved3: [2]u32,
    sramctl: Sramctl,
    reserved4: [47]u32,
    active_cfg: ActiveCfg,
    active_cfg1: u32,
    lp_cfg: LpCfg,
    lp_cfg1: u32,
    reserved5: [4]u32,
    delay: u32,
    active_vdelay: u32,
    reserved6: [2]u32,
    stat: VdStat,
    core: VdCoreCfg,
    sys: VdSysCfg,
    io: VdIoCfg,
    evd_cfg: EvdCfg,
    detect: GlitchDetectSc,
    reserved7: [110]u32,
    coreldo_cfg: CoreldoCfg,
    reserved8: [63]u32,
    sysldo_cfg: SysldoCfg,
    reserved9: [63]u32,
    dcdc_cfg: DcdcCfg,
    burst: DcdcBurstCfg,
};

pub const spc0: *volatile Spc0 = @ptrFromInt(SPC0_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x508, @sizeOf(Spc0));
}
