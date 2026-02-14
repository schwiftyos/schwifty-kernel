
/// Root System Description Pointer.
struct RSDPDescriptor: Sendable {
    let signature:(UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
    let checksum:UInt8
    let oemID:(UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
    let revision:UInt8

    /// Physical address of the RSDT.
    let rsdtAddress:UInt32
}