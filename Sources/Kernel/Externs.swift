
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

@_extern(c, "switch_threads")
func switch_threads(_ old: UnsafeRawPointer, _ new: UnsafeRawPointer)