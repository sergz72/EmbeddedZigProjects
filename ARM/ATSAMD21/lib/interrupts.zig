pub const Interrupt = enum(u8) {
    PM                  =  0, //  0 SAMD21G18A Power Manager (PM) 
    SYSCTRL             =  1, //  1 SAMD21G18A System Control (SYSCTRL) 
    WDT                 =  2, //  2 SAMD21G18A Watchdog Timer (WDT) 
    RTC                 =  3, //  3 SAMD21G18A Real-Time Counter (RTC) 
    EIC                 =  4, //  4 SAMD21G18A External Interrupt Controller (EIC) 
    NVMCTRL             =  5, //  5 SAMD21G18A Non-Volatile Memory Controller (NVMCTRL) 
    DMAC                =  6, //  6 SAMD21G18A Direct Memory Access Controller (DMAC) 
    USB                 =  7, //  7 SAMD21G18A Universal Serial Bus (USB) 
    EVSYS               =  8, //  8 SAMD21G18A Event System Interface (EVSYS) 
    SERCOM0             =  9, //  9 SAMD21G18A Serial Communication Interface 0 (SERCOM0) 
    SERCOM1             = 10, // 10 SAMD21G18A Serial Communication Interface 1 (SERCOM1) 
    SERCOM2             = 11, // 11 SAMD21G18A Serial Communication Interface 2 (SERCOM2) 
    SERCOM3             = 12, // 12 SAMD21G18A Serial Communication Interface 3 (SERCOM3) 
    SERCOM4             = 13, // 13 SAMD21G18A Serial Communication Interface 4 (SERCOM4) 
    SERCOM5             = 14, // 14 SAMD21G18A Serial Communication Interface 5 (SERCOM5) 
    TCC0                = 15, // 15 SAMD21G18A Timer Counter Control 0 (TCC0) 
    TCC1                = 16, // 16 SAMD21G18A Timer Counter Control 1 (TCC1) 
    TCC2                = 17, // 17 SAMD21G18A Timer Counter Control 2 (TCC2) 
    TC3                 = 18, // 18 SAMD21G18A Basic Timer Counter 3 (TC3) 
    TC4                 = 19, // 19 SAMD21G18A Basic Timer Counter 4 (TC4) 
    TC5                 = 20, // 20 SAMD21G18A Basic Timer Counter 5 (TC5) 
    ADC                 = 23, // 23 SAMD21G18A Analog Digital Converter (ADC) 
    AC                  = 24, // 24 SAMD21G18A Analog Comparators (AC) 
    DAC                 = 25, // 25 SAMD21G18A Digital Analog Converter (DAC) 
    PTC                 = 26, // 26 SAMD21G18A Peripheral Touch Controller (PTC) 
    I2S                 = 27, // 27 SAMD21G18A Inter-IC Sound Interface (I2S) 

    pub fn toU8(self: Interrupt) u8 {
        return @intFromEnum(self);
    }
};
