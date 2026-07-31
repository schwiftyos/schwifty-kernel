
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

@safe
final class PhysicalMemoryManager {
    nonisolated(unsafe) static let shared = PhysicalMemoryManager()

    // for our Single Address Space covering 4 GiB, we need: (4 GiB / 4096) bits ((1,048,576 / 8) = 131,072 bytes [128 KiB for bitmap])
    private nonisolated(unsafe) var bitmap:UnsafeMutablePointer<UInt64>!
    private let totalPages:UInt64 = 1_048_576
}

// MARK: initialize
extension PhysicalMemoryManager {
    func initialize(bitmapAddress: UInt64) {
        logger.log(staticString: "PhysicalMemoryManager: initializing...")

        unsafe bitmap = UnsafeMutablePointer<UInt64>(bitPattern: UInt(bitmapAddress))
        // initialize all as used (1); markAvailable will free them
        unsafe bitmap.initialize(repeating: UInt64.max, count: Int(totalPages / 64))

        logger.log(staticString: "PhysicalMemoryManager: initialized")
    }
}

// MARK: mark available
extension PhysicalMemoryManager {
    func markAvailable(
        base: UInt64,
        length: UInt64
    ) {
        logger.log(staticString: "PhysicalMemoryManager: attempting to mark X bytes available beginning at Y...")
        let startPage = base / 4096
        let pageCount = length / 4096
        for i in 0..<pageCount {
            let address = (startPage + i) * 4096
            if address >= kernelStartAddress && address < kernelEndAddress {
                continue
            }
            // TODO: protect the bitmap if its in the available range (assumes bitmap is 128 KiB)?
            setBitAsFree(pageIndex: startPage + i)
        }
        logger.log(staticString: "PhysicalMemoryManager: marked X bytes available beginning at Y")
    }

    private func setBitAsFree(pageIndex: UInt64) {
        let i = Int(pageIndex / 64)
        let bit = Int(pageIndex % 64)
        unsafe bitmap[i] &= ~(1 << bit)
    }
}

// MARK: allocate page
extension PhysicalMemoryManager {
    func allocatePage() -> UnsafeMutablePointer<UInt64>? {
        logger.log(staticString: "PhysicalMemoryManager: allocating page...")
        for i in 0..<Int(totalPages / 64) {
            let val = unsafe bitmap[i]
            if val != UInt64.max { // if not all 64 bits are 1
                for bit in 0..<64 {
                    let mask:UInt64 = 1 << bit
                    if (val & mask) == 0 {
                        unsafe bitmap[i] |= mask
                        let pageIndex = (i * 64) + bit
                        let address = UInt64(pageIndex * 4096)
                        logger.log(staticString: "PhysicalMemoryManager: allocated page (\\(address))")
                        return unsafe bitmap.advanced(by: Int(address))
                    }
                }
            }
        }
        Panic.physicalMemoryManagerOutOfMemory.execute()
        return nil
    }
}