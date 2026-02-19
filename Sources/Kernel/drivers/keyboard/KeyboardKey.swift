
public enum KeyboardKey: UInt8, Sendable {
    case unknown

    case escape
    case one, two, three, four, five, six, seven, eight, nine, zero
    case minus, equal, backspace
    case tab
    case q, w, e, r, t, y, u, i, o, p
    case leftBracket, rightBracket
    case enter
    case leftCtrl
    case a, s, d, f, g, h, j, k, l
    case semicolon, apostrophe, grave
    case leftShift
    case backslash
    case z, x, c, v, b, n, m
    case comma, period, slash
    case rightShift
    case leftAlt
    case space
    case capsLock
    case f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12

    // extended
    case rightCtrl
    case rightAlt
    case insert
    case delete
    case home
    case end
    case pageUp
    case pageDown
    case arrowUp
    case arrowDown
    case arrowLeft
    case arrowRight
}

// MARK: Name
extension KeyboardKey {
    var name: String {
        switch self {
        case .unknown: "unknown"

        case .escape: "escape"
        case .one: "one"
        case .two: "two"
        case .three: "three"
        case .four: "four"
        case .five: "five"
        case .six: "six"
        case .seven: "seven"
        case .eight: "eight"
        case .nine: "nine"

        case .q: "q"
        case .w: "w"
        case .e: "e"
        case .r: "r"
        case .t: "t"
        case .y: "y"

        default: "nil"
        }
    }
}
