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

var led_status: bool = undefined;
var led_counter: usize = undefined;

fn led_handler() void {
    if (!hal.timer_interrupt)
        return;
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

fn exti_handler() void {
    if (!hal.fpga_interrupt)
        return;
    hal.fpga_interrupt = false;
    //todo
}

export fn main() callconv(.c) noreturn {
    const a = allocator.build_allocator();

    hal.sh = shell.Shell.init(&shell_init, a, &usart_writer.usart_writer.writer, hal.usart_write) catch { while (true){} };

    _ = system_commands.register_system_commands(hal.sh);

    ui.UI.init(a) catch { while (true){} };

    hal.start_timer();
    hal.fpga_set_cs();

    led_status = false;
    led_counter = 0;

    while (true) {
        asm volatile ("wfi");
        hal.sh.handler() catch { while (true){} };
        led_handler();
        exti_handler();
    }
}
