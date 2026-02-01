
/// Measured in bytes.
let heapSize = 1024 * 1024 // 1MiB
nonisolated(unsafe) var heapStart:UnsafeMutableRawPointer? = nil
nonisolated(unsafe) var heapFirstBlock:UnsafeMutablePointer<HeapMemoryBlock>? = nil

@_cdecl("kmain")
public func kmain(
    infoPointer: UInt
) {
    initKernel(infoPointer: infoPointer)

    while true {
        cpu_halt()
    }
}