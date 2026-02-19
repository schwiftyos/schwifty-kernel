
let logger = KernelLogger()

struct KernelLogger {
    func log(_ string: String) {
        for char in string.utf8 {
            UART.putchar(char)
        }
        UART.putchar(10)
    }

    func logRaw(_ string: String) {
        for char in string.utf8 {
            UART.putchar(char)
        }
    }

    func logRaw(_ char: UInt8) {
        UART.putchar(char)
    }
}