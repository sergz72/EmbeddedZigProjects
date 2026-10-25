const std = @import("std");
const sysctl = @import("sysctl");
const gpio = @import("gpio");
const iomux = @import("iomux");
const uart = @import("uart");
const common = @import("common");
const cpu = @import("cpu");
const nvic = @import("nvic");
const interrupts = @import("interrupts");
const system_timer = @import("system_timer");
const shell = @import("shell");
const timer = @import("gptimer");
const i2c_soft = @import("i2c_soft");
const i2c = @import("i2c");
const usart_writer = @import("usart_writer");
const scd4x = @import("scd4x");
const veml = @import("veml7700");
const bme = @import("bme280");
const tsl = @import("tsl2591");
const config = @import("config");

const LED_PIN = 0;
const LED_PIN_MASK = 1 << LED_PIN;
const LED_PIN_IOMUX = 1;
const LED_PORT = gpio.gpioa;

const UART_INSTANCE = uart.uart0;
//--------------------------
const UART_TX_PIN = 10;
const UART_TX_PIN_MASK = 1 << UART_TX_PIN;
const UART_TX_PIN_IOMUX = 21;
const UART_TX_PORT = gpio.gpioa;
//--------------------------
const UART_RX_PIN = 11;
const UART_RX_PIN_MASK = 1 << UART_RX_PIN;
const UART_RX_PIN_IOMUX = 22;
const UART_RX_PORT = gpio.gpioa;
//------------------------------
const UART_IBRD = uart.calculateIbrd(115200, 32000000, 16);
const UART_FBRD = uart.calculateFbrd(115200, 32000000, 16);

const TIMER_INSTANCE = timer.timg0;

pub const I2C_INSTANCE = i2c.i2c1;
//--------------------------
const I2C_SCL_PIN = 4;
const I2C_SCL_PIN_MASK = 1 << I2C_SCL_PIN;
const I2C_SCL_PIN_IOMUX = 9;
const I2C_SCL_PORT = gpio.gpioa;
//--------------------------
const I2C_SDA_PIN = 3;
const I2C_SDA_PIN_MASK = 1 << I2C_SDA_PIN;
const I2C_SDA_PIN_IOMUX = 8;
const I2C_SDA_PORT = gpio.gpioa;
//------------------------------
const I2C_SPEED = 100000;
//------------------------------
const I2C_TIMEOUT = 100000;

pub var timer_interrupt: bool = undefined;
pub var sh: *shell.Shell = undefined;
pub var scd_device: scd4x.SCD4x = .{.i2c_read = scdRead, .i2c_write = scdWrite};
pub var veml_device: veml.VEML7700 = .{.i2c_read = vemlRead, .i2c_write = vemlWrite};
pub var bme_device: bme.BME280 = .{
    .i2c_read = bmeRead,
    .i2c_write = bmeWrite,
    .delayms = system_timer.delayms
};

const tsl_init: tsl.TSL2591Init = .{
    .i2c_read8 = tslRead8,
    .i2c_read16 = tslRead16,
    .i2c_write = tslWrite,
    .i2c_command = tslCommand,
    .delayms = system_timer.delayms,
    .config = .{}
};

pub var tsl_device: tsl.TSL2591 = .{
    .init_data = &tsl_init
};

const i2c_soft_instance: i2c_soft.I2cSoft = .{
    .delayus = system_timer.delayus,
    .get_scl = get_scl,
    .get_sda = get_sda,
    .set_scl = set_scl,
    .set_sda = set_sda,
    .timeout = I2C_TIMEOUT
};

inline fn initPower() void {
    LED_PORT.reset();
    UART_INSTANCE.reset();
    TIMER_INSTANCE.reset();
    if (!config.i2c_soft) {
        I2C_INSTANCE.reset();
    }
    LED_PORT.enablePower();
    UART_INSTANCE.enablePower();
    TIMER_INSTANCE.enablePower();
    if (!config.i2c_soft) {
        I2C_INSTANCE.enablePower();
    }
    common.powerStartupDelay();
}

