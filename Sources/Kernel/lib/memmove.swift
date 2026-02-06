
@_cdecl("memmove")
public func memmove(_ dest: UnsafeMutableRawPointer, _ src: UnsafeRawPointer, _ n: Int) -> UnsafeMutableRawPointer {
    logger.log("memmove: executing...")
    let d = unsafe dest.assumingMemoryBound(to: UInt8.self)
    let s = unsafe src.assumingMemoryBound(to: UInt8.self)
    if unsafe d < s {
        for i in 0..<n {
            unsafe d[i] = s[i]
        }
    } else {
        for i in (0..<n).reversed() {
            unsafe d[i] = s[i]
        }
    }
    logger.log("memmove: finished")
    return unsafe dest
}