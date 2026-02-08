
// https://www.gnu.org/software/grub/manual/multiboot2/multiboot.html
func initMultiboot2(infoPointer: UnsafeRawPointer) {
    logger.log("Multiboot2: initializing...")
    let info = unsafe infoPointer.load(as: MultibootInfo.self)
    var offset:UInt32 = 8 // skip the 8-byte header
    loop: while offset < info.totalSize {
        let tagPointer = unsafe (infoPointer + Int(offset))
        let header = unsafe tagPointer.load(as: MultibootTagHeader.self)
        switch header.type {
        case 0:
            logger.log("Multiboot2: found end tag")
        case 1:
            logger.log("Multiboot2: found boot command line tag")
        case 2:
            logger.log("Multiboot2: found boot loader name tag")
        case 3:
            logger.log("Multiboot2: found modules tag")
        case 4:
            logger.log("Multiboot2: found basic memory information tag")
        case 5:
            logger.log("Multiboot2: found BIOS boot device tag")
        case 6:
            logger.log("Multiboot2: found memory map tag; loading...")
            unsafe loadMemoryMapTag(tagPointer: tagPointer)
            logger.log("Multiboot2: memory map tag loaded")            
        case 7:
            logger.log("Multiboot2: found VBE tag")
        case 8:
            logger.log("Multiboot2: found framebuffer tag")
            //let fb = unsafe FramebufferTag(tagPointer: tagPointer)
            //fb.drawStatus()
        case 9:
            logger.log("Multiboot2: found elf symbols tag")
        case 10:
            logger.log("Multiboot2: found APM table tag")
        case 11:
            logger.log("Multiboot2: found EFI 32-bit system table pointer tag")
        case 12:
            logger.log("Multiboot2: found EFI 64-bit system table pointer tag")
        case 13:
            logger.log("Multiboot2: found SMBIOS tag")
        case 14:
            logger.log("Multiboot2: found ACPI old RSDP tag")
        case 15:
            logger.log("Multiboot2: found ACPI new RSDP tag")
        case 16:
            logger.log("Multiboot2: found networking information tag")
        case 17:
            logger.log("Multiboot2: found EFI memory map tag")
        case 18:
            logger.log("Multiboot2: found EFI boot services not terminated tag")
        case 19:
            logger.log("Multiboot2: found EFI 32-bit image handler pointer tag")
        case 20:
            logger.log("Multiboot2: found EFI 64-bit image handler pointer tag")
        case 21:
            logger.log("Multiboot2: found Image load base physical address tag")
        default:
            logger.log("Multiboot2: found unhandled tag")
            break loop
        }
        // tags are 8-byte aligned!
        offset += (header.size + 7) & ~7
    }
    logger.log("Multiboot2: initialized")
}


// MARK: memory map tag
private func loadMemoryMapTag(tagPointer: UnsafeRawPointer) {
    let map = unsafe tagPointer.load(as: MemoryMapTag.self)
    let entriesCount = (map.size - 16) / map.entrySize
    var entryPointer = unsafe (tagPointer + 16).assumingMemoryBound(to: MemoryMapEntry.self)
    for _ in 0..<entriesCount {
        let entry = unsafe entryPointer.pointee
        switch entry.type {
        case 1:
            let entryStart = entry.baseAddress
            let entryEnd = entryStart + entry.length

            unsafe PhysicalMemoryManager.shared.markAvailable(base: entry.baseAddress, length: entry.length)
            var heapStart = entryStart
            if kernelStartAddress >= entryStart && kernelStartAddress < entryEnd {
                // align
                heapStart = (UInt64(kernelEndAddress) + 4095) & ~4095
            }
            let heapSize = entryEnd - heapStart
            if heapSize > 1024 * 1024 * 10 { // 10MiB minimum
                logger.log("loadMemoryTag: found enough memory to setup KernelHeap")
                let heapStartPointer = unsafe UnsafeMutableRawPointer(bitPattern: UInt(heapStart))!
                unsafe KernelHeap.shared.load(
                    startAddress: heapStartPointer,
                    size: heapSize
                )
            } else {
                logger.log("loadMemoryTag: failed to load KernelHeap")
            }
        default:
            break
        }
        unsafe entryPointer += 1
    }
}