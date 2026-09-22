const rcc = @import("rcc");
const gpio = @import("gpio");
const afio = @import("afio");
const usart = @import("usart");
const system_timer = @import("system_timer");
const cpu = @import("cpu");
const pfic = @import("pfic");
const interrupts = @import("interrupts");
const usart_writer = @import("usart_writer");
const dac = @import("dac");
const spi = @import("spi");
const timer = @import("timer");
const exti = @import("exti");
const builtin = @import("builtin");

const LED_PORT = gpio.gpioc;
const LED_PIN = 8;
const LED_PIN_MASK: u16 = 1 << LED_PIN;

const USART_TX_PIN = 10;
const USART_TX_PIN_MASK: u16 = 1 << USART_TX_PIN;
const USART_TX_PORT = gpio.gpiob;

const USART_RX_PIN = 11;
const USART_RX_PIN_MASK: u16 = 1 << USART_RX_PIN;
const USART_RX_PORT = gpio.gpiob;

const DAC_PIN = 5;
const DAC_PIN_MASK: u16 = 1 << DAC_PIN;
const DAC_PORT = gpio.gpioa;

const SPI_PORT = gpio.gpiob;
const SPI_RX_PIN = 14;
const SPI_RX_PIN_MASK: u16 = 1 << SPI_RX_PIN;

const SPI_TX_PIN = 15;
const SPI_TX_PIN_MASK: u16 = 1 << SPI_TX_PIN;

const SPI_CLK_PIN = 13;
const SPI_CLK_PIN_MASK: u16 = 1 << SPI_CLK_PIN;

const LCD_RESET_PIN = 12;
const LCD_RESET_PIN_MASK: u16 = 1 << LCD_RESET_PIN;
const LCD_RESET_PORT = gpio.gpiob;

const LCD_DC_PIN = 7;
const LCD_DC_PIN_MASK: u16 = 1 << LCD_DC_PIN;
const LCD_DC_PORT = gpio.gpioc;

const LCD_CS_PIN = 6;
const LCD_CS_PIN_MASK: u16 = 1 << LCD_CS_PIN;
const LCD_CS_PORT = gpio.gpioc;

const FPGA_INT_PIN = 6;
const FPGA_INT_PIN_MASK: u16 = 1 << FPGA_INT_PIN;
const FPGA_INT_PORT = gpio.gpiob;

const FPGA_CS_PIN = 7;
const FPGA_CS_PIN_MASK: u16 = 1 << FPGA_CS_PIN;
const FPGA_CS_PORT = gpio.gpiob;

const MCO_PIN = 8;
const MCO_PIN_MASK: u16 = 1 << MCO_PIN;
const MCO_PORT = gpio.gpioa;

pub var command: [128]u8 = undefined;
pub var command_idx: usize = undefined;
pub var command_ready: bool = undefined;
pub var timer_interrupt: bool = undefined;
pub var fpga_interrupt: bool = undefined;

fn USART3IRQHandler() callconv(.c) void {
    @setRuntimeSafety(false);
    if (usart.usart3.statr.rxne) {
        const data = usart.usart3.datar;
        if (!command_ready) {
            if (data == '\r') {
                usart.usart3.datar = data;
                command_ready = true;
            } else if (command_idx < command.len) {
                usart.usart3.datar = data;
                command[command_idx] = data;
                command_idx += 1;
            }
        }
    }
}

