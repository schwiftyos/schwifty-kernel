
struct ACPIHeader: Sendable {
    let signature:(UInt8, UInt8, UInt8, UInt8)
    let length:UInt32
    let revision:UInt8
    let checksum:UInt8
    let oemID:(UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
    let oemTableID:UInt64
    let oemRevision:UInt32
    let creatorID:UInt32
    let creatorRevision:UInt32
}