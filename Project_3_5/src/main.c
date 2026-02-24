// 文件位置: ~/STM32_Project/Project_3_5/src/main.c
#include "stm32f10x.h"
#include "Delay.h"
#include "Buzzer.h"
#include "LightSensor.h"

int main(void)
{
    /* === 防砖保险（3行，必须在函数开头）=== */
    RCC_APB2PeriphClockCmd(RCC_APB2Periph_AFIO, ENABLE);          // 使能AFIO时钟
    GPIO_PinRemapConfig(GPIO_Remap_SWJ_JTAGDisable, ENABLE);      // 仅禁用JTAG，保留SWD
    
    /* 模块初始化 */
    Buzzer_Init();          // PB12
    LightSensor_Init();     // PB13

    while (1)
    {
        // ✅ 逻辑修正：遮光(高电平1) → 蜂鸣器响；不遮光(低电平0) → 静音
        if (LightSensor_Get() == 1)  // 遮光输出高电平
        {
            Buzzer_ON();             // PB12拉低 → 蜂鸣器响
        }
        else
        {
            Buzzer_OFF();            // PB12拉高 → 静音
        }
    }
}
