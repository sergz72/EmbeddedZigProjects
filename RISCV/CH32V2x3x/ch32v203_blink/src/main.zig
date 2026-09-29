const rcc = @import("rcc");
const gpio = @import("gpio");
const afio = @import("afio");
const usart = @import("usart");
const cpu = @import("cpu");
const system_timer = @import("system_timer");
const pfic = @import("pfic");
const interrupts = @import("interrupts");
const usart_writer = @import("usart_writer");

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

export fn SystemInit() callconv(.c) void {
    system_timer.delayInit();
    rcc.rcc.apb2pcenr = rcc.RccCfgrApb2pcEnr{.iopben = true, .afioen = true, .usart1en = true};
    afio.afio.pcfr1 = afio.AfioPcfr1{.usart1_rm = true};
    LED_PORT.init(LED_PIN_MASK, gpio.GpioModeOutputSlowSpeed | gpio.GpioCnfOutputPushPull);
    USART_TX_PORT.init(USART_TX_PIN_MASK, gpio.GpioModeOutputFastSpeed | gpio.GpioCnfAlternatePushPull);
    USART_RX_PORT.bshr = USART_RX_PIN_MASK; // pullup
    USART_RX_PORT.init(USART_RX_PIN_MASK, gpio.GpioCnfInputPullupPulldown);
    usart.usart1.init(115200, cpu.cpu.current_frequency);
    pfic.pfic.interruptEnable(interrupts.Interrupt.USART1.toU8());
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
