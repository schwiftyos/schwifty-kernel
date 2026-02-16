
# MARK: Macros





# MARK: Disable Legacy PIC
.macro DISABLE_LEGACY_PIC
    mov $0xFF, %al
    mov $0x21, %dx
    out %al, %dx

    mov $0xFF, %al
    mov $0xA1, %dx
    out %al, %dx
.endm

# MARK: Enable Local APIC
.macro ENABLE_LOCAL_APIC
    mov $0x1B, %ecx
    rdmsr
    or $(1 << 11), %eax
    wrmsr
.endm

# MARK: Save registers
.macro SAVE_REGISTERS
    push %rax
    push %rbx
    push %rcx
    push %rdx
    push %rsi
    push %rdi
    push %rbp
    push %r8
    push %r9
    push %r10
    push %r11
    push %r12
    push %r13
    push %r14
    push %r15
.endm

# MARK: Restore registers
.macro RESTORE_REGISTERS
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %r11
    pop %r10
    pop %r9
    pop %r8
    pop %rbp
    pop %rdi
    pop %rsi
    pop %rdx
    pop %rcx
    pop %rbx
    pop %rax
.endm

# MARK: Align stack before call
.macro STACK_ALIGN_BEFORE_CALL
    and $-16, %rsp # align to 16 bytes
    sub $8, %rsp   # satisfy ABI "16-byte alignment before call"
.endm

# MARK: Generic Interrupt Handler Wrapper
.macro INTERRUPT_HANDLER name, swift_func
.global \name
\name:
    SAVE_REGISTERS

    mov %rsp, %rbx # save original stack pointer
    STACK_ALIGN_BEFORE_CALL

    call \swift_func

    mov %rbx, %rsp # restore original stack pointer
    RESTORE_REGISTERS
    
    add $8, %rsp   # remove the error code
    iretq
.endm

# https://wiki.osdev.org/Exceptions
INTERRUPT_HANDLER handle_exception_division_error, handleExceptionDivisionError
INTERRUPT_HANDLER handle_exception_debug, handleExceptionDebug
INTERRUPT_HANDLER handle_exception_nonmaskable_interrupt, handleExceptionNonmaskableInterrupt
INTERRUPT_HANDLER handle_exception_breakpoint, handleExceptionBreakpoint
INTERRUPT_HANDLER handle_exception_overflow, handleExceptionOverflow
INTERRUPT_HANDLER handle_exception_bound_range_exceeded, handleExceptionBoundRangeExceeded
INTERRUPT_HANDLER handle_exception_invalid_opcode, handleExceptionInvalidOpcode
INTERRUPT_HANDLER handle_exception_device_not_available, handleExceptionDeviceNotAvailable
INTERRUPT_HANDLER handle_exception_double_fault, handleExceptionDoubleFault
INTERRUPT_HANDLER handle_exception_invalid_tss, handleExceptionInvalidTSS
INTERRUPT_HANDLER handle_exception_segment_not_present, handleExceptionSegmentNotPresent
INTERRUPT_HANDLER handle_exception_stack_segment_fault, handleExceptionStackSegmentFault
INTERRUPT_HANDLER handle_exception_general_protection_fault, handleExceptionGeneralProtectionFault
INTERRUPT_HANDLER handle_exception_page_fault, handleExceptionPageFault
INTERRUPT_HANDLER handle_exception_15, handleException15
INTERRUPT_HANDLER handle_exception_x87_floating_point_exception, handleExceptionX87FloatingPointException
INTERRUPT_HANDLER handle_exception_alignment_check, handleExceptionAlignmentCheck
INTERRUPT_HANDLER handle_exception_machine_check, handleExceptionMachineCheck
INTERRUPT_HANDLER handle_exception_simd_floating_point_exception, handleExceptionSIMDFloatingPointException
INTERRUPT_HANDLER handle_exception_virtualization_exception, handleExceptionVirtualizationException
INTERRUPT_HANDLER handle_exception_control_protection_exception, handleExceptionControlProtectionException
INTERRUPT_HANDLER handle_exception_22, handleException22
INTERRUPT_HANDLER handle_exception_23, handleException23
INTERRUPT_HANDLER handle_exception_24, handleException24
INTERRUPT_HANDLER handle_exception_25, handleException25
INTERRUPT_HANDLER handle_exception_26, handleException26
INTERRUPT_HANDLER handle_exception_27, handleException27
INTERRUPT_HANDLER handle_exception_hypervisor_injection_exception, handleExceptionHypervisorInjectionException
INTERRUPT_HANDLER handle_exception_vmm_communication_exception, handleExceptionVMMCommunicationException
INTERRUPT_HANDLER handle_exception_security_exception, handleExceptionSecurityException
INTERRUPT_HANDLER handle_exception_31, handleException31

