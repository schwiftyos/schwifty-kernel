
struct MemoryMapEntry {
    let baseAddress:UInt64
    let length:UInt64
    let type:UInt32
    let reserved:UInt32
}

extension MemoryMapEntry {
    enum MemoryType: UInt32 {
        case available = 1
        case acpi      = 3
        case preserved = 4
        case defective = 5
    }
}