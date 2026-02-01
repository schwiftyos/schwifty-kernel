
@_cdecl("malloc")
public func malloc(_ size: Int) -> UnsafeMutableRawPointer? {
    var current = unsafe heapFirstBlock
    while let block = unsafe current {
        if unsafe block.pointee.isFree && block.pointee.size >= size {
            // split block if there's enough room for a new header + 1 byte
            if unsafe block.pointee.size > (size + MemoryLayout<HeapMemoryBlock>.size + 8) {
                let newBlockPointer = unsafe UnsafeMutableRawPointer(block) + MemoryLayout<HeapMemoryBlock>.size + size
                let nextBlock = unsafe newBlockPointer.assumingMemoryBound(to: HeapMemoryBlock.self)
                unsafe nextBlock.pointee = HeapMemoryBlock(
                    size: block.pointee.size - size - MemoryLayout<HeapMemoryBlock>.size,
                    isFree: true,
                    next: block.pointee.next
                )
                unsafe block.pointee.size = size
                unsafe block.pointee.next = nextBlock
            }
            unsafe block.pointee.isFree = false
            // return pointer to memory right AFTER the header
            return unsafe UnsafeMutableRawPointer(block) + MemoryLayout<HeapMemoryBlock>.size
        }
        unsafe current = block.pointee.next
    }
    return nil // out of memory
}