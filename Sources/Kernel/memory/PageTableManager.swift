
@safe
struct PageTableManager {
    var pml4:UnsafeMutablePointer<UInt64>
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
    func map(
        virtual: UInt64,
        physical: UInt64,
        flags: Flag
    ) {
        // calculate indexes for each level
        let pml4Index = Int((virtual >> 39) & 0x1FF)
        let pdpIndex  = Int((virtual >> 30) & 0x1FF)
        let pdIndex   = Int((virtual >> 21) & 0x1FF)
        let ptIndex   = Int((virtual >> 12) & 0x1FF)

        let pdp = unsafe getOrCreateTable(from: pml4, index: pml4Index)
        let pd  = unsafe getOrCreateTable(from: pdp, index: pdpIndex)
        let pt  = unsafe getOrCreateTable(from: pd, index: pdIndex)

        // final entry in the Page Table
        unsafe pt[ptIndex] = physical | flags.rawValue
        
        // TODO: invalidate TLB for this address
        //invlpg(virtual)
    }

    private func getOrCreateTable(
        from table: UnsafeMutablePointer<UInt64>,
        index: Int
    ) -> UnsafeMutablePointer<UInt64> {
        let entry = unsafe table[index]
        if (entry & Flag.present.rawValue) != 0 {
            // table exists, extract address (mask out control bits)
            let physicalAddress = entry & 0x000FFFFF_FFFFF000
            return unsafe UnsafeMutablePointer<UInt64>(bitPattern: UInt(physicalAddress))!
        } else {
            let newTablePhysicalAddress = unsafe PhysicalMemoryManager.shared.allocatePage() 
            unsafe table[index] = newTablePhysicalAddress | Flag.present.rawValue | Flag.writable.rawValue
            
            let newTableVirtualAddress = unsafe UnsafeMutablePointer<UInt64>(bitPattern: UInt(newTablePhysicalAddress))!
            unsafe newTableVirtualAddress.initialize(repeating: 0, count: 512) // clear the new table
            return unsafe newTableVirtualAddress
        }
    }
}