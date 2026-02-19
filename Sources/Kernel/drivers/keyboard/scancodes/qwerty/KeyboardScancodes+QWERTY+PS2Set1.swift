
extension KeyboardScancodes.Qwerty {
    // TODO: fix | why do we get a general protection fault when using 128 inline array size?
    public static let ps2Set1: [_ of KeyboardKey] = {
        var t = [129 of KeyboardKey](repeating: .unknown)
        t[0x01] = .escape
        t[0x02] = .one
        t[0x03] = .two
        t[0x04] = .three
        t[0x05] = .four
        t[0x06] = .five
        t[0x07] = .six
        t[0x08] = .seven
        t[0x09] = .eight
        t[0x0A] = .nine
        t[0x0B] = .zero
        t[0x0C] = .minus
        t[0x0D] = .equal
        t[0x0E] = .backspace
        t[0x0F] = .tab
        t[0x10] = .q
        t[0x11] = .w
        t[0x12] = .e
        t[0x13] = .r
        t[0x14] = .t
        t[0x15] = .y
        t[0x16] = .u
        t[0x17] = .i
        t[0x18] = .o
        t[0x19] = .p
        t[0x1A] = .leftBracket
        t[0x1B] = .rightBracket
        t[0x1C] = .enter
        t[0x1D] = .leftCtrl
        t[0x1E] = .a
        t[0x1F] = .s
        t[0x20] = .d
        t[0x21] = .f
        t[0x22] = .g
        t[0x23] = .h
        t[0x24] = .j
        t[0x25] = .k
        t[0x26] = .l
        t[0x27] = .semicolon
        t[0x28] = .apostrophe
        t[0x29] = .grave
        t[0x2A] = .leftShift
        t[0x2B] = .backslash
        t[0x2C] = .z
        t[0x2D] = .x
        t[0x2E] = .c
        t[0x2F] = .v
        t[0x30] = .b
        t[0x31] = .n
        t[0x32] = .m
        t[0x33] = .comma
        t[0x34] = .period
        t[0x35] = .slash
        t[0x36] = .rightShift
        t[0x38] = .leftAlt
        t[0x39] = .space
        t[0x3A] = .capsLock
        t[0x3B] = .f1
        t[0x3C] = .f2
        t[0x3D] = .f3
        t[0x3E] = .f4
        t[0x3F] = .f5
        t[0x40] = .f6
        t[0x41] = .f7
        t[0x42] = .f8
        t[0x43] = .f9
        t[0x44] = .f10
        t[0x57] = .f11
        t[0x58] = .f12
        return t
    }()

    public static let ps2Set1Extended: [_ of KeyboardKey] = {
        var t = [129 of KeyboardKey](repeating: .unknown)
        t[0x1D] = .rightCtrl
        t[0x38] = .rightAlt

        t[0x47] = .home
        t[0x48] = .arrowUp
        t[0x49] = .pageUp
        t[0x4B] = .arrowLeft
        t[0x4D] = .arrowRight
        t[0x4F] = .end
        t[0x50] = .arrowDown
        t[0x51] = .pageDown
        t[0x52] = .insert
        t[0x53] = .delete
        return t
    }()
}