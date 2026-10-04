const rcu = @import("rcu");
const gpio = @import("gpio");
const cpu = @import("cpu");
const timer = @import("timer");
const usart = @import("usart");
const nvic = @import("nvic");
const interrupts = @import("interrupts");
const system_timer = @import("system_timer");
const shell = @import("shell");
const i2c = @import("i2c");
const spi = @import("spi");
const hal_constants = @import("hal_constants");
const usart_writer = @import("usart_writer");

const LED_PIN = 13;
const LED_PIN_MASK: u16 = 1 << LED_PIN;
const LED_PORT = gpio.gpioc;
const LED_INIT: gpio.GpioInit = .{
    .mode = .output,
    .output_speed = .low
};

const USART_INSTANCE = usart.usart0;

const USART_TX_PIN = 9;
const USART_TX_PIN_MASK: u16 = 1 << USART_TX_PIN;
const USART_TX_PORT = gpio.gpioa;
const USART_TX_PIN_INIT: gpio.GpioInit = .{
    .mode = .alternate,
    .output_speed = .high,
    .alternate = 1
};

const USART_RX_PIN = 10;
const USART_RX_PIN_MASK: u16 = 1 << USART_RX_PIN;
const USART_RX_PORT = gpio.gpioa;
const USART_RX_PIN_INIT: gpio.GpioInit = .{
    .mode = .alternate,
    .pud = .pullup,
    .output_speed = .high,
    .alternate = 1
};

const TIMER_INSTANCE = timer.bctm5;

const I2C_INSTANCE = i2c.i2c1;
//--------------------------
const I2C_PORT = gpio.gpiob;
const I2C_SCL_PIN = 10;
const I2C_SCL_PIN_MASK = 1 << I2C_SCL_PIN;
const I2C_SDA_PIN = 11;
const I2C_SDA_PIN_MASK = 1 << I2C_SDA_PIN;
const I2C_PINS_INIT: gpio.GpioInit = .{
    .mode = .alternate,
    .pud = .pullup,
    .output_speed = .high,
    .open_drain = true,
    .alternate = 1
};
//------------------------------
const I2C_TIMEOUT = 10000;

const SPI_INSTANCE = spi.spi0;
//--------------------------
const SPI_PORT = gpio.gpioa;
//--------------------------
const SPI_RX_PIN = 6;
const SPI_RX_PIN_MASK: u24 = 1 << SPI_RX_PIN;
const SPI_RX_PIN_INIT: gpio.GpioInit = .{
    .mode = .alternate,
    .pud = .pullup,
    .output_speed = .high,
    .alternate = 0
};
//--------------------------
const SPI_TX_PIN = 7;
const SPI_TX_PIN_MASK: u24 = 1 << SPI_TX_PIN;
const SPI_OUT_PINS_INIT: gpio.GpioInit = .{
    .mode = .alternate,
    .output_speed = .high,
    .alternate = 0
};
//--------------------------
const SPI_CLK_PIN = 5;
const SPI_CLK_PIN_MASK: u24 = 1 << SPI_CLK_PIN;
//--------------------------
const SPI_CS_PORT = gpio.gpioa;
const SPI_CS_PIN = 4;
const SPI_CS_PIN_MASK: u24 = 1 << SPI_CS_PIN;
const SPI_CS_PIN_INIT: gpio.GpioInit = .{
    .mode = .output,
    .output_speed = .high
};

pub var timer_interrupt: bool = undefined;
pub var sh: *shell.Shell = undefined;

export fn TIMER5_IRQHandler() callconv(.c) void {
    if (TIMER_INSTANCE.intf.upif) {
        timer_interrupt = true;
        // clear interrupt flag
        TIMER_INSTANCE.intf = timer.TimerIntf{};
    }
}

export fn USART0_IRQHandler() callconv(.c) void {
    if (USART_INSTANCE.stat.rbne) {
        sh.processChar(@truncate(USART_INSTANCE.rdata));
    }
}

pub fn usartWrite(byte: u8) void {
    USART_INSTANCE.write(byte);
}

