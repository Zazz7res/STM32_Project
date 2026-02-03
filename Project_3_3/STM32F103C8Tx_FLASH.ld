/*
***************************************************************************** 
* STM32F103C8Tx Linker Script (ST官方标准版)
***************************************************************************** 
*/

/* 指定内存区域 */
MEMORY
{
  FLASH (rx) : ORIGIN = 0x08000000, LENGTH = 64K
  RAM (xrw)  : ORIGIN = 0x20000000, LENGTH = 20K
}

/* 入口点 */
ENTRY(Reset_Handler)

/* 栈顶地址 */
_estack = ORIGIN(RAM) + LENGTH(RAM);

/* 段布局 */
SECTIONS
{
  /* 中断向量表 - 同时兼容 .vectors 和 .isr_vector */
  .isr_vector :
  {
    . = ALIGN(4);
    KEEP(*(.isr_vector)) /* 旧版标准库 */
    KEEP(*(.vectors))    /* 新版标准库 (GCC 14) */
    . = ALIGN(4);
  } >FLASH

  /* 代码段 */
  .text :
  {
    . = ALIGN(4);
    *(.text)
    *(.text*)
    *(.glue_7)
    *(.glue_7t)
    *(.eh_frame)
    KEEP (*(.init))
    KEEP (*(.fini))
    . = ALIGN(4);
    _etext = .;
  } >FLASH

  /* 只读数据 */
  .rodata :
  {
    . = ALIGN(4);
    *(.rodata)
    *(.rodata*)
    . = ALIGN(4);
  } >FLASH

  /* 初始化数据（Flash中存储，运行时复制到RAM） */
  .data : 
  {
    . = ALIGN(4);
    _sdata = .;
    *(.data)
    *(.data*)
    . = ALIGN(4);
    _edata = .;
  } >RAM AT> FLASH

  /* Flash中.data的加载地址 */
  _sidata = LOADADDR(.data);

  /* 未初始化数据（BSS） */
  .bss :
  {
    . = ALIGN(4);
    _sbss = .;
    __bss_start__ = _sbss;  /* Newlib必需 */
    *(.bss)
    *(.bss*)
    *(COMMON)
    . = ALIGN(4);
    _ebss = .;
    __bss_end__ = _ebss;    /* Newlib必需 */
  } >RAM

  /* 堆定义（Newlib必需） */
  ._user_heap_stack :
  {
    . = ALIGN(4);
    PROVIDE ( end = . );
    PROVIDE ( _end = . );
    . = . + 0x200;  /* 最小堆大小 */
    . = ALIGN(4);
    . = . + 0x400;  /* 最小栈大小 */
    . = ALIGN(4);
  } >RAM

  /* 丢弃无用段 */
  /DISCARD/ :
  {
    *(.ARM.exidx*)
    *(.ARM.extab*)
  }
}
