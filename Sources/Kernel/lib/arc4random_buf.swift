
@_extern(c, "rdrand")
private func rdrand(_ value: UnsafeMutablePointer<UInt64>) -> UInt64

func random64() -> UInt64? {
    var value:UInt64 = 0
    if unsafe rdrand(&value) == 1 {
        return value
    }
    return nil
}

@_cdecl("arc4random_buf")
public func arc4random_buf(
    pointer: UnsafeMutableRawPointer,
    nbytes: Int
) {
    var remaining = nbytes
    var current = unsafe pointer.bindMemory(to: UInt8.self, capacity: nbytes)
    while remaining > 0 {
        guard let value = random64() else {
            // TODO: if hardware fails, fallback to a PRNG (like ChaCha20) or panic if this is a security-critical kernel task
            continue 
        }
        let chunk = min(remaining, 8)
        unsafe withUnsafePointer(to: value) {
            let rawValuePointer = unsafe UnsafeRawPointer($0)
            unsafe current.update(from: rawValuePointer.assumingMemoryBound(to: UInt8.self), count: chunk)
        }
        unsafe current += chunk
        remaining -= chunk
    }
}