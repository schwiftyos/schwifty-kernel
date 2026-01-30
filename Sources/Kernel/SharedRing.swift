
/// Basic, but fast, communication method between the hardware and kernel.
@safe
struct SharedRing<T> {
    let pointer:UnsafeMutablePointer<T>
    let capacity:Int // must be power of 2
    var head = 0
    var tail = 0

    mutating func push(_ item: T) {
        unsafe pointer[tail & (capacity - 1)] = item
        tail += 1
    }

    mutating func pop() -> T? {
        if head == tail {
            return nil
        }
        let item = unsafe pointer[head & (capacity - 1)]
        head += 1
        return item
    }
}