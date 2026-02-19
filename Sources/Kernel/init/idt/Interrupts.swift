
// MARK: Register
// https://wiki.osdev.org/Exceptions
func registerIDTInterrupts() {
    logger.log("IDT: registering interrupts...")

    registerInterrupt(index: 0, handle_exception_division_error)
    logger.log("IDT: registered interrupt: division error")

    registerInterrupt(index: 1, handle_exception_debug)
    logger.log("IDT: registered interrupt: debug")

    registerInterrupt(index: 2, handle_exception_nonmaskable_interrupt)
    logger.log("IDT: registered interrupt: non-maskable interrupt")

    registerInterrupt(index: 3, handle_exception_breakpoint)
    logger.log("IDT: registered interrupt: breakpoint")

    registerInterrupt(index: 4, handle_exception_overflow)
    logger.log("IDT: registered interrupt: overflow")

    registerInterrupt(index: 5, handle_exception_bound_range_exceeded)
    logger.log("IDT: registered interrupt: bound range exceeded")

    registerInterrupt(index: 6, handle_exception_invalid_opcode)
    logger.log("IDT: registered interrupt: invalid opcode")

    registerInterrupt(index: 7, handle_exception_device_not_available)
    logger.log("IDT: registered interrupt: device not available")

    registerInterrupt(index: 8, handle_exception_double_fault)
    logger.log("IDT: registered interrupt: double fault")

    registerInterrupt(index: 10, handle_exception_invalid_tss)
    logger.log("IDT: registered interrupt: invalid tss")

    registerInterrupt(index: 11, handle_exception_segment_not_present)
    logger.log("IDT: registered interrupt: segment not present")

    registerInterrupt(index: 12, handle_exception_stack_segment_fault)
    logger.log("IDT: registered interrupt: stack-segment fault")

    registerInterrupt(index: 13, handle_exception_general_protection_fault)
    logger.log("IDT: registered interrupt: general protection fault")
    
    registerInterrupt(index: 14, handle_exception_page_fault)
    logger.log("IDT: registered interrupt: page fault")

    registerInterrupt(index: 15, handle_exception_15)
    logger.log("IDT: registered interrupt: 15")

    registerInterrupt(index: 16, handle_exception_x87_floating_point_exception)
    logger.log("IDT: registered interrupt: x87 floating-point exception")

    registerInterrupt(index: 17, handle_exception_alignment_check)
    logger.log("IDT: registered interrupt: alignment check")

    registerInterrupt(index: 18, handle_exception_machine_check)
    logger.log("IDT: registered interrupt: machine check")

    registerInterrupt(index: 19, handle_exception_simd_floating_point_exception)
    logger.log("IDT: registered interrupt: SIMD floating-point exception")

    registerInterrupt(index: 20, handle_exception_virtualization_exception)
    logger.log("IDT: registered interrupt: virtualization exception")

    registerInterrupt(index: 21, handle_exception_control_protection_exception)
    logger.log("IDT: registered interrupt: control protection exception")

    registerInterrupt(index: 22, handle_exception_22)
    logger.log("IDT: registered interrupt: 22")

    registerInterrupt(index: 23, handle_exception_23)
    logger.log("IDT: registered interrupt: 23")

    registerInterrupt(index: 24, handle_exception_24)
    logger.log("IDT: registered interrupt: 24")

    registerInterrupt(index: 25, handle_exception_25)
    logger.log("IDT: registered interrupt: 25")

    registerInterrupt(index: 26, handle_exception_26)
    logger.log("IDT: registered interrupt: 26")

    registerInterrupt(index: 27, handle_exception_27)
    logger.log("IDT: registered interrupt: 27")

    registerInterrupt(index: 28, handle_exception_hypervisor_injection_exception)
    logger.log("IDT: registered interrupt: hypervisor injection exception")

    registerInterrupt(index: 29, handle_exception_vmm_communication_exception)
    logger.log("IDT: registered interrupt: VMM communication exception")

    registerInterrupt(index: 30, handle_exception_security_exception)
    logger.log("IDT: registered interrupt: security exception")

    registerInterrupt(index: 31, handle_exception_31)
    logger.log("IDT: registered interrupt: 31")

    registerInterrupt(index: 33, keyboard_handler)
    logger.log("IDT: registered interrupt: 33")

    logger.log("IDT: registered interrupts")
}

