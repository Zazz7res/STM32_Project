#include "stm32f10x.h"                  // Device header
#include "Delay.h"

int main(void)
{
	/* === 防砖保险（3行，必须在函数内部）=== */
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_AFIO, ENABLE);	// 使能AFIO时钟
	GPIO_PinRemapConfig(GPIO_Remap_SWJ_JTAGDisable, ENABLE); // 仅禁用JTAG，保留SWD
	/* ====================================== */
	
	/*开启时钟*/
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOB, ENABLE);	//开启GPIOB的时钟
	
	/*GPIO初始化*/
	GPIO_InitTypeDef GPIO_InitStructure;					//定义结构体变量
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;		//GPIO模式，赋值为推挽输出模式
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_12;				//GPIO引脚，赋值为第12号引脚
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;		//GPIO速度，赋值为50MHz
	GPIO_Init(GPIOB, &GPIO_InitStructure);					//初始化GPIOB
	
	/*主循环*/
	while (1)
	{
		GPIO_ResetBits(GPIOB, GPIO_Pin_12);		//PB12低电平，蜂鸣器鸣叫
		Delay_ms(100);
		GPIO_SetBits(GPIOB, GPIO_Pin_12);		//PB12高电平，蜂鸣器停止
		Delay_ms(100);
		GPIO_ResetBits(GPIOB, GPIO_Pin_12);
		Delay_ms(100);
		GPIO_SetBits(GPIOB, GPIO_Pin_12);
		Delay_ms(700);
	}
}
