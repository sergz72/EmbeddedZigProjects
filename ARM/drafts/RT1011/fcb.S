    .syntax unified
    .cpu    cortex-m7
    .thumb

    .extern __isr_vector            @ defined in main.c (.isr_vector, 0x60002000)

/* ---------------------------------------------------------------
 * FlexSPI Configuration Block, 512 bytes at 0x60000400
 * 1-bit 0x0B fast read, 50 MHz, 4 MB window
 * --------------------------------------------------------------- */
    .section .boot_hdr.conf, "a", %progbits
    .align  2
    .global fcb
fcb:
    .word   0x42464346          @ [0]   tag 'FCFB'
    .word   0x56010400          @ [1]   version
    .word   0                   @ [2]   reserved
    .word   0x00030300          @ [3]   sampleClkSrc=0, csHold=3, csSetup=3, colAddrWidth=0
    .fill   12, 4, 0            @ [4..15]
    .word   0x00000010          @ [16]  controllerMiscOption: SafeConfigFreqEnable
    .word   0x00020101          @ [17]  deviceType=1 (NOR), padType=1 (single), serialClkFreq=2 (50 MHz)
    .fill   2, 4, 0             @ [18..19]
    .word   0x00400000          @ [20]  sflashA1Size = 4 MB
    .fill   11, 4, 0            @ [21..31]
    .word   0x0818040B          @ [32]  LUT0: CMD_SDR 1pad 0x0B | RADDR_SDR 1pad 24 bit
    .word   0x24043008          @ [33]       DUMMY_SDR 1pad 8 | READ_SDR 1pad 4
    .fill   78, 4, 0            @ [34..111] rest of LUT + custom seqs + reserved
    .word   256                 @ [112] pageSize
    .word   4096                @ [113] sectorSize
    .word   1                   @ [114] ipcmdSerialClkFreq = 30 MHz
    .word   0                   @ [115] isUniformBlockSize etc.
    .word   0x00010000          @ [116] blockSize
    .fill   11, 4, 0            @ [117..127]

/* ---------------------------------------------------------------
 * Image Vector Table, 32 bytes at 0x60001000
 * --------------------------------------------------------------- */
    .section .boot_hdr.ivt, "a", %progbits
    .align  2
    .global ivt
ivt:
    .word   0x402000D1          @ header: tag 0xD1, length 0x0020, version 0x40
    .word   __isr_vector        @ entry: address of vector table
    .word   0                   @ reserved
    .word   0                   @ DCD (none)
    .word   boot_data           @ pointer to boot data
    .word   0x60001000          @ self (address of this IVT)
    .word   0                   @ CSF (none)
    .word   0                   @ reserved

/* ---------------------------------------------------------------
 * Boot data, 12 bytes at 0x60001020
 * --------------------------------------------------------------- */
    .section .boot_hdr.boot_data, "a", %progbits
    .align  2
    .global boot_data
boot_data:
    .word   0x60000000          @ image start
    .word   0x00400000          @ image length
    .word   0                   @ plugin flag
