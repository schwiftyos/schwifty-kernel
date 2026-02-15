
struct MultibootTagACPI: Sendable {
    let type:UInt32
    let size:UInt32
    // RSDP structure starts immediately after `size`
    // use UnsafeRawPointer to access the data starting at offset 8
}