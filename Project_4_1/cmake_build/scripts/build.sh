#!/bin/bash
set -e
cd "$(dirname "$0")/.."
rm -rf build && mkdir build && cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE=../toolchain-arm-none-eabi.cmake -GNinja
ninja
echo -e "\n✅ 构建成功！输出文件："
ls -lh *.elf *.bin *.hex *.map 2>/dev/null | grep -E '\.(elf|bin|hex|map)$'
