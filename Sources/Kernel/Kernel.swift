
nonisolated(unsafe) var nextRandom = UInt32(0x12345678)

/// Measured in bytes.
let maximumStackSize = 8192 // 8KiB

/// Measured in bytes.
let heapSize = 1024 * 1024 // 1MiB
nonisolated(unsafe) var heapStart:UnsafeMutableRawPointer? = nil
nonisolated(unsafe) var heapFirstBlock:UnsafeMutablePointer<HeapMemoryBlock>? = nil

/// Active thread index being executed.
nonisolated(unsafe) var currentThreadIndex = 0
nonisolated(unsafe) var threads = [KernelThread]()

let vgaDriver = VGADriver<80, 25>()

@_cdecl("kmain")
public func kmain(
    magic: UInt32,
    infoPointer: UInt32
) {
    guard magic == 0x36D76289 else {
        cpu_halt()
        return 
    }
    initKernel(infoPointer: infoPointer)
    cpu_halt()
    return;

    vgaDriver.clearScreen()
    vgaDriver.write(StaticString("SchwiftyOS"), color: 0x0A)

    //testSet()
    writeCPUStatuses()

    while true {
        cpu_halt()
    }
}

private func testSet() {
    var set = Set<Int>()
    set.insert(1) // TODO: fix | causes reboots (likely due to being in Real Mode; we need to be in Protected Mode)

    if set.contains(1) {
        vgaDriver.write(StaticString("Set contains 1"), y: 1)
    } else {
        vgaDriver.write(StaticString("Set !contains 1"), y: 1)
    }
}

private func writeCPUStatuses() {
    if isProtectedMode() {
        vgaDriver.write(StaticString("PROTECTED MODE: TRUE"), y: 2)
    } else {
        vgaDriver.write(StaticString("PROTECTED MODE: FALSE"), y: 2)
    }

    if isPagingEnabled() {
        vgaDriver.write(StaticString("PAGING: TRUE"), y: 3)
    } else {
        vgaDriver.write(StaticString("PAGING: FALSE"), y: 3)
    }

    if isLongMode() {
        vgaDriver.write(StaticString("LONG MODE: TRUE"), y: 4)
    } else {
        vgaDriver.write(StaticString("LONG MODE: FALSE"), y: 4)
    }

    switch currentPrivilegeLevel() {
    case 0:  vgaDriver.write(StaticString("PRIVILEGE LEVEL: Kernel"),  y: 5)
    case 3:  vgaDriver.write(StaticString("PRIVILEGE LEVEL: User"),    y: 5)
    default: vgaDriver.write(StaticString("PRIVILEGE LEVEL: Unknown"), y: 5)
    }
}