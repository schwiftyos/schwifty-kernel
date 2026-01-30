
@safe
struct KernelTask {
    var stackPointer:UnsafeRawPointer // must be the first element
    let id:Int
    var state:State
}

// MARK: State
extension KernelTask {
    enum State {
        case ready
        case running
    }
}