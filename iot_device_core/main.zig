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

const shell_init = shell.ShellInit{
    .max_commands = 50,
    .max_parameters = 10,
    .max_parameter_length = 50,
    .max_command_length = 100,
    .history_length = 20
};

var led_counter: usize = undefined;

fn ledHandler() void {
    if (!hal.timer_interrupt)
        return;
    hal.timer_interrupt = false;
    if (led_counter == 9) {
        led_counter = 0;
        hal.ledToggle();
    } else {
        led_counter += 1;
    }
}

export fn main() callconv(.c) noreturn {
    const a = allocator.buildAllocator();

    hal.sh = shell.Shell.init(&shell_init, a, &usart_writer.usart_writer.writer, hal.usartWrite) catch { while (true){} };
    i2c_commands.registerCommands(hal.sh, hal_common.i2cScan) catch { while (true){} };
    spi_commands.registerCommands(hal.sh, hal.spiSendReceive) catch { while (true){} };
    scd4x_commands.registerCommands(hal.sh, &hal_common.scd_device) catch { while (true){} };
    veml7700_commands.registerCommands(hal.sh, &hal_common.veml_device) catch { while (true){} };
    cc1101_commands.registerCommands(hal.sh) catch { while (true){} };

    led_counter = 0;

    hal.startTimer();

    while (true) {
        asm volatile ("wfi");
        hal.sh.handler() catch { while (true){} };
        ledHandler();
    }
}
