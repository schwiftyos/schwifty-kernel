
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

.global cpu_halt
cpu_halt:
	hlt
	ret

# Reserve stack space (16KB)
.section .bss
.align 16
stack_bottom:
    .skip 16384 # 16 KiB
stack_top: