
@_cdecl("putchar")
public func putchar(_ char: Int32) -> Int32 {
    UART.putchar(UInt8(truncatingIfNeeded: char))
    return char
}