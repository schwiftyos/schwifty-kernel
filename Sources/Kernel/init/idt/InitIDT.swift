

@_extern(c, "load_idtr")
func load_idtr(_ pointer: UnsafeRawPointer)

typealias IDTPointer = (limit: UInt16, base: UInt64)

nonisolated(unsafe) var idt: UnsafeMutablePointer<IDTEntry>! = nil

/// Initializes the Interrupt Descriptor Table.
func initIDT() {
    logger.log("IDT: initializing...")

    unsafe idt = UnsafeMutablePointer<IDTEntry>.allocate(capacity: 256)
    unsafe idt.initialize(repeating: .init(handler: 0), count: 256)
    let idtBaseAddress = UInt(bitPattern: idt)
    logger.log("IDT: initialized idt at \(idtBaseAddress)")

    registerIDTExceptions()

    logger.log("IDT: loading idtr...")
    let limit = UInt16(MemoryLayout<IDTEntry>.size * 256 - 1)
    var idtr = IDTPointer(
        UInt16(0),
        UInt64(0)
    )
    unsafe withUnsafeMutableBytes(of: &idtr) {
        $0.storeBytes(of: limit, as: UInt16.self)
        $0.storeBytes(of: UInt64(idtBaseAddress), toByteOffset: 2, as: UInt64.self)
    }

    logger.log("IDT: calling load_idtr...")
    unsafe load_idtr(&idtr)

    logger.log("IDT: initialized")
}