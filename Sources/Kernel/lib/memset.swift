
@_cdecl("memset")
public func memset(_ s: UnsafeMutableRawPointer, _ c: Int32, _ n: Int) -> UnsafeMutableRawPointer {
    logger.log("memset: executing...")
    let dest = unsafe s.assumingMemoryBound(to: UInt8.self)
    var i = 0
    while i < n {
        unsafe dest[i] = UInt8(c)
        i += 1
    }
    logger.log("memset: finished")
    return unsafe s
}