const SPI1_BASE: usize = 0x40013000;
const SPI2_BASE: usize = 0x40003800;
const SPI3_BASE: usize = 0x40003C00;

pub const SpiBr = enum(u3) {
    div2 = 0,
    div4 = 1,
    div8 = 2,
    div16 = 3,
    div32 = 4,
    div64 = 5,
    div128 = 6,
    div256 = 7
};

pub const SpiCtlr1 = packed struct(u16) {
    cpha: bool = false,
    cpol: bool = false,
    mstr: bool = false,
    br: SpiBr = .div2,
    spe: bool = false,
    lsbfirst: bool = false,
    ssi: bool = false,
    ssm: bool = false,
    rxonly: bool = false,
    dff16: bool = false,
    crcnext: bool = false,
    crcen: bool = false,
    bidioe: bool = false,
    bidimode: bool = false
};

pub const SpiCtlr2 = packed struct(u16) {
    rxdmaen: bool = false,
    txdmaen: bool = false,
    ssoe: bool = false,
    reserved: u2 = 0,
    errie: bool = false,
    rxneie: bool = false,
    txeie: bool = false,
    reserved2: u8 = 0
};

pub const SpiStatr = packed struct(u16) {
    rxne: bool,
    txe: bool,
    chsid: bool,
    udr: bool,
    crcerr: bool,
    modf: bool,
    ovr: bool,
    bsy: bool,
    reserved: u8
};

pub const SpiI2sCfgr = packed struct(u16) {
    chlen: bool = false,
    datlen: u2 = 0,
    ckpol: bool = false,
    i2sstd: u2 = 0,
    reserved: bool = false,
    psmsync: bool = false,
    i2scfg: u2 = 0,
    i2se: bool = false,
    i2smod: bool = false,
    reserved2: u4 = 0
};

pub const SpiI2sPr = packed struct(u16) {
    i2sdiv: u8 = 0,
    odd: bool = false,
    mckoe: bool = false,
    reserved: u6 = 0
};

pub const SpiHscr = packed struct(u16) {
    hsrxen: bool = false,
    reserved: bool = false,
    hsrxen2: bool = false,
    reserved2: u13 = 0
};

const SpiDatar = extern union {
    b: u8,
    h: u16,
};

pub const Spi = extern struct {
    ctlr1: SpiCtlr1,
    reserved: u16,
    ctlr2: SpiCtlr2,
    reserved2: u16,
    statr: SpiStatr,
    reserved3: u16,
    datar: SpiDatar,
    reserved4: u16,
    crcr: u16,
    reserved5: u16,
    rcrcr: u16,
    reserved6: u16,
    tcrcr: u16,
    reserved7: u16,
    i2s_cfgr: SpiI2sCfgr,
    reserved8: u16,
    i2s_pr: SpiI2sPr,
    reserved9: u16,
    hscr: SpiHscr,

    pub fn send_poll8(self: *volatile Spi, data: []const u8) void {
        for (data) |b| {
            while (!self.statr.txe) {
                asm volatile ("nop");
            }
            self.datar.b = b;
        }
    }

    pub fn wait_for_transfer_complete(self: *volatile Spi) void {
        while (self.statr.bsy) {
            asm volatile ("nop");
        }
    }

    pub fn send_receive_poll8(self: *volatile Spi, data_in: []const u8, data_out: []u8) void {
        var idx: usize = 0;
        for (data_in) |b| {
            while (!self.statr.txe) {
                asm volatile ("nop");
            }
            self.datar.b = b;
            while (!self.statr.rxne) {
                asm volatile ("nop");
            }
            data_out[idx] = self.datar.b;
            idx += 1;
        }
    }
};

pub const spi1: *volatile Spi = @ptrFromInt(SPI1_BASE);
pub const spi2: *volatile Spi = @ptrFromInt(SPI2_BASE);
pub const spi3: *volatile Spi = @ptrFromInt(SPI3_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x26, @sizeOf(Spi));
}
