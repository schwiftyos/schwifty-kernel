
final class BumpAllocator {
    var nextFree:UInt
    let limit:UInt

    init(
        start: UInt,
        size: UInt
    ) {
        self.nextFree = start
        self.limit = start + size
    }
}

// MARK: Allocate
extension BumpAllocator {
    func allocate(
        size: Int,
        alignment: Int
    ) -> UnsafeMutableRawPointer? {
        // round up to alignment
        let aligned = (nextFree + UInt(alignment) - 1) & ~(UInt(alignment) - 1)
        if aligned + UInt(size) > limit {
            return nil
        }
        
        let pointer = unsafe UnsafeMutableRawPointer(bitPattern: aligned)
        nextFree = aligned + UInt(size)
        return unsafe pointer
    }
}