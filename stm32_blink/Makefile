CC = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
SIZE = arm-none-eabi-size

# 源文件
SOURCES = $(wildcard library/*.c) start/system_stm32f10x.c user/main.c user/stm32f10x_it.c
OBJECTS = $(patsubst %.c,%.o,$(SOURCES)) startup_stm32f10x_md.o

# 编译标志（-O0 禁用优化确保延时循环保留）
CFLAGS = -mcpu=cortex-m3 -mthumb -O0 -g -Wall \
         -ffunction-sections -fdata-sections \
         -DSTM32F10X_MD -DUSE_STDPERIPH_DRIVER \
         -Istart -Iuser -Ilibrary \
         -mno-unaligned-access

# 链接标志（保留 --gc-sections，它不会裁剪启动代码）
LDFLAGS = -T STM32F103C8Tx_FLASH.ld \
          -mcpu=cortex-m3 -mthumb \
          -specs=nosys.specs \
          -Wl,--gc-sections

TARGET = stm32_blink

all: $(TARGET).bin
	@$(SIZE) $(TARGET).elf
	@echo "Build complete. Size: $$(ls -lh $(TARGET).bin | awk '{print $$5}')"

$(TARGET).elf: $(OBJECTS)
	@echo "  LINK    $@"
	@$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

%.o: %.c
	@echo "  CC      $<"
	@$(CC) $(CFLAGS) -c $< -o $@

startup_stm32f10x_md.o: start/startup_stm32f10x_md.s
	@echo "  AS      $<"
	@$(CC) -mcpu=cortex-m3 -mthumb -x assembler-with-cpp -c $< -o $@

$(TARGET).bin: $(TARGET).elf
	@echo "  OBJCOPY $@"
	@$(OBJCOPY) -O binary $< $@

clean:
	rm -f *.o $(TARGET).elf $(TARGET).bin

flash:
	st-flash write $(TARGET).bin 0x08000000

.PHONY: all clean flash


