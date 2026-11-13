const SPI1_BASE = 0x40013000;
const SPI2_BASE = 0x40003800;
const SPI3_BASE = 0x40003C00;

pub const SpiCr1 = bitpack struct(u32) {
    spe: bool = false,
    reserved0: u7 = 0,
    masrx: bool = false,
    cstart: bool = false,
    csusp: bool = false,
    hddir: bool = false,
    ssi: bool = false,
    crc33_17: bool = false,
    rcrcini: bool = false,
    tcrcini: bool = false,
    iolock: bool = false,
    reserved1: u15 = 0,
};

pub const Mbr = enum(u3) {
    div2 = 0,
    div4 = 1,
    div8 = 2,
    div16 = 3,
    div32 = 4,
    div64 = 5,
    div128 = 6,
    div256 = 7
};

pub const SpiCfg1 = bitpack struct(u32) {
    dsize: u5 = 7,
    fthlv: u4 = 0,
    udrcfg: bool = false,
    reserved0: u4 = 12,
    rxdmaen: bool = false,
    txdmaen: bool = false,
    crcsize: u5 = 7,
    reserved1: u1 = 0,
    crcen: bool = false,
    reserved3: u1 = 0,
    ddrs: bool = false,
    reserved2: u3 = 0,
    mbr: Mbr = .div2,
    bpass: bool = false,
};

pub const Comm = enum(u2) {
    full_duplex = 0,
    simplex_tx = 1,
    simplex_rx = 2,
    half_duplex = 3
};

pub const Sp = enum(u3) {
    motorola = 0,
    ti = 1
};

pub const SpiCfg2 = bitpack struct(u32) {
    mssi: u4 = 0,
    midi: u4 = 0,
    reserved0: u5 = 0,
    rdiom: bool = false,
    rdiop: bool = false,
    ioswp: bool = false,
    reserved1: u1 = 0,
    comm: Comm = .full_duplex,
    sp: Sp = .motorola,
    master: bool = false,
    lsbfrst: bool = false,
    cpha: bool = false,
    cpol: bool = false,
    ssm: bool = false,
    reserved2: u1 = 0,
    ssiop: bool = false,
    ssoe: bool = false,
    ssom: bool = false,
    afcntr: bool = false,
};

pub const SpiIer = bitpack struct(u32) {
    rxpie: bool = false,
    txpie: bool = false,
    dxpie: bool = false,
    eotie: bool = false,
    txtfie: bool = false,
    udrie: bool = false,
    ovrie: bool = false,
    crceie: bool = false,
    tifreie: bool = false,
    modfie: bool = false,
    reserved0: u22 = 0,
};

pub const SpiSr = bitpack struct(u32) {
    rxp: bool = false,
    txp: bool = true,
    dxp: bool = false,
    eot: bool = false,
    txtf: bool = false,
    udr: bool = false,
    ovr: bool = false,
    crce: bool = false,
    tifre: bool = false,
    modf: bool = false,
    reserved0: u1 = 0,
    susp: bool = false,
    txc: bool = true,
    rxplvl: u2 = 0,
    rxwne: bool = false,
    ctsize: u16 = 0,
};

pub const SpiIfcr = bitpack struct(u32) {
    reserved0: u3 = 0,
    eotc: bool = false,
    txtfc: bool = false,
    udrc: bool = false,
    ovrc: bool = false,
    crcec: bool = false,
    tifrec: bool = false,
    modfc: bool = false,
    reserved1: u1 = 0,
    suspc: bool = false,
    reserved2: u20 = 0,
};

const SpiDr = extern union {
    b: u8,
    h: u16,
    w: u32
};

pub const I2scfg = enum(u3) {
    slave_tx = 0,
    slave_rx = 1,
    master_tx = 2,
    master_rx = 3,
    slave_full_duplex = 4,
    master_full_duplex = 5
};

pub const I2sstd = enum(u2) {
    philips = 0,
    msb = 1,
    lsb = 2,
    pcm = 3,
};

pub const Datlen = enum(u2) {
    _16bit = 0,
    _24bit = 1,
    _32bit = 2
};

