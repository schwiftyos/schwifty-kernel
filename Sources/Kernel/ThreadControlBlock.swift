
@unsafe
struct ThreadControlBlock {
    var stackPointer:UnsafeMutableRawPointer
    var id:Int
    var state:State

    enum State { // TODO: fix: missing hash (and random) logic due to automatic conformance
        case ready
        case running
        case blocked
    }
}