// MARK: Externs
@_extern(c, "read_cr2")
private func readFaultAddress() -> UInt64


@_extern(c, "handle_exception_division_error")
private func handle_exception_division_error()

@_extern(c, "handle_exception_debug")
private func handle_exception_debug()

@_extern(c, "handle_exception_nonmaskable_interrupt")
private func handle_exception_nonmaskable_interrupt()

@_extern(c, "handle_exception_breakpoint")
private func handle_exception_breakpoint()

@_extern(c, "handle_exception_overflow")
private func handle_exception_overflow()

@_extern(c, "handle_exception_bound_range_exceeded")
private func handle_exception_bound_range_exceeded()

@_extern(c, "handle_exception_invalid_opcode")
private func handle_exception_invalid_opcode()

@_extern(c, "handle_exception_device_not_available")
private func handle_exception_device_not_available()

@_extern(c, "handle_exception_double_fault")
private func handle_exception_double_fault()

@_extern(c, "handle_exception_invalid_tss")
private func handle_exception_invalid_tss()

@_extern(c, "handle_exception_segment_not_present")
private func handle_exception_segment_not_present()

@_extern(c, "handle_exception_stack_segment_fault")
private func handle_exception_stack_segment_fault()

@_extern(c, "handle_exception_general_protection_fault")
private func handle_exception_general_protection_fault()

@_extern(c, "handle_exception_page_fault")
private func handle_exception_page_fault()

@_extern(c, "handle_exception_15")
private func handle_exception_15()

@_extern(c, "handle_exception_x87_floating_point_exception")
private func handle_exception_x87_floating_point_exception()

@_extern(c, "handle_exception_alignment_check")
private func handle_exception_alignment_check()

@_extern(c, "handle_exception_machine_check")
private func handle_exception_machine_check()

@_extern(c, "handle_exception_simd_floating_point_exception")
private func handle_exception_simd_floating_point_exception()

@_extern(c, "handle_exception_virtualization_exception")
private func handle_exception_virtualization_exception()

@_extern(c, "handle_exception_control_protection_exception")
private func handle_exception_control_protection_exception()

@_extern(c, "handle_exception_22")
private func handle_exception_22()

@_extern(c, "handle_exception_23")
private func handle_exception_23()

@_extern(c, "handle_exception_24")
private func handle_exception_24()

@_extern(c, "handle_exception_25")
private func handle_exception_25()

@_extern(c, "handle_exception_26")
private func handle_exception_26()

@_extern(c, "handle_exception_27")
private func handle_exception_27()

@_extern(c, "handle_exception_hypervisor_injection_exception")
private func handle_exception_hypervisor_injection_exception()

@_extern(c, "handle_exception_vmm_communication_exception")
private func handle_exception_vmm_communication_exception()

@_extern(c, "handle_exception_security_exception")
private func handle_exception_security_exception()

@_extern(c, "handle_exception_31")
private func handle_exception_31()

@_extern(c, "keyboard_handler")
private func keyboard_handler()

private func registerInterrupt(
    index: Int,
    _ closure: @convention(c) () -> Void
) {
    let stubAddr = unsafe UInt64(bitPattern: Int64(
            Int(bitPattern: unsafeBitCast(
                    closure, to: UnsafeRawPointer.self
                )
            )
        )
    )
    unsafe idt[index] = IDTEntry(handler: stubAddr)
}

// MARK: handlers
@_cdecl("handleExceptionDivisionError")
func handleExceptionDivisionError() {
    //let fa = readFaultAddress()
    logger.log("PANIC: division error at address \\(fa)")
    LocalAPIC.endOfInterrupt()
    cpu_halt()
}

