
@_cdecl("free")
public func free(_ pointer: UnsafeMutableRawPointer?) {
    logger.log("free: deallocating at X...")
    unsafe KernelHeap.shared.deallocate(pointer)
    logger.log("free: deallocated")
}