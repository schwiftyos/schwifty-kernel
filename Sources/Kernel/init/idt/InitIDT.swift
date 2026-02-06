

@_extern(c, "load_idtr")
func load_idtr(_ pointer: UnsafeRawPointer)

nonisolated(unsafe) var idt: UnsafeMutablePointer<IDTEntry>! = nil

/// Initializes the Interrupt Descriptor Table.
func initIDT() {
    logger.log("IDT: initializing...")

    unsafe idt = UnsafeMutablePointer<IDTEntry>.allocate(capacity: 256)
    unsafe idt.initialize(repeating: .init(handler: 0), count: 256)
    logger.log("IDT: initialized idt")

    registerIDTExceptions()

    logger.log("IDT: loading idtr...")
    var idtr = unsafe IDTPointer(
        limit: UInt16(MemoryLayout<IDTEntry>.size * 256 - 1),
        base: UnsafeRawPointer(idt)
    )

    logger.log("IDT: calling load_idtr...")
    unsafe load_idtr(&idtr)

    logger.log("IDT: initialized")
}