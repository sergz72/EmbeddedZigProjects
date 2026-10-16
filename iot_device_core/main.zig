const hal = @import("hal");
const hal_common = @import("hal_common");
const usart_writer = @import("usart_writer");
const shell = @import("shell");
const allocator = @import("allocator");
const i2c_commands = @import("i2c_commands");
const spi_commands = @import("spi_commands");
const lcd = @import("lcd");
const ui = @import("ui");
const lux_sensor = @import("lux_sensor");
const co2_sensor = @import("co2_sensor");
const pressure_sensor = @import("pressure_sensor");
const external_temperature_sensor = @import("external_temperature_sensor");
const rf_modem = @import("rf_modem");

const MEASUREMENT_INTERVAL = 300;

const shell_init = shell.ShellInit{
    .max_commands = 50,
    .max_parameters = 10,
    .max_parameter_length = 50,
    .max_command_length = 100,
    .history_length = 20
};

var prev_measurement_time: usize = undefined;
var measurement_started: bool = undefined;

inline fn timerHandler() void {
    if (!hal.timer_interrupt)
        return;
    hal.timer_interrupt = false;
    hal.ledToggle();
    if (hal.INIT_DEVICES) {
        const remote_data = rf_modem.timerEvent();
        if (remote_data) |rd| {
            ui.ui.updateRemoteData(rd);
        }
        if (measurement_started) {
            const lux_sensor_data_ready = lux_sensor.isMeasurementFinished(&usart_writer.usart_writer.writer);
            const co2_sensor_data_ready = co2_sensor.isMeasurementFinished(&usart_writer.usart_writer.writer);
            const pressure_sensor_data_ready = pressure_sensor.isMeasurementFinished(&usart_writer.usart_writer.writer);
            const external_temperature_sensor_data_ready = external_temperature_sensor.isMeasurementFinished(&usart_writer.usart_writer.writer);
            if (lux_sensor_data_ready and co2_sensor_data_ready and pressure_sensor_data_ready and external_temperature_sensor_data_ready) {
                measurement_started = false;
                ui.ui.updateLocalData();
            }
        } else {
            if (hal.time -% prev_measurement_time >= MEASUREMENT_INTERVAL) {
                prev_measurement_time = hal.time;
                lux_sensor.measurementStart(&usart_writer.usart_writer.writer);
                co2_sensor.measurementStart(&usart_writer.usart_writer.writer);
                pressure_sensor.measurementStart(&usart_writer.usart_writer.writer);
                external_temperature_sensor.measurementStart(&usart_writer.usart_writer.writer);
                measurement_started = true;
            }
        }
    }
    ui.ui.timerEvent();
}

export fn main() callconv(.c) noreturn {
    prev_measurement_time = 0xFFFFFFFF;
    measurement_started = false;

    const a = allocator.buildAllocator();

    hal.sh = shell.Shell.init(&shell_init, a, &usart_writer.usart_writer.writer, hal.usartWrite) catch { while (true){} };
    i2c_commands.registerCommands(hal.sh, hal_common.i2cScan) catch { while (true){} };
    spi_commands.registerCommands(hal.sh, hal.spiSendReceive) catch { while (true){} };
    lux_sensor.init();
    co2_sensor.init();
    pressure_sensor.init();
    external_temperature_sensor.init();
    rf_modem.init();

    hal_common.lcd_device.init(.reverse_landscape, a) catch { while (true){} };
    ui.ui.init();

    hal.startTimer();

    while (true) {
        hal.enterSleep();
        hal.sh.handler() catch { while (true){} };
        timerHandler();
    }
}
