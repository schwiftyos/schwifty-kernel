
@_cdecl("free")
public func free(_ pointer: UnsafeMutableRawPointer?) {
    logger.log(staticString: "free: deallocating at X...")
    unsafe KernelHeap.shared.deallocate(pointer)
    logger.log(staticString: "free: deallocated")
}