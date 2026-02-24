#include "Delay.h"
#include "Encoder.h"
#include "OLED.h"
#include "stm32f10x.h"

int16_t Num;

int main(void) {
  /* =========================================================================
     ⚠️ 防砖代码：禁用 USB 引脚上拉 (PA11/PA12)
     防止 USB 引脚拉高导致无法烧录
     =========================================================================
   */
  RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);
  GPIO_InitTypeDef GPIO_InitStructure;
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_11 | GPIO_Pin_12;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
  GPIO_Init(GPIOA, &GPIO_InitStructure);
  GPIO_ResetBits(GPIOA, GPIO_Pin_11 | GPIO_Pin_12);
  /* =========================================================================
   */

  /* 模块初始化 */
  OLED_Init();
  Encoder_Init();

  /* 显示静态字符串 */
  OLED_ShowString(1, 1, "Num:");

  while (1) {
    Num += Encoder_Get();
    OLED_ShowSignedNum(1, 5, Num, 5);
  }
}
