
@safe
final class BuddyAllocator {
    private let baseAddress:UInt
    private let maxOrder = 11 // max block = 4KiB * 2^11 = 8MiB
    private let minBlockSize = 4096 // 4 KiB
    private var freeLists:UnsafeMutablePointer<UnsafeMutableRawPointer?>

    public init(
        start: UInt,
        size: UInt
    ) {
        self.baseAddress = start
        
        // Allocate space for the free list headers (using a tiny bit of the start)
        let headerSize = unsafe MemoryLayout<UnsafeMutableRawPointer?>.stride * (maxOrder + 1)
        unsafe self.freeLists = UnsafeMutablePointer<UnsafeMutableRawPointer?>.allocate(capacity: maxOrder + 1)
        unsafe self.freeLists.initialize(repeating: nil, count: maxOrder + 1)
        
        // Initially, treat the whole chunk as one big block at the highest order
        // (Simplified: assumes size is a power of 2)
        unsafe addBlock(
            order: maxOrder,
            pointer: UnsafeMutableRawPointer(bitPattern: start + UInt(headerSize))!
        )
    }

    private func requiredOrder(for size: Int) -> Int {
        var order = 0
        var currentSize = minBlockSize
        while currentSize < size && order < maxOrder {
            currentSize <<= 1
            order += 1
        }
        return order
    }

    private func findOrSplit(order: Int) -> UnsafeMutableRawPointer? {
        guard order < maxOrder else { return nil }

        // take block if it exists at the order
        if let pointer = unsafe popBlock(order: order) {
            return unsafe pointer
        }

        // go to the next order and split it
        if let higherPointer = unsafe findOrSplit(order: order + 1) {
            let blockSize = minBlockSize << order
            let buddy = unsafe (higherPointer + blockSize)
            // put the second half back
            unsafe addBlock(order: order, pointer: buddy)
            // return the first half
            return unsafe higherPointer 
        }
        return nil
    }

    private func coalesce(
        pointer: UnsafeMutableRawPointer,
        order: Int
    ) {
        if order == maxOrder {
            unsafe addBlock(order: order, pointer: pointer)
            return
        }
        let blockSize = minBlockSize << order
        let offset = UInt(bitPattern: pointer) - baseAddress
        let buddyOffset = offset ^ UInt(blockSize)
        let buddyPointer = unsafe UnsafeMutableRawPointer(bitPattern: baseAddress + buddyOffset)!
        if unsafe tryRemoveBlock(order: order, pointer: buddyPointer) {
            // buddy is free; merge and go up one level
            let combinedPointer = unsafe offset < buddyOffset ? pointer : buddyPointer
            unsafe coalesce(pointer: combinedPointer, order: order + 1)
        } else {
            // buddy is busy; add block to the free list
            unsafe addBlock(order: order, pointer: pointer)
        }
    }
}

// MARK: Add block
extension BuddyAllocator {
    private func addBlock(
        order: Int,
        pointer: UnsafeMutableRawPointer
    ) {
        let node = unsafe pointer.assumingMemoryBound(to: UnsafeMutableRawPointer?.self)
        unsafe node.pointee = freeLists[order]
        unsafe freeLists[order] = pointer
    }
}

// MARK: Pop block
extension BuddyAllocator {
    private func popBlock(order: Int) -> UnsafeMutableRawPointer? {
        guard let pointer = unsafe freeLists[order] else { return nil }
        let nextNode = unsafe pointer.assumingMemoryBound(to: UnsafeMutableRawPointer?.self)
        unsafe freeLists[order] = nextNode.pointee
        return unsafe pointer
    }
}

// MARK: Try remove block
extension BuddyAllocator {
    private func tryRemoveBlock(
        order: Int,
        pointer: UnsafeMutableRawPointer
    ) -> Bool {
        var current = unsafe freeLists[order]
        var previous:UnsafeMutableRawPointer? = nil
        while let node = unsafe current {
            if unsafe node == pointer {
                let nextNode = unsafe node.assumingMemoryBound(to: UnsafeMutableRawPointer?.self)
                if let previousPointer = unsafe previous {
                    unsafe previousPointer.assumingMemoryBound(to: UnsafeMutableRawPointer?.self).pointee = nextNode.pointee
                } else {
                    unsafe freeLists[order] = nextNode.pointee
                }
                return true
            }
            unsafe previous = node
            let nextNode = unsafe node.assumingMemoryBound(to: UnsafeMutableRawPointer?.self)
            unsafe current = nextNode.pointee
        }
        return false
    }
}

// MARK: Alloc
extension BuddyAllocator {
    public func alloc(size: Int) -> UnsafeMutableRawPointer? {
        let order = requiredOrder(for: size)
        return unsafe findOrSplit(order: order)
    }
}

// MARK: Free
extension BuddyAllocator {
    public func free(
        pointer: UnsafeMutableRawPointer,
        size: Int
    ) {
        let order = requiredOrder(for: size)
        unsafe coalesce(pointer: pointer, order: order)
    }
}