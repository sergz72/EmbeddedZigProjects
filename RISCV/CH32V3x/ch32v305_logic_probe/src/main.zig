const std = @import("std");
const system_timer = @import("system_timer");
const usart_writer = @import("usart_writer");
const shell = @import("shell");
const allocator = @import("allocator");
const hal = @import("hal");
const usart = @import("usart");
const system_commands = @import("system_commands");
const ui = @import("ui");

const shell_init = shell.ShellInit{
    .max_commands = 50,
    .max_parameters = 10,
    .max_parameter_length = 50,
    .max_command_length = 100,
    .history_length = 20
};

fn shell_handler(sh: *shell.Shell) !void {
    if (hal.command_ready) {
        usart.usart1.write('\n');
        const rc = try sh.execute(hal.command[0..hal.command_idx]);
        hal.command_idx = 0;
        hal.command_ready = false;
        try usart_writer.usart_writer.writer.print("shell returned {}\n", .{rc});
    }
}

export fn main() callconv(.c) noreturn {
    const a = allocator.build_allocator();

    const sh = shell.Shell.init(&shell_init, a, &usart_writer.usart_writer.writer) catch { while (true){} };

    _ = system_commands.register_system_commands(sh);

    ui.UI.init(a) catch { while (true){} };

    hal.start_timer();

    var led_status = false;
    var led_counter: usize = 0;
    while (true) {
        asm volatile ("wfi");

        shell_handler(sh) catch { while (true){} };

        if (!hal.timer_interrupt)
            continue;
        hal.timer_interrupt = false;
        if (led_counter == 9) {
            led_counter = 0;
            led_status = !led_status;
            if (led_status) {
                hal.led_on();
            } else {
                hal.led_off();
            }
        } else {
            led_counter += 1;
        }
    }
}
