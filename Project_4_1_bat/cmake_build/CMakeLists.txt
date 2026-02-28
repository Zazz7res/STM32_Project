cmake_minimum_required(VERSION 3.15)
project(OLED_Display VERSION 1.0 LANGUAGES C ASM)
set(SOURCES
    startup_stm32f10x_md_gcc.s
    ../Start/core_cm3.c
    ../Start/system_stm32f10x.c
    ../Library/misc.c
    ../Library/stm32f10x_gpio.c
    ../Library/stm32f10x_rcc.c
    ../Library/stm32f10x_i2c.c
    ../Library/stm32f10x_spi.c
    ../Library/stm32f10x_tim.c
    ../Library/stm32f10x_usart.c
    ../System/Delay.c
    ../Hardware/LED.c
    ../Hardware/Key.c
    ../Hardware/OLED.c
    ../User/main.c
    ../User/stm32f10x_it.c
    syscalls.c
)
add_executable(${PROJECT_NAME}.elf ${SOURCES})
target_include_directories(${PROJECT_NAME}.elf PRIVATE
    ../Start ../Library ../System ../Hardware ../User
)
target_link_options(${PROJECT_NAME}.elf PRIVATE
    -T "${CMAKE_SOURCE_DIR}/ldscripts/STM32F103C8T6.ld"
    -Wl,-Map=${PROJECT_NAME}.map
)
add_custom_target(${PROJECT_NAME}.bin ALL
    COMMAND ${CMAKE_OBJCOPY} -O binary ${PROJECT_NAME}.elf ${PROJECT_NAME}.bin
    DEPENDS ${PROJECT_NAME}.elf
)
add_custom_target(${PROJECT_NAME}.hex ALL
    COMMAND ${CMAKE_OBJCOPY} -O ihex ${PROJECT_NAME}.elf ${PROJECT_NAME}.hex
    DEPENDS ${PROJECT_NAME}.elf
)
add_custom_command(TARGET ${PROJECT_NAME}.elf POST_BUILD
    COMMAND ${CMAKE_SIZE_UTIL} ${PROJECT_NAME}.elf
    COMMENT "Memory usage:"
)
