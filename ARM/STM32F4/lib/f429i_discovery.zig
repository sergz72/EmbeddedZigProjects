const system_timer = @import("system_timer");
const gpio = @import("gpio");
const rcc = @import("rcc");
const cpu = @import("cpu");
const nvic = @import("nvic");
const flash = @import("flash");
const usart = @import("usart");
const interrupts = @import("interrupts");
const usart_writer = @import("usart_writer");
const fmc = @import("fmc");
const ltdc = @import("ltdc");
const sdram = @import("sdram");

const LED_GREEN_PIN = 13;
const LED_GREEN_PIN_MASK: u16 = 1 << LED_GREEN_PIN;
const LED_GREEN_PIN_CLR_MASK: u32 = 0x10000 << LED_GREEN_PIN;
const LED_GREEN_PORT = gpio.gpiog;

const LED_RED_PIN = 14;
const LED_RED_PIN_MASK: u16 = 1 << LED_RED_PIN;
const LED_RED_PIN_CLR_MASK: u32 = 0x10000 << LED_RED_PIN;
const LED_RED_PORT = gpio.gpiog;

const BUTTON_PIN = 0;
const BUTTON_PIN_MASK: u16 = 1 << BUTTON_PIN;
const BUTTON_PORT = gpio.gpioa;

const USART_PORT = gpio.gpioa;
pub const USART_INSTANCE = usart.usart1;
//--------------------------------
const USART_TX_PIN = 9;
const USART_TX_PIN_MASK: u16 = 1 << USART_TX_PIN;
//--------------------------------
const USART_RX_PIN = 10;
const USART_RX_PIN_MASK: u16 = 1 << USART_RX_PIN;

const SDRAM_SDNE1_PIN = 6;
const SDRAM_SDCKE1_PIN = 5;
const SDRAM_GPIOB_PINS_MASK = (1 << SDRAM_SDNE1_PIN) | (1 << SDRAM_SDCKE1_PIN);
const SDRAM_SDNWE_PIN = 0;
const SDRAM_GPIOC_PINS_MASK = (1 << SDRAM_SDNWE_PIN);
const SDRAM_D0_PIN = 14;
const SDRAM_D1_PIN = 15;
const SDRAM_D2_PIN = 0;
const SDRAM_D3_PIN = 1;
const SDRAM_D13_PIN = 8;
const SDRAM_D14_PIN = 9;
const SDRAM_D15_PIN = 10;
const SDRAM_GPIOD_PINS_MASK = (1 << SDRAM_D0_PIN) | (1 << SDRAM_D1_PIN) | (1 << SDRAM_D2_PIN) |
                        (1 << SDRAM_D3_PIN) | (1 << SDRAM_D13_PIN) | (1 << SDRAM_D14_PIN) | (1 << SDRAM_D15_PIN);
const SDRAM_NBL0_PIN = 0;
const SDRAM_NBL1_PIN = 1;
const SDRAM_D4_PIN = 7;
const SDRAM_D5_PIN = 8;
const SDRAM_D6_PIN = 9;
const SDRAM_D7_PIN = 10;
const SDRAM_D8_PIN = 11;
const SDRAM_D9_PIN = 12;
const SDRAM_D10_PIN = 13;
const SDRAM_D11_PIN = 14;
const SDRAM_D12_PIN = 15;
const SDRAM_GPIOE_PINS_MASK = (1 << SDRAM_NBL0_PIN) | (1 << SDRAM_NBL1_PIN) | (1 << SDRAM_D4_PIN) |
                        (1 << SDRAM_D5_PIN) | (1 << SDRAM_D6_PIN) |
                        (1 << SDRAM_D7_PIN) | (1 << SDRAM_D8_PIN) | (1 << SDRAM_D9_PIN) |
                        (1 << SDRAM_D10_PIN) | (1 << SDRAM_D11_PIN) | (1 << SDRAM_D12_PIN);
