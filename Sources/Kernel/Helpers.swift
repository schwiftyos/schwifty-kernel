
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
    let blockPtr = unsafe (pointer - MemoryLayout<HeapMemoryBlock>.size).assumingMemoryBound(to: HeapMemoryBlock.self)
    unsafe blockPtr.pointee.isFree = true
    
    // simple Coalescing: merge with next free block
    if let next = unsafe blockPtr.pointee.next, unsafe next.pointee.isFree {
        unsafe blockPtr.pointee.size += MemoryLayout<HeapMemoryBlock>.size + next.pointee.size
        unsafe blockPtr.pointee.next = next.pointee.next
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
                let newBlockPtr = unsafe UnsafeMutableRawPointer(block) + MemoryLayout<HeapMemoryBlock>.size + size
                let nextBlock = unsafe newBlockPtr.assumingMemoryBound(to: HeapMemoryBlock.self)
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
    var ptr: UnsafeMutableRawPointer? = nil
    _ = unsafe posix_memalign(&ptr, requiredAlignmentMask + 1, requiredSize)
    return unsafe ptr
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

// MARK: arc4random_buf
@_cdecl("arc4random_buf")
public func arc4random_buf(
    _ buffer: UnsafeMutableRawPointer,
    _ nbytes: Int
) {
    let dest = unsafe buffer.assumingMemoryBound(to: UInt8.self)
    for i in 0..<nbytes {
        let val = read_rdrand()
        if i % 4 == 0 {
            unsafe dest[i] = UInt8(val & 0xFF)
        } else {
            unsafe dest[i] = UInt8((val >> 8) & 0xFF)
        }
    }
}

// MARK: arc4random
@_cdecl("arc4random")
public func arc4random() -> UInt32 {
    var val:UInt32 = 0
    unsafe arc4random_buf(&val, MemoryLayout<UInt32>.size)
    return val
}

// MARK: __ashldi3
@_cdecl("__ashldi3")
public func __ashldi3(
    value: UInt64,
    count: Int32
) -> UInt64 {
    if count == 0 {
        return value
    }
    let low = UInt32(value & 0xFFFFFFFF)
    let high = UInt32(value >> 32)
    if count >= 32 {
        let newHigh = low << (count - 32)
        return UInt64(newHigh) << 32
    } else {
        let newLow = low << count
        let newHigh = (high << count) | (low >> (32 - count))
        return (UInt64(newHigh) << 32) | UInt64(newLow)
    }
}

// MARK: __lshrdi3
@_cdecl("__lshrdi3")
public func __lshrdi3(
    value: UInt64,
    count: Int32
) -> UInt64 {
    if count == 0 {
        return value
    }
    let low = UInt32(value & 0xFFFFFFFF)
    let high = UInt32(value >> 32)
    if count >= 32 {
        let newLow = high >> (count - 32)
        return UInt64(newLow)
    } else {
        let newHigh = high >> count
        let newLow = (low >> count) | (high << (32 - count))
        return (UInt64(newHigh) << 32) | UInt64(newLow)
    }
}

// MARK: __ashrdi3
@_cdecl("__ashrdi3")
public func __ashrdi3(value: Int64, count: Int32) -> Int64 {
    if count == 0 {
        return value
    }
    let bits = UInt64(bitPattern: value)
    let low = UInt32(bits & 0xFFFFFFFF)
    let high = Int32(bitPattern: UInt32(bits >> 32))
    if count >= 32 {
        let newHigh = high >> 31
        let newLow = high >> (count - 32)
        let resultBits = (UInt64(UInt32(bitPattern: newHigh)) << 32) | UInt64(UInt32(bitPattern: newLow))
        return Int64(bitPattern: resultBits)
    } else {
        let newHigh = high >> count
        let newLow = (low >> count) | (UInt32(bitPattern: high) << (32 - count))
        let resultBits = (UInt64(UInt32(bitPattern: newHigh)) << 32) | UInt64(newLow)
        return Int64(bitPattern: resultBits)
    }
}

// MARK: __udivdi3
@_cdecl("__udivdi3")
public func __udivdi3(
    _ dividend: UInt64,
    _ divisor: UInt64
) -> UInt64 {
    // TODO: optimize
    if divisor == 0 {
        // TODO: kernel panic
        return 0 
    }
    var quotient:UInt64 = 0
    var remainder:UInt64 = 0
    // Binary Long Division Algorithm
    for i in (0...63).reversed() {
        remainder <<= 1
        remainder |= (dividend >> i) & 1
        if remainder >= divisor {
            remainder -= divisor
            quotient |= (1 << i)
        }
    }
    return quotient
}

// MARK: ceil
@_cdecl("ceil")
public func ceil(_ x: Double) -> Double {
    guard x.isFinite else { return x }
    let truncated = Double(Int64(x))
    if x > 0 && x > truncated {
        // x is positive and has a fractional part; round up
        return truncated + 1.0
    }
    // x is negative; already truncated
    return truncated
}

// MARK: ceilf
@_cdecl("ceilf")
public func ceilf(_ x: Float) -> Float {
    return Float(ceil(Double(x)))
}

// MARK: yield
@_cdecl("yield")
func yield() {
    let current = unsafe threads[currentThreadIndex]
    // find the next thread in the 'Ready' queue
    // for 1:1 pinning, this might just be the 'next' task in a simple circular list
    let next = unsafe (current.id + 1) % threads.count
    let nextThread = unsafe threads[next]
    unsafe currentThreadIndex = next
    unsafe context_switch(current.stackPointer, nextThread.stackPointer)
}