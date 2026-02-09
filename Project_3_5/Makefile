TARGET=project_3_5
MCU=cortex-m3
CC=arm-none-eabi-gcc
LD=arm-none-eabi-gcc
OBJCOPY=arm-none-eabi-objcopy
SIZE=arm-none-eabi-size
INCLUDES=-I. -ILibrary -IUser -IHardware -ISystem -IStart
SRC_FILES=User/main.c User/stm32f10x_it.c System/Delay.c Hardware/LightSensor.c Hardware/Buzzer.c Hardware/LED.c Hardware/Key.c Start/system_stm32f10x.c Library/misc.c Library/stm32f10x_rcc.c Library/stm32f10x_gpio.c
OBJ_FILES=$(SRC_FILES:.c=.o)
CFLAGS=-mcpu=$(MCU) -mthumb -O0 -g3 -Wall -fno-builtin -DUSE_STDPERIPH_DRIVER -DSTM32F10X_MD $(INCLUDES)
LDFLAGS=-mcpu=$(MCU) -mthumb -TSTM32F103C8Tx_FLASH.ld -Wl,--gc-sections -Wl,--print-memory-usage
all: $(TARGET).elf $(TARGET).bin
$(TARGET).elf: $(OBJ_FILES) startup.o
	$(LD) $(LDFLAGS) -o $@ $^
	$(SIZE) $@
startup.o: Start/startup_stm32f10x_md.s
	$(CC) -c $(CFLAGS) -o $@ $<
%.o: %.c
	$(CC) -c $(CFLAGS) -o $@ $<
$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@
clean:
	rm -f $(OBJ_FILES) startup.o $(TARGET).elf $(TARGET).bin $(TARGET).hex $(TARGET).map
flash: $(TARGET).bin
	st-flash --reset write $(TARGET).bin 0x8000000
.PHONY: all clean flash
