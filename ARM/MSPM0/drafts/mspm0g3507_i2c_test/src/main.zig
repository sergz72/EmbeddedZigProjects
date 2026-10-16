const std = @import("std");
const hal = @import("hal");
const shell = @import("shell");
const allocator = @import("allocator");
const i2c_commands = @import("i2c_commands");
const usart_writer = @import("usart_writer");
const veml7700_commands = @import("veml7700_commands");
const scd4x_commands = @import("scd4x_commands");

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
}

export fn main() callconv(.c) noreturn {
    const a = allocator.buildAllocator();

    hal.sh = shell.Shell.init(&shell_init, a, &usart_writer.usart_writer.writer, hal.usartWrite) catch { while (true){} };
    i2c_commands.registerCommands(hal.sh, hal.i2cScan) catch { while (true){} };
    veml7700_commands.registerCommands(hal.sh, &hal.veml_device) catch { while (true){} };
    scd4x_commands.registerCommands(hal.sh, &hal.scd_device) catch { while (true){} };

    hal.startTimer();

    while (true) {
        hal.enterSleep();
        hal.sh.handler() catch { while (true){} };
        timerHandler();
    }
}
