const rcc = @import("rcc");
const gpio = @import("gpio");
const gpio_common = @import("gpio_common");
const afio = @import("afio");
const usart = @import("usart");
const system_timer = @import("system_timer");
const cpu = @import("cpu");
const pfic = @import("pfic");
const interrupts = @import("interrupts");
const usart_writer = @import("usart_writer");
const spi = @import("spi");
const timer = @import("timer");
const eth_driver = @import("eth_driver");
const shell = @import("shell");
const builtin = @import("builtin");

const LED_BLUE_PORT = gpio.gpiob;
const LED_BLUE_PIN = 4;
const LED_BLUE_PIN_MASK: u16 = 1 << LED_BLUE_PIN;

const LED_RED_PORT = gpio.gpioa;
const LED_RED_PIN = 15;
const LED_RED_PIN_MASK: u16 = 1 << LED_RED_PIN;

const USART_TX_PIN = 0;
const USART_TX_PIN_MASK: u16 = 1 << USART_TX_PIN;
const USART_TX_PORT = gpio.gpioe;

const USART_RX_PIN = 1;
const USART_RX_PIN_MASK: u16 = 1 << USART_RX_PIN;
const USART_RX_PORT = gpio.gpioe;

pub const usart_instance = usart.usart4;

const SPI_PORT = gpio.gpiob;
const SPI_RX_PIN = 14;
const SPI_RX_PIN_MASK: u16 = 1 << SPI_RX_PIN;

const SPI_TX_PIN = 15;
const SPI_TX_PIN_MASK: u16 = 1 << SPI_TX_PIN;

const SPI_CLK_PIN = 13;
const SPI_CLK_PIN_MASK: u16 = 1 << SPI_CLK_PIN;

pub var timer_interrupt: bool = undefined;
pub var sh: *shell.Shell = undefined;

fn UART4IRQHandler() callconv(.c) void {
    if (usart_instance.statr.rxne) {
        sh.process_char(usart_instance.datar);
    }
}

export fn UART4_IRQHandler() callconv(.naked) void {
    asm volatile(
        \\ call %[handler_fn]
        \\ mret
        :
        : [handler_fn] "i" (&UART4IRQHandler)
    );
}

export fn TIM6_IRQHandler() callconv(.naked) void {
    if (timer.bctm6.intfr.uif) {
        timer_interrupt = true;
        // clear interrupt flag
        timer.bctm6.intfr = timer.TimerIntfr{};
    }
    asm volatile("mret");
}

pub fn usart_write(byte: u8) void {
    usart_instance.write(byte);
}

inline fn init_usart() void {
    gpio_common.init(USART_TX_PORT, USART_TX_PIN_MASK, gpio.GpioModeOutputFastSpeed | gpio.GpioCnfAlternatePushPull);
    USART_RX_PORT.bshr = USART_RX_PIN_MASK; // pullup
    gpio_common.init(USART_RX_PORT, USART_RX_PIN_MASK, gpio.GpioCnfInputPullupPulldown);
    usart_instance.init(115200, cpu.cpu.current_frequency);
    pfic.pfic.interrupt_enable(interrupts.Interrupt.UART4.to_u8());
    usart_writer.usart_writer.writeCharFunc = usart_write;
}

inline fn init_spi() void {
    gpio_common.init(SPI_PORT, SPI_TX_PIN_MASK|SPI_CLK_PIN_MASK, gpio.GpioModeOutputFastSpeed | gpio.GpioCnfAlternatePushPull);
    SPI_PORT.bshr = SPI_RX_PIN_MASK; // pullup
    gpio_common.init(SPI_PORT, SPI_RX_PIN_MASK, gpio.GpioCnfInputPullupPulldown);
    spi.spi2.ctlr1 = spi.SpiCtlr1{.mstr = true, .spe = true, .br = .div8, .ssi = true, .ssm = true};
}

inline fn init_timer() void {
    timer.bctm6.psc = @truncate(cpu.cpu.current_frequency / 10000 - 1);
    timer.bctm6.atrlr.value16 = 1000 - 1; //0.1 second interval
    timer.bctm6.dmaintenr = timer.TimerDmaIntEnr{.uie = true};
    pfic.pfic.interrupt_enable(interrupts.Interrupt.TIM6.to_u8());
    timer_interrupt = false;
}

pub inline fn start_timer() void {
    timer.bctm6.ctlr1 = timer.TimerCtlr1{.cen = true, .apre = true};
}

inline fn init_clock() void {
    rcc.rcc.ctlr.hseon = true;
    while (!rcc.rcc.ctlr.hserdy) {
        asm volatile ("nop");
    }
    // pll multiplication is 12
    //rcc.rcc.cfgr0 = .{.usbpre = .div3, .pllmul = 10, .pllsrc_hse_or_prediv1 = true, .adcpre = .div8};
    //rcc.rcc.ctlr.pllon = true;
    //while (!rcc.rcc.ctlr.pllrdy) {
    //    asm volatile ("nop");
    //}
    rcc.rcc.cfgr0.sw = .hse;
    while (rcc.rcc.cfgr0.sws != .hse) {
        asm volatile ("nop");
    }
    //cpu.cpu.current_frequency = 144000000;
}

inline fn init_leds() void {
    gpio_common.init(LED_BLUE_PORT, LED_BLUE_PIN_MASK, gpio.GpioModeOutputSlowSpeed | gpio.GpioCnfOutputPushPull);
    gpio_common.init(LED_RED_PORT, LED_RED_PIN_MASK, gpio.GpioModeOutputSlowSpeed | gpio.GpioCnfOutputPushPull);
}

export fn SystemInit() callconv(.c) void {
    init_clock();
    system_timer.delay_init();
    rcc.rcc.apb2pcenr = rcc.RccCfgrApb2pcEnr{
        .iopaen = true, .iopben = true, .iopeen = true, .afioen = true
    };
    rcc.rcc.apb1pcenr = rcc.RccCfgrApb1pcEnr{.usart4en = true, .tim6en = true};
    afio.afio.pcfr2 = afio.AfioPcfr2{.usart4_rm = 3}; // remap to PE0:PE1

    init_leds();

    init_usart();
//    init_spi();
    init_timer();
}

pub inline fn led_blue_on() void {
    LED_BLUE_PORT.bshr = LED_BLUE_PIN_MASK;
}

pub inline fn led_blue_off() void {
    LED_BLUE_PORT.bcr = LED_BLUE_PIN_MASK;
}

pub inline fn led_red_on() void {
    LED_RED_PORT.bshr = LED_RED_PIN_MASK;
}

pub inline fn led_red_off() void {
    LED_RED_PORT.bcr = LED_RED_PIN_MASK;
}
