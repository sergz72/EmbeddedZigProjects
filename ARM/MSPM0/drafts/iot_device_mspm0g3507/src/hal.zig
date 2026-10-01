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
const i2c = @import("i2c");
const spi = @import("spi");
const usart_writer = @import("usart_writer");

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
const UART_BAUD_RATE = 115200;
const UART_IBRD = uart.calculateIbrd(UART_BAUD_RATE, 32000000, 16);
const UART_FBRD = uart.calculateFbrd(UART_BAUD_RATE, 32000000, 16);

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

inline fn initPower() void {
    LED_PORT.reset();
    UART_INSTANCE.reset();
    TIMER_INSTANCE.reset();
    I2C_INSTANCE.reset();
    LED_PORT.enablePower();
    UART_INSTANCE.enablePower();
    TIMER_INSTANCE.enablePower();
    I2C_INSTANCE.enablePower();
    common.powerStartupDelay();
}

inline fn initGpio() void {
    iomux.iomux.initDigitalOutput(LED_PIN_IOMUX);
    LED_PORT.setPins(LED_PIN_MASK);
    LED_PORT.enableOutput(LED_PIN_MASK);
}

pub fn usartWrite(byte: u8) void {
    UART_INSTANCE.write(byte);
}

inline fn initUart() void {
    iomux.iomux.initPeripheralOutputFunction(UART_TX_PIN_IOMUX, .function2);
    iomux.iomux.initPeripheralInputFunctionWithPullup(UART_RX_PIN_IOMUX, .function2);
    UART_INSTANCE.clksel = common.Clksel3{.busclksel = true};
    UART_INSTANCE.clkdiv = common.ClkDiv{.ratio = .div1};
    UART_INSTANCE.setBaudRateDivisor(UART_IBRD, UART_FBRD);
    // When updating the baud-rate divisor (UARTIBRD or UARTIFRD), the LCRH register must also be written.
    // The write strobe for the baud-rate divisor registers is tied to the LCRH register.
    UART_INSTANCE.lcrh = .{.wlen = ._8};
    UART_INSTANCE.cpu_int.imask = .{.rxint = true};
    UART_INSTANCE.ctl0.enable = true;
    nvic.nvic.enableInterrupt(interrupts.Interrupt.UART0.toU8());
    usart_writer.usart_writer.writeCharFunc = usartWrite;
}

inline fn initTimer() void {
    timer_interrupt = false;
    TIMER_INSTANCE.clksel = common.Clksel3{.lfclksel = true};
    TIMER_INSTANCE.clkdiv = common.ClkDiv{.ratio = .div1};
    TIMER_INSTANCE.initTimer(32768/10);
    TIMER_INSTANCE.cpu_int.imask = .{.z = true};
    TIMER_INSTANCE.enableClock();
    nvic.nvic.enableInterrupt(interrupts.Interrupt.TIMG0.toU8());
}

inline fn initI2C() void {
    // enable pullups, open-drain
    iomux.iomux.initPeripheralI2CFunction(I2C_SDA_PIN_IOMUX, .function9);
    iomux.iomux.initPeripheralI2CFunction(I2C_SCL_PIN_IOMUX, .function9);
    I2C_INSTANCE.clksel = common.Clksel2{.busclksel = true};
    I2C_INSTANCE.clkdiv = common.ClkDiv{.ratio = .div8};
    I2C_INSTANCE.disableAnalogGlitchFilter();
    I2C_INSTANCE.resetControllerTransfer();
    I2C_INSTANCE.setSpeed(I2C_SPEED, cpu.cpu.current_frequency / 8);
    I2C_INSTANCE.setControllerTXFIFOThreshold(0);
    I2C_INSTANCE.setControllerRXFIFOThreshold(1);
    I2C_INSTANCE.enableControllerClockStretching();
    I2C_INSTANCE.enableController();
}

inline fn initSPI() void {
}

export fn SystemInit() callconv(.c) void {
    sysctl.sysctl.mclkcfg.flashwait = .upto48Mhz;
    system_timer.delay_init(system_timer.init_div1);
    initPower();
    initGpio();
    initUart();
    initTimer();
    initI2C();
    initSPI();
}

pub inline fn ledToggle() void {
    LED_PORT.togglePins(LED_PIN_MASK);
}

pub inline fn startTimer() void {
    TIMER_INSTANCE.startCounter();
}

pub fn i2c_scan(channel: usize, address: u10) u8 {
    if (channel != 0)
        return 'e';
    I2C_INSTANCE.scan(address, 10000) catch |err| {
        if (err == i2c.I2cError.Timeout) {
            return 't';
        }
        return 'e';
    };
    return 0;
}

pub const panic = std.debug.no_panic;

pub var timer_interrupt: bool = undefined;
pub var sh: *shell.Shell = undefined;

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
