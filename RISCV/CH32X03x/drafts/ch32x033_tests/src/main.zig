const hal = @import("hal");
const i2c_memory_commands = @import("i2c_memory_commands");
const spi_flash_commands = @import("spi_flash_commands");
const allocator = @import("allocator");
const shell = @import("shell");
const usart_writer = @import("usart_writer");

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


export fn main() callconv(.c) noreturn {
    const a = allocator.build_allocator();

    hal.sh = shell.Shell.init(&shell_init, a, &usart_writer.usart_writer.writer, hal.usart_write) catch { while (true){} };

    _ = i2c_memory_commands.register_commands(hal.sh);
    _ = spi_flash_commands.register_commands(hal.sh);

    hal.start_timer();

    led_status = false;
    led_counter = 0;

    while (true) {
        asm volatile ("wfi");
        hal.sh.handler() catch { while (true){} };
        led_handler();
    }
}
