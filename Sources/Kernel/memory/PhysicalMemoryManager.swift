
@_silgen_name("_kernel_start")
private nonisolated(unsafe) var KERNEL_PHYSICAL_START:UInt8

@_silgen_name("_kernel_end")
private nonisolated(unsafe) var KERNEL_PHYSICAL_END:UInt8

var kernelStartAddress: UInt {
    unsafe UInt(bitPattern: UnsafeRawPointer(&KERNEL_PHYSICAL_START))
}

var kernelEndAddress: UInt {
    unsafe UInt(bitPattern: UnsafeRawPointer(&KERNEL_PHYSICAL_END))
}

final class PhysicalMemoryManager {
    nonisolated(unsafe) static let shared = PhysicalMemoryManager()
}

// MARK: mark available
extension PhysicalMemoryManager {
    func markAvailable(
        base: UInt64,
        length: UInt64
    ) {
        logger.log("PhysicalMemoryManager: attempting to mark X bytes available beginning at Y...")
        //logger.log("PhysicalMemoryManager: attempting to mark \(length) bytes available beginning at \(base)...")
        var marked = 0
        for addr in stride(from: base, to: base + length, by: 4096) {
            if addr >= kernelStartAddress && addr < kernelEndAddress {
                // don't manage the memory where the kernel is actually running
                continue 
            }
            self.setBitAsFree(pageIndex: addr / 4096)
            marked += 1
        }
        logger.log("PhysicalMemoryManager: marked Z as available")
        //logger.log("PhysicalMemoryManager: marked \(marked) as available")
    }

    private func setBitAsFree(pageIndex: UInt64) {
        // TODO: implement
    }
}

// MARK: allocate page
extension PhysicalMemoryManager {
    func allocatePage() -> UInt64 {
        // TODO: implement
        return 0
        /*
        for i in 0..<(totalPages / 64) {
            let val = bitmap[i]
            if val != UInt64.max { // if not all 64 bits are 1
                for bit in 0..<64 {
                    let mask:UInt64 = 1 << bit
                    if (val & mask) == 0 {
                        bitmap[i] |= mask // mark as used
                        let pageIndex = (i * 64) + bit
                        return memStart + UInt64(pageIndex * 4096)
                    }
                }
            }
        }
        logger.log("PhysicalMemoryManager: out of physical memory!")
        */
    }
}