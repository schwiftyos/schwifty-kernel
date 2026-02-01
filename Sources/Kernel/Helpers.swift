
// MARK: memset
@_cdecl("memset")
public func memset(_ s: UnsafeMutableRawPointer, _ c: Int32, _ n: Int) -> UnsafeMutableRawPointer {
    let dest = unsafe s.assumingMemoryBound(to: UInt8.self)
    var i = 0
    while i < n {
        unsafe dest[i] = UInt8(c)
        i += 1
    }
    return unsafe s
}

// MARK: memmove
@_cdecl("memmove")
public func memmove(_ dest: UnsafeMutableRawPointer, _ src: UnsafeRawPointer, _ n: Int) -> UnsafeMutableRawPointer {
    let d = unsafe dest.assumingMemoryBound(to: UInt8.self)
    let s = unsafe src.assumingMemoryBound(to: UInt8.self)
    if unsafe d < s {
        for i in 0..<n {
            unsafe d[i] = s[i]
        }
    } else {
        for i in (0..<n).reversed() {
            unsafe d[i] = s[i]
        }
    }
    return unsafe dest
}

// MARK: memcpy
@_cdecl("memcpy")
public func memcpy(_ dest: UnsafeMutableRawPointer, _ src: UnsafeRawPointer, _ n: Int) -> UnsafeMutableRawPointer {
    let d = unsafe dest.assumingMemoryBound(to: UInt8.self)
    let s = unsafe src.assumingMemoryBound(to: UInt8.self)
    var i = 0
    while i < n {
        unsafe d[i] = s[i]
        i += 1
    }
    return unsafe dest
}

// MARK: free
@_cdecl("free")
public func free(_ pointer: UnsafeMutableRawPointer?) {
    guard let pointer = unsafe pointer else { return }
    
    // move pointer back to find the header
    let blockPointer = unsafe (pointer - MemoryLayout<HeapMemoryBlock>.size).assumingMemoryBound(to: HeapMemoryBlock.self)
    unsafe blockPointer.pointee.isFree = true
    
    // simple Coalescing: merge with next free block
    if let next = unsafe blockPointer.pointee.next, unsafe next.pointee.isFree {
        unsafe blockPointer.pointee.size += MemoryLayout<HeapMemoryBlock>.size + next.pointee.size
        unsafe blockPointer.pointee.next = next.pointee.next
    }
}

// MARK: malloc
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

// MARK: posix_memalign
@_cdecl("posix_memalign")
public func posix_memalign(
    _ pointer: UnsafeMutablePointer<UnsafeMutableRawPointer?>,
    _ alignment: Int,
    _ size: Int
) -> Int32 {
    // simple hack for kernel: malloc a bit extra and align the pointer
    // in a production kernel, we'd use a buddy allocator
    let totalSize = size + alignment
    if let raw = unsafe malloc(totalSize) {
        let addr = Int(bitPattern: raw)
        let alignedAddr = (addr + alignment - 1) & ~(alignment - 1)
        unsafe pointer.pointee = UnsafeMutableRawPointer(bitPattern: alignedAddr)
        return 0
    }
    return 12 // ENOMEM
}

// MARK: swift_allocObject
@_cdecl("swift_allocObject")
public func swift_allocObject(
    metadata: UnsafeRawPointer,
    requiredSize: Int,
    requiredAlignmentMask: Int
) -> UnsafeMutableRawPointer? {
    // alignment mask = (alignment - 1)
    var pointer:UnsafeMutableRawPointer? = nil
    _ = unsafe posix_memalign(&pointer, requiredAlignmentMask + 1, requiredSize)
    return unsafe pointer
}

// MARK: swift_deallocObject
@_cdecl("swift_deallocObject")
public func swift_deallocObject(
    object: UnsafeMutableRawPointer,
    allocatedSize: Int,
    allocatedAlignMask: Int
) {
    unsafe free(object)
}