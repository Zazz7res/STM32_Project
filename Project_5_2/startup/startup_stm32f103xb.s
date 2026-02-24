.syntax unified
.cpu cortex-m3
.thumb

/* ⚠️ 关键：向量表段定义 - 确保放在 Flash 起始位置 */
.section .isr_vector,"a",%progbits
.type g_pfnVectors, %object
.align 2
.globl  g_pfnVectors

g_pfnVectors:
    /* ⚠️ 修复：直接使用链接脚本定义的 _estack 符号 */
    .word   _estack                /* 初始 MSP (链接脚本中定义为 RAM 顶部) */
    .word   Reset_Handler          /* 复位中断 */
    .word   NMI_Handler
    .word   HardFault_Handler
    .word   MemManage_Handler
    .word   BusFault_Handler
    .word   UsageFault_Handler
    .word   0
    .word   0
    .word   0
    .word   0
    .word   SVC_Handler
    .word   DebugMon_Handler
    .word   0
    .word   PendSV_Handler
    .word   SysTick_Handler

    /* 外部中断 (STM32F103 Medium Density) */
    .word   WWDG_IRQHandler
    .word   PVD_IRQHandler
    .word   TAMPER_IRQHandler
    .word   RTC_IRQHandler
    .word   FLASH_IRQHandler
    .word   RCC_IRQHandler
    .word   EXTI0_IRQHandler
    .word   EXTI1_IRQHandler
    .word   EXTI2_IRQHandler
    .word   EXTI3_IRQHandler
    .word   EXTI4_IRQHandler
    .word   DMA1_Channel1_IRQHandler
    .word   DMA1_Channel2_IRQHandler
    .word   DMA1_Channel3_IRQHandler
    .word   DMA1_Channel4_IRQHandler
    .word   DMA1_Channel5_IRQHandler
    .word   DMA1_Channel6_IRQHandler
    .word   DMA1_Channel7_IRQHandler
    .word   ADC1_2_IRQHandler
    .word   USB_HP_CAN1_TX_IRQHandler
    .word   USB_LP_CAN1_RX0_IRQHandler
    .word   CAN1_RX1_IRQHandler
    .word   CAN1_SCE_IRQHandler
    .word   EXTI9_5_IRQHandler
    .word   TIM1_BRK_IRQHandler
    .word   TIM1_UP_IRQHandler
    .word   TIM1_TRG_COM_IRQHandler
    .word   TIM1_CC_IRQHandler
    .word   TIM2_IRQHandler
    .word   TIM3_IRQHandler
    .word   TIM4_IRQHandler
    .word   I2C1_EV_IRQHandler
    .word   I2C1_ER_IRQHandler
    .word   I2C2_EV_IRQHandler
    .word   I2C2_ER_IRQHandler
    .word   SPI1_IRQHandler
    .word   SPI2_IRQHandler
    .word   USART1_IRQHandler
    .word   USART2_IRQHandler
    .word   USART3_IRQHandler
    .word   EXTI15_10_IRQHandler
    .word   RTCAlarm_IRQHandler
    .word   USBWakeUp_IRQHandler
    /* 补全剩余向量，确保 256 字节 */
    .word   0
    .word   0
    .word   0
    .word   0
    .word   0

.size g_pfnVectors, .-g_pfnVectors

.section .text.Reset_Handler
.weak   Reset_Handler
.type   Reset_Handler, %function
Reset_Handler:
    /* 栈指针已由硬件自动加载 _estack，无需软件再次设置 */
    ldr     r0, =SystemInit
    blx     r0
    ldr     r0, =_sdata
    ldr     r1, =_edata
    ldr     r2, =_sidata
    movs    r3, #0
    b       LoopCopyDataInit
CopyDataInit:
    ldr     r4, [r2, r3]
    str     r4, [r0, r3]
    adds    r3, r3, #4
LoopCopyDataInit:
    adds    r4, r0, r3
    cmp     r4, r1
    bcc     CopyDataInit
    ldr     r2, =_sbss
    b       LoopFillZerobss
FillZerobss:
    movs    r3, #0
    str     r3, [r2], #4
LoopFillZerobss:
    ldr     r3, =_ebss
    cmp     r2, r3
    bcc     FillZerobss
    bl      main
    bx      lr
.size Reset_Handler, .-Reset_Handler

.macro  DEF_WEAK handler
.weak   \handler
.thumb_set \handler, Default_Handler
.endm

DEF_WEAK NMI_Handler
DEF_WEAK HardFault_Handler
DEF_WEAK MemManage_Handler
DEF_WEAK BusFault_Handler
DEF_WEAK UsageFault_Handler
DEF_WEAK SVC_Handler
DEF_WEAK DebugMon_Handler
DEF_WEAK PendSV_Handler
DEF_WEAK SysTick_Handler
DEF_WEAK WWDG_IRQHandler
DEF_WEAK PVD_IRQHandler
DEF_WEAK TAMPER_IRQHandler
DEF_WEAK RTC_IRQHandler
DEF_WEAK FLASH_IRQHandler
DEF_WEAK RCC_IRQHandler
DEF_WEAK EXTI0_IRQHandler
DEF_WEAK EXTI1_IRQHandler
DEF_WEAK EXTI2_IRQHandler
DEF_WEAK EXTI3_IRQHandler
DEF_WEAK EXTI4_IRQHandler
DEF_WEAK DMA1_Channel1_IRQHandler
DEF_WEAK DMA1_Channel2_IRQHandler
DEF_WEAK DMA1_Channel3_IRQHandler
DEF_WEAK DMA1_Channel4_IRQHandler
DEF_WEAK DMA1_Channel5_IRQHandler
DEF_WEAK DMA1_Channel6_IRQHandler
DEF_WEAK DMA1_Channel7_IRQHandler
DEF_WEAK ADC1_2_IRQHandler
DEF_WEAK USB_HP_CAN1_TX_IRQHandler
DEF_WEAK USB_LP_CAN1_RX0_IRQHandler
DEF_WEAK CAN1_RX1_IRQHandler
DEF_WEAK CAN1_SCE_IRQHandler
DEF_WEAK EXTI9_5_IRQHandler
DEF_WEAK TIM1_BRK_IRQHandler
DEF_WEAK TIM1_UP_IRQHandler
DEF_WEAK TIM1_TRG_COM_IRQHandler
DEF_WEAK TIM1_CC_IRQHandler
DEF_WEAK TIM2_IRQHandler
DEF_WEAK TIM3_IRQHandler
DEF_WEAK TIM4_IRQHandler
DEF_WEAK I2C1_EV_IRQHandler
DEF_WEAK I2C1_ER_IRQHandler
DEF_WEAK I2C2_EV_IRQHandler
DEF_WEAK I2C2_ER_IRQHandler
DEF_WEAK SPI1_IRQHandler
DEF_WEAK SPI2_IRQHandler
DEF_WEAK USART1_IRQHandler
DEF_WEAK USART2_IRQHandler
DEF_WEAK USART3_IRQHandler
DEF_WEAK EXTI15_10_IRQHandler
DEF_WEAK RTCAlarm_IRQHandler
DEF_WEAK USBWakeUp_IRQHandler

.section .text.Default_Handler,"ax",%progbits
Default_Handler:
Infinite_Loop:
    b       Infinite_Loop
.size Default_Handler, .-Default_Handler
.end
