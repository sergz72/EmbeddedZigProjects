const gpio = @import("gpio");
const rcc = @import("rcc");
const system_timer = @import("system_timer");

const LED1_PIN = 2;
const LED1_PIN_MASK = 1 << LED1_PIN;
const LED1_PORT = gpio.gpioc;

const LED2_PIN = 3;
const LED2_PIN_MASK = 1 << LED2_PIN;
const LED2_PORT = gpio.gpioc;

pub fn init0() void {
    rcc.init();
    system_timer.delayInit();
    rcc.rcc.hb2pcenr = rcc.RccHb2pcenr{.iopcen = true};
    LED1_PORT.init(LED1_PIN_MASK, gpio.GpioModeOutputSlowSpeed | gpio.GpioCnfOutputPushPull);
    LED2_PORT.init(LED2_PIN_MASK, gpio.GpioModeOutputSlowSpeed | gpio.GpioCnfOutputPushPull);
}

pub fn init1() void {
    system_timer.delayInit();
}

pub fn led1On() void {
    LED1_PORT.bshr = LED1_PIN_MASK;
}

pub fn led1Off() void {
    LED1_PORT.bcr = LED1_PIN_MASK;
}

pub fn led2On() void {
    LED2_PORT.bshr = LED2_PIN_MASK;
}

pub fn led2Off() void {
    LED2_PORT.bcr = LED2_PIN_MASK;
}
