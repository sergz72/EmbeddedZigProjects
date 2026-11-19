const std = @import("std");
const board = @import("board");
const tc = @import("tc");
const cpu = @import("cpu");
const gclk = @import("gclk");
const mclk = @import("mclk");
const nvic = @import("nvic");
const interrupts = @import("interrupts");
const sercom = @import("sercom");
const scd4x = @import("scd4x");
const veml = @import("veml7700");
const shell = @import("shell");
const scb = @import("scb");
const wdt = @import("wdt");
const nvmctrl = @import("nvmctrl");
const trng = @import("trng");
const rstc = @import("rstc");
const rtc = @import("rtc");
const i2c = @import("i2c");
const port = @import("port");
const pac = @import("pac");
const dmac = @import("dmac");

const TIMER_INSTANCE = tc.tc5_16;

const I2C_INSTANCE = sercom.sercom3;
const I2C_PORT = 0;
//--------------------------
const I2C_SCL_PIN = 23;
const I2C_SCL_PIN_MASK = 1 << I2C_SCL_PIN;
const I2C_SDA_PIN = 22;
const I2C_SDA_PIN_MASK = 1 << I2C_SDA_PIN;
//------------------------------
const I2C_SCLSM = false;
const I2C_SPEED = 100000;

const SPI_INSTANCE = sercom.sercom0;
const SPI_PORT = 0;
//--------------------------
const SPI_RX_PIN = 19;
const SPI_RX_PIN_MASK = 1 << SPI_RX_PIN;
const SPI_DIPO = 3;
//--------------------------
const SPI_TX_PIN = 16;
const SPI_TX_PIN_MASK = 1 << SPI_TX_PIN;
const SPI_DOPO = 0;
//--------------------------
const SPI_CLK_PIN = 17;
const SPI_CLK_PIN_MASK = 1 << SPI_CLK_PIN;
//--------------------------
const SPI_CS_PORT = 0;
const SPI_CS_PIN = 18;
const SPI_CS_PIN_MASK = 1 << SPI_CS_PIN;

pub var timer_interrupt: bool = undefined;
pub var sh: *shell.Shell = undefined;
pub var scd_device: scd4x.SCD4x = .{.i2c_read = scdRead, .i2c_write = scdWrite};
pub var veml_device: veml.VEML7700 = .{.i2c_read = vemlRead, .i2c_write = vemlWrite};
var i2c_instance: i2c.I2cMaster = .{.instance = I2C_INSTANCE, .sclsm = I2C_SCLSM};

export fn TC5_Handler() callconv(.c) void {
    TIMER_INSTANCE.intflag = .{ .mc0 = true };
    timer_interrupt = true;
}

export fn SERCOM3_0_Handler() callconv(.c) void {
    i2c_instance.mbHandler();
}

export fn SERCOM3_1_Handler() callconv(.c) void {
    i2c_instance.sbHandler();
}

export fn SERCOM3_OTHER_Handler() callconv(.c) void {
    i2c_instance.errorHandler();
}

inline fn clocksInit() void {
    //SPI
    //gclk.gclk.channelEnable(.sercom0_core, 0);
    //I2C
    mclk.mclk.apbbmask.sercom3 = true;
    gclk.gclk.channelEnable(.sercom3_core, 0);
    //Timer
    mclk.mclk.apbcmask.tc5 = true;
    gclk.gclk.channelEnable(.tc4_tc5, 0);
    mclk.mclk.apbcmask.trng = true;
    mclk.mclk.apbcmask.aes = true;
    mclk.mclk.apbamask.rtc = true;
}

inline fn timerInit() void {
    timer_interrupt = false;
    TIMER_INSTANCE.initTimerInterrupt(@truncate(cpu.cpu.current_frequency / 1024), .div1024);
    nvic.nvic.enableInterrupt(interrupts.Interrupt.TC5.toU8());
}

inline fn i2cInit() void {
    const parameters: sercom.I2CHostInitParameters = .{
        .baud = I2C_SPEED,
        .clock_frequency = cpu.cpu.current_frequency,
        .scl_pin = I2C_SCL_PIN,
        .sda_pin = I2C_SDA_PIN,
        .pmux = .C,
        .port = I2C_PORT,
        .sclsm = I2C_SCLSM
    };
    _ = I2C_INSTANCE.i2cm.init(parameters);
    nvic.nvic.enableInterrupt(interrupts.Interrupt.SERCOM3_0.toU8());
    nvic.nvic.enableInterrupt(interrupts.Interrupt.SERCOM3_1.toU8());
    nvic.nvic.enableInterrupt(interrupts.Interrupt.SERCOM3_OTHER.toU8());
}

