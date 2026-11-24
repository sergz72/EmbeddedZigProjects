const gpio = @import("gpio");
const rcc = @import("rcc");
const system_timer = @import("system_timer");
const usart = @import("usart");
const cpu = @import("cpu");
const pfic = @import("pfic");
const interrupts = @import("interrupts");
const usart_writer = @import("usart_writer");
const afio = @import("afio");

const LED_GREEN_PIN = 2;
const LED_GREEN_PIN_MASK = 1 << LED_GREEN_PIN;
const LED_GREEN_PORT = gpio.gpioc;

const LED_BLUE_PIN = 3;
const LED_BLUE_PIN_MASK = 1 << LED_BLUE_PIN;
const LED_BLUE_PORT = gpio.gpioc;

pub const USART_INSTANCE = usart.usart1;
const USART_PORT = gpio.gpioa;

const USART_TX_PIN = 9;
const USART_TX_PIN_MASK = 1 << USART_TX_PIN;

const USART_RX_PIN = 10;
const USART_RX_PIN_MASK = 1 << USART_RX_PIN;

fn USART1IRQHandler() callconv(.c) void {
    @setRuntimeSafety(false);
    if (USART_INSTANCE.statr.rxne) {
        const data = USART_INSTANCE.datar;
        USART_INSTANCE.datar = data;
    }
}

export fn USART1_IRQHandler() callconv(.naked) void {
    asm volatile(
        \\ call %[handler_fn]
        \\ mret
        :
        : [handler_fn] "i" (&USART1IRQHandler)
    );
}

inline fn initUsart() void {
    afio.setGpioFunction(.A, USART_TX_PIN, 7);
    afio.setGpioFunction(.A, USART_RX_PIN, 7);
    USART_PORT.init(USART_TX_PIN_MASK, gpio.GpioModeOutputFastSpeed | gpio.GpioCnfAlternatePushPull);
    USART_PORT.bshr = USART_RX_PIN_MASK; // pullup
    USART_PORT.init(USART_RX_PIN_MASK, gpio.GpioCnfInputPullupPulldown);
    USART_INSTANCE.init(115200, cpu.cpu.current_frequency);
    pfic.interruptEnable(interrupts.Interrupt.USART1.toU8());
    usart_writer.usart_writer.writeCharFunc = usartWrite;
}

inline fn initLeds() void{
    LED_GREEN_PORT.init(LED_GREEN_PIN_MASK, gpio.GpioModeOutputSlowSpeed | gpio.GpioCnfOutputPushPull);
    LED_BLUE_PORT.init(LED_BLUE_PIN_MASK, gpio.GpioModeOutputSlowSpeed | gpio.GpioCnfOutputPushPull);
}

pub fn init0() void {
    rcc.init();
    system_timer.delayInit();
    rcc.rcc.hb2pcenr = rcc.RccHb2pcenr{.iopaen = true, .iopcen = true, .usart1en = true, .afioen = true};
    initLeds();
    initUsart();
}

pub fn init1() void {
    system_timer.delayInit();
}

pub fn usartWrite(byte: u8) void {
    USART_INSTANCE.write(byte);
}

pub fn ledGreenOn() void {
    LED_GREEN_PORT.bshr = LED_GREEN_PIN_MASK;
}

pub fn ledGreenOff() void {
    LED_GREEN_PORT.bcr = LED_GREEN_PIN_MASK;
}

pub fn ledBlueOn() void {
    LED_BLUE_PORT.bshr = LED_BLUE_PIN_MASK;
}

pub fn ledBlueOff() void {
    LED_BLUE_PORT.bcr = LED_BLUE_PIN_MASK;
}
