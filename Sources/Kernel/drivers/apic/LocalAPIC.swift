
// https://wiki.osdev.org/APIC

/// Local Advanced Programmable Interrupt Controller.
final class LocalAPIC {
    static nonisolated(unsafe) let shared = LocalAPIC()

    private let baseAddress:UInt64 = 0xFEE00000 // 4276092928

    func endOfInterrupt() {
        logger.log("LocalAPIC: eoi: executing...")
        write(0, to: .endOfInterrupt)
        logger.log("LocalAPIC: eoi: executed")
    }
}

// MARK: Register
extension LocalAPIC {
    private enum Register: UInt64 {
        case id             = 0x20
        case version        = 0x30
        case taskPriority   = 0x80
        case endOfInterrupt = 0xB0
        case spurious       = 0xF0
        case icrLow         = 0x300
        case icrHigh        = 0x310
        case lvtTimer       = 0x320

        case timerDivideConfig = 0x3E0
        case timerInitialCount = 0x380
        case timerCurrentCount = 0x390
    }
}

// MARK: Read
extension LocalAPIC {
    private func read(_ register: Register) -> UInt32 {
        let pointer = unsafe UnsafePointer<UInt32>(bitPattern: UInt(baseAddress + register.rawValue))
        return unsafe pointer?.pointee ?? 0
    }
}

// MARK: Write
extension LocalAPIC {
    private func write(_ value: UInt32, to register: Register) {
        let pointer = unsafe UnsafeMutablePointer<UInt32>(bitPattern: UInt(baseAddress + register.rawValue))
        unsafe pointer?.pointee = value
    }
}

// MARK: Configure
extension LocalAPIC {
    func configure() {
        logger.log("LocalAPIC: configuring...")

        // set Spurious Interrupt Vector and enable APIC
        // Vector 0xFF; bit 8 = software enable
        write(read(.spurious) | 0x1FF, to: .spurious)

        // set Task Priority to 0 to accept all interrupts
        write(0, to: .taskPriority)

        logger.log("LocalAPIC: configured")
    }
}

// MARK: test timer
extension LocalAPIC {
    func testTimer() {
        logger.log("LocalAPIC: testTimer: executing...")

        // set the Divide Configuration Register to divide by 16
        write(0x03, to: .timerDivideConfig)

        // set the Initial Count to a high value
        write(0xFFFFFFFF, to: .timerInitialCount)

        // wait a bit
        for _ in 0..<1000000 {
            _ = 1 + 1
        }

        let count = read(.timerCurrentCount)
        if count < 0xFFFFFFFF {
            logger.log("LocalAPIC: testTimer: ticking; current: \\(count)")
        } else {
            logger.log("LocalAPIC: testTimer: timer is stuck!")
        }
    }
}