
@_cdecl("malloc")
public func malloc(_ size: Int) -> UnsafeMutableRawPointer? {
    logger.log("malloc: trying to allocate X bytes...")
    let ptr = unsafe KernelHeap.shared.allocate(size: size)
    if unsafe ptr == nil {
        logger.log("malloc: failed")
    } else {
        logger.log("malloc: succeeded")
    }
    return unsafe ptr
}