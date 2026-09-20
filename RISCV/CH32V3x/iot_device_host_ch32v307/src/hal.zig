const rcc = @import("rcc");
const gpio = @import("gpio");
const afio = @import("afio");
const usart = @import("usart");
const system_timer = @import("system_timer");
const cpu = @import("cpu");
const pfic = @import("pfic");
const usart_writer = @import("usart_writer");
const spi = @import("spi");
const timer = @import("timer");
const eth = @import("eth");
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

pub var command: [128]u8 = undefined;
pub var command_idx: usize = undefined;
pub var command_ready: bool = undefined;
pub var timer_interrupt: bool = undefined;

fn UART4IRQHandler() callconv(.c) void {
    @setRuntimeSafety(false);
    if (usart_instance.statr.rxne) {
        const data = usart_instance.datar;
        if (!command_ready) {
            if (data == '\r') {
                usart_instance.datar = data;
                command_ready = true;
            } else if (command_idx < command.len) {
                usart_instance.datar = data;
                command[command_idx] = data;
                command_idx += 1;
            }
        }
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

fn usartWrite(byte: u8) void {
    usart_instance.write(byte);
}

inline fn init_usart() void {
    command_idx = 0;
    command_ready = false;
    USART_TX_PORT.Init(USART_TX_PIN_MASK, gpio.GpioModeOutputFastSpeed | gpio.GpioCnfAlternatePushPull);
    USART_RX_PORT.bshr = USART_RX_PIN_MASK; // pullup
    USART_RX_PORT.Init(USART_RX_PIN_MASK, gpio.GpioCnfInputPullupPulldown);
    usart_instance.init(115200, cpu.cpu.current_frequency);
    pfic.pfic.interrupt_enable(pfic.Interrupt.UART4);
    usart_writer.usart_writer.writeCharFunc = usartWrite;
}

inline fn init_spi() void {
    SPI_PORT.Init(SPI_TX_PIN_MASK|SPI_CLK_PIN_MASK, gpio.GpioModeOutputFastSpeed | gpio.GpioCnfAlternatePushPull);
    SPI_PORT.bshr = SPI_RX_PIN_MASK; // pullup
    SPI_PORT.Init(SPI_RX_PIN_MASK, gpio.GpioCnfInputPullupPulldown);
    spi.spi2.ctlr1 = spi.SpiCtlr1{.mstr = true, .spe = true, .br = .div8, .ssi = true, .ssm = true};
}

inline fn init_timer() void {
    timer.bctm6.psc = @truncate(cpu.cpu.current_frequency / 10000 - 1);
    timer.bctm6.atrlr.value16 = 1000 - 1; //0.1 second interval
    timer.bctm6.dmaintenr = timer.TimerDmaIntEnr{.uie = true};
    pfic.pfic.interrupt_enable(pfic.Interrupt.TIM6);
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
    LED_BLUE_PORT.Init(LED_BLUE_PIN_MASK, gpio.GpioModeOutputSlowSpeed | gpio.GpioCnfOutputPushPull);
    LED_RED_PORT.Init(LED_RED_PIN_MASK, gpio.GpioModeOutputSlowSpeed | gpio.GpioCnfOutputPushPull);
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
