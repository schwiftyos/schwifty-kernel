
@_cdecl("kmain")
public func kmain(
    infoPointer: UnsafeRawPointer
) {
    UART.initialize()
    unsafe initKernel(infoPointer: infoPointer)

    testSIMD()
    KernelHeap.shared.verify(amount: 9)

    logger.log("kmain: halting CPU")
    while true {
        cpu_halt()
    }
}

func testSIMD() {
    logger.log("testSIMD: testing...")
    let bro = UnsafeMutableRawPointer.allocate(byteCount: 1024, alignment: 16)
    unsafe bro.initializeMemory(as: UInt64.self, repeating: 3, count: 16)
    unsafe clearMemory(at: bro, count: 1024)
    logger.log("testSIMD: success")

    //unsafe bro.deallocate() // TODO: fix | causes reboots
}
func clearMemory(
    at address: UnsafeMutableRawPointer,
    count: Int
) {
    logger.log("clearMemory: executing...")
    let zero = SIMD64<UInt8>(repeating: 0) // 512-bit vector
    let pointer = unsafe address.assumingMemoryBound(to: SIMD64<UInt8>.self)
    for i in 0..<(count / 64) {
        unsafe pointer[i] = zero
    }
    logger.log("clearMemory: success")
}