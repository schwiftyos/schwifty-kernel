
func initKernel(
    infoPointer: UnsafeRawPointer
) {
    logger.log("Kernel: initializing...")

    initIDT()
    initHeap()
    unsafe initMultiboot2(infoPointer: infoPointer)

    logger.log("Kernel: initialized")
}

// MARK: Heap
private func initHeap() {
    logger.log("Heap: initializing...")
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
    logger.log("Heap: initialized")
}