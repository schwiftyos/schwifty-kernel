
let keyEventQueue = KeyEventQueue<64>()

nonisolated(unsafe) var keyboardInterruptScancodeIsExtended = false

@_cdecl("keyboard_interrupt_handler")
func keyboardInterruptHandler(vector: UInt64) {
    let rawScancode = inb(0x60) // PS/2 keyboard port
    if rawScancode == 0xE0 {
        #if LogKeyEvents
        logger.log(staticString: "keyboardInterruptHandler: rawScancode == 0xE0")
        #endif

        unsafe keyboardInterruptScancodeIsExtended = true
        LocalAPIC.endOfInterrupt()
        return
    }
    let event:KeyEvent
    if unsafe keyboardInterruptScancodeIsExtended {
        unsafe keyboardInterruptScancodeIsExtended = false
        event = KeyboardScancodes.Qwerty.ps2Set1Extended[Int(rawScancode)].clone()
    } else {
        event = KeyboardScancodes.Qwerty.ps2Set1[Int(rawScancode)].clone()
    }
    if event.key != .unknown {
        keyEventQueue.push(event)
    }
    LocalAPIC.endOfInterrupt()
}

enum Keyboard {
}