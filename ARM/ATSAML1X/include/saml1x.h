#ifndef SAML1X_H
#define SAML1X_H

typedef enum IRQn
{
/******  CORTEX-M23 Processor Exceptions Numbers ******************************/
  Reset_IRQn                = -15, /* -15 Reset Vector, invoked on Power up and warm reset */
  NonMaskableInt_IRQn       = -14, /* -14 Non maskable Interrupt, cannot be stopped or preempted */
  HardFault_IRQn            = -13, /* -13 Hard Fault, all classes of Fault    */
  SVCall_IRQn               =  -5, /* -5  System Service Call via SVC instruction */
  PendSV_IRQn               =  -2, /* -2  Pendable request for system service */
  SysTick_IRQn              =  -1, /* -1  System Tick Timer                   */

/******  SAML10E16A specific Interrupt Numbers ***********************************/
  MCLK_IRQn                 =   0, /* 0   Shared between MCLK OSCCTRL OSC32KCTRL PM SUPC (MCLK) */
  OSC32KCTRL_IRQn           =   0, /* 0   Shared between MCLK OSCCTRL OSC32KCTRL PM SUPC (OSC32KCTRL) */
  OSCCTRL_IRQn              =   0, /* 0   Shared between MCLK OSCCTRL OSC32KCTRL PM SUPC (OSCCTRL) */
  PM_IRQn                   =   0, /* 0   Shared between MCLK OSCCTRL OSC32KCTRL PM SUPC (PM) */
  SUPC_IRQn                 =   0, /* 0   Shared between MCLK OSCCTRL OSC32KCTRL PM SUPC (SUPC) */
  WDT_IRQn                  =   1, /* 1   Watchdog Timer (WDT)                */
  RTC_IRQn                  =   2, /* 2   Real-Time Counter (RTC)             */
  EIC_EXTINT_0_IRQn         =   3, /* 3   External Interrupt Controller (EIC) */
  EIC_EXTINT_1_IRQn         =   4, /* 4   External Interrupt Controller (EIC) */
  EIC_EXTINT_2_IRQn         =   5, /* 5   External Interrupt Controller (EIC) */
  EIC_EXTINT_3_IRQn         =   6, /* 6   External Interrupt Controller (EIC) */
  EIC_OTHER_IRQn            =   7, /* 7   External Interrupt Controller (EIC) */
  FREQM_IRQn                =   8, /* 8   Frequency Meter (FREQM)             */
  NVMCTRL_IRQn              =   9, /* 9   Non-Volatile Memory Controller (NVMCTRL) */
  PORT_IRQn                 =  10, /* 10  Port Module (PORT)                  */
  DMAC_0_IRQn               =  11, /* 11  Direct Memory Access Controller (DMAC) */
  DMAC_1_IRQn               =  12, /* 12  Direct Memory Access Controller (DMAC) */
  DMAC_2_IRQn               =  13, /* 13  Direct Memory Access Controller (DMAC) */
  DMAC_3_IRQn               =  14, /* 14  Direct Memory Access Controller (DMAC) */
  DMAC_OTHER_IRQn           =  15, /* 15  Direct Memory Access Controller (DMAC) */
  EVSYS_0_IRQn              =  16, /* 16  Event System Interface (EVSYS)      */
  EVSYS_1_IRQn              =  17, /* 17  Event System Interface (EVSYS)      */
  EVSYS_2_IRQn              =  18, /* 18  Event System Interface (EVSYS)      */
  EVSYS_3_IRQn              =  19, /* 19  Event System Interface (EVSYS)      */
  EVSYS_NSCHK_IRQn          =  20, /* 20  Event System Interface (EVSYS)      */
  PAC_IRQn                  =  21, /* 21  Peripheral Access Controller (PAC)  */
  SERCOM0_0_IRQn            =  22, /* 22  Serial Communication Interface (SERCOM0) */
  SERCOM0_1_IRQn            =  23, /* 23  Serial Communication Interface (SERCOM0) */
  SERCOM0_2_IRQn            =  24, /* 24  Serial Communication Interface (SERCOM0) */
  SERCOM0_OTHER_IRQn        =  25, /* 25  Serial Communication Interface (SERCOM0) */
  SERCOM1_0_IRQn            =  26, /* 26  Serial Communication Interface (SERCOM1) */
  SERCOM1_1_IRQn            =  27, /* 27  Serial Communication Interface (SERCOM1) */
  SERCOM1_2_IRQn            =  28, /* 28  Serial Communication Interface (SERCOM1) */
  SERCOM1_OTHER_IRQn        =  29, /* 29  Serial Communication Interface (SERCOM1) */
  SERCOM2_0_IRQn            =  30, /* 30  Serial Communication Interface (SERCOM2) */
  SERCOM2_1_IRQn            =  31, /* 31  Serial Communication Interface (SERCOM2) */
  SERCOM2_2_IRQn            =  32, /* 32  Serial Communication Interface (SERCOM2) */
  SERCOM2_OTHER_IRQn        =  33, /* 33  Serial Communication Interface (SERCOM2) */
  TC0_IRQn                  =  34, /* 34  Basic Timer Counter (TC0)           */
  TC1_IRQn                  =  35, /* 35  Basic Timer Counter (TC1)           */
  TC2_IRQn                  =  36, /* 36  Basic Timer Counter (TC2)           */
  ADC_OTHER_IRQn            =  37, /* 37  Analog Digital Converter (ADC)      */
  ADC_RESRDY_IRQn           =  38, /* 38  Analog Digital Converter (ADC)      */
  AC_IRQn                   =  39, /* 39  Analog Comparators (AC)             */
  DAC_UNDERRUN_A_IRQn       =  40, /* 40  Digital Analog Converter (DAC)      */
  DAC_EMPTY_IRQn            =  41, /* 41  Digital Analog Converter (DAC)      */
  PTC_IRQn                  =  42, /* 42  Peripheral Touch Controller (PTC)   */
  TRNG_IRQn                 =  43, /* 43  True Random Generator (TRNG)        */
  TRAM_IRQn                 =  44, /* 44  TrustRAM (TRAM)                     */

  PERIPH_MAX_IRQn           =  44  /* Max peripheral ID */
} IRQn_Type;

