
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
    unsafe initMultiboot2(infoPointer: infoPointer)

    logger.log("kinit: executed")
}