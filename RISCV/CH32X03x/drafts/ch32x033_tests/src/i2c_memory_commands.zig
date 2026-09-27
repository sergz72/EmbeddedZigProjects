const std = @import("std");
const shell = @import("shell");
const utils = @import("utils");

pub fn registerCommands(sh: *shell.Shell) isize {
    _ = sh;
    return 0; //sh.register_command(&spi_trfr_command);
}
