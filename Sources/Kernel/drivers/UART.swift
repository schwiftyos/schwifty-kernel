
/// Universal Asynchronous Receiver-Transmitter.
/// 
/// The hardware communication protocol used
/// for serial data transmission between devices.
struct UART {
    static let port:UInt16 = 0x3F8 // COM1

    static func initialize() {
        outb(port + 1, 0x00) // disable all interrupts
        outb(port + 3, 0x80) // enable DLAB (set baud rate divisor)
        outb(port + 0, 0x03) // set divisor to 3 (38400 baud)
        outb(port + 1, 0x00) // hi byte
        outb(port + 3, 0x03) // 8 bits, no parity, one stop bit
        outb(port + 2, 0xC7) // enable FIFO; clear with 14-byte threshold
        outb(port + 4, 0x0B) // IRQs enabled; RTS/DSR set
        logger.log(staticString: "UART: initialized")
    }

    static func isTransmitEmpty() -> Bool {
        return (inb(port + 5) & 0x20) != 0
    }

    @available(*, deprecated, message: "Use `putASCII(_:)` instead")
    static func putChar(_ char: UInt8) {
        while !isTransmitEmpty() {}
        outb(port, char)
    }

    static func putASCII(_ ascii: ASCII) {
        while !isTransmitEmpty() {}
        outb(port, ascii.rawValue)
    }
}