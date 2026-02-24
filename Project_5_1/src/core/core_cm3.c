/* ~/STM32_Project/Project_5_1/src/core/core_cm3.c */
#include "stm32f10x.h" /* 必须先包含此文件，以定义 IRQn_Type 等 */
#include <stdint.h>

/* 修复 GCC 14+ 对 naked 函数参数的严格检查 */
#if defined(__GNUC__)

__attribute__((naked)) uint32_t __get_MSP(void) {
  __asm volatile("mrs r0, msp\n"
                 "bx lr\n");
}

__attribute__((naked)) void __set_MSP(uint32_t topOfMainStack) {
  (void)topOfMainStack; /* 告诉编译器参数已使用，消除警告 */
  __asm volatile("msr msp, r0\n"
                 "bx lr\n");
}

__attribute__((naked)) uint32_t __get_PSP(void) {
  __asm volatile("mrs r0, psp\n"
                 "bx lr\n");
}

__attribute__((naked)) void __set_PSP(uint32_t topOfProcStack) {
  (void)topOfProcStack;
  __asm volatile("msr psp, r0\n"
                 "bx lr\n");
}

__attribute__((naked)) uint32_t __get_CONTROL(void) {
  __asm volatile("mrs r0, control\n"
                 "bx lr\n");
}

__attribute__((naked)) void __set_CONTROL(uint32_t control) {
  (void)control;
  __asm volatile("msr control, r0\n"
                 "bx lr\n");
}

#endif /* __GNUC__ */
