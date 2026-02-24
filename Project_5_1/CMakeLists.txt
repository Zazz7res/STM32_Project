# ~/STM32_Project/Project_5_1/CMakeLists.txt
cmake_minimum_required(VERSION 3.20)
project(STM32_Project_5_1 C ASM)

# 芯片定义
set(CHIP_DEF "STM32F10X_MD")
set(USE_STDPERIPH_DRIVER "USE_STDPERIPH_DRIVER")

# 收集源文件
# 1. 启动文件
set(STARTUP_SRC startup/startup_stm32f10x_md.S)

# 2. 核心文件 (CMSIS + System)
file(GLOB CORE_SRC src/core/*.c)

# 3. 标准库文件
file(GLOB PERIPHERAL_SRC src/peripheral/*.c)

# 4. 用户驱动 (Hardware + System)
file(GLOB DRIVERS_SRC src/drivers/*.c)

# 5. 应用层 (User)
file(GLOB APP_SRC src/app/*.c)

set(SOURCES ${STARTUP_SRC} ${CORE_SRC} ${PERIPHERAL_SRC} ${DRIVERS_SRC} ${APP_SRC})

# 包含目录
include_directories(
    src/core
    src/peripheral/inc
    src/drivers
    src/app
)

# 添加可执行文件
add_executable(${PROJECT_NAME}.elf ${SOURCES})

# 编译定义
target_compile_definitions(${PROJECT_NAME}.elf PRIVATE
    ${CHIP_DEF}
    ${USE_STDPERIPH_DRIVER}
    SYSCLK_FREQ_72MHz  # <--- 添加这一行，确保系统时钟配置为 72MHz
)

# 链接脚本
target_link_options(${PROJECT_NAME}.elf PRIVATE
    -T${CMAKE_SOURCE_DIR}/linker/STM32F103C8Tx.ld
)

# 生成 bin/hex 文件
add_custom_command(TARGET ${PROJECT_NAME}.elf POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:${PROJECT_NAME}.elf> ${PROJECT_NAME}.hex
    COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${PROJECT_NAME}.elf> ${PROJECT_NAME}.bin
    COMMAND ${CMAKE_SIZE} $<TARGET_FILE:${PROJECT_NAME}.elf>
    COMMENT "Building ${PROJECT_NAME}.hex and ${PROJECT_NAME}.bin"
)
