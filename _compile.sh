echo "Compiling..."

if swiftc -target i686-unknown-none-elf \
        -emit-object \
        $PWD/Sources/Kernel/*.swift \
        $PWD/Sources/Kernel/*/*.swift \
        -o Kernel.o \
        -static \
        -wmo \
        -Osize \
        -Xfrontend -disable-implicit-concurrency-module-import \
        -Xfrontend -disable-stack-protector \
        -Xcc -fno-stack-protector \
        -Xcc -fno-pic \
        -enable-experimental-feature Extern \
        -enable-experimental-feature Embedded ; then
    echo "Compilation successful"

    # generate assembly
    echo "Generating assembly..."
    objdump -D Kernel.o > generatedAssembly.asm
    echo "Generated assembly"
else
    echo "Compilation failed"
    exit 1
fi