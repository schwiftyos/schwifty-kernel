
@_cdecl("posix_memalign")
public func posix_memalign(
    _ pointer: UnsafeMutablePointer<UnsafeMutableRawPointer?>,
    _ alignment: Int,
    _ size: Int
) -> Int32 {
    logger.log(staticString: "posix_memalign: executing...")
    // alignment must be a power of 2 and a multiple of a pointer's size
    guard unsafe alignment.isPowerOfTwo && alignment >= MemoryLayout<UnsafeRawPointer>.size else {
        logger.log(staticString: "posix_memalign: errno 22")
        return 22 // EINVAL
    }
    if let newPointer = unsafe KernelHeap.shared.allocate(size: size, alignment: alignment) {
        unsafe pointer.pointee = newPointer
        logger.log(staticString: "posix_memalign: success")
        return 0
    }
    logger.log(staticString: "posix_memalign: errno 12")
    return 12 // ENOMEM
}