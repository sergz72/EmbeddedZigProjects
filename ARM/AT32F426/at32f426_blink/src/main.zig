const system_timer = @import("system_timer");
const crm = @import("crm");
const gpio = @import("gpio");
const tmr = @import("tmr");
const cpu = @import("cpu");
const nvic = @import("nvic");
const interrupts = @import("interrupts");
const usart = @import("usart");

const LED_PIN = 2;
const LED_PIN_MASK: u16 = 1 << LED_PIN;
const LED_PORT = gpio.gpiob;
const LED_INIT: gpio.GpioInit = .{
    .mode = .output
};

const USART_INSTANCE = usart.usart1;

const USART_TX_PIN = 6;
const USART_TX_PIN_MASK: u16 = 1 << USART_TX_PIN;
const USART_TX_PORT = gpio.gpiob;
const USART_TX_PIN_INIT: gpio.GpioInit = .{
    .mode = .multiplexed,
    .mux = .mux0
};

const USART_RX_PIN = 7;
const USART_RX_PIN_MASK: u16 = 1 << USART_RX_PIN;
const USART_RX_PORT = gpio.gpiob;
const USART_RX_PIN_INIT: gpio.GpioInit = .{
    .mode = .multiplexed,
    .mux = .mux0,
    .pull = .pullup
};

const TIMER_INSTANCE = tmr.btmr6;

var timer_interrupt: bool = undefined;

export fn TMR6_GLOBAL_IRQHandler() callconv(.c) void {
    if (TIMER_INSTANCE.ists.ovfif) {
        TIMER_INSTANCE.ists = .{}; // clear interrupt flag
        timer_interrupt = true;
    }
}

export fn USART1_IRQHandler() callconv(.c) void {
    if (USART_INSTANCE.sts.rdbf) {
        const data = USART_INSTANCE.dt;
        USART_INSTANCE.dt = data;
    }
}

inline fn initTimer() void {
    TIMER_INSTANCE.div = @truncate(cpu.cpu.current_frequency / 10000 - 1);
    TIMER_INSTANCE.pr = 10000 - 1; //1 second interval
    TIMER_INSTANCE.iden = .{.ovfien = true};
    nvic.nvic.enableInterrupt(interrupts.Interrupt.TMR6_GLOBAL.toU8());
    timer_interrupt = false;
}

inline fn initUsart() void {
    USART_TX_PORT.init(USART_TX_PIN_MASK, USART_TX_PIN_INIT);
    USART_RX_PORT.init(USART_RX_PIN_MASK, USART_RX_PIN_INIT);
    USART_INSTANCE.init(115200, cpu.cpu.current_frequency);
    nvic.nvic.enableInterrupt(interrupts.Interrupt.USART1.toU8());
}

export fn SystemInit() callconv(.c) void {
    system_timer.delay_init(system_timer.init_div1);
    crm.crm.ahben = .{.gpioben = true};
    crm.crm.apb1en = .{.tmr6 = true};
    crm.crm.apb2en = .{.usart1 = true};
    LED_PORT.init(LED_PIN_MASK, LED_INIT);
    initTimer();
    initUsart();
}

inline fn startTimer() void {
    TIMER_INSTANCE.ctrl1 = .{.tmren = true};
}

export fn main() callconv(.c) noreturn {
    startTimer();
    while (true) {
        asm volatile("wfi");
        if (timer_interrupt) {
            timer_interrupt = false;
            LED_PORT.togglePins(LED_PIN_MASK);
        }
    }
}
