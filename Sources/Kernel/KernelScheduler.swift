
typealias JobInvokeFunc = @convention(c) (UnsafeMutableRawPointer) -> Void

@safe
public final class KernelScheduler {
    public static nonisolated(unsafe) let shared = KernelScheduler()

    var queue = unsafe [UnsafeMutablePointer<Job>]()
}

// MARK: start
extension KernelScheduler {
    public func start() -> Never {
        logger.log("KernelScheduler: starting...")
        while true {
            if let job = unsafe queue.first {
                logger.log("KernelScheduler: running a job...")
                unsafe queue.removeFirst()
                unsafe runJob(job)
                logger.log("KernelScheduler: job finished")
            } else {
                logger.log("KernelScheduler: halting cpu; waiting for interrupt...")
                cpu_halt()
            }
            while let keyEvent = unsafe keyboardBuffer.pop() {
                logger.logRaw("KernelScheduler: keyboard key=")
                logger.logRaw(keyEvent.key.name)
                logger.logRaw(";pressed=")
                logger.logRaw("\(keyEvent.pressed)")
                logger.logRaw(10)
            }
        }
    }
}


// MARK: run job
extension KernelScheduler {
    func runJob(_ job: UnsafeMutablePointer<Job>) {
        let jobRaw = UnsafeMutableRawPointer(job)
        let invokeFnPtr = unsafe jobRaw
            .advanced(by: MemoryLayout<Int>.size * 2)
            .assumingMemoryBound(to: JobInvokeFunc.self)
            .pointee
        unsafe invokeFnPtr(jobRaw)
    }
}

// MARK: enqueue
extension KernelScheduler {
    func enqueue(_ job: UnsafeMutablePointer<Job>) {
        unsafe queue.append(job)
    }
}