const ICU_BASE: usize = 0x40006000;

const ElcEvent = enum(u8) {
    NONE                          = 0x0,   // Link disabled
    ICU_IRQ0                      = 0x001, // External pin interrupt 0
    ICU_IRQ1                      = 0x002, // External pin interrupt 1
    ICU_IRQ2                      = 0x003, // External pin interrupt 2
    ICU_IRQ3                      = 0x004, // External pin interrupt 3
    ICU_IRQ4                      = 0x005, // External pin interrupt 4
    ICU_IRQ5                      = 0x006, // External pin interrupt 5
    ICU_IRQ6                      = 0x007, // External pin interrupt 6
    ICU_IRQ7                      = 0x008, // External pin interrupt 7
    ICU_IRQ8                      = 0x009, // External pin interrupt 8
    ICU_IRQ9                      = 0x00A, // External pin interrupt 9
    ICU_IRQ10                     = 0x00B, // External pin interrupt 10
    ICU_IRQ11                     = 0x00C, // External pin interrupt 11
    ICU_IRQ12                     = 0x00D, // External pin interrupt 12
    ICU_IRQ14                     = 0x00F, // External pin interrupt 14
    ICU_IRQ15                     = 0x010, // External pin interrupt 15
    DMAC0_INT                     = 0x011, // DMAC0 transfer end
    DMAC1_INT                     = 0x012, // DMAC1 transfer end
    DMAC2_INT                     = 0x013, // DMAC2 transfer end
    DMAC3_INT                     = 0x014, // DMAC3 transfer end
    DTC_COMPLETE                  = 0x015, // DTC transfer complete
    DTC_END                       = 0x016, // DTC transfer end
    ICU_SNOOZE_CANCEL             = 0x017, // Canceling from Snooze mode
    FCU_FRDYI                     = 0x018, // Flash ready interrupt
    LVD_LVD1                      = 0x019, // Voltage monitor 1 interrupt
    LVD_LVD2                      = 0x01A, // Voltage monitor 2 interrupt
    LVD_VBATT                     = 0x01B, // VBATT low voltage detect
    CGC_MOSC_STOP                 = 0x01C, // Main Clock oscillation stop
    LPM_SNOOZE_REQUEST            = 0x01D, // Snooze entry
    AGT0_INT                      = 0x01E, // AGT interrupt
    AGT0_COMPARE_A                = 0x01F, // Compare match A
    AGT0_COMPARE_B                = 0x020, // Compare match B
    AGT1_INT                      = 0x021, // AGT interrupt
    AGT1_COMPARE_A                = 0x022, // Compare match A
    AGT1_COMPARE_B                = 0x023, // Compare match B
    IWDT_UNDERFLOW                = 0x024, // IWDT underflow
    WDT_UNDERFLOW                 = 0x025, // WDT underflow
    RTC_ALARM                     = 0x026, // Alarm interrupt
    RTC_PERIOD                    = 0x027, // Periodic interrupt
    RTC_CARRY                     = 0x028, // Carry interrupt
    ADC0_SCAN_END                 = 0x029, // End of A/D scanning operation
    ADC0_SCAN_END_B               = 0x02A, // A/D scan end interrupt for group B
    ADC0_WINDOW_A                 = 0x02B, // Window A Compare match interrupt
    ADC0_WINDOW_B                 = 0x02C, // Window B Compare match interrupt
    ADC0_COMPARE_MATCH            = 0x02D, // Compare match
    ADC0_COMPARE_MISMATCH         = 0x02E, // Compare mismatch
    ACMPLP0_INT                   = 0x02F, // Low Power Comparator channel 0 interrupt
    ACMPLP1_INT                   = 0x030, // Low Power Comparator channel 1 interrupt
    USBFS_FIFO_0                  = 0x031, // DMA/DTC transfer request 0
    USBFS_FIFO_1                  = 0x032, // DMA/DTC transfer request 1
    USBFS_INT                     = 0x033, // USBFS interrupt
    USBFS_RESUME                  = 0x034, // USBFS resume interrupt
    IIC0_RXI                      = 0x035, // Receive data full
    IIC0_TXI                      = 0x036, // Transmit data empty
    IIC0_TEI                      = 0x037, // Transmit end
    IIC0_ERI                      = 0x038, // Transfer error
    IIC0_WUI                      = 0x039, // Wakeup interrupt
    IIC1_RXI                      = 0x03A, // Receive data full
    IIC1_TXI                      = 0x03B, // Transmit data empty
    IIC1_TEI                      = 0x03C, // Transmit end
    IIC1_ERI                      = 0x03D, // Transfer error
    SSI0_TXI                      = 0x03E, // Transmit data empty
    SSI0_RXI                      = 0x03F, // Receive data full
    SSI0_INT                      = 0x041, // Error interrupt
    CTSU_WRITE                    = 0x042, // Write request interrupt
    CTSU_READ                     = 0x043, // Measurement data transfer request interrupt
    CTSU_END                      = 0x044, // Measurement end interrupt
    KEY_INT                       = 0x045, // Key interrupt
    DOC_INT                       = 0x046, // Data operation circuit interrupt
    CAC_FREQUENCY_ERROR           = 0x047, // Frequency error interrupt
    CAC_MEASUREMENT_END           = 0x048, // Measurement end interrupt
    CAC_OVERFLOW                  = 0x049, // Overflow interrupt
    CAN0_ERROR                    = 0x04A, // Error interrupt
    CAN0_FIFO_RX                  = 0x04B, // Receive FIFO interrupt
    CAN0_FIFO_TX                  = 0x04C, // Transmit FIFO interrupt
    CAN0_MAILBOX_RX               = 0x04D, // Reception complete interrupt
    CAN0_MAILBOX_TX               = 0x04E, // Transmission complete interrupt
    IOPORT_EVENT_1                = 0x04F, // Port 1 event
    IOPORT_EVENT_2                = 0x050, // Port 2 event
    IOPORT_EVENT_3                = 0x051, // Port 3 event
    IOPORT_EVENT_4                = 0x052, // Port 4 event
    ELC_SOFTWARE_EVENT_0          = 0x053, // Software event 0
    ELC_SOFTWARE_EVENT_1          = 0x054, // Software event 1
    POEG0_EVENT                   = 0x055, // Port Output disable 0 interrupt
    POEG1_EVENT                   = 0x056, // Port Output disable 1 interrupt
    GPT0_CAPTURE_COMPARE_A        = 0x057, // Capture/Compare match A
    GPT0_CAPTURE_COMPARE_B        = 0x058, // Capture/Compare match B
    GPT0_COMPARE_C                = 0x059, // Compare match C
    GPT0_COMPARE_D                = 0x05A, // Compare match D
    GPT0_COMPARE_E                = 0x05B, // Compare match E
    GPT0_COMPARE_F                = 0x05C, // Compare match F
    GPT0_COUNTER_OVERFLOW         = 0x05D, // Overflow
    GPT0_COUNTER_UNDERFLOW        = 0x05E, // Underflow
    GPT1_CAPTURE_COMPARE_A        = 0x05F, // Capture/Compare match A
    GPT1_CAPTURE_COMPARE_B        = 0x060, // Capture/Compare match B
    GPT1_COMPARE_C                = 0x061, // Compare match C
    GPT1_COMPARE_D                = 0x062, // Compare match D
    GPT1_COMPARE_E                = 0x063, // Compare match E
    GPT1_COMPARE_F                = 0x064, // Compare match F
    GPT1_COUNTER_OVERFLOW         = 0x065, // Overflow
    GPT1_COUNTER_UNDERFLOW        = 0x066, // Underflow
    GPT2_CAPTURE_COMPARE_A        = 0x067, // Capture/Compare match A
    GPT2_CAPTURE_COMPARE_B        = 0x068, // Capture/Compare match B
    GPT2_COMPARE_C                = 0x069, // Compare match C
    GPT2_COMPARE_D                = 0x06A, // Compare match D
    GPT2_COMPARE_E                = 0x06B, // Compare match E
    GPT2_COMPARE_F                = 0x06C, // Compare match F
    GPT2_COUNTER_OVERFLOW         = 0x06D, // Overflow
    GPT2_COUNTER_UNDERFLOW        = 0x06E, // Underflow
    GPT3_CAPTURE_COMPARE_A        = 0x06F, // Capture/Compare match A
    GPT3_CAPTURE_COMPARE_B        = 0x070, // Capture/Compare match B
    GPT3_COMPARE_C                = 0x071, // Compare match C
    GPT3_COMPARE_D                = 0x072, // Compare match D
    GPT3_COMPARE_E                = 0x073, // Compare match E
    GPT3_COMPARE_F                = 0x074, // Compare match F
    GPT3_COUNTER_OVERFLOW         = 0x075, // Overflow
    GPT3_COUNTER_UNDERFLOW        = 0x076, // Underflow
    GPT4_CAPTURE_COMPARE_A        = 0x077, // Capture/Compare match A
    GPT4_CAPTURE_COMPARE_B        = 0x078, // Capture/Compare match B
    GPT4_COMPARE_C                = 0x079, // Compare match C
    GPT4_COMPARE_D                = 0x07A, // Compare match D
    GPT4_COMPARE_E                = 0x07B, // Compare match E
    GPT4_COMPARE_F                = 0x07C, // Compare match F
    GPT4_COUNTER_OVERFLOW         = 0x07D, // Overflow
    GPT4_COUNTER_UNDERFLOW        = 0x07E, // Underflow
    GPT5_CAPTURE_COMPARE_A        = 0x07F, // Capture/Compare match A
    GPT5_CAPTURE_COMPARE_B        = 0x080, // Capture/Compare match B
    GPT5_COMPARE_C                = 0x081, // Compare match C
    GPT5_COMPARE_D                = 0x082, // Compare match D
    GPT5_COMPARE_E                = 0x083, // Compare match E
    GPT5_COMPARE_F                = 0x084, // Compare match F
    GPT5_COUNTER_OVERFLOW         = 0x085, // Overflow
    GPT5_COUNTER_UNDERFLOW        = 0x086, // Underflow
    GPT6_CAPTURE_COMPARE_A        = 0x087, // Capture/Compare match A
    GPT6_CAPTURE_COMPARE_B        = 0x088, // Capture/Compare match B
    GPT6_COMPARE_C                = 0x089, // Compare match C
    GPT6_COMPARE_D                = 0x08A, // Compare match D
    GPT6_COMPARE_E                = 0x08B, // Compare match E
    GPT6_COMPARE_F                = 0x08C, // Compare match F
    GPT6_COUNTER_OVERFLOW         = 0x08D, // Overflow
    GPT6_COUNTER_UNDERFLOW        = 0x08E, // Underflow
    GPT7_CAPTURE_COMPARE_A        = 0x08F, // Capture/Compare match A
    GPT7_CAPTURE_COMPARE_B        = 0x090, // Capture/Compare match B
    GPT7_COMPARE_C                = 0x091, // Compare match C
    GPT7_COMPARE_D                = 0x092, // Compare match D
    GPT7_COMPARE_E                = 0x093, // Compare match E
    GPT7_COMPARE_F                = 0x094, // Compare match F
    GPT7_COUNTER_OVERFLOW         = 0x095, // Overflow
    GPT7_COUNTER_UNDERFLOW        = 0x096, // Underflow
    OPS_UVW_EDGE                  = 0x097, // UVW edge event
    SCI0_RXI                      = 0x098, // Receive data full
    SCI0_TXI                      = 0x099, // Transmit data empty
    SCI0_TEI                      = 0x09A, // Transmit end
    SCI0_ERI                      = 0x09B, // Receive error
    SCI0_AM                       = 0x09C, // Address match event
    SCI0_RXI_OR_ERI               = 0x09D, // Receive data full/Receive error
    SCI1_RXI                      = 0x09E, // Receive data full
    SCI1_TXI                      = 0x09F, // Transmit data empty
    SCI1_TEI                      = 0x0A0, // Transmit end
    SCI1_ERI                      = 0x0A1, // Receive error
    SCI1_AM                       = 0x0A2, // Address match event
    SCI2_RXI                      = 0x0A3, // Receive data full
    SCI2_TXI                      = 0x0A4, // Transmit data empty
    SCI2_TEI                      = 0x0A5, // Transmit end
    SCI2_ERI                      = 0x0A6, // Receive error
    SCI2_AM                       = 0x0A7, // Address match event
    SCI9_RXI                      = 0x0A8, // Receive data full
    SCI9_TXI                      = 0x0A9, // Transmit data empty
    SCI9_TEI                      = 0x0AA, // Transmit end
    SCI9_ERI                      = 0x0AB, // Receive error
    SCI9_AM                       = 0x0AC, // Address match event
    SPI0_RXI                      = 0x0AD, // Receive buffer full
    SPI0_TXI                      = 0x0AE, // Transmit buffer empty
    SPI0_IDLE                     = 0x0AF, // Idle
    SPI0_ERI                      = 0x0B0, // Error
    SPI0_TEI                      = 0x0B1, // Transmission complete event
    SPI1_RXI                      = 0x0B2, // Receive buffer full
    SPI1_TXI                      = 0x0B3, // Transmit buffer empty
    SPI1_IDLE                     = 0x0B4, // Idle
    SPI1_ERI                      = 0x0B5, // Error
    SPI1_TEI                      = 0x0B6  // Transmission complete event
};

