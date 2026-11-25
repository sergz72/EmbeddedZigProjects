  .syntax unified
	.cpu cortex-m23
	.fpu softvfp
	.thumb

.global g_pfnVectors
.global Default_Handler

/* start address for the initialization values of the .data section.
defined in linker script */
.word _sidata
/* start address for the .data section. defined in linker script */
.word _sdata
/* end address for the .data section. defined in linker script */
.word _edata
/* start address for the .bss section. defined in linker script */
.word _sbss
/* end address for the .bss section. defined in linker script */
.word _ebss

/**
  * @brief  This is the code that gets called when the processor first
  *          starts execution following a reset event. Only the absolutely
  *          necessary set is performed, after which the application
  *          supplied main() routine is called.
  * @param  None
  * @retval : None
  */

    .section	.text.Reset_Handler
	.weak	Reset_Handler
	.type	Reset_Handler, %function
Reset_Handler:
  ldr   r0, =_estack
  mov   sp, r0          /* set stack pointer */

/* Copy the data segment initializers from flash to SRAM */
  ldr r0, =_sdata
  ldr r1, =_edata
  ldr r2, =_sidata
  movs r3, #0
  b LoopCopyDataInit

CopyDataInit:
  ldr r4, [r2, r3]
  str r4, [r0, r3]
  adds r3, r3, #4

LoopCopyDataInit:
  adds r4, r0, r3
  cmp r4, r1
  bcc CopyDataInit

/* Zero fill the bss segment. */
  ldr r2, =_sbss
  ldr r4, =_ebss
  movs r3, #0
  b LoopFillZerobss

FillZerobss:
  str  r3, [r2]
  adds r2, r2, #4

LoopFillZerobss:
  cmp r2, r4
  bcc FillZerobss

/* Call the clock system initialization function.*/
  bl  SystemInit
/* Call static constructors */
  //bl __libc_init_array
/* Call the application's entry point.*/
  bl main

LoopForever:
    b LoopForever

  .size Reset_Handler, .-Reset_Handler

/**
 * @brief  This is the code that gets called when the processor receives an
 *         unexpected interrupt.  This simply enters an infinite loop, preserving
 *         the system state for examination by a debugger.
 *
 * @param  None
 * @retval : None
*/
  .section .text.Default_Handler,"ax",%progbits
Default_Handler:
Infinite_Loop:
  b Infinite_Loop
  .size Default_Handler, .-Default_Handler

/******************************************************************************
*
* The STM32H563xx vector table.  Note that the proper constructs
* must be placed on this to ensure that it ends up at physical address
* 0x0000.0000.
*
******************************************************************************/
  .section .isr_vector,"a",%progbits
  .type g_pfnVectors, %object

g_pfnVectors:
	.word	_estack
	.word	Reset_Handler
	.word	NMI_Handler
	.word	HardFault_Handler
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	SVC_Handler
	.word	0
	.word	0
	.word	PendSV_Handler
	.word	SysTick_Handler
    .word   SYSTEM_Handler
    .word   WDT_Handler
    .word   RTC_Handler
    .word   EIC_EXTINT_0_Handler
    .word   EIC_EXTINT_1_Handler
    .word   EIC_EXTINT_2_Handler
    .word   EIC_EXTINT_3_Handler
    .word   EIC_EXTINT_4_Handler
    .word   EIC_EXTINT_5_Handler
    .word   EIC_EXTINT_6_Handler
    .word   EIC_EXTINT_7_Handler
    .word   EIC_OTHER_Handler
    .word   FREQM_Handler
    .word   NVMCTRL_Handler
    .word   PORT_Handler
    .word   DMAC_0_Handler
    .word   DMAC_1_Handler
    .word   DMAC_2_Handler
    .word   DMAC_3_Handler
    .word   DMAC_OTHER_Handler
    .word   USB_Handler
    .word   EVSYS_0_Handler
    .word   EVSYS_1_Handler
    .word   EVSYS_2_Handler
    .word   EVSYS_3_Handler
    .word   EVSYS_4_Handler
    .word   EVSYS_5_Handler
    .word   EVSYS_6_Handler
    .word   EVSYS_7_Handler
    .word   EVSYS_NSCHK_Handler
    .word   PAC_Handler
    .word   SERCOM0_0_Handler
    .word   SERCOM0_1_Handler
    .word   SERCOM0_2_Handler
    .word   SERCOM0_OTHER_Handler
    .word   SERCOM1_0_Handler
    .word   SERCOM1_1_Handler
    .word   SERCOM1_2_Handler
    .word   SERCOM1_OTHER_Handler
    .word   SERCOM2_0_Handler
    .word   SERCOM2_1_Handler
    .word   SERCOM2_2_Handler
    .word   SERCOM2_OTHER_Handler
    .word   SERCOM3_0_Handler
    .word   SERCOM3_1_Handler
    .word   SERCOM3_2_Handler
    .word   SERCOM3_OTHER_Handler
    .word   SERCOM4_0_Handler
    .word   SERCOM4_1_Handler
    .word   SERCOM4_2_Handler
    .word   SERCOM4_OTHER_Handler
    .word   SERCOM5_0_Handler
    .word   SERCOM5_1_Handler
    .word   SERCOM5_2_Handler
    .word   SERCOM5_OTHER_Handler
    .word   TC0_Handler
    .word   TC1_Handler
    .word   TC2_Handler
    .word   TCC0_Handler
    .word   TCC1_Handler
    .word   TCC2_Handler
    .word   TCC3_Handler
    .word   ADC_OTHER_Handler
    .word   ADC_RESRDY_Handler
    .word   AC_Handler
    .word   DAC_UNDERRUN_Handler
    .word   DAC_EMPTY_Handler
    .word   PTC_Handler
    .word   TRNG_Handler
    .word   I2S_Handler
    .word   TRAM_Handler

  .size g_pfnVectors, .-g_pfnVectors

