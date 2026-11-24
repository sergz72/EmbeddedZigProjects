const std = @import("std");
const rv = std.Target.riscv;

pub fn build(b: *std.Build) !void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .riscv32,
        .os_tag = .freestanding,
        .abi = .eabi,
        .cpu_model = .{ .explicit = &rv.cpu.rv32imafc },
        .cpu_features_add = rv.featureSet(&.{ .i, .m, .a, .c, .f, .b, .xwchc, .zicsr, .zifencei }),
    });

    const optimize = b.standardOptimizeOption(.{});

    const rcc = b.addModule("rcc", .{
        .root_source_file = b.path("../lib/rcc.zig"),
        .target = target,
        .optimize = optimize
    });

    const cpu = b.addModule("cpu", .{
        .root_source_file = b.path("../lib/cpu_3f.zig"),
        .target = target,
        .optimize = optimize
    });

    const gpio_common = b.addModule("gpio_common", .{
        .root_source_file = b.path("../../ch32lib/gpio_common.zig"),
        .target = target,
        .optimize = optimize
    });

    const gpio = b.addModule("gpio", .{
        .root_source_file = b.path("../lib/gpio.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "gpio_common", .module = gpio_common }
        },
    });

    const afio = b.addModule("afio", .{
        .root_source_file = b.path("../lib/afio.zig"),
        .target = target,
        .optimize = optimize
    });

    const pfic = b.addModule("pfic", .{
        .root_source_file = b.path("../../ch32lib/pfic.zig"),
        .target = target,
        .optimize = optimize
    });

    const interrupts = b.addModule("interrupts", .{
        .root_source_file = b.path("../lib/interrupts.zig"),
        .target = target,
        .optimize = optimize
    });

    const system_timer = b.addModule("system_timer", .{
        .root_source_file = b.path("../lib/system_timer.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "cpu", .module = cpu },
            .{ .name = "pfic", .module = pfic }
        },
    });

    const usart = b.addModule("usart", .{
        .root_source_file = b.path("../lib/usart.zig"),
        .target = target,
        .optimize = optimize
    });

    const timer = b.addModule("timer", .{
        .root_source_file = b.path("../lib/timer.zig"),
        .target = target,
        .optimize = optimize
    });

    const usart_writer = b.addModule("usart_writer", .{
        .root_source_file = b.path("../../../common_lib/usart_writer.zig"),
        .target = target,
        .optimize = optimize
    });

    const exe_3f = b.addExecutable(.{
        .name = "ch32h417_3f_blink.elf",
        .root_module = b.createModule(.{
            .root_source_file = b.path("3f/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "rcc", .module = rcc },
                .{ .name = "gpio", .module = gpio },
                .{ .name = "afio", .module = afio },
                .{ .name = "system_timer", .module = system_timer },
                .{ .name = "timer", .module = timer },
                .{ .name = "usart", .module = usart },
                .{ .name = "cpu", .module = cpu },
                .{ .name = "pfic", .module = pfic },
                .{ .name = "interrupts", .module = interrupts },
                .{ .name = "usart_writer", .module = usart_writer }
            },
        }),
    });

    exe_3f.link_gc_sections = true;
    exe_3f.function_sections = true;
    exe_3f.data_sections = true;
    //riscv_exe.lto = .full;                     // Whole-program optimization & inlining

    exe_3f.root_module.addAssemblyFile(b.path("../startup_ch32h417_v3f.S"));

    exe_3f.setLinkerScript(b.path("../Link_v3f.ld"));

    b.installArtifact(exe_3f);

    const riscv_size_report = b.addSystemCommand(&.{ "llvm-size-22" });
    riscv_size_report.addArtifactArg(exe_3f);

    const riscv_bin_create = b.addSystemCommand(&.{ "llvm-objcopy-22" });
    riscv_bin_create.addArg("-Obinary");
    riscv_bin_create.addArtifactArg(exe_3f);
    riscv_bin_create.addFileArg(b.path("zig-out/bin/ch32h417_3f_blink.bin"));

    b.getInstallStep().dependOn(&riscv_size_report.step);
    b.getInstallStep().dependOn(&riscv_bin_create.step);
}
