const rcc = @import("rcc");
const gpio = @import("gpio");
const afio = @import("afio");
const usart = @import("usart");
const cpu = @import("cpu");
const system_timer = @import("system_timer");
const pfic = @import("pfic");
const interrupts = @import("interrupts");
const usart_writer = @import("usart_writer");

const LED_PIN = 4;
const LED_PIN_MASK: u24 = 1 << LED_PIN;
const LED_PORT = gpio.gpioa;

const USART_INSTANCE = usart.usart2;

const TX_PIN = 2;
const TX_PIN_MASK: u24 = 1 << TX_PIN;
const TX_PORT = gpio.gpioa;

const RX_PIN = 3;
const RX_PIN_MASK: u24 = 1 << RX_PIN;
const RX_PORT = gpio.gpioa;

export fn USART2_IRQHandler() callconv(.naked) void {
    if (USART_INSTANCE.statr.rxne) {
        const data = USART_INSTANCE.datar;
        USART_INSTANCE.datar = data;
    }
    asm volatile("mret");
}

fn usartWrite(byte: u8) void {
    USART_INSTANCE.write(byte);
}

export fn SystemInit() callconv(.c) void {
    system_timer.delay_init();
    rcc.rcc.apb2pcenr = rcc.RccCfgrApb2pcEnr{.iopaen = true, .afioen = true};
    rcc.rcc.apb1pcenr = rcc.RccCfgrApb1pcEnr{.usart2en = true};
    LED_PORT.init(LED_PIN_MASK, gpio.GpioModeOutput | gpio.GpioCnfOutputPushPull);
    TX_PORT.init(TX_PIN_MASK, gpio.GpioModeOutput | gpio.GpioCnfAlternatePushPull);
    RX_PORT.bshr = RX_PIN_MASK; // pullup
    RX_PORT.init(RX_PIN_MASK, gpio.GpioCnfInputPullupPulldown);
    USART_INSTANCE.init(115200, cpu.cpu.current_frequency);
    pfic.pfic.interrupt_enable(interrupts.Interrupt.USART2.to_u8());
}

export fn main() callconv(.c) noreturn {
    usart_writer.usart_writer.writeCharFunc = usartWrite;
    usart_writer.usart_writer.writer.print("Hello from Embedded Zig!\n", .{}) catch {};
    while (true) {
        LED_PORT.bshr = LED_PIN_MASK;
        system_timer.delayms(1000);
        LED_PORT.bcr = LED_PIN_MASK;
        system_timer.delayms(1000);
    }
}
