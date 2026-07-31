
nonisolated(unsafe) let keyboardBuffer = KeyboardRingBuffer<64>()
private nonisolated(unsafe) var extended = false

@_cdecl("keyboard_interrupt_handler")
func keyboardInterruptHandler(vector: UInt64) {
    let rawScancode = inb(0x60) // PS/2 keyboard port
    if rawScancode == 0xE0 {
        logger.log(staticString: "keyboardInterruptHandler: rawScancode == 0xE0")
        unsafe extended = true
        LocalAPIC.endOfInterrupt()
        return
    }
    let event:KeyEvent
    if unsafe extended {
        unsafe extended = false
        event = KeyboardScancodes.Qwerty.ps2Set1Extended[Int(rawScancode)]
    } else {
        event = KeyboardScancodes.Qwerty.ps2Set1[Int(rawScancode)]
    }
    if event.key != .unknown {
        unsafe keyboardBuffer.push(event)
    }
    LocalAPIC.endOfInterrupt()
}

enum Keyboard {
}