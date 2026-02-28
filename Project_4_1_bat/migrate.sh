#!/bin/bash
# STM32F103 CMake Migration Kit - 保存为 migrate.sh 并执行
set -e

PROJECT_ROOT="${PWD}"
MIGRATION_DIR="cmake_build"
CHIP="STM32F103C8T6" # 默认值，后续可调整

echo "🔧 正在创建 CMake 项目结构..."
mkdir -p "${MIGRATION_DIR}/scripts" "${MIGRATION_DIR}/ldscripts"

# 1. 生成工具链文件
cat >"${MIGRATION_DIR}/toolchain-arm-none-eabi.cmake" <<'EOF'
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(TOOLCHAIN_PREFIX arm-none-eabi)
set(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}-gcc)
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}-g++)
set(CMAKE_ASM_COMPILER ${TOOLCHAIN_PREFIX}-gcc)
set(CMAKE_OBJCOPY ${TOOLCHAIN_PREFIX}-objcopy CACHE INTERNAL "objcopy tool")
set(CMAKE_SIZE_UTIL ${TOOLCHAIN_PREFIX}-size CACHE INTERNAL "size tool")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mcpu=cortex-m3 -mthumb -mfloat-abi=soft")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -ffunction-sections -fdata-sections -fno-common")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -Werror -g3")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DUSE_STDPERIPH_DRIVER -DSTM32F10X_MD")  # Medium Density

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-gc-sections,--print-memory-usage")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-Map=\${CMAKE_PROJECT_NAME}.map")
EOF

# 2. 生成链接脚本（通用 STM32F103 128KB Flash）
cat >"${MIGRATION_DIR}/ldscripts/STM32F103C8T6.ld" <<'EOF'
MEMORY
{
  FLASH (rx) : ORIGIN = 0x08000000, LENGTH = 128K
  RAM (rwx)  : ORIGIN = 0x20000000, LENGTH = 20K
}

SECTIONS
{
  .isr_vector :
  {
    KEEP(*(.isr_vector))
  } > FLASH

  .text :
  {
    *(.text*)
    *(.rodata*)
    KEEP(*(.init))
    KEEP(*(.fini))
    _etext = .;
  } > FLASH

  .preinit_array :
  {
    PROVIDE_HIDDEN (__preinit_array_start = .);
    KEEP (*(.preinit_array*))
    PROVIDE_HIDDEN (__preinit_array_end = .);
  } > FLASH

  .init_array :
  {
    PROVIDE_HIDDEN (__init_array_start = .);
    KEEP (*(SORT(.init_array.*)))
    KEEP (*(.init_array*))
    PROVIDE_HIDDEN (__init_array_end = .);
  } > FLASH

  .fini_array :
  {
    PROVIDE_HIDDEN (__fini_array_start = .);
    KEEP (*(SORT(.fini_array.*)))
    KEEP (*(.fini_array*))
    PROVIDE_HIDDEN (__fini_array_end = .);
  } > FLASH

  _sidata = LOADADDR(.data);

  .data : AT (_sidata)
  {
    _sdata = .;
    *(.data*)
    _edata = .;
  } > RAM

  .bss :
  {
    _sbss = .;
    __bss_start__ = _sbss;
    *(.bss*)
    *(COMMON)
    _ebss = .;
    __bss_end__ = _ebss;
  } > RAM

  .heap :
  {
    __end__ = .;
    PROVIDE(end = .);
    *(.heap*)
    __HeapLimit = .;
  } > RAM

  .stack :
  {
    __StackLimit = .;
    . += 2K;  /* 2KB stack */
    __StackTop = .;
    PROVIDE(__stack = __StackTop);
  } > RAM

  .ARM.attributes 0 : { *(.ARM.attributes) }
}
EOF

# 3. 生成 syscalls 实现（解决 _sbrk 等未定义问题）
cat >"${MIGRATION_DIR}/syscalls.c" <<'EOF'
#include <stdint.h>
#include <sys/stat.h>
#include <sys/times.h>
#include <errno.h>

extern uint32_t __StackTop;
extern uint32_t __HeapLimit;

caddr_t _sbrk(int incr) {
    static uint32_t heap_ptr = 0;
    uint32_t prev_heap_ptr;

    if (heap_ptr == 0) {
        heap_ptr = (uint32_t)&__HeapLimit;
    }
    prev_heap_ptr = heap_ptr;
    if (heap_ptr + incr > (uint32_t)&__StackTop) {
        errno = ENOMEM;
        return (caddr_t)-1;
    }
    heap_ptr += incr;
    return (caddr_t)prev_heap_ptr;
}

