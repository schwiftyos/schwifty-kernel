
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
    var address: UnsafeMutableRawPointer {
        unsafe tagPointer.load(fromByteOffset: 8, as: UnsafeMutableRawPointer.self)
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
        unsafe tagPointer.load(fromByteOffset: 28, as: UInt8.self)
    }
    var typeInfo: UInt8 {
        unsafe tagPointer.load(fromByteOffset: 29, as: UInt8.self)
    }
    var reserved: UInt8 {
        unsafe tagPointer.load(fromByteOffset: 30, as: UInt8.self)
    }

    // TODO: color info (red, green, blue masks)
}

// MARK: Draw
extension FramebufferTag {
    private static func drawGlyph<let count: Int>(
        _ glyph: [count of UInt8],
        screen: UnsafeMutableRawPointer,
        pitch: UInt32,
        x: Int,
        y: Int,
        color: UInt32
    ) {
        let stride = Int(pitch / 4)
        for rowIndex in glyph.indices {
            let row = glyph[rowIndex]
            let pixelY = y + rowIndex
            for columnIndex in 0..<8 {
                let isSet = (row & (0b10000000 >> columnIndex)) != 0
                if isSet {
                    let pixelX = x + columnIndex
                    let offset = stride * pixelY + pixelX
                    unsafe screen.storeBytes(
                        of: color,
                        toByteOffset: offset,
                        as: UInt32.self
                    )
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
        Self.drawGlyph(glyph, screen: address, pitch: pitch, x: x, y: y, color: color)
    }
}

extension FramebufferTag {
    func drawStatus() {
        var y = 1
        drawGlyph(SimpleFont.charS, x: 0, y: y, color: .max)
        drawGlyph(SimpleFont.charC, x: 1 * 8, y: y, color: .max)
        drawGlyph(SimpleFont.charH, x: 2 * 8, y: y, color: .max)
        drawGlyph(SimpleFont.charW, x: 3 * 8, y: y, color: .max)
        drawGlyph(SimpleFont.charI, x: 4 * 8, y: y, color: .max)
        drawGlyph(SimpleFont.charF, x: 5 * 8, y: y, color: .max)
        drawGlyph(SimpleFont.charT, x: 6 * 8, y: y, color: .max)
        drawGlyph(SimpleFont.charY, x: 7 * 8, y: y, color: .max)
        drawGlyph(SimpleFont.charO, x: 8 * 8, y: y, color: .max)
        drawGlyph(SimpleFont.charS, x: 9 * 8, y: y, color: .max)

        y += 8
        #if arch(x86_64)
        // long mode
        drawGlyph(SimpleFont.charL, x: 0, y: y, color: .max)
        #else
        // not long mode (likely protected mode)
        drawGlyph(SimpleFont.charP, x: 0, y: y, color: .max)
        #endif

        drawGlyph(SimpleFont.charM, x: 2 * 8, y: y, color: .max)
        drawGlyph(SimpleFont.charO, x: 3 * 8, y: y, color: .max)
        drawGlyph(SimpleFont.charD, x: 4 * 8, y: y, color: .max)
        drawGlyph(SimpleFont.charE, x: 5 * 8, y: y, color: .max)
    }
}