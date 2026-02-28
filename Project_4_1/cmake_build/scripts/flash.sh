#!/bin/bash
# ==========================================================================
# 文件名：flash.sh
# 作用：一键烧录程序到 STM32
# 依赖：st-flash (需安装 stlink-tools)
# 位置：cmake_build/scripts/flash.sh
# ==========================================================================

set -e
set -u

# 0. 检查 st-flash 是否已安装
if ! command -v st-flash &> /dev/null; then
    echo "❌ 错误：st-flash 未找到"
    echo "💡 请安装 stlink-tools："
    echo "   sudo apt install stlink-tools"
    exit 1
fi

# 1. 定位文件
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BIN_FILE="$PROJECT_ROOT/build/OLED_Display.bin"

# 2. 检查编译产物是否存在
if [ ! -f "$BIN_FILE" ]; then
    echo "❌ 错误：找不到 $BIN_FILE"
    echo "💡 请先运行 ./scripts/build.sh"
    exit 1
fi

# 3. 烧录程序
echo "🔌 正在烧录..."
echo "📦 文件：$BIN_FILE"
echo "📍 地址：0x08000000"

if ! st-flash write "$BIN_FILE" 0x08000000; then
    echo "❌ 烧录失败！"
    echo "💡 检查项："
    echo "   1. ST-Link 是否已插入 USB"
    echo "   2. 是否需要 sudo 权限 (sudo ./scripts/flash.sh)"
    echo "   3. udev 规则是否已配置"
    exit 1
fi

# 4. 完成提示
echo "✅ 烧录成功！"
echo "💡 程序应自动运行，如无反应请按下 RESET 按钮"
