// this array represents the number of days in one non-leap year at
// the beginning of each month
const days_to_month_table: [13]usize = .{
  0,31,59,90,120,151,181,212,243,273,304,334,365
};

pub const Month = enum(u8) {
    January = 1,
    February,
    March,
    April,
    May,
    June,
    July,
    August,
    September,
    October,
    November,
    December
};

const WeekDay = enum(u8) {
    Sunday = 0,
    Monday,
    Tuesday,
    Wednesday,
    Thursday,
    Friday,
    Saturday
};

pub const RtcDataError = error {
    InvalidMonth,
    InvalidWeekDay,
    InvalidYear,
    InvalidDay,
    InvalidHour,
    InvalidMinute,
    InvalidSecond
};

pub const RtcData = struct {
    month: Month,
    day: u8,
    hours: u8,
    minutes: u8,
    seconds: u8,
    wday: WeekDay,
    year: usize,
    yday: usize,

    pub fn toBinary(self: *const RtcData) usize {
        const iday = 365 * (self.year - 1970) + (self.yday - 1) + (self.year - 1969) / 4;
        return @as(usize, self.seconds) + 60 * @as(usize, self.minutes) + 3600 * (@as(usize, self.hours) + 24 * iday);
    }

    fn fromBinary(self: *RtcData, binary: usize) void {
        const whole_minutes = binary / 60;
        self.seconds = @truncate(binary - (60 * whole_minutes)); // leftover seconds
        const whole_hours = whole_minutes / 60;
        self.minutes = @truncate(whole_minutes - (60 * whole_hours)); // leftover minutes
        const whole_days = whole_hours / 24;
        self.hours = @truncate(whole_hours - (24 * whole_days)); // leftover hours
        const whole_days_since_1968 = whole_days + 365 + 366;
        var leap_year_periods = whole_days_since_1968 / (4 * 365 + 1);
        const days_since_current_lyear = whole_days_since_1968 % ((4 * 365) + 1);
        // if days are after a current leap year then add a leap year period
        if (days_since_current_lyear >= 31 + 29)
            leap_year_periods += 1;
        const whole_years = (whole_days_since_1968 - leap_year_periods) / 365;
        var days_since_first_of_year = whole_days_since_1968 - whole_years * 365 - leap_year_periods;
        if (days_since_current_lyear <= 365 and days_since_current_lyear >= 60)
            days_since_first_of_year += 1;
        const year = whole_years + 68;
        // setup for a search for what month it is based on how many days have past
        // within the current year
        var month: u8 = 13;
        var days_to_month: usize = 366;
        while (days_since_first_of_year < days_to_month)
        {
            month -= 1;
            days_to_month = days_to_month_table[month-1];
            if ((month > 2) and ((year % 4) == 0))
            days_to_month += 1;
        }
        self.day = @truncate(days_since_first_of_year - days_to_month + 1);
        const wd: u8 = @truncate((whole_days + 4) % 7);
        self.wday = @bitCast(wd);

        self.yday    = days_since_first_of_year + 1; // days since January 1 - [0,365]
        self.month   = @bitCast(month); // month - [1,12]
        self.year    = year + 1900; // years
    }

    pub fn buildYDay(self: *RtcData) void {
        const m = @backingInt(self.month);
        self.yday = days_to_month_table[m - 1] + self.day;
        if (m > 2 and (self.year & 3) == 0)
            self.yday += 1;
    }

    pub fn buildWDayAndYDay(self: *RtcData) void {
        const b = self.toBinary();
        var data: RtcData = undefined;
        data.fromBinary(b);
        self.wday = data.wday;
        self.yday = data.yday;
    }

    pub fn setMonth(self: *RtcData, month: u8) RtcDataError!void {
        if (month < 1 or month > 12)
            return RtcDataError.InvalidMonth;
        self.month = @bitCast(month);
    }

    pub fn setWeekDay(self: *RtcData, wday: u8) RtcDataError!void {
        if (wday < 0 or wday > 6)
            return RtcDataError.InvalidWeekDay;
        self.wday = @bitCast(wday);
    }

    pub fn validate(self: *RtcData) RtcDataError!void {
        if (self.year < 2026)
            return RtcDataError.InvalidYear;
        if (self.day < 1 or self.day > 31)
            return RtcDataError.InvalidDay;
        if (self.hours > 23)
            return RtcDataError.InvalidHour;
        if (self.minutes > 59)
            return RtcDataError.InvalidMinute;
        if (self.seconds > 59)
            return RtcDataError.InvalidSecond;
    }
};

pub fn pack(data: u8) u8 {
    return (data & 0xF) + (data >> 4) * 10;
}

pub fn unpack(data: u8) u8 {
    return (data % 10) + ((data / 10) << 4);
}

test "RtcData test" {
    const std = @import("std");
    var rtc: RtcData = undefined;
    rtc.fromBinary(1793198726);
    try std.testing.expectEqual(rtc.year, 2026);
    try std.testing.expectEqual(rtc.month, .October);
    try std.testing.expectEqual(rtc.day, 28);
    try std.testing.expectEqual(rtc.hours, 14);
    try std.testing.expectEqual(rtc.minutes, 45);
    try std.testing.expectEqual(rtc.seconds, 26);
    try std.testing.expectEqual(rtc.wday, .Wednesday);
    try std.testing.expectEqual(rtc.yday, 301);
    rtc.buildYDay();
    try std.testing.expectEqual(rtc.yday, 301);
    const b = rtc.toBinary();
    try std.testing.expectEqual(b, 1793198726);
}