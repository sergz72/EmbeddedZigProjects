const rcc = @import("rcc");
const gpio = @import("gpio");
const afio = @import("afio");
const usart = @import("usart");
const system_timer = @import("system_timer");
const cpu = @import("cpu");
const pfic = @import("pfic");
const usart_writer = @import("usart_writer");
const dac = @import("dac");
const spi = @import("spi");
const dma = @import("dma");
const builtin = @import("builtin");

const LED_PIN = 0;
const LED_PIN_MASK: u16 = 1 << LED_PIN;
const LED_PORT = gpio.gpiod;

const USART_TX_PIN = 6;
const USART_TX_PIN_MASK: u16 = 1 << USART_TX_PIN;
const USART_TX_PORT = gpio.gpiob;

const USART_RX_PIN = 7;
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

const LCD_DC_PIN = 11;
const LCD_DC_PIN_MASK: u16 = 1 << LCD_DC_PIN;
const LCD_DC_PORT = gpio.gpiob;

const LCD_CS_PIN = 10;
const LCD_CS_PIN_MASK: u16 = 1 << LCD_CS_PIN;
const LCD_CS_PORT = gpio.gpioa;

var command_buffer: [128]u8 = undefined;
var command_idx: usize = undefined;
pub var command: ?[]u8 = undefined;

export fn USART1_IRQHandler() callconv(.naked) void {
    @setRuntimeSafety(false);
    if (builtin.mode == .debug) asm volatile ("addi sp, sp, -16");
    if (usart.usart1.statr.rxne) {
        const data = usart.usart1.datar;
        if (command == null) {
            if (data == '\r') {
                usart.usart1.datar = data;
                command = command_buffer[0..command_idx];
                command_idx = 0;
            } else if (command_idx < command_buffer.len) {
                usart.usart1.datar = data;
                command_buffer[command_idx] = data;
                command_idx += 1;
            }
        }
    }
    if (builtin.mode == .debug) asm volatile ("addi sp, sp, 16");
    asm volatile("mret");
}

fn usartWrite(byte: u8) void {
    usart.usart1.write(byte);
}

inline fn init_usart() void {
    command_idx = 0;
    command = null;
    USART_TX_PORT.Init(USART_TX_PIN_MASK, gpio.GpioModeOutputFastSpeed | gpio.GpioCnfAlternatePushPull);
    USART_RX_PORT.bshr = USART_RX_PIN_MASK; // pullup
    USART_RX_PORT.Init(USART_RX_PIN_MASK, gpio.GpioCnfInputPullupPulldown);
    usart.usart1.init(115200, cpu.cpu.current_frequency);
    pfic.pfic.interrupt_enable(pfic.Interrupt.USART1);
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

export fn SystemInit() callconv(.c) void {
    system_timer.delay_init();
    rcc.rcc.apb2pcenr = rcc.RccCfgrApb2pcEnr{.iopaen = true, .iopden = true, .iopben = true, .afioen = true, .usart1en = true};
    rcc.rcc.apb1pcenr = rcc.RccCfgrApb1pcEnr{.dacen = true, .spi2en = true};
    afio.afio.pcfr1 = afio.AfioPcfr1{.pd01_rm = true, .usart1_rm = true};

    LED_PORT.Init(LED_PIN_MASK, gpio.GpioModeOutputSlowSpeed | gpio.GpioCnfOutputPushPull);

    DAC_PORT.Init(DAC_PIN_MASK, gpio.GpioModeInput | gpio.GpioCnfInputAnalog);
    dac.dac.ctlr = dac.DacCtlr{.ch2 = dac.DacCtlrChannel{.en = true}};

    init_usart();
    init_spi();
    init_lcd();
}

pub inline fn led_on() void {
    LED_PORT.bshr = LED_PIN_MASK;
}

pub inline fn led_off() void {
    LED_PORT.bcr = LED_PIN_MASK;
}

pub fn lcd_writer(data: []const u8) void {
    spi.spi2.send_poll8(data);
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
