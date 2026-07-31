
public struct KeyEvent: Sendable, ~Copyable {
    public let key:KeyboardKey
    public let pressed:Bool

    public var released: Bool {
        !pressed
    }

    func clone() -> Self {
        .init(key: key, pressed: pressed)
    }

    func log() {
        #if LogKeyEvents
        logger.logRaw(staticString: "KeyEvent: key=")
        logger.logRaw(staticString: key.name)
        logger.logRaw(staticString: ";pressed=")
        if pressed {
            logger.logRaw(staticString: "true")
        } else {
            logger.logRaw(staticString: "false")
        }
        logger.logRaw(.lineFeed)
        #endif
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