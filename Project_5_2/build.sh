#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"

echo "=============================================="
echo "🔨 STM32 项目构建脚本"
echo "=============================================="
echo "📁 项目目录：${SCRIPT_DIR}"
echo "📂 构建目录：${BUILD_DIR}"
echo ""

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

echo "📋 配置 CMake..."
cmake -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE=../cmake/gcc_stm32f103c8.cmake \
  -DCMAKE_BUILD_TYPE=Release \
  ..

echo "🔨 开始编译..."
ninja

echo ""
echo "=============================================="
echo "✅ 构建完成！"
echo "=============================================="
echo "📦 ELF: ${BUILD_DIR}/STM32_Rotary_Encoder.elf"
echo "📦 BIN: ${BUILD_DIR}/STM32_Rotary_Encoder.bin"
echo "📦 HEX: ${BUILD_DIR}/STM32_Rotary_Encoder.hex"
echo ""

arm-none-eabi-size "${BUILD_DIR}/STM32_Rotary_Encoder.elf"
