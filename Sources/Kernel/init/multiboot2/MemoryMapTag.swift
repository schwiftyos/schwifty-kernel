
struct MemoryMapTag {
    let type:UInt32
    let size:UInt32
    let entrySize:UInt32
    let entryVersion:UInt32
    // TODO: entries follow immediately after these 16 bytes
}