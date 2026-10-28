const hal_common = @import("hal_common");
const hal = @import("hal");
const font8 = @import("font8");

pub const Ui = struct {
    prev_time: usize,

    pub fn init(self: *Ui) void {
        hal_common.lcd_device.canvas.drawChar(0, 0, 'A', &font8.courierNew8ptFontInfo, false);
        hal_common.lcd_device.update();
        hal_common.lcd_device.on();
        self.prev_time = hal.time;
    }

    pub fn updateLocalData(self: *Ui) void {
        _ = self;
    }

    pub fn updateRemoteData(self: *Ui, data: []u8) void {
        _ = self;
        _ = data;
    }

    pub fn timerEvent(self: *Ui) void {
        const diff: u8 = @truncate(hal.time -% self.prev_time);
        self.prev_time = hal.time;
        hal_common.rtc_data.seconds += diff;
        if (hal_common.rtc_data.seconds > 59) {
            hal_common.rtc_data.seconds -= 60;
            if (hal_common.rtc_data.minutes < 59) {
                hal_common.rtc_data.minutes += 1;
            } else {
                hal_common.rtc_data.minutes = 0;
                if (hal_common.rtc_data.hours < 23) {
                    hal_common.rtc_data.hours += 1;
                } else {
                    hal_common.rtc_data.hours = 0;
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