@_cdecl("handleExceptionDebug")
func handleExceptionDebug() {
    //let fa = readFaultAddress()
    logger.log("PANIC: debug at address \\(fa)")
    LocalAPIC.endOfInterrupt()
    cpu_halt()
}

@_cdecl("handleExceptionNonmaskableInterrupt")
func handleExceptionNonmaskableInterrupt() {
    //let fa = readFaultAddress()
    logger.log("PANIC: non-maskable interrupt at address \\(fa)")
    LocalAPIC.endOfInterrupt()
    cpu_halt()
}

@_cdecl("handleExceptionBreakpoint")
func handleExceptionBreakpoint() {
    //let fa = readFaultAddress()
    logger.log("PANIC: breakpoint at address \\(fa)")
    LocalAPIC.endOfInterrupt()
    cpu_halt()
}

@_cdecl("handleExceptionOverflow")
func handleExceptionOverflow() {
    //let fa = readFaultAddress()
    logger.log("PANIC: overflow at address \\(fa)")
    LocalAPIC.endOfInterrupt()
    cpu_halt()
}

@_cdecl("handleExceptionBoundRangeExceeded")
func handleExceptionBoundRangeExceeded() {
    //let fa = readFaultAddress()
    logger.log("PANIC: bound range exceeded at address \\(fa)")
    LocalAPIC.endOfInterrupt()
    cpu_halt()
}

@_cdecl("handleExceptionInvalidOpcode")
func handleExceptionInvalidOpcode() {
    //let fa = readFaultAddress()
    logger.log("PANIC: invalid opcode at address \\(fa)")
    LocalAPIC.endOfInterrupt()
    cpu_halt()
}

@_cdecl("handleExceptionDeviceNotAvailable")
func handleExceptionDeviceNotAvailable() {
    //let fa = readFaultAddress()
    logger.log("PANIC: device not available at address \\(fa)")
    LocalAPIC.endOfInterrupt()
    cpu_halt()
}

@_cdecl("handleExceptionDoubleFault")
func handleExceptionDoubleFault() {
    //let fa = readFaultAddress()
    logger.log("PANIC: double fault at address \\(fa)")
    LocalAPIC.endOfInterrupt()
    cpu_halt()
}

@_cdecl("handleExceptionInvalidTSS")
func handleExceptionInvalidTSS() {
    //let fa = readFaultAddress()
    logger.log("PANIC: invalid tss at address \\(fa)")
    LocalAPIC.endOfInterrupt()
    cpu_halt()
}

@_cdecl("handleExceptionSegmentNotPresent")
func handleExceptionSegmentNotPresent() {
    //let fa = readFaultAddress()
    logger.log("PANIC: segment not present at address \\(fa)")
    LocalAPIC.endOfInterrupt()
    cpu_halt()
}

@_cdecl("handleExceptionStackSegmentFault")
func handleExceptionStackSegmentFault() {
    //let fa = readFaultAddress()
    logger.log("PANIC: stack segment fault at address \\(fa)")
    LocalAPIC.endOfInterrupt()
    cpu_halt()
}

@_cdecl("handleExceptionGeneralProtectionFault")
func handleExceptionGeneralProtectionFault() {
    //let fa = readFaultAddress()
    logger.log("PANIC: general protection fault at address \\(fa)")
    LocalAPIC.endOfInterrupt()
    cpu_halt()
}

@_cdecl("handleExceptionPageFault")
func handleExceptionPageFault() {
    //let fa = readFaultAddress()
    logger.log("PANIC: page fault at address \\(fa)")
    LocalAPIC.endOfInterrupt()
    cpu_halt()
}

@_cdecl("handleException15")
func handleException15() {
    //let fa = readFaultAddress()
    logger.log("PANIC: exception 15 at address \\(fa)")
    LocalAPIC.endOfInterrupt()
    cpu_halt()
}

@_cdecl("handleExceptionX87FloatingPointException")
func handleExceptionX87FloatingPointException() {
    //let fa = readFaultAddress()
    logger.log("PANIC: x87 floating-point exception at address \\(fa)")
    LocalAPIC.endOfInterrupt()
    cpu_halt()
}