export fn USART3_IRQHandler() callconv(.naked) void {
    asm volatile(
        \\ call %[handler_fn]
        \\ mret
        :
        : [handler_fn] "i" (&USART3IRQHandler)
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

export fn EXTI9_5_IRQHandler() callconv(.naked) void {
    if ((exti.exti.intfr & FPGA_INT_PIN_MASK) != 0) {
        fpga_interrupt = true;
    }
    exti.exti.intfr = 0x1FFFFF; // clear all interrupt flags
    asm volatile("mret");
}

fn usartWrite(byte: u8) void {
    usart.usart3.write(byte);
}

inline fn init_usart() void {
    command_idx = 0;
    command_ready = false;
    USART_TX_PORT.Init(USART_TX_PIN_MASK, gpio.GpioModeOutputFastSpeed | gpio.GpioCnfAlternatePushPull);
    USART_RX_PORT.bshr = USART_RX_PIN_MASK; // pullup
    USART_RX_PORT.Init(USART_RX_PIN_MASK, gpio.GpioCnfInputPullupPulldown);
    usart.usart3.init(115200, cpu.cpu.current_frequency);
    pfic.pfic.interrupt_enable(interrupts.Interrupt.USART3.to_u8());
    usart_writer.usart_writer.writeCharFunc = usartWrite;
}

inline fn init_spi() void {
    SPI_PORT.Init(SPI_TX_PIN_MASK|SPI_CLK_PIN_MASK, gpio.GpioModeOutputFastSpeed | gpio.GpioCnfAlternatePushPull);
    SPI_PORT.bshr = SPI_RX_PIN_MASK; // pullup
    SPI_PORT.Init(SPI_RX_PIN_MASK, gpio.GpioCnfInputPullupPulldown);
    spi.spi2.ctlr1 = spi.SpiCtlr1{.mstr = true, .spe = true, .br = .div8, .ssi = true, .ssm = true};
}

inline fn init_lcd() void {
    LCD_CS_PORT.bshr = LCD_CS_PIN_MASK;
    LCD_CS_PORT.Init(LCD_CS_PIN_MASK, gpio.GpioModeOutputFastSpeed | gpio.GpioCnfOutputPushPull);
    LCD_RESET_PORT.Init(LCD_RESET_PIN_MASK, gpio.GpioModeOutputFastSpeed | gpio.GpioCnfOutputPushPull);
    LCD_DC_PORT.Init(LCD_DC_PIN_MASK, gpio.GpioModeOutputFastSpeed | gpio.GpioCnfOutputPushPull);
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

inline fn init_exti() void {
    FPGA_INT_PORT.bcr = FPGA_INT_PIN_MASK; // pulldown
    FPGA_INT_PORT.Init(FPGA_INT_PIN_MASK, gpio.GpioCnfInputPullupPulldown);
    afio.afio.exticr2.exti6 = .portb;
    exti.exti.rtenr = FPGA_INT_PIN_MASK;  // rising edge
    exti.exti.intenr = FPGA_INT_PIN_MASK; // interrupt enable
    pfic.pfic.interrupt_enable(interrupts.Interrupt.EXTI9_5.to_u8());
    fpga_interrupt = false;
}

inline fn init_fpga() void {
    init_exti();
    FPGA_CS_PORT.Init(FPGA_CS_PIN_MASK, gpio.GpioModeOutputFastSpeed | gpio.GpioCnfOutputPushPull);
}

pub inline fn fpga_set_cs() void {
    FPGA_CS_PORT.bshr = FPGA_CS_PIN_MASK;
}

inline fn init_dac() void {
    DAC_PORT.Init(DAC_PIN_MASK, gpio.GpioModeInput | gpio.GpioCnfInputAnalog);
    dac.dac.ctlr = dac.DacCtlr{.ch2 = dac.DacCtlrChannel{.en = true}};
}

inline fn init_clkout() void {
    MCO_PORT.Init(MCO_PIN_MASK, gpio.GpioModeOutputFastSpeed | gpio.GpioCnfAlternatePushPull);
    rcc.rcc.cfgr0.mco = .plldiv2;
}

inline fn init_clock() void {
    rcc.rcc.ctlr.hsebyp = true;
    rcc.rcc.ctlr.hseon = true;
    while (!rcc.rcc.ctlr.hserdy) {
        asm volatile ("nop");
    }
    // pll multiplication is 12
    rcc.rcc.cfgr0 = .{.usbpre = .div3, .pllmul = 10, .pllsrc_hse_or_prediv1 = true, .adcpre = .div8};
    rcc.rcc.ctlr.pllon = true;
    while (!rcc.rcc.ctlr.pllrdy) {
        asm volatile ("nop");
    }
    rcc.rcc.cfgr0.sw = .pll;
    while (rcc.rcc.cfgr0.sws != .pll) {
        asm volatile ("nop");
    }
    cpu.cpu.current_frequency = 144000000;
}

export fn SystemInit() callconv(.c) void {
    init_clock();
    system_timer.delay_init();
    rcc.rcc.apb2pcenr = rcc.RccCfgrApb2pcEnr{
        .iopaen = true, .iopben = true, .iopcen = true, .afioen = true
    };
    rcc.rcc.apb1pcenr = rcc.RccCfgrApb1pcEnr{.dacen = true, .usart3en = true, .spi2en = true, .tim6en = true};

    LED_PORT.Init(LED_PIN_MASK, gpio.GpioModeOutputSlowSpeed | gpio.GpioCnfOutputPushPull);

    init_dac();
    init_clkout();

    init_usart();
    init_spi();
    init_lcd();
    init_timer();
    init_fpga();
}

pub inline fn led_on() void {
    LED_PORT.bshr = LED_PIN_MASK;
}

pub inline fn led_off() void {
    LED_PORT.bcr = LED_PIN_MASK;
}

pub fn lcd_writer(data: []const u8) void {
    spi.spi2.send_poll8(data);
    spi.spi2.wait_for_transfer_complete();
}

pub fn lcd_reset_set(state: bool) void {
    if (state) {
        LCD_RESET_PORT.bshr = LCD_RESET_PIN_MASK;
    } else {
        LCD_RESET_PORT.bcr = LCD_RESET_PIN_MASK;
    }
}

pub fn lcd_dc_set(state: bool) void {
    if (state) {
        LCD_DC_PORT.bshr = LCD_DC_PIN_MASK;
    } else {
        LCD_DC_PORT.bcr = LCD_DC_PIN_MASK;
    }
}

pub fn lcd_cs_set(state: bool) void {
    if (state) {
        LCD_CS_PORT.bshr = LCD_CS_PIN_MASK;
    } else {
        LCD_CS_PORT.bcr = LCD_CS_PIN_MASK;
    }
}
