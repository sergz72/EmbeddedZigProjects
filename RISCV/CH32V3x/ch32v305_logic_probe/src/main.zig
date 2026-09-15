const std = @import("std");
const system_timer = @import("system_timer");
const usart_writer = @import("usart_writer");
const shell = @import("shell");
const allocator = @import("allocator");
const hal = @import("hal");
const usart = @import("usart");
const system_commands = @import("system_commands");
const lcd = @import("lcd");
const font5 = @import("font5");

const shell_init = shell.ShellInit{
    .max_commands = 50,
    .max_parameters = 10,
    .max_parameter_length = 50,
    .max_command_length = 100,
    .history_length = 20
};

const lcd_interface = lcd.LcdSSD1357Interface ;

var lcd_instance = lcd.LcdSSD1357 {
    .spi_lcd = .{
        .interface = .{
            .writer = hal.lcd_writer,
            .dc_set = hal.lcd_dc_set,
            .cs_set = hal.lcd_cs_set,
            .set_window = lcd.LcdSSD1357.set_window
        },
        .width = 64,
        .height = 64,
        .ctx = undefined
    },
    .reset_set = hal.lcd_reset_set
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

    lcd_instance.spi_lcd.ctx = &lcd_instance;
    lcd_instance.init(0);
    //lcd_instance.spi_lcd.rect_fill(0, 0, 10, 20, lcd.YELLOW_COLOR);
    lcd_instance.spi_lcd.draw_char(0, 0, 'A', &font5.fiveBySevenFontInfo, lcd.YELLOW_COLOR, lcd.BLACK_COLOR);

    var led_status = false;
    var led_counter: usize = 0;
    while (true) {
        system_timer.delayms(100);

        shell_handler(sh) catch { while (true){} };

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
