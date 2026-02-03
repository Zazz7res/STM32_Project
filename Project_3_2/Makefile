CC = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
SIZE = arm-none-eabi-size

# 源文件（适配教学项目结构）
SOURCES = $(wildcard Library/*.c) \
	Start/system_stm32f10x.c \
	System/Delay.c \
	User/main.c \
	User/stm32f10x_it.c

OBJECTS = $(patsubst %.c,%.o,$(SOURCES)) Start/startup_stm32f10x_md.o

# 编译标志（-O0 禁用优化确保延时循环保留）
CFLAGS = -mcpu=cortex-m3 -mthumb -O0 -g -Wall \
	-ffunction-sections -fdata-sections \
	-DSTM32F10X_MD -DUSE_STDPERIPH_DRIVER \
	-IStart -IUser -ILibrary -ISystem \
	-mno-unaligned-access

# 链接标志
LDFLAGS = -T STM32F103C8Tx_FLASH.ld \
	-mcpu=cortex-m3 -mthumb \
	-specs=nosys.specs \
	-Wl,--gc-sections

TARGET = project_3_2

all: $(TARGET).bin
	@$(SIZE) $(TARGET).elf
	@echo "Build complete. Size: $$(ls -lh $(TARGET).bin | awk '{print $$5}')"

$(TARGET).elf: $(OBJECTS)
	@echo "  LINK    $@"
	@$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

%.o: %.c
	@echo "  CC      $<"
	@$(CC) $(CFLAGS) -c $< -o $@

Start/startup_stm32f10x_md.o: Start/startup_stm32f10x_md.s
	@echo "  AS      $<"
	@$(CC) -mcpu=cortex-m3 -mthumb -x assembler-with-cpp -c $< -o $@

$(TARGET).bin: $(TARGET).elf
	@echo "  OBJCOPY $@"
	@$(OBJCOPY) -O binary $< $@

clean:
	rm -f Start/*.o Library/*.o System/*.o User/*.o $(TARGET).elf $(TARGET).bin

flash:
	st-flash write $(TARGET).bin 0x08000000

.PHONY: all clean flash
