CC = i686-elf-gcc
CL = i686-elf-ld
AC = nasm

space := $(subst ,, )

INCLUDES = -I./src
FLAGS = -g -ffreestanding -falign-jumps -falign-functions -falign-labels -falign-loops -fstrength-reduce -fomit-frame-pointer -finline-functions -Wno-unused-function -fno-builtin -Werror -Wno-unused-label -Wno-cpp -Wno-unused-parameter -nostdlib -nostartfiles -nodefaultlibs -Wall -O0 -Iinc

C_FILES := $(shell find . -name "*.c")
ASM_FILES := $(shell find . -name "*.asm")

C_OBJS := $(subst src,bin-int, $(patsubst %.c, %.o, $(C_FILES)))
ASM_OBJS := $(subst src,bin-int, $(filter-out ./src/boot/boot.asm.o, $(patsubst %.asm, %.asm.o, $(ASM_FILES))))

all: ./bin/boot.bin ./bin/kernel.bin
	rm -rf ./bin/os.bin
	dd if=./bin/boot.bin >> ./bin/os.bin
	dd if=./bin/kernel.bin >> ./bin/os.bin
	dd if=/dev/zero bs=512 count=100 >> ./bin/os.bin 

./bin/kernel.bin:  $(C_OBJS) $(ASM_OBJS)
	$(CL) -g -relocatable $(ASM_OBJS) $(C_OBJS) -o ./bin-int/kernel_linked.o
	$(CC) -T ./src/linker.ld -o ./bin/kernel.bin -ffreestanding -O0 -nostdlib ./bin-int/kernel_linked.o

./bin/boot.bin: ./src/boot/boot.asm
	mkdir -p bin
	$(AC) -f bin ./src/boot/boot.asm -o ./bin/boot.bin

$(filter %.asm.o, $(ASM_OBJS)): %.asm.o:
	mkdir -p $(patsubst %, ./%, $(subst $(space),/,$(filter-out %.o, $(subst /,$(space),$@))))
	$(AC) -f elf -g $(patsubst %.asm.o, %.asm, $(subst bin-int,src, $@)) -o $@

$(filter-out %.asm.o, $(C_OBJS)): %.o:
	mkdir -p $(patsubst %, ./%, $(subst $(space),/,$(filter-out %.o, $(subst /,$(space),$@))))
	$(CC) $(INCLUDES) $(patsubst %, -I./%, $(subst bin-int,src, $(subst $(space),/,$(filter-out %.o, $(subst /,$(space),$@))))) $(FLAGS) -std=gnu99 -c $(patsubst %.o, %.c, $(subst bin-int,src, $@)) -o $@

clean:
	rm -rf ./bin
	rm -rf ./bin-int

build:
	make clean
	./build.sh

run64:
	qemu-system-x86_64 -hda ./bin/os.bin

run32:
	qemu-system-i386 -hda ./bin/os.bin

sim:
	gdb -x rungdbcommands

test64:
	make build
	make run64
	clear

test32:
	make build
	make run32
	clear

files:
	@echo " "
	@echo " "
	@echo "----------------------- INPUT FILES ------------------------"
	@echo " "
	@echo $(C_FILES)
	@echo " "
	@echo $(ASM_FILES)
	@echo " "
	@echo "----------------------- OBJECT FILES -----------------------"
	@echo " "
	@echo $(C_OBJS)
	@echo " "
	@echo $(ASM_OBJS)
	@echo " "
	@echo "------------------------------------------------------------"
	@echo " "
	@echo " "
	