
@_cdecl("malloc")
public func malloc(_ size: Int) -> UnsafeMutableRawPointer? {
    let pointer = unsafe KernelHeap.shared.allocate(size: size)
    if unsafe pointer == nil {
        logger.log(staticString: "malloc: failed")
    } else {
        logger.log(staticString: "malloc: succeeded")
    }
    return unsafe pointer
}