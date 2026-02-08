
@_silgen_name("_kernel_start")
nonisolated(unsafe) var KERNEL_PHYSICAL_START:UInt8

@_silgen_name("_kernel_end")
nonisolated(unsafe) var KERNEL_PHYSICAL_END:UInt8

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