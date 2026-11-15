const board = @import("board");
const hal = @import("hal");
const shell = @import("shell");
const allocator = @import("allocator");
const usart_writer = @import("usart_writer");
const system_commands = @import("system_commands");
const flash_commands = @import("flash_commands");
const i2c_commands = @import("i2c_commands");
const spi_commands = @import("spi_commands");

const shell_init = shell.ShellInit{
    .max_commands = 50,
    .max_parameters = 10,
    .max_parameter_length = 50,
    .max_command_length = 100,
    .history_length = 20,
    .source_init = &.{
        shell.ShellSourceInit{
            .writer = &usart_writer.usart_writer.writer,
            .echo_func = board.uartWrite
        }
    }
};

export fn main() callconv(.c) noreturn {
    const a = allocator.buildAllocator();

    hal.sh = shell.Shell.init(&shell_init, a) catch { while (true){} };
    system_commands.registerCommands(hal.sh) catch { while (true){} };
    flash_commands.registerCommands(hal.sh) catch { while (true){} };
    i2c_commands.registerCommands(hal.sh, hal.i2cScan) catch { while (true){} };
    spi_commands.registerCommands(hal.sh, hal.spiSendReceive) catch { while (true){} };

    _ = usart_writer.usart_writer.writer.write(hal.getResetCause()) catch { while (true){} };

    hal.startTimer();

    while (true) {
        asm volatile ("wfi");
        hal.wdtReset();
        hal.sh.handler() catch { while (true){} };
        if (hal.timer_interrupt) {
            hal.timer_interrupt = false;
            board.ledGreenToggle();
        }
    }
}
