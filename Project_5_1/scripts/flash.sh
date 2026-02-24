#!/bin/bash
# ~/STM32_Project/Project_5_1/scripts/flash.sh

cd "$(dirname "$0")/.."

ELF_FILE="build/STM32_Project_5_1.elf"

if [ ! -f "$ELF_FILE" ]; then
  echo "Error: ELF file not found. Please build first."
  exit 1
fi

echo "Erasing chip..."
# 先擦除整个 Flash
openocd -f interface/stlink.cfg -f target/stm32f1x.cfg -c "init; reset halt; stm32f1x mass_erase 0; reset run; exit"

echo "Flashing..."
# 再烧录新程序
openocd -f interface/stlink.cfg -f target/stm32f1x.cfg -c "program $ELF_FILE verify reset exit"
