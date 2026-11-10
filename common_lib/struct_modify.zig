const std = @import("std");

pub fn struct_modify(reg: anytype, comptime changes: anytype) void {
    const T = @typeInfo(@TypeOf(reg)).pointer.child;
    const Int = @typeInfo(T).@"struct".backing_integer.?;

    const m = comptime blk: {
        var clear: Int = 0;
        var set: Int = 0;
        for (@typeInfo(@TypeOf(changes)).@"struct".field_names) |f| {
            const F = @FieldType(T, f);
            const bits = @bitSizeOf(F);
            const off = @bitOffsetOf(T, f);

            const fmask: Int = @intCast(((1 << bits) - 1) << off);
            const val = @as(Int, @field(changes, f));

            clear |= fmask;
            set |= val << off;
        }
        break :blk .{ .clear = clear, .set = set };
    };

    const raw: Int = @bitCast(reg.*);                    // one volatile load
    reg.* = @bitCast((raw & ~m.clear) | m.set);          // and-not mask, or value, one volatile store
}

const TestStruct  = packed struct(u32) {
    field1: u8,
    field2: u8,
    field3: u8,
    field4: u8
};

test "modify works" {
    var reg: TestStruct = .{ .field1 = 10, .field2 = 20, .field3 = 30, .field4 = 40 };
    struct_modify(&reg, .{ .field1 = 3, .field2 = 2 });
    try std.testing.expect(reg.field1 == 3);
    try std.testing.expect(reg.field2 == 2);
    try std.testing.expect(reg.field3 == 30);
    try std.testing.expect(reg.field4 == 40);
}