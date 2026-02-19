
// TODO: optimize for power-of-two sizes.
public final class KeyboardRingBuffer<let size: Int> {
    private var buffer = [size of KeyEvent?](repeating: nil)

    private var writeIndex:UInt16 = 0
    private var readIndex:UInt16 = 0

    public func push(_ event: KeyEvent) {
        let next = (writeIndex &+ 1) % UInt16(size)
        if next == readIndex {
            // TODO: buffer full; drop event (or overwrite policy)
            return
        }
        buffer[Int(writeIndex)] = event
        writeIndex = next
    }

    public func pop() -> KeyEvent? {
        if readIndex == writeIndex {
            return nil
        }
        let event = buffer[Int(readIndex)]
        readIndex = (readIndex &+ 1) % UInt16(size)
        return event
    }
}