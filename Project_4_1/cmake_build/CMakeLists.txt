cmake_minimum_required(VERSION 3.20)
project(OLED_Display C ASM)

set(CMAKE_C_STANDARD 99)

# 源文件列表
set(SOURCES
    ../src/Start/system_stm32f10x.c
    ../src/Start/core_cm3.c
    startup_stm32f10x_md_gcc.s
    ../src/System/Delay.c
    ../src/Hardware/OLED.c
    ../src/Hardware/LED.c
    ../src/Hardware/Key.c
    ../src/User/main.c
    ../src/User/stm32f10x_it.c
    ../src/Library/misc.c
    ../src/Library/stm32f10x_rcc.c
    ../src/Library/stm32f10x_gpio.c
    ../src/Library/stm32f10x_i2c.c
    syscalls.c
)

add_executable(${PROJECT_NAME}.elf ${SOURCES})

# 头文件路径
target_include_directories(${PROJECT_NAME}.elf PRIVATE
    ../src/Start
    ../src/System
    ../src/Hardware
    ../src/User
    ../src/Library
)

# 宏定义
target_compile_definitions(${PROJECT_NAME}.elf PRIVATE
    USE_STDPERIPH_DRIVER
    STM32F10X_MD
)

# 链接脚本
set_target_properties(${PROJECT_NAME}.elf PROPERTIES
    LINK_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/ldscripts/STM32F103C8T6.ld
    LINK_FLAGS "-T${CMAKE_CURRENT_SOURCE_DIR}/ldscripts/STM32F103C8T6.ld"
)

# 生成 .bin 文件
add_custom_command(TARGET ${PROJECT_NAME}.elf POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary ${PROJECT_NAME}.elf ${PROJECT_NAME}.bin
)
