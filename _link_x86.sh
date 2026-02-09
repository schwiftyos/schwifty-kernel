
echo "Linking..."
if ld -no-pie \
        -m elf_x86_64 \
        -T linker_x86.ld \
        --no-warn-rwx-segments \
        -nostdlib \
        --gc-sections \
        .build/release/boot_x86.o \
        .build/release/libKernel.a \
        -o $PWD/iso_root/boot/kernel.bin ; then
    echo "Linking successful"
else
    echo "Linking failed"
    exit 1
fi