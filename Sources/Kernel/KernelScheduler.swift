
typealias JobInvokeFunc = @convention(c) (UnsafeMutableRawPointer) -> Void

@safe
public final class KernelScheduler {
    public static nonisolated(unsafe) let shared = KernelScheduler()

    var queue = unsafe [UnsafeMutablePointer<Job>]()
}

// MARK: start
extension KernelScheduler {
    public func start() -> Never {
        logger.log(staticString: "KernelScheduler: starting...")
        while true {
            if let job = unsafe queue.first {
                logger.log(staticString: "KernelScheduler: running a job...")
                unsafe queue.removeFirst()
                unsafe runJob(job)
                logger.log(staticString: "KernelScheduler: job finished")
            } else {
                logger.log(staticString: "KernelScheduler: halting cpu; waiting for interrupt...")
                cpu_halt()
            }

            if !keyEventQueue.isEmpty {
                #if LogKeyEvents
                logger.log(staticString: "KernelScheduler: popping all key events...")
                #endif

                keyEventQueue.popAllUnchecked({ events in
                    for i in events.indices {
                        events[i].log()
                    }

                    // TODO: propagate key events to consumers
                })
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