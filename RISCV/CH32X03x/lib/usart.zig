const USART1_BASE: usize = 0x40013800;
const USART2_BASE: usize = 0x40004400;
const USART3_BASE: usize = 0x40004800;
const USART4_BASE: usize = 0x40004C00;

pub const UsartStatr = packed struct(u32) {
    pe: bool,
    fe: bool,
    ne: bool,
    ore: bool,
    idle: bool,
    rxne: bool,
    tc: bool,
    txe: bool,
    lbd: bool,
    cts: bool,
    reserved: u22 = 0
};

pub const UsartCtlr1 = packed struct(u32) {
    sbk: bool = false,
    rwu: bool = false,
    re: bool = false,
    te: bool = false,
    idleie: bool = false,
    rxneie: bool = false,
    tcie: bool = false,
    txeie: bool = false,
    peie: bool = false,
    ps: bool = false,
    pce: bool = false,
    wake: bool = false,
    m: bool = false,
    ue: bool = false,
    reserved: u18 = 0
};

pub const UsartCtlr2 = packed struct(u32) {
    add: u4 = 0,
    reserved: u1 = 0,
    lbdl: bool = false,
    lbdie: bool = false,
    reserved2: u1 = 0,
    lbcl: bool = false,
    cpha: bool = false,
    cpol: bool = false,
    clken: bool = false,
    stop: u2 = 0,
    linen: bool = false,
    reserved3: u17 = 0
};

pub const UsartCtlr3 = packed struct(u32) {
    eie: bool = false,
    iren: bool = false,
    irlp: bool = false,
    hdsel: bool = false,
    nack: bool = false,
    scen: bool = false,
    dmar: bool = false,
    dmat: bool = false,
    rtse: bool = false,
    ctse: bool = false,
    ctsie: bool = false,
    reserved: u21 = 0
};

pub const Usart = extern struct {
    statr: UsartStatr,
    datar: u8,
    brr: u32,
    ctlr1: UsartCtlr1,
    ctlr2: UsartCtlr2,
    ctlr3: UsartCtlr3,
    gpr: u32,

    pub fn init(self: *volatile Usart, baud_rate: u32, apbclock: u32) void {
        self.brr = apbclock / baud_rate;
        self.ctlr1 = UsartCtlr1{.te = true, .re = true, .ue = true, .rxneie = true};
    }

    pub fn write(self: *volatile Usart, byte: u8) void {
        while (!self.statr.txe) {
            asm volatile ("nop");
        }
        self.datar = byte;
    }
};

pub const usart1: *volatile Usart = @ptrFromInt(USART1_BASE);
pub const usart2: *volatile Usart = @ptrFromInt(USART2_BASE);
pub const usart3: *volatile Usart = @ptrFromInt(USART3_BASE);
pub const usart4: *volatile Usart = @ptrFromInt(USART4_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x1C, @sizeOf(Usart));
}
