  .syntax unified
  .cpu cortex-m4
  .fpu fpv4-sp-d16
  .thumb
  
.global  Default_Handler

/* necessary symbols defined in linker script to initialize data */
.word  _sidata
.word  _sdata
.word  _edata
.word  _sbss
.word  _ebss

  .section  .text.Reset_Handler
  .weak  _start
  .type  _start, %function

/* reset Handler */
_start:
  movs r1, #0
  b DataInit

CopyData:
  ldr r3, =_sidata
  ldr r3, [r3, r1]
  str r3, [r0, r1]
  adds r1, r1, #4
    
DataInit:
  ldr r0, =_sdata
  ldr r3, =_edata
  adds r2, r0, r1
  cmp r2, r3
  bcc CopyData
  ldr r2, =_sbss
  b Zerobss

FillZerobss:
  movs r3, #0
  str r3, [r2], #4
    
Zerobss:
  ldr r3, = _ebss
  cmp r2, r3
  bcc FillZerobss
  /* Call SystemInit function */
  bl  SystemInit
  /*Call the main function */
  bl main
loop:
  b loop
.size _start, .-_start

    .section .text.Default_Handler,"ax",%progbits
Default_Handler:
Infinite_Loop:
  b Infinite_Loop
  .size Default_Handler, .-Default_Handler

   .section  .vectors,"a",%progbits
   .global __gVectors

