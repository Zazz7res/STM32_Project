#!/bin/bash
# ~/STM32_Project/Project_5_1/scripts/build.sh
cd "$(dirname "$0")/.."
mkdir -p build
cd build
cmake -DCMAKE_TOOLCHAIN_FILE=../cmake/gcc_arm_none_eabi.cmake -G Ninja ..
ninja
