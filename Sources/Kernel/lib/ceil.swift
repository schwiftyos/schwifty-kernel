
@_cdecl("ceil")
public func ceil(_ x: Double) -> Double {
    guard x.isFinite else { return x }
    let truncated = Double(Int64(x))
    if x > 0 && x > truncated {
        // x is positive and has a fractional part; round up
        return truncated + 1.0
    }
    // x is negative; already truncated
    return truncated
}