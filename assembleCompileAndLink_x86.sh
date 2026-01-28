# assemble
as --32 boot_x86.S -o boot_x86.o

# compile
swiftc -target i686-unknown-none-elf \
    -emit-object $PWD/Sources/Kernel/Kernel.swift \
    -static \
    -wmo \
    -Osize \
    -Xfrontend -disable-implicit-concurrency-module-import \
    -Xfrontend -disable-stack-protector \
    -Xcc -fno-stack-protector \
    -Xcc -fno-pic \
    -enable-experimental-feature Extern \
    -enable-experimental-feature Embedded

# link
ld -m elf_i386 -T linker_x86.ld --no-warn-rwx-segments -nostdlib --gc-sections boot_x86.o Kernel.o -o Kernel_x86.bin

# generated assembly
objdump -D Kernel.o > generatedAssembly.asm