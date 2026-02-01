
@_cdecl("posix_memalign")
public func posix_memalign(
    _ pointer: UnsafeMutablePointer<UnsafeMutableRawPointer?>,
    _ alignment: Int,
    _ size: Int
) -> Int32 {
    // simple hack for kernel: malloc a bit extra and align the pointer
    // in a production kernel, we'd use a buddy allocator
    let totalSize = size + alignment
    if let raw = unsafe malloc(totalSize) {
        let addr = Int(bitPattern: raw)
        let alignedAddr = (addr + alignment - 1) & ~(alignment - 1)
        unsafe pointer.pointee = UnsafeMutableRawPointer(bitPattern: alignedAddr)
        return 0
    }
    return 12 // ENOMEM
}