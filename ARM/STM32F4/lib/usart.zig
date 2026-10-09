const USART1_BASE: usize = 0x40011000;
const USART2_BASE: usize = 0x40004400;
const USART3_BASE: usize = 0x40004800;
const UART4_BASE: usize = 0x40004C00;
const UART5_BASE: usize = 0x40005000;
const USART6_BASE: usize = 0x40011400;
const UART7_BASE: usize = 0x40007800;
const UART8_BASE: usize = 0x40007C00;

pub const UsartSr = packed struct(u32) {
    pe: bool,
    fe: bool,
    nf: bool,
    ore: bool,
    idle: bool,
    rxne: bool,
    tc: bool,
    txe: bool,
    lbd: bool,
    cts: bool,
    reserved: u22 = 0
};

pub const UsartCr1 = packed struct(u32) {
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
    reserved: u1 = 0,
    over8: bool = false,
    reserved2: u16 = 0
};

pub const UsartCr2 = packed struct(u32) {
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

pub const UsartCr3 = packed struct(u32) {
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
    onebit: bool = false,
    reserved: u20 = 0
};

pub const Usart = extern struct {
    sr: UsartSr,
    dr: u8,
    reserved: [3]u8,
    brr: u32,
    cr1: UsartCr1,
    cr2: UsartCr2,
    cr3: UsartCr3,
    gtpr: u32,

    pub fn init(self: *volatile Usart, baud_rate: u32, apbclock: u32) void {
        self.brr = apbclock / baud_rate;
        self.cr1 = .{.te = true, .re = true, .ue = true, .rxneie = true};
    }

    pub fn write(self: *volatile Usart, byte: u8) void {
        while (!self.sr.txe) {
            asm volatile ("nop");
        }
        self.dr = byte;
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
