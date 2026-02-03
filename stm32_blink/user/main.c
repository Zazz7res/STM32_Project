#include "stm32f10x.h"

int main(void)
{
  RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOC, ENABLE);
  
  GPIO_InitTypeDef GPIO_InitStructure;
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_13;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_2MHz;
  GPIO_Init(GPIOC, &GPIO_InitStructure);
  
  while (1)
  {
    GPIO_ResetBits(GPIOC, GPIO_Pin_13);  // 低电平点亮
    for(volatile uint32_t i = 0; i < 1000000; i++);  // 100万次 ≈ 0.2秒
    
    GPIO_SetBits(GPIOC, GPIO_Pin_13);    // 高电平熄灭
    for(volatile uint32_t i = 0; i < 1000000; i++);
  }
}
