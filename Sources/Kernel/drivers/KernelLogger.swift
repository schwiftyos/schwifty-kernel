
let logger = KernelLogger()

struct KernelLogger {
    func log(_ string: String) {
        for char in string.utf8 {
            UART.putchar(char)
        }
        UART.putchar(10)
        UART.putchar(13)
    }
}