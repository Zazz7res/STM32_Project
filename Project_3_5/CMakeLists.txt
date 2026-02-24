cmake_minimum_required(VERSION 3.15)
project(STM32_OLED_Display C ASM)  # ← 项目名称修改

# 芯片宏定义（必须！）
add_definitions(
    -DUSE_STDPERIPH_DRIVER
    -DSTM32F10X_MD          # Medium Density - STM32F103C8T6
    -DHSE_VALUE=8000000     # 蓝丸晶振 8MHz
)

# 包含目录（指向所有头文件所在位置）
include_directories(
    ${CMAKE_SOURCE_DIR}/src
    ${CMAKE_SOURCE_DIR}/src/Hardware
    ${CMAKE_SOURCE_DIR}/src/System
    ${CMAKE_SOURCE_DIR}/src/Library
)

# 源文件列表（精准匹配 4-1 项目需求）
set(SOURCES
    # 启动文件
    ${CMAKE_SOURCE_DIR}/startup_stm32f10x_md_gcc.s

    # 核心系统文件
    ${CMAKE_SOURCE_DIR}/src/main.c
    ${CMAKE_SOURCE_DIR}/src/system_stm32f10x.c
    ${CMAKE_SOURCE_DIR}/src/core_cm3.c
    ${CMAKE_SOURCE_DIR}/src/stm32f10x_it.c

    # 标准外设库（关键：I2C 必须包含！FLASH 不能丢！）
    ${CMAKE_SOURCE_DIR}/src/Library/misc.c
    ${CMAKE_SOURCE_DIR}/src/Library/stm32f10x_gpio.c
    ${CMAKE_SOURCE_DIR}/src/Library/stm32f10x_rcc.c
    ${CMAKE_SOURCE_DIR}/src/Library/stm32f10x_flash.c   # ← system_stm32f10x.c 依赖
    ${CMAKE_SOURCE_DIR}/src/Library/stm32f10x_i2c.c     # ← OLED 常用 I2C 接口（必须！）

    # Hardware 驱动（OLED 核心 + 辅助模块）
    ${CMAKE_SOURCE_DIR}/src/Hardware/OLED.c
    ${CMAKE_SOURCE_DIR}/src/Hardware/LED.c    # 可能被 OLED 初始化调用
    ${CMAKE_SOURCE_DIR}/src/Hardware/Key.c    # 原项目存在，保留避免依赖缺失

    # 系统工具
    ${CMAKE_SOURCE_DIR}/src/System/Delay.c
)

# 创建可执行文件
add_executable(${PROJECT_NAME}.elf ${SOURCES})

# 链接脚本
set(LINKER_SCRIPT ${CMAKE_SOURCE_DIR}/STM32F103C8T6.ld)
target_link_options(${PROJECT_NAME}.elf PRIVATE
    -T ${LINKER_SCRIPT}
    -Wl,--gc-sections  # ← 自动剔除未使用代码（精简 .bin 大小）
    --specs=nosys.specs
)

# 生成 bin/hex + 显示大小
add_custom_command(TARGET ${PROJECT_NAME}.elf POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary ${PROJECT_NAME}.elf ${PROJECT_NAME}.bin
    COMMAND ${CMAKE_SIZE_UTIL} ${PROJECT_NAME}.elf
    COMMENT "✓ 生成 BIN: ${PROJECT_NAME}.bin | 大小: "
)
