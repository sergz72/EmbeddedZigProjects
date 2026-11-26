	.syntax	unified
	.eabi_attribute	67, "2.09"	@ Tag_conformance
	.cpu	cortex-m0plus
	.eabi_attribute	6, 12	@ Tag_CPU_arch
	.eabi_attribute	7, 77	@ Tag_CPU_arch_profile
	.eabi_attribute	8, 0	@ Tag_ARM_ISA_use
	.eabi_attribute	9, 1	@ Tag_THUMB_ISA_use
	.eabi_attribute	34, 0	@ Tag_CPU_unaligned_access
	.eabi_attribute	17, 1	@ Tag_ABI_PCS_GOT_use
	.eabi_attribute	20, 1	@ Tag_ABI_FP_denormal
	.eabi_attribute	21, 0	@ Tag_ABI_FP_exceptions
	.eabi_attribute	23, 3	@ Tag_ABI_FP_number_model
	.eabi_attribute	24, 1	@ Tag_ABI_align_needed
	.eabi_attribute	25, 1	@ Tag_ABI_align_preserved
	.eabi_attribute	38, 1	@ Tag_ABI_FP_16bit_format
	.eabi_attribute	18, 4	@ Tag_ABI_PCS_wchar_t
	.eabi_attribute	26, 2	@ Tag_ABI_enum_size
	.eabi_attribute	14, 0	@ Tag_ABI_PCS_R9_use
	.file	"startup_samd21.c"
	.text
	.globl	Dummy_Handler                   @ -- Begin function Dummy_Handler
	.p2align	1
	.type	Dummy_Handler,%function
	.code	16
	.thumb_func
Dummy_Handler:                          @ @Dummy_Handler
	.fnstart
@ %bb.0:
.LBB0_1:                                @ =>This Inner Loop Header: Depth=1
	b	.LBB0_1
.Lfunc_end0:
	.size	Dummy_Handler, .Lfunc_end0-Dummy_Handler
	.cantunwind
	.fnend
                                        @ -- End function
	.globl	Reset_Handler                   @ -- Begin function Reset_Handler
	.p2align	2
	.type	Reset_Handler,%function
	.code	16
	.thumb_func
Reset_Handler:                          @ @Reset_Handler
	.fnstart
@ %bb.0:
	ldr	r1, .LCPI1_0
	ldr	r0, .LCPI1_1
	cmp	r0, r1
	bhs	.LBB1_2
@ %bb.1:
	subs	r1, r0, r1
	mvns	r1, r1
	movs	r2, #3
	bics	r1, r2
	adds	r2, r1, #4
	ldr	r1, .LCPI1_2
	bl	__aeabi_memcpy4
.LBB1_2:
	ldr	r1, .LCPI1_3
	ldr	r0, .LCPI1_4
	cmp	r0, r1
	bhs	.LBB1_4
@ %bb.3:
	subs	r1, r0, r1
	mvns	r1, r1
	movs	r2, #3
	bics	r1, r2
	adds	r1, r1, #4
	bl	__aeabi_memclr4
.LBB1_4:
	movs	r0, #255
	ldr	r1, .LCPI1_5
	bics	r1, r0
	ldr	r0, .LCPI1_6
	str	r1, [r0]
	ldr	r0, .LCPI1_7
	movs	r1, #2
	str	r1, [r0]
	ldr	r1, .LCPI1_8
	ldrb	r2, [r1]
	movs	r0, #252
	ands	r2, r0
	adds	r2, r2, #2
	strb	r2, [r1]
	ldrb	r2, [r1]
	movs	r3, #243
	ands	r2, r3
	adds	r2, #8
	strb	r2, [r1]
	ldr	r1, .LCPI1_9
	ldrb	r2, [r1]
	movs	r4, #207
	ands	r4, r2
	adds	r4, #32
	strb	r4, [r1]
	ldrb	r2, [r1]
	ands	r2, r3
	adds	r2, #8
	strb	r2, [r1]
	ldrb	r2, [r1]
	ands	r2, r0
	adds	r0, r2, #2
	strb	r0, [r1]
	ldr	r0, .LCPI1_10
	ldr	r1, [r0]
	movs	r2, #128
	orrs	r2, r1
	str	r2, [r0]
	bl	SystemInit
	bl	main
