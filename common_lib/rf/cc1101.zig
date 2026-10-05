const system_timer = @import("system_timer");

pub const CC1101TxPower315 = enum(u8) {
    m30 = 0x12,
    m20 = 0x0d,
    m15 = 0x1c,
    m10 = 0x34,
    _0   = 0x51,
    _5   = 0x85,
    _7   = 0xcb,
    _10  = 0xc2,

    pub inline fn toU8(self: CC1101TxPower315) u8 {
        return @intFromEnum(self);
    }
};

pub const CC1101TxPower433 = enum(u8) {
    m30 = 0x12,
    m20 = 0x0e,
    m15 = 0x1d,
    m10 = 0x34,
    _0   = 0x60,
    _5   = 0x84,
    _7   = 0xc8,
    _10  = 0xc0,

    pub inline fn toU8(self: CC1101TxPower433) u8 {
        return @intFromEnum(self);
    }
};

pub const CC1101TxPower868 = enum(u8) {
    m30 = 0x03,
    m20 = 0x17,
    m15 = 0x1d,
    m10 = 0x26,
    m6  = 0x37,
    _0   = 0x50,
    _5   = 0x86,
    _7   = 0xcd,
    _10  = 0xc5,
    _12  = 0xc0,

    pub inline fn toU8(self: CC1101TxPower868) u8 {
        return @intFromEnum(self);
    }
};

pub const CC1101TxPower915 = enum(u8) {
    m30 = 0x03,
    m20 = 0x0e,
    m15 = 0x1e,
    m10 = 0x27,
    m6  = 0x38,
    _0   = 0x8e,
    _5   = 0x84,
    _7   = 0xcc,
    _10  = 0xc3,
    _12  = 0xc0,

    pub inline fn toU8(self: CC1101TxPower915) u8 {
        return @intFromEnum(self);
    }
};

const CC1101_STROBE_SRES    = 0x30;
const CC1101_STROBE_SFSTXON = 0x31;
const CC1101_STROBE_SXOFF   = 0x32;
const CC1101_STROBE_SRX     = 0x34;
const CC1101_STROBE_STX     = 0x35;
const CC1101_STROBE_SIDLE   = 0x36;
const CC1101_STROBE_SPWD    = 0x39;
const CC1101_STROBE_SFRX    = 0x3A;
const CC1101_STROBE_SFTX    = 0x3B;
const CC1101_STROBE_SNOP    = 0x3D;

const CC1101_READ  = 0x80;
const CC1101_BURST = 0x40;

const BaudRateAndModeParameters = struct { 
    adc_retention: u8,
    fifo_thr: u8,
    synch: u8,
    syncl: u8,
    freq_if: u8,
    mode: u3,
    chanspce: u2,
    chanspcm: u8,
    mdmcfg4: u8,
    dratem: u8,
    deviatn: u8,
    foccfg: u8,
    agcctrl2: u8,
    agcctrl1: u8,
    worctrl: u8,
    fscal3: u8,
    fscal2: u8,
    fscal1: u8,
    fscal0: u8,
    test2: u8,
    test1: u8,
    test0: u8
};

const baudRateAndModeParameters: [3]BaudRateAndModeParameters = .{
    //GFSK 600
    .{
        .adc_retention = 0x40,
        .fifo_thr = 7,
        .synch = 0xD3,
        .syncl = 0x91,
        .freq_if = 6,
        .mode = 1, // GFSK
        .chanspce = 2,
        .chanspcm = 0xF8,
        .mdmcfg4 = 0xF4,
        .dratem = 0x83,
        .deviatn = 0x15,
        .foccfg = 0x16,
        .agcctrl2 = 3,
        .agcctrl1 = 0x40,
        .worctrl = 0xFB,
        .fscal3 = 0xE9,
        .fscal2 = 0x2A,
        .fscal1 = 0,
        .fscal0 = 0x1F,
        .test2 = 0x81,
        .test1 = 0x35,
        .test0 = 0x09
    },
    //GFSK 1200
    .{
        .adc_retention = 0x40,
        .fifo_thr = 7,
        .synch = 0xD3,
        .syncl = 0x91,
        .freq_if = 6,
        .mode = 1, // GFSK
        .chanspce = 2,
        .chanspcm = 0xF8,
        .mdmcfg4 = 0xF5,
        .dratem = 0x83,
        .deviatn = 0x15,
        .foccfg = 0x16,
        .agcctrl2 = 3,
        .agcctrl1 = 0x40,
        .worctrl = 0xFB,
        .fscal3 = 0xE9,
        .fscal2 = 0x2A,
        .fscal1 = 0,
        .fscal0 = 0x1F,
        .test2 = 0x81,
        .test1 = 0x35,
        .test0 = 0x09
    },
    // LaCrosse TX29IT
    .{
        .adc_retention = 0x40,
        .fifo_thr = 1,
        .synch = 0x2D,
        .syncl = 0xD4,
        .freq_if = 0x0F,
        .mode = 0, // 2-FSK
        .chanspce = 2,
        .chanspcm = 0xF8,
        .mdmcfg4 = 0x89,
        .dratem = 0x5C,
        .deviatn = 0x56,
        .foccfg = 0x16,
        .agcctrl2 = 0x43,
        .agcctrl1 = 0x68,
        .worctrl = 0xF8,
        .fscal3 = 0xE9,
        .fscal2 = 0x2A,
        .fscal1 = 0,
        .fscal0 = 0x11,
        .test2 = 0x81,
        .test1 = 0x35,
        .test0 = 0x09
    }
};

