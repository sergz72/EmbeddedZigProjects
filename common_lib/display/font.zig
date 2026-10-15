pub const FontInfo = struct {
    character_height: u8,
    start_character: u8,
    character_count: u8,
    character_width: u8,
    character_spacing: u8,
    character_bitmaps: []const u8,

    pub fn getCharWidthBytes(self: *const FontInfo) u8 {
        const value = self.character_height >> 3;
        if ((self.character_height & 7) == 0) {
            return value;
        }
        return value + 1;
    }

    pub fn getCharTotalBytes(self: *const FontInfo) u8 {
        return self.getCharWidthBytes() * self.character_height;
    }
};
