pub const Interrupt = enum(u8) {

    pub fn toU8(self: Interrupt) u8 {
        return @intFromEnum(self);
    }
};
