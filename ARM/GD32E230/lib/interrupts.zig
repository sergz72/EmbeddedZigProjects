pub const Interrupt = enum(u8) {
    WWDGT                   = 0,      // window watchdog timer interrupt                          
    LVD                     = 1,      // LVD through EXTI line detect interrupt                   
    RTC                     = 2,      // RTC through EXTI line interrupt                          
    FMC                     = 3,      // FMC interrupt                                            
    RCU                     = 4,      // RCU interrupt                                            
    EXTI0_1                 = 5,      // EXTI line 0 and 1 interrupts                             
    EXTI2_3                 = 6,      // EXTI line 2 and 3 interrupts                             
    EXTI4_15                = 7,      // EXTI line 4 to 15 interrupts                             
    DMA_Channel0            = 9,      // DMA channel 0 interrupt                                  
    DMA_Channel1_2          = 10,     // DMA channel 1 and channel 2 interrupts                   
    DMA_Channel3_4          = 11,     // DMA channel 3 and channel 4 interrupts                   
    ADC_CMP                 = 12,     // ADC, CMP interrupts                            
    TIMER0_BRK_UP_TRG_COM   = 13,     // TIMER0 break, update, trigger and commutation interrupts 
    TIMER0_Channel          = 14,     // TIMER0 channel capture compare interrupts                
    TIMER2                  = 16,     // TIMER2 interrupt                                         
    TIMER5                  = 17,     // TIMER5 interrupt                                         
    TIMER13                 = 19,     // TIMER13 interrupt                                        
    TIMER14                 = 20,     // TIMER14 interrupt                                        
    TIMER15                 = 21,     // TIMER15 interrupt                                        
    TIMER16                 = 22,     // TIMER16 interrupt                                        
    I2C0_EV                 = 23,     // I2C0 event interrupt                                     
    I2C1_EV                 = 24,     // I2C1 event interrupt                                     
    SPI0                    = 25,     // SPI0 interrupt                                           
    SPI1                    = 26,     // SPI1 interrupt                                           
    USART0                  = 27,     // USART0 interrupt                                         
    USART1                  = 28,     // USART1 interrupt                                         
    I2C0_ER                 = 32,     // I2C0 error interrupt                                     
    I2C1_ER                 = 34,     // I2C1 error interrupt                                     

    pub fn toU8(self: Interrupt) u8 {
        return @intFromEnum(self);
    }
};
