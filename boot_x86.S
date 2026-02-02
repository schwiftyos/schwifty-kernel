
# Multiboot2
.set MB2_MAGIC,    0xE85250D6
.set MB2_ARCH,     0 # 0 = i386 (Protected Mode)
.set MB2_LENGTH,   (header_end - header_start)
.set MB2_CHECKSUM, -(MB2_MAGIC + MB2_ARCH + MB2_LENGTH)

# Actual code

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

# Kernel Entry Point
.section .text
.global _start
.code32
_start:
	cli                  # disable interrupts
    mov $stack_top, %esp # setup stack
    push %ebx            # save multiboot pointer for later use

    # flush page tables
    mov $p4_table, %edi
    mov $3072, %ecx      # (4096 * 3) / 4 bytes
    xor %eax, %eax
    rep stosl

    pop %esi             # restore multiboot pointer

    # map P4 to P3
    mov $p3_table, %eax
    or $0b11, %eax
    mov %eax, (p4_table)

    # map P3 to P2
    mov $p2_table, %eax
    or $0b11, %eax
    mov %eax, (p3_table)

    # map P2 to 2MB Huge Pages (identity map first 1GB)
    xor %ecx, %ecx
.map_p2:
    mov %ecx, %eax
    shl $21, %eax
    or $0b10000011, %eax           # (present | writable | huge)

    mov %eax, p2_table(,%ecx,8)    # write the low 32 bits
    movl $0, p2_table + 4(,%ecx,8) # write the high 32 bits as zero

    inc %ecx
    cmp $512, %ecx
    jne .map_p2

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

.global cpu_halt
cpu_halt:
	hlt
	ret

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
    mov %rsi, %rdi       # multiboot pointer
    call kmain
    hlt

# Standard I/O port helpers
.global outb
outb:
    mov %di, %dx  # port
    mov %sil, %al # value
    out %al, %dx
    ret

.global inb
inb:
    mov %di, %dx   # port
    xor %rax, %rax # clear to ensure clean return
    in %dx, %al
    ret

.global read_cr2
read_cr2:
    mov %cr2, %rax
    ret

# IDT helpers
.global load_idtr
load_idtr:
    lidt (%rdi) # rdi contains the pointer to the IDTPointer struct
    ret

# Generic Interrupt Handler Wrapper
.macro INTERRUPT_HANDLER name, swift_func
.global \name
\name:
    # save all registers
    push %rax
    push %rbx
    push %rcx
    push %rdx
    push %rsi
    push %rdi
    push %rsp
    push %rbp
    push %r8
    push %r9
    push %r10
    push %r11
    push %r12
    push %r13
    push %r14
    push %r15

    # call the Swift function
    call \swift_func

    # restore registers
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %r11
    pop %r10
    pop %r9
    pop %r8
    pop %rbp
    pop %rsp
    pop %rdi
    pop %rsi
    pop %rdx
    pop %rcx
    pop %rbx
    pop %rax
    
    # remove the 8-byte error code pushed by the CPU, then return from interrupt
    add $8, %rsp
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

# Page tables
.section .bss
.align 4096
p4_table:
    .skip 4096
p3_table:
    .skip 4096
p2_table:
    .skip 4096

# Stack
.align 16
stack_bottom:
    .skip 16384 # 16 KiB
stack_top:

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
