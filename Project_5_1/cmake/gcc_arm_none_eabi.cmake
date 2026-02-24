# ~/STM32_Project/Project_5_1/cmake/gcc_arm_none_eabi.cmake
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

# 指定交叉编译工具链前缀
set(TOOLCHAIN_PREFIX arm-none-eabi-)

set(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}gcc)
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}g++)
set(CMAKE_ASM_COMPILER ${TOOLCHAIN_PREFIX}gcc)
set(CMAKE_OBJCOPY ${TOOLCHAIN_PREFIX}objcopy)
set(CMAKE_SIZE ${TOOLCHAIN_PREFIX}size)

# 关键：规避 CMake 的链接测试错误
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# 编译标志 (已移除 -mfpu=none)
# Cortex-M3 没有 FPU，-mcpu=cortex-m3 已隐含此信息，-mfloat-abi=soft 确保不使用硬件浮点指令
set(COMMON_FLAGS "-mcpu=cortex-m3 -mthumb -mfloat-abi=soft")
set(COMMON_FLAGS "${COMMON_FLAGS} -ffunction-sections -fdata-sections")
set(COMMON_FLAGS "${COMMON_FLAGS} -Wall -Wextra -Wimplicit-function-declaration")

# 调试/发布配置
set(CMAKE_C_FLAGS "${COMMON_FLAGS} -g -gdwarf-2")
set(CMAKE_CXX_FLAGS "${COMMON_FLAGS} -g -gdwarf-2")
set(CMAKE_ASM_FLAGS "${COMMON_FLAGS} -x assembler-with-cpp")

# 链接标志
set(CMAKE_EXE_LINKER_FLAGS "${COMMON_FLAGS} -nostartfiles -Wl,--gc-sections")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-Map=${CMAKE_PROJECT_NAME}.map")

# 查找根目录
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
