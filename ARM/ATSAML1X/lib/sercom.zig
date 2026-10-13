const port = @import("port");

const SERCOM0_BASE = 0x42000400;
const SERCOM1_BASE = 0x42000800;
const SERCOM2_BASE = 0x42000C00;

pub const SercomMode = enum(u3) {
    usart_ext_clk = 0,
    usart_int_clk = 1,
    spi_client = 2,
    spi_host = 3,
    i2c_client = 4,
    i2c_host = 5
};

pub const SercomI2cInactOut = enum(u2) {
    disabled = 0,
    _55us = 1,
    _105us = 2,
    _205us = 3
};

pub const SercomI2cHostCtrlA = packed struct(u32) {
    swrst: bool = false,
    enable: bool = false,
    mode: SercomMode = .usart_ext_clk,
    reserved: u2 = 0,
    runstdby: bool = false,
    reserved2: u8 = 0,
    pinout: bool = false,
    reserved3: u3 = 0,
    sdahold: SercomSdaHold = .disabled,
    mexttoen: bool = false,
    sexttoen: bool = false,
    speed: SercomI2cSpeed = .standard,
    reserved5: u1 = 0,
    sclsm: bool = false,
    inactout: SercomI2cInactOut = .disabled,
    lowtouten: bool = false,
    reserved7: u1 = 0
};

pub const SercomI2cHostCmd = enum(u2) {
    none = 0,
    repeated_start = 1,
    byte_read = 2,
    stop = 3
};

pub const SercomI2cHostCtrlB = packed struct(u32) {
    reserved: u8 = 0,
    smen: bool = false,
    gcen: bool = false,
    reserved3: u6 = 0,
    cmd: SercomI2cHostCmd = .none,
    ackact: bool = false,
    reserved5: u13 = 0
};

pub const SercomI2cHostInt = packed struct(u8) {
    mb: bool = false,
    sb: bool = false,
    reserved: u5 = 0,
    err: bool = false
};

pub const SercomI2cBusState = enum(u2) {
    unknown = 0,
    idle = 1,
    owner = 2,
    busy = 3
};

pub const SercomI2cHostStatus = packed struct(u16) {
    buserr: bool = false,
    arblost: bool = false,
    rxnack: bool = false,
    reserved: u1 = 0,
    busstate: SercomI2cBusState = .unknown,
    lowtout: bool = false,
    clkhold: bool = false,
    mexttout: bool = false,
    sexttout: bool = false,
    lenerr: bool = false,
    reserve3: u5 = 0
};

pub const SercomI2cHostSyncBusy = packed struct(u32) {
    swrst: bool,
    enable: bool,
    sysop: bool,
    reserved: u29
};

pub const SercomI2cHostAddr = packed struct(u32) {
    addr: u11 = 0,
    reserved: u2 = 0,
    lenen: bool = false,
    hs: bool = false,
    tenbiten: bool = false,
    len: u8 = 0,
    reserved2: u8 = 0
};

pub const SercomI2cHostBaud = packed struct(u32) {
    baud: u8 = 0,
    baudlow: u8 = 0,
    hsbaud: u8 = 0,
    hsbaudlow: u8 = 0
};

pub const I2CHostInitParameters = struct {
    sclsm: bool,
    baud: usize,
    clock_frequency: usize,
    scl_pin: usize,
    sda_pin: usize,
    pmux: port.PortFunction
};

