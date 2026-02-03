
@_extern(c, "cpu_halt")
func cpu_halt()

// MARK: I/O

@_extern(c, "outb")
func outb(_ port: UInt16, _ value: UInt8)

@_extern(c, "inb")
func inb(_ port: UInt16) -> UInt8

// MARK: cpuid
@_extern(c, "cpuid_low")
private func cpuid_low(
    leaf: UInt32,
    subleaf: UInt32,
    result: UnsafeMutableRawPointer
)

func cpuidLow(leaf: UInt32, subleaf: UInt32, result: inout CPUIDResult) {
    //logger.log("cpuidLow: calling cpuid_low...")
    unsafe cpuid_low(leaf: leaf, subleaf: subleaf, result: &result)
    //logger.log("cpuidLow: loaded cpuid_low value")
}

struct CPUIDResult {
    var eax:UInt32 = 0
    var ebx:UInt32 = 0
    var ecx:UInt32 = 0
    var edx:UInt32 = 0
}