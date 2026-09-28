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

const SPI_INSTANCE = spi.spi1;
//--------------------------
const SPI_PORT = gpio.gpioa;
//--------------------------
const SPI_RX_PIN = 6;
const SPI_RX_PIN_MASK: u24 = 1 << SPI_RX_PIN;
//--------------------------
const SPI_TX_PIN = 7;
const SPI_TX_PIN_MASK: u24 = 1 << SPI_TX_PIN;
//--------------------------
const SPI_CLK_PIN = 5;
const SPI_CLK_PIN_MASK: u24 = 1 << SPI_CLK_PIN;
//--------------------------
const SPI_FLASH_CS_PORT = gpio.gpiob;
const SPI_FLASH_CS_PIN = 7;
const SPI_FLASH_CS_PIN_MASK: u24 = 1 << SPI_FLASH_CS_PIN;
//--------------------------
const SPI_LCD_CS_PORT = gpio.gpioc;
const SPI_LCD_CS_PIN = 3;
const SPI_LCD_CS_PIN_MASK: u24 = 1 << SPI_LCD_CS_PIN;
//--------------------------
const SPI_LCD_RESET_PORT = gpio.gpioa;
const SPI_LCD_RESET_PIN = 0;
const SPI_LCD_RESET_PIN_MASK: u24 = 1 << SPI_LCD_RESET_PIN;

pub var timer_interrupt: bool = undefined;
pub var sh: *shell.Shell = undefined;

fn USART2IRQHandler() callconv(.c) void {
    @setRuntimeSafety(false);
    if (USART_INSTANCE.statr.rxne) {
        sh.processChar(USART_INSTANCE.datar);
    }
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

pub fn usartWrite(byte: u8) void {
    USART_INSTANCE.write(byte);
}

fn initUsart() void {
    USART_TX_PORT.init(USART_TX_PIN_MASK, gpio.GpioModeOutput | gpio.GpioCnfAlternatePushPull);
    USART_RX_PORT.bshr = USART_RX_PIN_MASK; // pullup
    USART_RX_PORT.init(USART_RX_PIN_MASK, gpio.GpioCnfInputPullupPulldown);
    USART_INSTANCE.init(115200, cpu.cpu.current_frequency);
    pfic.pfic.interruptEnable(interrupts.Interrupt.USART2.toU8());
    usart_writer.usart_writer.writeCharFunc = usartWrite;
}

inline fn initTimer() void {
    timer.gptm3.psc = @truncate(cpu.cpu.current_frequency / 10000 - 1);
    timer.gptm3.atrlr = 1000 - 1; //0.1 second interval
    timer.gptm3.dmaintenr = timer.TimerDmaIntEnr{.uie = true};
    pfic.pfic.interruptEnable(interrupts.Interrupt.TIM3.toU8());
    timer_interrupt = false;
}

pub inline fn startTimer() void {
    timer.gptm3.ctlr1 = timer.TimerCtlr1{.cen = true, .apre = true};
}

inline fn initClock() void {
    flash.flash.actlr = 2; // 2 wait states, 24 to 48 mhz
    rcc.rcc.cfgr0.hpre = .off;
    cpu.cpu.current_frequency = 48000000;
}

inline fn initSpi() void {
    SPI_PORT.init(SPI_TX_PIN_MASK|SPI_CLK_PIN_MASK, gpio.GpioModeOutput | gpio.GpioCnfAlternatePushPull);
    SPI_PORT.bshr = SPI_RX_PIN_MASK; // pullup
    SPI_PORT.init(SPI_RX_PIN_MASK, gpio.GpioCnfInputPullupPulldown);
    SPI_INSTANCE.ctlr1 = spi.SpiCtlr1{.mstr = true, .spe = true, .br = .div8, .ssi = true, .ssm = true};
    SPI_FLASH_CS_PORT.bshr = SPI_FLASH_CS_PIN_MASK; // cs is 1
    SPI_FLASH_CS_PORT.init(SPI_FLASH_CS_PIN_MASK, gpio.GpioModeOutput | gpio.GpioCnfOutputPushPull);
    SPI_LCD_CS_PORT.bshr = SPI_LCD_CS_PIN_MASK; // cs is 1
    SPI_LCD_CS_PORT.init(SPI_LCD_CS_PIN_MASK, gpio.GpioModeOutput | gpio.GpioCnfOutputPushPull);
    //SPI_LCD_RESET_PORT.bshr = SPI_LCD_RESET_PIN_MASK; // cs is 1
    SPI_LCD_RESET_PORT.init(SPI_LCD_RESET_PIN_MASK, gpio.GpioModeOutput | gpio.GpioCnfOutputPushPull);
}

inline fn initI2c() void {
}

export fn SystemInit() callconv(.c) void {
    initClock();
    system_timer.delayInit();
    rcc.rcc.apb2pcenr = rcc.RccCfgrApb2pcEnr{.iopaen = true, .afioen = true, .spi1en = true};
    rcc.rcc.apb1pcenr = rcc.RccCfgrApb1pcEnr{.usart2en = true, .i2c1en = true, .tim3en = true};
    LED_PORT.init(LED_PIN_MASK, gpio.GpioModeOutput | gpio.GpioCnfOutputPushPull);
    initUsart();
    initTimer();
    initSpi();
    initI2c();
}

pub fn ledOn() void {
    LED_PORT.bcr = LED_PIN_MASK;
}

pub fn ledOff() void {
    LED_PORT.bshr = LED_PIN_MASK;
}

inline fn spiFlashCsClr() void {
    SPI_FLASH_CS_PORT.bcr = SPI_FLASH_CS_PIN_MASK;
}

inline fn spiFlashCsSet() void {
    SPI_FLASH_CS_PORT.bshr = SPI_FLASH_CS_PIN_MASK;
}

inline fn spiLcdCsClr() void {
    SPI_LCD_CS_PORT.bcr = SPI_LCD_CS_PIN_MASK;
}

inline fn spiLcdCsSet() void {
    SPI_LCD_CS_PORT.bshr = SPI_LCD_CS_PIN_MASK;
}

inline fn spiLcdResetClr() void {
    SPI_LCD_RESET_PORT.bcr = SPI_LCD_RESET_PIN_MASK;
}

inline fn spiLcdResetSet() void {
    SPI_LCD_RESET_PORT.bshr = SPI_LCD_RESET_PIN_MASK;
}

pub fn spiFlashTransfer(write_data: []const u8, read_data: ?[]u8) bool {
    spiFlashCsClr();
    SPI_INSTANCE.transferPoll8(write_data, read_data);
    spiFlashCsSet();
    return true;
}

pub fn spiFlashSendReceive(write_data: []const u8, read_data: []u8) bool {
    spiFlashCsClr();
    SPI_INSTANCE.transferPoll8(write_data, read_data);
    spiFlashCsSet();
    return true;
}

pub fn spiLcdWrite(data: []u8) void {
    spiLcdCsClr();
    SPI_INSTANCE.sendPoll8(data);
    spiLcdCsSet();
}
