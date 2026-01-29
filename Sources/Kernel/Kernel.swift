
private nonisolated(unsafe) var nextRandom = UInt32(0x12345678)

/// Measured in bytes.
private let maximumStackSize = 8192 // 8KiB

/// Measured in bytes.
private let heapSize = 1024 * 1024 // 1MiB
private nonisolated(unsafe) var heapStart:UnsafeMutableRawPointer? = nil
private nonisolated(unsafe) var heapFirstBlock:UnsafeMutablePointer<HeapMemoryBlock>? = nil

/// Active thread index being executed.
private nonisolated(unsafe) var currentThreadIndex = 0
private nonisolated(unsafe) var threads = [ThreadControlBlock]()

let vgaDriver = VGADriver<80, 25>()

@_cdecl("kmain")
public func kmain(
    magic: UInt32,
    infoPointer: UInt32
) {
    initRandom()
    initHeap()
    initMultitasking()
    vgaClearBuffer()
    //vgaDriver.clearScreen() // TODO: fix | causes reboots

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

func vgaClearBuffer() {
    for x in 0..<85 {
        for y in 0..<25 {
            vgaDriver.write(value: 0x0720, x: x, y: y)
        }
    }
}

// MARK: Init heap
@_cdecl("kernel_heap_init")
public func initHeap() {
    // in a production/real kernel, we'd get this from our memory map (Multiboot)
    // for now, we'll use a static buffer
    let buffer = UnsafeMutableRawPointer.allocate(byteCount: heapSize, alignment: 4096)
    unsafe heapStart = buffer
    
    unsafe heapFirstBlock = buffer.assumingMemoryBound(to: HeapMemoryBlock.self)
    unsafe heapFirstBlock?.pointee = HeapMemoryBlock(
        size: heapSize - MemoryLayout<HeapMemoryBlock>.size,
        isFree: true,
        next: nil
    )
}

// MARK: Init multitasking
func initMultitasking() {
    unsafe threads.reserveCapacity(6)
    // TODO: fix | causes reboots
    /*
    let mainThread = unsafe ThreadControlBlock(
        stackPointer: UnsafeMutableRawPointer(bitPattern: 0)!, // overwritten on first yield
        id: 0,
        state: .running
    )
    unsafe threads.append(mainThread)*/
}

// MARK: Init random
func initRandom() {
    unsafe nextRandom = UInt32(truncatingIfNeeded: rdtsc())
}

// MARK: C helpers

@_cdecl("memset")
public func memset(_ s: UnsafeMutableRawPointer, _ c: Int32, _ n: Int) -> UnsafeMutableRawPointer {
    let dest = unsafe s.assumingMemoryBound(to: UInt8.self)
    var i = 0
    while i < n {
        unsafe dest[i] = UInt8(c)
        i += 1
    }
    return unsafe s
}

@_cdecl("memmove")
public func memmove(_ dest: UnsafeMutableRawPointer, _ src: UnsafeRawPointer, _ n: Int) -> UnsafeMutableRawPointer {
    let d = unsafe dest.assumingMemoryBound(to: UInt8.self)
    let s = unsafe src.assumingMemoryBound(to: UInt8.self)
    if unsafe d < s {
        for i in 0..<n {
            unsafe d[i] = s[i]
        }
    } else {
        for i in (0..<n).reversed() {
            unsafe d[i] = s[i]
        }
    }
    return unsafe dest
}

@_cdecl("memcpy")
public func memcpy(_ dest: UnsafeMutableRawPointer, _ src: UnsafeRawPointer, _ n: Int) -> UnsafeMutableRawPointer {
    let d = unsafe dest.assumingMemoryBound(to: UInt8.self)
    let s = unsafe src.assumingMemoryBound(to: UInt8.self)
    var i = 0
    while i < n {
        unsafe d[i] = s[i]
        i += 1
    }
    return unsafe dest
}

// MARK: free
@_cdecl("free")
public func free(_ pointer: UnsafeMutableRawPointer?) {
    guard let pointer = unsafe pointer else { return }
    
    // move pointer back to find the header
    let blockPtr = unsafe (pointer - MemoryLayout<HeapMemoryBlock>.size).assumingMemoryBound(to: HeapMemoryBlock.self)
    unsafe blockPtr.pointee.isFree = true
    
    // simple Coalescing: merge with next free block
    if let next = unsafe blockPtr.pointee.next, unsafe next.pointee.isFree {
        unsafe blockPtr.pointee.size += MemoryLayout<HeapMemoryBlock>.size + next.pointee.size
        unsafe blockPtr.pointee.next = next.pointee.next
    }
}

// MARK: malloc
@_cdecl("malloc")
public func malloc(_ size: Int) -> UnsafeMutableRawPointer? {
    var current = unsafe heapFirstBlock
    while let block = unsafe current {
        if unsafe block.pointee.isFree && block.pointee.size >= size {
            // split block if there's enough room for a new header + 1 byte
            if unsafe block.pointee.size > (size + MemoryLayout<HeapMemoryBlock>.size + 8) {
                let newBlockPtr = unsafe UnsafeMutableRawPointer(block) + MemoryLayout<HeapMemoryBlock>.size + size
                let nextBlock = unsafe newBlockPtr.assumingMemoryBound(to: HeapMemoryBlock.self)
                unsafe nextBlock.pointee = HeapMemoryBlock(
                    size: block.pointee.size - size - MemoryLayout<HeapMemoryBlock>.size,
                    isFree: true,
                    next: block.pointee.next
                )
                unsafe block.pointee.size = size
                unsafe block.pointee.next = nextBlock
            }
            unsafe block.pointee.isFree = false
            // return pointer to memory right AFTER the header
            return unsafe UnsafeMutableRawPointer(block) + MemoryLayout<HeapMemoryBlock>.size
        }
        unsafe current = block.pointee.next
    }
    return nil // out of memory
}

// MARK: posix_memalign
@_cdecl("posix_memalign")
public func posix_memalign(
    _ pointer: UnsafeMutablePointer<UnsafeMutableRawPointer?>,
    _ alignment: Int,
    _ size: Int
) -> Int32 {
    // simple hack for kernel: malloc a bit extra and align the pointer
    // in a production kernel, we'd use a buddy allocator for this.
    let totalSize = size + alignment
    if let raw = unsafe malloc(totalSize) {
        let addr = Int(bitPattern: raw)
        let alignedAddr = (addr + alignment - 1) & ~(alignment - 1)
        unsafe pointer.pointee = UnsafeMutableRawPointer(bitPattern: alignedAddr)
        return 0
    }
    return 12 // ENOMEM
}

// MARK: swift_allocObject
@_cdecl("swift_allocObject")
public func swift_allocObject(
    metadata: UnsafeRawPointer,
    requiredSize: Int,
    requiredAlignmentMask: Int
) -> UnsafeMutableRawPointer? {
    // alignment mask = (alignment - 1)
    var ptr: UnsafeMutableRawPointer? = nil
    _ = unsafe posix_memalign(&ptr, requiredAlignmentMask + 1, requiredSize)
    return unsafe ptr
}

// MARK: swift_deallocObject
@_cdecl("swift_deallocObject")
public func swift_deallocObject(
    object: UnsafeMutableRawPointer,
    allocatedSize: Int,
    allocatedAlignMask: Int
) {
    unsafe free(object)
}

// MARK: arc4random_buf
@_cdecl("arc4random_buf")
public func arc4random_buf(
    _ buffer: UnsafeMutableRawPointer,
    _ nbytes: Int
) {
    let dest = unsafe buffer.assumingMemoryBound(to: UInt8.self)
    for i in 0..<nbytes {
        let val = read_rdrand()
        if i % 4 == 0 {
            unsafe dest[i] = UInt8(val & 0xFF)
        } else {
            unsafe dest[i] = UInt8((val >> 8) & 0xFF)
        }
    }
}

// MARK: arc4random
@_cdecl("arc4random")
public func arc4random() -> UInt32 {
    var val: UInt32 = 0
    unsafe arc4random_buf(&val, MemoryLayout<UInt32>.size)
    return val
}

// MARK: __ashldi3
@_cdecl("__ashldi3")
public func __ashldi3(
    value: UInt64,
    count: Int32
) -> UInt64 {
    if count == 0 {
        return value
    }
    let low = UInt32(value & 0xFFFFFFFF)
    let high = UInt32(value >> 32)
    if count >= 32 {
        let newHigh = low << (count - 32)
        return UInt64(newHigh) << 32
    } else {
        let newLow = low << count
        let newHigh = (high << count) | (low >> (32 - count))
        return (UInt64(newHigh) << 32) | UInt64(newLow)
    }
}

// MARK: __lshrdi3
@_cdecl("__lshrdi3")
public func __lshrdi3(
    value: UInt64,
    count: Int32
) -> UInt64 {
    if count == 0 {
        return value
    }
    let low = UInt32(value & 0xFFFFFFFF)
    let high = UInt32(value >> 32)
    if count >= 32 {
        let newLow = high >> (count - 32)
        return UInt64(newLow)
    } else {
        let newHigh = high >> count
        let newLow = (low >> count) | (high << (32 - count))
        return (UInt64(newHigh) << 32) | UInt64(newLow)
    }
}

// MARK: __ashrdi3
@_cdecl("__ashrdi3")
public func __ashrdi3(value: Int64, count: Int32) -> Int64 {
    if count == 0 {
        return value
    }
    let bits = UInt64(bitPattern: value)
    let low = UInt32(bits & 0xFFFFFFFF)
    let high = Int32(bitPattern: UInt32(bits >> 32))
    if count >= 32 {
        let newHigh = high >> 31
        let newLow = high >> (count - 32)
        let resultBits = (UInt64(UInt32(bitPattern: newHigh)) << 32) | UInt64(UInt32(bitPattern: newLow))
        return Int64(bitPattern: resultBits)
    } else {
        let newHigh = high >> count
        let newLow = (low >> count) | (UInt32(bitPattern: high) << (32 - count))
        let resultBits = (UInt64(UInt32(bitPattern: newHigh)) << 32) | UInt64(newLow)
        return Int64(bitPattern: resultBits)
    }
}

// MARK: ceil
@_cdecl("ceil")
public func ceil(_ x: Double) -> Double {
    guard x.isFinite else { return x }
    let truncated = Double(Int64(x))
    if x > 0 && x > truncated {
        // x is positive and has a fractional part; round up
        return truncated + 1.0
    }
    // x is negative; already truncated
    return truncated
}

// MARK: ceilf
@_cdecl("ceilf")
public func ceilf(_ x: Float) -> Float {
    return Float(ceil(Double(x)))
}

// MARK: Create thread
func createThread(
    entryPoint: @escaping () -> Void
) -> Int {
    let stackBase = unsafe malloc(maximumStackSize)!
    var stackPointer = unsafe stackBase + maximumStackSize
    // ensure alignment
    let spAddr = Int(bitPattern: stackPointer)
    unsafe stackPointer = UnsafeMutableRawPointer(bitPattern: spAddr & ~0xF)!

    // push the entry point onto the stack
    let registerCount = 5
    unsafe stackPointer -= (registerCount * MemoryLayout<UInt32>.size)

    let frame = unsafe stackPointer.assumingMemoryBound(to: UInt32.self)
    unsafe frame[6] = UInt32(UInt(bitPattern: unsafeBitCast(entryPoint, to: UnsafeRawPointer.self)))

    // flush registers
    for i in 0..<4 {
        unsafe frame[i] = 0
    }

    let thread = unsafe ThreadControlBlock(
        stackPointer: frame,
        id: threads.count,
        state: .ready
    )
    unsafe threads.append(thread)
    return thread.id
}

// MARK: Yield
@_cdecl("yield")
func yield() {
    let current = unsafe threads[currentThreadIndex]
    // find the next thread in the 'Ready' queue
    // for 1:1 pinning, this might just be the 'next' task in a simple circular list
    let next = unsafe (current.id + 1) % threads.count
    let nextThread = unsafe threads[next]
    unsafe currentThreadIndex = next
    unsafe switch_threads(current.stackPointer, nextThread.stackPointer)
}

// MARK: Externs
@_extern(c, "cpu_halt")
func cpu_halt()

@_extern(c, "read_rdrand")
func read_rdrand() -> UInt32

@_extern(c, "rdtsc")
func rdtsc() -> UInt32

@_extern(c, "outb")
func outb(_ port: UInt16, _ value: UInt8)

@_extern(c, "inb")
func inb(_ port: UInt16) -> UInt8

@_extern(c, "switch_threads")
func switch_threads(_ old: UnsafeRawPointer, _ new: UnsafeRawPointer)

// MARK: VGA Driver
struct VGADriver<let width: Int, let height: Int> {
    // use a computed property to get a fresh pointer every time
    // to prevent the compiler from caching a stale value
    private var buffer: UnsafeMutablePointer<UInt16> {
        return unsafe UnsafeMutablePointer<UInt16>(bitPattern: 0xB8000)!
    }

    func write(
        char: UnicodeScalar,
        x: Int,
        y: Int,
        color: UInt8 = 0x07
    ) {
        write(value: (UInt16(color) << 8) | UInt16(char.value), x: x, y: y)
    }
    func write(
        value: UInt16,
        x: Int,
        y: Int,
        color: UInt8 = 0x07
    ) {
        let index = y * width + x
        unsafe buffer[index] = value
    }

    func clearScreen() {
        for x in 0..<width {
            for y in 0..<height {
                write(value: 0x0720, x: x, y: y)
            }
        }
    }

    func write(
        _ message: StaticString,
        x: Int = 0,
        y: Int = 0,
        color: UInt8 = 0x07
    ) {
        var vgaBufferIndex = y * width + x
        message.withUTF8Buffer {
            for unsafe char in unsafe $0 {
                unsafe buffer[vgaBufferIndex] = (UInt16(color) << 8) | UInt16(char)
                vgaBufferIndex += 1
            }
        }
    }
    func write(
        _ message: String,
        x: Int = 0,
        y: Int = 0,
        color: UInt8 = 0x07
    ) {
        var i = 0
        var vgaBufferIndex = y * width + x
        unsafe message.withCString { ptr in
            while unsafe ptr[i] != 0 {
                let char = unsafe ptr[i]
                unsafe buffer[vgaBufferIndex] = (UInt16(color) << 8) | UInt16(char)
                vgaBufferIndex += 1
                i += 1
            }
        }
    }
}

// MARK: HeapMemoryBlock
@unsafe
struct HeapMemoryBlock {
    var size:Int
    var isFree:Bool
    var next:UnsafeMutablePointer<HeapMemoryBlock>?
}

// MARK: Thread Control Block
struct ThreadControlBlock {
    var stackPointer:UnsafeMutableRawPointer
    var id:Int
    var state:State

    enum State { // TODO: fix: missing hash (and random) logic due to automatic conformance
        case ready
        case running
        case blocked
    }
}