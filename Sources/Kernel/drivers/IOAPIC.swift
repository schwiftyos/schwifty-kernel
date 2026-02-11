
// https://wiki.osdev.org/IOAPIC

/// I/O Advanced Programmable Interrupt Controller.
final class IOAPIC {
    static nonisolated(unsafe) let shared = IOAPIC()

    private let baseAddress:UInt64 = 0xFEC00000

    // Memory-mapped register offsets
    private let ioregsel:UInt32 = 0x00
    private let iowin:UInt32    = 0x10
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
    private func write(
        _ data: UInt32,
        to index: UInt8
    ) {
        let selPtr = unsafe UnsafeMutablePointer<UInt32>(bitPattern: UInt(baseAddress + UInt64(ioregsel)))
        let winPtr = unsafe UnsafeMutablePointer<UInt32>(bitPattern: UInt(baseAddress + UInt64(iowin)))
        unsafe selPtr?.pointee = UInt32(index)
        unsafe winPtr?.pointee = data
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
    private func configure(
        irq: UInt8,
        vector: UInt8,
        cpuID: UInt8
    ) {
        let lowIndex = Register.redirectionTableBase.rawValue + (irq * 2)
        let highIndex = lowIndex + 1

        // lower 32 bits = vector, delivery mode (000 = fixed), destination mode (0 = physical), unmask (0 = enabled)
        let lowValue = UInt32(vector) 

        // upper 32 bits = destination (APIC ID of the core)
        let highValue = UInt32(cpuID) << 24

        write(lowValue, to: lowIndex)
        write(highValue, to: highIndex)
    }
}

// MARK: Configure
extension IOAPIC {
    /// Configures basic interrupts.
    func configure() {
        logger.log("IOAPIC: configuring...")
        configureKeyboard()
        logger.log("IOAPIC: configured")
    }
}

// MARK: Register keyboard
extension IOAPIC {
    private func configureKeyboard() {
        logger.log("IOAPIC: configuring keyboard...")
        // Route IRQ 1 (Keyboard) to IDT Vector 33 (0x21), target CPU 0
        configure(irq: 1, vector: 0x21, cpuID: 0)
        logger.log("IOAPIC: configured keyboard")
    }
}