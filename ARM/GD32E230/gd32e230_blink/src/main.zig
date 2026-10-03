const rcu = @import("rcu");
const gpio = @import("gpio");
const cpu = @import("cpu");
const timer = @import("timer");
const usart = @import("usart");
const nvic = @import("nvic");
const interrupts = @import("interrupts");
const system_timer = @import("system_timer");

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

var led_status: bool = undefined;
var led_counter: usize = undefined;
var timer_interrupt: bool = undefined;

export fn TIMER5_IRQHandler() callconv(.c) void {
    if (TIMER_INSTANCE.intf.upif) {
        timer_interrupt = true;
        // clear interrupt flag
        TIMER_INSTANCE.intf = timer.TimerIntf{};
    }
}

export fn USART1_IRQHandler() callconv(.c) void {
    if (USART_INSTANCE.stat.rbne) {
        const data = USART_INSTANCE.rdata;
        USART_INSTANCE.tdata = data;
    }
}

fn usartWrite(byte: u8) void {
    USART_INSTANCE.write(byte);
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
}

export fn SystemInit() callconv(.c) void {
    system_timer.delay_init(system_timer.init_div1);
    rcu.rcu.ahben = .{.paen = true, .pcen = true};
    rcu.rcu.apb1en = .{.usart1en = true, .timer5en = true};
    LED_PORT.init(LED_PIN_MASK, LED_INIT);

    initTimer();
    initUsart();
}

inline fn startTimer() void {
    TIMER_INSTANCE.ctl0 = .{.cen = true, .arse = true};
}

export fn main() callconv(.c) noreturn {
    startTimer();
    while (true) {
        asm volatile("wfi");
        if (timer_interrupt) {
            timer_interrupt = false;
            // toggle pin
            LED_PORT.tg = LED_PIN_MASK;
        }
    }
}