pub const CC1101Mode = enum(usize) {
    gfsk600 = 0,
    gfsk1200 = 1,
    lacrosse_tx29it = 3,

    inline fn toU8(self: CC1101Mode) usize {
        return @intFromEnum(self);
    }
};

pub const CC1101AddressCheck = enum(u2) {
    no_address_check = 0,
    address_check_no_broadcast = 1,
    address_check_0_broadcast = 2,
    address_check_0_and_255_broadcast = 3
};

pub const CC1101PktCtrl1 = packed struct(u8) {
    adr_chk: CC1101AddressCheck = .no_address_check,
    append_status: bool = true,
    crc_autoflush: bool = false,
    reserved: u1 = 0,
    pqt: u3 = 0,

    inline fn toU8(self: CC1101PktCtrl1) u8 {
        return @backingInt(self);
    }
};

pub const CC1101LengthConfig = enum(u2) {
    fixed_length = 0,
    variable_length = 1,
    infinite_length = 2
};

pub const CC1101PktFormat = enum(u2) {
    normal_mode = 0,
    sync_serial_mode = 1,
    random_tx_mode = 2,
    async_serial_mode = 3
};

pub const CC1101PktCtrl0 = packed struct(u8) {
    length_config: CC1101LengthConfig = .variable_length,
    crc_en: bool = true,
    reserved: u1 = 0,
    pkt_format: CC1101PktFormat = .normal_mode,
    white_data: bool = true,
    reserved2: u1 = 0,

    inline fn toU8(self: CC1101PktCtrl0) u8 {
        return @backingInt(self);
    }
};

pub const CC1101SyncMode = enum(u3) {
    no_sync = 0,
    sync1516 = 1,
    sync1616 = 2,
    sync3032 = 3,
    no_sync_carrier_sense = 4,
    sync1516_carrier_sense = 5,
    sync1616_carrier_sense = 6,
    sync3032_carrier_sense = 7
};

pub const CC1101MdmCfg2 = packed struct(u8) {
    sync_mode: CC1101SyncMode = .sync1616,
    manchester_en: bool = false,
    mod_format: u3 = 0,
    dem_dcfilt_off: bool = false,

    inline fn toU8(self: CC1101MdmCfg2) u8 {
        return @backingInt(self);
    }
};

pub const CC1101NumPreamble = enum(u3) {
    _2 = 0,
    _3 = 1,
    _4 = 2,
    _6 = 3,
    _8 = 4,
    _12 = 5,
    _16 = 6,
    _24 = 7
};

pub const CC1101MdmCfg1 = packed struct(u8) {
    chanspc_e: u2 = 2,
    reserved: u2 = 0,
    num_preamble: CC1101NumPreamble = ._4,
    fec_en: bool = false,

    inline fn toU8(self: CC1101MdmCfg1) u8 {
        return @backingInt(self);
    }
};

pub const CC1101Mcsm2 = packed struct(u8) {
    rx_time: u3 = 7,
    rx_time_qual: bool = false,
    rx_time_rssi: bool = false,
    reserved: u3 = 0,

    inline fn toU8(self: CC1101Mcsm2) u8 {
        return @backingInt(self);
    }
};

pub const CC1101OffMode = enum(u2) {
    idle = 0,
    fstxon = 1,
    tx = 2,
    rx = 3
};

