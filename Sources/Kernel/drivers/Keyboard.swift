
@_cdecl("keyboard_interrupt_handler")
func keyboardInterruptHandler() {
    let scancode = inb(0x60) // PS/2 keyboard port
    logger.log("keyboardInterruptHandler: scancode=\(scancode)")
    unsafe LocalAPIC.shared.endOfInterrupt()
}