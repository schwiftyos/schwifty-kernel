
func initKernel(
    infoPointer: UnsafeRawPointer
) {
    logger.log("Kernel: initializing...")

    initSIMD()
    unsafe initMultiboot2(infoPointer: infoPointer)
    initIDT()

    logger.log("Kernel: initialized")
}