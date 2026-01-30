
@safe
struct KernelThread {
    var stackPointer:UnsafeMutableRawPointer
    let id:Int
    private var tasks:[KernelTask]
    private var currentTaskIndex:Int
    private(set) var state:State

    init(
        stackPointer: UnsafeMutableRawPointer,
        id: Int,
        state: State,
        tasks: [KernelTask] = [],
        currentTaskIndex: Int = 0
    ) {
        unsafe self.stackPointer = stackPointer
        self.id = id
        self.state = state
        self.tasks = tasks
        self.currentTaskIndex = currentTaskIndex
    }
}

// MARK: State
extension KernelThread {
    enum State {
        case ready
        case running
        case blocked
    }
}

// MARK: Schedule next
extension KernelThread {
    mutating func scheduleNext() {
        let oldIndex = currentTaskIndex
        currentTaskIndex = (currentTaskIndex + 1) % tasks.count

        let oldPointer = unsafe tasks[oldIndex].stackPointer
        let newPointer = unsafe tasks[currentTaskIndex].stackPointer
        unsafe context_switch(oldPointer, newPointer)
    }
}

// MARK: Submit task
extension KernelThread {
    mutating func submitTask(
        entryPoint: @convention(c) () -> Void,
        stackBottom: UnsafeMutableRawPointer
    ) -> KernelTask {
        var stack = unsafe (stackBottom + maximumStackSize).assumingMemoryBound(to: UInt32.self)
        
        // push EIP (Entry Point)
        unsafe stack = stack.advanced(by: -1)
        unsafe stack.pointee = UInt32(bitPattern: Int32(truncatingIfNeeded: Int(bitPattern: UnsafeRawPointer(bitPattern: unsafeBitCast(entryPoint, to: Int.self)))))
        
        // push EFLAGS (0x202 enables interrupts)
        unsafe stack = stack.advanced(by: -1)
        unsafe stack.pointee = 0x202
        
        // flush registers
        for _ in 0..<7 {
            unsafe stack = stack.advanced(by: -1)
            unsafe stack.pointee = 0
        }
        let task = unsafe KernelTask(
            stackPointer: stack,
            id: threads.count,
            state: .ready
        )
        tasks.append(task)
        return task
    }
}

// MARK: Create thread
func createThread(
    entryPoint: @convention(c) () -> Void
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

    let thread = unsafe KernelThread(
        stackPointer: frame,
        id: threads.count,
        state: .ready
    )
    unsafe threads.append(thread)
    return thread.id
}