const std = @import("std");
const spi = @import("spi");
const gpio = @import("gpio");
const cc1101 = @import("cc1101");

pub const CC1101DeviceConfig = struct {
    spi_bus_number:       usize,
    spi_device_number:    usize,
    gd0_gpio_chip_number: usize,
    gd0_gpio_pin:         u32,
    gd2_gpio_chip_number: usize,
    gd2_gpio_pin:         u32,
    cs_gpio_chip_number:  usize,
    cs_gpio_pin:          u32,
    pqt:                  u3,
    crc_auto_flush:       bool,
    address_check:        cc1101.CC1101AddressCheck,
    white_data:           bool,
    crc_enabled:          bool,
    packet_length:        u8,
    packet_length_config: cc1101.CC1101LengthConfig,
    address:              u8,
    channel:              u8,
    freq_offset:          u8,
    frequency:            u24,
    dem_dc_filt_off:      bool,
    mode:                 cc1101.CC1101Mode,
    manchester_en:        bool,
    sync_mode:            cc1101.CC1101SyncMode,
    enable_fec:           bool,
    num_preamble:         cc1101.CC1101NumPreamble,
    rx_time_rssi:         bool,
    rx_time_qual:         bool,
    rx_time:              u3,
    cca_mode:             cc1101.CC1101CcaMode,
    rxoff_mode:           cc1101.CC1101OffMode,
    txoff_mode:           cc1101.CC1101OffMode,
    autocal:              cc1101.CC1101FsAutocal,
    po_timeout:           cc1101.CC1101PoTimeout,
    enable_pin_control:   bool,
    forcexosc_on:         bool,
    tx_power:             cc1101.CC1101TxPower
};

const ValidationResult = struct {
    pktctrl1: cc1101.CC1101PktCtrl1 = undefined
};

pub const InternalError = error {
    JsonParseError
};

pub const CC1101DeviceError = cc1101.CC1101Error || std.Io.Dir.ReadFileAllocError || InternalError || spi.SPIError ||
            gpio.GpioError;

const init_data: cc1101.CC1101init = .{
    .timeout = 1000000,
    .spi_write = CC1101Device.spiWrite,
    .spi_read_write = CC1101Device.spiReadWrite,
    .spi_transfer = CC1101Device.spiTransfer,
    .spi_cs_set = CC1101Device.spiCsSet,
    .get_gdo0 = CC1101Device.getGdo0,
    .get_gdo2 = CC1101Device.getGdo2
};

