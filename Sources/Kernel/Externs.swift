
@_extern(c, "cpu_halt")
func cpu_halt()

@_extern(c, "read_rdrand")
func read_rdrand() -> UInt32

@_extern(c, "rdtsc")
func rdtsc() -> UInt32

@_extern(c, "outb")
func outb(_ port: UInt16, _ value: UInt8)

@_extern(c, "inb")
func inb(_ port: UInt16) -> UInt8

@_extern(c, "context_switch")
func context_switch(_ old: UnsafeRawPointer, _ new: UnsafeRawPointer)

// MARK: CR0
@_extern(c, "get_cr0")
func register_CR0() -> UInt32

func isProtectedMode() -> Bool {
    return (register_CR0() & 1) != 0
}
func isPagingEnabled() -> Bool {
    return (register_CR0() & (1 << 31)) != 0
}

// MARK: Extended Feature Enable Register
@_extern(c, "read_efer")
func register_EFE() -> UInt32

func isLongMode() -> Bool {
    return (register_EFE() & (1 << 8)) != 0
}

// MARK: Code Segment register
@_extern(c, "get_cs")
func register_code_segment() -> UInt32

func currentPrivilegeLevel() -> Int {
    // bottom 2 bits = current privilege level
    return Int(register_code_segment() & 0x3)
}