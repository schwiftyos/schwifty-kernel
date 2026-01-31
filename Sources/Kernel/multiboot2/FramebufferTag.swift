
struct FramebufferTag {
    let type:UInt32
    let size:UInt32

    /// Physical start of the screen
    let address:UInt64

    /// Bytes per scanline
    let pitch:UInt32
    let width:UInt32
    let height:UInt32

    /// Usually 32
    let bitsPerPixel:UInt8
    let typeInfo:UInt8
    let reserved:UInt8

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
    func drawTest(x: Int, y: Int, color: UInt32) {
        Self.drawGlyph(SimpleFont.charA, address: address, pitch: pitch, x: x, y: y, color: color)
    }

    static func drawGlyph<let count: Int>(
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