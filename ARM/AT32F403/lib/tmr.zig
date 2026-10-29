pub const TMR1_BASE = 0x40012C00;

pub const TMR2_BASE = 0x40000000;
pub const TMR3_BASE = 0x40000400;
pub const TMR4_BASE = 0x40000800;
pub const TMR5_BASE = 0x40000C00;
pub const TMR6_BASE = 0x40001000;
pub const TMR7_BASE = 0x40001400;

pub const TMR8_BASE = 0x40013400;
pub const TMR9_BASE = 0x40014C00;
pub const TMR10_BASE = 0x40015000;
pub const TMR11_BASE = 0x40015400;

pub const TMR12_BASE = 0x40001800;
pub const TMR13_BASE = 0x40001C00;
pub const TMR14_BASE = 0x40002000;

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

pub const TmrCtrl1 = packed struct(u16) {
    tmren: bool = false,
    ovfen: bool = false,
    ovfs: bool = false,
    ocmen: bool = false,
    owcdir: bool = false,
    twcmsel: TmrCmSel = .one_way,
    prben: bool = false,
    clkdiv: TmrClkDiv = .div1,
    reserved1: u6 = 0
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

pub const TmrCtrl2 = packed struct(u16) {
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
    reserved2: u1 = 0
};

pub const TmrStcCtrl = packed struct(u16) {
    smsel: u3 = 0,
    cossel: bool = false,
    stis: u3 = 0,
    sts: bool = false,
    esf: u4 = 0,
    esdiv: u2 = 0,
    ecmben: bool = false,
    esp: bool = false
};

pub const TmrIden = packed struct(u16) {
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
    reserved1: u1 = 0
};

pub const TmrISts = packed struct(u16) {
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
    reserved2: u3 = 0
};

pub const TmrSwEvt = packed struct(u16) {
    ovfswtr: bool = false,
    c1swtr: bool = false,
    c2swtr: bool = false,
    c3swtr: bool = false,
    c4swtr: bool = false,
    hallswtr: bool = false,
    trgswtr: bool = false,
    brkswtr: bool = false,
    reserved: u8 = 0
};

pub const TmrCm1 = packed struct(u16) {
    c1c: u2 = 0,
    c1oien: bool = false,
    c1oben: bool = false,
    c1octrl: u3 = 0,
    c1osen: bool = false,
    c2c: u2 = 0,
    c2oien: bool = false,
    c2oben: bool = false,
    c2octrl: u3 = 0,
    c2osen: bool = false
};

pub const TmrCm2 = packed struct(u16) {
    c3c: u2 = 0,
    c3oien: bool = false,
    c3oben: bool = false,
    c3octrl: u3 = 0,
    c3osen: bool = false,
    c4c: u2 = 0,
    c4oien: bool = false,
    c4oben: bool = false,
    c4octrl: u3 = 0,
    c4osen: bool = false
};

pub const TmrCctrl = packed struct(u16) {
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
    reserved1: u2 = 0
};

pub const TmrBrk = packed struct(u16) {
    dtc: u8 = 0,
    wpc: u2 = 0,
    fcsodis: bool = false,
    fcsoen: bool = false,
    brken: bool = false,
    brkv: bool = false,
    aoen: bool = false,
    oen: bool = false
};

pub const TmrDmaCtrl = packed struct(u16) {
    addr: u5 = 0,
    reserved1: u3 = 0,
    dtb: u5 = 0,
    reserved2: u3 = 0
};

pub const TmrRmp = packed struct(u32) {
    tmr4_ch1_irmp: u2 = 0,
    reserved1: u30 = 0
};

pub const TimCdt = extern struct {
    cdt: u16,
    reserved: u16
};

pub const Tmr = extern struct {
    ctrl1: TmrCtrl1,
    reserved: u16,
    ctrl2: TmrCtrl2,
    reserved1: u16,
    stctrl: TmrStcCtrl,
    reserved2: u16,
    iden: TmrIden,
    reserved3: u16,
    ists: TmrISts,
    reserved4: u16,
    swevt: TmrSwEvt,
    reserved5: u16,
    cm1: TmrCm1,
    reserved6: u16,
    cm2: TmrCm2,
    reserved7: u16,
    cctrl: TmrCctrl,
    reserved8: u16,
    cval: u16,
    reserved9: u16,
    div: u16,
    reserved10: u16,
    pr: u16,
    reserved11: u16,
    rpr: u16,
    reserved12: u16,
    cdt: [4]TimCdt,
    brk: TmrBrk,
    reserved13: u16,
    dmactrl: TmrDmaCtrl,
    reserved14: u16,
    dmadt: u16,
    reserved15: u16
};

pub const gptmr2: *volatile Tmr = @ptrFromInt(TMR2_BASE);
pub const gptmr3: *volatile Tmr = @ptrFromInt(TMR3_BASE);
pub const gptmr4: *volatile Tmr = @ptrFromInt(TMR4_BASE);
pub const gptmr5: *volatile Tmr = @ptrFromInt(TMR5_BASE);

pub const btmr6: *volatile Tmr = @ptrFromInt(TMR6_BASE);
pub const btmr7: *volatile Tmr = @ptrFromInt(TMR7_BASE);

pub const actmr1: *volatile Tmr = @ptrFromInt(TMR1_BASE);
pub const actmr8: *volatile Tmr = @ptrFromInt(TMR8_BASE);

pub const gptmr9: *volatile Tmr = @ptrFromInt(TMR9_BASE);
pub const gptmr10: *volatile Tmr = @ptrFromInt(TMR10_BASE);
pub const gptmr11: *volatile Tmr = @ptrFromInt(TMR11_BASE);
pub const gptmr12: *volatile Tmr = @ptrFromInt(TMR12_BASE);
pub const gptmr13: *volatile Tmr = @ptrFromInt(TMR13_BASE);
pub const gptmr14: *volatile Tmr = @ptrFromInt(TMR14_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x50, @sizeOf(Tmr));
}