__gVectors:
                    .word _sp                                     /* Top of Stack */
                    .word _start                                  /* Reset Handler */
                    .word NMI_Handler                             /* NMI Handler */
                    .word HardFault_Handler                       /* Hard Fault Handler */
                    .word MemManage_Handler                       /* MPU Fault Handler */
                    .word BusFault_Handler                        /* Bus Fault Handler */
                    .word UsageFault_Handler                      /* Usage Fault Handler */
                    .word SecureFault_Handler                     /* Secure Fault Handler */
                    .word 0                                       /* Reserved */
                    .word 0                                       /* Reserved */
                    .word 0                                       /* Reserved */
                    .word SVC_Handler                             /* SVCall Handler */
                    .word DebugMon_Handler                        /* Debug Monitor Handler */
                    .word 0                                       /* Reserved */
                    .word PendSV_Handler                          /* PendSV Handler */
                    .word SysTick_Handler                         /* SysTick Handler */
                    .word ApplicationInterrupt0Handler
                    .word ApplicationInterrupt1Handler
                    .word ApplicationInterrupt2Handler
                    .word ApplicationInterrupt3Handler
                    .word ApplicationInterrupt4Handler
                    .word ApplicationInterrupt5Handler
                    .word ApplicationInterrupt6Handler
                    .word ApplicationInterrupt7Handler
                    .word ApplicationInterrupt8Handler
                    .word ApplicationInterrupt9Handler
                    .word ApplicationInterrupt10Handler
                    .word ApplicationInterrupt11Handler
                    .word ApplicationInterrupt12Handler
                    .word ApplicationInterrupt13Handler
                    .word ApplicationInterrupt14Handler
                    .word ApplicationInterrupt15Handler
                    .word ApplicationInterrupt16Handler
                    .word ApplicationInterrupt17Handler
                    .word ApplicationInterrupt18Handler
                    .word ApplicationInterrupt19Handler
                    .word ApplicationInterrupt20Handler
                    .word ApplicationInterrupt21Handler
                    .word ApplicationInterrupt22Handler
                    .word ApplicationInterrupt23Handler
                    .word ApplicationInterrupt24Handler
                    .word ApplicationInterrupt25Handler
                    .word ApplicationInterrupt26Handler
                    .word ApplicationInterrupt27Handler
                    .word ApplicationInterrupt28Handler
                    .word ApplicationInterrupt29Handler
                    .word ApplicationInterrupt30Handler
                    .word ApplicationInterrupt31Handler

  .size   __gVectors, . - __gVectors

  .weak NMI_Handler
  .thumb_set NMI_Handler,Default_Handler

  .weak HardFault_Handler
  .thumb_set HardFault_Handler,Default_Handler

  .weak MemManage_Handler
  .thumb_set MemManage_Handler,Default_Handler

  .weak BusFault_Handler
  .thumb_set BusFault_Handler,Default_Handler

  .weak UsageFault_Handler
  .thumb_set UsageFault_Handler,Default_Handler

  .weak SecureFault_Handler
  .thumb_set SecureFault_Handler,Default_Handler

  .weak SVC_Handler
  .thumb_set SVC_Handler,Default_Handler

  .weak DebugMon_Handler
  .thumb_set DebugMon_Handler,Default_Handler

  .weak PendSV_Handler
  .thumb_set PendSV_Handler,Default_Handler

  .weak SysTick_Handler
  .thumb_set SysTick_Handler,Default_Handler

  .weak ApplicationInterrupt0Handler
  .thumb_set ApplicationInterrupt0Handler,Default_Handler

  .weak ApplicationInterrupt1Handler
  .thumb_set ApplicationInterrupt1Handler,Default_Handler

  .weak ApplicationInterrupt2Handler
  .thumb_set ApplicationInterrupt2Handler,Default_Handler

  .weak ApplicationInterrupt3Handler
  .thumb_set ApplicationInterrupt3Handler,Default_Handler

  .weak ApplicationInterrupt4Handler
  .thumb_set ApplicationInterrupt4Handler,Default_Handler

  .weak ApplicationInterrupt5Handler
  .thumb_set ApplicationInterrupt5Handler,Default_Handler

  .weak ApplicationInterrupt6Handler
  .thumb_set ApplicationInterrupt6Handler,Default_Handler

  .weak ApplicationInterrupt7Handler
  .thumb_set ApplicationInterrupt7Handler,Default_Handler

  .weak ApplicationInterrupt8Handler
  .thumb_set ApplicationInterrupt8Handler,Default_Handler

  .weak ApplicationInterrupt9Handler
  .thumb_set ApplicationInterrupt9Handler,Default_Handler

  .weak ApplicationInterrupt10Handler
  .thumb_set ApplicationInterrupt10Handler,Default_Handler

  .weak ApplicationInterrupt11Handler
  .thumb_set ApplicationInterrupt11Handler,Default_Handler

  .weak ApplicationInterrupt12Handler
  .thumb_set ApplicationInterrupt12Handler,Default_Handler

  .weak ApplicationInterrupt13Handler
  .thumb_set ApplicationInterrupt13Handler,Default_Handler

  .weak ApplicationInterrupt14Handler
  .thumb_set ApplicationInterrupt14Handler,Default_Handler

  .weak ApplicationInterrupt15Handler
  .thumb_set ApplicationInterrupt15Handler,Default_Handler

  .weak ApplicationInterrupt16Handler
  .thumb_set ApplicationInterrupt16Handler,Default_Handler

  .weak ApplicationInterrupt17Handler
  .thumb_set ApplicationInterrupt17Handler,Default_Handler

  .weak ApplicationInterrupt18Handler
  .thumb_set ApplicationInterrupt18Handler,Default_Handler

  .weak ApplicationInterrupt19Handler
  .thumb_set ApplicationInterrupt19Handler,Default_Handler

  .weak ApplicationInterrupt20Handler
  .thumb_set ApplicationInterrupt20Handler,Default_Handler

  .weak ApplicationInterrupt21Handler
  .thumb_set ApplicationInterrupt21Handler,Default_Handler

  .weak ApplicationInterrupt22Handler
  .thumb_set ApplicationInterrupt22Handler,Default_Handler

  .weak ApplicationInterrupt23Handler
  .thumb_set ApplicationInterrupt23Handler,Default_Handler

  .weak ApplicationInterrupt24Handler
  .thumb_set ApplicationInterrupt24Handler,Default_Handler

  .weak ApplicationInterrupt25Handler
  .thumb_set ApplicationInterrupt25Handler,Default_Handler

  .weak ApplicationInterrupt26Handler
  .thumb_set ApplicationInterrupt26Handler,Default_Handler

  .weak ApplicationInterrupt27Handler
  .thumb_set ApplicationInterrupt27Handler,Default_Handler

  .weak ApplicationInterrupt28Handler
  .thumb_set ApplicationInterrupt28Handler,Default_Handler

  .weak ApplicationInterrupt29Handler
  .thumb_set ApplicationInterrupt29Handler,Default_Handler

  .weak ApplicationInterrupt30Handler
  .thumb_set ApplicationInterrupt30Handler,Default_Handler

  .weak ApplicationInterrupt31Handler
  .thumb_set ApplicationInterrupt31Handler,Default_Handler
