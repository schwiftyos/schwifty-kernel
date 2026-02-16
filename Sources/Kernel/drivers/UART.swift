
/// Universal Asynchronous Receiver-Transmitter.
/// 
/// The hardware communication protocol used
/// for serial data transmission between devices.
struct UART {
    static let port:UInt16 = 0x3F8 // COM1

    static func initialize() {
        outbyte(port: port + 1, value: 0x00) // disable all interrupts
        outbyte(port: port + 3, value: 0x80) // enable DLAB (set baud rate divisor)
        outbyte(port: port + 0, value: 0x03) // set divisor to 3 (38400 baud)
        outbyte(port: port + 1, value: 0x00) // hi byte
        outbyte(port: port + 3, value: 0x03) // 8 bits, no parity, one stop bit
        outbyte(port: port + 2, value: 0xC7) // enable FIFO; clear with 14-byte threshold
        outbyte(port: port + 4, value: 0x0B) // IRQs enabled; RTS/DSR set
        logger.log("UART: initialized")
    }

    static func isTransmitEmpty() -> Bool {
        return (inbyte(port: port + 5) & 0x20) != 0
    }

    static func putchar(_ char: UInt8) {
        while !isTransmitEmpty() {
        }
        outbyte(port: port, value: char)
    }
}