echo "Assembling..."

if as boot_x86.S -o .build/release/boot_x86.o ; then
    echo "Assembling successful"
else
    echo "Assembling failed"
    exit 1
fi