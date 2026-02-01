
/// Every tag starts with these 8 bytes.
struct MultibootTagHeader {
    let type:UInt32
    let size:UInt32
}