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

const LED_PIN = 0;
const LED_PIN_MASK = 1 << LED_PIN;
const LED_PIN_IOMUX = 0;
const LED_PORT = gpio.gpioa;

const UART_INSTANCE = uart.uart0;
//--------------------------
const UART_TX_PIN = 10;
const UART_TX_PIN_MASK: u24 = 1 << UART_TX_PIN;
const UART_TX_PIN_IOMUX = 20;
const UART_TX_PORT = gpio.gpioa;
//--------------------------
const UART_RX_PIN = 11;
const UART_RX_PIN_MASK: u124 = 1 << UART_RX_PIN;
const UART_RX_PIN_IOMUX = 21;
const UART_RX_PORT = gpio.gpioa;
//------------------------------
const UART_IBRD = uart.calculateIbrd(115200, 4000000, 16);
const UART_FBRD = uart.calculateFbrd(115200, 4000000, 16);

inline fn initPower() void {
    LED_PORT.reset();
    UART_INSTANCE.reset();
    LED_PORT.enablePower();
    UART_INSTANCE.enablePower();
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
    UART_INSTANCE.clksel = common.Clksel3{.busclksel = true};
    UART_INSTANCE.clkdiv = uart.UartClkDiv{.ratio = .div8};
    UART_INSTANCE.setBaudRateDivisor(UART_IBRD, UART_FBRD);
    // When updating the baud-rate divisor (UARTIBRD or UARTIFRD), the LCRH register must also be written.
    // The write strobe for the baud-rate divisor registers is tied to the LCRH register.
    UART_INSTANCE.lcrh = uart.UartLcrh{.wlen = ._8};
    UART_INSTANCE.cpu_int.imask = uart.UartIntIMask{.rxint = true};
    UART_INSTANCE.ctl0.enable = true;
    nvic.nvic.enableInterrupt(interrupts.Interrupt.UART0.toU8());
}

export fn SystemInit() callconv(.c) void {
    sysctl.sysctl.mclkcfg.flashwait = .upto48Mhz;
    system_timer.delay_init(system_timer.init_div1);
    initPower();
    initGpio();
    initUart();
}

pub const panic = std.debug.no_panic;

export fn UART0_IRQHandler() callconv(.c) void {
    if (UART_INSTANCE.cpu_int.iidx == .receive_interrupt) {
        const data = UART_INSTANCE.rxdata;
        if (data > 0x7F or data < 8)
            return;
        UART_INSTANCE.txdata = data;
    }
}

export fn main() callconv(.c) noreturn {
    while (true) {
        system_timer.delayms(1000);
        LED_PORT.togglePins(LED_PIN_MASK);
    }
}
