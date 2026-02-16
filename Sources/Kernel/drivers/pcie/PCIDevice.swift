
struct PCIDevice: Sendable {
    let bus:UInt8
    let slot:UInt8
    let function:UInt8
    
    var vendorID: UInt16 {
        readWord(offset: 0x00)
    }
    var deviceID: UInt16 {
        readWord(offset: 0x02)
    }
    var classCode: UInt8 {
        UInt8(readWord(offset: 0x0A) >> 8)
    }
    var subClass: UInt8 {
        UInt8(readWord(offset: 0x0A) & 0xFF)
    }
}

// MARK: Read word
extension PCIDevice {
    func readWord(offset: UInt8) -> UInt16 {
        let address = UInt32(0x80000000)
            | (UInt32(bus) << 16)
            | (UInt32(slot) << 11)
            | (UInt32(function) << 8)
            | (UInt32(offset) & 0xFC)
        
        outlong(port: 0xCF8, value: address)
        return UInt16((inlong(port: 0xCFC) >> ((offset & 2) * 8)) & 0xFFFF)
    }
}