
nonisolated(unsafe) var nextRandom = UInt32(0x12345678)

/// Measured in bytes.
let maximumStackSize = 8192 // 8KiB

/// Measured in bytes.
let heapSize = 1024 * 1024 // 1MiB
nonisolated(unsafe) var heapStart:UnsafeMutableRawPointer? = nil
nonisolated(unsafe) var heapFirstBlock:UnsafeMutablePointer<HeapMemoryBlock>? = nil

/// Active thread index being executed.
nonisolated(unsafe) var currentThreadIndex = 0
nonisolated(unsafe) var threads = [ThreadControlBlock]()

let vgaDriver = VGADriver<80, 25>()

@_cdecl("kmain")
public func kmain(
    magic: UInt32,
    infoPointer: UInt32
) {
    initKernel()
    vgaDriver.clearScreen()
    vgaDriver.write("holy shmoly", y: 3, color: 0x0A)
    vgaDriver.write(StaticString("SchwiftyOS"), color: 0x0A)

    var set = Set<Int>()
    //set.insert(1) // TODO: fix | causes reboots

    if set.contains(1) {
        vgaDriver.write(StaticString("Set contains 1"), y: 1)
    } else {
        vgaDriver.write(StaticString("Set !contains 1"), y: 1)
    }

    while true {
        cpu_halt()
    }
}