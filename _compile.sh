echo "Compiling..."

if swiftly run swift build -c release ; then
    echo "Compilation successful"

    # generate assembly
    echo "Generating assembly..."
    objdump -D Kernel.o > generatedAssembly.asm
    echo "Generated assembly"
else
    echo "Compilation failed"
    exit 1
fi