pub const SercomI2cHost = extern struct {
    ctrla: SercomI2cHostCtrlA,
    ctrlb: SercomI2cHostCtrlB,
    reserved1: u32,
    baud: SercomI2cHostBaud,
    reserved2: u32,
    intenclr: SercomI2cHostInt,
    reserved3: u8,
    intenset: SercomI2cHostInt,
    reserved4: u8,
    intflag: SercomI2cHostInt,
    reserved5: u8,
    status: SercomI2cHostStatus,
    syncbusy: SercomI2cHostSyncBusy,
    reserved6: u32,
    addr: SercomI2cHostAddr,
    data: u16,
    reserved7: [6]u8,
    dbgctrl: u8,
    reserved8: [3]u8,

    pub fn init(self: *volatile SercomI2cHost, parameters: I2CHostInitParameters) bool {
        if (parameters.baud == 0) {
            return false;
        }
        const coef = parameters.clock_frequency / parameters.baud;
        if (coef < 10) {
            return false;
        }
        const b = (coef - 10) / 2;
        if (b > 255) {
            return false;
        }

        port.ports[0].pincfg[parameters.scl_pin] = .{.pmuxen = true, .pullen = true};
        port.ports[0].pincfg[parameters.sda_pin] = .{.pmuxen = true, .pullen = true};
        port.ports[0].pmux[parameters.sda_pin/2] = .{.pmuxe = parameters.pmux, .pmuxo = parameters.pmux};

        self.ctrla = .{.mode = .i2c_host, .sdahold = ._75ns, .sclsm = parameters.sclsm};
        self.ctrlb = .{.smen = true};
        self.baud = .{.baud = @truncate(b)};
        self.ctrla.enable = true;
        while (self.syncbusy.enable) {
            asm volatile("nop");
        }
        self.status = .{.busstate = .idle, .lenerr = true, .sexttout = true,
                        .mexttout = true, .lowtout = true, .arblost = true, .buserr = true};
        while (self.syncbusy.sysop) {
            asm volatile("nop");
        }
        self.intenset = .{.mb = true, .sb = true, .err = true};
        return true;
    }
};

pub const SercomSdaHold = enum(u2) {
    disabled = 0,
    _75ns = 1,
    _450ns = 2,
    _600ns = 3
};

pub const SercomI2cSpeed = enum(u2) {
    standard = 0,
    fast = 1,
    high = 2
};

pub const SercomI2cClientCtrlA = packed struct(u32) {
    swrst: bool = false,
    enable: bool = false,
    mode: SercomMode = .usart_ext_clk,
    reserved: u2 = 0,
    runstdby: bool = false,
    reserved2: u8 = 0,
    pinout: bool = false,
    reserved3: u3 = 0,
    sdahold: SercomSdaHold = .disabled,
    reserved4: u1 = 0,
    sexttoen: bool = false,
    speed: SercomI2cSpeed = .standard,
    reserved5: u1 = 0,
    sclsm: bool = false,
    reserved6: u2 = 0,
    lowtout: bool = false,
    reserved7: u1 = 0
};

pub const SercomI2cClientCmd = enum(u2) {
    none = 0,
    start_wait = 2,
    byte_read = 3
};

pub const SercomI2cClientCtrlB = packed struct(u32) {
    reserved: u8 = 0,
    smen: bool = false,
    gcmd: bool = false,
    aacken: bool = false,
    reserved3: u3 = 0,
    amode: SercomAmode = .mask,
    cmd: SercomI2cClientCmd = .none,
    ackact: bool = false,
    reserved5: u13 = 0
};

pub const SercomI2cClientInt = packed struct(u8) {
    prec: bool = false,
    amatch: bool = false,
    drdy: bool = false,
    reserved: u4 = 0,
    err: bool = false
};

pub const SercomI2cClientStatus = packed struct(u16) {
    buserr: bool = false,
    coll: bool = false,
    rxnack: bool = false,
    dir: bool = false,
    sr: bool = false,
    reserved: u1 = 0,
    lowtout: bool = false,
    clkhold: bool = false,
    reserved2: u1 = 0,
    sexttout: bool = false,
    hs: bool = false,
    reserve3: u5 = 0
};

pub const SercomI2cClientSyncBusy = packed struct(u32) {
    swrst: bool,
    enable: bool,
    reserved: u30
};

pub const SercomI2cClientAddr = packed struct(u32) {
    gencen: bool = false,
    addr: u10 = 0,
    reserved: u4 = 0,
    tenbiten: bool = false,
    reserved2: u1 = 0,
    addrmask: u10 = 0,
    reserved3: u5 = 0
};

pub const SercomI2cClient = extern struct {
    ctrla: SercomI2cClientCtrlA,
    ctrlb: SercomI2cClientCtrlB,
    reserved1: [3]u32,
    intenclr: SercomI2cClientInt,
    reserved2: u8,
    intenset: SercomI2cClientInt,
    reserved3: u8,
    intflag: SercomI2cClientInt,
    reserved4: u8,
    status: SercomI2cClientStatus,
    syncbusy: SercomI2cClientSyncBusy,
    reserved5: u32,
    addr: SercomI2cClientAddr,
    data: u16,
    reserved6: u16
};

