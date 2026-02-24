# ============================================================================
# STM32F103C8T6 GCC 工具链文件 (修复 GCC 14+ 兼容性)
# ============================================================================

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

# ⚠️ 关键：必须在最前面设置，规避 CMake 的链接测试
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# 工具链前缀
set(TOOLCHAIN_PREFIX arm-none-eabi-)
set(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}gcc)
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}g++)
set(CMAKE_ASM_COMPILER ${TOOLCHAIN_PREFIX}gcc)
set(CMAKE_OBJCOPY ${TOOLCHAIN_PREFIX}objcopy)
set(CMAKE_SIZE ${TOOLCHAIN_PREFIX}size)

# ============================================================================
# CPU 配置 (Cortex-M3) - ⚠️ 移除 -mfpu=none (GCC 14+ 不识别)
# ============================================================================
set(CPU_FLAGS "-mcpu=cortex-m3 -mthumb -mfloat-abi=soft")

# C 编译 flags
set(CMAKE_C_FLAGS "${CPU_FLAGS} -Wall -ffunction-sections -fdata-sections" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_DEBUG "-g -O0" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_RELEASE "-O2" CACHE STRING "" FORCE)

# C++ 编译 flags
set(CMAKE_CXX_FLAGS "${CPU_FLAGS} -Wall -ffunction-sections -fdata-sections" CACHE STRING "" FORCE)

# ASM 编译 flags
set(CMAKE_ASM_FLAGS "${CPU_FLAGS} -x assembler-with-cpp" CACHE STRING "" FORCE)

# ============================================================================
# 链接 flags
# ============================================================================
set(LINKER_SCRIPT ${CMAKE_SOURCE_DIR}/cmake/STM32F103C8Tx_FLASH.ld)
set(CMAKE_EXE_LINKER_FLAGS 
    "${CPU_FLAGS} -nostartfiles -Wl,--gc-sections -T${LINKER_SCRIPT}" 
    CACHE STRING "" FORCE
)

# ============================================================================
# 查找路径配置
# ============================================================================
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
