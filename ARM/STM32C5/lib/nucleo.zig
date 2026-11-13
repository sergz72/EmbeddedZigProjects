const std = @import("std");
const gpio = @import("gpio");
const rcc = @import("rcc");
const system_timer = @import("system_timer");
const cpu = @import("cpu");
const flash = @import("flash");
const usart = @import("usart");
const nvic = @import("nvic");
const interrupts = @import("interrupts");
const usart_writer = @import("usart_writer");
const dma_sender = @import("dma_sender");
const lpdma = @import("lpdma");
const i2c = @import("i2c");
const spi = @import("spi");

const LED_GREEN_PG0_PIN = 0;
const LED_GREEN_PG0_PIN_MASK: u16 = 1 << LED_GREEN_PG0_PIN;
const LED_GREEN_PG0_PORT = gpio.gpiog;

const LED_GREEN_PA5_PIN = 5;
const LED_GREEN_PA5_PIN_MASK: u16 = 1 << LED_GREEN_PA5_PIN;
const LED_GREEN_PA5_PORT = gpio.gpioa;

const LED_BLUE_PIN = 2;
const LED_BLUE_PIN_MASK: u16 = 1 << LED_BLUE_PIN;
const LED_BLUE_PORT = gpio.gpiog;

const LED_RED_PIN = 1;
const LED_RED_PIN_MASK: u16 = 1 << LED_RED_PIN;
const LED_RED_PORT = gpio.gpiog;

const LED_GPIO_INIT: gpio.GpioInit = .{
    .mode = .output,
    .speed = .low
};

const BUTTON_PIN = 13;
const BUTTON_PIN_MASK: u16 = 1 << BUTTON_PIN;
const BUTTON_PORT = gpio.gpioc;

const BUTTON_GPIO_INIT: gpio.GpioInit = .{
    .mode = .input
};

const USART_PORT = gpio.gpioa;
pub const USART_INSTANCE = usart.usart2;
//--------------------------------
const USART_TX_PIN = 2;
const USART_TX_PIN_MASK: u16 = 1 << USART_TX_PIN;
//--------------------------------
const USART_RX_PIN = 3;
const USART_RX_PIN_MASK: u16 = 1 << USART_RX_PIN;

pub const I2C_INSTANCE = i2c.i2c1;
//--------------------------
const I2C_PORT = gpio.gpiob;
const I2C_SCL_PIN = 6;
const I2C_SCL_PIN_MASK = (1 << I2C_SCL_PIN);
const I2C_SDA_PIN = 7;
const I2C_SDA_PIN_MASK = (1 << I2C_SDA_PIN);
const I2C_PINS_INIT: gpio.GpioInit = .{
    .mode = .alternate,
    .pull = .pullup,
    .open_drain = true,
    .speed = .low,
    .alternate = 4
};
//------------------------------
pub const I2C_TIMEOUT = 10000;
const I2C_SPEED = 100000;

pub const SPI_INSTANCE = spi.spi1;
//--------------------------
const SPI_PORT = gpio.gpioa;
const SPI_RX_PIN = 6;
const SPI_RX_PIN_MASK: u16 = 1 << SPI_RX_PIN;
const SPI_RX_PIN_INIT: gpio.GpioInit = .{
    .mode = .alternate,
    .pull = .pullup,
    .speed = .very_high,
    .alternate = 5
};
//--------------------------
const SPI_TX_PIN = 7;
const SPI_TX_PIN_MASK: u16 = 1 << SPI_TX_PIN;
const SPI_OUT_PINS_INIT: gpio.GpioInit = .{
    .mode = .alternate,
    .speed = .very_high,
    .alternate = 5
};
//--------------------------
const SPI_CLK_PIN = 5;
const SPI_CLK_PIN_MASK: u16 = 1 << SPI_CLK_PIN;
//--------------------------
const SPI_CS_PORT = gpio.gpiob;
const SPI_CS_PIN = 5;
const SPI_CS_PIN_MASK: u16 = 1 << SPI_CS_PIN;
const SPI_CS_PIN_INIT: gpio.GpioInit = .{
    .mode = .output,
    .speed = .very_high
};

var led_green_alternate: bool = undefined;
var rcc_init = rcc.RccInit{};
var usart_callback: *const fn(u8) void = undefined;
var dma_sender_instance = dma_sender.DmaSender {
    .dma_start = &usartDmaStart,
    .delayms = system_timer.delayms,
};

pub inline fn ledGreenOn() void {
    if (led_green_alternate) {
        LED_GREEN_PG0_PORT.setPins(LED_GREEN_PG0_PIN_MASK);
    } else {
        LED_GREEN_PA5_PORT.setPins(LED_GREEN_PA5_PIN_MASK);
    }
}

pub inline fn ledGreenOff() void {
    if (led_green_alternate) {
        LED_GREEN_PG0_PORT.clearPins(LED_GREEN_PG0_PIN_MASK);
    } else {
        LED_GREEN_PA5_PORT.clearPins(LED_GREEN_PA5_PIN_MASK);
    }
}

pub inline fn ledBlueOn() void {
    LED_BLUE_PORT.clearPins(LED_BLUE_PIN_MASK);
}

pub inline fn ledBlueOff() void {
    LED_BLUE_PORT.setPins(LED_BLUE_PIN_MASK);
}

pub inline fn ledRedOn() void {
    LED_RED_PORT.clearPins(LED_RED_PIN_MASK);
}

pub inline fn ledRedOff() void {
    LED_RED_PORT.setPins(LED_RED_PIN_MASK);
}