int _close(int file) { return -1; }
int _fstat(int file, struct stat *st) { st->st_mode = S_IFCHR; return 0; }
int _isatty(int file) { return 1; }
int _lseek(int file, int ptr, int dir) { return 0; }
int _read(int file, char *ptr, int len) { return 0; }
int _write(int file, char *ptr, int len) { return len; }
void _exit(int status) { while(1); }
int _open(const char *name, int flags, int mode) { return -1; }
int _kill(int pid, int sig) { errno = EINVAL; return -1; }
int _getpid(void) { return -1; }
EOF

# 4. 生成主 CMakeLists.txt
cat >"${MIGRATION_DIR}/CMakeLists.txt" <<'EOF'
cmake_minimum_required(VERSION 3.15)
project(STM32_OLED_Display VERSION 1.0 LANGUAGES C ASM)

# 芯片配置（根据实际型号调整）
set(MCU_FAMILY STM32F1)
set(FLASH_SIZE 128K)
set(RAM_SIZE 20K)
set(STARTUP_FILE startup_stm32f10x_md.s)  # Medium Density

# 源文件组织
file(GLOB_RECURSE STARTUP_FILES "../Start/*.s")
file(GLOB_RECURSE CORE_FILES "../Start/core_cm3.c")
file(GLOB_RECURSE SYSTEM_FILES "../System/*.c")
file(GLOB_RECURSE LIBRARY_FILES "../Library/*.c")
file(GLOB_RECURSE HARDWARE_FILES "../Hardware/*.c")
file(GLOB_RECURSE USER_FILES "../User/*.c")

# 过滤不需要的 startup 文件（只保留 MD 版本）
list(FILTER STARTUP_FILES EXCLUDE REGEX ".*(_cl|_hd|_hd_vl|_ld|_ld_vl|_xl)\\.s$")

add_executable(${PROJECT_NAME}.elf
    ${STARTUP_FILE}
    ${CORE_FILES}
    ${SYSTEM_FILES}
    ${LIBRARY_FILES}
    ${HARDWARE_FILES}
    ${USER_FILES}
    syscalls.c
)

# 包含路径
target_include_directories(${PROJECT_NAME}.elf PRIVATE
    ../Start
    ../Library
    ../System
    ../Hardware
    ../User
)

# 编译选项
target_compile_options(${PROJECT_NAME}.elf PRIVATE
    -mcpu=cortex-m3
    -mthumb
    -mfloat-abi=soft
    -ffunction-sections
    -fdata-sections
    -fno-common
    -Wall
    -Wextra
    -g3
)

# 定义宏（关键！匹配 Keil 配置）
target_compile_definitions(${PROJECT_NAME}.elf PRIVATE
    USE_STDPERIPH_DRIVER
    STM32F10X_MD  # Medium Density - 根据实际芯片调整
)

# 链接脚本
target_link_options(${PROJECT_NAME}.elf PRIVATE
    -T "${CMAKE_SOURCE_DIR}/ldscripts/STM32F103C8T6.ld"
    -Wl,-Map=${PROJECT_NAME}.map
    -Wl,--gc-sections
)

# 生成 BIN/HEX 文件
add_custom_target(${PROJECT_NAME}.bin ALL
    COMMAND ${CMAKE_OBJCOPY} -O binary ${PROJECT_NAME}.elf ${PROJECT_NAME}.bin
    DEPENDS ${PROJECT_NAME}.elf
)

add_custom_target(${PROJECT_NAME}.hex ALL
    COMMAND ${CMAKE_OBJCOPY} -O ihex ${PROJECT_NAME}.elf ${PROJECT_NAME}.hex
    DEPENDS ${PROJECT_NAME}.elf
)

# 构建后显示大小
add_custom_command(TARGET ${PROJECT_NAME}.elf POST_BUILD
    COMMAND ${CMAKE_SIZE_UTIL} ${PROJECT_NAME}.elf
)
EOF

# 5. 生成构建脚本
cat >"${MIGRATION_DIR}/scripts/build.sh" <<'EOF'
#!/bin/bash
set -e
cd "$(dirname "$0")/.."
rm -rf build && mkdir build && cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE=../toolchain-arm-none-eabi.cmake -GNinja
ninja
echo "✅ 构建成功! 生成文件:"
ls -lh *.elf *.bin *.hex *.map 2>/dev/null | grep -E '\.(elf|bin|hex|map)$'
EOF

# 6. 生成烧录脚本（OpenOCD + ST-Link）
cat >"${MIGRATION_DIR}/scripts/flash.sh" <<'EOF'
#!/bin/bash
set -e
cd "$(dirname "$0")/.."
BUILD_DIR="build"

if [ ! -f "${BUILD_DIR}/STM32_OLED_Display.bin" ]; then
    echo "❌ 未找到 .bin 文件，请先执行 ./scripts/build.sh"
    exit 1
