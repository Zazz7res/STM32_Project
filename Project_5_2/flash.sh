#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"
ELF_FILE="${BUILD_DIR}/STM32_Rotary_Encoder.elf"

echo "=============================================="
echo "📡 STM32 烧录脚本"
echo "=============================================="

if [ ! -f "${ELF_FILE}" ]; then
  echo "❌ 错误：ELF 文件不存在！请先运行 build.sh"
  exit 1
fi

echo "🔌 连接 ST-Link..."
openocd -f interface/stlink.cfg \
  -f target/stm32f1x.cfg \
  -c "program ${ELF_FILE} verify reset exit"

echo ""
echo "=============================================="
echo "✅ 烧录完成！"
echo "=============================================="
