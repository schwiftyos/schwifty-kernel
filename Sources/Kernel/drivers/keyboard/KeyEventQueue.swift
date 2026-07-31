
final class KeyEventQueue<let size: Int>: @unchecked Sendable {
    private var buffer = [size of KeyEvent].init(initializingWith: {
        for i in 0..<size {
            $0.append(.released(.unknown))
        }
    })

    /// Number of pending key events.
    /// 
    /// - Complexity: O(1).
    private(set) var count = 0

    /// - Complexity: O(1).
    var isEmpty: Bool {
        count == 0
    }
}

// MARK: push
extension KeyEventQueue {
    /// - Complexity: O(1).
    func push(_ event: consuming KeyEvent) {
        if count == size {
            Panic.keyboardRingBufferIsFull.execute()
            return
        }
        buffer[count] = event
        count &+= 1
    }
}

// MARK: pop all
extension KeyEventQueue {
    /// Pops all pending key events.
    /// 
    /// Complexity: O(1).
    func popAllUnchecked(_ closure: (Span<KeyEvent>) -> Void) {
        assert(!isEmpty)
        unsafe closure(buffer.span.extracting(unchecked: 0..<count))
        count = 0
    }
}