const rcc = @import("rcc");

const PWR_BASE = 0x40007000;

pub const PwrPvdLevel = enum(u3) {
    _2v3 = 0,
    _2v5 = 1,
    _2v6 = 2,
    _2v7 = 3,
    _2v8 = 4,
    _3v0 = 5,
    _3v1 = 6,
    _3v2 = 7
};

pub const PwrCtrl = packed struct(u32) {
    lpds: bool = false,
    pdds: bool = false,
    cwuf: bool = false,
    csbf: bool = false,
    pvde: bool = false,
    pls: PwrPvdLevel = ._2v3,
    dbp: bool = false,
    reserved: u7 = 0,
    r2ksty: bool = false,
    r30ksty: bool = false,
    r2kvbat: bool = false,
    r30kvbat: bool = false,
    ramlv: bool = false,
    reserved2: u11 = 0
};

pub const PwrCsr = packed struct(u32) {
    wuf: bool = false,
    sbf: bool = false,
    pvdo: bool = false,
    reserved: u5 = 0,
    ewup: bool = false,
    reserved2: u23 = 0
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