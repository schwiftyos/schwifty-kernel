
@_cdecl("swift_deallocObject")
public func swift_deallocObject(
    object: UnsafeMutableRawPointer,
    allocatedSize: Int,
    allocatedAlignMask: Int
) {
    logger.log("swift_deallocObject: executing...")
    unsafe free(object)
    logger.log("swift_deallocObject: finished")
}