pub const Interrupt = enum(u8) {
    IRQ0               = 0,      // 16 SYSCTL_INT Interrupt
                                 // 16 WWDT1_INT Interrupt
                                 // 16 WWDT0_INT Interrupt
                                 // 16 FLASHCTL_INT Interrupt
                                 // 16 DEBUGSS_INT Interrupt
    IRQ1               = 1,      // 17 GPIOB_INT Interrupt
                                 // 17 GPIOA_INT Interrupt
                                 // 17 TRNG_INT Interrupt
                                 // 17 COMP0_INT Interrupt
                                 // 17 COMP1_INT Interrupt
                                 // 17 COMP2_INT Interrupt
    TIMG8              = 2,      // 18 TIMG8_INT Interrupt 
    UART3              = 3,      // 19 UART3_INT Interrupt 
    ADC0               = 4,      // 20 ADC0_INT Interrupt 
    ADC1               = 5,      // 21 ADC1_INT Interrupt 
    CANFD0             = 6,      // 22 CANFD0_INT Interrupt 
    DAC0               = 7,      // 23 DAC0_INT Interrupt 
    SPI0               = 9,      // 25 SPI0_INT Interrupt 
    SPI1               = 10,     // 26 SPI1_INT Interrupt 
    UART1              = 13,     // 29 UART1_INT Interrupt 
    UART2              = 14,     // 30 UART2_INT Interrupt 
    UART0              = 15,     // 31 UART0_INT Interrupt 
    TIMG0              = 16,     // 32 TIMG0_INT Interrupt 
    TIMG6              = 17,     // 33 TIMG6_INT Interrupt 
    TIMA0              = 18,     // 34 TIMA0_INT Interrupt 
    TIMA1              = 19,     // 35 TIMA1_INT Interrupt 
    TIMG7              = 20,     // 36 TIMG7_INT Interrupt 
    TIMG12             = 21,     // 37 TIMG12_INT Interrupt 
    I2C0               = 24,     // 40 I2C0_INT Interrupt 
    I2C1               = 25,     // 41 I2C1_INT Interrupt 
    AES                = 28,     // 44 AES_INT Interrupt 
    RTC                = 30,     // 46 RTC_INT Interrupt 
    DMA                = 31,     // 47 DMA_INT Interrupt 

    pub fn toU8(self: Interrupt) u8 {
        return @intFromEnum(self);
    }
};
