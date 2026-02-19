
nonisolated(unsafe) let keyboardBuffer = KeyboardRingBuffer<64>()
private nonisolated(unsafe) var extended = false

@_cdecl("keyboard_interrupt_handler")
func keyboardInterruptHandler(vector: UInt64) {
    let rawScancode = inb(0x60) // PS/2 keyboard port
    if rawScancode == 0xE0 {
        logger.log("keyboardInterruptHandler: rawScancode == 0xE0")
        unsafe extended = true
        LocalAPIC.endOfInterrupt()
        return
    }
    let scancode = rawScancode & 0x7F
    let key:KeyboardKey
    if unsafe extended {
        unsafe extended = false
        key = KeyboardScancodes.Qwerty.ps2Set1Extended[Int(scancode)]
    } else {
        key = KeyboardScancodes.Qwerty.ps2Set1[Int(scancode)]
    }
    if key != .unknown {
        let isMake = (rawScancode & 0x80) == 0
        unsafe keyboardBuffer.push(.init(key: key, pressed: isMake))
    }
    LocalAPIC.endOfInterrupt()
}

enum Keyboard {
}