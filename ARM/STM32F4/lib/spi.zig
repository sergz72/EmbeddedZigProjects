const SPI1_BASE: usize = 0x40013000;
const SPI2_BASE: usize = 0x40003800;
const SPI3_BASE: usize = 0x40003C00;
const SPI4_BASE: usize = 0x40013400;

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

pub const SpiCr1 = packed struct(u16) {
    cpha: bool = false,
    cpol: bool = false,
    mstr: bool = false,
    br: SpiBr = .div2,
    spe: bool = false,
    lsbfirst: bool = false,
    ssi: bool = false,
    ssm: bool = false,
    rxonly: bool = false,
    dff: bool = false,
    crcnext: bool = false,
    crcen: bool = false,
    bidioe: bool = false,
    bidimode: bool = false
};

pub const SpiCr2 = packed struct(u16) {
    rxdmaen: bool = false,
    txdmaen: bool = false,
    ssoe: bool = false,
    reserved: u1 = 0,
    frf: bool = false,
    errie: bool = false,
    rxneie: bool = false,
    txeie: bool = false,
    reserved2: u8 = 0
};

pub const SpiSr = packed struct(u16) {
    rxne: bool,
    txe: bool,
    chside: bool,
    udr: bool,
    crcerr: bool,
    modf: bool,
    ovr: bool,
    bsy: bool,
    fre: bool,
    reserved: u7
};

pub const SpiI2sCfgr = packed struct(u16) {
    chlen: bool = false,
    datlen: u2 = 0,
    ckpol: bool = false,
    i2sstd: u2 = 0,
    reserved: u1 = 0,
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

const SpiDr = extern union {
    b: u8,
    h: u16,
};

pub const Spi = extern struct {
    cr1: SpiCr1,
    reserved: u16,
    cr2: SpiCr2,
    reserved2: u16,
    sr: SpiSr,
    reserved3: u16,
    dr: SpiDr,
    reserved4: u16,
    crcpr: u16,
    reserved5: u16,
    rxcrcr: u16,
    reserved6: u16,
    txcrcr: u16,
    reserved7: u16,
    i2scfgr: SpiI2sCfgr,
    reserved8: u16,
    i2spr: SpiI2sPr,

    pub fn sendPoll8(self: *volatile Spi, data: []const u8) void {
        for (data) |b| {
            while (!self.sr.txe) {
                asm volatile ("nop");
            }
            self.dr.b = b;
            while (!self.sr.rxne) {
                asm volatile ("nop");
            }
            _ = self.dr.b;
        }
    }

    pub fn waitForTransferComplete(self: *volatile Spi) void {
        while (self.sr.bsy) {
            asm volatile ("nop");
        }
    }

    pub fn sendReceivePoll8(self: *volatile Spi, data_in: []const u8, data_out: []u8) void {
        var idx: usize = 0;
        for (data_in) |b| {
            while (!self.sr.txe) {
                asm volatile ("nop");
            }
            self.dr.b = b;
            while (!self.sr.rxne) {
                asm volatile ("nop");
            }
            data_out[idx] = self.dr.b;
            idx += 1;
        }
    }

    pub fn receivePoll8(self: *volatile Spi, data_out: []u8) void {
        for (0..data_out.len) |idx| {
            while (!self.sr.txe) {
                asm volatile ("nop");
            }
            self.dr.b = 0;
            while (!self.sr.rxne) {
                asm volatile ("nop");
            }
            data_out[idx] = self.dr.b;
        }
    }
};

pub const spi1: *volatile Spi = @ptrFromInt(SPI1_BASE);
pub const spi2: *volatile Spi = @ptrFromInt(SPI2_BASE);
pub const spi3: *volatile Spi = @ptrFromInt(SPI3_BASE);
pub const spi4: *volatile Spi = @ptrFromInt(SPI4_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x22, @sizeOf(Spi));
}
