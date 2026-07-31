
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
    var name: StaticString {
        switch self {
        case .unknown: "unknown"

        case .escape: "escape"
        case .f1: "f1"
        case .f2: "f2"
        case .f3: "f3"
        case .f4: "f4"
        case .f5: "f5"
        case .f6: "f6"
        case .f7: "f7"
        case .f8: "f8"
        case .f9: "f9"
        case .f10: "f10"
        case .f11: "f11"
        case .f12: "f12"
        case .zero: "zero"
        case .one: "one"
        case .two: "two"
        case .three: "three"
        case .four: "four"
        case .five: "five"
        case .six: "six"
        case .seven: "seven"
        case .eight: "eight"
        case .nine: "nine"
        case .minus: "minus"
        case .equal: "equal"
        case .backspace: "backspace"
        case .tab: "tab"
        case .leftBracket: "leftBracket"
        case .rightBracket: "rightBracket"
        case .backslash: "backslash"
        case .capsLock: "capsLock"
        case .semicolon: "semicolon"
        case .apostrophe: "apostrophe"
        case .enter: "enter"
        case .leftShift: "leftShift"
        case .comma: "comma"
        case .period: "period"
        case .slash: "slash"
        case .rightShift: "rightShift"
        case .leftCtrl: "leftCtrl"
        case .leftAlt: "leftAlt"
        case .space: "space"
        case .rightAlt: "rightAlt"
        case .rightCtrl: "rightCtrl"

        case .arrowLeft: "arrowLeft"
        case .arrowUp: "arrowUp"
        case .arrowDown: "arrowDown"
        case .arrowRight: "arrowRight"

        case .grave: "grave"
        case .home: "home"
        case .end: "end"
        case .insert: "insert"
        case .delete: "delete"
        case .pageUp: "pageUp"
        case .pageDown: "pageDown"

        case .a: "a"
        case .b: "b"
        case .c: "c"
        case .d: "d"
        case .e: "e"
        case .f: "f"
        case .g: "g"
        case .h: "h"
        case .i: "i"
        case .j: "j"
        case .k: "k"
        case .l: "l"
        case .m: "m"
        case .n: "n"
        case .o: "o"
        case .p: "p"
        case .q: "q"
        case .r: "r"
        case .s: "s"
        case .t: "t"
        case .u: "u"
        case .v: "v"
        case .w: "w"
        case .x: "x"
        case .y: "y"
        case .z: "z"
        }
    }
}
