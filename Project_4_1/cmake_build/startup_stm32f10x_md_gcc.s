/* ==========================================================================
   文件名：startup_stm32f10x_md_gcc.s
   作用：STM32F103 系列启动文件 (GCC 格式)
   芯片：STM32F103C8T6 (Medium Density, MD)
   注意：必须使用 Unix 换行符 (LF)，不能用 Windows 换行符 (CRLF)
   ========================================================================== */

.syntax unified           @ 统一汇编语法 (支持 ARM 和 Thumb 混合)
.cpu cortex-m3            @ 指定 CPU 为 Cortex-M3
.fpu softvfp              @ 浮点单元：软件模拟 (M3 无硬件 FPU)
.thumb                    @ 使用 Thumb 指令集 (代码更紧凑，M3 必须)

.global g_pfnVectors      @ 导出向量表符号 (供链接脚本使用)
.global Default_Handler   @ 导出默认中断处理函数

/* ==========================================================================
   中断向量表 (Vector Table)
   必须放在 Flash 起始地址 (0x08000000)，由链接脚本保证
   前两项必须是：栈顶地址、复位中断入口
   ========================================================================== */
.section .isr_vector,"a",%progbits
.type g_pfnVectors, %object
.size g_pfnVectors, .-g_pfnVectors

g_pfnVectors:
    .word _estack              @ 1. 栈顶地址 (由链接脚本 _estack 定义)
    .word Reset_Handler        @ 2. 复位中断入口 (芯片上电后执行的第一段代码)
    .word NMI_Handler          @ 3. 不可屏蔽中断
    .word HardFault_Handler    @ 4. 硬故障中断
    .word MemManage_Handler    @ 5. 内存管理中断
    .word BusFault_Handler     @ 6. 总线故障中断
    .word UsageFault_Handler   @ 7. 用法故障中断
    .word 0                    @ 8. 保留
    .word 0                    @ 9. 保留
    .word 0                    @ 10. 保留
    .word 0                    @ 11. 保留
    .word SVC_Handler          @ 12. 系统服务调用
    .word DebugMon_Handler     @ 13. 调试监控
    .word 0                    @ 14. 保留
    .word PendSV_Handler       @ 15. 可挂起系统服务
    .word SysTick_Handler      @ 16. 系统滴答定时器

    /* 外部中断 (IRQn) - STM32F103 MD 系列 */
    .word WWDG_IRQHandler      @ 窗口看门狗
    .word PVD_IRQHandler       @ PVD 通过 EXTI 线检测
    .word TAMPER_IRQHandler    @ 篡改
    .word RTC_IRQHandler       @ RTC
    .word FLASH_IRQHandler     @ Flash
    .word RCC_IRQHandler       @ RCC
    .word EXTI0_IRQHandler     @ EXTI 线 0
    .word EXTI1_IRQHandler     @ EXTI 线 1
    .word EXTI2_IRQHandler     @ EXTI 线 2
    .word EXTI3_IRQHandler     @ EXTI 线 3
    .word EXTI4_IRQHandler     @ EXTI 线 4
    .word DMA1_Channel1_IRQHandler
    .word DMA1_Channel2_IRQHandler
    .word DMA1_Channel3_IRQHandler
    .word DMA1_Channel4_IRQHandler
    .word DMA1_Channel5_IRQHandler
    .word DMA1_Channel6_IRQHandler
    .word DMA1_Channel7_IRQHandler
    .word ADC1_2_IRQHandler    @ ADC1 和 ADC2
    .word USB_HP_CAN1_TX_IRQHandler
    .word USB_LP_CAN1_RX0_IRQHandler
    .word CAN1_RX1_IRQHandler
    .word CAN1_SCE_IRQHandler
    .word EXTI9_5_IRQHandler   @ EXTI 线 9-5
    .word TIM1_BRK_IRQHandler  @ TIM1 _break
    .word TIM1_UP_IRQHandler   @ TIM1_UP
    .word TIM1_TRG_COM_IRQHandler
    .word TIM1_CC_IRQHandler
    .word TIM2_IRQHandler
    .word TIM3_IRQHandler
    .word TIM4_IRQHandler
    .word I2C1_EV_IRQHandler
    .word I2C1_ER_IRQHandler
    .word I2C2_EV_IRQHandler
    .word I2C2_ER_IRQHandler
    .word SPI1_IRQHandler
    .word SPI2_IRQHandler
    .word USART1_IRQHandler
    .word USART2_IRQHandler
    .word USART3_IRQHandler
    .word EXTI15_10_IRQHandler
    .word RTCAlarm_IRQHandler
    .word USBWakeUp_IRQHandler

/* ==========================================================================
   默认中断处理函数 (Default_Handler)
   如果某个中断未单独实现，则跳转到这里 (死循环)
   ========================================================================== */
.section .text.Default_Handler,"ax",%progbits
Default_Handler:
Infinite_Loop:
    b Infinite_Loop            @ 死循环 (B 是无条件跳转)
.size Default_Handler, .-Default_Handler

/* ==========================================================================
   复位处理函数 (Reset_Handler)
   芯片上电后真正执行的第一段 C 代码入口
   ========================================================================== */