pub const SpiI2scfgr = bitpack struct(u32) {
    i2smod: bool = false,
    i2scfg: I2scfg = .slave_tx,
    i2sstd: I2sstd = .philips,
    reserved0: u1 = 0,
    pcmsync: bool = false,
    datlen: Datlen = ._16bit,
    chlen: bool = false,
    ckpol: bool = false,
    fixch: bool = false,
    wsinv: bool = false,
    datfmt: bool = false,
    reserved1: u1 = 0,
    i2sdiv: u8 = 0,
    odd: bool = false,
    mckoe: bool = false,
    reserved2: u6 = 0,
};

pub const Spi = extern struct {
    cr1: SpiCr1,
    cr2: u32,
    cfg1: SpiCfg1,
    cfg2: SpiCfg2,
    ier: SpiIer,
    sr: SpiSr,
    ifcr: SpiIfcr,
    reserved0: u32,
    txdr: SpiDr,
    reserved1: [3]u32,
    rxdr: SpiDr,
    reserved2: [3]u32,
    crcpoly: u32,
    txcrc: u32,
    rxcrc: u32,
    udrdr: u32,
    i2scfgr: SpiI2scfgr,

    pub fn initMasterSoftwareCs(self: *volatile Spi, speed: usize, clock_speed: usize, comm: Comm) void {
        if (speed == 0 or clock_speed == 0) {
            while (true) {}
        }
        var mbr: Mbr = .div2;
        const div = clock_speed / speed;
        if (div > 1) {
            if (div <= 2) {
                mbr = .div2;
            } else if (div <= 4) {
                mbr = .div4;
            } else if (div <= 8) {
                mbr = .div8;
            } else if (div <= 16) {
                mbr = .div16;
            } else if (div <= 32) {
                mbr = .div32;
            } else if (div <= 64) {
                mbr = .div64;
            } else if (div <= 128) {
                mbr = .div128;
            } else {
                mbr = .div256;
            }
            self.cfg1 = SpiCfg1{ .mbr = mbr };
        } else {
            self.cfg1 = SpiCfg1{ .bpass = true };
        }
        self.cr1.ssi = true;
        self.cfg2.ssm = true;
        self.cfg2.comm = comm;
        self.cfg2.master = true;
        self.cr1.spe = true;
        self.cr1.cstart = true;
    }

    pub fn sendPoll8(self: *volatile Spi, data: []const u8) void {
        for (data) |b| {
            while (!self.sr.txp) {
                asm volatile ("nop");
            }
            self.txdr.b = b;
            while (!self.sr.rxp) {
                asm volatile ("nop");
            }
            _ = self.rxdr.b;
        }
        self.waitForTransferComplete();
    }

    pub fn sendPoll8Simplex(self: *volatile Spi, data: []const u8) void {
        for (data) |b| {
            while (!self.sr.txp) {
                asm volatile ("nop");
            }
            self.txdr.b = b;
        }
        self.waitForTransferComplete();
    }

    pub fn waitForTransferComplete(self: *volatile Spi) void {
        while (!self.sr.txc) {
            asm volatile ("nop");
        }
    }

    pub fn sendReceivePoll8(self: *volatile Spi, data_in: []const u8, data_out: []u8) void {
        for (data_in, 0..) |b, idx| {
            while (!self.sr.txp) {
                asm volatile ("nop");
            }
            self.txdr.b = b;
            while (!self.sr.rxp) {
                asm volatile ("nop");
            }
            data_out[idx] = self.rxdr.b;
        }
        self.waitForTransferComplete();
    }

    pub fn receivePoll8(self: *volatile Spi, data_out: []u8) void {
        for (data_out) |*d| {
            while (!self.sr.txp) {
                asm volatile ("nop");
            }
            self.txdr.b = 0;
            while (!self.sr.rxp) {
                asm volatile ("nop");
            }
            d.* = self.rxdr.b;
        }
        self.waitForTransferComplete();
    }
};

pub const spi1: *volatile Spi = @ptrFromInt(SPI1_BASE);
pub const spi2: *volatile Spi = @ptrFromInt(SPI2_BASE);
pub const spi3: *volatile Spi = @ptrFromInt(SPI3_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x54, @sizeOf(Spi));
}
