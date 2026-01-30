
@safe
struct CPU {
    var id:Int
    var currentThread:KernelThread?
    var interruptStack:UnsafeMutableRawPointer
}