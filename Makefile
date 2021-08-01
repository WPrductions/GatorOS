FILES = ./bin-int/kernel.asm.o ./bin-int/kernel.o ./bin-int/idt/idt.asm.o ./bin-int/idt/idt.o ./bin-int/memory/memory.o ./bin-int/io/io.asm.o ./bin-int/memory/heap/heap.o ./bin-int/memory/heap/kheap.o 
INCLUDES = -I./src
FLAGS = -g -ffreestanding -falign-jumps -falign-functions -falign-labels -falign-loops -fstrength-reduce -fomit-frame-pointer -finline-functions -Wno-unused-function -fno-builtin -Werror -Wno-unused-label -Wno-cpp -Wno-unused-parameter -nostdlib -nostartfiles -nodefaultlibs -Wall -O0 -Iinc

all: ./bin/boot.bin ./bin/kernel.bin
	rm -rf ./bin/os.bin
	dd if=./bin/boot.bin >> ./bin/os.bin
	dd if=./bin/kernel.bin >> ./bin/os.bin
	dd if=/dev/zero bs=512 count=100 >> ./bin/os.bin 

./bin/kernel.bin: $(FILES)
	i686-elf-ld -g -relocatable $(FILES) -o ./bin-int/kernel_linked.o
	i686-elf-gcc -T ./src/linker.ld -o ./bin/kernel.bin -ffreestanding -O0 -nostdlib ./bin-int/kernel_linked.o

./bin/boot.bin: ./src/boot/boot.asm
	nasm -f bin ./src/boot/boot.asm -o ./bin/boot.bin

./bin-int/kernel.asm.o: ./src/kernel.asm
	nasm -f elf -g ./src/kernel.asm -o ./bin-int/kernel.asm.o

./bin-int/idt/idt.asm.o: ./src/idt/idt.asm
	nasm -f elf -g ./src/idt/idt.asm -o ./bin-int/idt/idt.asm.o

./bin-int/kernel.o: ./src/kernel.c
	i686-elf-gcc $(INCLUDES) $(FLAGS) -std=gnu99 -c ./src/kernel.c -o ./bin-int/kernel.o

./bin-int/idt/idt.o: ./src/idt/idt.c
	i686-elf-gcc $(INCLUDES) -I./src/idt $(FLAGS) -std=gnu99 -c ./src/idt/idt.c -o ./bin-int/idt/idt.o

./bin-int/memory/memory.o: ./src/memory/memory.c
	i686-elf-gcc $(INCLUDES) -I./src/memory $(FLAGS) -std=gnu99 -c ./src/memory/memory.c -o ./bin-int/memory/memory.o

./bin-int/io/io.asm.o: ./src/io/io.asm
	nasm -f elf -g ./src/io/io.asm -o ./bin-int/io/io.asm.o

./bin-int/memory/heap/heap.o: ./src/memory/heap/heap.c
	i686-elf-gcc $(INCLUDES) -I./src/memory/heap/heap $(FLAGS) -std=gnu99 -c ./src/memory/heap/heap.c -o ./bin-int/memory/heap/heap.o

./bin-int/memory/heap/kheap.o: ./src/memory/heap/kheap.c
	i686-elf-gcc $(INCLUDES) -I./src/memory/heap $(FLAGS) -std=gnu99 -c ./src/memory/heap/kheap.c -o ./bin-int/memory/heap/kheap.o


clean:
	rm -rf ./bin/*.bin
	rm -rf $(FILES)

build:

	./build.sh

run:
	qemu-system-x86_64 -hda ./bin/os.bin

sim:
	gdb -x rungdbcommands

test:
	make build
	make run
	clear