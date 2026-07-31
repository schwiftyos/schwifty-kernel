
@_cdecl("memcpy")
public func memcpy(_ dest: UnsafeMutableRawPointer, _ src: UnsafeRawPointer, _ n: Int) -> UnsafeMutableRawPointer {
    logger.log(staticString: "memcpy: executing...")
    let d = unsafe dest.assumingMemoryBound(to: UInt8.self)
    let s = unsafe src.assumingMemoryBound(to: UInt8.self)
    var i = 0
    while i < n {
        unsafe d[i] = s[i]
        i += 1
    }
    logger.log(staticString: "memcpy: finished")
    return unsafe dest
}