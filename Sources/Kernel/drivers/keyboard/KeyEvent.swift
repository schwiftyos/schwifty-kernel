
public struct KeyEvent: Sendable, ~Copyable {
    public let key:KeyboardKey
    public let pressed:Bool

    public var released: Bool {
        !pressed
    }

    func clone() -> Self {
        .init(key: key, pressed: pressed)
    }
}

extension KeyEvent {
    static func pressed(_ key: KeyboardKey) -> Self {
        .init(key: key, pressed: true)
    }

    static func released(_ key: KeyboardKey) -> Self {
        .init(key: key, pressed: false)
    }
}