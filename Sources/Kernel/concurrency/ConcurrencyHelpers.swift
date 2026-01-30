
@_silgen_name("swift_task_enqueueGlobal")
func swift_task_enqueueGlobal(job: UnsafeMutablePointer<Job>) {
    // add job to kernel's scheduler run queue
    //scheduler.shared.enqueue(job)
}

// Minimal implementation of task memory management
@_cdecl("swift_task_alloc")
func swift_task_alloc(size: Int) -> UnsafeMutableRawPointer? {
    return unsafe malloc(size)
}

@_cdecl("swift_task_dealloc")
func swift_task_dealloc(_ pointer: UnsafeMutableRawPointer) {
    unsafe free(pointer)
}