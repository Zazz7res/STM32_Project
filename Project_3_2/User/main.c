#include "stm32f10x.h"                  // Device header
#include "Delay.h"

int main(void)
{
	/* === 防砖保险（3行，必须放在函数内部）=== */
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_AFIO, ENABLE);	// 使能AFIO时钟
	GPIO_PinRemapConfig(GPIO_Remap_SWJ_JTAGDisable, ENABLE); // 仅禁用JTAG，保留SWD (PA13/PA14)
	/* ========================================= */
	
	/*开启时钟*/
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);	//开启GPIOA的时钟
	
	/*GPIO初始化*/
	GPIO_InitTypeDef GPIO_InitStructure;					//定义结构体变量
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;		//GPIO模式，赋值为推挽输出模式
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_All;				//GPIO引脚，赋值为所有引脚
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;		//GPIO速度，赋值为50MHz
	GPIO_Init(GPIOA, &GPIO_InitStructure);					//将赋值后的构体变量传递给GPIO_Init函数
	
	/*主循环*/
	while (1)
	{
		GPIO_Write(GPIOA, ~0x0001);	//PA0低电平亮
		Delay_ms(100);
		GPIO_Write(GPIOA, ~0x0002);	//PA1低电平亮
		Delay_ms(100);
		GPIO_Write(GPIOA, ~0x0004);	//PA2低电平亮
		Delay_ms(100);
		GPIO_Write(GPIOA, ~0x0008);	//PA3低电平亮
		Delay_ms(100);
		GPIO_Write(GPIOA, ~0x0010);	//PA4低电平亮
		Delay_ms(100);
		GPIO_Write(GPIOA, ~0x0020);	//PA5低电平亮
		Delay_ms(100);
		GPIO_Write(GPIOA, ~0x0040);	//PA6低电平亮
		Delay_ms(100);
		GPIO_Write(GPIOA, ~0x0080);	//PA7低电平亮
		Delay_ms(100);
	}
}
