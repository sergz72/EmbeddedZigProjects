const rcc = @import("rcc");
const gpio = @import("gpio");
const afio = @import("afio");
const usart = @import("usart");
const cpu = @import("cpu");
const system_timer = @import("system_timer");
const pfic = @import("pfic");
const interrupts = @import("interrupts");
const usart_writer = @import("usart_writer");
const timer = @import("timer");

const LED_PIN = 2;
const LED_PIN_MASK: u16 = 1 << LED_PIN;
const LED_PORT = gpio.gpiob;

const USART_INSTANCE = usart.usart1;

const USART_TX_PIN = 6;
const USART_TX_PIN_MASK: u16 = 1 << USART_TX_PIN;
const USART_TX_PORT = gpio.gpiob;

const USART_RX_PIN = 7;
const USART_RX_PIN_MASK: u16 = 1 << USART_RX_PIN;
const USART_RX_PORT = gpio.gpiob;

const TIMER_INSTANCE = timer.gptm4;

var led_status: bool = undefined;
var led_counter: usize = undefined;
var timer_interrupt: bool = undefined;

fn TIM4IRQHandler() callconv(.c) void {
    if (TIMER_INSTANCE.intfr.uif) {
        timer_interrupt = true;
        // clear interrupt flag
        TIMER_INSTANCE.intfr = timer.TimerIntfr{};
    }
}

export fn TIM4_IRQHandler() callconv(.naked) void {
    asm volatile(
        \\ call %[handler_fn]
        \\ mret
        :
        : [handler_fn] "i" (&TIM4IRQHandler)
    );
}

export fn USART1_IRQHandler() callconv(.naked) void {
    if (USART_INSTANCE.statr.rxne) {
        const data = USART_INSTANCE.datar;
        USART_INSTANCE.datar = data;
    }
    asm volatile("mret");
}

fn usartWrite(byte: u8) void {
    USART_INSTANCE.write(byte);
}

inline fn initTimer() void {
    TIMER_INSTANCE.psc = @truncate(cpu.cpu.current_frequency / 10000 - 1);
    TIMER_INSTANCE.atrlr.value16 = 1000 - 1; //0.1 second interval
    TIMER_INSTANCE.dmaintenr = timer.TimerDmaIntEnr{.uie = true};
    pfic.pfic.interruptEnable(interrupts.Interrupt.TIM4.toU8());
    timer_interrupt = false;
}

export fn SystemInit() callconv(.c) void {
    system_timer.delayInit();
    rcc.rcc.apb2pcenr = rcc.RccCfgrApb2pcEnr{.iopben = true, .afioen = true, .usart1en = true};
    rcc.rcc.apb1pcenr = rcc.RccCfgrApb1pcEnr{.tim4en = true};
    afio.afio.pcfr1 = afio.AfioPcfr1{.usart1_rm = true};
    LED_PORT.init(LED_PIN_MASK, gpio.GpioModeOutputSlowSpeed | gpio.GpioCnfOutputPushPull);
    USART_TX_PORT.init(USART_TX_PIN_MASK, gpio.GpioModeOutputFastSpeed | gpio.GpioCnfAlternatePushPull);
    USART_RX_PORT.bshr = USART_RX_PIN_MASK; // pullup
    USART_RX_PORT.init(USART_RX_PIN_MASK, gpio.GpioCnfInputPullupPulldown);
    usart.usart1.init(115200, cpu.cpu.current_frequency);
    pfic.pfic.interruptEnable(interrupts.Interrupt.USART1.toU8());

    initTimer();
}

fn ledOn() void {
    LED_PORT.bshr = LED_PIN_MASK;
}

fn ledOff() void {
    LED_PORT.bcr = LED_PIN_MASK;
}

fn ledHandler() void {
    if (!timer_interrupt)
        return;
    timer_interrupt = false;
    if (led_counter == 9) {
        led_counter = 0;
        led_status = !led_status;
        if (led_status) {
            ledOn();
        } else {
            ledOff();
        }
    } else {
        led_counter += 1;
    }
}

inline fn startTimer() void {
    TIMER_INSTANCE.ctlr1 = timer.TimerCtlr1{.cen = true, .apre = true};
}

export fn main() callconv(.c) noreturn {
    usart_writer.usart_writer.writeCharFunc = usartWrite;
    usart_writer.usart_writer.writer.print("Hello from Embedded Zig!\n", .{}) catch {};
    startTimer();
    while (true) {
        asm volatile ("wfi");
        ledHandler();
    }
}
