
@_cdecl("keyboard_interrupt_handler")
func keyboard_interrupt_handler(vector: UInt64) {
    logger.log("Keyboard: keyboardInterruptHandler: executing...")
    let scancode = inb(0x60) // PS/2 keyboard port
    logger.log("Keyboard: keyboardInterruptHandler: scancode=\\(scancode)")
    unsafe LocalAPIC.shared.endOfInterrupt()
    logger.log("Keyboard: keyboardInterruptHandler: executed")
}

final class Keyboard {
    static nonisolated(unsafe) let shared = Keyboard()
}

extension Keyboard {
    /// Wait for the PS/2 controller to be ready
    private func waitBufferEmpty() {
        // Bit 1 of port 0x64 is the 'Input buffer status'
        // 0: empty, 1: full. We wait until it is 0.
        while (inb(0x64) & 0x2) != 0 {
        }
    }

    /// Sends a command byte to the keyboard (Port 0x60)
    private func sendCommand(_ command: UInt8) {
        waitBufferEmpty()
        outb(0x60, command)
    }

    /// Sends a command byte to the PS/2 Controller (Port 0x64)
    private func sendControllerCommand(_ command: UInt8) {
        waitBufferEmpty()
        outb(0x64, command)
    }
}

// MARK: Prepare
extension Keyboard {
    /// Initiates a hardware handshake for the keyboard.
    func prepare() {
        logger.log("Keyboard: preparing...")

        // enable the first PS/2 port (command 0xAE sent to the controller [0x64])
        sendControllerCommand(0xAE)

        // enable interrupts in the Configuration Byte (tells the controller to actually pull the IRQ line)
        // Command: Read Command Byte
        sendControllerCommand(0x20)

        // wait for data to be available (bit 0 of 0x64)
        while (inb(0x64) & 0x1) == 0 {}

        var config = inb(0x60)
        config |= 0x01 // set bit 0 to enable IRQ 1
        config &= ~0x10 // clear bit 4 to disable clock

        sendControllerCommand(0x60) // command: Write Command Byte
        sendCommand(config)

        // enable scanning (command 0xF4 sent to the data port [0x60])
        sendCommand(0xF4)

        logger.log("Keyboard: prepared")
    }
}