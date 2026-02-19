
@_cdecl("kinit")
public func kinit(
    infoPointer: UnsafeRawPointer
) {
    UART.initialize()

    logger.log("kinit: executing...")

    initSIMD()
    initIDT()

    if hasRDRANDSupport() {
        logger.log("kinit: RDRAND supported")
    } else {
        logger.log("kinit: RDRAND unsupported")
    }

    unsafe PhysicalMemoryManager.shared.initialize(bitmapAddress: 0x200000)
    LocalAPIC.configure()
    unsafe initMultiboot2(infoPointer: infoPointer)

    unsafe PageTableManager.shared.initialize(pml4: UnsafeMutablePointer<UInt64>(bitPattern: 0x1000)!)
    IOAPIC.configure()

    logger.log("kinit: executed")
}