const hal = @import("hal");
const shell = @import("shell");
const allocator = @import("allocator");
const usart_writer = @import("usart_writer");
const system_commands = @import("system_commands");
const flash_commands = @import("flash_commands");
const trng_commands = @import("trng_commands");
const crc_commands = @import("crc_commands");
const i2c_commands = @import("i2c_commands");
const ds3231_commands = @import("ds3231_commands");
const prng = @import("prng");
const crc = @import("crc");

const shell_init = shell.ShellInit{
    .max_commands = 50,
    .max_parameters = 10,
    .max_parameter_length = 50,
    .max_command_length = 100,
    .history_length = 20
};

const rng: trng_commands.Rng = .{
    .gen = &prng.prngGen,
    .init = &prng.prngInit
};

const crc_generators: crc_commands.Generators = .{
    .crc8 = null,
    .crc16 = null,
    .crc32 = &crc32
};

fn crc32(data:[]const u8) u32 {
    return crc.crc.crc32(data);
}

export fn main() callconv(.c) noreturn {
    const a = allocator.buildAllocator();

    hal.sh = shell.Shell.init(&shell_init, a, &usart_writer.usart_writer.writer, hal.usartWrite) catch { while (true){} };
    system_commands.registerCommands(hal.sh) catch { while (true){} };
    flash_commands.registerCommands(hal.sh) catch { while (true){} };
    trng_commands.registerCommands(hal.sh, &rng) catch { while (true){} };
    crc_commands.registerCommands(hal.sh, &crc_generators) catch { while (true){} };
    i2c_commands.registerCommands(hal.sh, hal.i2cScan) catch { while (true){} };
    ds3231_commands.registerCommands(hal.sh, &hal.ds3231_device) catch { while (true){} };

    _ = usart_writer.usart_writer.writer.write(hal.getResetCause()) catch { while (true){} };

    hal.startTimer();

    while (true) {
        asm volatile("wfi");
        hal.wdtReset();
        hal.sh.handler() catch { while (true){} };
        if (hal.timer_interrupt) {
            hal.timer_interrupt = false;
            hal.ledToggle();
        }
    }
}
