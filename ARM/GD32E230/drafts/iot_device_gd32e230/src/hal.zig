const std = @import("std");
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
const scd4x = @import("scd4x");
const veml = @import("veml7700");
const usart_writer = @import("usart_writer");

const LED_PIN = 13;
const LED_PIN_MASK: u16 = 1 << LED_PIN;
const LED_PORT = gpio.gpioc;
const LED_INIT: gpio.GpioInit = .{
    .mode = .output,
    .output_speed = .low
};

const USART_INSTANCE = usart.usart1;

const USART_TX_PIN = 2;
const USART_TX_PIN_MASK: u16 = 1 << USART_TX_PIN;
const USART_TX_PORT = gpio.gpioa;
const USART_TX_PIN_INIT: gpio.GpioInit = .{
    .mode = .alternate,
    .output_speed = .high,
    .alternate = 1
};

const USART_RX_PIN = 3;
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
const I2C_SPEED = 100000;
//------------------------------
const I2C_TIMEOUT = 10000;

pub const panic = std.debug.no_panic;

pub var timer_interrupt: bool = undefined;
pub var sh: *shell.Shell = undefined;
pub var scd_device: scd4x.SCD4x = .{.i2c_read = scdRead, .i2c_write = scdWrite};
pub var veml_device: veml.VEML7700 = .{.i2c_read = vemlRead, .i2c_write = vemlWrite};

export fn TIMER5_IRQHandler() callconv(.c) void {
    if (TIMER_INSTANCE.intf.upif) {
        timer_interrupt = true;
        // clear interrupt flag
        TIMER_INSTANCE.intf = timer.TimerIntf{};
    }
}

export fn USART1_IRQHandler() callconv(.c) void {
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
    usart.usart1.init(115200, cpu.cpu.current_frequency);
    nvic.nvic.enableInterrupt(interrupts.Interrupt.USART1.toU8());
    usart_writer.usart_writer.writeCharFunc = usartWrite;
}

inline fn initI2C() void {
   I2C_PORT.init(I2C_SCL_PIN_MASK|I2C_SDA_PIN_MASK, I2C_PINS_INIT);
   I2C_INSTANCE.initMaster(I2C_SPEED);
}

inline fn initSPI() void {
}

export fn SystemInit() callconv(.c) void {
    initClock();
    system_timer.delay_init(system_timer.init_div1);
    rcu.rcu.ahben = .{.paen = true, .pben = true, .pcen = true};
    rcu.rcu.apb1en = .{.usart1en = true, .timer5en = true, .i2c1en = true};
    LED_PORT.init(LED_PIN_MASK, LED_INIT);

    initTimer();
    initUsart();
    initI2C();
    initSPI();
}

pub inline fn startTimer() void {
    TIMER_INSTANCE.ctl0 = .{.cen = true, .arse = true};
}

pub fn i2cScan(channel: usize, address: u10) u8 {
    if (channel != 0)
        return 'e';
    I2C_INSTANCE.scan(address, I2C_TIMEOUT) catch {
        return 'e';
    };
    return 0;
}

pub fn scdRead(data: []u8) bool {
    I2C_INSTANCE.read(scd4x.SCD4X_SENSOR_ADDR, data, I2C_TIMEOUT) catch |err| {
        scd_device.i2c_error_name = @errorName(err);
        return false;
    };
    return true;
}

pub fn scdWrite(data: []const u8) bool {
    I2C_INSTANCE.write(scd4x.SCD4X_SENSOR_ADDR, data, I2C_TIMEOUT) catch |err| {
        scd_device.i2c_error_name = @errorName(err);
        return false;
    };
    return true;
}

pub fn vemlRead(reg: u8) ?u16 {
    var rdata: [2]u8 = undefined;
    I2C_INSTANCE.transfer(veml.VEML7700_I2C_ADDRESS, &[_]u8{ reg }, &rdata, I2C_TIMEOUT) catch |err| {
        veml_device.i2c_error_name = @errorName(err);
        return null;
    };
    return std.mem.readInt(u16, &rdata, .little);
}

pub fn vemlWrite(reg: u8, data: u16) bool {
    const wdata: []const u8 = &.{reg, @truncate(data), @truncate(data >> 8)};
    I2C_INSTANCE.write(veml.VEML7700_I2C_ADDRESS, wdata, I2C_TIMEOUT) catch |err| {
        veml_device.i2c_error_name = @errorName(err);
        return false;
    };
    return true;
}

pub fn ledToggle() void {
    LED_PORT.tg = LED_PIN_MASK;
}