inline fn initGpio() void {
    iomux.iomux.initDigitalOutput(LED_PIN_IOMUX);
    LED_PORT.setPins(LED_PIN_MASK);
    LED_PORT.enableOutput(LED_PIN_MASK);
}

inline fn initUart() void {
    iomux.iomux.initPeripheralOutputFunction(UART_TX_PIN_IOMUX, .function2);
    iomux.iomux.initPeripheralInputFunction(UART_RX_PIN_IOMUX, .function2);
    const v = common.Clksel3{.busclksel = true};
    UART_INSTANCE.clksel = v;
    const v2: common.ClkDiv = .{.ratio = .div1};
    UART_INSTANCE.clkdiv = v2;
    UART_INSTANCE.setBaudRateDivisor(UART_IBRD, UART_FBRD);
    // When updating the baud-rate divisor (UARTIBRD or UARTIFRD), the LCRH register must also be written.
    // The write strobe for the baud-rate divisor registers is tied to the LCRH register.
    const v3: uart.UartLcrh = .{.wlen = ._8};
    UART_INSTANCE.lcrh = v3;
    const v4 = uart.UartIntIMask{.rxint = true};
    UART_INSTANCE.cpu_int.imask = v4;
    UART_INSTANCE.ctl0.enable = true;
    nvic.nvic.enableInterrupt(interrupts.Interrupt.UART0.toU8());
    usart_writer.usart_writer.writeCharFunc = usartWrite;
}

inline fn initTimer() void {
    timer_interrupt = false;
    const v = common.Clksel3{.lfclksel = true};
    TIMER_INSTANCE.clksel = v;
    const v2 = common.ClkDiv{.ratio = .div1};
    TIMER_INSTANCE.clkdiv = v2;
    TIMER_INSTANCE.initTimer(32768);
    const v3: timer.GptimerIntIMask = .{.z = true};
    TIMER_INSTANCE.cpu_int.imask = v3;
    TIMER_INSTANCE.enableClock();
    nvic.nvic.enableInterrupt(interrupts.Interrupt.TIMG0.toU8());
}

inline fn initI2C() void {
    // enable pullups, open-drain
    iomux.iomux.initPeripheralI2CFunction(I2C_SDA_PIN_IOMUX, .function9);
    iomux.iomux.initPeripheralI2CFunction(I2C_SCL_PIN_IOMUX, .function9);
    const v = common.Clksel2{.busclksel = true};
    I2C_INSTANCE.clksel = v;
    const v2 = common.ClkDiv{.ratio = .div8};
    I2C_INSTANCE.clkdiv = v2;
    I2C_INSTANCE.init(I2C_SPEED);
}

inline fn initI2cSoft() void {
    iomux.iomux.initPeripheralI2CFunction(I2C_SDA_PIN_IOMUX, .gpio);
    iomux.iomux.initPeripheralI2CFunction(I2C_SCL_PIN_IOMUX, .gpio);
    I2C_SCL_PORT.enableOutput(I2C_SCL_PIN_MASK);
    I2C_SDA_PORT.enableOutput(I2C_SDA_PIN_MASK);
    i2c_soft_instance.init();
}

export fn SystemInit() callconv(.c) void {
    sysctl.sysctl.mclkcfg.flashwait = .upto48Mhz;
    system_timer.delay_init(system_timer.init_div1);
    initPower();
    initGpio();
    initUart();
    initTimer();
    if (config.i2c_soft) {
        initI2cSoft();
    } else {
        initI2C();
    }
}

pub fn usartWrite(byte: u8) void {
    UART_INSTANCE.write(byte);
}

pub inline fn ledToggle() void {
    LED_PORT.togglePins(LED_PIN_MASK);
}

pub const panic = std.debug.no_panic;

