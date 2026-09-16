const NVIC_BASE: usize = 0xE000E000;

pub const Interrupt = enum(u32) {
    WWDGT_IRQn                   = 0,      // window watchDog timer interrupt
    LVD_IRQn                     = 1,      // LVD through EXTI line detect interrupt                   
    TAMPER_IRQn                  = 2,      // tamper through EXTI line detect                          
    RTC_IRQn                     = 3,      // RTC through EXTI line interrupt                          
    FMC_IRQn                     = 4,      // FMC interrupt                                            
    RCU_CTC_IRQn                 = 5,      // RCU and CTC interrupt                                    
    EXTI0_IRQn                   = 6,      // EXTI line 0 interrupt                                    
    EXTI1_IRQn                   = 7,      // EXTI line 1 interrupt                                    
    EXTI2_IRQn                   = 8,      // EXTI line 2 interrupt                                    
    EXTI3_IRQn                   = 9,      // EXTI line 3 interrupt                                    
    EXTI4_IRQn                   = 10,     // EXTI line 4 interrupt                                    
    DMA0_Channel0_IRQn           = 11,     // DMA0 channel0 interrupt                                  
    DMA0_Channel1_IRQn           = 12,     // DMA0 channel1 interrupt                                  
    DMA0_Channel2_IRQn           = 13,     // DMA0 channel2 interrupt                                  
    DMA0_Channel3_IRQn           = 14,     // DMA0 channel3 interrupt                                  
    DMA0_Channel4_IRQn           = 15,     // DMA0 channel4 interrupt                                  
    DMA0_Channel5_IRQn           = 16,     // DMA0 channel5 interrupt                                  
    DMA0_Channel6_IRQn           = 17,     // DMA0 channel6 interrupt                                  
    ADC0_1_IRQn                  = 18,     // ADC0 and ADC1 interrupt                                  
    USBD_HP_CAN0_TX_IRQn         = 19,     // CAN0 TX interrupts
    USBD_LP_CAN0_RX0_IRQn        = 20,     // CAN0 RX0 interrupts                                      
    CAN0_RX1_IRQn                = 21,     // CAN0 RX1 interrupt                                       
    CAN0_EWMC_IRQn               = 22,     // CAN0 EWMC interrupt                                      
    EXTI5_9_IRQn                 = 23,     // EXTI[9:5] interrupts                                     
    TIMER0_BRK_IRQn              = 24,     // TIMER0 break interrupt                                   
    TIMER0_UP_IRQn               = 25,     // TIMER0 update interrupt                                  
    TIMER0_TRG_CMT_IRQn          = 26,     // TIMER0 trigger and commutation interrupt                 
    TIMER0_Channel_IRQn          = 27,     // TIMER0 channel capture compare interrupt                 
    TIMER1_IRQn                  = 28,     // TIMER1 interrupt                                         
    TIMER2_IRQn                  = 29,     // TIMER2 interrupt                                         
    TIMER3_IRQn                  = 30,     // TIMER3 interrupt                                         
    I2C0_EV_IRQn                 = 31,     // I2C0 event interrupt                                     
    I2C0_ER_IRQn                 = 32,     // I2C0 error interrupt                                     
    I2C1_EV_IRQn                 = 33,     // I2C1 event interrupt                                     
    I2C1_ER_IRQn                 = 34,     // I2C1 error interrupt                                     
    SPI0_IRQn                    = 35,     // SPI0 interrupt                                           
    SPI1_IRQn                    = 36,     // SPI1 interrupt                                           
    USART0_IRQn                  = 37,     // USART0 interrupt                                         
    USART1_IRQn                  = 38,     // USART1 interrupt                                         
    USART2_IRQn                  = 39,     // USART2 interrupt                                         
    EXTI10_15_IRQn               = 40,     // EXTI[15:10] interrupts                                   
    RTC_Alarm_IRQn               = 41,     // RTC alarm interrupt                                      
    USBD_WKUP_IRQn               = 42,     // USBD Wakeup interrupt                                    
    TIMER7_BRK_IRQn              = 43,     // TIMER7 break interrupt                                   
    TIMER7_UP_IRQn               = 44,     // TIMER7 update interrupt                                  
    TIMER7_TRG_CMT_IRQn          = 45,     // TIMER7 trigger and commutation interrupt                 
    TIMER7_Channel_IRQn          = 46,     // TIMER7 channel capture compare interrupt                 
    ADC2_IRQn                    = 47,     // ADC2 global interrupt                                    
    EXMC_IRQn                    = 48,     // EXMC global interrupt                                    
    SDIO_IRQn                    = 49,     // SDIO global interrupt                                    
    TIMER4_IRQn                  = 50,     // TIMER4 global interrupt                                  
    SPI2_IRQn                    = 51,     // SPI2 global interrupt                                    
    UART3_IRQn                   = 52,     // UART3 global interrupt                                   
    UART4_IRQn                   = 53,     // UART4 global interrupt                                   
    TIMER5_IRQn                  = 54,     // TIMER5 global interrupt                                  
    TIMER6_IRQn                  = 55,     // TIMER6 global interrupt                                  
    DMA1_Channel0_IRQn           = 56,     // DMA1 channel0 global interrupt                           
    DMA1_Channel1_IRQn           = 57,     // DMA1 channel1 global interrupt                           
    DMA1_Channel2_IRQn           = 58,     // DMA1 channel2 global interrupt                           
    DMA1_Channel3_Channel4_IRQn  = 59,     // DMA1 channel3 and channel4 global Interrupt              
    DMA1_Channel4_IRQn           = 60,     // DMA1 channel3 global interrupt
    ENET_IRQn                    = 61,     // ENET global interrupt                                    
    ENET_WKUP_IRQn               = 62,     // ENET Wakeup interrupt                                    
    CAN1_TX_IRQn                 = 63,     // CAN1 TX interrupt                                        
    CAN1_RX0_IRQn                = 64,     // CAN1 RX0 interrupt                                       
    CAN1_RX1_IRQn                = 65,     // CAN1 RX1 interrupt                                       
    CAN1_EWMC_IRQn               = 66,     // CAN1 EWMC interrupt                                      
    USBFS_IRQn                   = 67      // USBFS global interrupt
};

pub const Nvic = extern struct {
    reserved: u32,
    ictr: u32,
    reserved2: [62]u32,
    iser: [8]u32,
    reserved3: [24]u32,
    icer: [8]u32,
    reserved4: [24]u32,
    ispr: [8]u32,
    reserved5: [24]u32,
    icpr: [8]u32,
    reserved6: [24]u32,
    iabr: [8]u32,
    reserved7: [56]u32,
    ipr:  [60]u32,

    pub fn interrupt_enable(self: *volatile Nvic, interrupt: Interrupt) void {
        const v = @intFromEnum(interrupt);
        const shift: u5 = @truncate(v);
        self.iser[v >> 5] = @as(u32, 1) << shift;
    }

    pub fn interrupt_disable(self: *volatile Nvic, interrupt: Interrupt) void {
        const v = @intFromEnum(interrupt);
        const shift: u5 = @truncate(v);
        self.icer[v >> 5] = @as(u32, 1) << shift;
    }
};

pub const nvic: *volatile Nvic = @ptrFromInt(NVIC_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x4F0, @sizeOf(Nvic));
}
