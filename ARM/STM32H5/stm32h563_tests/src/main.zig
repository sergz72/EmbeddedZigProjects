const std = @import("std");
const hal = @import("hal");
const shell = @import("shell");
const allocator = @import("allocator");
const usart_writer = @import("usart_writer");
const system_commands = @import("system_commands");
const flash_commands = @import("flash_commands");
const board = @import("board");
const usb_cdc_impl = @import("usb_cdc_impl");
const rcc = @import("rcc");

const shell_init = shell.ShellInit{
    .max_commands = 50,
    .max_parameters = 10,
    .max_parameter_length = 50,
    .max_command_length = 100,
    .history_length = 20
};

fn cdc_rx_callback(data: []const u8) void {
    usb_cdc_impl.tx(data);
}

export fn main() callconv(.c) noreturn {
    const a = allocator.buildAllocator();

    usb_cdc_impl.init(.pll1q, &cdc_rx_callback, 10240, a) catch { while (true){} };

    board.usartDmaInit(10*1024, a) catch { while (true){} };

    hal.sh = shell.Shell.init(&shell_init, a, &usart_writer.usart_writer.writer, board.shellWriteCharDma) catch { while (true){} };
    system_commands.registerCommands(hal.sh) catch { while (true){} };
    flash_commands.registerCommands(hal.sh) catch { while (true){} };

    _ = usart_writer.usart_writer.writer.write(hal.getResetCause()) catch { while (true){} };

    hal.startTimer();

    while (true) {
        asm volatile ("wfi");
        hal.wdtReset();
        hal.sh.handler() catch { while (true){} };
        if (hal.timer_interrupt) {
            hal.timer_interrupt = false;
            hal.ledToggle();
        }
    }
}
