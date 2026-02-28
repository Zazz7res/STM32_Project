# cmake_build/toolchain-arm-none-eabi.cmake
# ================================
# 第 1 部分：指定编译器
# ================================
set(CMAKE_SYSTEM_NAME Generic)          # 目标系统：通用嵌入式 (非 Windows/Linux)
set(CMAKE_SYSTEM_PROCESSOR ARM)         # 目标处理器：ARM 架构

# 告诉 CMake 使用 ARM 交叉编译器 (而非电脑自带的 gcc)
set(CMAKE_C_COMPILER arm-none-eabi-gcc)
set(CMAKE_ASM_COMPILER arm-none-eabi-gcc)

# ================================
# 第 2 部分：ARM 架构参数
# ================================
# Cortex-M3 核心参数
set(CPU "-mcpu=cortex-m3")              # CPU 型号
set(FPU "-mfloat-abi=soft")             # 浮点运算：软件模拟 (M3 无硬件 FPU)
set(THUMB "-mthumb")                    # 指令集：Thumb 模式 (代码更小)

# 编译器标志
set(CMAKE_C_FLAGS "${CPU} ${FPU} ${THUMB}" CACHE INTERNAL "")
set(CMAKE_ASM_FLAGS "${CPU} ${FPU} ${THUMB}" CACHE INTERNAL "")

# ================================
# 第 3 部分：关键修复 (规避链接测试)
# ================================
# ⚠️ 最重要的一行！嵌入式必加！
# 原因：CMake 默认会编译测试程序并链接，但嵌入式没有操作系统，
#      链接器会报错 _exit 未定义。这行告诉 CMake："只编译，不链接"
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# ================================
# 第 4 部分：搜索路径
# ================================
# 告诉 CMake 去哪里找 ARM 相关的工具
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
