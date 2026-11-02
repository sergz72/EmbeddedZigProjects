const gpio = @import("gpio");
const rcc = @import("rcc");
const system_timer = @import("system_timer");
const cpu = @import("cpu");
const flash = @import("flash");
const usart = @import("usart");
const nvic = @import("nvic");
const interrupts = @import("interrupts");
const usart_writer = @import("usart_writer");

const LED_GREEN_PB0_PIN = 0;
const LED_GREEN_PB0_PIN_MASK: u16 = 1 << LED_GREEN_PB0_PIN;
const LED_GREEN_PB0_PORT = gpio.gpiob;

const LED_GREEN_PA5_PIN = 5;
const LED_GREEN_PA5_PIN_MASK: u16 = 1 << LED_GREEN_PA5_PIN;
const LED_GREEN_PA5_PORT = gpio.gpioa;

const LED_YELLOW_PIN = 4;
const LED_YELLOW_PIN_MASK: u16 = 1 << LED_YELLOW_PIN;
const LED_YELLOW_PORT = gpio.gpiof;

const LED_RED_PIN = 4;
const LED_RED_PIN_MASK: u16 = 1 << LED_RED_PIN;
const LED_RED_PORT = gpio.gpiog;

const BUTTON_PIN = 13;
const BUTTON_PIN_MASK: u16 = 1 << BUTTON_PIN;
const BUTTON_PORT = gpio.gpioc;

const USART_PORT = gpio.gpiod;
pub const USART_INSTANCE = usart.usart3;
//--------------------------------
const USART_TX_PIN = 8;
const USART_TX_PIN_MASK: u16 = 1 << USART_TX_PIN;
//--------------------------------
const USART_RX_PIN = 9;
const USART_RX_PIN_MASK: u16 = 1 << USART_RX_PIN;

var led_green_alternate: bool = undefined;
var rcc_init = rcc.RccInit{};
var usart_callback: *const fn(u8) void = undefined;

pub inline fn ledGreenOn() void {
    if (led_green_alternate) {
        LED_GREEN_PA5_PORT.setPins(LED_GREEN_PA5_PIN_MASK);
    } else {
        LED_GREEN_PB0_PORT.setPins(LED_GREEN_PB0_PIN_MASK);
    }
}

pub inline fn ledGreenOff() void {
    if (led_green_alternate) {
        LED_GREEN_PA5_PORT.clearPins(LED_GREEN_PA5_PIN_MASK);
    } else {
        LED_GREEN_PB0_PORT.clearPins(LED_GREEN_PB0_PIN_MASK);
    }
}

pub inline fn ledYellowOn() void {
    LED_YELLOW_PORT.setPins(LED_YELLOW_PIN_MASK);
}

pub inline fn ledYellowOff() void {
    LED_YELLOW_PORT.clearPins(LED_YELLOW_PIN_MASK);
}

pub inline fn ledRedOn() void {
    LED_RED_PORT.setPins(LED_RED_PIN_MASK);
}

pub inline fn ledRedOff() void {
    LED_RED_PORT.clearPins(LED_RED_PIN_MASK);
}

pub fn initClock(cpu_frequency: usize, pll_characteristics: rcc.PllCharacteristics) void {
    rcc_init.pll1_init.pllp_frequency = cpu_frequency;
    rcc_init.pll1_init.pll_characteristics = pll_characteristics;
    rcc.rcc.init(&rcc_init) catch {
        while (true) {}
    };
    cpu.cpu.current_frequency = cpu_frequency;
    cpu.cpu.pclk1_frequency = cpu_frequency;
    cpu.cpu.pclk2_frequency = cpu_frequency;
}

pub fn initLeds(led_green_pa5: bool) void {
    if (led_green_pa5) {
        rcc.rcc.hpenr.ahb2.gpioaen = true;
    } else {
        rcc.rcc.hpenr.ahb2.gpioben = true;
    }
    rcc.rcc.hpenr.ahb2.gpiofen = true;
    rcc.rcc.hpenr.ahb2.gpiogen = true;
    led_green_alternate = led_green_pa5;
    const ginit: gpio.GpioInit = .{
        .mode = .output,
        .speed = .low
    };
    if (led_green_pa5) LED_GREEN_PA5_PORT.init(LED_GREEN_PA5_PIN_MASK, ginit) else LED_GREEN_PB0_PORT.init(LED_GREEN_PB0_PIN_MASK, ginit);
    LED_YELLOW_PORT.init(LED_YELLOW_PIN_MASK, ginit);
    LED_RED_PORT.init(LED_RED_PIN_MASK, ginit);
}

pub fn initButton() void {
    rcc.rcc.hpenr.ahb2.gpiocen = true;
    const init_data: gpio.GpioInit = .{
        .mode = .input
    };
    BUTTON_PORT.init(BUTTON_PIN_MASK, init_data);
}

pub fn initUsart(baud: u32, callback: *const fn(u8) void) void {
    usart_callback = callback;
    rcc.rcc.hpenr.ahb2.gpioden = true;
    rcc.rcc.hpenr.apb1l.usart3en = true;
    var init_data: gpio.GpioInit = .{
        .mode = .alternate,
        .speed = .very_high,
        .alternate = 7
    };
    USART_PORT.init(USART_TX_PIN_MASK, init_data); // TX
    init_data.pull = .pullup;
    USART_PORT.init(USART_RX_PIN_MASK, init_data); // RX
    USART_INSTANCE.init(baud, cpu.cpu.pclk1_frequency);
    nvic.nvic.enableInterrupt(interrupts.Interrupt.USART3.toU8());
    usart_writer.usart_writer.writeCharFunc = usartWrite;
}

pub fn init(led_green_pa5: bool, cpu_frequency: usize, pll_characteristics: rcc.PllCharacteristics) void {
    initClock(cpu_frequency, pll_characteristics);
    system_timer.delay_init(system_timer.init_div8);
    initLeds(led_green_pa5);
    initButton();
}

pub fn initEthernetGpio() void {
    //todo
}

pub fn initUsbGpio() void {
    //todo
}

export fn USART3_IRQHandler() callconv(.c) void {
    const sr = USART_INSTANCE.isr;
    if (sr.ore) {
        _ = USART_INSTANCE.rdr;
        return;
    }
    if (sr.rxfne) {
        usart_callback(@truncate(USART_INSTANCE.rdr));
    }
}

pub fn usartWrite(byte: u8) void {
    USART_INSTANCE.write(byte);
}
