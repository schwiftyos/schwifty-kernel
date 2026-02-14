
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
    unsafe initMultiboot2(infoPointer: infoPointer)

    let pml4Pointer = unsafe UnsafeMutablePointer<UInt64>(bitPattern: 0x1000)!
    let pageManager = unsafe PageTableManager(pml4: pml4Pointer)
    pageManager.map(
        virtual: 0xFEE00000,
        physical: 0xFEE00000,
        flags: PageTableManager.Flag.present.rawValue
                | PageTableManager.Flag.writable.rawValue
                | PageTableManager.Flag.cacheDisable.rawValue
                | PageTableManager.Flag.writeThrough.rawValue
    )
    unsafe LocalAPIC.shared.configure()

    logger.log("kinit: executed")
}