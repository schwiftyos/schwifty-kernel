
public func initKernel() {
    initRandom()
    initHeap()
    initMultitasking()
}

// MARK: Init random
private func initRandom() {
    unsafe nextRandom = UInt32(truncatingIfNeeded: rdtsc())
}

// MARK: Init heap
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

// MARK: Init multitasking
private func initMultitasking() {
    unsafe threads.reserveCapacity(6)
    // TODO: fix | causes reboots
    /*
    let mainThread = unsafe ThreadControlBlock(
        stackPointer: UnsafeMutableRawPointer(bitPattern: 0)!, // overwritten on first yield
        id: 0,
        state: .running
    )
    unsafe threads.append(mainThread)*/
}