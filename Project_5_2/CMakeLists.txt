cmake_minimum_required(VERSION 3.20)
project(STM32_Rotary_Encoder C ASM)

# 芯片宏定义 (Medium Density)
add_compile_definitions(STM32F10X_MD USE_STDPERIPH_DRIVER)

# 包含目录
include_directories(
    ${CMAKE_SOURCE_DIR}/Start
    ${CMAKE_SOURCE_DIR}/Library
    ${CMAKE_SOURCE_DIR}/User
    ${CMAKE_SOURCE_DIR}/System
    ${CMAKE_SOURCE_DIR}/Hardware
)

# 源文件
file(GLOB USER_SOURCES "User/*.c" "Hardware/*.c" "System/*.c")
set(STDPERIPH_SOURCES
    Library/misc.c
    Library/stm32f10x_rcc.c
    Library/stm32f10x_gpio.c
    Library/stm32f10x_exti.c
    Library/stm32f10x_spi.c
    Library/stm32f10x_flash.c
    Library/stm32f10x_pwr.c
    Library/stm32f10x_dbgmcu.c
)
set(SYSTEM_SOURCES Start/system_stm32f10x.c)
set(STARTUP_FILE ${CMAKE_SOURCE_DIR}/startup/startup_stm32f103xb.s)

set(ALL_SOURCES ${USER_SOURCES} ${STDPERIPH_SOURCES} ${SYSTEM_SOURCES} ${STARTUP_FILE})

add_executable(${PROJECT_NAME}.elf ${ALL_SOURCES})

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -ffunction-sections -fdata-sections")
set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} -x assembler-with-cpp")

# 生成 bin/hex
add_custom_command(TARGET ${PROJECT_NAME}.elf POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:${PROJECT_NAME}.elf> ${PROJECT_NAME}.hex
    COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${PROJECT_NAME}.elf> ${PROJECT_NAME}.bin
    COMMAND ${CMAKE_SIZE} $<TARGET_FILE:${PROJECT_NAME}.elf>
)
