/* ==========================================================================
   文件名：STM32F103C8T6.ld
   作用：定义 STM32F103C8T6 芯片的内存布局 (Flash 和 RAM 的大小及位置)
   芯片：STM32F103C8T6 (Medium Density)
   ========================================================================== */

/* 1. 定义内存区域 (MEMORY) */
/* 告诉链接器：芯片里有哪些可用的内存块 */
MEMORY
{
  /* Flash 区域：
     - 名称：FLASH
     - 权限：r (读) x (执行)
     - 起始地址：0x08000000 (STM32 Flash 固定起始地址)
     - 大小：64K (C8T6 标称 64KB，实际可能 128K，但写 64K 最安全) */
  FLASH (rx) : ORIGIN = 0x08000000, LENGTH = 64K

  /* RAM 区域：
     - 名称：RAM
     - 权限：rw (读 写)
     - 起始地址：0x20000000 (STM32 RAM 固定起始地址)
     - 大小：20K (C8T6 的 RAM 大小) */
  RAM (rwx) : ORIGIN = 0x20000000, LENGTH = 20K
}

/* 2. 定义栈和堆的大小 (Stack & Heap) */
/* 栈 (Stack)：用于函数调用、局部变量。设大一点防止溢出 */
_Min_Stack_Size = 0x400;      /* 1KB (默认值，可根据需要调大) */

/* 堆 (Heap)：用于 malloc 动态内存分配。嵌入式通常不用，设小一点 */
_Min_Heap_Size = 0x200;       /* 512 Bytes */

/* 3. 定义段 (SECTIONS) */
/* 告诉链接器：把编译出来的各种代码块，放到上面定义的 MEMORY 里 */
SECTIONS
{
  /* --- 中断向量表 (必须放在 Flash 最开头) --- */
  .isr_vector :
  {
    . = ALIGN(4);             /* 4 字节对齐 (硬件要求) */
    KEEP(*(.isr_vector))      /* 强制保留中断向量表，不要被优化掉 */
    . = ALIGN(4);
  } >FLASH                      /* 放到 FLASH 区域 */

  /* --- 代码段 (普通程序代码) --- */
  .text :
  {
    . = ALIGN(4);
    *(.text)                  /* 所有 .text 段 */
    *(.text*)                 /* 所有以 .text 开头的段 */
    *(.rodata)                /* 只读数据 (如 const 变量) */
    *(.rodata*)               /* 所有以 .rodata 开头的段 */
    . = ALIGN(4);
    _etext = .;               /* 记录代码结束地址 */
  } >FLASH

  /* --- 初始化数据段 (有初值的全局变量) --- */
  /* 存放在 Flash 中，运行前复制到 RAM */
  _sidata = LOADADDR(.data);  /* 记录在 Flash 中的加载地址 */
  .data :
  {
    . = ALIGN(4);
    _sdata = .;               /* 记录 RAM 中数据段起始地址 */
    *(.data)                  /* 所有 .data 段 */
    *(.data*)                 /* 所有以 .data 开头的段 */
    . = ALIGN(4);
    _edata = .;               /* 记录 RAM 中数据段结束地址 */
  } >RAM AT> FLASH              /* 运行在 RAM，但存储在 Flash */

  /* --- 未初始化数据段 (初值为 0 的全局变量) --- */
  .bss :
  {
    . = ALIGN(4);
    _sbss = .;                /* 记录 BSS 段起始地址 */
    __bss_start__ = _sbss;    /* 兼容符号 */
    *(.bss)                   /* 所有 .bss 段 */
    *(.bss*)                  /* 所有以 .bss 开头的段 */
    *(COMMON)                 /* 公共变量 */
    . = ALIGN(4);
    _ebss = .;                /* 记录 BSS 段结束地址 */
    _end = .;
    __bss_end__ = _ebss;      /* 兼容符号 */
  } >RAM

  /* --- 栈 (Stack) --- */
  /* 放在 RAM 的最高地址，向下生长 */
  ._user_stack :
  {
    . = ALIGN(8);
    . = . + _Min_Stack_Size;  /* 分配栈空间 */
    . = ALIGN(8);
    _estack = .;              /* 栈顶地址 (启动文件会用到这个符号) */
  } >RAM

  /* --- 堆 (Heap) --- */
  /* 放在 BSS 段之后 */
  ._user_heap :
  {
    . = ALIGN(8);
    . = . + _Min_Heap_Size;   /* 分配堆空间 */
    . = ALIGN(8);
    _eheap = .;
  } >RAM

  /* 丢弃不需要的段 (如调试信息) */
  /DISCARD/ :
  {
    libc.a ( * )
    libm.a ( * )
    libgcc.a ( * )
  }
}
