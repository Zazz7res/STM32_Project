MEMORY
{
  FLASH (rx) : ORIGIN = 0x08000000, LENGTH = 64K
  RAM (rwx)  : ORIGIN = 0x20000000, LENGTH = 20K
}
SECTIONS
{
  .isr_vector : { KEEP(*(.isr_vector)) } > FLASH
  .text : {
    *(.text*) *(.rodata*) KEEP(*(.init)) KEEP(*(.fini))
    _etext = .;
  } > FLASH
  .preinit_array : {
    PROVIDE_HIDDEN (__preinit_array_start = .);
    KEEP (*(.preinit_array*))
    PROVIDE_HIDDEN (__preinit_array_end = .);
  } > FLASH
  .init_array : {
    PROVIDE_HIDDEN (__init_array_start = .);
    KEEP (*(SORT(.init_array.*))) KEEP (*(.init_array*))
    PROVIDE_HIDDEN (__init_array_end = .);
  } > FLASH
  .fini_array : {
    PROVIDE_HIDDEN (__fini_array_start = .);
    KEEP (*(SORT(.fini_array.*))) KEEP (*(.fini_array*))
    PROVIDE_HIDDEN (__fini_array_end = .);
  } > FLASH
  _sidata = LOADADDR(.data);
  .data : AT (_sidata) {
    _sdata = .; *(.data*) _edata = .;
  } > RAM
  .bss : {
    _sbss = .; __bss_start__ = _sbss; *(.bss*) *(COMMON) _ebss = .; __bss_end__ = _ebss;
  } > RAM
  .heap : {
    __end__ = .; PROVIDE(end = .); *(.heap*) __HeapLimit = .;
  } > RAM
  ._stack : {
    . = ALIGN(8);
    . = . + 2K;
    . = ALIGN(8);
    _estack = .;
  } > RAM
}
