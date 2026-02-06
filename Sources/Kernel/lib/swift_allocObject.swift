
@_cdecl("swift_allocObject")
public func swift_allocObject(
    metadata: UnsafeRawPointer,
    requiredSize: Int,
    requiredAlignmentMask: Int
) -> UnsafeMutableRawPointer? {
    logger.log("swift_allocObject: executing...")
    // alignment mask = (alignment - 1)
    var pointer:UnsafeMutableRawPointer? = nil
    _ = unsafe posix_memalign(&pointer, requiredAlignmentMask + 1, requiredSize)
    logger.log("swift_allocObject: finished")
    return unsafe pointer
}