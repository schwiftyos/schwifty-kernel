
@safe
struct LocalAPIC {
    let baseAddress:UnsafeMutableRawPointer

    /// Register offsets
    private enum Offset: Int {
        case id                           = 0x20
        case version                      = 0x30
        case taskPriorityRegister         = 0x80
        case endOfInterrupt               = 0x0B0
        case spuriousInterruptVector      = 0x0F0
        case interruptCommandRegisterLow  = 0x300 // low 32 bits
        case interruptCommandRegisterHigh = 0x310 // high 32 bits
        case lvtTimer                     = 0x320
    }

    init(
        address: UInt32 = 0xFEE00000
    ) {
        unsafe self.baseAddress = UnsafeMutableRawPointer(bitPattern: UInt(address))!
    }

    private func write(_ offset: Offset, _ value: UInt32) {
        unsafe (baseAddress + offset.rawValue).assumingMemoryBound(to: UInt32.self).pointee = value
    }

    private func read(_ offset: Offset) -> UInt32 {
        return unsafe (baseAddress + offset.rawValue).assumingMemoryBound(to: UInt32.self).pointee
    }
}

// MARK: Setup
extension LocalAPIC {
    func setup() {
        // set Spurious Interrupt Vector to 0xFF and set bit 8 to enable APIC
        // use 0xFF as a common dummy vector for spurious interrupts
        write(.spuriousInterruptVector, 0x1FF)

        // set Task Priority to 0 to allow all interrupts
        write(.taskPriorityRegister, 0)

        vgaDriver.write(
            StaticString("LAPIC initialized for CPU"),
            y: 6 + Int(read(.id))
        )
    }
}

// MARK: EOI
extension LocalAPIC {
    /// Signal the end of an interrupt. Call this at the end of every ISR.
    @_silgen_name("lapic_eoi")
    func sendEndOfInterrupt() {
        write(.endOfInterrupt, 0)
    }
}

// MARK: Inter-processor interrupt
extension LocalAPIC {
    func sendInterProcessorInterrupt(
        apicID: UInt32,
        vector: UInt32,
        deliveryMode: UInt32
    ) {
        // high 32 bits = destination APIC ID
        write(.interruptCommandRegisterHigh, apicID << 24)
        
        // low 32 bits: 
        // - 0-7: vector
        // - 8-10: delivery mode (000=fixed, 110=startup, 101=init)
        // - 14: assert (1)
        let command = vector | (deliveryMode << 8) | (1 << 14)
        write(.interruptCommandRegisterLow, command)
        
        // wait for delivery status bit (12) to clear
        while (read(.interruptCommandRegisterLow) & (1 << 12)) != 0 {
        }
    }
}