.LBB1_5:                                @ =>This Inner Loop Header: Depth=1
	b	.LBB1_5
	.p2align	2
@ %bb.6:
.LCPI1_0:
	.long	_erelocate
.LCPI1_1:
	.long	_srelocate
.LCPI1_2:
	.long	_etext
.LCPI1_3:
	.long	_ezero
.LCPI1_4:
	.long	_szero
.LCPI1_5:
	.long	_sfixed
.LCPI1_6:
	.long	3758157064                      @ 0xe000ed08
.LCPI1_7:
	.long	1090548000                      @ 0x41007120
.LCPI1_8:
	.long	1090539523                      @ 0x41005003
.LCPI1_9:
	.long	1090537486                      @ 0x4100480e
.LCPI1_10:
	.long	1090535428                      @ 0x41004004
.Lfunc_end1:
	.size	Reset_Handler, .Lfunc_end1-Reset_Handler
	.cantunwind
	.fnend
                                        @ -- End function
	.type	exception_table,%object         @ @exception_table
	.section	.vectors,"a",%progbits
	.globl	exception_table
	.p2align	2, 0x0
exception_table:
	.long	_estack
	.long	Reset_Handler
	.long	NonMaskableInt_Handler
	.long	HardFault_Handler
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	SVCall_Handler
	.long	0
	.long	0
	.long	PendSV_Handler
	.long	SysTick_Handler
	.long	PM_Handler
	.long	SYSCTRL_Handler
	.long	WDT_Handler
	.long	RTC_Handler
	.long	EIC_Handler
	.long	NVMCTRL_Handler
	.long	DMAC_Handler
	.long	USB_Handler
	.long	EVSYS_Handler
	.long	SERCOM0_Handler
	.long	SERCOM1_Handler
	.long	SERCOM2_Handler
	.long	SERCOM3_Handler
	.long	SERCOM4_Handler
	.long	SERCOM5_Handler
	.long	TCC0_Handler
	.long	TCC1_Handler
	.long	TCC2_Handler
	.long	TC3_Handler
	.long	TC4_Handler
	.long	TC5_Handler
	.long	TC6_Handler
	.long	TC7_Handler
	.long	ADC_Handler
	.long	AC_Handler
	.long	DAC_Handler
	.long	PTC_Handler
	.long	I2S_Handler
	.long	0
	.size	exception_table, 180

	.weak	NonMaskableInt_Handler
	.type	NonMaskableInt_Handler,%function
NonMaskableInt_Handler = Dummy_Handler
	.weak	HardFault_Handler
	.type	HardFault_Handler,%function
HardFault_Handler = Dummy_Handler
	.weak	SVCall_Handler
	.type	SVCall_Handler,%function
SVCall_Handler = Dummy_Handler
	.weak	PendSV_Handler
	.type	PendSV_Handler,%function
PendSV_Handler = Dummy_Handler
	.weak	SysTick_Handler
	.type	SysTick_Handler,%function
SysTick_Handler = Dummy_Handler
	.weak	PM_Handler
	.type	PM_Handler,%function
PM_Handler = Dummy_Handler
	.weak	SYSCTRL_Handler
	.type	SYSCTRL_Handler,%function
SYSCTRL_Handler = Dummy_Handler
	.weak	WDT_Handler
	.type	WDT_Handler,%function
WDT_Handler = Dummy_Handler
	.weak	RTC_Handler
	.type	RTC_Handler,%function
RTC_Handler = Dummy_Handler
	.weak	EIC_Handler
	.type	EIC_Handler,%function
EIC_Handler = Dummy_Handler
	.weak	NVMCTRL_Handler
	.type	NVMCTRL_Handler,%function
NVMCTRL_Handler = Dummy_Handler
	.weak	DMAC_Handler
	.type	DMAC_Handler,%function
DMAC_Handler = Dummy_Handler
	.weak	USB_Handler
	.type	USB_Handler,%function
USB_Handler = Dummy_Handler
	.weak	EVSYS_Handler
	.type	EVSYS_Handler,%function
EVSYS_Handler = Dummy_Handler
	.weak	SERCOM0_Handler
	.type	SERCOM0_Handler,%function
SERCOM0_Handler = Dummy_Handler
	.weak	SERCOM1_Handler
	.type	SERCOM1_Handler,%function
