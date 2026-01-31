echo "Assembling..."

if as --32 boot_x86.S -o boot_x86.o ; then
    echo "Assembling successful"
else
    echo "Assembling failed"
    exit 1
fi