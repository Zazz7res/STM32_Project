CC = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
SIZE = arm-none-eabi-size

SOURCES = \
	Library/misc.c \
	Library/stm32f10x_gpio.c \
	Library/stm32f10x_rcc.c \
	Library/stm32f10x_exti.c \
	Start/system_stm32f10x.c \
	System/Delay.c \
	Hardware/LED.c \
	Hardware/Key.c \
	User/main.c \
	User/stm32f10x_it.c

OBJECTS = $(patsubst %.c,%.o,$(SOURCES)) Start/startup_stm32f10x_md.o

CFLAGS = -mcpu=cortex-m3 -mthumb -O0 -g -Wall \
	-ffunction-sections -fdata-sections \
	-DSTM32F10X_MD -DUSE_STDPERIPH_DRIVER \
	-IStart -ISystem -IUser -ILibrary -IHardware \
	-mno-unaligned-access

LDFLAGS = -T STM32F103C8Tx_FLASH.ld \
	-mcpu=cortex-m3 -mthumb \
	-specs=nosys.specs \
	-Wl,--gc-sections

TARGET = project_3_4

all: $(TARGET).bin
	@$(SIZE) $(TARGET).elf
	@echo "✓ 构建成功! 二进制大小: $$(ls -lh $(TARGET).bin 2>/dev/null | awk '{print $$5}')"

$(TARGET).elf: $(OBJECTS)
	@echo "  [LINK]  $@"
	@$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^ -lm

%.o: %.c
	@echo "  [CC]    $<"
	@$(CC) $(CFLAGS) -c $< -o $@

Start/startup_stm32f10x_md.o: Start/startup_stm32f10x_md.s
	@echo "  [AS]    $<"
	@$(CC) -mcpu=cortex-m3 -mthumb -x assembler-with-cpp -c $< -o $@

$(TARGET).bin: $(TARGET).elf
	@echo "  [BIN]   $@"
	@$(OBJCOPY) -O binary $< $@

clean:
	rm -f Start/*.o Library/*.o System/*.o User/*.o Hardware/*.o $(TARGET).elf $(TARGET).bin
	@echo "✓ 清理完成"

flash:
	st-flash write $(TARGET).bin 0x08000000

.PHONY: all clean flash
