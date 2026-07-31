
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
    //logger.log(staticString: "cpuidLow: calling cpuid_low...")
    unsafe cpuid_low(leaf: leaf, subleaf: subleaf, result: &result)
    //logger.log(staticString: "cpuidLow: loaded cpuid_low value")
}

func hasRDRANDSupport() -> Bool {
    var result = CPUIDResult()
    cpuidLow(leaf: 1, subleaf: 0, result: &result)
    return (result.ecx & (1 << 30)) != 0
}

struct CPUIDResult {
    var eax:UInt32 = 0
    var ebx:UInt32 = 0
    var ecx:UInt32 = 0
    var edx:UInt32 = 0
}