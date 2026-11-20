const PWM0_BASE = 0x400CE000;

pub const ClkSel = enum(u2) {
    ipbus = 0,
    ext_clk = 1,
    aux_clk = 2,
};

pub const ForceSel = enum(u3) {
    local = 0,
    master = 1,
    local_reload = 2,
    master_reload = 3,
    local_sync = 4,
    master_sync = 5,
    ext_force = 6,
    ext_sync = 7,
};

pub const InitSel = enum(u2) {
    pwm_x = 0,
    master_reload = 1,
    master_sync = 2,
    ext_sync = 3,
};

pub const Smctrl2 = bitpack struct(u16) {
    clk_sel: ClkSel = .ipbus,
    reload_sel: bool = false,
    force_sel: ForceSel = .local,
    force: bool = false,
    frcen: bool = false,
    init_sel: InitSel = .pwm_x,
    pwmx_init: bool = false,
    pwm45_init: bool = false,
    pwm23_init: bool = false,
    indep: bool = false,
    reserved0: u1 = 0,
    dbgen: bool = false,
};

pub const Prsc = enum(u3) {
    _1 = 0,
    _2 = 1,
    _4 = 2,
    _8 = 3,
    _16 = 4,
    _32 = 5,
    _64 = 6,
    _128 = 7,
};

pub const Smctrl = bitpack struct(u16) {
    dblen: bool = false,
    dblx: bool = false,
    ldmod: bool = false,
    split: bool = false,
    prsc: Prsc = ._1,
    compmode: bool = false,
    dt: u2 = 0,
    full: bool = true,
    half: bool = false,
    ldfq: u4 = 0,
};

pub const Smfrctrl = bitpack struct(u16) {
    reserved0: u1 = 0,
    frac1_en: bool = false,
    frac23_en: bool = false,
    reserved1: u1 = 0,
    frac45_en: bool = false,
    reserved2: u10 = 0,
    tst: bool = false,
};

pub const Pwmfs = enum(u2) {
    logic_0 = 0,
    logic_1 = 1,
    tristated_2 = 2,
    tristated_3 = 3,
};

pub const Smoctrl = bitpack struct(u16) {
    pwmxfs: Pwmfs = .logic_0,
    pwmbfs: Pwmfs = .logic_0,
    pwmafs: Pwmfs = .logic_0,
    reserved0: u2 = 0,
    polx: bool = false,
    polb: bool = false,
    pola: bool = false,
    reserved1: u2 = 0,
    pwmx_in: bool = false,
    pwmb_in: bool = false,
    pwma_in: bool = false,
};

pub const Smsts = bitpack struct(u16) {
    cmpf: u6 = 0,
    cfx0: bool = false,
    cfx1: bool = false,
    cfb0: bool = false,
    cfb1: bool = false,
    cfa0: bool = false,
    cfa1: bool = false,
    rf: bool = false,
    ref: bool = false,
    ruf: bool = false,
    reserved0: u1 = 0,
};

pub const Sminten = bitpack struct(u16) {
    cmpie: u6 = 0,
    cx0ie: bool = false,
    cx1ie: bool = false,
    cb0ie: bool = false,
    cb1ie: bool = false,
    ca0ie: bool = false,
    ca1ie: bool = false,
    rie: bool = false,
    reie: bool = false,
    reserved0: u2 = 0,
};

pub const Captde = enum(u2) {
    disabled = 0,
    exceedfifo = 1,
    local_sync = 2,
    local_reload = 3,
};

pub const Smdmaen = bitpack struct(u16) {
    cx0de: bool = false,
    cx1de: bool = false,
    cb0de: bool = false,
    cb1de: bool = false,
    ca0de: bool = false,
    ca1de: bool = false,
    captde: Captde = .disabled,
    fand: bool = false,
    valde: bool = false,
    reserved0: u6 = 0,
};

pub const Smtctrl = bitpack struct(u16) {
    out_trig_en: u6 = 0,
    reserved0: u6 = 0,
    trgfrq: bool = false,
    reserved1: u1 = 0,
    pwbot1: bool = false,
    pwaot0: bool = false,
};

pub const Smdismap0 = bitpack struct(u16) {
    dis0a: u4 = 15,
    dis0b: u4 = 15,
    dis0x: u4 = 15,
    reserved0: u4 = 15,
};

pub const Edg = enum(u2) {
    disabled = 0,
    falling_edge = 1,
    rising_edge = 2,
    any_edge = 3,
};

pub const Smcaptctrl = bitpack struct(u16) {
    arm: bool = false,
    oneshot: bool = false,
    edg0: Edg = .disabled,
    edg1: Edg = .disabled,
    inp_sel: bool = false,
    edgcnt_en: bool = false,
    cfwm: u2 = 0,
    c0cnt: u3 = 0,
    c1cnt: u3 = 0,
};

pub const Smcaptcomp = bitpack struct(u16) {
    edgcmp: u8 = 0,
    edgcnt: u8 = 0,
};

pub const Smcaptfilt = bitpack struct(u16) {
    capta_filt_per: u8 = 0,
    capta_filt_cnt: u3 = 0,
    reserved0: u5 = 0,
};

pub const Outen = bitpack struct(u16) {
    pwmx_en: u4 = 0,
    pwmb_en: u4 = 0,
    pwma_en: u4 = 0,
    reserved0: u4 = 0,
};

