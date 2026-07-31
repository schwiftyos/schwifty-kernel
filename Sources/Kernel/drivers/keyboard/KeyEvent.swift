
public struct KeyEvent: Sendable {
    public let key:KeyboardKey
    public let pressed:Bool
}

extension KeyEvent {
    static func pressed(_ key: KeyboardKey) -> Self {
        .init(key: key, pressed: true)
    }

    static func released(_ key: KeyboardKey) -> Self {
        .init(key: key, pressed: false)
    }
}