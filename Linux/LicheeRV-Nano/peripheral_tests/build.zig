const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});

    const target = b.resolveTargetQuery(.{
        .cpu_arch = .riscv64,
        .os_tag = .linux,
        .abi = .musl,
        .cpu_features_add = std.Target.riscv.featureSet(&.{
            .m,
            .a,
            .f,
            .d,
            .c,
        }),
    });

    const gpio = b.addModule("gpio", .{
        .root_source_file = b.path("../../peripheral_library/gpio.zig"),
        .target = target,
        .optimize = optimize
    });

    const spi = b.addModule("spi", .{
        .root_source_file = b.path("../../peripheral_library/spi.zig"),
        .target = target,
        .optimize = optimize
    });

    const i2c = b.addModule("i2c", .{
        .root_source_file = b.path("../../peripheral_library/i2c.zig"),
        .target = target,
        .optimize = optimize
    });

    const exe = b.addExecutable(.{
        .name = "peripheral_tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("../../peripheral_library/peripheral_tests.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "gpio", .module = gpio },
                .{ .name = "spi", .module = spi },
                .{ .name = "i2c", .module = i2c }
            },
        }),
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_cmd.step);
}
