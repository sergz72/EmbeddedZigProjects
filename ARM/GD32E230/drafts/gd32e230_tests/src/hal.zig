const std = @import("std");
const rcu = @import("rcu");
const gpio = @import("gpio");
const cpu = @import("cpu");
const timer = @import("timer");
const usart = @import("usart");
const nvic = @import("nvic");
const interrupts = @import("interrupts");
const system_timer = @import("system_timer");
const scb = @import("scb");
const fmc = @import("fmc");
const fwdgt = @import("fwdgt");
const shell = @import("shell");
const usart_writer = @import("usart_writer");
const i2c = @import("i2c");
const ds3231 = @import("ds3231");

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
const I2C_SPEED = 100000;
const I2C_TIMEOUT = 10000;

pub var ds3231_device = ds3231.DS3231{
    .i2c_write = ds3231Write,
    .i2c_transfer = ds3231Transfer
};

pub var timer_interrupt: bool = undefined;
pub var sh: *shell.Shell = undefined;

pub const panic = std.debug.no_panic;

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

inline fn initClock() void {
    rcu.rcu.ctl0.hxtalen = true;
    while (!rcu.rcu.ctl0.hxtalstb) {
        asm volatile ("nop");
    }
    rcu.rcu.cfg0.scs = .hxtal;
    while (rcu.rcu.cfg0.scss != .hxtal) {
        asm volatile ("nop");
    }
    rcu.rcu.enableIrc40k();
}

inline fn initTimer() void {
    TIMER_INSTANCE.psc = @truncate(cpu.cpu.current_frequency / 10000 - 1);
    TIMER_INSTANCE.car = 10000 - 1; //1 second interval
    TIMER_INSTANCE.dmainten = timer.TimerDmaIntEn{.upie = true};
    nvic.nvic.enableInterrupt(interrupts.Interrupt.TIMER5.toU8());
    timer_interrupt = false;
}

inline fn initUsart() void {
    USART_TX_PORT.init(USART_TX_PIN_MASK, USART_TX_PIN_INIT);
    USART_RX_PORT.init(USART_RX_PIN_MASK, USART_RX_PIN_INIT);
    USART_INSTANCE.init(115200, cpu.cpu.current_frequency);
    nvic.nvic.enableInterrupt(interrupts.Interrupt.USART0.toU8());
    usart_writer.usart_writer.writeCharFunc = usartWrite;
}

inline fn initI2C() void {
    I2C_PORT.init(I2C_SCL_PIN_MASK|I2C_SDA_PIN_MASK, I2C_PINS_INIT);
    I2C_INSTANCE.initMaster(I2C_SPEED);
}

export fn SystemInit() callconv(.c) void {
    initClock();
    system_timer.delay_init(system_timer.init_div1);
    rcu.rcu.ahben = rcu.RcuAhben{.paen = true, .pben = true, .pcen = true, .crcen = true};
    rcu.rcu.apb1en = rcu.RcuApb1en{.timer5en = true, .i2c1en = true};
    rcu.rcu.apb2en = rcu.RcuApb2en{.usart0en = true};
    LED_PORT.init(LED_PIN_MASK, LED_INIT);

    initTimer();
    initUsart();
    initI2C();

    if (!fwdgt.fwdgt.init(10000)) {
        while (true) {}
    }
}

pub fn i2cScan(channel: usize, address: u10) [2]u8 {
    if (channel != 0)
        return [2]u8{'e', 'c'};
    I2C_INSTANCE.scan(address, I2C_TIMEOUT) catch |err| {
        const e: []const u8 = @errorName(err);
        return [2]u8{e[0], e[1]};
    };
    return [2]u8{0,0};
}

pub fn usartWrite(byte: u8) void {
    USART_INSTANCE.write(byte);
}

pub inline fn startTimer() void {
    TIMER_INSTANCE.ctl0 = timer.TimerCtl0{.cen = true, .arse = true};
}

pub inline fn ledToggle() void {
    LED_PORT.tg = LED_PIN_MASK;
}

pub fn flashWrite(address: usize, data: []const u8) fmc.FmcError!void {
    fmc.fmc.flashUnlock();
    defer fmc.fmc.flashLock();
    try fmc.fmc.write(address, data);
}

pub fn flashSectorErase(address: usize) fmc.FmcError!void {
    fmc.fmc.flashUnlock();
    defer fmc.fmc.flashLock();
    try fmc.fmc.pageErase(address);
}

pub fn reboot() void {
    scb.scb.reboot();
}

pub fn wdtReset() void {
    fwdgt.fwdgt.reload();
}

pub fn getResetCause() []const u8 {
    return rcu.rcu.getResetCause();
}

pub fn ds3231Transfer(reg: u8, data: []u8) bool {
    I2C_INSTANCE.transfer(ds3231.DS3231_I2C_ADDRESS, &[_]u8{ reg }, data, I2C_TIMEOUT) catch |err| {
        ds3231_device.i2c_error_name = @errorName(err);
        return false;
    };
    return true;
}

pub fn ds3231Write(data: []const u8) bool {
    I2C_INSTANCE.write(ds3231.DS3231_I2C_ADDRESS, data, I2C_TIMEOUT) catch |err| {
        ds3231_device.i2c_error_name = @errorName(err);
        return false;
    };
    return true;
}
