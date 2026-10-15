const std = @import("std");
const port = @import("port");
const gclk = @import("gclk");
const pm = @import("pm");
const supc = @import("supc");
const sercom = @import("sercom");
const i2c = @import("i2c");
const tc = @import("tc");
const cpu = @import("cpu");
const nvic = @import("nvic");
const shell = @import("shell");
const interrupts = @import("interrupts");
const system_timer = @import("system_timer");
const hal_constants = @import("hal_constants");
const usart_writer = @import("usart_writer");

pub const INIT_DEVICES = true;

const LED_PIN = 27;
const LED_PIN_MASK: u32 = 1 << LED_PIN;

const USART_INSTANCE = sercom.sercom2;
const USART_RX_PIN = 25;
const USART_RX_PIN_MASK: u32 = 1 << USART_RX_PIN;
const USART_TX_PIN = 24;
const USART_TX_PIN_MASK: u32 = 1 << USART_TX_PIN;

const I2C_INSTANCE = sercom.sercom1;
//--------------------------
const I2C_SCL_PIN = 1;
const I2C_SCL_PIN_MASK = 1 << I2C_SCL_PIN;
const I2C_SDA_PIN = 0;
const I2C_SDA_PIN_MASK = 1 << I2C_SDA_PIN;
//------------------------------
const I2C_SCLSM = false;

const SPI_INSTANCE = sercom.sercom0;
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
const SPI_CS_PIN = 18;
const SPI_CS_PIN_MASK = 1 << SPI_CS_PIN;

pub const CC1101_TIMEOUT = 10000;
//--------------------------
const GDO0_PIN = 23;
const GDO0_PIN_MASK = 1 << GDO0_PIN;
const GDO2_PIN = 22;
const GDO2_PIN_MASK = 1 << GDO2_PIN;

const LCD_DC_PIN = 2;
const LCD_DC_PIN_MASK = 1 << LCD_DC_PIN;
const LCD_E_PIN = 3;
const LCD_E_PIN_MASK = 1 << LCD_E_PIN;
const LCD_D0_PIN = 4;
const LCD_D0_PIN_MASK = 1 << LCD_D0_PIN;
const LCD_D1_PIN = 5;
const LCD_D1_PIN_MASK = 1 << LCD_D1_PIN;
const LCD_D2_PIN = 6;
const LCD_D2_PIN_MASK = 1 << LCD_D2_PIN;
const LCD_D3_PIN = 7;
const LCD_D3_PIN_MASK = 1 << LCD_D3_PIN;
const LCD_D4_PIN = 8;
const LCD_D4_PIN_MASK = 1 << LCD_D4_PIN;
const LCD_D5_PIN = 9;
const LCD_D5_PIN_MASK = 1 << LCD_D5_PIN;
const LCD_D6_PIN = 10;
const LCD_D6_PIN_MASK = 1 << LCD_D6_PIN;
const LCD_D7_PIN = 11;
const LCD_D7_PIN_MASK = 1 << LCD_D7_PIN;
const LCD_CS1_PIN = 14;
const LCD_CS1_PIN_MASK = 1 << LCD_CS1_PIN;
const LCD_CS2_PIN = 15;
const LCD_CS2_PIN_MASK = 1 << LCD_CS2_PIN;

pub const panic = std.debug.no_panic;

pub var timer_interrupt: bool = undefined;
pub var sh: *shell.Shell = undefined;
var i2c_instance: i2c.I2cMaster = .{.instance = I2C_INSTANCE, .sclsm = I2C_SCLSM};

export fn SERCOM2_2_Handler() callconv(.c) void {
    const flags = USART_INSTANCE.usart.intflag;
    if (flags.err) {
        USART_INSTANCE.usart.intflag = .{.err = true};
    }
    if (flags.rxc) {
        sh.processChar(@truncate(USART_INSTANCE.usart.data));
    }
}

export fn TC2_Handler() callconv(.c) void {
    tc.tc2_16.intflag = .{ .ovf = true };
    timer_interrupt = true;
}

