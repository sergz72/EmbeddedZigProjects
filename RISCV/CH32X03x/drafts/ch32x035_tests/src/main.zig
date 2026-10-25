const hal = @import("hal");
const i2c_memory_commands = @import("i2c_memory_commands");
const spi_memory_commands = @import("spi_memory_commands");
const system_commands = @import("system_commands");
const allocator = @import("allocator");
const shell = @import("shell");
const usart_writer = @import("usart_writer");
const spi_memory = @import("spi_memory");

const shell_init = shell.ShellInit{
    .max_commands = 50,
    .max_parameters = 10,
    .max_parameter_length = 50,
    .max_command_length = 100,
    .history_length = 20
};

const spi_chip_init: spi_memory.SpiMemoryInit = .{.memory_type = .flash, .address_size = ._3bytes, .spi_transfer = hal.spiFlashTransfer};

fn timerHandler() void {
    if (!hal.timer_interrupt)
        return;
    hal.timer_interrupt = false;
    hal.ledToggle();
}

export fn main() callconv(.c) noreturn {
    const a = allocator.buildAllocator();

    hal.sh = shell.Shell.init(&shell_init, a, &usart_writer.usart_writer.writer, hal.usartWrite) catch { while (true){} };

    i2c_memory_commands.registerCommands(hal.sh) catch { while (true){} };
    spi_memory_commands.registerCommands(hal.sh, &spi_chip_init) catch { while (true){} };
    system_commands.registerCommands(hal.sh) catch { while (true){} };

    hal.startTimer();

    while (true) {
        asm volatile ("wfi");
        hal.sh.handler() catch { while (true){} };
        timerHandler();
    }
}
