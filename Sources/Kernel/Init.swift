
public func initKernel(
    infoPointer: UInt32
) {
    initRandom()
    initMultiboot2(infoPointer: infoPointer)

    initHeap()
    //initCPUs(cores: 1)
    initMultitasking()
}

// MARK: Random
private func initRandom() {
    unsafe nextRandom = UInt32(truncatingIfNeeded: rdtsc())
}

// MARK: Multiboot2
private func initMultiboot2(infoPointer: UInt32) {
    let infoBase = unsafe UnsafeRawPointer(bitPattern: UInt(infoPointer))!
    let totalSize = unsafe infoBase.load(as: UInt32.self)
    var offset:UInt32 = 8 // skip the 8-byte header
    while offset < totalSize {
        let tagPointer = unsafe (infoBase + Int(offset))
        let header = unsafe tagPointer.load(as: MultibootTagHeader.self)
        switch header.type {
        case 0: // end tag
            break
        case 6: // memory map
            let map = unsafe tagPointer.load(as: MemoryMapTag.self)
            let entriesCount = (map.size - 16) / map.entrySize
            
            // pointer to the first entry
            var entryPointer = unsafe (tagPointer + 16).assumingMemoryBound(to: MemoryMapEntry.self)
            
            for _ in 0..<entriesCount {
                let entry = unsafe entryPointer.pointee
                if entry.type == 1 {
                    // memory is safe to use (entry.baseAddress to (entry.baseAddress + entry.length))
                }
                unsafe entryPointer += 1
            }
            break
        case 8: // framebuffer info
            let fb = unsafe tagPointer.load(as: FramebufferTag.self)
            //fb.drawBlueScreen()
            FramebufferTag.drawGlyph(SimpleFont.charS, address: fb.address, pitch: fb.pitch, x: 0, y: 1, color: .max)
            FramebufferTag.drawGlyph(SimpleFont.charC, address: fb.address, pitch: fb.pitch, x: 1 * 8, y: 1, color: .max)
            FramebufferTag.drawGlyph(SimpleFont.charH, address: fb.address, pitch: fb.pitch, x: 2 * 8, y: 1, color: .max)
            FramebufferTag.drawGlyph(SimpleFont.charW, address: fb.address, pitch: fb.pitch, x: 3 * 8, y: 1, color: .max)
            FramebufferTag.drawGlyph(SimpleFont.charI, address: fb.address, pitch: fb.pitch, x: 4 * 8, y: 1, color: .max)
            FramebufferTag.drawGlyph(SimpleFont.charF, address: fb.address, pitch: fb.pitch, x: 5 * 8, y: 1, color: .max)
            FramebufferTag.drawGlyph(SimpleFont.charT, address: fb.address, pitch: fb.pitch, x: 6 * 8, y: 1, color: .max)
            FramebufferTag.drawGlyph(SimpleFont.charY, address: fb.address, pitch: fb.pitch, x: 7 * 8, y: 1, color: .max)
            FramebufferTag.drawGlyph(SimpleFont.charO, address: fb.address, pitch: fb.pitch, x: 8 * 8, y: 1, color: .max)
            FramebufferTag.drawGlyph(SimpleFont.charS, address: fb.address, pitch: fb.pitch, x: 9 * 8, y: 1, color: .max)
        default:
            break
        }
        // tags are 8-byte aligned!
        offset += (header.size + 7) & ~7
    }
}

// MARK: Heap
private func initHeap() {
    // in a production/real kernel, we'd get this from our memory map (Multiboot)
    // for now, we'll use a static buffer
    let buffer = UnsafeMutableRawPointer.allocate(byteCount: heapSize, alignment: 4096)
    unsafe heapStart = buffer
    
    unsafe heapFirstBlock = buffer.assumingMemoryBound(to: HeapMemoryBlock.self)
    unsafe heapFirstBlock?.pointee = HeapMemoryBlock(
        size: heapSize - MemoryLayout<HeapMemoryBlock>.size,
        isFree: true,
        next: nil
    )
}

// MARK: Multitasking
private func initMultitasking() {
    unsafe threads.reserveCapacity(6)
    // TODO: fix | causes reboots
    /*let mainThread = unsafe KernelThread(
        stackPointer: UnsafeMutableRawPointer(bitPattern: 0)!, // overwritten on first yield
        id: 0,
        state: .running
    )
    unsafe threads.append(mainThread)*/
}

// MARK: CPUs
private func initCPUs(cores: Int) {
    let lapic = LocalAPIC()
    lapic.setup()

    for core in 1..<cores {
        lapic.sendInterProcessorInterrupt(
            apicID: UInt32(core),
            vector: 0,
            deliveryMode: 0b101
        )

        // vector 0x08 points to address 0x08000 where our assembly "trampoline" code lives
        lapic.sendInterProcessorInterrupt(
            apicID: UInt32(core),
            vector: 0x08,
            deliveryMode: 0b110
        )
    }
}