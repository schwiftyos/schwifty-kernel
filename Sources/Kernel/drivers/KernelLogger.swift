
let logger = KernelLogger()

struct KernelLogger {
    func logRaw(_ ascii: ASCII) {
        #if Log
        UART.putASCII(ascii)
        #endif
    }
}

// MARK: StaticString
extension KernelLogger {
    func log(staticString: StaticString) {
        #if Log
        logRaw(staticString: staticString)
        UART.putASCII(.lineFeed)
        #endif
    }

    func logRaw(staticString: StaticString) {
        #if Log
        for i in 0..<staticString.utf8CodeUnitCount {
            unsafe UART.putChar((staticString.utf8Start + i).pointee)
        }
        #endif
    }
}

// MARK: String
extension KernelLogger {
    /// - Warning: Can allocate heap memory!
    func log(string: String) {
        #if Log
        logRaw(string: string)
        UART.putASCII(.lineFeed)
        #endif
    }

    func logRaw(string: String) {
        #if Log
        for char in string.utf8 {
            UART.putChar(char)
        }
        #endif
    }
}