pub const Interrupt = enum(u8) {
    WWDT                   = 0,      // window watchdog timer interrupt                      
    PVM                    = 1,      // pvm through exint line detection interrupt           
    ERTC                   = 2,      // ertc global interrupt                                
    FLASH                  = 3,      // flash global interrupt                               
    CRM                    = 4,      // crm global interrupt                                 
    EXINT1_0               = 5,      // external line1~0 interrupt                           
    EXINT3_2               = 6,      // external line3~2 interrupt                           
    EXINT15_4              = 7,      // external line15~4 interrupt                          

    DMA1_Channel1          = 9,      // dma1 channel 1 global interrupt                      
    DMA1_Channel3_2        = 10,     // dma1 channel 3~2 global interrupt                    
    DMA1_Channel7_4        = 11,     // dma1 channel 7~4 global interrupt                    
    ADC1_CMP               = 12,     // adc1 and comparator global interrupt                 
    TMR1_BRK_OVF_TRG_HALL  = 13,     // tmr1 brake overflow trigger and hall interrupt       
    TMR1_CH                = 14,     // tmr1 channel interrupt                               
    TMR3_GLOBAL            = 16,     // tmr3 global interrupt                                
    TMR6_GLOBAL            = 17,     // tmr6 global interrupt                                
    TMR4_GLOBAL            = 19,     // tmr4 global interrupt                                
    TMR15_GLOBAL           = 20,     // tmr15 global interrupt                               
    TMR16_GLOBAL           = 21,     // tmr16 global interrupt                               
    TMR17_GLOBAL           = 22,     // tmr17 global interrupt                               
    I2C1_EVT               = 23,     // i2c1 event interrupt                                 
    I2C2_EVT               = 24,     // i2c2 event interrupt                                 
    SPI1                   = 25,     // spi1 global interrupt                                
    SPI2                   = 26,     // spi2 global interrupt                                
    USART1                 = 27,     // usart1 global interrupt                              
    USART2                 = 28,     // usart2 global interrupt                              
    CAN1_TX                = 30,     // can1 tx interrupt                                    
    CAN1_RX                = 31,     // can1 rx interrupt                                    
    I2C1_ERR               = 32,     // i2c1 error interrupt                                 
    I2C2_ERR               = 34,     // i2c2 error interrupt                                 
    CAN1_STAT              = 35,     // can1 stat interrupt                                  
    CAN1_ERR               = 36,     // can1 err interrupt                                   
    FPU                    = 37,     // fpu interrupt                                        

    pub fn toU8(self: Interrupt) u8 {
        return @intFromEnum(self);
    }
};