/*******************************************************************************
*
* Provide weak aliases for each Exception handler to the Default_Handler.
* As they are weak aliases, any function with the same name will override
* this definition.
*
*******************************************************************************/

	.weak	NMI_Handler
	.thumb_set NMI_Handler,Default_Handler

	.weak	HardFault_Handler
	.thumb_set HardFault_Handler,Default_Handler

	.weak	SVC_Handler
	.thumb_set SVC_Handler,Default_Handler

	.weak	PendSV_Handler
	.thumb_set PendSV_Handler,Default_Handler

	.weak	SysTick_Handler
	.thumb_set SysTick_Handler,Default_Handler

        .weak   SYSTEM_Handler
        .thumb_set SYSTEM_Handler,Default_Handler

        .weak   WDT_Handler
        .thumb_set WDT_Handler,Default_Handler

        .weak   RTC_Handler
        .thumb_set RTC_Handler,Default_Handler

        .weak   EIC_EXTINT_0_Handler
        .thumb_set EIC_EXTINT_0_Handler,Default_Handler

        .weak   EIC_EXTINT_1_Handler
        .thumb_set EIC_EXTINT_1_Handler,Default_Handler

        .weak   EIC_EXTINT_2_Handler
        .thumb_set EIC_EXTINT_2_Handler,Default_Handler

        .weak   EIC_EXTINT_3_Handler
        .thumb_set EIC_EXTINT_3_Handler,Default_Handler

        .weak   EIC_EXTINT_4_Handler
        .thumb_set EIC_EXTINT_4_Handler,Default_Handler

        .weak   EIC_EXTINT_5_Handler
        .thumb_set EIC_EXTINT_5_Handler,Default_Handler

        .weak   EIC_EXTINT_6_Handler
        .thumb_set EIC_EXTINT_6_Handler,Default_Handler

        .weak   EIC_EXTINT_7_Handler
        .thumb_set EIC_EXTINT_7_Handler,Default_Handler

        .weak   EIC_OTHER_Handler
        .thumb_set EIC_OTHER_Handler,Default_Handler

        .weak   FREQM_Handler
        .thumb_set FREQM_Handler,Default_Handler

        .weak   NVMCTRL_Handler
        .thumb_set NVMCTRL_Handler,Default_Handler

        .weak   PORT_Handler
        .thumb_set PORT_Handler,Default_Handler

        .weak   DMAC_0_Handler
        .thumb_set DMAC_0_Handler,Default_Handler

        .weak   DMAC_1_Handler
        .thumb_set DMAC_1_Handler,Default_Handler

        .weak   DMAC_2_Handler
        .thumb_set DMAC_2_Handler,Default_Handler

        .weak   DMAC_3_Handler
        .thumb_set DMAC_3_Handler,Default_Handler

        .weak   DMAC_OTHER_Handler
        .thumb_set DMAC_OTHER_Handler,Default_Handler

        .weak   USB_Handler
        .thumb_set USB_Handler,Default_Handler

        .weak   EVSYS_0_Handler
        .thumb_set EVSYS_0_Handler,Default_Handler

        .weak   EVSYS_1_Handler
        .thumb_set EVSYS_1_Handler,Default_Handler

        .weak   EVSYS_2_Handler
        .thumb_set EVSYS_2_Handler,Default_Handler

        .weak   EVSYS_3_Handler
        .thumb_set EVSYS_3_Handler,Default_Handler

        .weak   EVSYS_4_Handler
        .thumb_set EVSYS_4_Handler,Default_Handler

        .weak   EVSYS_5_Handler
        .thumb_set EVSYS_5_Handler,Default_Handler

        .weak   EVSYS_6_Handler
        .thumb_set EVSYS_6_Handler,Default_Handler

        .weak   EVSYS_7_Handler
        .thumb_set EVSYS_7_Handler,Default_Handler

        .weak   EVSYS_NSCHK_Handler
        .thumb_set EVSYS_NSCHK_Handler,Default_Handler

        .weak   PAC_Handler
        .thumb_set PAC_Handler,Default_Handler

        .weak   SERCOM0_0_Handler
        .thumb_set SERCOM0_0_Handler,Default_Handler

        .weak   SERCOM0_1_Handler
        .thumb_set SERCOM0_1_Handler,Default_Handler

        .weak   SERCOM0_2_Handler
        .thumb_set SERCOM0_2_Handler,Default_Handler

        .weak   SERCOM0_OTHER_Handler
        .thumb_set SERCOM0_OTHER_Handler,Default_Handler

        .weak   SERCOM1_0_Handler
        .thumb_set SERCOM1_0_Handler,Default_Handler

        .weak   SERCOM1_1_Handler
        .thumb_set SERCOM1_1_Handler,Default_Handler

        .weak   SERCOM1_2_Handler
        .thumb_set SERCOM1_2_Handler,Default_Handler

        .weak   SERCOM1_OTHER_Handler
        .thumb_set SERCOM1_OTHER_Handler,Default_Handler

        .weak   SERCOM2_0_Handler
        .thumb_set SERCOM2_0_Handler,Default_Handler

        .weak   SERCOM2_1_Handler
        .thumb_set SERCOM2_1_Handler,Default_Handler

        .weak   SERCOM2_2_Handler
        .thumb_set SERCOM2_2_Handler,Default_Handler

        .weak   SERCOM2_OTHER_Handler
        .thumb_set SERCOM2_OTHER_Handler,Default_Handler

        .weak   SERCOM3_0_Handler
        .thumb_set SERCOM3_0_Handler,Default_Handler

        .weak   SERCOM3_1_Handler
        .thumb_set SERCOM3_1_Handler,Default_Handler

        .weak   SERCOM3_2_Handler
        .thumb_set SERCOM3_2_Handler,Default_Handler

        .weak   SERCOM3_OTHER_Handler
        .thumb_set SERCOM3_OTHER_Handler,Default_Handler

        .weak   SERCOM4_0_Handler
        .thumb_set SERCOM4_0_Handler,Default_Handler

        .weak   SERCOM4_1_Handler
        .thumb_set SERCOM4_1_Handler,Default_Handler

        .weak   SERCOM4_2_Handler
        .thumb_set SERCOM4_2_Handler,Default_Handler

        .weak   SERCOM4_OTHER_Handler
        .thumb_set SERCOM4_OTHER_Handler,Default_Handler

        .weak   SERCOM5_0_Handler
        .thumb_set SERCOM5_0_Handler,Default_Handler

        .weak   SERCOM5_1_Handler
        .thumb_set SERCOM5_1_Handler,Default_Handler

        .weak   SERCOM5_2_Handler
        .thumb_set SERCOM5_2_Handler,Default_Handler

        .weak   SERCOM5_OTHER_Handler
        .thumb_set SERCOM5_OTHER_Handler,Default_Handler

        .weak   TC0_Handler
        .thumb_set TC0_Handler,Default_Handler

        .weak   TC1_Handler
        .thumb_set TC1_Handler,Default_Handler

        .weak   TC2_Handler
        .thumb_set TC2_Handler,Default_Handler

        .weak   TCC0_Handler
        .thumb_set TCC0_Handler,Default_Handler

        .weak   TCC1_Handler
        .thumb_set TCC1_Handler,Default_Handler

        .weak   TCC2_Handler
        .thumb_set TCC2_Handler,Default_Handler

        .weak   TCC3_Handler
        .thumb_set TCC3_Handler,Default_Handler

        .weak   ADC_OTHER_Handler
        .thumb_set ADC_OTHER_Handler,Default_Handler

        .weak   ADC_RESRDY_Handler
        .thumb_set ADC_RESRDY_Handler,Default_Handler

        .weak   AC_Handler
        .thumb_set AC_Handler,Default_Handler

        .weak   DAC_UNDERRUN_Handler
        .thumb_set DAC_UNDERRUN_Handler,Default_Handler

        .weak   DAC_EMPTY_Handler
        .thumb_set DAC_EMPTY_Handler,Default_Handler

        .weak   PTC_Handler
        .thumb_set PTC_Handler,Default_Handler

        .weak   TRNG_Handler
        .thumb_set TRNG_Handler,Default_Handler

        .weak   I2S_Handler
        .thumb_set I2S_Handler,Default_Handler

        .weak   TRAM_Handler
        .thumb_set TRAM_Handler,Default_Handler