export fn UART0_IRQHandler() callconv(.c) void {
    if (UART_INSTANCE.cpu_int.iidx == .receive_interrupt) {
        const data = UART_INSTANCE.rxdata;
        if (data > 0x7F or data < 8)
            return;
        sh.processChar(@truncate(data));
    }
}

export fn TIMG0_IRQHandler() callconv(.c) void {
    timer_interrupt = true;
}

fn get_scl() bool {
    return I2C_SCL_PORT.get() & I2C_SCL_PIN_MASK != 0;
}

fn set_scl(level: bool) void {
    if (level) {
        I2C_SCL_PORT.setPins(I2C_SCL_PIN_MASK);
    } else {
        I2C_SCL_PORT.clearPins(I2C_SCL_PIN_MASK);
    }
}

fn get_sda() bool {
    return I2C_SDA_PORT.get() & I2C_SDA_PIN_MASK != 0;
}

fn set_sda(level: bool) void {
    if (level) {
        I2C_SDA_PORT.setPins(I2C_SDA_PIN_MASK);
    } else {
        I2C_SDA_PORT.clearPins(I2C_SDA_PIN_MASK);
    }
}

pub fn i2cScan(channel: usize, address: u10) [2]u8 {
    if (channel != 0)
        return [2]u8{'e', 'c'};
    if (config.i2c_soft) {
        i2c_soft_instance.scan(address) catch |err| {
            const e: []const u8 = @errorName(err);
            return [2]u8{e[0], e[1]};
        };
    } else {
        I2C_INSTANCE.scan(address, I2C_TIMEOUT) catch |err| {
            const e: []const u8 = @errorName(err);
            return [2]u8{e[0], e[1]};
        };
    }
    return [2]u8{0,0};
}

pub fn scdRead(data: []u8) bool {
    if (config.i2c_soft) {
        i2c_soft_instance.read(scd4x.SCD4X_SENSOR_ADDR, data) catch |err| {
            scd_device.i2c_error_name = @errorName(err);
            return false;
        };
    } else {
        I2C_INSTANCE.read(scd4x.SCD4X_SENSOR_ADDR, data, I2C_TIMEOUT) catch |err| {
            scd_device.i2c_error_name = @errorName(err);
            return false;
        };
    }
    return true;
}

pub fn scdWrite(data: []const u8) bool {
    if (config.i2c_soft) {
        i2c_soft_instance.write(scd4x.SCD4X_SENSOR_ADDR, data) catch |err| {
            scd_device.i2c_error_name = @errorName(err);
            return false;
        };
    } else {
        I2C_INSTANCE.write(scd4x.SCD4X_SENSOR_ADDR, data, I2C_TIMEOUT) catch |err| {
            scd_device.i2c_error_name = @errorName(err);
            return false;
        };
    }
    return true;
}

pub fn vemlRead(reg: u8) ?u16 {
    var rdata: [2]u8 = undefined;
    if (config.i2c_soft) {
        i2c_soft_instance.transfer(veml.VEML7700_I2C_ADDRESS, &[_]u8{ reg }, &rdata) catch |err| {
            veml_device.i2c_error_name = @errorName(err);
            return null;
        };
    } else {
        I2C_INSTANCE.transfer(veml.VEML7700_I2C_ADDRESS, &[_]u8{ reg }, &rdata, I2C_TIMEOUT) catch |err| {
            veml_device.i2c_error_name = @errorName(err);
            return null;
        };
    }
    return std.mem.readInt(u16, &rdata, .little);
}

pub fn vemlWrite(reg: u8, data: u16) bool {
    const wdata: []const u8 = &.{reg, @truncate(data), @truncate(data >> 8)};
    if (config.i2c_soft) {
        i2c_soft_instance.write(veml.VEML7700_I2C_ADDRESS, wdata) catch |err| {
            veml_device.i2c_error_name = @errorName(err);
            return false;
        };
    } else {
        I2C_INSTANCE.write(veml.VEML7700_I2C_ADDRESS, wdata, I2C_TIMEOUT) catch |err| {
            veml_device.i2c_error_name = @errorName(err);
            return false;
        };
    }
    return true;
}

