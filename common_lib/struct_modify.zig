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
            const val = if (F == bool) @as(Int, @intFromBool(@field(changes, f))) else @as(Int, @field(changes, f));

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
    field4: u7,
    field5: bool
};

test "modify works" {
    var source: std.Random.IoSource = .{ .io = std.testing.io };
    const rand = source.interface();
    var reg = TestStruct{
        .field1 = rand.int(u8), 
        .field2 = rand.int(u8),
        .field3 = rand.int(u8),
        .field4 = rand.int(u7),
        .field5 = rand.boolean()
    };
    const saved = reg;
    struct_modify(&reg, .{ .field1 = 3, .field2 = 2, .field5 = true });
    try std.testing.expect(reg.field1 == 3);
    try std.testing.expect(reg.field2 == 2);
    try std.testing.expect(reg.field3 == saved.field3);
    try std.testing.expect(reg.field4 == saved.field4);
    try std.testing.expect(reg.field5 == true); 
}