fi

echo "🔌 正在烧录到 STM32F103..."
openocd -f interface/stlink-v2-1.cfg -f target/stm32f1x.cfg \
    -c "program ${BUILD_DIR}/STM32_OLED_Display.bin verify reset exit" 2>&1 | tee flash.log

if grep -q "verified" flash.log; then
    echo "✅ 烧录成功!"
    rm flash.log
else
    echo "❌ 烧录失败，请检查连接和 OpenOCD 配置"
    exit 1
fi
EOF

# 7. 生成防砖补丁（关键！修复 PA11/PA12 问题）
cat >"${MIGRATION_DIR}/scripts/fix_usb_pins.patch" <<'EOF'
--- a/User/main.c
+++ b/User/main.c
@@ -1,5 +1,6 @@
 #include "stm32f10x.h"
 #include "Delay.h"
 #include "OLED.h"
+#include "stm32f10x_gpio.h"
 
 int main(void)
 {
@@ -8,6 +9,16 @@ int main(void)
     SystemInit();  // 时钟初始化（72MHz）
     Delay_Init();  // SysTick 初始化
     
+    // 🔑 防砖关键代码：拉低 PA11/PA12 (USB D-/D+) 避免干扰 OLED
+    RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);
+    GPIO_InitTypeDef GPIO_InitStruct;
+    GPIO_InitStruct.GPIO_Pin = GPIO_Pin_11 | GPIO_Pin_12;
+    GPIO_InitStruct.GPIO_Mode = GPIO_Mode_Out_PP;
+    GPIO_InitStruct.GPIO_Speed = GPIO_Speed_50MHz;
+    GPIO_Init(GPIOA, &GPIO_InitStruct);
+    GPIO_ResetBits(GPIOA, GPIO_Pin_11 | GPIO_Pin_12);
+    Delay_ms(10);  // 确保电平稳定
+    
     OLED_Init();
     OLED_ShowString(1, 1, "Hello STM32!");
     OLED_ShowString(2, 1, "Linux CMake Build");
EOF

# 8. 生成使用说明
cat >"${MIGRATION_DIR}/README.md" <<EOF
# STM32F103 OLED 项目 - CMake 迁移指南

## 📦 依赖安装（Ubuntu）
\`\`\`bash
sudo apt install cmake ninja-build gcc-arm-none-eabi openocd
\`\`\`

## 🔧 构建步骤
\`\`\`bash
cd cmake_build
./scripts/build.sh
\`\`\`

## 🔌 烧录步骤
\`\`\`bash
./scripts/flash.sh  # 需要 ST-Link 连接
\`\`\`

## ⚠️ 重要提示
1. **芯片型号确认**：当前配置为 STM32F103C8T6 (MD)，如使用其他型号请修改：
   - \`CMakeLists.txt\` 中的 \`STM32F10X_MD\` → \`STM32F10X_HD\`（高密度）
   - \`ldscripts/STM32F103C8T6.ld\` 中的 Flash/RAM 大小
   - \`STARTUP_FILE\` 选择对应版本（md/hd/hd_vl）

2. **防砖保护**：已提供补丁 \`fix_usb_pins.patch\`，务必应用到 main.c
   \`\`\`bash
   cd ../User && patch -p1 < ../cmake_build/scripts/fix_usb_pins.patch
   \`\`\`

3. **OLED 接口**：默认假设 I2C 接口（PB6=SCL, PB7=SDA），如使用 SPI 请检查 OLED.c 配置

## 📊 输出文件
- \`build/STM32_OLED_Display.elf\` - 调试用 ELF
- \`build/STM32_OLED_Display.bin\` - 烧录用二进制
- \`build/STM32_OLED_Display.map\` - 内存布局分析
EOF

# 设置权限
chmod +x "${MIGRATION_DIR}/scripts/build.sh" "${MIGRATION_DIR}/scripts/flash.sh"

echo "✅ 迁移套件生成完成!"
echo "👉 下一步操作:"
echo "   1. cd ${MIGRATION_DIR}"
echo "   2. ./scripts/build.sh       # 构建项目"
echo "   3. ./scripts/flash.sh       # 烧录到开发板"
echo ""
echo "⚠️  重要：请先应用防砖补丁（避免 OLED 不亮）:"
echo "   cd ../User && patch -p1 < ../cmake_build/scripts/fix_usb_pins.patch"
echo ""
echo "🔍 如需调整芯片型号，请编辑:"
echo "   - cmake_build/CMakeLists.txt (STM32F10X_MD 宏)"
echo "   - cmake_build/ldscripts/STM32F103C8T6.ld (内存大小)"