pub fn bmeRead(reg: u8, data: []u8) bool {
    if (config.i2c_soft) {
        i2c_soft_instance.transfer(bme.BME280_ADDRESS, &[_]u8{ reg }, data) catch |err| {
            bme_device.i2c_error_name = @errorName(err);
            return false;
        };
    } else {
        I2C_INSTANCE.transfer(bme.BME280_ADDRESS, &[_]u8{ reg }, data, I2C_TIMEOUT) catch |err| {
            bme_device.i2c_error_name = @errorName(err);
            return false;
        };
    }
    return true;
}

pub fn bmeWrite(data: []const u8) bool {
    if (config.i2c_soft) {
        i2c_soft_instance.write(bme.BME280_ADDRESS, data) catch |err| {
            bme_device.i2c_error_name = @errorName(err);
            return false;
        };
    } else {
        I2C_INSTANCE.write(bme.BME280_ADDRESS, data, I2C_TIMEOUT) catch |err| {
            bme_device.i2c_error_name = @errorName(err);
            return false;
        };
    }
    return true;
}

pub fn tslRead8(reg: u8) ?u8 {
    var data: [1]u8 = undefined;
    if (config.i2c_soft) {
        i2c_soft_instance.transfer(tsl.TSL2591_I2C_ADDRESS, &[_]u8{ reg }, &data) catch |err| {
            tsl_device.i2c_error_name = @errorName(err);
            return null;
        };
    } else {
        I2C_INSTANCE.transfer(tsl.TSL2591_I2C_ADDRESS, &[_]u8{ reg }, &data, I2C_TIMEOUT) catch |err| {
            tsl_device.i2c_error_name = @errorName(err);
            return null;
        };
    }
    return data[0];
}

pub fn tslRead16(reg: u8) ?u16 {
    var data: [2]u8 = undefined;
    if (config.i2c_soft) {
        i2c_soft_instance.transfer(tsl.TSL2591_I2C_ADDRESS, &[_]u8{ reg }, &data) catch |err| {
            tsl_device.i2c_error_name = @errorName(err);
            return null;
        };
    } else {
        I2C_INSTANCE.transfer(tsl.TSL2591_I2C_ADDRESS, &[_]u8{ reg }, &data, I2C_TIMEOUT) catch |err| {
            tsl_device.i2c_error_name = @errorName(err);
            return null;
        };
    }
    return std.mem.readInt(u16, &data, .little);
}

pub fn tslWrite(reg: u8, value: u8) bool {
    const data: [2]u8 = .{reg, value};
    if (config.i2c_soft) {
        i2c_soft_instance.write(tsl.TSL2591_I2C_ADDRESS, &data) catch |err| {
            tsl_device.i2c_error_name = @errorName(err);
            return false;
        };
    } else {
        I2C_INSTANCE.write(tsl.TSL2591_I2C_ADDRESS, &data, I2C_TIMEOUT) catch |err| {
            tsl_device.i2c_error_name = @errorName(err);
            return false;
        };
    }
    return true;
}

pub fn tslCommand(command: u8) bool {
    const data: [1]u8 = .{command};
    if (config.i2c_soft) {
        i2c_soft_instance.write(tsl.TSL2591_I2C_ADDRESS, &data) catch |err| {
            tsl_device.i2c_error_name = @errorName(err);
            return false;
        };
    } else {
        I2C_INSTANCE.write(tsl.TSL2591_I2C_ADDRESS, &data, I2C_TIMEOUT) catch |err| {
            tsl_device.i2c_error_name = @errorName(err);
            return false;
        };
    }
    return true;
}

pub inline fn startTimer() void {
    TIMER_INSTANCE.startCounter();
}

pub inline fn enterSleep() void {
    asm volatile("wfi");
}