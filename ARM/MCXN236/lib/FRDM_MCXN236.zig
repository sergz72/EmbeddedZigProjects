const std = @import("std");
const gpio = @import("gpio");
const syscon = @import("syscon");
const scg = @import("scg");
const vbat = @import("vbat");
const system_timer = @import("system_timer");
const port = @import("port");
const lp_flexcomm = @import("lp_flexcomm");
const lpuart = @import("lpuart");
const nvic = @import("nvic");
const interrupts = @import("interrupts");
const cpu = @import("cpu");
const lpi2c = @import("lpi2c");
const lpspi = @import("lpspi");
const usart_writer = @import("usart_writer");

const LED_GPIO = gpio.gpio4;
const LED_RED_GPIO_PIN = 18;
const LED_RED_GPIO_PIN_MASK = 1 << LED_RED_GPIO_PIN;
const LED_BLUE_GPIO_PIN = 17;
const LED_BLUE_GPIO_PIN_MASK = 1 << LED_BLUE_GPIO_PIN;
const LED_GREEN_GPIO_PIN = 19;
const LED_GREEN_GPIO_PIN_MASK = 1 << LED_GREEN_GPIO_PIN;

const SW_GPIO = gpio.gpio0;
const SW2_GPIO_PIN = 20;
const SW3_GPIO_PIN = 6;

const UART_PORT = port.port1;
pub const UART_INSTANCE = lpuart.lpuart4;
const UART_RX_PIN = 8;
const UART_RX_PIN_MASK = 1 << UART_RX_PIN;
const UART_TX_PIN = 9;
const UART_TX_PIN_MASK = 1 << UART_TX_PIN;

pub const ARDUINO_I2C_INSTANCE = lpi2c.lpi2c5;
const ARDUINO_I2C_PORT = port.port1;
//--------------------------
const ARDUINO_I2C_SCL_PIN = 17;
const ARDUINO_I2C_SCL_PIN_MASK = (1 << ARDUINO_I2C_SCL_PIN);
const ARDUINO_I2C_SDA_PIN = 16;
const ARDUINO_I2C_SDA_PIN_MASK = (1 << ARDUINO_I2C_SDA_PIN);
//------------------------------
pub const SENSOR_I2C_INSTANCE = lpi2c.lpi2c2;
const SENSOR_I2C_PORT = port.port4;
//--------------------------
const SENSOR_I2C_SCL_PIN = 1;
const SENSOR_I2C_SCL_PIN_MASK = (1 << SENSOR_I2C_SCL_PIN);
const SENSOR_I2C_SDA_PIN = 0;
const SENSOR_I2C_SDA_PIN_MASK = (1 << SENSOR_I2C_SDA_PIN);
//------------------------------
pub const I2C_TIMEOUT = 10000;
const I2C_SPEED = 100000;

const ARDUINO_SPI_PORT = port.port1;
const ARDUINO_SPI_GPIO = gpio.gpio1;
pub const ARDUINO_SPI_INSTANCE = lpspi.lpspi3;
//--------------------------
const ARDUINO_SPI_RX_PIN = 2;
const ARDUINO_SPI_RX_PIN_MASK = 1 << ARDUINO_SPI_RX_PIN;
//--------------------------
const ARDUINO_SPI_TX_PIN = 0;
const ARDUINO_SPI_TX_PIN_MASK = 1 << ARDUINO_SPI_TX_PIN;
//--------------------------
const ARDUINO_SPI_CLK_PIN = 1;
const ARDUINO_SPI_CLK_PIN_MASK = 1 << ARDUINO_SPI_CLK_PIN;
//--------------------------
const ARDUINO_SPI_CS_PIN = 3;
const ARDUINO_SPI_CS_PIN_MASK = 1 << ARDUINO_SPI_CS_PIN;

const FLASH_SPI_PORT = port.port3;
pub const FLASH_SPI_INSTANCE = lpspi.lpspi6;
//--------------------------
const FLASH_SPI_D0_PIN = 20;
const FLASH_SPI_D0_PIN_MASK = 1 << FLASH_SPI_D0_PIN;
//--------------------------
const FLASH_SPI_D1_PIN = 22;
const FLASH_SPI_D1_PIN_MASK = 1 << FLASH_SPI_D1_PIN;
//--------------------------
const FLASH_SPI_D2_PIN = 13;
const FLASH_SPI_D2_PIN_MASK = 1 << FLASH_SPI_D2_PIN;
//--------------------------
const FLASH_SPI_D3_PIN = 12;
const FLASH_SPI_D3_PIN_MASK = 1 << FLASH_SPI_D3_PIN;
//--------------------------
const FLASH_SPI_CLK_PIN = 21;
const FLASH_SPI_CLK_PIN_MASK = 1 << FLASH_SPI_CLK_PIN;
//--------------------------
const FLASH_SPI_CS_PIN = 23;
const FLASH_SPI_CS_PIN_MASK = 1 << FLASH_SPI_CS_PIN;