SERCOM1_Handler = Dummy_Handler
	.weak	SERCOM2_Handler
	.type	SERCOM2_Handler,%function
SERCOM2_Handler = Dummy_Handler
	.weak	SERCOM3_Handler
	.type	SERCOM3_Handler,%function
SERCOM3_Handler = Dummy_Handler
	.weak	SERCOM4_Handler
	.type	SERCOM4_Handler,%function
SERCOM4_Handler = Dummy_Handler
	.weak	SERCOM5_Handler
	.type	SERCOM5_Handler,%function
SERCOM5_Handler = Dummy_Handler
	.weak	TCC0_Handler
	.type	TCC0_Handler,%function
TCC0_Handler = Dummy_Handler
	.weak	TCC1_Handler
	.type	TCC1_Handler,%function
TCC1_Handler = Dummy_Handler
	.weak	TCC2_Handler
	.type	TCC2_Handler,%function
TCC2_Handler = Dummy_Handler
	.weak	TC3_Handler
	.type	TC3_Handler,%function
TC3_Handler = Dummy_Handler
	.weak	TC4_Handler
	.type	TC4_Handler,%function
TC4_Handler = Dummy_Handler
	.weak	TC5_Handler
	.type	TC5_Handler,%function
TC5_Handler = Dummy_Handler
	.weak	TC6_Handler
	.type	TC6_Handler,%function
TC6_Handler = Dummy_Handler
	.weak	TC7_Handler
	.type	TC7_Handler,%function
TC7_Handler = Dummy_Handler
	.weak	ADC_Handler
	.type	ADC_Handler,%function
ADC_Handler = Dummy_Handler
	.weak	AC_Handler
	.type	AC_Handler,%function
AC_Handler = Dummy_Handler
	.weak	DAC_Handler
	.type	DAC_Handler,%function
DAC_Handler = Dummy_Handler
	.weak	PTC_Handler
	.type	PTC_Handler,%function
PTC_Handler = Dummy_Handler
	.weak	I2S_Handler
	.type	I2S_Handler,%function
I2S_Handler = Dummy_Handler
	.ident	"Ubuntu clang version 23.1.6 (++20261116013916+5b10d2d74929-1~exp1~20261116133927.96)"
	.section	".note.GNU-stack","",%progbits
	.addrsig
	.addrsig_sym Dummy_Handler
	.addrsig_sym Reset_Handler
	.addrsig_sym _estack
	.addrsig_sym exception_table
	.addrsig_sym _srelocate
	.addrsig_sym _erelocate
	.addrsig_sym _szero
	.addrsig_sym _ezero
	.addrsig_sym _sfixed
	.addrsig_sym NonMaskableInt_Handler
	.addrsig_sym HardFault_Handler
	.addrsig_sym SVCall_Handler
	.addrsig_sym PendSV_Handler
	.addrsig_sym SysTick_Handler
	.addrsig_sym PM_Handler
	.addrsig_sym SYSCTRL_Handler
	.addrsig_sym WDT_Handler
	.addrsig_sym RTC_Handler
	.addrsig_sym EIC_Handler
	.addrsig_sym NVMCTRL_Handler
	.addrsig_sym DMAC_Handler
	.addrsig_sym USB_Handler
	.addrsig_sym EVSYS_Handler
	.addrsig_sym SERCOM0_Handler
	.addrsig_sym SERCOM1_Handler
	.addrsig_sym SERCOM2_Handler
	.addrsig_sym SERCOM3_Handler
	.addrsig_sym SERCOM4_Handler
	.addrsig_sym SERCOM5_Handler
	.addrsig_sym TCC0_Handler
	.addrsig_sym TCC1_Handler
	.addrsig_sym TCC2_Handler
	.addrsig_sym TC3_Handler
	.addrsig_sym TC4_Handler
	.addrsig_sym TC5_Handler
	.addrsig_sym TC6_Handler
	.addrsig_sym TC7_Handler
	.addrsig_sym ADC_Handler
	.addrsig_sym AC_Handler
	.addrsig_sym DAC_Handler
	.addrsig_sym PTC_Handler
	.addrsig_sym I2S_Handler
	.eabi_attribute	30, 2	@ Tag_ABI_optimization_goals
