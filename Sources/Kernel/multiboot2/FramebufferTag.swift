
@safe
struct FramebufferTag: ~Copyable {
    let tagPointer:UnsafeRawPointer

    var type: UInt32 {
        unsafe tagPointer.load(as: UInt32.self)
    }
    var size: UInt32 {
        unsafe tagPointer.load(fromByteOffset: 4, as: UInt32.self)
    }

    /// Physical start of the screen
    var address: UInt64 {
        unsafe tagPointer.load(fromByteOffset: 8, as: UInt64.self)
    }

    /// Bytes per scanline
    var pitch: UInt32 {
        unsafe tagPointer.load(fromByteOffset: 16, as: UInt32.self)
    }
    var width: UInt32 {
        unsafe tagPointer.load(fromByteOffset: 20, as: UInt32.self)
    }
    var height: UInt32 {
        unsafe tagPointer.load(fromByteOffset: 24, as: UInt32.self)
    }

    /// Usually 32
    var bitsPerPixel: UInt8 {
        unsafe (tagPointer + 28).load(as: UInt8.self)
    }
    var typeInfo: UInt8 {
       unsafe  (tagPointer + 29).load(as: UInt8.self)
    }
    var reserved: UInt8 {
        unsafe (tagPointer + 30).load(as: UInt8.self)
    }

    // TODO: color info (red, green, blue masks)
}

extension FramebufferTag {
    private static func drawBlueScreen(address: UInt64, width: UInt32, height: UInt32) {
        let screen = unsafe UnsafeMutablePointer<UInt32>(bitPattern: UInt(address))!
        for i in 0..<(width * height) {
            unsafe screen[Int(i)] = 0x0000FFFF // Solid Blue (ABGR/RGBA depending on layout)
        }
    }

    func drawBlueScreen() {
        Self.drawBlueScreen(address: address, width: width, height: height)
    }
}

// MARK: Draw
extension FramebufferTag {
    private static func drawGlyph<let count: Int>(
        _ glyph: [count of UInt8],
        address: UInt64,
        pitch: UInt32,
        x: Int,
        y: Int,
        color: UInt32
    ) {
        let screen = unsafe UnsafeMutablePointer<UInt32>(bitPattern: UInt(address))!
        for rowIndex in glyph.indices {
            let row = glyph[rowIndex]
            let pixelY = y + rowIndex
            for columnIndex in 0..<8 {
                let isSet = (row & (0b10000000 >> columnIndex)) != 0
                if isSet {
                    let pixelX = x + columnIndex
                    let offset = Int(pitch / 4) * pixelY + pixelX
                    unsafe screen[offset] = color
                }
            }
        }
    }

    func drawGlyph<let count: Int>(
        _ glyph: [count of UInt8],
        x: Int,
        y: Int,
        color: UInt32
    ) {
        Self.drawGlyph(glyph, address: address, pitch: pitch, x: x, y: y, color: color)
    }
}

extension FramebufferTag {
    func drawStatus() {
        drawGlyph(SimpleFont.charS, x: 0, y: 1, color: .max)
        drawGlyph(SimpleFont.charC, x: 1 * 8, y: 1, color: .max)
        drawGlyph(SimpleFont.charH, x: 2 * 8, y: 1, color: .max)
        drawGlyph(SimpleFont.charW, x: 3 * 8, y: 1, color: .max)
        drawGlyph(SimpleFont.charI, x: 4 * 8, y: 1, color: .max)
        drawGlyph(SimpleFont.charF, x: 5 * 8, y: 1, color: .max)
        drawGlyph(SimpleFont.charT, x: 6 * 8, y: 1, color: .max)
        drawGlyph(SimpleFont.charY, x: 7 * 8, y: 1, color: .max)
        drawGlyph(SimpleFont.charO, x: 8 * 8, y: 1, color: .max)
        drawGlyph(SimpleFont.charS, x: 9 * 8, y: 1, color: .max)

        switch UInt.bitWidth {
        case 32:
            // protected mode
            drawGlyph(SimpleFont.charP, x: 0, y: 9, color: .max)
        case 64:
            // long mode
            drawGlyph(SimpleFont.charL, x: 0, y: 9, color: .max)
        default:
            // unknown mode
            drawGlyph(SimpleFont.charU, x: 0, y: 9, color: .max)
        }

        drawGlyph(SimpleFont.charM, x: 2 * 8, y: 9, color: .max)
        drawGlyph(SimpleFont.charO, x: 3 * 8, y: 9, color: .max)
        drawGlyph(SimpleFont.charD, x: 4 * 8, y: 9, color: .max)
        drawGlyph(SimpleFont.charE, x: 5 * 8, y: 9, color: .max)
    }
}