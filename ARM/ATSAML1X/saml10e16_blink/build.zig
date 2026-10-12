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
        .optimize = optimize
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

    const system_timer = b.addModule("system_timer", .{
        .root_source_file = b.path("../../lib/system_timer.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "cpu", .module = cpu },
            .{ .name = "nvic", .module = nvic }
        },
    });

    const exe = b.addExecutable(.{
        .name = "atsaml10e16_blink.elf",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
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
                .{ .name = "system_timer", .module = system_timer }
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