pub const Mask = bitpack struct(u16) {
    maskx: u4 = 0,
    maskb: u4 = 0,
    maska: u4 = 0,
    update_mask: u4 = 0,
};

pub const Swcout = bitpack struct(u16) {
    sm0out45: bool = false,
    sm0out23: bool = false,
    sm1out45: bool = false,
    sm1out23: bool = false,
    sm2out45: bool = false,
    sm2out23: bool = false,
    sm3out45: bool = false,
    sm3out23: bool = false,
    reserved0: u8 = 0,
};

pub const Smsel45 = enum(u2) {
    smpwm45 = 0,
    inverted_smpwm45 = 1,
    smout45 = 2,
};

pub const Smsel23 = enum(u2) {
    smpwm23 = 0,
    inverted_smpwm23 = 1,
    smout23 = 2,
    pwm_exta = 3,
};

pub const Dtsrcsel = bitpack struct(u16) {
    sm0sel45: Smsel45 = .smpwm45,
    sm0sel23: Smsel23 = .smpwm23,
    sm1sel45: Smsel45 = .smpwm45,
    sm1sel23: Smsel23 = .smpwm23,
    sm2sel45: Smsel45 = .smpwm45,
    sm2sel23: Smsel23 = .smpwm23,
    sm3sel45: Smsel45 = .smpwm45,
    sm3sel23: Smsel23 = .smpwm23,
};

pub const Mctrl = bitpack struct(u16) {
    ldok: u4 = 0,
    cldok: u4 = 0,
    run: u4 = 0,
    ipol: u4 = 0,
};

pub const Wrprot = enum(u2) {
    disabled = 0,
    enabled = 1,
    disabled_locked = 2,
    enabled_locked = 3,
};

pub const StretchCntPrsc = enum(u2) {
    disabled = 0,
    enabled = 1,
    disabled_locked = 2,
    enabled_locked = 3,
};

pub const Mctrl2 = bitpack struct(u16) {
    reserved0: u2 = 0,
    wrprot: Wrprot = .disabled,
    reserved1: u2 = 0,
    stretch_cnt_prsc: StretchCntPrsc = .disabled,
    reserved2: u8 = 0,
};

pub const Fctrl0 = bitpack struct(u16) {
    fie: u4 = 0,
    fsafe: u4 = 0,
    fauto: u4 = 0,
    flvl: u4 = 0,
};

pub const Fsts0 = bitpack struct(u16) {
    fflag: u4 = 0,
    ffull: u4 = 0,
    ffpin: u4 = 0,
    fhalf: u4 = 0,
};

pub const Ffilt0 = bitpack struct(u16) {
    filt_per: u8 = 0,
    filt_cnt: u3 = 0,
    reserved0: u4 = 0,
    gstr: bool = false,
};

pub const Ftst0 = bitpack struct(u16) {
    ftest: bool = false,
    reserved0: u15 = 0,
};

pub const Fctrl20 = bitpack struct(u16) {
    nocomb: u4 = 0,
    reserved0: u12 = 0,
};

pub const Smfracval = bitpack struct(u16) {
    reserved0: u11 = 0,
    fracval: u5 = 0,
};

pub const PwmChannel = extern struct {
    smcnt: u16,
    sminit: u16,
    smctrl2: Smctrl2,
    smctrl: Smctrl,
    reserved0: u16,
    smval0: u16,
    smfracval1: Smfracval,
    smval1: u16,
    smfracval2: Smfracval,
    smval2: u16,
    smfracval3: Smfracval,
    smval3: u16,
    smfracval4: Smfracval,
    smval4: u16,
    smfracval5: Smfracval,
    smval5: u16,
    smfrctrl: Smfrctrl,
    smoctrl: Smoctrl,
    smsts: Smsts,
    sminten: Sminten,
    smdmaen: Smdmaen,
    smtctrl: Smtctrl,
    smdismap0: Smdismap0,
    reserved1: u16,
    smdtcnt0: u16,
    smdtcnt1: u16,
    smcaptctrla: Smcaptctrl,
    smcaptcompa: u16,
    smcaptctrlb: Smcaptctrl,
    smcaptcompb: u16,
    smcaptctrlx: Smcaptctrl,
    smcaptcompx: u16,
    smcval0: u16,
    smcval0cyc: u16,
    smcval1: u16,
    smcval1cyc: u16,
    smcval2: u16,
    smcval2cyc: u16,
    smcval3: u16,
    smcval3cyc: u16,
    smcval4: u16,
    smcval4cyc: u16,
    smcval5: u16,
    smcval5cyc: u16,
    reserved2: u16,
    smcaptfilta: Smcaptfilt,
    smcaptfiltb: Smcaptfilt,
    smcaptfiltx: Smcaptfilt,
};

pub const Pwm = extern struct {
    ch: [4]PwmChannel,
    outen: Outen,
    mask: Mask,
    swcout: Swcout,
    dtsrcsel: Dtsrcsel,
    mctrl: Mctrl,
    mctrl2: Mctrl2,
    fctrl0: Fctrl0,
    fsts0: Fsts0,
    ffilt0: Ffilt0,
    ftst0: Ftst0,
    fctrl20: Fctrl20,
};

pub const pwm0: *volatile Pwm = @ptrFromInt(PWM0_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x196, @sizeOf(Pwm));
}
