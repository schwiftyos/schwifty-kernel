
echo "Linking..."
if ld -m elf_i386 -T linker_x86.ld --no-warn-rwx-segments -nostdlib --gc-sections boot_x86.o Kernel.o -o $PWD/iso_root/boot/kernel.bin ; then
    echo "Linking successful"
else
    echo "Linking failed"
    exit 1
fi