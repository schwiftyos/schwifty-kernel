
struct Panic: Sendable, ~Copyable {
    let message:StaticString

    func execute() {
        #if Log
        logger.log(staticString: message)
        #endif
    }
}

extension Panic {
    private static func get(_ msg: StaticString) -> Self {
        .init(message: msg)
    }

    static let kernelLoadHeapButAlreadyLoaded = get("PANIC: KernelHeap: load: tried loading heap, but its already loaded!")
    static let kernelAllocationOutOfMemory = get("PANIC: KernelHeap: allocate: out of memory!")

    static let keyboardRingBufferIsFull = get("PANIC: KeyboardRingBuffer: buffer is full!")

    static let pageTableManagerFailedToAllocatePage = get("PANIC: PageTableManager: getOrCreateTable: failed to allocate page!")

    static let physicalMemoryManagerOutOfMemory = get("PANIC: PhysicalMemoryManager: out of physical memory!")
}