pub const SercomSpiForm = enum(u4) {
    spi_frame = 0,
    spi_frame_with_address = 2
};

pub const SercomSpiCtrlA = packed struct(u32) {
    swrst: bool = false,
    enable: bool = false,
    mode: SercomMode = .usart_ext_clk,
    reserved: u2 = 0,
    runstdby: bool = false,
    ibon: bool = false,
    reserved2: u7 = 0,
    dopo: u2 = 0,
    reserved3: u2 = 0,
    dipo: u2 = 0,
    reserved4: u2 = 0,
    form: SercomSpiForm = .spi_frame,
    cpha: bool = false,
    cpol: bool = false,
    dord: bool = false,
    reserved5: u1 = 0
};

pub const SercomSpiChSize = enum(u3) {
    _8 = 0,
    _9 = 1
};

pub const SercomAmode = enum(u2) {
    mask = 0,
    addr2 = 1,
    range = 2
};

pub const SercomSpiCtrlB = packed struct(u32) {
    chsize: SercomSpiChSize = ._8,
    reserved: u3 = 0,
    ploaden: bool = false,
    reserved2: u2 = 0,
    ssde: bool = false,
    reserved3: u3 = 0,
    mssen: bool = false,
    amode: SercomAmode = .mask,
    reserved4: u1 = 0,
    rxen: bool = false,
    reserved5: u14 = 0
};

pub const SercomSpiInt = packed struct(u8) {
    dre: bool = false,
    txc: bool = false,
    rxc: bool = false,
    ssl: bool = false,
    reserved: u3 = 0,
    err: bool = false
};

pub const SercomSpiStatus = packed struct(u16) {
    reserved: u2 = 0,
    bufovf: bool = false,
    reserved2: u13 = 0
};

pub const SercomSpiSyncBusy = packed struct(u32) {
    swrst: bool,
    enable: bool,
    ctrlb: bool,
    reserved: u29
};

pub const SercomSpiAddr = packed struct(u32) {
    addr: u8 = 0,
    reserved: u8 = 0,
    addrmask: u8 = 0,
    reserved2: u8 = 0
};

pub const SercomSpi = extern struct {
    ctrla: SercomSpiCtrlA,
    ctrlb: SercomSpiCtrlB,
    reserved1: u32,
    baud: u8,
    reserved2: [7]u8,
    intenclr: SercomSpiInt,
    reserved3: u8,
    intenset: SercomSpiInt,
    reserved4: u8,
    intflag: SercomSpiInt,
    reserved5: u8,
    status: SercomSpiStatus,
    syncbusy: SercomSpiSyncBusy,
    reserved6: u32,
    addr: SercomSpiAddr,
    data: u32,
    reserved7: u32,
    dbgctrl: u8,
    reserved8: [3]u8
};

pub const SercomUsartSampr = enum(u3) {
    over16_int = 0,
    over16_frac = 1,
    over8_int = 2,
    over8_frac = 3,
    over3_int = 4
};

pub const SercomUsartForm = enum(u4) {
    usart = 0,
    usart_with_parity = 1,
    lin_client_auto_baud = 4,
    auto_baud_with_parity = 5,
    iso7816 = 7
};

pub const SercomUsartCtrlA = packed struct(u32) {
    swrst: bool = false,
    enable: bool = false,
    mode: SercomMode = .usart_ext_clk,
    reserved: u2 = 0,
    runstdby: bool = false,
    ibon: bool = false,
    rxinv: bool = false,
    txinv: bool = false,
    reserved2: u2 = 0,
    sampr: SercomUsartSampr = .over16_int,
    txpo: u2 = 0,
    reserved3: u2 = 0,
    rxpo: u2 = 0,
    sampa: u2 = 0,
    form: SercomUsartForm = .usart,
    cmode: bool = false,
    cpol: bool = false,
    dord: bool = false,
    reserved4: u1 = 0
};

pub const SercomUsartChSize = enum(u3) {
    _8 = 0,
    _9 = 1,
    _5 = 5,
    _6 = 6,
    _7 = 7
};

