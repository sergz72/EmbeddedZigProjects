const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .thumb,
        .os_tag = .freestanding,
        .abi = .eabihf,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m4 }
    });

    const optimize = b.standardOptimizeOption(.{});

    const cpu = b.addModule("cpu", .{
        .root_source_file = b.path("../lib/cpu.zig"),
        .target = target,
        .optimize = optimize
    });

    const port = b.addModule("port", .{
        .root_source_file = b.path("../lib/port.zig"),
        .target = target,
        .optimize = optimize
    });

    const gclk = b.addModule("gclk", .{
        .root_source_file = b.path("../lib/gclk.zig"),
        .target = target,
        .optimize = optimize
    });

    const mclk = b.addModule("mclk", .{
        .root_source_file = b.path("../lib/mclk.zig"),
        .target = target,
        .optimize = optimize
    });

    const pm = b.addModule("pm", .{
        .root_source_file = b.path("../lib/pm.zig"),
        .target = target,
        .optimize = optimize
    });

    const sercom = b.addModule("sercom", .{
        .root_source_file = b.path("../lib/sercom.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "port", .module = port }
        },
    });

    const i2c = b.addModule("i2c", .{
        .root_source_file = b.path("../lib/i2c.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "sercom", .module = sercom }
        },
    });

    const tc = b.addModule("tc", .{
        .root_source_file = b.path("../lib/tc.zig"),
        .target = target,
        .optimize = optimize
    });

    const nvmctrl = b.addModule("nvmctrl", .{
        .root_source_file = b.path("../lib/nvmctrl.zig"),
        .target = target,
        .optimize = optimize
    });

    const wdt = b.addModule("wdt", .{
        .root_source_file = b.path("../lib/wdt.zig"),
        .target = target,
        .optimize = optimize
    });

    const rstc = b.addModule("rstc", .{
        .root_source_file = b.path("../lib/rstc.zig"),
        .target = target,
        .optimize = optimize
    });

    const trng = b.addModule("trng", .{
        .root_source_file = b.path("../lib/trng.zig"),
        .target = target,
        .optimize = optimize
    });

    const aes = b.addModule("aes", .{
        .root_source_file = b.path("../lib/aes.zig"),
        .target = target,
        .optimize = optimize
    });

    const generic_rtc = b.addModule("generic_rtc", .{
        .root_source_file = b.path("../../../common_lib/rtc/generic_rtc.zig"),
        .target = target,
        .optimize = optimize
    });

    const rtc = b.addModule("rtc", .{
        .root_source_file = b.path("../lib/rtc.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "generic_rtc", .module = generic_rtc }
        },
    });

    const dsu = b.addModule("dsu", .{
        .root_source_file = b.path("../lib/dsu.zig"),
        .target = target,
        .optimize = optimize
    });

    const pac = b.addModule("pac", .{
        .root_source_file = b.path("../lib/pac.zig"),
        .target = target,
        .optimize = optimize
    });

    const dmac = b.addModule("dmac", .{
        .root_source_file = b.path("../lib/dmac.zig"),
        .target = target,
        .optimize = optimize
    });

    const cmcc = b.addModule("cmcc", .{
        .root_source_file = b.path("../lib/cmcc.zig"),
        .target = target,
        .optimize = optimize
    });

    const nvic = b.addModule("nvic", .{
        .root_source_file = b.path("../../lib/nvic.zig"),
        .target = target,
        .optimize = optimize
    });

    const interrupts = b.addModule("interrupts", .{
        .root_source_file = b.path("../lib/interrupts.zig"),
        .target = target,
        .optimize = optimize
    });

    const system_timer = b.addModule("system_timer", .{
        .root_source_file = b.path("../../lib/system_timer.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "cpu", .module = cpu },
        },
    });

    const scb = b.addModule("scb", .{
        .root_source_file = b.path("../../lib/scb.zig"),
        .target = target,
        .optimize = optimize
    });

    const usart_writer = b.addModule("usart_writer", .{
        .root_source_file = b.path("../../../common_lib/usart_writer.zig"),
        .target = target,
        .optimize = optimize
    });

    const allocator = b.addModule("allocator", .{
        .root_source_file = b.path("../../lib/fb_allocator.zig"),
        .target = target,
        .optimize = optimize
    });

    const shell = b.addModule("shell", .{
        .root_source_file = b.path("../../../common_lib/shell.zig"),
        .target = target,
        .optimize = optimize
    });

    const utils = b.addModule("utils", .{
        .root_source_file = b.path("../../../common_lib/utils.zig"),
        .target = target,
        .optimize = optimize
    });

    const board = b.addModule("board", .{
        .root_source_file = b.path("../lib/curiosity_nano.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "cpu", .module = cpu },
            .{ .name = "nvic", .module = nvic },
            .{ .name = "gclk", .module = gclk },
            .{ .name = "pm", .module = pm },
            .{ .name = "sercom", .module = sercom },
            .{ .name = "port", .module = port },
            .{ .name = "system_timer", .module = system_timer },
            .{ .name = "interrupts", .module = interrupts },
            .{ .name = "mclk", .module = mclk },
            .{ .name = "usart_writer", .module = usart_writer },
        },
    });

    const scd4x = b.addModule("scd4x", .{
        .root_source_file = b.path("../../../common_lib/sensor/scd4x.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "system_timer", .module = system_timer }
        }
    });

    const veml7700 = b.addModule("veml7700", .{
        .root_source_file = b.path("../../../common_lib/sensor/veml7700.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "system_timer", .module = system_timer }
        }
    });

    const hal = b.addModule("hal", .{
        .root_source_file = b.path("src/hal.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "gclk", .module = gclk },
            .{ .name = "tc", .module = tc },
            .{ .name = "cpu", .module = cpu },
            .{ .name = "nvic", .module = nvic },
            .{ .name = "interrupts", .module = interrupts },
            .{ .name = "board", .module = board },
            .{ .name = "mclk", .module = mclk },
            .{ .name = "scd4x", .module = scd4x },
            .{ .name = "veml7700", .module = veml7700 },
            .{ .name = "shell", .module = shell },
            .{ .name = "scb", .module = scb },
            .{ .name = "nvmctrl", .module = nvmctrl },
            .{ .name = "wdt", .module = wdt },
            .{ .name = "rstc", .module = rstc },
            .{ .name = "trng", .module = trng },
            .{ .name = "rtc", .module = rtc },
            .{ .name = "aes", .module = aes },
            .{ .name = "sercom", .module = sercom },
            .{ .name = "i2c", .module = i2c },
            .{ .name = "port", .module = port },
            .{ .name = "pac", .module = pac },
            .{ .name = "dmac", .module = dmac },
            .{ .name = "cmcc", .module = cmcc },
        },
    });

    const system_commands = b.addModule("system_commands", .{
        .root_source_file = b.path("../../../common_lib/shell_commands/system_commands.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "shell", .module = shell },
            .{ .name = "allocator", .module = allocator },
            .{ .name = "hal", .module = hal },
            .{ .name = "system_timer", .module = system_timer },
        }
    });

    const flash_commands = b.addModule("flash_commands", .{
        .root_source_file = b.path("../../../common_lib/shell_commands/flash_commands.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "shell", .module = shell },
            .{ .name = "hal", .module = hal },
            .{ .name = "utils", .module = utils },
        }
    });

    const i2c_commands = b.addModule("i2c_commands", .{
        .root_source_file = b.path("../../../common_lib/shell_commands/i2c_commands.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "shell", .module = shell }
        }
    });

    const spi_commands = b.addModule("spi_commands", .{
        .root_source_file = b.path("../../../common_lib/shell_commands/spi_commands.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "shell", .module = shell },
            .{ .name = "utils", .module = utils }
        }
    });

    const trng_commands = b.addModule("trng_commands", .{
        .root_source_file = b.path("../../../common_lib/shell_commands/trng_commands.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "shell", .module = shell }
        }
    });

    const crc_commands = b.addModule("crc_commands", .{
        .root_source_file = b.path("../../../common_lib/shell_commands/crc_commands.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "shell", .module = shell },
            .{ .name = "utils", .module = utils }
        }
    });

    const veml7700_commands = b.addModule("veml7700_commands", .{
        .root_source_file = b.path("../../../common_lib/shell_commands/veml7700_commands.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "shell", .module = shell },
            .{ .name = "veml7700", .module = veml7700 }
        }
    });

    const scd4x_commands = b.addModule("scd4x_commands", .{
        .root_source_file = b.path("../../../common_lib/shell_commands/scd4x_commands.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "shell", .module = shell },
            .{ .name = "scd4x", .module = scd4x }
        }
    });

    const rtc_commands = b.addModule("rtc_commands", .{
        .root_source_file = b.path("../lib/shell_commands/rtc_commands.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "shell", .module = shell },
            .{ .name = "rtc", .module = rtc },
            .{ .name = "generic_rtc", .module = generic_rtc }
        }
    });

    const aes_commands = b.addModule("aes_commands", .{
        .root_source_file = b.path("../../../common_lib/shell_commands/aes_commands.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "shell", .module = shell },
            .{ .name = "utils", .module = utils }
        }
    });

    const exe = b.addExecutable(.{
        .name = "atsame51j20_tests.elf",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "hal", .module = hal },
                .{ .name = "board", .module = board },
                .{ .name = "shell", .module = shell },
                .{ .name = "allocator", .module = allocator },
                .{ .name = "usart_writer", .module = usart_writer },
                .{ .name = "system_commands", .module = system_commands },
                .{ .name = "flash_commands", .module = flash_commands },
                .{ .name = "i2c_commands", .module = i2c_commands },
                .{ .name = "spi_commands", .module = spi_commands },
                .{ .name = "trng_commands", .module = trng_commands },
                .{ .name = "crc_commands", .module = crc_commands },
                .{ .name = "trng", .module = trng },
                .{ .name = "scd4x_commands", .module = scd4x_commands },
                .{ .name = "veml7700_commands", .module = veml7700_commands },
                .{ .name = "rtc_commands", .module = rtc_commands },
                .{ .name = "aes_commands", .module = aes_commands },
                .{ .name = "dsu", .module = dsu },
                .{ .name = "dmac", .module = dmac },
                .{ .name = "aes", .module = aes },
            },
        }),
    });

    exe.entry = .{ .symbol_name = "Reset_Handler" };
    exe.link_gc_sections = true;
    exe.function_sections = true;
    exe.data_sections = true;
    //exe.lto = .full;                     // Whole-program optimization & inlining

    exe.root_module.addAssemblyFile(b.path("../startup_same51j20a.s"));

    exe.setLinkerScript(b.path("../same51j20a_flash.ld"));

    b.installArtifact(exe);

    const size_report = b.addSystemCommand(&.{ "llvm-size-22" });
    size_report.addArtifactArg(exe);

    b.getInstallStep().dependOn(&size_report.step);
}
