
@_extern(c, "cpu_halt")
func cpu_halt()

// MARK: I/O

@_extern(c, "outb")
func outb(_ port: UInt16, _ value: UInt8)

@_extern(c, "inb")
func inb(_ port: UInt16) -> UInt8