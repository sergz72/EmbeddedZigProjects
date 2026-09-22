pub const Interrupt = enum(u8) {
    WWDG = 16,            // Window WatchDog Interrupt                            
    PVD = 17,             // PVD through EXTI Line detection Interrupt            
    FLASH = 18,           // FLASH global Interrupt                               
    EXTI7_0 = 20,         // External Line[7:0] Interrupts                        
    AWU = 21,             // AWU global Interrupt                                 
    DMA1_Channel1 = 22,   // DMA1 Channel 1 global Interrupt                      
    DMA1_Channel2 = 23,   // DMA1 Channel 2 global Interrupt                      
    DMA1_Channel3 = 24,   // DMA1 Channel 3 global Interrupt                      
    DMA1_Channel4 = 25,   // DMA1 Channel 4 global Interrupt                      
    DMA1_Channel5 = 26,   // DMA1 Channel 5 global Interrupt                      
    DMA1_Channel6 = 27,   // DMA1 Channel 6 global Interrupt                      
    DMA1_Channel7 = 28,   // DMA1 Channel 7 global Interrupt                      
    ADC1 = 29,            // ADC1 global Interrupt                                
    I2C1_EV = 30,         // I2C1 Event Interrupt                                 
    I2C1_ER = 31,         // I2C1 Error Interrupt                                 
    USART1 = 32,          // USART1 global Interrupt                              
    SPI1 = 33,            // SPI1 global Interrupt                                
    TIM1_BRK = 34,        // TIM1 Break Interrupt                                 
    TIM1_UP = 35,         // TIM1 Update Interrupt                                
    TIM1_TRG_COM = 36,    // TIM1 Trigger and Commutation Interrupt               
    TIM1_CC = 37,         // TIM1 Capture Compare Interrupt                       
    TIM2_UP = 38,         // TIM2 Update Interrupt                                
    USART2 = 39,          // USART2 global Interrupt                              
    EXTI15_8 = 40,        // External Line[15:8] Interrupts                       
    EXTI25_16 = 41,       // External Line[25:16] Interrupts                      
    USART3 = 42,          // USART3 global Interrupt                              
    USART4 = 43,          // USART4 global Interrupt                              
    DMA1_Channel8 = 44,   // DMA1 Channel 8 global Interrupt                      
    USBFS = 45,           // USBFS Host/Device global Interrupt                   
    USBFSWakeUp = 46,     // USBFS Host/Device WakeUp Interrupt                   
    PIOC = 47,            // PIOC global Interrupt                                
    OPA = 48,             // OPA global Interrupt                                 
    USBPD = 49,           // USBPD global Interrupt                               
    USBPDWakeUp = 50,     // USBPD WakeUp Interrupt                               
    TIM2_CC = 51,         // TIM2 Capture Compare Interrupt                       
    TIM2_TRG_COM = 52,    // TIM2 Trigger and Commutation Interrupt               
    TIM2_BRK = 53,        // TIM2 Break Interrupt                                 
    TIM3 = 54,            // TIM3 global Interrupt                                

    pub fn to_u8(self: Interrupt) u8 {
        return @intFromEnum(self);
    }
};