inline fn initClock() void {
    rcu.rcu.ctl0.hxtalen = true;
    while (!rcu.rcu.ctl0.hxtalstb) {
        asm volatile ("nop");
    }
    rcu.rcu.cfg0.scs = .hxtal;
    while (rcu.rcu.cfg0.scss != .hxtal) {
        asm volatile ("nop");
    }
}

inline fn initTimer() void {
    TIMER_INSTANCE.psc = @truncate(cpu.cpu.current_frequency / 10000 - 1);
    TIMER_INSTANCE.car = 1000 - 1; //0.1 second interval
    TIMER_INSTANCE.dmainten = .{.upie = true};
    nvic.nvic.enableInterrupt(interrupts.Interrupt.TIMER5.toU8());
    timer_interrupt = false;
}

inline fn initUsart() void {
    USART_TX_PORT.init(USART_TX_PIN_MASK, USART_TX_PIN_INIT);
    USART_RX_PORT.init(USART_RX_PIN_MASK, USART_RX_PIN_INIT);
    USART_INSTANCE.init(hal_constants.USART_BAUD, cpu.cpu.current_frequency);
    nvic.nvic.enableInterrupt(interrupts.Interrupt.USART0.toU8());
    usart_writer.usart_writer.writeCharFunc = usartWrite;
}

inline fn initI2C() void {
   I2C_PORT.init(I2C_SCL_PIN_MASK|I2C_SDA_PIN_MASK, I2C_PINS_INIT);
   I2C_INSTANCE.initMaster(hal_constants.I2C_SPEED);
}

inline fn initSPI() void {
    SPI_PORT.init(SPI_TX_PIN_MASK|SPI_CLK_PIN_MASK, SPI_OUT_PINS_INIT);
    SPI_PORT.init(SPI_RX_PIN_MASK, SPI_RX_PIN_INIT);
    SPI_INSTANCE.ctl0 = .{.mstmod = true, .spien = true, .psc = .div8, .swnss = true, .swnssen = true};
    SPI_CS_PORT.bop = SPI_CS_PIN_MASK; // cs is 1
    SPI_CS_PORT.init(SPI_CS_PIN_MASK, SPI_CS_PIN_INIT);
}

export fn SystemInit() callconv(.c) void {
    initClock();
    system_timer.delay_init(system_timer.init_div1);
    rcu.rcu.ahben = .{.paen = true, .pben = true, .pcen = true};
    rcu.rcu.apb1en = .{.timer5en = true, .i2c1en = true};
    rcu.rcu.apb2en = .{.usart0en = true, .spi0en = true};
    LED_PORT.init(LED_PIN_MASK, LED_INIT);

    initTimer();
    initUsart();
    initI2C();
    initSPI();
}

pub inline fn startTimer() void {
    TIMER_INSTANCE.ctl0 = .{.cen = true, .arse = true};
}

pub inline fn ledToggle() void {
    LED_PORT.tg = LED_PIN_MASK;
}

pub inline fn i2cScan(address: u10) i2c.I2cError!void {
    return I2C_INSTANCE.scan(address, I2C_TIMEOUT);
}

pub inline fn i2cRead(address: u10, data: []u8) i2c.I2cError!void {
    return I2C_INSTANCE.read(address, data, I2C_TIMEOUT);
}

pub inline fn i2cWrite(address: u10, data: []const u8) i2c.I2cError!void {
    return I2C_INSTANCE.write(address, data, I2C_TIMEOUT);
}

pub inline fn i2cTransfer(address: u10, wdata: []const u8, rdata: []u8) i2c.I2cError!void {
    return I2C_INSTANCE.transfer(address, wdata, rdata, I2C_TIMEOUT);
}

inline fn spiCsClr() void {
    SPI_CS_PORT.bc = SPI_CS_PIN_MASK;
}

inline fn spiCsSet() void {
    SPI_CS_PORT.bop = SPI_CS_PIN_MASK;
}

pub fn spiSendReceive(channel: usize, wdata: []const u8, rdata: []u8) bool {
    _ = channel;
    spiCsClr();
    SPI_INSTANCE.sendReceivePoll8(wdata, rdata);
    spiCsSet();
    return true;
}