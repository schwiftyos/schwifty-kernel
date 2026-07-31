
// https://wiki.osdev.org/IOAPIC

/// I/O Advanced Programmable Interrupt Controller.
enum IOAPIC {
    private static nonisolated(unsafe) var _address:UInt!

    // use a computed property to avoid caching a stale pointer
    private static var baseAddress: UnsafeMutablePointer<UInt32> {
        unsafe UnsafeMutablePointer<UInt32>(bitPattern: _address)!
    }

    // Memory-mapped register offsets
    private static let ioregsel = 0x00
    private static let iowin    = 0x10
}

// MARK: initialize
extension IOAPIC {
    // usually 0xFEC00000
    static func initialize(baseAddress: UInt) {
        unsafe _address = baseAddress
    }
}

// MARK: Register
extension IOAPIC {
    private enum Register: UInt8 {
        case id                   = 0x00
        case version              = 0x01
        case arbitration          = 0x02
        case redirectionTableBase = 0x10 // First entry (2 registers per entry)
    }
}

// MARK: Write
extension IOAPIC {
    private static func write(
        _ data: UInt32,
        to register: UInt8
    ) {
        unsafe baseAddress.advanced(by: (ioregsel / 4)).pointee = UInt32(register)
        unsafe baseAddress.advanced(by: (iowin / 4)).pointee = data
    }
}

// MARK: Read
extension IOAPIC {
    private static func read(register: UInt8) -> UInt32 {
        unsafe baseAddress.advanced(by: (ioregsel / 4)).pointee = UInt32(register)
        return unsafe baseAddress.advanced(by: (iowin / 4)).pointee
    }
}

// MARK: Configure
extension IOAPIC {
    /// Configures a Redirection Table Entry (RTE)
    /// 
    /// - Parameters:
    ///   - irq: The hardware IRQ pin (e.g., 1 for keyboard)
    ///   - vector: The IDT index you want to trigger (e.g., 0x21)
    ///   - cpuID: The APIC ID of the target processor
    private static func configure(
        irq: UInt8,
        vector: UInt8,
        cpuID: UInt8
    ) {
        let lowRegister = Register.redirectionTableBase.rawValue + (irq * 2)
        let highRegister = lowRegister + 1

        // upper 32 bits = destination (APIC ID of the core)
        let highValue = UInt32(0xFF) << 24 // UInt32(cpuID) << 24
        write(highValue, to: highRegister)

        // lower 32 bits = vector
        // delivery mode (000 = fixed)
        // destination mode (0 = physical)
        // unmask (0 = enabled)
        let lowValue = UInt32(vector)
        write(lowValue, to: lowRegister)
    }
}

// MARK: Configure
extension IOAPIC {
    /// Configures basic interrupts.
    static func configure() {
        logger.log(staticString: "IOAPIC: configuring...")
        configureKeyboard()
        logger.log(staticString: "IOAPIC: configured")
    }
}

// MARK: Configure keyboard
extension IOAPIC {
    /// Configures ports to enable keyboard interrupts.
    private static func configureKeyboard() {
        logger.log(staticString: "IOAPIC: configuring keyboard...")

        Keyboard.prepare()

        logger.log(staticString: "IOAPIC: configureKeyboard: flushing buffer...")
        // flush existing data in the buffer
        while (inb(0x64) & 0x1) != 0 {
            _ = inb(0x60)
        }
        logger.log(staticString: "IOAPIC: configureKeyboard: flushed buffer")

        // Route IRQ 1 (Keyboard) to IDT Vector 33 (0x21), target CPU 0
        configure(irq: 1, vector: 33, cpuID: 0)
        logger.log(staticString: "IOAPIC: configured keyboard")
    }
}

extension IOAPIC {
    enum Keyboard {
        /// Waits for the PS/2 controller to be ready.
        private static func waitBufferEmpty() {
            // Bit 1 of port 0x64 is the 'Input buffer status'
            // 0: empty, 1: full. We wait until it is 0.
            while (inb(0x64) & 0x2) != 0 {
            }
        }

        /// Sends a command byte to the keyboard (port 0x60).
        private static func sendCommand(_ command: UInt8) {
            waitBufferEmpty()
            outb(0x60, command)
        }

        /// Sends a command byte to the PS/2 Controller (port 0x64).
        private static func sendControllerCommand(_ command: UInt8) {
            waitBufferEmpty()
            outb(0x64, command)
        }

        /// Initiates a hardware handshake for the keyboard.
        static func prepare() {
            logger.log(staticString: "IOAPIC: Keyboard: preparing...")

            // enable the first PS/2 port (command 0xAE sent to the controller [0x64])
            sendControllerCommand(0xAE)

            // enable interrupts in the Configuration Byte (tells the controller to actually pull the IRQ line)
            // command: Read Command Byte
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

            logger.log(staticString: "IOAPIC: Keyboard: prepared")
        }
    }
}