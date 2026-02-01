
public func initKernel(
    infoPointer: UInt
) {
    initMultiboot2(infoPointer: infoPointer)
    initHeap()
}

// MARK: Multiboot2
private func initMultiboot2(infoPointer: UInt) {
    let infoBase = unsafe UnsafeRawPointer(bitPattern: infoPointer)!
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
            let fb = unsafe FramebufferTag(tagPointer: tagPointer)
            fb.drawStatus()
        default:
            return
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