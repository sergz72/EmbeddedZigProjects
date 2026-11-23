const rcc = @import("rcc");

const PWR_BASE = 0x40007000;

pub const PwrPvdLevel = enum(u3) {
    _2v4 = 0,
    _2v6 = 1,
    _2v7 = 2,
    _2v8 = 3,
    _2v9 = 4,
    _3v0 = 5,
    _3v1 = 6,
    _3v2 = 7
};

pub const PwrVselVio18 = enum(u3) {
    _1v2 = 0,
    _1v8 = 1,
    _2v5 = 2,
    _3v3 = 3,
    power_down_discharging = 4,
    power_down_floating = 5
};

pub const PwrCtrl = bitpack struct(u32) {
    lpds: bool = false,
    reserved: u3 = 0,
    pvde: bool = false,
    pls: PwrPvdLevel = ._2v4,
    dbp: bool = false,
    vio_sw_cr: bool = false,
    vsel_vio18: PwrVselVio18 = ._1v2,
    reserved2: u19 = 0
};

pub const PwrVio18Sr = enum(u2) {
    _1v2 = 0,
    _2v5 = 1,
    _1v8 = 2,
};

pub const PwrCsr = bitpack struct(u32) {
    pvdo: bool,
    reserved0: u7,
    vio18_sr: PwrVio18Sr,
    reserved1: u22,
};

pub const Pwr = extern struct {
    ctlr: PwrCtrl,
    csr: PwrCsr,

    pub fn enable() void {
        rcc.rcc.apb1pcenr.pwren = true;
    }

    pub fn setBatteryPoweredDomainWriteAccess(self: *volatile Pwr, en: bool) void {
        self.ctlr.dbp = en;
    }
};

pub const pwr: *volatile Pwr = @ptrFromInt(PWR_BASE);