pub const CC1101CcaMode = enum(u2) {
    always = 0,
    rssi_below_threshold = 1,
    unless_currently_receiving_packet = 2,
    rssi_below_threshold_unless_currently_receiving_packet = 3
};

pub const CC1101Mcsm1 = packed struct(u8) {
    txoff_mode: CC1101OffMode = .idle,
    rxoff_mode: CC1101OffMode = .idle,
    cca_mode: CC1101CcaMode = .rssi_below_threshold_unless_currently_receiving_packet,
    reserved: u2 = 0,

    inline fn toU8(self: CC1101Mcsm1) u8 {
        return @backingInt(self);
    }
};

pub const CC1101PoTimeout = enum(u2) {
    _2p4us = 0,
    _39us = 1,
    _155us = 2,
    _620us = 3
};

pub const CC1101FsAutocal = enum(u2) {
    never = 0,
    from_idle_torx_or_tx_or_fstxon = 1,
    from_rx_tx_to_idle = 2,
    from_rx_tx_to_idle_every_4_time = 3
};

pub const CC1101Mcsm0 = packed struct(u8) {
    xosc_force_on: bool = false,
    pin_ctrl_en: bool = false,
    po_timeout: CC1101PoTimeout,
    fs_autocal: CC1101FsAutocal,
    reserved: u2 = 0,

    inline fn toU8(self: CC1101Mcsm0) u8 {
        return @backingInt(self);
    }
};

pub const CC1101Cfg = struct {
    mode: CC1101Mode,
    crc_enabled: bool = true,
    freq: u64,
    packet_length: u8,
    pktctrl1: CC1101PktCtrl1 = .{
        .adr_chk = .address_check_0_broadcast, .append_status = true,
        .crc_autoflush = true, .pqt = 0
    },
    pktctrl0: CC1101PktCtrl0 = .{
        .crc_en = true, .white_data = true, .length_config = .variable_length,
        .pkt_format = .normal_mode
    },
    address: u8,
    channel: u8 = 0,
    freqoffset: u8 = 0,
    dem_dcfilt_off: bool = false,
    manchester_en: bool = false,
    sync_mode: CC1101SyncMode = .sync3032,
    fec_en: bool = false,
    num_preamble: CC1101NumPreamble = ._4,
    mcsm2: CC1101Mcsm2 = .{
        .rx_time = 7,
        .rx_time_qual = false,
        .rx_time_rssi = false
    },
    mcsm1: CC1101Mcsm1,
    mcsm0: CC1101Mcsm0 = .{
        .fs_autocal = .from_idle_torx_or_tx_or_fstxon,
        .po_timeout = ._155us,
        .pin_ctrl_en = false,
        .xosc_force_on = false
    },
    tx_power: u8
};

const CC1101Registers = enum(u8) {
    iocfg2   = 0,
    iocfg0   = 2,
    pktlen   = 6,
    agcctrl2 = 0x1b,
    worctrl  = 0x20,
    fscal3   = 0x23,
    test2    = 0x2c,
    patable  = 0x3e,
    fifo     = 0x3f,
    partnum = 0xf0,
    version = 0xf1,
    freqest = 0xf2,
    lqi = 0xf3,
    rssi = 0xf4,
    marcstate = 0xf5,
    txbytes = 0xfa,
    rxbytes = 0xfb,

    inline fn toU8(self: CC1101Registers) u8 {
        return @intFromEnum(self);
    }
};

const CC1101_PACKET_RECEIVED = 7;
const CC1101_RX_FIFO_FULL_OR_END_OF_THE_PACKET = 1;

const FOSC = 26000;

pub const CC1101Error = error {
    Timeout, SpiError, InvalidFrequency, InvalidTxPower, InvalidPacketLength, InvalidPartNum,
    InvalidDeviceVersion, RxBufferTooSmall
};

pub const CC1101State = enum(u3) {
    idle = 0,
    rx = 1,
    tx = 2,
    fstxon = 3,
    calibrate = 4,
    settling = 5,
    rxfifo_overflow = 6,
    txfifo_underflow = 7
};

pub const CC1101Status = packed struct(u8) {
    fifo_bytes_available: u4,
    state: CC1101State,
    chip_rdy: bool
};

