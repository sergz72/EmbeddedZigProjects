const hal_common = @import("hal_common");
const font8 = @import("font8");

pub const Ui = struct {
    pub fn init(self: *Ui) void {
        _ = self;
        hal_common.lcd_device.canvas.drawChar(0, 0, 'A', &font8.courierNew8ptFontInfo, false);
        hal_common.lcd_device.update();
    }
};

pub var ui: Ui = undefined;