.section .text.Reset_Handler,"ax",%progbits
.type Reset_Handler, %function
Reset_Handler:
    @ 1. 初始化数据段 (.data)
    @ 将存储在 Flash 中的初始化数据复制到 RAM
    ldr r0, =_sidata           @ 源地址 (Flash 中 .data 的加载地址)
    ldr r1, =_sdata            @ 目的地址 (RAM 中 .data 起始地址)
    ldr r2, =_edata            @ 结束地址 (RAM 中 .data 结束地址)
    movs r3, #0                @ 计数器清零
    b LoopCopyDataInit         @ 跳转到复制循环

CopyDataInit:
    ldr r4, [r0, r3]           @ 从源地址读取数据
    str r4, [r1, r3]           @ 写入目的地址
    adds r3, r3, #4            @ 计数器 +4 (32 位数据)

LoopCopyDataInit:
    adds r4, r1, r3            @ 计算当前目的地址
    cmp r4, r2                 @ 比较是否到达结束地址
    bcc CopyDataInit           @ 如果小于，继续复制

    @ 2. 清零 BSS 段 (.bss)
    @ 将未初始化的全局变量清零
    ldr r2, =_sbss             @ BSS 起始地址
    ldr r4, =_ebss             @ BSS 结束地址
    movs r3, #0                @ 清零值
    b LoopFillZerobss

FillZerobss:
    str r3, [r2]               @ 写入 0
    adds r2, r2, #4            @ 地址 +4

LoopFillZerobss:
    cmp r2, r4                 @ 比较是否到达结束地址
    bcc FillZerobss            @ 如果小于，继续清零

    @ 3. 调用系统初始化函数 (SystemInit)
    @ 配置系统时钟 (由 C 代码实现)
    bl SystemInit

    @ 4. 跳转到主函数 (main)
    @ 程序正式进入用户代码
    bl main

    @ 5. 如果 main 返回 (不应该发生)，进入死循环
    b Infinite_Loop
.size Reset_Handler, .-Reset_Handler

/* ==========================================================================
   中断服务函数声明 (Weak 属性)
   允许用户在 C 代码中重写这些函数，否则使用 Default_Handler
   ========================================================================== */
.macro IRQ_HANDLER name
    .weak \name
    .set \name, Default_Handler
.endm

@ 为所有中断声明弱符号
IRQ_HANDLER NMI_Handler
IRQ_HANDLER HardFault_Handler
IRQ_HANDLER MemManage_Handler
IRQ_HANDLER BusFault_Handler
IRQ_HANDLER UsageFault_Handler
IRQ_HANDLER SVC_Handler
IRQ_HANDLER DebugMon_Handler
IRQ_HANDLER PendSV_Handler
IRQ_HANDLER SysTick_Handler
IRQ_HANDLER WWDG_IRQHandler
IRQ_HANDLER PVD_IRQHandler
IRQ_HANDLER TAMPER_IRQHandler
IRQ_HANDLER RTC_IRQHandler
IRQ_HANDLER FLASH_IRQHandler
IRQ_HANDLER RCC_IRQHandler
IRQ_HANDLER EXTI0_IRQHandler
IRQ_HANDLER EXTI1_IRQHandler
IRQ_HANDLER EXTI2_IRQHandler
IRQ_HANDLER EXTI3_IRQHandler
IRQ_HANDLER EXTI4_IRQHandler
IRQ_HANDLER DMA1_Channel1_IRQHandler
IRQ_HANDLER DMA1_Channel2_IRQHandler
IRQ_HANDLER DMA1_Channel3_IRQHandler
IRQ_HANDLER DMA1_Channel4_IRQHandler
IRQ_HANDLER DMA1_Channel5_IRQHandler
IRQ_HANDLER DMA1_Channel6_IRQHandler
IRQ_HANDLER DMA1_Channel7_IRQHandler
IRQ_HANDLER ADC1_2_IRQHandler
IRQ_HANDLER USB_HP_CAN1_TX_IRQHandler
IRQ_HANDLER USB_LP_CAN1_RX0_IRQHandler
IRQ_HANDLER CAN1_RX1_IRQHandler
IRQ_HANDLER CAN1_SCE_IRQHandler
IRQ_HANDLER EXTI9_5_IRQHandler
IRQ_HANDLER TIM1_BRK_IRQHandler
IRQ_HANDLER TIM1_UP_IRQHandler
IRQ_HANDLER TIM1_TRG_COM_IRQHandler
IRQ_HANDLER TIM1_CC_IRQHandler
IRQ_HANDLER TIM2_IRQHandler
IRQ_HANDLER TIM3_IRQHandler
IRQ_HANDLER TIM4_IRQHandler
IRQ_HANDLER I2C1_EV_IRQHandler
IRQ_HANDLER I2C1_ER_IRQHandler
IRQ_HANDLER I2C2_EV_IRQHandler
IRQ_HANDLER I2C2_ER_IRQHandler
IRQ_HANDLER SPI1_IRQHandler
IRQ_HANDLER SPI2_IRQHandler
IRQ_HANDLER USART1_IRQHandler
IRQ_HANDLER USART2_IRQHandler
IRQ_HANDLER USART3_IRQHandler
IRQ_HANDLER EXTI15_10_IRQHandler
IRQ_HANDLER RTCAlarm_IRQHandler
IRQ_HANDLER USBWakeUp_IRQHandler

.end                        @ 文件结束标记
