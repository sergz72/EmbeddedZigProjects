const CLOCK_BASE: usize = 0x4001E000;

pub const ClockSckDiv = enum(u3) {
    div1 = 0,
    div2 = 1,
    div4 = 2,
    div8 = 3,
    div16 = 4,
    div32 = 5,
    div64 = 6
};

pub const ClockSckDivCr = packed struct(u32) {
    pckd: ClockSckDiv = .div16,
    reserved: u1 = 0,
    pckc: ClockSckDiv = .div16,
    reserved2: u1 = 0,
    pckb: ClockSckDiv = .div16,
    reserved3: u1 = 0,
    pcka: ClockSckDiv = .div16,
    reserved4: u9 = 0,
    ick: ClockSckDiv = .div16,
    reserved5: u1 = 0,
    fck: ClockSckDiv = .div16,
    reserved6: u1 = 0
};

pub const ClockSckScr = enum(u8) {
    hoco = 0,
    moco = 1,
    loco = 2,
    mosc = 3,
    sosc = 4,
    pll = 5
};

pub const ClockPllDiv = enum(u2) {
    reserved = 0,
    div2 = 1,
    div4 = 2
};

pub const ClockPllCr2 = packed struct(u8) {
    pllmul: u5 = 7,
    reserved: u1 = 0,
    plldiv: ClockPllDiv = .reserved
};

pub const ClockStop = packed struct(u8) {
    stop: bool = true,
    reserved: u7 = 0
};

pub const ClockHocoCr2 = enum(u8) {
    f24 = 0,
    f32 = 0x10,
    f48 = 0x20,
    f64 = 0x28
};

pub const ClockOscSf = packed struct(u8) {
    hocosf: bool,
    reserved: u2,
    moscsf: bool,
    reserved2: u1,
    pllsf: bool,
    reserved3: u2
};

pub const ClockOstDcr = packed struct(u8) {
    ostdie: bool = false,
    reserved: u6 = 0,
    ostde: bool = false
};

pub const ClockMomCr = packed struct(u8) {
    reserved: u3 = 0,
    modrv1: bool = false,
    reserved2: u2 = 0,
    mosel: bool = false,
    reserved3: u1 = 0,
};

pub const ClockLcdSckCr = packed struct(u8) {
    lcdscksel: u3 = 0,
    reserved: u4 = 0,
    lcdscken: bool = false
};

pub const ClockCkOcr = packed struct(u8) {
    ckosel: u3 = 0,
    reserved: u1 = 0,
    ckodiv: u3 = 0,
    coken: bool = false
};

pub const Clock = extern struct {
    //e000
    hococr2: ClockHocoCr2,
    reserved7: [31]u8,
    //e020
    sckdivcr: ClockSckDivCr,
    reserved: u16,
    //e026
    sckscr: ClockSckScr,
    reserved2: [3]u8,
    //e02a
    pllcr: ClockStop,
    //e02b
    pllcr2: ClockPllCr2,
    reserved3: [5]u8,
    //e031
    memwait: u8,
    //e032
    mosccr: ClockStop,
    reserved4: [3]u8,
    //e036
    hococr: ClockStop,
    reserved8: u8,
    //e038
    mococr: ClockStop,
    reserved9: [3]u8,
    //e03c
    oscsf: ClockOscSf,
    reserved10: u8,
    //e03e
    ckocr: ClockCkOcr,
    //e03f
    trckcr: u8,
    //e040
    ostdcr: ClockOstDcr,
    //e041
    ostdsr: u8,
    reserved13: [14]u8,
    //e050
    slcdsckcr: ClockLcdSckCr,
    reserved17: [16]u8,
    //e061
    mocoutcr: u8,
    //e062
    hocoutcr: u8,
    reserved11: [63]u8,
    //e0a2
    moscwtcr: u8,
    reserved12: [2]u8,
    //e0a5
    hocowtcr: u8,
    reserved18: [42]u8,
    //e0d0
    usbckcr: u8,
    reserved5: [834]u8,
    //e413
    momcr: ClockMomCr,
    reserved14: [108]u8,
    //e480
    sosccr: ClockStop,
    //e481
    somcr: u8,
    reserved6: [14]u8,
    //e490
    lococr: ClockStop,
    reserved16: u8,
    //e492
    locoutcr: u8,
    reserved19: u8
};

pub const clock: *volatile Clock = @ptrFromInt(CLOCK_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x494, @sizeOf(Clock));
}
