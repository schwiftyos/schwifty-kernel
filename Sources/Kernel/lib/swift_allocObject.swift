
@_cdecl("swift_allocObject")
public func swift_allocObject(
    metadata: UnsafeRawPointer,
    requiredSize: Int,
    requiredAlignmentMask: Int
) -> UnsafeMutableRawPointer? {
    // alignment mask = (alignment - 1)
    var pointer:UnsafeMutableRawPointer? = nil
    _ = unsafe posix_memalign(&pointer, requiredAlignmentMask + 1, requiredSize)
    return unsafe pointer
}