pub const CC1101Device = struct {
    bus:      spi.SPIMaster = undefined,
    gd0_port: gpio.GPIO = undefined,
    gd0_pin:  gpio.GPIOPin = undefined,
    gd2_port: ?gpio.GPIO = null,
    gd2_pin:  gpio.GPIOPin = undefined,
    cs_port:  ?gpio.GPIO = null,
    cs_pin:   gpio.GPIOPin = undefined,
    device:   cc1101.CC1101 = undefined,

    pub fn close(self: *CC1101Device) void {
        self.bus.close();
        self.gd0_pin.close();
        self.gd2_pin.close();
        self.cs_pin.close();
        self.gd0_port.close();
        if (self.gd2_port) |port| {
            port.close();
        }
        if (self.cs_port) |port| {
            port.close();
        }
    }

    pub fn init(self: *CC1101Device, io: std.Io, allocator: std.mem.Allocator, config_file_name: []const u8) CC1101DeviceError!void {
        const config = try buildDeviceConfiguration(io, allocator, config_file_name);
        try self.bus.init(io, allocator, config.spi_bus_number, config.spi_device_number);

        try self.gd0_port.init(io, allocator, config.gd0_gpio_chip_number);
        self.gd0_pin = try self.gd0_port.setLineInput(config.gd0_gpio_pin, gpio.GPIO_V2_LINE_FLAG_BIAS_PULL_UP);

        if (config.gd0_gpio_chip_number != config.gd2_gpio_chip_number) {
            self.gd2_port = .{};
            try self.gd2_port.?.init(io, allocator, config.gd2_gpio_chip_number);
            self.gd2_pin = try self.gd2_port.?.setLineInput(config.gd2_gpio_pin, gpio.GPIO_V2_LINE_FLAG_BIAS_PULL_UP);
        } else {
            self.gd2_pin = try self.gd0_port.setLineInput(config.gd2_gpio_pin, gpio.GPIO_V2_LINE_FLAG_BIAS_PULL_UP);
        }

        if (config.cs_gpio_chip_number != config.gd0_gpio_chip_number and config.cs_gpio_chip_number != config.gd2_gpio_chip_number) {
            self.cs_port = .{};
            try self.cs_port.?.init(io, allocator, config.cs_gpio_chip_number);
            self.cs_pin = try self.cs_port.?.setLineOutput(config.cs_gpio_pin, true, 0);
        } else  if (config.cs_gpio_chip_number == config.gd0_gpio_chip_number) {
            self.cs_pin = try self.gd0_port.setLineOutput(config.cs_gpio_pin, true, 0);
        } else {
            self.cs_pin = try self.gd2_port.?.setLineOutput(config.cs_gpio_pin, true, 0);
        }

        const device_cfg: cc1101.CC1101Cfg = .{
            .mode = config.mode,
            .freq = config.frequency,
            .packet_length = config.packet_length,
            .pktctrl1 = .{
                .adr_chk = config.address_check,
                .append_status = true,
                .crc_autoflush = true,
                .pqt = config.pqt
            },
            .pktctrl0 = .{
                .crc_en = config.crc_enabled,
                .white_data = config.white_data,
                .length_config = config.packet_length_config,
                .pkt_format = .normal_mode
            },
            .address = config.address,
            .channel = config.channel,
            .freqoffset = config.freq_offset,
            .dem_dcfilt_off = config.dem_dc_filt_off,
            .manchester_en = config.manchester_en,
            .sync_mode = config.sync_mode,
            .fec_en = config.enable_fec,
            .num_preamble = config.num_preamble,
            .mcsm2 = .{
                .rx_time = config.rx_time,
                .rx_time_qual = config.rx_time_qual,
                .rx_time_rssi = config.rx_time_rssi
            },
            .mcsm1 = .{
                .txoff_mode = config.txoff_mode,
                .rxoff_mode = config.rxoff_mode,
                .cca_mode = config.cca_mode
            },
            .mcsm0 = .{
                .fs_autocal = config.autocal,
                .po_timeout = config.po_timeout,
                .pin_ctrl_en = config.enable_pin_control,
                .xosc_force_on = config.forcexosc_on
            },
            .tx_power = config.tx_power
        };
        try self.device.validateAndInit(&device_cfg);
    }

    fn spiWrite(context: *anyopaque, data: []const u8) bool {
        const self: *CC1101Device = @ptrCast(@alignCast(context));
        var rdata: [data.len]u8 = undefined;
        try self.bus.transfer(data, &rdata) catch {
            return false;
        };
        return true;
    }

    fn spiReadWrite(context: *anyopaque, data: []u8) bool {
        const self: *CC1101Device = @ptrCast(@alignCast(context));
        try self.bus.transfer(data, data) catch {
            return false;
        };
        return true;
    }

    fn spiTransfer(context: *anyopaque, wdata: []const u8, rdata: []u8) bool {
        const self: *CC1101Device = @ptrCast(@alignCast(context));
        var wd = std.mem.zeroes([wdata.len+rdata.len]u8);
        @memcpy(wd[0..wdata.len], wdata);
        var rd: [wdata.len+rdata.len]u8 = undefined;
        try self.bus.transfer(wd, &rd) catch  {
            return false;
        };
        @memcpy(rdata, rd[wdata.len..]);
        return true;
    }

    fn spiCsSet(context: *anyopaque, level: bool) bool {
        const self: *CC1101Device = @ptrCast(@alignCast(context));
        self.cs_pin.write(level) catch {
            return false;
        };
        return true;
    }

    fn getGdo0(context: *anyopaque) ?bool {
        const self: *CC1101Device = @ptrCast(@alignCast(context));
        return self.gd0_pin.read() catch {
            return null;
        };
    }

    fn getGdo2(context: *anyopaque) ?bool {
        const self: *CC1101Device = @ptrCast(@alignCast(context));
        return self.gd2_pin.read() catch {
            return null;
        };
    }
};

fn buildDeviceConfiguration(io: std.Io, allocator: std.mem.Allocator, config_file_name: []const u8) CC1101DeviceError!CC1101DeviceConfig {
    const dir = std.Io.Dir.cwd();
    const data = try dir.readFileAlloc(io, config_file_name, allocator, .limited(10000));
    defer allocator.free(data);
    return std.json.parseFromSliceLeaky(CC1101DeviceConfig, allocator, data, .{}) catch {
        return InternalError.JsonParseError;
    };
}

test "build device configuration" {
    const config = try buildDeviceConfiguration(std.io, std.heap.page_allocator, "../cc1101Config.json");
    _ = config;
}
