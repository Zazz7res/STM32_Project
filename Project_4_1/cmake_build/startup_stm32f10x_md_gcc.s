.syntax unified
.cpu cortex-m3
.fpu softvfp
.thumb

.global g_pfnVectors
.global Default_Handler
.global Reset_Handler

.section .isr_vector,"a",%progbits
.type g_pfnVectors, %object
.size g_pfnVectors, .-g_pfnVectors

g_pfnVectors:
  .word _estack
  .word Reset_Handler
  .word NMI_Handler
  .word HardFault_Handler
  .word MemManage_Handler
  .word BusFault_Handler
  .word UsageFault_Handler
  .word 0
  .word 0
  .word 0
  .word 0
  .word SVC_Handler
  .word DebugMon_Handler
  .word 0
  .word PendSV_Handler
  .word SysTick_Handler
  .word WWDG_IRQHandler
  .word PVD_IRQHandler
  .word TAMPER_IRQHandler
  .word RTC_IRQHandler
  .word FLASH_IRQHandler
  .word RCC_IRQHandler
  .word EXTI0_IRQHandler
  .word EXTI1_IRQHandler
  .word EXTI2_IRQHandler
  .word EXTI3_IRQHandler
  .word EXTI4_IRQHandler
  .word DMA1_Channel1_IRQHandler
  .word DMA1_Channel2_IRQHandler
  .word DMA1_Channel3_IRQHandler
  .word DMA1_Channel4_IRQHandler
  .word DMA1_Channel5_IRQHandler
  .word DMA1_Channel6_IRQHandler
  .word DMA1_Channel7_IRQHandler
  .word ADC1_2_IRQHandler
  .word USB_HP_CAN1_TX_IRQHandler
  .word USB_LP_CAN1_RX0_IRQHandler
  .word CAN1_RX1_IRQHandler
  .word CAN1_SCE_IRQHandler
  .word EXTI9_5_IRQHandler
  .word TIM1_BRK_IRQHandler
  .word TIM1_UP_IRQHandler
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
  .word TIM8_BRK_IRQHandler
  .word TIM8_UP_IRQHandler
  .word TIM8_TRG_COM_IRQHandler
  .word TIM8_CC_IRQHandler
  .word ADC3_IRQHandler
  .word FSMC_IRQHandler
  .word SDIO_IRQHandler
  .word TIM5_IRQHandler
  .word SPI3_IRQHandler
  .word UART4_IRQHandler
  .word UART5_IRQHandler
  .word TIM6_IRQHandler
  .word TIM7_IRQHandler
  .word DMA2_Channel1_IRQHandler
  .word DMA2_Channel2_IRQHandler
  .word DMA2_Channel3_IRQHandler
  .word DMA2_Channel4_5_IRQHandler

.section .text.Reset_Handler
.type Reset_Handler, %function
Reset_Handler:
  ldr   r0, =_estack
  mov   sp, r0
  bl    SystemInit
  bl    main
  bx    lr

.section .text.Default_Handler
.type Default_Handler, %function
Default_Handler:
  b     .

.macro IRQ_HANDLER name
  .section .text.\name
  .weak \name
  .type \name, %function
\name:
  b     Default_Handler
.endm

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
IRQ_HANDLER TIM8_BRK_IRQHandler
IRQ_HANDLER TIM8_UP_IRQHandler
IRQ_HANDLER TIM8_TRG_COM_IRQHandler
IRQ_HANDLER TIM8_CC_IRQHandler
IRQ_HANDLER ADC3_IRQHandler
IRQ_HANDLER FSMC_IRQHandler
IRQ_HANDLER SDIO_IRQHandler
IRQ_HANDLER TIM5_IRQHandler
IRQ_HANDLER SPI3_IRQHandler
IRQ_HANDLER UART4_IRQHandler
IRQ_HANDLER UART5_IRQHandler
IRQ_HANDLER TIM6_IRQHandler
IRQ_HANDLER TIM7_IRQHandler
IRQ_HANDLER DMA2_Channel1_IRQHandler
IRQ_HANDLER DMA2_Channel2_IRQHandler
IRQ_HANDLER DMA2_Channel3_IRQHandler
IRQ_HANDLER DMA2_Channel4_5_IRQHandler

.end