# Multiboot2
.set MB2_MAGIC,    0xE85250D6
.set MB2_ARCH,     0 # 0 = i386 (Protected Mode)
.set MB2_LENGTH,   (header_end - header_start)
.set MB2_CHECKSUM, -(MB2_MAGIC + MB2_ARCH + MB2_LENGTH)

# MARK: Actual code

# Registers: https://wiki.osdev.org/CPU_Registers_x86-64

.section .multiboot_header
.align 8
.global header_start
header_start:
    .long MB2_MAGIC
    .long MB2_ARCH
    .long MB2_LENGTH
    .long MB2_CHECKSUM

    # Request Framebuffer
    .align 8
    .short 5    # type
    .short 0    # flags
    .long 20    # size
    .long 1024  # width
    .long 768   # height
    .long 32    # depth (RGBA)
    .long 0     # padding to make 8-byte aligned

    # End Tag
    .align 8
    .short 0 # type 0
    .short 0 # flags
    .long 8  # size
.global header_end
header_end:

# MARK: Kernel Entry Point
.section .text
.global _start
.code32
_start:
	cli                  # disable interrupts
    mov $stack_top, %esp # setup stack
    push %ebx            # save multiboot pointer for later use

    DISABLE_LEGACY_PIC

    # setup page tables
    mov $p4_table, %edi
    mov $3072, %ecx      # (4096 * 3) / 4 bytes
    xor %eax, %eax
    rep stosl

    pop %esi             # restore multiboot pointer

    # map P4 to P3
    mov $p3_table, %eax
    or $0b11, %eax
    mov %eax, (p4_table)

    # map P3[0..3] -> p2_tables[0..3]; linking 4 GiB of virtual space
    mov $4, %ecx
    mov $p3_table, %edi
    mov $p2_tables, %eax
.link_p3:
    or $0b11, %eax
    mov %eax, (%edi)
    add $4096, %eax # point to next p2 table
    add $8, %edi    # next p3 entry
    loop .link_p3

    mov $2048, %ecx # map 2048 entries (4 * 512) in the p2_tables to 2 MiB Huge Pages
    xor %ebx, %ebx  # physical address counter
.map_p2_expanded:
    mov %ebx, %eax
    shl $21, %eax
    or $0b10000011, %eax # present | writable | huge

    # use ecx to calculate offset in p2_tables; total entries 2048 - current ecx) * 8
    mov $2048, %edx
    sub %ecx, %edx

    mov %eax, p2_tables(,%edx,8)
    movl $0, p2_tables + 4(,%edx,8)

    inc %ebx
    loop .map_p2_expanded

    # enable Long Mode

    # enable PAE
    mov %cr4, %eax
    or $(1 << 5), %eax
    mov %eax, %cr4

    # load P4 to CR3
    mov $p4_table, %eax
    mov %eax, %cr3

    # set Long Mode bit
    mov $0xC0000080, %ecx
    rdmsr
    or $(1 << 8), %eax
    wrmsr

    # enable paging
    mov %cr0, %eax
    or $(1 << 31), %eax
    mov %eax, %cr0

    # long jump to Long Mode
    lgdt gdt64_pointer
    ljmp $8, $.long_mode_start

# MARK: CPU Halt
.global cpu_halt
cpu_halt:
	hlt
	ret

# MARK: Long Mode
.code64
.long_mode_start:
    # flush data segments
    mov $0x10, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %ss
    mov %ax, %fs
    mov %ax, %gs

    mov $stack_top, %rsp # setup 64-bit stack

    ENABLE_LOCAL_APIC

    mov %rsi, %rdi       # multiboot pointer
    call kinit
    sti                  # enable interrupts
    call kmain

# MARK: I/O port helpers
.global outbyte
outbyte:
    mov %di, %dx  # port
    mov %sil, %al # value
    out %al, %dx
    ret

.global inbyte
inbyte:
    mov %di, %dx # port
    in %dx, %al  # value
    ret

