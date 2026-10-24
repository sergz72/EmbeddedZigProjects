const USART1_BASE = 0x40013800;
const USART2_BASE = 0x40004400;

pub const UsartSts = packed struct(u32) {
    perr: bool = false,
    ferr: bool = false,
    nerr: bool = false,
    roerr: bool = false,
    idlef: bool = false,
    rdbf: bool = false,
    tdc: bool = false,
    tdbe: bool = false,
    bff: bool = false,
    ctscf: bool = false,
    reserved1: u1 = 0,
    rtodf: bool = false,
    reserved2: u5 = 0,
    cmdf: bool = false,
    reserved3: u14 = 0
};

pub const UsartCtrl1 = packed struct(u32) {
    sbf: bool = false,
    rm: bool = false,
    ren: bool = false,
    ten: bool = false,
    idleien: bool = false,
    rdbfien: bool = false,
    tdcien: bool = false,
    tdbeien: bool = false,
    perrien: bool = false,
    psel: bool = false,
    pen: bool = false,
    wum: bool = false,
    dbn0: bool = false,
    uen: bool = false,
    cmdie: bool = false,
    reserved1: u1 = 0,
    tcdt: u5 = 0,
    tsdt: u5 = 0,
    retodie: bool = false,
    rtoden: bool = false,
    dbn1: bool = false,
    reserved2: u3 = 0
};

pub const UsartStopbn = enum(u2) {
    _1 = 0,
    _0p5 = 1,
    _2 = 2,
    _1p5 = 3
};

pub const UsartCtrl2 = packed struct(u32) {
    idl: u4 = 0,
    reserved1: u1 = 0,
    bfbn: bool = false,
    bfien: bool = false,
    reserved2: u1 = 0,
    lbcp: bool = false,
    clkpha: bool = false,
    clkpol: bool = false,
    clken: bool = false,
    stopbn: UsartStopbn = ._1,
    linen: bool = false,
    trpswap: bool = false,
    rxrev: bool = false,
    txrev: bool = false,
    dtrev: bool = false,
    reserved3: u9 = 0,
    idh: u4 = 0
};

pub const UsartCtrl3 = packed struct(u32) {
    errien: bool = false,
    irdaen: bool = false,
    irdalp: bool = false,
    slben: bool = false,
    scnacken: bool = false,
    scmen: bool = false,
    dmaren: bool = false,
    dmaten: bool = false,
    rtsen: bool = false,
    ctsen: bool = false,
    ctscfien: bool = false,
    reserved1: u3 = 0,
    rs485en: bool = false,
    dep: bool = false,
    reserved2: u16 = 0
};

pub const UsartGdiv = packed struct(u32) {
    isdiv: u8 = 0,
    scgt: u8 = 0,
    reserved1: u16 = 0
};

pub const UsartIfc = packed struct(u32) {
    reserved1: u11 = 0,
    rtodfc: bool = false,
    reserved2: u5 = 0,
    cmdfc: bool = false,
    reserved3: u14 = 0
};

pub const Usart = extern struct {
    sts: UsartSts,
    dt: u32,
    baudr: u32,
    ctrl1: UsartCtrl1,
    ctrl2: UsartCtrl2,
    ctrl3: UsartCtrl3,
    gdiv: UsartGdiv,
    rtov: u32,
    ifc: UsartIfc,

    pub fn init(self: *volatile Usart, baud_rate: u32, apbclock: u32) void {
        self.baudr = apbclock / baud_rate;
        const v: UsartCtrl1 = .{.uen = true, .ten = true, .ren = true, .rdbfien = true};
        self.ctrl1 = v;
    }

    pub fn write(self: *volatile Usart, byte: u8) void {
        while (!self.sts.tdbe) {
            asm volatile ("nop");
        }
        self.dt = byte;
    }
};

pub const usart1: *volatile Usart = @ptrFromInt(USART1_BASE);
pub const usart2: *volatile Usart = @ptrFromInt(USART2_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x24, @sizeOf(Usart));
}
