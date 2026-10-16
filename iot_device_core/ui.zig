const hal_common = @import("hal_common");
const font8 = @import("font8");

pub const Ui = struct {
    hours: usize,
    minutes: usize,
    seconds: usize,

    pub fn init(self: *Ui) void {
        self.hours = 0;
        self.minutes = 0;
        self.seconds = 0;
        hal_common.lcd_device.canvas.drawChar(0, 0, 'A', &font8.courierNew8ptFontInfo, false);
        hal_common.lcd_device.update();
        hal_common.lcd_device.on();
    }

    pub fn updateLocalData(self: *Ui) void {
        _ = self;
    }

    pub fn updateRemoteData(self: *Ui, data: []u8) void {
        _ = self;
        _ = data;
    }

    pub fn timerEvent(self: *Ui) void {
        if (self.seconds < 59) {
            self.seconds += 1;
        } else {
            self.seconds = 0;
            if (self.minutes < 59) {
                self.minutes += 1;
            } else {
                self.minutes = 0;
                if (self.hours < 23) {
                    self.hours += 1;
                } else {
                    self.hours = 0;
                }
                self.updateHours();
            }
            self.updateMinutes();
        }
        self.updateSeconds();
    }

    fn updateSeconds(self: *Ui) void {
        _ = self;
        //todo
    }

    fn updateMinutes(self: *Ui) void {
        _ = self;
        //todo
    }

    fn updateHours(self: *Ui) void {
        _ = self;
        //todo
    }
};

pub var ui: Ui = undefined;
