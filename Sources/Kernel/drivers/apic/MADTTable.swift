
struct MADTTable: Sendable {
    let header:ACPIHeader
    let localApicAddress:UInt32
    let flags:UInt32
    // here is a list of variable-sized entries
}