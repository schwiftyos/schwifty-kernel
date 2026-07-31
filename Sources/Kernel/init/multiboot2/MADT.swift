
// MARK: Find
func madtFind(rsdtAddress: UInt64) -> UnsafePointer<MADTTable>? {
    let rsdt = unsafe UnsafePointer<ACPIHeader>(bitPattern: UInt(rsdtAddress))!
    let entryCount = unsafe (Int(rsdt.pointee.length) - MemoryLayout<ACPIHeader>.size) / 4
    let entries = unsafe UnsafeRawPointer(rsdt).advanced(by: MemoryLayout<ACPIHeader>.size).assumingMemoryBound(to: UInt32.self)
    for i in 0..<entryCount {
        let tableAddress = unsafe UInt(entries[i])
        let header = unsafe UnsafePointer<ACPIHeader>(bitPattern: tableAddress)!
        // check signature for "APIC"
        if unsafe header.pointee.signature == (0x41, 0x50, 0x49, 0x43) {
            return unsafe UnsafePointer<MADTTable>(bitPattern: tableAddress)
        }
    }
    return nil
}

// MARK: Parse
func madtParse(madt: UnsafePointer<MADTTable>) -> UInt32? {
    logger.log(staticString: "Multiboot2: madtParse: executing...")
    var ioapicAddress:UInt32? = nil
    var currentOffset = MemoryLayout<MADTTable>.size
    let totalLength = unsafe Int(madt.pointee.header.length)
    let rawPointer = unsafe UnsafeRawPointer(madt)
    while currentOffset < totalLength {
        let entryType = unsafe rawPointer.advanced(by: currentOffset).load(as: UInt8.self)
        let entryLength = unsafe rawPointer.advanced(by: currentOffset + 1).load(as: UInt8.self)
        switch entryType {
        case MADTEntryType.ioAPIC.rawValue:
            // offset 4: 32-bit Physical Address of I/O APIC
            ioapicAddress = unsafe rawPointer.advanced(by: currentOffset + 4).load(as: UInt32.self)
            logger.log(staticString: "Multiboot2: madtParse: found I/O APIC at \\(ioapicAddress!)")
            
        case MADTEntryType.interruptOverride.rawValue:
            // checks if IRQ1 is actually mapped to Global System Interrupt 1 or something else
            let irq = unsafe rawPointer.advanced(by: currentOffset + 3).load(as: UInt8.self)
            let gsi = unsafe rawPointer.advanced(by: currentOffset + 4).load(as: UInt32.self)
            logger.log(staticString: "Multiboot2: madtParse: IRQ \\(irq) is actually GSI \\(gsi)")
            
        default:
            //logger.log(staticString: "Multiboot2: madtParse: unhandled entryType (\(entryType))")
            break
        }
        currentOffset += Int(entryLength)
    }
    logger.log(staticString: "Multiboot2: madtParse: executed")
    return ioapicAddress
}