pub const panic = std.debug.no_panic;

var usart_callback: *const fn(u8) void = undefined;

pub inline fn ledGreenOn() void {
    LED_GPIO.clearPins(LED_GREEN_GPIO_PIN_MASK);
}

pub inline fn ledGreenOff() void {
    LED_GPIO.setPins(LED_GREEN_GPIO_PIN_MASK);
}

pub inline fn ledGreenToggle() void {
    LED_GPIO.togglePins(LED_GREEN_GPIO_PIN_MASK);
}

pub inline fn ledBlueOn() void {
    LED_GPIO.clearPins(LED_BLUE_GPIO_PIN_MASK);
}

pub inline fn ledBlueOff() void {
    LED_GPIO.setPins(LED_BLUE_GPIO_PIN_MASK);
}

pub inline fn ledBlueToggle() void {
    LED_GPIO.togglePins(LED_BLUE_GPIO_PIN_MASK);
}

pub inline fn ledRedOn() void {
    LED_GPIO.clearPins(LED_RED_GPIO_PIN_MASK);
}

pub inline fn ledRedOff() void {
    LED_GPIO.setPins(LED_RED_GPIO_PIN_MASK);
}

pub inline fn ledRedToggle() void {
    LED_GPIO.togglePins(LED_RED_GPIO_PIN_MASK);
}

pub fn getSW2() bool {
    return (SW_GPIO.in(1 << SW2_GPIO_PIN) != 0);
}

pub fn getSW3() bool {
    return (SW_GPIO.in(1 << SW3_GPIO_PIN) != 0);
}

pub fn initClock() void {
    scg.Scg.enable();
    //scg.scg0.enableLdo();
    scg.scg0.enableXosc(24000000);
    vbat.vbat0.enableOsc32k();
    if (!scg.scg0.pllInit(false, .sosc, 24000000, 48000000)) {
        ledRedOn();
        while (true) {}
    }
    scg.scg0.switchMainClockTo(.apll);
    system_timer.delay_init(system_timer.init_div1);
    syscon.syscon0.pllclkdiv = syscon.Clkdiv{.halt = false};
    syscon.syscon0.pllclkdivsel = .pll0;
}

pub fn initGpio() void {
    syscon.syscon0.ahbclkctrlset0 = syscon.Ahbclkctrl0{
        .gpio0 = true, .port0 = true,.gpio4 = true, .port4 = true
    };
    ledGreenOff();
    ledBlueOff();
    ledRedOff();
    LED_GPIO.setAsOutput(LED_RED_GPIO_PIN_MASK | LED_BLUE_GPIO_PIN_MASK | LED_GREEN_GPIO_PIN_MASK);
}

pub fn initUart(baud: usize, callback: *const fn(u8) void) void {
    usart_callback = callback;
    syscon.syscon0.ahbclkctrlset0 = syscon.Ahbclkctrl0{.port1 = true};
    syscon.syscon0.ahbclkctrlset1 = syscon.Ahbclkctrl1{.fc4 = true};
    syscon.syscon0.fcclksel[4] = .pll_div;
    syscon.syscon0.lp_flexcommclkdiv[4] = syscon.Clkdiv{.halt = false};
    UART_PORT.pcr[UART_RX_PIN] = port.Pcr{.mux = 2, .ibe = true};
    UART_PORT.pcr[UART_TX_PIN] = port.Pcr{.mux = 2, .ibe = true};
    lp_flexcomm.lp_flexcomm4.pselid = lp_flexcomm.Pselid{.persel = .uart};
    lpuart.lpuart4.init(baud, cpu.cpu.current_frequency);
    nvic.nvic.enableInterrupt(interrupts.Interrupt.LP_FLEXCOMM4.toU8());
    usart_writer.usart_writer.writeCharFunc = uartWrite;
}

