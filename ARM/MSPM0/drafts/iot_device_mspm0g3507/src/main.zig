const hal = @import("hal");
const shell = @import("shell");
const usart_writer = @import("usart_writer");
const allocator = @import("allocator");

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

    led_counter = 0;

    hal.startTimer();

    while (true) {
        asm volatile ("wfi");
        hal.sh.handler() catch { while (true){} };
        ledHandler();
    }
}
