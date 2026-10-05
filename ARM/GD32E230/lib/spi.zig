const SPI0_BASE: usize = 0x40013000;
const SPI1_BASE: usize = 0x40003800;

pub const SpiPsc = enum(u3) {
    div2 = 0,
    div4 = 1,
    div8 = 2,
    div16 = 3,
    div32 = 4,
    div64 = 5,
    div128 = 6,
    div256 = 7
};

pub const SpiCtl0 = packed struct(u32) {
    ckph: bool = false,
    ckpl: bool = false,
    mstmod: bool = false,
    psc: SpiPsc = .div2,
    spien: bool = false,
    lf: bool = false,
    swnss: bool = false,
    swnssen: bool = false,
    ro: bool = false,
    ff16_crcl: bool = false,
    crcnt: bool = false,
    crcen: bool = false,
    bdooen: bool = false,
    bden: bool = false,
    reserved: u16 = 0
};

pub const SpiCtl1 = packed struct(u32) {
    dmaren: bool = false,
    dmaten: bool = false,
    nssdrv: bool = false,
    nssp: bool = false,
    tmod: bool = false,
    errie: bool = false,
    rbneie: bool = false,
    tbeie: bool = false,
    dz: u4 = 0,
    byten: bool = false,
    rxdma_odd: bool = false,
    txdma_odd: bool = false,
    reserved2: u17 = 0
};

pub const SpiStat = packed struct(u32) {
    rbne: bool,
    tbe: bool,
    i2sch: bool,
    txurerr: bool,
    crcerr: bool,
    conferr: bool,
    rxorerr: bool,
    trans: bool,
    ferr: bool,
    rxlvl: u2,
    txlvl: u2,
    reserved: u19
};

pub const SpiI2sCtl = packed struct(u32) {
    chlen: bool = false,
    dtlen: u2 = 0,
    ckpl: bool = false,
    i2sstd: u2 = 0,
    reserved: u1 = 0,
    psmsmod: bool = false,
    i2sopmod: u2 = 0,
    i2sen: bool = false,
    i2ssel: bool = false,
    reserved2: u20 = 0
};

pub const SpiI2sPsc = packed struct(u32) {
    div: u8 = 0,
    of: bool = false,
    mckoen: bool = false,
    reserved: u22 = 0
};

pub const SpiQctl = packed struct(u32) {
    qmod: bool = false,
    qrd: bool = false,
    io23_drv: bool = false,
    reserved: u29 = 0
};

const SpiData = extern union {
    b: u8,
    h: u16,
    w: u32
};

pub const Spi = extern struct {
    ctl0: SpiCtl0,
    ctl1: SpiCtl1,
    stat: SpiStat,
    data: SpiData,
    crcpoly: u32,
    rcrc: u32,
    tcrc: u32,
    i2sctl: SpiI2sCtl,
    i2spsc: SpiI2sPsc,
    reserved: [23]u32,
    //0x80
    qctl: SpiQctl,

    pub fn sendPoll8(self: *volatile Spi, data: []const u8) void {
        for (data) |b| {
            while (!self.stat.tbe) {
                asm volatile ("nop");
            }
            self.data.b = b;
            while (!self.stat.rbne) {
                asm volatile ("nop");
            }
            _ = self.data.b;
        }
    }

    pub fn waitForTransferComplete(self: *volatile Spi) void {
        while (self.stat.trans) {
            asm volatile ("nop");
        }
    }

    pub fn sendReceivePoll8(self: *volatile Spi, data_in: []const u8, data_out: []u8) void {
        var idx: usize = 0;
        for (data_in) |b| {
            while (!self.stat.tbe) {
                asm volatile ("nop");
            }
            self.data.b = b;
            while (!self.stat.rbne) {
                asm volatile ("nop");
            }
            data_out[idx] = self.data.b;
            idx += 1;
        }
    }

    pub fn receivePoll8(self: *volatile Spi, data_out: []u8) void {
        for (0..data_out.len) |idx| {
            while (!self.stat.tbe) {
                asm volatile ("nop");
            }
            self.data.b = 0;
            while (!self.stat.rbne) {
                asm volatile ("nop");
            }
            data_out[idx] = self.data.b;
        }
    }

    pub fn transferPoll8(self: *volatile Spi, write_data: []const u8, read_data: ?[]u8) void {
        self.sendPoll8(write_data);
        if (read_data != null)
            self.receivePoll8(read_data.?);
    }
};

pub const spi0: *volatile Spi = @ptrFromInt(SPI0_BASE);
pub const spi1: *volatile Spi = @ptrFromInt(SPI1_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x84, @sizeOf(Spi));
}
