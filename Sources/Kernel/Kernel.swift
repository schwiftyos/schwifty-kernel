
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

    logger.log("kmain: creating set...")
    var set = Set<Int>()
    logger.log("kmain: set created")

    logger.log("kmain: inserting 1 into set...")
    set.insert(1)
    logger.log("kmain: inserted 1 into set")
    if set.contains(1) {
        logger.log("set.contains(1)")
    } else {
        logger.log("!set.contains(1)")
    }

    logger.log("kmain: halting CPU")
    while true {
        cpu_halt()
    }
}