pub fn initArduinoI2c() void {
    syscon.syscon0.ahbclkctrlset0 = syscon.Ahbclkctrl0{.port1 = true};
    syscon.syscon0.ahbclkctrlset1 = syscon.Ahbclkctrl1{.fc5 = true};
    syscon.syscon0.fcclksel[5] = .pll_div;
    syscon.syscon0.lp_flexcommclkdiv[5] = syscon.Clkdiv{.halt = false};
    ARDUINO_I2C_PORT.pcr[ARDUINO_I2C_SCL_PIN] = port.Pcr{.mux = 2, .ibe = true, .ode = true, .pe = true, .ps = true};
    ARDUINO_I2C_PORT.pcr[ARDUINO_I2C_SDA_PIN] = port.Pcr{.mux = 2, .ibe = true, .ode = true, .pe = true, .ps = true};
    lp_flexcomm.lp_flexcomm5.pselid = lp_flexcomm.Pselid{.persel = .i2c};
    ARDUINO_I2C_INSTANCE.init(100000, cpu.cpu.current_frequency) catch {
        while(true) {}
    };
}

pub fn initArduinoSpi() void {
    syscon.syscon0.ahbclkctrlset0 = syscon.Ahbclkctrl0{.port1 = true};
    syscon.syscon0.ahbclkctrlset1 = syscon.Ahbclkctrl1{.fc3 = true};
    syscon.syscon0.fcclksel[3] = .pll_div;
    syscon.syscon0.lp_flexcommclkdiv[3] = syscon.Clkdiv{.halt = false};
    lp_flexcomm.lp_flexcomm3.pselid = lp_flexcomm.Pselid{.persel = .spi};
    ARDUINO_I2C_PORT.pcr[ARDUINO_SPI_CLK_PIN] = port.Pcr{.mux = 2, .ibe = true};
    ARDUINO_I2C_PORT.pcr[ARDUINO_SPI_TX_PIN] = port.Pcr{.mux = 2, .ibe = true};
    ARDUINO_I2C_PORT.pcr[ARDUINO_SPI_RX_PIN] = port.Pcr{.mux = 2, .ibe = true, .pe = true, .ps = true};
    ARDUINO_SPI_GPIO.setAsOutput(ARDUINO_SPI_CS_PIN_MASK);
    ARDUINO_SPI_INSTANCE.initMasterSoftwareCs(1000000, cpu.cpu.current_frequency);
}

pub fn initFlashSpi() void {
    //todo: implement flash spi init
}

pub fn initLightSensor() void {
    //todo: implement light sensor init
}

pub fn initSensorI2c() void {
    syscon.syscon0.ahbclkctrlset0 = syscon.Ahbclkctrl0{.port4 = true};
    syscon.syscon0.ahbclkctrlset1 = syscon.Ahbclkctrl1{.fc2 = true};
    syscon.syscon0.fcclksel[2] = .pll_div;
    syscon.syscon0.lp_flexcommclkdiv[2] = syscon.Clkdiv{.halt = false};
    SENSOR_I2C_PORT.pcr[SENSOR_I2C_SCL_PIN] = port.Pcr{.mux = 2, .ibe = true, .ode = true, .pe = true, .ps = true};
    SENSOR_I2C_PORT.pcr[SENSOR_I2C_SDA_PIN] = port.Pcr{.mux = 2, .ibe = true, .ode = true, .pe = true, .ps = true};
    lp_flexcomm.lp_flexcomm2.pselid = lp_flexcomm.Pselid{.persel = .i2c};
    SENSOR_I2C_INSTANCE.init(100000, cpu.cpu.current_frequency) catch {
        while(true) {}
    };
}

pub fn arduinoSpiCsSet(state: bool) void {
    if (state) {
        ARDUINO_SPI_GPIO.setPins(ARDUINO_SPI_CS_PIN_MASK);
    } else {
        ARDUINO_SPI_GPIO.clearPins(ARDUINO_SPI_CS_PIN_MASK);
    }
}

pub fn init() void {
    cpu.SystemPreInit();
    initGpio();
    initClock();
}

pub fn uartWrite(byte: u8) void {
    UART_INSTANCE.write(byte);
}

export fn LP_FLEXCOMM4_IRQHandler() callconv(.c) void {
    const stat = UART_INSTANCE.stat;
    if (stat.rdrf) {
        usart_callback(UART_INSTANCE.data.data8);
    }
}
