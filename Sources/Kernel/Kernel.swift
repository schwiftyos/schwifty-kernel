
@_cdecl("kmain")
public func kmain(
    infoPointer: UnsafeRawPointer
) {
    logger.log(staticString: "kmain: executing...")

    //unsafe LocalAPIC.shared.testTimer()

    testSIMD()
    unsafe KernelHeap.shared.verify(amount: 9)

    logger.log(staticString: "kmain: executed")
    unsafe KernelScheduler.shared.start()
}

func testSIMD() {
    logger.log(staticString: "testSIMD: testing...")
    let bro = UnsafeMutableRawPointer.allocate(byteCount: 1024, alignment: 16)
    unsafe bro.initializeMemory(as: UInt64.self, repeating: 3, count: 16)
    unsafe clearMemory(at: bro, count: 1024)
    unsafe bro.deallocate()
    logger.log(staticString: "testSIMD: success")
}
func clearMemory(
    at address: UnsafeMutableRawPointer,
    count: Int
) {
    logger.log(staticString: "clearMemory: executing...")
    let zero = SIMD64<UInt8>(repeating: 0) // 512-bit vector
    let pointer = unsafe address.assumingMemoryBound(to: SIMD64<UInt8>.self)
    for i in 0..<(count / 64) {
        unsafe pointer[i] = zero
    }
    logger.log(staticString: "clearMemory: success")
}

/*
func testConcurrency() {
    logger.log(staticString: "testConcurrency: testing...")
    logger.log(staticString: "testConcurrency: success")
}
struct ConcurrencyTest: ~Copyable {
    func test() async {} // TODO: report: crashes compiler
}*/