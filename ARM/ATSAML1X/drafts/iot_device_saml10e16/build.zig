const std = @import("std");
const common = @import("build_common.zig");

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

    const allocator = b.addModule("allocator", .{
        .root_source_file = b.path("../../lib/fb_allocator.zig"),
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

    var build_parameters = common.preCreateModules(b, .{
        .target = target,
        .optimize = optimize,
        .system_timer = system_timer,
        .name = "iot_device_saml10e16.elf",
        .lux_sensor_module = "../../../iot_device_core/lux_sensor_veml7700.zig",
        .co2_sensor_module = "../../../iot_device_core/co2_sensor_scd4x.zig",
        .rf_modem_module = "../../../iot_device_core/rf_modem_cc1101.zig"
    });
    build_parameters.allocator = allocator;

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
            .{ .name = "i2c", .module = i2c },
            .{ .name = "tc", .module = tc },
            .{ .name = "cpu", .module = cpu },
            .{ .name = "nvic", .module = nvic },
            .{ .name = "interrupts", .module = interrupts },
            .{ .name = "system_timer", .module = system_timer },
            .{ .name = "hal_constants", .module = build_parameters.hal_constants },
            .{ .name = "shell", .module = build_parameters.shell },
            .{ .name = "usart_writer", .module = build_parameters.usart_writer }
        },
    });
    build_parameters.hal = hal;

    const config = b.addModule("config", .{
        .root_source_file = b.path("../../../iot_device_core/hal_config_one_cc1101.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "cc1101", .module = build_parameters.cc1101 }
        }
    });
    build_parameters.config = config;

    var exe = common.buildExe(b, build_parameters);
    exe.entry = .{ .symbol_name = "Reset_Handler" };
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