@_cdecl("handleExceptionAlignmentCheck")
func handleExceptionAlignmentCheck() {
    //let fa = readFaultAddress()
    logger.log("PANIC: alignment check at address \\(fa)")
    LocalAPIC.endOfInterrupt()
    cpu_halt()
}

@_cdecl("handleExceptionMachineCheck")
func handleExceptionMachineCheck() {
    //let fa = readFaultAddress()
    logger.log("PANIC: machine check at address \\(fa)")
    LocalAPIC.endOfInterrupt()
    cpu_halt()
}

@_cdecl("handleExceptionSIMDFloatingPointException")
func handleExceptionSIMDFloatingPointException() {
    //let fa = readFaultAddress()
    logger.log("PANIC: simd floating-point exception at address \\(fa)")
    LocalAPIC.endOfInterrupt()
    cpu_halt()
}

@_cdecl("handleExceptionVirtualizationException")
func handleExceptionVirtualizationException() {
    //let fa = readFaultAddress()
    logger.log("PANIC: virtualization exception at address \\(fa)")
    LocalAPIC.endOfInterrupt()
    cpu_halt()
}

@_cdecl("handleExceptionControlProtectionException")
func handleExceptionControlProtectionException() {
    //let fa = readFaultAddress()
    logger.log("PANIC: control protection exception at address \\(fa)")
    LocalAPIC.endOfInterrupt()
    cpu_halt()
}

@_cdecl("handleException22")
func handleException22() {
    //let fa = readFaultAddress()
    logger.log("PANIC: exception 22 at address \\(fa)")
    LocalAPIC.endOfInterrupt()
    cpu_halt()
}

@_cdecl("handleException23")
func handleException23() {
    //let fa = readFaultAddress()
    logger.log("PANIC: exception 23 at address \\(fa)")
    LocalAPIC.endOfInterrupt()
    cpu_halt()
}

@_cdecl("handleException24")
func handleException24() {
    //let fa = readFaultAddress()
    logger.log("PANIC: exception 24 at address \\(fa)")
    LocalAPIC.endOfInterrupt()
    cpu_halt()
}

@_cdecl("handleException25")
func handleException25() {
    //let fa = readFaultAddress()
    logger.log("PANIC: exception 25 at address \\(fa)")
    LocalAPIC.endOfInterrupt()
    cpu_halt()
}

@_cdecl("handleException26")
func handleException26() {
    //let fa = readFaultAddress()
    logger.log("PANIC: exception 26 at address \\(fa)")
    LocalAPIC.endOfInterrupt()
    cpu_halt()
}

@_cdecl("handleException27")
func handleException27() {
    //let fa = readFaultAddress()
    logger.log("PANIC: exception 27 at address \\(fa)")
    LocalAPIC.endOfInterrupt()
    cpu_halt()
}

@_cdecl("handleExceptionHypervisorInjectionException")
func handleExceptionHypervisorInjectionException() {
    //let fa = readFaultAddress()
    logger.log("PANIC: hypervisor injection exception at address \\(fa)")
    LocalAPIC.endOfInterrupt()
    cpu_halt()
}

@_cdecl("handleExceptionVMMCommunicationException")
func handleExceptionVMMCommunicationException() {
    //let fa = readFaultAddress()
    logger.log("PANIC: vmm communication exception at address \\(fa)")
    LocalAPIC.endOfInterrupt()
    cpu_halt()
}

@_cdecl("handleExceptionSecurityException")
func handleExceptionSecurityException() {
    //let fa = readFaultAddress()
    logger.log("PANIC: security exception at address \\(fa)")
    LocalAPIC.endOfInterrupt()
    cpu_halt()
}

@_cdecl("handleException31")
func handleException31() {
    //let fa = readFaultAddress()
    logger.log("PANIC: exception 31 at address \\(fa)")
    LocalAPIC.endOfInterrupt()
    cpu_halt()
}