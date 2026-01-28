
private let heapSize = 1024 * 1024 // 1MiB heap
private nonisolated(unsafe) var heapStart:UnsafeMutableRawPointer? = nil
private nonisolated(unsafe) var firstBlock:UnsafeMutablePointer<MemoryBlock>? = nil

//private nonisolated(unsafe) var threads:UnsafeMutableBufferPointer<ThreadControlBlock>? = nil

let vgaDriver = VGADriver<80, 25>()

@_cdecl("kmain")
public func kmain(magic: UInt32, infoPointer: UInt32) {
    //threads = .allocate(capacity: 1)
    kernelHeapInit()
    vgaClearBuffer()
    //vgaDriver.clearScreen() // causes reboots

    var list = [UInt16]()
    for i in 0..<10 {
        list.append(UInt16(i)) // triggers malloc/realloc, testing heap integrity and validity
    }

    vgaDriver.write("holy shmoly", y: 3, color: 0x0A)

    let operatingSystem = StaticString("SchwiftyOS")
    vgaDriver.write(operatingSystem, color: 0x0A)
    
    let msg = StaticString("Hello World!")
    vgaDriver.write(msg, y: 1)
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
public func kernelHeapInit() {
    // in a production/real kernel, we'd get this from our memory map (Multiboot)
    // for now, we'll use a static buffer
    let buffer = UnsafeMutableRawPointer.allocate(byteCount: heapSize, alignment: 4096)
    unsafe heapStart = buffer
    
    unsafe firstBlock = buffer.assumingMemoryBound(to: MemoryBlock.self)
    unsafe firstBlock?.pointee = MemoryBlock(
        size: heapSize - MemoryLayout<MemoryBlock>.size,
        isFree: true,
        next: nil
    )
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
    let blockPtr = unsafe (pointer - MemoryLayout<MemoryBlock>.size).assumingMemoryBound(to: MemoryBlock.self)
    unsafe blockPtr.pointee.isFree = true
    
    // simple Coalescing: merge with next free block
    if let next = unsafe blockPtr.pointee.next, unsafe next.pointee.isFree {
        unsafe blockPtr.pointee.size += MemoryLayout<MemoryBlock>.size + next.pointee.size
        unsafe blockPtr.pointee.next = next.pointee.next
    }
}

// MARK: malloc
@_cdecl("malloc")
public func malloc(_ size: Int) -> UnsafeMutableRawPointer? {
    var current = unsafe firstBlock
    while let block = unsafe current {
        if unsafe block.pointee.isFree && block.pointee.size >= size {
            // split block if there's enough room for a new header + 1 byte
            if unsafe block.pointee.size > (size + MemoryLayout<MemoryBlock>.size + 8) {
                let newBlockPtr = unsafe UnsafeMutableRawPointer(block) + MemoryLayout<MemoryBlock>.size + size
                let nextBlock = unsafe newBlockPtr.assumingMemoryBound(to: MemoryBlock.self)
                unsafe nextBlock.pointee = MemoryBlock(
                    size: block.pointee.size - size - MemoryLayout<MemoryBlock>.size,
                    isFree: true,
                    next: block.pointee.next
                )
                unsafe block.pointee.size = size
                unsafe block.pointee.next = nextBlock
            }
            unsafe block.pointee.isFree = false
            // return pointer to memory right AFTER the header
            return unsafe UnsafeMutableRawPointer(block) + MemoryLayout<MemoryBlock>.size
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

/*
// MARK: Create thread
func createThread(
    entryPoint: @escaping () -> Void
) -> ThreadControlBlock {
    let stackSize = 4096
    let stackBase = malloc(stackSize)!
    var stackPointer = stackBase + stackSize
    // push the entry point onto the stack
    stackPointer -= MemoryLayout<UnsafeRawPointer>.size
    stackPointer.storeBytes(of: unsafeBitCast(entryPoint, to: UnsafeRawPointer.self), as: UnsafeRawPointer.self)
    let block = ThreadControlBlock(
        stackPointer: stackPointer,
        id: threads!.count,
        state: .ready
    )
    threads![threads!.count] = block
    return block
}

// MARK: Yield
@_cdecl("yield")
func yield() {
    guard let currentT = currentThread else { return }
    // find the next thread in the 'Ready' queue
    // for 1:1 pinning, this might just be the 'next' task in a simple circular list
    let next = getNextReadyThread() 
    if next.id == currentT.pointee.id {
        // no other tasks to run
        return
    }
    // perform the magic switch
    let oldThread = currentT
    currentThread = next
    switch_threads(&oldThread.pointee.stackPointer, next.pointee.stackPointer)
}*/

// MARK: Externs
@_extern(c, "cpu_halt")
func cpu_halt()

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

// MARK: MemoryBlock
@unsafe
struct MemoryBlock {
    var size:Int
    var isFree:Bool
    var next:UnsafeMutablePointer<MemoryBlock>?
}

/*
// MARK: Thread Local Data
struct ThreadLocalData {
    var selfPointer:UnsafeMutableRawPointer?
    var threadID:Int
    var coreID:Int
    var taskCount:Int
    var lastYieldTime:UInt64
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
}*/

// MARK: Test
final class Test {
    var bro = 0

    func increment() {
        bro += 1
    }

    func decrement() {
        bro -= 1
    }
}