inline fn spiInit() void {
    const parameters: sercom.SpiHostInitParameters = .{
        .baud = 1000000,
        .clock_frequency = cpu.cpu.current_frequency,
        .dipo = SPI_DIPO,
        .dopo = SPI_DOPO,
        .tx_pin = SPI_TX_PIN,
        .rx_pin = SPI_RX_PIN,
        .sck_pin = SPI_CLK_PIN,
        .ss_pin = null,
        .pmux = .D,
        .port = SPI_PORT,
        .cpol = false,
        .cpha = false
    };
    _ = SPI_INSTANCE.spi.initHost(parameters);
    port.ports[SPI_CS_PORT].outset = SPI_CS_PIN_MASK;
    port.ports[SPI_CS_PORT].dirset = SPI_CS_PIN_MASK;
}

inline fn dsuInit() void {
    pac.pac.wrctrl = pac.PacWrctrl{.key = .clr, .perid = .dsu};
}

inline fn dmaInit() void {
    dmac.dmac.init();
}

fn usartCallback(data: u8) void {
    sh.processChar(0, data);
}

export fn SystemInit() callconv(.c) void {
    scb.scb.cpacr = scb.ScbCpacr{.cp10 = .full_access, .cp11 = .full_access};
    board.init(&usartCallback);
    clocksInit();
    timerInit();
    i2cInit();
    //spiInit();
    trng.trng.init();
    rtc.rtc.init();
    //dsuInit();
    dmaInit();
    wdt.wdt.init(10000);
}

pub inline fn timerStart() void {
    TIMER_INSTANCE.ctrla.enable = true;
}

pub fn flashWrite(address: usize, data: []const u8) nvmctrl.NvmctrlError!void {
    try nvmctrl.nvmctrl.writePage(address, data);
}

pub fn flashSectorErase(address: usize) nvmctrl.NvmctrlError!void {
    try nvmctrl.nvmctrl.pageErase(address);
}

pub fn reboot() void {
    scb.scb.reboot();
}

pub fn wdtReset() void {
    wdt.wdt.reset();
}

pub fn getResetCause() []const u8 {
    return rstc.rstc.getResetCause();
}

pub fn i2cScan(channel: usize, address: u10) [2]u8 {
    if (channel != 0)
        return [2]u8{'e', 'c'};
    i2c_instance.scan(address) catch |err| {
        const e: []const u8 = @errorName(err);
        return [2]u8{e[0], e[1]};
    };
    return [2]u8{0,0};
}

pub fn scdRead(data: []u8) bool {
    i2c_instance.read(scd4x.SCD4X_SENSOR_ADDR, data) catch |err| {
        scd_device.i2c_error_name = @errorName(err);
        return false;
    };
    return true;
}

pub fn scdWrite(data: []const u8) bool {
    i2c_instance.write(scd4x.SCD4X_SENSOR_ADDR, data) catch |err| {
        scd_device.i2c_error_name = @errorName(err);
        return false;
    };
    return true;
}

pub fn vemlRead(reg: u8) ?u16 {
    var rdata: [2]u8 = undefined;
    i2c_instance.transfer(veml.VEML7700_I2C_ADDRESS, &[_]u8{ reg }, &rdata) catch |err| {
        veml_device.i2c_error_name = @errorName(err);
        return null;
    };
    return std.mem.readInt(u16, &rdata, .little);
}

pub fn vemlWrite(reg: u8, data: u16) bool {
    const wdata: []const u8 = &.{reg, @truncate(data), @truncate(data >> 8)};
    i2c_instance.write(veml.VEML7700_I2C_ADDRESS, wdata) catch |err| {
        veml_device.i2c_error_name = @errorName(err);
        return false;
    };
    return true;
}

pub fn spiSendReceive(channel: usize, wdata: []const u8, rdata: []u8) bool {
    _ = channel;
    //board.arduinoSpiCsSet(false);
    //board.SPI_INSTANCE.sendReceivePoll8(wdata, rdata);
    //board.arduinoSpiCsSet(true);
    _ = wdata;
    _ = rdata;
    return false;
}