pub const IcuCr = packed struct(u8) {
    irqmd: u2 = 0,
    reserved: u2 = 0,
    fscksel: u2 = 0,
    reserved2: u1 = 0,
    flten: bool = false
};

pub const IcuIelsr = packed struct(u32) {
    iels: ElcEvent = .NONE,
    reserved: u8 = 0,
    ir: bool = false,
    reserved2: u7 = 0,
    dtce: bool = false,
    reserved3: u7 = 0
};

pub const IcuDelsr = packed struct(u32) {
    iels: ElcEvent = .NONE,
    reserved: u8 = 0,
    ir: bool = false,
    reserved2: u15 = 0
};

pub const IcuSelsr = packed struct(u16) {
    iels: ElcEvent = .NONE,
    reserved: u8 = 0
};

pub const Icu = extern struct {
    //6000
    cr: [16]IcuCr,
    reserved: [240]u8,
    //6100
    nmicr: u8,
    reserved4: [31]u8,
    //6120
    nmier: u16,
    reserved2: [7]u16,
    //6130
    nmiclr: u16,
    reserved3: [7]u16,
    //6140
    nmisr: u16,
    reserved5: [94]u8,
    //61A0
    wupen: u32,
    reserved6: [92]u8,
    //6200
    selsr: IcuSelsr,
    reserved7: [126]u8,
    //6280
    delsr: [4]IcuDelsr,
    reserved8: [112]u8,
    //6300
    ielsr: [32]IcuIelsr
};

pub const icu: *volatile Icu = @ptrFromInt(ICU_BASE);

test "sizeof test" {
    const std = @import("std");
    try std.testing.expectEqual(0x380, @sizeOf(Icu));
}