export fn SERCOM1_0_Handler() callconv(.c) void {
    i2c_instance.mbHandler();
}

export fn SERCOM1_1_Handler() callconv(.c) void {
    i2c_instance.sbHandler();
}

export fn SERCOM1_OTHER_Handler() callconv(.c) void {
    i2c_instance.errorHandler();
}

inline fn clocksInit() void {
    //SPI
    gclk.gclk.channelEnable(.sercom0_core, 0);
    //I2C
    gclk.gclk.channelEnable(.sercom1_core, 0);
    //USART
    gclk.gclk.channelEnable(.sercom2_core, 0);
    //Timer
    gclk.gclk.channelEnable(.tc2, 0);
}

inline fn usartInit() void {
    const init: sercom.UsartInitParameters = .{
        .baud = hal_constants.USART_BAUD,
        .clock_frequency = cpu.cpu.current_frequency,
        .rxpo = 3,
        .txpo = 1,
        .tx_pin = USART_TX_PIN,
        .rx_pin = USART_RX_PIN,
        .pmux = .D
    };
    USART_INSTANCE.usart.init(init);
    nvic.nvic.enableInterrupt(interrupts.Interrupt.SERCOM2_2.toU8());
    usart_writer.usart_writer.writeCharFunc = usartWrite;
}

inline fn timerInit() void {
    timer_interrupt = false;
    tc.tc2_16.setPer(@truncate(cpu.cpu.current_frequency / 1024));
    tc.tc2_16.intenset = .{.ovf = true};
    tc.tc2_16.ctrla = .{.runstdby = true, .presync = .presc, .prescaler = .div1024};
    nvic.nvic.enableInterrupt(interrupts.Interrupt.TC2.toU8());
}

inline fn i2cInit() void {
    const parameters: sercom.I2CHostInitParameters = .{
        .baud = hal_constants.I2C_SPEED,
        .clock_frequency = cpu.cpu.current_frequency,
        .scl_pin = I2C_SCL_PIN,
        .sda_pin = I2C_SDA_PIN,
        .pmux = .D,
        .sclsm = I2C_SCLSM
    };
    _ = I2C_INSTANCE.i2cm.init(parameters);
    nvic.nvic.enableInterrupt(interrupts.Interrupt.SERCOM1_0.toU8());
    nvic.nvic.enableInterrupt(interrupts.Interrupt.SERCOM1_1.toU8());
    nvic.nvic.enableInterrupt(interrupts.Interrupt.SERCOM1_OTHER.toU8());
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
        .cpol = false,
        .cpha = false
    };
    _ = SPI_INSTANCE.spi.initHost(parameters);
    port.ports[0].outset = SPI_CS_PIN_MASK;
    port.ports[0].dirset = SPI_CS_PIN_MASK;
}

inline fn cc1101Init() void {
    port.ports[0].outset = GDO2_PIN_MASK;
    port.ports[0].outclr = GDO0_PIN_MASK;
    port.ports[0].pincfg[GDO0_PIN] = .{.inen = true, .pullen = true};
    port.ports[0].pincfg[GDO2_PIN] = .{.inen = true, .pullen = true};
}

inline fn lcdInit() void {
    port.ports[0].dirset = LCD_DC_PIN_MASK | LCD_E_PIN_MASK | LCD_D0_PIN_MASK | LCD_D1_PIN_MASK | LCD_D2_PIN_MASK |
                    LCD_D3_PIN_MASK | LCD_D4_PIN_MASK | LCD_D5_PIN_MASK | LCD_D6_PIN_MASK | LCD_D7_PIN_MASK |
                    LCD_CS1_PIN_MASK | LCD_CS2_PIN_MASK;
}

export fn SystemInit() callconv(.c) void {
    pm.pm.sleepcfg = .idle;
    supc.supc.buckConverterEnable();
    system_timer.delay_init(system_timer.init_div1);
    port.ports[0].dirset = LED_PIN_MASK;
    clocksInit();
    usartInit();
    timerInit();
    i2cInit();
    spiInit();
    cc1101Init();
    lcdInit();
}

pub inline fn startTimer() void {
    tc.tc2_16.ctrla.enable = true;
}

