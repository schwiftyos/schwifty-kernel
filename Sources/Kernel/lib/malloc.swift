
@_cdecl("malloc")
public func malloc(_ size: Int) -> UnsafeMutableRawPointer? {
    let ptr = unsafe KernelHeap.shared.allocate(size: size)
    if unsafe ptr == nil {
        logger.log("malloc: failed")
    } else {
        logger.log("malloc: succeeded")
    }
    return unsafe ptr
}