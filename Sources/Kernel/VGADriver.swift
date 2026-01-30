
struct VGADriver<let width: Int, let height: Int> {
    // use a computed property to get a fresh pointer every time
    // to prevent the compiler from caching a stale value
    private var buffer: UnsafeMutablePointer<UInt16> {
        return unsafe UnsafeMutablePointer<UInt16>(bitPattern: 0xB8000)!
    }
}

// MARK: Write
extension VGADriver {
    func write(
        value: UInt16,
        x: Int,
        y: Int,
        color: UInt8 = 0x07
    ) {
        let index = y * width + x
        unsafe buffer[index] = value
    }
}

// MARK: Write StaticString
extension VGADriver {
    func write(
        _ message: StaticString,
        x: Int = 0,
        y: Int = 0,
        color: UInt8 = 0x07
    ) {
        var vgaBufferIndex = y * width + x
        message.withUTF8Buffer {
            for unsafe char in unsafe $0 {
                unsafe buffer[vgaBufferIndex] = (UInt16(color) << 8) | UInt16(char)
                vgaBufferIndex += 1
            }
        }
    }
}

// MARK: Write String
extension VGADriver {
    func write(
        _ message: String,
        x: Int = 0,
        y: Int = 0,
        color: UInt8 = 0x07
    ) {
        var i = 0
        var vgaBufferIndex = y * width + x
        unsafe message.withCString { ptr in
            while unsafe ptr[i] != 0 {
                let char = unsafe ptr[i]
                unsafe buffer[vgaBufferIndex] = (UInt16(color) << 8) | UInt16(char)
                vgaBufferIndex += 1
                i += 1
            }
        }
    }
}

// MARK: Clear
extension VGADriver {
    func clearScreen() {
        /*
        // TODO: fix | causes reboots
        for x in 0..<width {
            for y in 0..<height {
                write(value: 0x0720, x: x, y: y)
            }
        }*/
        for x in 0..<85 {
            for y in 0..<25 {
                write(value: 0x0720, x: x, y: y)
            }
        }
    }
}