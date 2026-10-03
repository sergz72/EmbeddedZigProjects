const USART0_BASE: usize = 0x40013800;
const USART1_BASE: usize = 0x40004400;

pub const UsartStat = packed struct(u32) {
    perr: bool,
    ferr: bool,
    nerr: bool,
    orerr: bool,
    idlef: bool,
    rbne: bool,
    tc: bool,
    tbe: bool,
    lbdf: bool,
    ctsf: bool,
    cts: bool,
    rtf: bool,
    ebf: bool,
    reserved: u3,
    bsy: bool,
    amf: bool,
    sbf: bool,
    rwu: bool,
    wuf: bool,
    tea: bool,
    rea: bool,
    reserved2: u9
};

pub const UsartIntc = packed struct(u32) {
    pec: bool,
    fec: bool,
    nec: bool,
    orec: bool,
    idlec: bool,
    reserved: u1,
    tcc: bool,
    reserved2: u1,
    lbdc: bool,
    ctsc: bool,
    reserved3: u1,
    rtc: bool,
    ebc: bool,
    reserved4: u4,
    amc: bool,
    reserved5: u2,
    wuc: bool,
    reserved6: u11
};

pub const UsartGp = packed struct(u32) {
    psc: u8 = 0,
    guat: u8 = 0,
    reserved: u16 = 0
};

pub const UsartRt = packed struct(u32) {
    rt: u24 = 0,
    bl: u8 = 0
};

pub const UsartCmd = packed struct(u32) {
    reserved0: u1 = 0,
    sbkcmd: bool = false,
    mmcmd: bool = false,
    rxfcmd: bool = false,
    txfcmd: bool = false,
    reserved1: u27 = 0
};

pub const UsartCtl0 = packed struct(u32) {
    uen: bool = false,
    uesm: bool = false,
    ren: bool = false,
    ten: bool = false,
    idleie: bool = false,
    rbneie: bool = false,
    tcie: bool = false,
    tbeie: bool = false,
    perrie: bool = false,
    pm: bool = false,
    pcen: bool = false,
    wm: bool = false,
    wl: bool = false,
    men: bool = false,
    amie: bool = false,
    ovsmod: bool = false,
    ded: u5 = 0,
    dea: u5 = 0,
    rtie: bool = false,
    ebie: bool = false,
    reserved: u4 = 0
};

pub const UsartCtl1 = packed struct(u32) {
    reserved0: u4 = 0,
    addm: bool = false,
    lblen: bool = false,
    lbdie: bool = false,
    reserved1: u1 = 0,
    clen: bool = false,
    cph: bool = false,
    cpl: bool = false,
    cken: bool = false,
    stb: u2 = 0,
    lmen: bool = false,
    strp: bool = false,
    rinv: bool = false,
    tinv: bool = false,
    dinv: bool = false,
    msbf: bool = false,
    reserved2: u3 = 0,
    rten: bool = false,
    addr: u8 = 0
};

pub const UsartCtl2 = packed struct(u32) {
    errie: bool = false,
    iren: bool = false,
    irlp: bool = false,
    hden: bool = false,
    nken: bool = false,
    scen: bool = false,
    denr: bool = false,
    dent: bool = false,
    rtsen: bool = false,
    ctsen: bool = false,
    ctsie: bool = false,
    osb: bool = false,
    ovrd: bool = false,
    ddre: bool = false,
    dem: bool = false,
    dep: bool = false,
    reserved: u1 = 0,
    scrtnum: u3 = 0,
    wum: u2 = 0,
    wuie: bool = false,
    reserved2: u9 = 0
};

pub const UsartRfcs = packed struct(u32) {
    elnack: bool = false,
    reserved: u7 = 0,
    rfen: bool = false,
    rffie: bool = false,
    rfe: bool,
    rff: bool,
    rfcnt: u3,
    rffint: bool = false,
    reserved2: u16 = 0
};

pub const Usart = extern struct {
    ctl0: UsartCtl0,
    ctl1: UsartCtl1,
    ctl2: UsartCtl2,
    baud: u32,
    gp: UsartGp,
    rt: UsartRt,
    cmd: UsartCmd,
    stat: UsartStat,
    intc: UsartIntc,
    rdata: u32,
    tdata: u32,
    reserved: [37]u32,
    //0xC0
    chc: u32,
    reserved2: [3]u32,
    //0xD0
    rfcs: UsartRfcs,

    pub fn init(self: *volatile Usart, baud_rate: u32, apbclock: u32) void {
        self.brr = apbclock / baud_rate;
        self.ctl0 = UsartCtl0{.ten = true, .ren = true, .uen = true, .rbneie = true};
    }

    pub fn write(self: *volatile Usart, byte: u8) void {
        while (!self.stat.tbe) {
            asm volatile ("nop");
        }
        self.tdata = byte;
    }
};

pub const usart0: *volatile Usart = @ptrFromInt(USART0_BASE);
pub const usart1: *volatile Usart = @ptrFromInt(USART1_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0xD4, @sizeOf(Usart));
}
