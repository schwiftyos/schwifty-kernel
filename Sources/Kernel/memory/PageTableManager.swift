
@_extern(c, "invlpg")
private func invlpg(_ address: UInt64)

@safe
final class PageTableManager {
    static nonisolated(unsafe) let shared = PageTableManager()

    private var pml4:UnsafeMutablePointer<UInt64>!

    /// Initializes the page table manager and maps the initial addresses.
    func initialize(pml4: UnsafeMutablePointer<UInt64>) {
        unsafe self.pml4 = pml4
        initMap()
    }
}

// MARK: Flag
extension PageTableManager {
    enum Flag: UInt64 {
        case present      = 1
        case writable     = 2
        case user         = 4
        case writeThrough = 8
        case cacheDisable = 16
        case accessed     = 32
        case dirty        = 64
        case hugePage     = 128 // only for PDP/PD
    }
}

// MARK: Map
extension PageTableManager {
    /// Maps initial addresses.
    private func initMap() {
        logger.log(staticString: "PageTableManager: mapping initial addresses...")
        let defaultFlags = PageTableManager.Flag.present.rawValue
            | PageTableManager.Flag.writable.rawValue
            | PageTableManager.Flag.cacheDisable.rawValue
            | PageTableManager.Flag.writeThrough.rawValue

        // kernel
        map(virtual: 0xFEE00000, physical: 0xFEE00000, flags: defaultFlags)

        // i/o apic
        map(virtual: 0xFEC00000, physical: 0xFEC00000, flags: defaultFlags)
        map(virtual: 0xFEE00000, physical: 0xFEE00000, flags: defaultFlags)

        logger.log(staticString: "PageTableManager: mapped initial addresses")
    }

    private func map(
        virtual: UInt64,
        physical: UInt64,
        flags: Flag.RawValue
    ) {
        logger.log(staticString: "PageTableManager: map: executing...")
        // calculate indexes for each level
        let pml4Index = Int((virtual >> 39) & 0x1FF)
        let pdpIndex  = Int((virtual >> 30) & 0x1FF)
        let pdIndex   = Int((virtual >> 21) & 0x1FF)
        let ptIndex   = Int((virtual >> 12) & 0x1FF)

        let pdp = unsafe getOrCreateTable(from: pml4, index: pml4Index)
        let pd  = unsafe getOrCreateTable(from: pdp, index: pdpIndex)
        let pt  = unsafe getOrCreateTable(from: pd, index: pdIndex)

        // final entry in the Page Table
        logger.log(staticString: "PageTableManager: map: assigning last page table entry...")
        unsafe pt[ptIndex] = physical | flags
        logger.log(staticString: "PageTableManager: map: assigned last page table entry")

        invlpg(virtual)
        logger.log(staticString: "PageTableManager: map: executed")
    }

    private func getOrCreateTable(
        from table: UnsafeMutablePointer<UInt64>,
        index: Int
    ) -> UnsafeMutablePointer<UInt64> {
        logger.log(staticString: "PageTableManager: getOrCreateTable: executing...")
        let entry = unsafe table[index]
        if (entry & Flag.present.rawValue) != 0 {
            logger.log(staticString: "PageTableManager: getOrCreateTable: table exists, extracting and returning address")
            // table exists, extract address (mask out control bits)
            let physicalAddress = entry & 0x000FFFFF_FFFFF000
            return unsafe UnsafeMutablePointer<UInt64>(bitPattern: UInt(physicalAddress))!
        } else {
            logger.log(staticString: "PageTableManager: getOrCreateTable: table doesn't exists, allocating page...")
            guard let newTableAddress = unsafe PhysicalMemoryManager.shared.allocatePage() else {
                logger.log(staticString: "PANIC: PageTableManager: getOrCreateTable: failed to allocate page")
                while true {
                    cpu_halt()
                }
            }
            unsafe table[index] = newTableAddress.pointee | Flag.present.rawValue | Flag.writable.rawValue

            logger.log(staticString: "PageTableManager: getOrCreateTable: clearing table...")
            unsafe newTableAddress.initialize(repeating: 0, count: 512)
            logger.log(staticString: "PageTableManager: getOrCreateTable: returning address")
            return unsafe newTableAddress
        }
    }
}