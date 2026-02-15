
@safe
final class KernelHeap {
    nonisolated(unsafe) static let shared = KernelHeap()

    var _startAddress:UnsafeMutableRawPointer! = nil
    var _offset = 0
    var _size = 0
}

// MARK: load
extension KernelHeap {
    func load(
        startAddress: UnsafeMutableRawPointer,
        size: UInt64
    ) {
        guard unsafe _startAddress == nil else {
            logger.log("KernelHeap: load: PANIC: tried loading heap, but its already loaded!")
            cpu_halt()
            return
        }
        unsafe _startAddress = startAddress
        _size = Int(size)

        logger.log("KernelHeap: loaded at \(UInt(bitPattern: startAddress)) with \(size) bytes")
    }
}

// MARK: allocate
extension KernelHeap {
    /// Tries to allocate the provided number of bytes using 16 byte alignment.
    func allocate(
        size: Int
    ) -> UnsafeMutableRawPointer? {
        return unsafe allocate(size: size, alignment: 16)
    }

    /// Tries to allocate the provided number of bytes using the provided alignment.
    func allocate(
        size: Int,
        alignment: Int
    ) -> UnsafeMutableRawPointer? {
        let alignedSize = (size + alignment) & ~alignment
        guard _offset + alignedSize < _size else {
            logger.log("PANIC: KernelHeap: allocate: ran out of memory trying to allocate X bytes with alignment Y")
            return nil
        }
        let p = unsafe _startAddress.advanced(by: Int(_offset))
        _offset += alignedSize
        //logger.log("KernelHeap: allocate: allocated X bytes with Y alignment")
        return unsafe p
    }
}

// MARK: deallocate
extension KernelHeap {
    func deallocate(_ pointer: UnsafeMutableRawPointer?) {
        // TODO: implement
        logger.log("KernelHeap: deallocate: NOT IMPLEMENTED")
    }
}

// MARK: verify
extension KernelHeap {
    func verify(amount: Int) {
        logger.log("KernelHeap: verify: starting...")
    
        // test class allocation
        let testObject = KernelTest(value: 42)
        let testObjectPointer = unsafe Unmanaged.passUnretained(testObject).toOpaque()
        logger.log("KernelHeap: verify: testObject allocated at memory address: \(UInt(bitPattern: testObjectPointer))")
        
        // test dynamic collection
        let testArray = UnsafeMutableBufferPointer<Int>.allocate(capacity: 10)
        for i in 0..<amount {
            unsafe testArray[i] = i * 10
        }
        logger.log("KernelHeap: verify: Array at \(UInt(bitPattern: testArray.baseAddress!)) contains \(testArray.count) elements.")
        
        // test alignment (crucial for SIMD)
        guard let rawPtr = unsafe malloc(16) else {
            logger.log("KernelHeap: verify: failed to malloc(16)")
            return
        }
        let addr = UInt(bitPattern: rawPtr)
        if addr % 16 == 0 {
            logger.log("KernelHeap: verify: 16-byte alignment confirmed at \(addr)")
        } else {
            logger.log("KernelHeap: verify: ALIGNMENT FAILURE at \(addr)")
        }
    }
}

private final class KernelTest {
    var value:Int

    init(value: Int) {
        self.value = value
    }
}