pub const CC1101 = struct {
    timeout: usize,
    spi_write: *const fn([]const u8) bool,
    spi_read_write: *const fn([]u8) bool,
    spi_transfer: *const fn([]const u8, []u8) bool,
    spi_cs_set: *const fn(bool) void,
    get_gdo0: *const fn() bool,
    get_gdo2: *const fn() bool,
    rx_buffer: []u8,

    pub fn init(self: *const CC1101, cfg: *const CC1101Cfg) CC1101Error!void {
        const p = baudRateAndModeParameters[cfg.mode.toU8()];
        try self.write(&.{
            CC1101Registers.iocfg0.toU8(),
            if (cfg.crc_enabled) CC1101_PACKET_RECEIVED else CC1101_RX_FIFO_FULL_OR_END_OF_THE_PACKET,
            0x40 | p.fifo_thr,
            p.synch,
            p.syncl
        }, &.{});

        const freq: u24 = @truncate((cfg.freq << 16) / FOSC);
        const mdmcfg2 = CC1101MdmCfg2{
            .dem_dcfilt_off = cfg.dem_dcfilt_off, .manchester_en = cfg.manchester_en,
            .sync_mode = cfg.sync_mode, .mod_format = p.mode
        };
        const mdmcfg1 = CC1101MdmCfg1{
            .chanspc_e = p.chanspce,
            .fec_en = cfg.fec_en,
            .num_preamble = cfg.num_preamble
        };

        try self.write(&.{
            CC1101Registers.pktlen.toU8(),
            cfg.packet_length,
            cfg.pktctrl1.toU8(),
            cfg.pktctrl0.toU8(),
            cfg.address,
            cfg.channel,
            p.freq_if,
            cfg.freqoffset,
            @truncate(freq >> 16),
            @truncate(freq >> 8),
            @truncate(freq),
            p.mdmcfg4,
            p.dratem,
            mdmcfg2.toU8(),
            mdmcfg1.toU8(),
            p.chanspcm,
            p.deviatn,
            cfg.mcsm2.toU8(),
            cfg.mcsm1.toU8(),
            cfg.mcsm0.toU8(),
            p.foccfg
        }, &.{});

        try self.write(&.{
            CC1101Registers.agcctrl2.toU8(),
            p.agcctrl2,
            p.agcctrl1
        }, &.{});

        try self.write(&.{
            CC1101Registers.worctrl.toU8(),
            p.worctrl
        }, &.{});

        try self.write(&.{
            CC1101Registers.fscal3.toU8(),
            p.fscal3,
            p.fscal2,
            p.fscal1,
            p.fscal0
        }, &.{});

        try self.write(&.{
            CC1101Registers.test2.toU8(),
            p.test2,
            p.test1,
            p.test0
        }, &.{});

        try self.setTxPower(cfg.tx_power);
    }

    pub fn setTxPower(self: *const CC1101, tx_power: u8) CC1101Error!void {
        try self.write(&.{
            CC1101Registers.patable.toU8(),
            tx_power
        }, &.{});
    }

    pub fn check(self: *const CC1101) CC1101Error!void {
        var data: [2]u8 = undefined;
        data[0] = CC1101Registers.partnum.toU8();
        try self.read_write(&data);
        if (data[1] != 0)
            return CC1101Error.InvalidPartNum;
        data[0] = CC1101Registers.version.toU8();
        try self.read_write(&data);
        if (data[1] != 0x14)
            return CC1101Error.InvalidDeviceVersion;
    }

    pub fn powerOn(self: *const CC1101) void {
        self.spi_cs_set(false);
        self.spi_cs_set(true);
        self.spi_cs_set(false);
        system_timer.delayus(50);
        self.spi_cs_set(true);
        system_timer.delayus(50);
    }

    pub fn calculateRssi(rssi_in: u8) i16 {
        const rssi: i16 = @bitCast(rssi_in);
        if (rssi > 128)
            return (rssi - 256) / 2 - 74;
        return rssi / 2 - 74;
    }

    fn validateFrequency(frequency: u64) bool {
        return (frequency >= 430000 and frequency <= 439999) or (frequency >= 863000 and frequency <= 869999);
    }

    fn validateTxPower(tx_power: u8) bool {
        return tx_power <= CC1101TxPower433._10.toU8() and tx_power >= CC1101TxPower868.m30.toU8();
    }

    pub fn validateAndInit(self: *const CC1101, cfg: *const CC1101Cfg) CC1101Error!void {
        if (!validateFrequency(cfg.freq))
            return CC1101Error.InvalidFrequency;
        if (!validateTxPower(cfg.tx_power))
            return CC1101Error.InvalidTxPower;
        if (cfg.packet_length == 0)
            return CC1101Error.InvalidPacketLength;
        _ = try self.strobe(CC1101_STROBE_SRES);
        try self.check();
        try self.init(cfg);
    }

    pub fn receiveStart(self: *const CC1101) CC1101Error!void {
        _ = try self.strobe(CC1101_STROBE_SFRX);
        _ = try self.strobe(CC1101_STROBE_SRX);
    }

    pub fn receiveStop(self: *const CC1101) CC1101Error!void {
        _ = try self.strobe(CC1101_STROBE_SIDLE);
    }

    pub fn powerDown(self: *const CC1101) CC1101Error!void {
        _ = try self.strobe(CC1101_STROBE_SPWD);
    }

    pub fn xoff(self: *const CC1101) CC1101Error!void {
        _ = try self.strobe(CC1101_STROBE_SXOFF);
    }

    pub fn receive(self: *const CC1101) CC1101Error![]u8 {
        if (!self.get_gdo0())
            return &.{}; // no data received

        errdefer { _ = self.strobe(CC1101_STROBE_SIDLE) catch {};}

        var data: [2]u8 = undefined;
        data[0] = CC1101Registers.rxbytes.toU8();
        self.read_write(&data) catch |err| {
            _ = self.strobe(CC1101_STROBE_SFRX) catch {};
            return err;
        };
        var sz = data[1];
        if (sz >= self.rx_buffer.len)
            return CC1101Error.RxBufferTooSmall;
        sz += 1;
        data[0] = CC1101Registers.fifo.toU8() | CC1101_READ;
        try self.transfer(data[0..1], self.rx_buffer[0..sz]);
        return self.rx_buffer[2..sz];
    }

    pub fn transmit(self: *const CC1101, address: u8, data: []u8) CC1101Error!void {
        _ = try self.strobe(CC1101_STROBE_SFTX);
        errdefer { _ = self.strobe(CC1101_STROBE_SIDLE) catch {};}
        try self.write(&.{CC1101Registers.fifo.toU8(), address}, data);
        _ = try self.strobe(CC1101_STROBE_STX);
    }

    fn write(self: *const CC1101, data1: []const u8, data2: []const u8) CC1101Error!void {
        self.spi_cs_set(false);
        defer self.spi_cs_set(true);

        var t = self.timeout;
        while (t != 0) {
            if (!self.get_gdo2())
                break;
            t -= 1;
        }
        if (t == 0) {
            return CC1101Error.Timeout;
        }

        var d0: [1]u8 = .{data1[0]};
        if (data1.len + data2.len > 2) {
            d0[0] |= CC1101_BURST;
            if (!self.spi_write(&d0)) {
                return CC1101Error.SpiError;
            }
            if (!self.spi_write(data1[1..])) {
                return CC1101Error.SpiError;
            }
        } else {
            if (!self.spi_write(data1)) {
                return CC1101Error.SpiError;
            }
        }

        if (data2.len != 0 and !self.spi_write(data2)) {
            return CC1101Error.SpiError;
        }
    }

    fn transfer(self: *const CC1101, wdata: []const u8, rdata: []u8) CC1101Error!void {
        self.spi_cs_set(false);
        defer self.spi_cs_set(true);

        var t = self.timeout;
        while (t != 0) {
            if (!self.get_gdo2())
                break;
            t -= 1;
        }
        if (t == 0) {
            return CC1101Error.Timeout;
        }

        var d0: [1]u8 = .{wdata[0]};
        if (wdata.len + rdata.len > 2) {
            d0[0] |= CC1101_BURST;
            if (!self.spi_write(&d0)) {
                return CC1101Error.SpiError;
            }
            if (!self.spi_transfer(wdata[1..], rdata)) {
                return CC1101Error.SpiError;
            }
        } else {
            if (!self.spi_transfer(wdata, rdata)) {
                return CC1101Error.SpiError;
            }
        }
    }

    fn read_write(self: *const CC1101, data: []u8) CC1101Error!void {
        self.spi_cs_set(false);
        defer self.spi_cs_set(true);

        var t = self.timeout;
        while (t != 0) {
            if (!self.get_gdo2())
                break;
            t -= 1;
        }
        if (t == 0) {
            return CC1101Error.Timeout;
        }

        if (!self.spi_read_write(data)) {
            return CC1101Error.SpiError;
        }
    }

    fn strobe(self: *const CC1101, command: u8) CC1101Error!CC1101Status {
        var data: [1]u8 = .{command};
        try self.read_write(&data);
        return @bitCast(data[0]);
    }
};

pub const CC1101Device = struct {
    device: CC1101,
    cfg: CC1101Cfg
};