pub const SercomUsartCtrlB = packed struct(u32) {
    chsize: SercomUsartChSize = ._8,
    reserved: u3 = 0,
    sbmode: bool = false,
    reserved2: u1 = 0,
    colden: bool = false,
    sfde: bool = false,
    enc: bool = false,
    reserved3: u2 = 0,
    pmode: bool = false,
    reserved4: u2 = 0,
    txen: bool = false,
    rxen: bool = false,
    reserved5: u14 = 0
};

pub const SercomUsartCtrlC = packed struct(u32) {
    gtime: u3 = 0,
    reserved: u13 = 0,
    inack: bool = false,
    dsnack: bool = false,
    reserved2: u2 = 0,
    maxiter: u3 = 0,
    reserved3: u9 = 0
};

pub const SercomUsartInt = packed struct(u8) {
    dre: bool = false,
    txc: bool = false,
    rxc: bool = false,
    rxs: bool = false,
    ctsic: bool = false,
    rxbrk: bool = false,
    reserved: u1 = 0,
    err: bool = false
};

pub const SercomUsartStatus = packed struct(u16) {
    perr: bool = false,
    ferr: bool = false,
    bufovf: bool = false,
    cts: bool = false,
    isf: bool = false,
    coll: bool = false,
    txe: bool = false,
    iter: bool = false,
    reserved: u8 = 0
};

pub const SercomUsartSyncBusy = packed struct(u32) {
    swrst: bool,
    enable: bool,
    ctrlb: bool,
    rxerrcnt: bool,
    reserved: u28
};

pub const UsartInitParameters = struct {
    baud: u64,
    clock_frequency: usize,
    rxpo: u2,
    txpo: u2,
    tx_pin: usize,
    rx_pin: usize,
    pmux: port.PortFunction
};

pub const SercomUsart = extern struct {
    ctrla: SercomUsartCtrlA,
    ctrlb: SercomUsartCtrlB,
    ctrlc: SercomUsartCtrlC,
    baud: u16,
    rxpl: u8,
    reserved1: [5]u8,
    intenclr: SercomUsartInt,
    reserved2: u8,
    intenset: SercomUsartInt,
    reserved3: u8,
    intflag: SercomUsartInt,
    reserved4: u8,
    status: SercomUsartStatus,
    syncbusy: SercomUsartSyncBusy,
    rxerrcnt: u8,
    reserved5: [7]u8,
    data: u16,
    reserved6: [3]u16,
    dbgctrl: u8,
    reserved8: [3]u8,

    pub fn init(self: *volatile SercomUsart, params: UsartInitParameters) void {
        port.ports[0].pincfg[params.tx_pin] = .{.pmuxen = true};
        port.ports[0].pincfg[params.rx_pin] = .{.pmuxen = true, .inen = true, .pullen = true};
        port.ports[0].pmux[params.tx_pin/2] = .{.pmuxe = params.pmux, .pmuxo = params.pmux};

        self.baud = @truncate(65536 - (params.baud << 20) / params.clock_frequency);
        self.ctrlb = .{.rxen = true, .txen = true, .sfde = true};
        while (self.syncbusy.ctrlb) {
            asm volatile("nop");
        }
        self.ctrla = .{.dord = true, .rxpo = params.rxpo, .txpo = params.txpo, .runstdby = true,
                        .mode = .usart_int_clk, .enable = true};
        self.intenset = .{.err = true, .rxc = true};
    }

    pub fn write(self: *volatile SercomUsart, data: u8) void {
        while (!self.intflag.dre) {
            asm volatile("nop");
        }
        self.data = data;
    }
};

pub const Sercom = extern union {
    i2cs: SercomI2cClient,
    i2cm: SercomI2cHost,
    spi: SercomSpi,
    usart: SercomUsart
};

pub const sercom0: *volatile Sercom = @ptrFromInt(SERCOM0_BASE);
pub const sercom1: *volatile Sercom = @ptrFromInt(SERCOM1_BASE);
pub const sercom2: *volatile Sercom = @ptrFromInt(SERCOM2_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x2C, @sizeOf(SercomI2cClient));
    try std.testing.expectEqual(0x34, @sizeOf(SercomI2cHost));
    try std.testing.expectEqual(0x34, @sizeOf(SercomSpi));
    try std.testing.expectEqual(0x34, @sizeOf(SercomUsart));
}
