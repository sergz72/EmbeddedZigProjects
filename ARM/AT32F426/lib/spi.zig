pub const SPI1_BASE = 0x40013000;
pub const SPI2_BASE = 0x40003800;

pub const SpiCtrl1 = packed struct(u16) {
    clkpha: bool = false,
    clkpol: bool = false,
    msten: bool = false,
    mdiv_l: u3 = 0,
    spien: bool = false,
    ltf: bool = false,
    swcsil: bool = false,
    swcsen: bool = false,
    ora: bool = false,
    fbn: bool = false,
    ntc: bool = false,
    ccen: bool = false,
    slbtd: bool = false,
    slben: bool = false
};

pub const SpiCtrl2 = packed struct(u16) {
    dmaren: bool = false,
    dmaten: bool = false,
    hwcsoe: bool = false,
    reserved1: u1 = 0,
    tien: bool = false,
    errie: bool = false,
    rdbfie: bool = false,
    tdbeie: bool = false,
    mdiv_h: u1 = 0,
    mdiv3en: bool = false,
    reserved: u6 = 0
};

pub const SpiSts = packed struct(u16) {
    rdbf: bool,
    tdbe: bool,
    acs: bool,
    tuerr: bool,
    ccerr: bool,
    mmerr: bool,
    roerr: bool,
    bf: bool,
    cspas: bool,
    reserved: u7
};

pub const SpiI2sCtrl = packed struct(u16) {
    i2scbn: bool = false,
    i2sdbn: u2 = 0,
    i2sclkpol: bool = false,
    stdsel: u2 = 0,
    reserved: u1 = 0,
    pcmfssel: bool = false,
    opersel: u2 = 0,
    i2sen: bool = false,
    i2smsel: bool = false,
    reserved2: u4 = 0
};

pub const SpiI2sClk = packed struct(u16) {
    i2sdiv_l: u8 = 2,
    i2sodd: bool = false,
    i2smclkoe: bool = false,
    i2sdiv_h: u2 = 0,
    reserved: u4 = 0
};

pub const Spi = extern struct {
    ctrl1: SpiCtrl1,
    reserved: u16,
    ctrl2: SpiCtrl2,
    reserved2: u16,
    sts: SpiSts,
    reserved3: u16,
    dt: u16,
    reserved4: u16,
    cpoly: u16,
    reserved5: u16,
    rcrc: u16,
    reserved6: u16,
    tcrc: u16,
    reserved7: u16,
    i2sctrl: SpiI2sCtrl,
    reserved8: u16,
    i2sclk: SpiI2sClk,

    pub fn initMasterSoftwareCs(self: *volatile Spi, speed: usize, clock_speed: usize) void {
        if (speed == 0) {
            while (true) {}
        }
        var div_l: u3 = 0;
        var div_h: u1 = 0;
        const div = clock_speed / speed;
        if (div > 2) {
            if (div <= 4) {
                div_l = 1;
            } else if (div <= 8) {
                div_l = 2;
            } else if (div <= 16) {
                    div_l = 3;
            } else if (div <= 32) {
                div_l = 4;
            } else if (div <= 64) {
                div_l = 5;
            } else if (div <= 128) {
                div_l = 6;
            } else if (div <= 256) {
                div_l = 7;
            } else if (div <= 512) {
                div_l = 0;
                div_h = 1;
            } else {
                div_l = 1;
                div_h = 1;
            }
        }
        const v2: SpiCtrl2 = .{.mdiv_h = div_h};
        self.ctrl2 = v2;
        const v: SpiCtrl1 = .{.msten = true, .mdiv_l = div_l, .swcsil = true, .swcsen = true, .spien = true};
        self.ctrl1 = v;
    }

    pub fn sendPoll8(self: *volatile Spi, data: []const u8) void {
        for (data) |b| {
            while (!self.sts.tdbe) {
                asm volatile ("nop");
            }
            self.dt = b;
            while (!self.sts.rdbf) {
                asm volatile ("nop");
            }
            _ = self.dt;
        }
    }

    pub fn waitForTransferComplete(self: *volatile Spi) void {
        while (self.sts.bf) {
            asm volatile ("nop");
        }
    }

    pub fn sendReceivePoll8(self: *volatile Spi, data_in: []const u8, data_out: []u8) void {
        var idx: usize = 0;
        for (data_in) |b| {
            while (!self.sts.tdbe) {
                asm volatile ("nop");
            }
            self.dt = b;
            while (!self.sts.rdbf) {
                asm volatile ("nop");
            }
            data_out[idx] = @truncate(self.dt);
            idx += 1;
        }
    }

    pub fn receivePoll8(self: *volatile Spi, data_out: []u8) void {
        for (0..data_out.len) |idx| {
            while (!self.sts.tdbe) {
                asm volatile ("nop");
            }
            self.dt = 0;
            while (!self.sts.rdbf) {
                asm volatile ("nop");
            }
            data_out[idx] = @truncate(self.dt);
        }
    }
};

pub const spi1: *volatile Spi = @ptrFromInt(SPI1_BASE);
pub const spi2: *volatile Spi = @ptrFromInt(SPI2_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x22, @sizeOf(Spi));
}
