
@_cdecl("kinit")
public func kinit(
    infoPointer: UnsafeRawPointer
) {
    UART.initialize()

    logger.log(staticString: "kinit: executing...")

    initSIMD()
    initIDT()

    if hasRDRANDSupport() {
        logger.log(staticString: "kinit: RDRAND supported")
    } else {
        logger.log(staticString: "kinit: RDRAND unsupported")
    }

    unsafe PhysicalMemoryManager.shared.initialize(bitmapAddress: 0x200000)
    LocalAPIC.configure()
    unsafe initMultiboot2(infoPointer: infoPointer)

    unsafe PageTableManager.shared.initialize(pml4: UnsafeMutablePointer<UInt64>(bitPattern: 0x1000)!)
    IOAPIC.configure()

    // general protection fault if we try initializing memory during an interrupt
    logger.log(staticString: "kinit: initializing memory required for handling interrupts...")
    let _ = KeyboardScancodes.Qwerty.ps2Set1[0]
    let _ = KeyboardScancodes.Qwerty.ps2Set1Extended[0]
    logger.log(staticString: "kinit: initialized memory required for handling interrupts")

    logger.log(staticString: "kinit: executed")
}