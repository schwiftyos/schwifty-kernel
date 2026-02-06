
@safe
final class KernelHeap {
    nonisolated(unsafe) static let shared = KernelHeap()

    var head:UnsafeMutablePointer<HeapMemoryBlock>?
}

// MARK: load
extension KernelHeap {
    func load(
        startAddress: UnsafeMutableRawPointer,
        size: UInt64
    ) {
        guard unsafe head == nil else {
            logger.log("KernelHeap: load: PANIC: tried loading heap, but its already loaded!")
            cpu_halt()
            return
        }
        logger.log("KernelHeap: load: loading at X with Y bytes...")
        //logger.log("KernelHeap: loading at \(UInt(bitPattern: startAddress)) with \(size) bytes...")
        let firstHead = unsafe startAddress.assumingMemoryBound(to: HeapMemoryBlock.self)
        unsafe firstHead.pointee = .init(
            size: size - UInt64(MemoryLayout<HeapMemoryBlock>.stride),
            isFree: true,
            next: nil
        )
        unsafe head = firstHead
        logger.log("KernelHeap: loaded")
    }
}

// MARK: allocate
extension KernelHeap {
    /// Tries to allocate the provided number of bytes using 16 byte alignment.
    func allocate(size: Int) -> UnsafeMutableRawPointer? {
        logger.log("KernelHeap: allocating X bytes...")
        //logger.log("KernelHeap: allocating \(size) bytes...")

        // align to 16 bytes for SIMD compatibility
        let alignedSize = (size + 15) & ~15
        var current = unsafe head
        while let block = unsafe current {
            if unsafe block.pointee.isFree && block.pointee.size >= alignedSize {
                unsafe block.pointee.isFree = false
                // TODO: split block if there is significant leftover space so we don't waste memory
                return unsafe UnsafeMutableRawPointer(block).advanced(by: MemoryLayout<HeapMemoryBlock>.stride)
            }
            unsafe current = block.pointee.next
        }
        logger.log("KernelHeap: allocate: ran out of memory trying to allocate X bytes")
        //logger.log("KernelHeap: allocate: ran out of memory trying to allocate \(size) bytes")
        // out of memory
        return nil
    }

    /// Tries to allocate the provided number of byes using the provided alignment.
    func allocate(
        size: Int,
        alignment: Int
    ) -> UnsafeMutableRawPointer? {
        logger.log("KernelHeap: allocating X bytes with alignment Y...")
        //logger.log("KernelHeap: allocating \(size) bytes with alignment \(alignment)...")
        var current = unsafe head
        while let block = unsafe current {
            let nextBlockPointer = unsafe UnsafeMutableRawPointer(block).advanced(by: MemoryLayout<HeapMemoryBlock>.stride)
            let nextBlockPointerAddress = Int(bitPattern: nextBlockPointer)

            let alignmentPadding = (alignment - (nextBlockPointerAddress % alignment)) % alignment
            let totalNeeded = size + alignmentPadding

            if unsafe block.pointee.isFree && block.pointee.size >= totalNeeded {
                unsafe block.pointee.isFree = false
                
                // in a Single Address Space, we return the aligned pointer
                // TODO: for 'free' to work, we'd ideally store the 'original' block start pointer just before the returned address
                return unsafe nextBlockPointer.advanced(by: alignmentPadding)
            }
            unsafe current = block.pointee.next
        }
        logger.log("KernelHeap: allocate: ran out of memory trying to allocate X bytes with alignment Y")
        //logger.log("KernelHeap: allocate: ran out of memory trying to allocate \(size) bytes with alignment \(alignment)")
        // out of memory
        return nil
    }
}

// MARK: deallocate
extension KernelHeap {
    func deallocate(_ pointer: UnsafeMutableRawPointer?) {
        logger.log("KernelHeap: deallocate: executing...")
        guard let pointer = unsafe pointer else {
            logger.log("KernelHeap: deallocate: pointer == nil")
            return
        }
        logger.log("KernelHeap: deallocate: deallocating X...")
        //logger.log("KernelHeap: deallocate: deallocating \(UInt(bitPattern: pointer))...")
    
        // move pointer back to find the header
        let blockPointer = unsafe (pointer - MemoryLayout<HeapMemoryBlock>.size).assumingMemoryBound(to: HeapMemoryBlock.self)
        unsafe blockPointer.pointee.isFree = true

        coalesce()
    }

    /// Merges adjacent free memory blocks.
    private func coalesce() {
        var current = unsafe head
        while let block = unsafe current {
            if unsafe block.pointee.isFree, let nextBlock = unsafe block.pointee.next, unsafe nextBlock.pointee.isFree {
                unsafe block.pointee.size += UInt64(MemoryLayout<HeapMemoryBlock>.stride) + nextBlock.pointee.size
                unsafe block.pointee.next = nextBlock.pointee.next
                // stay on this block to check if we can also merge the next block
                continue
            }
            unsafe current = block.pointee.next
        }
    }
}

// MARK: verify
extension KernelHeap {
    func verify() {
        logger.log("KernelHeap: verify: starting...")
    
        // test class allocation
        let testObject = KernelTest(value: 42)
        let testObjectAddr = withUnsafePointer(to: testObject) { UInt(bitPattern: $0) }
        logger.log("KernelHeap: verify: testObject allocated at memory address: X")
        //logger.log("KernelHeap: verify: testObject allocated at memory address: \(testObjectAddr)")
        
        // test dynamic collection
        var testArray = [Int]()
        for i in 0..<5 {
            testArray.append(i * 10)
        }
        let testArrayAddr = withUnsafePointer(to: testArray) { UInt(bitPattern: $0) }
        logger.log("KernelHeap: verify: Array at X contains Y elements.")
        //logger.log("KernelHeap: verify: Array at \(testArrayAddr) contains \(testArray.count) elements.")
        
        // test alignment (crucial for SIMD)
        guard let rawPtr = malloc(16) else {
            logger.log("KernelHeap: verify: failed to malloc(16)")
            return
        }
        let addr = UInt(bitPattern: rawPtr)
        if addr % 16 == 0 {
            logger.log("KernelHeap: verify: 16-byte alignment confirmed at X")
            //logger.log("KernelHeap: verify: 16-byte alignment confirmed at \(addr)")
        } else {
            logger.log("KernelHeap: verify: ALIGNMENT FAILURE at X")
            //logger.log("KernelHeap: verify: ALIGNMENT FAILURE at \(addr)")
        }
    }
}

private class KernelTest {
    var value:Int

    init(value: Int) {
        self.value = value
    }
}