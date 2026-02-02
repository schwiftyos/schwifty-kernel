
struct IDTEntry {
    var offsetLow:UInt16 = 0
    var selector:UInt16 = 0x08        // matches GDT code segment
    var interruptStackTable:UInt8 = 0 // TODO: interrupt stack table (set to 0 for now)
    var typeAttributes:UInt8 = 0x8E   // 0b10001110 -> Present, Ring 0, Interrupt Gate
    var offsetMid:UInt16 = 0
    var offsetHigh:UInt32 = 0
    var reserved:UInt32 = 0

    init(handler: UInt64) {
        self.offsetLow = UInt16(handler & 0xFFFF)
        self.offsetMid = UInt16((handler >> 16) & 0xFFFF)
        self.offsetHigh = UInt32((handler >> 32) & 0xFFFFFFFF)
    }
}