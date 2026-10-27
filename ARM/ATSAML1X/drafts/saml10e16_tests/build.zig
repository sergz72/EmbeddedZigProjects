const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .thumb,
        .os_tag = .freestanding,
        .abi = .eabi,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m23 }
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

    const pm = b.addModule("pm", .{
        .root_source_file = b.path("../lib/pm.zig"),
        .target = target,
        .optimize = optimize
    });

    const supc = b.addModule("supc", .{
        .root_source_file = b.path("../lib/supc.zig"),
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

    const trng = b.addModule("trng", .{
        .root_source_file = b.path("../lib/trng.zig"),
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

    const scb = b.addModule("scb", .{
        .root_source_file = b.path("../../lib/scb.zig"),
        .target = target,
        .optimize = optimize
    });

    const system_timer = b.addModule("system_timer", .{
        .root_source_file = b.path("../../lib/system_timer.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "cpu", .module = cpu },
            .{ .name = "nvic", .module = nvic }
        },
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

    const hal = b.addModule("hal", .{
        .root_source_file = b.path("src/hal.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "port", .module = port },
            .{ .name = "gclk", .module = gclk },
            .{ .name = "pm", .module = pm },
            .{ .name = "supc", .module = supc },
            .{ .name = "sercom", .module = sercom },
            .{ .name = "tc", .module = tc },
            .{ .name = "cpu", .module = cpu },
            .{ .name = "nvic", .module = nvic },
            .{ .name = "interrupts", .module = interrupts },
            .{ .name = "system_timer", .module = system_timer },
            .{ .name = "usart_writer", .module = usart_writer },
            .{ .name = "shell", .module = shell },
            .{ .name = "scb", .module = scb },
            .{ .name = "nvmctrl", .module = nvmctrl },
            .{ .name = "wdt", .module = wdt },
            .{ .name = "trng", .module = trng },
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

    const exe = b.addExecutable(.{
        .name = "atsaml10e16_tests.elf",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "hal", .module = hal },
                .{ .name = "usart_writer", .module = usart_writer },
                .{ .name = "shell", .module = shell },
                .{ .name = "trng_commands", .module = trng_commands },
                .{ .name = "system_commands", .module = system_commands },
                .{ .name = "flash_commands", .module = flash_commands },
                .{ .name = "crc_commands", .module = crc_commands },
                .{ .name = "allocator", .module = allocator }
            },
        }),
    });

    exe.entry = .{ .symbol_name = "Reset_Handler" };
    exe.link_gc_sections = true;
    exe.link_function_sections = true;
    exe.link_data_sections = true;
    exe.lto = .full;                     // Whole-program optimization & inlining

    exe.root_module.addCSourceFile(.{
        .file = b.path("../startup_saml10e16a.c"),
        .flags = &[_][]const u8{ "-I../include", "-std=c23", "-Wall" }
    });

    exe.setLinkerScript(b.path("../saml10e16a_flash.ld"));

    b.installArtifact(exe);

    const size_report = b.addSystemCommand(&.{ "llvm-size-22" });
    size_report.addArtifactArg(exe);

    b.getInstallStep().dependOn(&size_report.step);
}
