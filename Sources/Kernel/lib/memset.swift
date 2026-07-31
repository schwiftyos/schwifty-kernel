
@_cdecl("memset")
@_optimize(none)
public func memset(_ s: UnsafeMutableRawPointer, _ c: Int32, _ n: Int) -> UnsafeMutableRawPointer {
    logger.log(staticString: "memset: executing...")
    let dest = unsafe s.assumingMemoryBound(to: UInt8.self)
    var i = 0
    while i < n {
        unsafe dest[i] = UInt8(c)
        i += 1
    }
    logger.log(staticString: "memset: finished")
    return unsafe s
}