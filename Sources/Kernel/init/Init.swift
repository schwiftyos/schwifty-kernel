
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

    bootstrapMemory()

    logger.log(staticString: "kinit: executed")
}

private func bootstrapMemory() {
    // general protection fault if we try initializing memory during an interrupt (or other nondeterministic behavior); thank you Swift for being lazy ;)
    logger.log(staticString: "kinit: bootstrap memory: executing...")
    let _ = keyEventQueue.count
    unsafe keyboardInterruptScancodeIsExtended = false
    let _ = KeyboardScancodes.Qwerty.ps2Set1[0].clone()
    let _ = KeyboardScancodes.Qwerty.ps2Set1Extended[0].clone()
    logger.log(staticString: "kinit: bootstrap memory: executed")
}