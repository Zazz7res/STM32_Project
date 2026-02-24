/* ~/STM32_Project/Project_5_1/src/app/main.c */
#include "CountSensor.h"
#include "Delay.h"
#include "OLED.h"
#include "stm32f10x.h"

/* 防砖代码：禁用 USB 拉低 PA11/PA12 */
static void Disable_USB_DP_DM(void) {
  RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);
  GPIO_InitTypeDef GPIO_InitStructure;
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_11 | GPIO_Pin_12;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
  GPIO_Init(GPIOA, &GPIO_InitStructure);
  GPIO_ResetBits(GPIOA, GPIO_Pin_11 | GPIO_Pin_12);
}

int main(void) {
  /* 1. 防砖代码 (最优先执行) */
  Disable_USB_DP_DM();

  /* 2. 原有初始化 */
  /* Delay_init();  <-- 删除此行，Delay.c 中没有此函数，且 SysTick 已在
   * SystemInit 中配置 */

  OLED_Init();        // OLED 初始化
  CountSensor_Init(); // 计数传感器初始化

  /* 3. 原有业务逻辑 */
  OLED_ShowString(1, 1, "Count:");

  while (1) {
    OLED_ShowNum(1, 7, CountSensor_Get(), 5);
    Delay_ms(100);
  }
}
