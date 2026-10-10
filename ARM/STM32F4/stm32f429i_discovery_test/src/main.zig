const std = @import("std");
const board = @import("board");
const shell = @import("shell");
const allocator = @import("allocator");
const hal = @import("hal");
const usart_writer = @import("usart_writer");
const memory_test_commands = @import("memory_test_commands");
const trng_commands = @import("trng_commands");
const system_commands = @import("system_commands");

var led_status: bool = undefined;
var led_counter: usize = undefined;

const shell_init = shell.ShellInit{
    .max_commands = 50,
    .max_parameters = 10,
    .max_parameter_length = 50,
    .max_command_length = 100,
    .history_length = 20
};

fn ledHandler() void {
    if (!hal.timer_interrupt)
        return;
    hal.timer_interrupt = false;
    if (led_counter == 9) {
        led_counter = 0;
        led_status = !led_status;
        if (led_status) {
            board.ledGreenOn();
        } else {
            board.ledGreenOff();
        }
    } else {
        led_counter += 1;
    }
}

fn usartCallback(data: u8) void {
    hal.sh.processChar(data);
}

const memory_test_regions = std.StaticStringMap(memory_test_commands.MemoryRegion).initComptime(.{
    .{ "ccmram", memory_test_commands.MemoryRegion{.base = 0x10000000, .size = 64 * 1024} },
    .{ "sdram", memory_test_commands.MemoryRegion{.base = 0xD0000000, .size = 8 * 1024 * 1024} },
});

export fn main() callconv(.c) noreturn {
    const a = allocator.buildAllocator();

    hal.sh = shell.Shell.init(&shell_init, a, &usart_writer.usart_writer.writer, board.usartWrite) catch { while (true){} };
    memory_test_commands.registerCommands(hal.sh, &memory_test_regions, hal.generate_random_numbers) catch { while (true){} };
    trng_commands.registerCommands(hal.sh, hal.generate_random_numbers) catch { while (true){} };
    system_commands.registerCommands(hal.sh) catch { while (true){} };

    board.initUsart(115200, usartCallback);

    led_counter = 0;

    hal.startTimer();

    while (true) {
        asm volatile("wfi");
        hal.sh.handler() catch { while (true){} };
        ledHandler();
    }
}
