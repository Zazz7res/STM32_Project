#!/bin/bash
# ==========================================================================
# 文件名：build.sh
# 作用：一键清理并编译项目
# 位置：cmake_build/scripts/build.sh
# ==========================================================================

# 1. 安全设置
set -e  # 关键！如果任何命令失败，立即停止脚本（防止错误累积）
set -u  # 如果使用未定义变量，报错

# 2. 获取脚本所在目录
# 无论你在哪里运行脚本，都能正确定位到项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"  # 返回上一级，即 cmake_build 根目录

# 3. 进入构建目录
cd "$PROJECT_ROOT"

# 4. 清理旧构建 (避免旧文件干扰)
echo "🧹 清理旧构建..."
rm -rf build
mkdir -p build
cd build

# 5. 配置 CMake
echo "⚙️ 配置 CMake..."
cmake .. \
    -DCMAKE_TOOLCHAIN_FILE=../toolchain-arm-none-eabi.cmake \
    -GNinja

# 6. 开始编译
echo "🔨 开始编译..."
ninja

# 7. 完成提示
echo "✅ 编译成功！"
echo "📦 输出文件：$PROJECT_ROOT/build/OLED_Display.bin"
