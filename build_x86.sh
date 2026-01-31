
# assemble
if bash _assemble.sh ; then
    echo ""
else
    exit 1
fi

# compile
if bash _compile.sh ; then
    echo ""
else
    exit 1
fi

# link
if bash _link.sh ; then
    echo ""
else
    exit 1
fi          

# generate iso
if bash _generateISO.sh ; then
    echo ""
else
    exit 1
fi