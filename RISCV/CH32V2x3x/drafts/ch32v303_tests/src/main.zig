const hal = @import("hal");
const shell = @import("shell");
const allocator = @import("allocator");
const usart_writer = @import("usart_writer");
const usb_cdc_impl = @import("usb_cdc_impl");

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

    if (!usb_cdc_impl.init()) {
        while (true){}
    }

    hal.sh = shell.Shell.init(&shell_init, a, &usart_writer.usart_writer.writer, hal.usartWrite) catch { while (true){} };

    hal.startTimer();

    while (true) {
        asm volatile ("wfi");
        hal.sh.handler() catch { while (true){} };
        timerHandler();
    }
}