pub fn initLeds(led_green_pg0: bool) void {
    if (led_green_pg0) {
        rcc.rcc.ahb2enr.gpioaen = true;
    } else {
        rcc.rcc.ahb2enr.gpioben = true;
    }
    rcc.rcc.ahb2enr.gpiofen = true;
    rcc.rcc.ahb2enr.gpiogen = true;
    led_green_alternate = led_green_pg0;
    ledGreenOff();
    ledBlueOff();
    ledRedOff();
    if (led_green_pg0) LED_GREEN_PG0_PORT.init(LED_GREEN_PG0_PIN_MASK, LED_GPIO_INIT) else LED_GREEN_PA5_PORT.init(LED_GREEN_PA5_PIN_MASK, LED_GPIO_INIT);
    LED_BLUE_PORT.init(LED_BLUE_PIN_MASK, LED_GPIO_INIT);
    LED_RED_PORT.init(LED_RED_PIN_MASK, LED_GPIO_INIT);
}

pub fn initButton() void {
    rcc.rcc.ahb2enr.gpiocen = true;
    BUTTON_PORT.init(BUTTON_PIN_MASK, BUTTON_GPIO_INIT);
}

pub fn usartDmaInit(buffer_size: usize, allocator: std.mem.Allocator) error{OutOfMemory}!void {
    try dma_sender_instance.init(buffer_size, allocator);
    rcc.rcc.ahb1enr.lpdma1en = true;
    lpdma.lpdma1.channels[0].initMemoryToPeripheral8(@intFromPtr(&USART_INSTANCE.tdr), .usart2_tx);
    nvic.nvic.enableInterrupt(interrupts.Interrupt.LPDMA1_Channel0.toU8());
}

pub fn initUsart(baud: u32, callback: *const fn(u8) void, use_dma: bool) void {
    usart_callback = callback;
    rcc.rcc.ahb2enr.gpioaen = true;
    rcc.rcc.apb1lenr.usart2en = true;
    var init_data: gpio.GpioInit = .{
        .mode = .alternate,
        .speed = .very_high,
        .alternate = 7
    };
    USART_PORT.init(USART_TX_PIN_MASK, init_data); // TX
    init_data.pull = .pullup;
    USART_PORT.init(USART_RX_PIN_MASK, init_data); // RX
    if (use_dma) {
        USART_INSTANCE.initDma(baud, cpu.cpu.pclk1_frequency);
        usart_writer.usart_writer.writeCharFunc = usartWriteDma;
        usart_writer.usart_writer.writeFlushFunc = usartFlushDma;
    } else {
        USART_INSTANCE.init(baud, cpu.cpu.pclk1_frequency);
        usart_writer.usart_writer.writeCharFunc = usartWrite;
    }
    nvic.nvic.enableInterrupt(interrupts.Interrupt.USART2.toU8());
}

pub fn initArduinoI2c() void {
    rcc.rcc.ahb2enr.gpioben = true;
    rcc.rcc.apb1lenr.i2c1en = true;
    I2C_PORT.init(I2C_SCL_PIN_MASK | I2C_SDA_PIN_MASK, I2C_PINS_INIT);
    I2C_INSTANCE.initMaster(I2C_SPEED, cpu.cpu.pclk1_frequency) catch {
        while (true) {}
    };
}

pub fn initArduinoSPI(spi_baud: usize, comm: spi.Comm) void {
    rcc.rcc.ahb2enr.gpioaen = true;
    rcc.rcc.ahb2enr.gpioben = true;
    rcc.rcc.apb2enr.spi1en = true;
    SPI_PORT.init(SPI_TX_PIN_MASK | SPI_CLK_PIN_MASK, SPI_OUT_PINS_INIT);
    SPI_PORT.init(SPI_RX_PIN_MASK, SPI_RX_PIN_INIT);
    SPI_INSTANCE.initMasterSoftwareCs(spi_baud, cpu.cpu.pclk2_frequency, comm);
    SPI_CS_PORT.setPins(SPI_CS_PIN_MASK); // cs is 1
    SPI_CS_PORT.init(SPI_CS_PIN_MASK, SPI_CS_PIN_INIT);
}

pub fn arduinoSpiCsSet(state: bool) void {
    if (state) {
        SPI_CS_PORT.setPins(SPI_CS_PIN_MASK);
    } else {
        SPI_CS_PORT.clearPins(SPI_CS_PIN_MASK);
    }
}

pub fn init(led_green_pg0: bool) void {
    rcc.rcc.hseOn(false);
    rcc.rcc.clockSwitch(.hse);
    system_timer.delay_init(system_timer.init_div8);
    initLeds(led_green_pg0);
    initButton();
}

export fn USART2_IRQHandler() callconv(.c) void {
    if (USART_INSTANCE.isr.ore) {
        _ = USART_INSTANCE.rdr;
        return;
    }
    while (USART_INSTANCE.isr.rxfne) {
        usart_callback(@truncate(USART_INSTANCE.rdr));
    }
}

pub fn usartWrite(byte: u8) void {
    USART_INSTANCE.write(byte);
}

pub fn shellWriteCharDma(byte: u8) void {
    usartWriteDma(byte);
    usartFlushDma();
}

pub fn usartWriteDma(byte: u8) void {
    dma_sender_instance.sendChar(byte);
}

pub fn usartFlushDma() void {
    dma_sender_instance.start();
}

fn usartDmaStart(data: []const u8) usize {
    lpdma.lpdma1.channels[0].startTransferMemoryToPeripheral8(data);
    return data.len;
}

export fn LPDMA1_Channel0_IRQHandler() callconv(.c) void {
    lpdma.lpdma1.channels[0].clearInterruptFlags();
    dma_sender_instance.dmaDone();
}