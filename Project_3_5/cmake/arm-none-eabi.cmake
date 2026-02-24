set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR cortex-m3)

set(TOOLCHAIN_PREFIX arm-none-eabi)
set(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}-gcc)
set(CMAKE_ASM_COMPILER ${TOOLCHAIN_PREFIX}-gcc)
set(CMAKE_OBJCOPY ${TOOLCHAIN_PREFIX}-objcopy CACHE INTERNAL "objcopy")
set(CMAKE_SIZE_UTIL ${TOOLCHAIN_PREFIX}-size CACHE INTERNAL "size")

set(CPU_FLAGS "-mcpu=cortex-m3 -mthumb -mfloat-abi=soft")
set(OPT_FLAGS "-Og -g3")

set(CMAKE_C_FLAGS "${CPU_FLAGS} ${OPT_FLAGS}" CACHE STRING "C flags")
set(CMAKE_ASM_FLAGS "${CPU_FLAGS} -x assembler-with-cpp" CACHE STRING "ASM flags")

set(CMAKE_EXE_LINKER_FLAGS "-nostartfiles -nostdlib" CACHE STRING "Linker flags")
set(CMAKE_EXECUTABLE_SUFFIX ".elf")
