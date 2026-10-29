const USART1_BASE = 0x40013800;
const USART2_BASE = 0x40004400;
const USART3_BASE = 0x40004800;
const UART4_BASE = 0x40004C00;
const UART5_BASE = 0x40005000;
const USART6_BASE = 0x40016000;
const UART7_BASE = 0x40016400;
const UART8_BASE = 0x40016800;

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
    reserved1: u22 = 0
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
    dbn: bool = false,
    uen: bool = false,
    reserved2: u18 = 0
};

pub const UsartStopbn = enum(u2) {
    _1 = 0,
    _0p5 = 1,
    _2 = 2,
    _1p5 = 3
};

pub const UsartCtrl2 = packed struct(u32) {
    id: u4 = 0,
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
    reserved3: u17 = 0
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
    reserved2: u21 = 0
};

pub const UsartGdiv = packed struct(u32) {
    isdiv: u8 = 0,
    scgt: u8 = 0,
    reserved1: u16 = 0
};

pub const Usart = extern struct {
    sts: UsartSts,
    dt: u32,
    baudr: u32,
    ctrl1: UsartCtrl1,
    ctrl2: UsartCtrl2,
    ctrl3: UsartCtrl3,
    gdiv: UsartGdiv,

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
pub const usart3: *volatile Usart = @ptrFromInt(USART3_BASE);
pub const uart4: *volatile Usart = @ptrFromInt(UART4_BASE);
pub const uart5: *volatile Usart = @ptrFromInt(UART5_BASE);
pub const usart6: *volatile Usart = @ptrFromInt(USART6_BASE);
pub const uart7: *volatile Usart = @ptrFromInt(UART7_BASE);
pub const uart8: *volatile Usart = @ptrFromInt(UART8_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x1C, @sizeOf(Usart));
}
