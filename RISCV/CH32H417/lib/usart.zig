const USART1_BASE: usize = 0x40013800;
const USART2_BASE: usize = 0x40004400;
const USART3_BASE: usize = 0x40004800;
const USART4_BASE: usize = 0x40004C00;
const USART5_BASE: usize = 0x40005000;
const USART6_BASE: usize = 0x40001800;
const USART7_BASE: usize = 0x40001C00;
const USART8_BASE: usize = 0x40002000;

pub const UsartStatr = bitpack struct(u32) {
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
    rx_busy: bool,
    ms_err: bool,
    reserved0: u3 = 0,
    lpwkup_act_flag: bool = false,
    reserved1: u16 = 0,
};

pub const UsartCtlr1 = bitpack struct(u32) {
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
    m_ext: u2 = 0,
    reserved: u16 = 0
};

pub const UsartCtlr2 = bitpack struct(u32) {
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

pub const UsartCtlr3 = bitpack struct(u32) {
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
    lpwkup_en: bool = false,
    lpwkup_ck_src: bool = false,
    lpwkup_dly_cfg: u3 = 0,
    reserved0: u16 = 0,
};

pub const UsartGpr = bitpack struct(u32) {
    psc: u8 = 0,
    gt: u8 = 0,
    reserved0: u16 = 0,
};

pub const UsartCtlr4 = bitpack struct(u32) {
    reserved0: u1 = 0,
    ms_errie: bool = false,
    check_sel: u2 = 0,
    reserved1: u28 = 0,
};

pub const Usart = extern struct {
    statr: UsartStatr,
    datar: u8,
    reserved: [3]u8,
    brr: u32,
    ctlr1: UsartCtlr1,
    ctlr2: UsartCtlr2,
    ctlr3: UsartCtlr3,
    gpr: UsartGpr,
    ctlr4: UsartCtlr4,

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
pub const usart5: *volatile Usart = @ptrFromInt(USART5_BASE);
pub const usart6: *volatile Usart = @ptrFromInt(USART6_BASE);
pub const usart7: *volatile Usart = @ptrFromInt(USART7_BASE);
pub const usart8: *volatile Usart = @ptrFromInt(USART8_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x20, @sizeOf(Usart));
}
