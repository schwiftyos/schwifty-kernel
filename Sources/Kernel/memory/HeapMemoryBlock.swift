
@safe
struct HeapMemoryBlock {
    var size:UInt64
    var isFree:Bool
    var next:UnsafeMutablePointer<HeapMemoryBlock>?
}