pub fn usartWrite(byte: u8) void {
    USART_INSTANCE.usart.write(byte);
}

pub inline fn ledToggle() void {
    port.ports[0].outtgl = LED_PIN_MASK;
}

pub inline fn i2cScan(address: u10) i2c.I2cError!void {
    return i2c_instance.scan(address);
}

pub inline fn i2cRead(address: u10, data: []u8) i2c.I2cError!void {
    return i2c_instance.read(address, data);
}

pub inline fn i2cWrite(address: u10, data: []const u8) i2c.I2cError!void {
    return i2c_instance.write(address, data);
}

pub inline fn i2cTransfer(address: u10, wdata: []const u8, rdata: []u8) i2c.I2cError!void {
    return i2c_instance.transfer(address, wdata, rdata);
}

pub fn spi1CsSet(context: *anyopaque, state: bool) bool {
    _ = context;
    if (state) {
        port.ports[0].outset = SPI_CS_PIN_MASK;
    } else {
        port.ports[0].outclr = SPI_CS_PIN_MASK;
    }
    return true;
}

pub fn spiSendReceive(channel: usize, wdata: []const u8, rdata: []u8) bool {
    _ = channel;
    _ = spi1CsSet(@ptrFromInt(1), false);
    SPI_INSTANCE.spi.sendReceivePoll8(wdata, rdata);
    _ = spi1CsSet(@ptrFromInt(1), true);
    return true;
}

pub fn spi1Write(context: *anyopaque, data: []const u8) bool {
    _ = context;
    SPI_INSTANCE.spi.sendPoll8(data);
    return true;
}

pub fn spi1ReadWrite(context: *anyopaque, data: []u8) bool {
    _ = context;
    SPI_INSTANCE.spi.sendReceivePoll8(data, data);
    return true;
}

pub fn spi1Transfer(context: *anyopaque, wdata: []const u8, rdata: []u8) bool {
    _ = context;
    SPI_INSTANCE.spi.transferPoll8(wdata, rdata);
    return true;
}

pub fn getGdo01(context: *anyopaque) ?bool {
    _ = context;
    return port.ports[0].in & GDO0_PIN_MASK != 0;
}

pub fn getGdo21(context: *anyopaque) ?bool {
    _ = context;
    return port.ports[0].in & GDO2_PIN_MASK != 0;
}

inline fn setLcdData(data: u8) void {
    var out = port.ports[0].out;
    const mask = ~(@as(u32, 0xFF) << LCD_D0_PIN);
    out &= mask;
    out |= @as(u32, data) << LCD_D0_PIN;
    port.ports[0].out = out;
}

inline fn setLcdCs(cs: u2) void {
    if (cs & 1 != 0) {
        port.ports[0].outset = LCD_CS1_PIN_MASK;
    } else {
        port.ports[0].outclr = LCD_CS1_PIN_MASK;
    }
    if (cs & 2 != 0) {
        port.ports[0].outset = LCD_CS2_PIN_MASK;
    } else {
        port.ports[0].outclr = LCD_CS2_PIN_MASK;
    }
}

inline fn setLcdDc(dc: bool) void {
    if (dc) {
        port.ports[0].outset = LCD_DC_PIN_MASK;
    } else {
        port.ports[0].outclr = LCD_DC_PIN_MASK;
    }
}

inline fn setLcdE(e: bool) void {
    if (e) {
        port.ports[0].outset = LCD_E_PIN_MASK;
    } else {
        port.ports[0].outclr = LCD_E_PIN_MASK;
    }
}

pub fn lcdWrite(data: u8, cs: u2, dc: bool) void {
    setLcdData(data);
    setLcdCs(cs);
    setLcdDc(dc);
    setLcdE(true);
    system_timer.delayLoopus(1);
    setLcdE(false);
    system_timer.delayLoopus(1);
    setLcdCs(0);
}

pub fn lcdReset(state: bool) void {
    _ = state;
    //rst pin us not connected
}

pub inline fn enterSleep() void {
    pm.pm.enterStandby();
}