
.set MB2_MAGIC,    0xE85250D6
.set MB2_ARCH,     0 # 0 = i386 (Protected Mode)
.set MB2_LENGTH,   (header_end - header_start)
.set MB2_CHECKSUM, -(MB2_MAGIC + MB2_ARCH + MB2_LENGTH)

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
_start:
	cli                  # disable interrupts
	mov $stack_top, %esp # set up the stack 

    push %ebx # Multiboot info
    push %eax # Magic number

	# call the Swift entry point
	call kmain
1:	hlt
	jmp 1b

.global cpu_halt
cpu_halt:
	hlt
	ret

# Standard I/O port helpers
.global outb
outb:
    mov 4(%esp), %dx # port
    mov 8(%esp), %al # value
    out %al, %dx
    ret

.global inb
inb:
    mov 4(%esp), %dx # port
    in %dx, %al
    ret

# GS
.global load_gs
load_gs:
    mov 4(%esp), %ax # load the GDT Selector (e.g., 0x18)
    mov %ax, %gs
    ret

# Return the CR0 register (to check the bit modes)
.global get_cr0
get_cr0:
    mov %eax, %cr0
    ret

# Read Extended Feature Enable register (to check for "Long Mode")
.global read_efer
read_efer:
    mov %ecx, 0xC0000080 # EFER MSR address
    rdmsr                # Reads MSR into EDX:EAX
    ret

# Return the Code Segment register (to check privilege level)
.global get_cs
get_cs:
    mov 0, %eax
    mov %cs, %ax 
    ret

# Context switch
.global context_switch
context_switch:
    # save current thread's state
    push %ebp
    push %ebx
    push %esi
    push %edi

    # switch stacks
    mov 20(%esp), %eax # pointer to old_stack_ptr
    mov %esp, (%eax)   # save current ESP
    mov 24(%esp), %eax # new stack pointer
    mov %eax, %esp     # load new ESP

    # restore new thread's state
    pop %edi
    pop %esi
    pop %ebx
    pop %ebp
    ret

# Read rdrand
.global read_rdrand
read_rdrand:
    rdrand %eax
    jnc read_rdrand # try again if CF=0 (the hardware was busy)
    ret

# rdtsc
.global rdtsc
rdtsc:
    rdtsc # loads EDX:EAX with the 64-bit timestamp
    ret   # Swift will read EAX (the lower 32 bits)

# Reserve stack space (16KB)
.section .bss
.align 16
stack_bottom:
.skip 16384 # 16 KiB
stack_top: