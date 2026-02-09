
@_extern(c, "load_idtr")
func load_idtr(_ pointer: UnsafeRawPointer)

typealias IDTPointer = (limit: UInt16, base: UInt64)

nonisolated(unsafe) var idt = [256 of IDTEntry](repeating: .init(handler: 0))

/// Initializes the Interrupt Descriptor Table.
func initIDT() {
    logger.log("IDT: initializing...")

    registerIDTExceptions()

    logger.log("IDT: loading idtr...")
    let limit = UInt16(MemoryLayout<IDTEntry>.size * 256 - 1)
    var idtr = IDTPointer(
        UInt16(0),
        UInt64(0)
    )
    unsafe idt.mutableSpan.withUnsafeBytes { ms in
        guard let bs = ms.baseAddress else {
            logger.log("IDT: idt.mutableSpan.withUnsafeBytes baseAddress == nil")
            return
        }
        unsafe withUnsafeMutableBytes(of: &idtr) { i in
            unsafe i.storeBytes(of: limit, as: UInt16.self)
            unsafe i.storeBytes(of: UInt64(UInt(bitPattern: bs)), toByteOffset: 2, as: UInt64.self)
        }
        logger.log("IDT: calling load_idtr...")
        unsafe load_idtr(&idtr)
    }

    logger.log("IDT: initialized")
}