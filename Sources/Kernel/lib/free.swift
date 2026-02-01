
@_cdecl("free")
public func free(_ pointer: UnsafeMutableRawPointer?) {
    guard let pointer = unsafe pointer else { return }
    
    // move pointer back to find the header
    let blockPointer = unsafe (pointer - MemoryLayout<HeapMemoryBlock>.size).assumingMemoryBound(to: HeapMemoryBlock.self)
    unsafe blockPointer.pointee.isFree = true
    
    // simple Coalescing: merge with next free block
    if let next = unsafe blockPointer.pointee.next, unsafe next.pointee.isFree {
        unsafe blockPointer.pointee.size += MemoryLayout<HeapMemoryBlock>.size + next.pointee.size
        unsafe blockPointer.pointee.next = next.pointee.next
    }
}