#define __FPU_PRESENT                      0 /* FPU present or not                                                        */
#define __MPU_PRESENT                      1 /* MPU present or not                                                        */
#define __NVIC_PRIO_BITS                   2 /* Number of Bits used for Priority Levels                                   */
#define __VTOR_PRESENT                     1 /* Vector Table Offset Register present or not                               */
#define __Vendor_SysTickConfig             0 /* Set to 1 if different SysTick Config is used                              */
#define __ARCH_ARM                         1
#define __ARCH_ARM_CORTEX_M                1

#include "core_cm23.h"

typedef struct _DeviceVectors
{
  /* Stack pointer */
  void* pvStack;
  /* CORTEX-M23 handlers */
  void* pfnReset_Handler;                        /* -15 Reset Vector, invoked on Power up and warm reset */
  void* pfnNonMaskableInt_Handler;               /* -14 Non maskable Interrupt, cannot be stopped or preempted */
  void* pfnHardFault_Handler;                    /* -13 Hard Fault, all classes of Fault */
  void* pvReservedC12;
  void* pvReservedC11;
  void* pvReservedC10;
  void* pvReservedC9;
  void* pvReservedC8;
  void* pvReservedC7;
  void* pvReservedC6;
  void* pfnSVCall_Handler;                       /*  -5 System Service Call via SVC instruction */
  void* pvReservedC4;
  void* pvReservedC3;
  void* pfnPendSV_Handler;                       /*  -2 Pendable request for system service */
  void* pfnSysTick_Handler;                      /*  -1 System Tick Timer */

  /* Peripheral handlers */
  void* pfnSYSTEM_Handler;                       /*   0 System peripherals shared interrupt (MCLK OSCCTRL OSC32KCTRL PM SUPC) */
  void* pfnWDT_Handler;                          /*   1 Watchdog Timer (WDT) */
  void* pfnRTC_Handler;                          /*   2 Real-Time Counter (RTC) */
  void* pfnEIC_EXTINT_0_Handler;                 /*   3 External Interrupt Controller (EIC) */
  void* pfnEIC_EXTINT_1_Handler;                 /*   4 External Interrupt Controller (EIC) */
  void* pfnEIC_EXTINT_2_Handler;                 /*   5 External Interrupt Controller (EIC) */
  void* pfnEIC_EXTINT_3_Handler;                 /*   6 External Interrupt Controller (EIC) */
  void* pfnEIC_OTHER_Handler;                    /*   7 External Interrupt Controller (EIC) */
  void* pfnFREQM_Handler;                        /*   8 Frequency Meter (FREQM) */
  void* pfnNVMCTRL_Handler;                      /*   9 Non-Volatile Memory Controller (NVMCTRL) */
  void* pfnPORT_Handler;                         /*  10 Port Module (PORT) */
  void* pfnDMAC_0_Handler;                       /*  11 Direct Memory Access Controller (DMAC) */
  void* pfnDMAC_1_Handler;                       /*  12 Direct Memory Access Controller (DMAC) */
  void* pfnDMAC_2_Handler;                       /*  13 Direct Memory Access Controller (DMAC) */
  void* pfnDMAC_3_Handler;                       /*  14 Direct Memory Access Controller (DMAC) */
  void* pfnDMAC_OTHER_Handler;                   /*  15 Direct Memory Access Controller (DMAC) */
  void* pfnEVSYS_0_Handler;                      /*  16 Event System Interface (EVSYS) */
  void* pfnEVSYS_1_Handler;                      /*  17 Event System Interface (EVSYS) */
  void* pfnEVSYS_2_Handler;                      /*  18 Event System Interface (EVSYS) */
  void* pfnEVSYS_3_Handler;                      /*  19 Event System Interface (EVSYS) */
  void* pfnEVSYS_NSCHK_Handler;                  /*  20 Event System Interface (EVSYS) */
  void* pfnPAC_Handler;                          /*  21 Peripheral Access Controller (PAC) */
  void* pfnSERCOM0_0_Handler;                    /*  22 Serial Communication Interface (SERCOM0) */
  void* pfnSERCOM0_1_Handler;                    /*  23 Serial Communication Interface (SERCOM0) */
  void* pfnSERCOM0_2_Handler;                    /*  24 Serial Communication Interface (SERCOM0) */
  void* pfnSERCOM0_OTHER_Handler;                /*  25 Serial Communication Interface (SERCOM0) */
  void* pfnSERCOM1_0_Handler;                    /*  26 Serial Communication Interface (SERCOM1) */
  void* pfnSERCOM1_1_Handler;                    /*  27 Serial Communication Interface (SERCOM1) */
  void* pfnSERCOM1_2_Handler;                    /*  28 Serial Communication Interface (SERCOM1) */
  void* pfnSERCOM1_OTHER_Handler;                /*  29 Serial Communication Interface (SERCOM1) */
  void* pfnSERCOM2_0_Handler;                    /*  30 Serial Communication Interface (SERCOM2) */
  void* pfnSERCOM2_1_Handler;                    /*  31 Serial Communication Interface (SERCOM2) */
  void* pfnSERCOM2_2_Handler;                    /*  32 Serial Communication Interface (SERCOM2) */
  void* pfnSERCOM2_OTHER_Handler;                /*  33 Serial Communication Interface (SERCOM2) */
  void* pfnTC0_Handler;                          /*  34 Basic Timer Counter (TC0) */
  void* pfnTC1_Handler;                          /*  35 Basic Timer Counter (TC1) */
  void* pfnTC2_Handler;                          /*  36 Basic Timer Counter (TC2) */
  void* pfnADC_OTHER_Handler;                    /*  37 Analog Digital Converter (ADC) */
  void* pfnADC_RESRDY_Handler;                   /*  38 Analog Digital Converter (ADC) */
  void* pfnAC_Handler;                           /*  39 Analog Comparators (AC) */
  void* pfnDAC_UNDERRUN_A_Handler;               /*  40 Digital Analog Converter (DAC) */
  void* pfnDAC_EMPTY_Handler;                    /*  41 Digital Analog Converter (DAC) */
  void* pfnPTC_Handler;                          /*  42 Peripheral Touch Controller (PTC) */
  void* pfnTRNG_Handler;                         /*  43 True Random Generator (TRNG) */
  void* pfnTRAM_Handler;                         /*  44 TrustRAM (TRAM) */
} DeviceVectors;

#endif
