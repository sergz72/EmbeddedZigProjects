pub const TMR1_BASE = 0x40012C00;
pub const TMR15_BASE = 0x40014000;
pub const TMR16_BASE = 0x40014400;
pub const TMR17_BASE = 0x40014800;

pub const TMR3_BASE = 0x40000400;
pub const TMR6_BASE = 0x40001000;
pub const TMR4_BASE = 0x40002000;

pub const TmrClkDiv = enum(u2) {
    div1 = 0,
    div2 = 1,
    div4 = 2
};

pub const TmrCmSel = enum(u2) {
    one_way = 0,
    two_way_mode1 = 1,
    two_way_mode2 = 2,
    two_way_mode3 = 3
};

pub const TmrCtrl1 = packed struct(u32) {
    tmren: bool = false,
    ovfen: bool = false,
    ovfs: bool = false,
    ocmen: bool = false,
    owcdir: bool = false,
    twcmsel: TmrCmSel = .one_way,
    prben: bool = false,
    clkdiv: TmrClkDiv = .div1,
    reserved1: u22 = 0
};

pub const TmrPtos = enum(u3) {
    software_overflow_or_reset = 0,
    enable = 1,
    overflow = 2,
    compare_pulse = 3,
    c1oraw = 4,
    c2oraw = 5,
    c3oraw = 6,
    c4oraw = 7
};

pub const TmrCtrl2 = packed struct(u32) {
    cbctl: bool = false,
    reserved1: u1 = 0,
    ccfs: bool = false,
    drs: bool = false,
    ptos: u3 = 0,
    c1insel: bool = false,
    c1ios: bool = false,
    c1cios: bool = false,
    c2ios: bool = false,
    c2cios: bool = false,
    c3ios: bool = false,
    c3cios: bool = false,
    c4ios: bool = false,
    c4cios: bool = false,
    reserved2: u16 = 0
};

pub const TmrStcCtrl = packed struct(u32) {
    smsel: u3 = 0,
    cossel: bool = false,
    stis: u3 = 0,
    sts: bool = false,
    esf: u4 = 0,
    esdiv: u2 = 0,
    ecmben: bool = false,
    esp: bool = false,
    smsel_3: u1 = 0,
    reserved2: u15 = 0
};

pub const TmrIden = packed struct(u32) {
    ovfien: bool = false,
    c1ien: bool = false,
    c2ien: bool = false ,
    c3ien: bool = false,
    c4ien: bool = false,
    hallien: bool = false,
    tien: bool = false,
    brkie: bool = false,
    ovfden: bool = false,
    c1den: bool = false,
    c2den: bool = false,
    c3den: bool = false,
    c4den: bool = false,
    hallde: bool = false,
    tden: bool = false,
    reserved1: u17 = 0
};

pub const TmrISts = packed struct(u32) {
    ovfif: bool = false,
    c1if: bool = false,
    c2if: bool = false,
    c3if: bool = false,
    c4if: bool = false,
    hallif: bool = false,
    trgif: bool = false,
    brkif: bool = false,
    reserved1: u1 = 0,
    c1rf: bool = false,
    c2rf: bool = false,
    c3rf: bool = false,
    c4rf: bool = false,
    reserved2: u19 = 0
};

pub const TmrSwEvt = packed struct(u32) {
    ovfswtr: bool = false,
    c1swtr: bool = false,
    c2swtr: bool = false,
    c3swtr: bool = false,
    c4swtr: bool = false,
    hallswtr: bool = false,
    trgswtr: bool = false,
    brkswtr: bool = false,
    reserved: u24 = 0
};

pub const TmrCm1 = packed struct(u32) {
    c1c: u2 = 0,
    c1oien: bool = false,
    c1oben: bool = false,
    c1octrl: u3 = 0,
    c1osen: bool = false,
    c2c: u2 = 0,
    c2oien: bool = false,
    c2oben: bool = false,
    c2octrl: u3 = 0,
    c2osen: bool = false,
    reserved1: u16 = 0
};

pub const TmrCm2 = packed struct(u32) {
    c3c: u2 = 0,
    c3oien: bool = false,
    c3oben: bool = false,
    c3octrl: u3 = 0,
    c3osen: bool = false,
    c4c: u2 = 0,
    c4oien: bool = false,
    c4oben: bool = false,
    c4octrl: u3 = 0,
    c4osen: bool = false,
    reserved1: u16 = 0
};

pub const TmrCctrl = packed struct(u32) {
    c1en: bool = false,
    c1p: bool = false,
    c1cen: bool = false,
    c1cp: bool = false,
    c2en: bool = false,
    c2p: bool = false,
    c2cen: bool = false,
    c2cp: bool = false,
    c3en: bool = false,
    c3p: bool = false,
    c3cen: bool = false,
    c3cp: bool = false,
    c4en: bool = false,
    c4p: bool = false,
    c4cen: bool = false,
    c4cp: bool = false,
    reserved1: u16
};

pub const TmrDmaCtrl = packed struct(u32) {
    addr: u5 = 0,
    reserved1: u3 = 0,
    dtb: u5 = 0,
    reserved2: u19 = 0
};

pub const TmrRmp = packed struct(u32) {
    tmr4_ch1_irmp: u2 = 0,
    reserved1: u30 = 0
};

pub const Tmr = extern struct {
    ctrl1: TmrCtrl1,
    ctrl2: TmrCtrl2,
    stctrl: TmrStcCtrl,
    iden: TmrIden,
    ists: TmrISts,
    swevt: TmrSwEvt,
    cm1: TmrCm1,
    cm2: TmrCm2,
    cctrl: TmrCctrl,
    cval: u32,
    div: u32,
    pr: u32,
    cdt: [4]u32,
    dmactrl: TmrDmaCtrl,
    dmadt: u32,
    rmp: TmrRmp,
};

pub const gptmr3: *volatile Tmr = @ptrFromInt(TMR3_BASE);
pub const gptmr4: *volatile Tmr = @ptrFromInt(TMR4_BASE);
pub const btmr6: *volatile Tmr = @ptrFromInt(TMR6_BASE);
pub const actmr1: *volatile Tmr = @ptrFromInt(TMR1_BASE);
pub const gptmr15: *volatile Tmr = @ptrFromInt(TMR15_BASE);
pub const gptmr16: *volatile Tmr = @ptrFromInt(TMR16_BASE);
pub const gptmr17: *volatile Tmr = @ptrFromInt(TMR17_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x14, @sizeOf(Tmr));
}
