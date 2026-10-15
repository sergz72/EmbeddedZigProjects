const hal = @import("hal");
const hal_common = @import("hal_common");
const usart_writer = @import("usart_writer");
const shell = @import("shell");
const allocator = @import("allocator");
const i2c_commands = @import("i2c_commands");
const spi_commands = @import("spi_commands");
const scd4x_commands = @import("scd4x_commands");
const veml7700_commands = @import("veml7700_commands");
const cc1101_commands = @import("cc1101_commands");
const lcd = @import("lcd");
const ui = @import("ui");

const shell_init = shell.ShellInit{
    .max_commands = 50,
    .max_parameters = 10,
    .max_parameter_length = 50,
    .max_command_length = 100,
    .history_length = 20
};

inline fn timerHandler() void {
    if (!hal.timer_interrupt)
        return;
    hal.timer_interrupt = false;
    hal.ledToggle();
    ui.ui.timerEvent();
}

export fn main() callconv(.c) noreturn {
    const a = allocator.buildAllocator();

    hal.sh = shell.Shell.init(&shell_init, a, &usart_writer.usart_writer.writer, hal.usartWrite) catch { while (true){} };
    i2c_commands.registerCommands(hal.sh, hal_common.i2cScan) catch { while (true){} };
    spi_commands.registerCommands(hal.sh, hal.spiSendReceive) catch { while (true){} };
    scd4x_commands.registerCommands(hal.sh, &hal_common.scd_device) catch { while (true){} };
    veml7700_commands.registerCommands(hal.sh, &hal_common.veml_device) catch { while (true){} };
    cc1101_commands.registerCommands(hal.sh, &hal_common.cc1101_cfg, &hal_common.cc1101_devices) catch { while (true){} };

    hal_common.lcd_device.init(.reverse_landscape, a) catch { while (true){} };
    ui.ui.init();

    hal.startTimer();

    while (true) {
        hal.enterSleep();
        hal.sh.handler() catch { while (true){} };
        timerHandler();
    }
}
