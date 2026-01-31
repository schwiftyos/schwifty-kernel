echo "Generating ISO..."

if grub-mkrescue -o SchwiftyOS.iso iso_root ; then
    echo "Generating ISO succeeded"
else
    echo "Generating ISO failed"
    exit 1
fi