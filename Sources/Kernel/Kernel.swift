
nonisolated(unsafe) var nextRandom = UInt32(0x12345678)

/// Measured in bytes.
let heapSize = 1024 * 1024 // 1MiB
nonisolated(unsafe) var heapStart:UnsafeMutableRawPointer? = nil
nonisolated(unsafe) var heapFirstBlock:UnsafeMutablePointer<HeapMemoryBlock>? = nil

@_cdecl("kmain")
public func kmain(
    magic: UInt32,
    infoPointer: UInt
) {
    // check multiboot2 integrity
    guard magic == 0x36D76289 else {
        cpu_halt()
        return 
    }
    // check if we're in Protected Mode
    guard UInt.bitWidth == 32 else {
        cpu_halt()
        return
    }

    initKernel(infoPointer: infoPointer)

    while true {
        cpu_halt()
    }
}