
func initKernel(
    infoPointer: UnsafeRawPointer
) {
    logger.log("Kernel: initializing...")

    initSIMD()
    initIDT()
    if hasRDRANDSupport() {
        logger.log("Kernel: RDRAND supported")
    } else {
        logger.log("Kernel: RDRAND unsupported")
    }
    unsafe initMultiboot2(infoPointer: infoPointer)
    //unsafe LocalAPIC.shared.configure()
    //unsafe IOAPIC.shared.configure()

    logger.log("Kernel: initialized")
}