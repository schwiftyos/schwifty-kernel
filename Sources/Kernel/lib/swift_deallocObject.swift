
@_cdecl("swift_deallocObject")
public func swift_deallocObject(
    object: UnsafeMutableRawPointer,
    allocatedSize: Int,
    allocatedAlignMask: Int
) {
    logger.log(staticString: "swift_deallocObject: executing...")
    unsafe free(object)
    logger.log(staticString: "swift_deallocObject: finished")
}