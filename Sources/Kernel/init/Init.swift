
func initKernel(
    infoPointer: UnsafeRawPointer
) {
    logger.log("Kernel: initializing...")

    initSIMD()
    initIDT()
    unsafe initMultiboot2(infoPointer: infoPointer)

    logger.log("Kernel: initialized")
}