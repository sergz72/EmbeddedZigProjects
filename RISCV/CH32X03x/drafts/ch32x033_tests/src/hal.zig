const gpio = @import("gpio");
const rcc = @import("rcc");
const flash = @import("flash");
const system_timer = @import("system_timer");
const afio = @import("afio");
const usart = @import("usart");
const cpu = @import("cpu");
const pfic = @import("pfic");
const interrupts = @import("interrupts");
const usart_writer = @import("usart_writer");
const shell = @import("shell");
const timer = @import("timer");
const spi = @import("spi");

const LED_PIN = 4;
const LED_PIN_MASK: u24 = 1 << LED_PIN;
const LED_PORT = gpio.gpioa;

const USART_INSTANCE = usart.usart2;
//--------------------------
const USART_TX_PIN = 2;
const USART_TX_PIN_MASK: u24 = 1 << USART_TX_PIN;
const USART_TX_PORT = gpio.gpioa;
//--------------------------
const USART_RX_PIN = 3;
const USART_RX_PIN_MASK: u124 = 1 << USART_RX_PIN;
const USART_RX_PORT = gpio.gpioa;

const SPI_PORT = gpio.gpiob;
//--------------------------
const SPI_RX_PIN = 14;
const SPI_RX_PIN_MASK: u24 = 1 << SPI_RX_PIN;
//--------------------------
const SPI_TX_PIN = 15;
const SPI_TX_PIN_MASK: u24 = 1 << SPI_TX_PIN;
//--------------------------
const SPI_CLK_PIN = 13;
const SPI_CLK_PIN_MASK: u24 = 1 << SPI_CLK_PIN;
//--------------------------
const SPI_CS_PORT = gpio.gpiob;
const SPI_CS_PIN = 13;
const SPI_CS_PIN_MASK: u24 = 1 << SPI_CS_PIN;

pub var timer_interrupt: bool = undefined;
pub var sh: *shell.Shell = undefined;

fn USART2IRQHandler() callconv(.c) void {
    if (USART_INSTANCE.statr.rxne) {
        sh.process_char(USART_INSTANCE.datar);
    }
    asm volatile("mret");
}

export fn USART2_IRQHandler() callconv(.naked) void {
    asm volatile(
        \\ call %[handler_fn]
        \\ mret
        :
        : [handler_fn] "i" (&USART2IRQHandler)
    );
}

export fn TIM3_IRQHandler() callconv(.naked) void {
    if (timer.gptm3.intfr.uif) {
        timer_interrupt = true;
        // clear interrupt flag
        timer.gptm3.intfr = timer.TimerIntfr{};
    }
    asm volatile("mret");
}

pub fn usart_write(byte: u8) void {
    USART_INSTANCE.write(byte);
}

fn init_usart() void {
    USART_TX_PORT.init(USART_TX_PIN_MASK, gpio.GpioModeOutput | gpio.GpioCnfAlternatePushPull);
    USART_RX_PORT.bshr = USART_RX_PIN_MASK; // pullup
    USART_RX_PORT.init(USART_RX_PIN_MASK, gpio.GpioCnfInputPullupPulldown);
    USART_INSTANCE.init(115200, cpu.cpu.current_frequency);
    pfic.pfic.interrupt_enable(interrupts.Interrupt.USART2.to_u8());
    usart_writer.usart_writer.writeCharFunc = usart_write;
}

inline fn init_timer() void {
    timer.gptm3.psc = @truncate(cpu.cpu.current_frequency / 10000 - 1);
    timer.gptm3.atrlr = 1000 - 1; //0.1 second interval
    timer.gptm3.dmaintenr = timer.TimerDmaIntEnr{.uie = true};
    pfic.pfic.interrupt_enable(interrupts.Interrupt.TIM3.to_u8());
    timer_interrupt = false;
}

pub inline fn start_timer() void {
    timer.gptm3.ctlr1 = timer.TimerCtlr1{.cen = true, .apre = true};
}

inline fn init_clock() void {
    flash.flash.actlr = 2; // 2 wait states, 24 to 48 mhz
    rcc.rcc.cfgr0.hpre = .off;
    cpu.cpu.current_frequency = 48000000;
}

inline fn init_spi() void {
    SPI_PORT.init(SPI_TX_PIN_MASK|SPI_CLK_PIN_MASK, gpio.GpioModeOutput | gpio.GpioCnfAlternatePushPull);
    SPI_PORT.bshr = SPI_RX_PIN_MASK; // pullup
    SPI_PORT.init(SPI_RX_PIN_MASK, gpio.GpioCnfInputPullupPulldown);
    spi.spi1.ctlr1 = spi.SpiCtlr1{.mstr = true, .spe = true, .br = .div8, .ssi = true, .ssm = true};
}

inline fn init_i2c() void {
}

export fn SystemInit() callconv(.c) void {
    init_clock();
    system_timer.delay_init();
    rcc.rcc.apb2pcenr = rcc.RccCfgrApb2pcEnr{.iopaen = true, .afioen = true, .spi1en = true};
    rcc.rcc.apb1pcenr = rcc.RccCfgrApb1pcEnr{.usart2en = true, .i2c1en = true, .tim3en = true};
    LED_PORT.init(LED_PIN_MASK, gpio.GpioModeOutput | gpio.GpioCnfOutputPushPull);
    init_usart();
    init_timer();
    //init_spi();
    //init_i2c();
}

pub fn led_on() void {
    LED_PORT.bcr = LED_PIN_MASK;
}

pub fn led_off() void {
    LED_PORT.bshr = LED_PIN_MASK;
}