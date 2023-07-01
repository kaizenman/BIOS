OUTPUT_FORMAT(binary)
OUTPUT_ARCH(i8086)

ENTRY(_start)

SECTIONS {
    /* data */
    .text : {
        *(.text)
    }

    /DISCARD/ : {
        *(.text*) *(.data*) *(.bss*) *(.rodata*)
        *(COMMON) *(.discard*) *(.eh_frame) *(.note*)
    }
}
