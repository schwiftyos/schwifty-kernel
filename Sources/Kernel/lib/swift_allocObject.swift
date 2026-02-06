
@_cdecl("swift_allocObject")
public func swift_allocObject(
    metadata: UnsafeRawPointer,
    requiredSize: Int,
    requiredAlignmentMask: Int
) -> UnsafeMutableRawPointer? {
    logger.log("swift_allocObject: executing...")
    // alignment mask = (alignment - 1)
    var pointer:UnsafeMutableRawPointer? = nil
    let errno = unsafe posix_memalign(&pointer, requiredAlignmentMask + 1, requiredSize)
    guard errno == 0 else {
        logger.log("swift_allocObject: failed (errno != 0)")
        return nil
    }
    logger.log("swift_allocObject: finished")
    return unsafe pointer
}