.global outlong
outlong:
    mov %di, %dx   # port
    mov %esi, %eax # value
    out %eax, %dx
    ret

.global inlong
inlong:
    mov %di, %dx # port
    in %dx, %eax # value
    ret

# MARK: Random
.global rdrand
rdrand:
    # hardware might fail to provide a value if the bus is busy; retry up to 10 times
    mov $10, %rcx

.rdrand_retry:
    rdrand %rax         # generate 64-bit random number into RAX
    jc .rdrand_success  # jump if Carry Flag is set (success)
    loop .rdrand_retry  # decrement RCX and jump if not zero

    # failure
    xor %rax, %rax # clear RAX
    xor %rdx, %rdx # rdx = 0 (failure)
    ret

.rdrand_success:
    # swift expects the value in the pointer and a status code
    mov %rax, (%rdi) # store the result in the address passed in RDI
    mov $1, %rax     # return 1 for success
    ret

# MARK: SIMD
.global cpuid_low
cpuid_low:
    push %rbx
    mov %rdx, %r8  # return structure
    mov %rdi, %rax # leaf
    mov %rsi, %rcx # subleaf
    cpuid

    # move results into return structure
    mov %eax, 0(%r8)
    mov %ebx, 4(%r8)
    mov %ecx, 8(%r8)
    mov %edx, 12(%r8)
    pop %rbx
    ret

.global enable_simd_sse
enable_simd_sse:
    mov %cr0, %rax      # enable SSE (CR0.EM = 0, CR0.MP = 1)
    and $0xFFFB, %ax    # clear x87 FPU Emulation (bit 2)
    or $0x2, %ax        # set Monitor co-processor (bit 1)
    mov %rax, %cr0

    mov %cr4, %rax      # enable SSE (CR4.OSFXSR = 1, CR4.OSXMMEXCPT = 1)
    or $(3 << 9), %rax  # set bits 9 and 10
    or $(1 << 18), %rax # enable OSXSAVE

    mov %rax, %cr4
    ret

.global enable_simd_avx
enable_simd_avx:
    # set XCR0 bits via xsetbv
    # bit 0 = x87; 1 = SSE; 2 = AVX
    xor %rcx, %rcx # XCR0 is index 0
    mov $0x7, %eax # bits 0, 1, 2
    xor %edx, %edx # upper 32 bits zero
    xsetbv
    ret

.global enable_simd_avx512
enable_simd_avx512:
    # assuming osxsave was already called
    xor %rcx, %rcx  # XCR0
    
    # bits needed for AVX-512:
    # 0: x87; 1: SSE; 2: AVX; 5: Opmask; 6: ZMM_Hi256; 7: Hi16_ZMM
    mov $0xE7, %eax # 0b11100111
    xor %edx, %edx
    xsetbv
    ret

# MARK: Read CR2
.global read_cr2
read_cr2:
    mov %cr2, %rax
    ret

# MARK: IDT helpers
.global load_idtr
load_idtr:
    lidt (%rdi) # rdi = pointer to the IDTPointer struct
    ret

# MARK: TLV Invalidation (invlpg)
.global invlpg
invlpg:
    # rdi = virtual address to invalidate
    invlpg (%rdi)
    ret

# MARK: Keyboard
.global keyboard_handler
keyboard_handler:
    SAVE_REGISTERS

    mov %rsp, %rbx # save original stack pointer
    STACK_ALIGN_BEFORE_CALL

    mov $33, %rdi
    call keyboard_interrupt_handler

    mov %rbx, %rsp # restore original stack pointer

    RESTORE_REGISTERS
    iretq

# MARK: Page tables
.section .bss
.align 4096
p4_table: .skip 4096
p3_table: .skip 4096
p2_tables: .skip 4096 * 4 # 4 pages, 1 GiB each (4GiB total)

# MARK: Stack
.align 16
stack_bottom:
    .skip 16384 # 16 KiB
stack_top:

# MARK: GDT
.section .rodata
gdt64:
    .quad 0 # null descriptor
    .set CODE_IDX, . - gdt64
    .quad (1<<43) | (1<<44) | (1<<47) | (1<<53) # (executable | descriptor type | present | 64-bit)
    .set DATA_DX, . - gdt64
    .quad (1<<41) | (1<<44) | (1<<47)
gdt64_end:

gdt64_pointer:
    .short gdt64_end - gdt64 - 1
    .quad gdt64
