
public enum KeyboardKey: UInt8, Sendable {
    case unknown

    case escape
    case one, two, three, four, five, six, seven, eight, nine, zero
    case minus, equal, backspace
    case keypadOne, keypadTwo, keypadThree, keypadFour, keypadFive, keypadSix, keypadSeven, keypadEight, keypadNine, keypadZero
    case keypadMinus, keypadPlus, keypadAsterisk, keypadPeriod

    case tab
    case q, w, e, r, t, y, u, i, o, p
    case leftBracket, rightBracket
    case enter
    case leftCtrl
    case a, s, d, f, g, h, j, k, l
    case semicolon, apostrophe

    /// AKA: grave
    case backtick
    case leftShift
    case backslash
    case z, x, c, v, b, n, m
    case comma, period, slash
    case rightShift
    case leftAlt
    case space
    case capsLock
    case f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12
    case numberLock
    case scrollLock

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

    case previousTrack
    case nextTrack
    case mute
    case calculator
    case play
    case stop
    case volumeDown
    case volumeUp
    case wwwHome
    case wwwSearch
    case wwwFavorites
    case wwwRefresh
    case wwwStop
    case wwwForward
    case wwwBack
    case cursorUp
    case cursorLeft
    case cursorRight
    case cursorDown
    case leftGUI
    case rightGUI
    case apps
    case myComputer
    case email
    case mediaSelect

    case power
    case sleep
    case wake
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

        case .keypadZero: "keypadZero"
        case .keypadOne: "keypadOne"
        case .keypadTwo: "keypadTwo"
        case .keypadThree: "keypadThree"
        case .keypadFour: "keypadFour"
        case .keypadFive: "keypadFive"
        case .keypadSix: "keypadSix"
        case .keypadSeven: "keypadSeven"
        case .keypadEight: "keypadEight"
        case .keypadNine: "keypadNine"
        case .keypadMinus: "keypadMinus"
        case .keypadPlus: "keypadPlus"
        case .keypadAsterisk: "keypadAsterisk"
        case .keypadPeriod: "keypadPeriod"

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

        case .backtick: "grave"
        case .home: "home"
        case .end: "end"
        case .insert: "insert"
        case .delete: "delete"
        case .pageUp: "pageUp"
        case .pageDown: "pageDown"
        case .numberLock: "numberLock"
        case .scrollLock: "scrollLock"

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

        case .previousTrack: "previousTrack"
        case .nextTrack: "nextTrack"
        case .mute: "mute"
        case .calculator: "calculator"
        case .play: "play"
        case .stop: "stop"
        case .volumeDown: "volumeDown"
        case .volumeUp: "volumeUp"
        case .wwwHome: "wwwHome"
        case .wwwSearch: "wwwSearch"
        case .wwwFavorites: "wwwFavorites"
        case .wwwRefresh: "wwwRefresh"
        case .wwwStop: "wwwStop"
        case .wwwForward: "wwwForward"
        case .wwwBack: "wwwBack"
        case .cursorUp: "cursorUp"
        case .cursorLeft: "cursorLeft"
        case .cursorRight: "cursorRight"
        case .cursorDown: "cursorDown"
        case .leftGUI: "leftGUI"
        case .rightGUI: "rightGUI"
        case .apps: "apps"
        case .myComputer: "myComputer"
        case .email: "email"
        case .mediaSelect: "mediaSelect"

        case .power: "power"
        case .sleep: "sleep"
        case .wake: "wake"
        }
    }
}