const SDRAM_A0_PIN = 0;
const SDRAM_A1_PIN = 1;
const SDRAM_A2_PIN = 2;
const SDRAM_A3_PIN = 3;
const SDRAM_A4_PIN = 4;
const SDRAM_A5_PIN = 5;
const SDRAM_SDNRAS_PIN = 11;
const SDRAM_A6_PIN = 12;
const SDRAM_A7_PIN = 13;
const SDRAM_A8_PIN = 14;
const SDRAM_A9_PIN = 15;
const SDRAM_GPIOF_PINS_MASK = (1 << SDRAM_A0_PIN) | (1 << SDRAM_A1_PIN) | (1 << SDRAM_A2_PIN) |
                        (1 << SDRAM_A3_PIN) | (1 << SDRAM_A4_PIN) | (1 << SDRAM_A5_PIN) | (1 << SDRAM_SDNRAS_PIN) |
                        (1 << SDRAM_A6_PIN) | (1 << SDRAM_A7_PIN) | (1 << SDRAM_A8_PIN) | (1 << SDRAM_A9_PIN);
const SDRAM_A10_PIN = 0;
const SDRAM_A11_PIN = 1;
const SDRAM_BA0_PIN = 4;
const SDRAM_BA1_PIN = 5;
const SDRAM_SDCLK_PIN = 8;
const SDRAM_SDNCAS_PIN = 15;
const SDRAM_GPIOG_PINS_MASK = (1 << SDRAM_A10_PIN) | (1 << SDRAM_A11_PIN) | (1 << SDRAM_BA0_PIN) |
                        (1 << SDRAM_BA1_PIN) | (1 << SDRAM_SDCLK_PIN) | (1 << SDRAM_SDNCAS_PIN);

var usart_callback: *const fn(u8) void = undefined;

pub inline fn ledGreenOn() void {
    LED_GREEN_PORT.bsrr = @as(u32, LED_GREEN_PIN_MASK);
}

pub inline fn ledGreenOff() void {
    LED_GREEN_PORT.bsrr = LED_GREEN_PIN_CLR_MASK;
}

pub inline fn ledRedOn() void {
    LED_RED_PORT.bsrr = @as(u32, LED_RED_PIN_MASK);
}

pub inline fn ledRedOff() void {
    LED_RED_PORT.bsrr = LED_RED_PIN_CLR_MASK;
}

pub fn initClock() void {
    rcc.rcc.cr.hsebyp = true;
    rcc.rcc.cr.hseon = true;
    while (!rcc.rcc.cr.hserdy) {
        asm volatile ("nop");
    }

    rcc.rcc.pllcfgr = .{
        //The software has to set these bits correctly to ensure that the VCO input frequency ranges from 1 to 2 MHz.
        //It is recommended to select a frequency of 2 MHz to limit PLL jitter.
        .pllm = 4,
        // PLL frequency is 336 MHz
        .plln = 168,
        .pllq = 7, // 48 MHz for USB
        .pllp = .div2,
        .pllsrc = true
    };
    rcc.rcc.cr.pllon = true;
    while (!rcc.rcc.cr.pllrdy) {
        asm volatile ("nop");
    }

    flash.flash.acr = .{.dcrst = true, .icrst = true, .prften = true, .latency = 5};
    flash.flash.acr = .{.prften = true, .latency = 5};
    flash.flash.acr = .{.dcen = true, .icen = true, .prften = true, .latency = 5};

    rcc.rcc.cfgr = .{.ppre1 = .div4, .ppre2 = .div2};
    rcc.rcc.cfgr.sw = .pll;
    while (rcc.rcc.cfgr.sws != .pll) {
        asm volatile ("nop");
    }

    cpu.cpu.current_frequency = 168000000;
    cpu.cpu.apb1_frequency = 42000000;
    cpu.cpu.apb2_frequency = 84000000;
}

pub fn initLeds() void {
    rcc.rcc.ahb1enr.gpiogen = true;
    var init_data: gpio.GpioInit = .{
        .pins = LED_GREEN_PIN_MASK,
        .mode = .output,
        .speed = .low
    };
    LED_GREEN_PORT.init(&init_data);
    init_data.pins = LED_RED_PIN_MASK;
    LED_RED_PORT.init(&init_data);
}

pub fn initButton() void {
    rcc.rcc.ahb1enr.gpioaen = true;
    var init_data: gpio.GpioInit = .{
        .pins = BUTTON_PIN_MASK,
        .mode = .input
    };
    BUTTON_PORT.init(&init_data);
}

pub fn initLcd() void {
    //todo
}

fn fmcGpioInit(port: *volatile gpio.Gpio, pins: u16) void {
    var init_data: gpio.GpioInit = .{
        .pins = pins,
        .mode = .alternate,
        .speed = .high,
        .alternate_function = 12
    };
    port.init(&init_data);
}

