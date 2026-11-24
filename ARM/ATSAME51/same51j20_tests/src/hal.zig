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
const cmcc = @import("cmcc");

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

const SPI_INSTANCE = sercom.sercom4;
const SPI_PORT = 1;
//--------------------------
const SPI_RX_PIN = 11;
const SPI_RX_PIN_MASK = 1 << SPI_RX_PIN;
const SPI_DIPO = 3;
//--------------------------
const SPI_TX_PIN = 8;
const SPI_TX_PIN_MASK = 1 << SPI_TX_PIN;
const SPI_DOPO = 0;
//--------------------------
const SPI_CLK_PIN = 9;
const SPI_CLK_PIN_MASK = 1 << SPI_CLK_PIN;
//--------------------------
const SPI_CS_PORT = 1;
const SPI_CS_PIN = 10;
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
    mclk.mclk.apbdmask.sercom4 = true;
    gclk.channelEnable(.sercom4_core, 0);
    //I2C
    mclk.mclk.apbbmask.sercom3 = true;
    gclk.channelEnable(.sercom3_core, 0);
    //Timer
    mclk.mclk.apbcmask.tc5 = true;
    gclk.channelEnable(.tc4_tc5, 0);
    mclk.mclk.apbcmask.trng = true;
    mclk.mclk.apbcmask.aes = true;
    mclk.mclk.apbamask.rtc = true;
}

inline fn timerInit() void {
    timer_interrupt = false;
    TIMER_INSTANCE.initTimerInterrupt(@truncate(cpu.cpu.current_frequency / 1024), .div1024);
    nvic.enableInterrupt(interrupts.Interrupt.TC5.toU8());
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
    nvic.enableInterrupt(interrupts.Interrupt.SERCOM3_0.toU8());
    nvic.enableInterrupt(interrupts.Interrupt.SERCOM3_1.toU8());
    nvic.enableInterrupt(interrupts.Interrupt.SERCOM3_OTHER.toU8());
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
    spiCsSet();
    port.ports[SPI_CS_PORT].dirset = SPI_CS_PIN_MASK;
}

inline fn dsuInit() void {
    pac.pac.wrctrl = pac.PacWrctrl{.key = .clr, .perid = .dsu};
}

inline fn dmaInit() void {
    dmac.init();
}

fn usartCallback(data: u8) void {
    sh.processChar(0, data);
}

export fn SystemInit() callconv(.c) void {
    cmcc.cacheEnable();
    scb.scb.cpacr = scb.ScbCpacr{.cp10 = .full_access, .cp11 = .full_access};
    board.init(&usartCallback, true);
    clocksInit();
    timerInit();
    i2cInit();
    spiInit();
    trng.init();
    rtc.init(.count32);
    dsuInit();
    dmaInit();
    wdt.init(10000);
}

pub inline fn timerStart() void {
    TIMER_INSTANCE.ctrla.enable = true;
}

pub fn flashWrite(address: usize, data: []const u8) nvmctrl.NvmctrlError!void {
    try nvmctrl.writePage(address, data);
}

pub fn flashSectorErase(address: usize) nvmctrl.NvmctrlError!void {
    try nvmctrl.blockErase(address);
}

pub fn reboot() void {
    scb.reboot();
}

pub fn wdtReset() void {
    wdt.reset();
}

pub fn getResetCause() []const u8 {
    return rstc.getResetCause();
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

fn spiCsSet() void {
    port.ports[SPI_CS_PORT].outset = SPI_CS_PIN_MASK;
}

fn spiCsClr() void {
    port.ports[SPI_CS_PORT].outclr = SPI_CS_PIN_MASK;
}

pub fn spiSendReceive(channel: usize, wdata: []const u8, rdata: []u8) bool {
    _ = channel;
    spiCsClr();
    SPI_INSTANCE.spi.sendReceivePoll8(wdata, rdata);
    spiCsSet();
    return true;
}
