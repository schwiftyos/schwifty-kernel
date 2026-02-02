
/// Measured in bytes.
let heapSize = 1024 * 1024 // 1MiB
nonisolated(unsafe) var heapStart:UnsafeMutableRawPointer? = nil
nonisolated(unsafe) var heapFirstBlock:UnsafeMutablePointer<HeapMemoryBlock>? = nil

@_cdecl("kmain")
public func kmain(
    infoPointer: UnsafeRawPointer
) {
    UART.initialize()
    unsafe initKernel(infoPointer: infoPointer)

    logger.log("kmain: halting CPU")
    while true {
        cpu_halt()
    }
}