// +-------------------+--------------------+--------------------+--------------------+
// +                       SDRAM pins assignment                                      +
// +-------------------+--------------------+--------------------+--------------------+
// | PD0  <-> FMC_D2   | PE0  <-> FMC_NBL0  | PF0  <-> FMC_A0    | PG0  <-> FMC_A10   |
// | PD1  <-> FMC_D3   | PE1  <-> FMC_NBL1  | PF1  <-> FMC_A1    | PG1  <-> FMC_A11   |
// | PD8  <-> FMC_D13  | PE7  <-> FMC_D4    | PF2  <-> FMC_A2    | PG8  <-> FMC_SDCLK |
// | PD9  <-> FMC_D14  | PE8  <-> FMC_D5    | PF3  <-> FMC_A3    | PG15 <-> FMC_NCAS  |
// | PD10 <-> FMC_D15  | PE9  <-> FMC_D6    | PF4  <-> FMC_A4    |--------------------+
// | PD14 <-> FMC_D0   | PE10 <-> FMC_D7    | PF5  <-> FMC_A5    |
// | PD15 <-> FMC_D1   | PE11 <-> FMC_D8    | PF11 <-> FMC_NRAS  |
// +-------------------| PE12 <-> FMC_D9    | PF12 <-> FMC_A6    |
// | PE13 <-> FMC_D10   | PF13 <-> FMC_A7    |
// | PE14 <-> FMC_D11   | PF14 <-> FMC_A8    |
// | PE15 <-> FMC_D12   | PF15 <-> FMC_A9    |
// +-------------------+--------------------+--------------------+
// | PB5 <-> FMC_SDCKE1(bank2)|
// | PB6 <-> FMC_SDNE1(bank2) |
// | PC0 <-> FMC_SDNWE        |
// +--------------------------+
pub fn initSdram() void {
    rcc.rcc.ahb3enr.fmcen = true;
    rcc.rcc.ahb1enr.gpioben = true;
    rcc.rcc.ahb1enr.gpiocen = true;
    rcc.rcc.ahb1enr.gpioden = true;
    rcc.rcc.ahb1enr.gpioeen = true;
    rcc.rcc.ahb1enr.gpiofen = true;
    rcc.rcc.ahb1enr.gpiogen = true;
    fmcGpioInit(gpio.gpiof, SDRAM_GPIOF_PINS_MASK);
    fmcGpioInit(gpio.gpioc, SDRAM_GPIOC_PINS_MASK);
    fmcGpioInit(gpio.gpiog, SDRAM_GPIOG_PINS_MASK);
    fmcGpioInit(gpio.gpioe, SDRAM_GPIOE_PINS_MASK);
    fmcGpioInit(gpio.gpiod, SDRAM_GPIOD_PINS_MASK);
    fmcGpioInit(gpio.gpiob, SDRAM_GPIOB_PINS_MASK);
    fmc.fmc.initSdram(.{.bank = .bank2, .sdclk = .two_hclk_periods}, sdram.IS42S16400J_7);
}

pub fn initUsb() void {
    //todo
}

export fn USART1_IRQHandler() callconv(.c) void {
    const sr = USART_INSTANCE.sr;
    if (sr.ore) {
        _ = USART_INSTANCE.dr;
        return;
    }
    if (sr.rxne) {
        usart_callback(USART_INSTANCE.dr);
    }
}

pub fn usartWrite(byte: u8) void {
    USART_INSTANCE.write(byte);
}

pub fn initUsart(baud: u32, callback: *const fn(u8) void) void {
    usart_callback = callback;
    rcc.rcc.ahb1enr.gpioaen = true;
    rcc.rcc.apb2enr.usart1en = true;
    var init_data: gpio.GpioInit = .{
        .pins = USART_TX_PIN_MASK,
        .mode = .alternate,
        .speed = .high,
        .alternate_function = 7
    };
    USART_PORT.init(&init_data);
    init_data.pins = USART_RX_PIN_MASK;
    init_data.pupdr = .pullup;
    USART_PORT.init(&init_data);
    USART_INSTANCE.init(baud, cpu.cpu.apb2_frequency);
    nvic.nvic.enableInterrupt(interrupts.Interrupt.USART1.toU8());
    usart_writer.usart_writer.writeCharFunc = usartWrite;
}

pub fn init() void {
    initClock();
    system_timer.delay_init(system_timer.init_div8);
    initLeds();
    initButton();
    initLcd();
}