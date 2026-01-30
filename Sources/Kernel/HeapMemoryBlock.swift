
@unsafe
struct HeapMemoryBlock {
    var size:Int
    var isFree:Bool
    var next:UnsafeMutablePointer<HeapMemoryBlock>?
}